import { readFileSync } from "fs";
import { join } from "path";
import { rubroDeProducto } from "./bajoPedido";

const sql = readFileSync(
  join(__dirname, "../../sql/patch_alta_bajo_pedido_vitrina_20260916.sql"),
  "utf8"
);

function filas() {
  const block = sql.split("insert into _fc_vitrina_bp values")[1].split("\ninsert into")[0];
  const out = [];
  const re =
    /\('(\d+)',\s*'([^']+)',\s*'((?:[^']|'')+)',\s*'((?:[^']|'')+)',\s*'((?:[^']|'')+)',\s*'((?:[^']|'')+)',\s*('(?:[^']|'')+'|null),\s*'((?:[^']|'')+)',\s*(\d+)::numeric/g;
  let m;
  while ((m = re.exec(block))) {
    out.push({
      ean: m[1],
      sku: m[2],
      nombre: m[3].replace(/''/g, "'"),
      marca: m[4].replace(/''/g, "'"),
      categoria: m[6].replace(/''/g, "'"),
      subcategoria: m[7] === "null" ? "" : m[7].slice(1, -1).replace(/''/g, "'"),
      precio: Number(m[9]),
    });
  }
  return out;
}

describe("lote vitrina bajo pedido 20260916", () => {
  const rows = filas();

  test("26 SKUs con EAN y ancla, sin caducidad inventada", () => {
    expect(rows).toHaveLength(26);
    expect(sql).not.toMatch(/0000/);
    expect(sql).toMatch(/bajo_pedido/);
    for (const r of rows) {
      expect(r.ean.length).toBeGreaterThanOrEqual(12);
      expect(r.sku).toMatch(/^FC-\d{8}$/);
      expect(r.precio).toBeGreaterThan(1);
    }
  });

  test("incluye Effaclar, Isdin y SVR con rubro dermatología", () => {
    const marcas = rows.map((r) => r.marca);
    expect(marcas).toEqual(expect.arrayContaining(["La Roche-Posay", "Isdin", "SVR"]));
    const derm = rows.filter((r) =>
      /Effaclar|Isdin|SVR|CeraVe|Eucerin|Avène/.test(r.nombre + r.marca)
    );
    for (const r of derm) {
      expect(rubroDeProducto({ ...r, bajo_pedido: true })).toBe("dermatologia");
    }
  });

  test("los 4 rubros de la vitrina tienen al menos un SKU", () => {
    const rubros = new Set(
      rows.map((r) => rubroDeProducto({ ...r, bajo_pedido: true }))
    );
    expect([...rubros].sort()).toEqual(["dermatologia", "proteina", "suplementos", "vitaminas"]);
  });
});
