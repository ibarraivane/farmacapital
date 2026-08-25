"use strict";

const {
  CADUCIDAD_CONFIG,
} = require("../../config/caducidad");
const {
  planificarPropuestas,
  debeAdelantarFase,
  textoEtiquetaPrecioEspecial,
  money2,
} = require("../../src/lib/descuentoCaducidad");
const { rpc } = require("./supabaseAdmin");

const TZ = "America/Mexico_City";

function hoyMexico() {
  return new Date().toLocaleDateString("en-CA", { timeZone: TZ });
}

function isoHaceDias(dias) {
  const d = new Date();
  d.setUTCDate(d.getUTCDate() - dias);
  return d.toISOString();
}

async function restGetAll(supabaseUrl, serviceKey, path) {
  const out = [];
  let from = 0;
  for (;;) {
    const to = from + 999;
    const resp = await fetch(`${supabaseUrl}/rest/v1/${path}`, {
      headers: {
        apikey: serviceKey,
        Authorization: `Bearer ${serviceKey}`,
        Range: `${from}-${to}`,
        Prefer: "count=exact",
      },
    });
    const data = await resp.json().catch(() => null);
    if (!resp.ok) {
      const detail = typeof data === "object" ? JSON.stringify(data) : String(data || "");
      throw new Error(`rest_get_failed:${resp.status}:${detail.slice(0, 220)}`);
    }
    if (!Array.isArray(data) || data.length === 0) break;
    out.push(...data);
    if (data.length < 1000) break;
    from += 1000;
  }
  return out;
}

async function restInsert(supabaseUrl, serviceKey, table, rows) {
  if (!rows.length) return { inserted: 0 };
  const resp = await fetch(`${supabaseUrl}/rest/v1/${table}`, {
    method: "POST",
    headers: {
      apikey: serviceKey,
      Authorization: `Bearer ${serviceKey}`,
      "Content-Type": "application/json",
      Prefer: "return=minimal",
    },
    body: JSON.stringify(rows),
  });
  if (resp.status === 409) return { inserted: 0, conflict: true };
  if (!resp.ok) {
    const data = await resp.json().catch(() => null);
    const detail = typeof data === "object" ? JSON.stringify(data) : String(data || "");
    throw new Error(`rest_insert_failed:${resp.status}:${detail.slice(0, 220)}`);
  }
  return { inserted: rows.length };
}

function filaDesdeDecision(lote, decision, hoy) {
  const prod = lote.productos || {};
  const pvp = Number(prod.precio ?? lote.pvp ?? lote.precio);
  const etiqueta = decision.propuesta
    ? textoEtiquetaPrecioEspecial({
        descripcion: prod.nombre || lote.nombre,
        pvp,
        precio_propuesto: decision.precio_propuesto,
        descuento_efectivo: decision.descuento_efectivo,
        fecha_caducidad: lote.fecha_caducidad,
      })
    : null;
  return {
    lote_id: lote.id,
    producto_id: lote.producto_id,
    fecha_job: hoy,
    fase: decision.fase ?? null,
    estado: decision.propuesta ? "PENDIENTE" : decision.estado,
    motivo: decision.motivo || decision.motivo_exclusion || null,
    fecha_caducidad: lote.fecha_caducidad,
    dias_restantes: decision.dias_restantes ?? null,
    existencia: Number(lote.cantidad_actual) || 0,
    costo_unitario: lote.costo_unitario,
    pvp,
    precio_propuesto: decision.precio_propuesto ?? null,
    precio_piso: decision.precio_piso ?? null,
    descuento_escalon: decision.descuento_escalon ?? null,
    descuento_efectivo: decision.descuento_efectivo ?? null,
    margen_resultante: decision.margen_resultante ?? null,
    perdida_pieza: decision.perdida_pieza ?? null,
    capital_en_riesgo: decision.capital_en_riesgo ?? money2((lote.cantidad_actual || 0) * (Number(lote.costo_unitario) || 0)),
    capital_recuperable: decision.capital_recuperable ?? null,
    vigencia_hasta: decision.vigencia_hasta ?? null,
    texto_etiqueta: etiqueta,
    numero_lote: lote.numero_lote,
    nombre: prod.nombre || lote.nombre || null,
    sku: prod.sku || lote.sku || null,
  };
}

