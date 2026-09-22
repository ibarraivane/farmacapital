import { aplicarTiendaV2, tiendaV2Activa, V2 } from "./tiendaV2";

describe("tiendaV2Activa", () => {
  const env = process.env;

  beforeEach(() => {
    process.env = { ...env };
    delete process.env.REACT_APP_TIENDA_V2;
    window.history.replaceState({}, "", "/");
    sessionStorage.clear();
  });

  afterAll(() => {
    process.env = env;
  });

  test("apagada por defecto", () => {
    expect(tiendaV2Activa()).toBe(false);
  });

  test("se enciende con ?v2=1 y persiste en la sesión", () => {
    window.history.replaceState({}, "", "/?v2=1");
    expect(tiendaV2Activa()).toBe(true);
    window.history.replaceState({}, "", "/catalogo");
    expect(tiendaV2Activa()).toBe(true);
  });

  test("?v2=0 apaga y limpia la sesión", () => {
    window.history.replaceState({}, "", "/?v2=1");
    expect(tiendaV2Activa()).toBe(true);
    window.history.replaceState({}, "", "/?v2=0");
    expect(tiendaV2Activa()).toBe(false);
    window.history.replaceState({}, "", "/");
    expect(tiendaV2Activa()).toBe(false);
  });

  test("REACT_APP_TIENDA_V2=1 enciende sin query", () => {
    process.env.REACT_APP_TIENDA_V2 = "1";
    expect(tiendaV2Activa()).toBe(true);
  });
});

test("aplicarTiendaV2 publica variables solo en el elemento", () => {
  const el = document.createElement("div");
  aplicarTiendaV2(el);
  expect(el.style.getPropertyValue("--ink")).toBe(V2.ink);
  expect(el.style.getPropertyValue("--jade-txt")).toBe(V2.jadeTxt);
  expect(el.style.getPropertyValue("--sans")).toContain("Inter");
  expect(document.documentElement.style.getPropertyValue("--ink")).toBe("");
});
