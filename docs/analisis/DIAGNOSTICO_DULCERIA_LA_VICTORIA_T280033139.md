# Ticket Dulcería La Victoria · T280033139

**Fecha:** 2026-09-05 11:33 · Central de Abasto Bodega F-20  
**Total:** $404.89 (tarjeta) · IVA impreso $35.35  
**Clave factura:** LAFAM73305 · WinCaja

## Proveedor: La Victoria, no La Famosa

El ticket imprime **DULCERIA LA FAMOSA** y clave `LAFAM…`, pero:

- Correo del pie: `quejas_ysug@dulcerialavictoria.com.mx`
- Dirección: Calle 15 Zona 1 Bodega F-20 = **Dulcería La Victoria**
- En código: `normalizeProveedorCompra("DULCERIA LA FAMOSA")` → `Dulcería La Victoria`

En Recibir / lotes / reabasto el proveedor es **Dulcería La Victoria**.

## Renglones (1 exhibidor/cuadreta cada uno)

| # | Ticket | Piezas a vender | Costo línea | Costo/pza | PVP sugerido (impulso +40%, ceil) |
|---|--------|-----------------|-------------|-----------|-----------------------------------|
| 1 | SKITTLES ORIGINAL, 24/10PZ | 24 bolsas | 74.60 | 3.1083 | 5 |
| 2 | HALLS YERBA 30/12PZ | 12 packs | 74.00 | 6.1667 | 9 |
| 3 | ORBIT 4P FRESA, 24/40PZ | 40 packs | 87.06 | 2.1765 | 4 |
| 4 | ORBIT 4P HIERBABUENA, 24/40PZ | 40 packs | 87.06 | 2.1765 | 4 |
| 5 | CLORETS 4 S PLUS 24/40PZ | 40 packs | 82.17 | 2.0543 | 3 |

`24/40PZ` = caja master 24 × exhibidor 40 (se compra el exhibidor).  
Halls `30/12` = master 30 × cuadreta 12.  
Skittles `24/10` = caja de 24 bolsas de 10 piezas (se venden las 24 bolsas).

## Pendiente antes de cerrar altas

El ticket **no trae EAN**. No inventar códigos.

1. Foto del código de barras de cada pieza (bolsa Skittles, pack Halls, Orbit 4’s, Clorets).
2. Packshot de mostrador → `public/catalogo-propia/` si la URL es frágil.
3. Correr `sql/patch_carga_dulceria_victoria_T280033139.sql` en Supabase (crea cola Recibir; stock al escanear + MMAA).
4. Caducidad: de la caja (MMAA). No poner `0000`.

## Archivos

- `sql/generated/ticket_dulceria_victoria_T280033139.csv`
- `sql/patch_carga_dulceria_victoria_T280033139.sql`
