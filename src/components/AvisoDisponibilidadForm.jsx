import { useState } from "react";
import {
  AVISO_API_PATH,
  validarAvisoDisponibilidad,
} from "../lib/encargoMedicamentos";

/**
 * Caso A — formulario "Avísame cuando esté disponible".
 * Solo teléfono obligatorio; sin login.
 */
export default function AvisoDisponibilidadForm({
  productoId,
  productoNombre,
  brandPrimary = "#0B6E4F",
  onDone,
}) {
  const [nombre, setNombre] = useState("");
  const [telefono, setTelefono] = useState("");
  const [website, setWebsite] = useState(""); // honeypot
  const [sending, setSending] = useState(false);
  const [msg, setMsg] = useState(null);
  const [err, setErr] = useState(null);

  async function onSubmit(e) {
    e?.preventDefault?.();
    setMsg(null);
    setErr(null);
    const parsed = validarAvisoDisponibilidad({
      producto_id: productoId,
      nombre,
      telefono,
    });
    if (!parsed.ok) {
      setErr(parsed.errors[0] || "Revisa los datos.");
      return;
    }
    setSending(true);
    try {
      const resp = await fetch(AVISO_API_PATH, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          producto_id: parsed.value.producto_id,
          nombre: parsed.value.cliente_nombre,
          telefono: parsed.value.cliente_telefono,
          website,
        }),
      });
      const data = await resp.json().catch(() => ({}));
      if (!resp.ok || !data?.ok) {
        if (data?.error === "producto_con_stock") {
          setErr(data.message || "Ya hay stock: agrégalo al carrito.");
        } else {
          setErr("No se pudo registrar el aviso. Intenta de nuevo.");
        }
        return;
      }
      setMsg(
        data.mensaje ||
          (data.duplicado
            ? "Ya estabas registrado: te avisamos cuando haya stock."
            : "Listo. Te avisamos por WhatsApp cuando esté disponible."),
      );
      onDone?.(data);
    } catch {
      setErr("Sin conexión. Intenta de nuevo.");
    } finally {
      setSending(false);
    }
  }

  if (msg) {
    return (
      <div
        style={{
          background: "#ecfdf5",
          border: "1px solid #a7f3d0",
          borderRadius: 10,
          padding: "12px 14px",
          color: "#065f46",
          fontSize: 13,
          fontWeight: 600,
          lineHeight: 1.45,
        }}
      >
        {msg}
      </div>
    );
  }

  return (
    <form onSubmit={onSubmit} style={{ display: "grid", gap: 10 }}>
      <div style={{ fontSize: 13, fontWeight: 700, color: "#1f2937" }}>
        Avísame cuando esté disponible
        {productoNombre ? (
          <span style={{ fontWeight: 500, color: "#6b7280" }}> · {productoNombre}</span>
        ) : null}
      </div>
      <input
        value={nombre}
        onChange={(e) => setNombre(e.target.value)}
        placeholder="Tu nombre (opcional)"
        autoComplete="name"
        style={inputStyle}
      />
      <input
        value={telefono}
        onChange={(e) => setTelefono(e.target.value)}
        placeholder="WhatsApp a 10 dígitos"
        inputMode="tel"
        autoComplete="tel"
        required
        style={inputStyle}
      />
      {/* honeypot */}
      <input
        value={website}
        onChange={(e) => setWebsite(e.target.value)}
        tabIndex={-1}
        autoComplete="off"
        aria-hidden="true"
        style={{ position: "absolute", left: -9999, opacity: 0, height: 0, width: 0 }}
      />
      {err ? (
        <div style={{ color: "#b91c1c", fontSize: 12, fontWeight: 600 }}>{err}</div>
      ) : null}
      <button
        type="submit"
        disabled={sending}
        style={{
          border: "none",
          borderRadius: 10,
          padding: "10px 14px",
          background: brandPrimary,
          color: "#fff",
          fontWeight: 800,
          fontSize: 13,
          cursor: sending ? "wait" : "pointer",
          opacity: sending ? 0.7 : 1,
        }}
      >
        {sending ? "Registrando…" : "Avísame por WhatsApp"}
      </button>
    </form>
  );
}

const inputStyle = {
  width: "100%",
  boxSizing: "border-box",
  border: "1px solid #e5e7eb",
  borderRadius: 10,
  padding: "10px 12px",
  fontSize: 14,
  fontFamily: "inherit",
};
