import {
  construirHistorial,
  tendenciaCosto,
  filtrarFilas,
  soloConComparacion,
  fechaCorta,
} from "./recepcionHistorial";

const payload = {
  tickets: [
    { id: 1, proveedor: "Cityfarma Iztapalapa", folio: "A1", fecha: "2026-08-08" },
    { id: 2, proveedor: "Bodega F-42", folio: "A2", fecha: "2026-08-08" },
    { id: 3, proveedor: "Levic", folio: "B2", fecha: "2026-08-20" },
    { id: 4, proveedor: "Farmalive Club", folio: "C3", fecha: "2026-08-21" },
  ],
  renglones: [
    // el mismo día en dos tiendas distintas
    { recepcion_id: 1, producto_id: 10, sku: "S10", nombre: "Paracetamol", cantidad: 5, costo: 90 },
    { recepcion_id: 2, producto_id: 10, sku: "S10", nombre: "Paracetamol", cantidad: 4, costo: 86 },
    { recepcion_id: 3, producto_id: 10, sku: "S10", nombre: "Paracetamol", cantidad: 3, costo: 80 },
    { recepcion_id: 4, producto_id: 10, sku: "S10", nombre: "Paracetamol", cantidad: 2, costo: 95 },
    { recepcion_id: 3, producto_id: 20, sku: "S20", nombre: "Aspirina", cantidad: 1, costo: 40 },
  ],
};

describe("historia de compras", () => {
  test("tendencia se mide contra la compra anterior", () => {
    expect(tendenciaCosto(80, 90)).toBe("baja");
    expect(tendenciaCosto(95, 80)).toBe("sube");
    expect(tendenciaCosto(80, 80)).toBe("igual");
    expect(tendenciaCosto(80, null)).toBe("primera");
    expect(tendenciaCosto(null, 80)).toBe(null);
  });

  test("un centavo de redondeo sigue siendo el mismo precio", () => {
    expect(tendenciaCosto(80.002, 80)).toBe("igual");
    expect(tendenciaCosto(79.99, 80)).toBe("baja");
  });

  test("una columna por día, de la más nueva a la más vieja", () => {
    const { fechas } = construirHistorial(payload);
    expect(fechas).toEqual(["2026-08-21", "2026-08-20", "2026-08-08"]);
  });

  test("dos tiendas el mismo día caen en una sola celda, la barata arriba", () => {
    const { filas } = construirHistorial(payload);
    const para = filas.find((f) => f.producto_id === 10);
    const dia8 = para.celdas[2];
    expect(dia8.compras.map((c) => [c.precio, c.tienda]))
      .toEqual([[86, "Bodega F-42"], [90, "Farma City"]]);
    expect(dia8.mejor).toBe(86);
    expect(dia8.tienda).toBe("Bodega F-42");
    expect(dia8.tiendas).toBe(2);
    expect(dia8.cantidad).toBe(9);
  });

  test("el movimiento compara el mejor precio de cada día", () => {
    const { filas } = construirHistorial(payload);
    const para = filas.find((f) => f.producto_id === 10);
    expect(para.celdas.map((c) => c?.mejor)).toEqual([95, 80, 86]);
    expect(para.celdas.map((c) => c?.tendencia)).toEqual(["sube", "baja", "primera"]);
  });

  test("la base es la compra más barata, con su tienda y su fecha", () => {
    const { filas } = construirHistorial(payload);
    const para = filas.find((f) => f.producto_id === 10);
    expect(para.minCosto).toBe(80);
    expect(para.tiendaBase).toBe("Levic");
    expect(para.fechaBase).toBe("2026-08-20");
    expect(para.celdas.map((c) => !!c?.esBase)).toEqual([false, true, false]);
    expect(para.dias).toBe(3);
    expect(para.compras).toBe(4);
    expect(para.piezas).toBe(14);
    expect(para.ultimoCosto).toBe(95);
  });

  test("un producto de un solo día no tiene con qué comparar", () => {
    const { filas } = construirHistorial(payload);
    const asp = filas.find((f) => f.producto_id === 20);
    expect(asp.dias).toBe(1);
    expect(soloConComparacion(filas).map((f) => f.producto_id)).toEqual([10]);
  });

  test("el buscador encuentra por nombre, SKU y tienda", () => {
    const { filas } = construirHistorial(payload);
    expect(filas.map((f) => f.nombre)).toEqual(["Aspirina", "Paracetamol"]);
    expect(filtrarFilas(filas, "para").map((f) => f.sku)).toEqual(["S10"]);
    expect(filtrarFilas(filas, "s20").map((f) => f.nombre)).toEqual(["Aspirina"]);
    expect(filtrarFilas(filas, "bodega").map((f) => f.sku)).toEqual(["S10"]);
    expect(filtrarFilas(filas, "")).toHaveLength(2);
  });

  test("la fecha se lee dd/mm/aa", () => {
    expect(fechaCorta("2026-08-08")).toBe("08/08/26");
    expect(fechaCorta("")).toBe("");
  });

  test("sin tickets no truena", () => {
    expect(construirHistorial(null)).toEqual({ fechas: [], filas: [] });
    expect(construirHistorial({ tickets: [], renglones: [] })).toEqual({ fechas: [], filas: [] });
  });
});
