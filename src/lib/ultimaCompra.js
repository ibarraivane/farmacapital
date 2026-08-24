/** Costo vigente de compra: primera compra (quién + precio).
 *  Recibir solo lo reemplaza si el ticket nuevo es más barato.
 */

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

/** Solo se pisa el costo vigente si el nuevo es más barato (o no había ninguno). */
export function debeReemplazarCompra(precioActual, precioNuevo) {
  const nuevo = parseCostoTicket(precioNuevo);
  if (nuevo == null) return false;
  const actual = parseCostoTicket(precioActual);
  if (actual == null) return true;
  return nuevo < actual - 0.005;
}

/**
 * Primera compra, luego se queda con quien bajó el precio.
 * eventos: { precio, proveedor, fecha, id }
 */
export function elegirCompraVigente(eventos) {
  const ordenados = (eventos || [])
    .map((e, idx) => ({
      precio: parseCostoTicket(e.precio),
      proveedor: normalizeProveedorCompra(e.proveedor) || String(e.proveedor || "").trim(),
      fecha: e.fecha || "",
      id: e.id ?? idx,
    }))
    .filter((e) => e.precio != null)
    .sort((a, b) => {
      if (a.fecha !== b.fecha) return String(a.fecha).localeCompare(String(b.fecha));
      return (a.id || 0) - (b.id || 0);
    });
  if (!ordenados.length) return null;
  let vigente = ordenados[0];
  for (const ev of ordenados.slice(1)) {
    if (debeReemplazarCompra(vigente.precio, ev.precio)) vigente = ev;
  }
  return vigente;
}

export function compraVigenteDe(producto, refsMap) {
  const ref = refsMap?.ultima_compra;
  const precioRef = parseCostoTicket(ref?.precio);
  if (precioRef) {
    return {
      precio: precioRef,
      proveedor: normalizeProveedorCompra(ref.nombre_fuente)
        || normalizeProveedorCompra(producto?.proveedor)
        || "",
      fecha: ref.fecha || null,
      origen: "compra",
    };
  }
  const costo = parseCostoTicket(producto?.costo);
  if (costo) {
    return {
      precio: costo,
      proveedor: normalizeProveedorCompra(producto?.proveedor) || "",
      fecha: null,
      origen: "catalogo",
    };
  }
  return null;
}

export function costoComparacionDe(producto, refsMap) {
  return compraVigenteDe(producto, refsMap)?.precio ?? null;
}

export function filasCompraVigenteDesdeRecepcion(rec, actualesPorProducto = {}) {
  const proveedor = normalizeProveedorCompra(rec?.proveedor) || String(rec?.proveedor || "").trim();
  // La vista actual es DISTINCT ON fecha DESC: hay que estampar hoy para que el más barato se vea.
  const fecha = new Date().toISOString().slice(0, 10);
  const fechaTicket = rec?.fecha || fecha;
  const folio = rec?.folio ? String(rec.folio) : "";
  const byProd = new Map();
  for (const item of rec?.items || []) {
    if (!item?.confirmado || item.pendiente_alta) continue;
    const productoId = Number(item.producto_id);
    const precio = parseCostoTicket(item.costo_estimado ?? item.costo);
    if (!productoId || !precio) continue;
    const actual = actualesPorProducto[productoId];
    if (!debeReemplazarCompra(actual, precio)) continue;
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
      notas: folio ? `ticket ${folio} ${fechaTicket}` : `recepcion ${fechaTicket}`,
    });
  }
  return [...byProd.values()];
}

/** @deprecated usar filasCompraVigenteDesdeRecepcion */
export function filasUltimaCompraDesdeRecepcion(rec, actuales) {
  return filasCompraVigenteDesdeRecepcion(rec, actuales);
}

export async function persistirUltimaCompra(supabase, filas) {
  if (!filas?.length) return 0;
  const { error } = await supabase.from("producto_precios_referencia").insert(filas);
  if (error) throw error;
  return filas.length;
}
