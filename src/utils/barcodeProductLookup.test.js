import {
  queryCatalogoDesdeInputPos,
  normalizeBarcodeRaw,
  findProductExactScan,
  codigosBarrasDeProducto,
} from "./barcodeProductLookup";

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

describe("Broncolin paleta: bote y pieza", () => {
  const paleta = {
    id: 702,
    activo: true,
    sku: "FC-06903205",
    nombre: "Broncolin Paleta",
    codigo_barras: "747589705123",
    descripcion: "EAN pieza 747589705123 · EAN bote C/50 714706903205.",
  };

  test("el EAN del vitrolero y el de la paleta son el mismo producto", () => {
    expect(codigosBarrasDeProducto(paleta)).toEqual(
      expect.arrayContaining(["747589705123", "714706903205"])
    );
    expect(findProductExactScan([paleta], "714706903205")?.id).toBe(702);
    expect(findProductExactScan([paleta], "7 14706 90320 5")?.id).toBe(702);
    expect(findProductExactScan([paleta], "747589705123")?.id).toBe(702);
    expect(findProductExactScan([paleta], "0714706903205")?.id).toBe(702);
  });
});
