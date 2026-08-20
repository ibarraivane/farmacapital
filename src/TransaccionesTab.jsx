import { useState, useEffect, useCallback } from "react";
import { supabase } from "./supabase";
import { C_LIGHT, BRAND } from "./constants";
import { showToast, SkeletonTable, Paginador } from "./ui";
import TicketVenta from "./components/tickets/TicketVenta";
import { printTicket } from "./utils/printTicket";
import { labelTipoEntregaPedido, labelTipoPedido, pedidoCoincideFiltroTipo, pedidoEsTipoOnline, pedidoEsTipoServicio } from "./utils/orderChannels";
import { configRowsToMap, mergeFarmaciaConfig } from "./constants/farmaciaFiscal";
import { productMatchesSearchQuery } from "./utils/fuzzySearch";
import { parseRpcJsonArray } from "./utils/rpcJson";
import { notifyPosTicket, notifyOnlineOrderReceipt, formatFolioPOS, formatFolioOnline, formatWhatsAppSendError, formatWhatsAppSuccessMessage } from "./utils/orderReceiptWhatsApp";
import { usePedidoTicketUrl } from "./hooks/usePedidoTicketUrl";
import { telefonoMxValido } from "./utils";

function esPagoServicio(p) {
  return p?.origen === "pago_servicio" || pedidoEsTipoServicio(p?.tipo);
}

function mapPagoServicioAFila(ps) {
  const proveedor = ps.proveedor || "Servicio";
  return {
    origen: "pago_servicio",
    id: `srv-${ps.id}`,
    servicioId: ps.id,
    folio: ps.folio,
    total: ps.total_cobrado,
    metodo_pago: ps.metodo_pago,
    tipo: "servicio",
    estado: "completado",
    created_at: ps.created_at,
    notas: ps.notas || null,
    atendido_por: ps.atendido_por ?? null,
    clientes: {
      nombre: proveedor,
      telefono: ps.referencia || "",
    },
    usuarios: { nombre: ps.atendido_por_nombre || "" },
    proveedor,
    categoria: ps.categoria,
    referencia: ps.referencia,
    monto_servicio: ps.monto_servicio,
    comision: ps.comision,
    liquidado_point: ps.liquidado_point,
  };
}

function nombreVendedor(p) {
  if (!p) return "—";
  return p.usuarios?.nombre || p.atendido_por_nombre || "—";
}

async function fetchPagosServicioRango(tok, rango) {
  const { data, error } = await supabase.rpc("empleado_listar_pagos_servicio_rango", {
    p_session_token: tok,
    p_desde: rango?.desde ?? null,
    p_hasta: rango?.hasta ?? null,
    p_limite: 300,
  });
  if (!error) return parseRpcJsonArray(data);
  const dia = await supabase.rpc("empleado_listar_pagos_servicio_dia", {
    p_session_token: tok,
    p_limite: 100,
  });
  if (dia.error) {
    console.warn("[TransaccionesTab] pagos servicio:", error?.message || dia.error.message);
    return [];
  }
  let rows = parseRpcJsonArray(dia.data);
  if (rango?.desde || rango?.hasta) {
    const desdeMs = rango.desde ? new Date(rango.desde).getTime() : null;
    const hastaMs = rango.hasta ? new Date(rango.hasta).getTime() : null;
    rows = rows.filter((r) => {
      const t = new Date(r.created_at).getTime();
      if (desdeMs != null && t < desdeMs) return false;
      if (hastaMs != null && t > hastaMs) return false;
      return true;
    });
  }
  return rows;
}

