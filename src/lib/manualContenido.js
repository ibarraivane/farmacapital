/** Contenido del Manual interno. Filtrado por módulos que el perfil sí puede ver. */

export const GLOSARIO = [
  { id: "mmaa", term: "MMAA", aliases: ["caducidad", "fecha de caducidad", "0629"], def: "Mes y año de la caja, en 4 dígitos. Ejemplo: junio 2029 se escribe 0629. Nunca se inventa: sale de la caja, no del ticket." },
  { id: "lote", term: "Lote", aliases: ["número de lote", "producción"], def: "Identificación de esa fabricación. El mismo producto puede tener varios lotes en anaquel, cada uno con su caducidad." },
  { id: "lote-distinto", term: "Lote distinto", aliases: ["otro lote"], def: "El SKU ya estaba en catálogo, pero esta entrega es otra producción. Hay que confirmar la caducidad de ESTA caja, no copiar la del anaquel." },
  { id: "fefo", term: "FEFO / PEPS", aliases: ["peps", "primero en caducar", "primero que caduca"], def: "Se vende primero lo que caduca antes. Si un lote no tiene fecha, el sistema lo vende primero (por si ya está viejo). Por eso hay que capturar MMAA al recibir." },
  { id: "ean", term: "Código de barras / EAN", aliases: ["ean", "upc", "pistola", "escáner"], def: "El código de la caja. La pistola lo lee y el sistema busca el producto. No escribas precios aquí." },
  { id: "sku", term: "SKU", aliases: ["sku farmacapital", "fc-"], def: "Clave interna FarmaCapital (ej. FC-06134531). Distinta del código de barras del laboratorio." },
  { id: "folio", term: "Folio", aliases: ["ticket", "número de ticket"], def: "Número del ticket o factura del proveedor. Identifica esa entrega." },
  { id: "borrador", term: "Borrador de recepción", aliases: ["recibir abierto", "ticket pendiente"], def: "Un ticket abierto en Recibir. En la pantalla de inicio ves todos los pendientes (tarjetas). Tocas uno para trabajarlo. ← Tickets te regresa a la lista sin borrar. No toques Descartar si es una cola de caducidades (Cityfarma, Farmalive, Levic)." },
  { id: "pendiente-alta", term: "Pendiente de alta", aliases: ["no está en catálogo"], def: "El código no está en el catálogo. Se anota, no se vende. El dueño lo da de alta (precio, receta, categoría)." },
  { id: "descuadre", term: "Descuadre", aliases: ["no cuadra"], def: "Antes el sistema avisaba si el total del ticket (con IVA) no coincidía con la suma de las líneas. Si todo está en verde, el stock sí entró: no es que falte una caja." },
  { id: "anaquel", term: "Anaquel", aliases: ["piso", "mostrador"], def: "Lo que está en el piso de venta, no en un papel ni en un PDF." },
  { id: "pvp", term: "PVP", aliases: ["precio de venta", "precio al público"], def: "Precio al público. La vendedora lo consulta en el POS al escanear, no en el Catálogo. No se captura al recibir. Lo define el dueño." },
  { id: "costo", term: "Costo", aliases: ["precio de compra", "en cuánto compramos"], def: "Lo que se pagó al proveedor. El piso no lo ve: ni en Catálogo, ni en Recibir (estimado). Vive en el lote y lo ve el dueño." },
  { id: "reabasto", term: "Reabasto", aliases: ["qué comprar", "sugerido", "agotados", "stock bajo"], def: "Reporte de agotados y stock bajo para armar pedidos. Cada ítem va al surtidor con mejor precio y sale en su hoja. No es Recibir. Tampoco es «Lo que buscan» (eso es lo que el cliente pidió en mostrador)." },
  { id: "lo-que-buscan", term: "Lo que buscan", aliases: ["pedidos de mostrador", "faltantes de mostrador", "solicitudes", "lo que piden"], def: "Lista viva: el piso anota lo que el cliente pidió y no hay (o no está en catálogo), con vendedor, cliente, teléfono y si dejó depósito. Sirve para decidir qué comprar." },
  { id: "pos", term: "POS", aliases: ["punto de venta", "caja registradora"], def: "Punto de venta: escanear, cobrar, receta. En el POS no se elige lote: el sistema descuenta por FEFO." },
  { id: "receta", term: "Receta", aliases: ["requiere receta", "controlado"], def: "En antibióticos se recomienda receta, pero no detiene la venta. Solo los controlados exigen receta en el POS (médico, cédula, paciente)." },
  { id: "corte", term: "Corte de caja", aliases: ["fondo", "arqueo"], def: "Cierre del turno: se cuenta el efectivo y se compara con lo que el sistema dice que debió haber." },
  { id: "fondo", term: "Fondo de caja", aliases: ["apertura", "efectivo inicial"], def: "Dinero con el que abres el turno. Lo entregaron; hay que contarlo antes de vender." },
  { id: "midia", term: "Mi Día", aliases: ["inicio vendedor"], def: "Pantalla de arranque del vendedor. El recuadro Tickets se toca: lista del turno (folio, hora, artículos), sin montos. No es el inventario." },
  { id: "devolucion", term: "Devolución", aliases: ["regresar", "cambio"], def: "Regresar una venta. Se busca por folio o teléfono. No borra el historial: ajusta stock y, si aplica, caja." },
  { id: "puntos", term: "Puntos", aliases: ["cliente frecuente"], def: "Programa de lealtad. Se acumulan al vender si el cliente está identificado. No se editan en Recibir." },
  { id: "expediente", term: "Expediente", aliases: ["historia clínica"], def: "Ficha del paciente en consultorio. Solo agenda médica y dueño. No es el catálogo de farmacia." },
  { id: "no-show", term: "No-show", aliases: ["falta a consulta"], def: "El paciente no llegó. Se puede cancelar para no dejar la agenda sucia; al corte se limpian las viejas." },
  { id: "cofepris", term: "COFEPRIS", aliases: ["bitácora", "licencia"], def: "Cumplimiento sanitario. Módulo del dueño: licencias y bitácora. La receta de venta va en el POS." },
  { id: "pwa", term: "Instalar app", aliases: ["pwa", "acceso directo"], def: "Instala FarmaCapital en el teléfono o la computadora para abrirla como app, sin buscar el sitio cada vez." },
  { id: "pdf", term: "PDF del ticket", aliases: ["factura pdf", "subir pdf"], def: "Ticket o factura del proveedor. El sistema lo lee sin formato especial FarmaCapital. Tiene que verse claro. La caducidad nunca se toma del PDF: sale de la caja (MMAA)." },
  { id: "csv", term: "CSV", aliases: ["excel", "plantilla csv"], def: "Plan B si no hay PDF legible. Excel del proveedor guardado como CSV: ean o codigo, nombre, cantidad. Opcional costo, lote, folio. No hay que armarlo a mano con el dueño cada entrega." },
  { id: "recarga", term: "Recarga", aliases: ["tiempo aire", "telcel", "movistar", "servicios", "cfe"], def: "Saldo de celular o pago de luz/TV que se hace en la terminal Point. El cliente te deja efectivo; el costo sale del saldo de Mercado Pago. La compensación (1%) de MP no entra al cajón." },
  { id: "recargo", term: "Recargo de farmacia", aliases: ["comisión farmacia", "tu comisión", "los 5 pesos"], def: "Lo que le sumas al cliente por pagarle un recibo ($8 CFE, $10 Sky). Las recargas de tiempo aire no llevan recargo. Entra al cajón. No es lo que paga Mercado Pago." },
  { id: "compensacion-mp", term: "Compensación MP", aliases: ["1%", "comisión mercado pago", "cashback recarga"], def: "El 1% del monto recargado que Mercado Pago te acredita en tu cuenta cuando la recarga ya quedó. No entra al cajón. Se ve en Actividad de la app." },
  { id: "saldo-mp", term: "Saldo Mercado Pago", aliases: ["saldo point", "fondeo recargas"], def: "Dinero en la cuenta de Mercado Pago. Las recargas se pagan de ahí. Es inventario: si se acaba, la Point deja de recargar. Hay que reponerlo con el efectivo de las recargas." },
];

