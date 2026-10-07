# Conteo Cyntia (WhatsApp) — 7-oct-2026

Auditoría física vs POS. Correr en Supabase SQL Editor, en este orden:

1. `patch_ajuste_conteo_cyntia_stock_20261007.sql` — stock por lotes (no tocar solo `productos.stock`)
2. `patch_ajuste_conteo_cyntia_altas_20261007.sql` — productos que no estaban / no se encontraban
3. `patch_ajuste_conteo_cyntia_fix_nz_20261007.sql` — corrección N–Z (Nysmoson 2, Metamizol AMSA 2, Neuralin 1)

## Ajustes de stock (caption «Físico N»)

| SKU | Producto | Sistema → Físico |
|---|---|---|
| FC-BE76D409 | Amcef IM 1 g | 9 → 8 |
| FC-D210172A | Ampicilina 1 g / 5 ml AMSA | 3 → 2 |
| FC-08496701 | Aspirina efervescente C/12 | 1 → 2 |
| FC-070839 | Alliviax Garganta | → 2 |
| EQ-AMS147 | Ácido alendrónico 10 mg C/30 | 7 → 8 |
| EQ-AMS458 | Ácido alendrónico 70 mg C/4 | 4 → 3 |
| FL-8509810 | Antiflu-Des Pediátrico 30 ml | 1 → 2 |
| FC-369D1689 | Beneventol Cefixima 400 mg C/6 | 1 → 2 |
| FC-447B30F9 | Budesonida 0.250 mg/2 ml | 2 → 1 |
| EQ-WER038 | Charyn Azitromicina 500 mg C/3 | 6 → 5 |
| EQ-MAV236 | Ideliver Pro Duloxetina 60 mg C/14 | 9 → 6 |
| FC-49022492 | Irbesartán 150 mg C/28 Lgen | 1 → 2 |
| FC-42700643 | Camber Irbesartán + HCTZ 150/12.5 C/28 | → 1 |
| FC-697EEAD0 | Kurtosil crema | 2 → 1 |
| FC-93888302 | Kenciclen Doxiciclina 100 mg C/10 | → 1 |
| EQ-SER024 | Lonixer Clonixinato 125 mg C/10 | 3 → 2 |
| EQ-QUI096 | Quifa Levonorgestrel/Etinilestradiol | 1 → 3 (+ presentación C/28) |
| FC-09740435 | Laritol Loratadina 10 mg C/10 | 5 → 4 |
| FC-09742828 | Laritol Loratadina 10 mg C/20 | → 2 |
| EQ-SON091 | Meclison 50/25 mg C/20 | 5 → 4 |
| FC-27427392 | ML-Prim Metocarbamol/Ibuprofeno C/12 | 5 → 4 |
| EQ-BEA424 | Be Advance Metoprolol 100 mg C/20 | 6 → 3 |
| EQ-ALP0628 | Alpharma Metamizol 1 g/2 ml C/3 amp | 4 → 2 |
| EQ-MAI150 | Maviglin 500/5 mg C/60 | 4 → 3 |
| EQ-SON153 | Nysmoson’s-V óvulos C/10 | → 2 (decía «no están»; ya existe) |
| EQ-EXA045 | Neomicina/Polimixina B/Bacitracina ung. | 1 → 2 |
| EQ-BEA336 | Neomicina/Kaolín/Pectina C/20 | → 3 (decía «no está»; ya existe) |
| FC-AEA8C8DA | Namifen Ácido mefenámico 500 mg C/20 | 2 → 1 |
| EQ-MAV196 | Oxatech Olanzapina 10 mg C/14 | 3 → 1 |
| FC-58207010 | Oxital-C Vitamina C 2 g C/10 | 6 → 1 |

## Altas / piezas fuera de catálogo

| EAN | Producto | Piezas | SKU |
|---|---|---|---|
| 7501349022434 | Irbesartán AMSA 150 mg C/14 | 3 | FC-9022434 |
| 7503049078205 | Itoprida Avivid 50 mg | 3 | FC-49078205 |
| 7501342802213 | Ketorolaco Trometamina Advance 10 mg C/10 | 6 | FC-42802213 |
| 7501349022126 | Metamizol sódico AMSA 1 g/2 ml C/3 amp | 2 | FC-9022126 |
| — | Neuralin C/2 amp (`FC-8505126`) | 2 → 1 | (fix N–Z) |

## No tocado a propósito (alineado con #440 A–C)

- **Alphalock** (`EQ-AVT201`): fotos 4 + 1 = 5 = sistema. No se toca.
- **Celecoxib** (`FC-E6B50AC3`): caption «Fisco 2» pero foto de 3 cajas = sistema. No se baja.
- **Amikacina 100 mg** (`FC-347A49C7`): la pila «2» es 100 mg + **500 mg**, no dos de 100.
- **Neomicina ung. precio $60 vs sticker $224**: no se cambia PVP sin confirmación.
- **Neomicina/Kaolín/Pectina** y **Nysmoson**: no son alta; ya existen (`EQ-BEA336`, `EQ-SON153`).
- **Maviglin «1 pieza»**: mismo EAN que el «Físico 3»; se mantiene 3.
- **Caducidades**: no se inventan MMAA. Los lotes de conteo van sin fecha.
- El draft #440 queda supersedido por #447 + este fix N–Z.

## Verificación rápida

```sql
select sku, nombre, stock
from public.productos
where sku in (
  'FC-BE76D409','EQ-AVT201','FC-D210172A','EQ-SON091','FC-27427392',
  'EQ-BEA424','EQ-MAI150','EQ-SON153','EQ-BEA336','FC-58207010',
  'FC-9022434','FC-49078205','FC-42802213','FC-9022126'
)
order by sku;
```
