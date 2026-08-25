/** Compensación oficial de Mercado Pago por recarga / pago de servicio (Point). */
export const COMPENSACION_MP_TASA = 0.01;
export const TZ_FARMACIA = "America/Mexico_City";

/** Fecha civil de la farmacia (YYYY-MM-DD), no la del navegador en Europa. */
export function fechaLocalMexico(d = new Date()) {
  return new Intl.DateTimeFormat("en-CA", {
    timeZone: TZ_FARMACIA,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).format(d);
}

export function esMismoDiaMexico(iso, dia = fechaLocalMexico()) {
  if (!iso) return false;
  const dt = iso instanceof Date ? iso : new Date(iso);
  if (Number.isNaN(dt.getTime())) return false;
  return fechaLocalMexico(dt) === dia;
}

/** Recargo de mostrador por servicio. No lo pone Mercado Pago: lo pone FarmaCapital. */
export const CATALOGO_SERVICIOS = [
  { id: "telcel", categoria: "recarga", proveedor: "Telcel", comision: 5, emoji: "📱" },
  { id: "movistar", categoria: "recarga", proveedor: "Movistar", comision: 5, emoji: "📱" },
  { id: "att", categoria: "recarga", proveedor: "AT&T", comision: 5, emoji: "📱" },
  { id: "unefon", categoria: "recarga", proveedor: "Unefon", comision: 5, emoji: "📱" },
  { id: "cfe", categoria: "luz", proveedor: "CFE", comision: 8, emoji: "💡" },
  { id: "telmex", categoria: "telefonia", proveedor: "Telmex", comision: 8, emoji: "☎️" },
  { id: "totalplay", categoria: "telefonia", proveedor: "Totalplay", comision: 8, emoji: "📺" },
  { id: "izzi", categoria: "telefonia", proveedor: "Izzi", comision: 8, emoji: "📺" },
  { id: "sky", categoria: "tv", proveedor: "Sky", comision: 10, emoji: "📡" },
  { id: "agua", categoria: "agua", proveedor: "Agua (local)", comision: 8, emoji: "💧" },
  { id: "gas", categoria: "gas", proveedor: "Gas Natural", comision: 8, emoji: "🔥" },
  { id: "otro", categoria: "otro", proveedor: "Otro servicio", comision: 10, emoji: "📋" },
];

/** Recargo fijo del catálogo. El piso no lo captura. */
export function recargoCatalogoDe(idOrProveedor) {
  const key = String(idOrProveedor || "").trim().toLowerCase();
  const hit = CATALOGO_SERVICIOS.find(
    (s) => s.id === key || String(s.proveedor).toLowerCase() === key
  );
  return money2(hit?.comision ?? 5);
}

/** Recargo de farmacia: no se guarda en cero. El dueño puede corregir después. */
export function recargoEsValido(comision) {
  return money2(comision) > 0;
}

export function money2(n) {
  const x = Number(n);
  if (!Number.isFinite(x)) return 0;
  return Math.round(x * 100) / 100;
}

/** 1% del monto recargado. Entra al saldo MP, no al cajón. */
export function compensacionMpDe(montoServicio) {
  const n = money2(montoServicio);
  if (n <= 0) return 0;
  return money2(n * COMPENSACION_MP_TASA);
}

/** Lo que sale del saldo MP al fondear la recarga (débito bruto). */
export function costoLiquidacionDe(montoServicio) {
  const n = money2(montoServicio);
  return n > 0 ? n : 0;
}

export function utilidadServicio({ comision = 0, compensacionMp = 0 } = {}) {
  return money2(money2(comision) + money2(compensacionMp));
}

/** Si el API aún no manda compensacion_mp, se estima al 1%. */
export function compensacionMpDeFila(row) {
  if (!row) return 0;
  if (row.compensacion_mp != null && row.compensacion_mp !== "") {
    const n = money2(row.compensacion_mp);
    if (Number.isFinite(n)) return n;
  }
  return compensacionMpDe(row.monto_servicio);
}

export const SALDO_MP_MINIMO_DEFAULT = 500;
export const CLAVES_SALDO_MP = ["saldo_mp_recargas", "saldo_mp_recargas_minimo"];

/** MP no avisa. FarmaCapital sí, si el admin cargó el saldo. */
export function parseSaldoConfig(rows) {
  const map = Object.fromEntries((rows || []).map((r) => [r.clave, r.valor]));
  const raw = map.saldo_mp_recargas;
  const configurado = raw != null && String(raw).trim() !== "";
  const saldo = configurado ? money2(raw) : null;
  const minimoRaw = money2(map.saldo_mp_recargas_minimo);
  const minimo = minimoRaw > 0 ? minimoRaw : SALDO_MP_MINIMO_DEFAULT;
  const bajo = configurado && saldo <= minimo;
  return { configurado, saldo, minimo, bajo };
}

/** Título del ticket que ve el cliente (sin jerga de MP). */
export function tituloTicketServicio(categoria, proveedor) {
  const prov = String(proveedor || "").trim() || "SERVICIO";
  const cat = String(categoria || "").toLowerCase();
  if (cat === "recarga") return `RECARGA ${prov}`.toUpperCase();
  return `PAGO ${prov}`.toUpperCase();
}

export function labelMetodoServicio(metodo) {
  const m = String(metodo || "").toLowerCase();
  if (m === "tarjeta") return "Tarjeta Point";
  if (m === "efectivo") return "Efectivo";
  return metodo || "Efectivo";
}