/** @typedef {{ id: string, moduloId: string, invTab?: string, roles?: string[], titulo: string, resumen: string, pasos: string[], dudas?: {q: string, a: string}[] }} TemaManual */

/** @type {TemaManual[]} */
export const TEMAS = [
  {
    id: "usar-manual",
    moduloId: "ayuda",
    titulo: "Cómo usar este Manual",
    resumen: "Busca una duda, toca un término del glosario o abre el módulo en el que estás trabado.",
    pasos: [
      "El Manual está en el menú (libro). El botón ? flotante no es este Manual.",
      "Arriba escribe lo que no te queda claro: caducidad, corte, receta, lote…",
      "Solo ves los temas de TU perfil. La vendedora no ve Reabasto ni costos; la doctora no ve el POS.",
      "En el glosario toca una palabra. Abajo dice en qué temas aparece.",
      "Si ya entendiste, «Abrir módulo» te lleva a esa pantalla.",
    ],
    dudas: [
      { q: "¿Esto cambia el inventario?", a: "No. El Manual solo explica. Recibir, vender o cortar caja se hace en su módulo." },
    ],
  },
  {
    id: "midia",
    moduloId: "midia",
    roles: ["vendedor"],
    titulo: "Mi Día",
    resumen: "Tu inicio de turno: cómo vas, tickets del turno y atajos. No se reciben cajas aquí.",
    pasos: [
      "Al entrar con perfil vendedor aterrizas en Mi Día. En el menú también ves Recibir, Inventario y Manual.",
      "El recuadro Tickets se toca: abre folio, hora y artículos de TU turno. Sin montos ni edición.",
      "Para vender: Punto de Venta. Para meter cajas: Recibir. Inventario solo consulta existencias.",
      "Si te pide abrir caja, cuenta el [[fondo]] antes de cobrar.",
    ],
    dudas: [
      { q: "No veo costos ni ganancias", a: "Así debe ser. Costos y Dashboard son del dueño." },
      { q: "Toco Tickets y no pasa nada", a: "Recarga fuerte o cierra la app instalada. Debe decir «Toca para ver los tickets»." },
    ],
  },
  {
    id: "pos",
    moduloId: "pos",
    titulo: "Punto de venta (cobrar)",
    resumen: "Pistola, carrito, cliente, receta y cobro. El lote lo elige el sistema ([[fefo]]), no tú.",
    pasos: [
      "Pistola en el buscador, o escribe nombre / [[sku]].",
      "Revisa cantidad en el carrito. Quita líneas si te equivocaste.",
      "Si es [[receta]] de controlado, cárgala antes de cobrar. Antibiótico se cobra igual; la receta es recomendación.",
      "Identifica al cliente si acumula [[puntos]].",
      "Cobra (efectivo, tarjeta, mixto). Imprime o manda el ticket.",
      "Recargas y CFE no van en el carrito: pestaña Servicios. Primero la Point, luego anotas aquí.",
      "No entres a Recibir desde aquí para «arreglar» un lote: eso es otra pantalla.",
    ],
    dudas: [
      { q: "¿Puedo elegir qué lote descontar?", a: "No. Se descuenta el que caduca primero. Si la fecha está mal, corrígela en Recibir/Lotes, no en el POS." },
      { q: "El código no existe", a: "No lo inventes. Avísale al dueño. Si acaba de llegar, primero Recibir." },
      { q: "¿Dónde anoto una recarga de Telcel?", a: "Pestaña Servicios. El paso a paso está en el tema Recargas y pago de servicios." },
    ],
  },
  {
    id: "recargas",
    moduloId: "pos",
    titulo: "Recargas y pago de servicios",
    resumen: "La [[recarga]] se hace en la Point. Aquí solo anotas lo que cobraste. En tiempo aire el recargo va en 0 (ganas el 1% de MP). En recibos (CFE, Sky…) sí hay [[recargo]] al cajón más la [[compensacion-mp]].",
    pasos: [
      "El cliente pide recarga o pagar un servicio (Telcel, CFE, Sky…). Cobra en efectivo si puedes: con tarjeta, Point se come la ganancia.",
      "En la terminal Point: Smart Launcher → Recargas (o Pago de servicios). Número, monto, confirmar. Espera el OK de la operadora.",
      "Ese monto sale de tu [[saldo-mp]], no del cajón. Si el saldo está en ceros, la Point no recarga. Avisa al dueño.",
      "POS → pestaña Servicios. Elige la operadora. Escribe el teléfono o referencia. Monto de la recarga (ej. 50). Las recargas no llevan recargo; en recibos (CFE, Sky…) el recargo se suma solo. Si sale aviso de saldo bajo, avisa al dueño: hay que fondear Mercado Pago.",
      "Marca «ya pagué» (la recarga ya salió en la Point). Toca Efectivo. En recarga el cliente deja solo el monto (ej. $50). En recibos deja monto + recargo (ej. CFE $200 + $8 = $208). Folio SRV-…",
      "Mercado Pago te acredita 1% en tu cuenta cuando la recarga queda hecha. Se ve en Actividad de la app, no en el cajón. En $50 AT&T son $0.50. En un CFE $200 son $8 de recargo + $2 de MP.",
      "Al corte, lo cobrado ya entra solo al efectivo esperado. No lo vuelvas a capturar. El 1% no se cuenta en el cajón: hay que reponer el [[saldo-mp]] con parte de ese efectivo.",
    ],
    dudas: [
      { q: "¿Cuándo me pagan la comisión de Mercado Pago?", a: "Cuando la recarga ya quedó. Entra a tu cuenta de Mercado Pago (Actividad), no al cajón. Es el 1% del monto recargado, no de tu recargo." },
      { q: "¿Los $5 son lo de Mercado Pago?", a: "Ya no cobramos $5 en recargas: el recargo va en 0. Mercado Pago te da el 1% en su app. El recargo ($8, $10) es solo en recibos (CFE, Sky…)." },
      { q: "¿Puedo cobrar la recarga con tarjeta?", a: "Sí, pero Point cobra su comisión sobre el total. En Telcel $50 te come el 1%. En CFE $500 se pierde dinero. Prefiere efectivo." },
      { q: "El cliente ya se fue y no anoté", a: "Anótalo igual en Servicios el mismo turno. Si no, el corte va a decir que sobra efectivo y el dueño no va a poder conciliar el saldo MP." },
      { q: "La Point no deja recargar", a: "Casi siempre se acabó el [[saldo-mp]]. No es un fallo del POS. Avisa para fondear la cuenta." },
      { q: "¿Mercado Pago avisa si se acaba el saldo?", a: "No. El dueño carga el saldo en POS → Servicios (lo que ve en la app de MP) y un mínimo (ej. $500). FarmaCapital avisa a los admins cuando baja. Cada recarga descuenta de ese control." },
      { q: "¿Puedo dejar el recargo en 0?", a: "En recargas ya va en 0. En recibos de servicios el POS pone el recargo solo ($8 CFE, $10 Sky). Si de verdad no cobraste, el dueño lo corrige en Transacciones." },
      { q: "¿Esto es una venta?", a: "No. No tiene folio VTA ni ticket de productos. Vive en POS → Servicios y en Transacciones como recarga." },
    ],
  },
  {
    id: "devoluciones",
    moduloId: "dev",
    titulo: "Devoluciones",
    resumen: "Regresar una venta con folio o teléfono. No borra el historial.",
    pasos: [
      "Abre Devoluciones.",
      "Busca la venta por folio del ticket o teléfono del cliente.",
      "Elige las líneas a devolver y el motivo.",
      "Confirma. El stock regresa; si hubo efectivo, sigue las indicaciones de caja.",
    ],
    dudas: [
      { q: "¿Puedo devolver sin ticket?", a: "Intenta con el teléfono. Si no aparece, el dueño revisa Transacciones." },
    ],
  },
  {
    id: "lo-que-buscan",
    moduloId: "ped_mostrador",
    titulo: "Lo que buscan",
    resumen: "Lista viva de lo que piden en mostrador o en la tienda web y no hay (o no está en catálogo), con cliente y anticipo.",
    pasos: [
      "Abre Lo que buscan en el menú.",
      "Anota qué piden, cantidad y para cuándo (hoy / mañana / sin prisa).",
      "Si está en catálogo, búscala y vincúlala (queda como agotado). Si no, deja el texto libre.",
      "Opcional: nombre y teléfono del cliente, y si dejó depósito o pagó todo.",
      "El sistema te registra a ti como vendedor automáticamente.",
      "Las solicitudes de farmacapital.mx (Te lo conseguimos) llegan solas con chip Tienda web. Aviso también a contacto@farmacapital.mx y farmacapital@outlook.com.",
      "Toca Pasar costo por WhatsApp: le escribes el precio y la liga de pago.",
      "Admin/gerencia cambia el estado: Pedir → Pedido → Llegó (o Descartado).",
      "La pestaña Más pedidos muestra el ranking de los últimos 30 días para decidir compras.",
      "El botón Flyer abre la tarjeta con QR para compartir por WhatsApp.",
    ],
    dudas: [
      { q: "¿Es lo mismo que Reabasto?", a: "No. Reabasto mira stock bajo del catálogo. Esto es lo que la gente pidió aunque no exista en catálogo." },
      { q: "¿El depósito entra a caja?", a: "Esta lista solo lo anota para seguimiento. El cobro del depósito se registra en el POS / caja como corresponda." },
      { q: "¿Cómo llega un pedido de la página?", a: "El cliente busca, no lo encuentra y llena Te lo conseguimos. Te llega correo y aparece aquí. Tú cotizas y le mandas WhatsApp o correo con el costo y la liga." },
    ],
  },
  {
    id: "agenda-vendedor",
    moduloId: "agenda",
    roles: ["vendedor", "admin", "gerente"],
    titulo: "Consultas del día (agenda)",
    resumen: "Quién tiene cita hoy. Cobro de consulta va en el POS, no aquí.",
    pasos: [
      "Abre Agenda de consultas (en vendedor dice Consultas del día).",
      "Confirma llegada o marca [[no-show]] si no vino.",
      "Para cobrar la consulta: Punto de Venta → pestaña Consultas.",
    ],
  },
  {
    id: "recibir",
    moduloId: "recibir",
    invTab: "recibir",
    titulo: "Recibir mercancía",
    resumen: "Pistola = esta caja está aquí. [[mmaa]] = la fecha impresa en ESTA caja. Cerrar = ya conté lo que sí llegó.",
    pasos: [
      "Mira el menú de la izquierda. Hay dos entradas distintas: Recibir (meter cajas) e Inventario (solo consultar qué hay). No son lo mismo. No hay pestaña Catálogo dentro de Recibir.",
      "Toca Recibir. Primera pantalla: tarjetas con el nombre del proveedor (Cityfarma, Farmalive). No hace falta el número del ticket. Toca la tarjeta de esas cajas.",
      "Si el ticket que vas a checar ya está en una tarjeta: tócala, o escanea cualquier caja de ese ticket. No subas otra vez el mismo [[pdf]] ni el mismo [[csv]].",
      "Si no hay tarjeta de ese ticket: toca Nuevo ticket. Escribe el proveedor (puedes elegir de la lista blanca; no el globo negro del sistema). Escribe el [[folio]] que viene en el papel. El piso no ve el total. Luego Empezar a escanear, o Subir PDF / Subir CSV.",
      "El PDF es la foto o archivo del ticket del proveedor. No tiene que decir FarmaCapital. Tiene que verse nítido. La caducidad NUNCA sale del papel: sale de la caja.",
      "Si el PDF no se lee (foto borrosa): no insistas. Toma cada caja, pistola, o usa [[csv]] del Excel del proveedor (columnas ean o codigo, nombre, cantidad).",
      "Ya dentro del ticket verás el recuadro Código de barras con el texto Pistola aquí. Apunta la pistola a la caja. Revisa que el nombre en pantalla sea el de la caja que tienes en la mano.",
      "Cuenta las piezas. Si el número no coincide, corrígelo. Luego Caducidad MMAA: 4 dígitos de ESTA caja. Junio 2029 = 0629. Enter o Guardar renglón.",
      "La línea se pone verde. Toma la siguiente caja. Gris = falta fecha. Amarillo = [[pendiente-alta]] (avísale al dueño; no se vende).",
      "Si dice [[lote-distinto]]: mismo producto, otra fabricación. Pon la fecha de esta caja. No copies la del [[anaquel]].",
      "¿Quieres ver el otro ticket? Toca ← Tickets (arriba). Eso NO borra nada. Toca la otra tarjeta. No toques Descartar: eso sí borra la cola (Cityfarma / Farmalive / Levic).",
      "Cuando las cajas que sí llegaron estén verdes: Cerrar recepción. Si faltan del ticket, el botón dice Recibir lo confirmado y el resto se queda pendiente. Si ya están en anaquel sin fecha, el botón se apaga: hay que escanear, no hay “cerrar de todas maneras”.",
    ],
    dudas: [
      { q: "¿Recibir e Inventario son lo mismo?", a: "No. Recibir = pistola y caducidad de cajas nuevas. Inventario = buscar existencias. El botón Recibir cajas de Inventario te manda a Recibir." },
      { q: "El ticket no trae caducidad", a: "Normal. La fecha está impresa en la caja. El [[pdf]] nunca debe inventarla." },
      { q: "¿El PDF tiene que ser de FarmaCapital?", a: "No. Cualquier ticket o factura que se lea. Foto borrosa de ticket térmico: pistola caja por caja o [[csv]]." },
      { q: "¿De dónde saco el CSV?", a: "Del Excel del proveedor, guardado como CSV. No lo armes a mano con el dueño en cada entrega. Si no hay Excel, no uses CSV." },
      { q: "Cargamos dos tickets, ¿dónde están?", a: "En Recibir, en las tarjetas: Cityfarma 6315912 (11), Farmalive 11590 (6) y Levic 9012078353 (7). Toca uno. Nuevo ticket no pisa el otro. ← Tickets vuelve a esa lista." },
      { q: "Ya estaba en catálogo", a: "Igual se recibe. Si el [[lote]] es otro, confirma la fecha de esta caja." },
      { q: "¿Ya se puede vender?", a: "No. El ticket arma la lista. El stock entra a POS y a la tienda en línea solo cuando el renglón queda verde (pistola + MMAA)." },
      { q: "Dos cajas, dos fechas", a: "Dos renglones, dos [[mmaa]]. Nunca una sola fecha para las dos." },
      { q: "¿Cierro aunque falten MMAA?", a: "No si ya están en anaquel: el botón se apaga. Si son cajas del ticket que no llegaron: Recibir lo confirmado y avisa." },
      { q: "¿Toco Descartar?", a: "Solo si abriste un ticket por error y está vacío. Nunca en Cityfarma, Farmalive ni Levic." },
    ],
  },
  {
    id: "catalogo",
    moduloId: "inv",
    invTab: "catalogo",
    titulo: "Inventario (existencias)",
    resumen: "Buscar existencias y ficha del producto. La vendedora consulta; el dueño edita precios y receta.",
    pasos: [
      "En el menú toca Inventario. Aquí solo miras existencias. Para meter cajas: Recibir (o el botón Recibir cajas, que te lleva ahí).",
      "No vas a ver pestañas Recibir / Catálogo. Recibir ya no vive dentro de esta pantalla.",
      "Busca por nombre, [[sku]] o [[ean]].",
      "Toca Agotados, Bajo stock, Por caducar, etc. Toca Activos para volver al listado general (igual que Limpiar filtros).",
      "El reporte para pedir (agotados y bajos, por surtidor más barato) está en [[reabasto]], no en esta lista.",
      "La vendedora no ve [[costo]] ni [[pvp]] aquí. El precio de venta se consulta en el [[pos]] al escanear.",
      "Si acaba de llegar mercancía: sal de Inventario y entra a Recibir. No «inventes» stock en la ficha.",
    ],
    dudas: [
      { q: "¿Por qué hay Recibir e Inventario?", a: "Porque no son lo mismo. Inventario = consultar. Recibir = pistola + [[mmaa]]. Antes Recibir era una pestaña; ya no." },
      { q: "No encuentro un producto que sí vendí", a: "Puede estar inactivo o con otro nombre. Prueba el código de barras. Si no, Recibir o avísale al dueño." },
      { q: "¿Por qué no veo precios?", a: "El [[costo]] (en cuánto compramos) y el [[pvp]] no salen en Inventario del piso. El PVP se ve en el POS al escanear." },
      { q: "Activos no me quita Bajo stock", a: "En la versión nueva sí. Recarga. Activos limpia el filtro; no hace falta Limpiar filtros para eso." },
    ],
  },
  {
    id: "reabasto",
    moduloId: "inv",
    invTab: "reabasto",
    roles: ["admin", "gerente"],
    titulo: "Reabasto (qué comprar)",
    resumen: "Reporte de agotados y stock bajo. Los pedidos se arman con el surtidor más barato y salen separados.",
    pasos: [
      "Inventario → Reabasto.",
      "Bajar reporte: Excel con hojas Agotados, Stock bajo y Por surtidor.",
      "Pedir agotados y bajos: arma un pedido por cada surtidor (el de mejor precio: listas + última compra). El Surtidor, Farma City, Levic y Exprezo no se mezclan.",
      "Si hay Levic, también baja Pedido_Levic_portal.xlsx para subir al portal.",
      "Caduca 90 días es otra alerta: no la uses como lista de compra.",
      "Cuando llegue el pedido: Recibir, no sumar a mano en Reabasto.",
    ],
  },
  {
    id: "lotes",
    moduloId: "inv",
    invTab: "lotes",
    roles: ["admin", "gerente"],
    titulo: "Lotes PEPS",
    resumen: "Ver y corregir lotes y caducidades. FEFO: sin fecha se vende primero.",
    pasos: [
      "Inventario → Lotes PEPS.",
      "Críticos ≤ 30 días; por vencer ≤ 90 días.",
      "Si Recibir dejó un lote sin fecha, aquí se ve. Mejor capturar [[mmaa]] en Recibir.",
      "No borres un lote con piezas: primero entiende si es error de recepción.",
    ],
  },
  {
    id: "precios-ref",
    moduloId: "inv",
    invTab: "precios",
    roles: ["admin", "gerente"],
    titulo: "Referencias de precio",
    resumen: "Comparables de mercado para fijar PVP. No es el POS.",
    pasos: [
      "Inventario → Referencias de precio.",
      "Sirve para decidir [[pvp]], no para cobrar ni recibir.",
    ],
  },
  {
    id: "rappi",
    moduloId: "inv",
    invTab: "rappi",
    roles: ["admin", "gerente"],
    titulo: "Rappi",
    resumen: "Disponibilidad hacia Rappi y precios de otras tiendas en línea. El piso no opera esto.",
    pasos: [
      "Inventario → Rappi → Disponibilidad: cola y colchón. El Excel de Partner se rellena con Precio y SI/NO (no piezas).",
      "Inventario → Rappi → Precios en línea: qué cobran GDL, Farmatodo, Benavides y el súper.",
      "El sugerido usa farmacias + Del Ahorro / Similares. El súper no lo mueve.",
      "No sustituye Recibir ni el POS de mostrador.",
    ],
  },
  {
    id: "caja",
    moduloId: "caja",
    titulo: "Corte de caja",
    resumen: "Cerrar el turno contando efectivo contra el sistema. Las [[recarga]]s ya entran solas; el 1% de MP no está en el cajón.",
    pasos: [
      "Abre Corte de caja al terminar el turno (o cuando te lo indiquen).",
      "El vendedor no elige turno: lo asigna RR.HH. El dueño sí puede cubrir.",
      "Cuenta el efectivo. Captura lo contado. No copies un número que viste antes: el conteo es a ciegas a propósito.",
      "Si hubo recargas, el recuadro Pagos de servicio ya suma el efectivo y la tarjeta de esas operaciones. No los captures otra vez.",
      "Ese efectivo de recargas no es ganancia extra: hay que reponer el [[saldo-mp]]. La [[compensacion-mp]] (1%) vive en la app de Mercado Pago.",
      "Si hay diferencia, no «ajustes» ventas: anota y avisa.",
      "Confirma el corte. Sin corte, el siguiente turno hereda un lío.",
    ],
    dudas: [
      { q: "No me deja vender", a: "Falta abrir caja con el [[fondo]] que te entregaron. Cuéntalo, no adivines." },
      { q: "Me sobra efectivo y vendí recargas", a: "Normal si no repones el saldo MP. El cajón tiene el dinero del cliente; el costo ya salió de Mercado Pago." },
    ],
  },
  {
    id: "instalar-app",
    moduloId: "pwa",
    titulo: "Instalar la app",
    resumen: "Acceso directo en teléfono o computadora.",
    pasos: [
      "Abre Instalar app.",
      "Sigue las instrucciones de tu aparato (Safari / Chrome / escritorio).",
      "Úsala para el turno. Sigue necesitando internet para cobrar y recibir.",
    ],
  },
  {
    id: "dashboard",
    moduloId: "dash",
    roles: ["admin", "gerente"],
    titulo: "Dashboard",
    resumen: "Operación, resumen, transacciones y margen. Datos de negocio, no de piso.",
    pasos: [
      "Ventas / Dashboard.",
      "Operación = el día. Transacciones = listado (ventas y recargas SRV-). Margen = rentabilidad.",
      "En una recarga el recargo va en 0; la ganancia es la compensación MP (1%). En recibos sí ves recargo de farmacia + 1%. El 1% no es venta de mostrador.",
      "Alertas de caducidad a 90 días: para actuar (devolver, marcar), no para vender más barato a ciegas.",
    ],
  },
  {
    id: "clientes",
    moduloId: "cli",
    roles: ["admin", "gerente"],
    titulo: "Clientes y puntos",
    resumen: "Padrón y lealtad. El alta rápida también ocurre al vender en el POS.",
    pasos: [
      "Clientes & Puntos.",
      "Corrige teléfono y datos. Los [[puntos]] se mueven sobre todo en el POS.",
    ],
  },
  {
    id: "pedidos-online",
    moduloId: "ped_online",
    roles: ["admin", "gerente"],
    titulo: "Pedidos online",
    resumen: "Pedidos de la tienda web. Se atienden como pestaña del POS.",
    pasos: [
      "Pedidos online o POS → pedidos web.",
      "Confirma, surte y cobra según el flujo. El stock sale igual que una venta de mostrador.",
    ],
  },
  {
    id: "consultorio",
    moduloId: "cons",
    roles: ["admin", "gerente"],
    titulo: "Consultorio (configuración)",
    resumen: "Armado del consultorio. La doctora usa Agenda médica y Expedientes.",
    pasos: [
      "Consultorio para configuración. Metas y precios de consulta están en Metas y Precios.",
      "No confundir con Recibir mercancía.",
    ],
  },
  {
    id: "metas-precios",
    moduloId: "config_cons",
    roles: ["admin", "gerente"],
    titulo: "Metas y precios (consulta)",
    resumen: "Honorarios y metas del consultorio. No es el PVP de farmacia.",
    pasos: [
      "Metas y Precios.",
      "Ahí se define lo que se cobra por consulta, no el [[pvp]] del anaquel.",
    ],
  },
  {
    id: "agenda-doctora",
    moduloId: "cons_dr",
    roles: ["doctora"],
    titulo: "Agenda médica",
    resumen: "Tus consultas del día. Sin POS, sin caja y sin agendar.",
    pasos: [
      "Agenda médica es tu inicio: ves las consultas del día, no un calendario de huecos.",
      "Entrá a la siguiente consulta pagada. Si falta el pago, el botón no avanza.",
      "En la ficha: signos, diagnóstico, receta con folio y seguimiento. La receta baja a caja para surtirse.",
      "Quien anula o marca [[no-show]] es mostrador, no vos.",
    ],
  },
  {
    id: "expedientes",
    moduloId: "exp_dr",
    titulo: "Expedientes",
    resumen: "Historia clínica. No es inventario ni puntos de farmacia.",
    pasos: [
      "Expedientes → busca al paciente → Ver expediente.",
      "Arriba ves alergias, un resumen y las gráficas de peso, talla, IMC y signos (cómo ha ido evolucionando).",
      "Abajo está el historial de citas. Si abres una ficha, «Volver a citas» te regresa a ese expediente, no a la lista.",
      "La receta de mostrador (venta de medicamento) se cobra en el POS de farmacia, no aquí.",
    ],
  },
  {
    id: "cofepris",
    moduloId: "cof",
    roles: ["admin", "gerente"],
    titulo: "COFEPRIS",
    resumen: "Licencias y bitácora sanitaria.",
    pasos: [
      "Módulo COFEPRIS del dueño.",
      "La receta al vender controlados se pide en el POS, no sustituye esta bitácora.",
    ],
  },
  {
    id: "facturacion",
    moduloId: "fact",
    roles: ["admin", "gerente"],
    titulo: "Facturación CFDI",
    resumen: "Timbrar facturas. No es el ticket de mostrador.",
    pasos: [
      "Facturación.",
      "El ticket de venta no es factura. Aquí se emite CFDI cuando el cliente lo pide.",
    ],
  },
  {
    id: "promociones",
    moduloId: "promo",
    roles: ["admin", "gerente"],
    titulo: "Promociones",
    resumen: "Ofertas de tienda y piso. El POS las aplica si están vigentes.",
    pasos: [
      "Promociones: arma vigencia y productos.",
      "No uses una promo para «ocultar» caducidad: eso se ve en Lotes / Recibir.",
    ],
  },
  {
    id: "banners",
    moduloId: "banners",
    roles: ["admin", "gerente"],
    titulo: "Banners de la tienda",
    resumen: "Imágenes del sitio público.",
    pasos: [
      "Banners: hero, franja, mosaico o popup.",
      "No afecta inventario ni Recibir.",
    ],
  },
  {
    id: "asistente",
    moduloId: "bot",
    roles: ["admin", "gerente"],
    titulo: "Asistente IA",
    resumen: "Ayuda con costos de uso. El piso usa el Manual, no esto.",
    pasos: [
      "Asistente IA para el dueño.",
      "Dudas de operación de piso: módulo Manual (gratis, filtrado por perfil).",
    ],
  },
  {
    id: "usuarios",
    moduloId: "usuarios",
    roles: ["admin", "gerente"],
    titulo: "Usuarios",
    resumen: "Altas, rol y módulos. El Manual se muestra a todos los perfiles.",
    pasos: [
      "Usuarios → crea vendedor, doctora o admin.",
      "🔧 Módulos: no habilites Dashboard ni costos a un vendedor.",
      "El Manual no se quita: todos pueden consultarlo.",
    ],
  },
  {
    id: "rrhh",
    moduloId: "rrhh",
    roles: ["admin", "gerente"],
    titulo: "RR.HH.",
    resumen: "Turnos y personal. El vendedor no elige su turno en caja.",
    pasos: [
      "RR.HH. asigna turnos.",
      "Sin turno, el vendedor no puede cortar ni a veces abrir bien la caja.",
    ],
  },
];

