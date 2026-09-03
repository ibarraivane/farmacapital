/**
 * Ficha de catálogo a partir de la página del proveedor.
 * El ticket trae códigos (BLOQ ANTHE UVAIR…). El nombre de mostrador,
 * marca, presentación y rubro salen del PDP / meta del distribuidor.
 */

"use strict";

const MARCAS_CASA_NADRO = new Set([
  "frabel",
  "frabel 2",
  "frabel2",
  "lgen",
  "nadro",
  "genericos",
  "genérico",
  "generico",
]);

const MARCAS_TITULO = [
  ["la roche-posay", "La Roche-Posay"],
  ["la roche posay", "La Roche-Posay"],
  ["larocheposay", "La Roche-Posay"],
  ["cerave", "CeraVe"],
  ["eucerin", "Eucerin"],
  ["nivea", "Nivea"],
  ["vichy", "Vichy"],
  ["isdin", "Isdin"],
  ["avene", "Avène"],
  ["avène", "Avène"],
];

function norm(s) {
  return String(s || "")
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/\s+/g, " ")
    .trim();
}

function primerValor(v) {
  if (Array.isArray(v)) return v[0] != null ? String(v[0]).trim() : "";
  if (v == null) return "";
  return String(v).trim();
}

/** Nombre de ticket / SKU interno: no se usa como nombre de mostrador. */
function esNombreTicketProveedor(nombre) {
  const n = String(nombre || "").trim();
  if (!n) return true;
  if (/\b(BLOQ|ANTHE|UVAIR|UVMUNE|JBN|TCO|CRA CORP|POM LAB|SH ACOND)\b/i.test(n)) return true;
  const letters = n.replace(/[^A-Za-zÁÉÍÓÚáéíóúÑñ]/g, "");
  if (letters.length >= 8) {
    const upper = letters.replace(/[^A-ZÁÉÍÓÚÑ]/g, "").length;
    if (upper / letters.length >= 0.85 && /\s/.test(n)) return true;
  }
  return false;
}

function tituloDesdeMeta(meta) {
  const parts = String(meta || "")
    .split(" - ")
    .map((s) => s.trim())
    .filter(Boolean);
  const kept = [];
  for (const p of parts) {
    const digits = p.replace(/\D/g, "");
    if (digits.length >= 8 && digits === p.replace(/\s/g, "").replace(/-/g, "")) break;
    if (/^\d{8,14}$/.test(digits) && digits.length === p.replace(/\s/g, "").length) break;
    if (/^(Cuidado Personal|Medicamentos|Solares|Bloqueadores|belleza)\b/i.test(p)) break;
    kept.push(p);
  }
  return kept[0] || "";
}

function marcaDesdeTexto(...textos) {
  const blob = norm(textos.filter(Boolean).join(" "));
  for (const [needle, marca] of MARCAS_TITULO) {
    if (blob.includes(needle)) return marca;
  }
  return null;
}

function presentacionDesdeNombre(nombre) {
  const m = String(nombre || "").match(/(\d+(?:[.,]\d+)?)\s*(ml|mL|ML|g|G|mg|l|L|tab|tabs|caps)\b/);
  if (!m) return null;
  const unit = m[2].toLowerCase();
  return `${m[1].replace(",", ".")} ${unit}`;
}

function rubrosDesdeCategorias(categories) {
  const paths = (categories || []).map((c) => norm(c));
  const blob = paths.join(" ");
  if (/solar|bloqueador/.test(blob)) {
    return { categoria: "Cuidado personal", subcategoria: "Protector solar" };
  }
  if (/cuidado personal|belleza|dermocosmet/.test(blob)) {
    return { categoria: "Cuidado personal", subcategoria: null };
  }
  if (/medicament/.test(blob)) {
    return { categoria: "Medicamentos", subcategoria: null };
  }
  return { categoria: null, subcategoria: null };
}

function formaDesdeFicha({ nombre, nombreTicket, categorias }) {
  const blob = norm([nombre, nombreTicket, (categorias || []).join(" ")].join(" "));
  if (/\bflu\b|fluido/.test(blob)) return "Fluido";
  if (/\bgel\b/.test(blob)) return "Gel";
  if (/crema|\bcra\b/.test(blob)) return "Crema";
  if (/spray|bruma/.test(blob)) return "Spray";
  if (blob.includes("bloqueador") || blob.includes("solar")) return "Protector solar";
  return null;
}

/**
 * @param {object} hit  salida de extraerProductoNadro (o el JSON crudo de iNadro)
 * @returns {{ nombre, marca, presentacion, categoria, subcategoria, forma_farmaceutica, descripcion, imagen_url, nombre_ticket }}
 */
function fichaCatalogoDesdeNadro(hit) {
  if (!hit || typeof hit !== "object") return null;
  const nombreTicket = String(hit.nombre || hit.productName || hit.productTitle || "").trim();
  const meta = primerValor(hit.metaTagDescription);
  const tituloMeta = tituloDesdeMeta(meta);
  const desc = primerValor(hit.description || hit.descripcion);
  const categorias = hit.categories || hit.categorias || [];
  const linkText = String(hit.linkText || "").trim();

  let nombre = tituloMeta;
  if (!nombre && !esNombreTicketProveedor(nombreTicket)) nombre = nombreTicket;
  if (!nombre && linkText) {
    nombre = linkText
      .replace(/[-_]+/g, " ")
      .replace(/\bml\b/i, "ml")
      .trim();
  }
  if (!nombre) nombre = nombreTicket;

  const marcaTicket = String(hit.marca || hit.brand || "").trim();
  const marcaReal = marcaDesdeTexto(tituloMeta, meta, linkText, nombre, desc);
  const marcaCasa = MARCAS_CASA_NADRO.has(norm(marcaTicket));
  const marca = marcaReal || (!marcaCasa && marcaTicket ? marcaTicket : null);

  const rubros = rubrosDesdeCategorias(categorias);
  const presentacion = presentacionDesdeNombre(nombre) || presentacionDesdeNombre(nombreTicket);
  const imagenes = hit.imagenes || [];

  return {
    nombre,
    marca,
    presentacion,
    categoria: rubros.categoria,
    subcategoria: rubros.subcategoria,
    forma_farmaceutica: formaDesdeFicha({ nombre, nombreTicket, categorias }),
    descripcion: desc || null,
    imagen_url: imagenes[0] || null,
    nombre_ticket: nombreTicket || null,
    precio_publico: hit.precioPublico != null ? hit.precioPublico : null,
  };
}

function fichaListaParaAlta(ficha) {
  if (!ficha || !ficha.nombre) return false;
  if (esNombreTicketProveedor(ficha.nombre)) return false;
  if (!ficha.marca) return false;
  return true;
}

module.exports = {
  esNombreTicketProveedor,
  tituloDesdeMeta,
  marcaDesdeTexto,
  fichaCatalogoDesdeNadro,
  fichaListaParaAlta,
};
