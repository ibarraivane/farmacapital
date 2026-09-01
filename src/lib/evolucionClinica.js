/** Serie de signos vitales e IMC a partir de las fichas del paciente. */

export function parseSignosVitales(raw) {
  if (!raw) return null;
  let o = raw;
  if (typeof raw === "string") {
    const t = raw.trim();
    if (!t) return null;
    try {
      o = JSON.parse(t);
    } catch {
      return null;
    }
  }
  if (!o || typeof o !== "object" || Array.isArray(o)) return null;
  return o;
}

export function parseNumeroClinico(v) {
  if (v == null || v === "") return null;
  if (typeof v === "number") return Number.isFinite(v) ? v : null;
  const s = String(v).trim().replace(",", ".");
  if (!s) return null;
  const n = parseFloat(s);
  return Number.isFinite(n) ? n : null;
}

export function parseTensionArterial(ta) {
  if (ta == null || ta === "") return null;
  const s = String(ta).trim();
  const m = s.match(/(\d+(?:[.,]\d+)?)\s*[/\-]\s*(\d+(?:[.,]\d+)?)/);
  if (!m) return null;
  const sis = parseNumeroClinico(m[1]);
  const dia = parseNumeroClinico(m[2]);
  if (sis == null || dia == null) return null;
  return { sis, dia, texto: `${Math.round(sis)}/${Math.round(dia)}` };
}

export function calcIMC(pesoKg, tallaCm) {
  const p = parseNumeroClinico(pesoKg);
  const t = parseNumeroClinico(tallaCm);
  if (p == null || t == null || t <= 0) return null;
  const m = t / 100;
  if (m < 0.4 || m > 2.5) return null;
  if (p < 2 || p > 400) return null;
  return Math.round((p / (m * m)) * 10) / 10;
}

export function clasificarIMC(imc) {
  if (imc == null || !Number.isFinite(imc)) return null;
  if (imc < 18.5) return { id: "bajo", label: "bajo peso", tono: "amber" };
  if (imc < 25) return { id: "normal", label: "normal", tono: "green" };
  if (imc < 30) return { id: "sobrepeso", label: "sobrepeso", tono: "amber" };
  return { id: "obesidad", label: "obesidad", tono: "red" };
}

export function clasificarTA(sis, dia) {
  if (sis == null && dia == null) return null;
  if ((sis != null && sis >= 140) || (dia != null && dia >= 90)) {
    return { id: "alta", label: "alta", tono: "red" };
  }
  if ((sis != null && sis >= 130) || (dia != null && dia >= 85)) {
    return { id: "limite", label: "en el límite", tono: "amber" };
  }
  if ((sis != null && sis < 90) || (dia != null && dia < 60)) {
    return { id: "baja", label: "baja", tono: "amber" };
  }
  return { id: "normal", label: "normal", tono: "green" };
}

export function clasificarFC(fc) {
  if (fc == null || !Number.isFinite(fc)) return null;
  if (fc < 50) return { id: "baja", label: "baja", tono: "amber" };
  if (fc > 100) return { id: "alta", label: "alta", tono: "amber" };
  return { id: "normal", label: "normal", tono: "green" };
}

export function clasificarTemp(temp) {
  if (temp == null || !Number.isFinite(temp)) return null;
  if (temp >= 38) return { id: "fiebre", label: "fiebre", tono: "red" };
  if (temp >= 37.5) return { id: "febricula", label: "febrícula", tono: "amber" };
  if (temp < 35.5) return { id: "baja", label: "baja", tono: "amber" };
  return { id: "normal", label: "normal", tono: "green" };
}

export function clasificarSat(sat) {
  if (sat == null || !Number.isFinite(sat)) return null;
  if (sat < 92) return { id: "baja", label: "baja", tono: "red" };
  if (sat < 95) return { id: "limite", label: "en el límite", tono: "amber" };
  return { id: "normal", label: "normal", tono: "green" };
}

export function fmtFechaCorta(ymd) {
  if (!ymd) return "—";
  const m = String(ymd).match(/^(\d{4})-(\d{2})-(\d{2})/);
  if (!m) return String(ymd);
  return `${m[3]}/${m[2]}/${m[1]}`;
}

function claveOrdenCita(c) {
  return `${c.fecha || ""}T${c.hora || "00:00"}`;
}

/** Puntos cronológicos (viejo → nuevo) con al menos un signo medido. */
export function puntosDesdeCitas(citas) {
  const rows = [];
  for (const c of citas || []) {
    const sv = parseSignosVitales(c.signos_vitales);
    if (!sv) continue;
    const ta = parseTensionArterial(sv.ta);
    const peso = parseNumeroClinico(sv.peso);
    const talla = parseNumeroClinico(sv.talla);
    const fc = parseNumeroClinico(sv.fc);
    const temp = parseNumeroClinico(sv.temp);
    const sat = parseNumeroClinico(sv.sat);
    const hasAny =
      ta ||
      peso != null ||
      talla != null ||
      fc != null ||
      temp != null ||
      sat != null;
    if (!hasAny) continue;
    rows.push({
      id: c.id,
      fecha: c.fecha,
      hora: c.hora,
      sis: ta?.sis ?? null,
      dia: ta?.dia ?? null,
      taTexto: ta?.texto ?? null,
      fc,
      temp,
      sat,
      peso,
      talla,
      imc: calcIMC(peso, talla),
    });
  }
  rows.sort((a, b) => claveOrdenCita(a).localeCompare(claveOrdenCita(b)));
  return llevarTallaParaIMC(rows);
}

