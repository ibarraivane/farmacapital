# Gerber pouch: 4 pza. sin lote PEPS

## Qué pasó

En Inventario la ficha decía «Hay 4 pza. en stock pero sin lote PEPS». Al elegir caducidad (1-may-2027) o Guardar, salía:

`Error al guardar: canceling statement due to statement timeout`

No era un error de la fecha: Postgres cortaba el RPC (`admin_editar_producto` / `admin_guardar_caducidad_producto`) por candado de sesión + `information_schema`.

## Importante

El merge del PR **no** crea el lote. Hay que pegar el SQL en **Supabase → SQL Editor → Run**.
Si Inventario sigue diciendo «sin lote PEPS», el Run no se hizo o falló.

## Qué pegar (en este orden)

1. **Desbloqueo inmediato** (crea el lote de las 4 piezas, caducidad 2027-05-01):

   `sql/patch_gerber_lote_peps_4pza_20261119_SOLO_pegar_esto.sql`

   En Results debe salir al menos una fila con `lote_id` y `fecha_caducidad = 2027-05-01`.
   Si `filas_insertadas_candidatas = 0`, el producto no matcheó: copia el DIAGNOSTICO y avísame.

2. **Arreglo permanente** (para que Guardar / caducidad no vuelvan a timeout):

   `sql/patch_inventario_guardar_sin_timeout_20261119.sql`

Luego recargar Inventario.

## Raw (después del merge a main)

- SOLO lote: `…/main/sql/patch_gerber_lote_peps_4pza_20261119_SOLO_pegar_esto.sql`
- Timeout: `…/main/sql/patch_inventario_guardar_sin_timeout_20261119.sql`
