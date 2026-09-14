import { cuadreSiArrastraCortePrevio, esperadoEnCajon } from "./corteCajaCuadre";

describe("cuadre de caja vs corte previo", () => {
  test("esperado = fondo + lo vendido desde que abrió", () => {
    expect(esperadoEnCajon(4443.5, 184)).toBe(4627.5);
  });

  test("el corte del 5-sep: arrastrar $30 del corte previo fabrica faltante de $23", () => {
    const q = cuadreSiArrastraCortePrevio({
      fondo: 4443.5,
      ventasDesdeApertura: 184, // 134 pedidos + 50 recargas del día
      ventasEntreCortes: 30,
      contado: 4634.5,
    });
    expect(q.sistemaMal).toBe(214);
    expect(q.esperadoMal).toBe(4657.5);
    expect(q.diferenciaMal).toBe(-23);
    expect(q.sistemaBien).toBe(184);
    expect(q.esperadoBien).toBe(4627.5);
    expect(q.diferenciaBien).toBe(7);
  });
});
