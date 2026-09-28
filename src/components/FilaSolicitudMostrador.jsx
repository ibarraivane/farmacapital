import { ChevronRight, Calculator, MessageCircle } from "lucide-react";
import { C_LIGHT } from "../constants";
import { buildSolicitudWhatsAppCliente } from "../lib/solicitudTienda";
import { folioCotizacion } from "../lib/cotizaciones";
import {
  etiquetaEstado,
  etiquetaOrigen,
  etiquetaPago,
  etiquetaTipo,
  etiquetaUrgencia,
  siguientesEstados,
} from "../lib/pedidosMostrador";

const C = C_LIGHT;

const MESES = ["ene", "feb", "mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic"];

function fmtCuando(iso) {
  if (!iso) return "—";
  return new Date(iso).toLocaleString("es-MX", {
    day: "2-digit",
    month: "short",
    hour: "2-digit",
    minute: "2-digit",
  });
}

function fmtDia(iso) {
  if (!iso) return "";
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return "";
  return `${d.getDate()} ${MESES[d.getMonth()]}`;
}

function chip(bg, color, text) {
  return (
    <span
      style={{
        display: "inline-block",
        padding: "2px 8px",
        borderRadius: 999,
        background: bg,
        color,
        fontSize: 11,
        fontWeight: 700,
        whiteSpace: "nowrap",
      }}
    >
      {text}
    </span>
  );
}

function colorEstado(estado) {
  switch (estado) {
    case "pendiente":
      return { bg: C.amberDim, color: C.amber };
    case "pedir":
      return { bg: C.blueDim, color: C.blue };
    case "pedido":
      return { bg: C.purpleDim, color: C.purple };
    case "llego":
      return { bg: C.greenDim, color: C.greenDark };
    default:
      return { bg: C.cardDark, color: C.textMid };
  }
}

function colorUrgencia(u) {
  if (u === "hoy") return { bg: C.redDim, color: C.red };
  if (u === "manana") return { bg: C.amberDim, color: C.amber };
  return { bg: C.cardDark, color: C.textMid };
}

/**
 * Una línea por encargo. El detalle (cliente, nota, estados) sale al tocarla.
 */
