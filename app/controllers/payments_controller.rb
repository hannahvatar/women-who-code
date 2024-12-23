class PaymentsController < ApplicationController
  def create
    order = Order.find(params[:order_id])

    session = Stripe::Checkout::Session.create(
      customer_email: order.email,
      payment_method_types: ['card'],
      line_items: order.order_items.map { |item|
        {
          price_data: {
            currency: 'usd',
            unit_amount: (item.unit_price * 100).to_i,
            product_data: {
              name: item.product_variant.product.name,
              description: "Size: #{item.product_variant.size.name}, Color: #{item.product_variant.color.name}",
              images: [item.product_variant.image_url].compact
            },
          },
          quantity: item.quantity
        }
      },
      mode: 'payment',
      metadata: {
        order_id: order.id,
        customer_name: "#{order.first_name} #{order.last_name}"
      },
      success_url: order_url(order, status: 'success'),
      cancel_url: order_url(order, status: 'cancel'),
      shipping_address_collection: {
        allowed_countries: ['US'] # Modify the countries as needed
      }
    )

    order.update(
      checkout_session_id: session.id,
      payment_status: 'processing'
    )

    redirect_to session.url, allow_other_host: true
  end
end
