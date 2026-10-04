# Ticket El Surtidor 136447 · 28-sep-2026

Foto térmica (Luis). Pegar `sql/patch_carga_surtidor_136447.sql` en Supabase → SQL Editor → Run.

| Línea | Producto | EAN pistola | Qty | Costo u. | Match |
|-------|----------|-------------|-----|----------|-------|
| 1 | Cloxan Ambroxol 30 mg | `7501573900337` | 2 | $13.38 | ya (FC-1DA570E3) |
| 2 | Glucerna líquido chocolate | `7501033956133` | 3 | $47.50 | ya (FC-33956133) |
| 3 | Glucerna líquido vainilla | `7501033956126` | 4 | $47.50 | ya (FC-33956126) |
| 4 | Glucerna líquido fresa | `7501033956140` | 3 | $47.50 | ya (FC-33956140) |
| 5 | Thealoz Duo | `3662042003059` | 2 | $541.45 | **alta** (FC-42003059) |

**Total ticket:** $1,584.67 · proveedor El Surtidor · Bodega F48

## Notas

- Costo = total de renglón ÷ cantidad (después del descuento del ticket).
- Glucerna vainilla: el ticket truncó a `7501033952` → pistola `7501033956126`.
- Thealoz Duo: recargo marca +25% → PVP sugerido $677 (solo si PVP estaba en 0).
- Sin lote ni caducidad: MMAA de la caja al escanear.
- Fotos en `public/catalogo-propia/` (Thealoz + Glucerna). Tras el deploy, el SQL apunta a `farmacapital.mx/catalogo-propia/…`.
- Orden: 1) merge/deploy de las fotos  2) pegar el SQL en Supabase.
