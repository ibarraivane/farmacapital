# Tickets 30-oct-2026 → Recibir

Tres tickets de mostrador (Cityfarma ×2 + Equilibrio). Pegar **todo** `sql/patch_recepciones_tickets_20261030.sql` en Supabase → SQL Editor → Run.

## Tickets

| Proveedor | Folio | Total | Renglones |
|---|---|---|---|
| Cityfarma Iztapalapa | **S336478** | $1,880.68 | Actron 400/600/Plus · Cicloferon · Fixodent Org/Plus · Flanax 550 C/12 y C/6 |
| Equilibrio (Iztapalapa 2) | **450041** | $152.64 | Amoxicilina AMSA 500 mg C/12 ×8 @ $19.08 |
| Cityfarma Iztapalapa | **S336493** | $716.58 | Binotal 1 g C/28 ×2 · Binotal 500 mg C/20 ×2 |

## Notas

1. **Cityfarma:** P.U. ya con IVA donde aplica (suma de renglones = total). S336493 sale “Pendiente de pago” — va a Recibir igual (como S335144).
2. **Equilibrio 450041:** pedido online · costo neto tras descuento. Ticket imprime lote `Q0626290` / cad `06-2028` — **no** se guarda; MMAA de la caja con pistola. EAN canónico `7501349021570` (AMS265).
3. **Actron:** packshots oficiales Bayer (Nadro tenía placeholder).
4. Stock **0** hasta pistola + MMAA. No inventar `0000`.
5. Flanax / Cicloferon / Fixodent / Amoxicilina ya podían estar: actualiza costo; **no baja** PVP bueno.

## Después del SQL

1. Recargar Recibir en la tablet.
2. Deben aparecer **3 botones** nuevos (no se pisan con Nadro/Farmalive/Bodega vivos).
3. Escanear → MMAA → Guardar renglón.
