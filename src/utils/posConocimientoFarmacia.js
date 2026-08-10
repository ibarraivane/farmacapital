'use strict';

function normalize(text) {
  return String(text || "")
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/\s+/g, " ")
    .trim();
}

function words(text, minLen = 3) {
  return normalize(text)
    .split(/\s+/)
    .filter((w) => w.length >= minLen);
}

function posStockFromProduct(p) {
  const lotes = Array.isArray(p?.lotes) ? p.lotes : [];
  if (lotes.length) {
    return lotes
      .filter((l) => l?.activo !== false)
      .reduce((s, l) => s + Math.max(0, Number(l.cantidad_actual || 0)), 0);
  }
  return Math.max(0, Number(p?.stock || 0));
}

function posEsOtcConStock(p) {
  if (!p || p.activo === false) return false;
  if (p.requiere_receta || p.controlado) return false;
  return posStockFromProduct(p) > 0;
}

const SINTOMA_REGLAS = [
  {
    match: ["dolor de cabeza", "cefalea", "migrana", "migraña", "duele la cabeza"],
    keywords: ["paracetamol", "acetaminofen", "ibuprofeno", "aspirina", "migran", "tempra", "advil", "motrin", "analg"],
    nota: "Si el dolor es muy intenso, recurrente o con visión alterada, conviene valoración médica.",
  },
  {
    match: ["fiebre", "temperatura", "calentura"],
    keywords: ["paracetamol", "acetaminofen", "ibuprofeno", "antipiret", "tempra"],
    nota: "Hidratación y reposo. Acudir al médico si la fiebre persiste más de 3 días o supera 39 °C.",
  },
  {
    match: ["tos seca", "tos irritativa"],
    keywords: ["dextrometorfano", "antitusivo", "tos seca", "bisolvon", "alex"],
  },
  {
    match: ["tos", "tos con flema", "expectoracion", "congestion"],
    keywords: ["ambroxol", "bromhexina", "expectorante", "jarabe", "tos", "mucolit", "solucion"],
  },
  {
    match: ["dolor de garganta", "garganta irritada", "faringitis"],
    keywords: ["spray", "garganta", "mentol", "strepsils", "hexyl", "isodine", "enjuague"],
  },
  {
    match: ["gripa", "resfriado", "resfriado comun", "congestion nasal"],
    keywords: ["paracetamol", "gripa", "descongest", "fenilefrina", "loratadina", "next", "vick", "antigrip"],
    nota: "Reposo e hidratación. Antibióticos solo con receta si hay complicación.",
  },
  {
    match: ["alergia", "estornudos", "rinitis", "picazon en ojos", "conjuntivitis alergica"],
    keywords: ["loratadina", "cetirizina", "fexofenadina", "clorfenamina", "antihist", "allegra", "claritin"],
  },
  {
    match: ["diarrea", "evacuaciones liquidas"],
    keywords: ["loperamida", "electrolit", "suero oral", "oralit", "rehidrat", "diarrea", "flora"],
    nota: "Priorizar rehidratación oral. Si hay sangre, fiebre alta o deshidratación severa, acudir al médico.",
  },
  {
    match: ["deshidratacion", "deshidratado", "calor", "golpe de calor"],
    keywords: ["electrolit", "suero oral", "oralit", "rehidrat", "oral"],
  },
  {
    match: ["acidez", "agruras", "reflujo", "ardor estomago"],
    keywords: ["omeprazol", "antiacido", "aluminio", "magnesio", "gaviscon", "sal de frutas", "peps"],
  },
  {
    match: ["gastritis", "dolor estomago", "colico abdominal", "cólico"],
    keywords: ["hioscina", "butilescopolamina", "buscapina", "omeprazol", "antiespasmod", "colitis"],
  },
  {
    match: ["dolor muscular", "contractura", "lumbalgia", "dolor de espalda"],
    keywords: ["ibuprofeno", "diclofenaco", "metamizol", "naproxeno", "musculo", "volaren", "dol"],
  },
  {
    match: ["dolor menstrual", "colicos menstruales", "regla"],
    keywords: ["ibuprofeno", "naproxeno", "metamizol", "buscapina", "menstr"],
  },
  {
    match: ["constipacion", "estreñimiento", "no puede defecar"],
    keywords: ["laxante", "bisacodilo", "sen", "fibra", "magnesio", "citrat"],
  },
  {
    match: ["nausea", "vomito", "vómito", "mareo"],
    keywords: ["metoclopramida", "dimenhidrinato", "dramamine", "nause", "vom"],
    nota: "Si el vómito es persistente o con sangre, acudir al médico.",
  },
  {
    match: ["quemadura solar", "insolacion", "insolación", "sol"],
    keywords: ["after sun", "aloe", "rehidrat", "electrolit", "protector"],
  },
  {
    match: ["herida leve", "corte", "raspadura", "curacion"],
    keywords: ["curitas", "venda", "yodo", "agua oxigenada", "antisept", "gasas"],
  },
  {
    match: ["hongos", "micosis", "pie de atleta", "tiña"],
    keywords: ["clotrimazol", "miconazol", "ketoconazol", "terbinafina", "antimicot"],
  },
  {
    match: ["hemorroides", "anal", "picazon anal"],
    keywords: ["hemorroid", "anovate", "proct", "lidocaina"],
  },
  {
    match: ["insomnio", "no puede dormir"],
    keywords: ["difenhidramina", "melatonina", "sleep", "dormir"],
    nota: "Evitar automedicación prolongada para dormir; consultar si persiste.",
  },
];

