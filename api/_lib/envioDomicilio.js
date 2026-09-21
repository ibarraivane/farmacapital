'use strict';

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
  if (estado === 'pagado') return true;
  if (estado === 'cotizado' && Number.isFinite(costo) && costo === 0) return true;
  if (envio.cobrado_en_checkout && opts.paymentApproved && ['cotizado', 'pagado'].includes(estado)) {
    return true;
  }
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

function linkCarritoCorreo(origen) {
  const base = String(origen || 'https://www.farmacapital.mx').replace(/\/+$/, '');
  return `${base}/carrito`;
}

function escapeHtmlCorreo(value) {
  return String(value ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
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
  total,
  nombre,
  origen,
  items,
} = {}) {
  const folio = folioCorreo(pedidoId);
  const quien = String(nombre || '').trim();
  const saludo = quien ? `Hola ${quien}.` : 'Hola.';
  const productos = dineroCorreo(itemsTotal);
  const envio = dineroCorreo(costo);
  const totalTxt = dineroCorreo(total);
  const link = linkCarritoCorreo(origen);
  const lineas = lineasTicketCorreo(items);
  const detalle = lineas.length
    ? `${lineas.map((l) => `${l.nombre} ×${l.qty}  ${dineroCorreo(l.importe)}`).join('\n')}\n`
    : '';
  const avisoCorto = `Tu pedido ${folio} ya tiene precio. Total ${totalTxt}.`;
  const text =
    `${saludo} ${avisoCorto}\n\n` +
    `Ábrelo y toca Pagar ahora:\n${link}\n\n` +
    `Productos: ${productos}\n` +
    `Envío a domicilio: ${envio}\n` +
    (detalle ? `\n${detalle}` : '') +
    `\nEl ticket se crea cuando terminas el pago.\n` +
    `Entra con el teléfono del pedido.\n\n` +
    `FarmaCapital`;

  const filas = lineas.map((l) => (
    `<tr><td style="padding:10px 0;color:#0f172a;border-bottom:1px solid #e2e8f0;">${escapeHtmlCorreo(l.nombre)} ×${l.qty}</td>` +
    `<td style="padding:10px 0;text-align:right;color:#0f172a;border-bottom:1px solid #e2e8f0;">${dineroCorreo(l.importe)}</td></tr>`
  )).join('');
  const html =
    `<div style="display:none;max-height:0;overflow:hidden;mso-hide:all;">${escapeHtmlCorreo(`${saludo} ${avisoCorto}`)}</div>` +
    `<div style="font-family:Arial,sans-serif;color:#0f172a;background:#ffffff;max-width:480px;line-height:1.45;">` +
    `<p style="margin:0 0 8px;font-size:16px;">${escapeHtmlCorreo(saludo)}</p>` +
    `<p style="margin:0 0 16px;font-size:16px;">Tu pedido <strong>${escapeHtmlCorreo(folio)}</strong> ya tiene precio.</p>` +
    `<p style="margin:0 0 4px;color:#64748b;font-size:13px;">Total a pagar</p>` +
    `<p style="margin:0 0 18px;font-size:28px;font-weight:800;letter-spacing:-0.02em;">${totalTxt}</p>` +
    `<p style="margin:0 0 22px;"><a href="${escapeHtmlCorreo(link)}" style="display:inline-block;background:#0f766e;color:#ffffff;text-decoration:none;font-weight:700;padding:12px 18px;border-radius:8px;">Pagar ahora</a></p>` +
    `<p style="margin:0 0 18px;color:#64748b;font-size:13px;">Productos ${productos} · Envío ${envio}</p>` +
    (filas ? `<table style="width:100%;border-collapse:collapse;margin:0 0 16px;font-size:14px;">${filas}</table>` : '') +
    `<p style="margin:0 0 8px;color:#334155;font-size:14px;">El ticket se crea cuando terminas el pago. Entra con el teléfono del pedido.</p>` +
    `<p style="margin:0;color:#64748b;font-size:12px;">FarmaCapital · contacto@farmacapital.mx</p>` +
    `</div>`;

  return {
    from: CORREO_ENVIO_FROM,
    replyTo: 'contacto@farmacapital.mx',
    subject: `Pedido ${folio} listo para pagar`,
    text,
    html,
    link,
    lineas,
  };
}

function textoClienteEnvioEnCheckout({ pedidoId, costo, itemsTotal, total, origen } = {}) {
  const folio = `#FC-${String(pedidoId).padStart(4, '0')}`;
  const envioTxt = Number(costo).toFixed(2);
  const prodTxt = Number(itemsTotal).toFixed(2);
  const totalTxt = Number(total).toFixed(2);
  const base = String(origen || 'https://www.farmacapital.mx').replace(/\/+$/, '');
  const link = `${base}/carrito`;
  return (
    `🏥 FarmaCapital\n\n` +
    `Tu pedido ${folio} ya tiene el precio final.\n` +
    `Productos $${prodTxt} + envío $${envioTxt} = $${totalTxt}.\n\n` +
    `Ábrelo en tu carrito y toca Pagar ahora. Es un solo cargo:\n${link}`
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
  lineasTicketCorreo,
};
