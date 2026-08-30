import {
  csvCargaRappi,
  filaCargaRappi,
  nombreArchivoCargaRappi,
  precioCsvRappi,
  rappiSkuFromInternal,
  reservaMostradorDe,
  skuInternoDesdeRappi,
  stockPublicadoRappi,
} from "./rappiCargaCsv";

const otc = {
  sku: "FC-ENSURE-VAN",
  codigo_barras: "7501008443026",
  stock: 5,
  precio: 65,
  activo: true,
  requiere_receta: false,
  nombre: "Ensure vainilla 236 ml",
};

test("SKU de Rappi es prefijo + sku en minúsculas", () => {
  expect(rappiSkuFromInternal("FC-ENSURE-VAN")).toBe("FARMACAPITALmt_fc-ensure-van");
  expect(rappiSkuFromInternal("")).toBe("");
});

test("SKU Partner vuelve al sku interno", () => {
  expect(skuInternoDesdeRappi("FARMACAPITALmt_eq-nov032")).toBe("eq-nov032");
  expect(skuInternoDesdeRappi("EQ-NOV032")).toBe("eq-nov032");
  expect(skuInternoDesdeRappi("")).toBe("");
});

test("stock publicado resta el colchón de 2", () => {
  expect(stockPublicadoRappi({ ...otc, stock: 5 }, 2)).toBe(3);
  expect(stockPublicadoRappi({ ...otc, stock: 2 }, 2)).toBe(0);
  expect(stockPublicadoRappi({ ...otc, stock: 1 }, 2)).toBe(0);
});

test("receta, inactivo y controlado salen en 0", () => {
  expect(stockPublicadoRappi({ ...otc, requiere_receta: true })).toBe(0);
  expect(stockPublicadoRappi({ ...otc, activo: false })).toBe(0);
  expect(stockPublicadoRappi({ ...otc, controlado: true })).toBe(0);
});

test("caja de granel (Aspirina C/40) no se publica", () => {
  const caja = {
    ...otc,
    sku: "FC-ASP40",
    nombre: "Aspirina 500 mg C/40",
    presentacion: "C/40 tabletas",
    unidades_por_caja: 40,
    categoria: "Analgésico",
    venta_unidad: true,
    stock: 20,
  };
  expect(stockPublicadoRappi(caja)).toBe(0);
  expect(filaCargaRappi(caja).AVAILABLE).toBe(false);
});

test("fila de carga tiene EAN limpio y AVAILABLE según stock", () => {
  const row = filaCargaRappi({ ...otc, codigo_barras: "750-1008-443026" });
  expect(row.SKU).toBe("FARMACAPITALmt_fc-ensure-van");
  expect(row.EAN).toBe("7501008443026");
  expect(row.STOCK).toBe(3);
  expect(row.AVAILABLE).toBe(true);
  expect(row.PRICE).toBe("65");
});

test("sin sku no hay fila; precio decimal se formatea", () => {
  expect(filaCargaRappi({ ...otc, sku: "" })).toBe(null);
  expect(precioCsvRappi(66.5)).toBe("66.50");
  expect(precioCsvRappi(null)).toBe("");
});

test("CSV es el de Partner: encabezado y true/false", () => {
  const csv = csvCargaRappi([otc, { ...otc, sku: "FC-RX", requiere_receta: true, stock: 10 }]);
  const lines = csv.trim().split("\n");
  expect(lines[0]).toBe("SKU,EAN,STOCK,AVAILABLE,PRICE");
  expect(lines[1]).toBe("FARMACAPITALmt_fc-ensure-van,7501008443026,3,true,65");
  expect(lines[2]).toBe("FARMACAPITALmt_fc-rx,7501008443026,0,false,65");
});

test("reserva inválida cae a 2; nombre de archivo usa la fecha", () => {
  expect(reservaMostradorDe("abc")).toBe(2);
  expect(reservaMostradorDe("3")).toBe(3);
  expect(nombreArchivoCargaRappi(new Date("2026-08-30T20:00:00Z"))).toBe("rappi_carga_2026-08-30.csv");
});
