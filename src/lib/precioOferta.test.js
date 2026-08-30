import { cobroLinea } from "../utils/pesoPublico";
import {
  mapaPromosPorProducto,
  ofertaDeProducto,
  precioDesdePromo,
  promoVigente,
} from "./precioOferta";

const HOY = "2026-08-30";

test("sin descuento ni campaña, se cobra el precio de lista", () => {
  const o = ofertaDeProducto({ precio: 148, descuento_pct: 0 }, null, HOY);
  expect(o.hayOferta).toBe(false);
  expect(o.oferta).toBe(148);
  expect(o.lista).toBe(148);
});

test("descuento_pct del producto: lista tachada, oferta = cobroLinea", () => {
  const o = ofertaDeProducto({ precio: 148, descuento_pct: 10 }, null, HOY);
  expect(o.hayOferta).toBe(true);
  expect(o.lista).toBe(148);
  expect(o.oferta).toBe(cobroLinea(148, 1, 10));
  expect(o.etiqueta).toBe("−10%");
  expect(o.leyenda).toBe("Precio especial");
  expect(o.fuente).toBe("producto");
  expect(o.ahorro).toBe(o.lista - o.oferta);
});

test("campaña % vigente gana si deja el precio más bajo", () => {
  const promo = {
    id: 1,
    nombre: "Hot sale",
    tipo: "descuento_pct",
    valor: 25,
    activa: true,
    fecha_inicio: "2026-08-01",
    fecha_fin: "2026-08-31",
  };
  const o = ofertaDeProducto({ precio: 200, descuento_pct: 10 }, promo, HOY);
  expect(o.oferta).toBe(cobroLinea(200, 1, 25));
  expect(o.fuente).toBe("campaña");
  expect(o.leyenda).toBe("Hot sale");
});

test("campaña $ fijo", () => {
  const promo = { tipo: "descuento_fijo", valor: 20, activa: true };
  expect(precioDesdePromo(100, promo)).toBe(80);
  const o = ofertaDeProducto({ precio: 100 }, promo, HOY);
  expect(o.oferta).toBe(80);
  expect(o.etiqueta).toBe("Oferta");
});

test("campaña vencida no aplica", () => {
  expect(promoVigente({ activa: true, fecha_fin: "2026-08-01" }, HOY)).toBe(false);
  const o = ofertaDeProducto(
    { precio: 100, descuento_pct: 0 },
    { tipo: "descuento_pct", valor: 30, activa: true, fecha_fin: "2026-08-01" },
    HOY
  );
  expect(o.hayOferta).toBe(false);
});

test("2x1 no baja el unitario", () => {
  expect(precioDesdePromo(90, { tipo: "2x1", valor: 1, activa: true })).toBe(null);
});

test("mapa agrupa campañas vigentes por producto", () => {
  const map = mapaPromosPorProducto(
    [
      { id: 7, tipo: "descuento_pct", valor: 15, activa: true, fecha_fin: "2026-09-01" },
      { id: 8, tipo: "descuento_pct", valor: 10, activa: true, fecha_fin: "2026-01-01" },
    ],
    [
      { promocion_id: 7, producto_id: 55 },
      { promocion_id: 8, producto_id: 55 },
    ],
    HOY
  );
  expect(map.get(55)).toHaveLength(1);
  expect(map.get(55)[0].id).toBe(7);
});
