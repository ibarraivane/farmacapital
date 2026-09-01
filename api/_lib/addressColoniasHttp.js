'use strict';

const { applyRestrictiveCors } = require('./allowedOrigins');
const { lookupColoniasByCp } = require('./sepomexColonias');

/**
 * Handler HTTP: colonias por CP.
 * Vive en _lib (no cuenta como Serverless Function) y se monta desde
 * logistics/webhook para no pasar el límite Hobby de 12 funciones.
 */
module.exports = async function handleAddressColoniasHttp(req, res) {
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

  let cp = '';
  if (req.method === 'GET') {
    const q = req.query || {};
    cp = String(q.cp || q.zip || q.codigo || '');
  } else {
    let body = req.body;
    if (typeof body === 'string') {
      try {
        body = JSON.parse(body || '{}');
      } catch {
        body = {};
      }
    }
    cp = String(body?.cp || body?.zip || body?.codigo || '');
  }

  const result = await lookupColoniasByCp(cp);
  const ok = Boolean(result.ok);
  res.statusCode = ok ? 200 : result.error === 'cp_invalid' ? 400 : 502;
  res.setHeader('Content-Type', 'application/json');
  res.setHeader('Cache-Control', 'public, max-age=86400');
  res.end(
    JSON.stringify({
      ok,
      cp: result.cp || '',
      colonias: result.colonias || [],
      provider: result.provider || null,
      error: result.error || null,
      detail: result.detail || null,
    })
  );
};
