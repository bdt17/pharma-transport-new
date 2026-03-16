#!/bin/bash
clear
echo "🚀 PHARMA-CTL v1.2 MASTER DASHBOARD"
echo "=================================="
echo "🩺 Health: $(curl -s -o /dev/null -w '%{http_code}' https://pharma-transport-new.onrender.com)"
echo "🌐 DNS: pharma-dashboard-s4g5.onrender.com → $(dig +short pharma-dashboard-s4g5.onrender.com | head -1)"
echo "🔒 SSL: $(echo | openssl s_client -servername pharma-transport-new.onrender.com -connect pharma-transport-new.onrender.com:443 2>/dev/null | openssl x509 -noout -dates | grep notAfter)"
echo "📊 Git: $(git log --oneline -1)"
echo "👥 Render: $(curl -s https://api.render.com/v1/services/pharma-transport-new/status)"
echo ""
echo "Commands: [h]ealth [d]eploy [a]udit [l]ogs [r]ollback [q]uit"
read -n1 choice
case $choice in h) curl -I https://pharma-transport-new.onrender.com ;; d) git pull && git push ;; q) exit ;; *) ./pharma-ctl.sh ;; esac
