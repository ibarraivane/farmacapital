import { useCallback, useEffect, useState } from "react";
import { MessageCircle, RefreshCw } from "lucide-react";
import { C_LIGHT } from "../constants";
import { supabase } from "../supabase";
import { showToast } from "../ui";
import { estadoReserva, horasRestantesReserva } from "../lib/bajoPedido";
import { normalizarTelefonoPedido } from "../lib/solicitudTienda";

const C = C_LIGHT;
const RESERVA_API = "/api/payments/mp/point";

const ETIQUETA = {
  reservado: { txt: "Reservado · conseguir", bg: C.blueDim, color: C.blue },
  vencido: { txt: "Reserva vencida", bg: C.redDim, color: C.red },
  cobrado: { txt: "Cobrado · surtir", bg: C.greenDim, color: C.greenDark },
  cancelado: { txt: "Cancelado sin cargo", bg: C.cardDark, color: C.textMid },
  sin_reserva: { txt: "Sin reserva", bg: C.amberDim, color: C.amber },
};

function tokenEmpleado() {
  try {
    return sessionStorage.getItem("farmacapital_session_token") || "";
  } catch {
    return "";
  }
}

function pesos(n) {
  return `$${Number(n || 0).toLocaleString("es-MX", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
}

function waCliente(p, texto) {
  const tel = normalizarTelefonoPedido(p?.clientes?.telefono || p?.guest_telefono || "");
  if (tel.length !== 10) return null;
  return `https://wa.me/52${tel}?text=${encodeURIComponent(texto)}`;
}

/**
 * Encargos bajo pedido pagados con RESERVA en tarjeta.
 * Flujo: se pide al mayorista → llega (Recibir) → «Cobrar reserva» → pasa a pedidos por surtir.
 * Si no se consigue: «Cancelar reserva» (el banco libera el monto, sin comisión).
 */
