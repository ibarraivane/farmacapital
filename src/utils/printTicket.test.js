import {
  TICKET_COLA_MM,
  TICKET_CSS,
  applyThermalPageSize,
  isStandalonePwa,
  shouldKeepPrintWindowOpen,
  thermalCanvasPageMm,
} from "./printTicket";

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

describe("cola del ticket térmico", () => {
  test("1 cm después de farmacapital.mx, no 13 mm de más", () => {
    expect(TICKET_COLA_MM).toBe(10);
    expect(TICKET_CSS).toMatch(/padding: 3mm 2mm 10mm 2mm/);
    expect(TICKET_CSS).not.toMatch(/13mm/);
    expect(TICKET_CSS).not.toMatch(/calc\(10px \+ 10mm\)/);
  });

  test("la hoja mide el ticket: un canvas bajo no rellena carta (279 mm)", () => {
    const page = thermalCanvasPageMm({ width: 280, height: 300 }, { tablet: true });
    expect(page.widthMm).toBe(216);
    expect(page.heightMm).toBe(231.4);
    expect(page.heightMm).toBeLessThan(260);
  });

  test("en PC la hoja es 80 mm de ancho y el alto del ticket", () => {
    const page = thermalCanvasPageMm({ width: 280, height: 700 }, { tablet: false });
    expect(page.widthMm).toBe(80);
    expect(page.heightMm).toBe(200);
  });

  test("aplica @page al documento de impresión", () => {
    document.documentElement.classList.remove("fc-thermal-fill");
    document.body.innerHTML = `<div id="farmacapital-ticket">farmacapital.mx</div>`;
    const el = document.getElementById("farmacapital-ticket");
    Object.defineProperty(el, "scrollHeight", { configurable: true, value: 200 });
    Object.defineProperty(el, "offsetHeight", { configurable: true, value: 200 });
    const sized = applyThermalPageSize(document);
    expect(sized.heightMm).toBeGreaterThanOrEqual(40);
    const css = document.getElementById("fc-thermal-page")?.textContent || "";
    expect(css).toMatch(/@page \{ size: 80mm /);
    document.body.innerHTML = "";
  });
});
