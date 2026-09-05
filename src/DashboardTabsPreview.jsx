import { useState } from "react";
import { Award, Banknote, BarChart3, CircleDollarSign, HeartPulse, Hourglass, Receipt, SlidersHorizontal, Stethoscope, Syringe, TrendingUp, UserRound } from "lucide-react";
import { C_LIGHT } from "./constants";
import { DashboardTabsRail } from "./DashboardModule";
import { SegmentedNav } from "./components/SegmentedNav";
import { PageHero } from "./components/AdminChrome";

const OPERATIVAS = ["operacion", "resumen", "transacciones", "margen", "flujo"];

/** Vista local (dev) de las pestañas del dashboard, sin login de admin. */
export default function DashboardTabsPreview() {
  const C = C_LIGHT;
  const [active, setActive] = useState("flujo");
  const [sub, setSub] = useState("flujo");
  const [periodo, setPeriodo] = useState("mes");
  const [consTab, setConsTab] = useState("consulta");
  const [metasTab, setMetasTab] = useState("finanzas");
  return (
    <div style={{ padding: 32, background: C.bg, minHeight: "100vh", fontFamily: "var(--fc-body)" }}>
      <h1 style={{ margin: "0 0 4px", color: C.text, fontSize: 20, fontWeight: 800 }}>Dashboard y reportes</h1>
      <p style={{ margin: "0 0 20px", color: C.textMid, fontSize: 12 }}>
        md = sección · sm = vista · mismo riel en todos los módulos
      </p>
      <DashboardTabsRail
        activeId={active}
        onSelect={setActive}
        operativaIds={OPERATIVAS}
        showProyecto
        isMobile={false}
      />
      {active === "flujo" && (
        <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>
          <SegmentedNav
            size="sm"
            activation="auto"
            ariaLabel="Secciones de flujo de caja"
            value={sub}
            onChange={setSub}
            items={[
              { id: "flujo", label: "Flujo", Icon: Banknote },
              { id: "resultados", label: "Resultados · pronto", Icon: BarChart3, disabled: true, title: "P&L bloqueado: falta la cobertura de costo de lo vendido (consulta 4)." },
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
