#!/usr/bin/env bash
set -o errexit

echo "=== render-build.sh: starting ==="

echo "Installing Ruby gems..."
bundle install

echo "Precompiling assets..."
bundle exec bin/rails assets:precompile

echo "Deploying..."
bundle exec bin/rails db:migrate

echo "=== render-build.sh: done ==="
