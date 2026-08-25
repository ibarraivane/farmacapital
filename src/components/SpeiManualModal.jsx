import React, { useState, useEffect } from "react";

/**
 * FARMACAPITAL — Cobro por transferencia SPEI a la cuenta de la farmacia
 *
 * El cliente transfiere desde su banco a la CLABE de FarmaCapital y el
 * cajero confirma aquí cuando ve el abono. No hay integración bancaria:
 * la única prueba válida es el movimiento en la cuenta, NO la pantalla
 * que el cliente enseña — por eso la confirmación es explícita y el
 * texto insiste en ese punto.
 *
 * Los datos bancarios salen de variables de entorno porque una CLABE
 * para recibir no es un secreto (se le da al cliente), pero cambiarla
 * no debería requerir tocar código.
 */
const CLABE        = process.env.REACT_APP_SPEI_CLABE || "";
const BANCO        = process.env.REACT_APP_SPEI_BANCO || "BBVA México";
const BENEFICIARIO = process.env.REACT_APP_SPEI_BENEFICIARIO || "FarmaCapital";

export default function SpeiManualModal({ open, total, folio, onSuccess, onCancel }) {
  const [estado, setEstado] = useState("idle"); // idle | esperando | exito
  const [copiado, setCopiado] = useState(false);
  const [referencia, setReferencia] = useState("");

  useEffect(() => {
    if (!open) {
      setEstado("idle");
      setCopiado(false);
      setReferencia("");
    }
  }, [open]);

  useEffect(() => {
    if (!open) return undefined;
    const prev = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return () => { document.body.style.overflow = prev || "auto"; };
  }, [open]);

  if (!open) return null;

  const monto = parseFloat(total || 0).toFixed(2);
  const faltaConfig = !CLABE;

  const copiarClabe = async () => {
    try {
      await navigator.clipboard.writeText(CLABE);
      setCopiado(true);
      setTimeout(() => setCopiado(false), 2000);
    } catch {
      setCopiado(false);
    }
  };

  const confirmar = () => {
    setEstado("exito");
    setTimeout(() => onSuccess?.({ via: "spei_manual", referencia: referencia.trim() || null, folio }), 1000);
  };

  const cerrar = () => { setEstado("idle"); onCancel?.(); };

  const iconos = { idle: "🏦", esperando: "⏳", exito: "✅" };

  return (
    <div style={{
      position: "fixed", inset: 0,
      background: "rgba(15,23,42,.65)", backdropFilter: "blur(4px)",
      zIndex: 9000, display: "flex", alignItems: "center", justifyContent: "center", padding: 20,
    }}>
      <div style={{
        background: "#fff", borderRadius: 16, width: "min(440px,95vw)",
        maxHeight: "92vh", overflowY: "auto", padding: 28,
        boxShadow: "0 24px 80px rgba(2,132,199,.2)",
      }}>
        <div style={{ textAlign: "center", marginBottom: 20 }}>
          <div style={{ fontSize: 44, marginBottom: 6 }}>{iconos[estado]}</div>
          <div style={{ fontWeight: 800, fontSize: 18, color: "#0f172a" }}>
            Transferencia SPEI
          </div>
          <div style={{ color: "#475569", fontSize: 13, marginTop: 4 }}>Folio: {folio}</div>
        </div>

        <div style={{
          background: "#ecfeff", borderRadius: 12, padding: 16,
          textAlign: "center", marginBottom: 18, border: "1px solid #a5f3fc",
        }}>
          <div style={{ color: "#0891b2", fontSize: 11, fontWeight: 700, marginBottom: 4 }}>
            TOTAL A TRANSFERIR
          </div>
          <div style={{ color: "#0e7490", fontWeight: 900, fontSize: 36 }}>${monto}</div>
        </div>

        {faltaConfig ? (
          <div style={{
            background: "#fef2f2", border: "1px solid #fca5a5", borderRadius: 10,
            padding: "12px 16px", marginBottom: 18, fontSize: 12.5, color: "#b91c1c", lineHeight: 1.6,
          }}>
            <strong>Falta configurar la CLABE.</strong><br />
            Agrega <code>REACT_APP_SPEI_CLABE</code> en las variables de entorno
            de Vercel y vuelve a desplegar. Mientras tanto, cobra de otra forma.
          </div>
        ) : (
          <div style={{
            background: "#f8fafc", border: "1px solid #e2e8f0", borderRadius: 10,
            padding: 16, marginBottom: 18,
          }}>
            <div style={{ fontSize: 11, color: "#64748b", fontWeight: 700, marginBottom: 8, letterSpacing: .5 }}>
              DATOS PARA LA TRANSFERENCIA
            </div>
            <Dato label="Banco" valor={BANCO} />
            <Dato label="Beneficiario" valor={BENEFICIARIO} />
            <div style={{ marginTop: 10 }}>
              <div style={{ fontSize: 11, color: "#64748b", marginBottom: 4 }}>CLABE</div>
              <div style={{ display: "flex", gap: 8, alignItems: "center" }}>
                <code style={{
                  flex: 1, fontSize: 16, fontWeight: 800, color: "#0f172a",
                  letterSpacing: 1, background: "#fff", border: "1px solid #cbd5e1",
                  borderRadius: 8, padding: "9px 12px", wordBreak: "break-all",
                }}>{CLABE}</code>
                <button onClick={copiarClabe} style={{
                  padding: "9px 12px", borderRadius: 8, border: "1px solid #cbd5e1",
                  background: copiado ? "#dcfce7" : "#fff", color: copiado ? "#15803d" : "#475569",
                  fontWeight: 700, fontSize: 12, cursor: "pointer", whiteSpace: "nowrap",
                }}>{copiado ? "✓ Copiada" : "Copiar"}</button>
              </div>
            </div>
            <div style={{ marginTop: 10 }}>
              <div style={{ fontSize: 11, color: "#64748b", marginBottom: 4 }}>Concepto sugerido</div>
              <code style={{
                display: "block", fontSize: 13, color: "#0f172a", background: "#fff",
                border: "1px solid #cbd5e1", borderRadius: 8, padding: "8px 12px",
              }}>{folio}</code>
            </div>
          </div>
        )}

        {estado === "idle" && !faltaConfig && (
          <div style={{
            background: "#fffbeb", border: "1px solid #fcd34d", borderRadius: 10,
            padding: "12px 16px", marginBottom: 18, fontSize: 12, color: "#92400e", lineHeight: 1.6,
          }}>
            <strong>Antes de entregar el producto:</strong>
            <ol style={{ margin: "8px 0 0", paddingLeft: 18 }}>
              <li>El cliente transfiere ${monto} a la CLABE de arriba.</li>
              <li>Abre <strong>tu</strong> app del banco y verifica que el abono ya esté ahí.</li>
              <li>Confirma que el monto coincide exactamente.</li>
            </ol>
            <div style={{ marginTop: 8, fontWeight: 700 }}>
              No aceptes la captura de pantalla del cliente como prueba. Un comprobante
              se falsifica en segundos; el abono en tu cuenta no.
            </div>
          </div>
        )}

        {estado === "esperando" && (
          <div style={{ marginBottom: 18 }}>
            <div style={{
              background: "#e0f2fe", border: "1px solid #7dd3fc", borderRadius: 10,
              padding: "12px 16px", fontSize: 13, color: "#075985", textAlign: "center", lineHeight: 1.55,
            }}>
              Esperando la transferencia...<br />
              <strong>¿Ya viste el abono de ${monto} en tu cuenta?</strong>
            </div>
            <div style={{ marginTop: 12 }}>
              <div style={{ fontSize: 11, color: "#64748b", marginBottom: 4 }}>
                Clave de rastreo (opcional, para aclaraciones)
              </div>
              <input
                value={referencia}
                onChange={(e) => setReferencia(e.target.value)}
                placeholder="Ej. 2026082540014..."
                style={{
                  width: "100%", boxSizing: "border-box", padding: "9px 12px",
                  borderRadius: 8, border: "1px solid #cbd5e1", fontSize: 13,
                }}
              />
            </div>
          </div>
        )}

        {estado === "exito" && (
          <div style={{
            background: "#f0fdf4", border: "1px solid #86efac", borderRadius: 10,
            padding: "12px 16px", marginBottom: 18, fontSize: 13,
            color: "#15803d", textAlign: "center", fontWeight: 700,
          }}>
            Transferencia confirmada. Registrando venta...
          </div>
        )}

        <div style={{ display: "flex", gap: 10, flexDirection: "column" }}>
          {estado === "idle" && (
            <button onClick={() => setEstado("esperando")} disabled={faltaConfig} style={{
              padding: 13, borderRadius: 10, border: "none",
              background: faltaConfig ? "#cbd5e1" : "linear-gradient(135deg,#0891b2,#0e7490)",
              color: "#fff", fontWeight: 800, fontSize: 15,
              cursor: faltaConfig ? "not-allowed" : "pointer",
            }}>
              🏦 Ya le di los datos al cliente
            </button>
          )}

          {estado === "esperando" && (
            <button onClick={confirmar} style={{
              padding: 13, borderRadius: 10, border: "none",
              background: "linear-gradient(135deg,#16a34a,#15803d)",
              color: "#fff", fontWeight: 800, fontSize: 15, cursor: "pointer",
            }}>
              ✅ Vi el abono en mi cuenta — registrar venta
            </button>
          )}

          {estado !== "exito" && (
            <button onClick={cerrar} style={{
              padding: 10, borderRadius: 10, border: "1px solid #e2e8f0",
              background: "transparent", color: "#475569",
              fontWeight: 700, fontSize: 13, cursor: "pointer",
            }}>✕ Cancelar — cobrar de otra forma</button>
          )}
        </div>

        {estado === "esperando" && (
          <div style={{ marginTop: 14, fontSize: 10, color: "#94a3b8", textAlign: "center", lineHeight: 1.6 }}>
            La venta NO se registra hasta que confirmes el abono.
          </div>
        )}
      </div>
    </div>
  );
}

function Dato({ label, valor }) {
  return (
    <div style={{ display: "flex", justifyContent: "space-between", padding: "3px 0", gap: 12 }}>
      <span style={{ fontSize: 12, color: "#64748b" }}>{label}</span>
      <span style={{ fontSize: 12.5, color: "#0f172a", fontWeight: 600, textAlign: "right" }}>{valor}</span>
    </div>
  );
}
