# Equilibrio 450233 — Recibir

Cliente **307513** Luis Ángel Palillero Ventura · pedido online · sucursal Iztapalapa 2 · 02-nov-2026.

## Qué correr

1. Pegar **todo** `sql/patch_carga_equilibrio_450233.sql` en Supabase → SQL Editor → Run.
2. En Recibir debe aparecer el botón vivo **Equilibrio · 450233**.
3. Escanear cada caja → MMAA de la caja (no inventar `0000`) → confirmar.
4. Hisopos: hay **dos lotes** (H1402226 ×7 y H1402026 ×3). Escanea y confirma cada renglón.

## Totales

- 15 renglones / **42 pzas** / **$1,125.10** (subtotal P.U. $1,059.92 + IVA $65.18)
- Folio **450233** del ticket térmico.
- **7 altas** stock 0: FC-09749698 Bromhexina/oxeladina · FC-03406051 Gasa estéril Quirmex 10×10 · FC-14377883 Max Sens Uva · FC-14377890 Max Sens Chocomenta · FC-75034498 Playboy Texturizado · FC-75034481 Playboy Extra Sensible · FC-14377876 Max Sens Fresa
- Ya en catálogo: EQ-PBY007 · EQ-PBY008 · EQ-QUM052 · EQ-SON096 · FC-09747052 · FC-34064021 · FC-83144302

## Notas de mapeo

| Clave ticket | EAN | SKU | Nota |
|---|---|---|---|
| MAV414 | 7502009749698 | FC-09749698 | Bromhexina/oxeladina Maver frasco 225 ml |
| QIR016 | 7503003406402 | FC-34064021 | Dos lotes → dos renglones |
| QUM052 | 7502223112445 | EQ-QUM052 | Quimikan |
| QIR023 | 7503003406051 | FC-03406051 | Gasa Quirmex 10×10 C/10 |
| COL145 | 0780083144302 | FC-83144302 | Collifrin Adulto |
| MAV344 | 7502009747052 | FC-09747052 | Coriver 750 mg C/10 |
| SON098 | 7502001164697 | EQ-SON096 | Fenimeth (SKU catálogo, no EQ-SON098) |
| PBY019/021/018 | …7883/7890/7876 | FC-14377883/90/76 | Max Sens Uva / Chocomenta / Fresa |
| PBY007/008 | …7197/7180 | EQ-PBY007/008 | Tropicana / Passion ya en catálogo |
| PBY003/002 | 75034498 / 75034481 | FC-75034498/81 | Códigos Costofarma/FarmaMedical (8 dígitos) |

## Pendiente

- Al escanear Playboy Texturizado / Extra Sensible: si el beep no pega con 8 dígitos, mandar foto del código de barras de la caja.
- Collifrin Adulto: si falta packshot adulto en catálogo, no se pisó el infantil.

## Regenerar

`python3 scripts/generar_carga_equilibrio_450233.py`
