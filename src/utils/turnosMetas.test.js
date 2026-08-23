import { bonosActivos, mezclarCfgMetas, METAS_COLONIA_DEF } from "./turnosMetas";

describe("mezclarCfgMetas", () => {
  test("si no hay config, usa las de colonia", () => {
    expect(mezclarCfgMetas({})).toEqual(METAS_COLONIA_DEF);
    expect(mezclarCfgMetas([])).toEqual(METAS_COLONIA_DEF);
  });
  test("las filas de la base pisan el respaldo", () => {
    const m = mezclarCfgMetas([{ clave: "meta_ventas_dia", valor: "4500" }]);
    expect(m.meta_ventas_dia).toBe("4500");
    expect(m.meta_ventas_mes).toBe("110000");
  });
});

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
