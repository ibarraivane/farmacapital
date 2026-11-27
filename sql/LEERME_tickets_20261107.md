# Tickets 07-nov-2026 → Recibir

Tres tickets del mismo día. Pegar **todo** `sql/patch_recepciones_tickets_20261107_SOLO_pegar_esto.sql` en Supabase → SQL Editor → Run.

## Tickets

| Proveedor | Folio | Total | Renglones / pzas |
|---|---|---|---|
| Equilibrio (Iztapalapa 2) | **450987** | $697.11 | 6 / 22 |
| Cityfarma Iztapalapa | **S338883** | $1,884.14 | 10 / 16 |
| Bodega F-42 | **86837** | $451.12 | 9 / 12 |

## Notas

1. **Equilibrio:** costo = P.U. neto tras descuento; IVA $0; lote de fábrica sí; caducidad **no** (MMAA caja). Claves EQF → EAN ficha.
2. **Cityfarma:** P.U. del papel; suma de renglones = total $1,884.14. Sin lote en cola.
3. **Bodega F-42:** ticket imprime Citymark; folio **86837** (Caja 2). P.U. con IVA; suma = total.
4. Stock **0** hasta pistola + MMAA. No inventar `0000`.
5. Altas previstas (12): FC-09747281 Dolver ibuprofeno 800 mg · FC-21440013 Buscapina Duo · FC-70615277 Daflon 500 mg · FC-75727890 Duosym · FC-00408259 Plidan 10 mg · FC-00408204 Plidan Compuesto · FC-49029729 Telmisartán / hidroclorotiazida 80/12.5 mg · FC-06251373 Sedal Ceramidas · FC-06258013 Sedal Mega Crecimiento · FC-06224780 Sedal Prebiótico + Biotina · FC-06210905 Sedal Micelar Arroz · FC-56340100 Sedal Anti-esponjado

## Después del SQL

1. Recargar Recibir en la tablet.
2. Deben aparecer **3 botones** nuevos.
3. Escanear → MMAA → Guardar renglón.

## Regenerar

`python3 scripts/generar_carga_tickets_20261107.py`
