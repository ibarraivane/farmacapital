import React, { useCallback, useEffect, useState } from "react";
import {
  consultarEstadoPoint,
  activarPdvPoint,
  resetearTerminalPoint,
  textoPaqueteSoportePoint,
} from "../utils/mercadoPago";

async function copyText(text) {
  if (navigator.clipboard?.writeText) {
    await navigator.clipboard.writeText(text);
    return;
  }
  const el = document.createElement("textarea");
  el.value = text;
  el.setAttribute("readonly", "");
  el.style.position = "fixed";
  el.style.left = "-9999px";
  document.body.appendChild(el);
  el.select();
  document.execCommand("copy");
  document.body.removeChild(el);
}

export default function PointMpStatusPanel({ compact = false }) {
  const [open, setOpen] = useState(!compact);
  const [busy, setBusy] = useState("");
  const [status, setStatus] = useState(null);
  const [error, setError] = useState("");
  const [copied, setCopied] = useState(false);

  const run = useCallback(async (label, fn) => {
    setBusy(label);
    setError("");
    setCopied(false);
    try {
      const data = await fn();
      if (data) setStatus(data);
      return data;
    } catch (e) {
      setError(e?.message || "Error al consultar el Point");
      return null;
    } finally {
      setBusy("");
    }
  }, []);

  const refresh = () => run("status", consultarEstadoPoint);

  useEffect(() => {
    if (open && !status && !busy) refresh();
    // Carga inicial al abrir el panel; no re-consultar en cada render.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [open]);

  const copySupport = async () => {
    let data = status;
    if (!data) data = await refresh();
    const text = textoPaqueteSoportePoint(data || {});
    try {
      await copyText(text);
      setCopied(true);
    } catch {
      setError("No se pudo copiar. Selecciona el texto manualmente.");
    }
  };

  const device = status?.device || status?.devices?.[0];
  const mode = status?.operating_mode || device?.operating_mode || "—";
  const pending = status?.pending_count ?? null;

  const btn = (label, onClick, disabled) => (
    <button
      type="button"
      onClick={onClick}
      disabled={!!busy || disabled}
      style={{
        padding: "6px 10px",
        borderRadius: 8,
        border: "1px solid #cbd5e1",
        background: "#fff",
        color: "#334155",
        fontSize: 11,
        fontWeight: 700,
        cursor: busy ? "wait" : "pointer",
      }}
    >
      {label}
    </button>
  );

  return (
    <div style={{ marginTop: 10, border: "1px solid #e2e8f0", borderRadius: 10, background: "#f8fafc", padding: 10 }}>
      <button
        type="button"
        onClick={() => {
          setOpen((v) => !v);
          if (!status && !open) refresh();
        }}
        style={{
          width: "100%",
          border: "none",
          background: "transparent",
          textAlign: "left",
          cursor: "pointer",
          fontSize: 11,
          fontWeight: 800,
          color: "#0f172a",
        }}
      >
        {open ? "▾" : "▸"} Estado Point Smart 2
        {mode !== "—" ? ` · ${mode}` : ""}
        {pending != null ? ` · cola ${pending}` : ""}
      </button>
      {open && (
        <div style={{ marginTop: 8 }}>
          <div style={{ fontSize: 11, color: "#475569", lineHeight: 1.45, marginBottom: 8 }}>
            {busy ? "Consultando Mercado Pago…" : status?.diagnosis || "Pulsa Actualizar para ver store_id / pos_id y copiar el paquete a soporte."}
          </div>
          {device && (
            <div style={{ fontSize: 10, color: "#64748b", fontFamily: "ui-monospace, Menlo, monospace", lineHeight: 1.5, marginBottom: 8 }}>
              terminal_id: {device.id}<br />
              store_id: {device.store_id || "—"} · pos_id: {device.pos_id ?? "—"}<br />
              external_pos_id: {device.external_pos_id === "" ? "(vacío)" : (device.external_pos_id || "—")}
            </div>
          )}
          {error && <div style={{ color: "#b91c1c", fontSize: 11, marginBottom: 8 }}>{error}</div>}
          <div style={{ display: "flex", flexWrap: "wrap", gap: 6 }}>
            {btn(busy === "status" ? "Actualizando…" : "Actualizar", refresh)}
            {btn(busy === "pdv" ? "Activando…" : "Reactivar PDV", () => run("pdv", async () => {
              await activarPdvPoint();
              return consultarEstadoPoint();
            }))}
            {btn(busy === "reset" ? "Reseteando…" : "Reset cola + PDV", () => run("reset", async () => {
              await resetearTerminalPoint();
              return consultarEstadoPoint();
            }))}
            {btn(copied ? "Copiado" : "Copiar para soporte MP", copySupport)}
          </div>
        </div>
      )}
    </div>
  );
}
