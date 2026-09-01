'use strict';

/**
 * Canje OAuth (Supabase Auth) → sesión FarmaCapital (sesiones_cliente).
 * Vive en api/_lib para no consumir un Serverless Function extra (Hobby máx. 12).
 * Se monta desde api/auth/password-reset-request.js vía ?type=oauth-bridge
 * y rewrite /api/auth/oauth-bridge.
 */

const { getSupabaseAdminConfig, rpc } = require('./supabaseAdmin');

const ALLOWED_PROVIDERS = new Set(['google', 'facebook', 'apple']);

async function safeJson(req) {
  try {
    if (!req?.body) return {};
    if (typeof req.body === 'object') return req.body;
    return JSON.parse(req.body || '{}');
  } catch {
    return {};
  }
}

async function fetchAuthUser(supabaseUrl, anonOrServiceKey, accessToken) {
  const resp = await fetch(`${supabaseUrl}/auth/v1/user`, {
    method: 'GET',
    headers: {
      apikey: anonOrServiceKey,
      Authorization: `Bearer ${accessToken}`,
    },
  });
  const data = await resp.json().catch(() => null);
  if (!resp.ok || !data || !data.id) return null;
  return data;
}

function pickIdentity(user, preferredProvider) {
  const identities = Array.isArray(user?.identities) ? user.identities : [];
  let identity = null;
  if (preferredProvider) {
    identity =
      identities.find((i) => String(i?.provider || '').toLowerCase() === preferredProvider) || null;
  }
  if (!identity && identities.length === 1) identity = identities[0];
  if (!identity && identities.length > 1) {
    identity =
      identities.find((i) => ALLOWED_PROVIDERS.has(String(i?.provider || '').toLowerCase())) ||
      identities[0];
  }

  const provider = String(
    preferredProvider || identity?.provider || user?.app_metadata?.provider || ''
  )
    .trim()
    .toLowerCase();

  const subject = String(
    identity?.id || identity?.identity_id || user?.user_metadata?.sub || user?.id || ''
  ).trim();

  const email = String(
    user?.email || identity?.identity_data?.email || user?.user_metadata?.email || ''
  )
    .trim()
    .toLowerCase();

  const nombre = String(
    user?.user_metadata?.full_name ||
      user?.user_metadata?.name ||
      identity?.identity_data?.full_name ||
      identity?.identity_data?.name ||
      ''
  ).trim();

  return { provider, subject, email: email || null, nombre: nombre || null };
}

module.exports = async function oauthBridgeHandler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ ok: false, error: 'method_not_allowed' });
  }

  const { supabaseUrl, serviceKey } = getSupabaseAdminConfig();
  const anonKey = String(
    process.env.SUPABASE_ANON_KEY || process.env.REACT_APP_SUPABASE_ANON_KEY || ''
  ).trim();

  if (!supabaseUrl || !serviceKey) {
    return res.status(500).json({ ok: false, error: 'server_not_configured' });
  }

  const body = await safeJson(req);
  const accessToken = String(body?.access_token || body?.accessToken || '').trim();
  const preferredProvider = String(body?.provider || '')
    .trim()
    .toLowerCase();

  if (!accessToken) {
    return res.status(400).json({ ok: false, error: 'missing_access_token' });
  }
  if (preferredProvider && !ALLOWED_PROVIDERS.has(preferredProvider)) {
    return res.status(400).json({ ok: false, error: 'unsupported_provider' });
  }

  try {
    const authUser = await fetchAuthUser(supabaseUrl, anonKey || serviceKey, accessToken);
    if (!authUser) {
      return res.status(401).json({ ok: false, error: 'invalid_oauth_session' });
    }

    const { provider, subject, email, nombre } = pickIdentity(
      authUser,
      preferredProvider || null
    );

    if (!ALLOWED_PROVIDERS.has(provider) || !subject) {
      return res.status(400).json({
        ok: false,
        error: 'oauth_identity_incomplete',
        detail: { provider: provider || null, has_subject: Boolean(subject) },
      });
    }

    const ip =
      String(body?.ip || req.headers['x-forwarded-for'] || '')
        .split(',')[0]
        .trim() || null;
    const userAgent =
      String(body?.user_agent || body?.userAgent || req.headers['user-agent'] || '').slice(0, 500) ||
      null;

    const result = await rpc(serviceKey, supabaseUrl, 'service_login_cliente_oauth', {
      p_provider: provider,
      p_subject: subject,
      p_email: email,
      p_nombre: nombre,
      p_ip: ip,
      p_user_agent: userAgent,
    });

    if (!result?.success || !result?.token) {
      return res.status(400).json({
        ok: false,
        error: result?.error || 'oauth_bridge_failed',
      });
    }

    return res.status(200).json({
      ok: true,
      created: Boolean(result.created),
      token: result.token,
      session_token: result.token,
      cliente: result.cliente || null,
      user: result.cliente || null,
      needs_phone: !result.cliente?.telefono,
      provider,
    });
  } catch (e) {
    console.error('[oauth-bridge]', e);
    const msg = String(e?.message || e || '');
    if (/service_login_cliente_oauth_failed:404/i.test(msg)) {
      return res.status(503).json({
        ok: false,
        error: 'oauth_sql_pending',
        message:
          'Falta aplicar sql/patch_cliente_oauth_login.sql en Supabase. El login social aún no está activo en la base.',
      });
    }
    return res.status(502).json({ ok: false, error: 'oauth_bridge_failed' });
  }
};
