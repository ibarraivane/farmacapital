# Ticket HS Comercial · T610241957

**Fecha:** 2026-10-24 13:24 (America/Mexico_City) · Central de Abasto Bodega E-17  
**Total:** $396.66 (tarjeta débito) · bruto $430.20 · descuento $33.54 · IVA impreso $10.43  
**Cajero:** 18 Abigail Rodríguez Hernández

## Proveedor: HS Comercial

El ticket imprime **MAYORISTA DE DULCES IZTAPALAPA, S.A. DE C.V.** (RFC `MDI0803131A9`), pero:

- Web / correo: `www.hscomercial.mx` · `domicilio@hscomercial.mx`
- WhatsApp: 55 4412 5724
- En código: `normalizeProveedorCompra("MAYORISTA DE DULCES…")` → `HS Comercial`

## Renglones (1 bolsa/display cada uno → piezas de mostrador)

| # | Ticket | Piezas | Neto línea | Costo/pza | PVP (+40% ceil) | SKU |
|---|--------|--------|------------|-----------|-----------------|-----|
| 1 | `Bimbo BOCADIN Bolsa 12/50pzs` | 50 | $54.95 | $1.0990 | $2 | `FC-HS-BOCADIN50` |
| 2 | `alv.Chiki BOTELLA 32/40pzs` | 40 | $32.46 | $0.8115 | $2 | `FC-HS-CHIKIBOT40` |
| 3 | `wrigley Orbit 4is Menta 24/40pzs` | 40 | $77.45 | $1.9363 | $3 | `FC-LV-ORBITMEN40` |
| 4 | `wrigley Skittles PAQUETE Original 220g` | 10 | $66.39 | $6.6390 | $10 | `FC-HS-SKITTLES220` |
| 5 | `effem m&m CHOCOLATE cafe 32/6pzs` | 6 | $81.14 | $13.5233 | $19 | `FC-HS-MMCAFE6` |
| 6 | `nest.KIT KAT Chunky 40g 12/6pzs` | 6 | $84.27 | $14.0450 | $20 | `FC-HS-KITCHUNKY6` |

`12/50pzs` / `32/40pzs` / `24/40pzs` / `32/6pzs` / `12/6pzs` = el 2.º número es el exhibidor (regla `piezasPorEmpaqueDesdeNombre`).  
Skittles **PAQUETE Original 220g**: sin `N/Mpz` en el papel; ficha HS «paquete con 10 sobres» → **10**.

## Pendiente antes de cerrar altas

El ticket **no trae EAN**. No inventar códigos.

1. Foto del código de barras de cada pieza (Bocadin, Chiki, Orbit 4's, sobre Skittles 220 g, M&M's, Kit Kat Chunky).
2. Packshot de mostrador → `public/catalogo-propia/` si la URL es frágil (sin placeholder de competencia).
3. Correr `sql/patch_carga_hs_comercial_T610241957.sql` en Supabase (cola Recibir; stock al escanear + MMAA).
4. Caducidad: de la caja (MMAA). No poner `0000`.

## Archivos

- `sql/generated/ticket_hs_comercial_T610241957.csv`
- `sql/patch_carga_hs_comercial_T610241957.sql`
- `scripts/generar_carga_hs_comercial_T610241957.py`
