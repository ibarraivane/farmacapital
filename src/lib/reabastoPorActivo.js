/**
 * Reabasto por principio activo: Busconet agotado + Pasmodil en anaquel
 * = el mismo surtido (hioscina + metamizol), no un faltante.
 */
import { claveSustancia, formaFarmaceuticaClave } from "../utils/equivalentesPos";
import { inventarioProductMatchesBusqueda } from "../utils/fuzzySearch";

export const STOCK_MIN_DEFAULT = 5;
export const VISTA_REABASTO = { ACTIVO: "activo", MARCA: "marca" };

const ETIQUETA_FORMA = {
  tabletas: "tabletas",
  capsulas: "cápsulas",
  suspension: "suspensión / jarabe",
  gotas: "gotas",
  unguento: "ungüento",
  crema: "crema",
  inyectable: "inyectable",
  polvo: "polvo",
};

export function stockDe(p) {
  return Number(p?.stock_peps ?? p?.stock) || 0;
}

export function stockMinimoEfectivo(p) {
  return Number(p?.stock_minimo) > 0 ? Number(p.stock_minimo) : STOCK_MIN_DEFAULT;
}

export function calcStockUrgencia(p, C) {
  const min = stockMinimoEfectivo(p);
  const stock = stockDe(p);
  const pct = min > 0 ? stock / min : 1;
  if (stock === 0) return { nivel: "AGOTADO", col: C.red, bg: C.redDim, icon: "🚨" };
  if (pct <= 0.5) return { nivel: "CRÍTICO", col: C.red, bg: C.redDim, icon: "🔴" };
  if (pct <= 1) return { nivel: "BAJO", col: C.amber, bg: C.amberDim, icon: "🟡" };
  if (pct <= 1.5) return { nivel: "PRONTO", col: "#0891b2", bg: "#cffafe", icon: "🔵" };
  return null;
}

export function etiquetaFormaReabasto(forma) {
  return ETIQUETA_FORMA[forma] || forma || "";
}

export function claveGrupoReabasto(producto) {
  const clave = claveSustancia(producto);
  if (!clave) return "";
  const forma = formaFarmaceuticaClave(producto) || "sin-forma";
  return `${clave}|${forma}`;
}

export function etiquetaGrupoReabasto(miembros) {
  const conPa = (miembros || []).find((p) =>
    String(p?.principio_activo || p?.denominacion_generica || "").trim()
  );
  const pa = String(conPa?.principio_activo || conPa?.denominacion_generica || "").trim();
  const forma = etiquetaFormaReabasto(formaFarmaceuticaClave(miembros?.[0]));
  if (pa && forma) return `${pa} · ${forma}`;
  return pa || forma || "Principio activo";
}

/** Qué marca pedir si el grupo se marca: la que ya hay en anaquel, o la que se compraba. */
export function representativoParaPedir(miembros) {
  const list = [...(miembros || [])];
  if (!list.length) return null;
  const conStock = list.filter((p) => stockDe(p) > 0);
  const pool = conStock.length ? conStock : list;
  return pool.slice().sort((a, b) => {
    const sa = stockDe(a);
    const sb = stockDe(b);
    if (sb !== sa) return sb - sa;
    const ca = Number(a.costo) > 0 ? 0 : 1;
    const cb = Number(b.costo) > 0 ? 0 : 1;
    if (ca !== cb) return ca - cb;
    return String(a.nombre || "").localeCompare(String(b.nombre || ""), "es");
  })[0];
}

function mejorTiendaDelGrupo(miembros) {
  return (miembros || [])
    .map((m) => m.mejorTienda)
    .filter((t) => t && Number(t.precio) > 0)
    .sort((a, b) => Number(a.precio) - Number(b.precio))[0] || null;
}

function minCaducidadDelGrupo(miembros) {
  const conStock = (miembros || []).filter((p) => stockDe(p) > 0 && p.min_caducidad_lotes);
  const pool = conStock.length ? conStock : (miembros || []).filter((p) => p.min_caducidad_lotes);
  if (!pool.length) return null;
  return pool.reduce((m, p) => (!m || p.min_caducidad_lotes < m) ? p.min_caducidad_lotes : m, null);
}

