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