/** Listado de pedidos con filtros — antes dentro de Admin/Reportes; requiere showConfirm del padre. */
export default function TransaccionesTab({ usuario, showConfirm }) {
  const C = C_LIGHT;
  const [pedidos, setPedidos] = useState([]);
  const [loading, setLoading] = useState(true);
  const [busqueda, setBusqueda] = useState("");
  const [filtroFecha, setFiltroF] = useState("mes");
  const [filtroTipo, setFiltroT] = useState("todos");
  const [filtroEstado, setFiltroE] = useState("todos");
  const [fechaDesde, setFDesde] = useState("");
  const [fechaHasta, setFHasta] = useState("");
  const [modalDetalle, setModalDet] = useState(null);
  const [modalEditar, setModalEdit] = useState(null);
  const [pagina, setPagina] = useState(1);
  const POR_PAGINA = 50;
  const [ticketReprint, setTicketReprint] = useState(null);
  const [farmaciaConfig, setFarmaciaConfig] = useState(() => mergeFarmaciaConfig({}));
  const [loadingReprint, setLoadingReprint] = useState(false);
  const [enviandoWaId, setEnviandoWaId] = useState(null);
  const [waTelDetalle, setWaTelDetalle] = useState("");
  const [enviandoWaDet, setEnviandoWaDet] = useState(false);

  useEffect(() => {
    supabase.from("configuracion").select("clave,valor").then(({ data }) => {
      if (data?.length) setFarmaciaConfig(mergeFarmaciaConfig(configRowsToMap(data)));
    });
  }, []);
  const [detItems, setDetItems] = useState([]);
  const [loadDet, setLoadDet] = useState(false);
  const [editForm, setEditForm] = useState({});
  const [saving, setSaving] = useState(false);
  const [vendedores, setVendedores] = useState([]);

  useEffect(() => {
    if (usuario?.rol !== "admin") return;
    const tok = sessionStorage.getItem("farmacapital_session_token");
    if (!tok) return;
    supabase.rpc("admin_listar_usuarios", { p_session_token: tok }).then(({ data, error }) => {
      if (error) {
        console.warn("[TransaccionesTab] vendedores:", error.message);
        return;
      }
      const rows = Array.isArray(data) ? data : [];
      setVendedores(rows.filter((u) => u.activo !== false));
    });
  }, [usuario?.rol]);
  const { ticketUrl: reprintTicketUrl, loading: reprintTicketUrlLoading } = usePedidoTicketUrl(
    ticketReprint?.venta?.id,
    Boolean(ticketReprint)
  );

  const getRango = () => {
    const h = new Date(), y = h.getFullYear(), m = h.getMonth(), d = h.getDate();
    if (filtroFecha === "hoy") return { desde: new Date(y, m, d, 0, 0, 0).toISOString(), hasta: new Date(y, m, d, 23, 59, 59).toISOString() };
    if (filtroFecha === "semana") return { desde: new Date(Date.now() - 7 * 86400000).toISOString(), hasta: h.toISOString() };
    if (filtroFecha === "mes") return { desde: new Date(y, m, 1).toISOString(), hasta: h.toISOString() };
    if (filtroFecha === "custom" && fechaDesde) return { desde: new Date(fechaDesde).toISOString(), hasta: fechaHasta ? new Date(fechaHasta + "T23:59:59").toISOString() : h.toISOString() };
    return null;
  };

  useEffect(() => { setPagina(1); }, [filtroFecha, filtroTipo, filtroEstado, busqueda]);

  const fetchPedidos = useCallback(async () => {
    setLoading(true);
    const tok = sessionStorage.getItem("farmacapital_session_token");
    const rango = getRango();
    if (!tok) {
      setPedidos([]);
      setLoading(false);
      return;
    }
    const { data, error } = await supabase.rpc("empleado_listar_pedidos_transacciones", {
      p_session_token: tok,
      p_created_desde: rango?.desde ?? null,
      p_created_hasta: rango?.hasta ?? null,
      p_limite: 300,
    });
    if (error) console.warn("[TransaccionesTab]", error.message);
    const ventas = parseRpcJsonArray(data);
    const servicios = (await fetchPagosServicioRango(tok, rango)).map(mapPagoServicioAFila);
    const mezclados = [...ventas, ...servicios].sort(
      (a, b) => new Date(b.created_at || 0) - new Date(a.created_at || 0)
    );
    setPedidos(mezclados);
    setLoading(false);
  }, [filtroFecha, fechaDesde, fechaHasta]);

  useEffect(() => { fetchPedidos(); }, [fetchPedidos]);

  const eliminarPedidoCompleto = async (p) => {
    const tok = sessionStorage.getItem("farmacapital_session_token");
    if (!tok) { showToast("Sesión expirada","error"); return; }
    const { error } = await supabase.rpc("admin_eliminar_pedido", {
      p_session_token: tok, p_pedido_id: p.id,
    });
    if (error) showToast("Error: "+error.message, "error");
  };

  const filtradosTodos = pedidos.filter((p) => {
    const q = busqueda.trim();
    const hayQ = q
      && (
        String(p.id || "").includes(q)
        || String(p.folio || "").toLowerCase().includes(q.toLowerCase())
        || String(p.proveedor || "").toLowerCase().includes(q.toLowerCase())
        || String(p.referencia || "").includes(q)
        || (p.clientes && productMatchesSearchQuery(p.clientes, busqueda, [(x) => x.nombre, (x) => x.telefono]))
      );
    const matchB = !q || hayQ;
    const matchT = pedidoCoincideFiltroTipo(p.tipo, filtroTipo);
    const matchE = filtroEstado === "todos" || p.estado === filtroEstado;
    return matchB && matchT && matchE;
  });
  const filtrados = filtradosTodos.slice((pagina - 1) * POR_PAGINA, pagina * POR_PAGINA);

  const mapItemsBasico = (items) =>
    parseRpcJsonArray(items).map((i) => ({
      nombre: i.productos?.nombre || "Producto",
      qty: i.cantidad,
      precio: i.precio_unitario,
    }));

  const folioPedido = (p) => {
    if (!p) return "—";
    if (esPagoServicio(p) && p.folio) return p.folio;
    if (p.tipo === "online" || String(p.tipo || "").includes("online")) return formatFolioOnline(p.id);
    return formatFolioPOS(p.id);
  };

  const cargarItemsPedido = async (pedidoId) => {
    const tok = sessionStorage.getItem("farmacapital_session_token");
    const { data: items, error } = await supabase.rpc("empleado_listar_pedido_items_basico", {
      p_session_token: tok,
      p_pedido_id: pedidoId,
    });
    if (error) throw new Error(error.message);
    return mapItemsBasico(items);
  };

  const enviarWhatsAppTransaccion = async (p, telefonoOverride, event = "auto") => {
    const tel = String(telefonoOverride || p.clientes?.telefono || "").trim();
    if (!telefonoMxValido(tel)) {
      showToast("Captura un teléfono válido de 10 dígitos.", "warning");
      return false;
    }
    if (p.estado === "cancelado") {
      showToast("No se puede enviar WhatsApp de un pedido cancelado.", "warning");
      return false;
    }
    if (esPagoServicio(p)) {
      showToast("Las recargas no tienen ticket de venta. Están en POS → Servicios.", "info");
      return false;
    }
    try {
      const productos = await cargarItemsPedido(p.id);
      const online = pedidoEsTipoOnline(p.tipo);
      let result;
      if (online) {
        const ev = event === "auto" || event === "pos_ticket" ? "order_created" : event;
        result = await notifyOnlineOrderReceipt({
          pedidoId: p.id,
          telefono: tel,
          event: ev,
          forceWhatsApp: true,
        });
      } else {
        result = await notifyPosTicket({
          pedidoId: p.id,
          telefono: tel,
          total: p.total,
          metodoPago: p.metodo_pago,
          productos,
        });
      }
      if (!result.sent) {
        console.warn("[TransaccionesTab] WhatsApp:", result.reason, result.detail);
        showToast(formatWhatsAppSendError({ reason: result.reason, detail: result.detail, telefono: tel }), "error");
        return false;
      }
      showToast(
        formatWhatsAppSuccessMessage({
          telefono: tel,
          whatsapp: result.whatsapp,
          devHint: result.devHint,
          ticketUrl: result.ticketUrl,
        }),
        "success"
      );
      return true;
    } catch (e) {
      showToast(e.message || "Error al enviar WhatsApp", "error");
      return false;
    }
  };

  const enviarTicketWhatsApp = enviarWhatsAppTransaccion;

  const reimprimir = async (p) => {
    if (esPagoServicio(p)) {
      showToast("Las recargas no tienen ticket de productos. Revísalas en POS → Servicios.", "info");
      return;
    }
    setLoadingReprint(true);
    try {
      const tok = sessionStorage.getItem("farmacapital_session_token");
      const productos = await cargarItemsPedido(p.id);
      let cliente = null;
      if (p.cliente_id) {
        const { data: cli } = await supabase.rpc("admin_obtener_cliente", {
          p_session_token: tok, p_cliente_id: p.cliente_id,
        });
        cliente = cli;
      }
      setTicketReprint({
        venta: { id: p.id, folio: folioPedido(p), total: p.total, created_at: p.created_at, metodo_pago: p.metodo_pago },
        productos,
        cliente,
        metodoPago: p.metodo_pago || "Efectivo",
        pedido: p,
      });
    } catch (e) {
      showToast(e.message || "No se pudo cargar el ticket", "error");
    }
    setLoadingReprint(false);
  };

  const reenviarWhatsApp = async (p) => {
    if (!p.clientes?.telefono) {
      await abrirDetalle(p);
      showToast("Captura el teléfono en el detalle para reenviar.", "info");
      return;
    }
    setEnviandoWaId(p.id);
    await enviarTicketWhatsApp(p);
    setEnviandoWaId(null);
  };

  const abrirDetalle = async (p) => {
    setModalDet(p);
    setWaTelDetalle(p.clientes?.telefono || "");
    setDetItems([]);
    if (esPagoServicio(p)) {
      setLoadDet(false);
      return;
    }
    setLoadDet(true);
    const tok = sessionStorage.getItem("farmacapital_session_token");
    const { data, error } = await supabase.rpc("empleado_listar_pedido_items_detalle_transacciones", {
      p_session_token: tok,
      p_pedido_id: p.id,
    });
    if (error) showToast("No se pudo cargar el detalle: " + error.message, "error");
    setDetItems(parseRpcJsonArray(data));
    setLoadDet(false);
  };

  const enviarWhatsAppDesdeDetalle = async (event = "auto") => {
    if (!modalDetalle) return;
    setEnviandoWaDet(true);
    await enviarWhatsAppTransaccion(modalDetalle, waTelDetalle, event);
    setEnviandoWaDet(false);
  };

  const abrirEditar = (p) => {
    setModalEdit(p);
    const mp = p.metodo_pago === "spei" || p.metodo_pago === "mercadopago" ? "tarjeta" : (p.metodo_pago || "efectivo");
    setEditForm({
      estado: p.estado || "completado",
      metodo_pago: mp,
      notas: p.notas || "",
      referencia: p.referencia || "",
      monto_servicio: p.monto_servicio != null ? String(p.monto_servicio) : "",
      comision: p.comision != null ? String(p.comision) : "",
      atendido_por: p.atendido_por != null ? String(p.atendido_por) : "",
    });
  };

  const guardarPagoServicioAdmin = async (action, extra = {}) => {
    const tok = sessionStorage.getItem("farmacapital_session_token");
    if (!tok) throw new Error("Sesión expirada");
    const resp = await fetch("/api/inventarioProcesarPdf?type=pago-servicio", {
      method: "POST",
      headers: { "Content-Type": "application/json", "x-session-token": tok },
      body: JSON.stringify({ session_token: tok, action, ...extra }),
    });
    const data = await resp.json().catch(() => ({}));
    if (!resp.ok || !data?.ok) {
      throw new Error(data?.error || "No se pudo guardar la recarga");
    }
    return data;
  };

  const guardarEditar = async () => {
    setSaving(true);
    const tok = sessionStorage.getItem("farmacapital_session_token");
    try {
      if (esPagoServicio(modalEditar)) {
        await guardarPagoServicioAdmin("editar", {
          id: modalEditar.servicioId,
          metodo_pago: editForm.metodo_pago,
          notas: editForm.notas || null,
          referencia: editForm.referencia,
          monto_servicio: editForm.monto_servicio,
          comision: editForm.comision,
          atendido_por: editForm.atendido_por ? Number(editForm.atendido_por) : null,
        });
      } else {
        const atendidoPor = editForm.atendido_por ? Number(editForm.atendido_por) : null;
        const { error } = await supabase.rpc("admin_editar_pedido", {
          p_session_token: tok,
          p_pedido_id: modalEditar.id,
          p_estado: editForm.estado,
          p_metodo_pago: editForm.metodo_pago,
          p_notas: editForm.notas || null,
          p_atendido_por: Number.isFinite(atendidoPor) ? atendidoPor : null,
        });
        if (error) throw error;
      }
      setModalEdit(null);
      fetchPedidos();
    } catch (e) {
      showToast("Error: " + (e.message || e), "error");
    }
    setSaving(false);
  };

  const cancelarPed = async (p) => {
    if (!showConfirm) {
      showToast("Diálogo de confirmación no disponible.", "error");
      return;
    }
    showConfirm("Cancelar pedido", `¿Cancelar el pedido #${p.id}? El estado cambiará a cancelado.`, async () => {
      const tok = sessionStorage.getItem("farmacapital_session_token");
      const { error } = await supabase.rpc("admin_cancelar_pedido", {
        p_session_token: tok, p_pedido_id: p.id,
      });
      if (error) showToast("Error: "+error.message, "error");
      fetchPedidos();
      showToast(`Pedido #${p.id} cancelado.`, "info");
    });
  };

  const eliminarPed = async (p) => {
    if (!showConfirm) {
      showToast("Diálogo de confirmación no disponible.", "error");
      return;
    }
    if (esPagoServicio(p)) {
      showConfirm("Eliminar recarga", `¿Eliminar ${p.folio || "esta recarga"}? No se puede deshacer.`, async () => {
        try {
          await guardarPagoServicioAdmin("eliminar", { id: p.servicioId });
          fetchPedidos();
          showToast(`${p.folio} eliminada.`, "info");
        } catch (e) {
          showToast("Error: " + (e.message || e), "error");
        }
      }, true);
      return;
    }
    showConfirm("Eliminar pedido", `¿Eliminar el pedido #${p.id}? Se restaurará el stock y esta acción NO se puede deshacer.`, async () => {
      await eliminarPedidoCompleto(p);
      fetchPedidos();
      showToast(`Pedido #${p.id} eliminado.`, "info");
    }, true);
  };

  const fmtM = (n) => `$${parseFloat(n || 0).toLocaleString("es-MX", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
  const fmtDT = (s) => { if (!s) return "—"; const d = new Date(s); return d.toLocaleDateString("es-MX", { day: "2-digit", month: "short" }) + " " + d.toLocaleTimeString("es-MX", { hour: "2-digit", minute: "2-digit" }); };
  const estCol = (e) => e === "completado" ? C.green : e === "cancelado" ? C.red : C.amber;
  const inpS = { padding: "7px 10px", borderRadius: 7, border: `1px solid ${C.border}`, background: C.card, color: C.text, fontSize: 12, outline: "none" };

  const btnAccionIcono = ({ col, bg, border, title, onClick, disabled, children }) => (
    <button
      type="button"
      title={title}
      onClick={onClick}
      disabled={disabled}
      style={{
        padding: "4px 7px",
        borderRadius: 6,
        border: `1px solid ${border}`,
        background: bg,
        color: col,
        cursor: disabled ? "not-allowed" : "pointer",
        fontSize: 12,
        fontWeight: 700,
        lineHeight: 1.2,
        minWidth: 28,
        opacity: disabled ? 0.55 : 1,
      }}
    >
      {children}
    </button>
  );

  const sumaTotal = filtradosTodos.reduce((a, p) => a + parseFloat(p.total || 0), 0);
  const promedio = filtradosTodos.length ? sumaTotal / filtradosTodos.length : 0;
  const byMetodo = filtradosTodos.reduce((acc, p) => { const k = p.metodo_pago || "otro"; acc[k] = (acc[k] || 0) + parseFloat(p.total || 0); return acc; }, {});

  return (
    <div>
      <div style={{ display: "flex", gap: 8, marginBottom: 14, flexWrap: "wrap", alignItems: "center" }}>
        <input placeholder="🔍 ID o cliente…" value={busqueda} onChange={(e) => setBusqueda(e.target.value)} style={{ ...inpS, maxWidth: 180 }} />
        <select value={filtroFecha} onChange={(e) => setFiltroF(e.target.value)} style={inpS}>
          <option value="hoy">Hoy</option>
          <option value="semana">Esta semana</option>
          <option value="mes">Este mes</option>
          <option value="custom">Rango custom</option>
        </select>
        {filtroFecha === "custom" && <>
          <input type="date" value={fechaDesde} onChange={(e) => setFDesde(e.target.value)} style={inpS} />
          <input type="date" value={fechaHasta} onChange={(e) => setFHasta(e.target.value)} style={inpS} />
        </>}
        <select value={filtroTipo} onChange={(e) => setFiltroT(e.target.value)} style={inpS}>
          <option value="todos">Todos los tipos</option>
          <option value="fisica">Física</option>
          <option value="online">Online</option>
          <option value="consulta">Consulta</option>
          <option value="servicio">Servicio / recarga</option>
        </select>
        <select value={filtroEstado} onChange={(e) => setFiltroE(e.target.value)} style={inpS}>
          <option value="todos">Todos los estados</option>
          <option value="completado">Completado</option>
          <option value="pendiente">Pendiente</option>
          <option value="cancelado">Cancelado</option>
        </select>
        <span style={{ color: C.textMid, fontSize: 11, marginLeft: "auto" }}>{filtradosTodos.length} transacciones</span>
        <button type="button" onClick={fetchPedidos} style={{ padding: "7px 12px", borderRadius: 7, border: `1px solid ${C.border}`, background: "transparent", color: C.textMid, cursor: "pointer", fontSize: 11, fontWeight: 700 }}>🔄 Actualizar</button>
      </div>

      <div style={{ fontSize: 11, color: C.textMid, marginBottom: 12, padding: "8px 12px", background: "#f8fafc", borderRadius: 8, border: `1px solid ${C.border}`, lineHeight: 1.45 }}>
        📱 <strong>WhatsApp (Meta — modo prueba):</strong> usa el 📱 en Acciones.
        El mensaje llega al celular del cliente desde el <strong>número de prueba Meta (+1 555…)</strong>, no desde +52 FarmaCapital.
        El teléfono del cliente debe estar en Meta → API Setup → «Números de prueba».
      </div>

      {loading ? <SkeletonTable rows={5} cols={9} /> : (
        <div style={{ overflowX: "auto", borderRadius: 12, border: `1px solid ${C.border}`, marginBottom: 16 }}>
          <table style={{ width: "100%", borderCollapse: "collapse", fontSize: 12 }}>
            <thead>
              <tr style={{ background: C.cardDark }}>
                {["ID", "Fecha/Hora", "Cliente", "Vendedor", "Total", "Método", "Tipo", "Estado", "Acciones"].map((h) => (
                  <th key={h} style={{ padding: "9px 12px", textAlign: "left", color: C.textMid, fontWeight: 700, borderBottom: `1px solid ${C.border}`, whiteSpace: "nowrap" }}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {filtrados.length === 0 && <tr><td colSpan={9} style={{ textAlign: "center", padding: 32, color: C.textMid }}>Sin transacciones en este período</td></tr>}
              {filtrados.map((p, i) => (
                <tr
                  className="farmacapital-table-row"
                  key={p.id}
                  onClick={() => abrirDetalle(p)}
                  title={esPagoServicio(p) ? "Ver detalle de la recarga" : "Ver detalle de la venta"}
                  style={{
                    background: p.estado === "cancelado" ? "#fff5f5" : i % 2 === 0 ? "transparent" : "#f8fafc",
                    cursor: "pointer",
                  }}
                >
                  <td style={{ padding: "8px 12px", color: C.textMid, borderBottom: `1px solid ${C.border}`, fontFamily: "monospace", fontSize: 11 }}>
                    {esPagoServicio(p) ? p.folio : `#${p.id}`}
                    <div style={{ fontSize: 9, color: C.textDim, marginTop: 2 }}>{esPagoServicio(p) ? "Recarga / servicio" : folioPedido(p)}</div>
                  </td>
                  <td style={{ padding: "8px 12px", color: C.textMid, borderBottom: `1px solid ${C.border}`, whiteSpace: "nowrap" }}>{fmtDT(p.created_at)}</td>
                  <td style={{ padding: "8px 12px", color: C.text, fontWeight: 600, borderBottom: `1px solid ${C.border}` }}>
                    {p.clientes?.nombre || "—"}
                    {p.clientes?.telefono ? <div style={{ fontSize: 10, color: C.textMid, fontWeight: 500, marginTop: 2 }}>{p.clientes.telefono}</div> : null}
                  </td>
                  <td style={{ padding: "8px 12px", color: C.text, fontWeight: 600, borderBottom: `1px solid ${C.border}`, whiteSpace: "nowrap" }}>
                    {nombreVendedor(p) === "—" ? (
                      <span style={{ color: C.textMid, fontWeight: 500 }}>Sin asignar</span>
                    ) : (
                      nombreVendedor(p)
                    )}
                  </td>
                  <td style={{ padding: "8px 12px", color: C.green, fontWeight: 700, borderBottom: `1px solid ${C.border}` }}>{fmtM(p.total)}</td>
                  <td style={{ padding: "8px 12px", color: C.textMid, borderBottom: `1px solid ${C.border}` }}>{p.metodo_pago || "—"}</td>
                  <td style={{ padding: "8px 12px", borderBottom: `1px solid ${C.border}`, verticalAlign: "top" }}>
                    <span style={{ padding: "2px 8px", borderRadius: 20, fontSize: 10, fontWeight: 700,
                      background: p.tipo === "online" ? "#ede9fe" : p.tipo === "consulta" ? "#dcfce7" : pedidoEsTipoServicio(p.tipo) ? "#fef3c7" : "#eff6ff",
                      color: p.tipo === "online" ? C.purple : p.tipo === "consulta" ? C.green : pedidoEsTipoServicio(p.tipo) ? C.amber : C.blue }}>
                      {labelTipoPedido(p.tipo)}
                    </span>
                    {pedidoEsTipoOnline(p.tipo) && p.tipo_entrega && (
                      <div style={{ fontSize: 10, color: C.textMid, marginTop: 4, lineHeight: 1.3, maxWidth: 140 }}>
                        {labelTipoEntregaPedido(p.tipo_entrega)}
                        {p.tipo_entrega === "envio" && p.direccion && (
                          <span title={p.direccion} style={{ display: "block", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{p.direccion}</span>
                        )}
                      </div>
                    )}
                  </td>
                  <td style={{ padding: "8px 12px", borderBottom: `1px solid ${C.border}` }}>
                    <span style={{ padding: "2px 8px", borderRadius: 20, fontSize: 10, fontWeight: 700, background: estCol(p.estado) + "20", color: estCol(p.estado) }}>{p.estado || "—"}</span>
                  </td>
                  <td style={{ padding: "8px 12px", borderBottom: `1px solid ${C.border}`, whiteSpace: "nowrap" }} onClick={(e) => e.stopPropagation()}>
                    <div style={{ display: "inline-flex", alignItems: "center", gap: 4, flexWrap: "wrap" }}>
                      <button type="button" onClick={() => abrirDetalle(p)} title="Ver detalle" style={{ padding: "3px 8px", borderRadius: 5, border: `1px solid ${C.blue}30`, background: "#eff6ff", color: C.blue, cursor: "pointer", fontSize: 10, fontWeight: 700 }}>Detalle</button>
                      {!esPagoServicio(p) && <>
                      {btnAccionIcono({
                        col: "#15803d",
                        bg: "#f0fdf4",
                        border: "#86efac",
                        title: p.estado === "cancelado" ? "Pedido cancelado" : "Reenviar ticket por WhatsApp",
                        onClick: () => reenviarWhatsApp(p),
                        disabled: enviandoWaId === p.id || p.estado === "cancelado",
                        children: enviandoWaId === p.id ? "…" : "📱",
                      })}
                      {btnAccionIcono({
                        col: C.purple,
                        bg: "#ede9fe",
                        border: `${C.purple}30`,
                        title: "Reimprimir ticket",
                        onClick: () => reimprimir(p),
                        disabled: loadingReprint,
                        children: "🖨️",
                      })}
                      </>}
                      {usuario?.rol === "admin" && <>
                        {btnAccionIcono({ col: C.amber, bg: "#fef3c7", border: `${C.amber}30`, title: "Editar", onClick: () => abrirEditar(p), children: "✏️" })}
                        {!esPagoServicio(p) && p.estado !== "cancelado" && btnAccionIcono({ col: C.textMid, bg: "#f1f5f9", border: "#94a3b830", title: "Cancelar pedido", onClick: () => cancelarPed(p), children: "❌" })}
                        {btnAccionIcono({ col: C.red, bg: "#fee2e2", border: `${C.red}30`, title: "Eliminar", onClick: () => eliminarPed(p), children: "🗑️" })}
                      </>}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      <Paginador total={filtradosTodos.length} porPagina={POR_PAGINA} pagina={pagina} setPagina={setPagina} />
      {filtradosTodos.length > 0 && (
        <div style={{ background: C.card, border: `1px solid ${C.border}`, borderRadius: 12, padding: 16, display: "flex", gap: 16, flexWrap: "wrap", alignItems: "center" }}>
          <div><div style={{ color: C.textMid, fontSize: 10, fontWeight: 700 }}>TRANSACCIONES</div><div style={{ color: C.blue, fontWeight: 800, fontSize: 18 }}>{filtradosTodos.length}</div></div>
          <div><div style={{ color: C.textMid, fontSize: 10, fontWeight: 700 }}>TOTAL PERÍODO</div><div style={{ color: C.green, fontWeight: 800, fontSize: 18 }}>{fmtM(sumaTotal)}</div></div>
          <div><div style={{ color: C.textMid, fontSize: 10, fontWeight: 700 }}>PROMEDIO</div><div style={{ color: C.purple, fontWeight: 800, fontSize: 18 }}>{fmtM(promedio)}</div></div>
          <div style={{ flex: "1 1 200px", minWidth: 0 }}>
            <div style={{ color: C.textMid, fontSize: 10, fontWeight: 700, marginBottom: 6 }}>POR MÉTODO</div>
            <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
              {Object.entries(byMetodo).map(([k, v]) => (
                <span key={k} style={{ padding: "2px 10px", borderRadius: 20, fontSize: 11, fontWeight: 700, background: "#eff6ff", color: C.blue }}>{k}: {fmtM(v)}</span>
              ))}
            </div>
          </div>
        </div>
      )}

      {modalDetalle && (
        <div style={{ position: "fixed", inset: 0, background: "rgba(15,23,42,.45)", backdropFilter: "blur(4px)", zIndex: 400, display: "flex", alignItems: "center", justifyContent: "center", padding: "max(12px, env(safe-area-inset-top, 0px)) max(12px, env(safe-area-inset-right, 0px)) max(12px, env(safe-area-inset-bottom, 0px)) max(12px, env(safe-area-inset-left, 0px))", boxSizing: "border-box" }} onClick={(e) => e.target === e.currentTarget && setModalDet(null)}>
          <div style={{ background: C.card, borderRadius: 14, width: "min(600px, 100%)", maxHeight: "min(85dvh, 90vh)", overflowY: "auto", WebkitOverflowScrolling: "touch", padding: "clamp(16px, 4vw, 24px)", boxShadow: "0 20px 60px rgba(0,82,204,.15)", minWidth: 0 }}>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 12 }}>
              <h3 style={{ margin: 0, color: C.text, fontSize: 15, fontWeight: 800 }}>
                👁 Detalle — {esPagoServicio(modalDetalle) ? (modalDetalle.folio || "Servicio") : `Pedido #${modalDetalle.id}`}
              </h3>
              <button type="button" onClick={() => setModalDet(null)} style={{ background: "none", border: "none", color: C.textMid, fontSize: 20, cursor: "pointer" }}>✕</button>
            </div>

            {!esPagoServicio(modalDetalle) && (
            <div style={{ background: "#f0fdf4", border: "2px solid #25D366", borderRadius: 12, padding: 14, marginBottom: 16 }}>
              <div style={{ fontWeight: 800, fontSize: 14, color: "#166534", marginBottom: 10 }}>📱 Reenviar por WhatsApp (Meta API)</div>
              <div style={{ display: "flex", gap: 8, flexWrap: "wrap", alignItems: "center", marginBottom: 10 }}>
                <input
                  type="tel"
                  inputMode="numeric"
                  value={waTelDetalle}
                  onChange={(e) => setWaTelDetalle(e.target.value)}
                  placeholder="Teléfono cliente (10 dígitos)"
                  style={{ flex: "1 1 160px", minWidth: 140, padding: "10px 12px", borderRadius: 8, border: "1px solid #86efac", fontSize: 16 }}
                />
              </div>
              <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
                {pedidoEsTipoOnline(modalDetalle.tipo) ? (
                  <>
                    <button type="button" onClick={() => enviarWhatsAppDesdeDetalle("order_created")} disabled={enviandoWaDet || modalDetalle.estado === "cancelado"} style={{ flex: "1 1 160px", padding: "11px 14px", borderRadius: 8, border: "none", background: "#25D366", color: "#fff", fontWeight: 800, fontSize: 12, cursor: "pointer", opacity: enviandoWaDet ? 0.7 : 1 }}>
                      {enviandoWaDet ? "Enviando…" : "✅ Confirmación pedido"}
                    </button>
                    <button type="button" onClick={() => enviarWhatsAppDesdeDetalle("payment_approved")} disabled={enviandoWaDet || modalDetalle.estado === "cancelado"} style={{ flex: "1 1 160px", padding: "11px 14px", borderRadius: 8, border: "1px solid #25D366", background: "#fff", color: "#15803d", fontWeight: 800, fontSize: 12, cursor: "pointer" }}>
                      💳 Pago aprobado
                    </button>
                  </>
                ) : (
                  <button type="button" onClick={() => enviarWhatsAppDesdeDetalle("pos_ticket")} disabled={enviandoWaDet || modalDetalle.estado === "cancelado"} style={{ flex: "1 1 200px", padding: "11px 14px", borderRadius: 8, border: "none", background: "#25D366", color: "#fff", fontWeight: 800, fontSize: 13, cursor: "pointer", opacity: enviandoWaDet ? 0.7 : 1 }}>
                    {enviandoWaDet ? "Enviando ticket…" : "📱 Reenviar ticket POS"}
                  </button>
                )}
                <button type="button" onClick={() => reimprimir(modalDetalle)} style={{ padding: "11px 14px", borderRadius: 8, border: `1px solid ${C.purple}40`, background: "#ede9fe", color: C.purple, fontWeight: 700, fontSize: 12, cursor: "pointer" }}>
                  🖨️ Imprimir
                </button>
              </div>
            </div>
            )}

            <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(min(100%, 160px), 1fr))", gap: 12, marginBottom: 16, fontSize: 12 }}>
              <div><span style={{ color: C.textMid }}>Folio: </span><strong style={{ color: C.text }}>{folioPedido(modalDetalle)}</strong></div>
              <div><span style={{ color: C.textMid }}>Cliente: </span><strong style={{ color: C.text }}>{modalDetalle.clientes?.nombre || "—"}</strong></div>
              <div><span style={{ color: C.textMid }}>Fecha: </span><strong style={{ color: C.text }}>{fmtDT(modalDetalle.created_at)}</strong></div>
              <div><span style={{ color: C.textMid }}>Total: </span><strong style={{ color: C.green }}>{fmtM(modalDetalle.total)}</strong></div>
              <div><span style={{ color: C.textMid }}>Método: </span><strong style={{ color: C.text }}>{modalDetalle.metodo_pago || "—"}</strong></div>
              <div><span style={{ color: C.textMid }}>Estado: </span><strong style={{ color: estCol(modalDetalle.estado) }}>{modalDetalle.estado}</strong></div>
              <div><span style={{ color: C.textMid }}>Tipo: </span><strong style={{ color: C.text }}>{labelTipoPedido(modalDetalle.tipo)}</strong></div>
              <div><span style={{ color: C.textMid }}>Atendido por: </span><strong style={{ color: C.text }}>{modalDetalle.usuarios?.nombre || "—"}</strong></div>
              {esPagoServicio(modalDetalle) && (
                <>
                  <div><span style={{ color: C.textMid }}>Proveedor: </span><strong style={{ color: C.text }}>{modalDetalle.proveedor || "—"}</strong></div>
                  <div><span style={{ color: C.textMid }}>Referencia: </span><strong style={{ color: C.text }}>{modalDetalle.referencia || "—"}</strong></div>
                  <div><span style={{ color: C.textMid }}>Monto recarga: </span><strong style={{ color: C.text }}>{fmtM(modalDetalle.monto_servicio)}</strong></div>
                  <div><span style={{ color: C.textMid }}>Comisión: </span><strong style={{ color: C.amber }}>{fmtM(modalDetalle.comision)}</strong></div>
                </>
              )}
              {pedidoEsTipoOnline(modalDetalle.tipo) && modalDetalle.tipo_entrega && (
                <div><span style={{ color: C.textMid }}>Entrega: </span><strong style={{ color: C.text }}>{labelTipoEntregaPedido(modalDetalle.tipo_entrega)}</strong></div>
              )}
              {pedidoEsTipoOnline(modalDetalle.tipo) && modalDetalle.tipo_entrega === "envio" && modalDetalle.direccion && (
                <div style={{ gridColumn: "1 / -1" }}><span style={{ color: C.textMid }}>Dirección: </span><strong style={{ color: C.text }}>{modalDetalle.direccion}</strong></div>
              )}
            </div>
            {modalDetalle.notas && <div style={{ background: C.cardDark, borderRadius: 8, padding: "8px 12px", marginBottom: 14, color: C.textMid, fontSize: 12 }}>📝 {modalDetalle.notas}</div>}

            {esPagoServicio(modalDetalle) ? (
              <div style={{ background: C.cardDark, borderRadius: 8, padding: 14, fontSize: 12, color: C.textMid, lineHeight: 1.5 }}>
                Recarga registrada en POS → Servicios. No es una venta de producto, por eso no tenía folio VTA ni aparecía aquí antes.
              </div>
            ) : (
            <>
            <div style={{ fontWeight: 700, color: C.text, fontSize: 13, marginBottom: 10 }}>Productos vendidos:</div>
            {loadDet ? <SkeletonTable rows={3} cols={4} /> : (
              <table style={{ width: "100%", borderCollapse: "collapse", fontSize: 12 }}>
                <thead><tr style={{ background: C.cardDark }}>{["Producto", "SKU", "Cant.", "Precio", "Subtotal"].map((h) => <th key={h} style={{ padding: "7px 10px", textAlign: "left", color: C.textMid, fontWeight: 700, borderBottom: `1px solid ${C.border}` }}>{h}</th>)}</tr></thead>
                <tbody>
                  {detItems.length === 0 && !loadDet && (
                    <tr><td colSpan={5} style={{ padding: 16, textAlign: "center", color: C.textMid }}>Sin productos registrados</td></tr>
                  )}
                  {detItems.map((it, i) => (
                    <tr key={i}>
                      <td style={{ padding: "7px 10px", color: C.text, fontWeight: 600, borderBottom: `1px solid ${C.border}` }}>
                        {it.productos?.nombre || it.nombre || "—"}
                        {it.lotes?.numero_lote && <div style={{ fontSize: 9, color: C.textDim, marginTop: 1 }}>Lote: {it.lotes.numero_lote}{it.lotes.fecha_caducidad ? ` | Cad: ${it.lotes.fecha_caducidad}` : ""}</div>}
                      </td>
                      <td style={{ padding: "7px 10px", color: C.textMid, fontSize: 10, borderBottom: `1px solid ${C.border}`, fontFamily: "monospace" }}>{it.productos?.sku || "—"}</td>
                      <td style={{ padding: "7px 10px", color: C.amber, fontWeight: 700, borderBottom: `1px solid ${C.border}` }}>{it.cantidad}</td>
                      <td style={{ padding: "7px 10px", color: C.textMid, borderBottom: `1px solid ${C.border}` }}>{fmtM(it.precio_unitario || it.precio || 0)}</td>
                      <td style={{ padding: "7px 10px", color: C.green, fontWeight: 700, borderBottom: `1px solid ${C.border}` }}>{fmtM((it.precio_unitario || it.precio || 0) * (it.cantidad || 1))}</td>
                    </tr>
                  ))}
                  <tr><td colSpan={4} style={{ padding: "8px 10px", textAlign: "right", fontWeight: 800, color: C.text }}>TOTAL</td><td style={{ padding: "8px 10px", color: C.green, fontWeight: 900, fontSize: 14 }}>{fmtM(modalDetalle.total)}</td></tr>
                </tbody>
              </table>
            )}
            </>
            )}
          </div>
        </div>
      )}

      {ticketReprint && (
        <div style={{ position: "fixed", inset: 0, background: "rgba(15,23,42,.6)", backdropFilter: "blur(4px)", zIndex: 500, display: "flex", alignItems: "center", justifyContent: "center", padding: "max(12px, env(safe-area-inset-top, 0px)) max(12px, env(safe-area-inset-right, 0px)) max(12px, env(safe-area-inset-bottom, 0px)) max(12px, env(safe-area-inset-left, 0px))", boxSizing: "border-box" }}
          onClick={(e) => e.target === e.currentTarget && setTicketReprint(null)}>
          <div style={{ background: C.card, borderRadius: 16, width: "min(380px, 100%)", maxHeight: "min(90dvh, 92vh)", overflowY: "auto", WebkitOverflowScrolling: "touch", boxShadow: "0 24px 80px rgba(0,82,204,.2)", minWidth: 0 }}>
            <div style={{ padding: "14px 20px", borderBottom: "1px solid #e2e8f0", display: "flex", justifyContent: "space-between", alignItems: "center", background: "linear-gradient(135deg,#7c3aed,#9d6fff)", borderRadius: "16px 16px 0 0" }}>
              <div style={{ color: "#fff", fontWeight: 800, fontSize: 15 }}>🖨️ Reimprimir Ticket #{ticketReprint.venta.id}</div>
              <button type="button" onClick={() => setTicketReprint(null)} style={{ background: "rgba(255,255,255,.2)", border: "none", color: "#fff", width: 28, height: 28, borderRadius: "50%", cursor: "pointer", fontSize: 16 }}>✕</button>
            </div>
            <div style={{ padding: 16, background: "#f8fafc", display: "flex", justifyContent: "center", borderBottom: "1px solid #e2e8f0", maxHeight: "60vh", overflowY: "visible" }}>
              <div style={{ background: C.card, boxShadow: "0 2px 12px rgba(0,0,0,.1)", borderRadius: 4, padding: 4 }}>
                <TicketVenta
                  venta={ticketReprint.venta}
                  productos={ticketReprint.productos}
                  cliente={ticketReprint.cliente}
                  metodoPago={ticketReprint.metodoPago}
                  config={farmaciaConfig}
                  ticketUrl={reprintTicketUrl}
                />
              </div>
            </div>
            <div style={{ padding: 16, display: "flex", gap: 10, flexWrap: "wrap" }}>
              <button type="button" onClick={() => printTicket("farmacapital-ticket")} disabled={reprintTicketUrlLoading} style={{ flex: "2 1 160px", minHeight: 44, padding: "11px", borderRadius: 10, border: "none", background: "linear-gradient(135deg,#7c3aed,#9d6fff)", color: "#fff", fontWeight: 800, fontSize: 14, cursor: "pointer", opacity: reprintTicketUrlLoading ? 0.65 : 1 }}>
                {reprintTicketUrlLoading ? "Preparando QR…" : "🖨️ Imprimir"}
              </button>
              {ticketReprint.pedido && (
                <button
                  type="button"
                  onClick={async () => {
                    setEnviandoWaId(ticketReprint.pedido.id);
                    await enviarTicketWhatsApp(ticketReprint.pedido, ticketReprint.cliente?.telefono);
                    setEnviandoWaId(null);
                  }}
                  disabled={enviandoWaId === ticketReprint.pedido?.id}
                  style={{ flex: "2 1 160px", minHeight: 44, padding: "11px", borderRadius: 10, border: "none", background: "#25D366", color: "#fff", fontWeight: 800, fontSize: 14, cursor: "pointer", opacity: enviandoWaId === ticketReprint.pedido?.id ? 0.7 : 1 }}
                >
                  {enviandoWaId === ticketReprint.pedido?.id ? "Enviando…" : "📱 WhatsApp"}
                </button>
              )}
              <button type="button" onClick={() => setTicketReprint(null)} style={{ flex: "1 1 120px", minHeight: 44, padding: "11px", borderRadius: 10, border: "1px solid #e2e8f0", background: "transparent", color: "#475569", fontWeight: 700, fontSize: 14, cursor: "pointer" }}>
                Cerrar
              </button>
            </div>
          </div>
        </div>
      )}

      {modalEditar && (
        <div style={{ position: "fixed", inset: 0, background: "rgba(15,23,42,.45)", backdropFilter: "blur(4px)", zIndex: 400, display: "flex", alignItems: "center", justifyContent: "center", padding: 20 }} onClick={(e) => e.target === e.currentTarget && setModalEdit(null)}>
          <div style={{ background: C.card, borderRadius: 14, width: "min(440px,95vw)", padding: 24, boxShadow: "0 20px 60px rgba(0,82,204,.15)" }}>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 18 }}>
              <h3 style={{ margin: 0, color: C.text, fontSize: 15, fontWeight: 800 }}>
                ✏️ Editar — {esPagoServicio(modalEditar) ? (modalEditar.folio || "Recarga") : `Pedido #${modalEditar.id}`}
              </h3>
              <button type="button" onClick={() => setModalEdit(null)} style={{ background: "none", border: "none", color: C.textMid, fontSize: 20, cursor: "pointer" }}>✕</button>
            </div>
            {!esPagoServicio(modalEditar) && (
            <div style={{ marginBottom: 12 }}>
              <label style={{ color: C.textMid, fontSize: 10, fontWeight: 700, display: "block", marginBottom: 4 }}>ESTADO</label>
              <select value={editForm.estado} onChange={(e) => setEditForm((f) => ({ ...f, estado: e.target.value }))} style={{ width: "100%", padding: "8px 10px", borderRadius: 7, border: `1px solid ${C.border}`, background: C.card, color: C.text, fontSize: 12, outline: "none" }}>
                <option value="completado">Completado</option>
                <option value="pendiente">Pendiente</option>
                <option value="cancelado">Cancelado</option>
              </select>
            </div>
            )}
            <div style={{ marginBottom: 12 }}>
              <label style={{ color: C.textMid, fontSize: 10, fontWeight: 700, display: "block", marginBottom: 4 }}>VENDEDOR / QUIEN CERRÓ</label>
              <select
                value={editForm.atendido_por || ""}
                onChange={(e) => setEditForm((f) => ({ ...f, atendido_por: e.target.value }))}
                style={{ width: "100%", padding: "8px 10px", borderRadius: 7, border: `1px solid ${C.border}`, background: C.card, color: C.text, fontSize: 12, outline: "none" }}
              >
                <option value="">Sin asignar</option>
                {vendedores.map((v) => (
                  <option key={v.id} value={String(v.id)}>
                    {v.nombre}{v.turno ? ` · ${v.turno}` : ""}
                  </option>
                ))}
              </select>
              <div style={{ fontSize: 10, color: C.textMid, marginTop: 4, lineHeight: 1.35 }}>
                Actualiza Mi Día, comisiones RRHH y ventas por empleado en el dashboard.
                El corte de caja cuadra por turno y horario, no por vendedor individual.
              </div>
            </div>
            {esPagoServicio(modalEditar) && (
              <>
                <div style={{ marginBottom: 12 }}>
                  <label style={{ color: C.textMid, fontSize: 10, fontWeight: 700, display: "block", marginBottom: 4 }}>REFERENCIA / TELÉFONO</label>
                  <input value={editForm.referencia || ""} onChange={(e) => setEditForm((f) => ({ ...f, referencia: e.target.value }))} style={{ width: "100%", padding: "8px 10px", borderRadius: 7, border: `1px solid ${C.border}`, background: C.card, color: C.text, fontSize: 12, outline: "none", boxSizing: "border-box" }} />
                </div>
                <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10, marginBottom: 12 }}>
                  <div>
                    <label style={{ color: C.textMid, fontSize: 10, fontWeight: 700, display: "block", marginBottom: 4 }}>MONTO RECARGA</label>
                    <input value={editForm.monto_servicio || ""} onChange={(e) => setEditForm((f) => ({ ...f, monto_servicio: e.target.value }))} inputMode="decimal" style={{ width: "100%", padding: "8px 10px", borderRadius: 7, border: `1px solid ${C.border}`, background: C.card, color: C.text, fontSize: 12, outline: "none", boxSizing: "border-box" }} />
                  </div>
                  <div>
                    <label style={{ color: C.textMid, fontSize: 10, fontWeight: 700, display: "block", marginBottom: 4 }}>COMISIÓN</label>
                    <input value={editForm.comision || ""} onChange={(e) => setEditForm((f) => ({ ...f, comision: e.target.value }))} inputMode="decimal" style={{ width: "100%", padding: "8px 10px", borderRadius: 7, border: `1px solid ${C.border}`, background: C.card, color: C.text, fontSize: 12, outline: "none", boxSizing: "border-box" }} />
                  </div>
                </div>
              </>
            )}
            <div style={{ marginBottom: 12 }}>
              <label style={{ color: C.textMid, fontSize: 10, fontWeight: 700, display: "block", marginBottom: 4 }}>MÉTODO DE PAGO</label>
              <select value={editForm.metodo_pago} onChange={(e) => setEditForm((f) => ({ ...f, metodo_pago: e.target.value }))} style={{ width: "100%", padding: "8px 10px", borderRadius: 7, border: `1px solid ${C.border}`, background: C.card, color: C.text, fontSize: 12, outline: "none" }}>
                <option value="efectivo">Efectivo</option>
                <option value="tarjeta">Tarjeta</option>
              </select>
            </div>
            <div style={{ marginBottom: 16 }}>
              <label style={{ color: C.textMid, fontSize: 10, fontWeight: 700, display: "block", marginBottom: 4 }}>NOTAS</label>
              <textarea value={editForm.notas} onChange={(e) => setEditForm((f) => ({ ...f, notas: e.target.value }))} rows={3} placeholder="Observaciones…" style={{ width: "100%", padding: "8px 10px", borderRadius: 7, border: `1px solid ${C.border}`, background: C.card, color: C.text, fontSize: 12, outline: "none", resize: "vertical", boxSizing: "border-box" }} />
            </div>
            <div style={{ display: "flex", gap: 10, justifyContent: "flex-end" }}>
              <button type="button" onClick={() => setModalEdit(null)} style={{ padding: "8px 16px", borderRadius: 8, border: `1px solid ${C.border}`, background: "transparent", color: C.textMid, cursor: "pointer", fontWeight: 700, fontSize: 12 }}>Cancelar</button>
              <button type="button" onClick={guardarEditar} disabled={saving} style={{ padding: "8px 18px", borderRadius: 8, border: "none", background: BRAND.gradient, color: "#fff", cursor: "pointer", fontWeight: 700, fontSize: 12 }}>
                {saving ? "Guardando…" : "💾 Guardar"}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
