/**
 * Categoría de mostrador a partir de nombre, marca y sustancia.
 * Solo reglas de alta confianza: si no hay señal, no inventa.
 */

function norm(s) {
  return String(s || "")
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .replace(/[^a-z0-9+/.\s-]/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

export function textoCategoriaProducto(p) {
  return norm(
    [
      p?.nombre,
      p?.marca,
      p?.forma_farmaceutica,
      p?.principio_activo,
      p?.presentacion,
      p?.subcategoria,
    ].join(" "),
  );
}

/** Más específico primero. */
const REGLAS = [
  [/\b(electrolit|electrolid|pedialyte|suerox|oralit|voldratol|suero oral|electrolitos)\b/, "Hidratación"],
  [/\b(solucion cs|cloruro de sodio 0\.?9|nacl 0\.?9|hartmann|solucion fisiologica)\b/, "Hidratación"],

  [/\b(gasa|venda|jeringa|algodon|tegaderm|curita|micropore|tela adhesiva|cubrebocas|guante esteril|tensolastic|material de curacion|agua oxigenada|agua destilada)\b/, "Botiquín"],
  [/\b(alcohol etilico|alcohol 70|isodine|yodo|termometro|gotero|cateter|perilla n\d)\b/, "Botiquín"],

  [/\b(omron|glucometro|tensiometro|oximetro|accu-?chek|softclix|monitor de presion)\b/, "Dispositivo médico"],

  [/\b(electrolit|pedialyte)\b/, "Hidratación"],

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

  // Vitaminas = lo que se toma. Un sérum o una crema con «vitamina C» es piel.
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

/** Tableta, cápsula, jarabe, gomita, polvo, ampolleta: se toma. */
const FORMA_TOMADA = /\b(tabletas?|tabs?|capsulas?|caps|comprimidos?|grageas?|gomitas?|efervescentes?|jarabes?|polvos?|sobres?|ampolletas?|softgels?|masticables?|perlas?|porcion(?:es)?|suplementos?)\b/;

/**
 * Forma de piel. «gel» suelto no agarra Naturagel ni Gelcavit.
 * «aceite de coco/pescado» es sabor o omega, no un aceite facial.
 * spf50 (pegado) también cuenta.
 */
const FORMA_PIEL = /\b(serums?|cremas?|gel(?:es)?|mascarillas?|limpiador(?:es)?|locion(?:es)?|fluidos?|fluidbase|fps\d*|spf\d*|protector solar|bloqueador|exfoliantes?|tonicos?|balsamos?|pomadas?|unguentos?|desmaquillantes?|agua micelar|peeling|retinol|activo puro|liftactiv|geneskin|pigmentbio|depiderm|actine|facial|contorno)\b/;
const ACEITE_FACIAL = /\baceite\b/;
const ACEITE_DIETARIO = /\baceite de (pescado|higado|coco|onagra|primula|krill|lino|oliva|germen)\b/;

/** Higiene que a veces dice «vitamina E» (Dove). No es un suplemento. */
const HIGIENE_CON_VITAMINA = /\b(shampoo|acondicionador|desodorante|antitranspirante|pantene|sedal|dove|crema dental|pasta dental|enjuague bucal)\b/;

const REGLA_VITAMINAS = /\b(vitamina c|vitamina d|vitamina a|vitamina e|complejo b|acido folico|centrum|aderogyl|redoxon|neurobion|multivitamin)\b/;

export function esProductoTomado(p) {
  return FORMA_TOMADA.test(textoCategoriaProducto(p));
}

/**
 * Dermocosmético de piel (sérum, crema, gel, aceite facial, línea Activo Puro…).
 * Si también trae forma oral, manda lo que se toma: Centrum con retinol y
 * «60 tabletas» sigue siendo vitamina.
 */
export function esDermocosmeticoTopico(p) {
  const t = textoCategoriaProducto(p);
  if (!t || FORMA_TOMADA.test(t) || HIGIENE_CON_VITAMINA.test(t)) return false;
  if (FORMA_PIEL.test(t)) return true;
  return ACEITE_FACIAL.test(t) && !ACEITE_DIETARIO.test(t);
}

function saltaVitaminas(t) {
  if (FORMA_TOMADA.test(t)) return false;
  if (HIGIENE_CON_VITAMINA.test(t)) return true;
  if (FORMA_PIEL.test(t)) return true;
  return ACEITE_FACIAL.test(t) && !ACEITE_DIETARIO.test(t);
}

/**
 * @returns {string} categoría canónica o "" si no hay señal.
 */
export function inferirCategoriaCatalogo(p) {
  const t = textoCategoriaProducto(p);
  if (!t) return "";
  const mencionaVitamina = REGLA_VITAMINAS.test(t);
  for (const [re, cat] of REGLAS) {
    if (cat === "Vitaminas" && mencionaVitamina && saltaVitaminas(t)) continue;
    if (re.test(t)) return cat;
  }
  if (mencionaVitamina && esDermocosmeticoTopico(p)) return "Cuidado personal";
  return "";
}

/** Cubos que el ticket/parser usó cuando no sabía. */
export function categoriaEsCuboBasura(raw) {
  const n = norm(raw);
  return !n || /^(otro|producto|productos|medicamento|general)$/.test(n);
}
