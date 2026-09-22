/**
 * Tarifas, radio y distancia de envío a domicilio (Plan B).
 * Números de arranque: env / REACT_APP_*, no hardcode de negocio en UI.
 */

export const DEFAULT_TARIFAS_ENVIO = [
  { distancia_min_km: 0, distancia_max_km: 2, costo_base: 30, gratis_desde: 180 },
  { distancia_min_km: 2, distancia_max_km: 4, costo_base: 45, gratis_desde: 230 },
  { distancia_min_km: 4, distancia_max_km: 5, costo_base: 65, gratis_desde: 320 },
];

export const PROVEEDORES_ENVIO = ["didi", "uber", "propio"];

export const DEFAULT_SUCURSAL_LAT = 19.3714047;
export const DEFAULT_SUCURSAL_LNG = -99.0526916;

function envRaw(key, fallback = "") {
  const v = typeof process !== "undefined" ? process.env?.[key] : undefined;
  if (v == null || String(v).trim() === "") return fallback;
  return String(v).trim();
}

function envNum(key, fallback) {
  const raw = envRaw(key, "");
  if (!raw) return fallback;
  const n = Number(raw);
  return Number.isFinite(n) ? n : fallback;
}

function parseTarifasJson(raw) {
  if (!raw) return null;
  try {
    const parsed = JSON.parse(raw);
    if (!Array.isArray(parsed) || !parsed.length) return null;
    return parsed
      .map((row) => ({
        distancia_min_km: Number(row.distancia_min_km),
        distancia_max_km: Number(row.distancia_max_km),
        costo_base: Number(row.costo_base),
        gratis_desde: Number(row.gratis_desde),
      }))
      .filter((row) => (
        Number.isFinite(row.distancia_min_km)
        && Number.isFinite(row.distancia_max_km)
        && Number.isFinite(row.costo_base)
        && Number.isFinite(row.gratis_desde)
      ));
  } catch {
    return null;
  }
}

export function foldColonia(s) {
  return String(s || "")
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, " ")
    .trim();
}

function parseColonias(raw) {
  if (!raw) return [];
  return String(raw).split(",").map((s) => foldColonia(s)).filter(Boolean);
}

export function getEnvioConfigCliente() {
  const tarifas = parseTarifasJson(envRaw("REACT_APP_ENVIO_TARIFAS_JSON")) || DEFAULT_TARIFAS_ENVIO;
  const proveedor = envRaw("REACT_APP_ENVIO_PROVEEDOR_DEFAULT", "didi").toLowerCase();
  return {
    radioMaximoKm: envNum("REACT_APP_RADIO_MAXIMO_KM", 0),
    tiempoMaximoCotizacionMin: envNum("REACT_APP_TIEMPO_MAXIMO_COTIZACION_MIN", 15),
    proveedorDefault: PROVEEDORES_ENVIO.includes(proveedor) ? proveedor : "didi",
    factorColchonPreautorizacion: envNum("REACT_APP_FACTOR_COLCHON_PREAUTORIZACION", 1.4),
    sucursalLat: envNum("REACT_APP_SUCURSAL_LAT", DEFAULT_SUCURSAL_LAT),
    sucursalLng: envNum("REACT_APP_SUCURSAL_LNG", DEFAULT_SUCURSAL_LNG),
    coloniasPropio: parseColonias(envRaw("REACT_APP_ENVIO_COLONIAS_PROPIO")),
    tarifas,
  };
}

export function haversineKm(lat1, lng1, lat2, lng2) {
  const a1 = Number(lat1);
  const o1 = Number(lng1);
  const a2 = Number(lat2);
  const o2 = Number(lng2);
  if (![a1, o1, a2, o2].every((n) => Number.isFinite(n))) return null;
  const R = 6371;
  const dLat = ((a2 - a1) * Math.PI) / 180;
  const dLng = ((o2 - o1) * Math.PI) / 180;
  const s1 = Math.sin(dLat / 2);
  const s2 = Math.sin(dLng / 2);
  const h = s1 * s1 + Math.cos((a1 * Math.PI) / 180) * Math.cos((a2 * Math.PI) / 180) * s2 * s2;
  return Math.round(2 * R * Math.asin(Math.min(1, Math.sqrt(h))) * 1000) / 1000;
}

