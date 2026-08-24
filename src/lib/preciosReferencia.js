/**
 * Lógica compartida — pestaña Referencias de precio (Inventario).
 * Espejo simplificado de scripts/pricing_preview.py (classify + piso de margen).
 */

/** Columnas visibles en la tabla Compra (no inflar con fuentes de pocos matches). */
export const FUENTES_COMPRA_TABLA = ["exprezo", "marzam", "nadro", "levic", "farmalive", "otros_compra"];
/** Entran a «Comprar en» / mejor precio, sin columna propia. */
export const FUENTES_COMPRA_EXTRA = ["scorpion", "abarrotero", "mayoreototal"];
export const FUENTES_COMPRA = [...FUENTES_COMPRA_TABLA, ...FUENTES_COMPRA_EXTRA];
export const FUENTES_VENTA = ["fahorro", "similares", "otros_venta"];

/** Fila tombstone al borrar una referencia manualmente (precio NOT NULL en BD). */
export const REFERENCIA_ANULADA_NOTA = "__anulado__";

export function esReferenciaAnulada(row) {
  return row?.notas === REFERENCIA_ANULADA_NOTA;
}

export function esReferenciaVigente(row) {
  if (!row || esReferenciaAnulada(row)) return false;
  const precio = parseFloat(row.precio);
  return Number.isFinite(precio) && precio > 0;
}

function normTextoProducto(s) {
  return String(s || "")
    .toLowerCase()
    .normalize("NFD")
    .replace(/\p{M}/gu, "")
    .replace(/\s+/g, " ")
    .trim();
}

/** ¿Parece medicamento (no abarrotes/superficie)? */
export function esMedicamentoReferencia(p) {
  const pa = (p?.principio_activo || "").trim();
  if (pa) return true;
  const tipo = (p?.tipo || "").toLowerCase();
  if (tipo === "generico" || tipo === "genérico" || tipo === "marca") return true;
  if ((p?.forma_farmaceutica || "").trim()) return true;
  const cat = (p?.categoria || "").toLowerCase();
  return /medic|fármaco|farmaco|antib|analge|vitamin|suplement|dermat|oftalm|gastro|cardio|diabetes|pedic/.test(cat);
}

/** El nombre comercial ya es (o contiene) el principio activo — no duplicar. */
export function nombreCoincideConPrincipioActivo(nombre, principioActivo) {
  const nom = normTextoProducto(nombre);
  const pa = normTextoProducto(principioActivo);
  if (!nom || !pa) return false;
  if (nom === pa) return true;
  if (nom.length >= 5 && pa.length >= 5 && (nom.includes(pa) || pa.includes(nom))) return true;

  const paTokens = pa.split(" ").filter((t) => t.length >= 4);
  if (paTokens.length && paTokens.every((t) => nom.includes(t))) return true;

  const nomTokens = nom.split(" ").filter((t) => t.length >= 4);
  if (nomTokens.length === 1 && paTokens.length === 1 && nomTokens[0] === paTokens[0]) return true;

  return false;
}

/**
 * Subtítulo bajo el nombre en tablas Compra/Venta.
 * Muestra PA cuando el nombre comercial no es el principio activo.
 */
export function productoSubtituloReferencia(p) {
  const pa = (p?.principio_activo || "").trim();
  const detParts = [];
  if (p?.concentracion?.trim()) detParts.push(p.concentracion.trim());
  if (p?.presentacion?.trim()) detParts.push(p.presentacion.trim());
  else if (p?.forma_farmaceutica?.trim()) detParts.push(p.forma_farmaceutica.trim());

  const mostrarPa =
    esMedicamentoReferencia(p) && pa && !nombreCoincideConPrincipioActivo(p?.nombre, pa);

  return {
    principioActivo: mostrarPa ? pa : null,
    detalle: detParts.join(" · "),
  };
}

