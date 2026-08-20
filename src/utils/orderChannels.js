/**
 * Modelo de canales y fulfillment para pedidos (tienda web, marketplace, POS).
 * Los valores son contrato frontend + documentación; parte se persistirá en BD vía
 * `pedidos.logistics_meta` cuando apliques sql/patch_pedidos_logistics_meta.sql.
 */

/** Envío foráneo (Skydropx) desactivado hasta nuevo aviso. Pick-up y CDMX siguen activos. */
export const ENABLE_FORANEO = false;

/** Origen comercial del pedido (nivel “canal”). */
export const ORDER_CHANNEL = {
  WEB_PICKUP: "web_pickup",
  WEB_DELIVERY: "web_delivery",
  RAPPI_MARKETPLACE: "rappi_marketplace",
  UBER_EATS_MARKETPLACE: "uber_eats_marketplace",
  COUNTER_POS: "counter_pos",
};

/** Cómo se cumple físicamente la entrega. */
export const FULFILLMENT_TYPE = {
  PICKUP_STORE: "pickup_store",
  MARKETPLACE_COURIER: "marketplace_courier",
  UBER_DIRECT: "uber_direct",
  OWN_DELIVERY: "own_delivery",
};

/** Proveedor logístico externo (tracking / API). */
export const LOGISTICS_PROVIDER = {
  RAPPI: "rappi",
  UBER_EATS: "uber_eats",
  UBER_DIRECT: "uber_direct",
  SKYDROPX: "skydropx",
  OTHER: "other",
};

/**
 * Estados operativos deseados (documentación + UI futura).
 * Mapeo al campo actual `pedidos.estado` en Supabase (no romper flujo existente).
 */
export const ORDER_WORKFLOW_STATE = {
  CREATED: "created",
  PAID_PENDING_VALIDATION: "paid_pending_validation",
  ACCEPTED: "accepted",
  PREPARING: "preparing",
  READY_FOR_PICKUP: "ready_for_pickup",
  COURIER_REQUESTED: "courier_requested",
  COURIER_ASSIGNED: "courier_assigned",
  PICKED_UP: "picked_up",
  DELIVERED: "delivered",
  CANCELLED: "cancelled",
};

/** Mapeo sugerido workflow → valor actual en columna `pedidos.estado`. */
export const WORKFLOW_TO_DB_ESTADO = {
  created: "pendiente",
  paid_pending_validation: "pendiente",
  accepted: "pendiente",
  preparing: "pendiente",
  ready_for_pickup: "listo",
  courier_requested: "listo",
  courier_assigned: "listo",
  picked_up: "listo",
  delivered: "completado",
  cancelled: "cancelado",
};

/**
 * UI carrito (Tienda.jsx) → RPC `cliente_crear_pedido_online` (solo recoger|envio).
 * @param {string} entregaUi - pickup | cdmx | foraneo
 */
export function mapUiEntregaToRpc(entregaUi) {
  const u = String(entregaUi || "pickup").toLowerCase();
  if (u === "foraneo" && !ENABLE_FORANEO) {
    throw new Error("Envío foráneo no disponible");
  }
  if (u === "pickup") {
    return {
      tipo_entrega: "recoger",
      order_channel: ORDER_CHANNEL.WEB_PICKUP,
      fulfillment_type: FULFILLMENT_TYPE.PICKUP_STORE,
    };
  }
  return {
    tipo_entrega: "envio",
    order_channel: ORDER_CHANNEL.WEB_DELIVERY,
    fulfillment_type: FULFILLMENT_TYPE.OWN_DELIVERY,
    ui_entrega: u,
  };
}

/** Producto apto para mostrarse y venderse en checkout web (alineado a validación RPC). */
export function productoPermitidoEnTiendaWeb(p) {
  if (!p || !p.activo) return false;
  if (p.visible_tienda === false) return false;
  if (p.requiere_receta) return false;
  if (p.controlado) return false;
  return true;
}

/**
 * Aptitud envío a domicilio (CDMX / foráneo). Sin columna `delivery_allowed` → true si pasa tienda web.
 * @param {object} p - fila productos
 */
export function productoPermitidoEnvioDomicilio(p, options = {}) {
  const permiteTienda = options.permiteEnTiendaWeb ?? productoPermitidoEnTiendaWeb;
  if (!permiteTienda(p)) return false;
  if (p.delivery_allowed === false) return false;
  return true;
}

