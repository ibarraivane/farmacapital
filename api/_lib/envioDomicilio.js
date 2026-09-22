'use strict';

const emailTemplates = require('./emailTemplates');

const DEFAULT_TARIFAS = [
  { distancia_min_km: 0, distancia_max_km: 2, costo_base: 30, gratis_desde: 180 },
  { distancia_min_km: 2, distancia_max_km: 4, costo_base: 45, gratis_desde: 230 },
  { distancia_min_km: 4, distancia_max_km: 5, costo_base: 65, gratis_desde: 320 },
];

const ESTADOS_ENVIO = [
  'pendiente_cotizacion',
  'cotizado',
  'link_enviado',
  'pagado',
  'en_ruta',
  'entregado',
  'fuera_radio',
  'vencido',
];

const PROVEEDORES_ENVIO = ['didi', 'uber', 'propio'];

const DEFAULT_SUCURSAL_LAT = 19.3714047;
const DEFAULT_SUCURSAL_LNG = -99.0526916;

function envRaw(env, key, fallback = '') {
  const v = env?.[key];
  if (v == null || String(v).trim() === '') return fallback;
  return String(v).trim();
}

function envNum(env, key, fallback) {
  const raw = envRaw(env, key, '');
  if (!raw) return fallback;
  const n = Number(raw);
  return Number.isFinite(n) ? n : fallback;
}

function parseTarifasJson(raw) {
  if (!raw) return null;
  try {
    const parsed = JSON.parse(raw);
    if (!Array.isArray(parsed) || !parsed.length) return null;
    return parsed.map((row) => ({
      distancia_min_km: Number(row.distancia_min_km),
      distancia_max_km: Number(row.distancia_max_km),
      costo_base: Number(row.costo_base),
      gratis_desde: Number(row.gratis_desde),
    })).filter((row) => (
      Number.isFinite(row.distancia_min_km)
      && Number.isFinite(row.distancia_max_km)
      && Number.isFinite(row.costo_base)
      && Number.isFinite(row.gratis_desde)
    ));
  } catch {
    return null;
  }
}

function parseColonias(raw) {
  if (!raw) return [];
  return String(raw)
    .split(',')
    .map((s) => foldColonia(s))
    .filter(Boolean);
}

function foldColonia(s) {
  return String(s || '')
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, ' ')
    .trim();
}

function getEnvioConfig(env = process.env) {
  const tarifas = parseTarifasJson(envRaw(env, 'ENVIO_TARIFAS_JSON')) || DEFAULT_TARIFAS;
  const proveedor = envRaw(env, 'ENVIO_PROVEEDOR_DEFAULT', 'didi').toLowerCase();
  return {
    radioMaximoKm: envNum(env, 'RADIO_MAXIMO_KM', 0),
    tiempoMaximoCotizacionMin: envNum(env, 'TIEMPO_MAXIMO_COTIZACION_MIN', 15),
    proveedorDefault: PROVEEDORES_ENVIO.includes(proveedor) ? proveedor : 'didi',
    factorColchonPreautorizacion: envNum(env, 'FACTOR_COLCHON_PREAUTORIZACION', 1.4),
    sucursalLat: envNum(env, 'SUCURSAL_LAT', DEFAULT_SUCURSAL_LAT),
    sucursalLng: envNum(env, 'SUCURSAL_LNG', DEFAULT_SUCURSAL_LNG),
    coloniasPropio: parseColonias(envRaw(env, 'ENVIO_COLONIAS_PROPIO')),
    tarifas,
  };
}

function haversineKm(lat1, lng1, lat2, lng2) {
  const a1 = Number(lat1);
  const o1 = Number(lng1);
  const a2 = Number(lat2);
  const o2 = Number(lng2);
  if (![a1, o1, a2, o2].every((n) => Number.isFinite(n))) return null;
  const R = 6371;
  const dLat = (a2 - a1) * Math.PI / 180;
  const dLng = (o2 - o1) * Math.PI / 180;
  const s1 = Math.sin(dLat / 2);
  const s2 = Math.sin(dLng / 2);
  const h = s1 * s1 + Math.cos(a1 * Math.PI / 180) * Math.cos(a2 * Math.PI / 180) * s2 * s2;
  return Math.round((2 * R * Math.asin(Math.min(1, Math.sqrt(h)))) * 1000) / 1000;
}

