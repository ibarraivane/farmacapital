# Tickets Recibir · 06-oct-2026 (tarde)

Fotos Farma Mayoreo + Bodega F-42. Pegar **cada** SQL en Supabase → SQL Editor → Run.

| Pedido | Archivo | Piezas | Total |
|--------|---------|--------|-------|
| Farma Mayoreo 308422 | `patch_carga_farmamayoreo_308422.sql` | 58 | $2,385.97 |
| Bodega F-42 83450 | `patch_carga_bodega_f42_83450.sql` | 14 | $641.67 |

## Todo-en-uno

`patch_carga_tickets_20261006_mayoreo_bodega_TODOS.sql`

## Altas nuevas (stock 0)

- Nuvel Beauty / Addiction roll-on 55 ml
- Inha-Rub ADN Pharma 40 g
- Olorex talco mentol / clásico 80 g
- Sensodyne Limpieza Profunda 50 g
- Vaso coprocultivo Kohn 100 ml
- eGo Force / Ultra Fresh / Sport aerosol 150 ml
- Kotex Unika nocturna C/10
- Grisi jabón neutro pack 3
- Protec toallitas alcohol C/100
- Koleston 477 Castaño Aterciopelado
- Old Spice Leña spray 150 ml

## Notas

- Farma Mayoreo: P.U. con IVA; suma = TOTAL $2,385.97. Lote de fábrica sí; caducidad = MMAA al escanear.
- Bodega: total tarjeta $641.67 (1 ¢ de redondeo en SQL vs papel).
- Regenerar: `python3 scripts/generar_carga_tickets_20261006_mayoreo_bodega.py`
