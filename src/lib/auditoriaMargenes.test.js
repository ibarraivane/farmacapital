import {
  auditarMargenProducto,
  catalogoGuardoImporteComoCosto,
  costoUnitarioDeRenglonTicket,
  csvGuardoImporteComoUnitario,
  familiaMargen,
  refsVentaComparablesAuditoria,
  ultimaPareceImporteDeVariasPiezas,
} from "./auditoriaMargenes";

const sedal135 = {
  nombre: "Crema Para Peinar Sedal Rizos Definidos",
  categoria: "Cuidado personal",
  tipo: "marca",
  presentacion: "135 ML",
  costo: 9.08,
};

test("Sedal 135 ml a $61 es margen abismal; sugerido $20", () => {
  const a = auditarMargenProducto({ ...sedal135, precio: 61 });
  expect(familiaMargen(sedal135)).toBe("higiene");
  expect(a.accion).toBe("bajar");
  expect(a.sugerido).toBe(20);
  expect(a.techoOk).toBe(20);
});

test("Sedal 135 ml a $20 (ya corregido) no alerta", () => {
  const a = auditarMargenProducto({ ...sedal135, precio: 20 });
  expect(a.accion).toBe("ok");
  expect(a.sugerido).toBeNull();
});

test("descarta Similares $92 en la crema de $9", () => {
  const refs = refsVentaComparablesAuditoria(9.08, 15, 20, [
    { fuente: "similares", precio: 92 },
    { fuente: "rappi_super", precio: 20 },
    { fuente: "rappi_gdl", precio: 33 },
  ]);
  expect(refs).toEqual([20, 33]);
});

test("Nivea Milk $207 vs costo $22.30 baja hacia el techo", () => {
  const a = auditarMargenProducto({
    nombre: "Nivea Milk Crema corp 400 ML",
    categoria: "Cuidado personal",
    tipo: "marca",
    costo: 22.3,
    precio: 207,
  });
  expect(a.accion).toBe("bajar");
  expect(a.sugerido).toBe(50);
});

test("venta bajo costo", () => {
  const a = auditarMargenProducto({
    nombre: "Pañuelos Kleenex",
    categoria: "Higiene",
    costo: 32.83,
    precio: 10,
  });
  expect(a.accion).toBe("bajo_costo");
  expect(a.sugerido).toBeGreaterThan(10);
});

test("costo $0.01 no sugiere bajar el PVP", () => {
  const a = auditarMargenProducto({
    nombre: "Metanucil 1 Polvo Sabor Natural 504 G",
    categoria: "Otro",
    costo: 0.01,
    precio: 150,
  });
  expect(a.accion).toBe("revisar_costo");
  expect(a.sugerido).toBeNull();
});

test("genérico al recargo 60% sobre venta (2.5×) no es alerta", () => {
  const a = auditarMargenProducto({
    nombre: "Omeprazol 20 mg",
    categoria: "Otro",
    tipo: "generico",
    forma_farmaceutica: "capsula",
    principio_activo: "Omeprazol",
    costo: 16.13,
    precio: 41,
  });
  expect(a.accion).toBe("ok");
});

test("genérico a 6× el costo sí se baja", () => {
  const a = auditarMargenProducto({
    nombre: "Cinitaprida 25 Comp 1 Mg",
    categoria: "Otro",
    tipo: "generico",
    forma_farmaceutica: "tableta",
    principio_activo: "Cinitaprida",
    costo: 17.58,
    precio: 119,
  });
  expect(a.accion).toBe("bajar");
  expect(a.sugerido).toBeLessThan(119);
  expect(a.sugerido).toBeGreaterThanOrEqual(29);
});

test("genérico apenas sobre el piso 1.55× no es alerta", () => {
  const a = auditarMargenProducto({
    nombre: "Cefalver Susp 125 Mg",
    categoria: "Otro",
    tipo: "marca",
    requiere_receta: true,
    costo: 26.25,
    precio: 42,
  });
  expect(a.accion).toBe("ok");
});

