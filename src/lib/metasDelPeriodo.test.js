import { mezclarCfgMetas } from "../utils/turnosMetas";
import {
  diaEnSemanaLunDom,
  fraccionMesTranscurrida,
  metasDelPeriodo,
} from "./metasDelPeriodo";

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

describe("metasDelPeriodo", () => {
  test("domingo usa meta_domingo, no el plano de 3k", () => {
    const r = metasDelPeriodo(new Date(2026, 7, 23), CFG);
    expect(r.dia).toBe(2200);
  });

  test("prorratea semana lun–dom (domingo = 7/7)", () => {
    const r = metasDelPeriodo(new Date(2026, 7, 23), CFG);
    expect(diaEnSemanaLunDom(new Date(2026, 7, 23))).toBe(7);
    expect(r.semana).toBe(20800);
  });

  test("miércoles = 3/7 de la meta semanal", () => {
    const r = metasDelPeriodo(new Date(2026, 7, 19), CFG); // mié
    expect(diaEnSemanaLunDom(new Date(2026, 7, 19))).toBe(3);
    expect(r.semana).toBe(Math.round(20800 * (3 / 7)));
  });

  test("día 3 del mes prorratea ~3/31 de la meta mensual", () => {
    const r = metasDelPeriodo(new Date(2026, 7, 3), CFG);
    expect(r.fracMes).toBeCloseTo(3 / 31, 5);
    expect(r.mes).toBe(Math.round(80000 * (3 / 31)));
  });

  test("con mezclarCfgMetas vacío no queda meta día en 0", () => {
    const r = metasDelPeriodo(new Date(2026, 7, 21), mezclarCfgMetas({}));
    expect(r.dia).toBeGreaterThan(0);
    expect(r.semana).toBeGreaterThan(0);
    expect(r.mes).toBeGreaterThan(0);
  });

  test("fraccionMesTranscurrida acota 0..1", () => {
    expect(fraccionMesTranscurrida(new Date(2026, 7, 1))).toBeCloseTo(1 / 31, 5);
    expect(fraccionMesTranscurrida(new Date(2026, 7, 31))).toBe(1);
  });
});
