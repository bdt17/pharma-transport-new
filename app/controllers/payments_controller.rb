class PaymentsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :webhook
  
  def checkout
    @shipment = {
      id: 'SHIP-20260319-001',
      name: 'Insulin Cold Chain Shipment PHX→LAX',
      price: 299.00,
      biologics: ['Insulin 100U', 'Vaccines Lot#456']
    }
  end

  def create_payment_intent
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    
    intent = Stripe::PaymentIntent.create({
      amount: (params[:amount].to_f * 100).to_i,
      currency: 'usd',
      automatic_payment_methods: {
        enabled: true,
      },
      metadata: {
        shipment_id: params[:shipment_id],
        biologics: params[:biologics]
      }
    })
    
    render json: { 
      client_secret: intent.client_secret,
      public_key: ENV['STRIPE_PUBLISHABLE_KEY']
    }
  end

  def webhook
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    
    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, ENV['STRIPE_WEBHOOK_SECRET']
      )
    rescue Stripe::SignatureVerificationError
      head 400
      return
    end
    
    case event.type
    when 'payment_intent.succeeded'
      shipment_id = event.data.object.metadata['shipment_id']
      
      # 21 CFR Part 11 Audit Trail
      AuditTrail.create!(
        user_id: nil, # Anonymous payment
        action: 'stripe_payment_confirmed',
        record_type: 'shipment_payment',
        record_id: shipment_id,
        details: {
          stripe_payment_intent: event.data.object.id,
          amount: event.data.object.amount / 100.0,
          biologics: event.data.object.metadata['biologics']
        }.to_json
      )
    end
    
    head 200
  end
end
