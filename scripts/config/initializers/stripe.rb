Rails.configuration.stripe = {
  publishable_key: Rails.application.credentials.stripe[:publishable_key],
  secret_key:      Rails.application.credentials.stripe[:secret_key],
  webhook_secret:  Rails.application.credentials.stripe[:webhook_secret]
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]
