# Patch inventario completo

Archivo: `patch_inventario_completo.sql`

| Sección | Acciones |
|---------|----------|
| Barcodes corregidos | 2 |
| Metadata forzada | 2 |
| Renombres | 32 |
| Updates campos vacíos | 6 |
| Inserts tickets | 2 |
| Altas manuales | 2 |

## Tribedoce Compuesto grageas

- EAN escaneado: `7501537164713` (C/30 grageas oral — **no estaba en inventario**)
- Distinto de `FC-71829601` (Tribedoce 50000 Amp C/5) y `FC-88947797` (Tribedoce tabletas)
- Alta manual `FC-37164713` — ajustar costo/precio/stock después

## Derman Crema

- Barcode correcto: `3543122250276` (SKU comercial 354312225027)
- El OCR del ticket mezcló la línea de Tempra: `1354312225027] DERMAN CREMA 50`
- El patch anterior de barcodes lo dejó en `7501354312250` (incorrecto)
- Buscar por `354312225027`, `543122250227` o nombre **Derman** tras ejecutar

## Ejecutar

1. Supabase → SQL Editor
2. Pegar y ejecutar `/Users/ibarra/farmacapital/sql/patch_inventario_completo.sql`
3. Recargar pestaña Inventario
