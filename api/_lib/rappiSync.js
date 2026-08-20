'use strict';

const { getSupabaseAdminConfig } = require('./supabaseAdmin');

const MAX_INTENTOS = 5;
const DEFAULT_BATCH = 25;
/** Dominio NEW de desarrollo (docs Authentication). México prod: https://api.rappi.com.mx */
const DEFAULT_API_BASE = 'https://api.dev.rappi.com';
const TOKEN_LOGIN_PATH = '/restaurants/auth/v1/token/login/integrations';

let tokenCache = { token: null, expMs: 0 };

function resetRappiTokenCache() {
  tokenCache = { token: null, expMs: 0 };
}

function rappiCredentials() {
  const clientId = String(process.env.RAPPI_CLIENT_ID || '').trim();
  const clientSecret = String(process.env.RAPPI_CLIENT_SECRET || '').trim();
  const storeId = String(process.env.RAPPI_STORE_ID || '').trim();
  const apiBase = String(process.env.RAPPI_API_BASE || DEFAULT_API_BASE).trim().replace(/\/+$/, '');
  const availabilityPath = String(process.env.RAPPI_AVAILABILITY_PATH || '').trim();
  const hasSecrets = Boolean(clientId && clientSecret);
  const stockReady = Boolean(hasSecrets && storeId && availabilityPath);
  return {
    clientId,
    clientSecret,
    storeId,
    apiBase,
    availabilityPath,
    hasSecrets,
    stockReady,
    ready: stockReady,
  };
}

function loginIntegrationsUrl(apiBase) {
  const base = String(apiBase || DEFAULT_API_BASE).replace(/\/+$/, '');
  return `${base}${TOKEN_LOGIN_PATH}`;
}

/**
 * Docs Authentication: header `x-authorization` = `Bearer: <access_token>`
 */
function rappiAuthHeaders(accessToken) {
  const prefix = String(process.env.RAPPI_BEARER_PREFIX || 'Bearer:').trim();
  return {
    'x-authorization': `${prefix} ${accessToken}`.replace(/ {2,}/g, ' '),
    Accept: 'application/json',
    'Content-Type': 'application/json',
    'User-Agent': 'FarmaCapital/1.0',
  };
}

async function getIntegrationsAccessToken(creds = rappiCredentials(), fetchFn = fetch) {
  if (tokenCache.token && Date.now() < tokenCache.expMs) {
    return tokenCache.token;
  }
  const resp = await fetchFn(loginIntegrationsUrl(creds.apiBase), {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/json',
      'User-Agent': 'FarmaCapital/1.0',
    },
    body: JSON.stringify({
      client_id: creds.clientId,
      client_secret: creds.clientSecret,
    }),
  });
  const data = await resp.json().catch(() => null);
  if (!resp.ok || !data?.access_token) {
    const detail = typeof data === 'object' ? JSON.stringify(data) : String(data || '');
    throw new Error(`rappi_token_${resp.status}:${detail.slice(0, 200)}`);
  }
  const ttlSec = Math.max(60, Number(data.expires_in) || 86400);
  tokenCache = {
    token: data.access_token,
    expMs: Date.now() + (ttlSec - 60) * 1000,
  };
  return tokenCache.token;
}

function nextBackoffIso(intentos, now = new Date()) {
  const n = Math.max(1, Number(intentos) || 1);
  const ms = Math.min(60 * 60 * 1000, 60 * 1000 * 2 ** Math.min(n - 1, 8));
  return new Date(now.getTime() + ms).toISOString();
}

/**
 * Push de disponibilidad. Auth = token integrations + x-authorization.
 * Sin RAPPI_AVAILABILITY_PATH (Rest API of Availability) no pega a Rappi.
 */
