#!/usr/bin/env bash

set -e

echo "➡️  Setting up Stripe in Rails..."

# 1. Add Stripe gem
if ! grep -q "stripe" Gemfile; then
  echo "gem 'stripe', '~> 10.0'" >> Gemfile
  bundle install
fi

# 2. Create Stripe initializer
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

# 3. Add Stripe routes
if ! grep -q "payments/checkout" config/routes.rb; then
  cat >> config/routes.rb <<'EOF'

  # PAYMENTS - Stripe Production
  get 'payments/checkout',          to: 'payments#checkout'
  get 'payments/success',           to: 'payments#success'
  get 'payments/cancel',            to: 'payments#cancel'
  post '/stripe/webhook',          to: 'payments#webhook'
EOF
fi

# 4. Generate controller (overwrite if needed)
rails generate controller Payments checkout success cancel webhook --no-test-framework

echo "✅ Stripe wiring done."
echo "Next:"
echo "  1. Run: EDITOR=nano bin/rails credentials:edit -> add Stripe keys"
echo "  2. Optional: symlink scripts/keygen-stripe-creds.sh for a template"
