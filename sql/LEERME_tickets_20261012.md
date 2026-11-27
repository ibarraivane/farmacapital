# Tickets Recibir · 12-oct-2026

Fotos Cityfarma ×2 + IFC + Equilibrio + Farmalive. Pegar **cada** SQL en Supabase → SQL Editor → Run.

| Pedido | Archivo | Piezas | Total |
|--------|---------|--------|-------|
| Cityfarma S330922 | `patch_carga_cityfarma_s330922.sql` | 5 | $789.82 |
| Cityfarma S330971 | `patch_carga_cityfarma_s330971.sql` | 4 | $942.64 |
| IFC F8 128440 | `patch_carga_ifc_128440.sql` | 20 | $187.50 |
| Equilibrio 447795 | `patch_carga_equilibrio_447795.sql` | 8 | $263.04 |
| Farmalive 1537 | `patch_carga_farmalive_1537.sql` | 36 | $2,694.79 |

## Todo-en-uno

`patch_carga_tickets_20261012_TODOS.sql`

## Notas

- Cityfarma S330922 pagado; S330971 **pendiente de pago** $942.64.
- Eutirox ticket «50 MG» = **50 mcg** (EAN `7501298234908`).
- Equilibrio trae **lote de fábrica**; caducidad = MMAA de la caja al escanear.
- Fenimeth (SON098) → EAN `7502001164697` / SKU `EQ-SON096` (ficha correcta).
- Cefalver 12 cáps 500 mg → EAN Sufarmed `7503000422863`.
- IFC: Pomada Manzana / Pan puerco sin EAN GS1; match por SKU. Jarabe granada código `3311000001612`.
- Farmalive: costo = neto del renglón. Tabcin Pods = **2PACK**. Levonorgestrel 5+1 promo $0.01.
- Farmalive papel $2,694.76 / SQL suma renglones (±¢ por redondeo); tarjeta $2,697.78.
- Madrid pomada pan puerco: **foto pendiente** (alta sin `imagen_url`).
- Regenerar: `python3 scripts/generar_carga_tickets_20261012.py`
