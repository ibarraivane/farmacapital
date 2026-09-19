import {
  cuentaPiezasCajaMostrador,
  descripcionPublicaTienda,
  esNotaInternaCompra,
  presentacionPublicaTienda,
  productoEsCajaAbiertaMostrador,
  subtituloPublicoTienda,
} from "./cajaAbiertaMostrador";

function caja(extra) {
  return {
    activo: true,
    venta_unidad: true,
    ...extra,
  };
}

test("Aspirina C/40 y C/80 no van a la tienda web", () => {
  expect(
    productoEsCajaAbiertaMostrador(
      caja({
        nombre: "Aspirina 500 mg C/40",
        presentacion: "C/40 tabletas",
        unidades_por_caja: 40,
        categoria: "Analgésico",
      }),
    ),
  ).toBe(true);
  expect(
    productoEsCajaAbiertaMostrador(
      caja({
        nombre: "Aspirina 500 mg",
        presentacion: "C/80 tabletas 500 mg",
        unidades_por_caja: 80,
        categoria: "Analgésico",
      }),
    ),
  ).toBe(true);
});

test("Aspirina 80 tabletas sin venta_unidad también se oculta", () => {
  expect(
    productoEsCajaAbiertaMostrador({
      nombre: "Aspirina",
      presentacion: "80 TABLETAS",
      venta_unidad: false,
      unidades_por_caja: 0,
      categoria: "Analgésico",
    }),
  ).toBe(true);
});

test("Cafiaspirina C/100, Junior C/60, Alka C/50 y Sedalmerck C/40 se ocultan", () => {
  expect(
    productoEsCajaAbiertaMostrador(
      caja({
        nombre: "Cafiaspirina tartrato C/100",
        presentacion: "C/100",
        unidades_por_caja: 100,
        categoria: "Analgésico",
      }),
    ),
  ).toBe(true);
  expect(
    productoEsCajaAbiertaMostrador(
      caja({
        nombre: "Aspirina Junior 100 mg C/60",
        presentacion: "C/60 tabletas 100 mg",
        unidades_por_caja: 60,
        categoria: "Analgésico",
      }),
    ),
  ).toBe(true);
  expect(
    productoEsCajaAbiertaMostrador(
      caja({
        nombre: "Alka-Seltzer",
        presentacion: "C/50",
        unidades_por_caja: 50,
        categoria: "Gastro",
        forma_farmaceutica: "TABLETAS",
      }),
    ),
  ).toBe(true);
  expect(
    productoEsCajaAbiertaMostrador(
      caja({
        nombre: "Sedalmerck C/40 tabletas",
        presentacion: "C/40 tabletas",
        unidades_por_caja: 40,
        categoria: "Analgésico",
      }),
    ),
  ).toBe(true);
  expect(
    productoEsCajaAbiertaMostrador(
      caja({
        nombre: "Bicarbonato Sobres",
        presentacion: "C/50",
        unidades_por_caja: 50,
        categoria: "Herbolario",
        forma_farmaceutica: "Producto natural",
      }),
    ),
  ).toBe(true);
});

test("cajas chicas C/12 y C/24 siguen en línea", () => {
  expect(
    productoEsCajaAbiertaMostrador(
      caja({
        nombre: "Aspirina Forte C/24",
        presentacion: "C/24",
        unidades_por_caja: 24,
        categoria: "Analgésico",
      }),
    ),
  ).toBe(false);
  expect(
    productoEsCajaAbiertaMostrador(
      caja({
        nombre: "Aspirina efervescente C/12",
        presentacion: "C/12",
        unidades_por_caja: 12,
        categoria: "Analgésico",
      }),
    ),
  ).toBe(false);
  expect(
    productoEsCajaAbiertaMostrador(
      caja({
        nombre: "Tabcin 500 C/12",
        presentacion: "C/12 capsulas",
        unidades_por_caja: 12,
        categoria: "Respiratorio",
      }),
    ),
  ).toBe(false);
});

test("gasa, cubrebocas, curitas, Tena y Saba no se ocultan", () => {
  expect(
    productoEsCajaAbiertaMostrador(
      caja({
        nombre: "Gasa Lox10 C/100",
        presentacion: "C/100",
        unidades_por_caja: 100,
        categoria: "Dispositivo médico",
      }),
    ),
  ).toBe(false);
  expect(
    productoEsCajaAbiertaMostrador(
      caja({
        nombre: "Cubrebocas tricapa desechable C/100",
        presentacion: "Caja C/100",
        unidades_por_caja: 100,
        categoria: "Dispositivo médico",
        forma_farmaceutica: "Cubrebocas",
      }),
    ),
  ).toBe(false);
  expect(
    productoEsCajaAbiertaMostrador(
      caja({
        nombre: "Tena Pants Comfort grande C/13",
        presentacion: "Bolsa con 13 pants talla grande",
        unidades_por_caja: 13,
        categoria: "Higiene",
      }),
    ),
  ).toBe(false);
  expect(
    productoEsCajaAbiertaMostrador(
      caja({
        nombre: "Saba buenas noches",
        presentacion: "C/8",
        unidades_por_caja: 8,
        categoria: "Higiene",
      }),
    ),
  ).toBe(false);
});

test("frasco Mercurio C/50 no se oculta", () => {
  expect(
    productoEsCajaAbiertaMostrador(
      caja({
        nombre: "Mercurio Oxido De Zinc",
        presentacion: "C/50",
        unidades_por_caja: 50,
        categoria: "Herbolario",
        forma_farmaceutica: "Pomada",
      }),
    ),
  ).toBe(false);
});

