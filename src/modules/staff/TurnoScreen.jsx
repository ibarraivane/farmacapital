import React, { useCallback } from "react";
import { C_LIGHT, BRAND } from "../../constants";
import useStaffAlerts from "../../hooks/useStaffAlerts";
import StaffAlertBanner from "../../components/staff/StaffAlertBanner";
import { isStaffAlertsMuted, setStaffAlertsMuted } from "../../utils/staffAlerts";

export default function TurnoScreen({ setPage, pushNotif }) {
  const C = C_LIGHT;

  const push = useCallback(
    (titulo, cuerpo, url) => {
      pushNotif?.(titulo, cuerpo, url);
    },
    [pushNotif]
  );

  const { alerts, activeAlert, attendAlert, snoozeAlert, dismissAlert } = useStaffAlerts({
    enabled: true,
    pushNotif: push,
  });

  const handleAttend = (alert) => {
    attendAlert(alert.key);
    if (alert.type === "pedido") {
      try {
        sessionStorage.setItem("farmacapital_pos_tab", "online");
      } catch (_) { /* noop */ }
      setPage?.("ped_online");
    } else {
      try {
        sessionStorage.setItem("farmacapital_pos_tab", "consultas");
      } catch (_) { /* noop */ }
      setPage?.("cons_cobro");
    }
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
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", gap: 12, marginBottom: 20, flexWrap: "wrap" }}>
          <div>
            <div style={{ fontSize: 12, fontWeight: 800, color: BRAND.secondary, letterSpacing: 1, textTransform: "uppercase" }}>
              Pantalla de turno
            </div>
            <h1 style={{ margin: "6px 0 4px", fontSize: 28, fontWeight: 900, color: C.text }}>
              Mostrador FarmaCapital
            </h1>
            <p style={{ margin: 0, color: C.textMid, fontSize: 14, lineHeight: 1.5 }}>
              Avisos con sonido cuando entra un pedido online o una cita agendada. Deja esta pantalla abierta en la tablet del mostrador.
            </p>
          </div>
          <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
            <button
              type="button"
              onClick={() => setStaffAlertsMuted(!muted)}
              style={{
                padding: "10px 14px",
                borderRadius: 10,
                border: `1px solid ${C.border}`,
                background: C.card,
                fontWeight: 700,
                cursor: "pointer",
              }}
            >
              {muted ? "🔇 Activar sonido" : "🔊 Silenciar sonido"}
            </button>
            <button
              type="button"
              onClick={() => setPage?.("dash")}
              style={{
                padding: "10px 14px",
                borderRadius: 10,
                border: "none",
                background: BRAND.primary,
                color: "#fff",
                fontWeight: 700,
                cursor: "pointer",
              }}
            >
              ← Panel admin
            </button>
          </div>
        </div>

        <StaffAlertBanner
          alert={activeAlert}
          queueCount={alerts.length}
          onAttend={handleAttend}
          onSnooze={(a, m) => snoozeAlert(a.key, m)}
          onDismiss={(a) => dismissAlert(a?.key || activeAlert?.key)}
          compact
        />

        {!activeAlert && (
          <div
            style={{
              background: C.card,
              border: `2px dashed ${C.border}`,
              borderRadius: 16,
              padding: "48px 24px",
              textAlign: "center",
              marginBottom: 20,
            }}
          >
            <div style={{ fontSize: 48, marginBottom: 12 }}>✅</div>
            <div style={{ fontWeight: 800, fontSize: 18, color: C.text }}>Sin turnos pendientes</div>
            <div style={{ color: C.textMid, fontSize: 14, marginTop: 8 }}>
              Cuando alguien compre en línea o agende cita, aparecerá aquí con sonido.
            </div>
          </div>
        )}

        {alerts.length > 0 && (
          <div style={{ background: C.card, borderRadius: 14, border: `1px solid ${C.border}`, overflow: "hidden" }}>
            <div style={{ padding: "12px 16px", borderBottom: `1px solid ${C.border}`, fontWeight: 800, fontSize: 13 }}>
              Cola de avisos ({alerts.length})
            </div>
            {alerts.map((a) => (
              <div
                key={a.key}
                style={{
                  padding: "12px 16px",
                  borderBottom: `1px solid ${C.border}`,
                  display: "flex",
                  justifyContent: "space-between",
                  alignItems: "center",
                  gap: 12,
                  flexWrap: "wrap",
                }}
              >
                <div>
                  <div style={{ fontWeight: 800, fontSize: 14 }}>
                    {a.icon} {a.titulo}
                  </div>
                  <div style={{ fontSize: 12, color: C.textMid }}>{a.subtitulo}</div>
                </div>
                <button
                  type="button"
                  onClick={() => handleAttend(a)}
                  style={{
                    padding: "8px 14px",
                    borderRadius: 8,
                    border: "none",
                    background: a.col || BRAND.secondary,
                    color: "#fff",
                    fontWeight: 700,
                    fontSize: 12,
                    cursor: "pointer",
                  }}
                >
                  Atender
                </button>
              </div>
            ))}
          </div>
        )}

        <div style={{ marginTop: 20, color: C.textDim, fontSize: 11, lineHeight: 1.5 }}>
          Actualización automática cada 30 segundos + aviso instantáneo por Realtime. El sonido se repite cada 15 s hasta que atiendas o pospongas.
        </div>
      </div>
    </div>
  );
}
