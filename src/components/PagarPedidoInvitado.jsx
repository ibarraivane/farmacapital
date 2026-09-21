import { useMemo, useState } from "react";
import { Btn } from "../ui";
import { BRAND, C_LIGHT } from "../constants";
import { formatEnvioMoney } from "../lib/envioDomicilio";

const campo = {
  background: "#ffffff",
  color: "#0f172a",
  WebkitTextFillColor: "#0f172a",
  caretColor: "#0f172a",
  colorScheme: "light",
  border: "1px solid #e2e8f0",
  borderRadius: 10,
  padding: "12px 14px",
  fontSize: 16,
  width: "100%",
  boxSizing: "border-box",
  fontFamily: "var(--fc-body)",
};

function pedidoIdDesdeUrl() {
  try {
    const q = new URLSearchParams(window.location.search);
    const raw = q.get("pedido") || q.get("id") || "";
    const n = Number(String(raw).replace(/\D/g, ""));
    return Number.isFinite(n) && n > 0 ? n : null;
  } catch {
    return null;
  }
}

function mensajeError(code) {
  if (code === "guest_phone_mismatch") return "Ese teléfono no es el del pedido. Usa los 10 dígitos con los que lo hiciste.";
  if (code === "guest_checkout_expired") return "Pasó el tiempo para pagar este pedido. Escríbenos por WhatsApp y lo reabrimos.";
  if (code === "envio_quote_required") return "Todavía estamos cotizando el envío. En cuanto esté el precio, esta página te deja pagarlo.";
  if (code === "amount_mismatch") return "El total cambió. Vuelve a consultar el pedido e intenta de nuevo.";
  if (code === "pedido_not_found") return "No encontramos ese pedido.";
  return "No se pudo continuar. Intenta de nuevo o escríbenos por WhatsApp.";
}

export default function PagarPedidoInvitado() {
  const C = C_LIGHT;
  const pedidoId = useMemo(() => pedidoIdDesdeUrl(), []);
  const [tel, setTel] = useState("");
  const [resumen, setResumen] = useState(null);
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);

  const consultar = async () => {
    if (!pedidoId) {
      setError("Falta el número de pedido en la liga.");
      return;
    }
    setBusy(true);
    setError("");
    try {
      const resp = await fetch("/api/logistics/envio", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          action: "resumen-pago",
          pedidoId,
          guestPhone: tel,
        }),
      });
      const data = await resp.json().catch(() => ({}));
      if (!resp.ok || !data?.ok) {
        setResumen(null);
        setError(mensajeError(data?.error));
        setBusy(false);
        return;
      }
      setResumen(data);
    } catch {
      setError("No se pudo consultar el pedido.");
    }
    setBusy(false);
  };

  const pagar = async () => {
    if (!resumen?.puede_pagar) return;
    setBusy(true);
    setError("");
    try {
      const resp = await fetch("/api/payments/mp/create-preference", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          pedidoId,
          amount: Number(resumen.total || 0),
          baseUrl: window.location.origin,
          guest: true,
          guestPhone: tel,
          payer: {},
        }),
      });
      const data = await resp.json().catch(() => ({}));
      if (!resp.ok || !data?.ok || !(data.initPoint || data.sandboxInitPoint)) {
        setError(mensajeError(data?.error));
        setBusy(false);
        return;
      }
      window.location.href = data.initPoint || data.sandboxInitPoint;
    } catch {
      setError("No se pudo abrir el pago.");
      setBusy(false);
    }
  };

  const fee = resumen?.costo_envio != null ? Number(resumen.costo_envio) : null;

  return (
    <div style={{ maxWidth: 520, margin: "32px auto", padding: "0 16px" }}>
      <h1 style={{ color: C.text, fontSize: 24, fontWeight: 800, marginBottom: 8 }}>Pagar pedido</h1>
      <p style={{ color: C.textMid, fontSize: 14, lineHeight: 1.5, marginTop: 0 }}>
        {pedidoId
          ? `Pedido #${pedidoId}. El transporte cotizado ya va en este total. Un solo cargo: productos + envío.`
          : "Abre la liga que te mandó la farmacia. Trae el número de pedido."}
      </p>
      <label style={{ display: "block", color: C.text, fontWeight: 700, fontSize: 13, marginBottom: 6 }}>
        Teléfono del pedido
      </label>
      <input
        className="farmacapital-field-input"
        inputMode="tel"
        autoComplete="tel"
        placeholder="10 dígitos"
        value={tel}
        onChange={(e) => setTel(e.target.value)}
        style={campo}
      />
      <div style={{ marginTop: 12 }}>
        <Btn onClick={consultar} col={BRAND.primary} disabled={busy || !pedidoId}>
          {busy && !resumen ? "Buscando…" : "Ver mi total"}
        </Btn>
      </div>
      {error ? (
        <div style={{ marginTop: 14, padding: "10px 12px", background: "#fef3c7", border: "1px solid #fcd34d", borderRadius: 8, color: "#92400e", fontSize: 13 }}>
          {error}
        </div>
      ) : null}
      {resumen ? (
        <div style={{ marginTop: 18, background: "#fff", border: `1px solid ${C.border}`, borderRadius: 14, padding: 16 }}>
          <div style={{ fontWeight: 800, color: C.text, marginBottom: 8 }}>{resumen.folio}</div>
          {(resumen.lineas || []).map((linea, i) => (
            <div key={i} style={{ display: "flex", justifyContent: "space-between", gap: 12, padding: "6px 0", fontSize: 13, color: C.text }}>
              <span>{linea.nombre} ×{linea.cantidad}</span>
              <span style={{ fontWeight: 700 }}>{formatEnvioMoney(linea.importe)}</span>
            </div>
          ))}
          {Number(resumen.cargo_plataforma) > 0 ? (
            <div style={{ display: "flex", justifyContent: "space-between", gap: 12, padding: "6px 0", fontSize: 13, color: C.text }}>
              <span>Pedido en línea</span>
              <span style={{ fontWeight: 700 }}>{formatEnvioMoney(resumen.cargo_plataforma)}</span>
            </div>
          ) : null}
          {fee != null ? (
            <div style={{ display: "flex", justifyContent: "space-between", gap: 12, padding: "6px 0", fontSize: 13, color: C.text }}>
              <span>Envío a domicilio</span>
              <span style={{ fontWeight: 700 }}>{formatEnvioMoney(fee)}</span>
            </div>
          ) : (
            <div style={{ fontSize: 13, color: "#92400e", padding: "6px 0" }}>
              El envío todavía no tiene precio. Te avisamos cuando puedas pagar.
            </div>
          )}
          <div style={{ display: "flex", justifyContent: "space-between", marginTop: 10, paddingTop: 10, borderTop: `1px solid ${C.border}` }}>
            <span style={{ fontWeight: 800, color: C.text }}>Total</span>
            <span style={{ fontWeight: 900, color: BRAND.primary, fontSize: 18 }}>{formatEnvioMoney(resumen.total)}</span>
          </div>
          {resumen.pagado ? (
            <div style={{ marginTop: 12, color: "#166534", fontWeight: 700, fontSize: 14 }}>Este pedido ya está pagado.</div>
          ) : (
            <div style={{ marginTop: 14 }}>
              <Btn onClick={pagar} col={BRAND.primary} disabled={busy || !resumen.puede_pagar}>
                {busy ? "Abriendo pago…" : `Pagar ahora ${formatEnvioMoney(resumen.total)}`}
              </Btn>
            </div>
          )}
        </div>
      ) : null}
    </div>
  );
}
