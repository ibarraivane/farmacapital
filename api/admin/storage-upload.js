'use strict';

const {
  getSupabaseAdminConfig,
  validateEmployeeSession,
  readRawBody,
} = require('../_lib/supabaseAdmin');

const ALLOWED_BUCKETS = new Set(['banners', 'productos']);
const MAX_BYTES = 12 * 1024 * 1024;

async function handler(req, res) {
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

  const valid = await validateEmployeeSession(supabaseUrl, serviceKey, sessionToken);
  if (!valid) {
    return res.status(401).json({ ok: false, error: 'invalid_session' });
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

  const uploadUrl = `${supabaseUrl}/storage/v1/object/${encodeURIComponent(bucket)}/${encodeURIComponent(fileName)}`;

  try {
    const uploadResp = await fetch(uploadUrl, {
      method: 'POST',
      headers: {
        apikey: serviceKey,
        Authorization: `Bearer ${serviceKey}`,
        'Content-Type': contentType,
        'x-upsert': 'false',
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
