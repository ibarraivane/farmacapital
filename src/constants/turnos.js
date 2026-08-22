// Fuente única de los horarios de turno de FarmaCapital.
//
// La farmacia abre 8:00 y cierra 22:30, en dos turnos que se traslapan media
// hora para el relevo:
//
//   Matutino    8:00 – 15:30
//   Vespertino 15:00 – 22:30
//
// Ese traslape es de PERSONAL, no de caja. Si hay sesión de caja abierta, el
// dinero es de esa sesión (aunque el reloj ya pasó de las 15:30). El corte a
// las 15:30 solo aplica cuando nadie tiene el cajón abierto.
//
// Los rangos de conciliación cubren el día completo (00:00–23:59) a propósito:
// si alguien vende a las 7:50 abriendo, o a las 22:40 cerrando, la venta cae
// igual en un turno en vez de perderse en un hueco.

export const HORARIO_FARMACIA = { apertura: "8:00", cierre: "22:30" };

// Hora del relevo de caja. Cambiar esto mueve la frontera en toda la app.
export const CORTE_HORA = 15;
export const CORTE_MINUTO = 30;

export const TURNOS = {
  matutino:   { label: "Matutino",   emoji: "🌅", horario: "8:00 – 15:30h" },
  vespertino: { label: "Vespertino", emoji: "🌆", horario: "15:00 – 22:30h" },
};

export const TURNOS_LISTA = ["matutino", "vespertino"];

/** Turno al que pertenece un momento dado, según el relevo de caja. */
export function inferirTurno(date = new Date()) {
  const minutos = date.getHours() * 60 + date.getMinutes();
  return minutos < CORTE_HORA * 60 + CORTE_MINUTO ? "matutino" : "vespertino";
}

/** Rango [inicio, fin] del turno en una fecha, en hora local. Nunca se traslapan. */
export function rangoTurno(fecha, turno) {
  const corte = new Date(fecha);
  corte.setHours(CORTE_HORA, CORTE_MINUTO, 0, 0);

  if (turno === "matutino") {
    const inicio = new Date(fecha);
    inicio.setHours(0, 0, 0, 0);
    return { inicio, fin: new Date(corte.getTime() - 1) };
  }

  const fin = new Date(fecha);
  fin.setHours(23, 59, 59, 999);
  return { inicio: corte, fin };
}

/** Ventana real del cajón: de cuando abrieron a cuando cerraron. */
export function rangoCajaDeCorte(corte) {
  const fecha = String(corte?.fecha || "").slice(0, 10);
  const fallback = () => rangoTurno(fecha ? new Date(`${fecha}T12:00:00-06:00`) : new Date(), corte?.turno || "matutino");
  if (!fecha) return fallback();
  const apRaw = String(corte.hora_apertura || "").slice(0, 8);
  const ciRaw = String(corte.hora_cierre || "").slice(0, 8);
  const ap = /^\d{2}:\d{2}:\d{2}$/.test(apRaw) ? apRaw : (corte.turno === "vespertino" ? "15:30:00" : "00:00:00");
  const ci = /^\d{2}:\d{2}:\d{2}$/.test(ciRaw) ? ciRaw : "23:59:59";
  const inicio = new Date(`${fecha}T${ap}-06:00`);
  const fin = new Date(`${fecha}T${ci}-06:00`);
  if (Number.isNaN(inicio.getTime()) || Number.isNaN(fin.getTime()) || fin < inicio) return fallback();
  return { inicio, fin };
}

/** "Matutino 8:00 – 15:30h" — para selects y etiquetas. */
export function etiquetaTurno(turno) {
  const t = TURNOS[turno];
  return t ? `${t.label} ${t.horario}` : turno;
}

/** Turno de caja asignado al perfil en RH. Null si aún no lo tienen. */
export function turnoDePerfil(usuario) {
  const t = String(usuario?.turno || "").toLowerCase();
  return t === "matutino" || t === "vespertino" ? t : null;
}

/** 0 = lunes … 6 = domingo. Coincide con extract(dow) de Postgres convertido. */
export const DIAS_SEMANA = [
  { idx: 0, corto: "Lun", largo: "lunes" },
  { idx: 1, corto: "Mar", largo: "martes" },
  { idx: 2, corto: "Mié", largo: "miércoles" },
  { idx: 3, corto: "Jue", largo: "jueves" },
  { idx: 4, corto: "Vie", largo: "viernes" },
  { idx: 5, corto: "Sáb", largo: "sábado" },
  { idx: 6, corto: "Dom", largo: "domingo" },
];

export function idxDiaDescanso(date = new Date()) {
  return (date.getDay() + 6) % 7;
}

export function etiquetaDiaDescanso(idx) {
  const d = DIAS_SEMANA.find((x) => x.idx === Number(idx));
  return d ? d.largo : null;
}

/**
 * Semana 6+1: quien descansa ese día; las demás cubren ambos turnos.
 * perfiles: { id, nombre, rol, turno, dia_descanso }
 */
export function planSemanaCaja(perfiles) {
  const piso = (perfiles || []).filter((p) => p.rol === "vendedor" || p.rol === "gerente");
  return DIAS_SEMANA.map((d) => ({
    ...d,
    celdas: piso.map((p) => {
      const descansoNum = p.dia_descanso == null || p.dia_descanso === ""
        ? null
        : Number(p.dia_descanso);
      if (descansoNum === d.idx) return { id: p.id, nombre: p.nombre, estado: "descanso" };
      const alguienDescansa = piso.some((o) => Number(o.dia_descanso) === d.idx && String(o.id) !== String(p.id));
      if (alguienDescansa) return { id: p.id, nombre: p.nombre, estado: "ambos" };
      const t = turnoDePerfil(p);
      return { id: p.id, nombre: p.nombre, estado: t || "sin_turno" };
    }),
  }));
}

export function descansosChocan(perfiles) {
  const counts = new Map();
  (perfiles || []).forEach((p) => {
    if (p.dia_descanso == null || p.dia_descanso === "") return;
    const k = Number(p.dia_descanso);
    counts.set(k, (counts.get(k) || []).concat(p.nombre || p.id));
  });
  return [...counts.entries()].filter(([, names]) => names.length > 1);
}
