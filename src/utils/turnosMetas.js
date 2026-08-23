// Helpers para calcular la meta de un turno específico en una fecha dada,
// aplicando los ajustes automáticos por fecha que viven en la tabla `configuracion`.
//
// Los turnos salen de src/constants/turnos.js — no se redefinen aquí. Antes
// este archivo partía el día a las 14:00 mientras el corte de caja lo partía a
// las 16:00, así que la meta y el efectivo esperado hablaban de rangos distintos.
//
// Ajustes por fecha (acumulativos, en %):
//   - Quincena   (día 15)            → ajuste_quincena
//   - Día de pago (último día mes)   → ajuste_dia_pago
//   - Viernes                         → ajuste_viernes
//   - Lunes                           → ajuste_lunes
//   - Domingo                         → ajuste_domingo
//
// Mapeo turno + día → clave de configuración:
//   L-V matutino     → meta_matutino_lv
//   L-V vespertino   → meta_vespertino_lv
//   Sábado matutino  → meta_sabado_matutino
//   Sábado vesper.   → meta_sabado_vespertino
//   Domingo (todo)   → meta_domingo
import { supabase } from "../supabase";
import { rangoTurno, inferirTurno } from "../constants/turnos";

export { inferirTurno };

export function inicioDelTurno(fecha, turno) {
  return rangoTurno(fecha, turno).inicio;
}

export function finDelTurno(fecha, turno) {
  return rangoTurno(fecha, turno).fin;
}

export function nombreDia(date) {
  return ["domingo","lunes","martes","miercoles","jueves","viernes","sabado"][date.getDay()];
}

export function claveMetaTurno(fecha, turno) {
  const dow = fecha.getDay(); // 0=dom, 6=sab
  if (dow === 0) return "meta_domingo";
  if (dow === 6) return turno === "matutino" ? "meta_sabado_matutino" : "meta_sabado_vespertino";
  return turno === "matutino" ? "meta_matutino_lv" : "meta_vespertino_lv";
}

function esUltimoDiaDelMes(fecha) {
  const t = new Date(fecha);
  t.setDate(t.getDate() + 1);
  return t.getDate() === 1;
}

// Calcula el multiplicador total (ej. 1.15 = +15%) a partir de los ajustes % vigentes para esa fecha.
// Los ajustes son acumulativos: si cae en viernes + quincena, se suman los dos.
export function calcularMultiplicador(fecha, ajustes) {
  let pct = 0;
  const dow = fecha.getDay();
  if (fecha.getDate() === 15)  pct += parseFloat(ajustes.ajuste_quincena  || 0);
  if (esUltimoDiaDelMes(fecha))pct += parseFloat(ajustes.ajuste_dia_pago  || 0);
  if (dow === 5) pct += parseFloat(ajustes.ajuste_viernes || 0);
  if (dow === 1) pct += parseFloat(ajustes.ajuste_lunes   || 0);
  if (dow === 0) pct += parseFloat(ajustes.ajuste_domingo || 0);
  return 1 + pct / 100;
}

// Carga todas las claves necesarias en una sola llamada. Cachea brevemente en memoria.
const _cache = { data: null, ts: 0 };
const TTL_MS = 60 * 1000;

export function invalidarCacheMetas() {
  _cache.data = null;
  _cache.ts = 0;
}

/** true solo si el admin encendió bonos_activos. Falta la clave = apagado. */
export function bonosActivos(map) {
  const v = String(map?.bonos_activos ?? "0").trim().toLowerCase();
  return v === "1" || v === "true" || v === "si" || v === "sí" || v === "on";
}

export async function cargarConfigMetas() {
  if (_cache.data && Date.now() - _cache.ts < TTL_MS) return _cache.data;
  const claves = [
    "meta_matutino_lv","meta_vespertino_lv",
    "meta_sabado_matutino","meta_sabado_vespertino","meta_domingo",
    "meta_ventas_mes","meta_ventas_dia","meta_ventas_semana",
    "ajuste_quincena","ajuste_dia_pago","ajuste_viernes","ajuste_lunes","ajuste_domingo",
    "bonos_activos",
  ];
  const { data, error } = await supabase.from("configuracion").select("clave,valor").in("clave", claves);
  if (error) { console.warn("[turnosMetas] cargar:", error.message); return {}; }
  const map = Object.fromEntries((data || []).map((r) => [r.clave, r.valor]));
  _cache.data = map;
  _cache.ts = Date.now();
  return map;
}

/** Meta de caja de todo el día (los dos turnos, o domingo suelto), con ajustes de fecha. */
export function metaDiaCompleto(fecha, map) {
  const cfg = map || {};
  const dow = fecha.getDay();
  const mult = calcularMultiplicador(fecha, cfg);
  const num = (clave) => parseFloat(cfg[clave] || 0) || 0;
  let base;
  if (dow === 0) base = num("meta_domingo");
  else if (dow === 6) base = num("meta_sabado_matutino") + num("meta_sabado_vespertino");
  else base = num("meta_matutino_lv") + num("meta_vespertino_lv");
  if (base <= 0) base = num("meta_ventas_dia");
  return Math.round(base * mult);
}

// Devuelve la meta en $ para el turno y fecha indicados.
export async function obtenerMetaTurno(fecha, turno) {
  const map = await cargarConfigMetas();
  const clave = claveMetaTurno(fecha, turno);
  const base = parseFloat(map[clave] || 0);
  const mult = calcularMultiplicador(fecha, map);
  return Math.round(base * mult);
}

// Escalón de bono según % de cumplimiento mensual.
export function escalonBono(pct) {
  if (pct >= 110) return { clave: "bono_110_plus",   label: "110% o más" };
  if (pct >= 100) return { clave: "bono_100_109",    label: "100-109%"    };
  if (pct >= 90)  return { clave: "bono_90_99",      label: "90-99%"      };
  if (pct >= 70)  return { clave: "bono_70_89",      label: "70-89%"      };
  return null;
}
