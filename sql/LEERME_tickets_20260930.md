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

## EANs de caja (01-oct) — si la carga ya corrió

Pegar **después** de los `patch_carga_*`:

- `sql/patch_ean_tickets_20260930_ifc_eq.sql`

| SKU viejo | EAN | SKU nuevo | Producto |
|-----------|-----|-----------|----------|
| FC-IFC-CORTA-TRY12 | `6932119800025` | `FC-19800025` | Cortaúñas Try C/12 |
| FC-IFC-CORTA-BOBO12 | `6976824588236` | `FC-24588236` | Cortaúñas Bobo C/12 |
| FC-IFC-PINZA-LADY | `7501370204577` | `FC-70204577` | Curtis Lady 57LC |
| FC-IFC-YOLI-ENCH | `7501370202023` | `FC-70202023` | Yoli enchinador |
| FC-IFC-ALICATA-GDE | `6855265655229` | `FC-65655229` | Alicata / set |
| FC-IFC-MER-RICINO | `3311000001292` | `FC-00001292` | Mercurio ricino 50 ml (ya existía) |
| EQ-AVT195 | `7506624900809` | `FC-24900809` | Tusilen adulto |
| EQ-SER181 | `7501258215947` | `FC-58215947` | **Ruquimax** (hidroxicloroquina) |

No toca costos ni cantidades. Miyako (salvo la 1ª) y aceite de almendras siguen sin EAN de caja.