function filaSku(p, extra = {}) {
  return {
    ...p,
    esGrupoActivo: false,
    miembros: [p],
    representativo: p,
    idPedido: p.id,
    ...extra,
  };
}

function filaGrupo(claveGrupo, miembros) {
  const representativo = representativoParaPedir(miembros);
  const stock = miembros.reduce((s, p) => s + stockDe(p), 0);
  const stockMin = Math.max(...miembros.map((p) => stockMinimoEfectivo(p)));
  const cubre = miembros.filter((p) => stockDe(p) > 0);
  const falta = miembros.filter((p) => stockDe(p) === 0);
  const minCad = minCaducidadDelGrupo(miembros);
  const dias = miembros
    .map((p) => p.diasCaducidad)
    .filter((d) => d != null)
    .sort((a, b) => a - b)[0];
  return {
    ...representativo,
    id: `pa:${claveGrupo}`,
    esGrupoActivo: true,
    claveGrupo,
    miembros,
    representativo,
    idPedido: representativo.id,
    nombre: etiquetaGrupoReabasto(miembros),
    principio_activo: representativo.principio_activo || miembros.find((p) => p.principio_activo)?.principio_activo || "",
    sku: miembros.map((p) => p.sku).filter(Boolean).join(" · ") || "varias marcas",
    stock,
    stock_peps: stock,
    stock_minimo: stockMin,
    mejorTienda: mejorTiendaDelGrupo(miembros) || representativo.mejorTienda,
    min_caducidad_lotes: minCad,
    diasCaducidad: dias ?? representativo.diasCaducidad,
    cubre,
    falta,
    marcas: miembros
      .slice()
      .sort((a, b) => stockDe(b) - stockDe(a) || String(a.nombre || "").localeCompare(String(b.nombre || ""), "es"))
      .map((p) => ({
        id: p.id,
        nombre: p.nombre,
        marca: p.marca,
        sku: p.sku,
        stock: stockDe(p),
      })),
  };
}

export function agruparReabastoPorActivo(productos) {
  const grupos = new Map();
  const sueltos = [];
  for (const p of productos || []) {
    const k = claveGrupoReabasto(p);
    if (!k) {
      sueltos.push(filaSku(p));
      continue;
    }
    if (!grupos.has(k)) grupos.set(k, []);
    grupos.get(k).push(p);
  }
  const filas = [];
  for (const [k, miembros] of grupos) {
    if (miembros.length === 1) filas.push(filaSku(miembros[0], { claveGrupo: k }));
    else filas.push(filaGrupo(k, miembros));
  }
  return [...filas, ...sueltos];
}

export function idParaPedir(fila, pedidoMarca = {}) {
  if (!fila?.esGrupoActivo) return fila?.id;
  const elegido = pedidoMarca[fila.claveGrupo];
  if (elegido && (fila.miembros || []).some((m) => m.id === elegido)) return elegido;
  return fila.idPedido || fila.representativo?.id;
}

export function leyendaCoberturaGrupo(fila) {
  if (!fila?.esGrupoActivo) return "";
  const hay = (fila.cubre || []).map((p) => `${p.marca || p.nombre} (${stockDe(p)})`);
  const noHay = (fila.falta || []).map((p) => p.marca || p.nombre);
  if (hay.length && noHay.length) {
    return `Hay ${hay.join(", ")} · falta ${noHay.join(", ")}`;
  }
  if (hay.length) return `Hay ${hay.join(", ")}`;
  if (noHay.length) return `Falta ${noHay.join(", ")}`;
  return "";
}

export function reabastoFilaMatchesBusqueda(fila, query) {
  const q = String(query || "").trim();
  if (!q) return true;
  if (inventarioProductMatchesBusqueda(fila, q)) return true;
  return (fila.miembros || []).some((p) => inventarioProductMatchesBusqueda(p, q));
}
