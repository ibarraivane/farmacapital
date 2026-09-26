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

  test("encendida por defecto (producción)", () => {
    expect(tiendaV2Activa()).toBe(true);
  });

  test("?v2=0 muestra la tienda anterior en la sesión y ?v2=1 la regresa", () => {
    window.history.replaceState({}, "", "/?v2=0");
    expect(tiendaV2Activa()).toBe(false);
    window.history.replaceState({}, "", "/catalogo");
    expect(tiendaV2Activa()).toBe(false);
    window.history.replaceState({}, "", "/?v2=1");
    expect(tiendaV2Activa()).toBe(true);
    window.history.replaceState({}, "", "/");
    expect(tiendaV2Activa()).toBe(true);
  });

  test("REACT_APP_TIENDA_V2=0 la apaga para todos", () => {
    process.env.REACT_APP_TIENDA_V2 = "0";
    window.history.replaceState({}, "", "/?v2=1");
    expect(tiendaV2Activa()).toBe(false);
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
