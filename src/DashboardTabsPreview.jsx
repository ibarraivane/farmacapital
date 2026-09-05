import { useState } from "react";
import { Banknote, BarChart3, Receipt } from "lucide-react";
import { C_LIGHT } from "./constants";
import { DashboardTabsRail } from "./DashboardModule";
import { SegmentedNav } from "./components/SegmentedNav";
import { Switch } from "./components/Switch";

const OPERATIVAS = ["operacion", "resumen", "transacciones", "margen", "flujo"];

/** Vista local (dev) de las pestañas del dashboard, sin login de admin. */
export default function DashboardTabsPreview() {
  const C = C_LIGHT;
  const [active, setActive] = useState("flujo");
  const [sub, setSub] = useState("flujo");
  const [periodo, setPeriodo] = useState("mes");
  const [sinCompra, setSinCompra] = useState(false);
  const [incluir, setIncluir] = useState(true);
  return (
    <div style={{ padding: 32, background: C.bg, minHeight: "100vh", fontFamily: "var(--fc-body)" }}>
      <h1 style={{ margin: "0 0 4px", color: C.text, fontSize: 20, fontWeight: 800 }}>Dashboard y reportes</h1>
      <p style={{ margin: "0 0 20px", color: C.textMid, fontSize: 12 }}>
        md = sección · sm = vista · Flujo de caja activo
      </p>
      <DashboardTabsRail
        activeId={active}
        onSelect={setActive}
        operativaIds={OPERATIVAS}
        showProyecto
        isMobile={false}
      />
      {active === "flujo" && (
        <div
          id="dash-panel-flujo"
          role="tabpanel"
          aria-labelledby="dash-tab-flujo"
          tabIndex={0}
        >
          <div className="fc-flujo-rails">
            <SegmentedNav
              size="sm"
              activation="auto"
              idPrefix="flujo"
              ariaLabel="Secciones de flujo de caja"
              value={sub}
              onChange={setSub}
              items={[
                { id: "flujo", label: "Flujo", Icon: Banknote },
                { id: "resultados", label: "Resultados · pronto", Icon: BarChart3, disabled: true, title: "Disponible cuando el sistema sepa cuánto costó lo que vendiste." },
                { id: "gastos", label: "Gastos", Icon: Receipt },
              ]}
            />
            <SegmentedNav
              size="sm"
              activation="auto"
              ariaLabel="Período del flujo"
              value={periodo}
              onChange={setPeriodo}
              items={[
                { id: "dia", label: "Hoy" },
                { id: "semana", label: "Esta semana" },
                { id: "mes", label: "Este mes" },
              ]}
            />
          </div>
          <div style={{ display: "flex", gap: 18, flexWrap: "wrap", marginTop: 8 }}>
            <Switch
              id="prev-sin-compra"
              checked={sinCompra}
              onChange={setSinCompra}
              label="Este mes no compré a proveedor"
            />
            <Switch
              id="prev-incluir"
              checked={incluir}
              onChange={setIncluir}
              label="Incluir canceladas"
            />
          </div>
        </div>
      )}
    </div>
  );
}
