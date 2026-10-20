# Tickets Recibir · 19-oct-2026

Fotos Cityfarma + Sahuayo + Equilibrio + Farmalive + Nadro. Pegar **cada** SQL en Supabase → SQL Editor → Run.

| Pedido | Archivo | Piezas | Total |
|--------|---------|--------|-------|
| Cityfarma S333074 | `patch_carga_cityfarma_s333074.sql` | 21 | $2,545.99 |
| Sahuayo 428641 | `patch_carga_sahuayo_428641.sql` | 2 | $43.30 |
| Equilibrio 448644 | `patch_carga_equilibrio_448644.sql` | 29 | $1,059.65 |
| Farmalive 14814 | `patch_carga_farmalive_14814.sql` | 42 | $1,664.96 |
| Nadro 6091278111 | `patch_carga_nadro_6091278111.sql` | 13 | $1,008.73 |

## Todo-en-uno

`patch_carga_tickets_20261019_TODOS.sql`

## Notas

- Equilibrio trae **lote de fábrica**; caducidad = MMAA de la caja al escanear.
- Equilibrio: renglón ácido ascórbico cortado en la foto → AMSA 6 amp EAN `7501349022119` (confirmar caja). AMS365 Zolmitriptano → EAN Ultra/AMSA `7502216805446`.
- Farmalive: costo = neto del renglón. Papel $1,664.99; suma SQL $1,664.96.
- Cityfarma: total = suma de renglones $2,545.99 (nebulizador Omron lleva el IVA 16% $80).
- Nadro: Timolol Exakta EAN corto `75049612` (mismo estilo que otros Exakta en Farmacity).
- Sahuayo: Nuvel Aclarado Ideal roll-on 50 mL EAN `7501082730258`.
- Regenerar: `python3 scripts/generar_carga_tickets_20261019.py`
