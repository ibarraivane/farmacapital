import {
  inferirCategoriaCatalogo,
  categoriaEsCuboBasura,
} from "./inferirCategoriaCatalogo";
import { categoriaVitrina } from "./categoriasProducto";
import inventario from "../../sql/generated/analisis_nombres_inventario.json";

test("ubica medicamentos y sueros que el ticket dejó en Otro/Higiene", () => {
  expect(inferirCategoriaCatalogo({
    nombre: "Clamoxin 12H",
    principio_activo: "AMOXICILINA/AC. CLAVULANICO",
    categoria: "Otro",
  })).toBe("Antibiótico");
  expect(inferirCategoriaCatalogo({
    nombre: "Acemetacina",
    principio_activo: "ACEMETACINA",
  })).toBe("Antiinflamatorio");
  expect(inferirCategoriaCatalogo({
    nombre: "Amlodipino 5 mg",
    principio_activo: "Amlodipino",
    categoria: "Otro",
  })).toBe("Hipertensión");
  expect(inferirCategoriaCatalogo({
    nombre: "Afrin Spray",
    marca: "Afrin",
    categoria: "Otro",
  })).toBe("Respiratorio");
  expect(inferirCategoriaCatalogo({
    nombre: "Aderogyl Amp",
    principio_activo: "Vitamina C + Vitamina A + Vitamina D3 + Complejo B",
  })).toBe("Vitaminas");
  expect(inferirCategoriaCatalogo({
    nombre: "Pantene Rizos",
    marca: "Pantene",
    categoria: "Otro",
  })).toBe("Higiene");
  expect(inferirCategoriaCatalogo({
    nombre: "Electrolit Uva",
    marca: "Electrolit",
    categoria: "Higiene",
  })).toBe("Hidratación");
  expect(inferirCategoriaCatalogo({
    nombre: "Ensure Fresa",
    marca: "Ensure",
    categoria: "Gastro",
  })).toBe("Suplemento");
  expect(inferirCategoriaCatalogo({
    nombre: "Broncolin Paleta",
    marca: "Broncolin",
    categoria: "Abarrotes",
  })).toBe("Respiratorio");
  expect(inferirCategoriaCatalogo({ nombre: "Antiflu-Des" })).toBe("Respiratorio");
  expect(inferirCategoriaCatalogo({ nombre: "Alka-Seltzer" })).toBe("Gastro");
  expect(inferirCategoriaCatalogo({ nombre: "Neomelubrina 500 mg" })).toBe("Analgésico");
  expect(inferirCategoriaCatalogo({ nombre: "Producto raro xyz" })).toBe("");
});

test("vitamina en sérum o crema es cuidado de la piel, no un suplemento", () => {
  const piel = [
    "Darrow Actine Vitamina C Serum 30 g",
    "Etat Pur Activo Puro Vitamina C Sérum anti-manchas 15 ml",
    "Etat Pur Activo Puro Vitamina E 15ml.",
    "Isispharma Geneskin c premium vitamina c 20% antioxidante 10ml.",
    "Genové Fluidbase Rederm Retinol + Vitamina C 30 ml",
    "Vichy Kit UV Age Daily SPF 50+ (40 ml) + Liftactiv B3 (5 ml) + Liftactiv Vitamina C (4 ml)",
    "CeraVe Limpiador Tono Uniforme Vitamina C 236 ml",
    "Cetaphil Sérum de vitamina C antimanchas 30 ml",
    "Season Love Your Skin Aceite vitamina C 30 ml",
    "Uriage Bariésun Aceite seco spf50+ con vitamina e 200 ml",
    "Bioderma Pigmentbio C-Concentrate Sérum concentrado de vitamina C 15 ml",
  ];
  for (const nombre of piel) {
    expect(inferirCategoriaCatalogo({ nombre })).toBe("Cuidado personal");
  }
  expect(inferirCategoriaCatalogo({
    nombre: "Dove aerosol tono uniforme caléndula y vitamina E",
    marca: "Dove",
  })).toBe("Higiene");
});

test("vitamina que se toma sigue en Vitaminas", () => {
  expect(inferirCategoriaCatalogo({
    nombre: "Vitamina C 120 Tabletas Vidanat",
    presentacion: "120 Tabletas",
  })).toBe("Vitaminas");
  expect(inferirCategoriaCatalogo({
    nombre: "Multivitamínico Centrum Mujer con Vitamina C Vitamina E y Retinol 60 Tabletas",
  })).toBe("Vitaminas");
  expect(inferirCategoriaCatalogo({
    nombre: "Emulsión de Scott Vitamina A y D Sabor Cereza 400ML",
  })).toBe("Vitaminas");
  expect(inferirCategoriaCatalogo({
    nombre: "Colagener Colageno Hidrolizado Vitamina C 60 Tabletas Tipo de Piel",
    forma_farmaceutica: "Tableta",
  })).toBe("Vitaminas");
  expect(inferirCategoriaCatalogo({
    nombre: "Afrodit Tocofersolan Vitamina E 99 Capsulas 400UI Progela",
  })).toBe("Vitaminas");
  expect(inferirCategoriaCatalogo({
    nombre: "Onedrop Ade Suplemento Alimenticio Vitaminas A, D y E, 3 ml Sabor Aceite de Coco",
  })).toBe("");
  expect(inferirCategoriaCatalogo({
    nombre: "Alphastan 10mg",
    marca: "Omega Lab",
    presentacion: "90 tabletas",
  })).toBe("");
});

test("categoriaVitrina no pisa Higiene real y sí saca sueros de Higiene", () => {
  expect(categoriaVitrina({ nombre: "Dove Barra", marca: "Dove", categoria: "Higiene" })).toBe("Higiene");
  expect(categoriaVitrina({ nombre: "Pedialyte", marca: "Pedialyte", categoria: "Bebidas" })).toBe("Hidratación");
  expect(categoriaEsCuboBasura("GENERAL")).toBe(true);
  expect(categoriaEsCuboBasura("Analgésico")).toBe(false);
});

test("el inventario de muestra deja de amontonarse en Otro", () => {
  const rows = Array.isArray(inventario) ? inventario : [];
  expect(rows.length).toBeGreaterThan(400);
  const vitrina = rows.map((p) => categoriaVitrina(p));
  const otro = vitrina.filter((c) => c === "Otro").length;
  const hidra = vitrina.filter((c) => c === "Hidratación").length;
  const antibio = vitrina.filter((c) => c === "Antibiótico").length;
  const higiene = vitrina.filter((c) => c === "Higiene").length;
  expect(hidra).toBeGreaterThan(15);
  expect(antibio).toBeGreaterThan(10);
  expect(higiene).toBeGreaterThan(80);
  expect(otro).toBeLessThan(rows.length * 0.45);
});
