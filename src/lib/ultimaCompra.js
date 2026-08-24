/** Última compra real (ticket Recibir), distinta de la lista del proveedor. */

export const FUENTE_ULTIMA_COMPRA = "ultima_compra";

export function normalizeProveedorCompra(nombre) {
  const n = String(nombre || "").trim();
  if (!n) return "";
  if (/cityfarma|farma\s*city/i.test(n)) return "Farma City";
  if (/farmalive|farmalife/i.test(n)) return "Farmalive";
  if (/^levic\b/i.test(n)) return "Levic";
  if (/exprezo|zorro/i.test(n)) return "Exprezo";
  if (/equilibrio/i.test(n)) return "Equilibrio";
  if (/surtidor/i.test(n)) return "El Surtidor";
  if (/bodega|f-?42/i.test(n)) return "Bodega F-42";
  if (/\bifc\b/i.test(n)) return "IFC";
  if (/farma\s*mx|farmamx/i.test(n)) return "Farma MX";
  if (/nadro/i.test(n)) return "Nadro";
  if (/marzam/i.test(n)) return "Marzam";
  if (/scorpion/i.test(n)) return "Scorpion";
  return n;
}

export function parseCostoTicket(val) {
  const n = parseFloat(val);
  return Number.isFinite(n) && n > 0 ? n : null;
}

export function ultimaCompraDe(producto, refsMap) {
  const ref = refsMap?.ultima_compra;
  const precioRef = parseCostoTicket(ref?.precio);
  if (precioRef) {
    return {
      precio: precioRef,
      proveedor: normalizeProveedorCompra(ref.nombre_fuente) || "Ticket",
      fecha: ref.fecha || null,
      origen: "ticket",
    };
  }
  const ultimo = parseCostoTicket(producto?.ultimo_costo);
  if (ultimo) {
    return {
      precio: ultimo,
      proveedor: normalizeProveedorCompra(producto.ultimo_proveedor) || "Ticket",
      fecha: producto.ultima_compra_en || null,
      origen: "ticket",
    };
  }
  const costo = parseCostoTicket(producto?.costo);
  if (costo) {
    return {
      precio: costo,
      proveedor: "",
      fecha: null,
      origen: "catalogo",
    };
  }
  return null;
}

export function costoComparacionDe(producto, refsMap) {
  return ultimaCompraDe(producto, refsMap)?.precio ?? null;
}

export function filasUltimaCompraDesdeRecepcion(rec) {
  const proveedor = normalizeProveedorCompra(rec?.proveedor) || String(rec?.proveedor || "").trim();
  const fecha = rec?.fecha || new Date().toISOString().slice(0, 10);
  const folio = rec?.folio ? String(rec.folio) : "";
  const byProd = new Map();
  for (const item of rec?.items || []) {
    if (!item?.confirmado || item.pendiente_alta) continue;
    const productoId = Number(item.producto_id);
    const precio = parseCostoTicket(item.costo_estimado ?? item.costo);
    if (!productoId || !precio) continue;
    byProd.set(productoId, {
      producto_id: productoId,
      fuente: FUENTE_ULTIMA_COMPRA,
      tipo: "compra",
      precio,
      fecha,
      nombre_fuente: proveedor,
      sku_externo: folio || null,
      confianza: 100,
      origen: "manual",
      notas: folio ? `ticket ${folio}` : "recepcion",
    });
  }
  return [...byProd.values()];
}

export async function persistirUltimaCompra(supabase, filas) {
  if (!filas?.length) return 0;
  const { error } = await supabase.from("producto_precios_referencia").insert(filas);
  if (error) throw error;
  return filas.length;
}
