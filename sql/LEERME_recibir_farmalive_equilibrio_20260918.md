# Recibir Farmalive 12790 + Equilibrio 20260914

Las cajas ya están en mostrador. El recuadro rojo y el “no corresponde” salían porque el folio/EAN no pegaban.

## Qué correr

1. Pegar **todo** `sql/patch_recibir_farmalive_equilibrio_escanear_20260918.sql` en Supabase → SQL Editor → Run.
2. Recargar Recibir en la tablet (sin chunk viejo).
3. **Farmalive:** las 6 amarillas pasan a gris. Escanea la caja → MMAA (ej. 0629) → Guardar renglón.
4. **Equilibrio:** escanea el EAN (o el DataMatrix). Si el beep no pega, toca el renglón gris y teclea MMAA. No inventar `0000`.

## Folio

El ticket físico es **12790** (32 renglones, $3,534.11). Los parches del 16-sep buscaron `127790` y no ligaron nada. Este SQL cubre `12790`, `127790` y `127900`.

## 6 altas (stock 0 hasta Recibir)

| Producto | EAN caja | Ticket / alias |
|---|---|---|
| Teatrical rosa lanolina 19 g | 6502400079009 | 650240079009 · 6502400070009 |
| Teatrical azul 19 g | 6502400078996 | 650240078996 |
| Gotinal adulto spray 15 ml | 7501088509926 | — |
| Ensure líquido chocolate 237 ml | 7501033954061 | FC-33954061 · no es el 236 ml FC-33950100 |
| Aspirina C/40 3-pack | 7501008499429 | OCR viejo 7501008849949 |
| Aspirina GO C/10 sobres | 7501008499245 | — |

## Fotos

Packshot pendiente en `catalogo-propia/` (Teatrical 19 g, Gotinal, Aspirina 3-pack). No usar placeholder de otra cadena. SQL de `imagen_url` después del deploy, cuando estén los JPG.

## Caja: “No se pudo verificar la caja” / statement timeout

Eso **no cierra la caja**. Al abrir POS, el catálogo y la verificación pisan el mismo token (`UPDATE sesiones`) y Postgres corta a los 8 s.

1. Pegar también `sql/patch_caja_verificar_sin_timeout_20260918.sql` en Supabase → Run. **Sin este SQL el aviso sigue** (el JS solo reintenta).
2. Recargar POS. Si vuelve el aviso, toca **Reintentar** (la app ya reintenta sola 3 veces). No cerrar sesión: la caja no se cierra.

## No hacer

- No ir a Inventario → Catálogo a darlos de alta a mano.
- No cerrar Recibir con esas 6 en rojo: no entran a stock.
- No poner caducidad `0000`.
