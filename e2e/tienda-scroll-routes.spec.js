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
    // Varios puntos: el aviso de config, el hero o el centro. Uno tiene que bajar.
    let top = 0;
    for (const [x, y] of [[640, 200], [400, 360], [240, 90]]) {
      await page.evaluate(() => window.scrollTo(0, 0));
      await page.mouse.move(x, y);
      await page.mouse.wheel(0, 900);
      top = await page.evaluate(() => window.scrollY);
      if (top > 80) break;
    }
    expect(top, "rueda del mouse no bajó la página en escritorio").toBeGreaterThan(80);
  });

  test("catálogo: al volver de un producto restaura el scroll", async ({ page }) => {
    await page.setViewportSize({ width: 390, height: 844 });
    await page.addInitScript(() => {
      try {
        sessionStorage.setItem("farmacapital_catalogo_scroll", "900");
        sessionStorage.setItem("farmacapital_catalogo_restore", "1");
      } catch (_) { /* noop */ }
      const addPad = () => {
        if (document.getElementById("e2e-catalogo-pad")) return;
        const host = document.querySelector("main") || document.body;
        if (!host) return;
        const pad = document.createElement("div");
        pad.id = "e2e-catalogo-pad";
        pad.style.height = "3200px";
        host.appendChild(pad);
      };
      const start = () => {
        addPad();
        new MutationObserver(addPad).observe(document.documentElement, { childList: true, subtree: true });
      };
      if (document.body) start();
      else document.addEventListener("DOMContentLoaded", start);
    });
    await page.goto("/catalogo", { waitUntil: "domcontentloaded", timeout: 60_000 });
    await page.waitForTimeout(700);
    const top = await page.evaluate(() => window.scrollY);
    expect(top, "debía volver al tramo del catálogo, no al inicio").toBeGreaterThan(400);
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
