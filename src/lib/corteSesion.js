/**
 * Regla de corte: quien abre caja corta ESA sesión.
 * Un corte previo del mismo turno (Cinthia matutino → Iván abre después)
 * no bloquea si hay sesión abierta.
 */

/** ¿El aviso/RPC debe impedir guardar otro corte? */
export function corteBloqueaGuardado(corteInfo, sesionAbierta) {
  if (!corteInfo?.existe && !corteInfo?.id) return false;
  // Compat: a veces solo viene { id } tras guardar.
  const hayCorte = !!(corteInfo?.existe || corteInfo?.id);
  if (!hayCorte) return false;
  if (sesionAbierta?.id || sesionAbierta === true) return false;
  return true;
}

/** Datos del RPC empleado_corte_turno_en_fecha → estado de UI. */
export function parseCorteTurnoRpc(data) {
  const propio =
    data?.existe && data?.id
      ? { existe: true, id: data.id, propio: data.propio !== false }
      : null;
  const previo =
    data?.previo_id
      ? {
          id: data.previo_id,
          nombre: data.previo_nombre || null,
        }
      : null;
  return { propio, previo, sesionAbiertaRpc: !!data?.sesion_abierta };
}
