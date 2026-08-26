import { queryCatalogoDesdeInputPos, normalizeBarcodeRaw } from "./barcodeProductLookup";

describe("queryCatalogoDesdeInputPos", () => {
  test("conserva espacios de una molestia de mostrador", () => {
    expect(queryCatalogoDesdeInputPos("dolor de cabeza")).toBe("dolor de cabeza");
    expect(normalizeBarcodeRaw("dolor de cabeza")).toBe("dolordecabeza");
  });

  test("pega el EAN de la pistola", () => {
    expect(queryCatalogoDesdeInputPos("7501234567890")).toBe("7501234567890");
    expect(queryCatalogoDesdeInputPos("750 1234 567890")).toBe("7501234567890");
  });
});
