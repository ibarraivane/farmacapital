'use strict';

const { getSupabaseAdminConfig, validateEmployeeSession } = require('./supabaseAdmin');
const { buscarNadroPorEan } = require('../../src/lib/monitorPrecios/fuentes/nadro');

const HOY = () => new Date().toISOString().slice(0, 10);
const MAX = 8;

function safeJson(req) {
  try {
    if (!req?.body) return {};
    if (typeof req.body === 'object') return req.body;
    return JSON.parse(req.body || '{}');
  } catch {
    return {};
  }
}

function headersDe(serviceKey) {
  return {
    apikey: serviceKey,
    Authorization: `Bearer ${serviceKey}`,
    'Content-Type': 'application/json',
    Prefer: 'return=representation',
  };
}

async function rest(supabaseUrl, serviceKey, path, opts = {}) {
  const r = await fetch(`${supabaseUrl}/rest/v1/${path}`, {
    method: opts.method || 'GET',
    headers: { ...headersDe(serviceKey), ...(opts.headers || {}) },
    body: opts.body ? JSON.stringify(opts.body) : undefined,
  });
  const text = await r.text();
  let data = null;
  try { data = text ? JSON.parse(text) : null; } catch { data = text; }
  return { ok: r.ok, status: r.status, data };
}

async function productosPendientes(supabaseUrl, serviceKey) {
  const prod = await rest(
    supabaseUrl,
    serviceKey,
    'productos?select=id,sku,nombre,codigo_barras,imagen_url,principio_activo,tipo,categoria&activo=eq.true&codigo_barras=not.is.null&order=nombre.asc&limit=800'
  );
  if (!prod.ok || !Array.isArray(prod.data)) return [];
  const imgs = await rest(
    supabaseUrl,
    serviceKey,
    'producto_imagenes?select=producto_id&limit=4000'
  );
  const conFoto = new Set(
    (imgs.ok && Array.isArray(imgs.data) ? imgs.data : []).map((r) => r.producto_id)
  );
  const refs = await rest(
    supabaseUrl,
    serviceKey,
    'producto_precios_referencia?select=producto_id,fecha&fuente=eq.nadro&order=fecha.desc&limit=4000'
  );
  const conPrecio = new Set(
    (refs.ok && Array.isArray(refs.data) ? refs.data : []).map((r) => r.producto_id)
  );
  return (prod.data || []).filter((p) => {
    const ean = String(p.codigo_barras || '').replace(/\D/g, '');
    if (ean.length < 8) return false;
    const sinFoto = !String(p.imagen_url || '').trim() && !conFoto.has(p.id);
    return sinFoto || !conPrecio.has(p.id);
  }).map((p) => ({
    ...p,
    ean: String(p.codigo_barras || '').replace(/\D/g, ''),
    necesitaFoto: !String(p.imagen_url || '').trim() && !conFoto.has(p.id),
    necesitaPrecio: !conPrecio.has(p.id),
    med: Boolean(String(p.principio_activo || '').trim())
      || /generico|genérico|marca/i.test(String(p.tipo || ''))
      || /medic/i.test(String(p.categoria || '')),
  })).sort((a, b) => Number(b.med) - Number(a.med) || a.id - b.id);
}

async function subirFoto(supabaseUrl, serviceKey, ean, imageUrl) {
  const imgRes = await fetch(imageUrl, {
    headers: { 'User-Agent': 'FarmaCapitalPricingBot/1.0 (+https://www.farmacapital.mx)' },
  });
  if (!imgRes.ok) return null;
  const buf = Buffer.from(await imgRes.arrayBuffer());
  if (buf.length < 800) return null;
  const ct = String(imgRes.headers.get('content-type') || 'image/jpeg').split(';')[0];
  const ext = ct.includes('png') ? 'png' : ct.includes('webp') ? 'webp' : 'jpg';
  const path = `distribuidor/nadro-${ean}.${ext}`;
  const up = await fetch(`${supabaseUrl}/storage/v1/object/productos/${path}`, {
    method: 'POST',
    headers: {
      apikey: serviceKey,
      Authorization: `Bearer ${serviceKey}`,
      'Content-Type': ct,
      'x-upsert': 'true',
    },
    body: buf,
  });
  if (!up.ok && up.status !== 400) return null;
  return `${supabaseUrl}/storage/v1/object/public/productos/${path}`;
}

