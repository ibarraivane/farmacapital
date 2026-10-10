# Correcciones Cyntia (WhatsApp) — 10-oct-2026

Relectura del chat: martes 7-oct (lo que no quedó aplicado) + miércoles 8-oct (Panclasa / Zagapsol / Gabapentina).

Correr en Supabase SQL Editor:

1. `patch_correcciones_cyntia_20261010.sql`

También va en el deploy (JS): par EAN Zagapsol en `src/lib/eanParesConocidos.js`.

## Stock / fichas

| SKU | Producto | Acción |
|---|---|---|
| EQ-SON153 | Nysmoson’s-V C/10 | 1 → 2 (fix N–Z #448 no quedó) |
| FC-9022126 | Metamizol AMSA 1 g/2 ml C/3 amp | 1 → 2 (fix N–Z #448 no quedó) |
| FC-8505126 | Neuralin C/2 amp | 2 → 1 (fix N–Z #448 no quedó) |
| EQ-MAV198 | Oxatech Olanzapina 10 mg C/14 | 3 → 1 + `requiere_receta` (el #447 usó SKU falso `EQ-MAV196`) |
| FC-71800265 | Panclasa 80/80 mg C/20 | 2 → 1 (miércoles «Físico 1») |
| FC-50D044FF | Wermy Gabapentina 300 mg C/15 | EAN/foto correctos; stock 1 → 0 (Miriam $45) |
| FC-759A5EF9 | Wermy Gabapentina 300 mg C/30 | EAN/foto correctos; stock 2 = físico 2 |
| EQ-AVT218 | Zagapsol Amlodipino 5 mg C/10 | EAN pistola `7502209858152` (Levic traía `…0231`); stock 1 ok |

## Gabapentina (cruzada)

Farmacity / caja física:

- `7502240450773` = C/15
- `7502240450780` = C/30

En BD estaban al revés (texto bien, EAN + Rappi mal). El patch intercambia `codigo_barras`, `imagen_url` y filas de `producto_imagenes`.

## Ya OK (no tocar)

Martes ya alineado en vivo: Ideliver 6, Maviglin 3, Namifen 1, Metamizol Alpharma 2, Oxital-C 1, Neomicina/Kaolín 3, Exakta ung. 2, Irbesartán AMSA C/14 = 3, Itoprida 3, Ketorolaco Advance 6, Camber 1, Kurtosil 1, Kenciclen 1.

Precio Exakta $60 vs sticker $224: sigue sin cambiar sin confirmación del dueño.

## Verificación

```sql
select sku, nombre, stock, codigo_barras, left(coalesce(imagen_url,''), 70) as img, requiere_receta
from public.productos
where sku in (
  'EQ-SON153','FC-9022126','FC-8505126','EQ-MAV198','FC-71800265',
  'FC-50D044FF','FC-759A5EF9','EQ-AVT218'
)
order by sku;
```
