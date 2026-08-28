/** Catálogo / inventario en vivo: refresca datos sin cambiar de página ni recargar. */

export const CATALOGO_VIVO_EVENT = "fc-catalogo-vivo";
export const CATALOGO_VIVO_CHANNEL = "farmacapital-catalogo-vivo";
export const CATALOGO_VIVO_DEBOUNCE_MS = 450;
export const CATALOGO_VIVO_TABLAS = ["productos", "lotes", "producto_imagenes"];

export function detalleCatalogoCambio(extra = {}) {
  return { at: Date.now(), ...extra };
}

export function avisarCatalogoCambio(extra = {}) {
  const detalle = detalleCatalogoCambio(extra);
  try {
    window.dispatchEvent(new CustomEvent(CATALOGO_VIVO_EVENT, { detail: detalle }));
  } catch (_) { /* noop */ }
  try {
    if (typeof BroadcastChannel !== "undefined") {
      const ch = new BroadcastChannel(CATALOGO_VIVO_CHANNEL);
      ch.postMessage(detalle);
      ch.close();
    }
  } catch (_) { /* noop */ }
  return detalle;
}

export function crearDebounceCatalogo(fn, ms = CATALOGO_VIVO_DEBOUNCE_MS) {
  let t = null;
  const run = (...args) => {
    if (t) clearTimeout(t);
    t = setTimeout(() => {
      t = null;
      fn(...args);
    }, ms);
  };
  run.cancel = () => {
    if (t) clearTimeout(t);
    t = null;
  };
  return run;
}

/**
 * Escucha cambios locales (misma pestaña), otras pestañas y Realtime de Supabase.
 * Llama `onRefresh(detalle)` ya con debounce. No navega ni hace location.reload.
 */
export function suscribirCatalogoVivo(onRefresh, opts = {}) {
  const {
    supabase,
    debounceMs = CATALOGO_VIVO_DEBOUNCE_MS,
    tablas = CATALOGO_VIVO_TABLAS,
  } = opts;

  const debounced = crearDebounceCatalogo((detalle) => {
    try { onRefresh(detalle || {}); } catch (_) { /* noop */ }
  }, debounceMs);

  const onLocal = (ev) => debounced(ev?.detail || {});
  if (typeof window !== "undefined") {
    window.addEventListener(CATALOGO_VIVO_EVENT, onLocal);
  }

  let bc = null;
  try {
    if (typeof BroadcastChannel !== "undefined") {
      bc = new BroadcastChannel(CATALOGO_VIVO_CHANNEL);
      bc.onmessage = (ev) => debounced(ev?.data || {});
    }
  } catch (_) { /* noop */ }

  let channel = null;
  if (supabase && typeof supabase.channel === "function") {
    const id = `catalogo-vivo-${Math.random().toString(36).slice(2, 10)}`;
    let ch = supabase.channel(id);
    for (const table of tablas) {
      ch = ch.on(
        "postgres_changes",
        { event: "*", schema: "public", table },
        (payload) => debounced({
          origen: "realtime",
          table: payload?.table || table,
          event: payload?.eventType || payload?.event,
        })
      );
    }
    channel = ch.subscribe();
  }

  return () => {
    debounced.cancel();
    if (typeof window !== "undefined") {
      window.removeEventListener(CATALOGO_VIVO_EVENT, onLocal);
    }
    try { bc?.close(); } catch (_) { /* noop */ }
    if (channel && supabase) {
      try { supabase.removeChannel(channel); } catch (_) { /* noop */ }
    }
  };
}
