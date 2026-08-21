/** Contenido del Manual interno. Filtrado por módulos que el perfil sí puede ver. */

export const GLOSARIO = [
  { id: "mmaa", term: "MMAA", aliases: ["caducidad", "fecha de caducidad", "0629"], def: "Mes y año de la caja, en 4 dígitos. Ejemplo: junio 2029 se escribe 0629. Nunca se inventa: sale de la caja, no del ticket." },
  { id: "lote", term: "Lote", aliases: ["número de lote", "producción"], def: "Identificación de esa fabricación. El mismo producto puede tener varios lotes en anaquel, cada uno con su caducidad." },
  { id: "lote-distinto", term: "Lote distinto", aliases: ["otro lote"], def: "El SKU ya estaba en catálogo, pero esta entrega es otra producción. Hay que confirmar la caducidad de ESTA caja, no copiar la del anaquel." },
  { id: "fefo", term: "FEFO / PEPS", aliases: ["peps", "primero en caducar", "primero que caduca"], def: "Se vende primero lo que caduca antes. Si un lote no tiene fecha, el sistema lo vende primero (por si ya está viejo). Por eso hay que capturar MMAA al recibir." },
  { id: "ean", term: "Código de barras / EAN", aliases: ["ean", "upc", "pistola", "escáner"], def: "El código de la caja. La pistola lo lee y el sistema busca el producto. No escribas precios aquí." },
  { id: "sku", term: "SKU", aliases: ["sku farmacapital", "fc-"], def: "Clave interna FarmaCapital (ej. FC-06134531). Distinta del código de barras del laboratorio." },
  { id: "folio", term: "Folio", aliases: ["ticket", "número de ticket"], def: "Número del ticket o factura del proveedor. Identifica esa entrega." },
  { id: "borrador", term: "Borrador de recepción", aliases: ["recibir abierto"], def: "Lista en curso. Solo puede haber un borrador a la vez. No lo descartes si es una cola de caducidades (Cityfarma, Farmalive)." },
  { id: "pendiente-alta", term: "Pendiente de alta", aliases: ["no está en catálogo"], def: "El código no está en el catálogo. Se anota, no se vende. El dueño lo da de alta (precio, receta, categoría)." },
  { id: "descuadre", term: "Descuadre", aliases: ["no cuadra"], def: "El total estimado no coincide con el total del ticket. El stock sí puede entrar; hay que avisarle al dueño." },
  { id: "anaquel", term: "Anaquel", aliases: ["piso", "mostrador"], def: "Lo que está en el piso de venta, no en un papel ni en un PDF." },
  { id: "pvp", term: "PVP", aliases: ["precio de venta", "precio al público"], def: "Precio al público. La vendedora no lo captura al recibir. Lo define el dueño." },
  { id: "costo", term: "Costo", aliases: ["precio de compra"], def: "Lo que se pagó al proveedor. No se captura en Recibir. Vive en el lote y lo ve el dueño en Reabasto." },
  { id: "reabasto", term: "Reabasto", aliases: ["qué comprar", "sugerido"], def: "Qué conviene pedir según rotación y existencia. No es la pantalla para recibir cajas." },
  { id: "pos", term: "POS", aliases: ["punto de venta", "caja registradora"], def: "Punto de venta: escanear, cobrar, receta. En el POS no se elige lote: el sistema descuenta por FEFO." },
  { id: "receta", term: "Receta", aliases: ["requiere receta", "controlado"], def: "Algunos medicamentos piden receta al vender. Eso lo configura el dueño en el catálogo, no al recibir." },
  { id: "corte", term: "Corte de caja", aliases: ["fondo", "arqueo"], def: "Cierre del turno: se cuenta el efectivo y se compara con lo que el sistema dice que debió haber." },
  { id: "fondo", term: "Fondo de caja", aliases: ["apertura", "efectivo inicial"], def: "Dinero con el que abres el turno. Lo entregaron; hay que contarlo antes de vender." },
  { id: "midia", term: "Mi Día", aliases: ["inicio vendedor"], def: "Pantalla de arranque del vendedor: ventas del turno, pendientes y atajos. No es el inventario." },
  { id: "devolucion", term: "Devolución", aliases: ["regresar", "cambio"], def: "Regresar una venta. Se busca por folio o teléfono. No borra el historial: ajusta stock y, si aplica, caja." },
  { id: "puntos", term: "Puntos", aliases: ["cliente frecuente"], def: "Programa de lealtad. Se acumulan al vender si el cliente está identificado. No se editan en Recibir." },
  { id: "expediente", term: "Expediente", aliases: ["historia clínica"], def: "Ficha del paciente en consultorio. Solo agenda médica y dueño. No es el catálogo de farmacia." },
  { id: "no-show", term: "No-show", aliases: ["falta a consulta"], def: "El paciente no llegó. Se puede cancelar para no dejar la agenda sucia; al corte se limpian las viejas." },
  { id: "cofepris", term: "COFEPRIS", aliases: ["bitácora", "licencia"], def: "Cumplimiento sanitario. Módulo del dueño: licencias y bitácora. La receta de venta va en el POS." },
  { id: "pwa", term: "Instalar app", aliases: ["pwa", "acceso directo"], def: "Instala FarmaCapital en el teléfono o la computadora para abrirla como app, sin buscar el sitio cada vez." },
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
    resumen: "Tu inicio de turno: cómo vas, qué falta y atajos. No se reciben cajas aquí.",
    pasos: [
      "Al entrar con perfil vendedor aterrizas en Mi Día.",
      "Revisa ventas del turno y pendientes (consultas, caja).",
      "Para vender: Punto de Venta. Para meter mercancía: Inventario → Recibir.",
      "Si te pide abrir caja, cuenta el [[fondo]] antes de cobrar.",
    ],
    dudas: [
      { q: "No veo costos ni ganancias", a: "Así debe ser. Costos y Dashboard son del dueño." },
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
      "Si el producto pide [[receta]], cárgala antes de cobrar.",
      "Identifica al cliente si acumula [[puntos]].",
      "Cobra (efectivo, tarjeta, mixto). Imprime o manda el ticket.",
      "No entres a Recibir desde aquí para «arreglar» un lote: eso es otra pantalla.",
    ],
    dudas: [
      { q: "¿Puedo elegir qué lote descontar?", a: "No. Se descuenta el que caduca primero. Si la fecha está mal, corrígela en Recibir/Lotes, no en el POS." },
      { q: "El código no existe", a: "No lo inventes. Avísale al dueño. Si acaba de llegar, primero Recibir." },
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
    moduloId: "inv",
    invTab: "recibir",
    titulo: "Recibir mercancía",
    resumen: "Pistola = está aquí. [[mmaa]] = fecha de ESTA caja. Cerrar = ya conté lo que sí llegó.",
    pasos: [
      "Inventario → Recibir. Un [[folio]] / ticket a la vez.",
      "Si hay lista gris: no subas el mismo PDF otra vez. Escanea cada caja y pon [[mmaa]].",
      "Si no hay lista: llena proveedor, folio y total → Empezar a escanear. O Subir PDF/CSV (la fecha NO sale del papel).",
      "[[ean]] con pistola → cantidad → [[mmaa]] (4 dígitos, ej. 0629) → Enter.",
      "Gris = falta fecha. Verde = ya confirmaste. Amarillo = [[pendiente-alta]].",
      "Si dice [[lote-distinto]]: es otra producción. Fecha de esta caja, no la del [[anaquel]].",
      "Cerrar recepción. Si hay [[descuadre]] o pendientes de alta, avísale al dueño.",
      "No toques Descartar si es una cola de caducidades ya armada (Cityfarma, Farmalive).",
    ],
    dudas: [
      { q: "El ticket no trae caducidad", a: "Normal. La fecha está en la caja. El PDF nunca debe inventarla." },
      { q: "Ya estaba en catálogo", a: "Igual se recibe. Si el [[lote]] es otro, queda pendiente de corroborar fecha." },
      { q: "¿Pongo el costo?", a: "No. Recibir no pide [[costo]] ni [[pvp]]." },
      { q: "Dos cajas, dos fechas", a: "Dos renglones, dos MMAA. Nunca una sola fecha para los dos." },
    ],
  },
  {
    id: "catalogo",
    moduloId: "inv",
    invTab: "catalogo",
    titulo: "Catálogo",
    resumen: "Buscar existencias y ficha del producto. La vendedora consulta; el dueño edita precios y receta.",
    pasos: [
      "Inventario → Catálogo.",
      "Busca por nombre, [[sku]] o [[ean]].",
      "La vendedora ve existencias. No cambia [[pvp]] ni da de alta para vender.",
      "Para meter piezas nuevas: pestaña Recibir, no «inventar» stock en la ficha.",
    ],
    dudas: [
      { q: "No encuentro un producto que sí vendí", a: "Puede estar inactivo o con otro nombre. Prueba el código de barras. Si no, Recibir o avísale al dueño." },
    ],
  },
  {
    id: "reabasto",
    moduloId: "inv",
    invTab: "reabasto",
    roles: ["admin", "gerente"],
    titulo: "Reabasto (qué comprar)",
    resumen: "Sugerido de compra por rotación. No mezclar con caducidad ni con Recibir.",
    pasos: [
      "Inventario → Reabasto.",
      "Revisa qué está bajo el mínimo. Eso es «qué pedir», no «qué acaba de llegar».",
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
    resumen: "Disponibilidad hacia Rappi. El piso no opera esto.",
    pasos: [
      "Inventario → Rappi.",
      "Revisa cola de disponibilidad. No sustituye Recibir ni el POS de mostrador.",
    ],
  },
  {
    id: "caja",
    moduloId: "caja",
    titulo: "Corte de caja",
    resumen: "Cerrar el turno contando efectivo contra el sistema.",
    pasos: [
      "Abre Corte de caja al terminar el turno (o cuando te lo indiquen).",
      "El vendedor no elige turno: lo asigna RR.HH. El dueño sí puede cubrir.",
      "Cuenta el efectivo. Captura lo contado.",
      "Si hay diferencia, no «ajustes» ventas: anota y avisa.",
      "Confirma el corte. Sin corte, el siguiente turno hereda un lío.",
    ],
    dudas: [
      { q: "No me deja vender", a: "Falta abrir caja con el [[fondo]] que te entregaron. Cuéntalo, no adivines." },
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
      "Operación = el día. Transacciones = listado. Margen = rentabilidad.",
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
    resumen: "Tu calendario de pacientes. Sin POS ni caja.",
    pasos: [
      "Agenda médica es tu inicio.",
      "Revisa citas del día. Marca [[no-show]] si no llegaron.",
      "Abre el [[expediente]] desde la cita cuando vayas a atender.",
    ],
  },
  {
    id: "expedientes",
    moduloId: "exp_dr",
    titulo: "Expedientes",
    resumen: "Historia clínica. No es inventario ni puntos de farmacia.",
    pasos: [
      "Expedientes → busca al paciente.",
      "Registra nota, receta clínica y seguimiento.",
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
    if (t.moduloId && t.moduloId !== "ayuda" && typeof puedeVer === "function" && !puedeVer(usuario, t.moduloId)) {
      return false;
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
