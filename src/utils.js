// FARMACAPITAL — Utilidades globales
import { supabase } from "./supabase";
import { C } from "./constants";

export const dC   = f => Math.floor((new Date(f)-new Date())/86400000);
export const cC   = d => d<0?C.red:d<15?C.red:d<30?C.amber:C.green;
export const $    = n => {
  const v = Number(n);
  const x = Number.isFinite(v) ? v : 0;
  return `$${x.toLocaleString("es-MX", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
};
export const abc  = i => { const v=i.stock*i.price; return v>800?"A":v>300?"B":"C"; };
export const aCol = a => ({A:C.green,B:C.amber,C:C.red}[a]);
export const nCol = n => ({Gold:C.amber,Silver:C.textMid,Bronze:"#cd7f32"}[n]||C.textMid);

/** Solo dígitos del teléfono (para validar longitud). */
export const soloDigitosTel = (t) => String(t ?? "").replace(/\D/g, "");

/** Teléfono de contacto México: al menos 10 dígitos. */
export const telefonoMxValido = (t) => soloDigitosTel(t).length >= 10;

/**
 * Normaliza teléfono MX para guardar en BD.
 * Formato interno: 52 + 10 dígitos (coincide con Meta Developer → lista de prueba).
 * Al enviar, la API prueba también 521… si hace falta para entrega en producción.
 */
export function normalizarTelefonoMxGuardar(input) {
  const digits = soloDigitosTel(input);
  if (!digits) return "";

  if (digits.length === 11 && digits.startsWith("1")) return digits;
  const local = digits.length >= 10 ? digits.slice(-10) : digits;
  if (local.length === 10) return `52${local}`;
  if (digits.startsWith("521") && digits.length === 13) return `52${digits.slice(3)}`;
  if (digits.startsWith("52") && digits.length === 12) return digits;
  if (digits.length >= 10) return `52${digits.slice(-10)}`;

  return digits;
}

/** Compara dos teléfonos MX ignorando prefijo (+52 / 521). */
export function telefonosMxEquivalentes(a, b) {
  const da = soloDigitosTel(a);
  const db = soloDigitosTel(b);
  if (da.length < 10 || db.length < 10) return da === db;
  return da.slice(-10) === db.slice(-10);
}

/**
 * Nombre completo del paciente: al menos dos palabras (nombre + apellido) y longitud mínima.
 */
export const nombreCompletoPacienteValido = (n) => {
  const s = String(n ?? "").trim();
  if (s.length < 5) return false;
  const parts = s.split(/\s+/).filter(Boolean);
  return parts.length >= 2;
};

/**
 * Texto en minúsculas sin acentos ni marcas diacríticas (búsqueda tolerante).
 * Ej.: "Paracetámol" y "paracetamol" comparten la misma forma normalizada.
 */
/** Quita ZWSP/BOM/etc. que dejan tokens “rotos” en búsqueda. */
const stripInvisibleSearchChars = (s) =>
  String(s).replace(/[\u200B-\u200D\uFEFF\u2060]/g, "");

/** Token ya normalizado: dosis (5mg, 12.5ml, …) para no confundir con 15mg / 150mg / 250mg. */
export const isNormalizedDoseUnitToken = (tok) =>
  /^(\d+)(\.\d+)?(mg|mcg|ug|g|ml|iu)$/i.test(String(tok || ""));

/**
 * Subcadena en texto ya normalizado; para dosis exige límites numéricos (no "5mg" dentro de "15mg").
 */
export const tokenMatchesInNormalizedHaystack = (needle, haystack) => {
  if (needle == null || haystack == null) return false;
  const n = String(needle);
  const h = String(haystack);
  if (!n || !h.includes(n)) return false;
  if (!isNormalizedDoseUnitToken(n)) return true;
  let i = 0;
  while ((i = h.indexOf(n, i)) !== -1) {
    const before = i === 0 ? "" : h[i - 1];
    const after = i + n.length >= h.length ? "" : h[i + n.length];
    if (!/\d/.test(before) && !/\d/.test(after)) return true;
    i += 1;
  }
  return false;
};

export const normalizeForSearch = (s) => {
  if (s == null) return "";
  const t = stripInvisibleSearchChars(String(s)).trim();
  if (!t) return "";
  let d = t;
  try {
    if (typeof d.normalize === "function") d = d.normalize("NFD");
  } catch {
    /* IE / entornos raros */
  }
  try {
    d = d.replace(/\p{M}/gu, "");
  } catch {
    d = d.replace(/[\u0300-\u036f]/g, "");
  }
  return d.toLowerCase().replace(/ñ/g, "n");
};

/**
 * Cada palabra de la consulta (sin acentos) debe aparecer en al menos un campo.
 * Permite "500 paracetamol", "folico acido", segunda palabra sola, etc.
 */
export const someFieldIncludesNormalizedQuery = (fields, queryRaw) => {
  const q = normalizeForSearch(queryRaw);
  if (!q) return true;
  const tokens = q.split(/\s+/).filter(Boolean);
  if (!tokens.length) return true;
  const normalizedFields = fields.map((f) => normalizeForSearch(f));
  return tokens.every((tok) =>
    normalizedFields.some((nf) => tokenMatchesInNormalizedHaystack(tok, nf))
  );
};

/** Primer nombre (primer token) para saludos en UI. */
export const primerNombre = (nombre) => {
  const s = String(nombre ?? "").trim();
  if (!s) return "";
  return s.split(/\s+/)[0];
};

/** "Hola Juan" para barras laterales / cabeceras; sin nombre → "Hola". */
export const saludoUsuario = (nombre) => {
  const p = primerNombre(nombre);
  return p ? `Hola ${p}` : "Hola";
};

// Genera un salt aleatorio único (32 chars hex)
export const generateSalt = () => {
  const arr = new Uint8Array(16);
  crypto.getRandomValues(arr);
  return Array.from(arr).map(b=>b.toString(16).padStart(2,"0")).join("");
};

// Hash con salt único por usuario (P1.4)
export const hashPwd = async (pwd, salt=null) => {
  // Si no hay salt, usar el estático como fallback (compatibilidad)
  const s = salt || "farmacapital_2026_salt";
  const salted = s + pwd + s.length;
  const buf = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(salted));
  return Array.from(new Uint8Array(buf)).map(b=>b.toString(16).padStart(2,"0")).join("");
};

// Hash legacy (SHA-256 puro) para migración
export const hashPwdLegacy = async pwd => {
  const buf = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(pwd));
  return Array.from(new Uint8Array(buf)).map(b=>b.toString(16).padStart(2,"0")).join("");
};

// ────────────────────────────────────────────────────────────────
// F6b: helpers de sesión para llamar RPCs *_secure / admin_* / etc.
// ────────────────────────────────────────────────────────────────

/** Token de sesión de empleado (null si no hay sesión admin). */
export const getSessionToken = () => {
  try { return sessionStorage.getItem("farmacapital_session_token") || null; }
  catch { return null; }
};

export { esErrorSesionEmpleado, onSesionEmpleadoInvalida } from "./utils/sesionEmpleadoAuth";

/** Token de sesión de cliente (tienda pública). Persiste en localStorage. */
export { getClienteToken } from "./utils/clienteSession.js";

/**
 * Llama una RPC con p_session_token automático. Si la RPC devuelve
 * un error de sesión (28000 / 42501), propaga un mensaje claro.
 *
 *   const { data, error } = await rpcSecure("admin_editar_producto", { p_producto_id, p_patch });
 */
export const rpcSecure = async (fn, args = {}) => {
  const tok = getSessionToken();
  if (!tok) {
    return { data: null, error: new Error("Sesión no iniciada") };
  }
  return await supabase.rpc(fn, { p_session_token: tok, ...args });
};

/** Igual que rpcSecure pero usa el token de cliente (Tienda). */
export const rpcClienteSecure = async (fn, args = {}) => {
  const tok = getClienteToken();
  if (!tok) {
    return { data: null, error: new Error("Sesión cliente no iniciada") };
  }
  return await supabase.rpc(fn, { p_session_token: tok, ...args });
};

/**
 * Las RPC F6a/F6b devuelven `token` + `usuario` o `cliente`; el frontend
 * histórico usa `session_token` + `user`. Unifica ambos formatos.
 */
export function normalizarSesionLoginResp(resp) {
  if (!resp || typeof resp !== "object") return resp;
  const session_token = resp.session_token ?? resp.token ?? null;
  const user = resp.user ?? resp.usuario ?? resp.cliente ?? null;
  return { ...resp, session_token, user };
}

/**
 * DEPRECATED (cliente): no inserta en audit_log.
 * La auditoría en producción la escriben triggers / RPC SECURITY DEFINER en el servidor.
 * Se mantiene la export para no romper imports; en desarrollo se avisa una sola vez.
 */
let logAuditLegacyWarned = false;
export const logAudit = async (usuario, accion, tabla = "", registro_id = "", detalle = {}) => {
  if (process.env.NODE_ENV === "development" && !logAuditLegacyWarned) {
    logAuditLegacyWarned = true;
    console.warn(
      "[FarmaCapital] logAudit() está neutralizado en el navegador. " +
        "La fuente de verdad de auditoría es server-side (triggers, RPC, tablas protegidas por RLS)."
    );
  }
  void usuario;
  void accion;
  void tabla;
  void registro_id;
  void detalle;
};

/**
 * DEPRECATED (cliente): no inserta en movimientos_inventario.
 * Los movimientos se registran dentro de las transacciones RPC (p. ej. venta, ajustes *_secure).
 */
let logMovimientoLegacyWarned = false;
export const logMovimiento = async (
  producto_id,
  tipo,
  cantidad,
  stock_antes,
  stock_despues,
  motivo = "",
  usuario_id = null
) => {
  if (process.env.NODE_ENV === "development" && !logMovimientoLegacyWarned) {
    logMovimientoLegacyWarned = true;
    console.warn(
      "[FarmaCapital] logMovimiento() está neutralizado en el navegador. " +
        "Los movimientos de inventario se generan en el servidor vía RPC."
    );
  }
  void producto_id;
  void tipo;
  void cantidad;
  void stock_antes;
  void stock_despues;
  void motivo;
  void usuario_id;
};
