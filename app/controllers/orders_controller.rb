# app/controllers/orders_controller.rb
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
      redirect_to @order, notice: 'Order was successfully created.'
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
    @variant.product.base_price * quantity  # Make sure you're using base_price if that's what you use in the product page
  end

  def create_order_item
    OrderItem.create!(
      order: @order,
      product_variant: @variant,
      quantity: (params[:quantity] || 1).to_i,
      unit_price: @variant.price
    )
  end
end
