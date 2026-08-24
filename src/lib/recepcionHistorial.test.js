import {
  construirHistorial,
  tendenciaCosto,
  filtrarFilas,
  soloConComparacion,
} from "./recepcionHistorial";

const payload = {
  tickets: [
    { id: 1, proveedor: "Cityfarma Iztapalapa", folio: "A1", fecha: "2026-08-01" },
    { id: 2, proveedor: "Levic", folio: "B2", fecha: "2026-08-10" },
    { id: 3, proveedor: "Farmalive Club", folio: "C3", fecha: "2026-08-20" },
  ],
  renglones: [
    { recepcion_id: 1, producto_id: 10, sku: "S10", nombre: "Paracetamol", cantidad: 5, costo: 90 },
    { recepcion_id: 2, producto_id: 10, sku: "S10", nombre: "Paracetamol", cantidad: 3, costo: 80 },
    { recepcion_id: 3, producto_id: 10, sku: "S10", nombre: "Paracetamol", cantidad: 2, costo: 95 },
    { recepcion_id: 2, producto_id: 20, sku: "S20", nombre: "Aspirina", cantidad: 1, costo: 40 },
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

  test("los tickets salen del más nuevo al más viejo", () => {
    const { tickets } = construirHistorial(payload);
    expect(tickets.map((t) => t.id)).toEqual([3, 2, 1]);
    expect(tickets.map((t) => t.quien)).toEqual(["Farmalive", "Levic", "Farma City"]);
  });

  test("las celdas se alinean con las columnas y marcan el movimiento", () => {
    const { filas } = construirHistorial(payload);
    const para = filas.find((f) => f.producto_id === 10);
    expect(para.celdas.map((c) => c?.costo)).toEqual([95, 80, 90]);
    expect(para.celdas.map((c) => c?.tendencia)).toEqual(["sube", "baja", "primera"]);
  });

  test("la base es la compra más barata y dice en qué tienda fue", () => {
    const { filas } = construirHistorial(payload);
    const para = filas.find((f) => f.producto_id === 10);
    expect(para.minCosto).toBe(80);
    expect(para.tiendaBase).toBe("Levic");
    expect(para.celdas.map((c) => !!c?.esBase)).toEqual([false, true, false]);
    expect(para.compras).toBe(3);
    expect(para.piezas).toBe(10);
    expect(para.ultimoCosto).toBe(95);
  });

  test("un producto comprado una sola vez no tiene con qué comparar", () => {
    const { filas } = construirHistorial(payload);
    const asp = filas.find((f) => f.producto_id === 20);
    expect(asp.celdas.map((c) => c?.tendencia)).toEqual([undefined, "primera", undefined]);
    expect(soloConComparacion(filas).map((f) => f.producto_id)).toEqual([10]);
  });

  test("filas en orden alfabético y buscador por nombre o SKU", () => {
    const { filas } = construirHistorial(payload);
    expect(filas.map((f) => f.nombre)).toEqual(["Aspirina", "Paracetamol"]);
    expect(filtrarFilas(filas, "para").map((f) => f.sku)).toEqual(["S10"]);
    expect(filtrarFilas(filas, "s20").map((f) => f.nombre)).toEqual(["Aspirina"]);
    expect(filtrarFilas(filas, "")).toHaveLength(2);
  });

  test("sin tickets no truena", () => {
    expect(construirHistorial(null)).toEqual({ tickets: [], filas: [] });
    expect(construirHistorial({ tickets: [], renglones: [] })).toEqual({ tickets: [], filas: [] });
  });

  test("el mismo producto dos veces en un ticket cae en una sola celda", () => {
    const { filas } = construirHistorial({
      tickets: [{ id: 1, proveedor: "Levic", folio: "A", fecha: "2026-08-01" }],
      renglones: [
        { recepcion_id: 1, producto_id: 10, sku: "S10", nombre: "Paracetamol", cantidad: 5, costo: 90 },
        { recepcion_id: 1, producto_id: 10, sku: "S10", nombre: "Paracetamol", cantidad: 2, costo: 80 },
      ],
    });
    expect(filas[0].celdas).toHaveLength(1);
    expect(filas[0].celdas[0].costo).toBe(80);
  });
});
