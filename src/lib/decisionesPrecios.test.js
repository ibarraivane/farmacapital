import {
  TIPO_DECISION,
  esElegibleRappi,
  esMuchoMasCaroQueMercado,
  clasificarProducto,
  clasificarDecisiones,
  filtrarDecisiones,
  resumenDecisiones,
  loadDismissed,
  dismissDecision,
  claveDecision,
  textoConfirmacionAplicar,
  alertaCatalogoDe,
  productoTieneAlertaPrecio,
} from "./decisionesPrecios";

function prod(over = {}) {
  return {
    id: 1,
    sku: "FC-TEGA",
    nombre: "Tegaderm",
    categoria: "Botiquín",
    tipo: "marca",
    costo: 50,
    precio: 120,
    stock: 10,
    requiere_receta: false,
    activo: true,
    ...over,
  };
}

function refsVenta(fahorro = 90, similares = 95) {
  return {
    fahorro: { precio: fahorro, fuente: "fahorro" },
    similares: { precio: similares, fuente: "similares" },
  };
}

test("Rappi: activo y sin receta; receta o controlado no salen", () => {
  expect(esElegibleRappi(prod())).toBe(true);
  expect(esElegibleRappi(prod({ requiere_receta: true }))).toBe(false);
  expect(esElegibleRappi(prod({ controlado: true }))).toBe(false);
  expect(esElegibleRappi(prod({ activo: false }))).toBe(false);
});

test("venta más cara que la ref. → bajar, y marca Rappi", () => {
  const rows = clasificarProducto(prod(), refsVenta());
  const venta = rows.find((d) => d.ambito === "venta");
  expect(venta).toBeTruthy();
  expect(venta.tipo).toBe(TIPO_DECISION.VENTA_BAJAR);
  expect(venta.sugerido).toBe(89); // ceil(90 * 0.98)
  expect(venta.rappi).toBe(true);
  expect(venta.puede_aplicar).toBe(true);
  expect(venta.detalle).toMatch(/Rappi/);
});

test("ya al competitivo → no pide aplicar venta", () => {
  const rows = clasificarProducto(prod({ precio: 89 }), refsVenta());
  expect(rows.some((d) => d.ambito === "venta")).toBe(false);
});

test("debajo del mercado → subir", () => {
  const rows = clasificarProducto(prod({ precio: 60, costo: 20 }), refsVenta());
  const venta = rows.find((d) => d.ambito === "venta");
  expect(venta.tipo).toBe(TIPO_DECISION.VENTA_SUBIR);
  expect(venta.sugerido).toBe(89);
});

test("sugerido bajo costo → crítica, no aplicar a ciegas", () => {
  const rows = clasificarProducto(
    prod({ costo: 100, precio: 140, tipo: "marca" }),
    refsVenta(50, 55)
  );
  const venta = rows.find((d) => d.tipo === TIPO_DECISION.VENTA_DEBAJO_COSTO);
  expect(venta).toBeTruthy();
  expect(venta.puede_aplicar).toBe(false);
  expect(rows.some((d) => d.tipo === TIPO_DECISION.MARGEN_ACTUAL_BAJO)).toBe(true);
});

test("lista de compra más barata que tu costo", () => {
  const rows = clasificarProducto(prod({ costo: 100, precio: 89 }), {
    exprezo: { precio: 80, fuente: "exprezo" },
  });
  const compra = rows.find((d) => d.tipo === TIPO_DECISION.COMPRA_OPORTUNIDAD);
  expect(compra).toBeTruthy();
  expect(compra.mejor_label).toBe("Exprezo");
  expect(compra.impacto).toBeCloseTo(20);
  expect(compra.ambito).toBe("compra");
});

test("sin refs de venta + elegible Rappi → rappi_sin_ref", () => {
  const rows = clasificarProducto(prod({ precio: 89 }), {});
  expect(rows.some((d) => d.tipo === TIPO_DECISION.RAPPI_SIN_REF)).toBe(true);
});

test("Rx no genera rappi_sin_ref", () => {
  const rows = clasificarProducto(prod({ requiere_receta: true, precio: 89 }), {});
  expect(rows.some((d) => d.tipo === TIPO_DECISION.RAPPI_SIN_REF)).toBe(false);
});

