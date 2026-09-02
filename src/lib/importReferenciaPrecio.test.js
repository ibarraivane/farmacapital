import { parseGenericoRows, matchImportRows } from "./importReferenciaPrecio";
import {
  detectarInversionesPrecioPorTamano,
  coherenciaSugeridosPorTamano,
  extraerTamanoConsumo,
  proponerPreciosVentaPorTamano,
} from "./preciosPorTamano";

const productos = [
  { id: 1, sku: "FC-00005823", nombre: "Tobramicina", codigo_barras: "008400005823", marca: "" },
  { id: 2, sku: "FC-24227339", nombre: "Loxcel adulto", codigo_barras: "7502224227339", marca: "" },
];

const oxigenadas = [
  {
    id: 387,
    sku: "FC-83351381",
    nombre: "Agua oxigenada Dermocleen",
    marca: "Dermocleen",
    presentacion: "100 ML",
    forma_farmaceutica: "Agua oxigenada",
    precio: 13,
  },
  {
    id: 386,
    sku: "FC-83351691",
    nombre: "Agua oxigenada Dermocleen",
    marca: "Dermocleen",
    presentacion: "230 ML",
    forma_farmaceutica: "Agua oxigenada",
    precio: 16,
  },
  {
    id: 390,
    sku: "FC-48335305",
    nombre: "Agua oxigenada Dermocleen",
    marca: "Dermocleen",
    presentacion: "480 ML",
    forma_farmaceutica: "Agua oxigenada",
    precio: 15,
  },
];

describe("import ReferenciaPrecio Farmalive", () => {
  test("lee ean + precio 2%", () => {
    const rows = parseGenericoRows(
      [{ ean: "7502224227339", nombre: "LOXCELL ADTO", "precio 2%": "76.44", _line: 2 }],
      ["ean", "nombre", "precio 2%"]
    );
    expect(rows).toHaveLength(1);
    expect(rows[0].ean).toBe("7502224227339");
    expect(rows[0].precio).toBe(76.44);
  });

  test("match por EAN (UPC con/sin cero)", () => {
    const { matched, unmatched } = matchImportRows(
      [{ ean: "8400005823", nombre_fuente: "TOBRA", precio: 46.55 }],
      productos
    );
    expect(unmatched).toHaveLength(0);
    expect(matched[0].sku).toBe("FC-00005823");
    expect(matched[0].confianza).toBe(100);
  });

  test("sin EAN en catálogo no inventa match", () => {
    const { matched, unmatched } = matchImportRows(
      [{ ean: "7501125174193", nombre_fuente: "AMOXIC SALUCOM", precio: 41.65 }],
      productos,
      { minScore: 95 }
    );
    expect(matched).toHaveLength(0);
    expect(unmatched).toHaveLength(1);
  });

  test("fuzzy no cruza agua oxigenada 250 ml con la de 100 ml", () => {
    const { matched, unmatched } = matchImportRows(
      [{ nombre_fuente: "Botella de Agua Oxigenada 250 ml", precio: 13.2 }],
      oxigenadas,
      { minScore: 50 }
    );
    expect(matched).toHaveLength(0);
    expect(unmatched).toHaveLength(1);
  });

  test("fuzzy sí empareja 480 ml con lista 500 ml cercana", () => {
    const { matched } = matchImportRows(
      [{ nombre_fuente: "Agua Oxigenada Dermocleen 500 ml", precio: 18.5 }],
      oxigenadas,
      { minScore: 50 }
    );
    expect(matched).toHaveLength(1);
    expect(matched[0].sku).toBe("FC-48335305");
  });
});

describe("precios por tamaño", () => {
  test("extrae ml", () => {
    expect(extraerTamanoConsumo("480 ML")).toEqual({ cantidad: 480, unidad: "ml" });
  });

  test("detecta botella grande más barata que la chica", () => {
    const inv = detectarInversionesPrecioPorTamano(oxigenadas);
    expect(inv.length).toBeGreaterThanOrEqual(1);
    expect(inv.some((x) => x.grande.sku === "FC-48335305" && x.precioGrande < x.precioChico)).toBe(true);
  });

  test("proponer precios ordena 100 < 230 < 480 ml", () => {
    const corr = proponerPreciosVentaPorTamano(oxigenadas);
    const porSku = Object.fromEntries(corr.map((c) => [c.producto.sku, c.a]));
    // 480 ml estaba a $15; debe subir al menos a $16 (precio de 230 ml)
    expect(porSku["FC-48335305"]).toBeGreaterThanOrEqual(16);
  });

  test("coherencia sube el sugerido de la botella grande", () => {
    const filas = oxigenadas.map((p) => ({
      producto: p,
      sugerido: p.sku === "FC-48335305" ? 15 : p.precio,
    }));
    const out = coherenciaSugeridosPorTamano(filas);
    const grande = out.find((f) => f.producto.sku === "FC-48335305");
    expect(grande.sugerido).toBeGreaterThanOrEqual(16);
    expect(grande.coherenciaTamano).toBe(true);
  });

  test("agrupa agua oxigenada aunque falte forma_farmaceutica", () => {
    const sinForma = oxigenadas.map((p) => ({ ...p, forma_farmaceutica: "" }));
    const inv = detectarInversionesPrecioPorTamano(sinForma);
    expect(inv.length).toBeGreaterThanOrEqual(1);
  });
});
