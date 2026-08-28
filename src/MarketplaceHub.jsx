import { useState } from "react";
import { ShoppingBag } from "lucide-react";
import { C_LIGHT, BRAND } from "./constants";
import { Box } from "./ui";
import { CANALES_VENTA } from "./lib/canalesVenta";
import { filtrarDecisiones } from "./lib/decisionesPrecios";
import { useDecisionesPrecios } from "./hooks/useDecisionesPrecios";
import DecisionesPreciosPanel from "./DecisionesPreciosPanel";
import RappiSyncPanel from "./RappiSyncPanel";

const C = C_LIGHT;

const SUBS = [
  { id: "rappi", label: "Rappi", pronto: false },
  { id: "uber", label: "Uber", pronto: !CANALES_VENTA.uber.activo },
  { id: "didi", label: "DiDi", pronto: !CANALES_VENTA.didi.activo },
];

function CanalPronto({ canalId, dec }) {
  const canal = CANALES_VENTA[canalId];
  const [applyingId, setApplyingId] = useState(null);
  const decisiones = filtrarDecisiones(dec.decisiones, canalId);
  return (
    <div style={{ padding: "18px 24px 40px", maxWidth: 960 }}>
      <h2 style={{ margin: 0, fontSize: 16, fontWeight: 800, color: C.text, display: "flex", alignItems: "center", gap: 8 }}>
        <ShoppingBag size={18} strokeWidth={2.2} aria-hidden />
        {canal.label} · pronto
      </h2>
      <p style={{ margin: "8px 0 16px", color: C.textMid, fontSize: 13, maxWidth: 640, lineHeight: 1.45 }}>
        Todavía no hay conexión. Las alertas ya usan las mismas referencias de compra y venta
        del inventario y de Rappi. El precio que apliques en mostrador es el que publicarás aquí.
      </p>
      <Box style={{ padding: 16 }}>
        <div style={{ fontWeight: 800, fontSize: 13, color: C.text, marginBottom: 10 }}>
          Alertas que aplicarán a {canal.label}
        </div>
        <DecisionesPreciosPanel
          variant="marketplace"
          filtroInicial={canalId}
          decisiones={decisiones}
          loading={dec.loading}
          revisadoAt={dec.revisadoAt}
          onRefresh={dec.refetch}
          onPosponer={dec.posponer}
          onApplied={dec.marcarAplicado}
          applyingId={applyingId}
          setApplyingId={setApplyingId}
        />
      </Box>
    </div>
  );
}

export default function MarketplaceHub({ decisiones: decProp } = {}) {
  const [sub, setSub] = useState("rappi");
  const decLocal = useDecisionesPrecios({ enabled: !decProp });
  const dec = decProp || decLocal;

  return (
    <div>
      <div style={{
        display: "flex",
        gap: 6,
        padding: "12px 24px 0",
        borderBottom: `1px solid ${C.border}`,
        background: C.bg,
      }}>
        {SUBS.map((s) => {
          const on = sub === s.id;
          const n = s.id === "rappi" ? dec.resumen.rappi : dec.resumen[s.id];
          return (
            <button
              key={s.id}
              type="button"
              onClick={() => setSub(s.id)}
              style={{
                padding: "8px 16px",
                border: "none",
                cursor: "pointer",
                fontWeight: 700,
                fontSize: 12,
                background: "transparent",
                color: on ? BRAND.primary : C.textMid,
                borderBottom: `2px solid ${on ? BRAND.primary : "transparent"}`,
              }}
            >
              {s.label}{s.pronto ? " · pronto" : ""}
              {n > 0 ? ` (${n})` : ""}
            </button>
          );
        })}
      </div>
      {sub === "rappi" && <RappiSyncPanel decisiones={dec} />}
      {sub === "uber" && <CanalPronto canalId="uber" dec={dec} />}
      {sub === "didi" && <CanalPronto canalId="didi" dec={dec} />}
    </div>
  );
}
