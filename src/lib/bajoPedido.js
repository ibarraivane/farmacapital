/**
 * BAJO PEDIDO — reglas únicas para tienda, carrito, checkout y admin.
 *
 * Un producto bajo pedido (`productos.bajo_pedido = true`) no está en anaquel:
 * se exhibe con stock 0, sin «Agotado», y se consigue con mayorista.
 * - Con ancla usable (precio > $0.01): CTA «Encargar» → carrito → pago con
 *   RESERVA en tarjeta (se cobra al conseguirlo; si no, se cancela sin cargo).
 * - Sin ancla: CTA «Solicitar precio» → formulario de /pedidos-especiales.
 * Rubros de la vitrina salen de categoria/subcategoria (no hay categoría nueva).
 */
import { categoriaCanon } from "../constants/categoriasProducto";
import { precioAnclaUsable, precioOnlineMp } from "./precioOnlineMp";

export const TEXTO_RESERVA =
  "Apártalo con tarjeta de crédito. Solo se cobra cuando llega; si no lo conseguimos, no pagas nada.";

export const TEXTO_AVISO_RECETA =
  "Los medicamentos que requieren receta se surten presentando la receta en tienda. No encargamos en línea medicamentos controlados.";

export const BADGE_SOBRE_PEDIDO = "Sobre pedido · 24-48 h";
export const BADGE_EN_TIENDA = "En tienda";
export const CTA_SOLICITAR_PRECIO = "Solicitar precio";
/** Fase 2: las páginas de categoría mezclan anaquel + encargo (el carrito no). */
export const FASE2_INCLUIR_ANAQUEL = true;
export const FRANJA_HOME = "¿No lo encuentras? Lo pedimos por ti · 24-48 h";
export const TEXTO_BUSQUEDA_VACIA = "No lo tenemos en tienda, pero lo pedimos por ti. Llega en 24-48 h.";

/** Tope por línea en el carrito (no depende del stock físico). */
export const CANTIDAD_MAX_BAJO_PEDIDO = 12;

/** Días que Mercado Pago sostiene la reserva antes de vencer. */
export const DIAS_RESERVA_MP = 5;

export const RUBROS_BAJO_PEDIDO = Object.freeze([
  { id: "dermatologia", label: "Dermatología" },
  { id: "vitaminas", label: "Vitaminas" },
  { id: "suplementos", label: "Suplementos" },
  { id: "proteina", label: "Nutrición deportiva" },
  { id: "dispositivos", label: "Dispositivos médicos" },
]);

/** Categorías de vitrina + pedidos. Dispositivos viven en /dispositivos y en Pedidos especiales. */
export const SECCIONES_CONSEGUIR = Object.freeze([
  {
    id: "dermatologia",
    page: "dermocosmetica",
    label: "Dermocosmética",
    titulo: "Dermocosmética",
    teaser: "Lo que te recetó el dermatólogo.",
    desc: "La crema, el gel o el protector que te recetaron.",
    rubros: Object.freeze(["dermatologia"]),
  },
  {
    id: "nutricion",
    page: "vitaminas",
    label: "Vitaminas y suplementos",
    titulo: "Vitaminas y suplementos",
    teaser: "Vitaminas, omega y proteína.",
    desc: "Lo de todos los días y lo del entrenamiento.",
    rubros: Object.freeze(["vitaminas", "suplementos", "proteina"]),
  },
  {
    id: "dispositivos",
    page: "dispositivos",
    label: "Dispositivos médicos",
    titulo: "Dispositivos médicos",
    teaser: "Tensiómetro, glucómetro o nebulizador.",
    desc: "El aparato que te pidieron en consulta.",
    rubros: Object.freeze(["dispositivos"]),
  },
]);

