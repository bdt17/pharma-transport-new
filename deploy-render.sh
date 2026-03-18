#!/bin/bash
echo "🚀 PHARMA TRANSPORT - AUTO DEPLOY v2.0"

# 1. Generate secret key
echo "🔑 Generating SECRET_KEY_BASE..."
SECRET_KEY=$(bundle exec rails secret)
echo "✅ SECRET_KEY_BASE generated ($#SECRET_KEY chars)"

# 2. Precompile assets (clean)
echo "⚡ Precompiling assets..."
rm -rf public/assets tmp/cache/assets
RAILS_ENV=production bundle exec rails assets:precompile

# 3. Clean git (ignore tmp/cache)
echo "🧹 Cleaning git..."
git add public/assets/ config/environments/production.rb
git reset tmp/cache/
git checkout -- tmp/cache/
git commit -m "deploy: assets + production config $(date)" || true
git push origin main

echo "✅ Git push complete"

echo "=================================="
echo "📋 COPY THESE TO RENDER ENVIRONMENT:"
echo "RAILS_SERVE_STATIC_FILES=true"
echo "SECRET_KEY_BASE=$SECRET_KEY"
echo "=================================="
echo ""
echo "🎉 NEXT: Render Dashboard → Environment → Paste 2 vars → Manual Deploy"
echo "🌐 TEST: https://pharma-transport-new.onrender.com/"
