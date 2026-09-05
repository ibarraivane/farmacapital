import { useState } from "react";
import { C_LIGHT } from "./constants";
import { DashboardTabsRail } from "./DashboardModule";
import FlujoCajaTab from "./FlujoCajaTab";
import { FLUJO_DEMO_BUNDLE } from "./lib/flujoCajaDemo";

const OPERATIVAS = ["operacion", "resumen", "transacciones", "margen", "flujo"];

/** Vista local (dev) del riel + Flujo, sin login. Los números son los del 1–5 sep. */
export default function DashboardTabsPreview() {
  const C = C_LIGHT;
  const [active, setActive] = useState("flujo");
  return (
    <div style={{ padding: 32, background: C.bg, minHeight: "100vh", fontFamily: "var(--fc-body)" }}>
      <h1 style={{ margin: "0 0 4px", color: C.text, fontSize: 20, fontWeight: 800 }}>Dashboard y reportes</h1>
      <p style={{ margin: "0 0 20px", color: C.textMid, fontSize: 12 }}>
        Vista de ejemplo · 1–5 de septiembre · no guarda nada
      </p>
      <DashboardTabsRail
        activeId={active}
        onSelect={setActive}
        operativaIds={OPERATIVAS}
        showProyecto
        isMobile={false}
      />
      {active === "flujo" ? (
        <div
          id="dash-panel-flujo"
          role="tabpanel"
          aria-labelledby="dash-tab-flujo"
          tabIndex={0}
        >
          <FlujoCajaTab usuario={{ nombre: "Ivan Ibarra" }} demoBundle={FLUJO_DEMO_BUNDLE} />
        </div>
      ) : (
        <p style={{ color: C.textMid, fontSize: 13, marginTop: 8 }}>
          En este preview solo está armado Flujo de caja. En el admin, cada pestaña carga lo suyo.
        </p>
      )}
    </div>
  );
}
