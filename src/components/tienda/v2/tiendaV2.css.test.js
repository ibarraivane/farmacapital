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

test("no pinta body global ni tokens de Admin", () => {
  expect(css).not.toMatch(/(^|\n)\s*body\s*\{/);
  expect(css).not.toMatch(/#C9451F/);
  expect(css).toMatch(/\.fc-v2 \.cta\.dark/);
  expect(css).toMatch(/prefers-reduced-motion/);
});
