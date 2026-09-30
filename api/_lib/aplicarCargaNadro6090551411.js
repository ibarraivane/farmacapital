'use strict';

/**
 * Aplica en Supabase el ticket Nadro folio 6090551411 (cola Recibir).
 * Idempotente: reabre borrador y reemplaza renglones.
 * Misma lógica que sql/patch_carga_nadro_6090551411.sql.
 */

const LINEAS = [
  {
    linea: 1,
    ean: '7501026462245',
    sku: 'FC-26462078',
    nombre: 'Chupón Ternura flor y balón con miel',
    snap: 'CHUPON TERNURA FLOR/BALON MIEL S',
    qty: 18,
    costo: 3.1,
    precio: 4,
    tipo: 'marca',
    categoria: 'Bebés',
    subcategoria: 'Chupones',
    marca: 'Ternura',
    presentacion: '1 pieza',
    forma: 'Chupón',
    laboratorio: 'M.A. Carter',
    receta: false,
    alta_nueva: false,
  },
  {
    linea: 2,
    ean: '4042809591446',
    sku: 'FC-09591446',
    nombre: 'Leukoplast Hypafix',
    snap: 'LEUKOPLAST HYPAFIX 10 CM X 2M',
    qty: 1,
    costo: 71.63,
    precio: 90,
    tipo: 'marca',
    categoria: 'Botiquín',
    subcategoria: 'Material de curación',
    marca: 'Leukoplast',
    presentacion: '10 cm x 2 m',
    forma: 'Lamina adhesiva',
    laboratorio: 'Essity',
    receta: false,
    alta_nueva: true,
  },
  {
    linea: 3,
    ean: '650240032431',
    sku: 'FC-40032431',
    nombre: 'Asepxia polvo compacto Canela',
    snap: 'MJE ASEPXIA PVO COM TONO CANELA 10G',
    qty: 1,
    costo: 126.02,
    precio: 158,
    tipo: 'marca',
    categoria: 'Cuidado personal',
    subcategoria: 'Maquillaje',
    marca: 'Asepxia',
    presentacion: '10 g',
    forma: 'Polvo compacto',
    laboratorio: 'Genomma Lab',
    receta: false,
    alta_nueva: true,
  },
  {
    linea: 4,
    ean: '650240032455',
    sku: 'FC-40032455',
    nombre: 'Asepxia BB polvo compacto Natural Mate',
    snap: 'MJE ASEPXIABBPVOCOMPNATMA 10G',
    qty: 1,
    costo: 126.02,
    precio: 158,
    tipo: 'marca',
    categoria: 'Cuidado personal',
    subcategoria: 'Maquillaje',
    marca: 'Asepxia',
    presentacion: '10 g',
    forma: 'Polvo compacto',
    laboratorio: 'Genomma Lab',
    receta: false,
    alta_nueva: true,
  },
];

const FOLIO = '6090551411';
const NOTAS =
  'Pedido Nadro 6090551411 · CFDI 28-09-26 · EAN iNadro · cola Recibir; stock al confirmar pistola · chupón/Hypafix DV corregido';

function headers(serviceKey, extra = {}) {
  return {
    apikey: serviceKey,
    Authorization: `Bearer ${serviceKey}`,
    Accept: 'application/json',
    'Content-Type': 'application/json',
    ...extra,
  };
}

async function rest(supabaseUrl, serviceKey, method, pathAndQuery, body, prefer) {
  const resp = await fetch(`${supabaseUrl}/rest/v1/${pathAndQuery}`, {
    method,
    headers: headers(serviceKey, prefer ? { Prefer: prefer } : {}),
    body: body == null ? undefined : JSON.stringify(body),
  });
  const text = await resp.text();
  let data = null;
  try {
    data = text ? JSON.parse(text) : null;
  } catch {
    data = text;
  }
  if (!resp.ok) {
    const detail = typeof data === 'object' ? JSON.stringify(data) : String(data || '');
    throw new Error(`rest_${method}_${resp.status}:${detail.slice(0, 280)}`);
  }
  return data;
}

async function buscarPid(supabaseUrl, serviceKey, codigo) {
  const data = await rest(supabaseUrl, serviceKey, 'POST', 'rpc/fc_buscar_producto_escaneo', {
    p_codigo: codigo,
  });
  if (data == null || data === '') return null;
  const n = Number(data);
  return Number.isFinite(n) && n > 0 ? n : null;
}

async function skuOcupadoOtroEan(supabaseUrl, serviceKey, sku, ean) {
  const rows = await rest(
    supabaseUrl,
    serviceKey,
    'GET',
    `productos?sku=eq.${encodeURIComponent(sku)}&select=id,codigo_barras&limit=5`
  );
  return (rows || []).some((r) => String(r.codigo_barras || '') !== ean);
}

