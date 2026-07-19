/**
 * FARMACAPITAL — Health check
 *
 * Invocado por Vercel Cron diariamente para mantener vivo el proyecto de
 * Supabase Free (se pausa tras 7 días sin queries) y para monitoreo básico.
 *
 * También disponible manualmente: GET /api/health
 *
 * Respuesta esperada:
 *   200 { ok: true, db: "up", ts: "..." }
 *   503 { ok: false, db: "down", error: "..." }  ← sanitizado
 *
 * Variables de entorno esperadas (Vercel):
 *   SUPABASE_URL                o  REACT_APP_SUPABASE_URL
 *   SUPABASE_ANON_KEY           o  REACT_APP_SUPABASE_ANON_KEY
 *
 * Seguridad:
 *   - No requiere secret porque solo ejecuta "select 1" (no lee datos).
 *   - No loguea las credenciales.
 *   - Respuesta siempre cabe en <1KB.
 */

'use strict';

function normalizeSupabaseProjectUrl(url) {
  if (url == null || typeof url !== 'string') return url;
  let u = url.trim().replace(/\/+$/g, '');
  while (/\/rest\/v1$/i.test(u)) {
    u = u.replace(/\/rest\/v1$/i, '').replace(/\/+$/g, '');
  }
  return u;
}

const SUPABASE_URL =
  normalizeSupabaseProjectUrl(
    process.env.SUPABASE_URL || process.env.REACT_APP_SUPABASE_URL
  );
const SUPABASE_ANON_KEY =
  process.env.SUPABASE_ANON_KEY || process.env.REACT_APP_SUPABASE_ANON_KEY;

function sanitizeError(err) {
  const msg = (err && err.message) || String(err || 'unknown');
  return msg
    .replace(/postgres(?:ql)?:\/\/[^\s"']+/gi, 'postgres://***')
    .replace(/(key|token|secret|authorization)[:=]\s*[^\s"',]+/gi, '$1=***')
    .slice(0, 300);
}

module.exports = async function handler(req, res) {
  const startedAt = Date.now();

  if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
    res.status(500).json({
      ok: false,
      db: 'unknown',
      error: 'missing_supabase_env',
      ts: new Date().toISOString(),
    });
    return;
  }

  try {
    // Hacemos una query real a Postgres (no solo la raíz de PostgREST que
    // sirve desde caché y nunca toca la base de datos).
    // "select=id&limit=1" despierta Postgres si estaba en cold start.
    // Si RLS bloquea el acceso anon, el error 401/403 sigue siendo útil:
    // significa que Postgres ya respondió y ya está despierto.
    const url = `${SUPABASE_URL.replace(/\/$/, '')}/rest/v1/productos?select=id&limit=1`;
    const resp = await fetch(url, {
      method: 'GET',
      headers: {
        apikey: SUPABASE_ANON_KEY,
        Authorization: `Bearer ${SUPABASE_ANON_KEY}`,
        Accept: 'application/json',
      },
    });

    // Cualquier respuesta de Postgres (200, 401, 406…) significa que Postgres despertó.
    // Solo 503/504 o error de red significan que no respondió.
    if (resp.status === 503 || resp.status === 504) {
      res.status(503).json({
        ok: false,
        db: 'down',
        status: resp.status,
        ms: Date.now() - startedAt,
        ts: new Date().toISOString(),
      });
      return;
    }

    res.status(200).json({
      ok: true,
      db: 'up',
      status: resp.status,
      ms: Date.now() - startedAt,
      ts: new Date().toISOString(),
    });
  } catch (err) {
    res.status(503).json({
      ok: false,
      db: 'down',
      error: sanitizeError(err),
      ms: Date.now() - startedAt,
      ts: new Date().toISOString(),
    });
  }
};
