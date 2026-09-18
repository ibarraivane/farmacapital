import { useState } from "react";
import { Box, Tag, Btn } from "../ui";
import { C_LIGHT, BRAND } from "../constants";
import { $ } from "../utils";
import { labelTipoEntregaPedido } from "../utils/orderChannels";
import {
  esPedidoEnvioPorCotizar,
  esPedidoPickupPendienteCobro,
  etiquetaPagoPedidoOnline,
} from "../utils/pedidosTiendaWeb";
import { formatFolioOnline, buildOnlineOrderReceiptMessage, openWhatsAppToCustomer } from "../utils/orderReceiptWhatsApp";
import EnvioCotizacionPanel from "./EnvioCotizacionPanel";
import CronometroPedidoOnline from "./CronometroPedidoOnline";
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
  const needsAction = esPedidoEnvioPorCotizar(p) || esPedidoPickupPendienteCobro(p);
  const [abierto, setAbierto] = useState(needsAction);
  const clienteNombre = p.clientes?.nombre || p.guest_nombre || "—";
  const clienteTel = p.clientes?.telefono || p.guest_telefono || "";
  const folioPOS = formatFolioOnline(p.id);
  const ep = etiquetaPagoPedidoOnline(p, { accent: C.green, amber: C.amber, blue: C.blue, muted: C.textDim });

  const enviarWhatsApp = () => {
    if (!clienteTel) {
      showToast("Este pedido no tiene teléfono registrado", "warning");
      return;
    }
    const msg = buildOnlineOrderReceiptMessage({
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
    if (!openWhatsAppToCustomer(clienteTel, msg)) {
      showToast("No se pudo abrir WhatsApp", "warning");
    }
  };

  return (
    <Box style={{ padding: isNarrow ? 14 : 20, marginBottom: 12, minWidth: 0 }}>
      <button
        type="button"
        onClick={() => setAbierto((v) => !v)}
        style={{
          width: "100%",
          display: "flex",
          justifyContent: "space-between",
          alignItems: "flex-start",
          gap: 10,
          flexWrap: "wrap",
          background: "none",
          border: "none",
          padding: 0,
          cursor: "pointer",
          textAlign: "left",
          colorScheme: "light",
        }}
      >
        <div style={{ minWidth: 0, flex: "1 1 220px" }}>
          <div style={{ display: "flex", alignItems: "center", gap: 8, flexWrap: "wrap" }}>
            <span style={{ color: C.textDim, fontWeight: 800, fontSize: 14 }}>{abierto ? "▾" : "▸"}</span>
            <div style={{ color: C.text, fontWeight: 800, fontSize: 15 }}>Pedido #{p.id}</div>
            <div style={{ background: BRAND.primary, color: "#fff", fontWeight: 900, fontSize: 13, padding: "2px 10px", borderRadius: 20 }}>{folioPOS}</div>
            <Tag col={p.tipo_entrega === "envio" ? C.teal : C.green} sm>{labelTipoEntregaPedido(p.tipo_entrega)}</Tag>
            {(p.guest_nombre || p.guest_telefono) && <Tag col={C.amber} sm>Invitado</Tag>}
          </div>
          <div style={{ color: C.text, fontSize: 13, fontWeight: 700, marginTop: 6 }}>{clienteNombre}</div>
          {clienteTel && <div style={{ color: C.textMid, fontSize: 12, marginTop: 1 }}>📱 {clienteTel}</div>}
        </div>
        <div style={{ textAlign: "right", display: "flex", flexDirection: "column", alignItems: "flex-end", gap: 6 }}>
          <div style={{ color: C.blue, fontWeight: 900, fontSize: 18 }}>{$(p.total)}</div>
          <Tag col={ep.col} sm>{ep.label}</Tag>
          <CronometroPedidoOnline pedido={p} />
        </div>
      </button>

      {!abierto && (
        <div style={{ marginTop: 8, color: C.textMid, fontSize: 12 }}>
          {(p.pedido_items || []).length} producto{(p.pedido_items || []).length === 1 ? "" : "s"}
          {p.tipo_entrega === "envio" && p.direccion ? ` · ${p.direccion}` : ""}
          {" · "}
          <button type="button" onClick={() => setAbierto(true)} style={{ border: "none", background: "none", color: C.blue, fontWeight: 800, cursor: "pointer", padding: 0 }}>
            Ver detalle
          </button>
        </div>
      )}

      {abierto && (
        <div style={{ marginTop: 12 }}>
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
              onUpdated={(envio) => {
                setPedOn((rows) => rows.map((x) => (
                  x.id === p.id
                    ? { ...x, logistics_meta: { ...(x.logistics_meta || {}), envio } }
                    : x
                )));
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
            <Btn ol col={C.red} sm onClick={() => onCancelar(p)}>Cancelar</Btn>
          </div>
        </div>
      )}
    </Box>
  );
}
