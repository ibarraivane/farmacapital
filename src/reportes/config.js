// =====================================================================
// FarmaCapital — Configuración, formato y acceso a datos de reportes
// AJUSTAR: la ruta del cliente de Supabase según el repo.
// =====================================================================
import { supabase } from '../supabase';
import { parseRpcJsonArray } from '../utils/rpcJson';

// ---------------------------------------------------------------------
// Paleta del plan maestro. Jade SOLO para lo favorable, rojo SOLO para
// lo desfavorable. Ningún color decorativo.
// ---------------------------------------------------------------------
export const COLOR = {
  tinta:    '#001534',
  azul:     '#054ABC',
  jade:     '#02A158',
  rojo:     '#B00020',
  gris:     '#5B6470',
  grisClaro:'#E4E8ED',
  blanco:   '#FFFFFF',
};

// Versión ARGB para ExcelJS (sin '#', con alfa al frente)
export const ARGB = Object.fromEntries(
  Object.entries(COLOR).map(([k, v]) => [k, 'FF' + v.replace('#', '')])
);

export const CONFIG = {
  DIAS_SIN_ROTACION:      60,
  VENTANA_VELOCIDAD_DIAS: 30,
  UMBRAL_HORA_MUERTA:     3,      // tickets por hora
  TOLERANCIA_PUNTUALIDAD: 10,     // minutos
  MARGEN_MINIMO_ALERTA:   0.15,
  TOLERANCIA_CAJA:        50,     // MXN
  COMISION_TARJETA:       0.0,    // ← PONER LA TASA REAL DEL TERMINAL
  COMISION_MERCADOPAGO:   0.0,    // ← PONER LA TASA REAL
  PAGE_SIZE:              5000,   // filas por llamada al RPC del Excel
};

// Debe coincidir con src/constants/turnos.js. Si ahí cambia, cambia aquí.
export const TURNOS = {
  matutino:   { inicio: '08:00', fin: '15:30', etiqueta: 'Matutino' },
  vespertino: { inicio: '15:00', fin: '22:30', etiqueta: 'Vespertino' },
};

export const MESES = ['Enero','Febrero','Marzo','Abril','Mayo','Junio',
  'Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'];

export const DIAS = ['Domingo','Lunes','Martes','Miércoles','Jueves','Viernes','Sábado'];
export const DIAS_CORTO = ['Dom','Lun','Mar','Mié','Jue','Vie','Sáb'];

// ---------------------------------------------------------------------
// Formato
// ---------------------------------------------------------------------
const fmtMXN = new Intl.NumberFormat('es-MX', {
  style: 'currency', currency: 'MXN', minimumFractionDigits: 2,
});
const fmtNum = new Intl.NumberFormat('es-MX', { maximumFractionDigits: 0 });

export const mxn = (n) => fmtMXN.format(Number(n) || 0);
export const num = (n) => fmtNum.format(Number(n) || 0);
export const dec = (n, d = 1) => (Number(n) || 0).toFixed(d);
export const pct = (n, d = 1) => `${((Number(n) || 0) * 100).toFixed(d)}%`;

/** Variación con signo y flecha. null cuando no hay base de comparación. */
export function variacion(actual, previo) {
  const a = Number(actual) || 0, p = Number(previo) || 0;
  if (p === 0) return { texto: 'sin base', valor: null, sube: null };
  const v = (a - p) / p;
  return {
    valor: v,
    sube: v >= 0,
    texto: `${v >= 0 ? '▲' : '▼'} ${Math.abs(v * 100).toFixed(1)}%`,
  };
}

export const fechaCorta = (iso) => {
  if (!iso) return '';
  const d = new Date(iso);
  return `${String(d.getUTCDate()).padStart(2, '0')}/${String(d.getUTCMonth() + 1).padStart(2, '0')}/${d.getUTCFullYear()}`;
};

export const nombreMes = (anio, mes) => `${MESES[mes - 1]} ${anio}`;

/**
 * El RPC devuelve fechas como texto sin zona (ya vienen en hora local).
 * Se convierten a Date "neutro" para que Excel no vuelva a desplazarlas.
 */
export function aFecha(valor) {
  if (!valor) return null;
  const s = String(valor);
  const m = s.match(/^(\d{4})-(\d{2})-(\d{2})/);
  if (!m) return null;
  return new Date(Date.UTC(+m[1], +m[2] - 1, +m[3]));
}

export function aHora(valor) {
  if (!valor) return null;
  const m = String(valor).match(/(\d{2}):(\d{2})/);
  if (!m) return null;
  return new Date(Date.UTC(1899, 11, 30, +m[1], +m[2]));
}

// ---------------------------------------------------------------------
// Acceso a datos
// ---------------------------------------------------------------------

function sessionToken() {
  if (typeof sessionStorage === 'undefined') return null;
  return sessionStorage.getItem('farmacapital_session_token');
}

function filasRpc(data) {
  const raw = parseRpcJsonArray(data);
  return raw.map((r) => {
    if (r && typeof r === 'object' && r.empleado_rpc_transacciones_mes) {
      return r.empleado_rpc_transacciones_mes;
    }
    return r;
  });
}

/** Agregados completos del PDF. Un solo viaje, payload chico. */
export async function obtenerReporteMensual(anio, mes) {
  const tok = sessionToken();
  if (!tok) throw new Error('Sesión expirada');
  const { data, error } = await supabase.rpc('empleado_rpc_reporte_mensual', {
    p_session_token: tok,
    p_anio: anio,
    p_mes: mes,
  });
  if (error) throw traducirError(error);
  return data;
}

/** Una hoja del Excel, paginada hasta agotarla. */
export async function obtenerHoja(anio, mes, hoja, onProgreso) {
  const tok = sessionToken();
  if (!tok) throw new Error('Sesión expirada');
  const filas = [];
  let offset = 0;
  for (;;) {
    const { data, error } = await supabase.rpc('empleado_rpc_transacciones_mes', {
      p_session_token: tok,
      p_anio: anio,
      p_mes: mes,
      p_hoja: hoja,
      p_offset: offset,
      p_limit: CONFIG.PAGE_SIZE,
    });
    if (error) throw traducirError(error);
    const lote = filasRpc(data);
    filas.push(...lote);
    onProgreso?.(hoja, filas.length);
    if (lote.length < CONFIG.PAGE_SIZE) break;
    offset += CONFIG.PAGE_SIZE;
    if (offset > 500000) break; // cinturón de seguridad
  }
  return filas;
}

function traducirError(error) {
  const msg = String(error?.message || '');
  if (msg.includes('ACCESO_DENEGADO') || error?.code === '42501') {
    return new Error('Este reporte es exclusivo del administrador.');
  }
  if (msg.includes('HOJA_DESCONOCIDA')) {
    return new Error('Hoja no reconocida por el servidor.');
  }
  return new Error(`No se pudo consultar la información: ${msg}`);
}

/** Registro en bitácora. Falla en silencio: no debe impedir la descarga. */
export async function registrarAuditoria(accion, periodo) {
  try {
    await supabase.from('audit_log').insert({
      accion,
      tabla: 'reporte_mensual',
      detalle: JSON.stringify({ periodo }),
    });
  } catch { /* la exportación no se bloquea por la bitácora */ }
}

export const nombreArchivo = (base, anio, mes, ext) =>
  `farmacapital_${base}_${anio}-${String(mes).padStart(2, '0')}.${ext}`;
