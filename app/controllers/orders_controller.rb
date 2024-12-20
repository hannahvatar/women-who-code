class OrdersController < ApplicationController
  before_action :set_variant, only: [:new, :create]

  def new
    @order = Order.new
    @total_amount = calculate_total_amount
  end

  def create
    @order = Order.new(order_params)
    @total_amount = calculate_total_amount

    # Set default values for required fields
    @order.order_status = 'pending'
    @order.payment_status = 'pending'
    @order.total_amount = @total_amount

    if @order.save
      create_order_item
      begin
        # Create order in Printify
        printify_response = create_printify_order

        if printify_response.code == 200
          # Update order with Printify ID
          @order.update(printify_order_id: JSON.parse(printify_response.body)["id"])
          redirect_to @order, notice: 'Order was successfully created.'
        else
          # Log the error for debugging
          Rails.logger.error("Printify API Error: #{printify_response.body}")
          # Handle Printify order creation failure
          @order.destroy # Rollback our local order
          flash.now[:alert] = 'There was an issue creating your order with our printing partner.'
          render :new, status: :unprocessable_entity
        end
      rescue => e
        # Log any unexpected errors
        Rails.logger.error("Printify Order Creation Error: #{e.message}")
        @order.destroy
        flash.now[:alert] = 'An unexpected error occurred while processing your order.'
        render :new, status: :unprocessable_entity
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @order = Order.find(params[:id])
  end

  private

  def set_variant
    @variant = ProductVariant.find(params[:variant_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'Product variant not found'
  end

  def order_params
    params.require(:order).permit(
      :first_name,
      :last_name,
      :email,
      :street_address,
      :apartment,
      :city,
      :postal_code,
      :country,
      :phone_number,
      :shipping_method
    )
  end

  def calculate_total_amount
    quantity = (params[:quantity] || 1).to_i
    @variant.product.base_price * quantity
  end

  def create_order_item
    OrderItem.create!(
      order: @order,
      product_variant: @variant,
      quantity: (params[:quantity] || 1).to_i,
      unit_price: @variant.price
    )
  end

  def create_printify_order
    service = PrintifyService.new

    printify_order_data = {
      external_id: @order.id.to_s,
      shipping_method: @order.shipping_method || 1,
      line_items: [{
        product_id: @variant.product.printify_id,
        variant_id: @variant.printify_variant_id,
        quantity: @order.order_items.first.quantity
      }],
      shipping_address: {
        first_name: @order.first_name,
        last_name: @order.last_name,
        address1: @order.street_address,
        address2: @order.apartment.presence,
        city: @order.city,
        country: @order.country,
        zip: @order.postal_code,
        phone: @order.phone_number,
        email: @order.email
      }
    }

    service.create_order(printify_order_data)
  end
end
