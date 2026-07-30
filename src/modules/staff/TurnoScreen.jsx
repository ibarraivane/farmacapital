import React, { useCallback } from "react";
import { C_LIGHT, BRAND } from "../../constants";
import useStaffAlerts from "../../hooks/useStaffAlerts";
import StaffAlertBanner from "../../components/staff/StaffAlertBanner";
import { isStaffAlertsMuted, setStaffAlertsMuted } from "../../utils/staffAlerts";

export default function TurnoScreen({ setPage, pushNotif, applyPosTabHint }) {
  const C = C_LIGHT;

  const push = useCallback(
    (titulo, cuerpo, url) => {
      pushNotif?.(titulo, cuerpo, url);
    },
    [pushNotif]
  );

  const { alerts, activeAlert, attendAlert, dismissAlert } = useStaffAlerts({
    enabled: true,
    pushNotif: push,
  });

  const goPage = useCallback(
    (pageId, posTab) => {
      if (posTab && applyPosTabHint) applyPosTabHint(posTab);
      setPage?.(pageId);
    },
    [setPage, applyPosTabHint]
  );

  const handlePrimary = (alert) => {
    attendAlert(alert.key);
    if (alert.type === "pedido") {
      goPage("ped_online", "online");
    }
  };

  const handleSecondary = (alert) => {
    attendAlert(alert.key);
    if (alert.type === "cita") goPage("agenda");
  };

  const muted = isStaffAlertsMuted();

  return (
    <div
      style={{
        minHeight: "100dvh",
        background: `linear-gradient(160deg, ${C.bg} 0%, #e8eef8 100%)`,
        padding: "max(16px, env(safe-area-inset-top)) 16px 24px",
        boxSizing: "border-box",
      }}
    >
      <div style={{ maxWidth: 900, margin: "0 auto" }}>
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", gap: 12, marginBottom: 16, flexWrap: "wrap" }}>
          <div>
            <div style={{ fontSize: 12, fontWeight: 800, color: BRAND.secondary, letterSpacing: 1, textTransform: "uppercase" }}>
              Pantalla de turno
            </div>
            <h1 style={{ margin: "6px 0 4px", fontSize: 24, fontWeight: 900, color: C.text }}>
              Avisos al mostrador
            </h1>
            <p style={{ margin: 0, color: C.textMid, fontSize: 13, lineHeight: 1.5 }}>
              Pedidos online = surtir cuando corresponda. Citas en línea = solo aviso (el paciente paga el día de la consulta).
            </p>
          </div>
          <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
            <button
              type="button"
              onClick={() => setStaffAlertsMuted(!muted)}
              style={{
                padding: "8px 12px",
                borderRadius: 8,
                border: `1px solid ${C.border}`,
                background: C.card,
                fontWeight: 700,
                fontSize: 12,
                cursor: "pointer",
              }}
            >
              {muted ? "🔇 Sonido off" : "🔊 Sonido on"}
            </button>
            <button
              type="button"
              onClick={() => setPage?.("dash")}
              style={{
                padding: "8px 12px",
                borderRadius: 8,
                border: "none",
                background: BRAND.primary,
                color: "#fff",
                fontWeight: 700,
                fontSize: 12,
                cursor: "pointer",
              }}
            >
              ← Panel
            </button>
          </div>
        </div>

        <StaffAlertBanner
          alert={activeAlert}
          queueCount={alerts.length}
          onPrimary={handlePrimary}
          onSecondary={handleSecondary}
          onDismiss={(a) => dismissAlert(a?.key || activeAlert?.key)}
          compact
        />

        {!activeAlert && (
          <div
            style={{
              background: C.card,
              border: `1px dashed ${C.border}`,
              borderRadius: 12,
              padding: "36px 20px",
              textAlign: "center",
              marginBottom: 16,
            }}
          >
            <div style={{ fontSize: 40, marginBottom: 8 }}>✅</div>
            <div style={{ fontWeight: 800, fontSize: 16, color: C.text }}>Sin avisos pendientes</div>
          </div>
        )}

        {alerts.length > 0 && (
          <div style={{ background: C.card, borderRadius: 12, border: `1px solid ${C.border}`, overflow: "hidden" }}>
            <div style={{ padding: "10px 14px", borderBottom: `1px solid ${C.border}`, fontWeight: 800, fontSize: 12 }}>
              Cola ({alerts.length})
            </div>
            {alerts.map((a) => (
              <div
                key={a.key}
                style={{
                  padding: "10px 14px",
                  borderBottom: `1px solid ${C.border}`,
                  display: "flex",
                  justifyContent: "space-between",
                  alignItems: "center",
                  gap: 10,
                  flexWrap: "wrap",
                }}
              >
                <div style={{ minWidth: 0 }}>
                  <div style={{ fontWeight: 800, fontSize: 13 }}>
                    {a.icon} {a.titulo}
                  </div>
                  <div style={{ fontSize: 11, color: C.textMid }}>{a.subtitulo}</div>
                </div>
                <button
                  type="button"
                  onClick={() => (a.type === "pedido" ? handlePrimary(a) : handleSecondary(a))}
                  style={{
                    padding: "6px 12px",
                    borderRadius: 8,
                    border: "none",
                    background: a.col || BRAND.secondary,
                    color: "#fff",
                    fontWeight: 700,
                    fontSize: 11,
                    cursor: "pointer",
                  }}
                >
                  {a.type === "pedido" ? "Surtir" : "Agenda"}
                </button>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
