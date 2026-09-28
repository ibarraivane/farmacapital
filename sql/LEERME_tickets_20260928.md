# Tickets Recibir · 28-sep-2026

Fotos térmicas (Palillero / Luis). Pegar **cada** SQL en Supabase → SQL Editor → Run.

| Pedido | Archivo | Piezas | Total |
|--------|---------|--------|-------|
| Farma Mayoreo 306978 | `patch_carga_farmamayoreo_306978.sql` | 27 | $539.74 |
| IFC F8 126031 | `patch_carga_ifc_126031.sql` | 5 | $47.50 |
| Equilibrio 446088 | `patch_carga_equilibrio_446088.sql` | 106 | $3,149.38 |

## Altas nuevas (stock 0)

### Farma Mayoreo
- Blumen jabón líquido Coconut Paradise 525 ml (`7503007859624`)
- Blumen jabón líquido Kiwi 525 ml (`7503007859617`)
- Vitamina E Progela 850 mg C/30 (`7503008344617`)
- Acetona Madrid (`7506313000377`) · ml al escanear
- Aceite Madrid ×4 EAN (`7506313000810`, `0230`, `0155`, `0972`) · tipo/ml al escanear
- Blumen jabón líquido Kiwi Starfruit 221 ml (`7506267905148`)

### Equilibrio
- Ideliver Pro 30 mg C/7 (`7502009745485`)
- Alphalock tamsulosina 0.4 mg C/20 (`7502209858206`)
- Trociletas cereza C/10 (`7501547522220`)
- Sin EAN aún (SKU EQ-*): Rosel Ped, Delaphil 20, Tamsulosina beadvance C/30,
  Ácido alendrónico 70, Vivradoxil, Zensif IM, Esgaro, Trociletas cereza C/12

## Notas

- Farma Mayoreo: P.U. ya con IVA; suma renglones = total.
- Equilibrio: costo = P.U. neto post-descuento; lote de fábrica sí; MMAA de la caja.
- IFC: misma Pomada Manzana `FC-MER-MANZANA` que el ticket 122576.
- Ticket Equilibrio «BI0064» = clave **BIO064** Cloxan solución.
- Madrid Aceite/Acetona: no se inventa el tipo (mismo criterio que almendras 305016).
- Regenerar: `python3 scripts/generar_carga_tickets_20260928.py`
