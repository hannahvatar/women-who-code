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
        allowed_countries: ['US', 'CA', 'FR', 'GB', 'DE', 'IT', 'ES', 'NL',
                          'BE', 'CH', 'SE', 'NO', 'DK', 'FI', 'IE', 'AT',
                          'PT', 'GR']
      },
      shipping_options: [
        {
          shipping_rate_data: {
            type: 'fixed_amount',
            fixed_amount: {
              amount: calculate_shipping_amount(order, 'Standard'),
              currency: 'usd',
            },
            display_name: 'Standard Shipping',
          }
        },
        {
          shipping_rate_data: {
            type: 'fixed_amount',
            fixed_amount: {
              amount: calculate_shipping_amount(order, 'Express'),
              currency: 'usd',
            },
            display_name: 'Express Shipping',
          }
        }
      ]
    )

    order.update(
      checkout_session_id: session.id,
      payment_status: 'processing'
    )

    redirect_to session.url, allow_other_host: true
  end

  def webhook
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = ENV['STRIPE_WEBHOOK_SECRET']

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )

      case event.type
      when 'checkout.session.completed'
        session = event.data.object
        order = Order.find_by(checkout_session_id: session.id)

        if order
          order.update(
            payment_status: 'paid',
            payment_intent_id: session.payment_intent
          )

          # Now send to Printify with payment confirmation
          printify_service = PrintifyService.new
          printify_service.send_order_to_printify(order, paid: true)
        end
      end

      render json: { message: 'Success' }
    rescue => e
      render json: { error: e.message }, status: 400
    end
  end

  private

  def calculate_shipping_amount(order, shipping_method)
    base_costs = {
      'Standard' => {
        'US' => 500,    # $5.00 in cents
        'CA' => 700,    # $7.00 in cents
        'EU' => 1200,   # $12.00 in cents
        'OTHER' => 1500 # $15.00 in cents
      },
      'Express' => {
        'US' => 1000,   # $10.00 in cents
        'CA' => 1500,   # $15.00 in cents
        'EU' => 2500,   # $25.00 in cents
        'OTHER' => 3000 # $30.00 in cents
      }
    }

    eu_countries = ['FR', 'DE', 'IT', 'ES', 'NL', 'BE', 'AT', 'PT', 'GR', 'FI', 'SE', 'DK', 'IE']

    region = if order.country == 'US'
              'US'
            elsif order.country == 'CA'
              'CA'
            elsif eu_countries.include?(order.country)
              'EU'
            else
              'OTHER'
             end

    base_costs.dig(shipping_method, region) || 0
  end
end