test("cuenta piezas desde presentacion si falta unidades_por_caja", () => {
  expect(cuentaPiezasCajaMostrador({ presentacion: "80 TABLETAS", unidades_por_caja: 0 })).toBe(80);
  expect(cuentaPiezasCajaMostrador({ presentacion: "C/40 tabletas", unidades_por_caja: 0 })).toBe(40);
});

test("ocultar en web no implica bajar el SKU del POS", () => {
  const p = caja({
    activo: true,
    nombre: "Aspirina 500 mg C/40",
    presentacion: "C/40 tabletas",
    unidades_por_caja: 40,
    categoria: "Analgésico",
    venta_unidad: true,
    precio_unidad: 7,
  });
  expect(productoEsCajaAbiertaMostrador(p)).toBe(true);
  expect(p.activo).toBe(true);
  expect(p.venta_unidad).toBe(true);
  expect(p.precio_unidad).toBe(7);
});

test("descripcionPublicaTienda oculta notas de ticket", () => {
  expect(
    descripcionPublicaTienda({
      nombre: "Asmaral-K Ketotifeno",
      descripcion: "Ticket Equilibrio 440393 · código de proveedor SER001 · falta código de barras",
    }),
  ).toBe("");
  expect(
    descripcionPublicaTienda({
      nombre: "Butilhioscina",
      descripcion: "Factura Levic 9012118935 · clave AMS075",
    }),
  ).toBe("");
  expect(
    descripcionPublicaTienda({
      nombre: "Aspirina",
      descripcion: "Aspirina",
    }),
  ).toBe("");
  expect(
    descripcionPublicaTienda({
      nombre: "Aspirina 500 mg",
      descripcion: "Aspirina Bayer 500 mg 80 tabletas — EAN 7501008499818",
    }),
  ).toMatch(/Bayer/);
  expect(
    descripcionPublicaTienda({
      nombre: "Exkruthera Fruquintinib 1 mg",
      descripcion:
        "Alta mostrador · ficha SFE / Takeda · registro 295M2025 SSA IV · costo y PVP 0.01 por definir · 4 pzas sin lote",
    }),
  ).toBe("");
});

test("descripcionPublicaTienda oculta dónde se compró (Dulcería / ticket / EAN pendiente)", () => {
  const skittles = {
    nombre: "Skittles Original bolsa",
    descripcion:
      "Alta Dulcería La Victoria T280033139 · 2026-09-05 · EAN pendiente de caja · ticket decía La Famosa",
    presentacion: "Bolsa (caja mayoreo 24/10PZ)",
  };
  expect(esNotaInternaCompra(skittles.descripcion)).toBe(true);
  expect(descripcionPublicaTienda(skittles)).toBe("");
  expect(presentacionPublicaTienda(skittles)).toBe("Bolsa (caja mayoreo 24/10PZ)");
  expect(subtituloPublicoTienda(skittles)).toBe("Bolsa (caja mayoreo 24/10PZ)");
  expect(
    descripcionPublicaTienda({
      nombre: "Anthelios UV Air",
      descripcion: "Alta Nadro 000004568 · 2026-09-13 · listo para pistola",
    }),
  ).toBe("");
  expect(
    subtituloPublicoTienda({
      nombre: "Halls",
      descripcion: "Alta Dulcería La Victoria T280034008 · ticket decía La Famosa",
      presentacion: "Alta Dulcería La Victoria T280034008 · ticket decía La Famosa",
    }),
  ).toBe("");
});

test("descripcionPublicaTienda oculta cruce Fahorro / precio lista (no es ficha de cliente)", () => {
  const aDerma = {
    nombre: "A-Derma Exomega Control Crema Emoliente 400 ml",
    descripcion: "Fahorro SKU=EAN 3282770073577 · Exomega Control 400 ml · precio lista $801",
    presentacion: "400 ml",
  };
  expect(esNotaInternaCompra(aDerma.descripcion)).toBe(true);
  expect(descripcionPublicaTienda(aDerma)).toBe("");
  expect(subtituloPublicoTienda(aDerma)).toBe("400 ml");
  expect(
    descripcionPublicaTienda({
      nombre: "Avène Cicalfate+",
      descripcion: "SKU=EAN 3282770208122 · precio lista $640",
    }),
  ).toBe("");
});

test("descripcionPublicaTienda oculta notas de mayoreo y recargo", () => {
  const madrid = {
    nombre: "Aceite Madrid",
    descripcion:
      "Farma Mayoreo 305016 · térmico «MADRID ACEITE DE» EAN 7506313000513 · el nombre viene cortado: no se inventa tipo ni ml · foto pendiente · P.U. $30.90 ya con IVA · recargo marca +25%",
    presentacion: "Frasco",
  };
  expect(esNotaInternaCompra(madrid.descripcion)).toBe(true);
  expect(descripcionPublicaTienda(madrid)).toBe("");
  expect(subtituloPublicoTienda(madrid)).toBe("Frasco");
  expect(
    descripcionPublicaTienda({
      nombre: "Aceite de almendras dulces Flor de Aire 125 ml",
      descripcion: "IFC 124418. EAN de la botella 7502280170501. Recargo marca +25%.",
    }),
  ).toBe("");
  expect(
    descripcionPublicaTienda({
      nombre: "Grenobil mascarilla",
      descripcion: "Farmalive 127790 · ticket Aspirina · foto pendiente",
    }),
  ).toBe("");
  expect(
    descripcionPublicaTienda({
      nombre: "Aceite de almendras",
      descripcion: "Humecta piel y cabello. Uso tópico.",
    }),
  ).toBe("Humecta piel y cabello. Uso tópico.");
});
