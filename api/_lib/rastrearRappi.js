'use strict';

const {
  extraerOfertasRappi,
  fetchHtmlRappi,
  matchOfertaRappi,
  consultasBusquedaRappi,
  terminoBusquedaRappi,
  terminoCortoRappi,
} = require('../../src/lib/monitorPrecios/fuentes/rappi');
const { diagnosticoRefRappi } = require('../../src/lib/monitorPrecios/unidadVenta');

const FUENTES = [
  { id: 'rappi_gdl', nombre: 'Rappi · Guadalajara', tipo: 'venta', metodo: 'job_api' },
  { id: 'rappi_farmatodo', nombre: 'Rappi · Farmatodo', tipo: 'venta', metodo: 'job_api' },
  { id: 'rappi_benavides', nombre: 'Rappi · Benavides', tipo: 'venta', metodo: 'job_api' },
  { id: 'rappi_otros', nombre: 'Rappi · otras farmacias', tipo: 'venta', metodo: 'job_api' },
  { id: 'rappi_super', nombre: 'Rappi · súper', tipo: 'venta', metodo: 'job_api' },
];

const FUENTES_IDS = FUENTES.map((f) => f.id);
const DIAS_STALE = 7;
const RAPPI_SKU_PREFIX = 'farmacapitalmt_';
let partnerCatalogo = null;
try {
  partnerCatalogo = require('../../src/data/rappiPartnerActual.json');
} catch {
  partnerCatalogo = { productos: [] };
}

function skuInternoDesdeRappi(value) {
  let s = String(value || '').trim().toLowerCase();
  if (s.startsWith(RAPPI_SKU_PREFIX)) s = s.slice(RAPPI_SKU_PREFIX.length);
  return s;
}

function eanClaves(value) {
  const d = String(value || '').replace(/\D/g, '');
  if (d.length < 8) return [];
  const trimmed = d.replace(/^0+/, '') || '0';
  return [...new Set([d, trimmed, d.padStart(13, '0')])];
}

function idsPartnerEnProductos(productos, catalogo = partnerCatalogo) {
  const bySku = new Set();
  const byEan = new Set();
  for (const row of catalogo?.productos || []) {
    const sku = skuInternoDesdeRappi(row.sku);
    if (sku) bySku.add(sku);
    for (const e of eanClaves(row.ean)) byEan.add(e);
  }
  const ids = new Set();
  for (const p of productos || []) {
    const sku = skuInternoDesdeRappi(p.sku);
    if (sku && bySku.has(sku)) {
      ids.add(p.id);
      continue;
    }
    if (eanClaves(p.codigo_barras).some((e) => byEan.has(e))) ids.add(p.id);
  }
  return ids;
}
const CLAVE_PROGRESO = 'rappi_precios_backfill';
const HOY = () => new Date().toISOString().slice(0, 10);

function headersDe(serviceKey) {
  return {
    apikey: serviceKey,
    Authorization: `Bearer ${serviceKey}`,
    'Content-Type': 'application/json',
    Prefer: 'return=representation',
  };
}

function esStale(fecha, ahora, dias) {
  if (!fecha) return true;
  const t = new Date(fecha).getTime();
  if (!Number.isFinite(t)) return true;
  return ahora.getTime() - t > (dias || DIAS_STALE) * 86400000;
}

async function restGetAll(supabaseUrl, headers, path) {
  const out = [];
  let from = 0;
  for (;;) {
    const to = from + 999;
    const resp = await fetch(`${supabaseUrl}/rest/v1/${path}`, {
      headers: { ...headers, Range: `${from}-${to}`, Prefer: 'count=exact' },
    });
    const data = await resp.json().catch(() => null);
    if (!resp.ok) {
      const detail = typeof data === 'object' ? JSON.stringify(data) : String(data || '');
      throw new Error(`rest_get_failed:${resp.status}:${detail.slice(0, 220)}`);
    }
    if (!Array.isArray(data) || data.length === 0) break;
    out.push(...data);
    if (data.length < 1000) break;
    from += 1000;
  }
  return out;
}

async function ensureFuentes(supabaseUrl, headers) {
  await fetch(`${supabaseUrl}/rest/v1/fuentes_precio`, {
    method: 'POST',
    headers: { ...headers, Prefer: 'resolution=merge-duplicates,return=minimal' },
    body: JSON.stringify(FUENTES),
  }).catch(() => {});
}

