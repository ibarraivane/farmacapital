# Tickets Recibir · 06-oct-2026

Fotos IFC + Zorro + Equilibrio + Farmalive + Cityfarma. Pegar **cada** SQL en Supabase → SQL Editor → Run.

| Pedido | Archivo | Piezas | Total |
|--------|---------|--------|-------|
| IFC 127425 | `patch_carga_ifc_127425.sql` | 1 | $238.00 |
| Grupo Zorro T01696085 | `patch_carga_zorro_T01696085.sql` | 1 | $161.67 |
| Equilibrio 447156 | `patch_carga_equilibrio_447156.sql` | 75 | $2,643.87 |
| Farmalive 13999 | `patch_carga_farmalive_13999.sql` | 23 | $778.70 |
| Cityfarma S329263 | `patch_carga_cityfarma_s329263.sql` | 15 | $1,425.01 |

## Todo-en-uno

`patch_carga_tickets_20261006_TODOS.sql`

## Notas

- Equilibrio trae **lote de fábrica**; caducidad = MMAA de la caja al escanear.
- Schick bolsa 12 pzas EAN `7502274881475` (no la pieza suelta `7591066701015`).
- Cintapore caja C/12 EAN `7506484500034` (código IFC 84129).
- Farmalive: costo = neto del renglón (2% o 5%). Suerox/Asepxia con EAN canónico 13 dígitos.
- Cityfarma: pendiente de pago $1,425.01.
- Regenerar: `python3 scripts/generar_carga_tickets_20261006.py`