/**
 * @param {object[]} cart - ítems con id, nombre, …
 * @param {string} entregaUi
 * @param {Map|object} productRowById - mapa id → fila productos (opcional; si falta no valida SKUs)
 * @returns {{ ok: boolean, bloqueados: { id: any, nombre: string, razon: string }[] }}
 */
export function validarCarritoParaEntrega(cart, entregaUi, productRowById, options = {}) {
  const permiteEnTienda = options.permiteEnTiendaWeb ?? productoPermitidoEnTiendaWeb;
  const razonNoTienda =
    typeof options.razonNoPermitidoTienda === "function"
      ? options.razonNoPermitidoTienda
      : () => "No disponible en tienda en línea (receta, controlado u oculto).";
  const bloqueados = [];
  const normId = (id) => {
    const n = typeof id === "number" && Number.isFinite(id) ? id : parseInt(String(id), 10);
    return Number.isFinite(n) ? n : id;
  };
  const map =
    productRowById instanceof Map
      ? (id) => productRowById.get(normId(id))
      : (id) => productRowById?.[normId(id)];
  for (const item of cart || []) {
    const row = map?.(item.id);
    if (!row) continue;
    if (!permiteEnTienda(row)) {
      bloqueados.push({
        id: item.id,
        nombre: item.nombre || row.nombre,
        razon: razonNoTienda(row),
      });
      continue;
    }
    if (entregaUi !== "pickup" && !productoPermitidoEnvioDomicilio(row, { permiteEnTiendaWeb: permiteEnTienda })) {
      bloqueados.push({
        id: item.id,
        nombre: item.nombre || row.nombre,
        razon: "No elegible para envío a domicilio con las reglas actuales.",
      });
    }
  }
  return { ok: bloqueados.length === 0, bloqueados };
}

/** POS / legacy usan tienda_fisica; filtros antiguos usaban fisica. */
export function pedidoEsTipoFisica(tipo) {
  const t = String(tipo || "").toLowerCase().trim();
  return !t || t === "fisica" || t === "tienda_fisica" || t === "pos";
}

export function pedidoEsTipoOnline(tipo) {
  return String(tipo || "").toLowerCase().trim() === "online";
}

export function pedidoEsTipoConsulta(tipo) {
  return String(tipo || "").toLowerCase().trim() === "consulta";
}

export function pedidoEsTipoServicio(tipo) {
  const t = String(tipo || "").toLowerCase().trim();
  return t === "servicio" || t === "recarga";
}

export function pedidoCoincideFiltroTipo(pedidoTipo, filtro) {
  if (!filtro || filtro === "todos") return true;
  if (filtro === "fisica") return pedidoEsTipoFisica(pedidoTipo);
  if (filtro === "online") return pedidoEsTipoOnline(pedidoTipo);
  if (filtro === "consulta") return pedidoEsTipoConsulta(pedidoTipo);
  if (filtro === "servicio") return pedidoEsTipoServicio(pedidoTipo);
  return String(pedidoTipo || "") === filtro;
}

export function labelTipoPedido(tipo) {
  if (pedidoEsTipoOnline(tipo)) return "online";
  if (pedidoEsTipoConsulta(tipo)) return "consulta";
  if (pedidoEsTipoServicio(tipo)) return "servicio";
  if (pedidoEsTipoFisica(tipo)) return "física";
  return tipo || "física";
}

/** Etiqueta legible para `pedidos.tipo_entrega` (recoger | envio). */
export function labelTipoEntregaPedido(tipo) {
  const t = String(tipo || "").toLowerCase().trim();
  if (t === "recoger") return "Pick-up tienda";
  if (t === "envio") return "Envío domicilio";
  if (!t) return "—";
  return tipo;
}

/**
 * Una línea para UI cuando exista `pedidos.logistics_meta` (tras patch SQL).
 * @param {object|null|undefined} meta
 */
export function resumenLogisticsMeta(meta) {
  if (!meta || typeof meta !== "object") return null;
  const keys = Object.keys(meta);
  if (!keys.length) return null;
  const parts = [];
  if (meta.order_channel) parts.push(String(meta.order_channel));
  if (meta.logistics_provider) parts.push(String(meta.logistics_provider));
  if (meta.external_order_id) parts.push(`ped.ext ${meta.external_order_id}`);
  if (meta.external_delivery_id) parts.push(`envío ${meta.external_delivery_id}`);
  if (meta.tracking_url) parts.push("con tracking");
  return parts.length ? parts.join(" · ") : null;
}
