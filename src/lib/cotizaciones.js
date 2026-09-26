/**
 * Cotizaciones (oficina admin): estados, origen, números y validación.
 * Recargo marca +25% / genérico +60% sobre costo — misma regla que Recibir.
 * No es margen sobre venta. Ver margenMarkup.js.
 */

import { markupSobreCostoPct, margenSobreVentaPct, numPrecio, precioDesdeMarkup } from "./margenMarkup.js";

function tipoMargenNormalizado(tipo) {
  const t = String(tipo || "").toLowerCase();
  if (t === "marca" || t === "patente") return "marca";
  return "generico";
}

export const COTIZ_OPEN_STORAGE_KEY = "farmacapital_cotiz_open_id";

export const ESTADOS_COTIZACION = [
  { id: "nueva", label: "Nueva", hint: "Alta, aún no se busca" },
  { id: "buscando", label: "Buscando", hint: "Revisando mayoristas y precios" },
  { id: "lista", label: "Lista", hint: "Ya hay comparativa y precio de venta" },
  { id: "pedida", label: "Pedida", hint: "Ya se pidió al proveedor" },
  { id: "cerrada", label: "Cerrada", hint: "Entregada o cobrada" },
  { id: "perdida", label: "Perdida", hint: "No se consiguió o el cliente no siguió" },
];

export const ESTADOS_COTIZACION_ABIERTAS = ["nueva", "buscando", "lista", "pedida"];

export const ESTADOS_ITEM_COTIZACION = [
  { id: "pendiente", label: "Pendiente" },
  { id: "buscando", label: "Buscando" },
  { id: "elegido", label: "Elegido" },
  { id: "pedir", label: "Pedir" },
  { id: "pedido", label: "Pedido" },
  { id: "llego", label: "Llegó" },
  { id: "no_se_consigue", label: "No se consigue" },
];

export const ORIGENES_COTIZACION = [
  { id: "admin", label: "Alta admin" },
  { id: "tienda", label: "Tienda web" },
  { id: "mostrador", label: "Mostrador" },
  { id: "whatsapp", label: "WhatsApp" },
  { id: "telefono", label: "Teléfono" },
  { id: "otro", label: "Otro" },
];

export const URGENCIAS_COTIZACION = [
  { id: "hoy", label: "Hoy" },
  { id: "manana", label: "Mañana" },
  { id: "sin_prisa", label: "Sin prisa" },
];

export const FILTROS_COTIZACION = [
  { id: "abiertas", label: "Abiertas" },
  { id: "nueva", label: "Nuevas" },
  { id: "buscando", label: "Buscando" },
  { id: "lista", label: "Listas" },
  { id: "pedida", label: "Pedidas" },
  { id: "cerrada", label: "Cerradas" },
  { id: "perdida", label: "Perdidas" },
  { id: "", label: "Todas" },
];

export const TIPOS_MARGEN_COTIZACION = [
  { id: "marca", label: "Marca / patente", recargoPct: 25 },
  { id: "generico", label: "Genérico", recargoPct: 60 },
];

export const FUENTES_ATAJO_COTIZACION = [
  { id: "nadro", label: "Nadro" },
  { id: "levic", label: "Levic" },
  { id: "exprezo", label: "Exprezo" },
  { id: "dermaexpress", label: "Dermaexpress" },
  { id: "birdman", label: "Birdman" },
  { id: "ewafra", label: "Ewafra" },
  { id: "marzam", label: "Marzam" },
  { id: "farmalive", label: "Farmalive" },
  { id: "farmacity", label: "Farma City" },
  { id: "scorpion", label: "Scorpion" },
  { id: "otro", label: "Otro (escribir)" },
];

export function folioCotizacion(id) {
  const n = Number(id);
  if (!Number.isFinite(n) || n <= 0) return "C-—";
  return `C-${n}`;
}

export function etiquetaEstadoCotizacion(estado) {
  return ESTADOS_COTIZACION.find((e) => e.id === estado)?.label || estado || "—";
}

export function etiquetaEstadoItemCotizacion(estado) {
  return ESTADOS_ITEM_COTIZACION.find((e) => e.id === estado)?.label || estado || "—";
}

export function etiquetaOrigenCotizacion(origen) {
  return ORIGENES_COTIZACION.find((o) => o.id === origen)?.label || origen || "—";
}