export default function EncargosBajoPedidoPanel() {
  const [rows, setRows] = useState([]);
  const [loading, setLoading] = useState(true);
  const [busy, setBusy] = useState(null);

  const cargar = useCallback(async () => {
    const tok = tokenEmpleado();
    if (!tok) { setRows([]); setLoading(false); return; }
    setLoading(true);
    const { data, error } = await supabase.rpc("empleado_listar_encargos_bajo_pedido", { p_session_token: tok, p_limit: 100 });
    if (error) {
      showToast("No se pudieron cargar los encargos", "error");
      setRows([]);
    } else {
      setRows(Array.isArray(data) ? data : []);
    }
    setLoading(false);
  }, []);

  useEffect(() => { cargar(); }, [cargar]);

  const accion = async (p, tipo) => {
    const nombre = p?.clientes?.nombre || p?.guest_nombre || "cliente";
    const pregunta = tipo === "cobrar"
      ? `¿Ya tienes TODO el encargo #${p.id} de ${nombre}? Se cobrarán ${pesos(p.total)} a su tarjeta.`
      : `¿Cancelar la reserva del encargo #${p.id}? Se libera ${pesos(p.total)} en la tarjeta de ${nombre} y el pedido queda cancelado.`;
    if (!window.confirm(pregunta)) return;
    let motivo = "no_se_consiguio";
    if (tipo === "cancelar") {
      const m = window.prompt("Motivo (se guarda en el pedido):", "No lo surtió el mayorista");
      if (m === null) return;
      motivo = m.trim() || motivo;
    }
    setBusy(p.id);
    try {
      const resp = await fetch(`${RESERVA_API}?action=${tipo === "cobrar" ? "reserva-cobrar" : "reserva-cancelar"}`, {
        method: "POST",
        headers: { "Content-Type": "application/json", "x-session-token": tokenEmpleado() },
        body: JSON.stringify({ pedidoId: p.id, motivo }),
      });
      const data = await resp.json().catch(() => ({}));
      if (resp.ok && data?.ok) {
        showToast(tipo === "cobrar" ? `Cobrado ${pesos(p.total)}. Ya aparece en pedidos por surtir.` : "Reserva cancelada sin cargo.", "success");
      } else if (data?.error === "reserva_vencida") {
        showToast("La reserva ya venció en Mercado Pago. Pídele al cliente que vuelva a encargar.", "warning");
      } else {
        showToast(`No se pudo ${tipo}: ${data?.error || resp.status}`, "error");
      }
    } catch {
      showToast("Sin conexión con el servidor", "error");
    }
    setBusy(null);
    cargar();
  };

  const abiertos = rows.filter((p) => ["reservado", "vencido"].includes(estadoReserva(p)));
  const recientes = rows.filter((p) => !["reservado", "vencido"].includes(estadoReserva(p)));

  const tarjeta = (p) => {
    const est = estadoReserva(p);
    const e = ETIQUETA[est] || ETIQUETA.sin_reserva;
    const horas = horasRestantesReserva(p);
    const nombre = p?.clientes?.nombre || p?.guest_nombre || "Cliente";
    const items = Array.isArray(p.pedido_items) ? p.pedido_items : [];
    const faltan = items.filter((i) => Number(i?.productos?.stock || 0) < Number(i?.cantidad || 0));
    const linkLlego = waCliente(p, `Hola ${nombre}, soy FarmaCapital. Ya tenemos tu encargo #${p.id}. ${p.tipo_entrega === "envio" ? "Te avisamos cuando salga el mensajero." : "Puedes pasar por él."}`);
    const linkNo = waCliente(p, `Hola ${nombre}, soy FarmaCapital. No pudimos conseguir tu encargo #${p.id}; cancelamos la reserva y tu banco libera ${pesos(p.total)} sin cargo. Disculpa.`);
    return (
      <article key={p.id} style={{ background: C.card, border: `1px solid ${C.border}`, borderRadius: 12, padding: "12px 14px" }}>
        <div style={{ display: "flex", justifyContent: "space-between", gap: 10, flexWrap: "wrap" }}>
          <div style={{ minWidth: 200, flex: 1 }}>
            <div style={{ fontWeight: 800, fontSize: 15, color: C.text }}>
              Encargo #{p.id} · {pesos(p.total)}
            </div>
            <div style={{ display: "flex", gap: 6, flexWrap: "wrap", margin: "6px 0" }}>
              <span style={{ padding: "2px 8px", borderRadius: 999, background: e.bg, color: e.color, fontSize: 11, fontWeight: 700 }}>{e.txt}</span>
              {est === "reservado" && horas != null ? (
                <span style={{ padding: "2px 8px", borderRadius: 999, background: horas < 24 ? C.redDim : C.cardDark, color: horas < 24 ? C.red : C.textMid, fontSize: 11, fontWeight: 700 }}>
                  Vence en {horas} h
                </span>
              ) : null}
              <span style={{ padding: "2px 8px", borderRadius: 999, background: C.cardDark, color: C.textMid, fontSize: 11, fontWeight: 700 }}>
                {p.tipo_entrega === "envio" ? "Envío" : "Pick-up"}
              </span>
            </div>
            <div style={{ fontSize: 12, color: C.text }}>
              {nombre}{p?.clientes?.telefono || p?.guest_telefono ? ` · ${p?.clientes?.telefono || p?.guest_telefono}` : ""}
            </div>
            <ul style={{ margin: "6px 0 0", paddingLeft: 18, fontSize: 12, color: C.text }}>
              {items.map((i, idx) => (
                <li key={idx}>
                  {i.cantidad} × {i?.productos?.nombre || "Producto"}
                  {i?.productos?.codigo_barras ? <span style={{ color: C.textDim }}> · {i.productos.codigo_barras}</span> : null}
                  <span style={{ color: Number(i?.productos?.stock || 0) >= Number(i.cantidad || 0) ? C.greenDark : C.textDim }}>
                    {" "}· en tienda: {Number(i?.productos?.stock || 0)}
                  </span>
                </li>
              ))}
            </ul>
          </div>
          {est === "reservado" || est === "vencido" ? (
            <div style={{ display: "flex", flexDirection: "column", gap: 6, minWidth: 170 }}>
              <button
                type="button"
                disabled={busy === p.id || est === "vencido"}
                onClick={() => accion(p, "cobrar")}
                title={faltan.length ? "Aún no hay existencia de todo; revisa que ya llegó por Recibir" : ""}
                style={{ padding: "9px 12px", borderRadius: 8, border: 0, background: est === "vencido" ? C.border : C.green, color: "#fff", fontWeight: 800, fontSize: 12, cursor: busy === p.id || est === "vencido" ? "not-allowed" : "pointer" }}
              >
                {busy === p.id ? "…" : faltan.length ? "Cobrar (¿ya llegó?)" : "Cobrar reserva"}
              </button>
              <button
                type="button"
                disabled={busy === p.id}
                onClick={() => accion(p, "cancelar")}
                style={{ padding: "9px 12px", borderRadius: 8, border: `1px solid ${C.red}55`, background: C.card, color: C.red, fontWeight: 700, fontSize: 12, cursor: busy === p.id ? "not-allowed" : "pointer" }}
              >
                Cancelar reserva
              </button>
              {linkLlego && est === "reservado" && !faltan.length ? (
                <a href={linkLlego} target="_blank" rel="noopener noreferrer" style={{ display: "inline-flex", alignItems: "center", gap: 6, color: "#16a34a", fontWeight: 700, fontSize: 12 }}>
                  <MessageCircle size={14} /> Avisar que llegó
                </a>
              ) : null}
            </div>
          ) : est === "cancelado" && linkNo ? (
            <a href={linkNo} target="_blank" rel="noopener noreferrer" style={{ display: "inline-flex", alignItems: "center", gap: 6, color: C.textMid, fontWeight: 700, fontSize: 12, alignSelf: "flex-start" }}>
              <MessageCircle size={14} /> Avisar que no se consiguió
            </a>
          ) : null}
        </div>
      </article>
    );
  };

  return (
    <div>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", gap: 10, marginBottom: 10, flexWrap: "wrap" }}>
        <div style={{ fontSize: 12, color: C.textMid, lineHeight: 1.5, maxWidth: 620 }}>
          Encargos de la tienda web con el pago <strong>apartado</strong> en tarjeta. Pídelos al mayorista; cuando lleguen por
          Recibir, toca <strong>Cobrar reserva</strong> y el pedido pasa a «por surtir». Mercado Pago sostiene la reserva 5 días.
        </div>
        <button type="button" onClick={cargar} style={{ display: "inline-flex", alignItems: "center", gap: 6, padding: "7px 12px", borderRadius: 8, border: `1px solid ${C.border}`, background: C.card, color: C.textMid, fontWeight: 700, fontSize: 12, cursor: "pointer" }}>
          <RefreshCw size={14} /> Actualizar
        </button>
      </div>
      {loading ? (
        <div style={{ color: C.textMid, fontSize: 13, padding: 12 }}>Cargando…</div>
      ) : (
        <>
          {abiertos.length === 0 ? (
            <div style={{ color: C.textMid, fontSize: 13, padding: "14px 0" }}>No hay encargos esperando.</div>
          ) : (
            <div style={{ display: "flex", flexDirection: "column", gap: 10, marginBottom: 16 }}>{abiertos.map(tarjeta)}</div>
          )}
          {recientes.length > 0 && (
            <>
              <div style={{ fontWeight: 800, fontSize: 12, color: C.textMid, margin: "8px 0" }}>Últimos 7 días</div>
              <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>{recientes.map(tarjeta)}</div>
            </>
          )}
        </>
      )}
    </div>
  );
}
