# Tickets Recibir · 02-oct-2026

Fotos Central de Abastos + factura Nadro (Palillero). Pegar **cada** SQL en Supabase → SQL Editor → Run.

| Pedido | Archivo | Piezas | Total |
|--------|---------|--------|-------|
| Nadro 6090680530 | `patch_carga_nadro_6090680530.sql` | 10 | $777.49 |
| Equilibrio 446721 | `patch_carga_equilibrio_446721.sql` | 22 | $970.74 |
| Mayorista de Dulces T620721328 | `patch_carga_dulces_T620721328.sql` | 241 | $335.20 |
| Bodega F-42 83017 | `patch_carga_bodega_f42_83017.sql` | 11 | $309.95 |
| Farmalive 1028 | `patch_carga_farmalive_1028.sql` | 26 | $883.96 |

## Altas nuevas (stock 0)

- Dankial-B budesonida 0.250 mg/2 mL C/5 (`7502256040517`) · Nadro
- Derman crema 25 g (`354312225010`) · Nadro (distinto del 50 g)
- Broncolin paletas vitrolero surtido C/100 (`714706903182`) · Farmalive · **TODO foto**
- Broncolin Properlas propóleo/eucalipto 50 g · Properlas jengibre 50 g
- Pomada de la Campana Tepezcohuite 35 g (`650240019180`)
- Ricitos de Oro crema lavanda 100 mL · colonia avena/vainilla · **TODO foto**
- Nuvel crema manos suaves / hidratada 65 mL · **TODO foto**
- Chupa Chups Mini bolsa 240 · Vero Mix Clásico 1.5 kg · **TODO foto**

## Notas

- Nadro: Histiacil AD EAN canónico `7501328979502` (OCR del papel confundía dígitos).
- Equilibrio trae **lote de fábrica**; caducidad = MMAA de la caja al escanear.
- Farmalive: costo = P.U. después del 2%.
- Dulces: Chupa Chups 1 bolsa → 240 pzas; Vero Mix sin EAN hasta escanear la bolsa.
- Regenerar: `python3 scripts/generar_carga_tickets_20261002.py`
