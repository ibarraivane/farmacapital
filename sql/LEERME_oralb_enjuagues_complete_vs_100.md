# Oral-B enjuagues: Complete vs 100% (no son duplicados)

## Qué viste

En Inventario salen dos Oral-B 250 ml a $65 (FarmaLive), stock 6 + 3 = **9**, y en anaquel hay **4**.

## No es el mismo producto

| Ficha | EAN | Línea |
|---|---|---|
| `FC-51037878` | `7891051037878` | **Complete 4 en 1** (con flúor) |
| `FC-43517980` | `7500435179980` | **100% menta** (sin alcohol, sensibles) |

Farmalive los facturó como **dos renglones** (p. ej. tickets 11590 y 97). El sistema hizo bien en tener 2 SKUs: el candado anti-dup es por **mismo EAN**, y aquí los códigos son distintos.

El ícono 📦3 / 📦1 es **número de lotes**, no piezas.

## Qué correr

`sql/patch_oralb_enjuagues_stock4_nombres_20260925.sql`

- Renombra claro: Complete 4 en 1 vs 100% menta + fotos distintas.
- Baja stock a **3 + 1 = 4** (reparto default). Si al escanear las botellas el reparto es otro, editá `v_stock_complete` / `v_stock_100` antes del Run.

## Cómo evitar la confusión

1. **Al recibir / vender:** pistola al EAN de la botella (no elegir a ojo por “Oral-B azul”).
2. **En anaquel:** Complete y 100% se parecen; el código de barras decide.
3. **No fusionar** estas dos fichas — son fórmulas distintas.
4. El problema de “duplicado fantasma” (bórax, parches IFC) es otro: alta **sin EAN**. Estos Oral-B sí traían EAN.
