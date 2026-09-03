/**
 * Agrupa alertas de reabasto por el mismo medicamento (principio activo)
 * y, si no hay sustancia, por marca.
 */
import { claveSustancia, etiquetaTipoProducto } from "../utils/equivalentesPos";

const ORD_URGENCIA = { AGOTADO: 0, CRÍTICO: 1, CADUCA: 2, VENCIDO: 2, BAJO: 3, PRONTO: 4, OK: 5 };

function texto(value) {
  return String(value || "").replace(/\s+/g, " ").trim();
}

function esGenericoMarca(marca) {
  return /gen[eé]rico/i.test(marca || "");
}

function stockDe(p) {
  return Number(p?.stock_peps ?? p?.stock) || 0;
}

export function etiquetaPrincipioActivo(p) {
  return texto(p?.principio_activo || p?.denominacion_generica);
}

export function etiquetaMarca(p) {
  const marca = texto(p?.marca);
  if (marca && !esGenericoMarca(marca)) return marca;
  const tipo = etiquetaTipoProducto(p);
  if (tipo === "Genérico") return "Genérico";
  return marca;
}

export function claveGrupoReabasto(p) {
  const pa = claveSustancia(p);
  if (pa) return { tipo: "medicamento", clave: `pa:${pa}`, clavePa: pa };
  const marca = texto(p?.marca);
  if (marca && !esGenericoMarca(marca)) {
    return { tipo: "marca", clave: `marca:${marca.toLowerCase()}`, marca };
  }
  return { tipo: "suelto", clave: `sku:${p?.id ?? texto(p?.nombre)}` };
}

export function marcasDelGrupo(productos) {
  const seen = new Set();
  const out = [];
  for (const p of productos || []) {
    const label = etiquetaMarca(p) || "Sin marca";
    const k = label.toLowerCase();
    if (seen.has(k)) continue;
    seen.add(k);
    out.push(label);
  }
  return out;
}

function compararUrgencia(a, b) {
  const ua = ORD_URGENCIA[a?.urgencia?.nivel] ?? 9;
  const ub = ORD_URGENCIA[b?.urgencia?.nivel] ?? 9;
  if (ua !== ub) return ua - ub;
  return 0;
}

export function compararFilasReabasto(a, b) {
  return (
    compararUrgencia(a, b) ||
    texto(etiquetaMarca(a)).localeCompare(texto(etiquetaMarca(b)), "es") ||
    texto(a?.nombre).localeCompare(texto(b?.nombre), "es")
  );
}

function etiquetaGrupo(grupo, productos) {
  if (grupo.tipo === "medicamento") {
    const conPa = productos.find((p) => etiquetaPrincipioActivo(p));
    return etiquetaPrincipioActivo(conPa) || grupo.clavePa || "Principio activo";
  }
  if (grupo.tipo === "marca") return grupo.marca || texto(productos[0]?.marca);
  return texto(productos[0]?.nombre);
}

function subtituloGrupo(grupo, productos, marcas) {
  if (grupo.tipo === "medicamento") {
    if (productos.length > 1) {
      return marcas.length > 1
        ? `Mismo medicamento · ${marcas.length} marcas`
        : "Mismo medicamento · otra presentación";
    }
    return "Principio activo";
  }
  if (grupo.tipo === "marca") {
    return productos.length > 1 ? "Misma marca" : "Marca";
  }
  return "";
}

export function relacionadosAnaquel(grupo, catalogo, idsEnLista) {
  if (grupo?.tipo !== "medicamento" || !grupo.clavePa) return [];
  const ids = idsEnLista || new Set((grupo.productos || []).map((p) => p.id));
  return (catalogo || [])
    .filter((p) => p?.activo !== false && claveSustancia(p) === grupo.clavePa && !ids.has(p.id) && stockDe(p) > 0)
    .sort((a, b) =>
      texto(etiquetaMarca(a)).localeCompare(texto(etiquetaMarca(b)), "es") ||
      texto(a?.nombre).localeCompare(texto(b?.nombre), "es")
    )
    .slice(0, 8);
}

/**
 * @param {Array} filas  Productos ya filtrados (alertas visibles)
 * @param {{ catalogo?: Array }} [opts]  Catálogo completo para “también hay stock”
 */
export function agruparFilasReabasto(filas, { catalogo = [] } = {}) {
  const map = new Map();
  for (const p of filas || []) {
    const meta = claveGrupoReabasto(p);
    if (!map.has(meta.clave)) map.set(meta.clave, { ...meta, productos: [] });
    map.get(meta.clave).productos.push(p);
  }

  const idsVisibles = new Set((filas || []).map((p) => p.id));
  const grupos = [...map.values()].map((g) => {
    const productos = [...g.productos].sort(compararFilasReabasto);
    const marcas = marcasDelGrupo(productos);
    const etiqueta = etiquetaGrupo(g, productos);
    const relacionados = relacionadosAnaquel({ ...g, productos }, catalogo, idsVisibles);
    return {
      ...g,
      productos,
      marcas,
      etiqueta,
      subtitulo: subtituloGrupo(g, productos, marcas),
      urgenciaGrupo: productos[0]?.urgencia || null,
      relacionados,
    };
  });

  grupos.sort((a, b) => {
    const ua = ORD_URGENCIA[a.urgenciaGrupo?.nivel] ?? 9;
    const ub = ORD_URGENCIA[b.urgenciaGrupo?.nivel] ?? 9;
    if (ua !== ub) return ua - ub;
    if (a.tipo === "medicamento" && b.tipo !== "medicamento") return -1;
    if (b.tipo === "medicamento" && a.tipo !== "medicamento") return 1;
    const nRel = (g) => (g.productos.length > 1 || g.relacionados.length ? 0 : 1);
    return nRel(a) - nRel(b) || texto(a.etiqueta).localeCompare(texto(b.etiqueta), "es");
  });

  return grupos;
}

export function grupoEstaSeleccionado(grupo, selProds) {
  return Boolean(grupo?.productos?.length) && grupo.productos.every((p) => selProds?.[p.id] > 0);
}