export function lookupTarifa(distanciaKm, tarifas = DEFAULT_TARIFAS_ENVIO) {
  const d = Number(distanciaKm);
  if (!Number.isFinite(d) || d < 0) return null;
  const rows = Array.isArray(tarifas) && tarifas.length ? tarifas : DEFAULT_TARIFAS_ENVIO;
  for (const row of rows) {
    if (d >= Number(row.distancia_min_km) && d <= Number(row.distancia_max_km)) return row;
  }
  return null;
}

export function calcularCostoEnvio({
  distanciaKm,
  subtotal = 0,
  tarifas,
  radioMaximoKm = 5,
} = {}) {
  const d = Number(distanciaKm);
  const radio = Number(radioMaximoKm);
  if (!Number.isFinite(d) || d < 0) return { ok: false, error: "distancia_invalida" };
  if (Number.isFinite(radio) && radio > 0 && d > radio) {
    return { ok: false, error: "fuera_radio", distancia_km: d, radio_maximo_km: radio };
  }
  const row = lookupTarifa(d, tarifas);
  if (!row && Number.isFinite(radio) && radio > 0) {
    return { ok: false, error: "fuera_radio", distancia_km: d, radio_maximo_km: radio };
  }
  if (!row) {
    return { ok: true, distancia_km: d, costo: 0, costo_tabla: 0, gratis: false, pendiente_vendedor: true };
  }
  const sub = Number(subtotal) || 0;
  const gratis = sub >= Number(row.gratis_desde);
  return {
    ok: true,
    distancia_km: d,
    costo: gratis ? 0 : Number(row.costo_base),
    costo_tabla: Number(row.costo_base),
    gratis,
    gratis_desde: Number(row.gratis_desde),
    tramo: { min: Number(row.distancia_min_km), max: Number(row.distancia_max_km) },
  };
}

export function estimarEnvioDesdeCoords({ lat, lng, subtotal = 0, config } = {}) {
  const cfg = config || getEnvioConfigCliente();
  const distancia = haversineKm(cfg.sucursalLat, cfg.sucursalLng, lat, lng);
  if (distancia == null) return { ok: false, error: "coords_invalidas" };
  const calc = calcularCostoEnvio({
    distanciaKm: distancia,
    subtotal,
    tarifas: cfg.tarifas,
    radioMaximoKm: cfg.radioMaximoKm,
  });
  return { ...calc, distancia_km: distancia, radio_maximo_km: cfg.radioMaximoKm };
}

export function coloniaEsPropia(colonia, coloniasPropio = []) {
  const folded = foldColonia(colonia);
  if (!folded) return false;
  return (coloniasPropio || []).some((c) => c && (folded === c || folded.includes(c) || c.includes(folded)));
}

export function proveedorSugerido(colonia, config) {
  const cfg = config || getEnvioConfigCliente();
  if (coloniaEsPropia(colonia, cfg.coloniasPropio)) return "propio";
  return cfg.proveedorDefault;
}

export function formatEnvioMoney(n) {
  const v = Number(n);
  if (!Number.isFinite(v)) return "$0.00";
  return `$${v.toFixed(2)}`;
}

export function checkoutPuedePedirEnvio({ entrega, direccionOk } = {}) {
  if (entrega === "pickup") return true;
  return Boolean(direccionOk);
}

export function minutosRestantesCotizacion(cotizarAntesDe, now = new Date()) {
  if (!cotizarAntesDe) return null;
  const t = new Date(cotizarAntesDe).getTime();
  if (!Number.isFinite(t)) return null;
  return Math.max(0, Math.round((t - now.getTime()) / 60000));
}

export function leerMetaEnvio(pedido) {
  const meta = pedido?.logistics_meta;
  if (!meta || typeof meta !== "object") return {};
  if (meta.envio && typeof meta.envio === "object") return meta.envio;
  return {};
}

