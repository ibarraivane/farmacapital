/**
 * Vista de sabores en tienda y POS.
 * grupo_publico / variante_publica son etiquetas de pantalla.
 * No cambian stock, precio, EAN ni el renglón que se cobra.
 */

export function claveGrupoPublico(p) {
  return String(p?.grupo_publico || "").trim();
}

export function etiquetaVariantePublica(p) {
  return String(p?.variante_publica || "").trim();
}

export function leyendaSabores(n) {
  const k = Number(n) || 0;
  if (k <= 1) return "";
  return `${k} sabores`;
}

function escapeRe(s) {
  return String(s).replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

/** Nombre de la tarjeta, sin el sabor. El SKU guardado no se toca. */
export function tituloGrupoPublico(p) {
  const nombre = String(p?.nombre || "").trim();
  const variante = etiquetaVariantePublica(p);
  if (!nombre || !variante) return nombre;
  const palabras = variante.split(/[\s-]+/).filter(Boolean).map(escapeRe);
  if (!palabras.length) return nombre;
  const re = new RegExp(`(?:^|[\\s-]+)${palabras.join("[\\s-]+")}(?=$|[\\s-])`, "i");
  let limpio = nombre.replace(re, " ");
  limpio = limpio
    .replace(/\s+-\s+sabor\s+-\s+/gi, " - ")
    .replace(/\s+-\s+sabor\s*$/gi, "")
    .replace(/(?:^|\s)sabor\s+-\s+/gi, " ")
    .replace(/\s+-\s+-\s+/g, " - ")
    .replace(/\s*-\s*$/g, "")
    .replace(/^\s*-\s*/g, "")
    .replace(/\s{2,}/g, " ")
    .trim();
  return limpio || nombre;
}

function ordenVariante(a, b) {
  const byNombre = etiquetaVariantePublica(a).localeCompare(etiquetaVariantePublica(b), "es", { sensitivity: "base" });
  if (byNombre) return byNombre;
  const byProd = String(a?.nombre || "").localeCompare(String(b?.nombre || ""), "es", { sensitivity: "base" });
  if (byProd) return byProd;
  return (Number(a?.id) || 0) - (Number(b?.id) || 0);
}

function tieneImagen(p) {
  return Boolean(String(p?.imagen_url || p?.imagen_mobile_url || "").trim());
}

/** Hermanos activos del mismo grupo. Sin grupo, solo el producto. */
export function variantesDelGrupo(productos, ancla) {
  const clave = claveGrupoPublico(ancla);
  if (!clave) return ancla ? [ancla] : [];
  const list = (productos || []).filter((p) => p && p.activo !== false && claveGrupoPublico(p) === clave);
  if (!list.length) return ancla ? [ancla] : [];
  return [...list].sort(ordenVariante);
}

/** Para la cuadrícula sin búsqueda: el que tenga foto, si no el primero. */
export function representanteGrupo(variantes) {
  const list = variantes || [];
  if (!list.length) return null;
  return list.find(tieneImagen) || list[0];
}

function vistaDeGrupo(producto, grupo) {
  const n = (grupo || []).length;
  if (!producto || n <= 1) return producto;
  return {
    ...producto,
    sabores_publicos: n,
    titulo_grupo_publico: tituloGrupoPublico(producto),
  };
}

/**
 * Una fila por grupo_publico. El resto de los productos pasa igual.
 * preferirCoincidencia: se queda el primero de la lista (búsqueda ya ordenada).
 * Si no, la foto representante, siempre que esté en la lista.
 * universo: catálogo completo, para contar sabores aunque la lista venga filtrada.
 */
export function colapsarListaPublica(lista, opts = {}) {
  const arr = lista || [];
  const universo = opts.universo || arr;
  const preferirCoincidencia = opts.preferirCoincidencia === true;
  const vistos = new Set();
  const out = [];
  for (const p of arr) {
    if (!p) continue;
    const clave = claveGrupoPublico(p);
    if (!clave) {
      out.push(p);
      continue;
    }
    if (vistos.has(clave)) continue;
    vistos.add(clave);
    const grupo = variantesDelGrupo(universo, p);
    const enLista = arr.filter((x) => claveGrupoPublico(x) === clave);
    let elegido = enLista[0] || p;
    if (!preferirCoincidencia) {
      const foto = representanteGrupo(grupo);
      if (foto && enLista.some((x) => x.id === foto.id)) elegido = foto;
    }
    out.push(vistaDeGrupo(elegido, grupo));
  }
  return out;
}

/** Quita campos de pantalla antes de meter el SKU al carrito. */
export function productoSinVistaGrupo(p) {
  if (!p || p.sabores_publicos == null) return p;
  const copia = { ...p };
  delete copia.sabores_publicos;
  delete copia.titulo_grupo_publico;
  return copia;
}

/** Sugerencias: un renglón por grupo. El id es el sabor que coincidió. */
export function colapsarSugerenciasPublicas(sugerencias, productos) {
  const byId = new Map();
  for (const p of productos || []) {
    if (p?.id != null) byId.set(String(p.id), p);
  }
  const vistos = new Set();
  const out = [];
  for (const s of sugerencias || []) {
    const p = byId.get(String(s?.id));
    const clave = claveGrupoPublico(p);
    if (!clave) {
      out.push(s);
      continue;
    }
    if (vistos.has(clave)) continue;
    vistos.add(clave);
    const n = variantesDelGrupo(productos, p).length;
    out.push(n > 1 ? { ...s, sabores_publicos: n } : s);
  }
  return out;
}
