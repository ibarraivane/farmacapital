import {
  montoServicioParaMeta,
  sumServiciosParaMeta,
  sumarVentasConServicios,
  nombreAtendidoServicio,
  acumularServiciosEnMapaEmpleado,
  acumularServiciosPorDia,
  labelServicioTicket,
  ticketsTurnoDesdePedidosYServicios,
  filasServicioDesdeSnapshot,
} from "./serviciosEnMetas";

describe("serviciosEnMetas", () => {
  test("monto usa total_cobrado; recarga y CFE suman", () => {
    expect(montoServicioParaMeta({ categoria: "recarga", total_cobrado: 50, monto_servicio: 50 })).toBe(50);
    expect(montoServicioParaMeta({ categoria: "luz", total_cobrado: 208, monto_servicio: 200 })).toBe(208);
    expect(montoServicioParaMeta({ total_cobrado: 100 })).toBe(100);
    expect(montoServicioParaMeta({ total: 30 })).toBe(30);
    expect(montoServicioParaMeta(null)).toBe(0);
  });

  test("suma pedidos + todos los pagos de servicio para el % de meta", () => {
    expect(sumarVentasConServicios(800, [
      { categoria: "recarga", total_cobrado: 50 },
      { categoria: "recarga", total_cobrado: 100 },
      { categoria: "luz", total_cobrado: 208 },
    ])).toBe(1158);
    expect(sumServiciosParaMeta([])).toBe(0);
  });

  test("agrupa por vendedora en dashboard", () => {
    const byEmp = { Ana: 500 };
    acumularServiciosEnMapaEmpleado(byEmp, [
      { categoria: "recarga", total_cobrado: 50, atendido_por_nombre: "Ana" },
      { categoria: "recarga", total_cobrado: 100, usuarios: { nombre: "Bety" } },
      { categoria: "tv", total_cobrado: 90, atendido_por_nombre: "Ana" },
    ]);
    expect(byEmp.Ana).toBe(640);
    expect(byEmp.Bety).toBe(100);
    expect(nombreAtendidoServicio({})).toBe("Sin asignar");
  });

  test("acumula por día para rachas", () => {
    const m = new Map([["2026-09-12", 100]]);
    acumularServiciosPorDia(m, [
      { total_cobrado: 50, created_at: "2026-09-12T18:00:00.000Z" },
      { total_cobrado: 20, created_at: "2026-09-11T12:00:00.000Z" },
    ]);
    expect(m.get("2026-09-12")).toBe(150);
    expect(m.get("2026-09-11")).toBe(20);
  });

  test("etiqueta de ticket sin montos", () => {
    expect(labelServicioTicket({ categoria: "recarga", proveedor: "Telcel" })).toBe("Recarga Telcel");
    expect(labelServicioTicket({ categoria: "luz", proveedor: "CFE" })).toBe("Pago CFE");
  });

  test("lista une pedidos y servicios", () => {
    const list = ticketsTurnoDesdePedidosYServicios(
      [{
        id: 10,
        created_at: "2026-09-12T15:00:00.000Z",
        cliente_id: 1,
        pedido_items: [{ cantidad: 2, productos: { nombre: "Aspirina" }, lotes: {} }],
      }],
      [{
        id: 99,
        folio: "SRV-20260912-000099",
        categoria: "recarga",
        proveedor: "Telcel",
        created_at: "2026-09-12T16:00:00.000Z",
      }],
    );
    expect(list).toHaveLength(2);
    expect(list[0].esServicio).toBe(true);
    expect(list[0].folioLabel).toBe("SRV-20260912-000099");
    expect(list[0].items[0].nombre).toBe("Recarga Telcel");
    expect(list[1].pedidoId).toBe(10);
  });

  test("snapshot acepta srv_* o rec_*", () => {
    expect(filasServicioDesdeSnapshot({ srv_turno: [{ id: 1 }] }, "turno")).toEqual([{ id: 1 }]);
    expect(filasServicioDesdeSnapshot({ rec_turno: [{ id: 2 }] }, "turno")).toEqual([{ id: 2 }]);
    expect(filasServicioDesdeSnapshot({ srv_mes: [{ id: 3 }] }, "mes")).toEqual([{ id: 3 }]);
    expect(filasServicioDesdeSnapshot(null, "turno")).toEqual([]);
  });
});
