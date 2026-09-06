/**
 * Bandas de catálogo por categoría para la home de la tienda.
 * Orden canónico de categorías; dentro de cada banda: con stock primero, luego A–Z.
 */
import { CATEGORIAS_PRODUCTO, categoriaCanon } from "../constants/categoriasProducto";

function agotado(p) {
  return Number(p?.stock) <= 0;
}

function sortProductosBanda(arr) {
  return [...(arr || [])].sort((a, b) => {
    const agA = agotado(a) ? 1 : 0;
    const agB = agotado(b) ? 1 : 0;
    if (agA !== agB) return agA - agB;
    return String(a?.nombre || "").localeCompare(String(b?.nombre || ""), "es", {
      sensitivity: "base",
    });
  });
}

/**
 * Agrupa productos del catálogo vivo en franjas horizontales por categoría.
 * Omite categorías vacías. `Otro` y huérfanas van al final.
 *
 * @param {object[]} productos
 * @param {{ perCat?: number, maxCats?: number }} [opts]
 * @returns {{ categoria: string, productos: object[] }[]}
 */
export function bandasCatalogoPorCategoria(productos, opts = {}) {
  const perCat = Math.max(1, Number(opts.perCat) || 12);
  const maxCats = Math.max(1, Number(opts.maxCats) || 16);
  const byCat = new Map();

  for (const p of productos || []) {
    if (!p || p.activo === false) continue;
    const cat = categoriaCanon(p.categoria) || "Otro";
    if (!byCat.has(cat)) byCat.set(cat, []);
    byCat.get(cat).push(p);
  }

  const canonSet = new Set(CATEGORIAS_PRODUCTO);
  const ordered = [];

  for (const cat of CATEGORIAS_PRODUCTO) {
    if (cat === "Otro") continue;
    const list = byCat.get(cat);
    if (!list?.length) continue;
    ordered.push({
      categoria: cat,
      productos: sortProductosBanda(list).slice(0, perCat),
    });
  }

  const extras = [...byCat.keys()]
    .filter((c) => c !== "Otro" && !canonSet.has(c))
    .sort((a, b) => a.localeCompare(b, "es", { sensitivity: "base" }));

  for (const cat of extras) {
    ordered.push({
      categoria: cat,
      productos: sortProductosBanda(byCat.get(cat)).slice(0, perCat),
    });
  }

  if (byCat.has("Otro") && byCat.get("Otro").length) {
    ordered.push({
      categoria: "Otro",
      productos: sortProductosBanda(byCat.get("Otro")).slice(0, perCat),
    });
  }

  return ordered.slice(0, maxCats);
}

/** Abre el catálogo filtrado por categoría (sessionStorage + navegación SPA). */
export function irACatalogoCategoria(setPage, categoria) {
  const cat = categoriaCanon(categoria) || "Todos";
  try {
    sessionStorage.setItem("farmacapital_cat", cat);
    sessionStorage.removeItem("farmacapital_busq");
  } catch {
    /* ignore */
  }
  setPage?.("catalogo", { rx: false });
}
