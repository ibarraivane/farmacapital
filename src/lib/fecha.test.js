import { addDaysISO, hoyISOMexico, rangoDiaMexico, ymdMexico } from "./fecha";

describe("rangoDiaMexico", () => {
  test("cubre todo el día civil CDMX aunque el reloj esté en UTC", () => {
    // 28 ago 2026 22:00 UTC = 16:00 CDMX (aún viernes; turno vespertino)
    const tardeMexicoComoUtc = new Date("2026-08-28T22:00:00.000Z");
    expect(hoyISOMexico(tardeMexicoComoUtc)).toBe("2026-08-28");

    const { start, end } = rangoDiaMexico("2026-08-28");
    const ventaTarde = new Date("2026-08-28T22:30:00.000Z").getTime(); // 16:30 CDMX
    const ventaNoche = new Date("2026-08-29T04:00:00.000Z").getTime(); // 22:00 CDMX
    const yaSabado = new Date("2026-08-29T06:00:00.000Z").getTime(); // 00:00 CDMX sáb
    expect(ventaTarde).toBeGreaterThanOrEqual(new Date(start).getTime());
    expect(ventaTarde).toBeLessThan(new Date(end).getTime());
    expect(ventaNoche).toBeLessThan(new Date(end).getTime());
    expect(yaSabado).toBeGreaterThanOrEqual(new Date(end).getTime());
  });

  test("ymdMexico agrupa la venta en el viernes de farmacia", () => {
    expect(ymdMexico("2026-08-28T22:30:00.000Z")).toBe("2026-08-28");
    expect(ymdMexico("2026-08-29T05:59:00.000Z")).toBe("2026-08-28");
    expect(ymdMexico("2026-08-29T06:00:00.000Z")).toBe("2026-08-29");
  });

  test("addDaysISO no depende del huso del navegador", () => {
    expect(addDaysISO("2026-08-28", 1)).toBe("2026-08-29");
    expect(addDaysISO("2026-08-28", -1)).toBe("2026-08-27");
  });
});
