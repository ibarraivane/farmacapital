/**
 * Persistencia del monitor de precios. El pipeline puro vive en src/lib/monitorPrecios.
 */
"use strict";

const { MONITOR_PRECIOS_CONFIG } = require("../../src/lib/monitorPrecios/config");
const { correrPipeline } = require("../../src/lib/monitorPrecios/pipeline");
const { rastrearReferencias } = require("../../src/lib/monitorPrecios/rastrearReferencias");
const { crearAdaptadorDistribuidor } = require("../../src/lib/monitorPrecios/fuentes/distribuidor");
const { crearAdaptadorProfecoQqp } = require("../../src/lib/monitorPrecios/fuentes/profecoQqp");
const { crearAdaptadorDatosGobPatente } = require("../../src/lib/monitorPrecios/fuentes/datosGobPatente");
const { crearLlamarModelo } = require("./monitorPreciosModelo");

const TZ = "America/Mexico_City";

function hoyMexico() {
  return new Date().toLocaleDateString("en-CA", { timeZone: TZ });
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

async function restPost(supabaseUrl, serviceKey, table, rows, prefer = "return=minimal") {
  if (!rows.length) return { inserted: 0 };
  const resp = await fetch(`${supabaseUrl}/rest/v1/${table}`, {
    method: "POST",
    headers: {
      apikey: serviceKey,
      Authorization: `Bearer ${serviceKey}`,
      "Content-Type": "application/json",
      Prefer: prefer,
    },
    body: JSON.stringify(rows),
  });
  if (resp.status === 409) return { inserted: 0, conflict: true };
  if (!resp.ok) {
    const data = await resp.json().catch(() => null);
    const detail = typeof data === "object" ? JSON.stringify(data) : String(data || "");
    throw new Error(`rest_insert_${table}:${resp.status}:${detail.slice(0, 220)}`);
  }
  return { inserted: rows.length };
}

async function restUpsert(supabaseUrl, serviceKey, table, rows, onConflict) {
  if (!rows.length) return { upserted: 0 };
  const resp = await fetch(
    `${supabaseUrl}/rest/v1/${table}?on_conflict=${encodeURIComponent(onConflict)}`,
    {
      method: "POST",
      headers: {
        apikey: serviceKey,
        Authorization: `Bearer ${serviceKey}`,
        "Content-Type": "application/json",
        Prefer: "resolution=ignore-duplicates,return=minimal",
      },
      body: JSON.stringify(rows),
    }
  );
  if (!resp.ok) {
    const data = await resp.json().catch(() => null);
    const detail = typeof data === "object" ? JSON.stringify(data) : String(data || "");
    throw new Error(`rest_upsert_${table}:${resp.status}:${detail.slice(0, 220)}`);
  }
  return { upserted: rows.length };
}

function chunk(arr, size) {
  const out = [];
  for (let i = 0; i < arr.length; i += size) out.push(arr.slice(i, i + size));
  return out;
}

function tipoDeFuente(fuente) {
  if (MONITOR_PRECIOS_CONFIG.fuentes_venta.includes(fuente)) return "venta";
  return "compra";
}

async function persistir(supabaseUrl, serviceKey, result, meta) {
  const importRow = [{
    fuente: meta.fuente || "profeco_qqp",
    tipo: meta.tipo || "venta",
    fecha_lista: hoyMexico(),
    archivo: meta.archivo || "monitor_precios",
    filas_ok: result.capturas.filter((c) => c.estado_norm === "NORMALIZADO").length,
    filas_error: result.capturas.filter((c) => c.estado_norm !== "NORMALIZADO").length,
    notas: `monitor_precios llamadas_modelo=${result.llamadas_modelo} errores=${result.errores_fuente.length}`,
  }];
  await restPost(supabaseUrl, serviceKey, "importaciones_referencia", importRow);

  for (const part of chunk(result.capturas, 80)) {
    await restUpsert(supabaseUrl, serviceKey, "capturas_precio", part.map((c) => ({
      fuente: c.fuente,
      tipo: c.tipo || tipoDeFuente(c.fuente),
      nombre_crudo: c.nombre_crudo,
      precio: c.precio,
      moneda: c.moneda || "MXN",
      url_origen: c.url_origen,
      fecha_captura: c.fecha_captura,
      ciudad: c.ciudad,
      region: c.region,
      gtin_fuente: c.gtin_fuente || null,
      sku_externo: c.sku_externo,
      sustancia_activa: c.sustancia_activa,
      concentracion_valor: c.concentracion_valor,
      concentracion_unidad: c.concentracion_unidad,
      forma_farmaceutica: c.forma_farmaceutica,
      piezas_por_empaque: c.piezas_por_empaque,
      marca: c.marca,
      precio_unitario: c.precio_unitario,
      estado_norm: c.estado_norm,
      huella: c.huella,
    })), "huella");
  }

  const mapeos = result.mapeos.filter((m) => m.producto_id && m.estado !== "SIN_MAPEO");
  for (const part of chunk(mapeos, 80)) {
    await restUpsert(supabaseUrl, serviceKey, "mapeo_sku_fuente", part.map((m) => ({
      producto_id: m.producto_id,
      sku: m.sku,
      fuente: m.fuente,
      captura_huella: m.captura_huella,
      gtin_nuestro: m.gtin_nuestro,
      gtin_fuente: m.gtin_fuente,
      indice_elegido: m.indice_elegido,
      confianza: m.confianza,
      razon: m.razon,
      metodo: m.metodo,
      estado: m.estado,
      descripcion_producto_hash: m.descripcion_producto_hash,
      modelo: m.metodo === "MODELO" ? (process.env.ANTHROPIC_MODEL || "claude") : null,
    })), "producto_id,fuente,captura_huella");
  }

  const refs = result.referencias.filter((r) => r.producto_id);
  for (const part of chunk(refs, 80)) {
    await restPost(supabaseUrl, serviceKey, "producto_precios_referencia", part.map((r) => ({
      producto_id: r.producto_id,
      fuente: r.fuente,
      tipo: r.tipo || tipoDeFuente(r.fuente),
      precio: r.precio,
      moneda: r.moneda || "MXN",
      fecha: String(r.fecha_captura || "").slice(0, 10) || hoyMexico(),
      nombre_fuente: r.nombre_crudo,
      sku_externo: r.sku_externo,
      confianza: r.estado_ref === "VIGENTE" ? 100 : 0,
      origen: "monitor_precios",
      precio_unitario: r.precio_unitario,
      piezas_por_empaque: r.piezas_por_empaque,
      url_origen: r.url_origen,
      fecha_captura: r.fecha_captura,
      estado: r.estado_ref,
      delta_vs_anterior: r.delta_vs_anterior,
    })));
  }

  for (const part of chunk(result.referencia_vigente.filter((v) => v.producto_id), 80)) {
    const resp = await fetch(
      `${supabaseUrl}/rest/v1/referencia_vigente?on_conflict=producto_id`,
      {
        method: "POST",
        headers: {
          apikey: serviceKey,
          Authorization: `Bearer ${serviceKey}`,
          "Content-Type": "application/json",
          Prefer: "resolution=merge-duplicates,return=minimal",
        },
        body: JSON.stringify(part.map((v) => ({
          producto_id: v.producto_id,
          sku: v.sku,
          precio_unitario_mediana: v.precio_unitario_mediana,
          precio_unitario_min: v.precio_unitario_min,
          precio_unitario_max: v.precio_unitario_max,
          n_fuentes: v.n_fuentes,
          fecha_dato_mas_reciente: v.fecha_dato_mas_reciente,
          updated_at: new Date().toISOString(),
        }))),
      }
    );
    if (!resp.ok) {
      const data = await resp.json().catch(() => null);
      throw new Error(`rest_upsert_referencia_vigente:${resp.status}:${JSON.stringify(data).slice(0, 180)}`);
    }
  }

  for (const part of chunk(result.propuestas.filter((p) => p.producto_id), 80)) {
    await restPost(
      supabaseUrl,
      serviceKey,
      "propuestas_precio",
      part.map((p) => ({
        fecha_job: hoyMexico(),
        producto_id: p.producto_id,
        sku: p.sku,
        nombre: p.nombre,
        precio_actual: p.precio_actual,
        costo_usado: p.costo_usado,
        piezas_por_empaque: p.piezas_por_empaque,
        referencia_unitaria: p.referencia_unitaria,
        referencia_caja: p.referencia_caja,
        n_fuentes: p.n_fuentes,
        fecha_dato_mas_reciente: p.fecha_dato_mas_reciente,
        factor_posicionamiento: p.factor_posicionamiento,
        margen_minimo_categoria: p.margen_minimo_categoria,
        piso: p.piso,
        pmvp: p.pmvp,
        pvp_sugerido: p.pvp_sugerido,
        margen_resultante: p.margen_resultante,
        impacto_estimado: p.impacto_estimado,
        umbral_motivo: p.umbral_motivo,
        estado: "PENDIENTE",
      }))
    );
  }
}

async function cargarContexto(supabaseUrl, serviceKey) {
  const catalogo = await restGetAll(
    supabaseUrl,
    serviceKey,
    "productos?select=id,sku,nombre,marca,codigo_barras,principio_activo,concentracion,forma_farmaceutica,presentacion,unidades_por_caja,precio,costo,tipo,categoria,requiere_receta,stock,activo&activo=eq.true"
  );
  const mapeosCache = await restGetAll(
    supabaseUrl,
    serviceKey,
    "mapeo_sku_fuente?select=*&estado=neq.INVALIDADO"
  );
  const hist = await restGetAll(
    supabaseUrl,
    serviceKey,
    "producto_precios_referencia?select=producto_id,fuente,tipo,precio_unitario,fecha_captura,fecha,estado,sku_externo&precio_unitario=not.is.null&order=fecha.desc"
  );
  const byId = new Map(catalogo.map((p) => [p.id, p.sku]));
  const ultimoUnitarioPorClave = new Map();
  const historialVigente = [];
  for (const row of hist) {
    const sku = byId.get(row.producto_id);
    if (!sku) continue;
    const clave = `${sku}::${row.fuente}`;
    if (!ultimoUnitarioPorClave.has(clave) && row.estado === "VIGENTE") {
      ultimoUnitarioPorClave.set(clave, Number(row.precio_unitario));
    }
    historialVigente.push({
      ...row,
      sku,
      fecha_captura: row.fecha_captura || `${row.fecha}T00:00:00.000Z`,
      estado_ref: row.estado,
    });
  }
  const capturasDb = await restGetAll(
    supabaseUrl,
    serviceKey,
    "capturas_precio?select=fuente,tipo,nombre_crudo,precio,moneda,url_origen,fecha_captura,ciudad,region,gtin_fuente,sku_externo&estado_norm=eq.NORMALIZADO&order=fecha_captura.desc"
  );
  return { catalogo, mapeosCache, ultimoUnitarioPorClave, historialVigente, capturasDb };
}

function adaptadorDesdeFilas(id, tipo, filas) {
  return {
    id,
    tipo,
    async obtener() {
      return (filas || []).map((f) => ({
        ...f,
        fuente: f.fuente || id,
        tipo: f.tipo || tipo,
      }));
    },
  };
}

function adaptadoresJob(opts, capturasDb) {
  const list = [];
  const csvFuente = opts && opts.csvText ? (opts.fuente || "lista_distribuidor") : null;
  if (opts && opts.csvText) {
    if (csvFuente === "profeco_qqp") {
      list.push(crearAdaptadorProfecoQqp({
        csvText: opts.csvText,
        url_origen: opts.url_origen || "archivo:profeco.csv",
        ciudad: opts.ciudad || process.env.PROFECO_QQP_CIUDAD,
        fecha_captura: opts.fecha_captura,
      }));
    } else if (csvFuente === "datos_gob_patente") {
      list.push(crearAdaptadorDatosGobPatente({
        csvText: opts.csvText,
        url_origen: opts.url_origen || "archivo:datos_gob.csv",
        fecha_captura: opts.fecha_captura,
      }));
    } else {
      list.push(crearAdaptadorDistribuidor({
        csvText: opts.csvText,
        url_origen: opts.url_origen || `archivo:${opts.archivo || "lista_distribuidor.csv"}`,
        fecha_captura: opts.fecha_captura,
        fuente: csvFuente,
      }));
    }
  }
  if (process.env.PROFECO_QQP_CSV_URL && csvFuente !== "profeco_qqp") {
    list.push(crearAdaptadorProfecoQqp({
      ciudad: (opts && opts.ciudad) || process.env.PROFECO_QQP_CIUDAD,
    }));
  }
  if (process.env.DATOS_GOB_PATENTE_CSV_URL && csvFuente !== "datos_gob_patente") {
    list.push(crearAdaptadorDatosGobPatente({}));
  }
  const porFuente = new Map();
  for (const c of capturasDb || []) {
    if (!porFuente.has(c.fuente)) porFuente.set(c.fuente, []);
    porFuente.get(c.fuente).push(c);
  }
  for (const [fuente, filas] of porFuente) {
    if (fuente === csvFuente) continue;
    if (list.some((a) => a.id === fuente)) continue;
    list.push(adaptadorDesdeFilas(fuente, filas[0].tipo || tipoDeFuente(fuente), filas));
  }
  return list;
}

async function persistirFilasUi(supabaseUrl, serviceKey, filas) {
  if (!filas.length) return 0;
  const hoy = hoyMexico();
  const porFuente = new Map();
  for (const f of filas) {
    if (!porFuente.has(f.fuente)) porFuente.set(f.fuente, []);
    porFuente.get(f.fuente).push(f);
  }
  let n = 0;
  for (const [fuente, rows] of porFuente) {
    const tipo = rows[0].tipo || tipoDeFuente(fuente);
    await restPost(supabaseUrl, serviceKey, "importaciones_referencia", [{
      fuente,
      tipo,
      fecha_lista: hoy,
      archivo: "rastreo_automatico",
      filas_ok: rows.length,
      filas_error: 0,
      notas: "monitor_rastreo",
    }]);
    for (const part of chunk(rows, 80)) {
      await restPost(supabaseUrl, serviceKey, "producto_precios_referencia", part.map((r) => ({
        producto_id: r.producto_id,
        fuente: r.fuente,
        tipo,
        precio: r.precio,
        fecha: hoy,
        nombre_fuente: r.nombre_fuente,
        confianza: r.confianza,
        origen: r.origen || "job_api",
        notas: r.notas || "rastreo_automatico",
      })));
      n += part.length;
    }
  }
  return n;
}

async function cargarRefsUi(supabaseUrl, serviceKey) {
  try {
    const rows = await restGetAll(
      supabaseUrl,
      serviceKey,
      "producto_precios_referencia_actual?select=producto_id,fuente,precio,fecha,tipo"
    );
    const map = {};
    for (const r of rows) {
      if (!map[r.producto_id]) map[r.producto_id] = {};
      map[r.producto_id][r.fuente] = r;
    }
    return map;
  } catch {
    return {};
  }
}

async function runMonitorPreciosJob({ supabaseUrl, serviceKey, opts }) {
  if (opts && opts.csvText) {
    const ctx = await cargarContexto(supabaseUrl, serviceKey);
    const result = await correrPipeline({
      adaptadores: adaptadoresJob(opts || {}, ctx.capturasDb),
      catalogo: ctx.catalogo,
      mapeosCache: ctx.mapeosCache,
      ultimoUnitarioPorClave: ctx.ultimoUnitarioPorClave,
      historialVigente: ctx.historialVigente,
      llamarModelo: crearLlamarModelo(),
      ahora: new Date(),
    });
    await persistir(supabaseUrl, serviceKey, result, {
      fuente: opts.fuente || "lista_distribuidor",
      tipo: opts.fuente === "lista_distribuidor" ? "compra" : "venta",
      archivo: opts.archivo || "upload.csv",
    });
    return {
      ok: true,
      modo: "import",
      capturas: result.capturas.length,
      propuestas: result.propuestas.length,
      llamadas_modelo: result.llamadas_modelo,
      errores_fuente: result.errores_fuente,
    };
  }

  const catalogo = await restGetAll(
    supabaseUrl,
    serviceKey,
    "productos?select=id,sku,nombre,marca,codigo_barras,principio_activo,concentracion,forma_farmaceutica,presentacion,precio,costo,tipo,categoria,activo&activo=eq.true"
  );
  const refsByProduct = await cargarRefsUi(supabaseUrl, serviceKey);
  const rast = await rastrearReferencias({
    catalogo,
    refsByProduct,
    ahora: new Date(),
  });
  const insertadas = await persistirFilasUi(supabaseUrl, serviceKey, rast.filas);
  return {
    ok: true,
    modo: "rastreo",
    insertadas,
    ofertas_compra: rast.ofertas_compra,
    matches_compra: rast.matches_compra,
    busquedas_venta: rast.busquedas_venta,
    filas: rast.filas.length,
    errores_fuente: rast.errores,
    ms: rast.ms,
  };
}

module.exports = { runMonitorPreciosJob, persistir, cargarContexto };
