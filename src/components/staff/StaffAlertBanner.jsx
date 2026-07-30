import React from "react";
import { C_LIGHT } from "../../constants";
import { isStaffAlertsMuted, setStaffAlertsMuted } from "../../utils/staffAlerts";

/** Barra compacta arriba — aviso al vendedor, no modal invasivo. */
export default function StaffAlertBanner({
  alert,
  queueCount = 0,
  onPrimary,
  onSecondary,
  onDismiss,
  compact = false,
}) {
  const C = C_LIGHT;
  if (!alert) return null;

  const col = alert.col || C.blue;
  const muted = isStaffAlertsMuted();
  const primaryLabel = alert.primaryLabel || (alert.type === "pedido" ? "Surtir" : "Entendido");
  const secondaryLabel = alert.secondaryLabel || null;

  return (
    <div
      role="alert"
      aria-live="polite"
      style={{
        position: compact ? "relative" : "fixed",
        top: compact ? undefined : "max(6px, env(safe-area-inset-top, 0px))",
        left: compact ? undefined : 10,
        right: compact ? undefined : 10,
        zIndex: compact ? 1 : 10050,
        maxWidth: compact ? "100%" : 920,
        margin: compact ? "0 0 10px" : "0 auto",
        boxSizing: "border-box",
        pointerEvents: "none",
      }}
    >
      <div
        style={{
          pointerEvents: "auto",
          display: "flex",
          alignItems: "center",
          gap: 10,
          padding: "8px 12px",
          background: C.card,
          border: `1px solid ${C.border}`,
          borderLeft: `4px solid ${col}`,
          borderRadius: 10,
          boxShadow: "0 4px 18px rgba(15,23,42,.1)",
          flexWrap: "wrap",
        }}
      >
        <span style={{ fontSize: 18, lineHeight: 1, flexShrink: 0 }} aria-hidden>
          {alert.icon || "🔔"}
        </span>

        <div style={{ flex: 1, minWidth: 0 }}>
          <div
            style={{
              display: "flex",
              alignItems: "baseline",
              gap: 8,
              flexWrap: "wrap",
              lineHeight: 1.35,
            }}
          >
            <span style={{ fontWeight: 800, fontSize: 13, color: C.text }}>{alert.titulo}</span>
            <span style={{ fontSize: 12, color: C.textMid, fontWeight: 600 }}>{alert.subtitulo}</span>
            {alert.detalle ? (
              <span style={{ fontSize: 11, color: C.textDim }}>· {alert.detalle}</span>
            ) : null}
            {queueCount > 1 ? (
              <span style={{ fontSize: 10, color: col, fontWeight: 700 }}>+{queueCount - 1}</span>
            ) : null}
          </div>
          {alert.nota ? (
            <div style={{ fontSize: 10, color: C.textDim, marginTop: 2 }}>{alert.nota}</div>
          ) : null}
        </div>

        <div style={{ display: "flex", alignItems: "center", gap: 6, flexShrink: 0 }}>
          {secondaryLabel && onSecondary ? (
            <button
              type="button"
              onClick={() => onSecondary(alert)}
              style={{
                padding: "6px 10px",
                borderRadius: 8,
                border: `1px solid ${C.border}`,
                background: C.bg,
                color: C.textMid,
                fontWeight: 700,
                fontSize: 11,
                cursor: "pointer",
                whiteSpace: "nowrap",
              }}
            >
              {secondaryLabel}
            </button>
          ) : null}
          <button
            type="button"
            onClick={() => onPrimary?.(alert)}
            style={{
              padding: "6px 12px",
              borderRadius: 8,
              border: "none",
              background: col,
              color: "#fff",
              fontWeight: 800,
              fontSize: 11,
              cursor: "pointer",
              whiteSpace: "nowrap",
            }}
          >
            {primaryLabel}
          </button>
          <button
            type="button"
            onClick={() => onDismiss?.(alert)}
            aria-label="Cerrar aviso"
            style={{
              background: "none",
              border: "none",
              color: C.textDim,
              cursor: "pointer",
              fontSize: 16,
              lineHeight: 1,
              padding: "2px 4px",
            }}
          >
            ✕
          </button>
          <button
            type="button"
            onClick={() => setStaffAlertsMuted(!muted)}
            title={muted ? "Activar sonido" : "Silenciar avisos"}
            style={{
              background: "none",
              border: "none",
              cursor: "pointer",
              fontSize: 14,
              opacity: muted ? 0.45 : 1,
              padding: 2,
            }}
          >
            {muted ? "🔇" : "🔊"}
          </button>
        </div>
      </div>
    </div>
  );
}
