# app/controllers/orders_controller.rb
class OrdersController < ApplicationController
  def new
    @order = Order.new
    @variant = ProductVariant.find(params[:variant_id])
    @total_amount = @variant.price * (params[:quantity] || 1).to_i
  end

  def create
    @order = Order.new(order_params)
    @variant = ProductVariant.find(params[:variant_id])
    quantity = params[:quantity].to_i || 1

    # Calculate total amount
    @order.total_amount = @variant.price * quantity

    if @order.save
      # Create the order item
      OrderItem.create!(
        order: @order,
        product_variant_id: params[:variant_id],
        quantity: quantity,
        unit_price: @variant.price
      )

      redirect_to @order, notice: 'Order was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def order_params
    params.require(:order).permit(:email, :shipping_address, :phone_number, :shipping_method)
  end
end
