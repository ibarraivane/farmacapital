# Puntos FarmaCapital — escala estilo Ahorro (2026-10-03)

## Qué cambió

Del Ahorro no da “1 punto por cada $100” como tasa base. Su Monedero funciona así:

1. **1 punto = $1** de dinero electrónico.
2. La acumulación es **por producto** (porcentaje / promoción).
3. El **100+100** es un bono aparte: al juntar 100 “puntos récord”, te abonan $100.

FarmaCapital queda en la lectura simple que la gente recuerda:

| | Antes | Ahora |
|---|---|---|
| Ganas | 1 pt / $10 | **1 pt / $100** |
| Vale | $0.10 / pt | **$1 / pt** |
| Cashback | 1% | **1%** (igual) |

## SQL a correr en Supabase

`sql/patch_puntos_escala_ahorro_20261003.sql`

- Crea `fc_puntos_por_compra(monto)`.
- Convierte saldos existentes ÷10 (idempotente con `|PTS_ESCALA_V2|`).
- Actualiza acreditación POS, webhook y canje de tienda.
- Reemplaza `cliente_crear_pedido_online` con la misma fórmula.

Correr **después** (o junto) al deploy del front, para que canjes y acumulación no se desfasen.
