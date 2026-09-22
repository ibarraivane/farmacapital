import { useMemo, useState } from "react";
import {
  cotizarEnvioPedido,
  despacharEnvioPedido,
} from "../lib/envioDomicilioClient";
import {
  cargoServicioPedido,
  desgloseEnvioCheckout,
  formatEnvioMoney,
  leerMetaEnvio,
  proveedorSugerido,
  textoClienteEnvioEnCheckout,
  mensajeCorreoEnvioCotizado,
} from "../lib/envioDomicilio";
import { Inp, Btn } from "../ui";
import { C_LIGHT } from "../constants";

const DIDI_STAFF_URL = "https://www.didi-food.com/es-MX/mobile-delivery/home";
const UBER_STAFF_URL = "https://m.uber.com/";

const campoClaro = {
  background: "#ffffff",
  color: C_LIGHT.text,
  WebkitTextFillColor: C_LIGHT.text,
  caretColor: C_LIGHT.text,
  colorScheme: "light",
};

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
      mensajeCorreoEnvioCotizado({
        sent: Boolean(r.email?.sent),
        reason: r.email?.reason,
        detail: r.email?.detail,
        costo: n,
      }),
      r.email?.sent ? "success" : "warning"
    );
    onUpdated?.({ envio: r.envio, total: r.total, costo_envio: n, items_total: r.items_total });
  };

  const marcarRuta = async () => {
    setBusy(true);
    const r = await despacharEnvioPedido({ pedidoId: pedido.id, sessionToken: token() });
    setBusy(false);
    if (!r.ok) {
      const msg = r.error === "envio_no_pagado"
        ? "Este pedido aún no está pagado. El cliente liquida en su cuenta; después marcas en ruta."
        : `No se marcó en ruta: ${r.error}`;
      showToast(msg, "warning");
      return;
    }
    showToast("En ruta. Pide el Uber/DiDi y entrega.", "success");
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
      colorScheme: "light",
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
        {!pedidoPaid && meta.estado === "cotizado" && "Cargado al checkout del cliente. Falta que pague productos + transporte."}
        {!pedidoPaid && meta.estado !== "cotizado" && meta.estado !== "en_ruta" && "Abre DiDi o Uber, cotiza y pon aquí el costo. Se suma al total que el cliente paga en la tienda."}
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
        <button
          type="button"
          onClick={() => {
            const fee = Number(meta.costo_cotizado);
            const total = Number(pedido?.total);
            if (!Number.isFinite(fee) || fee < 0 || !Number.isFinite(total)) {
              showToast?.("Primero guarda el costo de transporte.", "warning");
              return;
            }
            const partes = desgloseEnvioCheckout(total, fee, cargoServicioPedido(pedido));
            const msg = textoClienteEnvioEnCheckout({
              pedidoId: pedido?.id,
              costo: partes.envio,
              itemsTotal: partes.productos,
              cargo: partes.servicio,
              total: partes.total,
            });
            if (navigator?.clipboard?.writeText) navigator.clipboard.writeText(msg);
            showToast?.("Mensaje copiado. El cliente entra a su cuenta y liquida ahí.", "success");
          }}
          style={{ border: "none", background: "none", color: "#0f766e", fontWeight: 700, cursor: "pointer", padding: 0 }}
        >
          Copiar mensaje
        </button>
      </div>
      {meta.estado !== "en_ruta" && (
        <div style={{ display: "flex", flexWrap: "wrap", gap: 8, alignItems: "center" }}>
          <label style={{ display: "flex", alignItems: "center", gap: 6, color: "#134e4a", fontWeight: 700 }}>
            Costo transporte
            <Inp
              value={costo}
              onChange={(e) => setCosto(e.target.value)}
              placeholder="0.00"
              inputMode="decimal"
              style={{ width: 96, minWidth: 96, padding: "8px 10px", minHeight: 40, ...campoClaro }}
            />
          </label>
          <label style={{ display: "flex", alignItems: "center", gap: 6, color: "#134e4a", fontWeight: 700 }}>
            App
            <select
              className="farmacapital-field-input farmacapital-field-select"
              value={proveedor}
              onChange={(e) => setProveedor(e.target.value)}
              style={{
                ...campoClaro,
                minHeight: 40,
                padding: "8px 10px",
                border: "1px solid #e2e8f0",
                borderRadius: 8,
                fontSize: 16,
                fontFamily: "var(--fc-body)",
              }}
            >
              <option value="didi">DiDi</option>
              <option value="uber">Uber</option>
              <option value="propio">Repartidor propio</option>
            </select>
          </label>
          <Btn sm col="#0f766e" dis={busy || pedidoPaid} onClick={enviarCotizacion}>
            Guardar y avisar al cliente
          </Btn>
          <Btn sm ol col="#0f766e" dis={busy} onClick={marcarRuta}>Marcar en ruta</Btn>
        </div>
      )}
    </div>
  );
}
