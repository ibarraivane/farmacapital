import { buildPedidosPorSurtidorSheets, nombreHojaExcel } from "./exportarPedidoProveedor";

describe("excel por surtidor", () => {
  test("una hoja por surtidor más el resumen", () => {
    const sheets = buildPedidosPorSurtidorSheets([
      {
        proveedor: "El Surtidor",
        fuente: "surtidor:el_surtidor",
        total: 80,
        productos: [
          { nombre: "Tegaderm", sku: "FC-1", codigo_barras: "4001895928765", cantidadPedida: 2, precioUnit: 40 },
        ],
      },
      {
        proveedor: "Exprezo",
        fuente: "exprezo",
        total: 24,
        productos: [
          { nombre: "Jabón", sku: "FC-2", cantidadPedida: 2, precioUnit: 12 },
        ],
      },
    ]);
    expect(sheets.map((s) => s.name)).toEqual(["Resumen", "El Surtidor", "Exprezo"]);
    expect(sheets[1].aoa[1][3]).toBe("Tegaderm");
    expect(sheets[2].aoa[1][3]).toBe("Jabón");
  });

  test("nombres de hoja únicos y sin caracteres ilegales", () => {
    const used = new Set();
    expect(nombreHojaExcel("El Surtidor / Farma?", used)).toBe("El Surtidor Farma");
    expect(nombreHojaExcel("El Surtidor / Farma?", used)).toMatch(/2$/);
  });
});
