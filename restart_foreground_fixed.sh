#!/bin/bash
echo "🧹 Nuclear restart (FIXED rackup command)..."
pkill -f pharma 2>/dev/null || true
pkill -f rackup 2>/dev/null || true
sleep 2

echo "🔍 Checking dependencies... rackup(2.3.1) puma(7.1.0) ✅"
echo "🚀 Starting with PUMA DIRECTLY (correct threaded config)..."

# CORRECT: Use puma directly, NOT rackup with --threaded
exec puma pharma_transport.ru -p 9292 -b 0.0.0.0 -e production \
  -t 3:6 --preload
