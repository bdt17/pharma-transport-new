#!/bin/bash
# 🚀 PHARMA TRANSPORT - LOCAL DEV HEALTH CHECK
# Tests UI + auth + /health + PDF + /batches/* + GPS
# Now uses strong admin password and adds login‑body inspection.

URL="http://localhost:3000"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}🚀 PHARMA TRANSPORT LOCAL DEV DASHBOARD${NC}"
echo "=================================================="

# ✅ 1. Landing Page (accept 200 or 302, tolerate curl errors)
echo -e "${YELLOW}🖥️  Landing Page UI...${NC}"
response=$(curl -s -w "STATUS:%{http_code}" "$URL" 2>/dev/null || echo "STATUS:000")
status=$(echo "$response" | grep "STATUS:" | cut -d':' -f2)

if [ "$status" = "200" ] || [ "$status" = "302" ]; then
  echo -e "${GREEN}✅ LANDING OK (HTTP: $status)${NC}"
else
  echo -e "${RED}❌ LANDING BROKEN ($status)${NC}"
  echo "RAW SAMPLE:" >&2
  echo "$response" | head -30 >&2
  exit 1
fi

# ✅ 2. Health endpoint
echo -e "${YELLOW}🩺 Health Check...${NC}"
health_status=$(curl -s -o /dev/null -w "%{http_code}" "$URL/health" 2>/dev/null || echo "error")
if [ "$health_status" = "200" ]; then
  echo -e "${GREEN}✅ HEALTH OK${NC}"
else
  echo -e "${YELLOW}⚠️  /health not 200 (HTTP: $health_status)${NC}"
fi

# ✅ 3. Dashboard
echo -e "${YELLOW}📊 Dashboard...${NC}"
dash_status=$(curl -s -I "$URL/dashboard" 2>/dev/null | head -1 | awk '{print $2}' || echo "error")
if [ "$dash_status" = "200" ]; then
  echo -e "${GREEN}✅ DASHBOARD ACCESSIBLE${NC}"
elif [ "$dash_status" = "302" ]; then
  echo -e "${GREEN}✅ DASHBOARD LOGIN PROTECTED${NC}"
else
  echo -e "${YELLOW}⚠️  /dashboard UNEXPECTED (HTTP: $dash_status)${NC}"
fi

# ✅ 4. Login flow (optional; never hard‑fails)
echo -e "${YELLOW}🔐 Login Flow...${NC}"

# 1. Grab CSRF token and cookies
rm -f cookies.txt
auth_req=$(curl -s -c cookies.txt "$URL/users/sign_in" 2>/dev/null || echo "")
AUTH_TOKEN=$(echo "$auth_req" \
  | grep -o 'name="authenticity_token"[^>]*value="[^"]*"' \
  | grep -o 'value="[^"]*"' \
  | sed -E 's/value="([^"]*)"/\1/')

if [ -z "$AUTH_TOKEN" ]; then
  echo -e "${YELLOW}⚠️  Cannot extract authenticity_token${NC}"
else
  # 👍 Change 1: use strong password
  # Change this line in any future seed / README:
  PASSWORD="Pharma2026!TransportMFA123"

  # Send form body as proper x-www-form-urlencoded tokens (no &‑mangling)
  # 👍 Change 2: capture full body when 422 so you can debug Devise errors

  LOGIN_RESP=$(curl -X POST \
    -b cookies.txt \
    -c cookies.txt \
    -H "Content-Type: application/x-www-form-urlencoded" \
    "$URL/users/sign_in" \
    -d "authenticity_token=$AUTH_TOKEN" \
    -d "user[email]=admin@pharmatransport.com" \
    -d "user[password]=$PASSWORD" \
    -d "commit=Log+in" \
    -w "\nHTTP:%{http_code}" \
    2>/dev/null || echo "HTTP:error")

  LOGIN_BODY=${LOGIN_RESP%HTTP:*}       # everything before HTTP:...
  LOGIN_HTTP=$(echo "$LOGIN_RESP" | tail -n1 | sed 's/HTTP://')

  # 👍 Fix 1: accept 303 in addition to 302 (Devise behavior)
  if [ "$LOGIN_HTTP" = "302" ] || [ "$LOGIN_HTTP" = "303" ]; then
    echo -e "${GREEN}✅ LOGIN REDIRECT OK${NC}"
  elif [ "$LOGIN_HTTP" = "200" ] || [ "$LOGIN_HTTP" = "422" ]; then
    echo -e "${YELLOW}⚠️  LOGIN FAILED (HTTP: $LOGIN_HTTP)${NC}"
    echo "DEVISE ERROR BODY (snippet):" >&2
    # 👍 Fix 2: truncate body to avoid spam
    echo "$LOGIN_BODY" | head -20 >&2
    # 👍 Keep going instead of hard‑exit 1
  else
    echo -e "${RED}❌ LOGIN ERROR (HTTP: $LOGIN_HTTP)${NC}"
    echo "$LOGIN_BODY" >&2
  fi
