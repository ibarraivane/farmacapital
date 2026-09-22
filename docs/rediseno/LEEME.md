# Rediseño de FarmaCapital con el diseño de ChatGPT: paquete para Cursor

**Para Iván:** este paquete usa **el diseño que creó ChatGPT** (inicio, catálogo, ficha, carrito y sucursal) como base. Solo lleva los ajustes que acordamos (sin "Desde 2016", sin Chinampac en los textos de venta, un solo precio en línea) y dos cosas que pediste: cotizar medicamentos especializados y descripciones detalladas. **Reemplaza al paquete anterior** (`farmacapital-rediseno-v2-para-cursor.zip`), que no uses.

Abre `referencia/prototipo-chatgpt-ajustado.html` con doble clic para verlo y navegarlo antes de empezar.

## Por qué no veías el diseño de ChatGPT

Lo que Cursor subió hasta ahora fueron piezas sueltas:

- las fichas con descripción;
- los banners por plantilla;
- la animación de entrada.

El diseño en sí nunca se le pidió como programación. Además, el paquete anterior usaba mi prototipo (v3) en lugar del diseño de ChatGPT: tomé solo algunas ideas suyas y cambié el resto. Este paquete corrige eso: la referencia es el diseño de ChatGPT.

## Qué contiene

| Archivo | Para qué |
|---|---|
| `REDISENO_SPEC.md` | La especificación para Cursor: reglas, ajustes acordados, cada pantalla y las fases. |
| `referencia/prototipo-chatgpt-ajustado.html` | **El diseño de ChatGPT con los ajustes.** Se abre con doble clic y se puede navegar. |
| `referencia/prototipo-chatgpt-original.html` | El diseño de ChatGPT tal cual, para comparar. |
| `referencia/capturas/` | Cómo debe verse cada pantalla, en celular y en escritorio. |
| `referencia/estilos-prototipo.css` | Medidas y colores exactos del diseño de ChatGPT, listos para la tienda. |
| `codigo-base/src/theme/tiendaV2.js` | Los colores y letras ya listos en código, con el interruptor `?v2=1`. |

## Cómo se hace (una fase a la vez)

1. Descomprime este paquete dentro del proyecto en Cursor, en una carpeta `docs/rediseno/`.
2. Pega en Cursor el mensaje de la **Fase A** (abajo).
3. Cuando Cursor abra el PR, entra a la vista previa de Vercel **agregando `?v2=1` al final de la dirección** (por ejemplo, `https://…vercel.app/?v2=1`). Sin eso verás la tienda de siempre.
4. Si se ve como las capturas, apruebas el PR y pasas a la siguiente fase. Si no, me mandas captura y lo corregimos.

Mientras no se active para todos (fase F), tus clientes siguen viendo la tienda actual. Nada se rompe.

---

## Mensajes para pegar en Cursor

### Fase A: base visual
> Lee `docs/rediseno/REDISENO_SPEC.md` completo y respeta la sección 1 (reglas). Implementa la **Fase A**: copia `docs/rediseno/codigo-base/src/theme/tiendaV2.js` a `src/theme/tiendaV2.js`; copia `docs/rediseno/referencia/estilos-prototipo.css` a `src/components/tienda/v2/tiendaV2.css` (ya trae el alcance `.fc-v2`) con los valores exactos; asegura las fuentes Inter y Fraunces cursiva; y crea el encabezado, el menú, el pie y `TarjetaProducto` según las secciones 3.1 y 4. La referencia es `docs/rediseno/referencia/prototipo-chatgpt-ajustado.html`. Monta todo solo cuando `tiendaV2Activa()` sea verdadero. No modifiques `src/theme/tokens.js`, Admin, POS, precios ni pagos. Rama nueva, PR hacia `main` sin merge, con capturas a 390, 820 y 1280 px con `?v2=1` y sin él.

### Fase B: inicio
> Con la Fase A aprobada, implementa la **Fase B** de `docs/rediseno/REDISENO_SPEC.md`: el inicio (sección 3.2), igual a `referencia/capturas/celular-1-inicio.png` y `referencia/capturas/escritorio-1-inicio.png`. Usa datos reales. No muestres textos entre corchetes: si falta un dato, oculta el bloque. Reusa `BannersEstaSemana` e `IntroAnimacion`. Solo con `?v2=1`. PR sin merge, con capturas.

### Fase C1: cotizar especializado
> Implementa la **Fase C1** de `docs/rediseno/REDISENO_SPEC.md` (sección 3.6): la ruta `/cotizar` con el formulario, **sin foto de receta**. Envía por `/api/solicitudes` con `tipo: 'especializado'`, para que llegue a "Lo que buscan" con folio. El consentimiento es obligatorio. Pantallas como `referencia/capturas/celular-5-cotizar.png` y `celular-6-cotizar-enviado.png`. PR sin merge.

### Fase D: catálogo y fichas
> Implementa la **Fase D** de `docs/rediseno/REDISENO_SPEC.md` (secciones 3.3, 3.4 y 3.7): catálogo, ficha y sucursal, con los acordeones alimentados por la ficha enriquecida (#309). Un acordeón sin datos no se muestra. No cambies la lógica de bajo pedido ni de precios. Solo con `?v2=1`. PR sin merge, con capturas de un producto en sucursal, uno con receta y uno por encargo.

### Fase E: carrito y Mi cuenta
> Implementa la **Fase E** de `docs/rediseno/REDISENO_SPEC.md` (secciones 3.5 y 3.8): carrito con el aviso temprano de productos que no se pueden enviar y el desglose con Servicio; y la línea de tiempo del pedido en Mi cuenta. No cambies el cálculo del total ni el cobro. Solo con `?v2=1`. PR sin merge.

### Fase F: encender para todos
> Con B, C1, D y E aprobadas: activa el rediseño por defecto (`REACT_APP_TIENDA_V2=1` en Vercel) y, en un PR aparte, elimina los componentes viejos que ya no se usan (`HeroCarousel`, `PopupBienvenida`, `HomeBannersStrip`, `HomeBannersTiles`). Revisa que Admin y POS no cambien.

---

## Lo que falta que me des

Mientras no lo tengamos, esos bloques simplemente no aparecen:

- qué cubre "especializados";
- en cuánto tiempo responden una cotización;
- nombre y cédula del responsable sanitario, y número de aviso de funcionamiento;
- fotos de la fachada y el mostrador;
- horarios reales del consultorio (los del prototipo los puso ChatGPT).

## Pendiente aparte

- El paquete de **correos v2** (`farmacapital-correos-para-cursor-v2.zip`) se sube por separado.
- El **Sprint 0** (interruptor de antibióticos con los 5 ajustes de ChatGPT) es necesario para el bloqueo completo del carrito en la fase E. Te lo preparo como paquete cuando lleguemos ahí.
