/** Etiquetas y reglas puras del módulo "Lo que buscan" (pedidos de mostrador). */

export const ESTADOS_SOLICITUD = [
  { id: "pendiente", label: "Pendiente", hint: "Anotado, aún no se decide compra" },
  { id: "pedir", label: "Pedir", hint: "Hay que incluirlo en el próximo pedido" },
  { id: "pedido", label: "Pedido", hint: "Ya se pidió al proveedor" },
  { id: "llego", label: "Llegó", hint: "Ya está en anaquel / listo para avisar" },
  { id: "descartado", label: "Descartado", hint: "No se va a comprar" },
];

export const URGENCIAS = [
  { id: "hoy", label: "Hoy" },
  { id: "manana", label: "Mañana" },
  { id: "sin_prisa", label: "Sin prisa" },
];

export const FILTROS_LISTA = [
  { id: "abiertas", label: "Abiertas" },
  { id: "pendiente", label: "Pendientes" },
  { id: "pedir", label: "A pedir" },
  { id: "pedido", label: "Pedidos" },
  { id: "llego", label: "Llegaron" },
  { id: "descartado", label: "Descartados" },
  { id: "", label: "Todas" },
];

export const PAGOS = [
  { id: "nada", label: "Sin anticipo" },
  { id: "deposito", label: "Dejó depósito" },
  { id: "completo", label: "Pagó todo" },
];

export function etiquetaEstado(estado) {
  return ESTADOS_SOLICITUD.find((e) => e.id === estado)?.label || estado || "—";
}

export function etiquetaUrgencia(urgencia) {
  return URGENCIAS.find((u) => u.id === urgencia)?.label || urgencia || "—";
}

export function etiquetaTipo(tipo) {
  if (tipo === "agotado") return "Agotado en tienda";
  if (tipo === "en_catalogo") return "En catálogo (con stock)";
  if (tipo === "no_catalogo") return "No está en catálogo";
  return tipo || "—";
}

export function etiquetaOrigen(origen) {
  if (origen === "tienda") return "Tienda web";
  return "Mostrador";
}

export function etiquetaPago(pagoTipo, monto) {
  if (pagoTipo === "deposito") {
    return monto != null && Number(monto) > 0
      ? `Depósito $${Number(monto).toLocaleString("es-MX", { minimumFractionDigits: 0 })}`
      : "Dejó depósito";
  }
  if (pagoTipo === "completo") {
    return monto != null && Number(monto) > 0
      ? `Pagó todo $${Number(monto).toLocaleString("es-MX", { minimumFractionDigits: 0 })}`
      : "Pagó todo";
  }
  return "Sin anticipo";
}

/** Siguientes estados útiles desde el actual (botones rápidos). */
export function siguientesEstados(estado) {
  switch (estado) {
    case "pendiente":
      return ["pedir", "pedido", "llego", "descartado"];
    case "pedir":
      return ["pedido", "llego", "descartado", "pendiente"];
    case "pedido":
      return ["llego", "descartado", "pedir"];
    case "llego":
      return ["pendiente"];
    case "descartado":
      return ["pendiente"];
    default:
      return ["pendiente", "pedir", "pedido", "llego", "descartado"];
  }
}

export function normalizarTextoSolicitud(raw) {
  return String(raw || "").trim().replace(/\s+/g, " ").slice(0, 200);
}

export function puedeGuardarSolicitud({ texto, cantidad }) {
  const t = normalizarTextoSolicitud(texto);
  const n = Number(cantidad);
  return t.length >= 2 && Number.isFinite(n) && n >= 1 && n <= 999;
}