function sinAcentos(s) {
  return String(s || "")
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "");
}

export function hayrol(roles, rol) {
  if (!roles || !roles.length) return true;
  return roles.includes(rol);
}

/**
 * Temas visibles: módulo que el usuario puede ver + rol del tema.
 * Recibir/catálogo sí; reabasto/lotes no para vendedor.
 */
export function temasParaUsuario(usuario, puedeVer) {
  const rol = usuario?.rol;
  const vendedor = rol === "vendedor";
  return TEMAS.filter((t) => {
    if (!hayrol(t.roles, rol)) return false;
    if (t.moduloId && t.moduloId !== "ayuda" && typeof puedeVer === "function") {
      const visible = puedeVer(usuario, t.moduloId)
        || (t.moduloId === "recibir" && puedeVer(usuario, "inv"));
      if (!visible) return false;
    }
    if (vendedor && t.invTab && !["recibir", "catalogo"].includes(t.invTab)) return false;
    return true;
  });
}

export function buscarManual(query, temas, glosario = GLOSARIO) {
  const q = sinAcentos(query).trim();
  if (!q) return { temas: temas || [], glosario: [] };
  const tokens = q.split(/\s+/).filter(Boolean);
  const hit = (text) => {
    const t = sinAcentos(text);
    return tokens.every((tok) => t.includes(tok));
  };
  const blobTema = (t) =>
    [t.titulo, t.resumen, t.id, ...(t.pasos || []).map((p) => p.replace(/\[\[|\]\]/g, "")), ...(t.dudas || []).flatMap((d) => [d.q, d.a])].join(" ");
  const blobGlo = (g) => [g.term, g.def, g.id, ...(g.aliases || [])].join(" ");
  const temasHit = (temas || []).filter((t) => hit(blobTema(t)));
  const gloHit = (glosario || []).filter((g) => hit(blobGlo(g)));
  return { temas: temasHit, glosario: gloHit };
}

export function glosarioPorId(id) {
  return GLOSARIO.find((g) => g.id === id) || null;
}

export function temasQueMencionan(termId, temas) {
  const token = `[[${termId}]]`;
  return (temas || []).filter((t) => {
    const blob = [t.resumen, ...(t.pasos || []), ...(t.dudas || []).flatMap((d) => [d.q, d.a])].join(" ");
    return blob.includes(token) || sinAcentos(blob).includes(sinAcentos(glosarioPorId(termId)?.term || ""));
  });
}
