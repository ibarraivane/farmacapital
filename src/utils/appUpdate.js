/** Tras un deploy, tienda y admin recargan solas. No tumba un cobro ni un Recibir a medias. */

export const VERSION_URL = "/version.json";
export const UPDATE_CHANNEL = "farmacapital-app-update";
export const POLL_MS = 45_000;

const blockers = new Set();

export function buildIdLocal(win = typeof window !== "undefined" ? window : undefined) {
  return String(win?.__FARMACAPITAL_BUILD_ID__ || "").trim();
}

export function versionRemotaEsNueva(localId, remote) {
  const local = String(localId || "").trim();
  const remoteId = String(remote?.id || "").trim();
  if (!local || !remoteId) return false;
  return remoteId !== local;
}

export function setBloqueaReloadApp(on, reason = "default") {
  if (on) blockers.add(reason);
  else blockers.delete(reason);
}

export function paginaEnTrabajoCritico() {
  return blockers.size > 0;
}

export function parseVersionJson(raw) {
  if (!raw || typeof raw !== "object") return null;
  const id = String(raw.id || "").trim();
  if (!id) return null;
  return { id, builtAt: raw.builtAt || null };
}

async function leerVersionRemota() {
  const resp = await fetch(`${VERSION_URL}?t=${Date.now()}`, { cache: "no-store" });
  if (!resp.ok) return null;
  return parseVersionJson(await resp.json());
}

function recargarAhora() {
  try {
    if (sessionStorage.getItem("farmacapital_app_updating") === "1") return;
    sessionStorage.setItem("farmacapital_app_updating", "1");
  } catch (_) { /* noop */ }
  try {
    const u = new URL(window.location.href);
    u.searchParams.set("_fcv", String(Date.now()));
    window.location.replace(u.toString());
  } catch (_) {
    window.location.reload();
  }
}

export function aplicarNuevaVersion({ forzar = false } = {}) {
  if (!forzar && paginaEnTrabajoCritico()) {
    try { window.__FC_RELOAD_PENDIENTE__ = true; } catch (_) { /* noop */ }
    return { recargo: false, diferido: true };
  }
  try {
    if (typeof BroadcastChannel !== "undefined") {
      const ch = new BroadcastChannel(UPDATE_CHANNEL);
      ch.postMessage({ type: "FC_RELOAD" });
      ch.close();
    }
  } catch (_) { /* noop */ }
  recargarAhora();
  return { recargo: true, diferido: false };
}

async function checarDeploy() {
  const local = buildIdLocal();
  if (!local) return;
  try {
    const remote = await leerVersionRemota();
    if (versionRemotaEsNueva(local, remote)) aplicarNuevaVersion();
  } catch (_) { /* red caída: no recargar */ }
}

async function pedirUpdateServiceWorker() {
  if (!("serviceWorker" in navigator)) return;
  try {
    const regs = await navigator.serviceWorker.getRegistrations();
    await Promise.all(regs.map((r) => r.update().catch(() => {})));
  } catch (_) { /* noop */ }
}

export function iniciarVigilanciaDeploy() {
  if (typeof window === "undefined") return () => {};
  if (process.env.NODE_ENV !== "production") return () => {};
  if (!buildIdLocal()) return () => {};

  try { sessionStorage.removeItem("farmacapital_app_updating"); } catch (_) { /* noop */ }

  const tick = () => {
    if (window.__FC_RELOAD_PENDIENTE__ && !paginaEnTrabajoCritico()) {
      aplicarNuevaVersion({ forzar: true });
      return;
    }
    void checarDeploy();
    void pedirUpdateServiceWorker();
  };

  const onVisible = () => {
    if (document.visibilityState === "visible") tick();
  };
  const onSwMsg = (e) => {
    if (e.data?.type === "FC_SW_UPDATED") aplicarNuevaVersion();
  };
  const onController = () => aplicarNuevaVersion();

  let channel;
  try {
    channel = new BroadcastChannel(UPDATE_CHANNEL);
    channel.onmessage = (e) => {
      if (e.data?.type === "FC_RELOAD") recargarAhora();
    };
  } catch (_) { /* Safari viejo */ }

  document.addEventListener("visibilitychange", onVisible);
  window.addEventListener("online", tick);
  window.addEventListener("pageshow", tick);
  navigator.serviceWorker?.addEventListener("message", onSwMsg);
  navigator.serviceWorker?.addEventListener("controllerchange", onController);

  const interval = setInterval(tick, POLL_MS);
  setTimeout(tick, 8_000);

  return () => {
    clearInterval(interval);
    document.removeEventListener("visibilitychange", onVisible);
    window.removeEventListener("online", tick);
    window.removeEventListener("pageshow", tick);
    navigator.serviceWorker?.removeEventListener("message", onSwMsg);
    navigator.serviceWorker?.removeEventListener("controllerchange", onController);
    try { channel?.close(); } catch (_) { /* noop */ }
  };
}
