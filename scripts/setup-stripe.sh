#!/usr/bin/env bash

# Add Stripe gem (if not already there)
if ! grep -q "stripe" Gemfile; then
  echo "gem 'stripe', '~> 10.0'" >> Gemfile
  bundle install
fi

# Create Stripe config
if [ ! -f config/initializers/stripe.rb ]; then
  mkdir -p config/initializers
  cat > config/initializers/stripe.rb <<'EOF'
Rails.configuration.stripe = {
  publishable_key: Rails.application.credentials.stripe[:publishable_key],
  secret_key:      Rails.application.credentials.stripe[:secret_key],
  webhook_secret:  Rails.application.credentials.stripe[:webhook_secret]
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]
EOF
fi

# Wire routes (if not already there)
if ! grep -q "payments/checkout" config/routes.rb; then
  cat >> config/routes.rb <<'EOF'

  # PAYMENTS - Stripe Production
  get 'payments/checkout', to: 'payments#checkout'
  post 'payments/create_payment_intent', to: 'payments#create_payment_intent'
  post '/stripe/webhook', to: 'payments#webhook'
EOF
fi

# Create controller (overwrite if needed)
rails generate controller Payments checkout create_payment_intent webhook

echo "✅ Stripe wiring done."
echo "Next:"
echo "  1. Run: EDITOR=nano bin/rails credentials:edit -> paste Stripe test keys"
echo "  2. Edit app/controllers/payments_controller.rb to match your shipment model"
echo "  3. Add a 'Buy' button in your dashboard linking to payments_checkout_path"
