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

function cargarPrincipales() {
  if (principales) return Promise.resolve(principales);
  if (cargaPrincipales) return cargaPrincipales;

  cargaPrincipales = supabase
    .from("producto_imagenes")
    .select("producto_id,url")
    .eq("es_principal", true)
    .then(({ data, error }) => {
      const mapa = new Map();
      if (!error) {
        for (const r of data || []) {
          const url = normalizar(r.url);
          if (url && !mapa.has(r.producto_id)) mapa.set(r.producto_id, url);
        }
      }
      principales = mapa;
      cargaPrincipales = null;
      version += 1;
      suscriptores.forEach((fn) => fn(version));
      return mapa;
    })
    .catch(() => {
      principales = new Map();
      cargaPrincipales = null;
      return principales;
    });

  return cargaPrincipales;
}

/**
 * Devuelve una función `(productoId) => url` con la foto principal del
 * catálogo (Rappi si existe). Las rejillas la prefieren sobre el packshot
 * viejo de `imagen_url`.
 */
export function useImagenesPrincipales() {
  const [v, setV] = useState(version);

  useEffect(() => {
    let vivo = true;
    const avisar = (nueva) => { if (vivo) setV(nueva); };
    suscriptores.add(avisar);
    cargarPrincipales();
    return () => { vivo = false; suscriptores.delete(avisar); };
  }, []);

  return useCallback(
    (productoId) => (productoId == null ? "" : principales?.get(Number(productoId)) || ""),
    // v fuerza una nueva referencia cuando el mapa termina de cargar.
    [v],
  );
}
