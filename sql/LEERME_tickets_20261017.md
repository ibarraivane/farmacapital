# Tickets Recibir · 17-oct-2026

Fotos Citymark + Farmalive + Cityfarma. Pegar **cada** SQL en Supabase → SQL Editor → Run.

| Pedido | Archivo | Piezas | Total |
|--------|---------|--------|-------|
| Citymark 75116 | `patch_carga_citymark_75116.sql` | 7 | $491.64 |
| Farmalive 14702 | `patch_carga_farmalive_14702.sql` | 4 | $723.44 |
| Cityfarma S332558 | `patch_carga_cityfarma_s332558.sql` | 1 | $430.00 |

## Todo-en-uno

`patch_carga_tickets_20261017_TODOS.sql`

## Notas

- Citymark (Bodega F-42, Caja 1): P.U. con IVA. Sedal queda en $48.95 (el ticket trae $48.952).
- Farmalive: costo = neto del renglón (2%). Cliente FARMACAPITAL. Tarjeta débito.
- Cityfarma: efectivo pagado, pendiente $0. Daflon es alta nueva y pide receta.
- Altas nuevas con foto: Sterimar Cobre y Daflon 500 mg. Fotosun y Theraflu TD solo llenan foto si el catálogo la tiene vacía.
- Sedal Liso Perfecto ya está. No se usa `sedal-liso-perfecto-acond-300ml.jpg` (esa foto es el acondicionador).
- Sin lote ni caducidad: MMAA de la caja al escanear.
- Regenerar: `python3 scripts/generar_carga_tickets_20261017.py`
