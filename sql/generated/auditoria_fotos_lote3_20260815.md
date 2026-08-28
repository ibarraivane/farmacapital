# Auditoría fotos lote 3 — 2026-08-15

## Carga original (ya ejecutada)

1. `sql/patch_fotos_lote3_RUN_1.sql` — correcciones + altas 01–13
2. `sql/patch_fotos_lote3_RUN_2.sql` — altas 14–26
3. `sql/patch_fotos_lote3_RUN_3.sql` — altas 27–39 + verificación

**Costos:** solo Topron ($153.47) y fix Treda Sanfer ($139.84) con ticket. Resto costo=0 hasta ticket de compra (no PMP caja).

## Error detectado

Las fotos llegan en pares: la primera es la imagen principal del medicamento, la segunda el código de barras del mismo producto. En este lote no siempre se fusionaron. De 44 registros, ~30 quedaron bien y 9 se crearon usando **solo** la foto del código de barras, con nombre inventado. Sus contrapartes quedaron sin EAN.

### Registros fantasma (EAN sin foto principal)

| SKU | EAN | Nombre inventado |
| --- | --- | --- |
| FC-09740435 | 7502009740435 | Producto Maver Reg. 202M2001 |
| FC-24901059 | 7506624901059 | Producto Novag Reg. 410M2016 |
| FC-49022485 | 7501349022485 | Producto PiSA Reg. 423M2005 |
| FC-27426982 | 7502227426982 | Producto Gelpharma Reg. 065M2019 |
| FC-01165397 | 7502001165397 | Producto Sons side panel |
| FC-01165724 | 7502001165724 | Producto Sons side panel alt |
| FC-23111202 | 7502223111202 | Producto Quimpharma Reg. 476M2005 |
| FC-11784029 | 7502211784029 | ML-PRIM Russek side panel |
| FC-09763986 | 7501109763986 | Producto side morado (identificar) |

### Huérfanos (nombre sin EAN)

| SKU | Nombre |
| --- | --- |
| FC-1FFBB505 | Supratex levodropropizina jarabe 120 mL |
| FC-52D2A43A | Zukedib glimepirida 2 mg C/30 |

### Duplicado

ML-PRIM quedó con dos EAN distintos (`7502227427392` y `7502211784029`). Solo uno puede ser correcto.

## Reparación

1. `sql/patch_fix_fotos_lote3_1_DIAGNOSTICO.sql` — solo lecturas. Confirma el estado, detecta si algún nombre bueno fue sobrescrito y lista candidatos de fusión por prefijo GS1.
2. `sql/patch_fix_fotos_lote3_2_REPARAR.sql` — respalda todo en `public.fix_lote3_respaldo`, pone los 9 fantasma en cuarentena (`activo=false`, `visible_tienda=false`, prefijo `[REVISAR-EAN]`, stock a 0 desactivando sus lotes para evitar doble conteo) y crea `public.fix_lote3_fusionar(sku_fantasma, sku_real, sumar_stock)`.

Nada se borra: la cuarentena es reversible desde `fix_lote3_respaldo`.

## Protocolo para los siguientes lotes de fotos

- Foto impar = imagen principal, foto par = código de barras del **mismo** producto.
- Antes de generar SQL se devuelve una tabla de emparejamiento (par N = nombre + EAN) para validación.
- Número de fotos impar, o foto par sin código legible: se detiene y se pregunta.
- Nunca se crea un producto con nombre tipo "Producto X": si falta una mitad, se reporta como pendiente.
