/** Detección y aviso de sesión de empleado muerta (caja, recibir, inventario…). */

const listeners = new Set();
let lastNotifyAt = 0;

export function esErrorSesionEmpleado(msg) {
  const m = String(msg || "").toLowerCase();
  if (!m) return false;
  return (
    m.includes("sesión inválida") ||
    m.includes("sesion invalida") ||
    m.includes("sesión expirada") ||
    m.includes("sesion expirada") ||
    m.includes("sesión no iniciada") ||
    m.includes("sesion no iniciada")
  );
}

export function onSesionEmpleadoInvalida(fn) {
  listeners.add(fn);
  return () => listeners.delete(fn);
}

export function notifySesionEmpleadoInvalida() {
  const now = Date.now();
  if (now - lastNotifyAt < 2000) return;
  lastNotifyAt = now;
  listeners.forEach((fn) => {
    try { fn(); } catch (_) { /* noop */ }
  });
}

export function rpcIndicaSesionEmpleadoMuerta(fn, args, error) {
  if (!error || !esErrorSesionEmpleado(error.message || error)) return false;
  if (fn === "login_empleado" || fn === "login_cliente" || fn === "logout_empleado") return false;
  const tok = args && (args.p_session_token || args.p_token);
  return !!tok;
}
