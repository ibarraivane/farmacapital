# Reparar Recibir (cepillos, tickets, vendas)

Si al escanear **no abre el renglón** o **no salen pedidos vivos**, corre en este orden en Supabase → SQL Editor:

## 1. Tickets 24-sep (cola Recibir)

Si Farma Mayoreo / Farmalive / Cityfarma / etc. **no aparecen** como botones:

`sql/patch_carga_tickets_20260924_TODOS.sql`

(o cada `patch_carga_*` de `LEERME_tickets_20260924.md`)

## 2. Altas de catálogo (si aún no)

1. `sql/patch_alta_protec_bandas_adhesivas_7501048640676.sql`
2. `sql/patch_alta_vendas_mostrador_20260925.sql`

## 3. Reparación pistola + pedido Mostrador

`sql/patch_reparar_recibir_oralb_vendas_mostrador_20260925.sql`

Eso:

- Fuerza EAN Oral-B `3014260279264` / `3014260278922` en Farma Mayoreo
- Fuerza Suerox naranja-mango `7501048607214`
- Pega EAN reales en renglones IFC (Dibar / Venda-stick / Quirmex)
- Crea el pedido vivo **Mostrador 25-sep** con Protec + vendas para escanear

## Cómo probar

1. Recibir → debe salir **Mostrador** (y los tickets si corriste el paso 1).
2. Abre **Farma Mayoreo 306277** → escanea Oral-B → renglón gris.
3. Abre **Mostrador 25-sep** → escanea venda / Protec → renglón gris.

**Nota:** Si tienes **otro ticket abierto** y escaneas una venda que no es de ese ticket, Recibir dirá que no corresponde (es correcto). Toca el pedido Mostrador primero.
