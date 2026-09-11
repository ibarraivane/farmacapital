/**
 * Qué turno cuenta para Mi Día (meta / tickets).
 * Prioridad: caja abierta → turno habitual (RH) → reloj.
 */
import { inferirTurno } from "../constants/turnos";

export function resolverTurnoMiDia({
  jornada = null,
  sesionCaja = null,
  usuario = null,
  now = new Date(),
} = {}) {
  if (jornada?.cubre_ambos) {
    return { turno: null, cubreAmbos: true, fuente: "cubre_ambos" };
  }
  const sesionTurno = String(sesionCaja?.turno || "").toLowerCase();
  if (sesionTurno === "matutino" || sesionTurno === "vespertino") {
    return { turno: sesionTurno, cubreAmbos: false, fuente: "caja" };
  }
  const habitual = String(
    jornada?.turno_habitual || usuario?.turno || ""
  ).toLowerCase();
  if (habitual === "matutino" || habitual === "vespertino") {
    return { turno: habitual, cubreAmbos: false, fuente: "perfil" };
  }
  return { turno: inferirTurno(now), cubreAmbos: false, fuente: "reloj" };
}