/**
 * Si una visita no anotó talla, se usa la última (o la primera conocida)
 * para poder calcular IMC. En adultos casi no cambia.
 */
export function llevarTallaParaIMC(puntos) {
  let last = null;
  const fwd = (puntos || []).map((p) => {
    if (p.talla != null) last = p.talla;
    return { ...p, tallaEfectiva: p.talla ?? last };
  });
  const primera = fwd.find((p) => p.talla != null)?.talla ?? null;
  return fwd.map((p) => {
    const tallaEfectiva = p.tallaEfectiva ?? primera;
    return {
      ...p,
      tallaEfectiva,
      imc: p.imc ?? calcIMC(p.peso, tallaEfectiva),
    };
  });
}

export function valoresCampo(puntos, key) {
  return (puntos || []).filter((p) => Number.isFinite(p[key]));
}

export function ultimoConValor(puntos, key) {
  const vals = valoresCampo(puntos, key);
  return vals.length ? vals[vals.length - 1] : null;
}

export function promedioCampo(puntos, key, decimales = 1) {
  const vals = valoresCampo(puntos, key).map((p) => p[key]);
  if (!vals.length) return null;
  const avg = vals.reduce((a, b) => a + b, 0) / vals.length;
  const f = 10 ** decimales;
  return Math.round(avg * f) / f;
}

export function promedioTA(puntos) {
  const conSis = valoresCampo(puntos, "sis");
  if (!conSis.length) return null;
  const sis = Math.round(conSis.reduce((a, p) => a + p.sis, 0) / conSis.length);
  const conDia = valoresCampo(puntos, "dia");
  const dia = conDia.length
    ? Math.round(conDia.reduce((a, p) => a + p.dia, 0) / conDia.length)
    : null;
  return {
    sis,
    dia,
    texto: dia != null ? `${sis}/${dia}` : String(sis),
  };
}

export function tendenciaCampo(puntos, key, { umbral = 0, decimales = 1, unidad = "" } = {}) {
  const vals = valoresCampo(puntos, key);
  if (vals.length < 2) return null;
  const first = vals[0][key];
  const last = vals[vals.length - 1][key];
  const delta = last - first;
  const fmt = (n) => {
    const t = Number(n).toFixed(decimales);
    return decimales === 0 ? String(Math.round(n)) : t.replace(/\.0$/, "");
  };
  if (Math.abs(delta) <= umbral) {
    return { dir: "flat", delta: 0, texto: `estable (${fmt(last)}${unidad})` };
  }
  if (delta > 0) return { dir: "up", delta, texto: `subió ${fmt(delta)}${unidad}` };
  return { dir: "down", delta, texto: `bajó ${fmt(Math.abs(delta))}${unidad}` };
}

/** Texto corto para que la doctora lea la evolución de un vistazo. */
export function narrarEvolucion(puntos) {
  if (!puntos?.length) {
    return "Aún no hay signos vitales en las fichas. Cuando se anoten en una consulta, aquí se arma la curva de peso, talla e indicadores.";
  }
  const n = puntos.length;
  const desde = fmtFechaCorta(puntos[0].fecha);
  const partes = [];
  if (n === 1) {
    partes.push(`Hay 1 consulta con signos (${desde}).`);
  } else {
    partes.push(`En ${n} consultas con signos, desde ${desde}.`);
  }

  const pesoT = tendenciaCampo(puntos, "peso", { umbral: 0.5, decimales: 1, unidad: " kg" });
  if (pesoT) partes.push(`El peso ${pesoT.texto}.`);
  else {
    const lastPeso = ultimoConValor(puntos, "peso");
    if (lastPeso) partes.push(`Último peso ${lastPeso.peso} kg.`);
  }

  const lastTA = [...puntos].reverse().find((p) => p.sis != null);
  if (lastTA) {
    const cl = clasificarTA(lastTA.sis, lastTA.dia);
    partes.push(`Última TA ${lastTA.taTexto}${cl ? ` (${cl.label})` : ""}.`);
  }

  const lastIMC = ultimoConValor(puntos, "imc");
  if (lastIMC) {
    const cl = clasificarIMC(lastIMC.imc);
    partes.push(`IMC ${lastIMC.imc}${cl ? ` — ${cl.label}` : ""}.`);
  }

  return partes.join(" ");
}

export const INDICADORES = [
  { key: "peso", label: "Peso", unidad: "kg", color: "#7c3aed", decimales: 1, umbral: 0.5 },
  { key: "talla", label: "Talla", unidad: "cm", color: "#0891b2", decimales: 1, umbral: 0.5 },
  { key: "imc", label: "IMC", unidad: "", color: "#1E3ABA", decimales: 1, umbral: 0.3 },
  { key: "sis", label: "TA sistólica", unidad: "mmHg", color: "#ef4444", decimales: 0, umbral: 3 },
  { key: "dia", label: "TA diastólica", unidad: "mmHg", color: "#f59e0b", decimales: 0, umbral: 3 },
  { key: "fc", label: "Frecuencia", unidad: "lpm", color: "#1E3ABA", decimales: 0, umbral: 3 },
  { key: "temp", label: "Temperatura", unidad: "°C", color: "#f59e0b", decimales: 1, umbral: 0.2 },
  { key: "sat", label: "SpO₂", unidad: "%", color: "#22C55E", decimales: 0, umbral: 1 },
];
