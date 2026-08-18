'use strict';

const {
  getSupabaseAdminConfig,
  validateAdminSession,
  readRawBody,
  rpc,
} = require('../_lib/supabaseAdmin');

const BUCKET = 'rh-documentos';
const MAX_BYTES = 10 * 1024 * 1024;
const TIPOS = new Set([
  'contrato', 'ine_frente', 'ine_reverso', 'domicilio',
  'curp', 'rfc', 'nss', 'clabe', 'foto', 'otro',
]);
const MIMES = new Set([
  'application/pdf',
  'image/jpeg',
  'image/png',
  'image/webp',
]);
const EXT_MIME = {
  pdf: 'application/pdf',
  jpg: 'image/jpeg',
  jpeg: 'image/jpeg',
  png: 'image/png',
  webp: 'image/webp',
};

function sessionTokenOf(req) {
  return String(req.headers['x-session-token'] || req.query?.token || '').trim();
}

function encodeObjectPath(path) {
  return String(path).split('/').map(encodeURIComponent).join('/');
}

function extOf(name, mime) {
  const raw = String(name || '').split('.').pop() || '';
  const ext = raw.toLowerCase() === 'jfif' ? 'jpg' : raw.toLowerCase();
  if (EXT_MIME[ext]) return ext === 'jpeg' ? 'jpg' : ext;
  if (mime === 'application/pdf') return 'pdf';
  if (mime === 'image/png') return 'png';
  if (mime === 'image/webp') return 'webp';
  if (mime === 'image/jpeg') return 'jpg';
  return '';
}

function randomId() {
  if (typeof crypto !== 'undefined' && crypto.randomUUID) return crypto.randomUUID();
  return `${Date.now().toString(16)}-${Math.random().toString(16).slice(2)}`;
}

async function storageFetch(supabaseUrl, serviceKey, method, objectPath, opts = {}) {
  const url = `${supabaseUrl}/storage/v1/object/${encodeURIComponent(BUCKET)}/${encodeObjectPath(objectPath)}`;
  const headers = {
    apikey: serviceKey,
    Authorization: `Bearer ${serviceKey}`,
    ...(opts.headers || {}),
  };
  return fetch(url, { method, headers, body: opts.body });
}

async function handlePost(req, res, supabaseUrl, serviceKey, sessionToken) {
  const empleadoId = parseInt(String(req.headers['x-empleado-id'] || ''), 10);
  const tipo = String(req.headers['x-tipo'] || '').trim().toLowerCase();
  const fileName = String(req.headers['x-file-name'] || '').trim();
  const contentType = String(req.headers['content-type'] || '').split(';')[0].trim().toLowerCase();

  if (!Number.isFinite(empleadoId) || empleadoId <= 0) {
    return res.status(400).json({ ok: false, error: 'invalid_empleado' });
  }
  if (!TIPOS.has(tipo)) {
    return res.status(400).json({ ok: false, error: 'invalid_tipo' });
  }

  const ext = extOf(fileName, contentType);
  const mime = MIMES.has(contentType) ? contentType : EXT_MIME[ext];
  if (!mime || !MIMES.has(mime)) {
    return res.status(400).json({ ok: false, error: 'invalid_mime' });
  }
  if (!fileName || fileName.length > 180) {
    return res.status(400).json({ ok: false, error: 'invalid_file_name' });
  }

  let body;
  try {
    body = await readRawBody(req);
  } catch (e) {
    return res.status(400).json({ ok: false, error: 'empty_body', message: e.message });
  }
  if (!body?.length) return res.status(400).json({ ok: false, error: 'empty_body' });
  if (body.length > MAX_BYTES) return res.status(413).json({ ok: false, error: 'file_too_large' });

  const storagePath = `${empleadoId}/${tipo}/${randomId()}.${ext}`;
  const uploadResp = await storageFetch(supabaseUrl, serviceKey, 'POST', storagePath, {
    headers: { 'Content-Type': mime, 'x-upsert': 'false' },
    body,
  });

  if (!uploadResp.ok) {
    const detail = await uploadResp.text().catch(() => '');
    console.error('[rh-documento] upload', uploadResp.status, detail.slice(0, 300));
    return res.status(502).json({
      ok: false,
      error: 'upload_failed',
      message: detail.slice(0, 200) || `HTTP ${uploadResp.status}`,
    });
  }

  try {
    const registered = await rpc(serviceKey, supabaseUrl, 'admin_registrar_documento_empleado', {
      p_session_token: sessionToken,
      p_empleado_id: empleadoId,
      p_tipo: tipo,
      p_nombre_archivo: fileName.slice(0, 180),
      p_storage_path: storagePath,
      p_mime_type: mime,
      p_bytes: body.length,
    });
    if (registered?.success === false) {
      throw new Error(registered.error || 'register_failed');
    }
    return res.status(200).json({ ok: true, id: registered?.id, path: storagePath });
  } catch (e) {
    await storageFetch(supabaseUrl, serviceKey, 'DELETE', storagePath).catch(() => {});
    console.error('[rh-documento] register', e);
    return res.status(502).json({ ok: false, error: 'register_failed', message: e.message });
  }
}

