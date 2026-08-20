import { puedeCancelarCitaCaja, esCitaNoShow } from "./citasAgenda";

const base = {
  id: 1,
  nombre: "Ivan",
  estado: "agendada",
  pago_estado: "pendiente",
  pedido_consulta_id: null,
  fecha: "2026-07-29",
  hora: "13:00",
};

describe("cancelar cita en caja", () => {
  test("cita pagada no se cancela", () => {
    expect(puedeCancelarCitaCaja({ ...base, pago_estado: "pagada" })).toBe(false);
  });

  test("cita de un día anterior sin pago sí se puede cancelar (no-show)", () => {
    const cita = { ...base };
    expect(puedeCancelarCitaCaja(cita)).toBe(true);
    expect(esCitaNoShow(cita, 10, Date.parse("2026-08-19T21:00:00"))).toBe(true);
  });

  test("cita futura: se puede cancelar, todavía no es no-show", () => {
    const cita = { ...base, fecha: "2026-12-01", hora: "10:00" };
    expect(puedeCancelarCitaCaja(cita)).toBe(true);
    expect(esCitaNoShow(cita, 10, Date.parse("2026-08-19T12:00:00"))).toBe(false);
  });

  test("hoy, 11 min después de la hora: no-show", () => {
    const cita = { ...base, fecha: "2026-08-19", hora: "13:00" };
    const now = Date.parse("2026-08-19T13:11:00");
    expect(esCitaNoShow(cita, 10, now)).toBe(true);
  });

  test("hoy, 5 min después: aún no es no-show, pero sí se puede cancelar", () => {
    const cita = { ...base, fecha: "2026-08-19", hora: "13:00" };
    const now = Date.parse("2026-08-19T13:05:00");
    expect(puedeCancelarCitaCaja(cita)).toBe(true);
    expect(esCitaNoShow(cita, 10, now)).toBe(false);
  });
});
