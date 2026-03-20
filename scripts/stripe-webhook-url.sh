#!/usr/bin/env bash

APP_URL="https://your-render-app.onrender.com"
ENDPOINT="$APP_URL/stripe/webhook"

echo "💡 Stripe webhook endpoint:"
echo "  $ENDPOINT"

echo ""
echo "👉 Paste this as your Stripe webhook URL in:"
echo "  https://dashboard.stripe.com/test/webhooks"

# Optional: print curl command to ping the webhook
echo ""
echo "🧪 Test webhook route (no payload):"
echo "curl -X POST '$ENDPOINT'"