async function pushDisponibilidadRappi(payload, creds = rappiCredentials(), fetchFn = fetch) {
  if (!creds.hasSecrets) {
    return { ok: false, skipped: 'no_credentials' };
  }
  if (!creds.storeId || !creds.availabilityPath) {
    return { ok: false, skipped: 'adapter_unverified' };
  }
  const token = await getIntegrationsAccessToken(creds, fetchFn);
  const path = creds.availabilityPath.startsWith('/') ? creds.availabilityPath : `/${creds.availabilityPath}`;
  const url = `${creds.apiBase}${path}`.replace('{storeId}', encodeURIComponent(creds.storeId));
  const body = {
    store_id: creds.storeId,
    sku: payload?.sku,
    available: Boolean(payload?.disponible),
    stock: Number(payload?.stock_rappi) || 0,
  };
  const resp = await fetchFn(url, {
    method: 'PATCH',
    headers: rappiAuthHeaders(token),
    body: JSON.stringify(body),
  });
  if (!resp.ok) {
    let detail = '';
    try {
      detail = await resp.text();
    } catch {
      detail = '';
    }
    return {
      ok: false,
      error: `rappi_http_${resp.status}`,
      detail: String(detail || '').slice(0, 300),
    };
  }
  return { ok: true };
}

async function restJson({ supabaseUrl, serviceKey, path, method, body, extraHeaders }) {
  const resp = await fetch(`${supabaseUrl}/rest/v1/${path}`, {
    method,
    headers: {
      apikey: serviceKey,
      Authorization: `Bearer ${serviceKey}`,
      'Content-Type': 'application/json',
      Prefer: 'return=representation',
      ...(extraHeaders || {}),
    },
    body: body == null ? undefined : JSON.stringify(body),
  });
  const data = await resp.json().catch(() => null);
  if (!resp.ok) {
    const detail = typeof data === 'object' ? JSON.stringify(data) : String(data || '');
    throw new Error(`supabase_${method}_${path}:${resp.status}:${detail.slice(0, 200)}`);
  }
  return data;
}

