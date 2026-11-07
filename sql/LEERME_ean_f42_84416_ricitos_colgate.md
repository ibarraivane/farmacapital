# Bodega F-42 84416 · EANs faltantes (02-oct-2026)

El ticket **ya está en Recibir**. No vuelvas a pegar `patch_carga_bodega_f42_84416.sql`.

## Qué faltaba para escanear / cerrar

| # | Producto | Ticket | Caja / pistola | SKU |
|---|----------|--------|----------------|-----|
| 46 | Ricitos de Oro Bio-Pure jabón 90 g | sin EAN | `037836050725` | `FC-36050725` |
| 31 | Colgate Total Encías Saludables 250 ml | `7509546666959` (check malo) | `7509546666969` | `FC-46666969` |

## Cómo aplicar

1. Merge/deploy (fotos en `catalogo-propia/`).
2. Pegar **todo** `sql/patch_ean_f42_84416_ricitos_colgate_20261002.sql` en Supabase → Run.
3. En Recibir → **Bodega F-42 / 84416**: escanear los dos; pedir MMAA de la caja (no inventar `0000`).
4. Seguir con los renglones grises que queden y cerrar el ticket.

## Notas

- No uses `7509546666952` (check “arreglado” del OCR): la caja y retailers son `…6969`.
- Costos del ticket: Ricitos $22.325 · Colgate $57.79.
- Johnson's Kids ya tiene su parche aparte (`patch_ean_f42_johnsons_kids_8689.sql`).
