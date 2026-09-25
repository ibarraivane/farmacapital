# Tickets Recibir · 24-sep-2026

Fotos Central de Abastos (Palillero). Pegar **cada** SQL en Supabase → SQL Editor → Run.

| Pedido | Archivo | Piezas | Total |
|--------|---------|--------|-------|
| Cityfarma S325583 | `patch_carga_cityfarma_s325583.sql` | 18 | $1,051.12 |
| El 134730 | `patch_carga_surtidor_134730.sql` | 8 | $152.01 |
| Equilibrio 445679 | `patch_carga_equilibrio_445679.sql` | 22 | $875.52 |
| Farma 306277 | `patch_carga_farmamayoreo_306277.sql` | 55 | $2,978.43 |
| Farmalive 13395 | `patch_carga_farmalive_13395.sql` | 46 | $1,359.31 |
| Nadro 605425063 | `patch_carga_nadro_605425063.sql` | 2 | $383.42 |
| IFC 125448 | `patch_carga_ifc_125448.sql` | 5 | $404.00 |
| IFC 125445 | `patch_carga_ifc_125445.sql` | 22 | $770.00 |

## Notas

- **Farma Mayoreo 306277** viene en 3 fotos; el tramo Colgate/Kotex está sobreimpreso.
  Kotex tampones = EAN `7506425625536` (Unika Regular C/12). Total verificado $2,978.43 / 55 pzas.
- **Farmalive 13395**: foto partida. Costo = P.U. neto (2–5% desc.). Suerox EAN canónico 13 dígitos.
- **Nadro 605425063**: CFDI 24-sep. Nido + Ureadin Ultra 20. Costo = PR FAR; total con IVA $383.42.
- Equilibrio 445679: foto partida (inicio + pie). P.U. neto; total con IVA $875.52.
- Cityfarma: pendiente de pago $1,051.12 (subtotal + IVA). Hipebe es **0.4 mg** (ticket dice 4MG).
- IFC: sin EAN GS1 salvo Tensolastic `7501048690909`. Ligar EAN de caja al escanear.
- Caducidad: nunca inventar. `0000` inválido. MMAA de la caja al pistolear.
- Regenerar: `python3 scripts/generar_carga_tickets_20260924.py`
