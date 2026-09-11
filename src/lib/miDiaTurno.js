/**
 * Qué turno cuenta para Mi Día (meta / tickets).
 *
 * Regla de cobertura: quien abre la caja trabaja ese turno. El perfil de RH
 * es la costumbre semanal, no un candado. Si una vespertina abre matutino,
 * la meta y las ventas siguen a esa sesión (y si luego abre vespertino,
 * suma ambos).
 *
 * La ventana de ventas (qué tickets suman) es otra cosa — ver
 * resolverVentanaVentasMiDia.
 */
import { inferirTurno } from "../constants/turnos";
import { inicioDelTurno, finDelTurno } from "../utils/turnosMetas";

function turnosValidos(lista) {
  const out = [];
  const seen = new Set();
  for (const raw of lista || []) {
    const t = String(raw || "").toLowerCase();
    if ((t === "matutino" || t === "vespertino") && !seen.has(t)) {
      seen.add(t);
      out.push(t);
    }
  }
  return out;
}

/**
 * Turnos cuya meta en $ aplica hoy, según lo que realmente abrió.
 */
export function resolverTurnosMetaHoy({
  jornada = null,
  sesionCaja = null,
  usuario = null,
  now = new Date(),
} = {}) {
  const set = new Set();
  const turnosHoy = turnosValidos(jornada?.turnos_hoy);
  turnosHoy.forEach((t) => set.add(t));

  const sesionTurno = String(sesionCaja?.turno || "").toLowerCase();
  if (sesionCaja?.abierta && (sesionTurno === "matutino" || sesionTurno === "vespertino")) {
    set.add(sesionTurno);
  }

  if (jornada?.cubre_ambos) {
    // Día de cobertura completa (RH o ya abrió los dos turnos).
    return {
      turnos: ["matutino", "vespertino"],
      cubreAmbos: true,
      fuente: "cubre_ambos",
    };
  }

  if (set.size > 0) {
    const turnos = ["matutino", "vespertino"].filter((t) => set.has(t));
    return {
      turnos,
      cubreAmbos: turnos.length > 1,
      fuente: "sesiones_hoy",
    };
  }

  const base = resolverTurnoMiDia({ jornada, sesionCaja, usuario, now });
  if (base.cubreAmbos) {
    return { turnos: ["matutino", "vespertino"], cubreAmbos: true, fuente: base.fuente };
  }
  return {
    turnos: base.turno ? [base.turno] : [],
    cubreAmbos: false,
    fuente: base.fuente,
  };
}

export function resolverTurnoMiDia({
  jornada = null,
  sesionCaja = null,
  usuario = null,
  now = new Date(),
} = {}) {
  if (jornada?.cubre_ambos) {
    return { turno: null, cubreAmbos: true, fuente: "cubre_ambos" };
  }
  const turnosHoy = turnosValidos(jornada?.turnos_hoy);
  if (turnosHoy.length > 1) {
    return { turno: null, cubreAmbos: true, fuente: "sesiones_hoy" };
  }
  const sesionTurno = String(sesionCaja?.turno || "").toLowerCase();
  if (sesionTurno === "matutino" || sesionTurno === "vespertino") {
    return { turno: sesionTurno, cubreAmbos: false, fuente: "caja" };
  }
  if (turnosHoy.length === 1) {
    return { turno: turnosHoy[0], cubreAmbos: false, fuente: "sesiones_hoy" };
  }
  // Cobertura puntual (abrió turno ≠ perfil) sin marcar ambos todavía:
  // el turno de caja abierta ya se resolvió arriba; si no hay sesión,
  // preferimos turno_abrir de jornada.
  const abrir = String(jornada?.turno_abrir || "").toLowerCase();
  if (jornada?.cobertura && (abrir === "matutino" || abrir === "vespertino")) {
    return { turno: abrir, cubreAmbos: false, fuente: "cobertura" };
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
