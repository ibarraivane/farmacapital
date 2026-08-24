// InventarioHub: consulta y operación de catálogo.
// Recibir es otro ítem del menú (RecepcionModule), no una pestaña de este hub.
import React, { lazy, Suspense, useState, useEffect } from "react";
import { useMediaQuery } from "./hooks/useMediaQuery";
import { SkeletonCard } from "./ui";
import { C_LIGHT, BRAND } from "./constants";
import { Package, Truck, Tags, TrendingUp, ShoppingBag, Percent, BadgeCheck } from "lucide-react";

import RecepcionModule from "./RecepcionModule";

const InventarioModule = lazy(() => import("./InventarioModule"));
const ReabastoModule   = lazy(() => import("./ReabastoModule"));
const LotesModule      = lazy(() => import("./LotesModule"));
const PreciosReferenciaModule = lazy(() => import("./PreciosReferenciaModule"));
const RappiSyncPanel   = lazy(() => import("./RappiSyncPanel"));
const DescuentoCaducidadModule = lazy(() => import("./DescuentoCaducidadModule"));
const MonitorPreciosModule = lazy(() => import("./MonitorPreciosModule"));

const TABS_VENDEDOR = ["catalogo"];

const TABS = [
  { id: "catalogo", label: "Catálogo",   icon: Package },
  { id: "reabasto", label: "Reabasto",   icon: Truck },
  { id: "lotes",    label: "Lotes PEPS", icon: Tags },
  { id: "precios",  label: "Referencias de precio", icon: TrendingUp, labelMobile: "Precios" },
  { id: "aprobar", label: "Aprobar PVP", icon: BadgeCheck, labelMobile: "Aprobar" },
  { id: "caducidad", label: "Precio por caducar", icon: Percent, labelMobile: "Caducar" },
  { id: "rappi",    label: "Rappi",      icon: ShoppingBag },
];

const STORAGE_KEY = "farmacapital_inv_tab";

function tabInicial({ initialTab, tabPermitida }) {
  if (initialTab === "recibir") return "recibir";
  if (initialTab && tabPermitida(initialTab)) return initialTab;
  try {
    const saved = sessionStorage.getItem(STORAGE_KEY);
    if (saved === "recibir") return "recibir";
    if (saved && tabPermitida(saved)) return saved;
  } catch (_) { /* storage bloqueado */ }
  return "catalogo";
}

export default function InventarioHub({ initialTab, usuario, onNavigate }) {
  const C = C_LIGHT;
  const isMobile = useMediaQuery("(max-width: 768px)");
  const modoConsulta = usuario?.rol === "vendedor";
  const tabsVisibles = modoConsulta
    ? TABS_VENDEDOR.map((id) => TABS.find((t) => t.id === id)).filter(Boolean)
    : TABS;
  const tabPermitida = (id) => tabsVisibles.some((t) => t.id === id);
  const [tab, setTab] = useState(() => tabInicial({ initialTab, tabPermitida }));
  const enRecibir = tab === "recibir";
  const mostrarTabs = !enRecibir && tabsVisibles.length > 1;

  const selectTab = (id) => {
    if (!tabPermitida(id)) return;
    setTab(id);
    try { sessionStorage.setItem(STORAGE_KEY, id); } catch (_) { /* noop */ }
  };

  const irARecibir = () => {
    if (onNavigate) onNavigate("recibir");
  };

  useEffect(() => {
    if (tab === "recibir") return;
    if (!tabPermitida(tab)) setTab("catalogo");
  }, [modoConsulta, tab]);

  useEffect(() => {
    if (initialTab === "recibir") {
      setTab("recibir");
      return;
    }
    if (initialTab && tabPermitida(initialTab) && initialTab !== tab) {
      setTab(initialTab);
      try { sessionStorage.setItem(STORAGE_KEY, initialTab); } catch (_) { /* noop */ }
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [initialTab, modoConsulta]);

  return (
    <div style={{background: C.bg, minHeight: "100dvh", fontFamily: "var(--fc-body)"}}>
      {mostrarTabs && (
        <div style={{
          padding: isMobile ? "12px 16px 0" : "18px 24px 0 24px",
          borderBottom: `1px solid ${C.border}`,
          background: C.card,
          position: "sticky",
          top: isMobile ? "calc(60px + env(safe-area-inset-top, 0px))" : 0,
          zIndex: 20,
        }}>
          <div style={{display: "flex", alignItems: "center", gap: 10, marginBottom: 12, flexWrap: "wrap"}}>
            <h1 style={{margin: 0, color: C.text, fontSize: 20, fontWeight: 800}}>◆ Inventario</h1>
            {!isMobile && (
              <span style={{color: C.textDim, fontSize: 12}}>
                Catálogo · reabasto · lotes · referencias · aprobar · caducar · Rappi
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
                </button>
              );
            })}
          </div>
        </div>
      )}

      <Suspense fallback={
        <div style={{padding: 24, display: "flex", flexDirection: "column", gap: 12}}>
          <SkeletonCard height={48} />
          <SkeletonCard height={120} />
          <SkeletonCard height={120} />
        </div>
      }>
        {enRecibir && <RecepcionModule ocultarMontos={modoConsulta} />}
        {tab === "catalogo" && (
          <InventarioModule modoConsulta={modoConsulta} onIrARecibir={irARecibir} />
        )}
        {!modoConsulta && tab === "reabasto" && <ReabastoModule/>}
        {!modoConsulta && tab === "lotes"    && <LotesModule/>}
        {!modoConsulta && tab === "precios"  && <PreciosReferenciaModule/>}
        {!modoConsulta && tab === "aprobar" && <MonitorPreciosModule/>}
        {!modoConsulta && tab === "caducidad" && <DescuentoCaducidadModule/>}
        {!modoConsulta && tab === "rappi"    && <RappiSyncPanel/>}
      </Suspense>
    </div>
  );
}
