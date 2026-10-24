# Equilibrio 241026 — Recibir

Cliente **307513** Luis Ángel Palillero Ventura · foto térmica 24-oct-2026.

## Qué correr

1. Pegar **todo** `sql/patch_carga_equilibrio_241026.sql` en Supabase → SQL Editor → Run.
2. En Recibir debe aparecer el botón vivo **Equilibrio · 241026**.
3. Escanear cada caja → MMAA de la caja (no inventar `0000`) → confirmar.

## Totales

- 10 renglones / **27 pzas** / **$1,126.53**
- Folio **241026** provisional (`ddmmyy`): la foto no trae el número de factura. Si el papel dice otro, avisar.
- **4 altas** stock 0: ULT284 50/500 · AVT202 Cidorix 14 · AMS404 Metamizol AMSA · ULT285 50/850
- Ya en catálogo: Quimikan · Fluconazol AMS495 · Expicin · Cefalver 1 g · Cidorix 28 · Plusgel

## Mapeo ULT284 / ULT285

El ticket solo dice «VILDAGLIPTINA METFORMINA 30COMP». Concentraciones por ficha Ultra + costo mayoreo:

| Clave | EAN | Concentración | P.U. ticket |
|---|---|---|---|
| ULT284 | 7502216790896 | 50/500 mg | $158.27 |
| ULT285 | 7502216790490 | 50/850 mg | $172.28 |

Si al escanear la caja el beep no pega, mandar foto del código y lo corregimos.

## Pendiente

- **Fotos:** packshot en `catalogo-propia/` para las 4 altas (y Quimikan/Expicin si aún no tienen). SQL de `imagen_url` después del deploy.
- AMS404 es **AMSA** (EAN 7501349022126), distinto del Alpharma ALP0628 ya cargado.
- Lote AVT203 en papel: OCR `SD25083` (misma familia que AVT202 `SD26119`).

## Regenerar

`python3 scripts/generar_carga_equilibrio_241026.py`
