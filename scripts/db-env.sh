#!/usr/bin/env bash
# Exporta la cadena SUPA_DB_URL para herramientas que conectan directo a la base
# (gen types, run-sql, db push/advisors). Lee las credenciales de .env y NO imprime
# nada sensible con los valores a la vista: la cadena va a stdout para capurarla
# en la variable del shell.
#
# Uso (solo en sesiones de agente; nunca con las credenciales en pantalla):
#   export SUPA_DB_URL="$(bash scripts/db-env.sh)"
#   node scripts/run-sql.mjs supabase/tests/rls_negativas.sql
#   npx supabase db push --db-url "$SUPA_DB_URL" --yes
#   npx supabase gen types typescript --db-url "$SUPA_DB_URL" --schema public > src/lib/db-types.ts
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

if [ ! -f .env ]; then
  echo "falta .env (ver .env.example)" >&2
  exit 1
fi

set -a
# shellcheck disable=SC1091
. ./.env
set +a

python3 - <<'PYEOF'
import os, re, sys, urllib.parse

try:
    url = os.environ["PUBLIC_SUPABASE_URL"]
    pw = os.environ["SUPABASE_DB_PASSWORD"]
except KeyError as e:
    sys.exit(f"falta {e} en .env")

m = re.match(r"https://([a-z0-9]+)\.supabase\.co", url)
if not m:
    sys.exit("PUBLIC_SUPABASE_URL no matchea el formato esperado")
ref = m.group(1)
print(f"postgresql://postgres:{urllib.parse.quote(pw, safe='')}@db.{ref}.supabase.co:5432/postgres")
PYEOF
