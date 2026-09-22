import { useState } from "react";
import { Box, Tag, Btn } from "../ui";
import { C_LIGHT, BRAND } from "../constants";
import { $ } from "../utils";
import { labelTipoEntregaPedido } from "../utils/orderChannels";
import { esPedidoPickupPendienteCobro, etiquetaPagoPedidoOnline } from "../utils/pedidosTiendaWeb";
import { formatFolioOnline } from "../utils/orderReceiptWhatsApp";
import CronometroPedidoOnline from "./CronometroPedidoOnline";
import FilaPedidoUnaLinea, { nombreQuienPide } from "./FilaPedidoUnaLinea";
import { IconoAnaquel } from "./pos/PosIconos";

function ubicacionPedidoItem(item) {
  const raw = item?.productos?.ubicacion_texto;
  return String(raw || "").trim() || "Sin ubicación";
}

export default function PedidoHistorialFila({ pedido: p, guardando, onCobrarBbva, onMarcarRuta }) {
  const C = C_LIGHT;
  const [abierto, setAbierto] = useState(false);
  const nombre = nombreQuienPide(p);
  const ep = etiquetaPagoPedidoOnline(p, { accent: C.green, amber: C.amber, blue: C.blue, muted: C.textDim });
  const listo = p.delivery_status === "ready_for_pickup" || p.estado !== "completado";
  const items = Array.isArray(p.pedido_items) ? p.pedido_items : [];

  return (
    <Box style={{ padding: abierto ? 12 : "8px 12px", marginBottom: 8, minWidth: 0, opacity: 0.95 }}>
      <FilaPedidoUnaLinea
        abierto={abierto}
        onToggle={() => setAbierto((v) => !v)}
        nombre={nombre}
        pedidoId={p.id}
        total={$(p.total)}
      />
      {abierto && (
        <div style={{ marginTop: 10 }}>
          <div style={{ color: C.textMid, fontSize: 12, marginBottom: 6 }}>
            {formatFolioOnline(p.id)} · {new Date(p.created_at).toLocaleString("es-MX")}
          </div>
          {p.direccion ? (
            <div style={{ color: C.textDim, fontSize: 11, marginBottom: 8, lineHeight: 1.35 }}>{p.direccion}</div>
          ) : null}
          <div style={{ display: "flex", gap: 6, alignItems: "center", flexWrap: "wrap", marginBottom: 10 }}>
            <Tag col={p.tipo_entrega === "envio" ? C.teal : C.green} sm>{labelTipoEntregaPedido(p.tipo_entrega)}</Tag>
            <Tag col={listo ? BRAND.accent : C.green} sm>
              {p.delivery_status === "ready_for_pickup" ? "Listo" : p.estado === "completado" ? "Entregado" : "Listo"}
            </Tag>
            <Tag col={ep.col} sm>{ep.label}</Tag>
            <CronometroPedidoOnline pedido={p} />
          </div>
          <div style={{ background: C.bg, borderRadius: 8, padding: "10px 14px", marginBottom: 10 }}>
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
          <div style={{ display: "flex", gap: 6, alignItems: "center", flexWrap: "wrap" }}>
            {esPedidoPickupPendienteCobro(p) && p.estado === "listo" && (
              <Btn sm col="#1a237e" dis={guardando} onClick={() => onCobrarBbva?.(p)}>🏦 Cobrar BBVA</Btn>
            )}
            {p.tipo_entrega === "envio" && !p.delivery_tracking_url && (
              <Btn sm col={C.teal} dis={guardando} onClick={() => onMarcarRuta?.(p)}>Marcar en ruta</Btn>
            )}
            {p.delivery_tracking_url && (
              <a href={p.delivery_tracking_url} target="_blank" rel="noreferrer" style={{ fontSize: 11, fontWeight: 700, color: C.blue }}>Tracking</a>
            )}
          </div>
        </div>
      )}
    </Box>
  );
}
