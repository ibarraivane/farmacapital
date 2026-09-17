# Fase 2 — Nutrición deportiva + anaquel en las páginas

La tienda ya mezcla **En tienda** y **Sobre pedido** en Dermocosmética y Vitaminas.
Este SQL **no da de alta nada**. Solo reclasifica suplementos que ya existen.

## Qué pegar

Supabase → SQL Editor → Run:

`sql/patch_fase2_vitrina_nutricion_deportiva_20260917.sql`

Idempotente. Lo puedes correr más de una vez.

## Qué hace

Pone `subcategoria = 'Nutrición deportiva'` en filas de categoría **Suplemento** que ya son:

- proteína (incl. Prowinner / Pronat del primer lote, que decían `Proteína`)
- creatina, whey, pre-entreno, BCAA, aminoácido deportivo, ganador de peso

## Qué no hace

- No inserta SKUs.
- **No escribe `bajo_pedido`**. Si hay stock de anaquel, se queda en anaquel.
- No toca precio, foto, lote ni caducidad.
- No mueve pancreatina (digestivo) ni shampoo / cabello con «proteína».
- Glucerna, omega, biotina y vitaminas se quedan en su rubro.

## Cómo se ve

- Chip y banda: **Nutrición deportiva** (la URL sigue `?rubro=proteina`).
- Alias: `?rubro=creatina`, `?rubro=nutricion-deportiva`, `/conseguir?seccion=deporte`.
- Badge **En tienda** en anaquel clasificado; **Sobre pedido · 24-48 h** en encargo.
- Agotado de anaquel sigue diciendo Agotado.
- El carrito **no** mezcla encargo con anaquel.
