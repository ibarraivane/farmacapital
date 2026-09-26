/**
 * Qué más mostrar al pie de la ficha.
 *
 * Parecido es otra presentación, otro sabor o la misma sustancia.
 * Compartir «Suplemento» no alcanza: así la proteína terminaba junto a
 * Ensure, Glucerna y hierro.
 */

const STOP = new Set([
  "proteina", "protein", "suplemento", "suplementos", "vitamina", "vitaminas",
  "polvo", "sabor", "liquido", "liquida", "capsula", "capsulas", "tableta",
  "tabletas", "gramo", "gramos", "caja", "frasco", "crema", "nutricional",
  "nutricion", "deportiva", "original", "unisex", "etapa", "extra", "jumbo",
  "para", "bebe", "bebes", "con", "sin", "sobre", "pack",
]);

const SUB_AMPLIA = new Set([
  "suplemento", "suplementos", "vitamina", "vitaminas", "higiene",
  "medicamento", "medicamentos", "general", "otro", "nutricion",
  "bebes", "abarrotes", "basicos", "cuidado", "personal",
]);

function norm(s) {
  return String(s || "")
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .replace(/[^a-z0-9%\s]/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function tokensNombre(p) {
  const out = new Set();
  for (const raw of norm(p?.nombre).split(" ")) {
    if (raw.length < 4 || STOP.has(raw)) continue;
    out.add(raw);
  }
  return out;
}

function marcaUtil(p) {
  const m = norm(p?.marca);
  if (m.length < 3 || /^(generico|generica|s m|sin marca|varias)$/.test(m)) return "";
  return m;
}

function subcategoriaEspecifica(p) {
  const s = norm(p?.subcategoria);
  if (s.length < 4 || SUB_AMPLIA.has(s)) return "";
  return s;
}

function principioUtil(p) {
  const a = norm(p?.principio_activo);
  if (a.length < 4) return "";
  return a;
}

function puntajeSimilar(base, otro) {
  if (!otro || otro.id === base.id) return 0;
  let score = 0;
  const activo = principioUtil(base);
  if (activo && activo === principioUtil(otro)) score += 5;

  const marca = marcaUtil(base);
  const mismaMarca = Boolean(marca && marca === marcaUtil(otro));
  const sub = subcategoriaEspecifica(base);
  const mismaSub = Boolean(sub && sub === subcategoriaEspecifica(otro));
  const compartidos = [...tokensNombre(base)].filter((t) => tokensNombre(otro).has(t));

  if (mismaMarca && compartidos.length) score += 4;
  else if (mismaMarca && mismaSub) score += 3;
  else if (mismaSub && compartidos.length) score += 3;

  return score;
}

/**
 * @param {object} prod
 * @param {object[]} productos
 * @param {number} [limite]
 */
export function productosSimilaresTienda(prod, productos, limite = 4) {
  if (!prod || !Array.isArray(productos)) return [];
  const n = Math.max(0, Number(limite) || 0);
  return productos
    .map((p) => ({ p, score: puntajeSimilar(prod, p) }))
    .filter((x) => x.score >= 3)
    .sort((a, b) => b.score - a.score || Number(a.p.id) - Number(b.p.id))
    .slice(0, n)
    .map((x) => x.p);
}
