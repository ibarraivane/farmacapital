'use strict';

/** Bias CDMX / FarmaCapital (Radiodifusora). */
const BIAS_LAT = 19.3714;
const BIAS_LNG = -99.0527;

const CDMX_ALCALDIAS = new Set(
  [
    'alvaro obregon',
    'azcapotzalco',
    'benito juarez',
    'coyoacan',
    'cuajimalpa',
    'cuauhtemoc',
    'gustavo a madero',
    'iztacalco',
    'iztapalapa',
    'magdalena contreras',
    'miguel hidalgo',
    'milpa alta',
    'tlahuac',
    'tlalpan',
    'venustiano carranza',
    'xochimilco',
  ].map((s) => s)
);

function envTrim(key, fallback = '') {
  const v = process.env[key];
  if (v == null || String(v).trim() === '') return fallback;
  return String(v).trim();
}

function foldMx(s) {
  return String(s || '')
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/\s+/g, ' ')
    .trim();
}

function googleMapsApiKey() {
  return (
    envTrim('GOOGLE_MAPS_API_KEY') ||
    envTrim('GOOGLE_PLACES_API_KEY') ||
    envTrim('REACT_APP_GOOGLE_MAPS_API_KEY')
  );
}

function componentByType(components, type) {
  const list = Array.isArray(components) ? components : [];
  const hit = list.find((c) => Array.isArray(c.types) && c.types.includes(type));
  return hit ? String(hit.long_name || hit.short_name || '').trim() : '';
}

function streetFromGoogleComponents(components) {
  const route = componentByType(components, 'route');
  const num = componentByType(components, 'street_number');
  return [route, num].filter(Boolean).join(' ').trim();
}

function coloniaFromGoogleComponents(components) {
  const raw =
    componentByType(components, 'sublocality_level_1') ||
    componentByType(components, 'sublocality') ||
    componentByType(components, 'neighborhood') ||
    '';
  return cleanColonia(raw);
}

function cleanColonia(raw) {
  let s = String(raw || '')
    .replace(/^(colonia|col\.?)\s+/i, '')
    .replace(/\s+/g, ' ')
    .trim();
  if (!s) return '';
  const first = s.split(',')[0].trim();
  if (CDMX_ALCALDIAS.has(foldMx(first))) return '';
  return first;
}

/**
 * @param {object} raw
 * @returns {{ id: string, label: string, calle: string, colonia: string, cp: string, lat: number|null, lng: number|null, source: string } | null}
 */
function normalizeSuggestion(raw) {
  if (!raw || typeof raw !== 'object') return null;
  const calle = String(raw.calle || '').replace(/\s+/g, ' ').trim();
  const colonia = cleanColonia(raw.colonia);
  const cp = String(raw.cp || '').replace(/\D/g, '').slice(0, 5);
  const lat = Number(raw.lat);
  const lng = Number(raw.lng);
  const label = String(raw.label || [calle, colonia, cp].filter(Boolean).join(', ')).trim();
  if (!label && !calle) return null;
  return {
    id: String(raw.id || label).slice(0, 120),
    label,
    calle,
    colonia,
    cp: cp.length === 5 ? cp : '',
    lat: Number.isFinite(lat) ? lat : null,
    lng: Number.isFinite(lng) ? lng : null,
    source: String(raw.source || 'unknown'),
  };
}

async function suggestWithGoogle(query, deps = {}) {
  const key = googleMapsApiKey();
  if (!key) return { ok: false, error: 'no_google_key', suggestions: [] };
  const fetchFn = deps.fetchFn || fetch;
  const autoUrl =
    `https://maps.googleapis.com/maps/api/place/autocomplete/json` +
    `?input=${encodeURIComponent(query)}` +
    `&components=country:mx` +
    `&types=address` +
    `&language=es` +
    `&location=${BIAS_LAT},${BIAS_LNG}` +
    `&radius=35000` +
    `&key=${encodeURIComponent(key)}`;
  const autoResp = await fetchFn(autoUrl);
  const autoData = await autoResp.json().catch(() => ({}));
  if (autoData.status && autoData.status !== 'OK' && autoData.status !== 'ZERO_RESULTS') {
    return {
      ok: false,
      error: 'google_autocomplete_failed',
      detail: autoData.status,
      suggestions: [],
    };
  }
  const preds = Array.isArray(autoData.predictions) ? autoData.predictions.slice(0, 6) : [];
  const suggestions = [];
  for (const p of preds) {
    const placeId = String(p.place_id || '');
    if (!placeId) continue;
    const detUrl =
      `https://maps.googleapis.com/maps/api/place/details/json` +
      `?place_id=${encodeURIComponent(placeId)}` +
      `&fields=address_component,formatted_address,geometry` +
      `&language=es` +
      `&key=${encodeURIComponent(key)}`;
    const detResp = await fetchFn(detUrl);
    const detData = await detResp.json().catch(() => ({}));
    const result = detData.result || {};
    const components = result.address_components || [];
    const loc = result.geometry?.location || {};
    const suggestion = normalizeSuggestion({
      id: placeId,
      label: result.formatted_address || p.description || '',
      calle: streetFromGoogleComponents(components),
      colonia: coloniaFromGoogleComponents(components),
      cp: componentByType(components, 'postal_code'),
      lat: loc.lat,
      lng: loc.lng,
      source: 'google',
    });
    if (suggestion) suggestions.push(suggestion);
  }
  return { ok: true, provider: 'google', suggestions };
}

