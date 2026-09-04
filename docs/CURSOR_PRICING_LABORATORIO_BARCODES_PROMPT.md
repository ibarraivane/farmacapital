# Handoff — precios, laboratorio y códigos de barras

**Fecha:** 2026-09-04  
**Modo:** análisis. No ejecutar cambios de precio, costo ni barcode en producción hasta confirmar CSV por CSV.

Este archivo es el prompt de contexto. El diagnóstico técnico está en [PRICING_ALGORITMO_DIAGNOSTICO_20260904.md](PRICING_ALGORITMO_DIAGNOSTICO_20260904.md). Los números están en [PRICING_ANEXO_DATOS_20260904.md](PRICING_ANEXO_DATOS_20260904.md) y se regeneran con:

```bash
python3 scripts/diagnostico_pricing_20260904.py
```

No toca Supabase. Solo lee CSV locales.

---

## Qué se está resolviendo

No es un algoritmo: son **compra** y **venta** acoplados.

- **Venta:** precio de mostrador que no persiga el piso promocional de Similares, pero que tampoco se vaya del mercado. Objetivo: `Σ (precio − costo) × unidades` (pesos), no el % de markup.
- **Compra / reabasto:** costo de referencia confiable (reposición, no el mínimo histórico de una promo) y un **precio objetivo de compra** derivado hacia atrás desde lo que el mercado deja cobrar.
- **Laboratorio:** el mismo activo de otro lab no es “faltante”. Hoy `marca` ≠ laboratorio.
- **Códigos de barras:** pistola, POS y cruce de competencia. Un EAN mal puesto es peor que ninguno.

Función objetivo declarada por el dueño: **vender sobre todo, y ganar lo más posible**. Eso es GMROI / utilidad en pesos, no 60% parejo.

---

## Qué ya se cambió en código (este PR)

- Referencias: percentil 40 + piso de markup. Ya no sugiere `min − 2%`.
- Si piso > mercado → `revisar_compra` (no persigue Similares).
- Alta Recibir: 60% / 25% **sobre costo**.
- SQL listo (tú lo corres en Supabase): `sql/patch_barcodes_exactos_20260904.sql` (96 EAN), `patch_barcodes_duplicados_20260904.sql`, `patch_laboratorio_columna_20260904.sql`.

## Qué no se aplicó solo

- `UPDATE productos.precio` masivo (el sugerido vive en la UI; tú das Aplicar)
- Los 38 IFC sin EAN
- Borrar códigos `650…`

---

## Hallazgos que el código confirma

1. **Ya corregido:** Referencias ya no usa `min − 2%`. Queda percentil 40 + piso.
2. **Ya corregido el alta:** Recibir usa 60%/25% sobre costo. Rappi sigue con margen sobre venta (20%/40%).
3. Dos costos: `ultima_compra` solo baja; Recibir **pisa** `productos.costo` con el ticket.
4. Catálogo (626 SKUs, snapshot 14-ago): markup p50 = 41.4%, p75 = 60.0%. 350 SKUs en 28–45%, 183 en 55–65%. Eso es fórmula, no mercado.
5. 148 sin EAN. **110** se pueden proponer con clave Equilibrio → portal Levic o EAN de ticket. **38** quedan (casi todos IFC Mercurio/Perilla + 3 claves Equilibrio que Levic no trae).
6. 30 códigos prefijo `650` (no es GS1 México). 8 checksum inválido. 7 EAN duplicados / 17 SKUs. `UNIQUE` no está en producción.
7. `laboratorio` no existe en `productos`. `concentracion` 27%. `principio_activo` sucio en 106 filas (desodorante, surfactantes, látex).

---

## Arquitectura propuesta (siguiente fase, no esta)

```
costo_ref   = reposición neta (post-bonif, +flete)     — no min histórico
piso        = costo_ref × (1 + markup_mín[categoría, rol])
              ajustado merma / terminal / lealtad
mercado_ref = percentil 35–50 de precios regulares comparables
              (no min de Similares; no marca propia; no promo)
techo       = min(mercado_ref × posición, PMP)
precio      = clamp(mercado_ref × posición, piso, techo) → .50 / .90

SI piso > techo → renegociar compra / tráfico / no resurtir

precio_objetivo_compra = precio_mercado_sostenible / (1 + markup_objetivo)
```

Rol: ~5–10% KVI (el cliente compara) → mercado manda. Cola larga → margen manda. Sin unidades vendidas no hay KVI. El export está en [`scripts/exportar_ventas_sku.py`](../scripts/exportar_ventas_sku.py) (requiere `.env` local; no service_role).

---

## Laboratorio — modelo

Columna nueva `laboratorio`, distinta de `marca`.

| Campo | Qué es | Ejemplo |
|---|---|---|
| `marca` | Nombre comercial | XL-3, Cefalver, Vicks |
| `laboratorio` | Titular / fabricante | Genomma, Wandel, P&G |
| `principio_activo` | INN, no categoría | Paracetamol, no “antitranspirante” |
| `concentracion` | Dosis | 500 mg |
| `forma_farmaceutica` | Forma | tableta |
| `molecula_id` | PA + conc + forma | agrupa labs distintos |

Dónde tiene que verse: Inventario (columna), POS (búsqueda), Recibir, Reabasto (sumar por molécula), Referencias (heredar precio de Similares a todos los labs), alta.

Fuente local con laboratorio real: [`sql/generated/ticket_farmalive_9861.csv`](../sql/generated/ticket_farmalive_9861.csv).

---

## Códigos de barras — regla de oro

Solo **EAN exacto** o **clave proveedor exacta** (HIS075 → Levic `7502213042325`). Nunca nombre.

El CSV `06_barcodes_candidatos.csv` documenta 110 candidatos exactos. Columna `aceptado` vacía. No aplicar hasta revisión humana de una muestra (presentación caja vs ampolleta).

Los 38 restantes son IFC (Mercurio, perillas) y unas claves Equilibrio ausentes en el portal Levic de agosto. Se capturan al Recibir.

Códigos `650…`: marcar como internos, no borrar. Buscar el 750 real si aparece en otro ticket.

---

## Primer entregable si hay `.env` (tú lo corres)

```bash
python3 scripts/exportar_catalogo_supabase.py
python3 scripts/exportar_referencias_precio.py
python3 scripts/exportar_ventas_sku.py
python3 scripts/diagnostico_pricing_20260904.py
```

Sin ventas no hay KVI ni GMROI. No inventar unidades.

---

## Preguntas que el análisis ya contestó

- ¿El piso manda en Referencias? **No.** Ancla = mínimo − 2%.
- ¿60% es markup o margen? **Los dos, según el archivo.** Recibir alta usa margen sobre venta.
- ¿Se pueden completar barcodes con lo cargado? **110/148 sí, por clave/EAN. 38 no.**
- ¿`marca` es el laboratorio? **No.**
