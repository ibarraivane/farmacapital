"use strict";

/**
 * Qué productos pueden llevar estrellas y reseñas de clientes.
 *
 * Misma regla que usa la tienda y el correo. La base de datos repite el
 * criterio en sql/patch_resenas_producto_20260923.sql: el anon no puede
 * saltárselo. No se importan reseñas de Amazon ni de otros sitios.
 *
 * Lista blanca, no lista negra. Receta y medicamento controlado mandan.
 * El promedio solo suma reseñas aprobadas y es null si no hay ninguna.
 */

const CATEGORIAS_PRODUCTO = Object.freeze([
  "Analgésico", "Antiinflamatorio", "Antibiótico", "Gastro", "Diabetes",
  "Hipertensión", "Alergia", "Vitaminas", "Suplemento", "Herbolario",
  "Hidratación", "Cardiovascular", "Hormonales", "Respiratorio",
  "Dispositivo médico", "Botiquín", "Higiene", "Bebidas", "Básicos",
  "Abarrotes", "Minisuper", "Cuidado personal", "Otro",
]);

const CATEGORIA_ALIAS = {
  digestivo: "Gastro",
  gastro: "Gastro",
  botiquin: "Botiquín",
  curacion: "Botiquín",
  "material de curacion": "Botiquín",
  hospitalario: "Botiquín",
  suplementos: "Suplemento",
  bebes: "Higiene",
  bebe: "Higiene",
  general: "Otro",
  producto: "Otro",
  productos: "Otro",
  antibiotico: "Antibiótico",
  antibioticos: "Antibiótico",
  analgesico: "Analgésico",
  analgesicos: "Analgésico",
  hipertension: "Hipertensión",
  hidratacion: "Hidratación",
  "hidratacion / electrolitos": "Hidratación",
  electrolitos: "Hidratación",
  "dispositivo medico": "Dispositivo médico",
  dispositivo: "Dispositivo médico",
  "cuidado personal": "Cuidado personal",
};

const REGLAS = [
  [/\b(electrolit|electrolid|pedialyte|suerox|oralit|voldratol|suero oral|electrolitos)\b/, "Hidratación"],
  [/\b(solucion cs|cloruro de sodio 0\.?9|nacl 0\.?9|hartmann|solucion fisiologica)\b/, "Hidratación"],
  [/\b(gasa|venda|jeringa|algodon|tegaderm|curita|micropore|tela adhesiva|cubrebocas|guante esteril|tensolastic|material de curacion|agua oxigenada|agua destilada)\b/, "Botiquín"],
  [/\b(alcohol etilico|alcohol 70|isodine|yodo|termometro|gotero|cateter|perilla n\d)\b/, "Botiquín"],
  [/\b(omron|glucometro|tensiometro|oximetro|accu-?chek|softclix|monitor de presion)\b/, "Dispositivo médico"],
  [/\b(amoxicilina|ampicilina|azitromicina|ciprofloxacino|levofloxacino|cefalexina|cefaclor|ceftriaxona|claritromicina|doxiciclina|clindamicina|dicloxacilina|penicilina|amikacina|nitrofurantoina|trimetoprima|sulfametoxazol|cefuroxima|cefixima)\b/, "Antibiótico"],
  [/\b(clamoxin|cefalver|cefaroxil|gimalxina|valclan)\b/, "Antibiótico"],
  [/\b(antiflu|desenfriol|next\b|contac\b|theraflu|syncol|agrifen|tabcin)\b/, "Respiratorio"],
  [/\b(alka[-\s]?seltzer|sal de uvas)\b/, "Gastro"],
  [/\b(ibuprofeno|naproxeno|diclofenaco|nimesulida|piroxicam|celecoxib|ketoprofeno|acemetacina|meloxicam|indometacina|flanax|advil|motrin)\b/, "Antiinflamatorio"],
  [/\b(paracetamol|acetaminofen|metamizol|neomelubrina|ketorolaco|tramadol|tempra|tylenol|cafiaspirina)\b/, "Analgésico"],
  [/\b(acido acetilsalicilico|acetilsalicilico|aspirina)\b/, "Analgésico"],
  [/\b(omeprazol|pantoprazol|esomeprazol|lansoprazol|ranitidina|famotidina|sucralfato|bismuto|estomaquil|loperamida|butilhioscina|butilescopolamina|metoclopramida|ondansetron|dimenhidrinato|buscapina|gaviscon|sal de uvas)\b/, "Gastro"],
  [/\b(metformina|glibenclamida|insulina|sitagliptina|empagliflozina|dapagliflozina|linagliptina|gliclazida)\b/, "Diabetes"],
  [/\b(losartan|enalapril|amlodipino|telmisartan|valsartan|captopril|nifedipino|hidroclorotiazida|metoprolol|atenolol|bisoprolol|irbesartan|candesartan)\b/, "Hipertensión"],
  [/\b(atorvastatina|simvastatina|rosuvastatina|pravastatina|clopidogrel|rivaroxaban|warfarina|acenocumarol)\b/, "Cardiovascular"],
  [/\b(loratadina|cetirizina|levocetirizina|desloratadina|fexofenadina|clorfenamina|clarityne|claritin|allegra|zyrtec)\b/, "Alergia"],
  [/\b(ambroxol|dextrometorfano|bromhexina|guaifenesina|oxolamina|salbutamol|budesonida|montelukast|afrin|broncolin|agrifen|tabcin|nasalub|histiacil|bisolvon|antigripal)\b/, "Respiratorio"],
  [/\b(paracetamol\s*[+/]\s*(fenilefrina|clorfenamina)|next\b|contac\b|theraflu|syncol)\b/, "Respiratorio"],
  [/\b(levonorgestrel|etinilestradiol|levotiroxina|desogestrel|drospirenona|anticonceptivo)\b/, "Hormonales"],
  [/\b(vitamina c|vitamina d|vitamina a|vitamina e|complejo b|acido folico|centrum|aderogyl|redoxon|neurobion|multivitamin)\b/, "Vitaminas"],
  [/\b(ensure|pediasure|glucerna|omega 3|proteina whey|suplemento nutricional)\b/, "Suplemento"],
  [/\b(ajolotius|arnica|homeopatico|producto homeopatico|producto natural)\b/, "Herbolario"],
  [/\b(antitranspirante|desodorante \/ |surfactantes \/ formula|jabon \/ tensioactivos|fluoruro de sodio)\b/, "Higiene"],
  [/\b(emolientes \/|vaselina \+ lanolina)\b/, "Cuidado personal"],
  [/\b(material de curacion|alcohol etilico)\b/, "Botiquín"],
  [/\bsuplemento nutricional\b/, "Suplemento"],
  [/\bformula lactea\b/, "Abarrotes"],
  [/\b(pantene|sedal|caprice|savile|head & shoulders|head and shoulders|herbal essences|shampoo|acondicionador|crema dental|pasta dental|enjuague bucal|listerine|colgate|sensodyne|cepillo dental|hilo dental)\b/, "Higiene"],
  [/\b(desodorante|antitranspirante|rexona|axe\b|dove\b|obao|jabon|toallas sanitarias|naturella|saba\b|condon|lubricante|prudence|huggies|toallas humedas)\b/, "Higiene"],
  [/\b(protector solar|bloqueador|anthelios|cerave|a-?derma|avene|cicalfate|acetona|agua micelar|crema corporal|vaselina|emolientes)\b/, "Cuidado personal"],
  [/\b(nido\b|nan\b|nestum|leche en polvo|formula lactea)\b/, "Abarrotes"],
];