function lookupTarifa(distanciaKm, tarifas = DEFAULT_TARIFAS) {
  const d = Number(distanciaKm);
  if (!Number.isFinite(d) || d < 0) return null;
  const rows = Array.isArray(tarifas) && tarifas.length ? tarifas : DEFAULT_TARIFAS;
  for (const row of rows) {
    const min = Number(row.distancia_min_km);
    const max = Number(row.distancia_max_km);
    if (d >= min && d <= max) return row;
  }
  return null;
}

function calcularCostoEnvio({
  distanciaKm,
  subtotal = 0,
  tarifas,
  radioMaximoKm = 0,
} = {}) {
  const d = Number(distanciaKm);
  const radio = Number(radioMaximoKm);
  if (!Number.isFinite(d) || d < 0) {
    return { ok: false, error: 'distancia_invalida' };
  }
  if (Number.isFinite(radio) && radio > 0 && d > radio) {
    return {
      ok: false,
      error: 'fuera_radio',
      distancia_km: d,
      radio_maximo_km: radio,
    };
  }
  const row = lookupTarifa(d, tarifas);
  if (!row && Number.isFinite(radio) && radio > 0) {
    return { ok: false, error: 'fuera_radio', distancia_km: d, radio_maximo_km: radio };
  }
  if (!row) {
    return { ok: true, distancia_km: d, costo: 0, costo_tabla: 0, gratis: false, pendiente_vendedor: true };
  }
  const sub = Number(subtotal) || 0;
  const gratis = sub >= Number(row.gratis_desde);
  const costo = gratis ? 0 : Number(row.costo_base);
  return {
    ok: true,
    distancia_km: d,
    costo,
    costo_tabla: Number(row.costo_base),
    gratis,
    gratis_desde: Number(row.gratis_desde),
    tramo: { min: Number(row.distancia_min_km), max: Number(row.distancia_max_km) },
  };
}

function estimarEnvioDesdeCoords({
  lat,
  lng,
  subtotal = 0,
  config,
} = {}) {
  const cfg = config || getEnvioConfig();
  const distancia = haversineKm(cfg.sucursalLat, cfg.sucursalLng, lat, lng);
  if (distancia == null) return { ok: false, error: 'coords_invalidas' };
  const calc = calcularCostoEnvio({
    distanciaKm: distancia,
    subtotal,
    tarifas: cfg.tarifas,
    radioMaximoKm: cfg.radioMaximoKm,
  });
  return { ...calc, distancia_km: distancia, radio_maximo_km: cfg.radioMaximoKm };
}

function coloniaEsPropia(colonia, coloniasPropio = []) {
  const folded = foldColonia(colonia);
  if (!folded) return false;
  return (coloniasPropio || []).some((c) => c && (folded === c || folded.includes(c) || c.includes(folded)));
}

function proveedorSugerido(colonia, config) {
  const cfg = config || getEnvioConfig();
  if (coloniaEsPropia(colonia, cfg.coloniasPropio)) return 'propio';
  return cfg.proveedorDefault;
}

function normalizarProveedor(raw, fallback = 'didi') {
  const v = String(raw || '').toLowerCase().trim();
  if (PROVEEDORES_ENVIO.includes(v)) return v;
  return fallback;
}

function deadlineCotizacionIso(fromDate = new Date(), minutos) {
  const mins = Number(minutos);
  const ms = (Number.isFinite(mins) && mins > 0 ? mins : 15) * 60 * 1000;
  return new Date(fromDate.getTime() + ms).toISOString();
}

function cotizacionVencida(cotizarAntesDe, now = new Date()) {
  if (!cotizarAntesDe) return false;
  const t = new Date(cotizarAntesDe).getTime();
  if (!Number.isFinite(t)) return false;
  return now.getTime() > t;
}

function puedeDespacharEnvio(envio = {}, opts = {}) {
  const estado = String(envio.estado || '');
  const costo = Number(envio.costo_cotizado);
  // Pedido liquidado en Mercado Pago (productos + envío): el mensajero puede salir
  // aunque logistics_meta.envio se haya quedado en cotizado / link_enviado.
  if (opts.paymentApproved) return true;
  if (estado === 'pagado' || estado === 'en_ruta') return true;
  if (estado === 'cotizado' && Number.isFinite(costo) && costo === 0) return true;
  return false;
}

function formatMoneyMx(n) {
  const v = Number(n);
  if (!Number.isFinite(v)) return '$0.00';
  return `$${v.toFixed(2)}`;
}

/** Total del pedido = productos (sin el fee previo) + costo de transporte nuevo. */
function totalPedidoConCostoEnvio(totalActual, costoPrevio, costoNuevo) {
  let items = Number(totalActual || 0);
  const prev = Number(costoPrevio);
  if (Number.isFinite(prev) && prev >= 0) {
    items = Math.round((items - prev) * 100) / 100;
  }
  const costo = Number(costoNuevo);
  const fee = Number.isFinite(costo) && costo >= 0 ? costo : 0;
  return {
    itemsTotal: items,
    total: Math.round((items + fee) * 100) / 100,
  };
}

