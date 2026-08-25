import React, { useState, useEffect, useRef } from "react";
import { crearCobroSpei, esperarAcreditacionSpei } from "../utils/mercadoPago";

/**
 * FARMACAPITAL — Cobro por transferencia SPEI vía Mercado Pago
 *
 * A diferencia del SPEI manual, aquí MP genera una CLABE distinta por
 * cobro y avisa solo cuando el dinero llega: el cajero no tiene que
 * juzgar ningún comprobante. El costo es la comisión de MP y que el
 * dinero cae en la cuenta de Mercado Pago, no en el banco.
 *
 * La venta se registra únicamente cuando MP reporta la acreditación.
 */
export default function SpeiMPModal({ open, total, folio, clienteEmail, onSuccess, onCancel }) {
  const [estado, setEstado] = useState("idle"); // idle | creando | esperando | exito | error
  const [datos, setDatos]   = useState(null);
  const [error, setError]   = useState("");
  const [copiado, setCopiado] = useState(false);
  const [segundos, setSegundos] = useState(0);
  const esperaRef = useRef(null);
  const tickRef   = useRef(null);

  const detener = () => {
    if (esperaRef.current?.cancelar) esperaRef.current.cancelar();
    esperaRef.current = null;
    if (tickRef.current) clearInterval(tickRef.current);
    tickRef.current = null;
  };

  useEffect(() => {
    if (!open) {
      detener();
      setEstado("idle");
      setDatos(null);
      setError("");
      setCopiado(false);
      setSegundos(0);
    }
    return detener;
  }, [open]);

  useEffect(() => {
    if (!open) return undefined;
    const prev = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return () => { document.body.style.overflow = prev || "auto"; };
  }, [open]);

  if (!open) return null;

  const monto = parseFloat(total || 0).toFixed(2);

  const generar = async () => {
    setEstado("creando");
    setError("");
    try {
      const d = await crearCobroSpei({
        amount: Number(total),
        description: `Venta FarmaCapital ${folio}`,
        externalReference: folio,
        payerEmail: clienteEmail || undefined,
      });
      if (!d?.order_id) {
        // Sin id de orden no hay forma de saber si la transferencia llegó,
        // y cobrar a ciegas es peor que no cobrar.
        throw new Error("Mercado Pago no devolvió un identificador de cobro. Cobra de otra forma.");
      }
      setDatos(d);
      setEstado("esperando");
      setSegundos(0);

      tickRef.current = setInterval(() => setSegundos((s) => s + 1), 1000);

      const espera = esperarAcreditacionSpei(d.order_id);
      esperaRef.current = espera;
      espera
        .then(({ data }) => {
          detener();
          setEstado("exito");
          setTimeout(() => onSuccess?.({
            via: "spei_mp",
            order_id: d.order_id,
            referencia: data?.referencia || d.referencia || null,
            folio,
          }), 1000);
        })
        .catch((e) => {
          detener();
          setError(e?.message || "No se acreditó la transferencia.");
          setEstado("error");
        });
    } catch (e) {
      setError(e?.message || "No se pudo generar la CLABE de cobro.");
      setEstado("error");
    }
  };

  const copiar = async (texto) => {
    try {
      await navigator.clipboard.writeText(texto);
      setCopiado(true);
      setTimeout(() => setCopiado(false), 2000);
    } catch {
      setCopiado(false);
    }
  };

  const cerrar = () => { detener(); onCancel?.(); };

  const iconos = { idle: "🏦", creando: "⏳", esperando: "📲", exito: "✅", error: "❌" };
  const mmss = `${String(Math.floor(segundos / 60)).padStart(2, "0")}:${String(segundos % 60).padStart(2, "0")}`;

  return (
    <div style={{
      position: "fixed", inset: 0,
      background: "rgba(15,23,42,.65)", backdropFilter: "blur(4px)",
      zIndex: 9000, display: "flex", alignItems: "center", justifyContent: "center", padding: 20,
    }}>
      <div style={{
        background: "#fff", borderRadius: 16, width: "min(440px,95vw)",
        maxHeight: "92vh", overflowY: "auto", padding: 28,
        boxShadow: "0 24px 80px rgba(0,158,227,.2)",
      }}>
        <div style={{ textAlign: "center", marginBottom: 20 }}>
          <div style={{ fontSize: 44, marginBottom: 6 }}>{iconos[estado]}</div>
          <div style={{ fontWeight: 800, fontSize: 18, color: "#0f172a" }}>
            Transferencia vía Mercado Pago
          </div>
          <div style={{ color: "#475569", fontSize: 13, marginTop: 4 }}>Folio: {folio}</div>
        </div>

        <div style={{
          background: "#e6f7fd", borderRadius: 12, padding: 16,
          textAlign: "center", marginBottom: 18, border: "1px solid #9adcf5",
        }}>
          <div style={{ color: "#0080b0", fontSize: 11, fontWeight: 700, marginBottom: 4 }}>
            TOTAL A TRANSFERIR
          </div>
          <div style={{ color: "#006c95", fontWeight: 900, fontSize: 36 }}>${monto}</div>
        </div>

        {estado === "idle" && (
          <div style={{
            background: "#f8fafc", border: "1px solid #e2e8f0", borderRadius: 10,
            padding: "12px 16px", marginBottom: 18, fontSize: 12, color: "#475569", lineHeight: 1.6,
          }}>
            <strong style={{ color: "#0f172a" }}>Cómo funciona:</strong>
            <ol style={{ margin: "8px 0 0", paddingLeft: 18 }}>
              <li>Mercado Pago genera una CLABE única para este cobro.</li>
              <li>El cliente transfiere desde su banco a esa CLABE.</li>
              <li>Cuando el dinero llega, la venta se registra sola.</li>
            </ol>
            <div style={{ marginTop: 8 }}>
              No hay que revisar comprobantes: la CLABE es de un solo uso y
              sirve exactamente para este monto.
            </div>
          </div>
        )}

        {estado === "creando" && (
          <div style={{
            background: "#e6f7fd", border: "1px solid #9adcf5", borderRadius: 10,
            padding: "12px 16px", marginBottom: 18, fontSize: 13,
            color: "#006c95", textAlign: "center",
          }}>
            Generando la CLABE de cobro...
          </div>
        )}

        {estado === "esperando" && datos && (
          <>
            <div style={{
              background: "#f8fafc", border: "1px solid #e2e8f0",
              borderRadius: 10, padding: 16, marginBottom: 14,
            }}>
              <div style={{ fontSize: 11, color: "#64748b", fontWeight: 700, marginBottom: 8, letterSpacing: .5 }}>
                CLABE ÚNICA DE ESTE COBRO
              </div>
              <div style={{ display: "flex", gap: 8, alignItems: "center" }}>
                <code style={{
                  flex: 1, fontSize: 16, fontWeight: 800, color: "#0f172a",
                  letterSpacing: 1, background: "#fff", border: "1px solid #cbd5e1",
                  borderRadius: 8, padding: "9px 12px", wordBreak: "break-all",
                }}>{datos.clabe}</code>
                <button onClick={() => copiar(datos.clabe)} style={{
                  padding: "9px 12px", borderRadius: 8, border: "1px solid #cbd5e1",
                  background: copiado ? "#dcfce7" : "#fff", color: copiado ? "#15803d" : "#475569",
                  fontWeight: 700, fontSize: 12, cursor: "pointer", whiteSpace: "nowrap",
                }}>{copiado ? "✓" : "Copiar"}</button>
              </div>
              {datos.beneficiario && (
                <div style={{ marginTop: 10, fontSize: 12, color: "#475569" }}>
                  Beneficiario: <strong style={{ color: "#0f172a" }}>{datos.beneficiario}</strong>
                </div>
              )}
              {datos.banco && (
                <div style={{ marginTop: 3, fontSize: 12, color: "#475569" }}>
                  Banco: <strong style={{ color: "#0f172a" }}>{datos.banco}</strong>
                </div>
              )}
            </div>

            <div style={{
              background: "#e0f2fe", border: "1px solid #7dd3fc", borderRadius: 10,
              padding: "12px 16px", marginBottom: 18, fontSize: 13,
              color: "#075985", textAlign: "center", lineHeight: 1.55,
            }}>
              Esperando la transferencia... <strong>{mmss}</strong><br />
              <span style={{ fontSize: 11.5 }}>
                En cuanto el dinero llegue, la venta se registra sola.
                No cierres esta ventana.
              </span>
            </div>
          </>
        )}

        {estado === "exito" && (
          <div style={{
            background: "#f0fdf4", border: "1px solid #86efac", borderRadius: 10,
            padding: "12px 16px", marginBottom: 18, fontSize: 13,
            color: "#15803d", textAlign: "center", fontWeight: 700,
          }}>
            ¡Transferencia acreditada! Registrando venta...
          </div>
        )}

        {estado === "error" && (
          <div style={{
            background: "#fef2f2", border: "1px solid #fca5a5", borderRadius: 10,
            padding: "12px 16px", marginBottom: 18, fontSize: 12.5,
            color: "#b91c1c", lineHeight: 1.6,
          }}>
            {error}
          </div>
        )}

        <div style={{ display: "flex", gap: 10, flexDirection: "column" }}>
          {(estado === "idle" || estado === "error") && (
            <button onClick={generar} style={{
              padding: 13, borderRadius: 10, border: "none",
              background: "linear-gradient(135deg,#009ee3,#0080b0)",
              color: "#fff", fontWeight: 800, fontSize: 15, cursor: "pointer",
            }}>
              {estado === "error" ? "↻ Intentar de nuevo" : "🏦 Generar CLABE de cobro"}
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
            Si cancelas, la referencia deja de servir y el cliente no debe transferir.<br />
            La venta NO se registra hasta que Mercado Pago confirme el depósito.
          </div>
        )}
      </div>
    </div>
  );
}
