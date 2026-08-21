'use strict';

const {
  getSupabaseAdminConfig,
  validateEmployeeSession,
} = require('./supabaseAdmin');

const ESTADOS_VIVOS = ['borrador', 'pendiente_alta', 'pendiente_caducidad'];

async function restGet(supabaseUrl, serviceKey, pathAndQuery) {
  const resp = await fetch(`${supabaseUrl}/rest/v1/${pathAndQuery}`, {
    headers: {
      apikey: serviceKey,
      Authorization: `Bearer ${serviceKey}`,
      Accept: 'application/json',
    },
  });
  const data = await resp.json().catch(() => null);
  if (!resp.ok) {
    const detail = typeof data === 'object' ? JSON.stringify(data) : String(data || '');
    throw new Error(`rest_failed:${resp.status}:${detail.slice(0, 220)}`);
  }
  return Array.isArray(data) ? data : [];
}

function esPedidoVivo(t) {
  const renglones = Number(t.renglones || 0);
  const falta = Number(t.sin_confirmar || 0) + Number(t.sin_caducidad_anaquel || 0);
  return renglones > 0 && (falta > 0 || t.estado === 'borrador' || t.estado === 'pendiente_caducidad');
}

function agruparTickets(recepciones, items) {
  const byRec = new Map();
  for (const it of items || []) {
    const id = Number(it.recepcion_id);
    if (!byRec.has(id)) byRec.set(id, []);
    byRec.get(id).push(it);
  }
  const tickets = [];
  for (const r of recepciones || []) {
    const lista = byRec.get(Number(r.id)) || [];
    const renglones = lista.length;
    const piezas = lista.reduce((s, i) => s + (Number(i.cantidad) || 0), 0);
    const sin_confirmar = lista.filter((i) => !i.confirmado).length;
    const sin_caducidad_anaquel = lista.filter((i) => i.lote_id && !i.fecha_caducidad).length;
    const pendientes_alta = lista.filter((i) => i.pendiente_alta).length;
    const codigos = [...new Set(lista.map((i) => i.codigo_escaneado).filter(Boolean))];
    const t = {
      id: r.id,
      proveedor: r.proveedor,
      folio: r.folio,
      fecha: r.fecha,
      total_ticket: r.total_ticket,
      estado: r.estado,
      updated_at: r.updated_at,
      renglones,
      piezas,
      sin_confirmar,
      sin_caducidad_anaquel,
      pendientes_alta,
      codigos,
    };
    if (esPedidoVivo(t)) tickets.push(t);
  }
  return tickets;
}

async function cargarRecepcion(supabaseUrl, serviceKey, recepcionId) {
  const recs = await restGet(
    supabaseUrl,
    serviceKey,
    `recepciones?id=eq.${encodeURIComponent(recepcionId)}&select=*`,
  );
  const rec = recs[0];
  if (!rec) return null;
  if (!ESTADOS_VIVOS.includes(rec.estado)) return null;

  const items = await restGet(
    supabaseUrl,
    serviceKey,
    `recepcion_items?recepcion_id=eq.${encodeURIComponent(recepcionId)}&select=id,recepcion_id,producto_id,codigo_escaneado,nombre_snapshot,cantidad,fecha_caducidad,numero_lote,pendiente_alta,confirmado,origen,lote_distinto,lote_id,costo_estimado&order=id.asc`,
  );
  const pids = [...new Set(items.map((i) => i.producto_id).filter(Boolean))];
  let productos = [];
  if (pids.length) {
    productos = await restGet(
      supabaseUrl,
      serviceKey,
      `productos?id=in.(${pids.join(',')})&select=id,nombre,sku`,
    );
  }
  const prodById = new Map(productos.map((p) => [Number(p.id), p]));

  const mapped = items.map((i) => {
    const pr = prodById.get(Number(i.producto_id));
    return {
      id: i.id,
      producto_id: i.producto_id,
      codigo_escaneado: i.codigo_escaneado,
      nombre: pr?.nombre || i.nombre_snapshot || i.codigo_escaneado,
      sku: pr?.sku || null,
      cantidad: i.cantidad,
      fecha_caducidad: i.fecha_caducidad,
      numero_lote: i.numero_lote,
      pendiente_alta: !!i.pendiente_alta,
      confirmado: !!i.confirmado,
      origen: i.origen,
      lote_distinto: !!i.lote_distinto,
      lote_id: i.lote_id,
      lotes_piso: [],
    };
  });

  const subtotal = items.reduce(
    (s, i) => s + (Number(i.cantidad) || 0) * (Number(i.costo_estimado) || 0),
    0,
  );
  const sin_confirmar = mapped.filter((i) => !i.confirmado).length;
  const sin_cad = mapped.filter((i) => i.lote_id && !i.fecha_caducidad).length;

  return {
    id: rec.id,
    proveedor: rec.proveedor,
    folio: rec.folio,
    fecha: rec.fecha,
    total_ticket: rec.total_ticket,
    estado: rec.estado,
    capturado_por: rec.capturado_por,
    subtotal_estimado: Math.round(subtotal * 100) / 100,
    renglones: mapped.length,
    piezas: mapped.reduce((s, i) => s + (Number(i.cantidad) || 0), 0),
    pendientes_alta: mapped.filter((i) => i.pendiente_alta).length,
    sin_confirmar,
    sin_caducidad_anaquel: sin_cad,
    updated_at: rec.updated_at,
    cerrado_en: rec.cerrado_en,
    items: mapped,
  };
}

async function recepcionAbiertasHandler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }
  const { supabaseUrl, serviceKey } = getSupabaseAdminConfig();
  if (!supabaseUrl || !serviceKey) {
    return res.status(500).json({ error: 'Supabase no configurado en el servidor' });
  }

  let body = {};
  try {
    if (req.body && typeof req.body === 'object') body = req.body;
    else if (typeof req.body === 'string') body = JSON.parse(req.body || '{}');
  } catch {
    body = {};
  }

  const sessionToken = String(body.session_token || '').trim();
  const sessionOk = await validateEmployeeSession(supabaseUrl, serviceKey, sessionToken);
  if (!sessionOk) {
    return res.status(401).json({ error: 'Sesión no válida o expirada' });
  }

  const recepcionId = body.recepcion_id != null && body.recepcion_id !== ''
    ? Number(body.recepcion_id)
    : null;

  try {
    if (recepcionId && Number.isFinite(recepcionId)) {
      const recepcion = await cargarRecepcion(supabaseUrl, serviceKey, recepcionId);
      if (!recepcion) return res.status(404).json({ error: 'Ese pedido ya no está vivo' });
      return res.status(200).json({ ok: true, recepcion });
    }

    const recepciones = await restGet(
      supabaseUrl,
      serviceKey,
      `recepciones?estado=in.(${ESTADOS_VIVOS.join(',')})&select=id,proveedor,folio,fecha,total_ticket,estado,updated_at&order=updated_at.desc`,
    );
    const ids = recepciones.map((r) => r.id).filter(Boolean);
    const items = ids.length
      ? await restGet(
        supabaseUrl,
        serviceKey,
        `recepcion_items?recepcion_id=in.(${ids.join(',')})&select=id,recepcion_id,codigo_escaneado,cantidad,confirmado,fecha_caducidad,lote_id,pendiente_alta`,
      )
      : [];
    const tickets = agruparTickets(recepciones, items);
    return res.status(200).json({ ok: true, tickets });
  } catch (err) {
    return res.status(500).json({ error: err.message || 'No se listaron los pedidos vivos' });
  }
}

module.exports = { recepcionAbiertasHandler, esPedidoVivo };
