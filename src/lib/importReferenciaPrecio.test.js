import { parseGenericoRows, matchImportRows } from "./importReferenciaPrecio";

const productos = [
  { id: 1, sku: "FC-00005823", nombre: "Tobramicina", codigo_barras: "008400005823", marca: "" },
  { id: 2, sku: "FC-24227339", nombre: "Loxcel adulto", codigo_barras: "7502224227339", marca: "" },
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
});
