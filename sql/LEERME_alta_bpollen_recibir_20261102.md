# Alta BPOllen 5% / 2.5% — Recibir

Recibir marcó **2 productos sin registrar**:

| EAN | SKU | Mostrador | Packshot |
|---|---|---|---|
| `7502002461306` | `FC-02461306` | BPOllen peróxido de benzoílo **5%** · tubo 60 g · Farmapiel | `catalogo-propia/bpollen-gel-5pct-60g-7502002461306.jpg` |
| `7502002461290` | `FC-02461290` | BPOllen peróxido de benzoílo **2.5%** · tubo 60 g · Farmapiel | `catalogo-propia/bpollen-gel-2_5pct-60g-7502002461290.jpg` |

## Qué correr

1. Pegar **todo** `sql/patch_alta_bpollen_recibir_20261102.sql` en Supabase → SQL Editor → Run.
2. En Recibir: recarga. Los renglones amarillos deben dejar de decir «Pendiente de alta».
3. Toca cada uno → teclea **MMAA de la caja** (no `0000`) → Guardar.

Stock sigue en 0 hasta confirmar caducidad con la pistola.

## Precio

Ancla DermaExpress (marca **+25%** al costo): 5% costo $275 → PVP $344 · 2.5% costo $280 → PVP $350. Si el renglón del ticket ya traía `costo_estimado`, el SQL lo copia a la ficha.

## Nota del mismo ticket (pantalla)

**Telmisartán 40 mg** aparece con cad **03/2008** — eso está vencido hace años; casi seguro es **03/2028**. Corrígelo a mano en Recibir antes de Guardar.
