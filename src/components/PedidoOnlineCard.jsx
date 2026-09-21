import { useRef, useState } from "react";
import { Box, Tag, Btn } from "../ui";
import { C_LIGHT, BRAND } from "../constants";
import { $ } from "../utils";
import { labelTipoEntregaPedido } from "../utils/orderChannels";
import {
  esPedidoPickupPendienteCobro,
  etiquetaPagoPedidoOnline,
} from "../utils/pedidosTiendaWeb";
import {
  formatFolioOnline,
  buildOnlineOrderReceiptMessage,
  openWhatsAppToCustomer,
  ensurePedidoTicketUrl,
  lineasReciboPedidoOnline,
} from "../utils/orderReceiptWhatsApp";
import {
  desgloseEnvioCheckout,
  feeEnvioEnCheckout,
  textoClienteEnvioEnCheckout,
} from "../lib/envioDomicilio";
import { compartirODescargarPng } from "../utils/reciboImagen";
import TicketVenta from "./tickets/TicketVenta";
import EnvioCotizacionPanel from "./EnvioCotizacionPanel";
import CronometroPedidoOnline from "./CronometroPedidoOnline";
import FilaPedidoUnaLinea, { nombreQuienPide } from "./FilaPedidoUnaLinea";
import { IconoAnaquel } from "./pos/PosIconos";

function ubicacionPedidoItem(item) {
  const raw = item?.productos?.ubicacion_texto;
  return String(raw || "").trim() || "Sin ubicación";
}

