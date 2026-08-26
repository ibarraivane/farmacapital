/**
 * Título y subtítulo legibles en POS (nombres de ticket siguen en BD).
 */

function titleCase(s) {
  return String(s || "")
    .trim()
    .split(/\s+/)
    .map((w) =>
      w
        .split("-")
        .map((p) => (p ? p.charAt(0).toUpperCase() + p.slice(1).toLowerCase() : ""))
        .join("-")
    )
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

const FORMA_EN_NOMBRE =
  /\s+(?:suspensi[oó]n|tabletas?|tabs?\.?|c[aá]psulas?|c[aá]ps\.?|jarabe|crema|gel|ung[uü]ento|pomada|soluci[oó]n|gotas|aerosol|spray|comprimidos?|ampolletas?|inyectable|frasco|sobres?|polvo|loci[oó]n|emulsi[oó]n|elixir|jalea|[oó]vulos?|supositorios?|parche|inhalador|grageas?)\b/i;

/** Nombre de mostrador: Alu-Mag, no el laboratorio ni la fórmula completa. */
export function nombreComercialPos(nombre) {
  const limpio = limpiarNombrePosCrudo(nombre);
  if (!limpio) return "";
  // "Leche en polvo" no es forma farmacéutica: no cortar en "polvo".
  const protegido = limpio.replace(/\ben\s+polvo\b/gi, "en_polvo");
  const corte = protegido.split(FORMA_EN_NOMBRE)[0].trim().replace(/en_polvo/gi, "en polvo");
  if (corte && corte !== limpio && corte.length >= 2 && corte.length <= 48) {
    return corte;
  }
  const palabras = limpio.split(/\s+/);
  const esLechePolvo = /\bleche\s+en\s+polvo\b/i.test(limpio);
  if (palabras.length > 6 || limpio.length > 56) {
    return palabras.slice(0, esLechePolvo ? 6 : 3).join(" ");
  }
  return limpio;
}

function mismaMarca(texto, marca) {
  const a = String(texto || "").trim().toLowerCase();
  const b = String(marca || "").trim().toLowerCase();
  return Boolean(a && b && a === b);
}

/** Título principal en ficha, resultados y carrito. */
export function posTituloProducto(p) {
  if (!p) return "";
  const marca = String(p.marca || "").trim();
  const pa = String(p.principio_activo || "").trim();
  const forma = String(p.forma_farmaceutica || "").trim();
  const limpio = limpiarNombrePosCrudo(p.nombre);
  const comercial = nombreComercialPos(p.nombre);

  const tipo = nombreTipoProducto(p.nombre) || nombreTipoProducto(limpio);
  if (tipo) return titleCase(tipo);

  if (comercial && !mismaMarca(comercial, marca)) {
    const cortoConMarca =
      marca &&
      !/gen[eé]rico/i.test(marca) &&
      limpio.toLowerCase().startsWith(marca.toLowerCase()) &&
      limpio.split(/\s+/).length <= 5 &&
      limpio.length <= 40;
    if (cortoConMarca) return titleCase(limpio);
    return titleCase(comercial);
  }

  if (pa && (p.tipo === "generico" || p.requiere_receta)) {
    return titleCase(pa);
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

function pareceSoloEmpaque(texto) {
  const s = String(texto || "").trim();
  if (!s) return true;
  return /^(c\/\s*\d+|c\d+|tabletas?|c[aá]psulas?|jarabe|crema|gel|suspensi[oó]n|soluci[oó]n|gotas|frasco|comprimidos?)$/i.test(s);
}

/**
 * Cómo lo piden en mostrador (XL-3, Antiflu-Des).
 * No usa el principio activo: en “otras presentaciones” todas lo comparten.
 */
export function posNombreReconocido(p) {
  if (!p) return "";
  const comercial = nombreComercialPos(p.nombre);
  const dist = String(p.denominacion_distintiva || "").trim();
  const marca = String(p.marca || "").trim();
  if (comercial && !pareceSoloEmpaque(comercial) && !mismaMarca(comercial, marca)) {
    return titleCase(comercial);
  }
  if (dist && !pareceSoloEmpaque(dist)) return titleCase(dist);
  if (marca && !/gen[eé]rico/i.test(marca)) return titleCase(marca);
  if (comercial && !pareceSoloEmpaque(comercial)) return titleCase(comercial);
  const limpio = limpiarNombrePosCrudo(p.nombre);
  if (limpio && !pareceSoloEmpaque(limpio)) return titleCase(limpio);
  return titleCase(marca || limpio || p.nombre || "");
}

/** Nombre + empaque para las fichas de “otras presentaciones”. */
export function posEtiquetaVariante(p) {
  const nombre = posNombreReconocido(p);
  const partes = [
    p?.presentacion,
    p?.concentracion,
    p?.forma_farmaceutica,
  ].map((x) => String(x || "").trim()).filter(Boolean);
  const detalle = partes
    .filter((parte) => parte.toLowerCase() !== nombre.toLowerCase())
    .join(" · ");
  return { nombre, detalle };
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

/** Caja azul de la tarjeta: activos, o presentación / distintiva si no hay fórmula. */
export function posDestacadoTarjeta(p) {
  if (!p) return "";
  const activos = String(p.principio_activo || p.denominacion_generica || "").trim();
  if (activos) {
    return `Activos: ${activos
      .replace(/\bcaolin\b/gi, "Caolín")
      .replace(/\bneomicina\b/gi, "Neomicina")
      .replace(/\bpectina\b/gi, "Pectina")}`;
  }
  const dist = String(p.denominacion_distintiva || "").trim();
  if (dist) return dist;
  const partes = [p.contenido, p.presentacion, p.concentracion].map((x) => String(x || "").trim()).filter(Boolean);
  return partes.length ? partes.join(" · ") : "";
}
