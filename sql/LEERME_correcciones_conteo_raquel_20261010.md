# Correcciones Raquel (WhatsApp) — 10-oct-2026

Incluye el lote 3 del 7-oct (PR #452, aún no aplicado en BD) + el resto del chat.

Correr **después** de que Vercel publique las fotos de este PR:

1. `patch_correcciones_conteo_raquel_20261010.sql`

## Stock / fichas

| SKU | Producto | Acción |
|---|---|---|
| EQ-AMS234 | Pregabalina 150 mg AMSA C/28 | EAN `7501349022935` (pistola) · stock 1 |
| FC-5885E577 | Pabesorag 150/12.5 C/28 | 8 → **11** |
| FC-27870259 | Roxidolin Doxiciclina 100 mg C/10 | SIN LOTES → **1** |
| FC-94600038 | Rumoquin N.F. 215/25/0.75 C/30 | **alta** · EAN `7506494600038` · stock 1 · TODO foto |
| EQ-WER025 | Rosel cápsulas 50/3/300 C/24 | 3 → **4** |
| EQ-WER053 | Rosel Pediátrico 30 ml | 3 → **4** + foto teddy · EAN canónico |
| FC-40451015 | dup Rosel Pediátrico | quitar EAN · stock → 0 (misma caja que EQ-WER053) |
| FC-75354321 | Tylenol 500 mg C/10 | 2 → **4** (físico C/10; el C/20 es otro SKU) |
| EQ-AMS323 | Sertralina 50 mg C/14 | 3 → **2** + `requiere_receta` |
| FC-02772508 | Sucralfato Alivoato/Suanca 1 g C/40 | **alta** · EAN `7503002772508` · stock 3 + foto |

## No tocado a propósito

| Producto | Nota |
|---|---|
| Saridon C/20 (`FC-84095411`) | Stock **4** = 3 cerradas + 1 abierta suelta · OK. Precio $76 vs marca $64 en caja: sin cambio sin confirmación. |
| Rosel infantil 60 ml (`FC-40450230`) | Stock 3 OK. La confusión de imagen era el Pediátrico mostrando la caja de 60 ml. |

## Fotos (este PR)

- `public/catalogo-propia/rosel-pediatrico-30ml-7502240451015.jpg`
- `public/catalogo-propia/sucralfato-alivoato-1g-c40-7503002772508.jpg`

## Verificación

```sql
select sku, nombre, stock, codigo_barras, left(coalesce(imagen_url,''), 70) as img
from public.productos
where sku in (
  'EQ-AMS234','FC-5885E577','FC-27870259','FC-94600038','EQ-WER025',
  'EQ-WER053','FC-40451015','FC-75354321','EQ-AMS323','FC-02772508'
)
order by sku;
```
