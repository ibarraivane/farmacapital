import { normalizeForSearch } from "../utils";

/**
 * Lenguaje habitual de mostrador -> atributos estructurados del catálogo.
 *
 * Esto sirve para recuperar productos, no para diagnosticar ni prescribir. Nunca
 * se consulta `descripcion`: puede mencionar un síntoma como efecto adverso.
 * Cada coincidencia debe estar respaldada por un campo real del SKU.
 */
const INTENCIONES_MOSTRADOR = [
  { id: "mareo-viaje", label: "mareo o náusea por movimiento", q: ["mareo", "mareado", "mareada", "mareo viaje", "mareo carro", "nausea viaje", "vomito viaje"], pa: ["dimenhidrinato", "meclizina", "meclozina", "difenidol"], sub: ["antiemetico", "anticinetico"] },
  { id: "vertigo", label: "vértigo", q: ["vertigo"], pa: ["betahistina", "cinarizina", "difenidol", "meclizina", "meclozina"] },
  { id: "nausea", label: "náusea o vómito", q: ["nausea", "nauseas", "vomito", "vomitos", "ganas de vomitar"], pa: ["dimenhidrinato", "meclizina", "meclozina", "difenidol", "metoclopramida"], sub: ["antiemetico"] },

  { id: "dolor-espalda", label: "dolor muscular o de espalda", q: ["dolor espalda", "dolor de espalda", "espalda adolorida", "dolor muscular", "contractura", "musculo adolorido", "golpe muscular"], pa: ["metocarbamol", "diclofenaco", "piroxicam", "capsaicina", "salicilato de metilo", "arnica"], sub: ["analgesico topico", "relajante muscular"] },
  { id: "dolor-cabeza", label: "dolor de cabeza", q: ["dolor cabeza", "dolor de cabeza", "cefalea"], pa: ["paracetamol", "ibuprofeno", "naproxeno", "acido acetilsalicilico", "metamizol"] },
  { id: "migrana", label: "migraña", q: ["migrana", "jaqueca"], pa: ["sumatriptan", "paracetamol / cafeina", "paracetamol/cafeina", "acido acetilsalicilico / cafeina"] },
  { id: "dolor-dental", label: "dolor dental", q: ["dolor muela", "dolor de muela", "dolor dental", "diente adolorido"], pa: ["ibuprofeno", "naproxeno", "paracetamol", "ketorolaco", "benzocaina"], sub: ["analgesico", "anestesico local"] },
  { id: "dolor-menstrual", label: "cólico o dolor menstrual", q: ["colico menstrual", "colicos menstruales", "dolor menstrual", "dolor regla"], pa: ["ibuprofeno", "naproxeno", "acido mefenamico", "butilhioscina", "hioscina"] },
  { id: "fiebre", label: "fiebre", q: ["fiebre", "calentura", "temperatura alta"], pa: ["paracetamol", "ibuprofeno", "metamizol"], sub: ["antipiretico"] },
  { id: "dolor-general", label: "dolor", q: ["analgesico", "para dolor", "algo para el dolor", "dolor cuerpo", "cuerpo cortado"], pa: ["paracetamol", "ibuprofeno", "naproxeno", "metamizol"], sub: ["analgesico"] },

  { id: "tos-flema", label: "tos con flema", q: ["tos con flema", "tos flema", "flemas", "moco en pecho", "expectorante"], pa: ["ambroxol", "bromhexina", "acetilcisteina", "carbocisteina", "guaifenesina"], sub: ["expectorante", "mucolitico"] },
  { id: "tos-seca", label: "tos seca", q: ["tos seca", "tos sin flema", "antitusivo"], pa: ["dextrometorfano", "levodropropizina", "dropropizina", "benzonatato", "oxeladina"], sub: ["antitusivo"] },
  { id: "tos", label: "tos", q: ["tos", "jarabe para tos"], pa: ["dextrometorfano", "levodropropizina", "dropropizina", "benzonatato", "ambroxol", "bromhexina", "acetilcisteina", "carbocisteina", "guaifenesina"], sub: ["tos", "antitusivo", "expectorante"] },
  { id: "garganta", label: "molestia de garganta", q: ["dolor garganta", "dolor de garganta", "garganta irritada", "ardor garganta", "pastillas garganta", "ronquera"], pa: ["bencidamina", "benzocaina", "cetilpiridinio"], sub: ["garganta"] },
  { id: "congestion", label: "congestión nasal", q: ["congestion", "nariz tapada", "descongestionar", "descongestionante", "no puedo respirar nariz"], pa: ["oximetazolina", "fenilefrina"], sub: ["descongestionante", "antigripal"] },
  { id: "gripa", label: "gripa o resfriado", q: ["gripa", "gripe", "resfriado", "antigripal", "cuerpo cortado gripa"], sub: ["antigripal", "resfriado", "gripe"], pa: ["paracetamol / clorfenamina / fenilefrina", "amantadina / clorfenamina / paracetamol"] },
  { id: "alergia", label: "alergia", q: ["alergia", "alergias", "estornudos", "comezon nariz", "escurrimiento nasal", "rinitis"], pa: ["loratadina", "cetirizina", "levocetirizina", "desloratadina", "fexofenadina", "clorfenamina"], sub: ["antialergico", "antihistaminico"] },

  { id: "agruras", label: "agruras o acidez", q: ["agruras", "acidez", "ardor estomago", "reflujo", "antiacido"], pa: ["omeprazol", "esomeprazol", "pantoprazol", "lansoprazol", "magaldrato", "hidroxido de aluminio", "bicarbonato de sodio"], sub: ["antiacido", "protector gastrico"] },
  { id: "gas", label: "gases o distensión", q: ["gases", "gas estomago", "inflamacion estomago", "panza inflamada", "distension abdominal", "flatulencia"], pa: ["simeticona", "dimeticona", "pinaverio", "trimebutina"], sub: ["antiflatulento"] },
  { id: "indigestion", label: "indigestión", q: ["indigestion", "empacho", "pesadez estomago", "digestivo", "mala digestion"], pa: ["pancreatina", "dimeticona", "simeticona"], sub: ["digestivo"] },
  { id: "colicos", label: "cólicos o espasmos", q: ["colicos", "colico", "retortijones", "espasmo estomago", "dolor abdominal"], pa: ["butilhioscina", "hioscina", "trimebutina", "pinaverio"], sub: ["antiespasmodico"] },
  { id: "diarrea", label: "diarrea", q: ["diarrea", "evacuaciones liquidas", "estomago suelto", "antidiarreico"], pa: ["loperamida", "nifuroxazida", "subsalicilato de bismuto", "neomicina / caolin / pectina", "neomicina + caolin + pectina"], sub: ["antidiarreico"] },
  { id: "estrenimiento", label: "estreñimiento", q: ["estrenimiento", "estrenido", "estrenida", "no puedo evacuar", "laxante"], pa: ["lactulosa", "senosidos", "senna", "picosulfato", "psyllium", "citrato de magnesio"], sub: ["laxante", "fibra"] },
  { id: "deshidratacion", label: "hidratación oral", q: ["deshidratacion", "deshidratado", "deshidratada", "rehidratar", "rehidratacion", "electrolitos", "suero oral"], cat: ["hidratacion"], sub: ["electrolitos", "suero oral"] },
  { id: "parasitos", label: "desparasitación", q: ["parasitos", "lombrices", "desparasitar", "desparasitante", "amibas"], pa: ["albendazol", "nitazoxanida", "quinfamida", "mebendazol"], sub: ["antiparasitario"] },

  { id: "hongos-piel", label: "hongos en piel", q: ["hongos piel", "hongo pie", "pie de atleta", "tiña", "pano piel", "antimicotico piel"], pa: ["clotrimazol", "ketoconazol", "bifonazol", "terbinafina", "miconazol"], forma: ["crema", "gel", "solucion", "spray", "polvo"] },
  { id: "hongos-vaginal", label: "molestia vaginal por hongos", q: ["hongos vaginales", "infeccion vaginal", "comezon vaginal", "ovulos hongos", "candidiasis vaginal"], pa: ["clotrimazol", "miconazol", "nistatina"], forma: ["ovulo", "vaginal"] },
  { id: "rozadura", label: "rozadura", q: ["rozadura", "rozaduras", "panalitis", "irritacion panal"], pa: ["oxido de zinc"], sub: ["rozaduras"] },
  { id: "quemadura", label: "quemadura menor", q: ["quemadura", "quemaduras", "quemada", "crema quemadura"], pa: ["sulfadiazina de plata", "dexpantenol"], sub: ["quemaduras"] },
  { id: "herida", label: "limpieza y curación de heridas", q: ["herida", "curacion", "curar herida", "desinfectar herida", "antiseptico", "cortada"], pa: ["yodo", "peroxido de hidrogeno", "acido hipocloroso", "clorhexidina"], sub: ["antiseptico", "curacion", "aposito", "gasa", "venda"] },
  { id: "moreton", label: "golpe o moretón", q: ["moreton", "moretones", "golpe", "hematoma"], pa: ["arnica", "heparinoide"], sub: ["analgesico topico"] },
  { id: "comezon", label: "comezón o irritación de piel", q: ["comezon piel", "picazon piel", "ronchas", "irritacion piel"], pa: ["calamina", "hidrocortisona", "difenhidramina"], sub: ["antipruriginoso"] },
  { id: "hemorroides", label: "molestia por hemorroides", q: ["hemorroides", "almorranas", "dolor rectal"], pa: ["lidocaina / hidrocortisona", "lidocaina", "hidrocortisona"], sub: ["hemorroides", "anorrectal"] },

  { id: "ojo-seco", label: "resequedad ocular", q: ["ojo seco", "ojos secos", "lagrimas artificiales", "resequedad ojos", "ardor ojos"], pa: ["hipromelosa", "hialuronato de sodio", "carboximetilcelulosa"], sub: ["lubricante ocular"] },
  { id: "alergia-ojos", label: "alergia ocular", q: ["alergia ojos", "comezon ojos", "ojos llorosos"], pa: ["ketotifeno", "cromoglicato"], sub: ["antialergico oftalmico"] },
  { id: "boca", label: "molestia en boca", q: ["afta", "aftas", "llaga boca", "dolor boca", "encías inflamadas", "encias inflamadas"], pa: ["benzocaina", "bencidamina", "cetilpiridinio"], sub: ["bucal", "oral"] },
  { id: "dormir", label: "apoyo para dormir", q: ["dormir", "no puedo dormir", "insomnio", "sueno", "relajante para dormir"], pa: ["melatonina", "valeriana"], sub: ["sueno", "ayuda para dormir"] },

  { id: "proteccion-solar", label: "protección solar", q: ["bloqueador", "bloqueador solar", "protector solar", "quemadura solar", "anthelios"], name: ["protector solar", "bloqueador", "fps", "spf", "sun", "fotosun", "solsun", "sol sun", "fotoprotector", "anthelios", "la roche", "uvair", "anthe"], sub: ["protector solar"] },
  { id: "repelente", label: "repelente de insectos", q: ["mosquitos", "repelente", "insectos", "piquetes mosquito"], sub: ["repelente"] },
  { id: "incontinencia", label: "incontinencia", q: ["incontinencia", "panal adulto", "panales adulto", "ropa interior desechable"], name: ["panal", "diapro", "tena", "affective", "depend", "molicare", "indasec"] },
  { id: "curitas", label: "protección de cortadas", q: ["curita", "curitas", "bandita", "banditas", "band aid"], name: ["curita", "aposito", "nexcare", "band aid"] },
  { id: "prueba-embarazo", label: "prueba de embarazo", q: ["prueba embarazo", "test embarazo", "saber si estoy embarazada"], name: ["embarazo"], sub: ["prueba de embarazo"] },
  { id: "condones", label: "preservativos", q: ["condon", "condones", "preservativo", "preservativos", "proteccion sexual"], name: ["condon", "durex", "prudence", "trojan", "sico"] },
  { id: "adhesivo-dental", label: "adhesivo para dentadura", q: ["pegamento", "pegamento dental", "pegamento dentadura", "adhesivo dental", "adhesivo dentadura", "adhesivo protesis", "crema adhesiva", "dentadura", "dentadura postiza", "dientes postizos", "protesis dental"], name: ["corega", "fixodent", "polident", "protesis"], sub: ["protesis dental", "adhesivo"] },
  { id: "pasta-dental", label: "pasta de dientes", q: ["pasta dientes", "pasta de dientes", "pasta dental", "dentifrico"], name: ["pasta dent", "pasta dental", "colgate triple", "colgate max", "colgate total", "sensodyne"] },
  { id: "toallas-femeninas", label: "toallas sanitarias", q: ["toallas sanitarias", "toalla sanitaria", "toallas femeninas", "toalla femenina"], name: ["saba", "kotex", "always"] },
  { id: "cotonetes", label: "hisopos", q: ["cotonete", "cotonetes", "q tips", "qtips"], name: ["hisopo", "kiuts"] },
  { id: "formula-infantil", label: "fórmula infantil", q: ["formula", "formula bebe", "leche formula", "leche de formula", "leche para bebe"], name: ["nan", "enfamil", "similac"] },
];

