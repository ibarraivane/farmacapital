# FarmaCapital · Rediseño v2 de la tienda: especificación para Cursor

**Fecha:** 21 de septiembre de 2026 · **Preparado por:** Claude, con las ideas acordadas con ChatGPT y aprobadas por Iván
**Base del repositorio:** `main` en `3b79ccf`
**Referencia visual única:** `referencia/prototipo-v3.html` (se abre con doble clic) y `referencia/capturas/`
**Regla:** nada directo a `main`. Una fase = una rama = un PR con vista previa de Vercel. Iván aprueba cada PR.

---

## 0. Por qué la tienda todavía no se ve como el prototipo

Hasta hoy, Cursor recibió y subió piezas sueltas:

- fichas enriquecidas, banners por plantilla y la animación de entrada (#309);
- el correo y el Servicio de $5 (paquete aparte).

**Nunca recibió el rediseño visual como tarea de programación.** El inicio, el encabezado, los colores, la tipografía, las tarjetas, el catálogo, la ficha y el carrito siguen siendo los de antes: fondo marfil, botón terracota, letra Inter y carrusel de banners. Este documento es esa tarea.

---

## 1. Reglas de implementación (obligatorias)

1. **Solo la tienda.** No tocar Admin, POS, inventario, lotes, pagos, precios ni RPC de cobro. `src/theme/tokens.js` **no se modifica**, porque Admin y POS lo usan a través de `index.js` → `aplicarTokensCSS()`.
2. **Detrás de un interruptor.** Todo lo nuevo se ve solo con `tiendaV2Activa()` (ver `codigo-base/src/theme/tiendaV2.js`): variable `REACT_APP_TIENDA_V2=1` o `?v2=1` en la URL. Así Iván revisa en la vista previa y en producción sin afectar a clientes. Al final se enciende para todos y se borra lo viejo en un PR aparte.
3. **Componentes nuevos, no parches dentro de `Tienda.jsx`.** Crear `src/components/tienda/v2/` y montar desde `Tienda.jsx` con el interruptor. `Tienda.jsx` ya tiene más de 7,000 líneas.
4. **Estilos con alcance.** Las clases del prototipo (`referencia/estilos-prototipo-v3.css`) se copian a `src/components/tienda/v2/tiendaV2.css` bajo `.fc-v2`. Por ejemplo, `.fc-v2 .cta{…}`. Nada global.
5. **Datos reales, no inventados.**
   - Si falta un dato (foto, responsable sanitario, tiempo de respuesta), **el bloque o el renglón no se muestra**. Nunca se publican textos entre corchetes como "[Nombre y cédula]".
   - No hay testimonios, certificaciones ni beneficios médicos.
6. **Accesibilidad y movimiento.**
   - Botones y áreas táctiles de al menos 44 px; foco visible en azul.
   - Se respeta `prefers-reduced-motion`.
   - Sin carruseles automáticos ni popup de bienvenida.
7. **Pruebas:** `npm test` y `npm run build` pasan. Las pruebas de POS no cambian.

---

## 2. Sistema visual

Todos los valores están en `codigo-base/src/theme/tiendaV2.js` y en `referencia/estilos-prototipo-v3.css`.

| Elemento | Antes (hoy) | v2 |
|---|---|---|
| Fondo | Marfil `#F4ECE2` | Blanco, con bloques en gris frío `#F3F5F8` |
| Botón principal | Terracota `#C9451F` | Tinta `#001534`, texto blanco, alto 52 px, radio 8 |
| Botón secundario | — | Borde tinta de 1.5 px (`.cta.ghost`) |
| Enlaces e interactivos | Varios | Azul `#054ABC` |
| Verde jade | Decorativo en algunos lugares | **Solo** disponibilidad y confirmación |
| Crema | Fondo de todo | **Solo** dermocosmética (idea de ChatGPT) |
| Letra | Inter + titulares Fraunces | **Archivo** (ancho variable) para todo; **Fraunces cursiva** solo para la frase final del titular (`<em class="s">`); IBM Plex Mono solo en folios |
| Titulares | — | H1 36 px en celular / 64 px en escritorio, peso 760, `font-stretch:112%`; H2 24 / 30 px |
| Degradados, sombras fuertes, emojis en la interfaz | Sí | No |

**Fuentes:** en `public/index.html`, reemplazar el enlace de Google Fonts por:

```
https://fonts.googleapis.com/css2?family=Archivo:wdth,wght@62..125,400..800&family=Fraunces:ital,opsz,wght@1,9..144,400..500&family=IBM+Plex+Mono:wght@400;500&display=swap
```

Admin sigue con Inter: se carga en el mismo enlace o se deja el actual.

### 2.1 Estados de disponibilidad (la firma de la tienda)

Un solo componente, `EstadoDisponibilidad`, que se usa en tarjetas, ficha, carrito y categorías:

| Estado | Marca | Texto | Color | Regla de datos |
|---|---|---|---|---|
| En sucursal | Cuadrito lleno de 8 px | "En sucursal" / "En sucursal · recoge hoy" | `--jade-txt` | Existencia efectiva > 0 (`tiendaEffectiveStockFromDb`) y no `bajo_pedido` |
| Por encargo | Cuadrito con borde azul | "Por encargo" / "Por encargo · te confirmamos la fecha" | `--blue` | `bajo_pedido === true` |
| Cotización | Círculo con borde gris | "Cotización" | `--muted` | Categoría sin catálogo (equipo médico) o producto no encontrado |
| Agotado | — | "Agotado" | `--muted` | Existencia 0 y no bajo pedido |

"Disponible" o "En sucursal" solo se muestra con inventario confirmado.

### 2.2 Componentes base (`src/components/tienda/v2/`)

| Componente | Referencia en el prototipo | Notas |
|---|---|---|
| `EncabezadoV2` | `header()` | Franja superior `--ink2`: punto verde con pulso + "Abierto hoy 8:00–22:30" (de `HORARIO_FARMACIA`). **No usar "Farmacia mexicana"** (Iván lo rechazó). En escritorio, a la derecha: "WhatsApp 55 6253 0631". Barra tinta con logo blanco, carrito con contador verde y menú. Buscador blanco de 50 px siempre visible; en escritorio, en línea con el logo y con una barra de categorías debajo. Reusar la búsqueda existente (`TiendaBusquedaBar`, `tiendaCatalogSearchSuggestions`). |
| `TarjetaProducto` | `medCard()` | Foto sobre `--mist` cuadrada al 78 %, estado, nombre (15 px, 650), presentación, precio (18 px, cifras tabulares) y botón + de 44 px tinta. Al agregar se vuelve verde con ✓ (animación `pop`). Toda la tarjeta abre **su** producto. |
| `BotonCTA` | `.cta.dark`, `.cta.ghost` | — |
| `Pasos` | `.steps` | Números en círculo tinta con línea vertical. |
| `FichaTecnica` | `.spec` | Tabla limpia clave → valor, sin marco pesado. |
| `Acordeon` | `.acc` | `<details>` nativo, flecha que gira. |
| `PieV2` | `footer()` | Tinta, logo blanco, enlaces y datos legales. El responsable sanitario solo aparece si el dato existe en `farmaciaFiscal`. |

---

## 3. Pantallas

Para cada pantalla: captura, estructura, textos exactos y de qué parte actual sale el dato.

### 3.1 Inicio (`capturas/celular-1-home.png`, `capturas/escritorio-inicio.png`)
Reemplaza el cuerpo de `Home()` (línea ~3048 de `Tienda.jsx`) cuando v2 está activo.

1. **Encabezado v2.**
2. **Titular.**
   - Eyebrow "MEDICAMENTOS ESPECIALIZADOS".
   - H1: "¿No encuentras tu medicamento? *Te lo cotizamos.*", con la última frase en Fraunces cursiva.
   - Texto: "Mándanos el nombre o la foto de tu receta y te respondemos con precio, disponibilidad y fecha de entrega antes de cobrar nada." La frase "Oncológicos, biológicos, de alta especialidad…" **solo** se agrega cuando Iván confirme qué cubre "especializados".
   - Botón "Cotizar mi medicamento →", que lleva a la página Cotizar (fase C).
   - Debajo: "También por WhatsApp · 55 6253 0631".
   - En escritorio, dos columnas: el titular ocupa 7/12 y los pasos 5/12.
3. **Tres pasos** sobre `--mist`: "Nos dices qué necesitas" · "Te cotizamos" · "Apartas y lo recoges".
4. **"También te surtimos":** cuatro tarjetas con borde fino.
   - Medicamentos (En sucursal, hoy) → catálogo.
   - Dermocosmética (Por encargo) → vitrina dermo.
   - Nutrición y suplementos (Por encargo) → su categoría.
   - Equipo médico (Cotización) → Cotizar.
   - Iconos de línea: lucide `Pill`, `Droplet`, `Zap`, `FlaskConical`.
5. **"Esta semana":** `BannersEstaSemana` (ya existe desde #309), con el estilo v2. En celular, deslizable a mano; en escritorio, rejilla de 3.
6. **"Listos en sucursal":** fila deslizable de `TarjetaProducto`, solo con existencia > 0. Si existe, usar el orden por más vendidos de `sugeridos`; si no, `poolCatalogoTienda`. Incluye "Ver todo".
7. **Dermocosmética en crema:**
   - Eyebrow café "CUIDADO DE LA PIEL · POR ENCARGO".
   - H2 "Un espacio para *tu rutina.*"
   - Texto "Lo pedimos al proveedor, te confirmamos la fecha y solo entonces se cobra."
   - Fila de productos dermo reales, desde `VitrinaConseguir` / `bajo_pedido`.
8. **Farmacia nueva:**
   - Eyebrow "UNA FARMACIA NUEVA EN MÉXICO".
   - H2 "Abrimos nuestra primera sucursal en agosto. *Y vamos por más.*"
   - Foto real **solo si existe**; si no, el bloque va sin foto.
   - Ficha: Sucursal "Ciudad de México · ver ubicación" · Horario · Consultorio con su precio de `CONSULTA_PRECIO_DEFAULT`. Responsable sanitario solo con el dato real.
   - Botón secundario "Agendar consulta · $80", que lleva a la cita.
9. **Pie v2.**

**Se retira del inicio v2:**
- `HeroCarousel`;
- `PopupBienvenida`;
- las franjas `HomeBannersStrip` / `HomeBannersTiles` (sustituidas por "Esta semana");
- el bloque de puntos como sección propia (los puntos se mencionan en Mi cuenta).

**La animación de entrada** (`IntroAnimacion`, #309) se conserva.

### 3.2 Cotizar especializado (`capturas/celular-2-cotizar.png`)
Ruta nueva `/cotizar`, que se agrega a `src/shared/tiendaRoutes.js`. Se hace en dos partes:

- **C1, sin foto de receta:**
  - Campos: medicamento o sustancia · presentación · cantidad · WhatsApp · cómo lo quiere recibir (Recoger / Envío en CDMX; "Resto del país (próximamente)" deshabilitado).
  - Casilla de consentimiento con enlace al aviso de privacidad; el botón queda deshabilitado hasta marcarla.
  - Se envía por el mismo camino que "Te lo conseguimos" (`/api/solicitudes`, `solicitudTienda.js`), con un campo `tipo: 'especializado'`, para que llegue a "Lo que buscan" con folio.
  - Pantalla de éxito: ✓ verde · "Recibimos tu solicitud." · Folio en mono · Estado "Cotizando" · "Cobro: solo si aceptas". El renglón "Respuesta estimada" solo aparece cuando Iván defina el tiempo.
- **C2, foto de receta:** la receta es un **dato sensible de salud**.
  - Bucket **privado** de Supabase con acceso solo para el personal, borrado automático a los 30 días y consentimiento explícito.
  - Es un PR aparte y no se hace sin la aprobación de Iván.

### 3.3 Catálogo (`capturas/celular-3-catalogo.png`)
`Catalogo()`, línea ~3257.

- Título H2 "Medicamentos" y "N productos en sucursal".
- Chips: Todos · Genéricos · Con receta. Se reusa `filtroRx`.
- Rejilla de `TarjetaProducto`: 2 columnas en celular, 3 en tableta y 4 en escritorio.
- Al final, bloque tinta "¿No está aquí? Te lo cotizamos", que lleva a Cotizar. Reemplaza al actual "Te lo conseguimos" del catálogo, con el mismo destino.

### 3.4 Ficha de medicamento (`capturas/celular-4-ficha.png`)
`DetalleProducto()`, línea ~1985.

1. Ruta de categoría ("Medicamentos / Gastro").
2. Foto grande sobre `--mist`.
3. Estado de disponibilidad.
4. H1 con el nombre.
5. Presentación · "Genérico intercambiable" si aplica · laboratorio.
6. Si requiere receta: etiqueta "Rx" roja con "Requiere receta médica · se solicita al entregar".
7. Resumen y chips. Salen de `FichaProductoEnriquecida` (#309) cuando la ficha está publicada; si no hay ficha, no se muestran.
8. Precio de 34 px, precio por unidad y la nota "Precio en línea con IVA. Si recoges y pagas en sucursal, aplica el precio de mostrador."
9. Selector de cantidad y botón "Agregar · $total", que cambia a verde "En tu carrito · Ver".
10. Acordeones con los datos de la ficha enriquecida, en este orden:
    - ¿Para qué sirve? (abierto);
    - ¿Cómo se toma?;
    - Antes de tomarlo;
    - Interacciones;
    - Posibles efectos secundarios;
    - Cómo guardarlo;
    - **Ficha técnica** (sustancia, concentración, forma, presentación, laboratorio, registro sanitario, tipo de venta, código de barras; solo los renglones con dato);
    - Preguntas sobre la compra.

    Un acordeón sin datos no aparece.
11. Bloque WhatsApp "¿Tienes dudas sobre este medicamento?".
12. "Misma sustancia, otras presentaciones", con su estado y precio.
13. "¿Necesitas otra presentación o marca?", que lleva a Cotizar.

### 3.5 Ficha de dermocosmética / por encargo (`capturas/celular-5-dermo.png`)
Misma estructura, con fondo de foto crema, marca en mayúsculas pequeñas y estado "Por encargo · te confirmamos la fecha".

- Tres pasos en azul: "Apartas con tu tarjeta" / "Te confirmamos la fecha" / "Se cobra y lo recibes".
- Botón "Encargar · $precio". Usa el flujo actual de bajo pedido (`cliente_crear_pedido_bajo_pedido`); **no se cambia la lógica de reserva**.
- Acordeones: Descripción · Para quién es · Cómo se usa · Ingredientes · Precauciones. Salen de la ficha enriquecida.

### 3.6 Carrito (`capturas/celular-6-carrito.png`)
`Carrito()`, línea ~3616.

- Encabezado corto "Tu pedido" y fondo `--mist`.
- Lista de productos con su estado. Un antibiótico se marca en rojo: "Antibiótico · requiere receta".
- "¿Cómo lo quieres recibir?" con opciones tipo radio:
  - Recoger en sucursal — Gratis;
  - Envío en CDMX — Cotizado;
  - Resto del país — Pronto, deshabilitado.
- **Aviso temprano:** si la política no permite enviar un producto, se muestra la alerta roja con "Recoger todo" / "Quitar" y el botón de pago queda deshabilitado. Esto depende del Sprint 0 (módulo de política). Mientras no esté, se usa `esCategoriaAntibiotico` + `requiere_receta` como ya hace el checkout.
- Resumen: Productos · **Servicio** ($5 con envío, $0 al recoger; igual que `cargoPlataformaOnline`) · Envío (Gratis / Por cotizar) · Total.
- Botón principal: "Apartar para recoger" o "Solicitar cotización de envío".
- Nota "Pago procesado por Mercado Pago".

### 3.7 Mi cuenta: línea de tiempo del pedido
La misma línea de tiempo de los correos: Pedido → Cotizado → Pagado → En camino → Entregado; al recoger, Pedido → Pagado → Preparando → Listo → Entregado. Los pasos hechos van en verde, el actual en azul con halo y los pendientes en gris. Los datos salen de `etiquetaEstadoPagoPedido` y `etiquetaLogisticaPedido`.

### 3.8 Admin · Nuevo banner (`capturas/celular-7-banner.png`)
Ya está en #309. Solo se ajusta al estilo si hace falta; es opcional.

---

## 4. Fases (una por PR)

| Fase | Contenido | Depende de | Cómo lo revisa Iván |
|---|---|---|---|
| **A** | `tiendaV2.js`, `tiendaV2.css` con alcance, fuentes, interruptor `?v2=1`, `EncabezadoV2`, `PieV2`, `TarjetaProducto`, `EstadoDisponibilidad` | — | Vista previa con `?v2=1`: encabezado, pie y tarjetas nuevas |
| **B** | Inicio v2 completo (3.1) | A | Comparar contra `celular-1-home.png` y `escritorio-inicio.png` |
| **C1** | `/cotizar` sin foto (3.2) | A | Enviar una solicitud de prueba y verla en "Lo que buscan" |
| **D** | Catálogo (3.3) y fichas (3.4, 3.5) | A | Abrir 3 productos: uno en sucursal, uno con receta y uno por encargo |
| **E** | Carrito (3.6) y línea de tiempo de Mi cuenta (3.7) | A; Sprint 0 para el bloqueo completo | Pedido de prueba para recoger y otro con envío |
| **F** | Encender v2 para todos y borrar lo viejo | B–E aprobadas | Producción |
| C2 | Foto de receta (privada) | C1 + aprobación de Iván | — |

**Criterio de terminado de cada fase:**

1. Se ve igual que la captura de referencia en celular (390 px), tableta (820 px) y escritorio (1440 px), con las diferencias de datos reales permitidas.
2. Sin `?v2=1`, la tienda se ve exactamente como hoy.
3. Admin y POS sin cambios visuales.
4. `npm run build` y las pruebas pasan.
5. El PR incluye capturas de las tres medidas.
6. Lighthouse móvil no baja.

---

## 5. Lo que Iván tiene que dar (sin esto, el bloque no se muestra)

1. Qué cubre "especializados" (oncológicos, biológicos…), para el texto del titular.
2. Tiempo de respuesta de una cotización.
3. Nombre y cédula del responsable sanitario, y número de aviso de funcionamiento.
4. Fotos de la fachada y el mostrador.
5. Si algún especializado requiere refrigeración.
