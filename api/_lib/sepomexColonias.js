'use strict';

/** Colonias SEPOMEX por CP (Zippopotam, sin token). */

const CACHE = new Map();
const CACHE_TTL_MS = 7 * 24 * 60 * 60 * 1000;

function digitsCp(raw) {
  return String(raw || '').replace(/\D/g, '').slice(0, 5);
}

function foldMx(s) {
  return String(s || '')
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/\s+/g, ' ')
    .trim();
}

function uniquedColonias(names) {
  const seen = new Set();
  const out = [];
  for (const raw of names || []) {
    const name = String(raw || '').replace(/\s+/g, ' ').trim();
    if (!name) continue;
    const key = foldMx(name);
    if (!key || seen.has(key)) continue;
    seen.add(key);
    out.push(name);
  }
  out.sort((a, b) => a.localeCompare(b, 'es'));
  return out;
}

function coloniasFromZippopotam(data) {
  const places = Array.isArray(data?.places) ? data.places : [];
  return uniquedColonias(places.map((p) => p['place name'] || p.place_name || p['placeName']));
}

/**
 * Lista de colonias para un CP mexicano de 5 dígitos.
 * @param {string} cp
 * @param {{ fetchFn?: typeof fetch }} [opts]
 */
async function lookupColoniasByCp(cp, opts = {}) {
  const zip = digitsCp(cp);
  if (zip.length !== 5) {
    return { ok: false, error: 'cp_invalid', cp: zip, colonias: [] };
  }

  const hit = CACHE.get(zip);
  if (hit && Date.now() - hit.at < CACHE_TTL_MS) {
    return { ok: true, cp: zip, colonias: hit.colonias, provider: 'cache' };
  }

  const fetchImpl = opts.fetchFn || fetch;
  try {
    const resp = await fetchImpl(`https://api.zippopotam.us/mx/${zip}`, {
      headers: { Accept: 'application/json' },
    });
    if (resp.status === 404) {
      CACHE.set(zip, { at: Date.now(), colonias: [] });
      return { ok: true, cp: zip, colonias: [], provider: 'zippopotam' };
    }
    if (!resp.ok) {
      return { ok: false, error: `http_${resp.status}`, cp: zip, colonias: [] };
    }
    const data = typeof resp.json === 'function' ? await resp.json() : {};
    const colonias = coloniasFromZippopotam(data);
    CACHE.set(zip, { at: Date.now(), colonias });
    return { ok: true, cp: zip, colonias, provider: 'zippopotam' };
  } catch (err) {
    return {
      ok: false,
      error: 'fetch_failed',
      detail: err && err.message ? String(err.message) : 'unknown',
      cp: zip,
      colonias: [],
    };
  }
}

function __resetColoniasCache() {
  CACHE.clear();
}

module.exports = {
  digitsCp,
  uniquedColonias,
  coloniasFromZippopotam,
  lookupColoniasByCp,
  __resetColoniasCache,
};
