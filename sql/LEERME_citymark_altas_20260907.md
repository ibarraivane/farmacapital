# City Mark 20260905 — 71 sin catálogo + stock que no subía

El aviso rojo «71 productos sin registrar» era un fallo de la carga: se armó la cola Recibir y **no** se dieron de alta los EANs. Al escanear, Recibir no crea lote si `pendiente_alta` es true. Esas piezas no entran a stock.

Regla nueva (siempre): `.cursor/rules/ticket-alta-catalogo-obligatoria.mdc`. Un ticket no está cerrado si `pendiente_alta > 0`.

## Qué pegar en Supabase (en este orden)

1. **Si nunca corriste el parche de verde sin stock**  
   `sql/patch_recepcion_verde_sin_stock_20260903.sql`  
   Deja el RPC `recepcion_reparar_stock_huerfanos`. Sin esto, el paso 2 avisa `skipped`.

2. **Altas City Mark + relink de ese folio**  
   `sql/patch_alta_catalogo_citymark_20260905.sql`  
   84 renglones del ticket. Inserta los que falten (los 71 del aviso). Stock 0. No borra lo ya escaneado. PVP = ceil(costo × 1.25).  
   Al final: `siguen_sin_alta` tiene que ser **0**. `pendiente_alta` de ese folio, **0**.

3. **Resto de tickets (Farmalive, Nadro, Levic, Exprezo…)**  
   `sql/patch_recepcion_tickets_relink_stock_20260907.sql`  
   Enlaza cualquier EAN que ya esté en catálogo y entra stock de verdes con MMAA sin lote.  
   El SELECT final lista lo que **sigue** sin alta. Si sale vacío, no faltan productos.

## Cómo ver el stock en Inventario

Busca por marca o nombre de mostrador (no el código del ticket): `speed stick`, `colgate`, `neutrogena`, `savile`, `axe`. La columna Stock sale de los lotes.

Si el alta ya está y el stock es **0**: Recibir todavía no escaneó MMAA de esa caja. El SQL de alta no inventa piezas.

Para cruzar ticket vs anaquel: `sql/verificar_stock_citymark_20260905.sql`

## Después de pegar

- City Mark: vuelve a Recibir. Los 71 ya no salen en ámbar. Escanea caja + MMAA; el stock tiene que subir.
- Si un renglón ya estaba verde con caducidad y no tenía lote, el paso 2/3 lo repara. No hace falta volver a cargar el ticket.
- Si cerraste el ticket con «Guardar» y esas piezas quedaron fuera: el relink deja el renglón listo; escanea de nuevo (no inventamos MMAA).

## Fotos

19 packshots en `public/catalogo-propia/cm-{ean}.jpg` (Open Beauty/Food Facts). El resto queda como TODO de foto: no se inventó imagen. Tras el deploy de Vercel las 19 URLs `https://www.farmacapital.mx/catalogo-propia/cm-….jpg` ya resuelven.

## Otros tickets revisados

| Ticket | ¿Había SQL de altas? | Qué hacer |
|---|---|---|
| City Mark 20260905 | No (solo cola) | Paso 2 |
| Farmalive 12912 | No (cola); EANs ya venían de cargas Farmalive/Saba/Vitacilina | Paso 3 |
| Exprezo 1279718 | Sí, `patch_alta_catalogo_exprezo_14` | Paso 3 |
| Nadro 1658128647824 | Sí, `patch_alta_catalogo_nadro_41` | Paso 3 |
| Nadro 20260901, Cityfarma, Equilibrio, La Mejor, Levic 90121*, IFC, Dulcería | Sí, `patch_carga_*` | Paso 3 |
| Levic 1020554215 | Solo cola; 11 renglones, la mayoría ya tenía SKU | Paso 3 |

Si el paso 3 lista un EAN que no existe, ese es el siguiente alta (ficha del proveedor, no el código del PDF).
