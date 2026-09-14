# Pharmaton Complete C/100 · alta foto mostrador · 11-sep-2026

## Veredicto

| Producto | EAN | SKU | Stock | Lote | Cad |
|---|---|---|---|---|---|
| Pharmaton Complete tabletas C/100 | `3664798062243` | `FC-98062243` | **2** | `3514` | NOV/26 → `2026-11-30` |

No confundir con **C/30** `3664798062229` / `FC-8062229`.

## Ficha

- Marca: **Pharmaton** (laboratorio Opella / Sanofi)
- Presentación: caja con 100 tabletas de 773 mg
- Principio: Multivitaminas + Ginseng G115
- Categoría: Vitaminas
- PVP ancla: **$459** (Benavides / Guadalajara ~458–459; PMP caja ~$611.60)
- Costo: vacío — ticket Farmalive 97 lo traía en promo `$0.01` (no usable)

## Qué pegar en Supabase

1. `sql/patch_alta_pharmaton_complete_100_3664798062243.sql` — alta + lote 3514 ×2.
2. Tras deploy Vercel: `sql/patch_fotos_pharmaton_complete_100_3664798062243.sql`.

El patch de alta, si Farmalive 97 sigue en borrador con este EAN, marca el renglón confirmado para no volver a sumar stock al escanear.
