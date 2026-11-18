# Tickets 17-nov-2026 → Recibir

El merge a GitHub **no** crea la cola. Pegar **todo** el SQL en Supabase → SQL Editor → Run.

## Tickets

| Proveedor | Folio | Total | Renglones |
|---|---|---|---|
| El Surtidor de su Farmacia | **161443** | $216.00 | 5 |
| Equilibrio | **451922** | $1,541.23 | 13 |
| IFC | **134202** | $372.00 | 4 |
| Farma Mayoreo | **V01000004500** | $1,625.91 | 7 |
| Cityfarma Iztapalapa | **15341570** | $6,982.85 | 28 |
| El Surtidor de su Farmacia | **161448** | $334.00 | 2 |

## Pasos

1. Raw: https://raw.githubusercontent.com/ibarraivane/farmacapital/main/sql/patch_recibir_tickets_1711_SOLO_pegar_esto.sql
2. Selecciona TODO → copiar → pegar → **Run**
3. VERIFICACION FINAL con los 6 folios en `borrador`
4. Tablet Recibir → recargar

## Notas

1. **Surtidor 161443:** Electrolit con desc. mayoreo ($19 c/u) + Naturella.
2. **Equilibrio 451922:** claves → EAN de ficha. Lote sí; caducidad NO. ALP0607 sin EAN en portal (match por SKU).
3. **IFC 134202:** Miyako férulas; EAN solo en recta grande (`0750187760234`).
4. **Farma Mayoreo V01000004500:** subtotal $1,566.76 + IVA $59.15 = $1,625.91.
5. **Cityfarma 15341570:** Enterogermina 2 `3664798074680`. EANs de caja: Enterogermina 4 `7501165010826`, Arluy Duo `7841141004051`.
6. **Surtidor 161448:** Kola Loka brocha + gota.
7. **Stock:** 0 hasta pistola + MMAA. No poner `0000`.
