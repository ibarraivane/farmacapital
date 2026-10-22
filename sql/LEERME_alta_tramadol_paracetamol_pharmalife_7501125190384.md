# Alta Tramadol / Paracetamol Pharmalife C/20

Mostrador 18-oct-2026 · 5 cajas · caducidad feb 2028.

Pegar **todo** `sql/patch_alta_tramadol_paracetamol_pharmalife_7501125190384.sql` en Supabase → SQL Editor → Run.

## Producto

| Campo | Valor |
|---|---|
| Nombre | Tramadol / Paracetamol 37.5 mg / 325 mg |
| Marca | Pharmalife (Laboratorios PiSA) |
| Presentación | Caja con 20 tabletas |
| EAN | `7501125190384` |
| SKU | `FC-25190384` |
| Entrada | 5 cajas · cad. **2028-02-29** (MMAA `0228`) |
| Controlado | Fracción III · receta · **no** tienda web |

## Notas

1. **Costo / precio:** vacíos a propósito. Con costo, precio genérico = costo × 1.60.
2. **Lote de fábrica:** no sale en las fotos; queda el lote inicial del sistema.
3. **Foto:** `public/catalogo-propia/tramadol-paracetamol-pharmalife-37-5-325-c20.jpg` → tras deploy: `https://www.farmacapital.mx/catalogo-propia/tramadol-paracetamol-pharmalife-37-5-325-c20.jpg`.
4. Idempotente: si ya hay lote con esa caducidad y stock, no vuelve a sumar las 5 cajas.

## Después del SQL

1. En POS / Inventario buscar `tramadol` o escanear `7501125190384`.
2. Debe aparecer como controlado (badge / modal de receta al cobrar).
3. No debe salir en la tienda web.
