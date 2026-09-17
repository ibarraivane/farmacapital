// @ts-check
const { test, expect } = require("@playwright/test");

/**
 * Tras navegar dentro de la SPA (misma URL), el scroll debe volver arriba.
 * Regresión: Safari restauraba posición y la vista quedaba en el footer.
 */
async function scrollDown(page, y = 1200) {
  await page.evaluate((yy) => window.scrollTo(0, yy), y);
  const sy = await page.evaluate(() => window.scrollY);
  expect(sy, "scroll manual no aplicó (página muy corta en build vacío?)").toBeGreaterThan(80);
}

test.describe("tienda — scroll al cambiar de página", () => {
  test("móvil: carrito y registro dejan la vista arriba", async ({ page }) => {
    await page.setViewportSize({ width: 390, height: 844 });
    await page.goto("/", { waitUntil: "domcontentloaded", timeout: 60_000 });
    await page.waitForTimeout(600);

    await scrollDown(page);
    await page.getByRole("button", { name: "Ir al carrito" }).click();
    await page.waitForTimeout(200);
    let top = await page.evaluate(() => window.scrollY);
    expect(top, "carrito debe abrir con scroll arriba").toBeLessThan(120);

    await scrollDown(page);
    await page.getByRole("button", { name: "Registro" }).click();
    await page.waitForTimeout(200);
    top = await page.evaluate(() => window.scrollY);
    expect(top, "registro debe abrir con scroll arriba").toBeLessThan(120);
    await expect(page.getByRole("heading", { name: /Crear cuenta FarmaCapital/i })).toBeVisible();
  });

  test("escritorio: body/main no son scrollports (la rueda baja la página)", async ({ page }) => {
    await page.setViewportSize({ width: 1280, height: 720 });
    await page.goto("/", { waitUntil: "domcontentloaded", timeout: 60_000 });
    await page.waitForTimeout(600);

    const info = await page.evaluate(() => {
      const take = (el) => {
        if (!el) return null;
        const s = getComputedStyle(el);
        return { ox: s.overflowX, oy: s.overflowY };
      };
      return {
        html: take(document.documentElement),
        body: take(document.body),
        main: take(document.querySelector("main")),
        shell: take(document.querySelector(".farmacapital-tienda-shell")),
      };
    });

    expect(["auto", "scroll"]).toContain(info.html.oy);
    for (const key of ["body", "main", "shell"]) {
      const n = info[key];
      if (!n) continue;
      expect(n.oy, `${key} overflow-y=${n.oy}`).not.toMatch(/auto|scroll/);
      expect(n.ox, `${key} overflow-x=${n.ox}`).not.toBe("hidden");
    }

    await page.evaluate(() => {
      const pad = document.createElement("div");
      pad.style.height = "2400px";
      pad.setAttribute("data-testid", "farmacapital-scroll-pad");
      (document.querySelector("main") || document.body).appendChild(pad);
    });
    await page.mouse.move(200, 80);
    await page.mouse.wheel(0, 900);
    const top = await page.evaluate(() => window.scrollY);
    expect(top, "rueda del mouse no bajó la página en escritorio").toBeGreaterThan(80);
  });

  test("escritorio: carrito deja la vista arriba", async ({ page }) => {
    await page.setViewportSize({ width: 1280, height: 720 });
    await page.goto("/", { waitUntil: "domcontentloaded", timeout: 60_000 });
    await page.waitForTimeout(600);

    await scrollDown(page, 900);
    await page.getByRole("button", { name: "Ir al carrito" }).click();
    await page.waitForTimeout(200);
    const top = await page.evaluate(() => window.scrollY);
    expect(top).toBeLessThan(120);
  });
});
