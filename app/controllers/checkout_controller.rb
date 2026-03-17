require 'stripe'

class CheckoutController < ApplicationController
  def show
    # Your existing pharma-ctl.sh /pay works here
    @session_id = params[:session_id] || generate_checkout_session.id
  end

  def create
    Stripe.api_key = ENV['STRIPE_SECRET_KEY'] || 'sk_test_your_key'

    session = Stripe::Checkout::Session.create({
      payment_method_types: ['card'],
      customer_email: 'brett.thomas29.97@gmail.com',
      line_items: [{
        price_data: {
          currency: 'usd',
          product_data: {
            name: 'Pharma Transport Pro - Monthly'
          },
          unit_amount: 9900  # $99.00
        },
        quantity: 1
      }],
      mode: 'payment',
      success_url: "#{request.base_url}/success?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: "#{request.base_url}/pay"
    })

    redirect_to session.url, allow_other_host: true
  end

  private

  def generate_checkout_session
    # For your pharma-ctl.sh compatibility
    Stripe::Checkout::Session.create({
      payment_method_types: ['card'],
      line_items: [{
        price_data: {
          currency: 'usd',
          product_data: { name: 'Pharma Pro' },
          unit_amount: 9900
        },
        quantity: 1
      }],
      mode: 'payment'
    })
  end
end
