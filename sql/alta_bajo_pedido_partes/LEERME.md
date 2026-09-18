# Alta bajo pedido — trozos para el SQL Editor

El archivo único de 900 KB **no cabe** en Supabase. Por eso `/conseguir` sigue en **111** encargos.

## Opción A — pegar en orden (SQL Editor)

1. `00_staging.sql`
2. `01_filas.sql` … `28_filas.sql` (uno por uno; cada uno dice `commit`)
3. `99_aplicar.sql`

Al final `99` debe devolver algo como:

| bajo_pedido | encargar | cotizar |
|---:|---:|---:|
| ~3300 | ~2700 | ~640 |

Si sigue en ~111, faltó alguna parte o `99` no corrió.

## Opción B — una sola corrida

En Supabase → Settings → Database, copia la URI del **pooler Session** (puerto 6543) y:

```bash
export DATABASE_URL='postgresql://postgres.xxxx:CLAVE@aws-0-xx.pooler.supabase.com:6543/postgres'
node scripts/aplicar-alta-bajo-pedido-pg.js
```

## Comprobar ya

```sql
select
  count(*) filter (where coalesce(bajo_pedido, false)) as bajo_pedido,
  count(*) filter (where coalesce(bajo_pedido, false) and coalesce(precio,0) > 0.01) as encargar
from public.productos;
```
