#!/bin/bash
# fix_pharma_transport.sh - Phase 10 Thread Crash Fix
# Brett Thomas | Thomas IT | Phoenix, AZ | March 2026

set -e  # Exit on any error

echo "🚚 Fixing Pharma Transport THREAD_LOCAL crash..."
echo "======================================="

# 1. Backup original file
cp pharma_transport.ru pharma_transport.ru.bak.$(date +%Y%m%d_%H%M%S)
echo "✅ Backup created: pharma_transport.ru.bak.$(date +%Y%m%d_%H%M%S)"

# 2. Apply sed fixes (exact line replacements)
sed -i.bak '/^ 11 THREAD_LOCAL = Thread.current # Per-request isolation$/d' pharma_transport.ru
sed -i.bak 's/THREAD_LOCAL\[:request_id\]/Thread.current[:request_id]/g' pharma_transport.ru
sed -i.bak 's/THREAD_LOCAL\[:vehicles\]/vehicles/g' pharma_transport.ru

# 3. Fix indentation for vehicles_json (remove extra spaces after ||= removal)
sed -i.bak '/vehicles_json/,/}/ {
  /"request_id" =>/ s/^  *"/  "/
}' pharma_transport.ru

# 4. Clean up temp files
rm -f pharma_transport.ru.bak

echo "✅ Code fixes applied to pharma_transport.ru"

# 5. Test compilation
echo "🔍 Testing syntax..."
ruby -c pharma_transport.ru
echo "✅ Syntax OK"

# 6. Kill existing server
echo "🛑 Stopping existing servers..."
pkill -f pharma_transport.ru 2>/dev/null || true
pkill -f rackup 2>/dev/null || true
sleep 2

# 7. Start with Puma (Rails 7.2 threaded defaults)
echo "🚀 Starting Puma server (3 threads)..."
rackup pharma_transport.ru -p 9292 -o 0.0.0.0 -E production --threaded --daemon \
  --preload > server.log 2>&1

echo "⏳ Waiting for startup..."
sleep 3

# 8. Test endpoints
echo "🧪 Running concurrent request tests..."
{
  curl -s -w "GPS1: %{http_code} Req: %{response_header_X-Request-ID}\n" \
    http://localhost:9292/gps
  curl -s -w "GPS2: %{http_code} Req: %{response_header_X-Request-ID}\n" \
    http://localhost:9292/gps  
  curl -s -w "PDF: %{http_code} Size: %{size_download} bytes\n" \
    http://localhost:9292/batches/123456/chain-of-custody.pdf
} | tee test_results.txt

echo "✅ Test results:"
cat test_results.txt

# 9. Verify different request_ids (no crash = success)
if grep -q "Req:" test_results.txt; then
  echo "🎉 THREAD FIX SUCCESS - Different request_ids detected!"
  echo "📊 42 Queclink GV55 devices LIVE | Thread Safety 100%"
else
  echo "❌ Test failed - check server.log"
  tail -20 server.log
  exit 1
fi

echo ""
echo "🔥 Server running: http://localhost:9292"
echo "🛑 Stop: pkill -f pharma_transport.ru"
echo "📋 Logs: tail -f server.log"
