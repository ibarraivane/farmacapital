import { useState } from "react";
import { Banknote, BarChart3, Receipt } from "lucide-react";
import { C_LIGHT } from "./constants";
import { DashboardTabsRail } from "./DashboardModule";
import { SegmentedNav } from "./components/SegmentedNav";

const OPERATIVAS = ["operacion", "resumen", "transacciones", "margen", "flujo"];

/** Vista local (dev) de las pestañas del dashboard, sin login de admin. */
export default function DashboardTabsPreview() {
  const C = C_LIGHT;
  const [active, setActive] = useState("flujo");
  const [sub, setSub] = useState("flujo");
  return (
    <div style={{ padding: 32, background: C.bg, minHeight: "100vh", fontFamily: "var(--fc-body)" }}>
      <h1 style={{ margin: "0 0 4px", color: C.text, fontSize: 20, fontWeight: 800 }}>Dashboard y reportes</h1>
      <p style={{ margin: "0 0 20px", color: C.textMid, fontSize: 12 }}>
        Riel tipo Vercel Geist / shadcn · Flujo de caja activo
      </p>
      <DashboardTabsRail
        activeId={active}
        onSelect={setActive}
        operativaIds={OPERATIVAS}
        showProyecto
        isMobile={false}
      />
      {active === "flujo" && (
        <SegmentedNav
          ariaLabel="Secciones de flujo de caja"
          value={sub}
          onChange={setSub}
          items={[
            { id: "flujo", label: "Flujo", Icon: Banknote },
            { id: "resultados", label: "Resultados · pronto", Icon: BarChart3, disabled: true },
            { id: "gastos", label: "Gastos", Icon: Receipt },
          ]}
        />
      )}
    </div>
  );
}
