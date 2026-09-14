# Equilibrio 20260914 — Recibir

Cliente **307513** Luis Ángel Palillero Ventura · fotos POS 14-sep-2026.

## Qué correr

1. Pegar **todo** `sql/patch_carga_equilibrio_20260914.sql` en Supabase → SQL Editor → Run.
2. En Recibir debe aparecer el botón vivo **Equilibrio · 20260914**.
3. Escanear cada caja → MMAA de la caja (no inventar `0000`) → confirmar.

## Totales

- 41 renglones / **112 pzas** / **$3,498.95**
- Ketorolaco 10 mg C/10 va en **dos lotes** (`530056` ×4 y `530175` ×2)
- Calaffler lote `R2503424` salía en rojo en el POS (papel ~2027-04)

## Pendiente

- **Fotos:** ninguna packshot en `catalogo-propia/` todavía. Tras conseguir fotos, SQL de imagen post-deploy.
- Verificar en caja: lote Diclofenaco AMSA (papel/OCR `26E039`, histórico a veces `B26E…`); volumen Calaffler (ticket 15 ml / ficha 20 ml); EAN Pisa CS 500 ml si el beep no matchea.
- Regenerar: `python3 scripts/generar_carga_equilibrio_20260914.py`