function streetFromPhotonProps(props) {
  const name = String(props.name || '').trim();
  const street = String(props.street || '').trim();
  const num = String(props.housenumber || '').trim();
  if (street && num) return `${street} ${num}`.trim();
  if (street) return street;
  if (name && num) return `${name} ${num}`.trim();
  return name || street;
}

function coloniaFromPhotonProps(props) {
  const candidates = [
    props.suburb,
    props.neighbourhood,
    props.district,
    props.city,
    props.town,
  ];
  for (const c of candidates) {
    const cleaned = cleanColonia(c);
    if (cleaned) return cleaned;
  }
  return '';
}

async function suggestWithPhoton(query, deps = {}) {
  const fetchFn = deps.fetchFn || fetch;
  const q = /ciudad de m[eé]xico|cdmx|\bmx\b/i.test(query)
    ? query
    : `${query}, Ciudad de México`;
  const url =
    `https://photon.komoot.io/api/` +
    `?q=${encodeURIComponent(q)}` +
    `&limit=6` +
    `&lat=${BIAS_LAT}&lon=${BIAS_LNG}` +
    `&lang=en`;
  const resp = await fetchFn(url, {
    headers: { 'User-Agent': 'FarmaCapital/1.0 (contacto@farmacapital.mx)' },
  });
  const data = await resp.json().catch(() => ({}));
  const features = Array.isArray(data.features) ? data.features : [];
  const suggestions = [];
  for (const f of features) {
    const props = f.properties || {};
    if (props.countrycode && String(props.countrycode).toUpperCase() !== 'MX') continue;
    const coords = Array.isArray(f.geometry?.coordinates) ? f.geometry.coordinates : [];
    const lng = Number(coords[0]);
    const lat = Number(coords[1]);
    const calle = streetFromPhotonProps(props);
    const colonia = coloniaFromPhotonProps(props);
    const cp = String(props.postcode || '').replace(/\D/g, '').slice(0, 5);
    const city = String(props.city || props.state || 'Ciudad de México');
    const label = [calle, colonia, cp, city].filter(Boolean).join(', ');
    const suggestion = normalizeSuggestion({
      id: String(props.osm_id || label),
      label,
      calle,
      colonia,
      cp,
      lat,
      lng,
      source: 'photon',
    });
    if (suggestion) suggestions.push(suggestion);
  }
  return { ok: true, provider: 'photon', suggestions: rankSuggestions(query, suggestions) };
}

function isAlleyLabel(calle) {
  return /^(cerrada|privada|andador|callejon|callej[oó]n|retorno)\b/i.test(String(calle || '').trim());
}

function queryHouseNumber(query) {
  const parts = String(query || '').match(/\b(\d+[A-Za-z]?)\b/g) || [];
  const nums = parts.filter((n) => n.replace(/\D/g, '').length !== 5);
  return nums[0] || '';
}

function rankSuggestions(query, list) {
  const q = foldMx(query);
  const wantAlley = /\bcerrada\b|\bprivada\b|\bandador\b/.test(q);
  const wantNum = queryHouseNumber(query);
  const tokens = q.split(' ').filter((t) => t.length > 3 && !/^\d+$/.test(t));
  const scored = (list || []).map((sug) => {
    const calle = foldMx(sug.calle || sug.label);
    let n = 0;
    if (isAlleyLabel(sug.calle) && !wantAlley) n -= 80;
    for (const t of tokens) {
      if (calle.includes(t)) n += 10;
    }
    if (wantNum && calle.includes(foldMx(wantNum))) n += 25;
    const cpM = String(query).match(/\b(\d{5})\b/);
    if (cpM && sug.cp === cpM[1]) n += 20;
    let next = sug;
    if (wantNum && sug.calle && !/\d/.test(sug.calle) && !isAlleyLabel(sug.calle)) {
      next = {
        ...sug,
        calle: `${sug.calle} ${wantNum}`.trim(),
        label: [(`${sug.calle} ${wantNum}`).trim(), sug.colonia, sug.cp].filter(Boolean).join(', '),
      };
    }
    return { n, sug: next };
  });
  scored.sort((a, b) => b.n - a.n);
  return scored.map((x) => x.sug);
}

/**
 * Autocompletado predictivo. Prefer Google Places si hay API key; si no, Photon (OSM).
 * @param {string} query
 * @param {{ fetchFn?: typeof fetch }} [deps]
 */
async function suggestAddresses(query, deps = {}) {
  const q = String(query || '').replace(/\s+/g, ' ').trim();
  if (q.length < 3) return { ok: true, provider: 'none', suggestions: [] };

  if (googleMapsApiKey()) {
    try {
      const google = await suggestWithGoogle(q, deps);
      if (google.ok && google.suggestions.length) return google;
    } catch {
      /* fallback Photon */
    }
  }

  try {
    return await suggestWithPhoton(q, deps);
  } catch (err) {
    return {
      ok: false,
      error: 'suggest_failed',
      detail: err?.message || null,
      suggestions: [],
    };
  }
}

module.exports = {
  suggestAddresses,
  normalizeSuggestion,
  streetFromGoogleComponents,
  coloniaFromGoogleComponents,
  googleMapsApiKey,
  rankSuggestions,
  BIAS_LAT,
  BIAS_LNG,
};
