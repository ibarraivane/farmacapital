import { C_LIGHT } from "../constants";

function pctCumplimiento(actual, meta) {
  if (!meta || meta <= 0) return 0;
  return Math.max(0, (actual / meta) * 100);
}

/** Tarjeta de meta: cifra grande, barra y % — la de Operación. */
export default function InsightKpiCard({
  label, icon, value, display, meta, metaLabel, delta, col, formatMeta, onAction, actionLabel,
}) {
  const C = C_LIGHT;
  const tieneMeta = Number.isFinite(meta) && meta > 0;
  const pct = tieneMeta ? pctCumplimiento(value, meta) : 0;
  const pctClamp = Math.min(pct, 100);
  const barColor = pct >= 100 ? C.green : pct >= 70 ? (col || C.blue) : pct >= 40 ? C.amber : C.red;
  const mainCol = col || C.blue;
  const hasTrend = Number.isFinite(delta);
  const up = hasTrend && delta >= 0;
  const fmtMeta = formatMeta || ((n) => n.toLocaleString("es-MX"));
  return (
    <div style={{ background: C.card, border: `1px solid ${C.border}`, borderRadius: 12, padding: "16px 18px", display: "flex", flexDirection: "column", gap: 10 }}>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start" }}>
        <div style={{ color: C.textMid, fontSize: 11, fontWeight: 700, letterSpacing: 0.4 }}>{label.toUpperCase()}</div>
        {icon && <span style={{ fontSize: 18 }}>{icon}</span>}
      </div>
      <div style={{ color: mainCol, fontWeight: 800, fontSize: 26, lineHeight: 1.1 }}>{display ?? value}</div>
      {tieneMeta && (
        <>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", fontSize: 10, color: C.textMid }}>
            <span>Meta {metaLabel || ""}: <strong style={{ color: C.text }}>{fmtMeta(meta)}</strong></span>
            <span style={{ fontWeight: 800, color: barColor }}>{pct.toFixed(0)}%</span>
          </div>
          <div style={{ background: C.bg, borderRadius: 4, height: 6, overflow: "hidden" }}>
            <div style={{ height: "100%", width: `${pctClamp}%`, background: barColor, borderRadius: 4, transition: "width .6s ease" }} />
          </div>
        </>
      )}
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginTop: tieneMeta ? 0 : 4 }}>
        {hasTrend ? (
          <span style={{ fontSize: 11, fontWeight: 700, color: up ? C.green : C.red }}>
            {up ? "↑" : "↓"} {Math.abs(delta).toFixed(1)}% <span style={{ color: C.textDim, fontWeight: 500 }}>vs periodo anterior</span>
          </span>
        ) : <span style={{ fontSize: 11, color: C.textDim }}>Sin comparativo</span>}
        {onAction && (
          <button type="button" onClick={onAction} style={{ padding: "4px 10px", borderRadius: 6, border: `1px solid ${mainCol}40`, background: "transparent", color: mainCol, cursor: "pointer", fontSize: 10, fontWeight: 700 }}>
            {actionLabel || "Ver detalle →"}
          </button>
        )}
      </div>
    </div>
  );
}
