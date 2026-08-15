# Auditoría campos vacíos — inventario live

Export: `preview_catalogo_campos_y_precios.csv` · **626** productos

| Métrica | Cantidad |
|---------|----------|
| Sin código de barras | 148 |
| Sin presentación | 49 |
| Sin principio activo | 197 |
| **Parches SQL generados** | **6** |
| Barcodes inferidos (fuzzy ticket) | 0 |

El SQL `patch_completar_campos_vacios.sql` solo rellena campos **vacíos**.
No modifica precio, costo, stock ni valores ya capturados.

## Top actualizaciones (FarmaLive / catálogo curado)

| SKU | Nombre | Campos | PA | Presentación |
|-----|--------|--------|-----|--------------|
| FC-06247327 | Afrin No Drip extra humectante | presentacion, principio_activo, concentracion, forma_farmaceutica | Oximetazolina clorhidrato | 15 mL |
| FC-06134531 | Afrin Adulto rojo spray | concentracion | Oximetazolina clorhidrato | 20 mL |
| FC-49853867 | Softlub Extra condones C/3 | principio_activo | Latex | C/3 |
| FC-DB4A39AE | Eferox (Cefalexina) | principio_activo | Cefalexina | 12 COMPRIMIDOS |
| FC-F8691496 | Bactiver F (Sulfametoxazol/Tri | principio_activo | SULFAMETOXAZOL + TRIMETOPRIMA | 16 TABLETAS |

## Sin barcode — requieren ticket/Farma MX manual

Total sin barcode: **148** · Fuzzy puede asignar ~**0**
El resto son Farma MX / IFC / antibióticos sin EAN en OCR del ticket.

### Acción requerida

1. Ejecutar `sql/patch_completar_campos_vacios.sql` en Supabase SQL Editor
2. Recargar pestaña Inventario
3. Los ~47 medicamentos FarmaLive (Vitacilina, XL-3, Nasalub, etc.) quedarán con PA y presentación