/** Servicio $5 que el trigger ya sumó a pedidos.total (0 al recoger). */
export function cargoServicioPedido(p) {
  const n = Number(p?.logistics_meta?.cargo_plataforma_mxn);
  return Number.isFinite(n) && n > 0 ? Math.round(n * 100) / 100 : 0;
}

/**
 * Parte pedidos.total en productos + servicio + envío.
 * `cargo` es el Servicio ya incluido en el total (logistics_meta.cargo_plataforma_mxn).
 */
export function desgloseEnvioCheckout(total, costo, cargo = 0) {
  const t = Math.round((Number(total) || 0) * 100) / 100;
  const c = Math.round((Number(costo) || 0) * 100) / 100;
  const s = Number(cargo) > 0 ? Math.round(Number(cargo) * 100) / 100 : 0;
  const productos = Math.round((t - c - s) * 100) / 100;
  if (productos < -0.001) {
    return { productos: t, servicio: 0, envio: c, total: Math.round((t + c) * 100) / 100 };
  }
  return { productos: Math.max(0, productos), servicio: s, envio: c, total: t };
}

/** Fee ya cotizado que debe verse en el checkout. null si todavía no hay precio. */
export function feeEnvioEnCheckout(p) {
  if (String(p?.tipo_entrega || "").toLowerCase() !== "envio") return null;
  const envio = leerMetaEnvio(p);
  const es = String(envio.estado || "").toLowerCase();
  const fromCol = p?.costo_envio != null && p?.costo_envio !== "" ? Number(p.costo_envio) : null;
  const raw = fromCol != null ? fromCol : Number(envio.costo_cotizado);
  const quoted = ["cotizado", "link_enviado", "pagado"].includes(es)
    || envio.cobrado_en_checkout === true
    || fromCol != null;
  if (!quoted || !Number.isFinite(raw) || raw < 0) return null;
  return Math.round(raw * 100) / 100;
}

/**
 * El cliente puede abrir Mercado Pago.
 * Si el listado no trae la cotización, se deja intentar: el servidor rechaza si aún no hay precio.
 */
export function clientePuedePagarPedidoEnvio(p) {
  if (String(p?.tipo_entrega || "").toLowerCase() !== "envio") return true;
  const envio = leerMetaEnvio(p);
  const es = String(envio.estado || "").toLowerCase();
  if (["pendiente_cotizacion", "vencido", "fuera_radio"].includes(es)) return false;
  if (["cotizado", "link_enviado", "pagado"].includes(es)) return true;
  if (String(p?.delivery_status || "").toLowerCase() === "quoted") return true;
  if (p?.costo_envio != null && p?.costo_envio !== "" && Number.isFinite(Number(p.costo_envio)) && Number(p.costo_envio) >= 0) {
    return true;
  }
  if (envio.cobrado_en_checkout) return true;
  if (!es && (p?.costo_envio == null || p?.costo_envio === "") && !p?.delivery_status) return true;
  return false;
}

/** Pedidos de domicilio ya cotizados que el cliente todavía no liquida. */
export function pedidosConEnvioPorPagar(pedidos) {
  if (!Array.isArray(pedidos)) return [];
  return pedidos.filter((p) => {
    const estado = String(p?.estado || "").toLowerCase();
    if (["cancelado", "cancelada", "completado"].includes(estado)) return false;
    if (String(p?.payment_status || "").toLowerCase() === "approved") return false;
    if (String(p?.tipo_entrega || "").toLowerCase() !== "envio") return false;
    if (feeEnvioEnCheckout(p) == null) return false;
    return clientePuedePagarPedidoEnvio(p);
  });
}

export function linkPagarPedido(pedidoId, origen = "https://www.farmacapital.mx") {
  const base = String(origen || "https://www.farmacapital.mx").replace(/\/+$/, "");
  const id = Number(pedidoId);
  if (!Number.isFinite(id) || id <= 0) return `${base}/pagar`;
  return `${base}/pagar?pedido=${id}`;
}

