import { isStandalonePwa, shouldKeepPrintWindowOpen, printPreparedHtml, printTicket } from "./printTicket";

function mockMatchMedia(matchesByQuery) {
  window.matchMedia = (query) => ({
    matches: Boolean(matchesByQuery[query]),
    media: query,
    addEventListener() {},
    removeEventListener() {},
    addListener() {},
    removeListener() {},
    dispatchEvent() { return false; },
  });
}

describe("impresión tablet / PWA", () => {
  const originalMatchMedia = window.matchMedia;
  const originalStandalone = window.navigator.standalone;

  afterEach(() => {
    window.matchMedia = originalMatchMedia;
    Object.defineProperty(window.navigator, "standalone", {
      configurable: true,
      value: originalStandalone,
    });
  });

  test("en PC no mantiene la ventana abierta (popup, no iframe)", () => {
    mockMatchMedia({
      "(pointer: coarse)": false,
      "(hover: none)": false,
      "(display-mode: standalone)": false,
    });
    Object.defineProperty(window.navigator, "standalone", { configurable: true, value: false });
    expect(isStandalonePwa()).toBe(false);
    expect(shouldKeepPrintWindowOpen()).toBe(false);
  });

  test("en tablet (puntero grueso) usa el flujo térmico (iframe oculto)", () => {
    mockMatchMedia({
      "(pointer: coarse)": true,
      "(hover: none)": true,
      "(display-mode: standalone)": false,
    });
    expect(shouldKeepPrintWindowOpen()).toBe(true);
  });

  test("en PWA instalada también usa el flujo térmico", () => {
    mockMatchMedia({
      "(pointer: coarse)": false,
      "(hover: none)": false,
      "(display-mode: standalone)": true,
    });
    expect(isStandalonePwa()).toBe(true);
    expect(shouldKeepPrintWindowOpen()).toBe(true);
  });
});

describe("impresión térmica 80 mm (PC y tablet)", () => {
  test("printPreparedHtml siempre intenta captura canvas (no solo HTML @page)", () => {
    // Si fallara el import de html2canvas, cae a printRawHtml; aquí solo
    // verificamos que no abra el diálogo síncrono de HTML puro en PC.
    const openSpy = jest.spyOn(window, "open").mockReturnValue(null);
    const alertSpy = jest.spyOn(window, "alert").mockImplementation(() => {});
    const ok = printPreparedHtml("<div id=\"farmacapital-ticket\">x</div>");
    expect(ok).toBe(true);
    // Canvas es async: no debe haber abierto popup todavía en este tick
    expect(openSpy).not.toHaveBeenCalled();
    openSpy.mockRestore();
    alertSpy.mockRestore();
  });

  test("printTicket sin nodo devuelve false", () => {
    expect(printTicket("no-existe-este-ticket")).toBe(false);
  });
});