export default function PedidoOnlineCard({
  pedido: p,
  isNarrow,
  showToast,
  guardando,
  surtirOnline,
  setPedOn,
  onCobrarBbva,
  onCancelar,
}) {
  const C = C_LIGHT;
  const [abierto, setAbierto] = useState(false);
  const clienteNombre = nombreQuienPide(p);
  const clienteTel = p.clientes?.telefono || p.guest_telefono || "";
  const folioPOS = formatFolioOnline(p.id);
  const ep = etiquetaPagoPedidoOnline(p, { accent: C.green, amber: C.amber, blue: C.blue, muted: C.textDim });
  const ticketRef = useRef(null);
  const [reciboBusy, setReciboBusy] = useState(false);
  const [reciboListo, setReciboListo] = useState(null);
  const pagado = String(p.payment_status || "").toLowerCase() === "approved";

  const enviarWhatsApp = () => {
    if (!clienteTel) {
      showToast("Este pedido no tiene teléfono registrado", "warning");
      return;
    }
    const fee = feeEnvioEnCheckout(p);
    let msg;
    if (fee != null) {
      const partes = desgloseEnvioCheckout(p.total, fee);
      msg = textoClienteEnvioEnCheckout({
        pedidoId: p.id,
        costo: partes.envio,
        itemsTotal: partes.productos,
        total: partes.total,
        origen: window.location.origin,
      });
    } else {
      msg = buildOnlineOrderReceiptMessage({
        pedidoId: p.id,
        items: (p.pedido_items || []).map((i) => ({
          nombre: i.productos?.nombre,
          qty: i.cantidad,
          precio: i.precio_unitario,
        })),
        total: p.total,
        tipoEntrega: p.tipo_entrega,
        metodoPago: p.metodo_pago,
      });
    }
    const tel = String(clienteTel).replace(/\D/g, "").slice(-10);
    if (!openWhatsAppToCustomer(tel, msg)) {
      showToast("No se pudo abrir WhatsApp", "warning");
    }
  };

  const guardarReciboImagen = async () => {
    if (!pagado) return;
    setReciboBusy(true);
    try {
      const ensured = await ensurePedidoTicketUrl(p.id);
      setReciboListo({ ticketUrl: ensured.ok ? ensured.ticketUrl : null });
      await new Promise((resolve) => setTimeout(resolve, 180));
      const el = ticketRef.current;
      const nombre = `recibo-FC-${String(p.id).padStart(4, "0")}.png`;
      const modo = await compartirODescargarPng(el, nombre);
      showToast(
        modo === "shared"
          ? "Elige WhatsApp y se pega la imagen del recibo."
          : "Imagen descargada. Ábrela y mándala en el chat de WhatsApp.",
        "success"
      );
    } catch (e) {
      if (e?.name !== "AbortError") showToast("No se pudo armar la imagen del recibo.", "warning");
    }
    setReciboListo(null);
    setReciboBusy(false);
  };

  return (
    <Box style={{ padding: abierto ? (isNarrow ? 14 : 16) : "8px 12px", marginBottom: 8, minWidth: 0 }}>
      <FilaPedidoUnaLinea
        abierto={abierto}
        onToggle={() => setAbierto((v) => !v)}
        nombre={clienteNombre}
        pedidoId={p.id}
        total={$(p.total)}
      />

      {abierto && (
        <div style={{ marginTop: 12 }}>
          <div style={{ display: "flex", gap: 6, alignItems: "center", flexWrap: "wrap", marginBottom: 8 }}>
            <span style={{ background: BRAND.primary, color: "#fff", fontWeight: 900, fontSize: 11, padding: "2px 8px", borderRadius: 20 }}>{folioPOS}</span>
            <Tag col={p.tipo_entrega === "envio" ? C.teal : C.green} sm>{labelTipoEntregaPedido(p.tipo_entrega)}</Tag>
            {(p.guest_nombre || p.guest_telefono) && <Tag col={C.amber} sm>Invitado</Tag>}
            <Tag col={ep.col} sm>{ep.label}</Tag>
            <CronometroPedidoOnline pedido={p} />
          </div>
          <div style={{ color: C.text, fontSize: 13, fontWeight: 700 }}>{clienteNombre}</div>
          {clienteTel && <div style={{ color: C.textMid, fontSize: 12, marginTop: 2 }}>📱 {clienteTel}</div>}
          {p.tipo_entrega === "envio" && p.direccion && (
            <div style={{ color: C.textDim, fontSize: 11, marginBottom: 6, maxWidth: 480, lineHeight: 1.35, display: "flex", alignItems: "flex-start", gap: 5 }}>
              <span style={{ marginTop: 1 }}><IconoAnaquel size={13} /></span>
              {p.direccion}
            </div>
          )}
          {p.tipo_entrega === "envio" && (
            <EnvioCotizacionPanel
              pedido={p}
              showToast={showToast}
              onUpdated={(patch) => {
                const envio = patch?.envio?.estado ? patch.envio : patch;
                setPedOn((rows) => rows.map((x) => {
                  if (x.id !== p.id) return x;
                  const next = {
                    ...x,
                    logistics_meta: { ...(x.logistics_meta || {}), envio },
                  };
                  if (patch?.total != null) next.total = patch.total;
                  if (patch?.costo_envio != null) next.costo_envio = patch.costo_envio;
                  if (envio?.estado === "cotizado") next.delivery_status = "quoted";
                  return next;
                }));
              }}
            />
          )}
          <div style={{ color: C.textDim, fontSize: 11, marginTop: 8 }}>
            {new Date(p.created_at).toLocaleString("es-MX")}
          </div>
          <div style={{ background: C.bg, borderRadius: 8, padding: "10px 14px", margin: "12px 0" }}>
            <div style={{ color: C.textDim, fontSize: 10, letterSpacing: 1, textTransform: "uppercase", marginBottom: 6 }}>Productos</div>
            {(p.pedido_items || []).map((item, i) => (
              <div key={i} style={{ display: "flex", justifyContent: "space-between", gap: 10, marginBottom: 6 }}>
                <div style={{ minWidth: 0 }}>
                  <div style={{ color: C.text, fontSize: 12 }}>{item.productos?.nombre} ×{item.cantidad}</div>
                  <div style={{ color: ubicacionPedidoItem(item) === "Sin ubicación" ? C.textDim : C.blue, fontSize: 11, fontWeight: 700, display: "flex", alignItems: "center", gap: 5 }}>
                    <IconoAnaquel size={13} />
                    {ubicacionPedidoItem(item)}
                  </div>
                </div>
                <span style={{ color: C.blue, fontSize: 12, fontWeight: 700, flexShrink: 0 }}>{$(item.precio_unitario * item.cantidad)}</span>
              </div>
            ))}
          </div>
          <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
            <Btn onClick={() => surtirOnline(p)} col={C.green} dis={guardando}>✓ Surtir y marcar listo</Btn>
            {esPedidoPickupPendienteCobro(p) && (
              <Btn col="#1a237e" dis={guardando} onClick={() => onCobrarBbva(p)}>
                🏦 Cobrar con terminal BBVA
              </Btn>
            )}
            <button onClick={enviarWhatsApp} style={{ display: "flex", alignItems: "center", gap: 6, padding: "7px 14px", borderRadius: 8, border: "none", background: "#25D366", color: "#fff", fontWeight: 700, fontSize: 12, cursor: "pointer" }}>
              💬 WhatsApp cliente
            </button>
            {pagado && (
              <Btn ol col={C.blue} sm dis={reciboBusy} onClick={guardarReciboImagen}>
                {reciboBusy ? "Armando imagen…" : "Recibo (imagen)"}
              </Btn>
            )}
            <Btn ol col={C.red} sm onClick={() => onCancelar(p)}>Cancelar</Btn>
          </div>
        </div>
      )}
      {reciboListo ? (
        <div style={{ position: "fixed", left: "-120vw", top: 0, width: "80mm", background: "#fff" }} aria-hidden>
          <TicketVenta
            ref={ticketRef}
            venta={{
              id: p.id,
              folio: `FC-${String(p.id).padStart(4, "0")}`,
              total: p.total,
              created_at: p.created_at,
            }}
            productos={lineasReciboPedidoOnline(p)}
            cliente={{ nombre: clienteNombre, telefono: clienteTel }}
            metodoPago={pagado ? "Mercado Pago" : "Pendiente de pago"}
            mostrarPuntos={pagado}
            promoMsg={
              pagado || String(p.tipo_entrega || "").toLowerCase() !== "envio"
                ? null
                : "Incluye el envío. Entra a Mi cuenta y toca Pagar ahora."
            }
            ticketUrl={reciboListo.ticketUrl}
          />
        </div>
      ) : null}
    </Box>
  );
}
