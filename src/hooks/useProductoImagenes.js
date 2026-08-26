import { useCallback, useEffect, useState } from "react";
import { supabase } from "../supabase";

/**
 * Fotos de un producto para la galería.
 *
 * La foto curada de `productos.imagen_url` siempre va primero: la galería es
 * aditiva y no cambia lo que ya se ve hoy en pantalla. Detrás van las de
 * `producto_imagenes` ordenadas por posición, sin repetir la primera.
 */

const cache = new Map();
const enVuelo = new Map();

function normalizar(url) {
  return String(url || "").trim();
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

  const vistas = new Set();
  const imagenes = [];
  for (const url of [base, ...extra]) {
    if (!url || vistas.has(url)) continue;
    vistas.add(url);
    imagenes.push(url);
  }

  return { imagenes, cargando };
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
 * catálogo. Sirve de respaldo cuando el producto todavía no tiene
 * imagen_url propia: sin esto el vendedor ve un ícono en vez del empaque.
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
