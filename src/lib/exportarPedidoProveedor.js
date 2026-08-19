/**
 * Exporta el resurtido en dos archivos:
 * 1. Pedido_Levic_portal — plantilla del portal (código de barras + piezas). Ese se sube.
 * 2. Pedido_otras_tiendas — todo lo que no va a Levic (Exprezo, Scorpion, etc.).
 */

import * as XLSX from "xlsx";

export const esLevic = (orden) =>
  String(orden.fuente || "").toLowerCase() === "levic" ||
  /levic/i.test(orden.proveedor || "");

function fechaArchivo() {
  const d = new Date();
  const pad = (n) => String(n).padStart(2, "0");
  return `${d.getFullYear()}${pad(d.getMonth() + 1)}${pad(d.getDate())}`;
}

function barcodeDe(p) {
  const raw = String(p.codigo_barras || p.barcode || "").replace(/\D/g, "");
  return raw || "";
}

function precioDe(p) {
  return Number(p.precioUnit ?? p.mejorCompra?.precio ?? p.mejorTienda?.precio ?? p.costo ?? 0);
}

/** Hoja idéntica a /Downloads/plantilla_pedido.xlsx de Levic. */
export function hojaPlantillaLevic(productos) {
  const aoa = [
    [null, "FORMATO DE PEDIDO"],
    ["CÓDIGO DE BARRAS", "No DE PIEZAS"],
  ];
  const sinCodigo = [];
  for (const p of productos) {
    const ean = barcodeDe(p);
    if (!ean) {
      sinCodigo.push(p);
      continue;
    }
    aoa.push([ean, p.cantidadPedida]);
  }
  return { aoa, sinCodigo };
}

function descargarLibro(wb, nombre) {
  const out = XLSX.write(wb, { bookType: "xlsx", type: "array" });
  const blob = new Blob([out], {
    type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
  });
  const a = document.createElement("a");
  a.href = URL.createObjectURL(blob);
  a.download = nombre;
  a.click();
  URL.revokeObjectURL(a.href);
}

function bajarConPausa(fn, ms) {
  return new Promise((resolve) => {
    fn();
    setTimeout(resolve, ms);
  });
}

/** Archivo 1: el que se sube a levicventas.mx. Solo 2 columnas. */
export function descargarPlantillaPortalLevic(orden) {
  const { aoa } = hojaPlantillaLevic(orden.productos);
  const wb = XLSX.utils.book_new();
  const ws = XLSX.utils.aoa_to_sheet(aoa);
  ws["!cols"] = [{ wch: 22 }, { wch: 14 }];
  XLSX.utils.book_append_sheet(wb, ws, "Hoja1");
  descargarLibro(wb, `Pedido_Levic_portal_${fechaArchivo()}.xlsx`);
  return hojaPlantillaLevic(orden.productos).sinCodigo;
}

function descargarOtrasTiendas(ordenes, levicSinCodigo) {
  const filas = [];
  for (const orden of ordenes) {
    for (const p of orden.productos) {
      const unit = precioDe(p);
      filas.push([
        orden.proveedor,
        barcodeDe(p) || "",
        p.sku || "",
        p.nombre || "",
        p.cantidadPedida,
        Number(unit.toFixed(2)),
        Number((unit * p.cantidadPedida).toFixed(2)),
        p.motivoAgrupado || "",
      ]);
    }
  }
  for (const p of levicSinCodigo || []) {
    const unit = precioDe(p);
    filas.push([
      "Levic (falta código)",
      "",
      p.sku || "",
      p.nombre || "",
      p.cantidadPedida,
      Number(unit.toFixed(2)),
      Number((unit * p.cantidadPedida).toFixed(2)),
      "No entra al portal de Levic: no tiene código de barras",
    ]);
  }
  if (!filas.length) return false;

  const porTienda = {};
  for (const row of filas) {
    porTienda[row[0]] = (porTienda[row[0]] || 0) + 1;
  }

  const wb = XLSX.utils.book_new();
  const resumen = [
    ["Este archivo NO se sube a Levic. Levic va en Pedido_Levic_portal.xlsx"],
    [],
    ["Pedir en", "Líneas"],
    ...Object.entries(porTienda).map(([tienda, n]) => [tienda, n]),
  ];
  XLSX.utils.book_append_sheet(wb, XLSX.utils.aoa_to_sheet(resumen), "Resumen");

  const pedido = [
    ["Pedir en", "Código de barras", "SKU", "Producto", "Piezas", "Costo unit.", "Total", "Nota"],
    ...filas,
  ];
  const ws = XLSX.utils.aoa_to_sheet(pedido);
  ws["!cols"] = [
    { wch: 22 }, { wch: 16 }, { wch: 14 }, { wch: 42 },
    { wch: 8 }, { wch: 12 }, { wch: 12 }, { wch: 40 },
  ];
  XLSX.utils.book_append_sheet(wb, ws, "Pedido");
  descargarLibro(wb, `Pedido_otras_tiendas_${fechaArchivo()}.xlsx`);
  return true;
}

/**
 * Baja como máximo 2 archivos:
 * - Pedido_Levic_portal_…xlsx  → se sube al portal
 * - Pedido_otras_tiendas_…xlsx → Exprezo, Scorpion y lo demás
 */
export async function descargarPedidosWorkbook(ordenes) {
  const levic = (ordenes || []).find(esLevic);
  const resto = (ordenes || []).filter((o) => !esLevic(o));
  let levicSin = [];

  if (levic && levic.productos?.length) {
    const { aoa, sinCodigo } = hojaPlantillaLevic(levic.productos);
    levicSin = sinCodigo;
    if (aoa.length > 2) {
      const wb = XLSX.utils.book_new();
      const ws = XLSX.utils.aoa_to_sheet(aoa);
      ws["!cols"] = [{ wch: 22 }, { wch: 14 }];
      XLSX.utils.book_append_sheet(wb, ws, "Hoja1");
      await bajarConPausa(
        () => descargarLibro(wb, `Pedido_Levic_portal_${fechaArchivo()}.xlsx`),
        400
      );
    }
  }

  descargarOtrasTiendas(resto, levicSin);
}

/** Un solo archivo: Levic = portal; el resto = lista con columna «Pedir en». */
export function descargarPedidoTienda(orden) {
  if (esLevic(orden)) {
    descargarPlantillaPortalLevic(orden);
    return;
  }
  descargarOtrasTiendas([orden], []);
}
