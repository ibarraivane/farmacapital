/**
 * BAJO PEDIDO — reglas únicas para tienda, carrito, checkout y admin.
 *
 * Un producto bajo pedido (`productos.bajo_pedido = true`) no está en anaquel:
 * se exhibe con stock 0, sin «Agotado», y se consigue con mayorista.
 * - Con ancla usable (precio > $0.01): CTA «Encargar» → carrito → pago con
 *   RESERVA en tarjeta (se cobra al conseguirlo; si no, se cancela sin cargo).
 * - Sin ancla: CTA «Cotizar» → formulario de /conseguir.
 * Rubros de la vitrina salen de categoria/subcategoria (no hay categoría nueva).
 */
import { categoriaCanon } from "../constants/categoriasProducto";
import { precioAnclaUsable, precioOnlineMp } from "./precioOnlineMp";

/** Tope por línea en el carrito (no depende del stock físico). */
export const CANTIDAD_MAX_BAJO_PEDIDO = 12;

/** Días que Mercado Pago sostiene la reserva antes de vencer. */
export const DIAS_RESERVA_MP = 5;

export const RUBROS_BAJO_PEDIDO = Object.freeze([
  { id: "dermatologia", label: "Dermatología" },
  { id: "vitaminas", label: "Vitaminas" },
  { id: "suplementos", label: "Suplementos" },
  { id: "proteina", label: "Proteína" },
]);

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
  if (cat === "Suplemento") return sub.startsWith("protein") ? "proteina" : "suplementos";
  return "";
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

/** Vitrina de /conseguir: bajo pedido del rubro ("" = todos), alfabético. */
export function filtrarVitrina(productos, rubro = "") {
  return (productos || [])
    .filter((p) => esBajoPedido(p) && p.activo !== false)
    .filter((p) => !rubro || rubroDeProducto(p) === rubro)
    .sort((a, b) => String(a.nombre || "").localeCompare(String(b.nombre || ""), "es", { sensitivity: "base" }));
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
    return "Tu carrito tiene productos por encargo, que se pagan con reserva. Termina ese pedido o vacía el carrito para comprar productos en existencia.";
  }
  if (t === "normal" && nuevo) {
    return "Los productos por encargo se pagan aparte (reserva en tarjeta). Termina tu compra actual o vacía el carrito para encargar.";
  }
  return null;
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
