// InventarioHub: shell con tabs — Catálogo, Reabasto, Lotes PEPS, Referencias.
// Recibir NO es una tab de aquí: es otra pantalla del menú (RecepcionModule),
// para no arrastrar el catálogo mientras se descargan cajas.
// Cada tab carga lazy para no inflar el bundle inicial.
import React, { lazy, Suspense, useState, useEffect } from "react";
import { useMediaQuery } from "./hooks/useMediaQuery";
import { useDecisionesPrecios } from "./hooks/useDecisionesPrecios";
import { SkeletonCard } from "./ui";
import { C_LIGHT, BRAND } from "./constants";
import { Package, Truck, Tags, TrendingUp, BadgeCheck, Percent, ShoppingBag } from "lucide-react";

const InventarioModule = lazy(() => import("./InventarioModule"));
const ReabastoModule   = lazy(() => import("./ReabastoModule"));
const LotesModule      = lazy(() => import("./LotesModule"));
const PreciosReferenciaModule = lazy(() => import("./PreciosReferenciaModule"));
const MonitorPreciosModule    = lazy(() => import("./MonitorPreciosModule"));
const DescuentoCaducidadModule = lazy(() => import("./DescuentoCaducidadModule"));
const MarketplaceHub          = lazy(() => import("./MarketplaceHub"));

const TABS_VENDEDOR = ["catalogo"];

const TABS = [
  { id: "catalogo", label: "Catálogo",   icon: Package },
  { id: "reabasto", label: "Reabasto",   icon: Truck },
  { id: "lotes",    label: "Lotes PEPS", icon: Tags },
  { id: "precios",  label: "Referencias de precio", icon: TrendingUp, labelMobile: "Precios" },
  { id: "aprobar",  label: "Aprobar PVP", icon: BadgeCheck, labelMobile: "Aprobar" },
  { id: "caducidad", label: "Precio por caducar", icon: Percent, labelMobile: "Caducar" },
  { id: "rappi",    label: "Marketplaces", icon: ShoppingBag, labelMobile: "Apps" },
];

const STORAGE_KEY = "farmacapital_inv_tab";

function badgeStyle(C, amber) {
  return {
    minWidth: 16,
    height: 16,
    padding: "0 5px",
    borderRadius: 999,
    background: amber ? C.amber : C.teal,
    color: "#fff",
    fontSize: 10,
    fontWeight: 800,
    lineHeight: "16px",
    textAlign: "center",
  };
}

