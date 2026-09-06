import { useState } from "react";
import { Award, Banknote, CircleDollarSign, HeartPulse, Hourglass, SlidersHorizontal, Stethoscope, Syringe, TrendingUp, UserRound } from "lucide-react";
import { C_LIGHT } from "./constants";
import { DashboardTabsRail } from "./DashboardModule";
import { SegmentedNav } from "./components/SegmentedNav";
import { PageHero } from "./components/AdminChrome";
import FlujoCajaTab from "./FlujoCajaTab";
import { FLUJO_DEMO_BUNDLE } from "./lib/flujoCajaDemo";

const OPERATIVAS = ["operacion", "resumen", "transacciones", "margen", "flujo"];

/** Vista local (dev): Flujo completo + rieles de otros módulos, sin login. */
export default function DashboardTabsPreview() {
  const C = C_LIGHT;
  const [active, setActive] = useState("flujo");
  const [consTab, setConsTab] = useState("consulta");
  const [metasTab, setMetasTab] = useState("finanzas");
  return (
    <div style={{ padding: 32, background: C.bg, minHeight: "100vh", fontFamily: "var(--fc-body)" }}>
      <h1 style={{ margin: "0 0 4px", color: C.text, fontSize: 20, fontWeight: 800 }}>Dashboard y reportes</h1>
      <p style={{ margin: "0 0 20px", color: C.textMid, fontSize: 12 }}>
        Vista de ejemplo · Flujo con números del 1–5 de septiembre · no guarda nada
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
          En este preview el contenido armado es Flujo de caja. En el admin, cada pestaña carga lo suyo.
        </p>
      )}

      <div style={{ marginTop: 40 }}>
        <PageHero Icon={Stethoscope} sub="Gestión médica · FarmaCapital" style={{ marginBottom: 16 }}>Consultorio</PageHero>
        <SegmentedNav
          size="md"
          activation="auto"
          ariaLabel="Secciones del consultorio"
          value={consTab}
          onChange={setConsTab}
          items={[
            { id: "espera", label: "Lista de espera", Icon: Hourglass },
            { id: "consulta", label: "En consulta", Icon: HeartPulse },
            { id: "procedimientos", label: "Procedimientos", Icon: Syringe },
            { id: "medicos", label: "Médicos", Icon: UserRound },
          ]}
        />
      </div>

      <div style={{ marginTop: 36 }}>
        <PageHero Icon={SlidersHorizontal} style={{ marginBottom: 16 }}>Metas y Precios</PageHero>
        <SegmentedNav
          size="md"
          activation="auto"
          ariaLabel="Secciones de metas y precios"
          value={metasTab}
          onChange={setMetasTab}
          items={[
            { id: "servicios", label: "Precios de servicios", Icon: CircleDollarSign },
            { id: "ventas", label: "Metas de ventas", Icon: TrendingUp },
            { id: "bonos", label: "Bonos por desempeño", Icon: Award },
            { id: "cons", label: "Metas del consultorio", Icon: Stethoscope },
            { id: "finanzas", label: "Finanzas", Icon: Banknote },
          ]}
        />
      </div>
    </div>
  );
}