export function etiquetaUrgenciaCotizacion(urgencia) {
  return URGENCIAS_COTIZACION.find((u) => u.id === urgencia)?.label || urgencia || "—";
}

export function etiquetaTipoMargenCotizacion(tipo) {
  const t = tipoMargenNormalizado(tipo);
  return TIPOS_MARGEN_COTIZACION.find((x) => x.id === t)?.label || t;
}

export function etiquetaLugarCotizacion(lugar) {
  const raw = String(lugar || "").trim();
  if (!raw) return "—";
  const hit = FUENTES_ATAJO_COTIZACION.find((f) => f.id === raw && f.id !== "otro");
  return hit ? hit.label : raw;
}

export function siguientesEstadosCotizacion(estado) {
  switch (estado) {
    case "nueva":
      return ["buscando", "lista", "perdida"];
    case "buscando":
      return ["lista", "pedida", "perdida", "nueva"];
    case "lista":
      return ["pedida", "buscando", "perdida"];
    case "pedida":
      return ["cerrada", "lista", "perdida"];
    case "cerrada":
      return ["pedida"];
    case "perdida":
      return ["nueva", "buscando"];
    default:
      return ["nueva", "buscando", "lista", "pedida", "cerrada", "perdida"];
  }
}

export function siguientesEstadosItemCotizacion(estado) {
  switch (estado) {
    case "pendiente":
      return ["buscando", "elegido", "no_se_consigue"];
    case "buscando":
      return ["elegido", "pedir", "no_se_consigue", "pendiente"];
    case "elegido":
      return ["pedir", "pedido", "buscando"];
    case "pedir":
      return ["pedido", "llego", "elegido"];
    case "pedido":
      return ["llego", "pedir", "no_se_consigue"];
    case "llego":
      return ["pedido"];
    case "no_se_consigue":
      return ["pendiente", "buscando"];
    default:
      return ["pendiente", "buscando", "elegido", "pedir", "pedido", "llego", "no_se_consigue"];
  }
}

export function esEstadoCotizacionAbierto(estado) {
  return ESTADOS_COTIZACION_ABIERTAS.includes(estado);
}

export function normalizarTextoItemCotizacion(raw) {
  return String(raw || "").trim().replace(/\s+/g, " ").slice(0, 200);
}

export function normalizarEanCotizacion(raw) {
  const d = String(raw || "").replace(/\D/g, "");
  return d.length >= 8 ? d : "";
}

export function itemCotizacionValido({ texto, cantidad }) {
  const t = normalizarTextoItemCotizacion(texto);
  const n = Number(cantidad);
  return t.length >= 2 && Number.isFinite(n) && n >= 1 && n <= 999;
}

function telefonoDigitos(raw) {
  return String(raw || "").replace(/\D/g, "");
}

/** Nombre (2+) o teléfono (8+), y al menos una línea válida. */
export function puedeGuardarCotizacion({ clienteNombre, clienteTelefono, items }) {
  const nombre = String(clienteNombre || "").trim();
  const tel = telefonoDigitos(clienteTelefono);
  const tieneCliente = nombre.length >= 2 || tel.length >= 8;
  const lineas = Array.isArray(items) ? items : [];
  const tieneItem = lineas.some((it) => itemCotizacionValido(it));
  return tieneCliente && tieneItem;
}

export function payloadPromoverDesdeSolicitud(s) {
  const origen = s?.origen === "tienda" ? "tienda" : "mostrador";
  return {
    cliente_nombre: String(s?.cliente_nombre || "").trim() || null,
    cliente_telefono: telefonoDigitos(s?.cliente_telefono) || null,
    cliente_email: String(s?.cliente_email || "").trim() || null,
    direccion: String(s?.direccion || "").trim() || null,
    origen,
    urgencia: URGENCIAS_COTIZACION.some((u) => u.id === s?.urgencia) ? s.urgencia : "sin_prisa",
    notas: String(s?.notas || "").trim() || null,
    solicitud_id: s?.id ?? null,
    items: [
      {
        texto: normalizarTextoItemCotizacion(s?.texto || s?.producto_nombre || ""),
        cantidad: Number(s?.cantidad) > 0 ? Number(s.cantidad) : 1,
        producto_id: s?.producto_id ?? null,
        ean: "",
        tipo_margen: "marca",
      },
    ],
  };
}

