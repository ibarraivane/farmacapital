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

/** Recargo de mostrador por servicio. No lo pone Mercado Pago: lo pone FarmaCapital.
 *  Recargas (tiempo aire): comision 0. Recibos (CFE, Sky…): sí llevan recargo. */
export const CATALOGO_SERVICIOS = [
  { id: "telcel", categoria: "recarga", proveedor: "Telcel", comision: 0, emoji: "📱" },
  { id: "movistar", categoria: "recarga", proveedor: "Movistar", comision: 0, emoji: "📱" },
  { id: "att", categoria: "recarga", proveedor: "AT&T", comision: 0, emoji: "📱" },
  { id: "unefon", categoria: "recarga", proveedor: "Unefon", comision: 0, emoji: "📱" },
  { id: "movilidad-cdmx", categoria: "recarga", proveedor: "Tarjeta Movilidad CDMX", comision: 0, emoji: "🚇" },
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
  return money2(hit?.comision ?? 0);
}

/** Recargas van en 0. Recibos de servicio sí llevan recargo.
 *  La RPC registrar_pago_servicio_pos debe usar la misma regla. */
export function recargoEsValido(comision, categoria) {
  const n = money2(comision);
  if (String(categoria || "").toLowerCase() === "recarga") return n === 0;
  return n > 0;
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

export const METODOS_PAGO_SERVICIO = ["efectivo", "tarjeta"];

export function normalizarMetodoServicio(metodo) {
  const m = String(metodo || "").toLowerCase().trim();
  if (m === "tarjeta" || m === "bbva_terminal" || m === "mercadopago_point") return "tarjeta";
  return "efectivo";
}

export function labelMetodoServicio(metodo) {
  const m = normalizarMetodoServicio(metodo);
  if (m === "tarjeta") return "Tarjeta";
  return "Efectivo";
}

/** Totales del día para POS Servicios. Tarjeta no se mezcla con el cajón. */
export function resumenPagosServicioDia(rows) {
  return (Array.isArray(rows) ? rows : []).reduce(
    (acc, row) => {
      const cobrado = money2(row?.total_cobrado);
      const recargo = money2(row?.comision);
      const comp = compensacionMpDeFila(row);
      acc.ops += 1;
      acc.total = money2(acc.total + cobrado);
      acc.comision = money2(acc.comision + recargo);
      acc.compensacionMp = money2(acc.compensacionMp + comp);
      acc.utilidad = money2(acc.utilidad + utilidadServicio({ comision: recargo, compensacionMp: comp }));
      const metodo = normalizarMetodoServicio(row?.metodo_pago);
      if (metodo === "tarjeta") acc.tarjeta = money2(acc.tarjeta + cobrado);
      else acc.efectivo = money2(acc.efectivo + cobrado);
      return acc;
    },
    { ops: 0, total: 0, comision: 0, compensacionMp: 0, utilidad: 0, efectivo: 0, tarjeta: 0 },
  );
}

/** Flujo de caja: el cajón solo cuenta efectivo. Si el SQL aún no parte tarjeta, todo se trata como cajón. */
export function desgloseCobroServicios(cubetas) {
  const rawTarjeta = cubetas?.tarjeta_cobrada_servicios;
  const hasTarjeta = rawTarjeta != null && rawTarjeta !== "";
  const tarjeta = hasTarjeta ? money2(rawTarjeta) : 0;
  const cajon = money2(cubetas?.cajon_cobrado_servicios);
  return {
    efectivo: cajon,
    tarjeta,
    total: money2(cajon + tarjeta),
  };
}
