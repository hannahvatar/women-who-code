class OrdersController < ApplicationController
  before_action :set_variant, only: [:new, :create]

  def new
    @order = Order.new
    @total_amount = calculate_total_amount
    Rails.logger.debug "New Order Initialized: #{@order.inspect}, Total: #{@total_amount}"
  end

  def create
    @order = Order.new(order_params)
    @variant = ProductVariant.find(params[:variant_id])
    @order.total_amount = calculate_total_amount

    begin
      if @order.save
        create_order_item
        handle_printify_order
      else
        render_new_with_errors
      end
    rescue => e
      Rails.logger.error("Order creation failed: #{e.message}")
      handle_order_failure(e.message)
    end
  end

  def show
    @order = Order.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = "Order not found"
    redirect_to root_path
  end

  private

  def handle_printify_order
    printify_service = PrintifyService.new
    result = printify_service.send_order_to_printify(@order, test_mode: Rails.env.development?)

    if result[:success]
      redirect_to @order, notice: 'Order was successfully created. Please proceed to payment.'
    else
      @order.update(
        order_status: 'review_needed',
        error_message: result[:error]
      )
      redirect_to @order, alert: 'Order created but needs review. Our team will process it shortly.'
    end
  rescue => e
    Rails.logger.error "Printify Error: #{e.message}"
    @order.update(
      order_status: 'review_needed',
      error_message: e.message
    )
    redirect_to @order, alert: 'Order created but needs review. Our team will process it shortly.'
  end

  def set_variant
    @variant = ProductVariant.find(params[:variant_id])
    Rails.logger.debug "Loaded variant: #{@variant.inspect}"
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "Variant not found: #{e.message}"
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
    unit_price = @variant&.price || @variant&.product&.base_price || 0
    shipping_cost = calculate_shipping_cost

    total = (unit_price * quantity) + shipping_cost
    Rails.logger.debug "Calculated Total: Quantity: #{quantity}, Unit Price: #{unit_price}, Shipping: #{shipping_cost}, Total: #{total}"
    total.round(2)
  end

  def calculate_shipping_cost
    method = params[:order]&.dig(:shipping_method)
    case method
    when 'Standard'
      5.00
    when 'Express'
      10.00
    else
      0.00
    end
  rescue => e
    Rails.logger.error "Error calculating shipping cost: #{e.message}"
    0.00
  end

  def create_order_item
    OrderItem.create!(
      order: @order,
      product_variant: @variant,
      quantity: (params[:quantity] || 1).to_i,
      unit_price: @variant.price
    )
  rescue => e
    Rails.logger.error "Error creating order item: #{e.message}"
    raise
  end

  def send_to_printify
    Rails.logger.info "Sending order data to Printify: #{@order.to_json}"

    printify_service = PrintifyService.new

    begin
      printify_result = printify_service.send_order_to_printify(@order, test_mode: Rails.env.development?)

      if printify_result[:success]
        redirect_to @order, notice: 'Order was successfully created and sent to Printify.'
      else
        handle_printify_error(printify_result[:error])
      end
    rescue => e
      Rails.logger.error "Error sending order to Printify: #{e.message}"
      handle_printify_error(e.message)
    end
  end

  def handle_order_failure(error_message)
    @order.update(order_status: 'failed', error_message: error_message) if @order.persisted?
    render_new_with_errors
  end

  def handle_printify_error(error_message)
    Rails.logger.error "Printify Error: #{error_message}"
    @order.errors.add(:base, "Printify Error: #{error_message}")
    @order.update(order_status: 'failed', error_message: error_message)
    render_new_with_errors
  end

  def render_new_with_errors
    flash.now[:alert] = 'There was an issue creating your order.'
    @total_amount = calculate_total_amount
    render :new, status: :unprocessable_entity
  end
end
