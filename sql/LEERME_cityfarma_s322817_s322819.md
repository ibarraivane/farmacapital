# Cityfarma S322817 + S322819 · 14-sep-2026

Tickets térmicos Central de Abastos (mismo cliente, misma visita).

## Qué pegar en Supabase

1. `sql/patch_carga_cityfarma_s322817.sql` → orden **S322817** · $3,940.28 · 23 renglones
2. `sql/patch_carga_cityfarma_s322819.sql` → orden **S322819** · $738.06 · 2 renglones (Flanax + Lomotil)

No pegar los `.py`. Tras el Run, el SELECT final debe mostrar 1 tarjeta + N renglones por folio.

## Notas

- Nombres de ficha (YZA / Fahorro / Kenvue / Bayer), no del ticket (`FLANAXPRO`, `MOTRIN INF SUSP 20M`, etc.).
- Espaven usa EAN corto del ticket: `75004996` (30 ml).
- Motrin Infantil EAN `7501109902866` = **120 ml** (el ticket trunca “20M”).
- Bicalutamida EAN = C/14 (ticket trunca “C1”).
- Sepia = itraconazol/secnidazol (no homeopático).
- Sin lote ni MMAA en el SQL (tampoco los lotes BT1ALD1 / AX4250 del S322819). Stock al escanear.
- Fotos en `public/catalogo-propia/` (aparecen tras deploy Vercel).

## TODO foto pendiente

Sin packshot usable al armar la carga:

- `7506494600311` Cloropiramina 25 mg
- `7501573925071` Dosteril 10 mg C/30
- `7503003738671` Sepia 33.3/166.6 mg C/16
- `7503045798022` Dinaglix-Duo sitagliptina/metformina
- `7502009749469` Tribenósido/lidocaína crema 30 g
- `7501258208550` Valaciclovir Serral 500 mg

## Regenerar

```bash
python3 scripts/generar_carga_cityfarma_s322817.py
python3 scripts/generar_carga_cityfarma_s322819.py
```
