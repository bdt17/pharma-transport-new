#!/bin/bash
echo "🩺 PHARMA-CTL HEALTH $(date)"
echo "HTTP: $(curl -s -o /dev/null -w '%{http_code}' https://pharma-transport-new.onrender.com)"
echo "DNS:  $(dig +short pharma-dashboard-s4g5.onrender.com)"
echo "SSL:  $(curl -sI https://pharma-transport-new.onrender.com | grep -i expire)"
echo "Uptime: $(curl -s https://pharma-transport-new.onrender.com/up | jq .uptime 2>/dev/null || echo "OK")"
