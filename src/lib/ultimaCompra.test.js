import {
  normalizeProveedorCompra,
  ultimaCompraDe,
  costoComparacionDe,
  filasUltimaCompraDesdeRecepcion,
} from "./ultimaCompra";

describe("ultimaCompra", () => {
  test("normaliza mayoristas del ticket", () => {
    expect(normalizeProveedorCompra("Farmalive Club Iztapalapa")).toBe("Farmalive");
    expect(normalizeProveedorCompra("Cityfarma Iztapalapa")).toBe("Farma City");
    expect(normalizeProveedorCompra("Levic")).toBe("Levic");
  });

  test("prioriza ticket sobre costo de catálogo", () => {
    const u = ultimaCompraDe(
      { costo: 90, ultimo_costo: null },
      { ultima_compra: { precio: 64.44, nombre_fuente: "Farmalive", fecha: "2026-08-21" } }
    );
    expect(u.precio).toBe(64.44);
    expect(u.proveedor).toBe("Farmalive");
    expect(u.origen).toBe("ticket");
    expect(costoComparacionDe({ costo: 90 }, { ultima_compra: { precio: 64.44 } })).toBe(64.44);
  });

  test("sin ticket usa el costo de catálogo", () => {
    const u = ultimaCompraDe({ costo: 17.98 }, {});
    expect(u).toEqual({ precio: 17.98, proveedor: "", fecha: null, origen: "catalogo" });
  });

  test("arma filas al cerrar Recibir; sin costo no escribe", () => {
    const filas = filasUltimaCompraDesdeRecepcion({
      proveedor: "Farmalive",
      folio: "11590",
      fecha: "2026-08-21",
      items: [
        { producto_id: 10, confirmado: true, costo_estimado: 64.44 },
        { producto_id: 11, confirmado: true, costo_estimado: 0 },
        { producto_id: 12, confirmado: false, costo_estimado: 20 },
      ],
    });
    expect(filas).toHaveLength(1);
    expect(filas[0].producto_id).toBe(10);
    expect(filas[0].precio).toBe(64.44);
    expect(filas[0].nombre_fuente).toBe("Farmalive");
    expect(filas[0].notas).toBe("ticket 11590");
  });
});
