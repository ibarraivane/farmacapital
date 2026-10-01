# Parches Alfa Medical blancos — caja + piezas por tamaño

## Hecho en línea
Alfa Medical **no publica** código de barras por tamaño. Solo existe:

| Presentación | EAN |
|---|---|
| Caja C/10 mixto (4× 10×10 + 6× 6×8) | `7503014279552` |

## Modelo en FarmaCapital

| Rol | SKU | Código | Uso |
|---|---|---|---|
| Caja sellada | `FC-14279552` | `7503014279552` (fábrica) | Recibir / pistola |
| Pieza grande 10×10 | `FC-01000019` | `2008101000019` (sticker interno) | Venta suelta |
| Pieza chica 6×8 | `FC-68000015` | `2008068000015` (sticker interno) | Venta suelta |

Prefijo `20` = código de tienda (igual que cubrebocas). Imprimir sticker y pegarlo en el contenedor de cada tamaño.

## SQL (orden)

1. https://raw.githubusercontent.com/ibarraivane/farmacapital/cursor/alta-parches-alfa-medical-729b/sql/patch_alta_parches_alfa_medical_7503014279552.sql
2. https://raw.githubusercontent.com/ibarraivane/farmacapital/cursor/alta-parches-alfa-medical-729b/sql/patch_alta_parches_alfa_piezas_tamanos.sql

## Al abrir 1 caja

En Inventario / Lotes (manual):

- caja `FC-14279552` **−1**
- grande `FC-01000019` **+4**
- chico `FC-68000015` **+6**

Pieza: costo $5.32 · PVP $7 (marca +25% sobre costo caja ÷ 10).
