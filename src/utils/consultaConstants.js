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
