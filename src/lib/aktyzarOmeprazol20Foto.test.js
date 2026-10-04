const fs = require("fs");
const path = require("path");

const ROOT = path.join(__dirname, "../..");
const JPG = "aktyzar-omeprazol-20mg-c-14-capsulas-7502274792207.jpg";
const SQL = path.join(ROOT, "sql/patch_foto_aktyzar_omeprazol_20mg_c14_20261004.sql");

describe("foto Aktyzar Omeprazol 20 mg C/14", () => {
  test("el packshot de la caja está en catalogo-propia", () => {
    const file = path.join(ROOT, "public/catalogo-propia", JPG);
    const buf = fs.readFileSync(file);
    expect(buf.length).toBeGreaterThan(10000);
    expect(buf[0]).toBe(0xff);
    expect(buf[1]).toBe(0xd8);
  });

  test("el SQL engancha EQ-SOF066 y no el frasco C/120 ni el EAN del LGEN", () => {
    const sql = fs.readFileSync(SQL, "utf8");
    expect(sql).toContain("sku = 'EQ-SOF066'");
    expect(sql).toContain(JPG);
    expect(sql).not.toMatch(/sku = 'FC-82200016'/);
    expect(sql).not.toMatch(/sku = 'FC-74792207'/);
    expect(sql).not.toMatch(/codigo_barras\s*=/);
    expect(sql).not.toMatch(/codigo_barras\s+in/i);
  });
});