export function precioSugeridoCotizacion(costo, tipoMargen) {
  const tipo = tipoMargenNormalizado(tipoMargen);
  const recargoPct = tipo === "marca" ? 25 : 60;
  return precioDesdeMarkup(costo, recargoPct, { ceil: true });
}

/**
 * Números de un renglón: costo elegido, venta (o sugerida), recargo y margen.
 * Recargo ≠ margen. $100 × 1.25 = $125 (recargo 25%, margen 20%).
 */
function precioTecleado(texto, guardado) {
  if (texto === "" || texto == null) return guardado ?? null;
  return numPrecio(String(texto).replace(",", "."));
}

/**
 * Números del renglón mientras se teclea. El costo y el precio de la pantalla
 * cuentan aunque todavía no se haya pulsado Guardar.
 */
export function vistaNumerosProducto({
  costoTexto,
  precioTexto,
  costoGuardado,
  precioGuardado,
  cantidad,
  tipoMargen,
}) {
  return numerosLineaCotizacion({
    costo: precioTecleado(costoTexto, costoGuardado),
    precioVenta: precioTecleado(precioTexto, precioGuardado),
    cantidad,
    tipoMargen,
  });
}

export function numerosLineaCotizacion({ costo, precioVenta, cantidad, tipoMargen }) {
  const c = numPrecio(costo);
  const q = Number(cantidad);
  const cant = Number.isFinite(q) && q >= 1 ? q : 1;
  const tipo = tipoMargenNormalizado(tipoMargen);
  const sugerido = c != null && c > 0 ? precioSugeridoCotizacion(c, tipo) : null;
  const ventaIn = numPrecio(precioVenta);
  const venta = ventaIn != null && ventaIn > 0 ? ventaIn : sugerido;
  const recargoPct = c != null && venta != null ? markupSobreCostoPct(venta, c) : null;
  const margenPct = c != null && venta != null ? margenSobreVentaPct(venta, c) : null;
  const gananciaUnit = c != null && venta != null ? Math.round((venta - c) * 100) / 100 : null;
  const costoTotal = c != null ? Math.round(c * cant * 100) / 100 : null;
  const ventaTotal = venta != null ? Math.round(venta * cant * 100) / 100 : null;
  const gananciaTotal =
    gananciaUnit != null ? Math.round(gananciaUnit * cant * 100) / 100 : null;
  return {
    tipo,
    costo: c,
    cantidad: cant,
    sugerido,
    venta,
    recargoPct,
    margenPct,
    gananciaUnit,
    costoTotal,
    ventaTotal,
    gananciaTotal,
    usaSugerido: ventaIn == null || ventaIn <= 0,
  };
}

export function totalesCotizacion(items) {
  const lineas = Array.isArray(items) ? items : [];
  let costo = 0;
  let venta = 0;
  let conNumeros = 0;
  for (const it of lineas) {
    const n = numerosLineaCotizacion({
      costo: it.costo_elegido,
      precioVenta: it.precio_venta,
      cantidad: it.cantidad,
      tipoMargen: it.tipo_margen,
    });
    if (n.costoTotal == null || n.ventaTotal == null) continue;
    costo += n.costoTotal;
    venta += n.ventaTotal;
    conNumeros += 1;
  }
  if (!conNumeros) {
    return { costo: null, venta: null, ganancia: null, lineas: 0 };
  }
  return {
    costo: Math.round(costo * 100) / 100,
    venta: Math.round(venta * 100) / 100,
    ganancia: Math.round((venta - costo) * 100) / 100,
    lineas: conNumeros,
  };
}

export function resumenItemsCotizacion(items, max = 2) {
  const lineas = (Array.isArray(items) ? items : [])
    .map((it) => {
      const t = normalizarTextoItemCotizacion(it?.texto);
      if (!t) return "";
      const q = Number(it.cantidad);
      return q > 1 ? `${t} ×${q}` : t;
    })
    .filter(Boolean);
  if (!lineas.length) return "Sin productos";
  const head = lineas.slice(0, max);
  const extra = lineas.length - head.length;
  return extra > 0 ? `${head.join(" · ")} · +${extra}` : head.join(" · ");
}

export function fmtDineroCotiz(n) {
  const x = numPrecio(n);
  if (x == null) return "—";
  return x.toLocaleString("es-MX", {
    style: "currency",
    currency: "MXN",
    minimumFractionDigits: 0,
    maximumFractionDigits: 2,
  });
}

