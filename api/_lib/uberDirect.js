'use strict';

const { FARMACIA_FISCAL } = require('./farmaciaFiscal');

/** IDs públicos de Fermacapital's App (direct.uber.com). El secreto NUNCA va aquí. */
const DEFAULT_CUSTOMER_ID = 'ab470204-793f-493d-b575-ae458db8bba9';
const DEFAULT_CLIENT_ID = '5r4Y11Rx_VEkHeCUGBG-kYmKPB9OJifY';

const PICKUP_LAT = 19.3714047;
const PICKUP_LNG = -99.0526916;

const tokenCache = { accessToken: '', expiresAtMs: 0 };

function envTrim(key, fallback = '') {
  const v = process.env[key];
  if (v == null || String(v).trim() === '') return fallback;
  return String(v).trim();
}

function getUberDirectConfig() {
  const customerId = envTrim('UBER_DIRECT_CUSTOMER_ID', DEFAULT_CUSTOMER_ID);
  const clientId = envTrim('UBER_DIRECT_CLIENT_ID', DEFAULT_CLIENT_ID);
  const clientSecret = envTrim('UBER_DIRECT_CLIENT_SECRET');
  const webhookSecret = envTrim('UBER_DIRECT_WEBHOOK_SECRET');
  return {
    customerId,
    clientId,
    clientSecret,
    webhookSecret,
    configured: Boolean(customerId && clientId && clientSecret),
  };
}

function resetUberTokenCache() {
  tokenCache.accessToken = '';
  tokenCache.expiresAtMs = 0;
}

function mxPhoneE164(raw) {
  const digits = String(raw || '').replace(/\D/g, '');
  if (digits.length === 10) return `+52${digits}`;
  if (digits.length === 12 && digits.startsWith('52')) return `+${digits}`;
  if (digits.length === 13 && digits.startsWith('52')) return `+${digits.slice(0, 12)}`;
  if (String(raw || '').trim().startsWith('+') && digits.length >= 10) {
    return `+${digits}`;
  }
  return digits.length >= 10 ? `+${digits}` : '';
}

function feeCentsToMxn(fee) {
  const n = Number(fee);
  if (!Number.isFinite(n) || n < 0) return null;
  return Math.round(n) / 100;
}

function mxnToDisplay(n) {
  const v = Number(n);
  if (!Number.isFinite(v)) return '0.00';
  return v.toFixed(2);
}

function stringifyUberAddress(addr) {
  return JSON.stringify(addr);
}

function pickupAddressFromConfig() {
  const street = envTrim('UBER_DIRECT_PICKUP_STREET', 'Radiodifusora 100');
  const city = envTrim('UBER_DIRECT_PICKUP_CITY', 'Ciudad de México');
  const state = envTrim('UBER_DIRECT_PICKUP_STATE', 'CDMX');
  const zip = envTrim('UBER_DIRECT_PICKUP_ZIP', FARMACIA_FISCAL.codigo_postal || '09208');
  return {
    street_address: [street],
    city,
    state,
    zip_code: zip,
    country: 'MX',
  };
}

function pickupCoords() {
  const lat = Number(envTrim('UBER_DIRECT_PICKUP_LAT', String(PICKUP_LAT)));
  const lng = Number(envTrim('UBER_DIRECT_PICKUP_LNG', String(PICKUP_LNG)));
  return {
    lat: Number.isFinite(lat) ? lat : PICKUP_LAT,
    lng: Number.isFinite(lng) ? lng : PICKUP_LNG,
  };
}

function pickupContact() {
  return {
    name: envTrim('UBER_DIRECT_PICKUP_NAME', FARMACIA_FISCAL.nombre_comercial || 'FarmaCapital'),
    phone: mxPhoneE164(envTrim('UBER_DIRECT_PICKUP_PHONE', FARMACIA_FISCAL.telefono)),
  };
}

/**
 * Checkout guarda "calle, colonia, cp".
 * @param {string} direccion
 * @returns {{ street: string, colonia: string, zip: string } | null}
 */
