import { viaValida, normalizarClaveMonografia } from "./claveMonografia";
import { TIPOS_FICHA } from "./tipoFicha";

const FUENTE_TIPOS = new Set(["instructivo", "fabricante", "cofepris", "openfacts", "otra"]);
const CAMPOS_MONOGRAFIA = [
  "resumen",
  "para_que_sirve",
  "como_se_usa",
  "no_usar_si",
  "consulta_si",
  "interacciones",
  "efectos",
  "alarma",
  "conservacion",
];

function esTexto(v) {
  return typeof v === "string";
}

function esListaTexto(v) {
  return Array.isArray(v) && v.every((x) => typeof x === "string");
}

function noVacio(v) {
  if (Array.isArray(v)) return v.some((x) => String(x || "").trim());
  return String(v || "").trim().length > 0;
}

export function validarFuentes(fuentes, { exigir = false } = {}) {
  const errores = [];
  if (!Array.isArray(fuentes)) {
    return { ok: false, errores: ["fuentes debe ser un arreglo"] };
  }
  fuentes.forEach((f, i) => {
    if (!f || typeof f !== "object") {
      errores.push(`fuentes[${i}] inválida`);
      return;
    }
    if (!String(f.url || "").trim()) errores.push(`fuentes[${i}].url vacía`);
    if (f.tipo && !FUENTE_TIPOS.has(f.tipo)) errores.push(`fuentes[${i}].tipo inválido`);
    if (!Array.isArray(f.campos)) errores.push(`fuentes[${i}].campos debe ser arreglo`);
  });
  if (exigir && fuentes.length === 0) errores.push("hace falta al menos una fuente");
  return { ok: errores.length === 0, errores };
}

export function validarContenidoMonografia(contenido) {
  const errores = [];
  if (!contenido || typeof contenido !== "object") {
    return { ok: false, errores: ["contenido de monografía vacío"] };
  }
  if (!esTexto(contenido.resumen)) errores.push("resumen debe ser texto");
  if (!esTexto(contenido.para_que_sirve)) errores.push("para_que_sirve debe ser texto");
  if (!esListaTexto(contenido.como_se_usa || [])) errores.push("como_se_usa debe ser lista de textos");
  if (!esListaTexto(contenido.no_usar_si || [])) errores.push("no_usar_si debe ser lista de textos");
  if (!esListaTexto(contenido.consulta_si || [])) errores.push("consulta_si debe ser lista de textos");
  if (contenido.interacciones != null && !esTexto(contenido.interacciones)) {
    errores.push("interacciones debe ser texto");
  }
  if (!esListaTexto(contenido.efectos || [])) errores.push("efectos debe ser lista de textos");
  if (contenido.alarma != null && !esTexto(contenido.alarma)) errores.push("alarma debe ser texto");
  if (!esListaTexto(contenido.conservacion || [])) errores.push("conservacion debe ser lista de textos");
  if (contenido.requiere_receta_habitual != null && typeof contenido.requiere_receta_habitual !== "boolean") {
    errores.push("requiere_receta_habitual debe ser boolean");
  }
  return { ok: errores.length === 0, errores };
}

export function validarContenidoProducto(contenido) {
  const errores = [];
  if (!contenido || typeof contenido !== "object") {
    return { ok: false, errores: ["contenido de producto vacío"] };
  }
  if (contenido.resumen != null && !esTexto(contenido.resumen)) errores.push("resumen debe ser texto");
  if (contenido.chips != null && !esListaTexto(contenido.chips)) errores.push("chips debe ser lista de textos");
  if (contenido.fabricante != null) {
    const f = contenido.fabricante;
    if (typeof f !== "object") errores.push("fabricante debe ser objeto");
    else {
      if (f.descripcion != null && !esTexto(f.descripcion)) errores.push("fabricante.descripcion debe ser texto");
      if (f.modo_de_uso != null && !esListaTexto(f.modo_de_uso)) errores.push("fabricante.modo_de_uso debe ser lista");
      if (f.ingredientes_destacados != null && !esListaTexto(f.ingredientes_destacados)) {
        errores.push("fabricante.ingredientes_destacados debe ser lista");
      }
      if (f.precauciones != null && !esListaTexto(f.precauciones)) errores.push("fabricante.precauciones debe ser lista");
    }
  }
  return { ok: errores.length === 0, errores };
}

/**
 * Valida la salida del agente de investigación (§4 + prompt).
 * Cada sección con valor debe tener al menos una fuente que la respalde.
 */
export function validarResultadoEnriquecimiento(resultado) {
  const errores = [];
  if (!resultado || typeof resultado !== "object") {
    return { ok: false, errores: ["resultado vacío"], faltantes: [] };
  }
  if (!TIPOS_FICHA.includes(resultado.tipo_ficha)) {
    errores.push("tipo_ficha inválido");
  }
  const fuentes = resultado.fuentes || [];
  const vf = validarFuentes(fuentes);
  errores.push(...vf.errores);

  const camposConFuente = new Set();
  for (const f of fuentes) {
    for (const c of f.campos || []) camposConFuente.add(c);
  }

  const faltantes = Array.isArray(resultado.faltantes) ? resultado.faltantes : [];

  if (resultado.monografia) {
    const m = resultado.monografia;
    if (normalizarClaveMonografia(m.clave) !== String(m.clave || "").trim() && m.clave) {
      // aceptamos clave ya normalizada o la normalizamos en tests
    }
    if (m.clave && !normalizarClaveMonografia(m.clave)) errores.push("monografia.clave vacía");
    if (m.via && !viaValida(m.via)) errores.push("monografia.via inválida");
    const vm = validarContenidoMonografia(m.contenido || {});
    errores.push(...vm.errores.map((e) => `monografia.${e}`));
    const c = m.contenido || {};
    for (const campo of CAMPOS_MONOGRAFIA) {
      if (noVacio(c[campo]) && !camposConFuente.has(campo) && !faltantes.includes(campo)) {
        errores.push(`sección ${campo} sin fuente`);
      }
    }
  }

  if (resultado.producto) {
    const vp = validarContenidoProducto(resultado.producto);
    errores.push(...vp.errores.map((e) => `producto.${e}`));
    if (noVacio(resultado.producto.resumen) && !camposConFuente.has("resumen") && !faltantes.includes("resumen")) {
      errores.push("sección resumen sin fuente");
    }
  }

  if (resultado.imagenes != null && !Array.isArray(resultado.imagenes)) {
    errores.push("imagenes debe ser lista");
  }

  return { ok: errores.length === 0, errores, faltantes };
}

export function payloadSeguroParaAgente(producto) {
  return {
    producto_id: producto.id,
    nombre: producto.nombre || "",
    marca: producto.marca || "",
    codigo_barras: producto.codigo_barras || "",
    principio_activo: producto.principio_activo || "",
    concentracion: producto.concentracion || "",
    forma_farmaceutica: producto.forma_farmaceutica || "",
    presentacion: producto.presentacion || "",
    requiere_receta: Boolean(producto.requiere_receta),
    tipo_ficha: producto.tipo_ficha || "",
    monografia_existente: producto.monografia_existente || null,
  };
}
