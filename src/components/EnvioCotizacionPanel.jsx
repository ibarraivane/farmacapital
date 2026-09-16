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
const UBER_STAFF_URL = "https://m.uber.com/";

export default function EnvioCotizacionPanel({ pedido, showToast, onUpdated }) {
  const meta = leerMetaEnvio(pedido);
  const pedidoPaid = String(pedido?.payment_status || "").toLowerCase() === "approved";
  const [costo, setCosto] = useState(
    meta.costo_cotizado != null ? String(meta.costo_cotizado) : ""
  );
  const [proveedor, setProveedor] = useState(meta.proveedor || proveedorSugerido(meta.colonia || ""));
  const [busy, setBusy] = useState(false);

  const direccion = useMemo(() => {
    return [meta.calle || pedido?.direccion, meta.colonia, meta.cp].filter(Boolean).join(", ");
  }, [meta.calle, meta.colonia, meta.cp, pedido?.direccion]);

  const token = () => sessionStorage.getItem("farmacapital_session_token");

  const enviarCotizacion = async () => {
    const n = Number(costo);
    if (!Number.isFinite(n) || n < 0) {
      showToast("Escribe el costo que te dio DiDi o Uber.", "warning");
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
      showToast(r.error === "pedido_ya_pagado" ? "Este pedido ya está pagado." : `No se guardó: ${r.error}`, "warning");
      return;
    }
    showToast(
      r.whatsapp?.sent
        ? "Costo guardado y WhatsApp enviado al cliente."
        : "Costo guardado. Si no salió el WhatsApp, avísale tú desde el botón verde.",
      r.whatsapp?.sent ? "success" : "warning"
    );
    onUpdated?.(r.envio);
  };

  const marcarRuta = async () => {
    setBusy(true);
    const r = await despacharEnvioPedido({ pedidoId: pedido.id, sessionToken: token() });
    setBusy(false);
    if (!r.ok) {
      const msg = r.error === "envio_no_pagado"
        ? "El cliente aún no liquida en la tienda."
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
      border: "1px solid #99f6e4",
      background: "#f0fdfa",
      fontSize: 12,
      color: "#134e4a",
    }}>
      <div style={{ fontWeight: 800, marginBottom: 6 }}>Entrega a domicilio</div>
      <div style={{ lineHeight: 1.4, marginBottom: 8 }}>
        {direccion || "Sin dirección"}
        {meta.distancia_km != null ? ` · ${Number(meta.distancia_km).toFixed(2)} km` : ""}
        {Number.isFinite(Number(meta.costo_cotizado))
          ? ` · cotizado ${formatEnvioMoney(meta.costo_cotizado)}`
          : " · falta cotizar"}
      </div>
      <div style={{ marginBottom: 8, fontWeight: 700, color: "#0f766e" }}>
        {meta.estado === "en_ruta" && "En ruta"}
        {pedidoPaid && meta.estado !== "en_ruta" && "Cliente ya pagó. Puedes pedir el mensajero."}
        {!pedidoPaid && meta.estado === "cotizado" && "Cotización enviada. Esperando que el cliente pague en la tienda."}
        {!pedidoPaid && meta.estado !== "cotizado" && meta.estado !== "en_ruta" && "Abre DiDi o Uber, cotiza y pon aquí el costo. Se le avisa por WhatsApp para que liquide."}
      </div>
      <div style={{ display: "flex", flexWrap: "wrap", gap: 8, marginBottom: 8 }}>
        <a href={DIDI_STAFF_URL} target="_blank" rel="noreferrer" style={{ fontWeight: 800, color: "#0f766e" }}>
          Abrir DiDi
        </a>
        <a href={UBER_STAFF_URL} target="_blank" rel="noreferrer" style={{ fontWeight: 800, color: "#0f766e" }}>
          Abrir Uber
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
      {meta.estado !== "en_ruta" && (
        <div style={{ display: "flex", flexWrap: "wrap", gap: 8, alignItems: "center" }}>
          <label>
            Costo transporte{" "}
            <input
              value={costo}
              onChange={(e) => setCosto(e.target.value)}
              inputMode="decimal"
              style={{ width: 80, padding: "4px 6px" }}
            />
          </label>
          <label>
            App{" "}
            <select value={proveedor} onChange={(e) => setProveedor(e.target.value)}>
              <option value="didi">DiDi</option>
              <option value="uber">Uber</option>
              <option value="propio">Repartidor propio</option>
            </select>
          </label>
          <button type="button" disabled={busy || pedidoPaid} onClick={enviarCotizacion}>
            Guardar y avisar al cliente
          </button>
          <button type="button" disabled={busy} onClick={marcarRuta}>Marcar en ruta</button>
        </div>
      )}
    </div>
  );
}
