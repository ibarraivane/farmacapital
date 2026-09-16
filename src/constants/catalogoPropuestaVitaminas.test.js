import { readFileSync } from "fs";
import { join } from "path";
import { CATEGORIAS_PRODUCTO, categoriaCanon } from "./categoriasProducto";

function parseCsv(text) {
  const lines = String(text || "").trim().split(/\r?\n/).filter(Boolean);
  const header = lines[0].split(",");
  return lines.slice(1).map((line) => {
    const cols = [];
    let cur = "";
    let q = false;
    for (const ch of line) {
      if (ch === '"') {
        q = !q;
        continue;
      }
      if (ch === "," && !q) {
        cols.push(cur);
        cur = "";
        continue;
      }
      cur += ch;
    }
    cols.push(cur);
    const row = {};
    header.forEach((h, i) => { row[h] = cols[i] ?? ""; });
    return row;
  });
}

describe("catalogo_propuesta_vitaminas_electrolitos.csv", () => {
  const rows = parseCsv(
    readFileSync(join(__dirname, "../../docs/catalogo_propuesta_vitaminas_electrolitos.csv"), "utf8")
  );

  test("es borrador: ninguna fila lista para cargar", () => {
    expect(rows.length).toBeGreaterThan(0);
    for (const r of rows) {
      expect(r.listo_para_cargar).toBe("false");
      expect(String(r.notas_importacion || "")).toMatch(/NO CARGAR/i);
      expect(r.nombre).toBe("");
      expect(r.sku).toBe("");
    }
  });

  test("categorías son canónicas (no «Hidratación / electrolitos»)", () => {
    for (const r of rows) {
      expect(CATEGORIAS_PRODUCTO).toContain(r.categoria);
      expect(categoriaCanon(r.categoria)).toBe(r.categoria);
      expect(r.categoria).not.toMatch(/electrolitos/i);
    }
  });
});
