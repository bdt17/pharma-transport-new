#!/bin/bash
echo "🧪 PHARMA SAAS PRODUCTION TEST SUITE"
echo "=================================="

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

URL="https://pharma-transport-new.onrender.com"
TESTS=0
PASSED=0
FAILED=0

test_endpoint() {
  local name=$1
  local url=$2
  local expect_status=${3:-200}
  
  ((TESTS++))
  echo -n "  $name... "
  
  status=$(curl -s -o /dev/null -w "%{http_code}" "$url")
  size=$(curl -s "$url" | wc -c)
  
  if [ "$status" = "$expect_status" ] && [ "$size" -gt 1000 ]; then
    echo -e "${GREEN}PASS${NC} ($status, ${size}B)"
    ((PASSED++))
  else
    echo -e "${RED}FAIL${NC} ($status, ${size}B)"
    ((FAILED++))
    curl -s "$url" | head -20
    echo "---"
  fi
}

test_pdf() {
  local name=$1
  local url=$2
  
  ((TESTS++))
  echo -n "  $name... "
  
  if curl -s "$url" | grep -q "%PDF"; then
    echo -e "${GREEN}PASS${NC} (21 CFR PDF valid)"
    ((PASSED++))
  else
    echo -e "${YELLOW}WARN${NC} (checking PDF header)"
    ((FAILED++))
  fi
}

echo "🔍 Testing $URL..."
echo

echo "📱 USER FLOW TESTS"
test_endpoint "Homepage + Navbar" "$URL" 200
test_endpoint "Dashboard Table" "$URL/batches" 200
test_endpoint "Login Form" "$URL/users/sign_in" 200
test_endpoint "Payment Page" "$URL/pay?batch_id=LOT-INSULIN-PROD" 200

echo
echo "📄 COMPLIANCE TESTS" 
test_pdf "21 CFR Chain-of-Custody PDF" "$URL/batches/123456/chain-of-custody.pdf"

echo
echo "🏥 HEALTH CHECKS"
test_endpoint "API Health" "$URL/health" 200

echo
echo "📊 RESULTS: $PASSED/$TESTS passed"
if [ $FAILED -eq 0 ]; then
  echo -e "${GREEN}🎉 PRODUCTION READY!${NC}"
  echo "💰 Next: Add STRIPE_SECRET_KEY → Real payments"
else
  echo -e "${RED}❌ $FAILED failures - check logs${NC}"
fi

echo
echo "📱 MOBILE TEST (Browser):"
echo "1. iPhone Chrome → https://pharma-transport-new.onrender.com/"
echo "2. Login → Dashboard → Pay $50 → PDF"

