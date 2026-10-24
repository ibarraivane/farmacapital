import { describe, it } from "node:test";
import assert from "node:assert/strict";
import { corteBloqueaGuardado, parseCorteTurnoRpc } from "./corteSesion.js";

describe("corteBloqueaGuardado", () => {
  it("sin corte previo, no bloquea", () => {
    assert.equal(corteBloqueaGuardado(null, null), false);
    assert.equal(corteBloqueaGuardado({ existe: false }, null), false);
  });

  it("corte ajeno + sesión abierta (Cinthia → Iván) no bloquea", () => {
    assert.equal(
      corteBloqueaGuardado(
        { existe: true, id: 134 },
        { id: 99, turno: "matutino" }
      ),
      false
    );
  });

  it("ya cortó y sin sesión abierta sí bloquea", () => {
    assert.equal(corteBloqueaGuardado({ existe: true, id: 134 }, null), true);
    assert.equal(corteBloqueaGuardado({ id: 134 }, false), true);
  });
});

describe("parseCorteTurnoRpc", () => {
  it("sesión abierta en RPC → sin propio", () => {
    const out = parseCorteTurnoRpc({
      existe: false,
      id: null,
      sesion_abierta: true,
    });
    assert.equal(out.propio, null);
    assert.equal(out.sesionAbiertaRpc, true);
  });

  it("admin ve previo de compañera sin bloquear", () => {
    const out = parseCorteTurnoRpc({
      existe: false,
      id: null,
      previo_id: 134,
      previo_nombre: "Cinthia",
    });
    assert.equal(out.propio, null);
    assert.deepEqual(out.previo, { id: 134, nombre: "Cinthia" });
  });

  it("propio corte bloqueante", () => {
    const out = parseCorteTurnoRpc({ existe: true, id: 200, propio: true });
    assert.deepEqual(out.propio, { existe: true, id: 200, propio: true });
  });
});
