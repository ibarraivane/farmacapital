import {
  INCIDENTE_PIOGLITAZONA,
  RAPPI_SKU_PREFIX,
  alertaDeFila,
  buildFilasInventario,
  calcStockPublicado,
  csvCargaSegura,
  internalSkuFromRappi,
  matchRappiRow,
  parseRappiInventarioCsv,
  productoEligibleRappi,
  rappiSkuFromInternal,
  resumirCruce,
} from "./rappiInventario";

test("SKU Rappi FARMACAPITALmt_ + sku en minúsculas", () => {
  expect(rappiSkuFromInternal("EQ-ULT146")).toBe("FARMACAPITALmt_eq-ult146");
  expect(internalSkuFromRappi("FARMACAPITALmt_eq-ult146")).toBe("eq-ult146");
  expect(internalSkuFromRappi("FARMACAPITALmt_EQ-ULT146")).toBe("EQ-ULT146");
});

test("no publica las últimas 2 piezas", () => {
  expect(calcStockPublicado(4, 2)).toBe(2);
  expect(calcStockPublicado(2, 2)).toBe(0);
  expect(calcStockPublicado(1, 2)).toBe(0);
  expect(productoEligibleRappi({ activo: true, requiere_receta: true })).toBe(false);
});

test("pedido 2468274038: 4 en Rappi vs 2 locales con colchón = 0", () => {
  const { filas } = buildFilasInventario({
    productos: [{
      id: 953,
      sku: "EQ-ULT146",
      nombre: "Pioglitazona",
      codigo_barras: "7502216796737",
      stock: 2,
      precio: 24,
      activo: true,
      requiere_receta: false,
    }],
    queueRows: [{
      sku: "EQ-ULT146",
      estado: "pendiente",
      created_at: "2026-08-19T16:15:22Z",
      payload: { disponible: false, stock_rappi: 0, stock_local: 2 },
    }],
    rappiRows: [{
      sku: "FARMACAPITALmt_eq-ult146",
      ean: "7502216796737",
      stock: INCIDENTE_PIOGLITAZONA.qtyPedida,
      disponible: true,
    }],
  });
  expect(filas).toHaveLength(1);
  const f = filas[0];
  expect(f.incidente).toBe(true);
  expect(f.stockLocal).toBe(2);
  expect(f.stockPublicado).toBe(0);
  expect(f.disponible).toBe(false);
  expect(f.rappiStock).toBe(4);
  expect(f.alerta).toBe("incidente");
  expect(f.colaQuiereApagar).toBe(true);
  expect(f.colaPendiente).toBe(true);
});

test("CSV del partner matchea por SKU Rappi o EAN", () => {
  const { rows } = parseRappiInventarioCsv(
    "SKU,EAN,Stock,Available\nFARMACAPITALmt_eq-ult146,7502216796737,4,true\n"
  );
  expect(rows[0].sku).toBe("FARMACAPITALmt_eq-ult146");
  expect(rows[0].stock).toBe(4);
  const bySku = new Map([["eq-ult146", { id: 953, sku: "EQ-ULT146" }]]);
  const byEan = new Map([["7502216796737", { id: 953, sku: "EQ-ULT146" }]]);
  expect(matchRappiRow(rows[0], bySku, byEan, RAPPI_SKU_PREFIX)?.id).toBe(953);
});

test("CSV con punto y coma (Excel MX)", () => {
  const { rows } = parseRappiInventarioCsv("SKU;EAN;Existencias\neq-ult146;7502216796737;4");
  expect(rows[0].stock).toBe(4);
  expect(rows[0].ean).toBe("7502216796737");
});

test("cola pendiente de apagar es peligro aunque no haya CSV de Rappi", () => {
  const { filas } = buildFilasInventario({
    productos: [{
      id: 1, sku: "EQ-SON034", nombre: "Busconet", codigo_barras: "1",
      stock: 2, activo: true, requiere_receta: false,
    }],
    queueRows: [{
      sku: "EQ-SON034",
      estado: "pendiente",
      payload: { disponible: false, stock_rappi: 0 },
    }],
  });
  expect(filas[0].alerta).toBe("peligro");
});

test("resumen y CSV de carga segura usan stock publicado", () => {
  const { filas } = buildFilasInventario({
    productos: [
      { id: 1, sku: "EQ-ULT146", nombre: "Pio", codigo_barras: "7502216796737", stock: 2, activo: true, requiere_receta: false },
      { id: 2, sku: "FC-07521317", nombre: "Gotero", codigo_barras: "111", stock: 100, activo: true, requiere_receta: false },
    ],
    rappiRows: [{ sku: "EQ-ULT146", ean: "7502216796737", stock: 4 }],
  });
  const sum = resumirCruce(filas);
  expect(sum.incidente).toBe(1);
  expect(sum.publicables).toBe(1);
  expect(sum.rappiVendeDeMas).toBe(1);
  const csv = csvCargaSegura(filas);
  expect(csv).toContain("FARMACAPITALmt_eq-ult146,7502216796737,0,false");
  expect(csv).toContain("FARMACAPITALmt_fc-07521317,111,98,true");
});

test("alertaDeFila: Rappi disponible con stock publicado 0", () => {
  expect(alertaDeFila({
    incidente: false,
    rappiStock: 1,
    stockPublicado: 0,
    rappiDisponible: true,
    disponible: false,
  })).toBe("peligro");
});
