# Rediseño v2 de FarmaCapital: paquete para Cursor

**Para Iván:** este paquete convierte el prototipo que aprobaste (el v2/v3 con las ideas de ChatGPT) en la tienda real. Cursor escribe el código; tú solo pegas un mensaje por fase y revisas la vista previa.

## Por qué todavía no lo ves

Lo que Cursor subió hasta ahora fueron piezas sueltas:

- las fichas con descripción;
- los banners por plantilla;
- la animación de entrada.

El diseño en sí (colores, letra, encabezado, inicio, tarjetas, ficha y carrito) nunca se le pidió como programación, solo existía como prototipo en HTML. Eso es lo que hace este paquete.

## Qué contiene

| Archivo | Para qué |
|---|---|
| `REDISENO_V2_SPEC.md` | La especificación completa para Cursor: reglas, colores, letras, cada pantalla y las fases. |
| `referencia/prototipo-v3.html` | El prototipo. Se abre con doble clic. |
| `referencia/capturas/` | Cómo debe verse cada pantalla, en celular y en escritorio. |
| `referencia/estilos-prototipo-v3.css` | Medidas y colores exactos del prototipo. |
| `codigo-base/src/theme/tiendaV2.js` | Los colores y letras ya listos en código, con el interruptor `?v2=1`. |

## Cómo se hace (una fase a la vez)

1. Descomprime este paquete dentro del proyecto en Cursor, en una carpeta `docs/rediseno-v2/`.
2. Pega en Cursor el mensaje de la **Fase A** (abajo).
3. Cuando Cursor abra el PR, entra a la vista previa de Vercel **agregando `?v2=1` al final de la dirección** (por ejemplo, `https://…vercel.app/?v2=1`). Sin eso verás la tienda de siempre.
4. Si se ve como las capturas, apruebas el PR y pasas a la siguiente fase. Si no, me mandas captura y lo corregimos.

Mientras no se active para todos (fase F), tus clientes siguen viendo la tienda actual. Nada se rompe.

---

## Mensajes para pegar en Cursor

### Fase A: base visual
> Lee `docs/rediseno-v2/REDISENO_V2_SPEC.md` completo y respeta la sección 1 (reglas). Implementa la **Fase A**: copia `docs/rediseno-v2/codigo-base/src/theme/tiendaV2.js` a `src/theme/tiendaV2.js`; crea `src/components/tienda/v2/tiendaV2.css` con los estilos de `docs/rediseno-v2/referencia/estilos-prototipo-v3.css` con alcance `.fc-v2`; agrega las fuentes Archivo, Fraunces (cursiva) e IBM Plex Mono; y crea `EncabezadoV2`, `PieV2`, `TarjetaProducto` y `EstadoDisponibilidad` según la sección 2. Monta todo solo cuando `tiendaV2Activa()` sea verdadero. No modifiques `src/theme/tokens.js`, Admin, POS, precios ni pagos. Rama nueva, PR hacia `main` sin merge, con capturas a 390, 820 y 1440 px con `?v2=1` y sin él.

### Fase B: inicio
> Con la Fase A aprobada, implementa la **Fase B** de `docs/rediseno-v2/REDISENO_V2_SPEC.md`: el inicio v2 (sección 3.1), igual a `referencia/capturas/celular-1-home.png` y `referencia/capturas/escritorio-inicio.png`. Usa datos reales. No muestres textos entre corchetes: si falta un dato, oculta el bloque. Reusa `BannersEstaSemana` e `IntroAnimacion`. Solo con `?v2=1`. PR sin merge, con capturas.

### Fase C1: cotizar especializado
> Implementa la **Fase C1** de `docs/rediseno-v2/REDISENO_V2_SPEC.md` (sección 3.2): la ruta `/cotizar` con el formulario, **sin foto de receta**. Envía por `/api/solicitudes` con `tipo: 'especializado'`, para que llegue a "Lo que buscan" con folio. El consentimiento es obligatorio. Pantalla de éxito como en `referencia/capturas/celular-2-cotizar.png`. PR sin merge.

### Fase D: catálogo y fichas
> Implementa la **Fase D** de `docs/rediseno-v2/REDISENO_V2_SPEC.md` (secciones 3.3, 3.4 y 3.5): catálogo y fichas v2 con los acordeones alimentados por la ficha enriquecida (#309). Un acordeón sin datos no se muestra. No cambies la lógica de bajo pedido ni de precios. Solo con `?v2=1`. PR sin merge, con capturas de un producto en sucursal, uno con receta y uno por encargo.

### Fase E: carrito y Mi cuenta
> Implementa la **Fase E** de `docs/rediseno-v2/REDISENO_V2_SPEC.md` (secciones 3.6 y 3.7): carrito v2 con el aviso temprano de productos que no se pueden enviar y el desglose con Servicio; y la línea de tiempo del pedido en Mi cuenta. No cambies el cálculo del total ni el cobro. Solo con `?v2=1`. PR sin merge.

### Fase F: encender para todos
> Con B, C1, D y E aprobadas: activa v2 por defecto (`REACT_APP_TIENDA_V2=1` en Vercel) y, en un PR aparte, elimina los componentes viejos que ya no se usan (`HeroCarousel`, `PopupBienvenida`, `HomeBannersStrip`, `HomeBannersTiles`). Revisa que Admin y POS no cambien.

---

## Lo que falta que me des

Mientras no lo tengamos, esos bloques simplemente no aparecen:

- qué cubre "especializados";
- en cuánto tiempo responden una cotización;
- nombre y cédula del responsable sanitario, y número de aviso de funcionamiento;
- fotos de la fachada y el mostrador.

## Pendiente aparte

- El paquete de **correos v2** (`farmacapital-correos-para-cursor-v2.zip`) se sube por separado.
- El **Sprint 0** (interruptor de antibióticos con los 5 ajustes de ChatGPT) es necesario para el bloqueo completo del carrito en la fase E. Te lo preparo como paquete cuando lleguemos ahí.
