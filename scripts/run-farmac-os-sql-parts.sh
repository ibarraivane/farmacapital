#!/usr/bin/env bash
# Ejecuta en orden todos los fragmentos sql/generated/import_farmac_os_<stamp>_part*.sql
# usando psql (requiere DATABASE_URL de Postgres, ej. cadena del proyecto Supabase).
#
# Uso:
#   export DATABASE_URL='postgresql://postgres.[ref]:[password]@aws-0-[region].pooler.supabase.com:6543/postgres'
#   bash scripts/run-farmac-os-sql-parts.sh 20260429T123456
#
set -euo pipefail
STAMP="${1:?Uso: $0 <stamp>   # ej. 20260429T001108 según manifest.txt}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIR="$ROOT/sql/generated"
if [[ -z "${DATABASE_URL:-}" ]]; then
  echo "Definí DATABASE_URL (cadena Postgres)." >&2
  exit 1
fi
shopt -s nullglob
mapfile -t FILES < <(find "$DIR" -maxdepth 1 -name "import_farmac_os_${STAMP}_part*.sql" | LC_ALL=C sort)
if [[ ${#FILES[@]} -eq 0 ]]; then
  echo "No hay archivos para stamp=${STAMP} en $DIR" >&2
  exit 1
fi
for f in "${FILES[@]}"; do
  echo "→ $(basename "$f")"
  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f "$f"
done
echo "Listo: ${#FILES[@]} archivos ejecutados."
