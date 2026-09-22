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
