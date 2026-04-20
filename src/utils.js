// FARMAX — Utilidades globales
import { supabase } from "./supabase";
import { C } from "./constants";

export const dC   = f => Math.floor((new Date(f)-new Date())/86400000);
export const cC   = d => d<0?C.red:d<15?C.red:d<30?C.amber:C.green;
export const $    = n => `$${Number(n).toLocaleString("es-MX")}`;
export const abc  = i => { const v=i.stock*i.price; return v>800?"A":v>300?"B":"C"; };
export const aCol = a => ({A:C.green,B:C.amber,C:C.red}[a]);
export const nCol = n => ({Gold:C.amber,Silver:C.textMid,Bronze:"#cd7f32"}[n]||C.textMid);

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
  const s = salt || "farmax_2026_salt";
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
  try { return sessionStorage.getItem("farmax_session_token") || null; }
  catch { return null; }
};

/** Token de sesión de cliente (tienda pública). */
export const getClienteToken = () => {
  try { return sessionStorage.getItem("farmax_cliente_token") || null; }
  catch { return null; }
};

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

let auditLogDisabled = false;

export const logAudit = async (usuario, accion, tabla="", registro_id="", detalle={}) => {
  if (auditLogDisabled) return;
  try {
    const { error } = await supabase.from("audit_log").insert({
      usuario_id: usuario?.id||null,
      usuario_nombre: usuario?.nombre||"Sistema",
      accion, tabla,
      registro_id: String(registro_id),
      detalle,
    });
    if (error) {
      // If audit table/columns are missing in this environment, stop retrying.
      auditLogDisabled = true;
      console.warn("audit_log disabled:", error.message);
    }
  } catch(e) { console.warn("audit_log error:", e); }
};

let movimientoLogDisabled = false;

export const logMovimiento = async (producto_id, tipo, cantidad, stock_antes, stock_despues, motivo="", usuario_id=null) => {
  if (movimientoLogDisabled) return;
  try {
    const { error } = await supabase.from("movimientos_inventario").insert({
      producto_id, tipo, cantidad, stock_antes, stock_despues, motivo, usuario_id,
    });
    if (error) {
      movimientoLogDisabled = true;
      console.warn("movimientos_inventario disabled:", error.message);
    }
  } catch(e) { console.warn("movimientos_inventario error:", e); }
};
