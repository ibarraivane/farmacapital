import { useState } from "react";
import { C_LIGHT } from "./constants";
import { Logo } from "./ui";
import { AdminCollapsedTopbar, AdminNavToggle } from "./components/AdminChrome";
import {
  ADMIN_SIDEBAR_WIDTH_PX,
  adminMainMarginLeftPx,
  adminSidebarIsOverlay,
} from "./utils/adminSidebarCollapse";

const C = C_LIGHT;
const ROWS = [
  ["Tegaderm 1624W", "4001895928765", "12", "$325.00"],
  ["Paracetamol 500 mg", "7501000000001", "48", "$18.50"],
  ["Omeprazol 20 mg", "7501000000002", "30", "$42.00"],
  ["Suero oral 1 L", "7501000000003", "16", "$28.90"],
  ["Ibuprofeno 400 mg", "7501000000004", "24", "$22.00"],
];

/** Vista local (dev): menú izquierdo minimizable, sin login. */
export default function AdminSidebarPreview() {
  const [collapsed, setCollapsed] = useState(false);
  const [navOpen, setNavOpen] = useState(false);
  const overlay = adminSidebarIsOverlay({ isMobile: false, collapsed });
  const marginLeft = adminMainMarginLeftPx({ isMobile: false, collapsed });

  return (
    <div
      className="farmacapital-admin-root"
      data-sidebar-collapsed={collapsed ? "1" : "0"}
      style={{ background: C.bg, minHeight: "100vh", fontFamily: "var(--fc-body)", color: C.text }}
    >
      {overlay && navOpen && (
        <div
          role="presentation"
          onClick={() => setNavOpen(false)}
          style={{ position: "fixed", inset: 0, zIndex: 2099, background: "rgba(15,23,42,.45)" }}
        />
      )}
      {collapsed && (
        <AdminCollapsedTopbar
          title="Inventario"
          navOpen={navOpen}
          onToggleNav={() => setNavOpen((o) => !o)}
          onPin={() => { setCollapsed(false); setNavOpen(false); }}
        />
      )}
      <div
        className="farmacapital-admin-sidebar"
        data-overlay={overlay ? "1" : "0"}
        style={{
          width: ADMIN_SIDEBAR_WIDTH_PX,
          position: "fixed",
          left: overlay ? (navOpen ? 0 : -ADMIN_SIDEBAR_WIDTH_PX) : 0,
          top: overlay ? 52 : 0,
          height: overlay ? "calc(100vh - 52px)" : "100vh",
          zIndex: overlay ? 2101 : 100,
          background: C.card,
          borderRight: `1px solid ${C.border}`,
          boxSizing: "border-box",
          padding: 14,
          transition: "left .22s ease",
        }}
      >
        <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", gap: 8 }}>
          <Logo size={32} showText />
          {!collapsed && (
            <AdminNavToggle
              expanded
              compact
              label="Minimizar menú de navegación"
              onClick={() => { setCollapsed(true); setNavOpen(false); }}
            />
          )}
        </div>
        <div style={{ marginTop: 18, fontSize: 12, fontWeight: 700, color: C.textMid }}>Inventario</div>
        <div style={{ marginTop: 8, fontSize: 12, color: C.textDim }}>Dashboard</div>
        <div style={{ marginTop: 8, fontSize: 12, color: C.textDim }}>Recibir</div>
      </div>
      <main
        className="farmacapital-admin-main"
        style={{
          marginLeft,
          padding: collapsed ? "72px 24px 24px" : 24,
          transition: "margin-left .22s ease",
        }}
      >
        <h1 style={{ margin: "0 0 8px", fontSize: 20, fontWeight: 800 }}>Inventario</h1>
        <p style={{ margin: "0 0 16px", color: C.textMid, fontSize: 13 }}>
          Vista de ejemplo · pulsá ☰ para estirar la tabla a todo el ancho
        </p>
        <table style={{ width: "100%", borderCollapse: "collapse", background: C.card, fontSize: 13 }}>
          <thead>
            <tr style={{ textAlign: "left", borderBottom: `1px solid ${C.border}` }}>
              <th style={{ padding: "10px 12px" }}>Producto</th>
              <th style={{ padding: "10px 12px" }}>EAN</th>
              <th style={{ padding: "10px 12px" }}>Stock</th>
              <th style={{ padding: "10px 12px" }}>Precio</th>
            </tr>
          </thead>
          <tbody>
            {ROWS.map((row) => (
              <tr key={row[1]} style={{ borderBottom: `1px solid ${C.border}` }}>
                {row.map((cell) => (
                  <td key={cell} style={{ padding: "10px 12px", whiteSpace: "nowrap" }}>{cell}</td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </main>
    </div>
  );
}