function textHas(haystack, needle) {
  const h = normalizeForSearch(haystack);
  const n = normalizeForSearch(needle);
  return Boolean(h && n && (` ${h} `).includes(` ${n} `));
}

function queryMatchesPhrase(query, phrase) {
  const q = ` ${query} `;
  const p = ` ${normalizeForSearch(phrase)} `;
  if (q.includes(p)) return true;
  const queryTokens = query.split(" ").filter(Boolean);
  const phraseTokens = normalizeForSearch(phrase).split(" ").filter(Boolean);
  if (queryTokens.length !== phraseTokens.length) return false;
  return phraseTokens.every((token, index) => {
    const candidate = queryTokens[index];
    if (token === candidate) return true;
    if (token.length < 5 || candidate.length < 5 || Math.abs(token.length - candidate.length) > 1) return false;
    let previous = Array.from({ length: candidate.length + 1 }, (_, i) => i);
    for (let i = 1; i <= token.length; i += 1) {
      const current = [i];
      for (let j = 1; j <= candidate.length; j += 1) {
        current[j] = Math.min(
          current[j - 1] + 1,
          previous[j] + 1,
          previous[j - 1] + (token[i - 1] === candidate[j - 1] ? 0 : 1)
        );
      }
      previous = current;
    }
    return previous[candidate.length] <= 1;
  });
}

