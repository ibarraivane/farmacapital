import { isStandalonePwa, shouldKeepPrintWindowOpen } from "./printTicket";

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

  test("en PC no mantiene la ventana abierta", () => {
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
