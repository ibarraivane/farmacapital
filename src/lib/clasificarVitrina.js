/**
 * Misma clasificación que sql/patch_vitrina_seccion_20260924.sql.
 * No escribe requiere_receta ni productos.categoria.
 * Un producto sin sección no entra al menú.
 */

const CATEGORIAS_MEDICAMENTO = [
  "Medicamentos",
  "Medicamento",
  "Medicamentos OTC",
  "Analgésico",
  "Antiinflamatorio",
  "Antibiótico",
  "Antiviral",
  "Gastro",
  "Diabetes",
  "Hipertensión",
  "Cardiovascular",
  "Alergia",
  "Respiratorio",
  "Hormonales",
  "Hidratación",
  "Dermatología",
  "Ginecología",
];

const MARCAS_HIGIENE_CUIDADO = new Set([
  "ego",
  "silica",
  "shine sily",
  "moco de gorila",
  "garnier",
  "fructis",
  "jaloma",
  "hinds",
  "koleston",
  "teatrical",
  "nivea",
  "ponds",
  "pond's",
  "lubriderm",
  "labello",
  "grisi",
  "seda pure",
  "nuvel",
  "xiomara",
  "adidas",
  "revlon",
  "gum",
  "vitacilina",
  "pert",
  "herbal essences",
  "natural gloss",
  "nutribela",
]);

const SECCIONES_BELLEZA = [
  "Dermocosmética",
  "Nutrición deportiva",
  "Vitaminas y bienestar",
  "Higiene y cuidado personal",
];

function texto(v) {
  return String(v ?? "");
}

function marcaKey(p) {
  return texto(p?.marca).trim().toLowerCase();
}

function activo(p) {
  return p?.activo === true;
}

function esControlado(p) {
  if (p?.controlado === true) return true;
  return texto(p?.grupo_controlado).trim() !== "";
}

function esMedicamento(p) {
  return Boolean(p?.requiere_receta) || esControlado(p) || CATEGORIAS_MEDICAMENTO.includes(p?.categoria);
}

function subseccionMedicamento(categoria) {
  if (categoria === "Analgésico" || categoria === "Antiinflamatorio") return "Dolor y fiebre";
  if (categoria === "Respiratorio") return "Gripa y tos";
  if (categoria === "Gastro" || categoria === "Hidratación") return "Digestión";
  if (categoria === "Alergia") return "Alergia";
  if (categoria === "Diabetes") return "Diabetes";
  if (categoria === "Hipertensión" || categoria === "Cardiovascular") return "Presión y corazón";
  if (categoria === "Dermatología") return "Piel";
  if (categoria === "Antibiótico" || categoria === "Antiviral") return "Antibióticos";
  return "Otros";
}

function match(nombre, re) {
  return re.test(texto(nombre));
}

function subseccionHigiene(nombre) {
  if (match(nombre, /shampoo|champ(u|ú)|acondicionador|gel .*cabello|cera |tinte|koleston/i)) return "Cabello";
  if (match(nombre, /desodorante|antitranspirante/i)) return "Desodorantes";
  if (match(nombre, /pasta dental|cepillo dent|enjuague bucal|hilo dental/i)) return "Higiene bucal";
  if (match(nombre, /rastrillo|afeitar|rasurar|navaja/i)) return "Afeitado";
  if (match(nombre, /pa(ñ|n)al|bebe|beb(é|e)|toallitas/i)) return "Bebé";
  if (match(nombre, /cond(o|ó)n|preservativo|lubricante (i|í)ntimo/i)) return "Salud sexual";
  return "Cuidado diario";
}

function subseccionBotiquin(nombre) {
  if (match(nombre, /term(o|ó)metro/i)) return "Termómetros y baumanómetros";
  if (match(nombre, /baum(a|á)n(o|ó)metro|presi(o|ó)n/i)) return "Termómetros y baumanómetros";
  if (match(nombre, /gluc(o|ó)metro|tiras reactivas|lanceta/i)) return "Glucómetros";
  if (match(nombre, /prueba|test/i)) return "Pruebas";
  return "Curación";
}

/**
 * @param {object} p
 * @returns {{ vitrina_seccion: string|null, vitrina_subseccion: string|null }}
 */
export function clasificarVitrina(p) {
  if (!activo(p)) return { vitrina_seccion: null, vitrina_subseccion: null };

  if (esMedicamento(p)) {
    return {
      vitrina_seccion: "Medicamentos",
      vitrina_subseccion: subseccionMedicamento(p.categoria),
    };
  }

  const cat = p.categoria;
  const nombre = texto(p.nombre);
  const marca = marcaKey(p);

  if (cat === "Cuidado personal" && MARCAS_HIGIENE_CUIDADO.has(marca)) {
    return { vitrina_seccion: "Higiene y cuidado personal", vitrina_subseccion: "Cuidado diario" };
  }

  if (cat === "Cuidado personal" || cat === "Dermocosmético") {
    const solar = match(nombre, /solar|fps|spf|fotoprotec|sunscreen|heliocare/i);
    return { vitrina_seccion: "Dermocosmética", vitrina_subseccion: solar ? "Solar" : null };
  }

  if (cat === "Suplemento" || cat === "Suplementos") {
    const clinica = ["ensure", "glucerna", "pediasure", "abbott"].includes(marca)
      || /ensure|glucerna|pediasure/i.test(nombre);
    if (clinica) {
      return { vitrina_seccion: "Vitaminas y bienestar", vitrina_subseccion: "Nutrición clínica" };
    }
    return { vitrina_seccion: "Nutrición deportiva", vitrina_subseccion: null };
  }

  if (cat === "Vitaminas" || cat === "Herbolario") {
    let sub = "Vitaminas";
    if (cat === "Herbolario") sub = "Herbolarios";
    else if (/probi(o|ó)tic|lactobacil/i.test(nombre)) sub = "Probióticos";
    return { vitrina_seccion: "Vitaminas y bienestar", vitrina_subseccion: sub };
  }

  if (cat === "Higiene" || cat === "Bebés") {
    return { vitrina_seccion: "Higiene y cuidado personal", vitrina_subseccion: subseccionHigiene(nombre) };
  }

  if (["Botiquín", "Curación", "Dispositivo médico", "Dispositivos", "Pruebas"].includes(cat)) {
    return { vitrina_seccion: "Botiquín y equipo médico", vitrina_subseccion: subseccionBotiquin(nombre) };
  }

  return { vitrina_seccion: null, vitrina_subseccion: null };
}

export function esSeccionBelleza(seccion) {
  return SECCIONES_BELLEZA.includes(seccion);
}

export { CATEGORIAS_MEDICAMENTO, SECCIONES_BELLEZA };
