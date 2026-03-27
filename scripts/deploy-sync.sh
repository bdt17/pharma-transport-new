#!/bin/bash
set -e

echo "🔄 PHARMA SAAS DEPLOY SYNC SCRIPT"
echo "================================="

# 1. Pull latest production code
echo "📥 Pulling latest from origin/main..."
git pull origin main

# 2. Clean local caches/logs
echo "🧹 Cleaning local caches..."
rm -rf tmp/cache/ log/development.log
git checkout -- tmp/cache/ log/

# 3. Ensure User model is correct
echo "✅ Fixing User model..."
cat > app/models/user.rb << 'EOF'
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
EOF

# 4. Reset database to match production schema
echo "🔄 Resetting local DB to match production..."
rails db:drop db:create db:migrate db:seed

# 5. Precompile assets for production-like local
echo "⚡ Precompiling assets..."
rails assets:precompile

# 6. Commit local fixes
echo "💾 Committing fixes..."
git add .
git commit -m "DEPLOY SYNC: User model + DB + assets production-ready" || true

# 7. Push to production
echo "🚀 Pushing to Render..."
git push origin main

# 8. Test production endpoints
echo "🧪 Testing production..."
sleep 30  # Wait for Render deploy
curl -s "https://pharma-transport-new.onrender.com/health" | jq
curl -s "https://pharma-transport-new.onrender.com/batches" | head -20
curl -s "https://pharma-transport-new.onrender.com/users/sign_in" | grep -i "email\|password"

echo "🎉 DEPLOY COMPLETE! Visit: https://pharma-transport-new.onrender.com"
echo "📱 Test login → dashboard → pay → PDF workflow"
