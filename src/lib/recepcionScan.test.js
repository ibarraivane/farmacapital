import {
  itemMatchScan,
  recepcionEsTicketDocumento,
  resolverEscaneoRecepcion,
  recepcionItemEnAnaquel,
  recepcionItemVerdeSinStock,
  recepcionItemsVerdeSinStock,
  pedidoEsperaEntrada,
  extractGs1Gtin,
  extractGs1Lot,
  eanPistolaListo,
  esSerialTerminalPoint,
  barcodeDigitsMatch,
  normalizeBarcodeRaw,
  genommaTicketVsCaja,
  beepContieneCodigo,
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

  test("Dibar 500 ml: EAN del bote abre el renglón del ticket OCR", () => {
    const item = {
      id: 4,
      confirmado: false,
      codigo_escaneado: "7501868990023",
      sku: "FC-68990023",
      producto_id: 340,
      origen: "pdf",
    };
    const cat = [
      {
        id: 340,
        sku: "FC-68990023",
        codigo_barras: "7501868990023",
        activo: true,
      },
    ];
    expect(itemMatchScan(item, "7501868900233", cat)).toBe(true);
    expect(itemMatchScan(item, "7501868990023", cat)).toBe(true);
    expect(itemMatchScan(item, "7501868900226", cat)).toBe(false);
  });

  test("EAN de exhibidor anotado en descripción abre la pieza", () => {
    const item = {
      id: 9,
      confirmado: false,
      codigo_escaneado: null,
      sku: "FC-EXP-OPT48",
      producto_id: 501,
      origen: "pdf",
    };
    const cat = [
      {
        id: 501,
        sku: "FC-EXP-OPT48",
        codigo_barras: "7509546015699",
        descripcion: "Se vende el sobre. EAN pieza/exhibidor 7509546015699.",
        activo: true,
      },
    ];
    expect(itemMatchScan(item, "7509546015699", cat)).toBe(true);
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

  test("Dibar 500 ml en ticket PDF: el EAN del bote no queda fuera", () => {
    const item = {
      id: 4,
      confirmado: false,
      codigo_escaneado: "7501868990023",
      sku: "FC-68990023",
      producto_id: 340,
      origen: "pdf",
    };
    const cat = [
      { id: 340, sku: "FC-68990023", codigo_barras: "7501868990023", activo: true },
    ];
    const r = resolverEscaneoRecepcion({
      items: [item],
      codigo: "7501868900233",
      productos: cat,
      esTicketDocumento: true,
    });
    expect(r.tipo).toBe("gris");
    expect(r.item.id).toBe(4);
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

describe("pedidoEsperaEntrada", () => {
  test("ticket con cajas grises es pedido vivo", () => {
    expect(pedidoEsperaEntrada({ renglones: 11, sin_confirmar: 11, estado: "borrador" })).toBe(true);
  });

  test("historial ya recibido no vuelve a Recibir solo por estar en borrador", () => {
    expect(pedidoEsperaEntrada({ renglones: 184, sin_confirmar: 0, estado: "borrador" })).toBe(false);
  });

  test("falta MMAA de anaquel sigue en la cola", () => {
    expect(pedidoEsperaEntrada({
      renglones: 10,
      sin_confirmar: 0,
      sin_caducidad_anaquel: 3,
      estado: "borrador",
    })).toBe(true);
  });
});


describe("GS1 / DataMatrix en Recibir", () => {
  test("extrae GTIN de beep GS1 con AI 01", () => {
    expect(extractGs1Gtin("01075013490233691728031110U26J016")).toBe("7501349023369");
    expect(extractGs1Gtin("(01)07501349023369(17)280311(10)U26J016")).toBe("7501349023369");
  });

  test("DataMatrix GS1 abre el renglón gris del ticket", () => {
    const item = {
      id: 40,
      confirmado: false,
      codigo_escaneado: "7501349023369",
      sku: "EQ-AMS160",
      origen: "pdf",
    };
    expect(itemMatchScan(item, "01075013490233691728031110U26J016", [])).toBe(true);
    const r = resolverEscaneoRecepcion({
      items: [item],
      codigo: "01075013490233691728031110U26J016",
      productos: [],
      esTicketDocumento: true,
    });
    expect(r.tipo).toBe("gris");
    expect(r.codigo).toBe("7501349023369");
  });

  test("eanPistolaListo dispara con GS1 largo", () => {
    expect(eanPistolaListo("01075013490233691728031110U26J016")).toBe(true);
    expect(eanPistolaListo("7501349023369")).toBe(true);
    expect(eanPistolaListo("NCCC05728001")).toBe(false);
  });

  test("serial Point Smart no es producto del ticket", () => {
    expect(esSerialTerminalPoint("NCCC05728001")).toBe(true);
    expect(esSerialTerminalPoint("N950NCCC05728001")).toBe(true);
    const r = resolverEscaneoRecepcion({
      items: [{ confirmado: false, codigo_escaneado: "7501349023369", origen: "pdf" }],
      codigo: "NCCC05728001",
      productos: [],
      esTicketDocumento: true,
    });
    expect(r.tipo).toBe("fuera");
    expect(r.motivo).toBe("serial_point");
  });

  test("Equilibrio 20260914: DataMatrix GS1 abre cada renglón gris pendiente", () => {
    // EANs del ticket Palillero (los 8 sin caducidad de la foto).
    const grises = [
      { sku: "EQ-AMS160", ean: "7501349023369", lote: "U26J016" },
      { sku: "EQ-AVI026", ean: "7502216803893", lote: "530175" },
      { sku: "EQ-ULT117", ean: "7502216793439", lote: "6H445" },
      { sku: "FC-09747328", ean: "7502009747328", lote: "6FN231C" },
      { sku: "EQ-ALP0628", ean: "7502226293776", lote: "B25T515" },
      { sku: "EQ-ALP0120", ean: "7502226291871", lote: "2603022" },
      { sku: "EQ-NOV006", ean: "7501075711035", lote: "140185" },
    ];
    const items = grises.map((g, i) => ({
      id: i + 1,
      confirmado: false,
      codigo_escaneado: g.ean,
      sku: g.sku,
      numero_lote: g.lote,
      origen: "pdf",
    }));
    for (const g of grises) {
      const gs1 = `010${g.ean}17280311\x1d10${g.lote}`;
      expect(extractGs1Gtin(gs1)).toBe(g.ean);
      const r = resolverEscaneoRecepcion({
        items,
        codigo: gs1,
        productos: [],
        esTicketDocumento: true,
      });
      expect(r.tipo).toBe("gris");
      expect(r.codigo).toBe(g.ean);
      expect(r.item.sku).toBe(g.sku);
    }
  });

  test("pistola AIM ]C1 / ]d2 no deja el EAN irreconocible", () => {
    expect(normalizeBarcodeRaw("]C17501349023369")).toBe("7501349023369");
    expect(extractGs1Gtin("]d201075013490233691728031110U26J016")).toBe("7501349023369");
    expect(eanPistolaListo("]C17501349023369")).toBe(true);
    const item = {
      confirmado: false,
      codigo_escaneado: "7501349023369",
      sku: "EQ-AMS160",
      origen: "pdf",
    };
    expect(itemMatchScan(item, "]C17501349023369", [])).toBe(true);
    const r = resolverEscaneoRecepcion({
      items: [item],
      codigo: "]d201075013490233691728031110U26J016",
      productos: [],
      esTicketDocumento: true,
    });
    expect(r.tipo).toBe("gris");
  });

  test("Genomma 12 vs 13: ticket se come un 0, la caja lo trae", () => {
    expect(genommaTicketVsCaja("650240079009", "6502400079009")).toBe(true);
    expect(genommaTicketVsCaja("650240078996", "6502400078996")).toBe(true);
    expect(barcodeDigitsMatch("6502400079009", "650240079009")).toBe(true);
    expect(barcodeDigitsMatch("6502400078996", "650240078996")).toBe(true);
    const rosa = {
      confirmado: false,
      codigo_escaneado: "650240079009",
      origen: "csv",
    };
    const azul = {
      confirmado: false,
      codigo_escaneado: "650240078996",
      origen: "csv",
    };
    expect(itemMatchScan(rosa, "6502400079009", [])).toBe(true);
    expect(itemMatchScan(rosa, "6502400070009", [])).toBe(true);
    expect(itemMatchScan(azul, "6502400078996", [])).toBe(true);
    expect(resolverEscaneoRecepcion({
      items: [rosa, azul],
      codigo: "6502400079009",
      productos: [],
      esTicketDocumento: true,
    }).tipo).toBe("gris");
  });

  test("beep GS1 largo contiene el EAN aunque AI 01 no parsee", () => {
    expect(beepContieneCodigo("XX7501349023369YY", "7501349023369")).toBe(true);
    const item = {
      confirmado: false,
      codigo_escaneado: "EQ-AMS160",
      sku: "EQ-AMS160",
      codigo_barras: "7501349023369",
      numero_lote: "U26J016",
      origen: "pdf",
    };
    expect(itemMatchScan(item, "7501349023369", [])).toBe(true);
    expect(itemMatchScan(item, "01099999999999991728031110U26J016", [])).toBe(true);
    const r = resolverEscaneoRecepcion({
      items: [item],
      codigo: "7501349023369",
      productos: [],
      esTicketDocumento: true,
    });
    expect(r.tipo).toBe("gris");
  });

  test("dígito verificador: ticket 12 vs catálogo 13 (Teatrical / Farmalive)", () => {
    expect(barcodeDigitsMatch("650240013850", "6502400138504")).toBe(true);
    expect(barcodeDigitsMatch("6502400138504", "650240013850")).toBe(true);
    const item = {
      confirmado: false,
      codigo_escaneado: "650240013850",
      origen: "csv",
    };
    expect(itemMatchScan(item, "6502400138504", [])).toBe(true);
    expect(itemMatchScan(item, "01065024001385041728031110AB12", [])).toBe(true);
  });

  test("GS1 Genomma 650240 abre el renglón (Gargax Farmalive)", () => {
    expect(extractGs1Gtin("01065024002833541728031110GX01")).toBe("6502400283354");
    const item = {
      confirmado: false,
      codigo_escaneado: "650240028335",
      origen: "csv",
    };
    expect(itemMatchScan(item, "01065024002833541728031110GX01", [])).toBe(true);
  });

  test("lote GS1 abre el gris Equilibrio si el EAN de caja no está en el ticket", () => {
    expect(extractGs1Lot("01075000000000001728031110U26J016")).toBe("U26J016");
    const item = {
      confirmado: false,
      codigo_escaneado: "7501349023369",
      sku: "EQ-AMS160",
      numero_lote: "U26J016",
      origen: "pdf",
    };
    const r = resolverEscaneoRecepcion({
      items: [item],
      codigo: "01099999999999991728031110U26J016",
      productos: [],
      esTicketDocumento: true,
    });
    expect(r.tipo).toBe("gris");
    expect(r.item.sku).toBe("EQ-AMS160");
  });
});