async function rpcJson({ supabaseUrl, serviceKey, fn, payload }) {
  const resp = await fetch(`${supabaseUrl}/rest/v1/rpc/${fn}`, {
    method: 'POST',
    headers: {
      apikey: serviceKey,
      Authorization: `Bearer ${serviceKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(payload || {}),
  });
  const data = await resp.json().catch(() => null);
  if (!resp.ok) {
    const detail = typeof data === 'object' ? JSON.stringify(data) : String(data || '');
    throw new Error(`${fn}_failed:${resp.status}:${detail.slice(0, 200)}`);
  }
  return data;
}

/**
 * Aplica el resultado de un push a una fila de cola (puro, para tests).
 */
function applyPushResult(row, pushResult, now = new Date()) {
  const intentos = Number(row?.intentos) || 0;
  if (pushResult?.ok) {
    return {
      estado: 'ok',
      last_error: null,
      processed_at: now.toISOString(),
      available_at: now.toISOString(),
    };
  }
  if (pushResult?.skipped) {
    return {
      estado: 'omitido',
      last_error: pushResult.skipped,
      processed_at: now.toISOString(),
      available_at: now.toISOString(),
    };
  }
  if (intentos >= MAX_INTENTOS) {
    return {
      estado: 'error',
      last_error: String(pushResult?.error || 'rappi_push_failed').slice(0, 400),
      processed_at: now.toISOString(),
      available_at: now.toISOString(),
    };
  }
  return {
    estado: 'pendiente',
    last_error: String(pushResult?.error || 'rappi_push_failed').slice(0, 400),
    processed_at: null,
    available_at: nextBackoffIso(intentos, now),
  };
}

/**
 * Drena una cola en memoria (tests). Misma política que el worker real.
 * @param {Array<object>} queue
 */
async function drainSimulatedQueue(queue, options = {}) {
  const creds = options.creds || rappiCredentials();
  const now = options.now || new Date();
  const batchSize = Math.max(1, Math.min(Number(options.batchSize) || DEFAULT_BATCH, 100));
  const pushFn = options.pushFn;

  if (!creds.hasSecrets) {
    return { ok: true, skipped: 'no_credentials', processed: 0 };
  }
  if (!creds.apiBase && !options.allowUnverifiedPush) {
    return { ok: true, skipped: 'adapter_unverified', processed: 0 };
  }
  if (options.paused) {
    return { ok: true, skipped: 'paused', processed: 0 };
  }

  const claimed = queue
    .filter((row) => row.estado === 'pendiente' && new Date(row.available_at || 0) <= now)
    .sort((a, b) => String(a.created_at || '').localeCompare(String(b.created_at || '')))
    .slice(0, batchSize);

  let ok = 0;
  let error = 0;
  let retry = 0;
  for (const row of claimed) {
    row.estado = 'procesando';
    row.intentos = (Number(row.intentos) || 0) + 1;
    let pushResult;
    try {
      pushResult = await pushFn(row.payload || {});
    } catch (err) {
      pushResult = { ok: false, error: String(err.message || err).slice(0, 300) };
    }
    const patch = applyPushResult(row, pushResult, now);
    Object.assign(row, patch);
    if (patch.estado === 'ok') ok += 1;
    else if (patch.estado === 'error') error += 1;
    else retry += 1;
  }

  return {
    ok: true,
    processed: claimed.length,
    ok_count: ok,
    error_count: error,
    retry_count: retry,
  };
}

async function drainRappiQueue(options = {}) {
  const creds = options.creds || rappiCredentials();
  const fetchFn = options.fetchFn || fetch;
  const pushFn = options.pushFn || ((payload) => pushDisponibilidadRappi(payload, creds, fetchFn));
  const batchSize = Math.max(1, Math.min(Number(options.batchSize) || DEFAULT_BATCH, 100));

  if (!creds.hasSecrets) {
    console.warn('[rappi-sync] modo sin-API: faltan RAPPI_CLIENT_ID / RAPPI_CLIENT_SECRET');
    return { ok: true, skipped: 'no_credentials', processed: 0 };
  }
  if (!creds.stockReady) {
    console.warn(
      '[rappi-sync] auth lista, stock no: falta RAPPI_STORE_ID y/o RAPPI_AVAILABILITY_PATH (Rest API of Availability)'
    );
    return { ok: true, skipped: 'adapter_unverified', processed: 0 };
  }

  const { supabaseUrl, serviceKey } = options.supabase || getSupabaseAdminConfig();
  if (!supabaseUrl || !serviceKey) {
    return { ok: false, error: 'supabase_not_configured', processed: 0 };
  }

  let paused = false;
  try {
    const cfg = await restJson({
      supabaseUrl,
      serviceKey,
      path: 'configuracion?clave=eq.rappi_sync_paused&select=valor',
      method: 'GET',
    });
    paused = String(cfg?.[0]?.valor || '').trim().toLowerCase() === 'true';
  } catch (err) {
    console.warn('[rappi-sync] no se pudo leer rappi_sync_paused:', err.message);
  }
  if (paused) {
    return { ok: true, skipped: 'paused', processed: 0 };
  }

  let claimed = [];
  try {
    const rows = await rpcJson({
      supabaseUrl,
      serviceKey,
      fn: 'rappi_claim_sync_batch',
      payload: { p_limit: batchSize },
    });
    claimed = Array.isArray(rows) ? rows : [];
  } catch (err) {
    return { ok: false, error: err.message, processed: 0 };
  }

  let ok = 0;
  let error = 0;
  let retry = 0;
  for (const row of claimed) {
    let pushResult;
    try {
      pushResult = await pushFn(row.payload || {});
    } catch (err) {
      pushResult = { ok: false, error: String(err.message || err).slice(0, 300) };
    }
    const patch = applyPushResult(row, pushResult);
    try {
      await restJson({
        supabaseUrl,
        serviceKey,
        path: `rappi_sync_queue?id=eq.${row.id}`,
        method: 'PATCH',
        body: patch,
      });
    } catch (err) {
      console.error('[rappi-sync] no se pudo marcar fila', row.id, err.message);
      error += 1;
      continue;
    }
    if (patch.estado === 'ok') ok += 1;
    else if (patch.estado === 'error') error += 1;
    else retry += 1;
  }

  return {
    ok: true,
    processed: claimed.length,
    ok_count: ok,
    error_count: error,
    retry_count: retry,
  };
}

module.exports = {
  MAX_INTENTOS,
  DEFAULT_API_BASE,
  TOKEN_LOGIN_PATH,
  rappiCredentials,
  loginIntegrationsUrl,
  rappiAuthHeaders,
  getIntegrationsAccessToken,
  resetRappiTokenCache,
  nextBackoffIso,
  pushDisponibilidadRappi,
  applyPushResult,
  drainSimulatedQueue,
  drainRappiQueue,
};
