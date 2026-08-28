'use strict';

const {
  getSupabaseAdminConfig,
  validateEmployeeSession,
  validateAdminSession,
  readRawBody,
} = require('../_lib/supabaseAdmin');
const { isRhDocumentoRequest, rhDocumentoHandler } = require('../_lib/rhDocumentoHandler');

const ALLOWED_BUCKETS = new Set(['banners', 'productos', 'cortes']);
const MAX_BYTES = 12 * 1024 * 1024;

async function ensureCortesBucket(supabaseUrl, serviceKey) {
  const headers = {
    apikey: serviceKey,
    Authorization: `Bearer ${serviceKey}`,
  };
  const getResp = await fetch(`${supabaseUrl}/storage/v1/bucket/cortes`, { headers });
  if (getResp.ok) return;
  const createResp = await fetch(`${supabaseUrl}/storage/v1/bucket`, {
    method: 'POST',
    headers: { ...headers, 'Content-Type': 'application/json' },
    body: JSON.stringify({
      id: 'cortes',
      name: 'cortes',
      public: true,
      file_size_limit: 5 * 1024 * 1024,
      allowed_mime_types: ['application/pdf'],
    }),
  });
  if (!createResp.ok) {
    const detail = await createResp.text().catch(() => '');
    console.error('[storage-upload] create bucket cortes', createResp.status, detail.slice(0, 300));
  }
}

async function handler(req, res) {
  // Hobby: máx. 12 funciones. El expediente RH vive aquí (?type=rh-documento).
  if (isRhDocumentoRequest(req)) {
    return rhDocumentoHandler(req, res);
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ ok: false, error: 'method_not_allowed' });
  }

  const { supabaseUrl, serviceKey } = getSupabaseAdminConfig();
  if (!supabaseUrl || !serviceKey) {
    return res.status(500).json({ ok: false, error: 'supabase_not_configured' });
  }

  const sessionToken = String(req.headers['x-session-token'] || '').trim();
  const bucket = String(req.headers['x-bucket'] || '').trim();
  const fileName = String(req.headers['x-file-name'] || '').trim();
  const contentType = String(req.headers['content-type'] || 'application/octet-stream').trim();

  if (!sessionToken) {
    return res.status(401).json({ ok: false, error: 'missing_session' });
  }
  if (!ALLOWED_BUCKETS.has(bucket)) {
    return res.status(400).json({ ok: false, error: 'invalid_bucket' });
  }
  if (!fileName || !/^[a-z0-9._-]+$/i.test(fileName)) {
    return res.status(400).json({ ok: false, error: 'invalid_file_name' });
  }
  if (bucket === 'cortes' && !/^corte-\d+\.pdf$/i.test(fileName)) {
    return res.status(400).json({ ok: false, error: 'invalid_file_name' });
  }

  const valid = await validateEmployeeSession(supabaseUrl, serviceKey, sessionToken);
  if (!valid) {
    return res.status(401).json({ ok: false, error: 'invalid_session' });
  }
  if (bucket !== 'cortes') {
    const isAdmin = await validateAdminSession(supabaseUrl, serviceKey, sessionToken);
    if (!isAdmin) {
      return res.status(403).json({ ok: false, error: 'admin_required' });
    }
  }

  let body;
  try {
    body = await readRawBody(req);
  } catch (e) {
    return res.status(400).json({ ok: false, error: 'empty_body', message: e.message });
  }

  if (!body?.length) {
    return res.status(400).json({ ok: false, error: 'empty_body' });
  }
  if (body.length > MAX_BYTES) {
    return res.status(413).json({ ok: false, error: 'file_too_large' });
  }

  if (bucket === 'cortes') {
    try {
      await ensureCortesBucket(supabaseUrl, serviceKey);
    } catch (e) {
      console.error('[storage-upload] ensure bucket cortes', e);
    }
  }

  const uploadUrl = `${supabaseUrl}/storage/v1/object/${encodeURIComponent(bucket)}/${encodeURIComponent(fileName)}`;
  const upsert = bucket === 'cortes' ? 'true' : 'false';

  try {
    const uploadResp = await fetch(uploadUrl, {
      method: 'POST',
      headers: {
        apikey: serviceKey,
        Authorization: `Bearer ${serviceKey}`,
        'Content-Type': contentType,
        'x-upsert': upsert,
      },
      body,
    });

    if (!uploadResp.ok) {
      const detail = await uploadResp.text().catch(() => '');
      console.error('[storage-upload]', uploadResp.status, detail.slice(0, 300));
      return res.status(502).json({
        ok: false,
        error: 'upload_failed',
        message: detail.slice(0, 200) || `HTTP ${uploadResp.status}`,
      });
    }

    const publicUrl = `${supabaseUrl}/storage/v1/object/public/${bucket}/${fileName}?v=${Date.now()}`;
    return res.status(200).json({ ok: true, publicUrl, path: fileName });
  } catch (e) {
    console.error('[storage-upload]', e);
    return res.status(502).json({ ok: false, error: 'upload_error', message: e.message });
  }
}

handler.config = {
  api: { bodyParser: false },
};

module.exports = handler;
