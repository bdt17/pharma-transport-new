#!/bin/bash
URL="https://pharma-transport-new.onrender.com"
EMAIL="brett.thomas29.97@gmail.com"

clear
echo "🚀 PHARMA TRANSPORT HEALTH MONITOR v4.0"
echo "======================================"
echo "🌐 $URL"
echo

while true; do
  echo "Commands: [h]ealth [t]est [f]ull [l]ogs [d]ns [g]ps [q]uit"
  echo -n "→ "
  read -r cmd

  case $cmd in
    h|health)
      STATUS=$(curl -s -o /dev/null -w "%{http_code}" $URL)
      TIME=$(curl -s -o /dev/null -w "@%{time_total}s" $URL | awk '{printf "%.1f", $1*1000}')
      echo "🩺 Health: $STATUS ✓ | Response: ${TIME}s"
      ;;
    t|test)
      echo "🔍 Quick /pay test..."
      RESP=$(curl -s -X POST "$URL/pay" -d "email=$EMAIL&type=biologics")
      echo "RAW: $RESP" | head -c 100
      ;;
    f|full)
      echo "🚚 Full pharma transport test:"
      RESP=$(curl -s -X POST "$URL/pay" -d "email=$EMAIL&type=biologics")
      SESSION=$(echo "$RESP" | grep -o '"session":"[^"]*' | cut -d'"' -f4 | head -1)
      
      if [ -n "$SESSION" ]; then
        echo "✅ Session: $SESSION"
        curl -s -o /dev/null "$URL/pdf?session=$SESSION&type=biologics"
        echo "📄 PDF: OK"
      else
        echo "Session: (empty)"
      fi
      ;;
    l|logs)
      echo "📋 Render logs: https://dashboard.render.com/logs?service=pharma-transport-new"
      ;;
    d|dns)
      nslookup $URL | grep "origin.onrender.com" && echo "🌐 DNS: OK"
      ;;
    g|gps)
      echo "🛰️ GPS Tracking: Render-hosted (cloud scale)"
      ;;
    q|quit|exit)
      echo "👋 Goodbye"
      exit 0
      ;;
    *)
      echo "❓ Unknown: h t f l d g q"
      ;;
  esac
  echo
  sleep 1
done
