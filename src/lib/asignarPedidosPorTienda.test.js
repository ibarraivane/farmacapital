import { asignarPedidosPorTienda, elegirDestinoLinea, familiaDeFuente } from "./asignarPedidosPorTienda";

const item = (over = {}) => ({
  producto: {
    id: 1,
    nombre: "Producto",
    sku: "FC-1",
    stock: 0,
    costo: 50,
    mejorTienda: { opciones: [] },
    ...over,
  },
  cantidad: 3,
});

describe("asignar pedidos por surtidor", () => {
  test("El Surtidor no se absorbe en Levic aunque sea una sola línea", () => {
    const { producto } = item({
      nombre: "Tegaderm",
      mejorTienda: {
        fuente: "surtidor:el_surtidor",
        label: "El Surtidor",
        precio: 40,
        opciones: [
          { fuente: "surtidor:el_surtidor", label: "El Surtidor", precio: 40 },
          { fuente: "levic", label: "Levic", precio: 55 },
        ],
      },
    });
    expect(familiaDeFuente("surtidor:el_surtidor")).toBe("surtidor");
    const dest = elegirDestinoLinea(producto, 2);
    expect(dest.destId).toBe("surtidor:el_surtidor");
    expect(dest.destLabel).toBe("El Surtidor");

    const ordenes = asignarPedidosPorTienda([{ producto, cantidad: 2 }]);
    expect(ordenes).toHaveLength(1);
    expect(ordenes[0].proveedor).toBe("El Surtidor");
    expect(ordenes[0].productos).toHaveLength(1);
  });

  test("ahorro chico de Scorpion se va a Exprezo", () => {
    const { producto } = item({
      nombre: "Jabón",
      mejorTienda: {
        opciones: [
          { fuente: "scorpion", label: "Scorpion", precio: 19.9 },
          { fuente: "exprezo", label: "Exprezo", precio: 20 },
        ],
      },
    });
    const dest = elegirDestinoLinea(producto, 1);
    expect(dest.destId).toBe("exprezo");
  });

  test("separa Farma City y Levic", () => {
    const a = item({
      id: 10,
      nombre: "Genérico",
      mejorTienda: {
        opciones: [
          { fuente: "surtidor:farma_city", label: "Farma City", precio: 22 },
          { fuente: "levic", label: "Levic", precio: 30 },
        ],
      },
    }).producto;
    const b = item({
      id: 11,
      nombre: "Patente",
      mejorTienda: {
        opciones: [{ fuente: "levic", label: "Levic", precio: 90 }],
      },
    }).producto;
    const ordenes = asignarPedidosPorTienda([
      { producto: a, cantidad: 4 },
      { producto: b, cantidad: 1 },
    ]);
    expect(ordenes.map((o) => o.proveedor).sort()).toEqual(["Farma City", "Levic"]);
  });
});