function filasDesdeOfertas(producto, ofertas) {
  const porFuente = {};
  const porTienda = new Map();
  for (const ofe of ofertas || []) {
    const tienda = ofe.tienda || ofe.fuente;
    if (!porTienda.has(tienda)) porTienda.set(tienda, []);
    porTienda.get(tienda).push(ofe);
  }

  for (const group of porTienda.values()) {
    const hit = matchOfertaRappi(producto, group);
    if (!hit) continue;
    const fuente = hit.fuente;
    const prev = porFuente[fuente];
    if (!prev || hit.precio < prev.precio) {
      porFuente[fuente] = {
        producto_id: producto.id,
        fuente,
        tipo: 'venta',
        precio: Math.round(Number(hit.precio) * 100) / 100,
        fecha: HOY(),
        origen: 'manual',
        confianza: Math.round((hit.confianza || 0.7) * 100),
        nombre_fuente: hit.nombre || hit.tienda || null,
        notas: 'rastreo_automatico',
      };
    }
  }
  return Object.values(porFuente);
}

function seleccionarCandidatos(productos, opts) {
  const ahora = opts.ahora || new Date();
  const linked = opts.linked || new Set();
  const ultima = opts.ultima || {};
  const soloLinked = opts.soloLinked !== false;
  const soloPartner = opts.soloPartner === true;
  const partnerIds = opts.partnerIds || new Set();
  const diasStale = opts.diasStale || DIAS_STALE;
  const forzarIds = opts.forzarIds || new Set();

  return (productos || [])
    .filter((p) => terminoBusquedaRappi(p).length >= 4 || consultasBusquedaRappi(p).length)
    .filter((p) => {
      if (soloPartner) return partnerIds.has(p.id);
      if (soloLinked) return linked.has(p.id) || partnerIds.has(p.id);
      return true;
    })
    .filter((p) => forzarIds.has(p.id) || esStale(ultima[p.id], ahora, diasStale))
    .sort((a, b) => {
      const pa = partnerIds.has(a.id) ? 2 : 0;
      const pb = partnerIds.has(b.id) ? 2 : 0;
      const la = linked.has(a.id) ? 1 : 0;
      const lb = linked.has(b.id) ? 1 : 0;
      return (pb + lb) - (pa + la) || a.id - b.id;
    });
}

async function rastrearUno(producto, fetchImpl, timeoutMs, opts) {
  const consultas = opts && opts.corto
    ? [terminoCortoRappi(producto)]
    : consultasBusquedaRappi(producto);
  let last = { filas: [], error: 'sin_html', term: consultas[0] || terminoBusquedaRappi(producto) };
  for (const term of consultas) {
    const html = await fetchHtmlRappi(fetchImpl || fetch, term, timeoutMs || 4000);
    if (!html) {
      last = { filas: [], error: 'sin_html', term };
      continue;
    }
    const ofertas = extraerOfertasRappi(html);
    const filas = filasDesdeOfertas(producto, ofertas);
    if (filas.length) return { filas, term, ofertas: ofertas.length };
    last = { filas: [], error: 'sin_match', term, ofertas: ofertas.length };
  }
  return last;
}

async function escribirProgreso(supabaseUrl, headers, payload) {
  await fetch(`${supabaseUrl}/rest/v1/configuracion?on_conflict=clave`, {
    method: 'POST',
    headers: { ...headers, Prefer: 'resolution=merge-duplicates,return=minimal' },
    body: JSON.stringify({
      clave: CLAVE_PROGRESO,
      valor: JSON.stringify(payload),
    }),
  }).catch(() => {});
}

function snapshotProgreso(base, extra) {
  const done = extra.done || 0;
  const total = extra.total || 0;
  return {
    running: extra.running !== false,
    done,
    total,
    pct: total > 0 ? Math.round((done / total) * 1000) / 10 : 0,
    actualizados: extra.actualizados || 0,
    filas: extra.filas || 0,
    errores: extra.errores || 0,
    sku: extra.sku || '',
    nombre: extra.nombre || '',
    ultimo: extra.ultimo || '',
    started_at: base.started_at,
    updated_at: new Date().toISOString(),
    finished_at: extra.finished_at || null,
  };
}

