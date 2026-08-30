import {
  accionesRevisionFila,
  asegurarEpoch,
  botTsMasReciente,
  esPendienteRevision,
  huellaMercado,
  marcarRevisados,
  parseRevisionState,
  serializeRevisionState,
} from "./preciosRevision";

test("el epoch abuelo: refs viejas no piden decisión", () => {
  const state = asegurarEpoch({ epoch: null, porId: {} }, 1_000);
  expect(state.epoch).toBe(1_000);
  expect(esPendienteRevision({ botTs: 900, epoch: state.epoch })).toBe(false);
  expect(esPendienteRevision({ botTs: 1_001, epoch: state.epoch })).toBe(true);
});

test("tras Aceptar/Subir no vuelve hasta que el bot escriba de nuevo", () => {
  let state = asegurarEpoch({ epoch: 100, porId: {} }, 100);
  state = marcarRevisados(state, [7], { 7: { huella: "66|65" } }, 500);
  expect(esPendienteRevision({ botTs: 400, revisado: state.porId[7], epoch: state.epoch })).toBe(false);
  expect(esPendienteRevision({ botTs: 600, revisado: state.porId[7], epoch: state.epoch })).toBe(true);
});

test("botones: Subir+Aceptar, Bajar+Aceptar, o solo Aceptar", () => {
  expect(accionesRevisionFila({ pendiente: false, accion: "subir", sugerido: 40 }))
    .toEqual({ subir: false, bajar: false, aceptar: false });
  expect(accionesRevisionFila({ pendiente: true, accion: "subir", sugerido: 40 }))
    .toEqual({ subir: true, bajar: false, aceptar: true });
  expect(accionesRevisionFila({ pendiente: true, accion: "bajar", sugerido: 40 }))
    .toEqual({ subir: false, bajar: true, aceptar: true });
  expect(accionesRevisionFila({ pendiente: true, accion: "mantener", sugerido: 40 }))
    .toEqual({ subir: false, bajar: false, aceptar: true });
  expect(accionesRevisionFila({ pendiente: true, accion: "subir", sugerido: null }))
    .toEqual({ subir: false, bajar: false, aceptar: false });
});

test("huella y persistencia redondean el mercado", () => {
  expect(huellaMercado({ refMin: 66.004, sugerido: 65 })).toBe("66|65");
  const raw = serializeRevisionState({ epoch: 9, porId: { 3: { at: 8, huella: "66|65" } } });
  const back = parseRevisionState(raw);
  expect(back.epoch).toBe(9);
  expect(back.porId[3]).toEqual({ at: 8, huella: "66|65" });
});

test("sin timestamp de bot no hay pendiente", () => {
  expect(esPendienteRevision({ botTs: null, epoch: 1 })).toBe(false);
  expect(esPendienteRevision({})).toBe(false);
  expect(botTsMasReciente(null, 10, undefined, 4)).toBe(10);
});
