export const COOKIE_CONSENT_KEY = "farmacapital_cookie_consent";

/** null = todavía no eligió. El carrito y la sesión no dependen de este valor. */
export function leerConsentimientoCookies(storage) {
  try {
    const v = storage?.getItem(COOKIE_CONSENT_KEY);
    if (v === "aceptadas" || v === "rechazadas") return v;
  } catch (_) { /* almacenamiento bloqueado */ }
  return null;
}

export function guardarConsentimientoCookies(storage, valor) {
  if (valor !== "aceptadas" && valor !== "rechazadas") {
    throw new Error("consentimiento_invalido");
  }
  storage.setItem(COOKIE_CONSENT_KEY, valor);
}
