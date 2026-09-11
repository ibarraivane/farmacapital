/**
 * Qué turno cuenta para Mi Día (meta / tickets).
 * Prioridad: caja abierta → turno habitual (RH) → reloj.
 *
 * Importante: el TURNO solo elige la meta en $. La ventana de ventas
 * (qué tickets suman) es otra cosa — ver resolverVentanaVentasMiDia.
 * Un perfil "vespertino" no debe tirar a 0% las ventas de la mañana.
 */
import { inferirTurno } from "../constants/turnos";
import { inicioDelTurno, finDelTurno } from "../utils/turnosMetas";

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

/**
 * Ventana [inicio, fin] ISO de tickets que suman a la meta de hoy.
 * Prioridad: caja abierta (como el corte) → día civil completo.
 * Nunca recorta por perfil vespertino/matutino: eso dejaba 0% con ventas
 * reales en la mañana.
 */
export function resolverVentanaVentasMiDia({
  sesionCaja = null,
  diaRango = null,
  hoyAncla = null,
  turno = null,
  cubreAmbos = false,
} = {}) {
  if (sesionCaja?.abierta && sesionCaja.abierta_at) {
    return {
      inicio: new Date(sesionCaja.abierta_at).toISOString(),
      fin: new Date().toISOString(),
      fuente: "caja_abierta",
    };
  }
  if (diaRango?.start && diaRango?.end) {
    return {
      inicio: diaRango.start,
      fin: new Date(new Date(diaRango.end).getTime() - 1).toISOString(),
      fuente: cubreAmbos ? "cubre_ambos" : "dia_completo",
    };
  }
  // Respaldo raro (sin calendario): turno clásico.
  if (hoyAncla && turno) {
    return {
      inicio: inicioDelTurno(hoyAncla, turno).toISOString(),
      fin: finDelTurno(hoyAncla, turno).toISOString(),
      fuente: "turno_perfil",
    };
  }
  const now = new Date();
  return { inicio: now.toISOString(), fin: now.toISOString(), fuente: "vacio" };
}
