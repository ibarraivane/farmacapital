import { Box, Tag, Btn } from "../ui";
import { C_LIGHT, BRAND } from "../constants";
import { $ } from "../utils";
import {
  esPedidoPickupPendienteCobro,
  etiquetaPagoPedidoOnline,
} from "../utils/pedidosTiendaWeb";
import { formatFolioOnline } from "../utils/orderReceiptWhatsApp";
import CronometroPedidoOnline from "./CronometroPedidoOnline";

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
    && !p.delivery_tracking_url
    && p.estado !== "completado";

  return (
    <Box className="farmacapital-pedido-hist-card" style={{ padding: 12, marginBottom: 10, minWidth: 0, opacity: 0.95 }}>
      <div className="farmacapital-pedido-hist-row" data-testid={`pedido-hist-row-${p.id}`}>
        <div className="farmacapital-pedido-hist-row__id">
          <div className="farmacapital-pedido-hist-row__folio">
            Pedido #{p.id} · {formatFolioOnline(p.id)}
          </div>
          <div className="farmacapital-pedido-hist-row__cliente">
            {p.clientes?.nombre || "—"}
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
    </Box>
  );
}
