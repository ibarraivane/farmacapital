/**
 * Exporta pedidos de reabasto.
 * Levic: misma plantilla del portal (código de barras + piezas).
 * El resto: hoja usable para surtir a mano / WhatsApp / futuro portal.
 */

import * as XLSX from "xlsx";

const esLevic = (orden) =>
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

function hojaGenerica(orden) {
  return [
    ["Pedir en", orden.proveedor],
    ["Fecha", orden.fecha],
    ["Líneas", orden.productos.length],
    ["Total estimado", Number(orden.total.toFixed(2))],
    [],
    ["Código de barras", "SKU", "Producto", "Piezas", "Costo unit.", "Total", "Nota"],
    ...orden.productos.map((p) => [
      barcodeDe(p) || "",
      p.sku || "",
      p.nombre || "",
      p.cantidadPedida,
      Number((p.precioUnit ?? p.mejorCompra?.precio ?? p.costo ?? 0).toFixed(2)),
      Number(((p.precioUnit ?? p.mejorCompra?.precio ?? p.costo ?? 0) * p.cantidadPedida).toFixed(2)),
      p.motivoAgrupado || "",
    ]),
  ];
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

function nombreHoja(label, usados) {
  let base = String(label || "Pedido").replace(/[:\\/?*[\]]/g, "").slice(0, 28) || "Pedido";
  let name = base;
  let n = 2;
  while (usados.has(name)) {
    name = `${base.slice(0, 26)}_${n++}`;
  }
  usados.add(name);
  return name;
}

/** Un xlsx: Resumen + una hoja por tienda + Levic_portal si aplica. */
export function descargarPedidosWorkbook(ordenes) {
  const wb = XLSX.utils.book_new();
  const usados = new Set();

  const resumen = [
    ["Tienda", "Líneas", "Total estimado", "Ahorro vs tu costo", "Formato"],
    ...ordenes.map((o) => [
      o.proveedor,
      o.productos.length,
      Number(o.total.toFixed(2)),
      Number((o.ahorroVsHabitual || 0).toFixed(2)),
      esLevic(o)
        ? "Cargar Pedido_Levic_portal.xlsx en el portal — llega mañana"
        : "Lista FarmaCapital",
    ]),
  ];
  XLSX.utils.book_append_sheet(wb, XLSX.utils.aoa_to_sheet(resumen), "Resumen");

  for (const orden of ordenes) {
    const ws = XLSX.utils.aoa_to_sheet(hojaGenerica(orden));
    ws["!cols"] = [{ wch: 16 }, { wch: 14 }, { wch: 42 }, { wch: 8 }, { wch: 12 }, { wch: 12 }, { wch: 40 }];
    XLSX.utils.book_append_sheet(wb, ws, nombreHoja(orden.proveedor, usados));

    if (esLevic(orden)) {
      const { aoa, sinCodigo } = hojaPlantillaLevic(orden.productos);
      const lev = XLSX.utils.aoa_to_sheet(aoa);
      lev["!cols"] = [{ wch: 22 }, { wch: 14 }];
      XLSX.utils.book_append_sheet(wb, lev, nombreHoja("Levic_portal", usados));
      if (sinCodigo.length) {
        const rev = XLSX.utils.aoa_to_sheet([
          ["Estos no tienen código de barras — Levic no los puede cargar en el portal"],
          ["SKU", "Producto", "Piezas"],
          ...sinCodigo.map((p) => [p.sku || "", p.nombre || "", p.cantidadPedida]),
        ]);
        XLSX.utils.book_append_sheet(wb, rev, nombreHoja("Levic_sin_codigo", usados));
      }
    }
  }

  descargarLibro(wb, `Pedidos_FarmaCapital_${fechaArchivo()}.xlsx`);

  // El portal de Levic pide UN archivo = su plantilla (2 columnas). No se le sube el libro grande.
  const levic = ordenes.find(esLevic);
  if (levic) descargarPlantillaPortalLevic(levic);
}

/** Archivo que se sube al portal Levic: solo 2 columnas, como su plantilla. Entrega al día siguiente. */
export function descargarPlantillaPortalLevic(orden) {
  const { aoa } = hojaPlantillaLevic(orden.productos);
  const wb = XLSX.utils.book_new();
  const ws = XLSX.utils.aoa_to_sheet(aoa);
  ws["!cols"] = [{ wch: 22 }, { wch: 14 }];
  XLSX.utils.book_append_sheet(wb, ws, "Hoja1");
  descargarLibro(wb, `Pedido_Levic_portal_${fechaArchivo()}.xlsx`);
}

/** Solo la plantilla de una tienda (Levic = archivo del portal; otras = lista). */
export function descargarPedidoTienda(orden) {
  if (esLevic(orden)) {
    descargarPlantillaPortalLevic(orden);
    return;
  }
  const wb = XLSX.utils.book_new();
  const ws = XLSX.utils.aoa_to_sheet(hojaGenerica(orden));
  ws["!cols"] = [{ wch: 16 }, { wch: 14 }, { wch: 42 }, { wch: 8 }, { wch: 12 }, { wch: 12 }, { wch: 40 }];
  XLSX.utils.book_append_sheet(wb, ws, "Pedido");
  const slug = String(orden.proveedor || "tienda").replace(/\s+/g, "_").slice(0, 24);
  descargarLibro(wb, `Pedido_${slug}_${fechaArchivo()}.xlsx`);
}
