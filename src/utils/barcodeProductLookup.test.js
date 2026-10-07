import {
  queryCatalogoDesdeInputPos,
  normalizeBarcodeRaw,
  findProductExactScan,
  codigosBarrasDeProducto,
  looksLikeCompleteScanInput,
  isCompleteBarcodeLength,
  shouldClearScanMiss,
  shouldReplaceScanInput,
  esperaBusquedaPos,
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

  test("quita el prefijo AIM de la pistola", () => {
    expect(normalizeBarcodeRaw("]C17501234567890")).toBe("7501234567890");
    expect(normalizeBarcodeRaw("]d27501234567890")).toBe("7501234567890");
  });
});

describe("Dibar rojo 500 ml: bote vs ticket OCR", () => {
  const dibar500 = {
    id: 340,
    activo: true,
    sku: "FC-68990023",
    nombre: "Alcohol Etilico Rojo 96°",
    codigo_barras: "7501868990023",
    descripcion: "EAN bote 7501868900233 · EAN ticket OCR 7501868990023.",
  };

  test("el EAN del bote abre el SKU que nació con el código del ticket", () => {
    expect(codigosBarrasDeProducto(dibar500)).toEqual(
      expect.arrayContaining(["7501868900233", "7501868990023"])
    );
    expect(findProductExactScan([dibar500], "7501868900233")?.id).toBe(340);
    expect(findProductExactScan([dibar500], "7501868990023")?.id).toBe(340);
  });

  test("no confunde el 500 ml con el 250 ml", () => {
    const rojo250 = {
      id: 338,
      activo: true,
      sku: "FC-68900226",
      nombre: "Alcohol Etilico Rojo 96°",
      codigo_barras: "7501868900226",
    };
    expect(findProductExactScan([dibar500, rojo250], "7501868900233")?.id).toBe(340);
    expect(findProductExactScan([dibar500, rojo250], "7501868900226")?.id).toBe(338);
  });
});

describe("Troferit / Schick: tipógrafo y display Edgewell", () => {
  test("Troferit: tipógrafo Cityfarma abre la caja real", () => {
    const troferit = {
      id: 901,
      activo: true,
      sku: "FC-88576495",
      nombre: "Troferit 30 mg",
      codigo_barras: "7501088575495",
      descripcion: "EAN caja 7501088575495 · tipógrafo ticket 7501088576495.",
    };
    expect(findProductExactScan([troferit], "7501088575495")?.id).toBe(901);
    expect(findProductExactScan([troferit], "7501088576495")?.id).toBe(901);
  });

  test("Schick bolsa ×12: display Edgewell abre el SKU Zorro; pieza suelta no", () => {
    const bolsa = {
      id: 902,
      activo: true,
      sku: "FC-274881475",
      nombre: "Schick Xtreme 3 Piel Sensible",
      codigo_barras: "7502274881475",
      descripcion:
        "EAN bolsa ticket 7502274881475 · EAN display Edgewell 6937266702079 · no confundir con empaque individual.",
    };
    const pieza = {
      id: 903,
      activo: true,
      sku: "FC-66701015",
      nombre: "Schick Xtreme 3 Piel Sensible",
      codigo_barras: "7591066701015",
    };
    expect(findProductExactScan([bolsa, pieza], "6937266702079")?.id).toBe(902);
    expect(findProductExactScan([bolsa, pieza], "7502274881475")?.id).toBe(902);
    expect(findProductExactScan([bolsa, pieza], "7591066701015")?.id).toBe(903);
  });
});

describe("Estomaquil C/20 vs C/10: ficha no debe robar el EAN", () => {
  const c20 = {
    id: 637,
    activo: true,
    sku: "FC-69200016",
    nombre: "Estomaquil Polvo C/20",
    codigo_barras: "7501369200016",
    descripcion: "Estomaquil Polvo C/20 sobres 3 g — Higia.",
  };
  const c10 = {
    id: 1400,
    activo: true,
    sku: "FC-69200085",
    nombre: "Estomaquil polvo 3 g C/10 sobres",
    codigo_barras: "7501369200085",
    // Bug: citaba el EAN del C/20; el POS lo trataba como código alterno.
    descripcion:
      "Farmalive 127790 · Fahorro Estomaquil C/10 EAN 7501369200085 · distinto de C/20 7501369200016",
  };

  test("escanear 7501369200016 abre C/20 aunque el C/10 lo mencione en descripción", () => {
    expect(codigosBarrasDeProducto(c10)).toEqual(
      expect.arrayContaining(["7501369200085", "7501369200016"])
    );
    expect(findProductExactScan([c10, c20], "7501369200016")?.sku).toBe("FC-69200016");
    expect(findProductExactScan([c20, c10], "7501369200016")?.sku).toBe("FC-69200016");
    expect(findProductExactScan([c10, c20], "7501369200085")?.sku).toBe("FC-69200085");
  });
});

describe("Optims Extra Suavidad: los dos códigos del ticket son la misma crema", () => {
  const crema = {
    id: 19985,
    activo: true,
    sku: "FC-46695570",
    nombre: "Optims Extra Suavidad crema para peinar",
    codigo_barras: "7509546695570",
    descripcion: "EAN 7509546695570. Mismo producto el código 7509546695587.",
  };

  test("cualquiera de los dos EAN abre la misma ficha", () => {
    expect(codigosBarrasDeProducto(crema)).toEqual(
      expect.arrayContaining(["7509546695570", "7509546695587"])
    );
    expect(findProductExactScan([crema], "7509546695570")?.id).toBe(19985);
    expect(findProductExactScan([crema], "7509546695587")?.id).toBe(19985);
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

  test("el tecleo no repinta el catálogo en cada letra ni a mitad del EAN", () => {
    expect(esperaBusquedaPos("")).toBe(0);
    expect(esperaBusquedaPos("p")).toBe(160);
    expect(esperaBusquedaPos("para")).toBe(160);
    expect(esperaBusquedaPos("7501")).toBe(null);
    expect(esperaBusquedaPos("7501234567890")).toBe(0);
    expect(esperaBusquedaPos("FC-123")).toBe(0);
  });

  test("teclear dosis no pisa el buscador (paracetamol 500 mg)", () => {
    const t0 = 1_000_000;
    // Sin espacios: "paracetamol5" = 12, "paracetamol50" = 13, "paracetamol500" = 14.
    // Antes se trataba como EAN y al teclear el siguiente dígito borraba todo.
    expect(shouldReplaceScanInput("paracetamol 5", t0, t0 + 500)).toBe(false);
    expect(shouldReplaceScanInput("paracetamol 50", t0, t0 + 500)).toBe(false);
    expect(shouldReplaceScanInput("paracetamol 500", t0, t0 + 500)).toBe(false);
    expect(shouldReplaceScanInput("paracetamol 500 mg", t0, t0 + 500)).toBe(false);
    expect(shouldReplaceScanInput("ibuprofeno 400", t0, t0 + 800)).toBe(false);
  });

  test("UPC-A con cero a la izquierda sigue pegando en idle", () => {
    const upc = { id: 1, activo: true, sku: "X", codigo_barras: "747589705123" };
    expect(findProductExactScan([upc], "0747589705123", { allowNearPrefix: false })?.id).toBe(1);
  });
});
