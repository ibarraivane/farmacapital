import React, { useState, useEffect } from "react";

/**
 * FARMACAPITAL — Modal de pago con terminal BBVA (confirmación manual)
 *
 * Las terminales BBVA no exponen una API de integración pública,
 * por lo que el flujo es: el cajero procesa la tarjeta en el dispositivo
 * físico y confirma aquí cuando el terminal imprime el voucher aprobado.
 */
export default function BBVATerminalModal({ open, total, folio, hint, onSuccess, onCancel }) {
  const [estado, setEstado] = useState("idle"); // idle | esperando | exito | rechazado

  useEffect(() => {
    if (!open) setEstado("idle");
  }, [open]);

  useEffect(() => {
    if (!open) return undefined;
    const prev = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return () => {
      document.body.style.overflow = prev || "auto";
    };
  }, [open]);

  if (!open) return null;

  const colores = {
    idle:      "#1a237e",
    esperando: "#1565c0",
    exito:     "#16a34a",
    rechazado: "#ef4444",
  };

  const iconos = {
    idle:      "🏦",
    esperando: "⏳",
    exito:     "✅",
    rechazado: "❌",
  };

  const iniciar = () => setEstado("esperando");

  const confirmarAprobado = () => {
    setEstado("exito");
    setTimeout(() => onSuccess?.({ terminal: "bbva", folio }), 1200);
  };

  const confirmarRechazado = () => {
    setEstado("rechazado");
  };

  const cerrar = () => {
    setEstado("idle");
    onCancel?.();
  };

  return (
    <div style={{
      position: "fixed", inset: 0,
      background: "rgba(15,23,42,.65)",
      backdropFilter: "blur(4px)",
      zIndex: 9000,
      display: "flex", alignItems: "center", justifyContent: "center",
      padding: 20,
    }}>
      <div style={{
        background: "#fff",
        borderRadius: 16,
        width: "min(420px,95vw)",
        padding: 28,
        boxShadow: "0 24px 80px rgba(26,35,126,.2)",
      }}>
        {/* Header */}
        <div style={{ textAlign: "center", marginBottom: 24 }}>
          <div style={{ fontSize: 48, marginBottom: 8 }}>{iconos[estado]}</div>
          <div style={{ fontWeight: 800, fontSize: 18, color: "#0f172a" }}>
            Pago con terminal BBVA
          </div>
          <div style={{ color: "#475569", fontSize: 13, marginTop: 4 }}>Folio: {folio}</div>
          {hint && (
            <div style={{ color: "#64748b", fontSize: 11, marginTop: 10, lineHeight: 1.45, maxWidth: 340, margin: "10px auto 0" }}>
              {hint}
            </div>
          )}
        </div>

        {/* Monto */}
        <div style={{
          background: "#f0f4ff",
          borderRadius: 12, padding: 16,
          textAlign: "center", marginBottom: 20,
          border: "1px solid #c7d2fe",
        }}>
          <div style={{ color: "#6366f1", fontSize: 11, fontWeight: 700, marginBottom: 4 }}>
            TOTAL A COBRAR EN TERMINAL
          </div>
          <div style={{ color: "#1a237e", fontWeight: 900, fontSize: 36 }}>
            ${parseFloat(total || 0).toFixed(2)}
          </div>
        </div>

        {/* Instrucciones por estado */}
        {estado === "idle" && (
          <div style={{
            background: "#e8eaf6", border: "1px solid #9fa8da",
            borderRadius: 10, padding: "12px 16px", marginBottom: 20,
            fontSize: 12, color: "#283593", lineHeight: 1.6,
          }}>
            <strong>Pasos para cobrar con la terminal BBVA:</strong>
            <ol style={{ margin: "8px 0 0", paddingLeft: 18 }}>
              <li>Ingresa el monto <strong>${parseFloat(total || 0).toFixed(2)}</strong> en la terminal física.</li>
              <li>El cliente desliza, inserta o acerca su tarjeta.</li>
              <li>Espera a que la terminal imprima el voucher.</li>
              <li>Si dice <strong>APROBADO</strong>, presiona "Pago aprobado" aquí abajo.</li>
              <li>Si dice <strong>RECHAZADO</strong>, presiona "Pago rechazado".</li>
            </ol>
          </div>
        )}

        {estado === "esperando" && (
          <div style={{
            background: "#e3f2fd", border: "1px solid #90caf9",
            borderRadius: 10, padding: "12px 16px", marginBottom: 20,
            fontSize: 13, color: "#0d47a1", textAlign: "center", lineHeight: 1.55,
          }}>
            Esperando respuesta de la terminal BBVA...<br />
            <strong>¿Qué imprimió el voucher?</strong>
          </div>
        )}

        {estado === "exito" && (
          <div style={{
            background: "#f0fdf4", border: "1px solid #86efac",
            borderRadius: 10, padding: "12px 16px", marginBottom: 20,
            fontSize: 13, color: "#15803d", textAlign: "center", fontWeight: 700,
          }}>
            ¡Pago aprobado! Registrando venta...
          </div>
        )}

        {estado === "rechazado" && (
          <div style={{
            background: "#fef2f2", border: "1px solid #fca5a5",
            borderRadius: 10, padding: "12px 16px", marginBottom: 20,
            fontSize: 13, color: "#b91c1c", textAlign: "center", fontWeight: 700,
          }}>
            Pago rechazado. Intenta con otra tarjeta o método de pago.
          </div>
        )}

        {/* Botones */}
        <div style={{ display: "flex", gap: 10, flexDirection: "column" }}>
          {estado === "idle" && (
            <button onClick={iniciar} style={{
              padding: "13px", borderRadius: 10, border: "none",
              background: "linear-gradient(135deg,#1a237e,#283593)",
              color: "#fff", fontWeight: 800, fontSize: 15, cursor: "pointer",
            }}>
              🏦 Procesar en terminal BBVA
            </button>
          )}

          {estado === "esperando" && (
            <>
              <button onClick={confirmarAprobado} style={{
                padding: "13px", borderRadius: 10, border: "none",
                background: "linear-gradient(135deg,#16a34a,#15803d)",
                color: "#fff", fontWeight: 800, fontSize: 15, cursor: "pointer",
              }}>
                ✅ Pago APROBADO — registrar venta
              </button>
              <button onClick={confirmarRechazado} style={{
                padding: "10px", borderRadius: 10,
                border: "1px solid #fca5a5",
                background: "#fef2f2", color: "#b91c1c",
                fontWeight: 700, fontSize: 13, cursor: "pointer",
              }}>
                ❌ Pago RECHAZADO
              </button>
            </>
          )}

          {(estado === "idle" || estado === "esperando" || estado === "rechazado") && (
            <button onClick={cerrar} style={{
              padding: "10px", borderRadius: 10,
              border: "1px solid #e2e8f0",
              background: "transparent", color: "#475569",
              fontWeight: 700, fontSize: 13, cursor: "pointer",
            }}>
              {estado === "rechazado" ? "✕ Cerrar — elegir otro método" : "✕ Cancelar"}
            </button>
          )}
        </div>

        {estado === "esperando" && (
          <div style={{ marginTop: 14, fontSize: 10, color: "#94a3b8", textAlign: "center", lineHeight: 1.6 }}>
            No cierres esta ventana hasta confirmar el resultado del terminal.<br />
            La venta NO se registra hasta que presiones "Pago APROBADO".
          </div>
        )}
      </div>
    </div>
  );
}
