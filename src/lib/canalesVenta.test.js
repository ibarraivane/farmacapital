import {
  CANALES_VENTA,
  esElegibleCanal,
  canalesActivosDeProducto,
  canalesFuturosDeProducto,
  marketplacesActivosDeProducto,
} from "./canalesVenta";

const otc = { activo: true, requiere_receta: false };
const rx = { activo: true, requiere_receta: true };

test("Rappi está vivo; Uber y DiDi quedan listos apagados", () => {
  expect(CANALES_VENTA.rappi.activo).toBe(true);
  expect(CANALES_VENTA.uber.activo).toBe(false);
  expect(CANALES_VENTA.didi.activo).toBe(false);
  expect(CANALES_VENTA.uber.marketplace).toBe(true);
  expect(CANALES_VENTA.didi.marketplace).toBe(true);
});

test("OTC entra a Rappi y a Uber/DiDi futuros; receta no", () => {
  expect(esElegibleCanal("rappi", otc)).toBe(true);
  expect(esElegibleCanal("uber", otc)).toBe(true);
  expect(esElegibleCanal("didi", otc)).toBe(true);
  expect(esElegibleCanal("rappi", rx)).toBe(false);
  expect(marketplacesActivosDeProducto(otc).map((c) => c.id)).toEqual(["rappi"]);
  expect(canalesFuturosDeProducto(otc).map((c) => c.id)).toEqual(["uber", "didi"]);
  expect(canalesActivosDeProducto(rx).map((c) => c.id)).toEqual(["mostrador"]);
});
