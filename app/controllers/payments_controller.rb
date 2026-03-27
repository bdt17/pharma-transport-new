class PaymentsController < ApplicationController
  def checkout
    @batch_id = params[:batch_id] || 'LOT-INSULIN-PROD'
    
    if ENV['STRIPE_SECRET_KEY']
      Stripe.api_key = ENV['STRIPE_SECRET_KEY']
      @session = Stripe::Checkout::Session.create({
        payment_method_types: ['card'],
        line_items: [{
          price_data: {
            currency: 'usd',
            product_data: {
              name: "Cold Chain Shipment #{@batch_id}",
              description: "21 CFR Part 11 Compliant",
            },
            unit_amount: 5000,  # $50.00
          },
          quantity: 1,
        }],
        mode: 'payment',
        success_url: payments_success_url(batch_id: @batch_id),
        cancel_url: payments_cancel_url,
      })
    end
  end

  def success
    @batch_id = params[:batch_id]
  end

  def cancel
  end

  def webhook
    # Stripe webhook handler (no auth)
    head :ok
  end
end
