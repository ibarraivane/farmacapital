# Tickets 26-oct-2026 → Recibir

Fotos de mostrador (Farmalive Club Iztapalapa 1 + Cityfarma). Pegar **todo** `sql/patch_recepciones_tickets_20261026.sql` en Supabase → SQL Editor → Run.

## Tickets

| Proveedor | Folio | Total | Renglones |
|---|---|---|---|
| Farmalive (Club Iztapalapa 1) | **13677** | $2,892.07 | Aderogyl amp/gotas · Vaseline · Iliadin · OFF · Neo-Melubrina · Nair · Ensure polvo · Advance White · Pharmaton |
| Cityfarma Iztapalapa | **S335144** | $1,101.47 | Derman crema ×3 · Vartalon Compositum 30 sobres |
| Cityfarma Iztapalapa | **S335145** | $191.14 | Clearblue Digital (IVA 16% incluido en P.U.) |
| Cityfarma Iztapalapa | **S335151** | $270.97 | Ferranina gotas 20 mL |

## Notas

1. **Farmalive 13677:** dos fotos (arriba + abajo) del mismo ticket. Neo-Melubrina consolidada 1+2 → **3** pzas @ $123.68. Advance White 4 + promo $0.01 → **5** pzas @ costo promedio **$44.22**. Pharmaton Complete C/100 viene @ **$0.01** (promo): no se pisa el costo del catálogo.
2. **Advance White:** ticket imprime `33200186601`; canónico UPC `033200186601` (pistola).
3. **Cityfarma S335144 / S335151:** en papel “Pendiente de pago”, sello rojo PAGADO — van a Recibir igual.
4. **Stock:** 0 hasta pistola + MMAA de la caja. No poner `0000`.
5. **Fotos pendientes de alta nueva:** Iliadin (inf/adulto), OFF Defense/Family, Nair vello grueso, Ensure polvo chocolate/vainilla, Aderogyl C Infantil, Vartalon, Ferranina, Arm & Hammer. Las que ya tienen packshot en `catalogo-propia/` se enlazan (Neo-Melubrina, Clearblue, Nair sensible, Pharmaton).

## Después del SQL

1. Recargar Recibir en la tablet.
2. Debe haber **4 botones** de tickets vivos (no se pisan).
3. Escanear → MMAA → Guardar renglón.
