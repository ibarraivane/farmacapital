import React from "react";
import { C_LIGHT } from "../../constants";
import { formatStaffAlertTime, isStaffAlertsMuted, setStaffAlertsMuted } from "../../utils/staffAlerts";

export default function StaffAlertBanner({
  alert,
  queueCount = 0,
  onAttend,
  onSnooze,
  onDismiss,
  compact = false,
}) {
  const C = C_LIGHT;
  if (!alert) return null;

  const col = alert.col || C.blue;
  const muted = isStaffAlertsMuted();

  return (
    <div
      role="alert"
      aria-live="assertive"
      style={{
        position: compact ? "relative" : "fixed",
        top: compact ? undefined : "max(8px, env(safe-area-inset-top, 0px))",
        left: compact ? undefined : 12,
        right: compact ? undefined : 12,
        zIndex: compact ? 1 : 10050,
        maxWidth: compact ? "100%" : 720,
        margin: compact ? "0 0 12px" : "0 auto",
        boxSizing: "border-box",
        animation: "fcStaffPulse .9s ease-in-out infinite alternate",
      }}
    >
      <style>{`
        @keyframes fcStaffPulse {
          from { box-shadow: 0 0 0 0 ${col}55, 0 12px 40px rgba(15,23,42,.18); }
          to { box-shadow: 0 0 0 6px ${col}22, 0 16px 48px rgba(15,23,42,.22); }
        }
      `}</style>
      <div
        style={{
          background: `linear-gradient(135deg, ${col} 0%, #0D1B2A 100%)`,
          color: "#fff",
          borderRadius: 14,
          padding: compact ? "14px 16px" : "16px 18px",
          border: "2px solid rgba(255,255,255,.25)",
        }}
      >
        <div style={{ display: "flex", alignItems: "flex-start", gap: 12 }}>
          <div
            style={{
              fontSize: compact ? 28 : 34,
              lineHeight: 1,
              flexShrink: 0,
              filter: "drop-shadow(0 2px 4px rgba(0,0,0,.25))",
            }}
          >
            {alert.icon || "🔔"}
          </div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ display: "flex", alignItems: "center", gap: 8, flexWrap: "wrap" }}>
              <span
                style={{
                  fontSize: 10,
                  fontWeight: 800,
                  letterSpacing: 1.2,
                  textTransform: "uppercase",
                  background: "rgba(255,255,255,.18)",
                  padding: "3px 8px",
                  borderRadius: 999,
                }}
              >
                Atención en turno
              </span>
              {queueCount > 1 && (
                <span style={{ fontSize: 11, opacity: 0.85 }}>+{queueCount - 1} en cola</span>
              )}
            </div>
            <div style={{ fontWeight: 900, fontSize: compact ? 17 : 20, marginTop: 6, lineHeight: 1.2 }}>
              {alert.titulo}
            </div>
            <div style={{ fontSize: 14, fontWeight: 700, marginTop: 4, opacity: 0.95 }}>
              {alert.subtitulo}
            </div>
            <div style={{ fontSize: 12, marginTop: 4, opacity: 0.85 }}>{alert.detalle}</div>
          </div>
          <button
            type="button"
            onClick={onDismiss}
            aria-label="Cerrar alerta"
            style={{
              background: "rgba(255,255,255,.12)",
              border: "none",
              color: "#fff",
              borderRadius: 8,
              width: 32,
              height: 32,
              cursor: "pointer",
              fontSize: 16,
              flexShrink: 0,
            }}
          >
            ✕
          </button>
        </div>

        <div
          style={{
            display: "flex",
            flexWrap: "wrap",
            gap: 8,
            marginTop: 14,
          }}
        >
          <button
            type="button"
            onClick={() => onAttend?.(alert)}
            style={{
              flex: "1 1 160px",
              padding: "12px 16px",
              borderRadius: 10,
              border: "none",
              background: "#fff",
              color: col,
              fontWeight: 900,
              fontSize: 14,
              cursor: "pointer",
            }}
          >
            {alert.type === "pedido" ? "Ir a surtir →" : "Cobrar en POS →"}
          </button>
          <button
            type="button"
            onClick={() => onSnooze?.(alert, 2)}
            style={{
              padding: "12px 14px",
              borderRadius: 10,
              border: "1px solid rgba(255,255,255,.35)",
              background: "transparent",
              color: "#fff",
              fontWeight: 700,
              fontSize: 13,
              cursor: "pointer",
            }}
          >
            Posponer 2 min
          </button>
          <button
            type="button"
            onClick={() => setStaffAlertsMuted(!muted)}
            style={{
              padding: "12px 14px",
              borderRadius: 10,
              border: "1px solid rgba(255,255,255,.25)",
              background: "transparent",
              color: "#fff",
              fontWeight: 600,
              fontSize: 12,
              cursor: "pointer",
              opacity: muted ? 0.7 : 1,
            }}
          >
            {muted ? "🔇 Sonido off" : "🔊 Silenciar"}
          </button>
        </div>
        <div style={{ fontSize: 10, opacity: 0.65, marginTop: 8 }}>
          {formatStaffAlertTime(alert.receivedAt || alert.createdAt)}
        </div>
      </div>
    </div>
  );
}