export const FUENTE_META = {
  exprezo: {
    label: "Exprezo",
    tipo: "compra",
    listaDistribuidor: false,
    hint: "Zorro Abarrotero: el piso barato de higiene, pañales y abarrotes. No se compara con clubes (City Club / Sam's).",
  },
  marzam: { label: "Marzam", tipo: "compra", listaDistribuidor: true },
  nadro: { label: "Nadro", tipo: "compra", listaDistribuidor: true },
  levic: { label: "Levic", tipo: "compra", listaDistribuidor: false },
  farmalive: {
    label: "Farmalive",
    tipo: "compra",
    listaDistribuidor: false,
    hint: "Lista Club Iztapalapa. Precio base (2%), sin campañas de día.",
  },
  scorpion: {
    label: "Scorpion",
    tipo: "compra",
    listaDistribuidor: false,
    hint: "Mayoreo CDMX, higiene y pañales. Actualizar lo refresca. No tiene columna propia.",
  },
  abarrotero: {
    label: "Abarrotero",
    tipo: "compra",
    listaDistribuidor: false,
    hint: "OTC y cuidado personal. Actualizar lo refresca.",
  },
  mayoreototal: {
    label: "MayoreoTotal",
    tipo: "compra",
    listaDistribuidor: false,
    hint: "Poco traslape con el catálogo; solo aparece si gana precio.",
  },
  ultima_compra: {
    label: "Costo de compra",
    tipo: "compra",
    listaDistribuidor: false,
    hint: "Primera compra (quién + precio). Recibir solo lo pisa si el ticket es más barato.",
  },
  otros_compra: {
    label: "Otros",
    tipo: "compra",
    listaDistribuidor: false,
    hint: "Otro abarrotero barato o lista de representante. No uses esto para City Club/Sam's: no son el mismo piso que Zorro.",
  },
  similares: { label: "Similares", tipo: "venta", listaDistribuidor: false },
  fahorro: { label: "Del Ahorro", tipo: "venta", listaDistribuidor: false },
  otros_venta: {
    label: "Otros",
    tipo: "venta",
    listaDistribuidor: false,
    hint: "Promedio de mercado o consulta manual (Claude, Google, etc.)",
  },
};