/** Textos de la pantalla post-checkout. Un domicilio sin cobro no es “pagado”. */
export function copyConfirmacionPedido(lastOrder = {}) {
  if (lastOrder.reservado) {
    return { titulo: "¡Encargo apartado!", totalLabel: "Total apartado", pagado: false };
  }
  if (lastOrder.cobroEnTienda) {
    return { titulo: "¡Pedido registrado!", totalLabel: "Total a pagar al recoger", pagado: false };
  }
  if (lastOrder.envioPendienteCotizacion) {
    return {
      titulo: "¡Pedido recibido!",
      totalLabel: "Total de productos",
      pagado: false,
      pie: "Todavía no está pagado. Cuando cotizamos el envío te llega un correo y WhatsApp para pagar productos + transporte.",
    };
  }
  return { titulo: "¡Pedido confirmado!", totalLabel: "Total pagado", pagado: true };
}

export function textoClienteEnvioEnCheckout({ pedidoId, costo, itemsTotal, cargo = 0, total, origen } = {}) {
  const folio = `#FC-${String(pedidoId).padStart(4, "0")}`;
  const link = linkPagarPedido(pedidoId, origen);
  return (
    `🏥 FarmaCapital\n\n` +
    `Tu pedido ${folio} ya tiene el precio final. Todavía no está pagado.\n` +
    `Productos $${Number(itemsTotal).toFixed(2)}${Number(cargo) > 0 ? ` + servicio $${Number(cargo).toFixed(2)}` : ""} + envío $${Number(costo).toFixed(2)} = $${Number(total).toFixed(2)}.\n\n` +
    `Ábrelo y toca Pagar ahora. Es un solo cargo:\n${link}`
  );
}

function textoErrorResend(detail) {
  if (!detail) return "";
  if (typeof detail === "string") return detail;
  return String(detail.message || detail.error || "");
}

/** Texto del toast al guardar la cotización. El costo ya quedó en el pedido. */
export function mensajeCorreoEnvioCotizado({ sent, reason, detail, costo } = {}) {
  const n = Number(costo);
  const monto = Number.isFinite(n) ? `$${n.toFixed(2)}` : "El costo";
  if (sent) {
    return `${monto} cargado. Le mandamos un correo desde contacto@farmacapital.mx con la liga para pagar.`;
  }
  const err = textoErrorResend(detail);
  if (reason === "missing_email") {
    return `${monto} cargado, pero este pedido no tiene correo. Ponlo en la ficha del cliente y vuelve a guardar.`;
  }
  if (reason === "email_not_configured") {
    return `${monto} cargado. Falta la llave de Resend en el servidor, por eso no salió el correo.`;
  }
  if (reason === "domain_not_verified" || /domain is not verified|not verified|verificar/i.test(err)) {
    return `${monto} cargado. Resend rechazó contacto@farmacapital.mx: verifica el dominio farmacapital.mx en resend.com/domains y vuelve a guardar.`;
  }
  if (/only send testing emails/i.test(err)) {
    return `${monto} cargado. Esa cuenta de Resend solo escribe al correo con el que se creó, hasta que verifiques farmacapital.mx.`;
  }
  return `${monto} cargado al pedido. No salió el correo. Avísale por el botón verde de WhatsApp.`;
}

/** Etiqueta de cuenta/cliente: el envío va en el total, no hay segundo link. */
export function etiquetaEstadoEnvioCliente(envio = {}, paymentStatus) {
  const es = String(envio?.estado || "").toLowerCase();
  const paid = String(paymentStatus || "").toLowerCase() === "approved";
  if (es === "en_ruta") return "En ruta";
  if (es === "fuera_radio") return "Fuera de zona";
  if (es === "vencido") return "Cotización vencida";
  if (es === "pagado") return "Envío pagado";
  if (envio.cobrado_en_checkout && (es === "cotizado" || es === "pendiente_cotizacion" || !es)) {
    return paid ? "Envío pagado" : "Envío en el total";
  }
  if (es === "cotizado" || es === "link_enviado") return "Listo para pagar envío";
  if (es === "pendiente_cotizacion") return "Cotizando envío";
  return "";
}
