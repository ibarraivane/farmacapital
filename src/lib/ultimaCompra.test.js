import {
  normalizeProveedorCompra,
  debeReemplazarCompra,
  elegirCompraVigente,
  compraVigenteDe,
  costoComparacionDe,
  filasCompraVigenteDesdeRecepcion,
} from "./ultimaCompra";
import { hoyISOMexico } from "./fecha";

describe("compra vigente", () => {
  test("normaliza mayoristas del ticket", () => {
    expect(normalizeProveedorCompra("Farmalive Club Iztapalapa")).toBe("Farmalive");
    expect(normalizeProveedorCompra("Cityfarma Iztapalapa")).toBe("Farma City");
    expect(normalizeProveedorCompra("Levic")).toBe("Levic");
    expect(normalizeProveedorCompra("EQUILIBRIO FARMACEÚTICO")).toBe("Equilibrio");
  });

  test("solo reemplaza si el nuevo es más barato", () => {
    expect(debeReemplazarCompra(null, 90)).toBe(true);
    expect(debeReemplazarCompra(90, 64.44)).toBe(true);
    expect(debeReemplazarCompra(64.44, 80)).toBe(false);
    expect(debeReemplazarCompra(64.44, 64.44)).toBe(false);
  });

  test("primera compra se queda hasta que otra baje el precio", () => {
    const vigente = elegirCompraVigente([
      { precio: 90, proveedor: "Equilibrio", fecha: "2026-08-01", id: 1 },
      { precio: 80, proveedor: "Levic", fecha: "2026-08-10", id: 2 },
      { precio: 95, proveedor: "Farmalive", fecha: "2026-08-21", id: 3 },
    ]);
    expect(vigente.precio).toBe(80);
    expect(vigente.proveedor).toBe("Levic");
  });

  test("muestra quién en el costo de catálogo si no hay ticket", () => {
    const u = compraVigenteDe({ costo: 17.98, proveedor: "Equilibrio Farmacéutico" }, {});
    expect(u.precio).toBe(17.98);
    expect(u.proveedor).toBe("Equilibrio");
    expect(costoComparacionDe({ costo: 17.98, proveedor: "Equilibrio" }, {})).toBe(17.98);
  });

  test("ticket más caro al cerrar Recibir no pisa el vigente", () => {
    const filas = filasCompraVigenteDesdeRecepcion(
      {
        proveedor: "Farmalive",
        folio: "11590",
        fecha: "2026-08-21",
        items: [
          { producto_id: 10, confirmado: true, costo_estimado: 64.44 },
          { producto_id: 11, confirmado: true, costo_estimado: 80 },
        ],
      },
      { 10: 90, 11: 50 }
    );
    expect(filas).toHaveLength(1);
    expect(filas[0].producto_id).toBe(10);
    expect(filas[0].precio).toBe(64.44);
    expect(filas[0].nombre_fuente).toBe("Farmalive");
    expect(filas[0].fecha).toBe(hoyISOMexico());
  });

  test("lote anónimo más barato se queda el precio y toma el quién del ticket", () => {
    const vigente = elegirCompraVigente([
      { precio: 59.45, proveedor: "", fecha: "2026-08-16", id: 1 },
      { precio: 63.74, proveedor: "Levic", fecha: "2026-08-20", id: 2 },
    ]);
    expect(vigente.precio).toBe(59.45);
    expect(vigente.proveedor).toBe("Levic");
  });

  test("Recibir completa el quién sin subir el costo vigente", () => {
    const filas = filasCompraVigenteDesdeRecepcion(
      {
        proveedor: "Levic",
        folio: "9012078353",
        fecha: "2026-08-20",
        items: [{ producto_id: 900, confirmado: true, costo_estimado: 63.74 }],
      },
      { 900: { precio: 59.45, proveedor: "" } }
    );
    expect(filas).toHaveLength(1);
    expect(filas[0].precio).toBe(59.45);
    expect(filas[0].nombre_fuente).toBe("Levic");
  });

  test("Recibir no pisa el quién si ya hay proveedor aunque el ticket sea otro", () => {
    const filas = filasCompraVigenteDesdeRecepcion(
      {
        proveedor: "Farmalive",
        folio: "1",
        fecha: "2026-08-21",
        items: [{ producto_id: 11, confirmado: true, costo_estimado: 80 }],
      },
      { 11: { precio: 50, proveedor: "Equilibrio" } }
    );
    expect(filas).toHaveLength(0);
  });
});
