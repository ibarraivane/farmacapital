import fs from "fs";
import path from "path";
import * as XLSX from "xlsx";
import {
  catalogoPartnerActual,
  disponibilidadRappiDe,
  filasDesdeBufferPlantillaRappi,
  filasPartnerComoCatalogo,
  nombreArchivoPlantillaRappi,
  parchesPlantillaRappi,
  parseFilasProductosRappi,
  precioPlantillaRappi,
  rellenarBufferPlantillaRappi,
  resumenParchesRappi,
} from "./rappiPlantilla";
import { idsEnCatalogoRappi } from "./rappiPrecios";

const lizovag = {
  id: 9,
  sku: "EQ-NOV032",
  nombre: "Lizovag 10 Tab 200 Mg",
  codigo_barras: "7501075717150",
  precio: 29,
  stock: 5,
  activo: true,
  requiere_receta: false,
};

const plantillaPath = path.join(
  process.cwd(),
  "public/catalogo-propia/ProductosActualizacion-es.xlsx",
);

test("el catálogo Partner trae Lizovag y 68 SKUs", () => {
  const cat = catalogoPartnerActual();
  expect(cat.productos).toHaveLength(68);
  expect(cat.productos[0].sku).toBe("FARMACAPITALmt_eq-nov032");
  expect(cat.productos[0].ean).toBe("7501075717150");
});

test("Lizovag del Partner entra a En Rappi por SKU", () => {
  const ids = idsEnCatalogoRappi([lizovag], filasPartnerComoCatalogo());
  expect([...ids]).toEqual([9]);
});

test("Disponibilidad SI solo si hay stock menos colchón", () => {
  expect(disponibilidadRappiDe({ ...lizovag, stock: 5 }, 2)).toBe("SI");
  expect(disponibilidadRappiDe({ ...lizovag, stock: 2 }, 2)).toBe("NO");
  expect(disponibilidadRappiDe({ ...lizovag, requiere_receta: true, stock: 20 }, 2)).toBe("NO");
});

test("el precio de la plantilla es el de mostrador", () => {
  expect(precioPlantillaRappi(lizovag, 26)).toBe(29);
  expect(precioPlantillaRappi({ precio: null }, 26)).toBe(26);
});

test("parsea la hoja Productos por encabezados", () => {
  const aoa = [
    ["Actualización de productos"],
    ["solo azul"],
    ["ID", "SKU", "EAN", "Precio", "Descuento", "Disponibilidad"],
    ["", "FARMACAPITALmt_eq-nov032", "7501075717150", 26, 0, "SI"],
  ];
  const filas = parseFilasProductosRappi(aoa);
  expect(filas).toHaveLength(1);
  expect(filas[0].excelRow).toBe(4);
  expect(filas[0].sku).toBe("FARMACAPITALmt_eq-nov032");
});

test("rellena Precio y SI/NO de Lizovag en el xlsx oficial", () => {
  const buf = fs.readFileSync(plantillaPath);
  const filas = filasDesdeBufferPlantillaRappi(buf);
  expect(filas.length).toBe(68);
  expect(filas[0].sku).toBe("FARMACAPITALmt_eq-nov032");
  const parches = parchesPlantillaRappi(filas, [lizovag], 2);
  expect(parches[0]).toMatchObject({
    excelRow: 6,
    matched: true,
    precio: 29,
    disponibilidad: "SI",
  });
  const sinStock = parchesPlantillaRappi(filas, [{ ...lizovag, stock: 1 }], 2);
  expect(sinStock[0].disponibilidad).toBe("NO");
  const out = rellenarBufferPlantillaRappi(buf, parches);
  const wb = XLSX.read(out, { type: "array" });
  const ws = wb.Sheets.Productos;
  expect(ws.K6.v).toBe(29);
  expect(ws.M6.v).toBe("SI");
  const res = resumenParchesRappi(parches);
  expect(res.filas).toBe(68);
  expect(res.matched).toBe(1);
});

test("sin match no apaga el SI que ya trae Partner", () => {
  const filas = [{
    excelRow: 6,
    sku: "FARMACAPITALmt_desconocido",
    ean: "0000000000000",
    precio: 40,
    disponibilidad: "SI",
  }];
  const [p] = parchesPlantillaRappi(filas, [lizovag], 2);
  expect(p.matched).toBe(false);
  expect(p.disponibilidad).toBe("SI");
  expect(p.precio).toBe(40);
});

test("nombre de archivo usa la fecha", () => {
  expect(nombreArchivoPlantillaRappi(new Date("2026-08-30T20:00:00Z")))
    .toBe("ProductosActualizacion-FarmaCapital-2026-08-30.xlsx");
});
