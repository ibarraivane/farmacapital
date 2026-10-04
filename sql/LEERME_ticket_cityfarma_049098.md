# Ticket Cityfarma 049098 · 28-sep-2026

Factura CFDI `INV/2026/09/2057` · Folio **049098** · Yalesa / City Farma.
Pegar `sql/patch_carga_cityfarma_049098.sql` en Supabase → SQL Editor → Run.

| Piezas | Subtotal | IVA 16% | **Total** |
|--------|----------|---------|-----------|
| 34 | $6,431.19 | $133.85 | **$6,565.04** |

**Altas nuevas (12):** Bexident Post colutorio 250 ml, Bexident Post gel tópico 25 ml, Dolo Neurobion C/10, Dolo Neurobion C/5, Pepto-Bismol masticable C/12, Sies hidrosmina 200 mg C/20, Sterimar solución nasal 50 ml, Synalar Simple fluocinolona 0.01% crema 20 g, Synalar Simple fluocinolona 0.025% crema 20 g, Tesalon benzonatato 100 mg C/20, Thealoz Duo gotas 10 ml, Trayenta linagliptina 5 mg C/30

**Ya en catálogo (4):** Danzen serratiopeptidasa 10 mg C/20, Flanax naproxeno 550 mg C/12, Lotrimin Uno crema 1% 20 g, Rosel solución infantil 60 ml

## Notas

- Costo = Precio U de la factura (antes de IVA).
- Recargo marca +25% / genérico +60% solo si PVP estaba en 0.
- Sin lote ni caducidad: MMAA de la caja al escanear. No inventar `0000`.
- Thealoz Duo: misma SKU `FC-42003059` que El Surtidor 136447 (idempotente).
- Bexident: fotos Isdin en `public/catalogo-propia/` (tras deploy).
- Regenerar: `python3 scripts/generar_carga_cityfarma_049098.py`