const USO_POR_PRINCIPIO = {
  paracetamol: "Analgésico y antipirético de venta libre. Alivia dolor leve a moderado y baja la fiebre.",
  acetaminofen: "Analgésico y antipirético de venta libre. Alivia dolor leve a moderado y baja la fiebre.",
  ibuprofeno: "Antiinflamatorio, analgésico y antipirético. Útil para dolor, fiebre e inflamación leve.",
  aspirina: "Analgésico, antipirético y antiinflamatorio. También se usa en dosis bajas bajo indicación médica cardiovascular.",
  naproxeno: "Antiinflamatorio y analgésico para dolor e inflamación moderada.",
  diclofenaco: "Antiinflamatorio no esteroideo para dolor e inflamación. Algunas presentaciones requieren receta.",
  loratadina: "Antihistamínico de venta libre para alergias, rinitis alérgica y urticaria leve.",
  cetirizina: "Antihistamínico para alergias, picazón y rinitis alérgica.",
  ambroxol: "Mucolítico/expectorante para facilitar la eliminación de flemas en tos productiva.",
  dextrometorfano: "Antitusivo para tos seca sin flema, cuando no hay infección que requiera médico.",
  loperamida: "Antidiarreico de venta libre para diarrea aguda leve en adultos, siempre con rehidratación.",
  omeprazol: "Inhibidor de la secreción ácida gástrica. Se usa en acidez, reflujo y gastritis bajo indicación.",
  metoclopramida: "Procinético y antiemético para náusea y vómito leve, preferible bajo indicación profesional.",
  clotrimazol: "Antimicótico tópico para hongos en piel y mucosas superficiales.",
  miconazol: "Antimicótico tópico para infecciones por hongos en piel.",
};