async function persistirFilas(supabaseUrl, headers, filas) {
  if (!filas.length) return 0;
  const ins = await fetch(`${supabaseUrl}/rest/v1/producto_precios_referencia`, {
    method: 'POST',
    headers,
    body: JSON.stringify(filas),
  });
  if (!ins.ok) {
    const detail = await ins.text().catch(() => '');
    throw new Error(`insert_failed:${detail.slice(0, 240)}`);
  }
  return filas.length;
}

async function borrarRefsRappiProducto(supabaseUrl, headers, productoId) {
  const id = Number(productoId);
  if (!Number.isFinite(id)) return;
  const src = FUENTES_IDS.join(',');
  await fetch(
    `${supabaseUrl}/rest/v1/producto_precios_referencia?producto_id=eq.${id}&fuente=in.(${src})&notas=eq.rastreo_automatico`,
    { method: 'DELETE', headers: { ...headers, Prefer: 'return=minimal' } },
  ).catch(() => {});
}

async function reemplazarRefsRappiProducto(supabaseUrl, headers, productoId, filas) {
  await borrarRefsRappiProducto(supabaseUrl, headers, productoId);
  if (filas && filas.length) await persistirFilas(supabaseUrl, headers, filas);
  return (filas && filas.length) || 0;
}

async function cargarContextoRappi(supabaseUrl, serviceKey) {
  const headers = headersDe(serviceKey);
  await ensureFuentes(supabaseUrl, headers);
  const [productos, refs, imgs] = await Promise.all([
    restGetAll(
      supabaseUrl,
      headers,
      'productos?select=id,sku,nombre,principio_activo,presentacion,marca,codigo_barras,tipo,concentracion,forma_farmaceutica,precio,activo&activo=eq.true&order=nombre.asc'
    ),
    restGetAll(
      supabaseUrl,
      headers,
      `producto_precios_referencia_actual?select=producto_id,fuente,fecha,precio,nombre_fuente,notas&fuente=in.(${FUENTES_IDS.join(',')})`
    ),
    restGetAll(
      supabaseUrl,
      headers,
      'catalogo_imagenes_rappi?select=producto_id,nombre_rappi,ean&producto_id=not.is.null'
    ),
  ]);

  const nombreRappi = {};
  const linked = new Set();
  for (const row of imgs || []) {
    if (!row.producto_id) continue;
    linked.add(row.producto_id);
    if (row.nombre_rappi && !nombreRappi[row.producto_id]) {
      nombreRappi[row.producto_id] = row.nombre_rappi;
    }
  }

  const ultima = {};
  for (const row of refs || []) {
    const prev = ultima[row.producto_id];
    if (!prev || String(row.fecha || '') > String(prev || '')) ultima[row.producto_id] = row.fecha;
  }

  const partnerIds = idsPartnerEnProductos(productos, partnerCatalogo);
  for (const id of partnerIds) linked.add(id);

  const partnerRow = partnerRowPorProducto(productos, partnerCatalogo);
  const enriquecidos = (productos || []).map((p) => {
    const row = partnerRow.get(p.id);
    return {
      ...p,
      nombre_rappi: nombreRappi[p.id] || (row && row.nombre) || '',
      nombre_partner: (row && row.nombre) || '',
      ean: (row && row.ean) || p.codigo_barras,
    };
  });

  const incomparables = idsConRefsIncomparables(enriquecidos, refs);

  return { headers, productos: enriquecidos, linked, ultima, partnerIds, incomparables };
}

function partnerRowPorProducto(productos, catalogo = partnerCatalogo) {
  const bySku = new Map();
  const byEan = new Map();
  for (const row of catalogo?.productos || []) {
    const sku = skuInternoDesdeRappi(row.sku);
    if (sku) bySku.set(sku, row);
    for (const e of eanClaves(row.ean)) byEan.set(e, row);
  }
  const out = new Map();
  for (const p of productos || []) {
    const sku = skuInternoDesdeRappi(p.sku);
    const row = (sku && bySku.get(sku))
      || eanClaves(p.codigo_barras).map((e) => byEan.get(e)).find(Boolean);
    if (row) out.set(p.id, row);
  }
  return out;
}

function idsConRefsIncomparables(productos, refs) {
  const byProd = new Map();
  for (const row of refs || []) {
    if (!byProd.has(row.producto_id)) byProd.set(row.producto_id, []);
    byProd.get(row.producto_id).push(row);
  }
  const bad = new Set();
  for (const p of productos || []) {
    const rows = byProd.get(p.id) || [];
    if (!rows.length) continue;
    const anyOk = rows.some((row) => diagnosticoRefRappi(p, row).ok);
    if (!anyOk) bad.add(p.id);
  }
  return bad;
}

