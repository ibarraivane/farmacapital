# FarmaCapital · Rediseño de la tienda (base ChatGPT): especificación para Cursor

**Fecha:** 21 de septiembre de 2026 · **Preparado por:** Claude, para Iván
**Base del repositorio:** `main` en `3b79ccf`
**Referencia visual única:** `referencia/prototipo-chatgpt-ajustado.html` (se abre con doble clic y es navegable), `referencia/capturas/` y `referencia/estilos-prototipo.css`.
**Regla:** nada directo a `main`. Una fase = una rama = un PR con vista previa de Vercel. Iván aprueba cada PR.

> Este documento **reemplaza** al paquete anterior basado en el prototipo v3 de Claude. Iván eligió el diseño que hizo ChatGPT. Se usa tal cual, con solo los ajustes de la sección 2.

---

## 0. Qué es el diseño de ChatGPT

- Blanco con bloques gris frío, tinta `#001534`, azul para lo interactivo y verde solo para "Disponible en sucursal".
- Letra Inter, con la frase final de cada titular en Fraunces cursiva.
- Botones tinta con esquinas de 7 px y líneas finas `#DCE2EA`.

Pantallas del prototipo: **inicio, catálogo, ficha, carrito, sucursal** (de ChatGPT) y **cotizar especializado** (agregada con el mismo estilo).

`referencia/prototipo-chatgpt-original.html` es la versión de ChatGPT sin ajustes, por si hay dudas de cómo era algo.

---

## 1. Reglas de implementación (obligatorias)

1. **Solo la tienda.** No tocar Admin, POS, inventario, lotes, pagos, precios ni RPC de cobro. `src/theme/tokens.js` **no se modifica**, porque Admin y POS lo usan a través de `index.js` → `aplicarTokensCSS()`.
2. **Detrás de un interruptor.** Todo lo nuevo se ve solo con `tiendaV2Activa()` (`codigo-base/src/theme/tiendaV2.js`): `REACT_APP_TIENDA_V2=1` o `?v2=1` en la URL. Los clientes siguen viendo la tienda actual hasta la fase F.
3. **Componentes nuevos** en `src/components/tienda/v2/`, montados desde `Tienda.jsx` con el interruptor. No agregar más código dentro de `Tienda.jsx`, que ya tiene más de 7,000 líneas.
4. **Estilos con alcance.** `referencia/estilos-prototipo.css` ya viene con el prefijo `.fc-v2`. Se copia a `src/components/tienda/v2/tiendaV2.css` y el contenedor de la tienda v2 lleva `className="fc-v2"`. **Se copian los valores exactos** (tamaños, pesos, espacios, radios); no se reinterpretan.
5. **Datos reales.**
   - Si falta un dato (foto, responsable sanitario, tiempo de respuesta), el bloque no se muestra.
   - Nunca se muestran textos de ejemplo del prototipo como "Texto del instructivo autorizado…".
   - Sin testimonios, certificaciones ni beneficios médicos.
6. **Accesibilidad:** áreas táctiles de al menos 44 px, foco visible y `prefers-reduced-motion` respetado. Sin carruseles automáticos ni popup de bienvenida.
7. **Pruebas:** `npm test` y `npm run build` pasan.

---

## 2. Ajustes acordados sobre el diseño de ChatGPT

Ya están aplicados en `prototipo-chatgpt-ajustado.html`.

