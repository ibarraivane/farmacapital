import { metaDiaCompleto, mezclarCfgMetas } from "../utils/turnosMetas";
import {
  agruparVentasPorDia,
  construirSerie,
  metaSemana,
  parseYmdLocal,
  porDiaDesdeSerieRpc,
  resumenMetasActuales,
  resumenPunto,
  ymdFromLocalDate,
} from "./ventasVsMeta";

const CFG = {
  meta_matutino_lv: "1500",
  meta_vespertino_lv: "1500",
  meta_sabado_matutino: "1800",
  meta_sabado_vespertino: "1800",
  meta_domingo: "2200",
  meta_ventas_dia: "3000",
  meta_ventas_semana: "20800",
  meta_ventas_mes: "80000",
  ajuste_domingo: "0",
};

describe("metaDiaCompleto", () => {
  test("domingo usa meta_domingo, no los $3k planos", () => {
    expect(metaDiaCompleto(new Date(2026, 7, 23), CFG)).toBe(2200);
  });
  test("viernes L-V es la suma de turnos", () => {
    expect(metaDiaCompleto(new Date(2026, 7, 21), CFG)).toBe(3000);
  });
  test("sábado suma matutino + vespertino", () => {
    expect(metaDiaCompleto(new Date(2026, 7, 22), CFG)).toBe(3600);
  });
  test("sin config la gráfica no debe pintar meta $0", () => {
    expect(metaDiaCompleto(new Date(2026, 7, 21), {})).toBe(0);
    expect(metaDiaCompleto(new Date(2026, 7, 21), mezclarCfgMetas({}))).toBe(4000);
  });
});

describe("construirSerie", () => {
  const porDia = {
    "2026-08-21": 3100,
    "2026-08-22": 800,
    "2026-08-23": 12,
  };

  test("día: 21 barras y el domingo queda corto vs su meta", () => {
    const s = construirSerie({ porDia, cfg: CFG, grano: "dia", hoyYmd: "2026-08-23" });
    expect(s).toHaveLength(21);
    const hoy = s.find((p) => p.esActual);
    expect(hoy.actual).toBe(12);
    expect(hoy.meta).toBe(2200);
    expect(hoy.labelDia).toBe("23");
    expect(resumenPunto(hoy).ok).toBe(false);
  });

  test("día: ventana 7 para celular", () => {
    const s = construirSerie({ porDia, cfg: CFG, grano: "dia", hoyYmd: "2026-08-23", ventana: 7 });
    expect(s).toHaveLength(7);
    expect(s[0].key).toBe("2026-08-17");
    expect(s[6].esActual).toBe(true);
  });

  test("con respaldo de colonia ninguna barra queda en meta $0", () => {
    const s = construirSerie({
      porDia,
      cfg: mezclarCfgMetas({}),
      grano: "dia",
      hoyYmd: "2026-08-23",
    });
    expect(s.every((p) => p.meta > 0)).toBe(true);
  });

  test("resumenMetasActuales deja día, semana y mes a la vista (metas prorrateadas)", () => {
    const r = resumenMetasActuales({ porDia, cfg: CFG, hoyYmd: "2026-08-23" });
    expect(r.dia.meta).toBe(2200);
    expect(r.dia.actual).toBe(12);
    // domingo = 7/7 de la semana
    expect(r.semana.meta).toBe(20800);
    expect(r.semana.actual).toBe(3100 + 800 + 12);
    // 23 ago = 23/31 del mes
    expect(r.mes.meta).toBe(Math.round(80000 * (23 / 31)));
    expect(r.mes.actual).toBe(3100 + 800 + 12);
  });

  test("semana: lunes a domingo, meta fija si está configurada", () => {
    const lunes = parseYmdLocal("2026-08-17");
    expect(metaSemana(lunes, CFG)).toBe(
      3000 + 3000 + 3000 + 3000 + 3000 + 3600 + 2200,
    );
    const s = construirSerie({ porDia, cfg: CFG, grano: "semana", hoyYmd: "2026-08-23" });
    expect(s).toHaveLength(8);
    const actual = s.find((p) => p.esActual);
    expect(actual.actual).toBe(3100 + 800 + 12);
    expect(actual.meta).toBe(20800);
  });

  test("semana sin cifra fija usa la suma de días", () => {
    const { meta_ventas_semana, ...sinSemana } = CFG;
    const s = construirSerie({ porDia, cfg: sinSemana, grano: "semana", hoyYmd: "2026-08-23" });
    expect(s.find((p) => p.esActual).meta).toBe(20800);
  });

  test("mes: usa meta_ventas_mes", () => {
    const s = construirSerie({ porDia, cfg: CFG, grano: "mes", hoyYmd: "2026-08-23" });
    expect(s).toHaveLength(6);
    const ago = s.find((p) => p.esActual);
    expect(ago.actual).toBe(3100 + 800 + 12);
    expect(ago.meta).toBe(80000);
  });
});

describe("agruparVentasPorDia", () => {
  test("suma tickets del mismo día", () => {
    const map = agruparVentasPorDia([
      { created_at: "2026-08-23T15:00:00-06:00", total: 10 },
      { created_at: "2026-08-23T18:00:00-06:00", total: 2 },
    ]);
    expect(map["2026-08-23"]).toBe(12);
  });
});

describe("porDiaDesdeSerieRpc", () => {
  test("lee filas dia/total", () => {
    expect(porDiaDesdeSerieRpc([{ dia: "2026-08-23", total: "12" }])).toEqual({
      "2026-08-23": 12,
    });
  });

  test("resta devoluciones si el RPC las manda", () => {
    expect(porDiaDesdeSerieRpc([
      { dia: "2026-08-23", total: "100", devoluciones: "15" },
    ])).toEqual({ "2026-08-23": 85 });
  });
});

describe("ymdFromLocalDate", () => {
  test("no usa UTC (evita correr el día)", () => {
    expect(ymdFromLocalDate(new Date(2026, 7, 23))).toBe("2026-08-23");
  });
});