const USO_POR_PATRON = [
  { re: /electrolit|suero oral|oralit|pedialyte|oral\s/i, uso: "Solución de rehidratación oral. Repone electrolitos y líquidos perdidos por diarrea, vómito, ejercicio o calor." },
  { re: /bepanthen|panthenol|dermatol/i, uso: "Crema/pomada protectora y regeneradora de la piel. Se usa en irritaciones leves, pañalitis o piel reseca." },
  { re: /vick|vaporub| mentol |eucalipto/i, uso: "Balsamo/descongestionante tópico o inhalado para congestión nasal y molestias de resfriado leve." },
  { re: /protector\s+solar|bloqueador|fps\s|spf/i, uso: "Protector solar para reducir quemaduras solares y daño por radiación UV." },
  { re: /vitamina\s+c|ascorb|cee/i, uso: "Suplemento de vitamina C. Apoyo en resfriados leves y nutrición; no sustituye alimentación balanceada." },
  { re: /complejo\s+b|vitamina\s+b/i, uso: "Suplemento de vitaminas del grupo B para apoyo nutricional cuando hay deficiencia o indicación." },
  { re: /shampoo|sh\s|champu|acondicion|ac\s/i, uso: "Producto de aseo capilar para limpieza, cuidado o tratamiento cosmético del cabello." },
  { re: /desodor|desod|antitransp|odolex|rexona|speed\s*stick/i, uso: "Desodorante o antitranspirante para control de olor y sudor axilar o corporal." },
  { re: /pasta\s+dental|dentif|colgate|oral\s*b/i, uso: "Pasta dental para higiene bucal diaria y prevención de caries y placa." },
  { re: /preservativo|condon|condón/i, uso: "Preservativo de barrera para protección en relaciones sexuales y prevención de ITS/embarazo." },
  { re: /prueba\s+embarazo|test\s+embarazo/i, uso: "Prueba rápida casera para detectar embarazo en orina." },
  { re: /glucosa|tiras\s+react|medidor/i, uso: "Producto para monitoreo de glucosa en sangre en personas con diabetes o bajo indicación médica." },
  { re: /pañal|panal|huggies|pampers/i, uso: "Pañal desechable para absorción de orina y heces en bebés o incontinencia leve." },
  { re: /gel\s+antibact|sanitizer|alcohol\s+gel|antiséptico/i, uso: "Gel antiséptico para higiene de manos y reducción de gérmenes en superficies cutáneas." },
];

function expandSintomaContext(sintoma) {
  const n = normalize(sintoma);
  const queryWords = words(sintoma, 3);
  const matched = SINTOMA_REGLAS.filter((r) => r.match.some((m) => n.includes(normalize(m))));
  if (!matched.length) {
    return { keywords: queryWords, categorias: [], nota: "", queryWords };
  }
  return {
    keywords: [...new Set(matched.flatMap((r) => r.keywords))],
    categorias: [...new Set(matched.flatMap((r) => r.categorias || []))],
    nota: matched.map((r) => r.nota).filter(Boolean)[0] || "",
    queryWords,
  };
}

function productHaystack(p) {
  return normalize(
    [
      p.nombre,
      p.marca,
      p.principio_activo,
      p.categoria,
      p.descripcion,
      p.concentracion,
      p.presentacion,
      p.forma_farmaceutica,
    ].join(" ")
  );
}

function scoreProductForSintoma(p, ctx) {
  const hay = productHaystack(p);
  let score = 0;
  ctx.keywords.forEach((kw) => {
    if (hay.includes(normalize(kw))) score += 5;
  });
  ctx.categorias.forEach((cat) => {
    if (hay.includes(normalize(cat))) score += 2;
  });
  ctx.queryWords.forEach((w) => {
    if (hay.includes(w)) score += 1;
  });
  return score;
}

function razonSugerencia(sintoma, product) {
  const pa = String(product.principio_activo || "").trim();
  if (pa) return `${pa}: opción OTC con stock relacionada con «${sintoma}».`;
  const marca = String(product.marca || "").trim();
  if (marca) return `${marca}: producto de venta libre con stock para «${sintoma}».`;
  return `Producto de venta libre con stock relacionado con «${sintoma}».`;
}

