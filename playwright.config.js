// @ts-check
/** Navegadores dentro de node_modules (evita caché global con arquitectura incorrecta). */
process.env.PLAYWRIGHT_BROWSERS_PATH = process.env.PLAYWRIGHT_BROWSERS_PATH || "0";

const { defineConfig } = require("@playwright/test");

/**
 * Requiere `npm run build` antes (o CI que construya el artefacto).
 * Sirve el directorio `build/` en 4173 y ejecuta pruebas de layout móvil.
 */
module.exports = defineConfig({
  testDir: "./e2e",
  timeout: 90_000,
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 1 : 0,
  reporter: [["list"], ["html", { open: "never", outputFolder: "playwright-report" }]],
  use: {
    baseURL: "http://127.0.0.1:4173",
    trace: "on-first-retry",
  },
  webServer: {
    command: "npx serve -s build -l 4173",
    url: "http://127.0.0.1:4173",
    reuseExistingServer: !process.env.CI,
    timeout: 120_000,
  },
});
