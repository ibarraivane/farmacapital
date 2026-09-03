import {
  itemMatchScan,
  recepcionEsTicketDocumento,
  resolverEscaneoRecepcion,
  recepcionItemEnAnaquel,
  recepcionItemVerdeSinStock,
  recepcionItemsVerdeSinStock,
} from "./recepcionScan";

const TEGADERM = {
  id: 1,
  confirmado: false,
  codigo_escaneado: "4001895928765",
  sku: "FC-TEGA",
  producto_id: 88,
  nombre: "Tegaderm 3M 10 x 12 cm C/50",
  origen: "pdf",
};

const IFC_TIJERA = {
  id: 2,
  confirmado: false,
  codigo_escaneado: "FC-IFC-TIJ01",
  sku: "FC-IFC-TIJ01",
  producto_id: 91,
  nombre: "Tijera para bigote",
  origen: "csv",
};

const CAT = [
  { id: 88, sku: "FC-TEGA", codigo_barras: "4001895928765", activo: true },
  { id: 91, sku: "FC-IFC-TIJ01", codigo_barras: "7501234567890", activo: true },
];

describe("itemMatchScan", () => {
  test("Tegaderm por EAN del ticket", () => {
    expect(itemMatchScan(TEGADERM, "4001895928765", CAT)).toBe(true);
  });

  test("IFC por SKU interno", () => {
    expect(itemMatchScan(IFC_TIJERA, "FC-IFC-TIJ01", CAT)).toBe(true);
  });

  test("IFC por EAN del empaque (catálogo, no el ticket)", () => {
    expect(itemMatchScan(IFC_TIJERA, "7501234567890", CAT)).toBe(true);
  });

  test("otro EAN no pega", () => {
    expect(itemMatchScan(IFC_TIJERA, "7500000000000", CAT)).toBe(false);
  });
});

describe("resolverEscaneoRecepcion", () => {
  test("abre el gris", () => {
    const r = resolverEscaneoRecepcion({
      items: [TEGADERM],
      codigo: "4001895928765",
      productos: CAT,
      esTicketDocumento: true,
    });
    expect(r.tipo).toBe("gris");
    expect(r.item.id).toBe(1);
  });

  test("ya verde: no vuelve a registrar", () => {
    const r = resolverEscaneoRecepcion({
      items: [{ ...TEGADERM, confirmado: true }],
      codigo: "4001895928765",
      productos: CAT,
      esTicketDocumento: true,
    });
    expect(r.tipo).toBe("ya_confirmado");
  });

  test("EAN ajeno en ticket PDF/CSV: fuera", () => {
    const r = resolverEscaneoRecepcion({
      items: [IFC_TIJERA],
      codigo: "7500000000000",
      productos: CAT,
      esTicketDocumento: true,
    });
    expect(r.tipo).toBe("fuera");
  });

  test("ticket suelto (sin PDF/CSV): se puede agregar", () => {
    const r = resolverEscaneoRecepcion({
      items: [],
      codigo: "4001895928765",
      productos: CAT,
      esTicketDocumento: false,
    });
    expect(r.tipo).toBe("nuevo");
  });
});

describe("recepcionEsTicketDocumento", () => {
  test("csv/pdf cuentan", () => {
    expect(recepcionEsTicketDocumento([IFC_TIJERA])).toBe(true);
    expect(recepcionEsTicketDocumento([{ origen: "pistola" }])).toBe(false);
  });
});

describe("recepcionItemVerdeSinStock", () => {
  test("verde con lote = en anaquel", () => {
    const it = { confirmado: true, fecha_caducidad: "2027-06-01", lote_id: 9, pendiente_alta: false };
    expect(recepcionItemEnAnaquel(it)).toBe(true);
    expect(recepcionItemVerdeSinStock(it)).toBe(false);
  });

  test("confirmado sin lote = mentira verde (no está en Inventario/POS)", () => {
    const it = { confirmado: true, fecha_caducidad: "2027-06-01", lote_id: null, pendiente_alta: false };
    expect(recepcionItemEnAnaquel(it)).toBe(false);
    expect(recepcionItemVerdeSinStock(it)).toBe(true);
  });

  test("pendiente de alta no cuenta como verde mentiroso", () => {
    const it = { confirmado: true, fecha_caducidad: "2027-06-01", lote_id: null, pendiente_alta: true };
    expect(recepcionItemVerdeSinStock(it)).toBe(false);
  });

  test("lista filtra huérfanos", () => {
    const items = [
      { id: 1, confirmado: true, fecha_caducidad: "2027-01-01", lote_id: 1, pendiente_alta: false },
      { id: 2, confirmado: true, fecha_caducidad: "2027-01-01", lote_id: null, pendiente_alta: false },
      { id: 3, confirmado: false, fecha_caducidad: null, lote_id: null, pendiente_alta: false },
    ];
    expect(recepcionItemsVerdeSinStock(items).map((i) => i.id)).toEqual([2]);
  });
});
