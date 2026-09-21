import {
  INTRO_STORAGE_KEY,
  debeMostrarIntro,
  marcarIntroVista,
  leerIntroYaVista,
} from "./introAnimacion";

function fakeStorage() {
  const data = {};
  return {
    getItem: (k) => (k in data ? data[k] : null),
    setItem: (k, v) => { data[k] = String(v); },
  };
}

test("sale una vez por sesión", () => {
  const storage = fakeStorage();
  expect(debeMostrarIntro({ storage, win: { matchMedia: () => ({ matches: false }) } })).toBe(true);
  marcarIntroVista(storage);
  expect(leerIntroYaVista(storage)).toBe(true);
  expect(debeMostrarIntro({ storage, win: { matchMedia: () => ({ matches: false }) } })).toBe(false);
  expect(storage.getItem(INTRO_STORAGE_KEY)).toBe("1");
});

test("con movimiento reducido no se muestra", () => {
  const storage = fakeStorage();
  const win = { matchMedia: (q) => ({ matches: /reduce/.test(q) }) };
  expect(debeMostrarIntro({ storage, win })).toBe(false);
});

test("sessionStorage roto no tumba la tienda", () => {
  const storage = {
    getItem() { throw new Error("blocked"); },
    setItem() { throw new Error("blocked"); },
  };
  expect(debeMostrarIntro({ storage, win: { matchMedia: () => ({ matches: false }) } })).toBe(false);
  expect(marcarIntroVista(storage)).toBe(false);
});
