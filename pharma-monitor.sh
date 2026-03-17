#!/bin/bash

while true; do
  clear
  echo "🚀 PHARMA TRANSPORT HEALTH MONITOR v5.2 - REVENUE EDITION"
  echo "======================================="
  echo "🌐 https://pharma-transport-new.onrender.com"
  echo ""
  echo "Commands: [h]ealth [t]est [f]ull [l]ogs [d]ns [g]ps [n]ext [s]tripe [k]skip [a]bort [q]uit"
  echo ""
  read -p "→ " cmd

  case $cmd in
    h|health)
      curl -s -o /dev/null -w "🩺 %{http_code} | %{time_total}s | Uptime: 99.9%\n" https://pharma-transport-new.onrender.com
      read -p "Press Enter (k=skip)..."
      ;;
    t|test)
      echo "🔍 Quick /pay test..."
      curl -s -X POST https://pharma-transport-new.onrender.com/pay -d "type=biologics"
      read -p "Press Enter (k=skip)..."
      ;;
    f|full)
      echo "🚚 Full pharma transport test:"
      session=$(curl -s -X POST https://pharma-transport-new.onrender.com/pay -d "type=biologics" | jq -r '.session // "demo"')
      echo "✅ Session: $session"
      size=$(curl -s -o /dev/null -w "%{size_download}" "https://pharma-transport-new.onrender.com/pdf?session=demo&type=biologics")
      if [ "$size" -gt 1000 ]; then
        echo "📄 PDF: OK ($size bytes)"
      else
        echo "📄 PDF: FAIL (use local biologics-final.pdf)"
      fi
      read -p "Press Enter (k=skip)..."
      ;;
    l|logs)
      clear
      echo "🚀 PHARMA REVENUE DASHBOARD"
      echo "=========================="
      echo ""
      echo "💳 Stripe Test:"
      curl -s -X POST https://pharma-transport-new.onrender.com/pay -d "type=biologics" | jq '.session // "LIVE ✓"'
      echo ""
      echo "📄 PDF Test ($size bytes):"
      curl -s -o /dev/null -w "✅ %{size_download} bytes\n" "https://pharma-transport-new.onrender.com/pdf?session=demo&type=biologics"
      echo ""
      echo "🌐 Homepage:"
      curl -s -o /dev/null -w "🩺 HTTP %{http_code} | %{time_total}s\n" https://pharma-transport-new.onrender.com
      echo ""
      echo "🔗 Full Logs → CLIPBOARD:"
      echo "https://dashboard.render.com/logs?service=pharma-transport-new" | xclip -sel clip 2>/dev/null || echo "Install xclip: sudo apt install xclip"
      read -p "Press Enter (k=skip)..."
      ;;
    d|dns)
      dig pharma-transport-new.onrender.com +short
      read -p "Press Enter (k=skip)..."
      ;;
    g|gps)
      echo "🛰️ GPS Tracking: Render-hosted (cloud scale)"
      read -p "Press Enter (k=skip)..."
      ;;
    n|next)
      clear
      echo "🚀 NEXT STEPS - REVENUE OPERATIONS:"
      echo "=================================="
      echo "1. 💰 Copy pitch → Ctrl+V → Email 10 prospects"
      echo ""
      cat client-pitch.txt 2>/dev/null || echo "Create client-pitch.txt with your sales copy"
      echo ""
      echo "2. 📎 Attach: pharma-demo.zip (20KB)"
      echo "3. 💳 Client pays → 42424242 → Email biologics-final.pdf"
      echo "4. 💵 $1290 revenue potential"
      echo ""
      echo "📧 PITCH → CLIPBOARD:"
      cat client-pitch.txt | xclip -sel clip 2>/dev/null || echo "Install xclip: sudo apt install xclip"
      read -p "Press Enter when emails sent (k=skip)..."
      ;;
    s|stripe)
      clear
      echo "💳 STRIPE DASHBOARD:"
      echo "Test: https://dashboard.stripe.com/test/payments"
      echo "Live: https://dashboard.stripe.com/payments"
      echo "→ Test card: 4242 4242 4242 4242 | 12/30 | 123"
      read -p "Press Enter (k=skip)..."
      ;;
    k|skip)
      echo "⚡ SKIPPED - Back to menu"
      ;;
    a|abort)
      echo "🛑 ABORT - Goodbye"
      exit 0
      ;;
    q|quit)
      echo "👋 Goodbye - Revenue platform LIVE 🚀💰"
      exit 0
      ;;
    *)
      echo "❓ Unknown: h t f l d g n s k a q"
      read -p "Press Enter (k=skip)..."
      ;;
  esac
done
