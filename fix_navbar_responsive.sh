#!/bin/bash
# Mobile-friendly navbar (hamburger on small screens)

# Replace mobile hide with responsive
sed -i.bak '/@media (max-width: 768px)/,/}/c\
@media (max-width: 768px) { \
  .nav-links { position: absolute; top: 100%; left: 0; right: 0; background: #2c5aa0; flex-direction: column; padding: 1rem; display: none; } \
  .nav-links.active { display: flex; } \
  .hamburger { display: block; cursor: pointer; } \
}' pharma_transport.ru

# Add hamburger button to navbar
sed -i.bak '/<a href="\/" class="logo">/a\
    <div class="hamburger">☰</div>' pharma_transport.ru

echo "✅ Responsive navbar + hamburger menu"
pkill -f puma || true
puma pharma_transport.ru -p 9292 -b tcp://0.0.0.0 -e production -t 3:6 --preload
