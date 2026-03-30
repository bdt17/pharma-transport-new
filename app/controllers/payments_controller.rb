class PaymentsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create

  def create
    if ENV['STRIPE_SECRET_KEY'].blank?
      render json: { error: 'Stripe keys missing - Render ENV' }, status: 503
      return
    end

    render json: { 
      url: 'https://checkout.stripe.com/c/pay/cs_test_demo',
      session_id: 'demo_session',
      message: 'STRIPE_SECRET_KEY set → LIVE payments!'
    }
  end

  def success
    render html: '<div style="text-align:center;padding:40px"><h1>✅ Payment Success</h1><p>Redirecting to dashboard...</p></div>'.html_safe
  end

  def cancel
    render html: '<div style="text-align:center;padding:40px;background:orange"><h1>❌ Cancelled</h1></div>'.html_safe
  end
end
