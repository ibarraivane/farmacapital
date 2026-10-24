# Bodega F-42 · 28130 · solo cola Recibir

Si `patch_carga_bodega_f42_28130.sql` (con altas) marca error de SKU/EAN, pega **este**:

`sql/patch_recepcion_bodega_f42_28130_solo_cola.sql`

## Qué hace

- Crea/actualiza la recepción **Bodega F-42 · 28130** en borrador.
- 73 renglones / 110 piezas / total **$5,282.50**.
- **No** inserta ni actualiza `productos` (evita `productos_sku_key` / unique de código).
- Liga por EAN si ya existe; si no, `pendiente_alta`.

## Después

1. Recargar Recibir → botón del ticket.
2. Escanear + MMAA.
3. Los del recuadro rojo (sin catálogo) se dan de alta desde ahí o con un SQL de altas aparte.