const SECCION_ALIAS = {
  derma: "dermatologia",
  dermatologia: "dermatologia",
  dermatologico: "dermatologia",
  dermocosmetica: "dermatologia",
  nutri: "nutricion",
  nutricion: "nutricion",
  vitaminas: "nutricion",
  suplementos: "nutricion",
  proteina: "nutricion",
  proteinas: "nutricion",
  nutriciondeportiva: "nutricion",
  deporte: "nutricion",
  dispositivos: "dispositivos",
  dispositivo: "dispositivos",
  dispositivomedico: "dispositivos",
  dispositivosmedicos: "dispositivos",
  equipomedico: "dispositivos",
};

const RUBRO_ALIAS = {
  vitaminas: "vitaminas",
  vitamina: "vitaminas",
  suplementos: "suplementos",
  suplemento: "suplementos",
  proteina: "proteina",
  proteinas: "proteina",
  nutriciondeportiva: "proteina",
  deporte: "proteina",
  deportiva: "proteina",
  creatina: "proteina",
};

/** Aliases de `?seccion=` que además fijan el chip de nutrición. */
const SECCION_RUBRO_ALIAS = {
  suplementos: "suplementos",
  proteina: "proteina",
  proteinas: "proteina",
  nutriciondeportiva: "proteina",
  deporte: "proteina",
};

/** `?seccion=dermatologia` | `nutricion` (y alias). Vacío = pedidos especiales. */
export function seccionConseguirDeQuery(search) {
  try {
    const raw = new URLSearchParams(typeof search === "string" ? search : "").get("seccion");
    const key = norm(raw).replace(/[^a-z]/g, "");
    return SECCION_ALIAS[key] || "";
  } catch {
    return "";
  }
}

/** `?rubro=` de nutrición. Desconocido → "" (chip Todos). */
export function rubroDeQuery(search) {
  try {
    const raw = new URLSearchParams(typeof search === "string" ? search : "").get("rubro");
    const key = norm(raw).replace(/[^a-z]/g, "");
    return RUBRO_ALIAS[key] || "";
  } catch {
    return "";
  }
}

/** Si el alias de sección implica un chip (suplementos / proteína). */
export function rubroDesdeAliasSeccion(search) {
  try {
    const raw = new URLSearchParams(typeof search === "string" ? search : "").get("seccion");
    const key = norm(raw).replace(/[^a-z]/g, "");
    return SECCION_RUBRO_ALIAS[key] || "";
  } catch {
    return "";
  }
}

export function seccionConseguirPorId(id) {
  return SECCIONES_CONSEGUIR.find((s) => s.id === id) || null;
}

/** 3-4 marcas con más productos activos del rubro/sección. Nunca inventa. */
export function marcasDestacadas(productos, seccion, limite = 4) {
  const list = filtrarSeccion(productos, seccion, { incluirAnaquel: FASE2_INCLUIR_ANAQUEL });
  const counts = new Map();
  for (const p of list) {
    const m = String(p.marca || "").trim();
    if (!m) continue;
    counts.set(m, (counts.get(m) || 0) + 1);
  }
  return [...counts.entries()]
    .sort((a, b) => b[1] - a[1] || a[0].localeCompare(b[0], "es", { sensitivity: "base" }))
    .slice(0, Math.max(1, limite))
    .map(([m]) => m);
}

export function copyMarcasSeccion(productos, seccion) {
  const sec = seccionConseguirPorId(seccion);
  const marcas = marcasDestacadas(productos, seccion, 4);
  const base = sec?.desc || "";
  if (!marcas.length) return base;
  const lista =
    marcas.length === 1
      ? marcas[0]
      : `${marcas.slice(0, -1).join(", ")} y ${marcas[marcas.length - 1]}`;
  return `${lista}.`;
}

function norm(s) {
  return String(s ?? "")
    .trim()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase();
}

export function esBajoPedido(p) {
  return Boolean(p && p.bajo_pedido === true);
}

/** Ancla guardada en inventario (antes de aplicar el incremento web). */
export function precioAncla(p) {
  if (!p) return 0;
  const raw = p.precio_ancla != null ? p.precio_ancla : p.precio;
  const n = Number(raw);
  return Number.isFinite(n) ? n : 0;
}

