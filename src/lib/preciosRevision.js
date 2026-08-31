/**
 * Revisión de precios tras el bot.
 * El bot solo escribe referencias de mercado. Nunca acepta.
 * Subir / Bajar / Aceptar aparecen mientras haya un toque del bot
 * más nuevo que la última decisión humana de ese SKU.
 */

export const CLAVE_REVISION_PRECIOS = "precios_revision_venta";

export function parseRevisionState(raw) {
  let o = raw;
  if (typeof raw === "string") {
    try { o = JSON.parse(raw); } catch { o = null; }
  }
  if (!o || typeof o !== "object") return { epoch: 0, porId: {} };
  const epoch = Number(o.epoch);
  const src = o.porId && typeof o.porId === "object" ? o.porId : o;
  const porId = {};
  for (const [k, v] of Object.entries(src)) {
    if (k === "epoch" || k === "porId") continue;
    const id = Number(k);
    if (!Number.isFinite(id)) continue;
    const at = Number(v && typeof v === "object" ? v.at : v);
    if (!Number.isFinite(at)) continue;
    porId[id] = {
      at,
      huella: v && typeof v === "object" ? String(v.huella || "") : "",
    };
  }
  return {
    epoch: Number.isFinite(epoch) ? epoch : 0,
    porId,
  };
}

export function serializeRevisionState(state) {
  return JSON.stringify({
    epoch: Number.isFinite(Number(state?.epoch)) ? Number(state.epoch) : 0,
    porId: state?.porId || {},
  });
}

/** No sella Date.now(): eso escondía todas las refs del bot. */
export function asegurarEpoch(state, _now = Date.now()) {
  const epoch = Number(state?.epoch);
  return {
    epoch: Number.isFinite(epoch) ? epoch : 0,
    porId: { ...(state?.porId || {}) },
  };
}

export function huellaMercado({ refMin, sugerido } = {}) {
  const r = refMin == null || !Number.isFinite(Number(refMin))
    ? ""
    : String(Math.round(Number(refMin) * 100) / 100);
  const s = sugerido == null || !Number.isFinite(Number(sugerido))
    ? ""
    : String(Math.round(Number(sugerido) * 100) / 100);
  return `${r}|${s}`;
}

/** Pendiente si el bot tocó el SKU y nadie lo decidió después. El epoch global no cuenta. */
export function esPendienteRevision({ botTs, revisado } = {}) {
  if (botTs == null || !Number.isFinite(Number(botTs))) return false;
  const corte = revisado?.at != null ? Number(revisado.at) : 0;
  return Number(botTs) > corte;
}

export function accionesRevisionFila({ pendiente, accion, sugerido } = {}) {
  if (!pendiente || sugerido == null) {
    return { subir: false, bajar: false, aceptar: false };
  }
  return {
    subir: accion === "subir",
    bajar: accion === "bajar",
    aceptar: true,
  };
}

export function botTsMasReciente(...ts) {
  const nums = ts.map(Number).filter((n) => Number.isFinite(n));
  return nums.length ? Math.max(...nums) : null;
}

export async function cargarRevisionPrecios(client) {
  const { data, error } = await client
    .from("configuracion")
    .select("valor")
    .eq("clave", CLAVE_REVISION_PRECIOS)
    .maybeSingle();
  if (error && !/configuracion/.test(error.message || "")) {
    return { state: { epoch: 0, porId: {} }, persistirEpoch: false };
  }
  const parsed = parseRevisionState(data?.valor);
  return { state: asegurarEpoch(parsed), persistirEpoch: false };
}

export async function guardarRevisionPrecios(client, state) {
  const tok = typeof sessionStorage !== "undefined"
    ? sessionStorage.getItem("farmacapital_session_token")
    : "";
  if (!tok) return { error: { message: "Sesión no iniciada" } };
  return client.rpc("empleado_upsert_configuracion", {
    p_session_token: tok,
    p_clave: CLAVE_REVISION_PRECIOS,
    p_valor: serializeRevisionState(state),
  });
}

export function marcarRevisados(state, ids, extra = {}, now = Date.now()) {
  const epoch = Number(state?.epoch);
  const next = {
    epoch: Number.isFinite(epoch) ? epoch : 0,
    porId: { ...(state?.porId || {}) },
  };
  for (const id of ids || []) {
    const n = Number(id);
    if (!Number.isFinite(n)) continue;
    const prev = next.porId[n] || {};
    next.porId[n] = {
      at: now,
      huella: extra[n]?.huella ?? extra[id]?.huella ?? prev.huella ?? "",
    };
  }
  return next;
}
