/**
 * Revisión de precios tras el bot.
 * Si el bot escribe una ref más nueva que la última decisión (o que el
 * epoch al estrenar la feature), vuelven Subir / Bajar / Aceptar.
 * Aceptar no cambia el PVP: solo guarda que ya se vio esa corrida.
 */

export const CLAVE_REVISION_PRECIOS = "precios_revision_venta";

export function parseRevisionState(raw) {
  let o = raw;
  if (typeof raw === "string") {
    try { o = JSON.parse(raw); } catch { o = null; }
  }
  if (!o || typeof o !== "object") return { epoch: null, porId: {} };
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
    epoch: Number.isFinite(epoch) ? epoch : null,
    porId,
  };
}

export function serializeRevisionState(state) {
  return JSON.stringify({
    epoch: state?.epoch ?? null,
    porId: state?.porId || {},
  });
}

export function asegurarEpoch(state, now = Date.now()) {
  if (state?.epoch) return state;
  return { epoch: now, porId: { ...(state?.porId || {}) } };
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

/** ¿El bot tocó este SKU después de la última decisión (o del epoch)? */
export function esPendienteRevision({ botTs, revisado, epoch } = {}) {
  if (botTs == null || !Number.isFinite(Number(botTs))) return false;
  const corte = revisado?.at != null ? revisado.at : (epoch ?? 0);
  return Number(botTs) > Number(corte);
}

export function accionesRevisionFila({
  pendiente,
  accion,
  sugerido,
  exigirPendiente = true,
} = {}) {
  if (sugerido == null) {
    return { subir: false, bajar: false, aceptar: false };
  }
  if (exigirPendiente && !pendiente) {
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
    return { state: asegurarEpoch(parseRevisionState(null)), persistirEpoch: true };
  }
  const parsed = parseRevisionState(data?.valor);
  const neededEpoch = !parsed.epoch;
  return { state: asegurarEpoch(parsed), persistirEpoch: neededEpoch };
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
  const next = {
    epoch: state?.epoch ?? now,
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
