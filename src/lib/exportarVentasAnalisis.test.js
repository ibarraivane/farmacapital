import {
  buildVentasAnalisisCsv,
  csvEscape,
  filaPasaFiltrosExport,
  filtrarLineasExport,
  mensajeErrorExportVentas,
  nombreArchivoVentasAnalisis,
  normalizarFilaExport,
  paginarLineasVentas,
  partesFechaMexico,
} from "./exportarVentasAnalisis";

const ventaTardeViernes = {
  folio: "1842",
  pedido_id: 1842,
  fecha_venta: "2026-08-28T22:30:00.000Z", // 16:30 CDMX viernes
  vendedor: "Erika",
  cliente: "Juan",
  tipo: "tienda_fisica",
  estado: "completado",
  metodo_pago: "efectivo",
  total_ticket: 130,
  sku: "FC-TEGA",
  producto: 'Tegaderm 10 cm, "caja"',
  categoria: "Cuidado de heridas",
  marca: "3M",
  cantidad: 2,
  precio_unitario: 65,
  importe_linea: 130,
  costo_lote: 40,
  origen: "pedido",
};

test("partesFechaMexico usa calendario y reloj de CDMX", () => {
  expect(partesFechaMexico("2026-08-28T22:30:00.000Z")).toEqual({
    fecha: "2026-08-28",
    hora: "16:30",
    dia_semana: "viernes",
  });
  expect(partesFechaMexico("2026-08-29T05:59:00.000Z")).toMatchObject({
    fecha: "2026-08-28",
    dia_semana: "viernes",
  });
  expect(partesFechaMexico("2026-08-29T06:00:00.000Z")).toEqual({
    fecha: "2026-08-29",
    hora: "00:00",
    dia_semana: "sábado",
  });
});

test("csvEscape cita y duplica comillas", () => {
  expect(csvEscape('Tegaderm 10 cm, "caja"')).toBe('"Tegaderm 10 cm, ""caja"""');
  expect(csvEscape(null)).toBe('""');
});

test("normalizarFilaExport no incluye teléfono y arma columnas de análisis", () => {
  const fila = normalizarFilaExport({
    ...ventaTardeViernes,
    cliente_telefono: "5512345678",
  });
  expect(fila.fecha).toBe("2026-08-28");
  expect(fila.hora).toBe("16:30");
  expect(fila.dia_semana).toBe("viernes");
  expect(fila.vendedor).toBe("Erika");
  expect(fila.cliente).toBe("Juan");
  expect(JSON.stringify(fila)).not.toMatch(/5512345678/);
  expect(fila.origen).toBe("pedido");
});

test("servicio y devolución conservan origen e importes", () => {
  expect(normalizarFilaExport({
    folio: "SRV-9",
    fecha_venta: "2026-08-28T22:30:00.000Z",
    tipo: "servicio",
    estado: "completado",
    producto: "CFE",
    cantidad: 1,
    importe_linea: 220,
    origen: "servicio",
  })).toMatchObject({ origen: "servicio", producto: "CFE", importe_linea: "220" });

  expect(normalizarFilaExport({
    folio: "DEV-3",
    pedido_id: 10,
    fecha_venta: "2026-08-28T22:30:00.000Z",
    tipo: "tienda_fisica",
    estado: "aprobada",
    cantidad: -1,
    importe_linea: -65,
    origen: "devolucion",
  })).toMatchObject({ origen: "devolucion", cantidad: "-1", importe_linea: "-65" });
});

test("filtros de tipo y estado; devolución aprobada cuenta como completado", () => {
  expect(filaPasaFiltrosExport(ventaTardeViernes, { tipo: "fisica", estado: "completado" })).toBe(true);
  expect(filaPasaFiltrosExport(ventaTardeViernes, { tipo: "online" })).toBe(false);
  expect(filaPasaFiltrosExport({
    ...ventaTardeViernes,
    origen: "devolucion",
    estado: "aprobada",
  }, { estado: "completado" })).toBe(true);
  expect(filtrarLineasExport([
    ventaTardeViernes,
    { ...ventaTardeViernes, tipo: "online", folio: "9" },
  ], { tipo: "fisica" })).toHaveLength(1);
});

test("buildVentasAnalisisCsv tiene encabezado y escapa el producto", () => {
  const csv = buildVentasAnalisisCsv([ventaTardeViernes]);
  const lines = csv.trimEnd().split("\n");
  expect(lines[0]).toContain('"folio"');
  expect(lines[0]).toContain('"dia_semana"');
  expect(lines[0]).toContain('"origen"');
  expect(lines[1]).toContain('"Tegaderm 10 cm, ""caja"""');
  expect(lines[1]).toContain('"Erika"');
  expect(lines[1]).toContain('"viernes"');
  expect(csv.endsWith("\n")).toBe(true);
});

test("paginarLineasVentas junta páginas y corta si se acaba", async () => {
  const pages = [
    [{ folio: "1" }, { folio: "2" }],
    [{ folio: "3" }],
  ];
  const calls = [];
  const { rows, truncated } = await paginarLineasVentas(async ({ offset, limit }) => {
    calls.push({ offset, limit });
    return pages[offset / 2] || [];
  }, { pageSize: 2 });
  expect(calls).toEqual([{ offset: 0, limit: 2 }, { offset: 2, limit: 2 }]);
  expect(rows.map((r) => r.folio)).toEqual(["1", "2", "3"]);
  expect(truncated).toBe(false);
});

test("paginarLineasVentas marca truncado al llegar al tope de páginas", async () => {
  const { rows, truncated } = await paginarLineasVentas(
    async () => [{ folio: "x" }, { folio: "y" }],
    { pageSize: 2, maxPages: 2 },
  );
  expect(rows).toHaveLength(4);
  expect(truncated).toBe(true);
});

test("nombre de archivo y error si falta el RPC en Supabase", () => {
  expect(nombreArchivoVentasAnalisis(new Date("2026-09-20T18:00:00.000Z"))).toBe(
    "ventas_farmacapital_2026-09-20.csv",
  );
  expect(mensajeErrorExportVentas({ message: "Could not find the function public.empleado_exportar_ventas_lineas" }))
    .toMatch(/patch_exportar_ventas_analisis/);
});
