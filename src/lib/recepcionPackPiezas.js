/**
 * Packs de sobres / tiras / exhibidores de dulces que se venden por pieza.
 * Al cargar un ticket ("Pack 48 sobres…", "ORBIT 4P FRESA, 24/40PZ", qty 1,
 * costo del pack) se expanden a N piezas con costo unitario = pack / N.
 *
 * Sobres/sachets/tiras de higiene y mayoreo dulces N/MPZ.
 * No C/N de medicamentos.
 */

/** Piezas por empaque según el nombre del ticket/proveedor. */
export function piezasPorEmpaqueDesdeNombre(nombre) {
  const n = String(nombre || "");
  if (!n.trim()) return null;

  const packSobre = n.match(
    /\b(?:pack|tira|exhibidor|display|caja)\b[\s\S]{0,24}?\b(\d{1,3})\s*(?:sobres?|sachets?|pzas?|piezas?)?\b/i,
  );
  if (packSobre) {
    const p = parseInt(packSobre[1], 10);
    if (p >= 2 && p <= 200) return p;
  }

  const nSobres = n.match(/\b(\d{1,3})\s*(?:sobres?|sachets?)\b/i);
  if (nSobres) {
    const p = parseInt(nSobres[1], 10);
    if (p >= 2 && p <= 200) return p;
  }

  // Mayoreo dulces Central de Abasto: "ORBIT 4P FRESA, 24/40PZ",
  // "CLORETS 4 S PLUS 24/40PZ", "HALLS YERBA 30/12PZ".
  // El 2.º número es el exhibidor/cuadreta que se compra (piezas a vender).
  // Skittles "24/10PZ" es caja de 24 bolsas → usa el 1.º.
  const mayoreo = n.match(/\b(\d{1,3})\s*\/\s*(\d{1,3})\s*pz(?:as?)?\b/i);
  if (mayoreo) {
    const caja = parseInt(mayoreo[1], 10);
    const exhibidor = parseInt(mayoreo[2], 10);
    if (/skittles/i.test(n) && caja >= 2 && caja <= 200) return caja;
    if (exhibidor >= 2 && exhibidor <= 200) return exhibidor;
  }

  return null;
}

/**
 * @param {{ nombre?: string, cantidad?: number, costo?: number|null }} row
 * @returns {{ cantidad: number, costo: number|null, piezas_por_empaque: number|null, expandido: boolean }}
 */
export function expandirPackAPiezas(row) {
  const nombre = row?.nombre || "";
  const piezas = piezasPorEmpaqueDesdeNombre(nombre);
  const qtyIn = Number(row?.cantidad);
  const qty = Number.isFinite(qtyIn) && qtyIn > 0 ? qtyIn : 1;
  const costoIn = row?.costo != null ? Number(row.costo) : null;
  const costoOk = Number.isFinite(costoIn) && costoIn > 0 ? costoIn : null;

  if (!piezas) {
    return {
      cantidad: qty,
      costo: costoOk,
      piezas_por_empaque: null,
      expandido: false,
    };
  }

  // qty = packs en el ticket → piezas totales; costo de línea suele ser por pack.
  return {
    cantidad: piezas * qty,
    costo: costoOk != null ? Math.round((costoOk / piezas) * 10000) / 10000 : null,
    piezas_por_empaque: piezas,
    expandido: true,
  };
}

function norm(s) {
  return String(s || "")
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[^a-z0-9]+/g, " ")
    .trim();
}

/**
 * Si el renglón viene sin EAN (pack en PDF), intenta colgar el codigo_barras
 * del producto de pieza usando alias en descripción o tokens de marca/línea.
 */
export function enriquecerRenglonPackConCatalogo(renglon, productos) {
  if (!renglon) return renglon;
  const codigo = String(renglon.codigo || renglon.codigo_barras || "").replace(/\D/g, "");
  if (codigo.length >= 8) return renglon;

  const lista = Array.isArray(productos) ? productos : [];
  if (!lista.length) return renglon;

  const nom = norm(renglon.nombre);
  if (!nom) return renglon;

  const porAlias = lista.find((p) => {
    const desc = norm(p?.descripcion);
    if (!desc) return false;
    if (nom.length >= 12 && desc.includes(nom)) return true;
    if (nom.length >= 20 && desc.includes(nom.slice(0, 28))) return true;
    return false;
  });

  const hit =
    porAlias ||
    lista.find((p) => {
      const pn = norm(p?.nombre);
      if (!pn) return false;
      if (nom.includes("optims") && pn.includes("optims")) return true;
      if (nom.includes("head") && nom.includes("shoulders") && pn.includes("head") && pn.includes("shoulders")) {
        return true;
      }
      return false;
    });

  if (!hit) return renglon;
  const ean = String(hit.codigo_barras || "").replace(/\D/g, "");
  if (ean.length < 8) return renglon;

  return {
    ...renglon,
    codigo: ean,
    sku: renglon.sku || hit.sku || null,
  };
}

/** Expande qty/costo y opcionalmente pone EAN del catálogo. */
export function prepararRenglonesPackAPiezas(renglones, productos = []) {
  return (Array.isArray(renglones) ? renglones : []).map((r) => {
    const ex = expandirPackAPiezas(r);
    const base = {
      ...r,
      cantidad: ex.cantidad,
      costo: ex.costo,
      ...(ex.expandido ? { piezas_por_empaque: ex.piezas_por_empaque } : {}),
    };
    return enriquecerRenglonPackConCatalogo(base, productos);
  });
}
