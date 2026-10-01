# Tickets Recibir · 30-sep-2026

Fotos térmicas. Pegar **cada** SQL en Supabase → SQL Editor → Run.
No pegar este `LEERME_*.md`.

| Pedido | Archivo | Piezas | Total |
|--------|---------|--------|-------|
| Baracentro 14438 | `patch_carga_baracentro_14438.sql` | 1 | $95.00 |
| IFC F8 126446 | `patch_carga_ifc_126446.sql` | 38 | $867.00 |
| Dulcería La Victoria T280035422 | `patch_carga_dulceria_victoria_T280035422.sql` | 48 | $149.20 |
| Cityfarma S327411 | `patch_carga_cityfarma_s327411.sql` | 43 | $4,165.25 |
| Equilibrio 446466 | `patch_carga_equilibrio_446466.sql` | 71 | $2,532.66 |
| Bodega F-42 84416 | `patch_carga_bodega_f42_84416.sql` | 128 | $6,972.10 |

## Cantidades / precios (ojo)

- **Costo = P.U. unitario**, nunca el importe del renglón.
- **Dulcería Skittles:** ticket `74.60 × 2 PZA` (cajas 24/10PZ) → **48 bolsas** a **$3.1083**.
- **IFC:** qty = la del ticket (PAQ C/12 = 1 paquete; aceites = piezas sueltas).
- **Equilibrio:** P.U. post-descuento; lote sí; MMAA de la caja.
- **Cityfarma Pasta Lassar:** EAN `7501417006133` (check digit; no `…6138`).
- **F-42 #46** Grisi Ricitos Biopure: EAN cortado entre fotos → sin EAN hasta escanear.

Regenerar: `python3 scripts/generar_carga_tickets_20260930.py`
