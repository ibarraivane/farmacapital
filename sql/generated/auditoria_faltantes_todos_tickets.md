# Auditoría faltantes — todos los tickets PDF

Comparado contra export local del catálogo (no pisa lo que ya tengas en Supabase).

- Líneas únicas por barcode en tickets: **395**
- Ya en catálogo (CSV): **392**
- Faltan insertar: **3**

## SQL generado

`patch_solo_insertar_faltantes.sql` — **INSERT ONLY**: si el barcode o SKU ya existe, `return` sin cambios.

Precio/costo inicial solo en filas nuevas (costo ticket + 35% margen). Ajusta después en inventario.

## Faltantes por ticket

| Ticket | Barcode | Nombre | Presentación | Principio activo | Costo | Qty |
|--------|---------|--------|--------------|------------------|-------|-----|
| FL-080826 | `3543122250276` | Derman Crema 50 g | 50 G | Ácido undecilénico + Undecilenato d | $45.60 | 1 |
| 112558 | `7501033954245` | Pediasure | 236 ML | Suplemento nutricional | $44.00 | 2 |
| FL-080826 | `7501537163266` | Tribedoce Compuesto Amp C/3 | Amp C/3 | Diclofenaco + Complejo B (Tiamina,  | $54.10 | 2 |

## Ya registrados (no se tocan)

Total: 392 productos — el SQL los omite automáticamente.
