#!/bin/bash
URL="https://pharma-transport-new.onrender.com"

echo "🚀 PHARMA TRANSPORT - PRODUCTION TEST"
echo "===================================="

echo "🩺 Health check..."
curl -s -o /dev/null -w "HTTP: %{http_code}\n" $URL

echo -n "Email (ENTER=brett.thomas29.97@gmail.com): "
read -r email
email=${email:-"brett.thomas29.97@gmail.com"}

echo "💳 Testing /pay endpoint..."
RESP=$(curl -s -X POST "$URL/pay" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "email=${email}&type=biologics")

echo "RAW: $RESP"

# STRIPE URL (priority)
STRIPE_URL=$(echo "$RESP" | grep -o '"url":"[^"]*' | cut -d'"' -f4 | head -1)
# FALLBACK SESSION
SESSION=$(echo "$RESP" | grep -o '"session":"[^"]*' | cut -d'"' -f4 | head -1)

if [ -n "$STRIPE_URL" ]; then
  echo "✅ STRIPE LIVE! 💰💰💰"
  echo "🔗 $STRIPE_URL"
  echo "💳 Test card: 4242 4242 4242 4242 | Any future expiry | Any CVC"
elif [ -n "$SESSION" ]; then
  echo "✅ DEMO MODE"
  curl -s -o "coc_biologics.pdf" "$URL/pdf?session=$SESSION&type=biologics"
  echo "📄 PDF: $(du -h coc_biologics.pdf | cut -f1)"
else
  echo "❌ FAILED. Check Render ENV → STRIPE_SECRET_KEY"
fi
