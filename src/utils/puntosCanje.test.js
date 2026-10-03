import { describe, expect, it } from "vitest";
import {
  CANJES_PUNTOS,
  PESOS_PARA_UN_PUNTO,
  PESOS_POR_PUNTO,
  canjePorPuntos,
  pesosDePuntos,
  puntosGanados,
} from "./puntosCanje";

describe("puntos FarmaCapital (escala estilo Ahorro)", () => {
  it("1 punto = $1 y se gana 1 por cada $100", () => {
    expect(PESOS_POR_PUNTO).toBe(1);
    expect(PESOS_PARA_UN_PUNTO).toBe(100);
  });

  it("puntosGanados usa floor por cada $100", () => {
    expect(puntosGanados(0)).toBe(0);
    expect(puntosGanados(99.99)).toBe(0);
    expect(puntosGanados(100)).toBe(1);
    expect(puntosGanados(250)).toBe(2);
    expect(puntosGanados(999)).toBe(9);
    expect(puntosGanados(1000)).toBe(10);
  });

  it("pesosDePuntos: 1 punto vale $1", () => {
    expect(pesosDePuntos(10)).toBe(10);
    expect(pesosDePuntos(80)).toBe(80);
    expect(pesosDePuntos(0)).toBe(0);
  });

  it("canjes conservan el valor en pesos de la escala anterior", () => {
    expect(canjePorPuntos(10)?.valor).toBe(10);
    expect(canjePorPuntos(50)?.valor).toBe(50);
    expect(canjePorPuntos(80)?.tipo).toBe("consulta");
    expect(CANJES_PUNTOS.map((c) => c.pts)).toEqual([10, 25, 50, 80, 100]);
  });

  it("mismo 1% efectivo que la escala vieja (1 pt/$10 a $0.10)", () => {
    const compra = 1000;
    const ptsNuevos = puntosGanados(compra);
    const vale = pesosDePuntos(ptsNuevos);
    expect(vale).toBe(10); // 1% de $1000
  });
});