async function asegurarProducto(supabaseUrl, serviceKey, t) {
  let pid = await buscarPid(supabaseUrl, serviceKey, t.ean);
  if (!pid && t.alta_nueva) {
    let sku = t.sku;
    if (await skuOcupadoOtroEan(supabaseUrl, serviceKey, sku, t.ean)) {
      sku = `FC-ND-${t.ean.slice(-8)}`;
    }
    const inserted = await rest(
      supabaseUrl,
      serviceKey,
      'POST',
      'productos',
      {
        nombre: t.nombre,
        sku,
        codigo_barras: t.ean,
        categoria: t.categoria,
        tipo: t.tipo,
        descripcion: 'Alta Nadro 6090551411 · 2026-09-28 · listo para pistola',
        costo: t.costo,
        precio: t.precio,
        stock: 0,
        stock_minimo: 1,
        activo: true,
        requiere_receta: t.receta,
      },
      'return=representation'
    );
    pid = Array.isArray(inserted) ? inserted[0]?.id : inserted?.id;
  }
  if (!pid) {
    pid = await buscarPid(supabaseUrl, serviceKey, t.sku);
  }
  if (!pid) throw new Error(`producto_no_resuelto:${t.ean}`);

  const actuales = await rest(
    supabaseUrl,
    serviceKey,
    'GET',
    `productos?id=eq.${pid}&select=id,costo,precio,laboratorio`
  );
  const cur = (actuales || [])[0] || {};
  const patch = {
    marca: t.marca,
    presentacion: t.presentacion,
    forma_farmaceutica: t.forma,
    subcategoria: t.subcategoria,
    nombre: t.nombre,
    categoria: t.categoria,
    tipo: t.tipo,
    requiere_receta: t.receta,
    costo: t.costo,
  };
  if (!cur.laboratorio || !String(cur.laboratorio).trim()) {
    patch.laboratorio = t.laboratorio;
  }
  if (!(Number(cur.precio) > 0)) {
    patch.precio = t.precio;
  }
  await rest(supabaseUrl, serviceKey, 'PATCH', `productos?id=eq.${pid}`, patch, 'return=minimal');
  return Number(pid);
}

async function lotesActivos(supabaseUrl, serviceKey, productoId) {
  const rows = await rest(
    supabaseUrl,
    serviceKey,
    'GET',
    `lotes?producto_id=eq.${productoId}&activo=eq.true&cantidad_actual=gt.0&select=id&limit=1`
  );
  return Array.isArray(rows) && rows.length > 0;
}

async function asegurarRecepcion(supabaseUrl, serviceKey) {
  const existing = await rest(
    supabaseUrl,
    serviceKey,
    'GET',
    `recepciones?folio=eq.${FOLIO}&proveedor=ilike.*nadro*&select=id,estado&limit=5`
  );
  let id = Array.isArray(existing) && existing[0] ? Number(existing[0].id) : null;
  if (!id) {
    const inserted = await rest(
      supabaseUrl,
      serviceKey,
      'POST',
      'recepciones',
      {
        proveedor: 'Nadro',
        folio: FOLIO,
        fecha: '2026-09-28',
        total_ticket: 440.18,
        estado: 'borrador',
        notas: NOTAS,
      },
      'return=representation'
    );
    id = Array.isArray(inserted) ? Number(inserted[0]?.id) : Number(inserted?.id);
  }
  if (!id) throw new Error('recepcion_sin_id');

  await rest(
    supabaseUrl,
    serviceKey,
    'PATCH',
    `recepciones?id=eq.${id}`,
    {
      estado: 'borrador',
      cerrado_en: null,
      total_ticket: 440.18,
      fecha: '2026-09-28',
      proveedor: 'Nadro',
      notas: NOTAS,
      updated_at: new Date().toISOString(),
    },
    'return=minimal'
  );

  await rest(
    supabaseUrl,
    serviceKey,
    'DELETE',
    `recepcion_items?recepcion_id=eq.${id}`,
    null,
    'return=minimal'
  );

  return id;
}

async function aplicarCargaNadro6090551411({ supabaseUrl, serviceKey }) {
  if (!supabaseUrl || !serviceKey) {
    throw new Error('supabase_not_configured');
  }

  const pids = [];
  for (const t of LINEAS) {
    pids.push({ t, pid: await asegurarProducto(supabaseUrl, serviceKey, t) });
  }

  const recepcionId = await asegurarRecepcion(supabaseUrl, serviceKey);

  const items = [];
  for (const { t, pid } of pids) {
    const loteDistinto = await lotesActivos(supabaseUrl, serviceKey, pid);
    items.push({
      recepcion_id: recepcionId,
      producto_id: pid,
      codigo_escaneado: t.ean,
      nombre_snapshot: t.snap,
      cantidad: t.qty,
      fecha_caducidad: null,
      numero_lote: null,
      costo_estimado: t.costo,
      pendiente_alta: false,
      origen: 'pdf',
      confirmado: false,
      lote_distinto: loteDistinto,
      lote_id: null,
    });
  }

  const insertedItems = await rest(
    supabaseUrl,
    serviceKey,
    'POST',
    'recepcion_items',
    items,
    'return=representation'
  );

  if (!Array.isArray(insertedItems) || insertedItems.length !== 4) {
    throw new Error(`items_esperados_4_obtuve_${Array.isArray(insertedItems) ? insertedItems.length : 0}`);
  }

  return {
    ok: true,
    folio: FOLIO,
    recepcion_id: recepcionId,
    renglones: insertedItems.map((i) => ({
      id: i.id,
      ean: i.codigo_escaneado,
      cantidad: i.cantidad,
      costo_estimado: i.costo_estimado,
      producto_id: i.producto_id,
    })),
  };
}

module.exports = { aplicarCargaNadro6090551411, LINEAS, FOLIO };
