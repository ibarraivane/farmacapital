import { useState } from "react";
import { C_LIGHT } from "./constants";
import { DashboardNavTab } from "./DashboardModule";

const TABS = ["proyecto", "operacion", "resumen", "transacciones", "margen", "flujo"];

/** Vista local (dev) de las pestañas del dashboard, sin login de admin. */
export default function DashboardTabsPreview() {
  const C = C_LIGHT;
  const [active, setActive] = useState("flujo");
  return (
    <div style={{ padding: 32, background: C.bg, minHeight: "100vh", fontFamily: "var(--fc-body)" }}>
      <h1 style={{ margin: "0 0 4px", color: C.text, fontSize: 20, fontWeight: 800 }}>Dashboard y reportes</h1>
      <p style={{ margin: "0 0 20px", color: C.textMid, fontSize: 12 }}>Vista previa de pestañas · Flujo de caja activo</p>
      <div
        className="fc-dash-tabs"
        style={{
          display: "flex",
          alignItems: "stretch",
          gap: 2,
          flexWrap: "nowrap",
          borderBottom: `1px solid ${C.border}`,
          overflowX: "auto",
        }}
      >
        {TABS.map((id, i) => (
          <div key={id} style={{ display: "flex", alignItems: "stretch", flexShrink: 0 }}>
            {i === 1 && (
              <span
                aria-hidden
                style={{
                  width: 1,
                  alignSelf: "center",
                  height: 18,
                  background: C.border,
                  margin: "0 8px",
                }}
              />
            )}
            <DashboardNavTab
              id={id}
              active={active === id}
              onClick={() => setActive(id)}
              isMobile={false}
            />
          </div>
        ))}
      </div>
    </div>
  );
}
