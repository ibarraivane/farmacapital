'use strict';

const { applyRestrictiveCors } = require('./allowedOrigins');
const { suggestAddresses } = require('./addressSuggest');

/**
 * Handler HTTP de sugerencias de dirección (Google Places / Photon).
 * Vive en _lib (no cuenta como Serverless Function) y se monta desde
 * logistics/webhook para no pasar el límite Hobby de 12 funciones.
 */
module.exports = async function handleAddressSuggestHttp(req, res) {
  applyRestrictiveCors(req, res);
  if (req.method === 'OPTIONS') {
    res.statusCode = 204;
    res.end();
    return;
  }
  if (req.method !== 'GET' && req.method !== 'POST') {
    res.statusCode = 405;
    res.setHeader('Content-Type', 'application/json');
    res.end(JSON.stringify({ ok: false, error: 'method_not_allowed' }));
    return;
  }

  let query = '';
  if (req.method === 'GET') {
    const q = req.query || {};
    query = String(q.q || q.query || q.input || '');
  } else {
    let body = req.body;
    if (typeof body === 'string') {
      try {
        body = JSON.parse(body || '{}');
      } catch {
        body = {};
      }
    }
    query = String(body?.q || body?.query || body?.input || '');
  }

  const result = await suggestAddresses(query);
  res.statusCode = result.ok ? 200 : 502;
  res.setHeader('Content-Type', 'application/json');
  res.setHeader('Cache-Control', 'no-store');
  res.end(
    JSON.stringify({
      ok: Boolean(result.ok),
      provider: result.provider || null,
      suggestions: result.suggestions || [],
      error: result.error || null,
      detail: result.detail || null,
    })
  );
};
