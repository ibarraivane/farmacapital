'use strict';

const { getSupabaseAdminConfig, validateEmployeeSession } = require('./supabaseAdmin');
const { runRastreoRappi, filasDesdeOfertas } = require('./rastrearRappi');
const { terminoBusquedaRappi } = require('../../src/lib/monitorPrecios/fuentes/rappi');

function safeJson(req) {
  try {
    if (!req?.body) return {};
    if (typeof req.body === 'object') return req.body;
    return JSON.parse(req.body || '{}');
  } catch {
    return {};
  }
}

async function buscarRappiHandler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ ok: false, error: 'method_not_allowed' });
  }

  const { supabaseUrl, serviceKey } = getSupabaseAdminConfig();
  if (!supabaseUrl || !serviceKey) {
    return res.status(500).json({ ok: false, error: 'supabase_not_configured' });
  }

  const body = safeJson(req);
  const sessionToken = String(body.session_token || req.headers['x-session-token'] || '').trim();
  if (!sessionToken) return res.status(401).json({ ok: false, error: 'missing_session' });
  const valid = await validateEmployeeSession(supabaseUrl, serviceKey, sessionToken);
  if (!valid) return res.status(401).json({ ok: false, error: 'invalid_session' });

  try {
    const out = await runRastreoRappi({
      supabaseUrl,
      serviceKey,
      max: 3,
      concurrency: 1,
      soloLinked: true,
    });
    return res.status(200).json({
      ok: true,
      ...out,
      message: out.actualizados
        ? `Se actualizaron ${out.actualizados} producto(s) en Rappi.`
          + (out.pendientes ? ` Quedan ${out.pendientes} por buscar: pulsa otra vez.` : '')
        : (out.buscados
          ? 'Rappi no devolvió coincidencias en este lote. Intenta de nuevo.'
          : 'No hay productos para buscar.'),
    });
  } catch (err) {
    return res.status(502).json({
      ok: false,
      error: err && err.message ? err.message.slice(0, 180) : 'rastreo_failed',
    });
  }
}

module.exports = { buscarRappiHandler, filasDesdeOfertas, clasificarLote: terminoBusquedaRappi };