async function mapPool(items, concurrency, worker) {
  const out = [];
  let i = 0;
  async function run() {
    while (i < items.length) {
      const idx = i;
      i += 1;
      out[idx] = await worker(items[idx], idx);
    }
  }
  const n = Math.max(1, Math.min(concurrency || 1, items.length || 1));
  await Promise.all(Array.from({ length: n }, () => run()));
  return out;
}

async function runRastreoRappi(input) {
  const supabaseUrl = input.supabaseUrl;
  const serviceKey = input.serviceKey;
  const max = Number(input.max) > 0 ? Number(input.max) : 3;
  const concurrency = Number(input.concurrency) > 0 ? Number(input.concurrency) : 1;
  const timeoutMs = input.timeoutMs || 4000;
  const onProgress = typeof input.onProgress === 'function' ? input.onProgress : null;
  const dryRun = input.dryRun === true;

  const ctx = await cargarContextoRappi(supabaseUrl, serviceKey);
  let candidatos = seleccionarCandidatos(ctx.productos, {
    linked: ctx.linked,
    ultima: ctx.ultima,
    partnerIds: ctx.partnerIds,
    forzarIds: ctx.incomparables,
    soloLinked: input.soloLinked !== false,
    soloPartner: input.soloPartner === true && ctx.partnerIds && ctx.partnerIds.size > 0,
    diasStale: input.diasStale || DIAS_STALE,
  });
  if (Array.isArray(input.ids) && input.ids.length) {
    const want = new Set(input.ids.map(Number));
    candidatos = ctx.productos.filter((p) => want.has(Number(p.id)));
  }
  const lote = candidatos.slice(0, max);
  const filas = [];
  const errores = [];
  const startedAt = new Date().toISOString();
  const stats = { actualizados: 0, filas: 0, errores: 0, done: 0 };

  await escribirProgreso(supabaseUrl, ctx.headers, snapshotProgreso(
    { started_at: startedAt },
    { running: true, done: 0, total: lote.length }
  ));

  await mapPool(lote, concurrency, async (p, idx) => {
    const r = await rastrearUno(p, input.fetchImpl || fetch, timeoutMs, { corto: input.corto === true });
    if (r.error) {
      errores.push({ sku: p.sku, id: p.id, error: r.error, term: r.term });
      stats.errores += 1;
    } else {
      filas.push(...r.filas);
      stats.actualizados += 1;
      stats.filas += r.filas.length;
      if (!dryRun && r.filas.length) {
        await reemplazarRefsRappiProducto(supabaseUrl, ctx.headers, p.id, r.filas);
      }
    }
    stats.done += 1;
    const snap = snapshotProgreso(
      { started_at: startedAt },
      {
        running: true,
        done: stats.done,
        total: lote.length,
        actualizados: stats.actualizados,
        filas: stats.filas,
        errores: stats.errores,
        sku: p.sku,
        nombre: p.nombre,
        ultimo: r.error || `${r.filas.length} precio${r.filas.length === 1 ? '' : 's'}`,
      }
    );
    await escribirProgreso(supabaseUrl, ctx.headers, snap);
    if (onProgress) onProgress({ idx, total: lote.length, producto: p, ...r, progreso: snap });
    return { p, r };
  });

  await escribirProgreso(supabaseUrl, ctx.headers, snapshotProgreso(
    { started_at: startedAt },
    {
      running: false,
      done: lote.length,
      total: lote.length,
      actualizados: stats.actualizados,
      filas: stats.filas,
      errores: stats.errores,
      finished_at: new Date().toISOString(),
      ultimo: 'terminado',
    }
  ));

  return {
    buscados: lote.length,
    pendientes: Math.max(0, candidatos.length - lote.length),
    actualizados: stats.actualizados,
    filas: stats.filas,
    errores,
    dryRun,
  };
}

module.exports = {
  FUENTES,
  DIAS_STALE,
  filasDesdeOfertas,
  seleccionarCandidatos,
  idsPartnerEnProductos,
  idsConRefsIncomparables,
  rastrearUno,
  persistirFilas,
  reemplazarRefsRappiProducto,
  cargarContextoRappi,
  runRastreoRappi,
  escribirProgreso,
  CLAVE_PROGRESO,
  headersDe,
  ensureFuentes,
};
