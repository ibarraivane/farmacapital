import {
  agruparFilasPorSurtidor,
  buildReporteReabastoSheets,
  calcMejorTiendaPedido,
  cantidadSugerida,
  clasificarAlertas,
  filasReporte,
  idFuenteSurtidor,
  itemsParaPedir,
  nivelStockUrgencia,
  opcionesPedidoProducto,
} from "./reporteReabasto";

const prod = (over = {}) => ({
  id: 1,
  nombre: "Tegaderm",
  sku: "FC-1",
  stock: 0,
  stock_minimo: 4,
  costo: 40,
  ...over,
});

describe("urgencia de stock", () => {
  test("0 es agotado, ≤50% crítico, ≤mínimo bajo", () => {
    expect(nivelStockUrgencia(prod({ stock: 0, stock_minimo: 10 }))).toBe("AGOTADO");
    expect(nivelStockUrgencia(prod({ stock: 3, stock_minimo: 10 }))).toBe("CRÍTICO");
    expect(nivelStockUrgencia(prod({ stock: 8, stock_minimo: 10 }))).toBe("BAJO");
    expect(nivelStockUrgencia(prod({ stock: 12, stock_minimo: 10 }))).toBe("PRONTO");
    expect(nivelStockUrgencia(prod({ stock: 40, stock_minimo: 10 }))).toBe(null);
  });

  test("sin mínimo usa 5", () => {
    expect(nivelStockUrgencia(prod({ stock: 0, stock_minimo: 0 }))).toBe("AGOTADO");
    expect(nivelStockUrgencia(prod({ stock: 2, stock_minimo: 0 }))).toBe("CRÍTICO");
    expect(cantidadSugerida(prod({ stock: 0, stock_minimo: 4 }))).toBe(12);
  });
});

describe("mejor surtidor", () => {
  test("El Surtidor gana si el ticket es más barato que Levic", () => {
    const refs = { levic: { fuente: "levic", precio: 55 } };
    const best = calcMejorTiendaPedido(refs, { proveedor: "El surtidor de su farmacia", precio: 42 });
    expect(best.fuente).toBe("surtidor:el_surtidor");
    expect(best.label).toBe("El Surtidor");
    expect(best.precio).toBe(42);
    expect(best.opciones.map((o) => o.fuente)).toEqual(["surtidor:el_surtidor", "levic"]);
  });

  test("última compra Levic se fusiona con la lista y se queda el más barato", () => {
    const refs = { levic: { fuente: "levic", precio: 55 } };
    const ops = opcionesPedidoProducto(refs, { proveedor: "Levic", precio: 49 });
    expect(ops).toHaveLength(1);
    expect(ops[0].fuente).toBe("levic");
    expect(ops[0].precio).toBe(49);
  });

  test("id de surtidor conocido", () => {
    expect(idFuenteSurtidor("El Surtidor de su Farmacia")).toBe("surtidor:el_surtidor");
    expect(idFuenteSurtidor("Cityfarma Iztapalapa")).toBe("surtidor:farma_city");
    expect(idFuenteSurtidor("Farmalive Club")).toBe("farmalive");
    expect(idFuenteSurtidor("FARMA MAYOREO")).toBe("surtidor:farma_mayoreo");
  });
});

describe("reporte", () => {
  test("separa agotados, bajo y agrupa por surtidor", () => {
    const productos = [
      {
        ...prod({ id: 1, nombre: "Agua", stock: 0 }),
        mejorTienda: { fuente: "exprezo", label: "Exprezo", precio: 8, opciones: [] },
      },
      {
        ...prod({ id: 2, nombre: "Amox", stock: 2, stock_minimo: 6 }),
        mejorTienda: {
          fuente: "surtidor:el_surtidor",
          label: "El Surtidor",
          precio: 42,
          opciones: [{ label: "Levic", precio: 55 }],
        },
      },
      {
        ...prod({ id: 3, nombre: "Jabón", stock: 80, stock_minimo: 5 }),
        mejorTienda: { fuente: "exprezo", label: "Exprezo", precio: 12, opciones: [] },
      },
    ];
    const { agotados, paraPedir } = clasificarAlertas(productos);
    expect(agotados).toHaveLength(1);
    expect(paraPedir.map((p) => p.nombre)).toEqual(["Agua", "Amox"]);

    const filas = filasReporte(productos);
    expect(filas.map((f) => f.urgencia)).toEqual(["AGOTADO", "CRÍTICO"]);
    const grupos = agruparFilasPorSurtidor(filas);
    expect(grupos.map((g) => g.label)).toEqual(["Exprezo", "El Surtidor"]);

    const sheets = buildReporteReabastoSheets(filas);
    expect(sheets.Agotados[1][1]).toBe("Agua");
    expect(sheets["Stock bajo"][1][1]).toBe("Amox");
    expect(sheets["Por surtidor"].length).toBe(3);
    expect(itemsParaPedir(productos)).toHaveLength(2);
  });
});
