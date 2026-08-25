/**
 * Emparejador: candidatos deterministas + atajo GTIN + modelo acotado + caché.
 * El modelo NUNCA ve precios. Solo elige índice o ninguno.
 */

"use strict";

const { MONITOR_PRECIOS_CONFIG } = require("./config");
const { colapsar, extraerPiezas, extraerConcentracion, extraerForma } = require("./normalizador");
const {
  scoreNombre,
  gtinCoincide,
  hashEstable,
  mismaSustancia,
  mismaForma,
} = require("./similitud");

const SCHEMA_KEYS = ["confianza", "indice_elegido", "razon"];

function descripcionProductoHash(producto) {
  return hashEstable([
    producto.sku || "",
    producto.nombre || "",
    producto.principio_activo || "",
    producto.concentracion || "",
    producto.forma_farmaceutica || "",
    producto.unidades_por_caja || "",
    producto.codigo_barras || "",
  ].join("|"));
}

function huellaCapturaNorm(cap) {
  return hashEstable([
    cap.fuente || "",
    cap.gtin_fuente || "",
    cap.nombre_crudo || "",
    cap.piezas_por_empaque || "",
    cap.concentracion_valor || "",
    cap.concentracion_unidad || "",
  ].join("|"));
}

function cacheKey(producto, captura) {
  return `${producto.sku}::${captura.fuente}::${huellaCapturaNorm(captura)}`;
}

function mapeoVigente(cache, producto, captura) {
  if (!cache) return null;
  const row = cache.get(cacheKey(producto, captura)) || cache.get(`${producto.sku}::${captura.fuente}`);
  if (!row) return null;
  if (row.estado === "INVALIDADO") return null;
  if (row.descripcion_producto_hash && row.descripcion_producto_hash !== descripcionProductoHash(producto)) {
    return null;
  }
  return row;
}

function sustanciaDeProducto(producto) {
  return colapsar(producto.principio_activo || "") || null;
}

function formaDeProducto(producto) {
  const directa = colapsar(producto.forma_farmaceutica || "");
  if (directa) return extraerForma(directa) || producto.forma_farmaceutica;
  return extraerForma(colapsar(`${producto.nombre || ""} ${producto.presentacion || ""}`));
}

function textoProducto(producto) {
  return [producto.nombre, producto.marca, producto.principio_activo, producto.presentacion]
    .filter(Boolean)
    .join(" ");
}

function candidatosParaSku(producto, capturas, topN) {
  const sustancia = sustanciaDeProducto(producto);
  const forma = formaDeProducto(producto);
  const filtradas = capturas.filter((c) => {
    if (c.estado_norm !== "NORMALIZADO") return false;
    if (sustancia && c.sustancia_activa && !mismaSustancia(sustancia, c.sustancia_activa)) return false;
    if (forma && c.forma_farmaceutica && !mismaForma(forma, c.forma_farmaceutica)) return false;
    return true;
  });
  const ranked = filtradas
    .map((c) => ({ captura: c, score: scoreNombre(textoProducto(producto), c.nombre_crudo) }))
    .sort((a, b) => b.score - a.score);
  return ranked.slice(0, topN);
}

function validarRespuestaModelo(obj, nCandidatos) {
  if (!obj || typeof obj !== "object" || Array.isArray(obj)) return null;
  const keys = Object.keys(obj).sort();
  if (keys.length !== 3 || keys.some((k, i) => k !== SCHEMA_KEYS[i])) return null;
  const { indice_elegido: idx, confianza, razon } = obj;
  const conf = Number(confianza);
  if (!Number.isFinite(conf) || conf < 0 || conf > 1) return null;
  if (typeof razon !== "string" || !razon.trim() || razon.length > 400) return null;
  if (idx == null) return { indice_elegido: null, confianza: conf, razon: razon.trim() };
  if (!Number.isInteger(idx) || idx < 0 || idx >= nCandidatos) return null;
  return { indice_elegido: idx, confianza: conf, razon: razon.trim() };
}

function estadoPorConfianza(confianza, cfg) {
  if (confianza >= cfg.emparejador.auto) return "ACEPTADO";
  if (confianza >= cfg.emparejador.verificar) return "POR_VERIFICAR";
  return "SIN_MAPEO";
}

function promptEmparejamiento(producto, candidatos) {
  const nuestro = {
    sku: producto.sku,
    nombre: producto.nombre,
    marca: producto.marca || null,
    principio_activo: producto.principio_activo || null,
    concentracion: producto.concentracion || null,
    forma_farmaceutica: producto.forma_farmaceutica || null,
    presentacion: producto.presentacion || null,
    gtin: producto.codigo_barras || null,
  };
  const lista = candidatos.map((c, i) => ({
    indice: i,
    nombre_crudo: c.captura.nombre_crudo,
    sustancia_activa: c.captura.sustancia_activa,
    concentracion_valor: c.captura.concentracion_valor,
    concentracion_unidad: c.captura.concentracion_unidad,
    forma_farmaceutica: c.captura.forma_farmaceutica,
    piezas_por_empaque: c.captura.piezas_por_empaque,
    marca: c.captura.marca,
    gtin: c.captura.gtin_fuente || null,
    fuente: c.captura.fuente,
  }));
  return [
    "Elige el candidato que describe el MISMO producto farmacéutico, o ninguno.",
    "Debes elegir SOLO entre los candidatos dados. Nunca inventes uno.",
    "No comentes, estimes ni menciones precios.",
    "Responde JSON estricto con exactamente estas llaves: indice_elegido, confianza, razon.",
    "indice_elegido es el índice 0-based del arreglo candidatos, o null si ninguno coincide.",
    "confianza es un número entre 0 y 1.",
    JSON.stringify({ nuestro, candidatos: lista }),
  ].join("\n");
}

