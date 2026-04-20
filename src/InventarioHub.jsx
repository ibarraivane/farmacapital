// InventarioHub: shell con 3 tabs que agrupa Catálogo, Reabasto y Lotes PEPS.
// Los módulos internos se mantienen intactos; solo cambia la forma de entrar.
// Cada tab carga lazy para no inflar el bundle inicial.
import React, { lazy, Suspense, useState, useEffect } from "react";
import { C_LIGHT, BRAND } from "./constants";
import { Package, Truck, Tags } from "lucide-react";

const InventarioModule = lazy(() => import("./InventarioModule"));
const ReabastoModule   = lazy(() => import("./ReabastoModule"));
const LotesModule      = lazy(() => import("./LotesModule"));

const TABS = [
  { id: "catalogo", label: "Catálogo",   icon: Package },
  { id: "reabasto", label: "Reabasto",   icon: Truck },
  { id: "lotes",    label: "Lotes PEPS", icon: Tags },
];

const STORAGE_KEY = "farmax_inv_tab";

export default function InventarioHub({ initialTab }) {
  const C = C_LIGHT;
  const [tab, setTab] = useState(() => {
    const fromProp = initialTab && TABS.some((t) => t.id === initialTab) ? initialTab : null;
    if (fromProp) return fromProp;
    try {
      const saved = sessionStorage.getItem(STORAGE_KEY);
      if (saved && TABS.some((t) => t.id === saved)) return saved;
    } catch (_) { /* storage bloqueado */ }
    return "catalogo";
  });

  const selectTab = (id) => {
    setTab(id);
    try { sessionStorage.setItem(STORAGE_KEY, id); } catch (_) { /* noop */ }
  };

  // Si el padre cambia el initialTab (deep-link desde Dashboard u otro módulo) mientras
  // el hub ya está montado, cambiamos a esa tab.
  useEffect(() => {
    if (initialTab && TABS.some((t) => t.id === initialTab) && initialTab !== tab) {
      setTab(initialTab);
      try { sessionStorage.setItem(STORAGE_KEY, initialTab); } catch (_) { /* noop */ }
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [initialTab]);

  return (
    <div style={{background: C.bg, minHeight: "100vh", fontFamily: "'Plus Jakarta Sans',sans-serif"}}>
      <div style={{
        padding: "18px 24px 0 24px",
        borderBottom: `1px solid ${C.border}`,
        background: C.card,
        position: "sticky", top: 0, zIndex: 10,
      }}>
        <div style={{display: "flex", alignItems: "center", gap: 10, marginBottom: 12}}>
          <h1 style={{margin: 0, color: C.text, fontSize: 20, fontWeight: 800}}>◆ Inventario</h1>
          <span style={{color: C.textDim, fontSize: 12}}>Catálogo · reabasto · lotes PEPS</span>
        </div>
        <div style={{display: "flex", gap: 6, flexWrap: "wrap"}}>
          {TABS.map((t) => {
            const active = tab === t.id;
            const Icon = t.icon;
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
                }}
                onMouseEnter={(e) => { if (!active) e.currentTarget.style.color = C.text; }}
                onMouseLeave={(e) => { if (!active) e.currentTarget.style.color = C.textMid; }}
              >
                <Icon size={15} strokeWidth={2.1} />
                {t.label}
              </button>
            );
          })}
        </div>
      </div>

      <Suspense fallback={<div style={{padding: 24, color: C.textMid}}>Cargando...</div>}>
        {tab === "catalogo" && <InventarioModule/>}
        {tab === "reabasto" && <ReabastoModule/>}
        {tab === "lotes"    && <LotesModule/>}
      </Suspense>
    </div>
  );
}
