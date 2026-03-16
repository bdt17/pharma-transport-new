#!/bin/bash
# Always-visible navbar + new links
sed -i.bak '/@media (max-width: 768px)/,/}/s/^.nav-links.*/  .nav-links { display: flex !important; }/' pharma_transport.ru

# Add GPS/CoC links to navbar
sed -i.bak '/<a href="\/billing">/a\
      <a href="\/vehicles">🚛 GPS Live<\/a>\
      <a href="\/batches\/123456\/chain-of-custody.pdf" target="_blank">📄 CoC PDF<\/a>' pharma_transport.ru

echo "✅ Navbar fixed - always visible + GPS/CoC links"
pkill -f puma || true
puma pharma_transport.ru -p 9292 -b tcp://0.0.0.0 -e production -t 3:6 --preload
