# Accu-Chek · 3 SKUs con precios dueño · 27-sep-2026

Compra total **$681** repartida en tres piezas (costos asignados, no factura línea a línea). PVP dueño con margen bruto ~24.9% si se venden las tres.

| Piezas | EAN | SKU | Nombre mostrador | Costo | PVP | Recargo | Margen |
|---|---|---|---|---|---|---|---|
| 1 | `4015630064076` | `FC-30064076` | Accu-Chek Active | $262 | **$349** | +33.2% | 24.9% |
| 1 | `4015630083855` | `FC-30083855` | Accu-Chek Instant | $300 | **$399** | +33.0% | 24.8% |
| 1 | `4015630018239` | `FC-30018239` | Accu-Chek Softclix | $119 | **$159** | +33.6% | 25.2% |

262 + 300 + 119 = **$681**. 349 + 399 + 159 = **$907**.

## Cajas (fotos del dueño)

1. **Tiras Active 50** — EAN `4015630064076`, REF `07124112047`. La nota de precios decía «tiras Instant»; la caja es **Active**. Instant 50 es otro EAN (`4015630067084`).
2. **Medidor Instant** — GTIN `4015630083855`, REF `09221832020`, LOT `407868`, caducidad caja **2028-08-05**.
3. **Softclix puncionador + 25 lancetas** — EAN `4015630018239`, REF `03307450001`. PVP $159 = lista tienda Accu-Chek MX ($159.50).

## Qué pegar en Supabase

1. `sql/patch_carga_accuchek_split_precios_20260927.sql` — altas (si no existen) + costo/PVP dueño + cola Recibir borrador.
2. Tras merge/deploy de Vercel las fotos viven en `farmacapital.mx/catalogo-propia/`.

Stock **0** hasta escanear con pistola. Caducidad: Softclix y Active → MMAA de la caja (no inventar). Instant → ya va `2028-08-05` / lote `407868` en el renglón.

Fotos (packshot Roche / tienda Accu-Chek, no Fahorro):

- `public/catalogo-propia/accu-chek-active-tiras-50-4015630064076.jpg`
- `public/catalogo-propia/medidor-accu-chek-instant-4015630083855.jpg`
- `public/catalogo-propia/accu-chek-softclix-puncionador-25-4015630018239.jpg`
