import { guardarMostrarVitrina, leerMostrarVitrina, pasaVistaInventario, STORAGE_MOSTRAR_VITRINA } from "./inventarioVista";

const omeprazol = { id: 1, nombre: "Omeprazol 20 mg", bajo_pedido: false, activo: true };
const anthelios = { id: 2, nombre: "Anthelios UV Air", bajo_pedido: true, categoria: "Cuidado personal", subcategoria: "Dermatología" };
const whey = { id: 3, nombre: "Whey Gold", bajo_pedido: true, categoria: "Suplemento" };

function memoria() {
  const bag = new Map();
  return {
    getItem: (k) => (bag.has(k) ? bag.get(k) : null),
    setItem: (k, v) => bag.set(k, String(v)),
  };
}

describe("vista de inventario", () => {
  test("suplementos y dermatología apagados no entran al anaquel", () => {
    expect(pasaVistaInventario(omeprazol)).toBe(true);
    expect(pasaVistaInventario(anthelios)).toBe(false);
    expect(pasaVistaInventario(whey)).toBe(false);
    expect(pasaVistaInventario({ id: 4, nombre: "Sin bandera" })).toBe(true);
  });

  test("el interruptor los vuelve a mostrar", () => {
    expect(pasaVistaInventario(anthelios, { mostrarVitrina: true })).toBe(true);
    expect(pasaVistaInventario(whey, { mostrarVitrina: true })).toBe(true);
  });

  test("el filtro Bajo pedido los muestra aunque el interruptor esté apagado", () => {
    expect(pasaVistaInventario(anthelios, { filtroAlerta: "bajo_pedido" })).toBe(true);
    expect(pasaVistaInventario(omeprazol, { filtroAlerta: "bajo_pedido" })).toBe(true);
  });

  test("un servicio no entra al anaquel ni a la vitrina", () => {
    const presion = { id: 8, nombre: "Toma de presión arterial", tipo: "servicio", stock: 0, activo: true };
    expect(pasaVistaInventario(presion)).toBe(false);
    expect(pasaVistaInventario(presion, { mostrarVitrina: true })).toBe(false);
    expect(pasaVistaInventario(presion, { filtroAlerta: "agotados" })).toBe(false);
    expect(pasaVistaInventario(presion, { filtroAlerta: "bajo_pedido" })).toBe(false);
    expect(pasaVistaInventario(presion, { filtroAlerta: "servicios" })).toBe(true);
    expect(pasaVistaInventario(omeprazol, { filtroAlerta: "servicios" })).toBe(false);
  });

  test("la preferencia queda en este navegador y nace apagada", () => {
    const storage = memoria();
    expect(leerMostrarVitrina(storage)).toBe(false);
    expect(leerMostrarVitrina(null)).toBe(false);
    guardarMostrarVitrina(storage, true);
    expect(storage.getItem(STORAGE_MOSTRAR_VITRINA)).toBe("1");
    expect(leerMostrarVitrina(storage)).toBe(true);
    guardarMostrarVitrina(storage, false);
    expect(leerMostrarVitrina(storage)).toBe(false);
  });
});
