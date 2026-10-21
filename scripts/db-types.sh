#!/usr/bin/env bash
# Regenera src/lib/db-types.ts desde la base real. Requiere .env.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
export SUPA_DB_URL="$(bash scripts/db-env.sh)"
npx supabase gen types typescript --db-url "$SUPA_DB_URL" --schema public > src/lib/db-types.ts
echo "types regenerados: src/lib/db-types.ts"
