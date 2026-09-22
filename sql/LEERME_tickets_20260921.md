# Tickets Recibir · 21-sep-2026

Fotos Central de Abastos (Palillero). Pegar **cada** SQL en Supabase → SQL Editor → Run.

| Pedido | Archivo | Piezas | Total |
|--------|---------|--------|-------|
| Equilibrio 445246 | `patch_carga_equilibrio_445246.sql` | 42 | $1,612.20 |
| Cityfarma S324509 | `patch_carga_cityfarma_s324509.sql` | 12 | $2,855.11 |
| Farmalive 14173 | `patch_carga_farmalive_14173.sql` | 39 | $1,538.69 |
| Mas Farmacias 48165 | `patch_carga_mas_farmacias_48165.sql` | 4 | $646.50 |
| El Surtidor 132862 | `patch_carga_surtidor_132862.sql` | 5 | $222.00 |
| El Surtidor 132821 | `patch_carga_surtidor_132821.sql` | 6 | $720.01 |

## Altas nuevas (stock 0)

- Postday 0.75 mg C/2 (`7501249605634`)
- Algodón plisado Quirmex 50 g (`7503003406327`)
- Doxiciclina Alpharma 100 mg C/10 (`7502226291857`)
- Erbitrax-T C/28 (`7502211783787`) · Cityfarma
- Lactacyd Pro-Bio 200 mL (`7501165009486`) · Cityfarma
- Vessel Due-F C/50 (`8020030091252`) · Cityfarma
- Erbitrax-T C/40 (`7502211783671`) · Mas Farmacias
- Ego gel, Saba, H&S 650 ml / anti-resequedad, cinta Quirmex, jeringas Sensimedical · Farmalive
- Lysol 354 g (`7501409601018`) · Surtidor

## Notas

- Equilibrio trae **lote de fábrica**; caducidad = MMAA de la caja al escanear.
- Farmalive trunca Suerox a 12 dígitos; pistola = EAN `650…2` del catálogo.
- Postday mismo EAN, dos lotes (`2510245` ×9 + `2603328` ×1).
- Regenerar: `python3 scripts/generar_carga_tickets_20260921.py`