/** Devuelve primero las intenciones más específicas y evita mezclar una general. */
export function intencionesParaConsulta(queryRaw) {
  const query = normalizeForSearch(queryRaw);
  if (query.length < 3 || /^\d+$/.test(query)) return [];
  const found = INTENCIONES_MOSTRADOR.filter((intent) => intent.q.some((q) => queryMatchesPhrase(query, q)))
    .sort((a, b) => {
      const specificity = (x) => Math.max(...x.q.filter((q) => queryMatchesPhrase(query, q)).map((q) => normalizeForSearch(q).split(" ").length), 0);
      return specificity(b) - specificity(a);
    });
  if (!found.length) return [];
  const maxSpecificity = Math.max(...found.map((intent) => Math.max(...intent.q.filter((q) => queryMatchesPhrase(query, q)).map((q) => normalizeForSearch(q).split(" ").length), 0)));
  return found.filter((intent) => {
    const own = Math.max(...intent.q.filter((q) => queryMatchesPhrase(query, q)).map((q) => normalizeForSearch(q).split(" ").length), 0);
    return own === maxSpecificity;
  });
}

function fieldMatchesAny(value, needles) {
  return (needles || []).some((needle) => textHas(value, needle));
}

export function productoCoincideIntencion(producto, intencion) {
  if (!producto || !intencion) return false;
  return (
    fieldMatchesAny(producto.principio_activo, intencion.pa) ||
    fieldMatchesAny(producto.denominacion_generica, intencion.pa) ||
    fieldMatchesAny(producto.nombre, intencion.name) ||
    fieldMatchesAny(producto.subcategoria, intencion.sub) ||
    fieldMatchesAny(producto.categoria, intencion.cat) ||
    fieldMatchesAny(producto.forma_farmaceutica, intencion.forma)
  );
}

export function coincidenciaIntencionMostrador(producto, queryRaw) {
  return intencionesParaConsulta(queryRaw).find((intent) => productoCoincideIntencion(producto, intent)) || null;
}

export function etiquetaIntencionMostrador(queryRaw) {
  const intents = intencionesParaConsulta(queryRaw);
  return intents.length === 1 ? intents[0].label : "";
}
