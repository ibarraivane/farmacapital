import { useMemo, useState } from "react";
import {
  cotizarEnvioPedido,
  crearLinkPagoEnvio,
  despacharEnvioPedido,
} from "../lib/envioDomicilioClient";
import {
  formatEnvioMoney,
  leerMetaEnvio,
  minutosRestantesCotizacion,
  proveedorSugerido,
} from "../lib/envioDomicilio";

const DIDI_STAFF_URL = "https://www.didi-food.com/es-MX/mobile-delivery/home";

export default function EnvioCotizacionPanel({ pedido, showToast, onUpdated }) {
  const meta = leerMetaEnvio(pedido);
  const mins = minutosRestantesCotizacion(meta.cotizar_antes_de);
  const vencido = meta.estado === "vencido" || (mins === 0 && meta.estado === "pendiente_cotizacion");
  const [costo, setCosto] = useState(
    meta.costo_cotizado != null ? String(meta.costo_cotizado) : (meta.costo_tabla != null ? String(meta.costo_tabla) : "")
  );
  const [proveedor, setProveedor] = useState(meta.proveedor || proveedorSugerido(meta.colonia || ""));
  const [busy, setBusy] = useState(false);

  const direccion = useMemo(() => {
    return [meta.calle || pedido?.direccion, meta.colonia, meta.cp].filter(Boolean).join(", ");
  }, [meta.calle, meta.colonia, meta.cp, pedido?.direccion]);

  const token = () => sessionStorage.getItem("farmacapital_session_token");

  const guardarCotizacion = async () => {
    const n = Number(costo);
    if (!Number.isFinite(n) || n < 0) {
      showToast("Escribe el costo cotizado (0 si va gratis).", "warning");
      return;
    }
    setBusy(true);
    const r = await cotizarEnvioPedido({
      pedidoId: pedido.id,
      sessionToken: token(),
      costo: n,
      proveedor,
      distanciaKm: meta.distancia_km,
    });
    setBusy(false);
    if (!r.ok) {
      showToast(r.error === "fuera_radio" ? "Fuera de radio (máx. 5 km)." : `No se guardó la cotización: ${r.error}`, "warning");
      return;
    }
    showToast("Cotización guardada", "success");
    onUpdated?.(r.envio);
  };

  const mandarLink = async () => {
    setBusy(true);
    const r = await crearLinkPagoEnvio({ pedidoId: pedido.id, sessionToken: token() });
    setBusy(false);
    if (!r.ok) {
      showToast(r.error === "quote_required" ? "Primero guarda la cotización." : `No se creó el link: ${r.error}`, "warning");
      return;
    }
    if (r.gratis) {
      showToast("Envío gratis · ya quedó pagado", "success");
      onUpdated?.(r.envio);
      return;
    }
    if (r.initPoint && navigator?.clipboard?.writeText) {
      try { await navigator.clipboard.writeText(r.initPoint); } catch (_) { /* noop */ }
    }
    showToast(r.initPoint ? "Link de pago listo (copiado). Envíalo por WhatsApp." : "Link creado", "success");
    onUpdated?.(r.envio);
    if (r.initPoint) window.open(r.initPoint, "_blank", "noopener,noreferrer");
  };

  const marcarRuta = async () => {
    setBusy(true);
    const r = await despacharEnvioPedido({ pedidoId: pedido.id, sessionToken: token() });
    setBusy(false);
    if (!r.ok) {
      const msg = r.error === "envio_no_pagado"
        ? "El cliente aún no paga el envío."
        : r.error === "cotizacion_vencida"
          ? "Se venció el plazo de cotización. Vuelve a cotizar."
          : `No se marcó en ruta: ${r.error}`;
      showToast(msg, "warning");
      return;
    }
    showToast("Marcado en ruta", "success");
    onUpdated?.(r.envio);
  };

  return (
    <div style={{
      marginTop: 10,
      padding: "10px 12px",
      borderRadius: 8,
      border: `1px solid ${vencido ? "#fca5a5" : "#99f6e4"}`,
      background: vencido ? "#fef2f2" : "#f0fdfa",
      fontSize: 12,
      color: "#134e4a",
    }}>
      <div style={{ fontWeight: 800, marginBottom: 6 }}>Cotizar entrega a domicilio</div>
      <div style={{ lineHeight: 1.4, marginBottom: 8 }}>
        {direccion || "Sin dirección"}
        {meta.distancia_km != null ? ` · ${Number(meta.distancia_km).toFixed(2)} km` : ""}
        {meta.costo_tabla != null ? ` · tabla ${formatEnvioMoney(meta.costo_tabla)}` : ""}
      </div>
      <div style={{ marginBottom: 8, fontWeight: 700, color: vencido ? "#991b1b" : "#0f766e" }}>
        {meta.estado === "pagado" && "Envío pagado"}
        {meta.estado === "link_enviado" && "Link de pago enviado · esperando al cliente"}
        {meta.estado === "en_ruta" && "En ruta"}
        {meta.estado === "fuera_radio" && "Fuera de radio · no se envía"}
        {(meta.estado === "pendiente_cotizacion" || !meta.estado) && (
          vencido
            ? "Plazo de cotización vencido (15 min). Aún puedes cotizar si el pedido sigue vivo."
            : `Cotizar antes de ${meta.cotizar_antes_de ? new Date(meta.cotizar_antes_de).toLocaleTimeString("es-MX", { hour: "2-digit", minute: "2-digit" }) : "—"} · ${mins ?? "—"} min`
        )}
        {meta.estado === "cotizado" && `Cotizado ${formatEnvioMoney(meta.costo_cotizado)}`}
      </div>
      <div style={{ display: "flex", flexWrap: "wrap", gap: 8, marginBottom: 8 }}>
        <a
          href={DIDI_STAFF_URL}
          target="_blank"
          rel="noreferrer"
          style={{ fontWeight: 800, color: "#0f766e" }}
        >
          Abrir DiDi (cotizar)
        </a>
        <button
          type="button"
          onClick={() => {
            if (direccion && navigator?.clipboard?.writeText) navigator.clipboard.writeText(direccion);
          }}
          style={{ border: "none", background: "none", color: "#0f766e", fontWeight: 700, cursor: "pointer", padding: 0 }}
        >
          Copiar dirección
        </button>
      </div>
      {meta.estado !== "fuera_radio" && meta.estado !== "en_ruta" && (
        <div style={{ display: "flex", flexWrap: "wrap", gap: 8, alignItems: "center" }}>
          <label>
            Costo MXN{" "}
            <input
              value={costo}
              onChange={(e) => setCosto(e.target.value)}
              inputMode="decimal"
              style={{ width: 80, padding: "4px 6px" }}
            />
          </label>
          <label>
            Proveedor{" "}
            <select value={proveedor} onChange={(e) => setProveedor(e.target.value)}>
              <option value="didi">DiDi</option>
              <option value="uber">Uber (fallback)</option>
              <option value="propio">Repartidor propio</option>
            </select>
          </label>
          <button type="button" disabled={busy} onClick={guardarCotizacion}>Guardar cotización</button>
          <button type="button" disabled={busy} onClick={mandarLink}>Enviar link de pago</button>
          <button type="button" disabled={busy} onClick={marcarRuta}>Marcar en ruta</button>
        </div>
      )}
      {meta.mp_init_point && (
        <div style={{ marginTop: 8 }}>
          <a href={meta.mp_init_point} target="_blank" rel="noreferrer">Abrir link de pago</a>
        </div>
      )}
    </div>
  );
}
