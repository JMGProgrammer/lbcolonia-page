#!/usr/bin/env bash
# Aplica las migraciones locales pendientes contra la base real. Requiere .env.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
export SUPA_DB_URL="$(bash scripts/db-env.sh)"
npx supabase db push --db-url "$SUPA_DB_URL" --yes
echo "migraciones aplicadas con éxito"
