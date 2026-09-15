import { useMemo, useState } from "react";
import {
  cotizarEnvioPedido,
  despacharEnvioPedido,
} from "../lib/envioDomicilioClient";
import {
  formatEnvioMoney,
  leerMetaEnvio,
  proveedorSugerido,
} from "../lib/envioDomicilio";

const DIDI_STAFF_URL = "https://www.didi-food.com/es-MX/mobile-delivery/home";

export default function EnvioCotizacionPanel({ pedido, showToast, onUpdated }) {
  const meta = leerMetaEnvio(pedido);
  const pedidoPaid = String(pedido?.payment_status || "").toLowerCase() === "approved";
  const cobradoCheckout = Boolean(meta.cobrado_en_checkout) || pedidoPaid;
  const pagado = meta.estado === "pagado" || (cobradoCheckout && pedidoPaid);
  const [costoReal, setCostoReal] = useState(
    meta.costo_real_mensajeria != null
      ? String(meta.costo_real_mensajeria)
      : (meta.costo_tabla != null ? String(meta.costo_tabla) : "")
  );
  const [proveedor, setProveedor] = useState(meta.proveedor || proveedorSugerido(meta.colonia || ""));
  const [busy, setBusy] = useState(false);

  const direccion = useMemo(() => {
    return [meta.calle || pedido?.direccion, meta.colonia, meta.cp].filter(Boolean).join(", ");
  }, [meta.calle, meta.colonia, meta.cp, pedido?.direccion]);

  const cobradoCliente = Number(meta.costo_cotizado ?? pedido?.costo_envio);
  const token = () => sessionStorage.getItem("farmacapital_session_token");

  const guardarCostoReal = async () => {
    const n = Number(costoReal);
    if (!Number.isFinite(n) || n < 0) {
      showToast("Escribe el costo real de la mensajería (0 si va propio/gratis).", "warning");
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
      showToast(r.error === "fuera_radio" ? "Fuera de radio (máx. 5 km)." : `No se guardó: ${r.error}`, "warning");
      return;
    }
    showToast("Costo real guardado (interno; el cliente ya pagó la tarifa de checkout)", "success");
    onUpdated?.(r.envio);
  };

  const marcarRuta = async () => {
    setBusy(true);
    const r = await despacharEnvioPedido({ pedidoId: pedido.id, sessionToken: token() });
    setBusy(false);
    if (!r.ok) {
      const msg = r.error === "envio_no_pagado"
        ? "El pedido aún no tiene pago aprobado."
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
      border: `1px solid ${meta.estado === "fuera_radio" ? "#fca5a5" : "#99f6e4"}`,
      background: meta.estado === "fuera_radio" ? "#fef2f2" : "#f0fdfa",
      fontSize: 12,
      color: "#134e4a",
    }}>
      <div style={{ fontWeight: 800, marginBottom: 6 }}>Entrega a domicilio</div>
      <div style={{ lineHeight: 1.4, marginBottom: 8 }}>
        {direccion || "Sin dirección"}
        {meta.distancia_km != null ? ` · ${Number(meta.distancia_km).toFixed(2)} km` : ""}
        {Number.isFinite(cobradoCliente)
          ? ` · cobrado en checkout ${formatEnvioMoney(cobradoCliente)}`
          : ""}
      </div>
      <div style={{ marginBottom: 8, fontWeight: 700, color: meta.estado === "fuera_radio" ? "#991b1b" : "#0f766e" }}>
        {meta.estado === "en_ruta" && "En ruta"}
        {meta.estado === "fuera_radio" && "Fuera de radio · no se envía"}
        {meta.estado !== "en_ruta" && meta.estado !== "fuera_radio" && pagado && (
          `Cliente ya pagó el envío en checkout${Number.isFinite(cobradoCliente) ? ` (${formatEnvioMoney(cobradoCliente)})` : ""}. No se manda link.`
        )}
        {meta.estado !== "en_ruta" && meta.estado !== "fuera_radio" && !pagado && (
          "El envío se cobra en el checkout. Espera el pago aprobado para marcar en ruta."
        )}
      </div>
      <div style={{ display: "flex", flexWrap: "wrap", gap: 8, marginBottom: 8 }}>
        <a
          href={DIDI_STAFF_URL}
          target="_blank"
          rel="noreferrer"
          style={{ fontWeight: 800, color: "#0f766e" }}
        >
          Abrir DiDi (pedir mensajero)
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
            Costo real mensajería{" "}
            <input
              value={costoReal}
              onChange={(e) => setCostoReal(e.target.value)}
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
          <button type="button" disabled={busy} onClick={guardarCostoReal}>Guardar costo real</button>
          <button type="button" disabled={busy} onClick={marcarRuta}>Marcar en ruta</button>
        </div>
      )}
    </div>
  );
}
