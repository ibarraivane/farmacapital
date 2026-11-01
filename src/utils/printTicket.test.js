import {
  isStandalonePwa,
  shouldKeepPrintWindowOpen,
  TICKET_CSS,
  TICKET_SIDE_PAD_MM,
  TICKET_PDF_WIDTH_MM,
  ticketPdfPageSizeMm,
  ticketPdfFilename,
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

describe("márgenes térmicos Epson 80 mm", () => {
  test("padding lateral deja el texto dentro del área imprimible (~72 mm)", () => {
    expect(TICKET_SIDE_PAD_MM).toBeGreaterThanOrEqual(5);
    // 80 − 2×pad ≤ 72 mm del cabezal TM-T20
    expect(80 - 2 * TICKET_SIDE_PAD_MM).toBeLessThanOrEqual(72);
    expect(TICKET_CSS).toContain(`${TICKET_SIDE_PAD_MM}mm`);
    expect(TICKET_CSS).not.toMatch(/padding:\s*3mm 2mm/);
  });
});

describe("PDF ticket 80 mm (no hoja carta)", () => {
  test("el ancho fijo es 80 mm y el alto sigue la proporción del canvas", () => {
    expect(TICKET_PDF_WIDTH_MM).toBe(80);
    // canvas 800×2000 → alto 200 mm
    expect(ticketPdfPageSizeMm(800, 2000)).toEqual({ widthMm: 80, heightMm: 200 });
    // ticket corto
    expect(ticketPdfPageSizeMm(400, 600).heightMm).toBe(120);
  });

  test("valores inválidos no rompen el PDF", () => {
    expect(ticketPdfPageSizeMm(0, 100)).toEqual({ widthMm: 80, heightMm: 80 });
    expect(ticketPdfPageSizeMm(100, 1).heightMm).toBe(20); // piso 20 mm
  });

  test("nombre de archivo sanear folio", () => {
    expect(ticketPdfFilename("VTA-00001234")).toBe("Ticket_FarmaCapital_VTA-00001234.pdf");
    expect(ticketPdfFilename("a/b c")).toMatch(/^Ticket_FarmaCapital_a_b_c\.pdf$/);
  });
});
