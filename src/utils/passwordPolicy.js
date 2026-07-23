/** Reglas de contraseña — tienda FarmaCapital (validar también en SQL). */

export const PASSWORD_MIN_LENGTH = 8;

export const PASSWORD_RULES_TEXT =
  "Mínimo 8 caracteres, al menos una letra y un número.";

export function validarPasswordTienda(password) {
  const pwd = String(password || "");
  if (pwd.length < PASSWORD_MIN_LENGTH) {
    return {
      ok: false,
      error: `La contraseña debe tener al menos ${PASSWORD_MIN_LENGTH} caracteres.`,
    };
  }
  if (!/[A-Za-zÁÉÍÓÚáéíóúÑñ]/.test(pwd)) {
    return { ok: false, error: "Incluye al menos una letra." };
  }
  if (!/\d/.test(pwd)) {
    return { ok: false, error: "Incluye al menos un número." };
  }
  if (/\s/.test(pwd)) {
    return { ok: false, error: "No uses espacios en la contraseña." };
  }
  return { ok: true };
}

export function passwordsCoinciden(a, b) {
  return String(a || "") === String(b || "") && String(a || "").length > 0;
}
