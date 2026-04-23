// @ts-check
const { test, expect } = require("@playwright/test");

/** Viewports mínimos del prompt CURSOR_MOBILE_QA + 320 opcional */
const VIEWPORTS = [
  { width: 360, height: 800, name: "360x800" },
  { width: 390, height: 844, name: "390x844" },
  { width: 412, height: 915, name: "412x915" },
  { width: 768, height: 1024, name: "768x1024" },
  { width: 820, height: 1180, name: "820x1180" },
  { width: 320, height: 568, name: "320x568" },
];

/**
 * Tolerancia: subpíxeles, barras de scroll finas o rounding.
 * @param {import('@playwright/test').Page} page
 */
async function horizontalOverflowPx(page) {
  return page.evaluate(() => {
    const root = document.getElementById("root");
    const scrollEls = [document.documentElement, document.body, root].filter(Boolean);
    let max = 0;
    for (const el of scrollEls) {
      const d = el.scrollWidth - el.clientWidth;
      if (d > max) max = d;
    }
    return max;
  });
}

for (const vp of VIEWPORTS) {
  test.describe(`viewport ${vp.name}`, () => {
    test.use({ viewport: { width: vp.width, height: vp.height } });

    test(`tienda / — sin overflow horizontal relevante`, async ({ page }) => {
      const consoleErrors = [];
      page.on("console", (msg) => {
        if (msg.type() === "error") consoleErrors.push(msg.text());
      });
      await page.goto("/", { waitUntil: "domcontentloaded", timeout: 60_000 });
      await page.waitForTimeout(800);
      const over = await horizontalOverflowPx(page);
      expect(
        over,
        `overflow horizontal ~${over}px (doc/root). Revisar grids o width fijo.`
      ).toBeLessThanOrEqual(8);
      await page.screenshot({
        path: `e2e/artifacts/screenshots/${vp.name}-tienda.png`,
        fullPage: true,
      });
    });

    test(`admin /admin — login o shell sin overflow horizontal relevante`, async ({ page }) => {
      await page.goto("/admin", { waitUntil: "domcontentloaded", timeout: 60_000 });
      await page.waitForTimeout(800);
      const over = await horizontalOverflowPx(page);
      expect(
        over,
        `overflow horizontal ~${over}px en /admin`
      ).toBeLessThanOrEqual(8);
      await page.screenshot({
        path: `e2e/artifacts/screenshots/${vp.name}-admin.png`,
        fullPage: true,
      });
    });
  });
}
