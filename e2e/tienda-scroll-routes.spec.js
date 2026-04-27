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
    await expect(page.getByRole("heading", { name: /Crear cuenta Farmax/i })).toBeVisible();
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
