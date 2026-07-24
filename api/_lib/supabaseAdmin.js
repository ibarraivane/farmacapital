'use strict';

function normalizeSupabaseProjectUrl(url) {
  if (url == null || typeof url !== 'string') return '';
  let u = url.trim().replace(/\/+$/g, '');
  while (/\/rest\/v1$/i.test(u)) u = u.replace(/\/rest\/v1$/i, '').replace(/\/+$/g, '');
  return u;
}

function getSupabaseAdminConfig() {
  const supabaseUrl = normalizeSupabaseProjectUrl(
    process.env.SUPABASE_URL || process.env.REACT_APP_SUPABASE_URL || ''
  );
  const serviceKey = String(process.env.SUPABASE_SERVICE_ROLE_KEY || '').trim();
  return { supabaseUrl, serviceKey };
}

async function rpc(serviceKey, supabaseUrl, fn, payload) {
  const resp = await fetch(`${supabaseUrl}/rest/v1/rpc/${fn}`, {
    method: 'POST',
    headers: {
      apikey: serviceKey,
      Authorization: `Bearer ${serviceKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(payload),
  });
  const data = await resp.json().catch(() => null);
  if (!resp.ok) {
    const detail = typeof data === 'object' ? JSON.stringify(data) : String(data || '');
    throw new Error(`${fn}_failed:${resp.status}:${detail.slice(0, 200)}`);
  }
  return data;
}

async function validateEmployeeSession(supabaseUrl, serviceKey, sessionToken) {
  if (!sessionToken) return false;
  try {
    const data = await rpc(serviceKey, supabaseUrl, 'fn_validar_token_empleado', {
      p_token: sessionToken,
    });
    return data != null && Number(data) > 0;
  } catch {
    return false;
  }
}

async function readRawBody(req) {
  if (req.body && Buffer.isBuffer(req.body)) return req.body;
  if (typeof req.body === 'string') return Buffer.from(req.body);
  const chunks = [];
  for await (const chunk of req) chunks.push(chunk);
  return Buffer.concat(chunks);
}

module.exports = {
  normalizeSupabaseProjectUrl,
  getSupabaseAdminConfig,
  validateEmployeeSession,
  readRawBody,
};
