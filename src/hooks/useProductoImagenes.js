import { useCallback, useEffect, useState } from "react";
import { supabase } from "../supabase";

/**
 * Fotos de un producto para la galería.
 *
 * Si hay set de catálogo (Rappi), esa galería manda: más fotos y mejor
 * calidad. `imagen_url` solo se usa cuando no hay galería.
 */

const cache = new Map();
const enVuelo = new Map();

function normalizar(url) {
  return String(url || "").trim();
}

/** Galería Rappi primero; imagen_url solo si no hay set de catálogo. */
export function ordenarGaleriaProducto(imagenPrincipal, urlsGaleria) {
  const extra = (urlsGaleria || []).map(normalizar).filter(Boolean);
  const base = normalizar(imagenPrincipal);
  const fuentes = extra.length ? extra : (base ? [base] : []);
  const vistas = new Set();
  const imagenes = [];
  for (const url of fuentes) {
    if (vistas.has(url)) continue;
    vistas.add(url);
    imagenes.push(url);
  }
  return imagenes;
}

const URLS_VACIAS = [];
const IMAGENES_PAGE = 1000;

/**
 * Orden de la tarjeta: la marcada es_principal va primero (packshot propio
 * si ya está en el CDN). Si esa URL 404 / HTML del SPA, la tarjeta prueba
 * el resto de la galería — las mismas fotos que la ficha.
 */
export function ordenarUrlsTarjeta(filas) {
  const rows = (filas || [])
    .map((r) => ({
      url: normalizar(r?.url),
      posicion: Number(r?.posicion) || 0,
      principal: !!r?.es_principal,
    }))
    .filter((r) => r.url);
  rows.sort((a, b) => {
    if (a.principal !== b.principal) return a.principal ? -1 : 1;
    return a.posicion - b.posicion;
  });
  const vistas = new Set();
  const urls = [];
  for (const r of rows) {
    if (vistas.has(r.url)) continue;
    vistas.add(r.url);
    urls.push(r.url);
  }
  return urls;
}

export function mapaUrlsTarjetaPorProducto(filas) {
  const porId = new Map();
  for (const r of filas || []) {
    const pid = Number(r?.producto_id);
    if (!Number.isFinite(pid)) continue;
    if (!porId.has(pid)) porId.set(pid, []);
    porId.get(pid).push(r);
  }
  const mapa = new Map();
  for (const [pid, rows] of porId) {
    const urls = ordenarUrlsTarjeta(rows);
    if (urls.length) mapa.set(pid, urls);
  }
  return mapa;
}

/** Siguiente índice de galería, o -1 si ya no hay otra URL que probar. */
export function siguienteIndiceFotoTarjeta(urls, indiceActual) {
  const i = Number(indiceActual) || 0;
  return i + 1 < (urls || []).length ? i + 1 : -1;
}

async function traer(productoId) {
  if (cache.has(productoId)) return cache.get(productoId);
  if (enVuelo.has(productoId)) return enVuelo.get(productoId);

  const promesa = supabase
    .from("producto_imagenes")
    .select("url,posicion,es_principal")
    .eq("producto_id", productoId)
    .order("posicion", { ascending: true })
    .then(({ data, error }) => {
      const urls = error ? [] : (data || []).map((r) => normalizar(r.url)).filter(Boolean);
      cache.set(productoId, urls);
      enVuelo.delete(productoId);
      return urls;
    })
    .catch(() => {
      enVuelo.delete(productoId);
      return [];
    });

  enVuelo.set(productoId, promesa);
  return promesa;
}

/** Limpia el caché tras editar las fotos de un producto (o de todos). */
export function invalidarImagenesProducto(productoId) {
  if (productoId == null) cache.clear();
  else cache.delete(productoId);
  principales = null;
}

export function useProductoImagenes(productoId, imagenPrincipal = "") {
  const base = normalizar(imagenPrincipal);
  const [extra, setExtra] = useState(() => cache.get(productoId) || []);
  const [cargando, setCargando] = useState(() => productoId != null && !cache.has(productoId));

  useEffect(() => {
    let vivo = true;
    if (productoId == null) {
      setExtra([]);
      setCargando(false);
      return undefined;
    }
    if (cache.has(productoId)) {
      setExtra(cache.get(productoId));
      setCargando(false);
      return undefined;
    }
    setCargando(true);
    traer(productoId).then((urls) => {
      if (!vivo) return;
      setExtra(urls);
      setCargando(false);
    });
    return () => { vivo = false; };
  }, [productoId]);

  return { imagenes: ordenarGaleriaProducto(base, extra), cargando };
}

// ── Fotos principales de todo el catálogo ────────────────────────────
// Las rejillas del POS pintan decenas de productos a la vez: una consulta por
// tarjeta sería absurda. Esto trae de una sola vez la principal de cada
// producto y la deja en memoria para toda la sesión.

let principales = null;
let cargaPrincipales = null;
let version = 0;
const suscriptores = new Set();

async function traerImagenesCatalogo() {
  const filas = [];
  let desde = 0;
  for (;;) {
    const { data, error } = await supabase
      .from("producto_imagenes")
      .select("producto_id,url,posicion,es_principal")
      .order("producto_id", { ascending: true })
      .order("posicion", { ascending: true })
      .range(desde, desde + IMAGENES_PAGE - 1);
    if (error) throw error;
    const lote = data || [];
    filas.push(...lote);
    if (lote.length < IMAGENES_PAGE) break;
    desde += IMAGENES_PAGE;
  }
  return filas;
}

function cargarPrincipales() {
  if (principales) return Promise.resolve(principales);
  if (cargaPrincipales) return cargaPrincipales;

  cargaPrincipales = traerImagenesCatalogo()
    .then((filas) => {
      principales = mapaUrlsTarjetaPorProducto(filas);
      cargaPrincipales = null;
      version += 1;
      suscriptores.forEach((fn) => fn(version));
      return principales;
    })
    .catch(() => {
      principales = new Map();
      cargaPrincipales = null;
      return principales;
    });

  return cargaPrincipales;
}

function useVersionImagenesCatalogo() {
  const [v, setV] = useState(version);

  useEffect(() => {
    let vivo = true;
    const avisar = (nueva) => { if (vivo) setV(nueva); };
    suscriptores.add(avisar);
    cargarPrincipales();
    return () => { vivo = false; suscriptores.delete(avisar); };
  }, []);

  return v;
}

/**
 * Devuelve una función `(productoId) => url` con la foto principal del
 * catálogo (Rappi si existe). Las rejillas la prefieren sobre el packshot
 * viejo de `imagen_url`.
 */
export function useImagenesPrincipales() {
  const v = useVersionImagenesCatalogo();
  return useCallback(
    (productoId) => {
      if (productoId == null) return "";
      const urls = principales?.get(Number(productoId));
      return (urls && urls[0]) || "";
    },
    // v fuerza una nueva referencia cuando el mapa termina de cargar.
    [v],
  );
}

/**
 * Todas las URLs de galería de un producto, principal primero.
 * La tarjeta de categoría usa esto para no quedarse en la caja si la
 * principal (catalogo-propia sin deploy) no carga.
 */
export function useUrlsImagenesProducto() {
  const v = useVersionImagenesCatalogo();
  return useCallback(
    (productoId) => {
      if (productoId == null) return URLS_VACIAS;
      return principales?.get(Number(productoId)) || URLS_VACIAS;
    },
    [v],
  );
}