test("CSV $8.97 es el importe de 2 Escudo; el unitario es $4.48 y el PVP $42 se baja", () => {
  expect(csvGuardoImporteComoUnitario(4.48, 8.965, 2)).toBe(true);
  expect(costoUnitarioDeRenglonTicket({
    cantidad: 2,
    precioEtiquetado: 8.965,
    subtotal: 17.93,
    costoCatalogo: 4.48,
  })).toBe(4.48);
  const a = auditarMargenProducto(
    {
      nombre: "Escudo Rosa Cuidado",
      categoria: "Higiene",
      costo: 4.48,
      precio: 42,
    },
    { costoTicket: 8.965, cantidadTicket: 2 },
  );
  expect(a.accion).toBe("bajar");
  expect(a.sugerido).toBe(10);
});

test("Sedal: 2 pzas, importe $18.16 → unitario $9.08 (no $18.16)", () => {
  expect(csvGuardoImporteComoUnitario(9.08, 18.165, 2)).toBe(true);
  expect(costoUnitarioDeRenglonTicket({
    cantidad: 2,
    precioEtiquetado: 18.165,
    costoCatalogo: 9.08,
  })).toBe(9.08);
  const a = auditarMargenProducto({ ...sedal135, precio: 20 });
  expect(a.accion).toBe("ok");
});

test("última compra = importe de 2 pzas no tapa el margen alto", () => {
  expect(ultimaPareceImporteDeVariasPiezas(4.48, 8.96)).toBe(true);
  const a = auditarMargenProducto(
    {
      nombre: "Escudo Rosa Cuidado",
      categoria: "Higiene",
      costo: 4.48,
      precio: 42,
    },
    { ultimaCompra: 8.96 },
  );
  expect(a.accion).toBe("bajar");
  expect(a.sugerido).toBe(10);
});

test("Bodega: Pert kera $14.80 es el importe de 2 del oliva; unitario $7.40", () => {
  expect(catalogoGuardoImporteComoCosto(14.8, 7.4, 2)).toBe(true);
  expect(costoUnitarioDeRenglonTicket({
    cantidad: 2,
    precioEtiquetado: 14.8,
    subtotal: 29.6,
    costoCatalogo: 7.4,
  })).toBe(7.4);
});

test("Bodega: Speed Stick $29.91 es el de 2; unitario $14.95", () => {
  expect(catalogoGuardoImporteComoCosto(29.905, 14.95, 2)).toBe(true);
});

test("Mercurio C/50: el $54 es la caja; se vende por pieza a $1.08", () => {
  expect(catalogoGuardoImporteComoCosto(54, 1.08, 50)).toBe(true);
  expect(costoUnitarioDeRenglonTicket({
    cantidad: 50,
    precioEtiquetado: 54,
    subtotal: 54,
  })).toBe(1.08);
});

test("Exprezo: catálogo guardó el importe de N piezas como costo de una", () => {
  expect(catalogoGuardoImporteComoCosto(111.8, 18.63, 6)).toBe(true);
  expect(catalogoGuardoImporteComoCosto(32.04, 10.68, 3)).toBe(true);
  expect(catalogoGuardoImporteComoCosto(42.72, 10.68, 4)).toBe(true);
  expect(catalogoGuardoImporteComoCosto(38.38, 12.79, 3)).toBe(true);
  expect(catalogoGuardoImporteComoCosto(18.63, 18.63, 6)).toBe(false);
  expect(costoUnitarioDeRenglonTicket({
    cantidad: 6,
    precioEtiquetado: 18.63,
    subtotal: 111.8,
  })).toBe(18.63);
});

test("Kleenex Sellapack: Farmalive cobró el C/8; el EAN es de una", () => {
  expect(costoUnitarioDeRenglonTicket({
    cantidad: 8,
    precioEtiquetado: 32.83,
    subtotal: 32.83,
  })).toBe(4.1);
});

test("última compra mucho más cara que el costo catálogo → revisar, no bajar", () => {
  const a = auditarMargenProducto(
    {
      nombre: "Mercurio óxido de zinc C/50",
      categoria: "Otro",
      costo: 9,
      precio: 54,
    },
    { ultimaCompra: 54 },
  );
  expect(a.accion).toBe("revisar_costo");
});
