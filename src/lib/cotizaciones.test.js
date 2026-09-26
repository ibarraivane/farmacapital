import {
  ESTADOS_COTIZACION,
  ESTADOS_COTIZACION_ABIERTAS,
  ESTADOS_ITEM_COTIZACION,
  ORIGENES_COTIZACION,
  URGENCIAS_COTIZACION,
  FILTROS_COTIZACION,
  folioCotizacion,
  etiquetaEstadoCotizacion,
  etiquetaEstadoItemCotizacion,
  etiquetaOrigenCotizacion,
  etiquetaLugarCotizacion,
  siguientesEstadosCotizacion,
  siguientesEstadosItemCotizacion,
  esEstadoCotizacionAbierto,
  normalizarTextoItemCotizacion,
  normalizarEanCotizacion,
  itemCotizacionValido,
  puedeGuardarCotizacion,
  payloadPromoverDesdeSolicitud,
  precioSugeridoCotizacion,
  numerosLineaCotizacion,
  vistaNumerosProducto,
  totalesCotizacion,
  escaparHtmlCotizacion,
  itemConfirmadoDocumento,
  vigenciaDefaultTexto,
  importeDocumentoCliente,
  totalDocumentoCliente,
  resumenItemsCotizacion,
  fmtDineroCotiz,
  haceCuanto,
  stashCotizacionAbierta,
  takeCotizacionAbierta,
  COTIZ_OPEN_STORAGE_KEY,
} from "./cotizaciones";

test("folio y etiquetas del contrato", () => {
  expect(folioCotizacion(142)).toBe("C-142");
  expect(folioCotizacion(null)).toBe("C-—");
  expect(ESTADOS_COTIZACION.map((e) => e.id)).toEqual([
    "nueva",
    "buscando",
    "lista",
    "pedida",
    "cerrada",
    "perdida",
  ]);
  expect(ESTADOS_ITEM_COTIZACION.map((e) => e.id)).toContain("no_se_consigue");
  expect(ORIGENES_COTIZACION.map((o) => o.id)).toContain("whatsapp");
  expect(URGENCIAS_COTIZACION.map((u) => u.id)).toEqual(["hoy", "manana", "sin_prisa"]);
  expect(FILTROS_COTIZACION.some((f) => f.id === "abiertas")).toBe(true);
  expect(etiquetaEstadoCotizacion("lista")).toBe("Lista");
  expect(etiquetaEstadoItemCotizacion("pedir")).toBe("Pedir");
  expect(etiquetaOrigenCotizacion("tienda")).toBe("Tienda web");
  expect(etiquetaLugarCotizacion("nadro")).toBe("Nadro");
  expect(etiquetaLugarCotizacion("Farmacia del pueblo")).toBe("Farmacia del pueblo");
});

test("siguientes estados de proyecto y de línea", () => {
  expect(siguientesEstadosCotizacion("nueva")).toEqual(["buscando", "lista", "perdida"]);
  expect(siguientesEstadosCotizacion("pedida")).toContain("cerrada");
  expect(siguientesEstadosCotizacion("perdida")).toContain("nueva");
  expect(siguientesEstadosItemCotizacion("pendiente")).toContain("buscando");
  expect(siguientesEstadosItemCotizacion("elegido")).toContain("pedir");
  expect(siguientesEstadosItemCotizacion("pedido")).toContain("llego");
  expect(esEstadoCotizacionAbierto("buscando")).toBe(true);
  expect(esEstadoCotizacionAbierto("cerrada")).toBe(false);
  expect(ESTADOS_COTIZACION_ABIERTAS).toEqual(["nueva", "buscando", "lista", "pedida"]);
});

test("valida alta: cliente + al menos un producto", () => {
  expect(normalizarTextoItemCotizacion("  anthelios   40ml  ")).toBe("anthelios 40ml");
  expect(normalizarTextoItemCotizacion("x".repeat(250)).length).toBe(200);
  expect(normalizarEanCotizacion("3337875917810")).toBe("3337875917810");
  expect(normalizarEanCotizacion("12")).toBe("");
  expect(itemCotizacionValido({ texto: "a", cantidad: 1 })).toBe(false);
  expect(itemCotizacionValido({ texto: "Anthelios", cantidad: 2 })).toBe(true);
  expect(
    puedeGuardarCotizacion({
      clienteNombre: "María",
      items: [{ texto: "Anthelios", cantidad: 1 }],
    }),
  ).toBe(true);
  expect(
    puedeGuardarCotizacion({
      clienteNombre: "",
      clienteTelefono: "5512345678",
      items: [{ texto: "Anthelios", cantidad: 1 }],
    }),
  ).toBe(true);
  expect(
    puedeGuardarCotizacion({
      clienteNombre: "",
      clienteTelefono: "55",
      items: [{ texto: "Anthelios", cantidad: 1 }],
    }),
  ).toBe(false);
  expect(
    puedeGuardarCotizacion({
      clienteNombre: "María",
      items: [{ texto: "x", cantidad: 1 }],
    }),
  ).toBe(false);
});

test("promover desde solicitud copia cliente, origen y el renglón", () => {
  const p = payloadPromoverDesdeSolicitud({
    id: 88,
    texto: "BLOQ ANTHE UVAIR",
    cantidad: 2,
    urgencia: "hoy",
    origen: "tienda",
    cliente_nombre: "María López",
    cliente_telefono: "55 1234 5678",
    cliente_email: "maria@test.com",
    direccion: "Roma Norte",
    producto_id: 9,
  });
  expect(p.solicitud_id).toBe(88);
  expect(p.origen).toBe("tienda");
  expect(p.urgencia).toBe("hoy");
  expect(p.cliente_telefono).toBe("5512345678");
  expect(p.items[0]).toMatchObject({
    texto: "BLOQ ANTHE UVAIR",
    cantidad: 2,
    producto_id: 9,
    tipo_margen: "marca",
  });
  expect(payloadPromoverDesdeSolicitud({ texto: "x", origen: "mostrador" }).origen).toBe(
    "mostrador",
  );
});