function normalizeCategoriaKey(s) {
  return String(s ?? "")
    .trim()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .replace(/\s+/g, " ");
}

function categoriaCanon(raw) {
  const n = normalizeCategoriaKey(raw);
  if (!n) return "";
  if (CATEGORIA_ALIAS[n]) return CATEGORIA_ALIAS[n];
  const hit = CATEGORIAS_PRODUCTO.find((c) => normalizeCategoriaKey(c) === n);
  if (hit) return hit;
  return String(raw).trim();
}

function textoCategoriaProducto(p) {
  return [p?.nombre, p?.marca, p?.forma_farmaceutica, p?.principio_activo, p?.presentacion, p?.subcategoria]
    .join(" ")
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .replace(/[^a-z0-9+/.\s-]/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function inferirCategoriaCatalogo(p) {
  const t = textoCategoriaProducto(p);
  if (!t) return "";
  for (const [re, cat] of REGLAS) {
    if (re.test(t)) return cat;
  }
  return "";
}

function categoriaVitrina(p) {
  return inferirCategoriaCatalogo(p) || categoriaCanon(p?.categoria) || "Otro";
}

function esMedicamentoControlado(p) {
  if (!p || typeof p !== "object") return false;
  if (p.controlado === true) return true;
  return Boolean(String(p.grupo_controlado || "").trim());
}

const CATEGORIAS_CON_RESENA = Object.freeze([
  "Cuidado personal",
  "Dermocosmético",
  "Higiene",
  "Bebés",
  "Suplemento",
  "Vitaminas",
  "Herbolario",
  "Botiquín",
  "Curación",
  "Dispositivo médico",
]);

const PERMITIDAS = new Set(CATEGORIAS_CON_RESENA.map(normalizeCategoriaKey));
["dermocosmetica", "dermocosmeticos", "suplementos", "dispositivos", "bebe"].forEach((k) => PERMITIDAS.add(k));

function motivoSinResena(prod) {
  if (!prod || typeof prod !== "object") return "Producto no válido";
  if (prod.requiere_receta) return "Requiere receta médica";
  if (esMedicamentoControlado(prod)) return "Medicamento controlado";
  const cat = categoriaVitrina(prod);
  if (!PERMITIDAS.has(normalizeCategoriaKey(cat))) {
    return `Categoría sin reseñas: ${cat || "sin categoría"}`;
  }
  return "";
}

function productoAceptaResena(prod) {
  return motivoSinResena(prod) === "";
}

function promedioResenas(resenas) {
  const validas = (Array.isArray(resenas) ? resenas : []).filter(
    (r) => r && r.estado === "aprobada" && Number.isFinite(Number(r.estrellas))
  );
  if (!validas.length) return null;
  const suma = validas.reduce((s, r) => s + Math.min(5, Math.max(1, Math.round(Number(r.estrellas)))), 0);
  return { promedio: Math.round((suma / validas.length) * 10) / 10, total: validas.length };
}

function textoPromedio(resumen) {
  if (!resumen) return "Sin reseñas todavía";
  const n = resumen.total;
  return `${resumen.promedio} de 5 · ${n} ${n === 1 ? "reseña" : "reseñas"}`;
}

/** Fila de resenas_resumen, o null si el producto no lleva estrellas o no hay promedio. */
function resumenVisible(prod, fila) {
  if (!productoAceptaResena(prod)) return null;
  const promedio = Number(fila?.promedio);
  const total = Number(fila?.total);
  if (!Number.isFinite(promedio) || !Number.isFinite(total) || total < 1) return null;
  return { promedio: Math.round(promedio * 10) / 10, total };
}

module.exports = {
  CATEGORIAS_CON_RESENA,
  motivoSinResena,
  productoAceptaResena,
  promedioResenas,
  textoPromedio,
  resumenVisible,
};