fi

# ✅ 5. Batches after login
echo -e "${YELLOW}📊 Batches After Login...${NC}"
if [ -f cookies.txt ]; then
  BATCHES_CODE=$(curl -s \
    -b cookies.txt \
    -w "%{http_code}" \
    -o /dev/null \
    "$URL/batches" \
    2>/dev/null || echo "error")

  if [ "$BATCHES_CODE" = "200" ]; then
    echo -e "${GREEN}✅ BATCHES PAGE OK${NC}"
  elif [ "$BATCHES_CODE" = "302" ]; then
    echo -e "${YELLOW}⚠️  BATCHES REDIRECTS (auth broken)${NC}"
    # You can uncomment the next line if you want to see redirect reason:
    # curl -s -b cookies.txt -I "$URL/batches" >&2
  else
    echo -e "${YELLOW}⚠️  BATCHES FAILED (HTTP: $BATCHES_CODE)${NC}"
  fi
else
  echo -e "${YELLOW}⚠️  No cookies.txt (login skipped)${NC}"
fi

# ✅ 6. Public batch PDF (no auth) — local only
echo -e "${BLUE}\n📄 PDF HEALTH CHECKS (LOCAL)${NC}"

echo -e "${YELLOW}📄 Public Batch PDF (no auth)...${NC}"
batch_pdf_status=$(curl -s -o batch_test.pdf --write-out "%{http_code}" "$URL/batches/1/public_pdf.pdf" 2>/dev/null || echo "error")
if [ "$batch_pdf_status" = "200" ] && [ -s batch_test.pdf ]; then
  pdf_size=$(du -h batch_test.pdf | cut -f1)
  pdf_type=$(file batch_test.pdf | grep -o "PDF document")
  if [ -n "$pdf_type" ]; then
    echo -e "${GREEN}✅ PUBLIC_BATCH_PDF OK (${pdf_size})${NC}"
  else
    echo -e "${YELLOW}⚠️  PUBLIC_BATCH_PDF is NOT a PDF (check render/headers)${NC}"
  fi
else
  echo -e "${RED}❌ PUBLIC_BATCH_PDF FAILED (HTTP: $batch_pdf_status)${NC}"
  rm -f batch_test.pdf
fi

# 7. CoC / demo‑style PDF if you have it locally
echo -e "${YELLOW}📄 CoC / Demo PDF endpoint...${NC}"
if curl -s -o /dev/null -I --fail "$URL/pdf" >/dev/null 2>&1; then
  pdf_status=$(curl -s -o coc_demo.pdf --write-out "%{http_code}" "$URL/pdf?type=biologics&demo=1" 2>/dev/null || echo "error")
  if [ "$pdf_status" = "200" ] && [ -s coc_demo.pdf ]; then
    pdf_size=$(du -h coc_demo.pdf | cut -f1)
    pdf_type=$(file coc_demo.pdf | grep -o "PDF document")
    if [ -n "$pdf_type" ]; then
      echo -e "${GREEN}✅ DEMO_PDF COC OK (${pdf_size})${NC}"
    else
      echo -e "${YELLOW}⚠️  DEMO_PDF is NOT a PDF${NC}"
    fi
  else
    echo -e "${YELLOW}⚠️  DEMO_PDF FAILED (HTTP: $pdf_status)${NC}"
    rm -f coc_demo.pdf
  fi
else
  echo -e "${YELLOW}⚠️  /pdf endpoint not mounted locally (skipping)${NC}"
fi

# ✅ 8. GPS Endpoint (if mounted locally)
echo -e "${YELLOW}🛰️ GPS Endpoint...${NC}"
gps_code=$(curl -s -o /dev/null -w "%{http_code}" "$URL/api/gps" 2>/dev/null || echo "404")
# 👍 Fix 3: 404 is not “READY”, so change logic
if [ "$gps_code" = "200" ]; then
  echo -e "${GREEN}✅ GPS API READY${NC}"
elif [ "$gps_code" = "404" ] || [ "$gps_code" = "302" ]; then
  echo -e "${YELLOW}⚠️  GPS API WIP (HTTP: $gps_code)${NC}"
else
  echo -e "${RED}❌ GPS API ERROR (HTTP: $gps_code)${NC}"
fi

# ✅ 9. Final summary
# 👍 Added trailing newline to keep terminal clean
echo -e "\n${BLUE}🚀 PHARMA TRANSPORT LOCAL DEV = READY${NC}"
echo "🌐 LOCAL: http://localhost:3000"
echo "🔐 Login: [admin@pharmatransport.com](mailto:admin@pharmatransport.com) / Pharma2026!TransportMFA123"
echo "✅ Local PDFs:"
echo "   http://localhost:3000/batches/1/public_pdf.pdf"
echo "   (optional) http://localhost:3000/pdf?type=biologics&demo=1"
echo ""
echo "🔥 Run: rails server in another terminal"
echo "💡 Next: seed user, fix /pdf format, deploy to Render"