/** La cotización del vendedor queda dentro del único cobro del checkout. */
function cotizacionEnvioMeta(current = {}, { costo, proveedor, distanciaKm, nota, now = new Date() } = {}) {
  const fee = Number(costo);
  return {
    ...current,
    estado: 'cotizado',
    cobrado_en_checkout: true,
    costo_real_mensajeria: fee,
    costo_cotizado: fee,
    distancia_km: distanciaKm == null || distanciaKm === '' || !Number.isFinite(Number(distanciaKm))
      ? (current.distancia_km ?? null)
      : Number(distanciaKm),
    proveedor,
    fulfillment_type: proveedor === 'propio' ? 'own_delivery' : 'courier',
    cotizado_at: now.toISOString(),
    nota_interna: String(nota || '').trim() || current.nota_interna || null,
  };
}

const CORREO_ENVIO_FROM = 'FarmaCapital <contacto@farmacapital.mx>';

function dineroCorreo(n) {
  const v = Number(n);
  return `$${(Number.isFinite(v) ? v : 0).toFixed(2)}`;
}

function folioCorreo(pedidoId) {
  return `#FC-${String(pedidoId).padStart(4, '0')}`;
}

function linkPagarPedidoCorreo(origen, pedidoId) {
  const base = String(origen || 'https://www.farmacapital.mx').replace(/\/+$/, '');
  const id = Number(pedidoId);
  if (!Number.isFinite(id) || id <= 0) return `${base}/pagar`;
  return `${base}/pagar?pedido=${id}`;
}

