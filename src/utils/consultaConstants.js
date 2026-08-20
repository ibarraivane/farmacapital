/** Precio público de consulta (MXN). Config en `configuracion.precio_consulta` puede sobreescribir. */
export const CONSULTA_PRECIO_DEFAULT = 80;
/** Reparto consulta: 70% médico, 30% farmacia (sobre el monto de la consulta cobrado). */
export const CONSULTA_PARTE_DOCTOR = 0.7;
export const CONSULTA_PARTE_FARMACIA = 0.3;

export function repartoConsulta(monto) {
  const m = Number(monto) || 0;
  return {
    doctor: Math.round(m * CONSULTA_PARTE_DOCTOR * 100) / 100,
    farmacia: Math.round(m * CONSULTA_PARTE_FARMACIA * 100) / 100,
  };
}

/** Cobrada en caja: pedido vinculado o marcada pagada. */
export function citaEstaPagada(c) {
  if (!c) return false;
  return !!(c.pedido_consulta_id || c.pago_estado === "pagada" || c.estado === "pagada");
}

/** Falta cobrar en mostrador (incluye citas en línea hasta que paguen en caja). */
export function citaPagoPendiente(c) {
  return !!c && !citaEstaPagada(c);
}

/** La doctora puede actuar como si la consulta estuviera pagada (expediente, etc.). */
export function citaPagoOk(c) {
  return citaEstaPagada(c);
}

export function labelCanal(c) {
  const k = c?.canal || "web";
  if (k === "web") return "En línea";
  if (k === "mostrador") return "Mostrador";
  if (k === "pos") return "POS";
  return k;
}

/** Badge de cobro en caja (POS / agenda / consultorio). */
export function labelEstadoPagoCita(c) {
  if (!c) return { key: "unknown", label: "—", col: "#64748b" };
  const est = String(c.estado || "").toLowerCase();
  if (est === "cancelada") return { key: "cancelada", label: "Cancelada", col: "#64748b" };
  if (est === "no_asistio") return { key: "no_asistio", label: "No asistió", col: "#64748b" };
  const consumiblesPend = (c.consumibles_consulta || []).some((x) => !x.cobrado);
  const consultaPagada = citaEstaPagada(c);
  if (consultaPagada && !consumiblesPend) {
    return { key: "pagada", label: "Pagada", col: "#16a34a" };
  }
  if (consultaPagada && consumiblesPend) {
    return { key: "consumibles", label: "Pagada · consumibles pendientes", col: "#d97706" };
  }
  if (consumiblesPend && !consultaPagada) {
    return { key: "pendiente_mix", label: "Pendiente de pago", col: "#d97706" };
  }
  return { key: "pendiente", label: "Pendiente de pago", col: "#d97706" };
}

/** Colores de franja horaria en agenda (estado de visita + pago). */
export function franjaAgendaStyle(cita, { libre = false, focoAccion = false, C, BRAND }) {
  if (!cita) {
    return {
      background: libre ? C.greenDim : C.bg,
      border: `1px solid ${C.border}`,
      boxShadow: undefined,
    };
  }
  let background = C.card;
  let borderColor = C.border;
  if (cita.estado === "en_consulta") {
    background = C.blueDim;
    borderColor = C.blue;
  } else if (cita.estado === "completada") {
    background = citaPagoPendiente(cita) ? C.amberDim : C.greenDim;
    borderColor = citaPagoPendiente(cita) ? C.amber : C.green;
  } else if (citaPagoPendiente(cita)) {
    background = C.amberDim;
    borderColor = C.amber;
  } else if (citaEstaPagada(cita)) {
    background = C.greenDim;
    borderColor = C.green;
  }
  if (focoAccion) {
    return {
      background,
      border: `2px solid ${BRAND.primary}`,
      boxShadow: `0 0 0 3px ${BRAND.primary}22`,
    };
  }
  return {
    background,
    border: `1px solid ${borderColor}55`,
    boxShadow: undefined,
  };
}

/** Citas visibles en POS con su estado de cobro (hoy ± ventana cercana). */
export function citaRelevanteParaResumenPOS(c, { hoySv, diasAtras = 7, diasAdelante = 14 } = {}) {
  if (!c) return false;
  const est = String(c.estado || "").toLowerCase();
  if (est === "cancelada" && citaEstaPagada(c)) return false;
  const f = String(c.fecha || "").slice(0, 10);
  if (!f || !hoySv) return citaPagoPendiente(c) || (c.consumibles_consulta || []).some((x) => !x.cobrado);
  const tHoy = new Date(`${hoySv}T12:00:00`).getTime();
  const tCita = new Date(`${f}T12:00:00`).getTime();
  const diffDias = Math.round((tCita - tHoy) / 86400000);
  if (diffDias >= -diasAtras && diffDias <= diasAdelante) return true;
  return citaPagoPendiente(c) || (c.consumibles_consulta || []).some((x) => !x.cobrado);
}