function parseDireccionCheckout(direccion) {
  const raw = String(direccion || '').replace(/\s+/g, ' ').trim();
  if (raw.length < 8) return null;
  const parts = raw.split(',').map((p) => p.trim()).filter(Boolean);
  let street = parts[0] || '';
  let colonia = '';
  let zip = '';
  const zipMatch = raw.match(/\b(\d{5})\b/);
  if (zipMatch) zip = zipMatch[1];
  if (parts.length >= 3) {
    colonia = parts[1];
    if (!zip) {
      const last = parts[parts.length - 1].replace(/\D/g, '');
      if (last.length === 5) zip = last;
    }
  } else if (parts.length === 2) {
    const second = parts[1];
    const z = second.match(/\b(\d{5})\b/);
    colonia = second.replace(/\bC\.?P\.?\b/i, '').replace(/\b\d{5}\b/, '').trim();
    if (z) zip = z[1];
  }
  if (street.length < 5 || zip.length !== 5) return null;
  return { street, colonia, zip };
}

function dropoffAddressFromParts({ street, colonia, zip, city, referencia } = {}) {
  const streetLine = [String(street || '').trim(), String(colonia || '').trim()]
    .filter(Boolean)
    .join(', ');
  if (streetLine.length < 5) return null;
  const zipCode = String(zip || '').replace(/\D/g, '').slice(0, 5);
  if (zipCode.length !== 5) return null;
  const ref = String(referencia || '').trim();
  const street_address = ref ? [streetLine, ref.slice(0, 80)] : [streetLine];
  return {
    street_address,
    city: String(city || 'Ciudad de México').trim() || 'Ciudad de México',
    state: 'CDMX',
    zip_code: zipCode,
    country: 'MX',
  };
}

const geocodeCache = new Map();

function geocodeQueryFromAddress(addr) {
  if (!addr) return '';
  const street = Array.isArray(addr.street_address) ? addr.street_address[0] : '';
  return [street, addr.zip_code, addr.city, addr.state, 'México'].filter(Boolean).join(', ');
}

async function geocodeMxAddress(addr, deps = {}) {
  const q = geocodeQueryFromAddress(addr);
  if (!q) return null;
  if (geocodeCache.has(q)) return geocodeCache.get(q);
  const fetchFn = deps.fetchFn || fetch;
  const url = `https://nominatim.openstreetmap.org/search?format=json&limit=1&countrycodes=mx&q=${encodeURIComponent(q)}`;
  try {
    const resp = await fetchFn(url, {
      headers: { 'User-Agent': 'FarmaCapital/1.0 (contacto@farmacapital.mx)' },
    });
    const rows = await resp.json().catch(() => []);
    const hit = Array.isArray(rows) ? rows[0] : null;
    const lat = Number(hit?.lat);
    const lng = Number(hit?.lon);
    const coords = Number.isFinite(lat) && Number.isFinite(lng) ? { lat, lng } : null;
    geocodeCache.set(q, coords);
    return coords;
  } catch {
    geocodeCache.set(q, null);
    return null;
  }
}

function mapUberDeliveryStatus(raw) {
  const s = String(raw || '').trim().toLowerCase().replace(/[\s-]+/g, '_');
  if (!s) return null;
  if (['pending', 'scheduled', 'offering'].includes(s)) return 'courier_requested';
  if (['pickup', 'pickup_complete', 'dropoff', 'in_route', 'en_ruta', 'courier_imminent'].includes(s)) {
    return 'in_route';
  }
  if (['delivered', 'completed', 'dropped_off'].includes(s)) return 'delivered';
  if (['canceled', 'cancelled', 'returned', 'undeliverable'].includes(s)) return 'cancelled';
  return s;
}

function normalizeQuoteResponse(body) {
  if (!body || typeof body !== 'object') return { ok: false, error: 'quote_empty' };
  const currency = String(body.currency || body.currency_type || 'MXN').toUpperCase();
  if (currency && currency !== 'MXN' && currency !== 'MEX') {
    return { ok: false, error: 'quote_currency_not_mxn', currency };
  }
  const feeMxn = feeCentsToMxn(body.fee);
  if (feeMxn == null) return { ok: false, error: 'quote_fee_invalid' };
  const duration = Number(body.duration || body.pickup_duration || 0);
  return {
    ok: true,
    quote_id: body.id || body.quote_id || null,
    fee_cents: Math.round(Number(body.fee)),
    fee_mxn: feeMxn,
    currency: 'MXN',
    duration_min: Number.isFinite(duration) ? duration : null,
    expires_at: body.expires || body.expires_at || null,
    dropoff_eta: body.dropoff_eta || null,
    pickup_eta: body.pickup_eta || null,
    kind: body.kind || 'delivery_quote',
  };
}