/** "encargar" si se puede pagar en línea, "cotizar" si no hay precio usable, null si no es bajo pedido. */
export function ctaBajoPedido(p) {
  if (!esBajoPedido(p)) return null;
  return precioAnclaUsable(precioAncla(p)) ? "encargar" : "cotizar";
}

export function rubroDeProducto(p) {
  if (!p) return "";
  const cat = categoriaCanon(p.categoria);
  const sub = norm(p.subcategoria);
  if (cat === "Cuidado personal" && sub.startsWith("dermatolog")) return "dermatologia";
  if (cat === "Vitaminas") return "vitaminas";
  if (cat === "Suplemento") return esNutricionDeportiva(sub, p.nombre) ? "proteina" : "suplementos";
  if (cat === "Dispositivo médico") return "dispositivos";
  return "";
}

/** Proteína, creatina, pre-entreno. No pancreatina ni shampoo con “proteína”. */
export function esNutricionDeportiva(subcategoria, nombre) {
  const sub = norm(subcategoria);
  const nom = norm(nombre);
  const blob = `${sub} ${nom}`.replace(/-/g, " ");
  if (/pancreatin/.test(blob)) return false;
  if (/(shampoo|acondicionador|peinar|cabello|capilar)/.test(blob)) return false;
  if (sub.startsWith("protein") || sub.startsWith("nutricion deport") || sub.startsWith("deport")) {
    return true;
  }
  return /(^|[^a-z])(creatina|whey|pre[- ]?entren|bcaa|aminoacido|ganador de peso|mass gainer)/.test(blob)
    || /(proteina 90|proteina vegetal|proteina whey|proteina en polvo|proteina isolate|proteina low)/.test(blob);
}

/**
 * Producto como lo ve la TIENDA WEB: ancla → precio con MP.
 * Idempotente: si ya trae `precio_ancla`, no vuelve a inflar.
 * Bajo pedido: sin descuentos (el servidor cobra fc_precio_online_mp sin promos).
 */
export function prepararProductoTienda(p) {
  if (!p) return p;
  const ancla = precioAncla(p);
  const web = precioOnlineMp(ancla);
  if (web == null) {
    if (!esBajoPedido(p)) return p;
    return {
      ...p,
      precio_ancla: ancla,
      precio: 0,
      descuento_pct: 0,
      precio_marca: null,
    };
  }
  const marcaN = Number(p.precio_marca);
  const marcaWeb = Number.isFinite(marcaN) && marcaN > 0.01 ? precioOnlineMp(marcaN) : p.precio_marca;
  return {
    ...p,
    precio_ancla: ancla,
    precio: web,
    precio_marca: marcaWeb ?? p.precio_marca,
    descuento_pct: esBajoPedido(p) ? 0 : (p.descuento_pct ?? 0),
  };
}

export function prepararListaTienda(productos) {
  return (productos || []).map(prepararProductoTienda);
}

/**
 * Badge de disponibilidad en vitrina/ficha.
 * Sobre pedido gana; anaquel clasificado → En tienda; si no, el UI pone Agotado/Hoy.
 */
export function badgeVitrina(p) {
  if (esBajoPedido(p)) return BADGE_SOBRE_PEDIDO;
  if (rubroDeProducto(p)) return BADGE_EN_TIENDA;
  return "";
}

/**
 * Filtro de página de categoría.
 * Las vitrinas pasan `incluirAnaquel: FASE2_INCLUIR_ANAQUEL`. El carrito no mezcla.
 */
export function filtrarSeccion(productos, seccion, { rubro = "", incluirAnaquel = false } = {}) {
  const sec = seccionConseguirPorId(seccion);
  const allow = sec ? new Set(sec.rubros) : null;
  return (productos || [])
    .filter((p) => p && p.activo !== false)
    .filter((p) => incluirAnaquel || esBajoPedido(p))
    .filter((p) => {
      const r = rubroDeProducto(p);
      if (!r) return false;
      if (allow && !allow.has(r)) return false;
      if (rubro && r !== rubro) return false;
      return true;
    })
    .sort((a, b) => {
      const ra = esBajoPedido(a) ? 1 : Number(a.stock) > 0 ? 0 : 2;
      const rb = esBajoPedido(b) ? 1 : Number(b.stock) > 0 ? 0 : 2;
      if (ra !== rb) return ra - rb;
      return String(a.nombre || "").localeCompare(String(b.nombre || ""), "es", { sensitivity: "base" });
    });
}