async function handleGet(req, res, supabaseUrl, serviceKey, sessionToken) {
  const documentoId = parseInt(String(req.query?.id || ''), 10);
  if (!Number.isFinite(documentoId) || documentoId <= 0) {
    return res.status(400).json({ ok: false, error: 'invalid_id' });
  }

  let meta;
  try {
    meta = await rpc(serviceKey, supabaseUrl, 'admin_documento_empleado_path', {
      p_session_token: sessionToken,
      p_documento_id: documentoId,
    });
  } catch (e) {
    return res.status(404).json({ ok: false, error: 'not_found', message: e.message });
  }

  const path = meta?.storage_path;
  if (!path) return res.status(404).json({ ok: false, error: 'not_found' });

  const fileResp = await storageFetch(supabaseUrl, serviceKey, 'GET', path);
  if (!fileResp.ok) {
    const detail = await fileResp.text().catch(() => '');
    return res.status(502).json({ ok: false, error: 'download_failed', message: detail.slice(0, 200) });
  }

  const buf = Buffer.from(await fileResp.arrayBuffer());
  const mime = meta.mime_type || fileResp.headers.get('content-type') || 'application/octet-stream';
  const filename = String(meta.nombre_archivo || 'documento').replace(/[\r\n"]/g, '');
  res.setHeader('Content-Type', mime);
  res.setHeader('Content-Disposition', `inline; filename="${filename}"`);
  res.setHeader('Cache-Control', 'private, no-store');
  return res.status(200).send(buf);
}

async function handleDelete(req, res, supabaseUrl, serviceKey, sessionToken) {
  const documentoId = parseInt(String(req.query?.id || req.headers['x-documento-id'] || ''), 10);
  if (!Number.isFinite(documentoId) || documentoId <= 0) {
    return res.status(400).json({ ok: false, error: 'invalid_id' });
  }

  let meta;
  try {
    meta = await rpc(serviceKey, supabaseUrl, 'admin_documento_empleado_path', {
      p_session_token: sessionToken,
      p_documento_id: documentoId,
    });
  } catch (e) {
    return res.status(404).json({ ok: false, error: 'not_found', message: e.message });
  }

  if (meta?.storage_path) {
    const delFile = await storageFetch(supabaseUrl, serviceKey, 'DELETE', meta.storage_path);
    if (!delFile.ok && delFile.status !== 404) {
      const detail = await delFile.text().catch(() => '');
      console.error('[rh-documento] storage delete', delFile.status, detail.slice(0, 200));
    }
  }

  try {
    await rpc(serviceKey, supabaseUrl, 'admin_eliminar_documento_empleado', {
      p_session_token: sessionToken,
      p_documento_id: documentoId,
    });
  } catch (e) {
    return res.status(502).json({ ok: false, error: 'delete_failed', message: e.message });
  }

  return res.status(200).json({ ok: true });
}

async function handler(req, res) {
  const { supabaseUrl, serviceKey } = getSupabaseAdminConfig();
  if (!supabaseUrl || !serviceKey) {
    return res.status(500).json({ ok: false, error: 'supabase_not_configured' });
  }

  const sessionToken = sessionTokenOf(req);
  if (!sessionToken) {
    return res.status(401).json({ ok: false, error: 'missing_session' });
  }

  const isAdmin = await validateAdminSession(supabaseUrl, serviceKey, sessionToken);
  if (!isAdmin) {
    return res.status(403).json({ ok: false, error: 'admin_required' });
  }

  try {
    if (req.method === 'POST') return await handlePost(req, res, supabaseUrl, serviceKey, sessionToken);
    if (req.method === 'GET') return await handleGet(req, res, supabaseUrl, serviceKey, sessionToken);
    if (req.method === 'DELETE') return await handleDelete(req, res, supabaseUrl, serviceKey, sessionToken);
    return res.status(405).json({ ok: false, error: 'method_not_allowed' });
  } catch (e) {
    console.error('[rh-documento]', e);
    return res.status(502).json({ ok: false, error: 'server_error', message: e.message });
  }
}

handler.config = {
  api: { bodyParser: false },
};

module.exports = handler;
