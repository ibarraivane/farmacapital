# SQL 2026-09-04 — qué correr y en qué orden

Los dos primeros ya los corriste (4-sep). Siguiente: códigos de barras exactos.

## Ya aplicado

1. **Precios de venta (seguro) — 10 SKUs**  
   `patch_precios_venta_aplicar_20260904.sql`  
   Afrin 113, Amikacina 55, Penipot 31, Clindamicina 135, Listerine 97, Pedialyte 35, Ibupro-Cafe 41, Tropharma 62, Dac 66, Grisi 33.  
   Backup: `productos_precio_backup_20260904`.

2. **Duplicados — 10 liberaciones**  
   `patch_barcodes_duplicados_20260904.sql`  
   Deja el EAN en la tarjeta con más stock; las extras quedan sin código (no se borran).

## Siguiente (Editor de Supabase)

3. **Códigos de barras exactos — 96 SKUs**  
   `patch_barcodes_exactos_20260904.sql`  
   Solo si `codigo_barras` está vacío y el EAN no lo tiene otro SKU. Misma clave Equilibrio → Levic. No inventa códigos.

4. **Laboratorio**  
   `patch_laboratorio_columna_20260904.sql`  
   Un bloque (no 276 updates). Crea la columna y llena FarmaLive por EAN, con o sin dígito verificador.

## Revisión de precios — no es un lote ciego

| Lote | SKUs | Qué hacer |
|---|---|---|
| Seguro (ya corrido) | 10 | Confirmar en Inventario / POS |
| Revisar compra | 12 | **No** pegar a ciegas. Piso arriba de Similares (XL-3, Electrolit, Desenfriol, Contac, Flanax…). Decides: renegociar, no resurtir, o dejar el piso y verse caro |
| Resto del catálogo | ~580 | Siguen en fórmula ×1.30 / ×1.60. Falta mercado de **la misma presentación** y ventas 12 meses para KVI |
| Outliers | 39 | **No correr** `patch_precios_venta_outliers_NO_CORRER_20260904.sql` (otra presentación: Amlodipino $12→$282) |

Opcional, solo si ya revisaste uno por uno: `patch_precios_venta_revisar_compra_20260904.sql` te deja **al piso**, no al min de Similares.

## Algoritmo (código, no SQL)

En el PR de esta rama, aún no en el sitio hasta merge/deploy:

- Referencias: percentil 40 + piso de markup. Si piso > mercado → **Revisar compra** (no −2% del más barato).
- Recibir alta: 60% / 25% **sobre costo** ($10 → $16, no $25).
- El botón «Aplicar N subidas» **no** mete los de revisar compra.

## Rollback de PVP

```sql
update public.productos p
   set precio = b.precio
  from public.productos_precio_backup_20260904 b
 where p.id = b.id;
```
