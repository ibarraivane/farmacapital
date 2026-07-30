/** Alertas de mostrador: sonido, cola local y helpers. */

export const STAFF_ALERT_STORAGE = {
  seen: "farmacapital_staff_seen_v1",
  snoozed: "farmacapital_staff_snoozed_v1",
  mute: "farmacapital_staff_mute",
};

export function isStaffAlertsMuted() {
  try {
    return localStorage.getItem(STAFF_ALERT_STORAGE.mute) === "1";
  } catch {
    return false;
  }
}

export function setStaffAlertsMuted(muted) {
  try {
    if (muted) localStorage.setItem(STAFF_ALERT_STORAGE.mute, "1");
    else localStorage.removeItem(STAFF_ALERT_STORAGE.mute);
  } catch {
    /* noop */
  }
}

function readJson(key, fallback) {
  try {
    const raw = localStorage.getItem(key);
    return raw ? JSON.parse(raw) : fallback;
  } catch {
    return fallback;
  }
}

function writeJson(key, val) {
  try {
    localStorage.setItem(key, JSON.stringify(val));
  } catch {
    /* noop */
  }
}

export function staffAlertKey(type, id) {
  return `${type}:${String(id)}`;
}

export function markStaffAlertSeen(key) {
  const seen = readJson(STAFF_ALERT_STORAGE.seen, {});
  seen[key] = Date.now();
  const entries = Object.entries(seen).sort((a, b) => b[1] - a[1]).slice(0, 200);
  writeJson(STAFF_ALERT_STORAGE.seen, Object.fromEntries(entries));
}

export function isStaffAlertSeen(key) {
  const seen = readJson(STAFF_ALERT_STORAGE.seen, {});
  return !!seen[key];
}

export function snoozeStaffAlert(key, minutes = 2) {
  const snoozed = readJson(STAFF_ALERT_STORAGE.snoozed, {});
  snoozed[key] = Date.now() + minutes * 60 * 1000;
  writeJson(STAFF_ALERT_STORAGE.snoozed, snoozed);
}

export function isStaffAlertSnoozed(key) {
  const snoozed = readJson(STAFF_ALERT_STORAGE.snoozed, {});
  const until = snoozed[key];
  if (!until) return false;
  if (Date.now() > until) {
    delete snoozed[key];
    writeJson(STAFF_ALERT_STORAGE.snoozed, snoozed);
    return false;
  }
  return true;
}

let _audioCtx = null;

function getAudioCtx() {
  if (typeof window === "undefined") return null;
  if (!_audioCtx) {
    const AC = window.AudioContext || window.webkitAudioContext;
    if (!AC) return null;
    _audioCtx = new AC();
  }
  if (_audioCtx.state === "suspended") {
    void _audioCtx.resume();
  }
  return _audioCtx;
}

/** Tonos distintos: pedido = campana doble; cita = tono ascendente. */
export function playStaffAlertSound(type = "pedido") {
  if (isStaffAlertsMuted()) return;
  const ctx = getAudioCtx();
  if (!ctx) return;

  const playTone = (freq, start, dur, gain = 0.12) => {
    const osc = ctx.createOscillator();
    const g = ctx.createGain();
    osc.type = "sine";
    osc.frequency.value = freq;
    g.gain.setValueAtTime(0, ctx.currentTime + start);
    g.gain.linearRampToValueAtTime(gain, ctx.currentTime + start + 0.02);
    g.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + start + dur);
    osc.connect(g);
    g.connect(ctx.destination);
    osc.start(ctx.currentTime + start);
    osc.stop(ctx.currentTime + start + dur + 0.05);
  };

  if (type === "cita") {
    playTone(523, 0, 0.18, 0.14);
    playTone(659, 0.16, 0.22, 0.14);
    playTone(784, 0.32, 0.28, 0.12);
  } else {
    playTone(880, 0, 0.12, 0.15);
    playTone(988, 0.14, 0.14, 0.15);
    playTone(880, 0.32, 0.12, 0.13);
  }
}

export function formatStaffAlertTime(isoOrDate) {
  try {
    const d = isoOrDate ? new Date(isoOrDate) : new Date();
    return d.toLocaleTimeString("es-MX", { hour: "2-digit", minute: "2-digit" });
  } catch {
    return "";
  }
}

export function buildPedidoAlert(row) {
  const total = parseFloat(row?.total || 0);
  const cliente =
    row?.clientes?.nombre ||
    row?.guest_nombre ||
    "Cliente";
  const tel =
    row?.clientes?.telefono ||
    row?.guest_telefono ||
    "";
  return {
    type: "pedido",
    id: row.id,
    key: staffAlertKey("pedido", row.id),
    titulo: "Nuevo pedido online",
    subtitulo: `#${row.id} · ${cliente}${tel ? ` · ${tel}` : ""}`,
    detalle: `$${total.toFixed(2)} · ${row.tipo_entrega === "envio" ? "Envío" : "Pick-up en farmacia"}`,
    col: "#1E3ABA",
    icon: "🛒",
    row,
    createdAt: row.created_at || new Date().toISOString(),
  };
}

export function buildCitaAlert(row) {
  const nombre = row?.nombre || "Paciente";
  const tel = row?.telefono || "";
  const fecha = row?.fecha || "";
  const hora = row?.hora || "";
  const canal = row?.canal === "web" ? "En línea" : row?.canal || "";
  return {
    type: "cita",
    id: row.id,
    key: staffAlertKey("cita", row.id),
    titulo: "Nueva cita agendada",
    subtitulo: `${nombre}${tel ? ` · ${tel}` : ""}`,
    detalle: `${fecha ? `${fecha} · ` : ""}${hora} hrs${canal ? ` · ${canal}` : ""}`,
    col: "#7c3aed",
    icon: "📅",
    row,
    createdAt: row.created_at || new Date().toISOString(),
  };
}
