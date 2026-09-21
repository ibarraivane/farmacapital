import { categoriaCanon } from "../../constants/categoriasProducto";
import { normalizarClaveMonografia, viaDesdeForma } from "./claveMonografia";

export const TIPOS_FICHA = Object.freeze([
  "medicamento",
  "dermocosmetico",
  "suplemento",
  "cuidado_personal",
  "material",
  "equipo_medico",
]);

const CAT_TIPO = {
  Analgésico: "medicamento",
  Antiinflamatorio: "medicamento",
  Antibiótico: "medicamento",
  Gastro: "medicamento",
  Diabetes: "medicamento",
  Hipertensión: "medicamento",
  Alergia: "medicamento",
  Cardiovascular: "medicamento",
  Hormonales: "medicamento",
  Respiratorio: "medicamento",
  Vitaminas: "suplemento",
  Suplemento: "suplemento",
  Herbolario: "suplemento",
  Hidratación: "suplemento",
  "Dispositivo médico": "equipo_medico",
  Botiquín: "material",
  Higiene: "cuidado_personal",
  "Cuidado personal": "cuidado_personal",
};

const DERMO_RE = /derma|piel|solar|fps|cerave|laroche|la roche|isdin|eucerin|avene|a-derma|bioderma|uriage|cetaphil|atoderm|anthelios/i;
const SUPLE_RE = /proteina|proteína|vitamina|suplement|colageno|colágeno|omega|probiot/i;
const MATERIAL_RE = /venda|gasas?|jering|curacion|curación|algodon|algodón|guante|cubreboca|tela adhes/i;
const EQUIPO_RE = /monitor|oximetro|oxímetro|termometro|termómetro|nebulizador|glucometro|glucómetro/i;

/**
 * Clasifica tipo de ficha. Si no hay sustancia y no encaja, `revisar_clasificacion`.
 */
export function clasificarTipoFicha(producto = {}) {
  const clave = normalizarClaveMonografia(producto.principio_activo);
  const cat = categoriaCanon(producto.categoria);
  const blob = [
    producto.nombre,
    producto.marca,
    producto.subcategoria,
    producto.categoria,
  ].filter(Boolean).join(" ");

  if (EQUIPO_RE.test(blob) || cat === "Dispositivo médico") {
    return { tipo_ficha: "equipo_medico", clave_monografia: clave || null, revisar_clasificacion: false };
  }
  if (MATERIAL_RE.test(blob) || cat === "Botiquín") {
    return { tipo_ficha: "material", clave_monografia: clave || null, revisar_clasificacion: false };
  }
  if (DERMO_RE.test(blob) && (cat === "Cuidado personal" || !clave)) {
    return { tipo_ficha: "dermocosmetico", clave_monografia: null, revisar_clasificacion: false };
  }
  if (SUPLE_RE.test(blob) || cat === "Vitaminas" || cat === "Suplemento" || cat === "Herbolario" || cat === "Hidratación") {
    return { tipo_ficha: "suplemento", clave_monografia: clave || null, revisar_clasificacion: false };
  }
  if (cat === "Cuidado personal" || cat === "Higiene") {
    return { tipo_ficha: "cuidado_personal", clave_monografia: null, revisar_clasificacion: !clave };
  }
  if (CAT_TIPO[cat] === "medicamento" || clave) {
    return {
      tipo_ficha: "medicamento",
      clave_monografia: clave || null,
      revisar_clasificacion: !clave,
    };
  }
  if (CAT_TIPO[cat]) {
    return { tipo_ficha: CAT_TIPO[cat], clave_monografia: clave || null, revisar_clasificacion: !clave };
  }
  return {
    tipo_ficha: clave ? "medicamento" : "cuidado_personal",
    clave_monografia: clave || null,
    revisar_clasificacion: !clave,
  };
}

export function coberturaDesdeProducto(producto) {
  const tipo = clasificarTipoFicha(producto);
  return {
    producto_id: producto.id,
    sku: producto.sku || "",
    nombre: producto.nombre || "",
    principio_activo: producto.principio_activo || "",
    forma_farmaceutica: producto.forma_farmaceutica || "",
    categoria: producto.categoria || "",
    tipo_ficha: tipo.tipo_ficha,
    clave_monografia: tipo.clave_monografia,
    via: tipo.tipo_ficha === "medicamento"
      ? viaDesdeForma(producto.forma_farmaceutica, producto.presentacion)
      : null,
    revisar_clasificacion: tipo.revisar_clasificacion,
  };
}
