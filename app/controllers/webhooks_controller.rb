class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = ENV['STRIPE_WEBHOOK_SECRET']

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
    rescue JSON::ParserError => e
      render json: { error: e.message }, status: 400
      return
    rescue Stripe::SignatureVerificationError => e
      render json: { error: e.message }, status: 400
      return
    end

    case event.type
    when 'checkout.session.completed'
      handle_checkout_session_completed(event.data.object)
    when 'payment_intent.succeeded'
      handle_payment_intent_succeeded(event.data.object)
    when 'payment_intent.payment_failed'
      handle_payment_intent_failed(event.data.object)
    end

    render json: { message: 'success' }
  end

  private

  def handle_checkout_session_completed(session)
    order = Order.find_by(checkout_session_id: session.id)
    return unless order

    order.update(
      payment_status: 'paid',
      payment_intent_id: session.payment_intent,
      order_status: 'confirmed'
    )
  end

  def handle_payment_intent_succeeded(payment_intent)
    order = Order.find_by(payment_intent_id: payment_intent.id)
    return unless order

    order.update(payment_status: 'paid')
  end

  def handle_payment_intent_failed(payment_intent)
    order = Order.find_by(payment_intent_id: payment_intent.id)
    return unless order

    order.update(
      payment_status: 'failed',
      error_message: payment_intent.last_payment_error&.message
    )
  end
end
