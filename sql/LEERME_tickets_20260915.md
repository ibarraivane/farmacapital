# Tickets Recibir · 15-sep-2026

Fotos térmicas Central de Abastos. Pegar **cada** SQL en Supabase → SQL Editor → Run (en cualquier orden).

| Pedido | Archivo | Piezas | Total |
|--------|---------|--------|-------|
| Cityfarma S322819 | `patch_carga_cityfarma_s322819.sql` | 4 | $738.06 |
| Cityfarma S322895 | `patch_carga_cityfarma_s322895.sql` | 6 | $582.12 |
| Cityfarma S322903 | `patch_carga_cityfarma_s322903.sql` | 2 | $400.00 |
| Equilibrio 444555 | `patch_carga_equilibrio_444555.sql` | 14 | $477.49 |
| Bodega F-42 27163 | `patch_carga_bodega_f42_27163.sql` | 14 | $266.39 |

## Altas nuevas (stock 0)

- Metformina LP Ascend 750 mg C/30 (`7503046016507`) — **TODO foto**
- Pharmaton Woman 50+ C/30
- Crest Complete 4 en 1 61 ml
- Oral-B Frescura Duradera 66 ml
- Colagener-3 pepino-limón 150 g

## Notas

- No inventar caducidad. Equilibrio trae lote de fábrica; MMAA sale de la caja al escanear.
- Fotos en `public/catalogo-propia/` → visibles en `farmacapital.mx` tras el deploy.
- Regenerar: `python3 scripts/generar_carga_tickets_20260915.py`
