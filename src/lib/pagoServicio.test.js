import { catalogoServiciosConRecargos, compensacionMpDe, compensacionMpDeFila, costoLiquidacionDe, desgloseCobroServicios, esMismoDiaMexico, fechaLocalMexico, labelMetodoServicio, normalizarMetodoServicio, parseRecargosOverrides, parseSaldoConfig, recargoCatalogoDe, recargoEsValido, recargoVigenteDe, recargosReciboParaGuardar, resumenPagosServicioDia, tituloTicketServicio, utilidadServicio } from "./pagoServicio";

describe("pagoServicio", () => {
  test("compensación MP es 1% redondeado a centavos", () => {
    expect(compensacionMpDe(100)).toBe(1);
    expect(compensacionMpDe(50)).toBe(0.5);
    expect(compensacionMpDe(33)).toBe(0.33);
    expect(compensacionMpDe(0)).toBe(0);
  });

  test("costo de liquidación es el monto bruto", () => {
    expect(costoLiquidacionDe(100)).toBe(100);
    expect(costoLiquidacionDe("200.4")).toBe(200.4);
  });

  test("utilidad suma recargo de farmacia + compensación MP", () => {
    expect(utilidadServicio({ comision: 5, compensacionMp: 1 })).toBe(6);
  });

  test("fila usa compensacion_mp si viene; si no, estima 1%", () => {
    expect(compensacionMpDeFila({ monto_servicio: 100, compensacion_mp: 1.4 })).toBe(1.4);
    expect(compensacionMpDeFila({ monto_servicio: 100 })).toBe(1);
  });

  test("recargas van en cero; recibos sí llevan recargo", () => {
    expect(recargoEsValido(0, "recarga")).toBe(true);
    expect(recargoEsValido(5, "recarga")).toBe(false);
    expect(recargoEsValido(8, "luz")).toBe(true);
    expect(recargoEsValido(0, "luz")).toBe(false);
    expect(recargoEsValido(0)).toBe(false);
    expect(recargoEsValido("")).toBe(false);
    expect(recargoEsValido(null)).toBe(false);
  });

  test("el recargo del catálogo es 0 en recargas y fijo en recibos", () => {
    expect(recargoCatalogoDe("telcel")).toBe(0);
    expect(recargoCatalogoDe("att")).toBe(0);
    expect(recargoCatalogoDe("AT&T")).toBe(0);
    expect(recargoCatalogoDe("Movistar")).toBe(0);
    expect(recargoCatalogoDe("movilidad-cdmx")).toBe(0);
    expect(recargoCatalogoDe("Tarjeta Movilidad CDMX")).toBe(0);
    expect(recargoCatalogoDe("CFE")).toBe(8);
    expect(recargoCatalogoDe("izzi")).toBe(10);
    expect(recargoCatalogoDe("Izzi")).toBe(10);
    expect(recargoCatalogoDe("Sky")).toBe(10);
    expect(recargoCatalogoDe("desconocido")).toBe(0);
  });

  test("el admin puede sobreescribir el recargo de un recibo; recargas siguen en 0", () => {
    const cat = catalogoServiciosConRecargos({ izzi: 10, cfe: 12, telcel: 5 });
    expect(recargoCatalogoDe("izzi", cat)).toBe(10);
    expect(recargoCatalogoDe("cfe", cat)).toBe(12);
    expect(recargoCatalogoDe("telcel", cat)).toBe(0);
    expect(parseRecargosOverrides([{ clave: "servicios_recargos", valor: '{"izzi":12}' }])).toEqual({ izzi: 12 });
    const bad = recargosReciboParaGuardar({ izzi: 0 });
    expect(bad.ok).toBe(false);
    const ok = recargosReciboParaGuardar({
      cfe: 8, telmex: 8, totalplay: 8, izzi: 10, sky: 10, agua: 8, gas: 8, otro: 10,
    });
    expect(ok.ok).toBe(true);
    expect(ok.recargos.izzi).toBe(10);
    expect(recargoVigenteDe({ proveedor: "Izzi", categoria: "telefonia" })).toBe(10);
    expect(recargoVigenteDe({ proveedor: "Izzi", categoria: "telefonia", overrides: { izzi: 8 } })).toBe(8);
    expect(recargoVigenteDe({ proveedor: "Izzi", categoria: "recarga" })).toBe(0);
  });

  test("saldo de recargas avisa solo si ya lo cargó el admin y está bajo el mínimo", () => {
    expect(parseSaldoConfig([]).configurado).toBe(false);
    expect(parseSaldoConfig([]).bajo).toBe(false);
    expect(parseSaldoConfig([
      { clave: "saldo_mp_recargas", valor: "320" },
      { clave: "saldo_mp_recargas_minimo", valor: "500" },
    ]).bajo).toBe(true);
    expect(parseSaldoConfig([
      { clave: "saldo_mp_recargas", valor: "800" },
    ]).bajo).toBe(false);
  });

  test("el ticket de recarga se titula RECARGA + operadora", () => {
    expect(tituloTicketServicio("recarga", "Telcel")).toBe("RECARGA TELCEL");
    expect(tituloTicketServicio("luz", "CFE")).toBe("PAGO CFE");
    expect(labelMetodoServicio("tarjeta")).toBe("Tarjeta");
    expect(labelMetodoServicio("bbva_terminal")).toBe("Tarjeta");
    expect(labelMetodoServicio("efectivo")).toBe("Efectivo");
  });

  test("el día de la farmacia es el de Ciudad de México", () => {
    const medianocheMexicoComoUtc = new Date("2026-08-22T06:00:00.000Z");
    expect(fechaLocalMexico(medianocheMexicoComoUtc)).toBe("2026-08-22");
    expect(esMismoDiaMexico("2026-08-22T18:00:00.000Z", "2026-08-22")).toBe(true);
    expect(esMismoDiaMexico("2026-08-22T05:00:00.000Z", "2026-08-22")).toBe(false);
  });

  test("tarjeta y Point/BBVA se guardan como tarjeta; lo demás es efectivo", () => {
    expect(normalizarMetodoServicio("tarjeta")).toBe("tarjeta");
    expect(normalizarMetodoServicio("bbva_terminal")).toBe("tarjeta");
    expect(normalizarMetodoServicio("mercadopago_point")).toBe("tarjeta");
    expect(normalizarMetodoServicio("efectivo")).toBe("efectivo");
    expect(normalizarMetodoServicio("")).toBe("efectivo");
  });

  test("el resumen del día parte efectivo y tarjeta", () => {
    const r = resumenPagosServicioDia([
      { total_cobrado: 50, comision: 0, monto_servicio: 50, metodo_pago: "efectivo" },
      { total_cobrado: 100, comision: 0, monto_servicio: 100, metodo_pago: "tarjeta" },
      { total_cobrado: 208, comision: 8, monto_servicio: 200, metodo_pago: "efectivo" },
    ]);
    expect(r.ops).toBe(3);
    expect(r.efectivo).toBe(258);
    expect(r.tarjeta).toBe(100);
    expect(r.total).toBe(358);
    expect(r.comision).toBe(8);
  });

  test("flujo de caja: el cajón es efectivo; tarjeta va aparte si el SQL ya la manda", () => {
    expect(desgloseCobroServicios({ cajon_cobrado_servicios: 210 })).toEqual({
      efectivo: 210,
      tarjeta: 0,
      total: 210,
    });
    expect(desgloseCobroServicios({
      cajon_cobrado_servicios: 110,
      tarjeta_cobrada_servicios: 100,
    })).toEqual({
      efectivo: 110,
      tarjeta: 100,
      total: 210,
    });
  });
});
