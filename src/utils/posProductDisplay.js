/**
 * Título y subtítulo legibles en POS (nombres de ticket siguen en BD).
 */

function titleCase(s) {
  return String(s || "")
    .trim()
    .split(/\s+/)
    .map((w) => (w ? w.charAt(0).toUpperCase() + w.slice(1).toLowerCase() : ""))
    .join(" ");
}

/** Quita medidas, empaques y ruido al inicio/final del nombre crudo. */
export function limpiarNombrePosCrudo(nombre) {
  let s = String(nombre || "").trim();
  if (!s) return "";

  s = s.replace(/^[\d]+(?:[.,]\d+)?\s*(?:cm|mm|ml|g|gr|lt|l)\b\s*/i, "");
  s = s.replace(/^[\d]+(?:[Cc][Mm])?[xX][\d.,]+(?:[Mm])?\s+/i, "");
  s = s.replace(/^Tocmx[\d.,]+[Mm]?\s+/i, "");
  s = s.replace(/\s+(?:C\/\d+|C\d+)\s*(?:Pz|Pza|Pack)?\.?\s*$/i, "");
  s = s.replace(/\s+\d+\s*(?:CM|ML|G|GR|LT|L|PZA|PZ|PACK)\b.*$/i, "");
  s = s.replace(/\s+\|\s+.*$/, "");
  s = s.replace(/\s+\d+[.,]\d{2}\s+.*$/, "");
  s = s.replace(/\s{2,}/g, " ").trim();

  return s;
}

function nombreTipoProducto(nombre) {
  const n = String(nombre || "").toLowerCase();
  if (/venda\s+(?:de\s+)?yeso|yeso\s+c\d+/i.test(n)) return "Venda de yeso";
  if (/tensolastic|venda\s+el[aá]st/i.test(n)) return "Venda elástica";
  if (/venda\b/i.test(n)) return "Venda";
  if (/gasa\b/i.test(n)) return "Gasa";
  if (/algod[oó]n/i.test(n)) return "Algodón";
  if (/toa\s*[- ]?\s*hum|toallitas?\s+h[uú]med/i.test(n)) return "Toallitas húmedas";
  if (/electrolit|pedialyte|suero\s+oral/i.test(n)) return null;
  if (/quita\s*esmalte/i.test(n)) return "Quitaesmalte";
  if (/lubricante/i.test(n)) return "Lubricante";
  if (/crema\s+dent|pasta\s+dent/i.test(n)) return "Crema dental";
  if (/jarabe/i.test(n)) return "Jarabe";
  if (/pastilla|past\b|mastic/i.test(n)) return "Pastilla";
  return null;
}

/** Título principal en ficha, resultados y carrito. */
export function posTituloProducto(p) {
  if (!p) return "";
  const marca = String(p.marca || "").trim();
  const pa = String(p.principio_activo || "").trim();
  const forma = String(p.forma_farmaceutica || "").trim();
  const limpio = limpiarNombrePosCrudo(p.nombre);

  const tipo = nombreTipoProducto(p.nombre) || nombreTipoProducto(limpio);
  if (tipo) return titleCase(tipo);

  if (pa && (p.tipo === "generico" || p.requiere_receta)) {
    return titleCase(pa);
  }

  if (marca && !/gen[eé]rico/i.test(marca)) {
    const resto = limpio.replace(new RegExp(`^${marca}\\b`, "i"), "").trim();
    if (!resto || resto.length < 4) return titleCase(marca);
    if (limpio.length > 48) return titleCase(marca);
  }

  if (forma && !/material de curaci[oó]n|producto|medicamento|otro/i.test(forma)) {
    if (marca && !/gen[eé]rico/i.test(marca)) return titleCase(`${marca} ${forma}`);
    return titleCase(forma);
  }

  if (limpio.split(/\s+/).length <= 6 && limpio.length <= 56) {
    return titleCase(limpio);
  }

  if (marca && !/gen[eé]rico/i.test(marca)) return titleCase(marca);
  return titleCase(limpio || p.nombre || "");
}

/** Segunda línea: marca, presentación, concentración, forma. */
export function posSubtituloProducto(p) {
  if (!p) return "";
  const titulo = posTituloProducto(p).toLowerCase();
  const partes = [];
  const marca = String(p.marca || "").trim();
  const pres = String(p.presentacion || "").trim();
  const conc = String(p.concentracion || "").trim();
  const forma = String(p.forma_farmaceutica || "").trim();

  if (marca && !/gen[eé]rico/i.test(marca) && !titulo.includes(marca.toLowerCase())) {
    partes.push(marca);
  }
  if (pres) partes.push(pres);
  if (conc) partes.push(conc);
  if (forma && !partes.some((x) => x.toLowerCase() === forma.toLowerCase())) {
    partes.push(forma);
  }
  if (partes.length) return partes.join(" · ");

  const limpio = limpiarNombrePosCrudo(p.nombre);
  if (limpio && limpio.toLowerCase() !== titulo) return titleCase(limpio);
  return p.sku ? `SKU ${p.sku}` : "";
}