function timingSafeEqualHex(a, b) {
  const left = String(a || '');
  const right = String(b || '');
  if (!left || !right || left.length !== right.length) return false;
  let diff = 0;
  for (let i = 0; i < left.length; i += 1) {
    diff |= left.charCodeAt(i) ^ right.charCodeAt(i);
  }
  return diff === 0;
}

function verifyUberWebhookSignature(rawBody, signatureHeader, signingKey) {
  if (!signingKey) return { ok: false, reason: 'missing_signing_key' };
  const sig = String(signatureHeader || '').trim().toLowerCase();
  if (!sig) return { ok: false, reason: 'missing_signature' };
  const crypto = require('crypto');
  const expected = crypto
    .createHmac('sha256', signingKey)
    .update(typeof rawBody === 'string' ? rawBody : String(rawBody || ''), 'utf8')
    .digest('hex')
    .toLowerCase();
  if (!timingSafeEqualHex(expected, sig)) return { ok: false, reason: 'bad_signature' };
  return { ok: true };
}

function extractUberWebhookDelivery(body) {
  const root = body && typeof body === 'object' ? body : {};
  const data = root.data && typeof root.data === 'object' ? root.data : {};
  const deliveryId = String(
    root.delivery_id ||
      root.id ||
      data.delivery_id ||
      data.id ||
      root.resource_href ||
      ''
  ).replace(/^.*\//, '');
  const status = root.status || data.status || root.delivery_status || data.delivery_status;
  const trackingUrl = root.tracking_url || data.tracking_url || null;
  const externalId = root.external_id || data.external_id || null;
  return {
    deliveryId: deliveryId && deliveryId.startsWith('del_') ? deliveryId : (deliveryId || ''),
    status,
    trackingUrl,
    externalId,
    eventType: root.event_type || root.kind || '',
  };
}

async function getUberAccessToken(deps = {}) {
  const cfg = deps.config || getUberDirectConfig();
  if (!cfg.configured) return { ok: false, error: 'not_configured' };
  const now = deps.nowMs || Date.now();
  if (tokenCache.accessToken && tokenCache.expiresAtMs > now + 30_000) {
    return { ok: true, accessToken: tokenCache.accessToken };
  }
  const fetchFn = deps.fetchFn || fetch;
  const resp = await fetchFn('https://auth.uber.com/oauth/v2/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      client_id: cfg.clientId,
      client_secret: cfg.clientSecret,
      grant_type: 'client_credentials',
      scope: 'eats.deliveries',
    }),
  });
  const data = await resp.json().catch(() => ({}));
  if (!resp.ok || !data.access_token) {
    return { ok: false, error: 'oauth_failed', detail: data.error || data.message || null };
  }
  const ttlSec = Number(data.expires_in) || 3600;
  tokenCache.accessToken = data.access_token;
  tokenCache.expiresAtMs = now + ttlSec * 1000;
  return { ok: true, accessToken: data.access_token };
}

async function uberApi(path, { method = 'POST', body, deps = {} } = {}) {
  const token = await getUberAccessToken(deps);
  if (!token.ok) return token;
  const cfg = deps.config || getUberDirectConfig();
  const fetchFn = deps.fetchFn || fetch;
  const url = path.startsWith('http')
    ? path
    : `https://api.uber.com/v1/customers/${cfg.customerId}${path}`;
  const resp = await fetchFn(url, {
    method,
    headers: {
      Authorization: `Bearer ${token.accessToken}`,
      'Content-Type': 'application/json',
    },
    body: body == null ? undefined : JSON.stringify(body),
  });
  const data = await resp.json().catch(() => ({}));
  if (!resp.ok) {
    return {
      ok: false,
      error: 'uber_api_failed',
      status: resp.status,
      detail: data.message || data.error || data.code || null,
      raw: data,
    };
  }
  return { ok: true, data };
}

