#!/bin/bash
echo "🧹 Nuclear restart..."
pkill -f pharma 2>/dev/null || true
pkill -f rackup 2>/dev/null || true
sleep 2

echo "🔍 Checking dependencies..."
gem list rack puma | grep -E "(rack|puma)" || echo "⚠️  Install: gem install rack puma"

echo "🚀 Starting FOREGROUND (watch for errors)..."
rackup pharma_transport.ru -p 9292 -o 0.0.0.0 --threaded