test("marca +25% y genérico +60% sobre costo; muestra recargo y margen", () => {
  expect(precioSugeridoCotizacion(250, "marca")).toBe(313);
  expect(precioSugeridoCotizacion(250, "generico")).toBe(400);
  const marca = numerosLineaCotizacion({
    costo: 250,
    cantidad: 2,
    tipoMargen: "marca",
  });
  expect(marca.sugerido).toBe(313);
  expect(marca.venta).toBe(313);
  expect(marca.recargoPct).toBe(25.2);
  expect(marca.margenPct).toBe(20.1);
  expect(marca.gananciaUnit).toBe(63);
  expect(marca.gananciaTotal).toBe(126);
  expect(marca.usaSugerido).toBe(true);

  const gen = numerosLineaCotizacion({
    costo: 100,
    precioVenta: 160,
    cantidad: 1,
    tipoMargen: "generico",
  });
  expect(gen.sugerido).toBe(160);
  expect(gen.recargoPct).toBe(60);
  expect(gen.margenPct).toBe(37.5);
  expect(gen.usaSugerido).toBe(false);
});

test("la ganancia se ve al teclear costo y precio, antes de guardar", () => {
  const n = vistaNumerosProducto({
    costoTexto: "40",
    precioTexto: "50",
    costoGuardado: null,
    precioGuardado: null,
    cantidad: 2,
    tipoMargen: "marca",
  });
  expect(n.gananciaUnit).toBe(10);
  expect(n.gananciaTotal).toBe(20);
  expect(n.recargoPct).toBe(25);
  const guardado = vistaNumerosProducto({
    costoTexto: "",
    precioTexto: "",
    costoGuardado: 40,
    precioGuardado: 50,
    cantidad: 1,
    tipoMargen: "marca",
  });
  expect(guardado.gananciaUnit).toBe(10);
});

test("totales del proyecto solo suman líneas con costo y venta", () => {
  const t = totalesCotizacion([
    { texto: "A", cantidad: 2, costo_elegido: 389, precio_venta: 486, tipo_margen: "marca" },
    { texto: "B", cantidad: 1, costo_elegido: null, precio_venta: null, tipo_margen: "marca" },
  ]);
  expect(t.lineas).toBe(1);
  expect(t.costo).toBe(778);
  expect(t.venta).toBe(972);
  expect(t.ganancia).toBe(194);
  expect(totalesCotizacion([]).ganancia).toBe(null);
  expect(resumenItemsCotizacion([
    { texto: "Anthelios", cantidad: 2 },
    { texto: "CeraVe", cantidad: 1 },
    { texto: "Extra", cantidad: 1 },
  ])).toMatch(/Anthelios ×2/);
  expect(resumenItemsCotizacion([])).toBe("Sin productos");
});

test("documento del cliente suma precio de venta sin pedir el costo", () => {
  const viernes = new Date(2026, 8, 25);
  expect(vigenciaDefaultTexto(1, viernes)).toBe("28 de septiembre de 2026");
  expect(vigenciaDefaultTexto(5, viernes)).toBe("2 de octubre de 2026");
  expect(escaparHtmlCotizacion(`A & B <C>`)).toBe("A &amp; B &lt;C&gt;");
  expect(itemConfirmadoDocumento({ estado: "elegido", precio_venta: 120 })).toBe(true);
  expect(itemConfirmadoDocumento({ estado: "buscando", precio_venta: 120 })).toBe(false);
  expect(itemConfirmadoDocumento({ estado: "elegido", precio_venta: null })).toBe(false);

  const items = [
    { estado: "buscando", precio_venta: 80, cantidad: 2, costo_elegido: null },
    { estado: "elegido", precio_venta: 50, cantidad: 1, costo_elegido: 40 },
    { estado: "pendiente", precio_venta: null, cantidad: 1, costo_elegido: 100, tipo_margen: "marca" },
  ];
  expect(importeDocumentoCliente(items[0])).toBe(160);
  expect(importeDocumentoCliente(items[2])).toBe(null);
  expect(totalDocumentoCliente(items)).toBe(210);
  expect(totalDocumentoCliente([])).toBe(null);
  expect(totalesCotizacion(items).venta).toBe(175);
});

test("dinero y hace cuanto", () => {
  expect(fmtDineroCotiz(null)).toBe("—");
  expect(fmtDineroCotiz(389)).toMatch(/389/);
  const now = Date.parse("2026-09-21T12:00:00Z");
  expect(haceCuanto("2026-09-21T11:30:00Z", now)).toBe("hace 30 min");
  expect(haceCuanto("2026-09-20T12:00:00Z", now)).toBe("hace 1 día");
  expect(haceCuanto("2026-09-11T12:00:00Z", now)).toBe("hace 10 días");
});

test("sessionStorage abre la ficha promovida", () => {
  sessionStorage.removeItem(COTIZ_OPEN_STORAGE_KEY);
  expect(stashCotizacionAbierta(142)).toBe(true);
  expect(sessionStorage.getItem(COTIZ_OPEN_STORAGE_KEY)).toBe("142");
  expect(takeCotizacionAbierta()).toBe(142);
  expect(takeCotizacionAbierta()).toBe(null);
  expect(stashCotizacionAbierta(0)).toBe(false);
});
