import { useState } from "react";
import { Box, Tag, Btn } from "../ui";
import { C_LIGHT, BRAND } from "../constants";
import { $ } from "../utils";
import {
  esPedidoPickupPendienteCobro,
  etiquetaPagoPedidoOnline,
} from "../utils/pedidosTiendaWeb";
import { formatFolioOnline } from "../utils/orderReceiptWhatsApp";
import CronometroPedidoOnline from "./CronometroPedidoOnline";
import { IconoAnaquel } from "./pos/PosIconos";

function ubicacionPedidoItem(item) {
  return String(item?.productos?.ubicacion_texto || "").trim() || "Sin ubicación";
}

export function etiquetaEstadoSurtidoHist(p) {
  if (p?.delivery_status === "ready_for_pickup") return "Listo";
  if (p?.estado === "completado") return "Entregado";
  return "Listo";
}

export default function PedidoOnlineHistRow({
  pedido: p,
  guardando,
  onCobrarBbva,
  onMarcarRuta,
}) {
  const C = C_LIGHT;
  const ep = etiquetaPagoPedidoOnline(p, {
    accent: C.green,
    amber: C.amber,
    blue: C.blue,
    muted: C.textDim,
  });
  const estadoLbl = etiquetaEstadoSurtidoHist(p);
  const estadoCol = p.delivery_status === "ready_for_pickup" || p.estado !== "completado"
    ? BRAND.accent
    : C.green;
  const mostrarBbva = esPedidoPickupPendienteCobro(p) && p.estado === "listo";
  const mostrarRuta = p.tipo_entrega === "envio"
    && p.delivery_status !== "in_route"
    && !p.delivery_tracking_url
    && p.estado !== "completado";
  const [abierto, setAbierto] = useState(false);
  const items = Array.isArray(p.pedido_items) ? p.pedido_items : [];

  return (
    <Box className="farmacapital-pedido-hist-card" style={{ padding: 12, marginBottom: 10, minWidth: 0, opacity: 0.95 }}>
      <div className="farmacapital-pedido-hist-row" data-testid={`pedido-hist-row-${p.id}`}>
        <div className="farmacapital-pedido-hist-row__id">
          <div className="farmacapital-pedido-hist-row__folio">
            <button
              type="button"
              aria-expanded={abierto}
              onClick={() => setAbierto((v) => !v)}
              style={{
                background: "none",
                border: "none",
                padding: 0,
                cursor: "pointer",
                color: C.text,
                fontWeight: 800,
                fontSize: 13,
                textAlign: "left",
                colorScheme: "light",
              }}
            >
              {abierto ? "▾" : "▸"} Pedido #{p.id} · {formatFolioOnline(p.id)}
            </button>
          </div>
          <div className="farmacapital-pedido-hist-row__cliente">
            {p.clientes?.nombre || p.guest_nombre || "—"}
            <span className="farmacapital-pedido-hist-row__fecha">
              {" · "}
              {p.created_at ? new Date(p.created_at).toLocaleString("es-MX") : "—"}
            </span>
          </div>
        </div>
        <div className="farmacapital-pedido-hist-row__estado">
          <Tag col={estadoCol} sm>{estadoLbl}</Tag>
        </div>
        <div className="farmacapital-pedido-hist-row__pago">
          <Tag col={ep.col} sm>{ep.label}</Tag>
        </div>
        <div className="farmacapital-pedido-hist-row__tiempo">
          <CronometroPedidoOnline pedido={p} />
        </div>
        <div className="farmacapital-pedido-hist-row__precio">{$(p.total)}</div>
        <div className="farmacapital-pedido-hist-row__accion">
          {mostrarBbva ? (
            <Btn sm col="#1a237e" dis={guardando} onClick={() => onCobrarBbva?.(p)}>
              🏦 Cobrar BBVA
            </Btn>
          ) : null}
          {mostrarRuta ? (
            <Btn sm col={C.teal} dis={guardando} onClick={() => onMarcarRuta?.(p)}>
              Marcar en ruta
            </Btn>
          ) : null}
          {p.delivery_tracking_url ? (
            <a
              href={p.delivery_tracking_url}
              target="_blank"
              rel="noreferrer"
              className="farmacapital-pedido-hist-row__tracking"
            >
              Tracking
            </a>
          ) : null}
        </div>
      </div>
      {abierto ? (
        <div style={{ marginTop: 10 }} data-testid={`pedido-hist-items-${p.id}`}>
          {p.direccion ? (
            <div style={{ color: C.textDim, fontSize: 11, marginBottom: 8, lineHeight: 1.35 }}>{p.direccion}</div>
          ) : null}
          <div style={{ background: C.bg, borderRadius: 8, padding: "10px 14px" }}>
            <div style={{ color: C.textDim, fontSize: 10, letterSpacing: 1, textTransform: "uppercase", marginBottom: 6 }}>Productos</div>
            {items.length === 0 ? (
              <div style={{ color: C.textDim, fontSize: 12 }}>Sin detalle de productos</div>
            ) : items.map((item, i) => (
              <div key={i} style={{ display: "flex", justifyContent: "space-between", gap: 10, marginBottom: 6 }}>
                <div style={{ minWidth: 0 }}>
                  <div style={{ color: C.text, fontSize: 12 }}>{item.productos?.nombre || item.nombre || "Producto"} ×{item.cantidad}</div>
                  <div style={{ color: ubicacionPedidoItem(item) === "Sin ubicación" ? C.textDim : C.blue, fontSize: 11, fontWeight: 700, display: "flex", alignItems: "center", gap: 5 }}>
                    <IconoAnaquel size={13} />
                    {ubicacionPedidoItem(item)}
                  </div>
                </div>
                <span style={{ color: C.blue, fontSize: 12, fontWeight: 700, flexShrink: 0 }}>
                  {$((Number(item.precio_unitario) || 0) * (Number(item.cantidad) || 0))}
                </span>
              </div>
            ))}
          </div>
        </div>
      ) : null}
    </Box>
  );
}
