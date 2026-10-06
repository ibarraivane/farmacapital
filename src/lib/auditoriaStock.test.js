import {
  clasificarStockSospechoso,
  concatenacionGramaje,
  digitosGramajeFicha,
  esStockSospechoso,
  stockSumaPiezas,
} from "./auditoriaStock";

test("suma piezas: no concatena el 30 g con otro número", () => {
  expect("30" + 232).toBe("30232");
  expect(stockSumaPiezas("30", 232)).toBe(262);
  expect(stockSumaPiezas(30, 2)).toBe(32);
  expect(stockSumaPiezas(null, 4)).toBe(4);
});

test("gramaje de ficha: 30 G 5% y tubo 30 g", () => {
  expect(digitosGramajeFicha("30 G 5%")).toBe("30");
  expect(digitosGramajeFicha("Tubo 30 g")).toBe("30");
  expect(digitosGramajeFicha("C/24")).toBe(null);
  expect(digitosGramajeFicha("caja C/100 negra")).toBe(null);
});

test("30232 es el 30 g pegado a 232, no tubos en anaquel", () => {
  expect(concatenacionGramaje(30232, "30 G 5%")).toEqual({ gramaje: 30, resto: 232 });
  expect(concatenacionGramaje(30, "30 G 5%")).toBe(null);
  expect(concatenacionGramaje(100, "caja C/100")).toBe(null);
});

test("Bepanthen Protectora 30232 sale en la auditoría", () => {
  const p = {
    nombre: "Bepanthen Pomada Protectora Contra Rozaduras",
    presentacion: "30 G 5%",
    stock: 30232,
  };
  const hit = clasificarStockSospechoso(p);
  expect(hit.tipo).toBe("concat_gramaje");
  expect(hit.piezas).toBe(30232);
  expect(esStockSospechoso(p)).toBe(true);
});

test("jeringa C/100 y Multiusos en 0 no son fantasma", () => {
  expect(esStockSospechoso({ presentacion: "caja C/100", stock: 100, stock_peps: 100 })).toBe(false);
  expect(esStockSospechoso({ presentacion: "Tubo 30 g", stock: 0 })).toBe(false);
  expect(esStockSospechoso({ presentacion: "30 G 5%", stock: 1 })).toBe(false);
});
