class OrdersController < ApplicationController
  def new
    @order = Order.new
    @variant = ProductVariant.find(params[:variant_id])
  end

  def create
    @order = Order.new(order_params)

    if @order.save
      # Create the order item
      OrderItem.create!(
        order: @order,
        product_variant_id: params[:variant_id],
        quantity: params[:quantity],
        unit_price: ProductVariant.find(params[:variant_id]).price
      )

      redirect_to @order, notice: 'Order was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @order = Order.includes(order_items: { product_variant: [:product, :color, :size] }).find(params[:id])
  end

  private

  def order_params
    params.require(:order).permit(:email, :shipping_address, :phone_number, :shipping_method)
  end
end