async function runCaducidadJob({ supabaseUrl, serviceKey }) {
  const hoy = hoyMexico();
  let vencidas = 0;
  try {
    vencidas = await rpc(serviceKey, supabaseUrl, "job_vencer_propuestas_caducidad", {});
  } catch {
    vencidas = 0;
  }

  let rotacionPorProducto = {};
  try {
    const rot = await rpc(serviceKey, supabaseUrl, "job_rotacion_mensual_caducidad", {});
    if (rot && typeof rot === "object") rotacionPorProducto = rot;
  } catch {
    rotacionPorProducto = {};
  }

  const lotesRaw = await restGetAll(
    supabaseUrl,
    serviceKey,
    "lotes?select=id,producto_id,numero_lote,fecha_caducidad,cantidad_actual,costo_unitario,activo,productos!inner(id,sku,nombre,precio,activo)&activo=eq.true&fecha_caducidad=not.is.null&cantidad_actual=gt.0&productos.activo=eq.true"
  );

  const lotes = lotesRaw.map((l) => ({
    ...l,
    pvp: l.productos && l.productos.precio,
    canje_elegible: false,
    controlado: false,
    refrigerado: false,
  }));

  const existentes = await restGetAll(
    supabaseUrl,
    serviceKey,
    "propuestas_descuento_caducidad?select=id,lote_id,producto_id,estado,fase,fecha_job,vigencia_desde,existencia_al_aplicar,updated_at,created_at&estado=in.(PENDIENTE,APROBADA,RECHAZADA)"
  );

  const pendientes = existentes.filter((e) => e.estado === "PENDIENTE");
  const rechazadas = existentes.filter((e) => e.estado === "RECHAZADA");
  const aprobadas = existentes.filter((e) => e.estado === "APROBADA");

  const desde = isoHaceDias(CADUCIDAD_CONFIG.DIAS_EVALUACION + 5);
  let ventasRecientes = [];
  try {
    ventasRecientes = await restGetAll(
      supabaseUrl,
      serviceKey,
      `pedido_items?select=lote_id,cantidad,pedidos!inner(created_at,estado)&lote_id=not.is.null&pedidos.estado=eq.completado&pedidos.created_at=gte.${encodeURIComponent(desde)}`
    );
  } catch {
    ventasRecientes = [];
  }

  const lotesById = Object.fromEntries(lotes.map((l) => [String(l.id), l]));
  for (const ap of aprobadas) {
    const lote = lotesById[String(ap.lote_id)];
    if (!lote) continue;
    const desdeVig = ap.vigencia_desde || String(ap.created_at || "").slice(0, 10);
    const diasAplicada = Math.max(
      0,
      Math.round((new Date(`${hoy}T12:00:00`) - new Date(`${desdeVig}T12:00:00`)) / 86400000)
    );
    const vendidas = ventasRecientes
      .filter((v) => String(v.lote_id) === String(ap.lote_id) && String((v.pedidos && v.pedidos.created_at) || "").slice(0, 10) >= String(desdeVig).slice(0, 10))
      .reduce((s, v) => s + (Number(v.cantidad) || 0), 0);
    if (
      debeAdelantarFase({
        dias_aplicada: diasAplicada,
        piezas_vendidas_desde_aplicacion: vendidas,
        existencia_al_aplicar: ap.existencia_al_aplicar,
      })
    ) {
      const next = Math.min(5, (Number(ap.fase) || 1) + 1);
      lote.forzar_fase = next;
      lote.motivo = "SELLTHROUGH_INSUFICIENTE";
    }
  }

  const lotesEval = lotes.filter(
    (l) => l.forzar_fase || !aprobadas.some((a) => String(a.lote_id) === String(l.id))
  );

  const { inserts, alertas } = planificarPropuestas({
    hoy,
    lotes: lotesEval,
    rotacionPorProducto,
    existentes: pendientes.concat(aprobadas),
    rechazadas,
  });

  const filasPend = inserts.map((d) => {
    const lote = lotesById[String(d.lote_id)] || { id: d.lote_id, producto_id: d.producto_id };
    return filaDesdeDecision(lote, d, hoy);
  });
  const filasAlerta = alertas.map((d) => {
    const lote = lotesById[String(d.lote_id)] || { id: d.lote_id, producto_id: d.producto_id };
    return filaDesdeDecision(lote, d, hoy);
  });

  let inserted = 0;
  let alertasIns = 0;
  try {
    const r = await restInsert(supabaseUrl, serviceKey, "propuestas_descuento_caducidad", filasPend);
    inserted = r.inserted || 0;
  } catch (err) {
    if (!String(err.message || "").includes("23505") && !String(err.message || "").includes("409")) {
      throw err;
    }
  }
  if (filasAlerta.length) {
    try {
      const r = await restInsert(supabaseUrl, serviceKey, "propuestas_descuento_caducidad", filasAlerta);
      alertasIns = r.inserted || 0;
    } catch {
      alertasIns = 0;
    }
  }

  return {
    ok: true,
    fecha_job: hoy,
    lotes: lotes.length,
    propuestas_nuevas: inserted,
    alertas: alertasIns,
    vencidas,
    omitidas_pendiente: inserts.length - inserted,
  };
}

module.exports = { runCaducidadJob, hoyMexico };
