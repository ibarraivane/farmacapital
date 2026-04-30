import { useState, useEffect, useCallback } from "react";
import { supabase } from "./supabase";
import { C_LIGHT, BRAND } from "./constants";
import { showToast, SkeletonTable, Paginador } from "./ui";
import TicketVenta from "./components/tickets/TicketVenta";
import { printTicket } from "./utils/printTicket";
import { labelTipoEntregaPedido } from "./utils/orderChannels";
import { productMatchesSearchQuery } from "./utils/fuzzySearch";

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
  const [loadingReprint, setLoadingReprint] = useState(false);
  const [detItems, setDetItems] = useState([]);
  const [loadDet, setLoadDet] = useState(false);
  const [editForm, setEditForm] = useState({});
  const [saving, setSaving] = useState(false);

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
    const tok = sessionStorage.getItem("farmax_session_token");
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
    setPedidos(Array.isArray(data) ? data : []);
    setLoading(false);
  }, [filtroFecha, fechaDesde, fechaHasta]);

  useEffect(() => { fetchPedidos(); }, [fetchPedidos]);

  const eliminarPedidoCompleto = async (p) => {
    const tok = sessionStorage.getItem("farmax_session_token");
    if (!tok) { showToast("Sesión expirada","error"); return; }
    const { error } = await supabase.rpc("admin_eliminar_pedido", {
      p_session_token: tok, p_pedido_id: p.id,
    });
    if (error) showToast("Error: "+error.message, "error");
  };

  const filtradosTodos = pedidos.filter((p) => {
    const q = busqueda.trim();
    const matchB = !q || p.id?.toString().includes(q) || (p.clientes && productMatchesSearchQuery(p.clientes, busqueda, [(x) => x.nombre]));
    const matchT = filtroTipo === "todos" || p.tipo === filtroTipo || (!p.tipo && filtroTipo === "fisica");
    const matchE = filtroEstado === "todos" || p.estado === filtroEstado;
    return matchB && matchT && matchE;
  });
  const filtrados = filtradosTodos.slice((pagina - 1) * POR_PAGINA, pagina * POR_PAGINA);

  const reimprimir = async (p) => {
    setLoadingReprint(true);
    const tok = sessionStorage.getItem("farmax_session_token");
    const { data: items } = await supabase.rpc("empleado_listar_pedido_items_basico", {
      p_session_token: tok,
      p_pedido_id: p.id,
    });
    let cliente = null;
    if (p.cliente_id) {
      const tok = sessionStorage.getItem("farmax_session_token");
      const { data: cli } = await supabase.rpc("admin_obtener_cliente", {
        p_session_token: tok, p_cliente_id: p.cliente_id,
      });
      cliente = cli;
    }
    setTicketReprint({
      venta: { id: p.id, total: p.total, created_at: p.created_at, metodo_pago: p.metodo_pago },
      productos: (items || []).map((i) => ({
        nombre: i.productos?.nombre || "Producto",
        qty: i.cantidad,
        precio: i.precio_unitario,
      })),
      cliente,
      metodoPago: p.metodo_pago || "Efectivo",
    });
    setLoadingReprint(false);
  };

  const abrirDetalle = async (p) => {
    setModalDet(p); setLoadDet(true); setDetItems([]);
    const tok = sessionStorage.getItem("farmax_session_token");
    const { data } = await supabase.rpc("empleado_listar_pedido_items_detalle_transacciones", {
      p_session_token: tok,
      p_pedido_id: p.id,
    });
    setDetItems(data || []); setLoadDet(false);
  };

  const abrirEditar = (p) => {
    setModalEdit(p);
    const mp = p.metodo_pago === "spei" || p.metodo_pago === "mercadopago" ? "tarjeta" : (p.metodo_pago || "efectivo");
    setEditForm({ estado: p.estado || "", metodo_pago: mp, notas: p.notas || "" });
  };

  const guardarEditar = async () => {
    setSaving(true);
    const tok = sessionStorage.getItem("farmax_session_token");
    const { error } = await supabase.rpc("admin_editar_pedido", {
      p_session_token: tok,
      p_pedido_id: modalEditar.id,
      p_estado: editForm.estado,
      p_metodo_pago: editForm.metodo_pago,
      p_notas: editForm.notas || null,
    });
    setSaving(false); setModalEdit(null);
    if (error) showToast("Error: "+error.message, "error");
    fetchPedidos();
  };

  const cancelarPed = async (p) => {
    if (!showConfirm) {
      showToast("Diálogo de confirmación no disponible.", "error");
      return;
    }
    showConfirm("Cancelar pedido", `¿Cancelar el pedido #${p.id}? El estado cambiará a cancelado.`, async () => {
      const tok = sessionStorage.getItem("farmax_session_token");
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
        </select>
        <select value={filtroEstado} onChange={(e) => setFiltroE(e.target.value)} style={inpS}>
          <option value="todos">Todos los estados</option>
          <option value="completado">Completado</option>
          <option value="pendiente">Pendiente</option>
          <option value="cancelado">Cancelado</option>
        </select>
        <span style={{ color: C.textMid, fontSize: 11, marginLeft: "auto" }}>{filtradosTodos.length} transacciones</span>
      </div>

      {loading ? <SkeletonTable rows={5} cols={6} /> : (
        <div style={{ overflowX: "auto", borderRadius: 12, border: `1px solid ${C.border}`, marginBottom: 16 }}>
          <table style={{ width: "100%", borderCollapse: "collapse", fontSize: 12 }}>
            <thead>
              <tr style={{ background: C.cardDark }}>
                {["ID", "Fecha/Hora", "Cliente", "Total", "Método", "Tipo", "Atendido por", "Estado", "Acciones"].map((h) => (
                  <th key={h} style={{ padding: "9px 12px", textAlign: "left", color: C.textMid, fontWeight: 700, borderBottom: `1px solid ${C.border}`, whiteSpace: "nowrap" }}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {filtrados.length === 0 && <tr><td colSpan={9} style={{ textAlign: "center", padding: 32, color: C.textMid }}>Sin transacciones en este período</td></tr>}
              {filtrados.map((p, i) => (
                <tr className="farmax-table-row" key={p.id} style={{ background: p.estado === "cancelado" ? "#fff5f5" : i % 2 === 0 ? "transparent" : "#f8fafc" }}>
                  <td style={{ padding: "8px 12px", color: C.textMid, borderBottom: `1px solid ${C.border}`, fontFamily: "monospace", fontSize: 11 }}>#{p.id}</td>
                  <td style={{ padding: "8px 12px", color: C.textMid, borderBottom: `1px solid ${C.border}`, whiteSpace: "nowrap" }}>{fmtDT(p.created_at)}</td>
                  <td style={{ padding: "8px 12px", color: C.text, fontWeight: 600, borderBottom: `1px solid ${C.border}` }}>{p.clientes?.nombre || "—"}</td>
                  <td style={{ padding: "8px 12px", color: C.green, fontWeight: 700, borderBottom: `1px solid ${C.border}` }}>{fmtM(p.total)}</td>
                  <td style={{ padding: "8px 12px", color: C.textMid, borderBottom: `1px solid ${C.border}` }}>{p.metodo_pago || "—"}</td>
                  <td style={{ padding: "8px 12px", borderBottom: `1px solid ${C.border}`, verticalAlign: "top" }}>
                    <span style={{ padding: "2px 8px", borderRadius: 20, fontSize: 10, fontWeight: 700,
                      background: p.tipo === "online" ? "#ede9fe" : p.tipo === "consulta" ? "#dcfce7" : "#eff6ff",
                      color: p.tipo === "online" ? C.purple : p.tipo === "consulta" ? C.green : C.blue }}>
                      {p.tipo || "física"}
                    </span>
                    {p.tipo_entrega && (
                      <div style={{ fontSize: 10, color: C.textMid, marginTop: 4, lineHeight: 1.3, maxWidth: 140 }}>
                        {labelTipoEntregaPedido(p.tipo_entrega)}
                        {p.tipo_entrega === "envio" && p.direccion && (
                          <span title={p.direccion} style={{ display: "block", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{p.direccion}</span>
                        )}
                      </div>
                    )}
                  </td>
                  <td style={{ padding: "8px 12px", color: C.textMid, borderBottom: `1px solid ${C.border}` }}>{p.usuarios?.nombre || "—"}</td>
                  <td style={{ padding: "8px 12px", borderBottom: `1px solid ${C.border}` }}>
                    <span style={{ padding: "2px 8px", borderRadius: 20, fontSize: 10, fontWeight: 700, background: estCol(p.estado) + "20", color: estCol(p.estado) }}>{p.estado || "—"}</span>
                  </td>
                  <td style={{ padding: "8px 12px", borderBottom: `1px solid ${C.border}`, whiteSpace: "nowrap" }}>
                    <button type="button" onClick={() => abrirDetalle(p)} style={{ padding: "3px 8px", borderRadius: 5, border: `1px solid ${C.blue}30`, background: "#eff6ff", color: C.blue, cursor: "pointer", fontSize: 10, fontWeight: 700, marginRight: 4 }}>👁 Ver</button>
                    <button type="button" onClick={() => reimprimir(p)} disabled={loadingReprint} style={{ padding: "3px 8px", borderRadius: 5, border: `1px solid ${C.purple}30`, background: "#ede9fe", color: C.purple, cursor: "pointer", fontSize: 10, fontWeight: 700, marginRight: 4 }}>🖨️ Reimprimir</button>
                    {usuario?.rol === "admin" && <>
                      <button type="button" onClick={() => abrirEditar(p)} style={{ padding: "3px 8px", borderRadius: 5, border: `1px solid ${C.amber}30`, background: "#fef3c7", color: C.amber, cursor: "pointer", fontSize: 10, fontWeight: 700, marginRight: 4 }}>✏️</button>
                      {p.estado !== "cancelado" && <button type="button" onClick={() => cancelarPed(p)} style={{ padding: "3px 8px", borderRadius: 5, border: "1px solid #94a3b830", background: "#f1f5f9", color: C.textMid, cursor: "pointer", fontSize: 10, fontWeight: 700, marginRight: 4 }}>❌</button>}
                      <button type="button" onClick={() => eliminarPed(p)} style={{ padding: "3px 8px", borderRadius: 5, border: `1px solid ${C.red}30`, background: "#fee2e2", color: C.red, cursor: "pointer", fontSize: 10, fontWeight: 700 }}>🗑️</button>
                    </>}
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
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 16 }}>
              <h3 style={{ margin: 0, color: C.text, fontSize: 15, fontWeight: 800 }}>👁 Detalle — Pedido #{modalDetalle.id}</h3>
              <button type="button" onClick={() => setModalDet(null)} style={{ background: "none", border: "none", color: C.textMid, fontSize: 20, cursor: "pointer" }}>✕</button>
            </div>
            <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(min(100%, 160px), 1fr))", gap: 12, marginBottom: 16, fontSize: 12 }}>
              <div><span style={{ color: C.textMid }}>Cliente: </span><strong style={{ color: C.text }}>{modalDetalle.clientes?.nombre || "—"}</strong></div>
              <div><span style={{ color: C.textMid }}>Fecha: </span><strong style={{ color: C.text }}>{fmtDT(modalDetalle.created_at)}</strong></div>
              <div><span style={{ color: C.textMid }}>Total: </span><strong style={{ color: C.green }}>{fmtM(modalDetalle.total)}</strong></div>
              <div><span style={{ color: C.textMid }}>Método: </span><strong style={{ color: C.text }}>{modalDetalle.metodo_pago || "—"}</strong></div>
              <div><span style={{ color: C.textMid }}>Estado: </span><strong style={{ color: estCol(modalDetalle.estado) }}>{modalDetalle.estado}</strong></div>
              <div><span style={{ color: C.textMid }}>Tipo: </span><strong style={{ color: C.text }}>{modalDetalle.tipo || "física"}</strong></div>
              {modalDetalle.tipo_entrega && (
                <div><span style={{ color: C.textMid }}>Entrega: </span><strong style={{ color: C.text }}>{labelTipoEntregaPedido(modalDetalle.tipo_entrega)}</strong></div>
              )}
              {modalDetalle.tipo_entrega === "envio" && modalDetalle.direccion && (
                <div style={{ gridColumn: "1 / -1" }}><span style={{ color: C.textMid }}>Dirección: </span><strong style={{ color: C.text }}>{modalDetalle.direccion}</strong></div>
              )}
            </div>
            {modalDetalle.notas && <div style={{ background: C.cardDark, borderRadius: 8, padding: "8px 12px", marginBottom: 14, color: C.textMid, fontSize: 12 }}>📝 {modalDetalle.notas}</div>}
            <div style={{ fontWeight: 700, color: C.text, fontSize: 13, marginBottom: 10 }}>Productos:</div>
            {loadDet ? <SkeletonTable rows={3} cols={4} /> : (
              <table style={{ width: "100%", borderCollapse: "collapse", fontSize: 12 }}>
                <thead><tr style={{ background: C.cardDark }}>{["Producto", "Cant.", "Precio", "Subtotal"].map((h) => <th key={h} style={{ padding: "7px 10px", textAlign: "left", color: C.textMid, fontWeight: 700, borderBottom: `1px solid ${C.border}` }}>{h}</th>)}</tr></thead>
                <tbody>
                  {detItems.map((it, i) => (
                    <tr key={i}>
                      <td style={{ padding: "7px 10px", color: C.text, fontWeight: 600, borderBottom: `1px solid ${C.border}` }}>
                        {it.productos?.nombre || it.nombre || "—"}
                        {it.lotes?.numero_lote && <div style={{ fontSize: 9, color: C.textDim, marginTop: 1 }}>Lote: {it.lotes.numero_lote}{it.lotes.fecha_caducidad ? ` | Cad: ${it.lotes.fecha_caducidad}` : ""}</div>}
                      </td>
                      <td style={{ padding: "7px 10px", color: C.amber, fontWeight: 700, borderBottom: `1px solid ${C.border}` }}>{it.cantidad}</td>
                      <td style={{ padding: "7px 10px", color: C.textMid, borderBottom: `1px solid ${C.border}` }}>{fmtM(it.precio_unitario || it.precio || 0)}</td>
                      <td style={{ padding: "7px 10px", color: C.green, fontWeight: 700, borderBottom: `1px solid ${C.border}` }}>{fmtM((it.precio_unitario || it.precio || 0) * (it.cantidad || 1))}</td>
                    </tr>
                  ))}
                  <tr><td colSpan={3} style={{ padding: "8px 10px", textAlign: "right", fontWeight: 800, color: C.text }}>TOTAL</td><td style={{ padding: "8px 10px", color: C.green, fontWeight: 900, fontSize: 14 }}>{fmtM(modalDetalle.total)}</td></tr>
                </tbody>
              </table>
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
                  config={{}}
                />
              </div>
            </div>
            <div style={{ padding: 16, display: "flex", gap: 10, flexWrap: "wrap" }}>
              <button type="button" onClick={() => printTicket("farmax-ticket")} style={{ flex: "2 1 160px", minHeight: 44, padding: "11px", borderRadius: 10, border: "none", background: "linear-gradient(135deg,#7c3aed,#9d6fff)", color: "#fff", fontWeight: 800, fontSize: 14, cursor: "pointer" }}>
                🖨️ Imprimir
              </button>
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
              <h3 style={{ margin: 0, color: C.text, fontSize: 15, fontWeight: 800 }}>✏️ Editar — Pedido #{modalEditar.id}</h3>
              <button type="button" onClick={() => setModalEdit(null)} style={{ background: "none", border: "none", color: C.textMid, fontSize: 20, cursor: "pointer" }}>✕</button>
            </div>
            <div style={{ marginBottom: 12 }}>
              <label style={{ color: C.textMid, fontSize: 10, fontWeight: 700, display: "block", marginBottom: 4 }}>ESTADO</label>
              <select value={editForm.estado} onChange={(e) => setEditForm((f) => ({ ...f, estado: e.target.value }))} style={{ width: "100%", padding: "8px 10px", borderRadius: 7, border: `1px solid ${C.border}`, background: C.card, color: C.text, fontSize: 12, outline: "none" }}>
                <option value="completado">Completado</option>
                <option value="pendiente">Pendiente</option>
                <option value="cancelado">Cancelado</option>
              </select>
            </div>
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
