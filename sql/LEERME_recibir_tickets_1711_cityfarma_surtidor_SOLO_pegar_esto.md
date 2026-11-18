# Reintento Cityfarma + Surtidor 161448

Los primeros 4 tickets del lote 17-nov pueden haber quedado bien. Este SQL solo reintenta:

| Proveedor | Folio | Total |
|---|---|---|
| Cityfarma Iztapalapa | **15341570** | $6,982.85 |
| El Surtidor | **161448** | $334.00 |

1. Pegar **todo** `sql/patch_recibir_tickets_1711_cityfarma_surtidor_SOLO_pegar_esto.sql`
2. Empieza con `rollback;` (limpia sesión abortada del intento anterior)
3. Run → VERIFICACION con ambos folios en `borrador`
4. Recargar Recibir

Altas endurecidas contra `productos_sku_key` / barcode inactivo.
