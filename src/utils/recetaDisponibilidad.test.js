import { disponibilidadDeStock, disponibilidadLineaReceta, lineasRecetaParaMostrador, planSurtirReceta } from "./recetaDisponibilidad";

describe("recetaDisponibilidad", () => {
  test("stock: en mostrador / bajo / sin piezas", () => {
    expect(disponibilidadDeStock(12).tone).toBe("green");
    expect(disponibilidadDeStock(12).label).toMatch(/En mostrador/);
    expect(disponibilidadDeStock(2).tone).toBe("amber");
    expect(disponibilidadDeStock(0).tone).toBe("red");
    expect(disponibilidadDeStock(0).vendemos).toBe(true);
    expect(disponibilidadDeStock(0).hay).toBe(false);
  });

  test("línea libre = no está en catálogo", () => {
    const d = disponibilidadLineaReceta({ medicamento: "Algo de fuera", producto_id: null });
    expect(d.vendemos).toBe(false);
    expect(d.label).toMatch(/catálogo/i);
  });

  test("línea de catálogo usa stock vivo o snapshot", () => {
    const map = new Map([[10, { id: 10, stock: 8 }]]);
    expect(disponibilidadLineaReceta({ producto_id: 10, stock_snapshot: 1 }, map).tone).toBe("green");
    expect(disponibilidadLineaReceta({ producto_id: 10, stock_snapshot: 0 }).tone).toBe("red");
  });

  test("mostrador lista posología", () => {
    const lineas = lineasRecetaParaMostrador([
      { producto_id: 1, medicamento: "Amoxicilina 500", cantidad: 1, dosis: "1 cáps", frecuencia: "c/8 h", duracion: "7 días" },
      { producto_id: null, medicamento: "Algo externo", dosis: "1 tab" },
    ]);
    expect(lineas).toHaveLength(2);
    expect(lineas[0].posologia).toMatch(/Dosis/);
    expect(lineas[1].libre).toBe(true);
  });

  test("plan de surtir separa catálogo, libres y sin piezas", () => {
    const plan = planSurtirReceta({
      medicamentos: [
        { producto_id: 1, medicamento: "Paracetamol", cantidad: 2 },
        { producto_id: 2, medicamento: "Omeprazol", cantidad: 1 },
        { producto_id: null, medicamento: "Crema de fuera" },
      ],
      productos: [
        { id: 1, nombre: "Paracetamol 500", stock: 10 },
        { id: 2, nombre: "Omeprazol 20", stock: 0 },
      ],
      cart: [],
    });
    expect(plan.lineas).toHaveLength(1);
    expect(plan.lineas[0].qty).toBe(2);
    expect(plan.sinPiezas.join(" ")).toMatch(/Omeprazol/);
    expect(plan.libres).toEqual(["Crema de fuera"]);
  });
});
