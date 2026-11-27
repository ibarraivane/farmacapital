# Nadro folio 6090551411 · 28-sep-2026 · $440.18

Factura CFDI Nadro México Sur · UUID `63A7365A-98A6-4068-83F3-1897395A2AE8` · 4 renglones · 21 piezas.

Subtotal renglones $379.47 + IVA $60.71 = **$440.18**.

## Estado (2026-09-30)

**Aplicado en producción.** Recepción `#119` en borrador con 4 renglones pendientes de pistola.

| EAN pistola | Producto | Piezas | Costo | SKU |
|---|---|---:|---:|---|
| `7501026462245` | Chupón Ternura flor y balón con miel | 18 | $3.10 | `FC-26462078` |
| `4042809591446` | Leukoplast Hypafix 10 cm × 2 m | 1 | $71.63 | `FC-09591446` |
| `650240032431` | Asepxia polvo compacto Canela | 1 | $126.02 | `FC-40032431` |
| `650240032455` | Asepxia BB polvo compacto Natural Mate | 1 | $126.02 | `FC-40032455` |

En Recibir debe salir el botón **Nadro**. Stock 0 hasta escanear + MMAA de la caja (no inventar `0000`).

### Por qué antes no salía

Solo se había corrido `patch_fotos_…` (imagen del chupón). **No** el `patch_carga_…`: sin fila en `recepciones` Recibir queda vacío. El deploy de Vercel no crea tickets.

## Archivos

- `sql/patch_carga_nadro_6090551411.sql` — altas + cola (ya corrido)
- `sql/patch_fotos_nadro_6090551411.sql` — `imagen_url` (ya apuntado)
- `sql/diag_nadro_6090551411.sql` — solo lectura
- Fotos en `public/catalogo-propia/`

EANs pistola (DV de factura inválido): chupón `…6462245`, Hypafix `…591446`.

Regenerar: `python3 scripts/generar_carga_nadro_6090551411.py`