function construirMapeo({ producto, captura, confianza, razon, metodo, estado, indiceElegido }) {
  return {
    producto_id: producto.id || null,
    sku: producto.sku,
    fuente: captura.fuente,
    captura_huella: huellaCapturaNorm(captura),
    gtin_nuestro: producto.codigo_barras || null,
    gtin_fuente: captura.gtin_fuente || null,
    indice_elegido: indiceElegido,
    confianza,
    razon,
    metodo,
    estado,
    descripcion_producto_hash: descripcionProductoHash(producto),
    captura,
  };
}

async function emparejarSku(producto, capturas, opciones = {}) {
  const cfg = opciones.config || MONITOR_PRECIOS_CONFIG;
  const cache = opciones.cache || null;
  const llamarModelo = opciones.llamarModelo || null;
  const topN = cfg.emparejador.top_candidatos;
  let llamadasModelo = 0;

  const gtinHit = capturas.find(
    (c) => c.estado_norm === "NORMALIZADO" && gtinCoincide(producto.codigo_barras, c.gtin_fuente)
  );
  if (gtinHit) {
    const cached = mapeoVigente(cache, producto, gtinHit);
    if (cached) return { mapeos: [cached], llamadasModelo: 0, desdeCache: true };
    return {
      mapeos: [construirMapeo({
        producto,
        captura: gtinHit,
        confianza: 1,
        razon: "GTIN coincidente",
        metodo: "GTIN",
        estado: "ACEPTADO",
        indiceElegido: null,
      })],
      llamadasModelo: 0,
      desdeCache: false,
    };
  }

  const porFuente = new Map();
  for (const c of capturas) {
    if (!porFuente.has(c.fuente)) porFuente.set(c.fuente, []);
    porFuente.get(c.fuente).push(c);
  }

  const mapeos = [];
  for (const [, lista] of porFuente) {
    const muestra = lista[0];
    const cached = mapeoVigente(cache, producto, muestra);
    if (cached) {
      mapeos.push({ ...cached, desdeCache: true });
      continue;
    }

    const candidatos = candidatosParaSku(producto, lista, topN);
    if (!candidatos.length) {
      continue;
    }

    const presupuesto = opciones.presupuesto;
    const sinPresupuesto = presupuesto && presupuesto.usadas >= presupuesto.max;
    if (!llamarModelo || sinPresupuesto) {
      mapeos.push(construirMapeo({
        producto,
        captura: candidatos[0].captura,
        confianza: 0,
        razon: sinPresupuesto ? "presupuesto_modelo" : "modelo_no_configurado",
        metodo: "MODELO",
        estado: "SIN_MAPEO",
        indiceElegido: null,
      }));
      continue;
    }

    llamadasModelo += 1;
    if (presupuesto) presupuesto.usadas += 1;
    let raw;
    try {
      raw = await llamarModelo(promptEmparejamiento(producto, candidatos));
    } catch {
      raw = null;
    }
    const parsed = typeof raw === "string" ? safeJson(raw) : raw;
    const ok = validarRespuestaModelo(parsed, candidatos.length);
    if (!ok || ok.indice_elegido == null) {
      mapeos.push(construirMapeo({
        producto,
        captura: candidatos[0].captura,
        confianza: ok ? ok.confianza : 0,
        razon: ok ? ok.razon : "respuesta_modelo_invalida",
        metodo: "MODELO",
        estado: "SIN_MAPEO",
        indiceElegido: null,
      }));
      continue;
    }
    const elegida = candidatos[ok.indice_elegido].captura;
    mapeos.push(construirMapeo({
      producto,
      captura: elegida,
      confianza: ok.confianza,
      razon: ok.razon,
      metodo: "MODELO",
      estado: estadoPorConfianza(ok.confianza, cfg),
      indiceElegido: ok.indice_elegido,
    }));
  }

  return { mapeos, llamadasModelo, desdeCache: false };
}

function safeJson(text) {
  try {
    const trimmed = String(text).trim().replace(/^```json\s*|\s*```$/g, "");
    return JSON.parse(trimmed);
  } catch {
    return null;
  }
}

function indexarCache(filas) {
  const map = new Map();
  for (const row of filas || []) {
    if (row.sku && row.fuente && row.captura_huella) {
      map.set(`${row.sku}::${row.fuente}::${row.captura_huella}`, row);
    }
    if (row.sku && row.fuente) {
      map.set(`${row.sku}::${row.fuente}`, row);
    }
  }
  return map;
}

function piezasProducto(producto) {
  const n = parseInt(producto.unidades_por_caja, 10);
  if (n > 0) return n;
  const fromPres = extraerPiezas(colapsar(`${producto.presentacion || ""} ${producto.nombre || ""}`));
  return fromPres || null;
}

function concentracionProducto(producto) {
  return extraerConcentracion(colapsar(producto.concentracion || producto.nombre || ""));
}

module.exports = {
  descripcionProductoHash,
  huellaCapturaNorm,
  cacheKey,
  mapeoVigente,
  candidatosParaSku,
  validarRespuestaModelo,
  estadoPorConfianza,
  promptEmparejamiento,
  construirMapeo,
  emparejarSku,
  indexarCache,
  piezasProducto,
  concentracionProducto,
};
