# Tickets Farmacias Guadalajara · 11-sep-2026

**Sucursal:** SN Lorenzo Iztapalapa CDMX · CAJA 2  
**Proveedor canónico:** Farmacias Guadalajara

## Tickets

| Folio | Producto (ticket) | EAN | Costo | PVP sugerido |
|-------|-------------------|-----|-------|--------------|
| **531527** | LENZETTO 1.53MG/DS 6.5ML 56D SOL | `7506352500128` | $578.76 | $724 |
| **AUT-764870** | WEGOVY 1.7MG SOL INY 1 PLUMA/PRE | `7503007822970` | $4,650.00 | $5,813 |

- Lenzetto: FOLIO FACTURA `599104-181830-424489` · FECHA `2026-09-11 15:50` · NO TICKET `531527`.
- Wegovy: misma caja/tarjeta; **NO TICKET no salió en la foto** → folio provisional `AUT-764870` (autorización Bancomer). Corregir en Recibir si aparece el número.

## Catálogo (ficha, no el renglón)

| Nombre mostrador | Marca | Presentación |
|------------------|-------|--------------|
| Lenzetto estradiol 1.53 mg/dosis solución aerosol 6.5 ml (56 dosis) | Lenzetto (Gedeon Richter) | Frasco 6.5 ml |
| Wegovy FlexTouch semaglutida 1.7 mg/dosis pluma 3 ml + 4 agujas | Wegovy (Novo Nordisk) | FlexTouch 3 ml |

Ambos con receta. Wegovy: cadena de frío 2–8 °C.

EAN: SFE/Herrera (Lenzetto 6.5 ml) y tienda Novo Nordisk / Fahorro (Wegovy 1.7 mg). No inventados.

## Cómo correr

1. Pegar `sql/patch_carga_guadalajara_20260911.sql` en Supabase → SQL Editor → Run.
2. En Recibir: dos botones vivos (531527 y AUT-764870). Escanear caja + MMAA. No poner `0000`.
3. Tras deploy Vercel: `sql/patch_fotos_guadalajara_20260911.sql`.

## Archivos

- `sql/generated/ticket_guadalajara_531527.csv`
- `sql/generated/ticket_guadalajara_AUT764870.csv`
- `sql/patch_carga_guadalajara_20260911.sql`
- `sql/patch_fotos_guadalajara_20260911.sql`
- `public/catalogo-propia/lenzetto-1.53mg-6.5ml.jpg`
- `public/catalogo-propia/wegovy-flextouch-1.7mg.jpg`
- `scripts/generar_carga_guadalajara_20260911.py`
