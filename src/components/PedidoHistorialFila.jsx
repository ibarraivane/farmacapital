import { useState } from "react";
import { Box, Tag, Btn } from "../ui";
import { C_LIGHT, BRAND } from "../constants";
import { $ } from "../utils";
import { labelTipoEntregaPedido } from "../utils/orderChannels";
import { esPedidoPickupPendienteCobro, etiquetaPagoPedidoOnline } from "../utils/pedidosTiendaWeb";
import { formatFolioOnline } from "../utils/orderReceiptWhatsApp";
import CronometroPedidoOnline from "./CronometroPedidoOnline";
import FilaPedidoUnaLinea, { nombreQuienPide } from "./FilaPedidoUnaLinea";

export default function PedidoHistorialFila({ pedido: p, guardando, onCobrarBbva, onMarcarRuta }) {
  const C = C_LIGHT;
  const [abierto, setAbierto] = useState(false);
  const nombre = nombreQuienPide(p);
  const ep = etiquetaPagoPedidoOnline(p, { accent: C.green, amber: C.amber, blue: C.blue, muted: C.textDim });
  const listo = p.delivery_status === "ready_for_pickup" || p.estado !== "completado";

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
          <div style={{ display: "flex", gap: 6, alignItems: "center", flexWrap: "wrap" }}>
            <Tag col={p.tipo_entrega === "envio" ? C.teal : C.green} sm>{labelTipoEntregaPedido(p.tipo_entrega)}</Tag>
            <Tag col={listo ? BRAND.accent : C.green} sm>
              {p.delivery_status === "ready_for_pickup" ? "Listo" : p.estado === "completado" ? "Entregado" : "Listo"}
            </Tag>
            <Tag col={ep.col} sm>{ep.label}</Tag>
            <CronometroPedidoOnline pedido={p} />
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
