import { bonosActivos } from "./turnosMetas";

describe("bonosActivos", () => {
  test("apagado por defecto y con 0", () => {
    expect(bonosActivos(undefined)).toBe(false);
    expect(bonosActivos({})).toBe(false);
    expect(bonosActivos({ bonos_activos: "0" })).toBe(false);
  });

  test("encendido con 1 o true", () => {
    expect(bonosActivos({ bonos_activos: "1" })).toBe(true);
    expect(bonosActivos({ bonos_activos: "true" })).toBe(true);
  });
});