/** Vitrina de rubro: fase 2 incluye anaquel clasificado. */
export function filtrarVitrina(productos, rubro = "") {
  return filtrarSeccion(productos, "", { rubro, incluirAnaquel: FASE2_INCLUIR_ANAQUEL });
}

/** Productos de una sección (derma o nutrición). Fase 2: anaquel + encargo. */
export function filtrarVitrinaSeccion(productos, seccionId) {
  return filtrarSeccion(productos, seccionId, { incluirAnaquel: FASE2_INCLUIR_ANAQUEL });
}

/** El carrito no mezcla encargos con productos de anaquel (se pagan distinto). */
export function tipoCarrito(cart) {
  const lines = cart || [];
  if (!lines.length) return "vacio";
  const n = lines.filter(esBajoPedido).length;
  if (n === 0) return "normal";
  if (n === lines.length) return "bajo_pedido";
  return "mixto";
}

/** Motivo para no agregar `prod` al carrito actual, o null si se puede. */
export function motivoNoMezclar(cart, prod) {
  const t = tipoCarrito(cart);
  if (t === "vacio") return null;
  const nuevo = esBajoPedido(prod);
  if (t === "bajo_pedido" && !nuevo) {
    return "Tu carrito ya tiene un encargo. Eso se pide en otro pedido, no junto con lo de anaquel. Vacía el carrito o termina ese pedido para comprar este.";
  }
  if (t === "normal" && nuevo) {
    return "Tu carrito ya tiene productos de la tienda. El encargo va en otro pedido: apartas con tarjeta y se cobra cuando llega (si no lo conseguimos, no pagas). Vacía el carrito o termina esa compra para encargar este.";
  }
  return null;
}

/** Texto del botón que vacía y agrega el producto que chocó. */
export function etiquetaVaciarYAgregar(prod) {
  return esBajoPedido(prod) ? "Vaciar carrito y encargar este" : "Vaciar carrito y agregar este";
}

/** Máximo que se puede pedir de una línea. */
export function cantidadMaximaLinea(p) {
  if (esBajoPedido(p)) return CANTIDAD_MAX_BAJO_PEDIDO;
  return Math.max(0, Number(p?.stock) || 0);
}

/** Pedido marcado como bajo pedido (logistics_meta.bajo_pedido). */
export function pedidoEsBajoPedido(pedido) {
  const meta = pedido?.logistics_meta;
  return Boolean(meta && typeof meta === "object" && meta.bajo_pedido === true);
}

/** Estado de la reserva MP de un pedido: reservado | cobrado | cancelado | vencido | sin_reserva. */
export function estadoReserva(pedido, ahora = Date.now()) {
  const st = String(pedido?.payment_status || "").toLowerCase();
  const payload = pedido?.payment_payload && typeof pedido.payment_payload === "object" ? pedido.payment_payload : {};
  if (st === "approved") return "cobrado";
  if (st === "cancelled" || st === "canceled") return "cancelado";
  if (st === "authorized") {
    const vence = Date.parse(payload.reserva_expira_at || "");
    if (Number.isFinite(vence) && vence <= ahora) return "vencido";
    return "reservado";
  }
  return "sin_reserva";
}

/** Horas que le quedan a la reserva (null si no aplica). */
export function horasRestantesReserva(pedido, ahora = Date.now()) {
  const vence = Date.parse(pedido?.payment_payload?.reserva_expira_at || "");
  if (!Number.isFinite(vence)) return null;
  return Math.max(0, Math.floor((vence - ahora) / 3600000));
}