export default function FilaSolicitudMostrador({
  solicitud: s,
  abierta,
  onToggle,
  esAdmin,
  cotizacion,
  promoviendo,
  actualizando,
  onCambiarEstado,
  onAbrirCotizacion,
  conDivision,
}) {
  const est = colorEstado(s.estado);
  const urg = colorUrgencia(s.urgencia);
  const next = siguientesEstados(s.estado);
  const nombre = `${s.texto || "Sin nombre"}${s.cantidad > 1 ? ` ×${s.cantidad}` : ""}`;
  const wa = s.cliente_telefono
    ? buildSolicitudWhatsAppCliente({
        telefono: s.cliente_telefono,
        texto: s.texto,
        nombre: s.cliente_nombre,
      })
    : "";
  const detalleId = `encargo-detalle-${s.id}`;

  return (
    <article
      style={{
        borderTop: conDivision ? `1px solid ${C.border}` : "none",
        background: abierta ? "#f8fafc" : C.card,
      }}
    >
      <button
        type="button"
        className="fc-encargo-linea"
        aria-expanded={abierta ? "true" : "false"}
        aria-controls={detalleId}
        aria-label={nombre}
        onClick={onToggle}
      >
        <ChevronRight
          size={16}
          aria-hidden="true"
          style={{
            color: C.textDim,
            display: "block",
            transform: abierta ? "rotate(90deg)" : "none",
          }}
        />
        <span className="fc-encargo-linea__nombre" title={nombre}>
          {nombre}
        </span>
        <span className="fc-encargo-linea__meta">
          {chip(est.bg, est.color, etiquetaEstado(s.estado))}
          {s.urgencia === "hoy" || s.urgencia === "manana"
            ? chip(urg.bg, urg.color, etiquetaUrgencia(s.urgencia))
            : null}
          {s.origen === "tienda" ? chip(C.tealDim, C.teal, "Web") : null}
          {s.pago_tipo && s.pago_tipo !== "nada"
            ? chip(C.greenDim, C.greenDark, etiquetaPago(s.pago_tipo, s.pago_monto))
            : null}
          <span style={{ color: C.textDim, fontSize: 12, fontWeight: 600, whiteSpace: "nowrap" }}>
            {fmtDia(s.created_at)}
          </span>
        </span>
      </button>
      {abierta ? (
        <div id={detalleId} style={{ padding: "2px 14px 12px 40px" }}>
          <div style={{ display: "flex", gap: 6, flexWrap: "wrap", marginBottom: 6 }}>
            {chip(urg.bg, urg.color, etiquetaUrgencia(s.urgencia))}
            {chip(C.cardDark, C.textMid, etiquetaTipo(s.tipo))}
            {s.origen === "tienda"
              ? chip(C.tealDim, C.teal, etiquetaOrigen("tienda"))
              : chip(C.cardDark, C.textMid, etiquetaOrigen(s.origen))}
          </div>
          <div style={{ fontSize: 12, color: C.textMid }}>
            {s.origen === "tienda"
              ? "Llegó de la tienda web"
              : `Vendedor: ${s.anotado_por_nombre || "—"}`}
            {" · "}
            {fmtCuando(s.created_at)}
            {s.producto_nombre ? ` · Catálogo: ${s.producto_nombre}` : ""}
          </div>
          {(s.cliente_nombre || s.cliente_telefono || s.cliente_email) ? (
            <div style={{ fontSize: 12, color: C.text, marginTop: 4 }}>
              Cliente: {s.cliente_nombre || "—"}
              {s.cliente_telefono ? ` · ${s.cliente_telefono}` : ""}
              {s.cliente_email ? ` · ${s.cliente_email}` : ""}
            </div>
          ) : null}
          {s.direccion ? (
            <div style={{ fontSize: 12, color: C.textMid, marginTop: 4 }}>Envío: {s.direccion}</div>
          ) : null}
          {s.notas ? (
            <div style={{ fontSize: 12, color: C.text, marginTop: 4 }}>Nota: {s.notas}</div>
          ) : null}
          <div style={{ display: "flex", flexWrap: "wrap", alignItems: "center", gap: 12, marginTop: 8 }}>
            {wa ? (
              <a
                href={wa}
                target="_blank"
                rel="noopener noreferrer"
                style={{
                  display: "inline-flex",
                  alignItems: "center",
                  gap: 6,
                  color: "#16a34a",
                  fontWeight: 700,
                  fontSize: 12,
                  textDecoration: "none",
                }}
              >
                <MessageCircle size={14} /> Pasar costo por WhatsApp
              </a>
            ) : null}
            {esAdmin ? (
              <button
                type="button"
                disabled={promoviendo}
                onClick={onAbrirCotizacion}
                style={{
                  display: "inline-flex",
                  alignItems: "center",
                  gap: 6,
                  padding: 0,
                  border: "none",
                  background: "transparent",
                  color: C.blue,
                  fontWeight: 700,
                  fontSize: 12,
                  cursor: promoviendo ? "wait" : "pointer",
                }}
              >
                <Calculator size={14} />
                {cotizacion
                  ? `Abrir ${cotizacion.folio || folioCotizacion(cotizacion.id)}`
                  : "Abrir cotización"}
              </button>
            ) : null}
          </div>
          <div style={{ display: "flex", flexWrap: "wrap", gap: 6, marginTop: 10 }}>
            {next.map((e) => (
              <button
                key={e}
                type="button"
                disabled={actualizando}
                onClick={() => onCambiarEstado(e)}
                style={{
                  padding: "6px 10px",
                  borderRadius: 7,
                  border: `1px solid ${C.border}`,
                  background: C.card,
                  color: C.text,
                  fontWeight: 700,
                  fontSize: 11,
                  cursor: "pointer",
                  whiteSpace: "nowrap",
                  opacity: actualizando ? 0.6 : 1,
                }}
              >
                → {etiquetaEstado(e)}
              </button>
            ))}
          </div>
        </div>
      ) : null}
    </article>
  );
}
