#!/bin/bash
echo "🧪 Testing Pharma Compliance PDF..."
curl -s -w "\nHTTP: %{http_code}\nSize: %{size_download} bytes\nTime: %{time_total}s\n" \
  "https://pharma-transport-new.onrender.com/reports/compliance.pdf" -o /tmp/compliance.pdf

if [ $? -eq 0 ] && file /tmp/compliance.pdf | grep -q PDF; then
  echo "✅ Compliance PDF LIVE - $(du -h /tmp/compliance.pdf | cut -f1)"
else
  echo "❌ PDF failed"
fi
