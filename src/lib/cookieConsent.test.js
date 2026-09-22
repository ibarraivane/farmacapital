import { leerConsentimientoCookies, guardarConsentimientoCookies, COOKIE_CONSENT_KEY } from "./cookieConsent";

function memoria() {
  const data = new Map();
  return {
    getItem: (k) => (data.has(k) ? data.get(k) : null),
    setItem: (k, v) => data.set(k, String(v)),
  };
}

test("sin elección, el aviso debe mostrarse", () => {
  expect(leerConsentimientoCookies(memoria())).toBeNull();
});

test("aceptar o rechazar se recuerda y no se vuelve a preguntar", () => {
  const store = memoria();
  guardarConsentimientoCookies(store, "aceptadas");
  expect(store.getItem(COOKIE_CONSENT_KEY)).toBe("aceptadas");
  expect(leerConsentimientoCookies(store)).toBe("aceptadas");
  guardarConsentimientoCookies(store, "rechazadas");
  expect(leerConsentimientoCookies(store)).toBe("rechazadas");
});

test("un valor raro no cuenta como decisión", () => {
  const store = memoria();
  store.setItem(COOKIE_CONSENT_KEY, "si");
  expect(leerConsentimientoCookies(store)).toBeNull();
});