/** @returns {{ sugerencias: Array<{producto_id:number, razon:string}>, nota: string, source: 'catalogo' }} */
function suggestPosProductsLocal(sintoma, catalogProducts) {
  const list = Array.isArray(catalogProducts) ? catalogProducts.filter(posEsOtcConStock) : [];
  if (!list.length) {
    return { sugerencias: [], nota: "No hay productos OTC con stock en inventario.", source: "catalogo" };
  }
  const ctx = expandSintomaContext(sintoma);
  const scored = list
    .map((p) => ({ p, score: scoreProductForSintoma(p, ctx) }))
    .filter((x) => x.score > 0)
    .sort((a, b) => b.score - a.score || String(a.p.nombre).localeCompare(String(b.p.nombre), "es"));

  let picks = scored.slice(0, 4);
  if (!picks.length) {
    picks = list
      .map((p) => ({ p, score: scoreProductForSintoma(p, { ...ctx, keywords: ctx.queryWords, queryWords: ctx.queryWords }) }))
      .filter((x) => x.score > 0)
      .sort((a, b) => b.score - a.score)
      .slice(0, 4);
  }

  const sugerencias = picks.map(({ p }) => ({
    producto_id: Number(p.id),
    razon: razonSugerencia(sintoma, p),
  }));

  const nota = ctx.nota || (sugerencias.length
    ? "Sugerencias desde tu inventario (sin límite de consultas)."
    : "No encontramos coincidencias claras. Prueba otro término o busca por nombre en el catálogo.");

  return { sugerencias, nota, source: "catalogo" };
}

function describePosProductUseLocal(product) {
  if (!product) return null;
  const paNorm = normalize(product.principio_activo || "");
  if (paNorm) {
    if (USO_POR_PRINCIPIO[paNorm]) return USO_POR_PRINCIPIO[paNorm];
    for (const [key, uso] of Object.entries(USO_POR_PRINCIPIO)) {
      if (paNorm.includes(key) || key.includes(paNorm)) return uso;
    }
  }

  const blob = `${product.nombre || ""} ${product.marca || ""} ${product.denominacion_distintiva || ""}`;
  for (const { re, uso } of USO_POR_PATRON) {
    if (re.test(blob)) return uso;
  }

  const cat = normalize(product.categoria || "");
  if (cat.includes("antibiot")) {
    return "Antibiótico: requiere receta médica. No automedicarse; usar solo bajo prescripción y completar el tratamiento.";
  }
  if (cat.includes("analges") || cat.includes("analg")) {
    return "Analgésico de venta libre o con receta según presentación. Alivia dolor leve a moderado.";
  }
  if (cat.includes("derm") || cat.includes("piel")) {
    return "Producto dermatológico tópico para cuidado o tratamiento de la piel según indicación del envase.";
  }

  if (product.requiere_receta || product.controlado) {
    const pa = String(product.principio_activo || "").trim();
    return pa
      ? `${pa}: medicamento con receta. Uso exclusivamente según indicación médica.`
      : "Medicamento con receta. Uso según indicación del médico.";
  }

  const forma = normalize(product.forma_farmaceutica || "");
  if (/capsula|comprimido|tableta/.test(forma)) {
    return "Medicamento o suplemento oral de venta libre. Seguir indicaciones del envase o del químico farmacéutico.";
  }
  if (/jarabe|suspension|solucion/.test(forma)) {
    return "Solución o jarabe oral. Uso según edad y dosis del envase.";
  }

  return null;
}

function describePosProductUseFallback(product) {
  return (
    describePosProductUseLocal(product) ||
    (String(product?.principio_activo || "").trim()
      ? `${product.principio_activo}: consulta la información del fabricante o al químico farmacéutico.`
      : "Producto de venta libre. Indica seguir las instrucciones del envase o consultar al químico farmacéutico.")
  );
}

module.exports = {
  posStockFromProduct,
  posEsOtcConStock,
  suggestPosProductsLocal,
  describePosProductUseLocal,
  describePosProductUseFallback,
};
