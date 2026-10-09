import {
  STOCK_SERVICIO_POS,
  catalogoSinServicios,
  esServicio,
  etiquetaCortaAtencion,
  lineaFaltaStock,
  serviciosAtencionActivos,
} from "./servicioSalud";

const presion = { id: 1, sku: "SERV-PRESION", nombre: "Toma de presión arterial", tipo: "servicio", precio: 20, activo: true };
const inyeccion = { id: 2, sku: "SERV-INY-IM", nombre: "Aplicación de inyección intramuscular", tipo: "servicio", precio: 40, activo: true };
const oxi = { id: 3, sku: "SERV-OXIMETRIA", nombre: "Medición de oxigenación (oximetría)", tipo: "servicio", precio: 20, activo: true };
const glucosa = { id: 4, sku: "SERV-GLUCOSA", nombre: "Medición de glucosa capilar", tipo: "servicio", precio: 40, activo: false };
const omeprazol = { id: 9, sku: "FC-1", nombre: "Omeprazol 20 mg", tipo: "generico", stock: 0, activo: true };

describe("servicio de salud", () => {
  test("solo el tipo servicio cuenta como atención", () => {
    expect(esServicio(presion)).toBe(true);
    expect(esServicio({ tipo: " Servicio " })).toBe(true);
    expect(esServicio(omeprazol)).toBe(false);
    expect(esServicio(null)).toBe(false);
  });

  test("el acceso rápido deja fuera el inactivo y ordena por nombre", () => {
    const lista = serviciosAtencionActivos([glucosa, oxi, omeprazol, presion, inyeccion]);
    expect(lista.map((p) => p.sku)).toEqual(["SERV-INY-IM", "SERV-OXIMETRIA", "SERV-PRESION"]);
  });

  test("el botón usa el nombre corto", () => {
    expect(etiquetaCortaAtencion(inyeccion)).toBe("Inyección");
    expect(etiquetaCortaAtencion(presion)).toBe("Presión");
    expect(etiquetaCortaAtencion(oxi)).toBe("Oxigenación");
    expect(etiquetaCortaAtencion(glucosa)).toBe("Glucosa");
    expect(etiquetaCortaAtencion({ nombre: "Curación sencilla", tipo: "servicio" })).toBe("Curación sencilla");
  });

  test("el stock de un servicio no se agota y no se imprime como número", () => {
    expect(STOCK_SERVICIO_POS).toBe(Number.POSITIVE_INFINITY);
    expect(Number.isFinite(STOCK_SERVICIO_POS)).toBe(false);
  });

  test("el cobro no marca faltante de stock en un servicio", () => {
    expect(lineaFaltaStock({ qty: 2, tipo: "servicio" }, presion, 0)).toBe(false);
    expect(lineaFaltaStock({ qty: 2 }, omeprazol, 1)).toBe(true);
    expect(lineaFaltaStock({ qty: 1 }, omeprazol, 1)).toBe(false);
    expect(lineaFaltaStock({ qty: 1 }, null, 0)).toBe(false);
  });

  test("inventario, lotes y recepción pueden quitar servicios de la lista", () => {
    expect(catalogoSinServicios([omeprazol, presion, glucosa]).map((p) => p.id)).toEqual([9]);
  });
});
