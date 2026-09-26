const fs = require("fs");
const path = require("path");

const css = fs.readFileSync(path.join(__dirname, "tiendaV2.css"), "utf8");

test("todos los selectores van bajo .fc-v2", () => {
  const loose = css
    .replace(/\/\*[\s\S]*?\*\//g, "")
    .split("}")
    .map((chunk) => chunk.split("{")[0])
    .flatMap((sel) => sel.split(","))
    .map((s) => s.trim())
    .filter(Boolean)
    .filter((s) => !s.startsWith("@") && !s.startsWith("from") && !s.startsWith("to") && !s.startsWith("0%") && !s.startsWith("50%") && !s.startsWith("100%"));
  const bad = loose.filter((s) => !s.includes(".fc-v2"));
  expect(bad).toEqual([]);
});

test("copia los valores exactos del prototipo ChatGPT", () => {
  expect(css).toMatch(/--fc-ink:#001534/);
  expect(css).toMatch(/--fc-blue:#054ABC/);
  expect(css).toMatch(/--fc-jade:#02A158/);
  expect(css).toMatch(/font:400 15px\/1\.5 'Inter'/);
  expect(css).toMatch(/\.fc-serif\{font-family:'Fraunces'/);
  expect(css).toMatch(/prefers-reduced-motion/);
  expect(css).toMatch(/\.fc-search \.fc-textbtn\{white-space:nowrap/);
  expect(css).toMatch(/\.fc-nav-quote\{color:var\(--fc-blue\)\}/);
  expect(css).not.toMatch(/(^|\n)\s*body\s*\{/);
});

test("en celular el menú se desplaza y no esconde una sección", () => {
  expect(css).toMatch(/@media\(max-width:760px\)\{\s*\.fc-v2 \.fc-nav\{flex-wrap:nowrap;overflow-x:auto/);
  expect(css).not.toMatch(/fc-nav button:nth-child\(3\)\{display:none\}/);
  expect(css).toMatch(/\.fc-v2 \.fc-location\{display:none\}/);
});

test("el carrusel mantiene el alto y Cotizar no hereda el fondo del navegador", () => {
  expect(css).toMatch(/\.fc-studio\{[^}]*--fc-studio-media-h:180px;--fc-studio-media-my:-5px/);
  expect(css).toMatch(/\.fc-packshots\{height:var\(--fc-studio-media-h\)/);
  expect(css).toMatch(/\.fc-studio-icono\{height:var\(--fc-studio-media-h\);margin-top:var\(--fc-studio-media-my\);flex:none/);
  expect(css).toMatch(/\.fc-studio-note span\{[^}]*height:2\.7em/);
  expect(css).toMatch(/\.fc-studio-cta\{[^}]*background:transparent/);
  expect(css).toMatch(/\.fc-studio h2\{[^}]*min-height:3\.5em/);
  expect(css).toMatch(/--fc-studio-media-h:130px;--fc-studio-media-my:10px/);
  expect(css).not.toMatch(/\.fc-packshots\{height:130px/);
});

test("la cintilla del menú no deja ver el título a través del encabezado fijo", () => {
  expect(css).toMatch(/\.fc-sticky\{position:sticky;top:0;z-index:80;background:#ffffff !important;isolation:isolate;overscroll-behavior:none;touch-action:pan-y\}/);
  expect(css).toMatch(/\.fc-sticky::before\{content:"";position:absolute;inset:0;background:#ffffff;z-index:-1\}/);
  expect(css).toMatch(/\.fc-nav,\.fc-v2 \.fc-nav button\{background:#ffffff !important\}/);
  expect(css).not.toMatch(/fc-sticky\{position:static\}/);
});
