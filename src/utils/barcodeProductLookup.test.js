import {
  queryCatalogoDesdeInputPos,
  normalizeBarcodeRaw,
  findProductExactScan,
  codigosBarrasDeProducto,
  looksLikeCompleteScanInput,
  isCompleteBarcodeLength,
  shouldClearScanMiss,
  shouldReplaceScanInput,
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

const TEGADERM = {
  id: 88,
  activo: true,
  sku: "FC-TEGA",
  nombre: "Tegaderm 3M",
  codigo_barras: "4001895928765",
};

describe("pistola POS: beep completo vs a medias", () => {
  test("Tegaderm EAN-13 abre; 12 dígitos en idle no pisan el producto", () => {
    expect(looksLikeCompleteScanInput("4001895928765")).toBe(true);
    expect(isCompleteBarcodeLength("400189592876")).toBe(true);
    expect(looksLikeCompleteScanInput("400189")).toBe(false);
    expect(findProductExactScan([TEGADERM], "4001895928765")?.id).toBe(88);
    expect(findProductExactScan([TEGADERM], "400189592876", { allowNearPrefix: false })).toBeNull();
    expect(findProductExactScan([TEGADERM], "400189592876")?.id).toBe(88);
  });

  test("no borres el recuadro a los 12 dígitos: aún puede llegar el 13", () => {
    expect(shouldClearScanMiss("400189592876", { fromEnter: false })).toBe(false);
    expect(shouldClearScanMiss("40018959", { fromEnter: false })).toBe(false);
    expect(shouldClearScanMiss("4001895928765", { fromEnter: false })).toBe(true);
    expect(shouldClearScanMiss("400189592876", { fromEnter: true })).toBe(true);
  });

  test("pausa Bluetooth a mitad de EAN-13 no reemplaza el campo", () => {
    const t0 = 1_000_000;
    expect(shouldReplaceScanInput("40018959", t0, t0 + 250)).toBe(false);
    expect(shouldReplaceScanInput("40018959", t0, t0 + 500)).toBe(false);
    expect(shouldReplaceScanInput("4001895928765", t0, t0 + 250)).toBe(false);
    expect(shouldReplaceScanInput("4001895928765", t0, t0 + 450)).toBe(true);
    expect(shouldReplaceScanInput("747589705123", t0, t0 + 450)).toBe(true);
  });

  test("UPC-A con cero a la izquierda sigue pegando en idle", () => {
    const upc = { id: 1, activo: true, sku: "X", codigo_barras: "747589705123" };
    expect(findProductExactScan([upc], "0747589705123", { allowNearPrefix: false })?.id).toBe(1);
  });
});
