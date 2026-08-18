// InventarioHub: shell con tabs — Catálogo, Reabasto, Lotes PEPS, Referencias de precio.
// Los módulos internos se mantienen intactos; solo cambia la forma de entrar.
// Cada tab carga lazy para no inflar el bundle inicial.
import React, { lazy, Suspense, useState, useEffect } from "react";
import { useMediaQuery } from "./hooks/useMediaQuery";
import { SkeletonCard } from "./ui";
import { C_LIGHT, BRAND } from "./constants";
import { Package, Truck, Tags, TrendingUp } from "lucide-react";

const InventarioModule = lazy(() => import("./InventarioModule"));
const ReabastoModule   = lazy(() => import("./ReabastoModule"));
const LotesModule      = lazy(() => import("./LotesModule"));
const PreciosReferenciaModule = lazy(() => import("./PreciosReferenciaModule"));

const TABS = [
  { id: "catalogo", label: "Catálogo",   icon: Package },
  { id: "reabasto", label: "Reabasto",   icon: Truck },
  { id: "lotes",    label: "Lotes PEPS", icon: Tags },
  { id: "precios",  label: "Referencias de precio", icon: TrendingUp, labelMobile: "Precios" },
];

const STORAGE_KEY = "farmacapital_inv_tab";

export default function InventarioHub({ initialTab, usuario }) {
  const C = C_LIGHT;
  const isMobile = useMediaQuery("(max-width: 768px)");
  const modoConsulta = usuario?.rol === "vendedor";
  const tabsVisibles = modoConsulta ? TABS.filter((t) => t.id === "catalogo") : TABS;
  const [tab, setTab] = useState(() => {
    if (usuario?.rol === "vendedor") return "catalogo";
    const fromProp = initialTab && TABS.some((t) => t.id === initialTab) ? initialTab : null;
    if (fromProp) return fromProp;
    try {
      const saved = sessionStorage.getItem(STORAGE_KEY);
      if (saved && TABS.some((t) => t.id === saved)) return saved;
    } catch (_) { /* storage bloqueado */ }
    return "catalogo";
  });

  const selectTab = (id) => {
    if (modoConsulta && id !== "catalogo") return;
    setTab(id);
    try { sessionStorage.setItem(STORAGE_KEY, id); } catch (_) { /* noop */ }
  };

  useEffect(() => {
    if (modoConsulta && tab !== "catalogo") setTab("catalogo");
  }, [modoConsulta, tab]);

  // Si el padre cambia el initialTab (deep-link desde Dashboard u otro módulo) mientras
  // el hub ya está montado, cambiamos a esa tab.
  useEffect(() => {
    if (modoConsulta) return;
    if (initialTab && TABS.some((t) => t.id === initialTab) && initialTab !== tab) {
      setTab(initialTab);
      try { sessionStorage.setItem(STORAGE_KEY, initialTab); } catch (_) { /* noop */ }
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [initialTab, modoConsulta]);

  return (
    <div style={{background: C.bg, minHeight: "100dvh", fontFamily: "'Plus Jakarta Sans',sans-serif"}}>
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
                ? "Consulta de existencias y caducidad"
                : "Catálogo · reabasto · lotes · referencias de precio"}
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
          {!modoConsulta && tabsVisibles.map((t) => {
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
        {tab === "catalogo" && <InventarioModule modoConsulta={modoConsulta}/>}
        {!modoConsulta && tab === "reabasto" && <ReabastoModule/>}
        {!modoConsulta && tab === "lotes"    && <LotesModule/>}
        {!modoConsulta && tab === "precios"  && <PreciosReferenciaModule/>}
      </Suspense>
    </div>
  );
}