export default function InventarioHub({ initialTab, usuario, onNavigate }) {
  const C = C_LIGHT;
  const isMobile = useMediaQuery("(max-width: 768px)");
  const modoConsulta = usuario?.rol === "vendedor";
  const tabsVisibles = modoConsulta
    ? TABS_VENDEDOR.map((id) => TABS.find((t) => t.id === id)).filter(Boolean)
    : TABS;
  const tabPermitida = (id) => tabsVisibles.some((t) => t.id === id);
  const dec = useDecisionesPrecios({ enabled: !modoConsulta });
  const [tab, setTab] = useState(() => {
    const fromProp = initialTab && TABS.some((t) => t.id === initialTab) ? initialTab : null;
    if (fromProp && (!modoConsulta || TABS_VENDEDOR.includes(fromProp))) return fromProp;
    try {
      const saved = sessionStorage.getItem(STORAGE_KEY);
      if (saved && TABS.some((t) => t.id === saved) && (!modoConsulta || TABS_VENDEDOR.includes(saved))) return saved;
    } catch (_) { /* storage bloqueado */ }
    return "catalogo";
  });

  /** Recibir vive fuera del hub: se sale a esa pantalla del menú. */
  const irARecibir = () => { if (onNavigate) onNavigate("recibir"); };

  const selectTab = (id) => {
    if (!tabPermitida(id)) return;
    setTab(id);
    try { sessionStorage.setItem(STORAGE_KEY, id); } catch (_) { /* noop */ }
  };

  useEffect(() => {
    if (!tabPermitida(tab)) setTab("catalogo");
  }, [modoConsulta, tab]);

  // Si el padre cambia el initialTab (deep-link desde Dashboard u otro módulo) mientras
  // el hub ya está montado, cambiamos a esa tab.
  useEffect(() => {
    if (initialTab && TABS.some((t) => t.id === initialTab) && tabPermitida(initialTab) && initialTab !== tab) {
      setTab(initialTab);
      try { sessionStorage.setItem(STORAGE_KEY, initialTab); } catch (_) { /* noop */ }
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [initialTab, modoConsulta]);

  return (
    <div style={{background: C.bg, minHeight: "100dvh", fontFamily: "var(--fc-body)"}}>
      <div style={{
        padding: "18px 24px 0 24px",
        borderBottom: `1px solid ${C.border}`,
        background: C.card,
        position: "sticky", top: 0, zIndex: 10,
      }}>
        <div style={{display: "flex", alignItems: "center", gap: 10, marginBottom: 12, flexWrap: "wrap"}}>
          <h1 style={{margin: 0, color: C.text, fontSize: 20, fontWeight: 800}}>◆ Inventario</h1>
          {!isMobile && (
            <span style={{color: C.textDim, fontSize: 12}}>
              {modoConsulta
                ? "Consulta de existencias"
                : "Catálogo · reabasto · lotes · referencias · apps"}
            </span>
          )}
        </div>
        <div style={{
          display: "flex",
          gap: 6,
          flexWrap: isMobile ? "nowrap" : "wrap",
          overflowX: isMobile ? "auto" : "visible",
          WebkitOverflowScrolling: "touch",
          marginBottom: -1,
          scrollbarWidth: "thin",
        }}>
          {tabsVisibles.map((t) => {
            const active = tab === t.id;
            const Icon = t.icon;
            const label = isMobile && t.labelMobile ? t.labelMobile : t.label;
            const iconSz = isMobile ? 18 : 15;
            return (
              <button
                key={t.id}
                type="button"
                onClick={() => selectTab(t.id)}
                style={{
                  display: "inline-flex", alignItems: "center", gap: 6,
                  padding: "10px 14px", marginBottom: -1,
                  background: "transparent", border: "none",
                  borderBottom: `2px solid ${active ? BRAND.primary : "transparent"}`,
                  color: active ? BRAND.primary : C.textMid,
                  fontWeight: 700, fontSize: 13, cursor: "pointer",
                  transition: "color .15s, border-color .15s",
                  flexShrink: 0,
                  whiteSpace: "nowrap",
                }}
                onMouseEnter={(e) => { if (!active) e.currentTarget.style.color = C.text; }}
                onMouseLeave={(e) => { if (!active) e.currentTarget.style.color = C.textMid; }}
              >
                <Icon size={iconSz} strokeWidth={2.1} />
                {label}
                {!modoConsulta && t.id === "precios" && dec.resumen.total > 0 && (
                  <span style={badgeStyle(C, true)}>{dec.resumen.total}</span>
                )}
                {!modoConsulta && t.id === "rappi" && dec.resumen.rappi > 0 && (
                  <span style={badgeStyle(C, false)}>{dec.resumen.rappi}</span>
                )}
              </button>
            );
          })}
        </div>
      </div>

      <Suspense fallback={
        <div style={{padding: 24, display: "flex", flexDirection: "column", gap: 12}}>
          <SkeletonCard height={48} />
          <SkeletonCard height={120} />
          <SkeletonCard height={120} />
        </div>
      }>
        {tab === "catalogo" && (
          <InventarioModule
            modoConsulta={modoConsulta}
            onIrARecibir={irARecibir}
            refsByProduct={dec.refsByProduct}
          />
        )}
        {!modoConsulta && tab === "reabasto" && <ReabastoModule/>}
        {!modoConsulta && tab === "lotes"    && <LotesModule/>}
        {!modoConsulta && tab === "precios"  && <PreciosReferenciaModule/>}
        {!modoConsulta && tab === "aprobar" && <MonitorPreciosModule/>}
        {!modoConsulta && tab === "caducidad" && <DescuentoCaducidadModule/>}
        {!modoConsulta && tab === "rappi"    && <MarketplaceHub decisiones={dec}/>}
      </Suspense>
    </div>
  );
}