| # | En el original de ChatGPT | En la versión a implementar | Motivo |
|---|---|---|---|
| 1 | "Farmacia y consultorio · Desde 2016" | "Farmacia y consultorio · Ciudad de México" | La farmacia abrió en agosto de 2026; 2016 es la fecha fiscal. |
| 2 | "Chinampac · Ver sucursal", "Recoger en Chinampac", "Sucursal Chinampac" | "Sucursal CDMX · Ver ubicación", "Recoger en sucursal", "Sucursal Ciudad de México" | Marca nacional (decisión de Iván). La dirección completa queda en el pie legal y en la página de sucursal. |
| 3 | "Farmacia física · Desde 2016 … Visítanos en Radiodifusora 100…" | "Farmacia física · Nueva en la Ciudad de México · Abrimos en agosto de 2026…" | Igual que 1 y 2. |
| 4 | El precio sube 8 % si eliges envío | Un solo precio en línea ("Precio en línea · IVA incluido") | Así cobra el sistema real (`precioOnlineMp`); el envío solo suma el Servicio de $5 y el transporte cotizado. |
| 5 | No existía | Bloque tinta **"¿No encuentras tu medicamento? *Te lo cotizamos.*"** en el inicio, entrada "Cotizar especializado" en el menú y pantalla **Cotizar** | Prioridad de negocio de Iván. |
| 6 | El inicio solo mostraba dermocosmética | Fila **"Medicamentos · En sucursal / Listos para recoger hoy"** antes de dermocosmética | Plan maestro: los medicamentos son la columna del negocio. |
| 7 | Ficha sin descripción | Sección **"Información del medicamento"** con acordeones, alimentada por las fichas enriquecidas (#309) | Iván pidió descripciones detalladas. |
| 8 | Catálogo sin salida | Al final: "¿No está aquí? Te cotizamos…" | Lleva a Cotizar. |
| 9 | Pie con solo "Radiodifusora 100 · Iztapalapa" | Pie legal: razón social, RFC, domicilio y teléfono (de `farmaciaFiscal.js`) | Obligación de mostrar los datos del proveedor. |
| 10 | El botón "Buscar" se partía ("Busca / r") | Sin corte de línea | Error visual del original. |

---

## 3. Pantallas

Cada pantalla tiene su captura en `referencia/capturas/`, en celular (390 px) y escritorio (1280 px).

### 3.1 Encabezado y pie (todas las pantallas)
- Franja tinta: "Farmacia y consultorio · Ciudad de México" / "Atención en sucursal · 8:00–22:30" (de `HORARIO_FARMACIA`).
- Encabezado tinta:
  - logo blanco;
  - buscador blanco de 48 px con botón "Buscar". Reusar la búsqueda existente (`TiendaBusquedaBar` / `tiendaCatalogSearchSuggestions`);
  - carrito con contador.
- Menú: Medicamentos · Dermocosmética · Nutrición · **Cotizar especializado** (en azul) · a la derecha, "Sucursal CDMX · Ver ubicación".
- Aviso al agregar al carrito ("… agregado a tu carrito · Ver carrito").
- Pie tinta: logo, línea legal y "Atención y sucursal".

### 3.2 Inicio (`celular-1-inicio.png`, `escritorio-1-inicio.png`)
Reemplaza el cuerpo de `Home()` (≈ línea 3048) cuando v2 está activo. El orden de las secciones es:

1. **Titular** con dos columnas en escritorio:
   - izquierda: eyebrow "TU FARMACIA, TAMBIÉN EN LÍNEA", "Tu receta. / Tu rutina. / *Tu farmacia.*", texto, botón "Buscar medicamento" y enlace "Explorar cuidado de la piel";
   - derecha: tarjeta crema "Cuidado de la piel / Un espacio para *tu rutina.*" con dos fotos de dermocosmética reales, "Catálogo por encargo" y "Descubrir →".
2. **Tres beneficios** en línea: Recoge en sucursal · Envío cotizado en CDMX · Atención de farmacia.
3. **Bloque tinta "Cotizar especializado"** (ajuste 5), con tres pasos y el botón blanco "Cotizar mi medicamento".
4. **"¿Qué estás buscando?"**: cuatro tarjetas grises (Medicamentos, Dermocosmética, Nutrición, Equipo médico) con iconos lucide `Pill`, `Droplets`, `Leaf`, `HeartPulse`.
5. **"Listos para recoger hoy"**: medicamentos con existencia > 0, en la tarjeta de producto de ChatGPT (sección 4).
6. **"Tu cuidado, a tu manera."**: dermocosmética por encargo, con la nota "La disponibilidad y la fecha de llegada se confirman con el proveedor."
7. **Pie del inicio en dos columnas:**
   - "Farmacia física · Nueva en la Ciudad de México" con "Ver ubicación y horarios →";
   - tarjeta tinta del consultorio: "Consulta médica general · Consulta $80 (de `CONSULTA_PRECIO_DEFAULT`) · Atención de lunes a sábado" con "Ver horarios y contacto".

`BannersEstaSemana` (#309) puede ir entre los puntos 4 y 5 con el estilo de ChatGPT. Iván decide si se queda.

`IntroAnimacion` (#309) se conserva.

**Se retiran del inicio v2:** `HeroCarousel`, `PopupBienvenida`, `HomeBannersStrip` y `HomeBannersTiles`.

### 3.3 Catálogo (`*-2-catalogo.png`)
`Catalogo()`, ≈ línea 3257.

- Título de la categoría con enlace "Inicio" y una descripción corta.
- Filtros "Todos" / "En sucursal" y "Ordenar" (Relevancia, Menor precio).
- "N productos · Precios en línea".
- Rejilla de tarjetas: 4 columnas en escritorio y 2 en celular.
- Al final, "¿No está aquí?", que lleva a Cotizar.
- Sin resultados: "No encontramos esa combinación.", con salida a Cotizar o a contacto.

### 3.4 Ficha de producto (`*-3-ficha-medicamento.png`)
`DetalleProducto()`, ≈ línea 1985. En escritorio, dos columnas.

- **Izquierda:**
  - foto sobre gris;
  - tabla técnica (Presentación, Sustancia activa, Forma farmacéutica; en dermo, Marca), con solo los renglones que tengan dato.
- **Derecha:**
  - estado;
  - nombre en H1 y presentación;
  - precio con "Precio en línea · IVA incluido";
  - cajas grises de información: "Requiere receta médica" cuando aplica, y "Recoger en sucursal" o "Este producto se consigue por encargo";
  - selector de cantidad;
  - botón "Agregar al carrito · $total" o "Revisar encargo · $total".
- **Debajo:** "Información del medicamento" / "Sobre el producto", con acordeones que salen de `FichaProductoEnriquecida` (#309):
  - medicamento: ¿Para qué sirve? · ¿Cómo se toma? · Antes de tomarlo · Posibles efectos secundarios · Cómo guardarlo;
  - dermo: Descripción · Cómo se usa · Ingredientes · Precauciones.

  **Un acordeón sin datos no aparece; si la ficha no está publicada, la sección entera no aparece.**
- El flujo de bajo pedido (`cliente_crear_pedido_bajo_pedido`) **no se cambia**.

### 3.5 Carrito (`*-4-carrito-envio.png`)
`Carrito()`, ≈ línea 3616.

- **Líneas del carrito:** foto, nombre, presentación, estado, cantidad, "Quitar" e importe.
- **Aviso "Los encargos se tramitan por separado"** si el carrito mezcla productos en sucursal y por encargo. Hoy ya existe `tipoCarrito`.
- **Caja "¿Cómo lo quieres recibir?"** (a la derecha en escritorio):
  - opciones: Recoger en sucursal (sin costo de entrega) / Envío en CDMX (costo y plazo sujetos a cotización);
  - desglose: Productos · **Servicio $5** solo con envío (`cargoPlataformaOnline`) · Entrega (Gratis / Por cotizar) · Total o "Subtotal sin envío";
  - nota y botón.
- **Aviso rojo "La amoxicilina se entrega solo en sucursal"**, con "Recoger todo en sucursal" / "Quitar…", cuando la política no permite enviar. El bloqueo completo depende del Sprint 0; mientras tanto se usan `esCategoriaAntibiotico` + `requiere_receta`, como el checkout actual.
- **No cambiar** el cálculo del total ni el cobro.

### 3.6 Cotizar especializado (`*-5-cotizar.png`, `*-6-cotizar-enviado.png`)
Ruta nueva `/cotizar` en `src/shared/tiendaRoutes.js`.

- **C1, sin foto de receta:**
  - Campos: medicamento o sustancia · presentación · cantidad · WhatsApp · cómo lo quiere recibir.
  - Consentimiento obligatorio con enlace al aviso de privacidad.
  - Se envía por `/api/solicitudes` (`solicitudTienda.js`) con `tipo: 'especializado'` y llega a "Lo que buscan" con folio.
  - Pantalla de éxito: "Solicitud recibida" · folio · Estado "Cotizando" · Cobro "Solo si aceptas". "Respuesta estimada" solo aparece cuando Iván defina el tiempo.
- **C2, foto de receta:** es un dato sensible. Requiere bucket privado, borrado a los 30 días y la aprobación de Iván. Va en un PR aparte.

### 3.7 Sucursal (`*-7-sucursal.png`)
- "Sucursal Ciudad de México".
- Dirección completa. Aquí sí va, porque es la página para recoger.
- Horario, teléfono y correo.
- Tarjeta del consultorio con sus horarios. Los horarios del prototipo son de ChatGPT: **confirmarlos con Iván** antes de publicar.

### 3.8 Mi cuenta: línea de tiempo del pedido
Misma línea de tiempo que los correos v2. Con envío: Pedido → Cotizado → Pagado → En camino → Entregado. Para recoger: Pedido → Pagado → Preparando → Listo → Entregado.

---

## 4. Tarjeta de producto (componente `TarjetaProducto`)

Tal como la de ChatGPT (`.fc-product`), de arriba abajo:

1. foto sobre gris;
2. estado;
3. marca en mayúsculas pequeñas;
4. nombre;
5. presentación (con "· Requiere receta" cuando aplica);
6. precio y "Ver producto →" / "Ver encargo →".

Toda la tarjeta abre **su** producto.

| Estado | Texto | Regla de datos |
|---|---|---|
| En sucursal | "Disponible en sucursal" (verde, cuadrito lleno); "· Solo recoger" si la política no permite envío | Existencia efectiva > 0 (`tiendaEffectiveStockFromDb`) y no `bajo_pedido` |
| Por encargo | "Por encargo" (azul, cuadrito con borde) | `bajo_pedido === true` |
| Consultar | Precio "Consultar" | Sin precio publicado |

---

## 5. Fases (una por PR)

| Fase | Contenido | Revisión de Iván (vista previa con `?v2=1`) |
|---|---|---|
| **A** | `tiendaV2.js`, `tiendaV2.css`, interruptor, encabezado, pie y `TarjetaProducto` | Encabezado, menú y pie iguales a las capturas |
| **B** | Inicio (3.2) | Comparar con `*-1-inicio.png` |
| **C1** | Cotizar sin foto (3.6) | Enviar una solicitud de prueba y verla en "Lo que buscan" |
| **D** | Catálogo (3.3), ficha (3.4) y sucursal (3.7) | Un producto en sucursal, uno con receta y uno por encargo |
| **E** | Carrito (3.5) y Mi cuenta (3.8) | Un pedido para recoger y otro con envío |
| **F** | Encender para todos y borrar lo viejo | Producción |

**Terminado de cada fase:**

1. Igual a la captura en 390, 820 y 1280 px, con la única diferencia de los datos reales.
2. Sin `?v2=1`, la tienda se ve como hoy.
3. Admin y POS sin cambios.
4. `npm run build` y las pruebas pasan.
5. El PR incluye capturas.
6. Lighthouse móvil no baja.

---

## 6. Datos que faltan de Iván (sin ellos, el bloque no se muestra)

1. Qué cubre "especializados".
2. Tiempo de respuesta de una cotización.
3. Nombre y cédula del responsable sanitario, y número de aviso de funcionamiento.
4. Fotos de la fachada y el mostrador.
5. Horarios reales del consultorio.
