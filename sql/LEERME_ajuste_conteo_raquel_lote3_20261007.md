# Conteo Raquel (WhatsApp) — 7-oct-2026 (lote 3)

Correr en Supabase SQL Editor:

1. `patch_ajuste_conteo_raquel_lote3_20261007.sql`

## Casos

| SKU | Producto | Problema | Corrección |
|---|---|---|---|
| EQ-AMS234 | Pregabalina 150 mg AMSA C/28 | Pistola: «Código de barras no encontrado»; sí sale por nombre · 1 pza | EAN `7501349022935` + stock **1** |
| FC-5885E577 | Pabesorag 150/12.5 mg C/28 | Sistema **8**, físico **11** | stock **11** |
| FC-27870259 | Roxidolin Doxiciclina 100 mg C/10 | POS **SIN LOTES**, físico **1** | lote activo · stock **1** |

## Barcodes

| EAN (caja) | SKU |
|---|---|
| 7501349022935 | EQ-AMS234 Pregabalina 150 mg AMSA C/28 |

Confirmado en ficha mayoreo / Rappi (`…/rappi/7501349022935/…`) y en caja física de Raquel.

## Notas

- No inventar caducidades (lotes de conteo sin fecha).
- Pabesorag: el FEFO de abr 2028 que ya tenían se reasigna al lote principal al consolidar cantidad; si hay varios lotes vivos, el patch deja uno activo con 11.
- Roxidolin: el badge «Sin lotes» sale cuando `getStockFifoDisponible` es 0 (sin lote con cantidad).
