import { corteBloqueaGuardado, parseCorteTurnoRpc } from "./corteSesion.js";

test("sin corte previo, no bloquea", () => {
  expect(corteBloqueaGuardado(null, null)).toBe(false);
  expect(corteBloqueaGuardado({ existe: false }, null)).toBe(false);
});

test("corte de otra persona + sesión abierta (Cinthia → Iván) no bloquea", () => {
  expect(
    corteBloqueaGuardado(
      { existe: true, id: 134 },
      { id: 99, turno: "matutino" }
    )
  ).toBe(false);
});

test("mismo turno ya cortado y sin sesión abierta sí bloquea", () => {
  expect(corteBloqueaGuardado({ existe: true, id: 134 }, null)).toBe(true);
  expect(corteBloqueaGuardado({ id: 134 }, false)).toBe(true);
});

test("RPC con sesión abierta → sin propio", () => {
  const out = parseCorteTurnoRpc({
    existe: false,
    id: null,
    sesion_abierta: true,
  });
  expect(out.propio).toBeNull();
  expect(out.sesionAbiertaRpc).toBe(true);
});

test("admin ve previo de compañera sin bloquear", () => {
  const out = parseCorteTurnoRpc({
    existe: false,
    id: null,
    previo_id: 134,
    previo_nombre: "Cinthia",
  });
  expect(out.propio).toBeNull();
  expect(out.previo).toEqual({ id: 134, nombre: "Cinthia" });
});

test("propio corte bloqueante", () => {
  const out = parseCorteTurnoRpc({ existe: true, id: 200, propio: true });
  expect(out.propio).toEqual({ existe: true, id: 200, propio: true });
});
