# Cómo agrandar Dermocosmética, Vitaminas y Dispositivos

Estar registrado en el mayorista **no** llena la tienda. Cada pieza entra cuando abres su ficha, copias nombre de mostrador + EAN + foto + precio, y pegas el SQL. Sin EAN y sin foto no hay alta.

Plantilla vacía: `docs/fichas_proxima_vitrina.json`
Generador: `node scripts/alta-bajo-pedido-desde-fichas.js docs/fichas_proxima_vitrina.json sql/patch_alta_bajo_pedido_SIGUIENTE.sql`

## Circuito (el mismo para todos)

1. Entra al B2B. Elige solo lo que **sí puedes pedir hoy**.
2. Abre la **ficha del producto**, no el renglón del pedido ni el PDF.
3. Copia de esa página: nombre de mostrador, marca real, presentación, EAN (8–14 dígitos), foto de la pieza, precio de lista/público.
4. Pega un objeto en `docs/fichas_proxima_vitrina.json`.
5. Corre el script. Si falta EAN, marca de casa (`LGEN`, `FRABEL`) o el nombre parece `BLOQ ANTHE…`, se detiene.
6. Supabase → SQL Editor → Run. Idempotente: no pisa stock de anaquel.
7. En la tienda busca la marca. Si sale el código del ticket, la ficha está mal.

`bajo_pedido` solo si **no** hay piezas en góndola. Precio = ancla de mostrador (costo + margen), sin Mercado Pago. Stock 0. Sin lote ni caducidad inventada.

SKU: `FC-` + últimos 8 del EAN. Si ese SKU ya es de otro EAN → el SQL pone `FC-ND-`.

## Qué pedir en cada cuenta

| Cuenta | Qué llena | Categoría / subcategoría |
| --- | --- | --- |
| Nadro, Marzam, Levic | Dermocosmética y vitaminas de consultorio | `Cuidado personal` + `Dermatología` · `Vitaminas` · `Suplemento` |
| [Suplementos Mayoreo](https://suplementosmayoreo.com/) y [shop menudeo](https://shop.suplementosmayoreo.com/) | Nutrición deportiva (whey, creatina, pre-entreno) | `Suplemento` + `Nutrición deportiva` |
| [Birdman B2B MX](https://b2b.birdman.com/?country=MX) | Proteína vegetal, creatina, vitaminas Birdman | igual; marca **Birdman**, no el SKU interno |
| [Promexsa](https://www.promexsa.com.mx/) | Dispositivos médicos | `Dispositivo médico` |

Nadro / Marzam / Levic también traen glucómetro y tensiómetro. Si el EAN está ahí, úsalo: misma ficha, misma foto.

Promexsa a veces publica SKU tipo `ORT-AGH-1100` o `DIS-KIB-676`. **Eso no es EAN.** No lo metas como código de barras. Busca el GTIN en la caja o en la ficha; si no hay, el aparato se pide por el formulario de Pedidos especiales hasta que lo tengas.

Birdman B2B y el portal de mayoreo de suplementos piden login para el precio. El nombre y la foto pueden salir de la ficha pública; el ancla, de tu lista. No uses el código interno como nombre.

## Dónde aparece cada alta

- Dermocosmética → `/dermocosmetica`
- Vitaminas, suplementos, nutrición deportiva → `/vitaminas` (chip **Nutrición deportiva**)
- Dispositivos médicos → `/dispositivos` y en **Pedidos especiales**
- Lo que no esté en vitrina → formulario `/pedidos-especiales`

## JSON de una ficha

```json
{
  "ean": "7501234567890",
  "nombre": "Omron tensiómetro de brazo HEM-7120",
  "marca": "Omron",
  "presentacion": "1 pieza",
  "categoria": "Dispositivo médico",
  "subcategoria": "Diagnóstico",
  "forma": "Aparato",
  "precio": 899,
  "imagen_url": "https://www.farmacapital.mx/catalogo-propia/omron-hem-7120.jpg",
  "fuente": "Promexsa · ficha · lista $720"
}
```

El `ean` del ejemplo es de formato, no una pieza real. Sustitúyelo por el de la caja.

Si la URL de foto es frágil, cópiala a `public/catalogo-propia/` y apunta a `https://www.farmacapital.mx/catalogo-propia/…` **después** del deploy.

## Lotes que ya corriste

1. `sql/patch_alta_bajo_pedido_vitrina_20260916.sql` — 26 (Nadro / SVR)
2. `sql/patch_alta_bajo_pedido_derm_recetadas_20260916.sql` — 21 derma
3. `sql/patch_fase2_vitrina_nutricion_deportiva_20260917.sql` — reclasifica, no inserta

El siguiente lote es el JSON que armes con estas cuentas.