test("clasificar ordena por prioridad y respeta pospuestos", () => {
  const productos = [
    prod({ id: 1, nombre: "Alfa", precio: 120 }),
    prod({ id: 2, nombre: "Beta", costo: 100, precio: 140 }),
  ];
  const refs = {
    1: refsVenta(),
    2: refsVenta(50, 55),
  };
  const all = clasificarDecisiones(productos, refs);
  expect(all[0].tipo).toBe(TIPO_DECISION.VENTA_DEBAJO_COSTO);
  const critica = all.find((d) => d.tipo === TIPO_DECISION.VENTA_DEBAJO_COSTO);
  const filtered = clasificarDecisiones(productos, refs, { dismissedKeys: [critica.clave] });
  expect(filtered.some((d) => d.clave === critica.clave)).toBe(false);
});

test("filtros y resumen", () => {
  const productos = [prod({ precio: 120 }), prod({ id: 9, costo: 100, precio: 89, nombre: "Compra" })];
  const refs = {
    1: refsVenta(),
    9: { exprezo: { precio: 70, fuente: "exprezo" } },
  };
  const all = clasificarDecisiones(productos, refs);
  const r = resumenDecisiones(all);
  expect(r.venta).toBeGreaterThan(0);
  expect(r.compra).toBe(1);
  expect(r.rappi).toBeGreaterThan(0);
  expect(filtrarDecisiones(all, "compra")).toHaveLength(1);
  expect(filtrarDecisiones(all, "rappi").every((d) => d.rappi)).toBe(true);
});

test("posponer guarda y caduca", () => {
  const mem = {};
  const storage = {
    getItem: (k) => mem[k] || null,
    setItem: (k, v) => { mem[k] = v; },
  };
  const now = 1_000_000;
  dismissDecision("1:venta_bajar:89", 24, now, storage);
  expect(loadDismissed(now + 1000, storage)["1:venta_bajar:89"]).toBeTruthy();
  expect(loadDismissed(now + 25 * 3600 * 1000, storage)["1:venta_bajar:89"]).toBeFalsy();
});

test("confirmación avisa Rappi y no inventa aplicar automático", () => {
  const d = clasificarProducto(prod(), refsVenta()).find((x) => x.tipo === TIPO_DECISION.VENTA_BAJAR);
  const txt = textoConfirmacionAplicar(d);
  expect(txt).toMatch(/Aplicar/);
  expect(txt).toMatch(/Rappi/);
  expect(txt).toMatch(/Uber/);
  expect(claveDecision(d)).toContain(String(d.sugerido));
});

test("mucho más caro: 8% o $10 sobre la ref.", () => {
  expect(esMuchoMasCaroQueMercado(100, 90)).toBe(true);
  expect(esMuchoMasCaroQueMercado(92, 90)).toBe(false);
  expect(esMuchoMasCaroQueMercado(89, 90)).toBe(false);
});

test("margen actual bajo se alerta aunque no haya refs de venta", () => {
  const rows = clasificarProducto(prod({ costo: 80, precio: 70 }), {});
  const m = rows.find((d) => d.tipo === TIPO_DECISION.MARGEN_ACTUAL_BAJO);
  expect(m).toBeTruthy();
  expect(m.alerta).toBe("debajo_costo");
  expect(m.canales).toContain("mostrador");
  expect(m.canales).toContain("rappi");
  expect(m.canales_futuros).toEqual(["uber", "didi"]);
});

test("venta cara marca canales futuros Uber/DiDi y mucho_mas_caro", () => {
  const venta = clasificarProducto(prod({ precio: 120 }), refsVenta()).find((d) => d.tipo === TIPO_DECISION.VENTA_BAJAR);
  expect(venta.mucho_mas_caro).toBe(true);
  expect(venta.canales).toContain("rappi");
  expect(venta.canales_futuros).toEqual(["uber", "didi"]);
  expect(filtrarDecisiones([venta], "uber")).toHaveLength(1);
  expect(filtrarDecisiones([venta], "didi")).toHaveLength(1);
  expect(filtrarDecisiones([venta], "caro")).toHaveLength(1);
});

test("alerta de catálogo: chips de mercado, margen y Rappi", () => {
  const a = alertaCatalogoDe(prod({ precio: 120, costo: 50 }), refsVenta());
  expect(a.refMin).toBe(90);
  expect(a.sugerido).toBe(89);
  expect(a.tieneAlerta).toBe(true);
  expect(a.chips.some((c) => c.id === "caro")).toBe(true);
  expect(a.chips.some((c) => c.id === "apps")).toBe(true);
  expect(productoTieneAlertaPrecio(prod({ precio: 120 }), refsVenta(), "caro_mercado")).toBe(true);
  expect(productoTieneAlertaPrecio(prod({ precio: 89, costo: 50 }), refsVenta(), "alerta_precio")).toBe(false);
});
