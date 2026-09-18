const { test } = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const crypto = require("node:crypto");

const ROOT = path.resolve(__dirname, "../..");
const SQL = path.join(ROOT, "sql/patch_fotos_lote_capturas_20260918.sql");
const DEST = path.join(ROOT, "public/catalogo-propia");
const PLACEHOLDER_FAHORRO_MD5 = "59370f17d7cac03761209f4b0cf46374";
const PLACEHOLDER_FAHORRO_BYTES = 6334;

const ARCHIVOS = [
  "cubrebocas-tricapa-desechable-negro-c-100-2008500100013.jpg",
  "dona-bolsa-ijj-10-c-12-2008550100018.jpg",
  "copa-lavaojos-de-vidrio-2008490100017.jpg",
  "dorixina-forte-clonixinato-de-lisina-250-mg-c-20-7501300422750.jpg",
  "dosteril-lisinopril-10-mg-c-30-tabletas-7501573925071.jpg",
  "dolxen-naproxeno-250-mg-c-20-maver-7502009740176.jpg",
  "dolac-ketorolaco-sublingual-30-mg-c-6-7501300420824.jpg",
  "debisor-10-mg-c-20-novag-7501075711011.jpg",
  "contraxen-carisoprodol-naproxeno-200-250-mg-c-30-7501836003140.jpg",
  "coniax-citicolina-500-mg-c-10-maver-7502009749322.jpg",
  "savile-desodorante-manzanilla-stick-45-g-75065102.jpg",
  "savile-desodorante-sabila-y-nacar-spray-150-ml-7506306215511.jpg",
  "savile-desodorante-manzanilla-spray-150-ml-7506306209763.jpg",
  "rexona-women-bamboo-roll-on-50-ml-78924345.jpg",
  "old-spice-mar-profundo-spray-150-ml-7500435141796.jpg",
  "lady-speed-stick-powder-fresh-roll-on-50-ml-7509546060477.jpg",
  "lady-speed-stick-powder-fresh-spray-60-g-7509546071275.jpg",
  "gillette-arctic-ice-spray-150-ml-7506309864822.jpg",
  "gillette-cool-wave-roll-on-60-g-7702018913954.jpg",
  "condones-trojan-pro-tech-c-3-7501080950139.jpg",
];

test("SQL no hotlinkea Fahorro y cablea cubrebocas negro + Trojan caja", () => {
  const sql = fs.readFileSync(SQL, "utf8");
  assert.doesNotMatch(sql, /https?:\/\/[^'\s]*fahorro/i);
  assert.match(sql, /2008500100013/);
  assert.match(sql, /cubrebocas-tricapa-desechable-negro/);
  assert.match(sql, /7501080950139/);
  assert.match(sql, /condones-trojan-pro-tech/);
  assert.match(sql, /7501300420824/);
  assert.match(sql, /7501300422750/);
});

test("las 20 JPG existen y no son el placeholder de Del Ahorro", () => {
  assert.equal(ARCHIVOS.length, 20);
  for (const name of ARCHIVOS) {
    const file = path.join(DEST, name);
    assert.ok(fs.existsSync(file), `falta ${name}`);
    const blob = fs.readFileSync(file);
    const md5 = crypto.createHash("md5").update(blob).digest("hex");
    assert.ok(blob.length > 8_000, `${name} muy chica (${blob.length})`);
    assert.notEqual(blob.length, PLACEHOLDER_FAHORRO_BYTES);
    assert.notEqual(md5, PLACEHOLDER_FAHORRO_MD5);
  }
});
