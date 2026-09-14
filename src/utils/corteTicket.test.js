import { mapPagoServicio, mergeDetalleTurno, snapshotFromCorte } from "./corteTicket";

describe("detalle de corte: recargas + ventas", () => {
  test("mapPagoServicio arma un renglón con folio SRV y el cobrado", () => {
    const row = mapPagoServicio({
      id: 12,
      folio: "SRV-20260905-000012",
      proveedor: "Telcel",
      categoria: "recarga",
      total_cobrado: 80,
      metodo_pago: "efectivo",
      created_at: "2026-09-05T16:10:00.000Z",
      atendido_por_nombre: "Rene",
    });
    expect(row.tipo).toBe("servicio");
    expect(row.id).toBe("SRV-20260905-000012");
    expect(row.total).toBe(80);
    expect(row.metodo_pago).toBe("efectivo");
    expect(row.items[0].nombre).toBe("Telcel · recarga");
    expect(row.items[0].subtotal).toBe(80);
  });

  test("mergeDetalleTurno junta ventas y recargas y ordena por hora", () => {
    const ventas = [{
      id: 189,
      created_at: "2026-09-05T19:37:00.000Z",
      metodo_pago: "efectivo",
      total: 5,
      tipo: "venta",
      items: [{ nombre: "Peine", cantidad: 1, precio_unitario: 5, subtotal: 5 }],
    }];
    const merged = mergeDetalleTurno(ventas, [{
      folio: "SRV-80",
      proveedor: "Telcel",
      categoria: "recarga",
      total_cobrado: 80,
      metodo_pago: "efectivo",
      created_at: "2026-09-05T20:00:00.000Z",
    }]);
    expect(merged).toHaveLength(2);
    expect(merged[0].tipo).toBe("servicio");
    expect(merged[0].total).toBe(80);
    expect(merged[1].id).toBe(189);
    expect(merged.reduce((a, t) => a + t.total, 0)).toBe(85);
  });

  test("el hueco sistema vs tickets se cierra al sumar recargas", () => {
    const ventas = [
      { id: 189, created_at: "2026-09-05T19:37:00Z", metodo_pago: "efectivo", total: 5, items: [] },
      { id: 188, created_at: "2026-09-05T18:26:00Z", metodo_pago: "efectivo", total: 55, items: [] },
      { id: 187, created_at: "2026-09-05T17:46:00Z", metodo_pago: "efectivo", total: 6, items: [] },
      { id: 186, created_at: "2026-09-05T15:28:00Z", metodo_pago: "efectivo", total: 68, items: [] },
    ];
    const soloPedidos = ventas.reduce((a, t) => a + t.total, 0);
    expect(soloPedidos).toBe(134);

    const conRecarga = mergeDetalleTurno(ventas, [{
      folio: "SRV-80",
      proveedor: "Telcel",
      categoria: "recarga",
      total_cobrado: 80,
      metodo_pago: "efectivo",
      created_at: "2026-09-05T16:00:00Z",
    }]);
    expect(conRecarga.reduce((a, t) => a + t.total, 0)).toBe(214);
  });

  test("snapshotFromCorte suma tickets incluyendo recargas", () => {
    const snap = snapshotFromCorte({
      resultado: {
        efectivo_sistema: 214,
        fondo_inicial: 4443.5,
        esperado: 4657.5,
        diferencia: -23,
        total_general: 191,
        detalle_metodos: { efectivo_servicios: 80 },
      },
      turno: "matutino",
      zTransac: mergeDetalleTurno(
        [{ id: 186, created_at: "2026-09-05T15:28:00Z", metodo_pago: "efectivo", total: 134, items: [] }],
        [{ folio: "SRV-80", proveedor: "Telcel", categoria: "recarga", total_cobrado: 80, metodo_pago: "efectivo", created_at: "2026-09-05T16:00:00Z" }],
      ),
    });
    expect(snap.suma_tickets).toBe(214);
    expect(snap.sistema).toBe(214);
    expect(snap.devoluciones_efectivo).toBe(0);
  });
});
