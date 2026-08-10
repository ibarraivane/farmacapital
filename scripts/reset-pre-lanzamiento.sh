#!/usr/bin/env bash
# Ejecuta reset_pre_lanzamiento.sql contra Postgres (Supabase).
#
# Vista previa (solo conteos):
#   bash scripts/reset-pre-lanzamiento.sh
#
# Borrado real (irreversible):
#   CONFIRM=RESTABLECER bash scripts/reset-pre-lanzamiento.sh --execute
#
# Requiere DATABASE_URL o SUPABASE_DB_URL en .env.local o entorno.

set -euo pipefail
cd "$(dirname "$0")/.."

if [[ -f .env.local ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env.local
  set +a
fi

DB_URL="${DATABASE_URL:-${SUPABASE_DB_URL:-}}"
if [[ -z "$DB_URL" ]]; then
  echo "ERROR: define DATABASE_URL o SUPABASE_DB_URL (ej. en .env.local)" >&2
  exit 1
fi

SQL_FILE="sql/reset_pre_lanzamiento.sql"
MODE="${1:-preview}"

echo "── Conteos actuales ──"
psql "$DB_URL" -v ON_ERROR_STOP=1 -At -c "
select tablename || ': ' || n
from (
  select 'pedidos' t, count(*) n from public.pedidos
  union all select 'citas', count(*) from public.citas
  union all select 'productos', count(*) from public.productos
  union all select 'lotes', count(*) from public.lotes
  union all select 'clientes', count(*) from public.clientes
) x(tablename, n)
order by 1;
" 2>/dev/null || psql "$DB_URL" -v ON_ERROR_STOP=1 -f /dev/stdin <<'SQL'
select 'pedidos' as tabla, count(*) from public.pedidos;
select 'citas' as tabla, count(*) from public.citas;
select 'productos' as tabla, count(*) from public.productos;
SQL

if [[ "$MODE" != "--execute" ]]; then
  echo ""
  echo "Modo vista previa. Para borrar todo:"
  echo "  CONFIRM=RESTABLECER bash scripts/reset-pre-lanzamiento.sh --execute"
  exit 0
fi

if [[ "${CONFIRM:-}" != "RESTABLECER" ]]; then
  echo "ERROR: confirma con CONFIRM=RESTABLECER" >&2
  exit 1
fi

echo ""
echo "⚠️  Ejecutando borrado en 5 segundos… Ctrl+C para cancelar"
sleep 5

TMP="$(mktemp)"
# Copia el DO block con v_confirmar := true
awk '
  /v_confirmar[[:space:]]*:=[[:space:]]*boolean[[:space:]]*:=[[:space:]]*false/ {
    sub(/false/, "true")
  }
  { print }
' "$SQL_FILE" > "$TMP"

psql "$DB_URL" -v ON_ERROR_STOP=1 -f "$TMP"
rm -f "$TMP"

echo ""
echo "✓ Reset terminado. Revisa conteos:"
psql "$DB_URL" -v ON_ERROR_STOP=1 -c "
select 'pedidos' t, count(*) n from public.pedidos
union all select 'citas', count(*) from public.citas
union all select 'productos', count(*) from public.productos
union all select 'lotes', count(*) from public.lotes
union all select 'clientes', count(*) from public.clientes
order by 1;
"
