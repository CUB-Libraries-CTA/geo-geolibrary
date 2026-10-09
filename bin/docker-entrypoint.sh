#!/bin/sh
set -e

# Ensure the ephemeral SQLite DB is always initialized on pod start.
# sqlite DB is wiped on every pod restart by design —
# Blacklight requires ActiveRecord internally but we persist no user data.
echo "==> Loading database schema..."
bundle exec rails db:schema:load

echo "==> Starting Rails server..."
exec "$@"
