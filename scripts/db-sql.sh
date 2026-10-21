#!/usr/bin/env bash
# Ejecuta un archivo SQL multi-statement contra la base real (wrapper de run-sql).
# Uso: npm run db:sql -- supabase/tests/rls_negativas.sql
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
export SUPA_DB_URL="$(bash scripts/db-env.sh)"
exec node scripts/run-sql.mjs "$@"
