# Anexo de datos — diagnóstico 2026-09-04

Fuente: `sql/preview_catalogo_campos_y_precios.csv` (export 14-ago-2026) + tickets en `sql/generated/` + `pricing/importados/import_levic_portal_20260818.csv` + `pricing/reportes/similares_match_2026-09-03.csv`.

Regenerar:

```bash
python3 scripts/diagnostico_pricing_20260904.py
# → pricing/reportes/diagnostico_20260904/
```

---

## 00_resumen.txt (salida del script)

| Métrica | Valor |
|---|---|
| SKUs | 626 |
| Con EAN | 478 (76.4%) |
| Sin EAN | 148 (23.6%) |
| Markup p25 / p50 / p75 / p95 | 30.0% / 41.4% / 60.0% / 60.1% |
| Bin markup 28–45% | 350 |
| Bin markup 55–65% | 183 |
| EAN GS1 México (750, checksum ok) | 381 |
| EAN GS1 otro país | 49 |
| Prefijo 650 interno | 30 |
| Checksum inválido | 8 |
| EAN-8 / 8 dígitos | 9 |
| GTIN-14 caja | 1 |
| EAN duplicados / SKUs afectados | 7 / 17 |
| Con principio activo | 429 |
| PA sucio (categoría, no INN) | 106 |
| Con concentración | 171 (27.3%) |
| Grupos molécula (≥2 SKUs, PA no sucio) | 44 (30 con dispersión ≥25%) |
| SKUs con ref Similares o Del Ahorro | 70 |
| Piso teórico > sugerido min−2% | 20 |
| Candidatos barcode clave/EAN exacto | **110** |
| Candidatos solo por nombre | 0 |
| Sin match de barcode | **38** |
| Líneas de ticket con EAN | 623 |
| Claves portal Levic | 719 |
| Líneas Equilibrio | 481 |

---

## Archivos generados

| Archivo | Contenido |
|---|---|
| `00_resumen.txt` | Conteos |
| `01_item_por_item.csv` | 626 filas: costo, precio, markup, piso, EAN clase, refs, `piso_gt_mercado` |
| `02_barcodes_calidad.csv` | Códigos que no son GS1 MX limpio |
| `03_barcodes_duplicados.csv` | 7 EAN × SKUs |
| `04_cruce_tickets_ean.csv` | 623 líneas con EAN de Nadro/Levic/FarmaLive/Bodega/Surtidor/Cityfarma/Exprezo |
| `05_grupos_molecula.csv` | PA+conc+forma; `dispersion_precio_pct` |
| `06_barcodes_candidatos.csv` | 148 sin código. `aceptado` vacío. **No aplicar en lote.** |
| `07_diagnostico_sku.csv` | **626 filas** con `accion_ean`, `accion_precio`, `accion_principal` |
| `07_resumen_acciones.md` | Conteos por acción |

---

## Cruce Equilibrio → Levic (ejemplo)

Ticket Equilibrio 440393 línea 1: `HIS075` / lote `5M297` / TERFHICID (en pendientes: TERFICHO).  
Portal Levic: `HIS075` → `7502213042325` Terfhicid 40 caps 100 mg, $47.84.

`06_barcodes_candidatos.csv` SKU `FC-F967863B`: `via_match=lote_equilibrio`, `aceptable=candidato_clave_levic`.

Los 38 sin match son casi todos IFC (aceites Mercurio, perillas Edigar, pomadas) + Farma MX `FC producto botiquín` + 3 claves Equilibrio que el portal de ago-18 no trae (`AVT135` Wermy, `BRU106` Celesbitan, `SON136` Acroxil-C).

---

## Prefijo 650 (no borrar)

Aparecen en FarmaLive y en el ticket Exprezo (Alliviax). Ejemplos: XL-3, Tukol-D, Genoprazol, Suerox, Silka, Nasalub, Ultra Bengue, Next. México GS1 es `750`. Estos códigos los lee la pistola; Nadro / Levic / Similares por EAN no. El parche OCR les **añadió** dígito verificador (`650240010712` → `6502400107128`).

---

## Duplicados (snapshot)

| EAN | SKUs (n) |
|---|---|
| `3311000003920` | 5 (Árnica Mercurio) |
| `7501008491074` | 2 (Aspirina / acetilsalicílico) — además checksum inválido |
| + 5 EAN más | 2 cada uno |

El esquema declara `codigo_barras TEXT UNIQUE`. El export tiene colisiones → la constraint no está en producción o se perdió.

---

## Grupos “molécula” — leer con cuidado

`05_grupos_molecula.csv` agrupa por `principio_activo` + concentración + forma. Como el PA está sucio, los grupos más grandes **no son moléculas** (emolientes/crema ×13, jabón ×11, alcohol Dibar ×8). Esos muestran dispersión de presentación (125 ml vs 1 L), no labs distintos del mismo fármaco.

Los grupos útiles para laboratorio son los de INN real (ej. paracetamol + fenilefrina + clorfenamina: XL-3 / Next / Contac, dispersión 54%). Hay que limpiar PA antes de reabastecer por molécula.

---

## Qué no está en este anexo

- Unidades vendidas (no hay export de `pedido_items` en el repo).
- Refs vigentes en `producto_precios_referencia_actual` (las columnas `precio_similares` / `precio_del_ahorro` del snapshot van vacías; se usó el match file de sept-3).
- Lista FarmaCity ~3,487 de la Mac de Claude (no está commiteada). El cruce equivalente aquí es `04_cruce_tickets_ean.csv` + Levic.

---

## SQL para aplicar (tú, en Supabase)

Orden y detalle: [`sql/LEERME_AJUSTE_20260904.md`](../sql/LEERME_AJUSTE_20260904.md)

El algoritmo en la app **ya** sugiere bien. El PVP en BD **no** se tocó hasta que corras `patch_precios_venta_aplicar_20260904.sql` (10 SKUs seguros). Los 39 outliers no se aplican.

## Scripts de export (tú, con `.env` local)

No uses `service_role`. Anon key o SQL Editor.

```bash
python3 scripts/exportar_catalogo_supabase.py
python3 scripts/exportar_referencias_precio.py
python3 scripts/exportar_ventas_sku.py   # sku, unidades, venta_mxn — sin clientes
```

SQL seguro para ventas (SQL Editor → Download CSV):

```sql
select
  i.producto_id,
  p.sku,
  p.nombre,
  sum(i.cantidad) as unidades,
  sum(i.cantidad * i.precio_unitario) as venta_mxn,
  count(distinct i.pedido_id) as tickets
from public.pedido_items i
join public.pedidos d on d.id = i.pedido_id
join public.productos p on p.id = i.producto_id
where d.created_at >= (now() - interval '12 months')
  and coalesce(d.estado, '') not in ('cancelado', 'anulado')
group by 1, 2, 3
order by unidades desc;
```
