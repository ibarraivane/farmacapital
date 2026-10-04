const fs = require("fs");
const path = require("path");

const ROOT = path.join(__dirname, "../..");
const SQL = path.join(ROOT, "sql/patch_foto_aktyzar_omeprazol_20mg_c14_20261004.sql");
const DIR = path.join(ROOT, "public/catalogo-propia");

const FOTOS = [
  ["EQ-SOF066", "aktyzar-omeprazol-20mg-c-14-capsulas-7502274792207.jpg"],
  ["FC-C721E8D7", "levofloxacino-amsa-500-mg-c-7-tabletas-7501349021419-caja-20261002.jpg"],
  ["FC-11294615", "amikacina-amsa-500-mg-2ml-c-2-ampolletas-7501349021488.jpg"],
  ["EQ-MAV007", "cefalver-cefalexina-susp-125mg-5ml-90ml-7503000422610.jpg"],
  ["broxtorfan-adulto", "broxtorfan-adulto-ambroxol-dextrometorfano-jarabe-120ml-7501573907992-caja-20261002.jpg"],
];

describe("fotos de caja 02-oct en el producto vivo", () => {
  test("cada packshot está en catalogo-propia", () => {
    for (const [, file] of FOTOS) {
      const buf = fs.readFileSync(path.join(DIR, file));
      expect(buf.length).toBeGreaterThan(15000);
      expect(buf[0]).toBe(0xff);
      expect(buf[1]).toBe(0xd8);
    }
  });

  test("el SQL pega cada caja a su SKU y deja fuera las presentaciones vecinas", () => {
    const sql = fs.readFileSync(SQL, "utf8");
    const altas = sql.split("insert into tmp_foto_caja")[1].split(";")[0];
    for (const [sku, file] of FOTOS) {
      if (sku !== "broxtorfan-adulto") expect(altas).toContain(`'${sku}'`);
      expect(sql).toContain(file);
    }
    expect(altas).not.toContain("FC-82200016");
    expect(altas).not.toContain("FC-74792207");
    expect(altas).not.toContain("EQ-MAV008");
    expect(altas).not.toContain("EQ-BIO188");
    expect(sql).toContain("p.sku <> 'EQ-BIO188'");
    expect(sql).toContain("p.codigo_barras = '7501573907992'");
    expect(sql).not.toContain("codigo_barras = '7502274792207'");
  });
});
