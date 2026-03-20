class PaymentsController < ApplicationController
  protect_from_forgery except: :webhook

  # Open Stripe Checkout (shipment fee)
  def checkout
    session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: [{
        price_data: {
          currency: 'usd',
          product_data: {
            name: 'Pharma Transport Shipment Fee',
          },
          unit_amount: 50_00,  # $50
        },
        quantity: 1
      }],
      mode: 'payment',
      success_url: payments_success_url,
      cancel_url: payments_cancel_url
    )

    # In your app, store session.id with shipment, etc.
    redirect_to session.url, allow_other_host: true
  end

  def success
    render plain: "Payment succeeded. Shipments are now billable."
  end

  def cancel
    render plain: "Payment canceled."
  end

  # Stripe webhook handler
  def webhook
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    event = nil

    begin
      event = Stripe::Webhook.construct_event(
        payload,
        sig_header,
        Rails.application.credentials.stripe[:webhook_secret]
      )
    rescue JSON::ParserError, Stripe::SignatureVerificationError
      head :bad_request
      return
    end

    Rails.logger.info("Stripe event: #{event.type} (id: #{event.id})")

    case event.type
    when 'checkout.session.completed'
      session = event.data.object
      Rails.logger.info("Handling checkout.session.completed: #{session.id}")
      # In your app, e.g.:
      # Shipment.find_by(stripe_checkout_session_id: session.id)&.update(paid: true, paid_at: Time.current)
    else
      Rails.logger.info("Unhandled event type: #{event.type}")
    end

    head :ok
  end
end