export const fmtPrecioRef = (n) =>
  `$${parseFloat(n || 0).toLocaleString("es-MX", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;

/** Precio al público: peso entero hacia arriba (sin centavos). */
export function roundPrecioVenta(precio) {
  const p = parseFloat(precio);
  if (!Number.isFinite(p) || p <= 0) return null;
  return Math.ceil(p);
}

/** Formato venta al público — sin centavos. */
export function fmtPrecioVenta(n) {
  const p = roundPrecioVenta(n);
  if (p == null) return "—";
  return `$${p.toLocaleString("es-MX", { maximumFractionDigits: 0 })}`;
}

/**
 * Margen bruto sobre venta: (precio − costo) / precio.
 * tone: ok | debajo_piso | debajo_costo
 */
export function calcMargenVenta(precio, producto) {
  const costo = parseFloat(producto?.costo) || 0;
  const p = parseFloat(precio);
  if (!Number.isFinite(p) || p <= 0 || costo <= 0) {
    return { pct: null, utilidad: null, tone: null };
  }

  const utilidad = p - costo;
  const pct = (utilidad / p) * 100;
  const { markup } = classifyProductoMargen(producto);
  const piso = calcPriceFloor(costo, markup);

  let tone = "ok";
  if (p < costo) tone = "debajo_costo";
  else if (p < piso) tone = "debajo_piso";

  return {
    pct: Math.round(pct * 10) / 10,
    utilidad: Math.round(utilidad * 100) / 100,
    tone,
    piso,
  };
}

/** Precio de venta desde margen bruto % sobre venta, redondeado arriba. */
export function precioDesdeMargen(costo, margenPct) {
  const c = parseFloat(costo);
  const m = parseFloat(margenPct);
  if (!Number.isFinite(c) || c <= 0) return null;
  if (!Number.isFinite(m) || m < 0 || m >= 100) return null;
  return roundPrecioVenta(c / (1 - m / 100));
}

/** Sugerido competitivo: ~2% bajo ref. mínima, peso entero. */
export function calcPrecioCompetitivo(refMin) {
  const r = parseFloat(refMin);
  if (!Number.isFinite(r) || r <= 0) return null;
  return roundPrecioVenta(r * 0.98);
}

export function margenToneColors(tone, C) {
  if (tone === "debajo_costo") return { color: C.red, bg: C.redDim };
  if (tone === "debajo_piso") return { color: C.amber, bg: C.amberDim };
  if (tone === "ok") return { color: C.green, bg: C.greenDim };
  return { color: C.textMid, bg: C.cardDark };
}

/** Última fecha de referencia vigente por fuente (YYYY-MM-DD). */
export function fechasActualizacionPorFuente(rows) {
  const m = {};
  for (const row of rows || []) {
    if (!esReferenciaVigente(row)) continue;
    const f = row.fuente;
    const d =
      (row.fecha && String(row.fecha).slice(0, 10)) ||
      (row.created_at && String(row.created_at).slice(0, 10));
    if (!f || !d) continue;
    if (!m[f] || d > m[f]) m[f] = d;
  }
  return m;
}

export const NOTA_RASTREO_BOT = "rastreo_automatico";

export function esActualizacionBot(row) {
  return String(row?.notas || "") === NOTA_RASTREO_BOT;
}

export function instanteDeRef(row) {
  const t = Date.parse(row?.created_at || row?.fecha_captura || row?.fecha || "");
  return Number.isFinite(t) ? t : null;
}

/** Última vez que el bot tocó las refs de venta de este SKU. */
export function instanteBotVentaDe(refsMap) {
  let best = null;
  for (const id of FUENTES_VENTA) {
    const row = refsMap?.[id];
    if (!esActualizacionBot(row)) continue;
    const t = instanteDeRef(row);
    if (t != null && (best == null || t > best)) best = t;
  }
  return best;
}

export function instanteBotVentaGlobal(refsByProduct) {
  let best = null;
  for (const refs of Object.values(refsByProduct || {})) {
    const t = instanteBotVentaDe(refs);
    if (t != null && (best == null || t > best)) best = t;
  }
  return best;
}

export function fmtBotCuando(ts) {
  if (ts == null) return null;
  return new Date(ts).toLocaleString("es-MX", {
    timeZone: "America/Mexico_City",
    day: "numeric",
    month: "short",
    hour: "2-digit",
    minute: "2-digit",
  });
}

/** Mapa producto_id → { fuente → fila ref } desde filas de producto_precios_referencia_actual */
export function buildReferenciasPorProducto(rows) {
  const byProduct = {};
  for (const row of rows || []) {
    if (!esReferenciaVigente(row)) continue;
    const pid = row.producto_id;
    if (!pid) continue;
    if (!byProduct[pid]) byProduct[pid] = {};
    byProduct[pid][row.fuente] = row;
  }
  return byProduct;
}

/** Fallback: deduplicar historial crudo (si la vista aún no existe en Supabase) */
export function dedupeReferenciasActuales(rows) {
  const best = new Map();
  for (const row of rows || []) {
    if (!esReferenciaVigente(row)) continue;
    const key = `${row.producto_id}:${row.fuente}`;
    const prev = best.get(key);
    if (!prev) {
      best.set(key, row);
      continue;
    }
    const rowDate = `${row.fecha || ""}${row.created_at || ""}`;
    const prevDate = `${prev.fecha || ""}${prev.created_at || ""}`;
    if (rowDate > prevDate) best.set(key, row);
  }
  return Array.from(best.values());
}

/** Δ% compra: positivo = proveedor más caro que tu costo */
export function diffPctCompra(costo, precioRef) {
  const c = parseFloat(costo);
  const r = parseFloat(precioRef);
  if (!Number.isFinite(c) || c <= 0 || !Number.isFinite(r)) return null;
  return (((r - c) / c) * 100).toFixed(1);
}

/** Δ% venta vs competencia: positivo = tú más caro */
export function diffPctVenta(precio, precioRef) {
  const p = parseFloat(precio);
  const r = parseFloat(precioRef);
  if (!Number.isFinite(p) || !Number.isFinite(r) || r <= 0) return null;
  return (((p - r) / r) * 100).toFixed(1);
}

export function refsCompraDeProducto(refsMap) {
  const out = {};
  for (const id of FUENTES_COMPRA) {
    const row = refsMap?.[id];
    if (row?.precio != null) out[id] = parseFloat(row.precio);
  }
  return out;
}

export function refsVentaDeProducto(refsMap) {
  const out = {};
  for (const id of FUENTES_VENTA) {
    const row = refsMap?.[id];
    if (row?.precio != null) out[id] = parseFloat(row.precio);
  }
  return out;
}

/** Tiendas B2B con precio, de más barata a más cara. Nunca incluye «tu costo». */
export function opcionesTiendaCompra(refsMap) {
  return Object.entries(refsCompraDeProducto(refsMap))
    .filter(([, precio]) => Number.isFinite(precio) && precio > 0)
    .map(([id, precio]) => ({
      fuente: id,
      label: FUENTE_META[id]?.label || id,
      precio,
    }))
    .sort((a, b) => a.precio - b.precio);
}

/** Dónde pedir: la tienda más barata. El resurtido usa esto, no el último costo. */
export function calcMejorTienda(refsMap) {
  const opciones = opcionesTiendaCompra(refsMap);
  if (!opciones.length) return null;
  return { ...opciones[0], opciones };
}

/**
 * Mejor opción de compra: mínimo entre el costo vigente (quién + precio) y listas.
 * El precio más bajo gana.
 */
export function calcMejorCompra(costo, refsMap, meta = {}) {
  const c = parseFloat(costo);
  const options = [];
  const proveedor = String(meta.proveedor || "").trim();
  const labelCosto = proveedor
    ? `Compra ${proveedor}`
    : (meta.origen === "compra" ? "Tu compra" : "Tu costo");

  if (Number.isFinite(c) && c > 0) {
    options.push({
      fuente: "_tu_costo",
      label: labelCosto,
      precio: c,
      esTuCosto: true,
    });
  }

  for (const [id, precio] of Object.entries(refsCompraDeProducto(refsMap))) {
    if (!Number.isFinite(precio) || precio <= 0) continue;
    options.push({
      fuente: id,
      label: FUENTE_META[id]?.label || id,
      precio,
      esTuCosto: false,
    });
  }

  if (!options.length) return null;
  options.sort((a, b) => a.precio - b.precio);
  const best = options[0];
  const ahorroVsTuCosto =
    Number.isFinite(c) && c > 0 && !best.esTuCosto ? c - best.precio : null;

  return {
    fuente: best.fuente,
    label: best.label,
    precio: best.precio,
    esTuCosto: best.esTuCosto,
    ahorroVsTuCosto,
    /** Compat: proveedor más barato que tu costo abastos */
    ahorro: ahorroVsTuCosto,
    masBaratoQueTuCosto: ahorroVsTuCosto != null && ahorroVsTuCosto > 0.01,
  };
}

function minProfit(costo) {
  if (costo < 20) return 5;
  if (costo < 50) return 8;
  return 0;
}

function calcPriceFloor(costo, markup) {
  const base = costo * (1 + markup);
  const floor = costo + minProfit(costo);
  return Math.ceil(Math.max(base, floor));
}

/** Clasificación de margen mínimo (espejo pricing_preview.py) */
export function classifyProductoMargen(p) {
  const catL = (p.categoria || "").toLowerCase();
  const nombre = (p.nombre || "").toLowerCase();
  const tipo = (p.tipo || "").toLowerCase();
  const forma = (p.forma_farmaceutica || "").toLowerCase();
  const costo = parseFloat(p.costo) || 0;
  const pa = (p.principio_activo || "").trim();
  const rx = Boolean(p.requiere_receta);

  if (costo <= 0) return { markup: 0, code: "sin_costo" };
  if (costo < 2) return { markup: 0.35, code: "sin_clasificar" };

  const checks = [
    [() => catL.includes("hidrat") || catL === "bebidas" || /electrolit|pedialyte|suero oral|oralit/.test(nombre), 0.3],
    [() => catL.includes("beb") || /pañal|huggies|nan |enfamil/.test(nombre), 0.3],
    [() => catL === "abarrotes" || catL === "minisuper", 0.4],
    [() => catL === "suplemento" || catL === "vitaminas" || nombre.includes("vitamina"), 0.45],
    [() => catL.includes("botiqu") || /venda|gasa|jeringa|algodon|guante/.test(nombre), 0.5],
    [() => catL === "higiene" || catL === "cuidado personal", 0.4],
  ];
  for (const [cond, mk] of checks) {
    if (cond()) return { markup: mk, code: "categoria" };
  }

  if (/tensiometro|glucometro|nebulizador|termometro|oximetro/.test(nombre)) {
    return { markup: costo >= 300 ? 0.3 : 0.5, code: "disp_med" };
  }

  const medForm = /tableta|capsula|cápsula|jarabe|suspension|solucion|inyect|comprim|gragea/.test(forma);
  if ((tipo === "generico" || tipo === "genérico") && pa && medForm) return { markup: 0.6, code: "med_generico" };
  if (tipo === "marca" && rx) return { markup: 0.25, code: "med_patente" };
  if (tipo === "marca" && medForm && !rx) return { markup: 0.35, code: "med_otc_marca" };

  return { markup: 0.35, code: "sin_clasificar" };
}

/**
 * Precio de venta sugerido = ~2% bajo la ref. más barata (FDA / Similares / Otros).
 * Si hoy vendes más barato que eso, la acción es SUBIR (estabas dejando margen).
 * Si vendes más caro, la acción es BAJAR para no quedarte fuera.
 * El piso de margen no infla el precio; solo avisa si el competitivo queda bajo costo.
 */
export function calcPrecioSugeridoVenta(producto, refsMap) {
  const precioActual = parseFloat(producto.precio) || 0;
  const margenActual = calcMargenVenta(precioActual, producto);
  const margenSugeridoEmpty = { pct: null, utilidad: null, tone: null };

  const refs = refsVentaDeProducto(refsMap);
  const vals = Object.values(refs).filter((v) => Number.isFinite(v) && v > 0);
  if (!vals.length) {
    return {
      sugerido: null,
      sugeridoCompetitivo: null,
      refMin: null,
      piso: null,
      nota: "Sin referencias de venta",
      alerta: null,
      accion: null,
      margenActual,
      margenSugerido: margenSugeridoEmpty,
    };
  }

  const refMin = Math.min(...vals);
  const costo = parseFloat(producto.costo) || 0;
  const { markup } = classifyProductoMargen(producto);
  const piso = costo > 0 ? calcPriceFloor(costo, markup) : 0;
  const sugeridoCompetitivo = calcPrecioCompetitivo(refMin);
  const sugerido = sugeridoCompetitivo;
  const margenSugerido = sugerido != null ? calcMargenVenta(sugerido, producto) : margenSugeridoEmpty;
  const accion = accionPrecioSugerido(precioActual, sugerido);

  let nota = "Al nivel del mercado (~2% bajo la ref. más barata)";
  let alerta = margenSugerido.tone === "debajo_costo" ? "debajo_costo"
    : margenSugerido.tone === "debajo_piso" ? "debajo_piso"
    : null;

  if (alerta === "debajo_costo") {
    nota = `A ${fmtPrecioVenta(sugerido)} no cubres tu costo (${fmtPrecioRef(costo)}). Revisa costo o decide margen.`;
  } else if (alerta === "debajo_piso") {
    nota = `El mercado pide ${fmtPrecioVenta(sugerido)}, bajo tu piso habitual (${fmtPrecioVenta(piso)}).`;
  } else if (accion === "subir") {
    nota = `Subir: vendes ${fmtPrecioVenta(precioActual)} y el mercado más barato está en ${fmtPrecioRef(refMin)}. Puedes ir a ${fmtPrecioVenta(sugerido)} sin quedar caro.`;
  } else if (accion === "bajar") {
    nota = `Bajar: estás arriba del mercado (${fmtPrecioRef(refMin)}). Competir a ${fmtPrecioVenta(sugerido)}.`;
  } else if (accion === "mantener") {
    nota = "Tu precio ya está al nivel del mercado";
  }

  return {
    sugerido,
    sugeridoCompetitivo,
    refMin,
    piso,
    nota,
    alerta,
    accion,
    margenActual,
    margenSugerido,
  };
}

/** Compra: ref vs tu costo abastos — positivo = ref más caro (tu costo gana) */
export function colorDiffCompra(pctStr) {
  if (pctStr == null) return null;
  const n = parseFloat(pctStr);
  if (Number.isNaN(n)) return null;
  if (n > 0.5) return "tu_costo_mejor";
  if (n < -0.5) return "proveedor_mas_barato";
  return "neutral";
}

/** Texto corto para badge en columna compra */
export function labelDiffCompra(pctStr, vsLabel = "tu costo") {
  if (pctStr == null) return null;
  const n = parseFloat(pctStr);
  if (Number.isNaN(n)) return null;
  const vs = vsLabel || "tu costo";
  if (n > 0.5) return `+${pctStr}% vs ${vs}`;
  if (n < -0.5) return `${pctStr}% más barato`;
  return "≈ igual";
}

export function colorDiffVenta(pctStr) {
  if (pctStr == null) return null;
  const n = parseFloat(pctStr);
  if (Number.isNaN(n)) return null;
  // % = (tu precio − ref) / ref. Negativo = tú más barato.
  if (n < -12) return "barato";
  if (n <= 0) return "ok";
  return "caro";
}

/** ¿El sugerido sube, baja o ya está al mercado? */
export function accionPrecioSugerido(precioActual, sugerido) {
  const a = roundPrecioVenta(precioActual);
  const s = roundPrecioVenta(sugerido);
  if (a == null || s == null) return null;
  if (s - a >= 2) return "subir";
  if (a - s >= 2) return "bajar";
  return "mantener";
}
