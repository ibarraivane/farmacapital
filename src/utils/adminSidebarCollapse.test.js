import { readFileSync } from "fs";
import { join } from "path";
import {
  ADMIN_SIDEBAR_COLLAPSE_KEY,
  ADMIN_SIDEBAR_WIDTH_PX,
  adminMainMarginLeftPx,
  adminSidebarIsOverlay,
  loadAdminSidebarCollapsed,
  saveAdminSidebarCollapsed,
} from "./adminSidebarCollapse";

describe("adminSidebarCollapse", () => {
  test("en escritorio abierto el main deja 220px; minimizado o móvil ocupa todo el ancho", () => {
    expect(adminSidebarIsOverlay({ isMobile: false, collapsed: false })).toBe(false);
    expect(adminMainMarginLeftPx({ isMobile: false, collapsed: false })).toBe(ADMIN_SIDEBAR_WIDTH_PX);
    expect(adminSidebarIsOverlay({ isMobile: false, collapsed: true })).toBe(true);
    expect(adminMainMarginLeftPx({ isMobile: false, collapsed: true })).toBe(0);
    expect(adminSidebarIsOverlay({ isMobile: true, collapsed: false })).toBe(true);
    expect(adminMainMarginLeftPx({ isMobile: true, collapsed: false })).toBe(0);
  });

  test("persiste la preferencia en localStorage", () => {
    const storage = {
      data: {},
      getItem(key) { return this.data[key] ?? null; },
      setItem(key, value) { this.data[key] = String(value); },
    };
    expect(loadAdminSidebarCollapsed(storage)).toBe(false);
    saveAdminSidebarCollapsed(true, storage);
    expect(storage.data[ADMIN_SIDEBAR_COLLAPSE_KEY]).toBe("1");
    expect(loadAdminSidebarCollapsed(storage)).toBe(true);
    saveAdminSidebarCollapsed(false, storage);
    expect(loadAdminSidebarCollapsed(storage)).toBe(false);
  });

  test("sin storage no truena", () => {
    expect(loadAdminSidebarCollapsed(null)).toBe(false);
    expect(() => saveAdminSidebarCollapsed(true, null)).not.toThrow();
  });

  test("el admin de escritorio minimiza la barra con ☰ y extiende el main", () => {
    const src = readFileSync(join(__dirname, "../Admin.jsx"), "utf8");
    expect(src).toContain("Minimizar menú de navegación");
    expect(src).toContain("persistSidebarCollapsed");
    expect(src).toContain("AdminCollapsedTopbar");
    expect(src).toContain("onPin={()=>persistSidebarCollapsed(false)}");
    expect(src).toContain("adminMainMarginLeftPx");
  });
});