async function nadroSyncHandler(req, res) {
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

  const pendientes = await productosPendientes(supabaseUrl, serviceKey);
  const lote = pendientes.slice(0, MAX);
  let fotos = 0;
  let precios = 0;
  const encontrados = [];

  for (const p of lote) {
    const hit = await buscarNadroPorEan(fetch, p.ean);
    if (!hit || hit.ean !== p.ean) continue;
    encontrados.push({ ...p, hit });
    if (p.necesitaFoto && hit.imagenes[0]) {
      const url = await subirFoto(supabaseUrl, serviceKey, p.ean, hit.imagenes[0]);
      if (url) {
        await rest(supabaseUrl, serviceKey, 'producto_imagenes?on_conflict=producto_id,url', {
          method: 'POST',
          headers: { Prefer: 'return=minimal,resolution=ignore-duplicates' },
          body: [{
            producto_id: p.id,
            url,
            storage_path: `distribuidor/nadro-${p.ean}`,
            posicion: 1,
            es_principal: true,
            origen: 'distribuidor',
          }],
        });
        fotos += 1;
      }
    }
    if (hit.precioCompra > 0) {
      encontrados[encontrados.length - 1].precioCompra = hit.precioCompra;
    }
  }

  const conPrecio = encontrados.filter((x) => x.hit.precioCompra > 0);
  if (conPrecio.length) {
    const imp = await rest(supabaseUrl, serviceKey, 'importaciones_referencia', {
      method: 'POST',
      body: {
        fuente: 'nadro',
        tipo: 'compra',
        fecha_lista: HOY(),
        archivo: 'nadro_vtex',
        filas_ok: conPrecio.length,
        filas_error: 0,
        notas: 'boton_nadro_ui',
      },
    });
    const importId = Array.isArray(imp.data) ? imp.data[0]?.id : imp.data?.id;
    const ins = await rest(supabaseUrl, serviceKey, 'producto_precios_referencia', {
      method: 'POST',
      body: conPrecio.map((x) => ({
        producto_id: x.id,
        fuente: 'nadro',
        tipo: 'compra',
        precio: x.hit.precioCompra,
        fecha: HOY(),
        origen: 'job_vtex',
        import_id: importId || null,
        confianza: 95,
        nombre_fuente: x.hit.nombre,
        notas: 'rastreo_automatico',
      })),
    });
    if (ins.ok) precios = conPrecio.length;
  } else {
    await rest(supabaseUrl, serviceKey, 'importaciones_referencia', {
      method: 'POST',
      body: {
        fuente: 'nadro',
        tipo: 'compra',
        fecha_lista: HOY(),
        archivo: 'nadro_vtex',
        filas_ok: 0,
        filas_error: 0,
        notas: `boton_nadro_ui buscados=${lote.length} fotos=${fotos} sin_precio_cliente`,
      },
    });
  }

  const user = String(process.env.NADRO_USER || '').trim();
  const pass = String(process.env.NADRO_PASSWORD || '').trim();
  const faltaLogin = !user || !pass;

  return res.status(200).json({
    ok: true,
    buscados: lote.length,
    encontrados: encontrados.length,
    fotos,
    precios,
    pendientes: Math.max(0, pendientes.length - lote.length),
    falta_login: faltaLogin,
    message: [
      encontrados.length
        ? `Nadro reconoció ${encontrados.length} de ${lote.length}.`
        : (lote.length ? 'Nadro no reconoció este lote por EAN.' : 'No hay productos con EAN pendientes.'),
      fotos ? `Subí ${fotos} foto(s) al catálogo.` : '',
      precios
        ? `Escribí ${precios} precio(s) de compra.`
        : (faltaLogin
          ? 'El costo Nadro (lo que te cobran) no sale sin tu usuario. Las fotos sí.'
          : 'Nadro no soltó costo de cliente en este lote.'),
      pendientes.length > lote.length ? `Quedan ${pendientes.length - lote.length}: pulsa otra vez.` : '',
    ].filter(Boolean).join(' '),
  });
}

module.exports = { nadroSyncHandler, productosPendientes };