export function haceCuanto(iso, now = Date.now()) {
  if (!iso) return "—";
  const t = new Date(iso).getTime();
  if (!Number.isFinite(t)) return "—";
  const mins = Math.max(0, Math.floor((now - t) / 60000));
  if (mins < 1) return "hace un momento";
  if (mins < 60) return `hace ${mins} min`;
  const hrs = Math.floor(mins / 60);
  if (hrs < 24) return `hace ${hrs} h`;
  const dias = Math.floor(hrs / 24);
  if (dias === 1) return "hace 1 día";
  if (dias < 30) return `hace ${dias} días`;
  const meses = Math.floor(dias / 30);
  return meses === 1 ? "hace 1 mes" : `hace ${meses} meses`;
}

export function stashCotizacionAbierta(id) {
  const n = Number(id);
  if (!Number.isFinite(n) || n <= 0) return false;
  try {
    sessionStorage.setItem(COTIZ_OPEN_STORAGE_KEY, String(n));
    return true;
  } catch {
    return false;
  }
}

export function takeCotizacionAbierta() {
  try {
    const raw = sessionStorage.getItem(COTIZ_OPEN_STORAGE_KEY);
    if (raw == null) return null;
    sessionStorage.removeItem(COTIZ_OPEN_STORAGE_KEY);
    const n = Number(raw);
    return Number.isFinite(n) && n > 0 ? n : null;
  } catch {
    return null;
  }
}

/** Texto que se pega en el HTML de imprimir. */
export function escaparHtmlCotizacion(raw) {
  return String(raw ?? "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

/**
 * Documento para el cliente: ¿este renglón ya tiene precio decidido (fuente elegida)
 * o todavía se está buscando? Los "por confirmar" se muestran igual en el documento,
 * pero marcados, para no prometer un precio que puede cambiar.
 */
export function itemConfirmadoDocumento(item) {
  return (
    ["elegido", "pedir", "pedido", "llego"].includes(item?.estado) && item?.precio_venta != null
  );
}

/** Vigencia por default del documento: N días hábiles a partir de hoy, en español. */
export function vigenciaDefaultTexto(diasHabiles = 5, desde = new Date()) {
  const base = desde instanceof Date ? desde : new Date(desde);
  const d = new Date(base.getTime());
  if (!Number.isFinite(d.getTime())) return "";
  let restantes = Math.max(1, Number(diasHabiles) || 1);
  while (restantes > 0) {
    d.setDate(d.getDate() + 1);
    const dow = d.getDay();
    if (dow !== 0 && dow !== 6) restantes -= 1;
  }
  return d.toLocaleDateString("es-MX", { day: "numeric", month: "long", year: "numeric" });
}

/**
 * Importe que ve el cliente: precio de venta × cantidad.
 * No usa el costo ni el precio sugerido de la oficina.
 */
export function importeDocumentoCliente(item) {
  const p = numPrecio(item?.precio_venta);
  if (p == null || p < 0) return null;
  const q = Number(item?.cantidad);
  const cant = Number.isFinite(q) && q >= 1 ? q : 1;
  return Math.round(p * cant * 100) / 100;
}

/** Suma de importes con precio de venta. Null si ninguno está decidido. */
export function totalDocumentoCliente(items) {
  const lineas = Array.isArray(items) ? items : [];
  let venta = 0;
  let n = 0;
  for (const it of lineas) {
    const imp = importeDocumentoCliente(it);
    if (imp == null) continue;
    venta += imp;
    n += 1;
  }
  if (!n) return null;
  return Math.round(venta * 100) / 100;
}

/** Liga de WhatsApp para avisarle al cliente que su cotización ya está lista. */
export function buildCotizacionWhatsAppCliente({ telefono, nombre, folio, total, vigencia } = {}) {
  const digits = String(telefono || "").replace(/\D/g, "").slice(-10);
  if (digits.length !== 10) return "";
  const quien = nombre ? ` ${nombre}` : "";
  const totalTxt = total != null ? ` Total: ${fmtDineroCotiz(total)}.` : "";
  const vigTxt = vigencia ? ` Precio válido hasta ${vigencia}.` : "";
  const msg =
    `Hola${quien}, soy FarmaCapital. Tu cotización ${folio || ""} ya está lista.` +
    `${totalTxt}${vigTxt} Cualquier duda, contesta este WhatsApp.`;
  return `https://wa.me/52${digits}?text=${encodeURIComponent(msg)}`;
}
