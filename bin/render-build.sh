#!/bin/bash
set -e

echo "🌱 Running render-build.sh"

# 1. Install gems
bundle install

# 2. Run migrations
bin/rails db:migrate

# 3. Precompile assets (if you have any)
if [ -f "bin/rails" ]; then
  bin/rails assets:precompile 2>/dev/null || true
fi

echo "✅ Build complete."
