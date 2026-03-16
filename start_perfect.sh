#!/bin/bash
pkill -f puma 2>/dev/null || true
sleep 1
echo "🚀 Puma 7.1.0 FIXED - tcp://0.0.0.0"
puma pharma_transport.ru -p 9292 -b tcp://0.0.0.0 -e production -t 3:6 --preload