async function createUberQuote({ dropoffAddress, dropoffCoords, deps = {} } = {}) {
  if (!dropoffAddress) return { ok: false, error: 'missing_dropoff' };
  const pickup = pickupAddressFromConfig();
  const coords = pickupCoords();
  let dest = dropoffCoords;
  if (!dest || !Number.isFinite(dest.lat) || !Number.isFinite(dest.lng)) {
    dest = await geocodeMxAddress(dropoffAddress, deps);
  }
  const body = {
    pickup_address: stringifyUberAddress(pickup),
    dropoff_address: stringifyUberAddress(dropoffAddress),
    pickup_latitude: coords.lat,
    pickup_longitude: coords.lng,
  };
  if (dest && Number.isFinite(dest.lat) && Number.isFinite(dest.lng)) {
    body.dropoff_latitude = dest.lat;
    body.dropoff_longitude = dest.lng;
  }
  const result = await uberApi('/delivery_quotes', { method: 'POST', body, deps });
  if (!result.ok) return result;
  return normalizeQuoteResponse(result.data);
}

function buildManifestItems(items) {
  const list = Array.isArray(items) ? items : [];
  const mapped = list
    .map((i) => ({
      name: String(i?.nombre || i?.name || 'Producto').slice(0, 80),
      quantity: Math.max(1, Number(i?.qty ?? i?.cantidad ?? 1) || 1),
      size: 'small',
    }))
    .filter((i) => i.name);
  if (!mapped.length) return [{ name: 'Pedido FarmaCapital', quantity: 1, size: 'small' }];
  return mapped.slice(0, 40);
}

async function createUberDelivery({
  quoteId,
  dropoffAddress,
  dropoffName,
  dropoffPhone,
  items,
  externalId,
  pickupNotes,
  dropoffNotes,
  deps = {},
} = {}) {
  if (!dropoffAddress) return { ok: false, error: 'missing_dropoff' };
  const pickup = pickupAddressFromConfig();
  const coords = pickupCoords();
  const contact = pickupContact();
  const phone = mxPhoneE164(dropoffPhone);
  if (!phone) return { ok: false, error: 'missing_dropoff_phone' };
  const body = {
    pickup_address: stringifyUberAddress(pickup),
    pickup_name: contact.name,
    pickup_phone_number: contact.phone || '+525562530631',
    pickup_latitude: coords.lat,
    pickup_longitude: coords.lng,
    pickup_notes: pickupNotes || 'Recoger pedido FarmaCapital en mostrador. Mencionar folio.',
    dropoff_address: stringifyUberAddress(dropoffAddress),
    dropoff_name: String(dropoffName || 'Cliente FarmaCapital').slice(0, 80),
    dropoff_phone_number: phone,
    dropoff_notes: dropoffNotes || 'Entrega de farmacia FarmaCapital.',
    manifest_items: buildManifestItems(items),
    external_id: externalId ? String(externalId) : undefined,
  };
  if (quoteId) body.quote_id = quoteId;
  const result = await uberApi('/deliveries', { method: 'POST', body, deps });
  if (!result.ok) return result;
  const d = result.data || {};
  return {
    ok: true,
    delivery_id: d.id || d.delivery_id || null,
    tracking_url: d.tracking_url || null,
    status: d.status || 'pending',
    fee_cents: d.fee != null ? Math.round(Number(d.fee)) : null,
    fee_mxn: d.fee != null ? feeCentsToMxn(d.fee) : null,
    quote_id: d.quote_id || quoteId || null,
    live_mode: d.live_mode,
    raw: d,
  };
}

function quoteChangedTooMuch(displayedMxn, liveMxn, tolerance = 8) {
  const a = Number(displayedMxn);
  const b = Number(liveMxn);
  if (!Number.isFinite(a) || !Number.isFinite(b)) return true;
  return Math.abs(a - b) > Number(tolerance);
}

module.exports = {
  DEFAULT_CUSTOMER_ID,
  DEFAULT_CLIENT_ID,
  getUberDirectConfig,
  resetUberTokenCache,
  mxPhoneE164,
  feeCentsToMxn,
  mxnToDisplay,
  pickupAddressFromConfig,
  pickupCoords,
  pickupContact,
  parseDireccionCheckout,
  dropoffAddressFromParts,
  mapUberDeliveryStatus,
  normalizeQuoteResponse,
  verifyUberWebhookSignature,
  extractUberWebhookDelivery,
  getUberAccessToken,
  createUberQuote,
  createUberDelivery,
  buildManifestItems,
  quoteChangedTooMuch,
  stringifyUberAddress,
  geocodeMxAddress,
  geocodeQueryFromAddress,
};
