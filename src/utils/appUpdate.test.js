import {
  parseVersionJson,
  setBloqueaReloadApp,
  paginaEnTrabajoCritico,
  versionRemotaEsNueva,
  buildIdLocal,
  aplicarNuevaVersion,
} from "./appUpdate";

describe("versionRemotaEsNueva", () => {
  test("mismo id no recarga", () => {
    expect(versionRemotaEsNueva("2026-08-23T01:00:00.000Z", { id: "2026-08-23T01:00:00.000Z" })).toBe(false);
  });
  test("id distinto sí", () => {
    expect(versionRemotaEsNueva("viejo", { id: "nuevo" })).toBe(true);
  });
  test("sin id local o remoto, no", () => {
    expect(versionRemotaEsNueva("", { id: "nuevo" })).toBe(false);
    expect(versionRemotaEsNueva("viejo", {})).toBe(false);
  });
});

describe("parseVersionJson", () => {
  test("lee id", () => {
    expect(parseVersionJson({ id: "abc", builtAt: "x" })).toEqual({ id: "abc", builtAt: "x" });
  });
  test("rechaza basura", () => {
    expect(parseVersionJson(null)).toBeNull();
    expect(parseVersionJson({ foo: 1 })).toBeNull();
  });
});

describe("bloqueos de recarga", () => {
  afterEach(() => {
    setBloqueaReloadApp(false, "pos-cart");
    setBloqueaReloadApp(false, "recibir");
  });

  test("POS y Recibir pueden bloquear a la vez", () => {
    setBloqueaReloadApp(true, "pos-cart");
    expect(paginaEnTrabajoCritico()).toBe(true);
    setBloqueaReloadApp(false, "pos-cart");
    expect(paginaEnTrabajoCritico()).toBe(false);
    setBloqueaReloadApp(true, "recibir");
    setBloqueaReloadApp(true, "pos-cart");
    setBloqueaReloadApp(false, "recibir");
    expect(paginaEnTrabajoCritico()).toBe(true);
    setBloqueaReloadApp(false, "pos-cart");
    expect(paginaEnTrabajoCritico()).toBe(false);
  });

  test("con carrito no recarga", () => {
    setBloqueaReloadApp(true, "pos-cart");
    expect(aplicarNuevaVersion()).toEqual({ recargo: false, diferido: true });
  });
});

describe("buildIdLocal", () => {
  test("lee window", () => {
    expect(buildIdLocal({ __FARMACAPITAL_BUILD_ID__: "  z  " })).toBe("z");
  });
});
