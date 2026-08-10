/**
 * Etiqueta legible para productos con nombres abreviados de ticket (Bodega, etc.).
 * Si BD ya tiene marca/presentacion, los usa; si no, infiere lo básico del nombre.
 */

const BRAND_ALIASES = {
  LIST: "Listerine",
  PANT: "Pantene",
  PANTENE: "Pantene",
  NIVEA: "Nivea",
  MENNEN: "Mennen",
  PALMOL: "Palmolive",
};

const PREFIX_FORMA = [
  [/^Enj\s+Buc\b/i, "Enjuague bucal"],
  [/^Cep\s+Dent\b/i, "Cepillo dental"],
  [/^Cra\b/i, "Crema"],
  [/^Jbn\b/i, "Jabón"],
  [/^Desod\b/i, "Desodorante"],
  [/^Tco\b/i, "Talco"],
  [/^Enj Buc\b/i, "Enjuague bucal"],
  [/^Ac\b/i, "Acondicionador"],
  [/^Sh\b/i, "Shampoo"],
  [/^Tas\s+Hum\b/i, "Toallas húmedas"],
  [/^Protec\b/i, "Curación"],
];

export function etiquetaProductoInventario(p) {
  if (!p) return "";
  const forma = (p.forma_farmaceutica || "").trim();
  const marca = (p.marca || "").trim();
  const pres = (p.presentacion || "").trim();
  const nombre = (p.nombre || "").trim();

  if (forma || marca || pres) {
    const partes = [forma, marca, nombre].filter(Boolean);
    const base = partes.join(" · ");
    return pres ? `${base} (${pres})` : base;
  }

  let raw = nombre;
  let inferredForma = "";
  for (const [re, label] of PREFIX_FORMA) {
    if (re.test(raw)) {
      inferredForma = label;
      raw = raw.replace(re, "").trim();
      break;
    }
  }
  const tokens = raw.split(/\s+/);
  let inferredMarca = "";
  if (tokens[0]) {
    const key = tokens[0].toUpperCase();
    if (BRAND_ALIASES[key]) {
      inferredMarca = BRAND_ALIASES[key];
      tokens.shift();
    }
  }
  const resto = tokens.join(" ");
  const partes = [inferredForma, inferredMarca, resto].filter(Boolean);
  return partes.join(" · ") || nombre;
}

export function descripcionCortaProducto(p) {
  const e = etiquetaProductoInventario(p);
  return e || p?.nombre || "";
}
