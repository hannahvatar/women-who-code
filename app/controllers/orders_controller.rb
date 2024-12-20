class OrdersController < ApplicationController
  before_action :set_variant, only: [:new, :create]

  def new
    @order = Order.new
    @total_amount = calculate_total_amount
  end

  def create
    @order = Order.new(order_params)
    @order.total_amount = calculate_total_amount
    @order.order_status = 'pending'
    @order.payment_status = 'pending'

    if @order.save
      create_order_item
      send_to_printify
    else
      render_new_with_errors
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
      :first_name, :last_name, :email, :street_address, :apartment,
      :city, :state, :postal_code, :country, :phone_number, :shipping_method
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

  def send_to_printify
    printify_service = PrintifyService.new
    printify_result = printify_service.send_order_to_printify(@order, test_mode: Rails.env.development?)

    Rails.logger.info "Printify Result: #{printify_result.inspect}"

    if printify_result[:success]
      redirect_to @order, notice: 'Order was successfully created and sent to Printify.'
    else
      handle_printify_error(printify_result[:error])
    end
  end

  def handle_printify_error(error_message)
    @order.errors.add(:base, "Printify Error: #{error_message}")
    @order.update(order_status: 'failed')
    render_new_with_errors
  end

  def render_new_with_errors
    flash.now[:alert] = 'There was an issue creating your order.'
    @total_amount = calculate_total_amount
    render :new, status: :unprocessable_entity
  end
end
