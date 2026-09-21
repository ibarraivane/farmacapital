import {
  bannerVisibleEnTienda,
  puedeCrearBannerProducto,
  precioBannerProducto,
  bannersEstaSemana,
  destinoBanner,
} from "./bannersPlantilla";

const hoy = "2026-09-21";

test("banner de producto usa precio vigente y se oculta sin stock", () => {
  const prod = { id: 1, precio: 100, stock: 4, descuento_pct: 20, requiere_receta: false };
  const oferta = precioBannerProducto(prod, null, null);
  expect(oferta.hayOferta).toBe(true);
  expect(oferta.oferta).toBe(80);

  const banner = {
    plantilla: "producto",
    producto_ids: [1],
    activo: true,
    ocultar_sin_stock: true,
    vigente_hasta: "2026-09-30",
  };
  const map = new Map([[1, prod]]);
  expect(bannerVisibleEnTienda(banner, map, hoy)).toBe(true);
  expect(bannerVisibleEnTienda(banner, new Map([[1, { ...prod, stock: 0 }]]), hoy)).toBe(false);
});

test("no se puede crear banner de producto con receta", () => {
  expect(puedeCrearBannerProducto({ id: 2, requiere_receta: true }).ok).toBe(false);
  expect(puedeCrearBannerProducto({ id: 2, requiere_receta: false }).ok).toBe(true);
});

test("imagen_propia sigue visible aunque no tenga productos", () => {
  expect(bannerVisibleEnTienda({
    plantilla: "imagen_propia",
    activo: true,
    slot: "hero",
  }, new Map(), hoy)).toBe(true);
});

test("vence y Esta semana toma 1–5 plantillas", () => {
  const vencido = bannerVisibleEnTienda({
    plantilla: "servicio",
    activo: true,
    vigente_hasta: "2026-09-01",
  }, new Map(), hoy);
  expect(vencido).toBe(false);

  const list = bannersEstaSemana([
    { id: 1, plantilla: "servicio", activo: true, orden: 2, slot: "semana" },
    { id: 2, plantilla: "imagen_propia", activo: true, slot: "hero", orden: 0 },
    { id: 3, plantilla: "categoria", activo: true, orden: 1, producto_ids: [], slot: "semana" },
  ], new Map(), hoy);
  expect(list.map((b) => b.id)).toEqual([3, 1]);
});

test("destino cotizar y consultorio", () => {
  expect(destinoBanner({ destino: "cotizar" }).page).toBe("conseguir");
  expect(destinoBanner({ destino: "consultorio" }).page).toBe("cita");
  expect(destinoBanner({ destino: "categoria:Vitaminas" }).categoria).toBe("Vitaminas");
});