function escapeHtmlCorreo(value) {
  return String(value ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

/** Servicio $5 ya sumado al total por el trigger (logistics_meta.cargo_plataforma_mxn). */
function cargoServicioPedido(pedido) {
  const n = Number(pedido?.logistics_meta?.cargo_plataforma_mxn);
  return Number.isFinite(n) && n > 0 ? Math.round(n * 100) / 100 : 0;
}

/**
 * Parte el total del pedido en productos + servicio + envío.
 * pedido.total ya incluye el Servicio $5 (trigger) y, si hay cotización, el envío.
 */
function desglosePedido(total, costoEnvio, cargoServicio) {
  const t = Math.round((Number(total) || 0) * 100) / 100;
  const envio = Number.isFinite(Number(costoEnvio)) && Number(costoEnvio) >= 0 ? Math.round(Number(costoEnvio) * 100) / 100 : 0;
  const servicio = Number.isFinite(Number(cargoServicio)) && Number(cargoServicio) > 0 ? Math.round(Number(cargoServicio) * 100) / 100 : 0;
  return {
    productos: Math.max(0, Math.round((t - envio - servicio) * 100) / 100),
    servicio,
    envio,
    total: t,
  };
}

const NOMBRE_PROVEEDOR = { didi: 'DiDi', uber: 'Uber Direct', propio: 'Repartidor FarmaCapital' };

/** Renglones para la plantilla: nombre, cantidad, importe y foto (solo URL https). */
function itemsPlantillaCorreo(items) {
  const raw = Array.isArray(items) ? items : [];
  return lineasTicketCorreo(raw).map((l, i) => {
    const img = String(raw[i]?.productos?.imagen_url || raw[i]?.imagen_url || '').trim();
    return { nombre: l.nombre, cantidad: l.qty, importe: l.importe, img: /^https:\/\//i.test(img) ? img : undefined };
  });
}

function lineasTicketCorreo(items) {
  if (!Array.isArray(items)) return [];
  return items.map((i) => {
    const nombre = String(i?.nombre || i?.productos?.nombre || 'Producto').trim() || 'Producto';
    const qty = Number(i?.qty ?? i?.cantidad ?? 1);
    const precio = Number(i?.precio ?? i?.precio_unitario ?? 0);
    const cantidad = Number.isFinite(qty) && qty > 0 ? qty : 1;
    const unitario = Number.isFinite(precio) ? precio : 0;
    return {
      nombre,
      qty: cantidad,
      importe: Math.round(unitario * cantidad * 100) / 100,
    };
  });
}

/**
 * Carta al cliente cuando el envío ya tiene precio.
 * El texto de WhatsApp sigue en textoClienteEnvioEnCheckout.
 */
function correoAvisoEnvioCotizado({
  pedidoId,
  costo,
  itemsTotal,
  cargo = 0,
  total,
  nombre,
  origen,
  items,
  proveedor,
  colonia,
  telUltimos4,
} = {}) {
  const folio = folioCorreo(pedidoId);
  const quien = String(nombre || '').trim();
  const saludo = quien ? `Hola ${quien}.` : 'Hola.';
  const productos = dineroCorreo(itemsTotal);
  const envio = dineroCorreo(costo);
  const cargoN = Number(cargo) > 0 ? Number(cargo) : 0;
  const servicio = dineroCorreo(cargoN);
  const totalTxt = dineroCorreo(total);
  const link = linkPagarPedidoCorreo(origen, pedidoId);
  const lineas = lineasTicketCorreo(items);
  const detalle = lineas.length
    ? `${lineas.map((l) => `- ${l.nombre} ×${l.qty}: ${dineroCorreo(l.importe)}`).join('\n')}\n`
    : '';
  const text =
    `${saludo}\n\n` +
    `Ya cotizamos el envío de tu pedido ${folio}. Todavía no está pagado. Total a pagar: ${totalTxt}.\n\n` +
    `Para liquidarlo, abre esta liga, escribe el teléfono del pedido y toca Pagar ahora:\n${link}\n\n` +
    `Productos: ${productos}\n` +
    (cargoN > 0 ? `Servicio: ${servicio}\n` : '') +
    `Envío a domicilio: ${envio}\n` +
    (detalle ? `\n${detalle}` : '') +
    `\nEl ticket de compra se crea cuando terminas el pago. Te llega a este correo en cuanto el pago queda hecho.\n\n` +
    `FarmaCapital\n` +
    `Radiodifusora 100, Col. Chinampac de Juárez, Iztapalapa\n` +
    `contacto@farmacapital.mx`;

  // Diseño v2 (api/_lib/emailTemplates.js). El texto plano de arriba se conserva.
  const plantilla = emailTemplates.envioCotizado({
    pedidoId,
    nombre: quien,
    items: itemsPlantillaCorreo(items),
    subtotal: Number(itemsTotal),
    servicio: cargoN,
    envio: Number(costo),
    total: Number(total),
    paqueteria: NOMBRE_PROVEEDOR[String(proveedor || '').toLowerCase()] || undefined,
    destino: String(colonia || '').trim() || undefined, // solo colonia: nunca calle ni número
    telUltimos4: String(telUltimos4 || '').replace(/\D/g, '').slice(-4) || undefined,
    urlPagar: link,
  });
  const html = plantilla.html;

  return {
    from: CORREO_ENVIO_FROM,
    replyTo: 'contacto@farmacapital.mx',
    subject: plantilla.subject,
    text,
    html,
    link,
    lineas,
  };
}

function textoClienteEnvioEnCheckout({ pedidoId, costo, itemsTotal, cargo = 0, total, origen } = {}) {
  const folio = `#FC-${String(pedidoId).padStart(4, '0')}`;
  const envioTxt = Number(costo).toFixed(2);
  const prodTxt = Number(itemsTotal).toFixed(2);
  const totalTxt = Number(total).toFixed(2);
  const link = linkPagarPedidoCorreo(origen, pedidoId);
  return (
    `🏥 FarmaCapital\n\n` +
    `Tu pedido ${folio} ya tiene el precio final. Todavía no está pagado.\n` +
    `Productos $${prodTxt}${Number(cargo) > 0 ? ` + servicio $${Number(cargo).toFixed(2)}` : ''} + envío $${envioTxt} = $${totalTxt}.\n\n` +
    `Ábrelo y toca Pagar ahora. Es un solo cargo:\n${link}`
  );
}

module.exports = {
  DEFAULT_TARIFAS,
  ESTADOS_ENVIO,
  PROVEEDORES_ENVIO,
  DEFAULT_SUCURSAL_LAT,
  DEFAULT_SUCURSAL_LNG,
  getEnvioConfig,
  haversineKm,
  lookupTarifa,
  calcularCostoEnvio,
  estimarEnvioDesdeCoords,
  foldColonia,
  coloniaEsPropia,
  proveedorSugerido,
  normalizarProveedor,
  deadlineCotizacionIso,
  cotizacionVencida,
  puedeDespacharEnvio,
  formatMoneyMx,
  totalPedidoConCostoEnvio,
  cotizacionEnvioMeta,
  textoClienteEnvioEnCheckout,
  correoAvisoEnvioCotizado,
  itemsPlantillaCorreo,
  cargoServicioPedido,
  desglosePedido,
  lineasTicketCorreo,
};
