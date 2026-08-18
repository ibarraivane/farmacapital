import React, { useRef, useEffect, useState, useCallback } from "react";
import TicketVenta from "./TicketVenta";
import { printTicket } from "../../utils/printTicket";
import { downloadFacturaPDF } from "../../utils/generateFacturaPDF";
import {
  notifyPosTicket,
  formatWhatsAppSendError,
} from "../../utils/orderReceiptWhatsApp";
import { usePedidoTicketUrl } from "../../hooks/usePedidoTicketUrl";
import { supabase } from "../../supabase";
import { showToast } from "../../ui";
import { telefonoMxValido, soloDigitosTel, normalizarTelefonoMxGuardar, telefonosMxEquivalentes } from "../../utils";

function FacturaInlineForm({ venta, cliente, onClose }) {
  const [rfc,    setRfc]    = React.useState(cliente?.rfc||"");
  const [nombre, setNombre] = React.useState(cliente?.razon_social||cliente?.nombre||"");
  const [email,  setEmail]  = React.useState(cliente?.email||"");
  const [uso,    setUso]    = React.useState("G03");
  const [saving, setSaving] = React.useState(false);
  const [ok,     setOk]     = React.useState(false);
  const [err,    setErr]    = React.useState("");

  const USO_CFDI = [
    {val:"G01", label:"G01 — Adquisición de mercancias"},
    {val:"G03", label:"G03 — Gastos en general"},
    {val:"S01", label:"S01 — Sin efectos fiscales"},
    {val:"D01", label:"D01 — Honorarios médicos"},
    {val:"CP01",label:"CP01 — Pagos"},
  ];

  const validarRFC = r => /^[A-ZÑ&]{3,4}\d{6}[A-Z0-9]{3}$/i.test(r.trim());

  const solicitar = async () => {
    if(!rfc.trim())         { setErr("El RFC es requerido"); return; }
    if(!validarRFC(rfc))    { setErr("RFC inválido (ej: XAXX010101000)"); return; }
    if(!nombre.trim())      { setErr("El nombre/razón social es requerido"); return; }
    setSaving(true); setErr("");
    try {
      const tok = sessionStorage.getItem("farmacapital_session_token");
      if (!tok) throw new Error("Sesión expirada");
      const { data: resp, error } = await supabase.rpc("crear_factura", {
        p_session_token:  tok,
        p_pedido_id:      venta?.id || null,
        p_rfc:            rfc.trim().toUpperCase(),
        p_razon_social:   nombre.trim().toUpperCase(),
        p_uso_cfdi:       uso,
        p_regimen_fiscal: null,
        p_folio_fiscal:   null,
        p_pac_proveedor:  "pendiente",
        p_email:          null,
      });
      if (error) throw error;
      if (!resp?.success) throw new Error(resp?.error || "No se pudo solicitar");
      setOk(true);
    } catch(e) { setErr("Error al guardar: " + e.message); }
    setSaving(false);
  };

  const inpS = {
    width:"100%", boxSizing:"border-box",
    padding:"7px 10px", borderRadius:7,
    border:"1px solid #e2e8f0",
    background:"#fff", color:"#0f172a",
    fontSize:12, outline:"none", marginBottom:8,
    fontFamily:"var(--fc-body)",
  };

  if(ok) return(
    <div style={{background:"#dcfce7",borderRadius:10,padding:16,textAlign:"center",margin:"8px 0"}}>
      <div style={{fontSize:32,marginBottom:8}}>✅</div>
      <div style={{color:"#16a34a",fontWeight:800,fontSize:14}}>¡Solicitud guardada!</div>
      <button type="button" onClick={onClose} style={{marginTop:12,padding:"7px 20px",borderRadius:8,border:"none",background:"#16a34a",color:"#fff",fontWeight:700,cursor:"pointer",fontSize:12}}>
        Cerrar
      </button>
    </div>
  );

  return(
    <div style={{background:"#f8fafc",borderRadius:10,padding:14,border:"1px solid #e2e8f0",margin:"8px 0"}}>
      <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:10}}>
        <div style={{color:"#0f172a",fontWeight:700,fontSize:13}}>🧾 Solicitar factura CFDI</div>
        <button type="button" onClick={onClose} aria-label="Cerrar factura" style={{background:"none",border:"none",color:"#94a3b8",cursor:"pointer",fontSize:18,lineHeight:1}}>✕</button>
      </div>
      <input style={inpS} value={rfc} onChange={e=>setRfc(e.target.value.toUpperCase())} placeholder="RFC *"/>
      <input style={inpS} value={nombre} onChange={e=>setNombre(e.target.value)} placeholder="Nombre o Razón Social *"/>
      <input style={{...inpS}} type="email" value={email} onChange={e=>setEmail(e.target.value)} placeholder="Correo electrónico"/>
      <select style={inpS} value={uso} onChange={e=>setUso(e.target.value)}>
        {USO_CFDI.map(u=><option key={u.val} value={u.val}>{u.label}</option>)}
      </select>
      {err&&<div style={{color:"#ef4444",fontSize:11,marginBottom:8,padding:"4px 8px",background:"#fee2e2",borderRadius:6}}>{err}</div>}
      <button type="button" onClick={solicitar} disabled={saving} style={{
        width:"100%",padding:"10px",borderRadius:8,border:"none",
        background:"linear-gradient(135deg,#0D1B2A,#1E3ABA)",
        color:"#fff",fontWeight:700,fontSize:13,cursor:"pointer",opacity:saving?0.6:1,
      }}>
        {saving?"Guardando…":"📤 Solicitar factura"}
      </button>
    </div>
  );
}

async function buscarClientePorTelefono(telefono) {
  const tok = sessionStorage.getItem("farmacapital_session_token");
  if (!tok) return null;
  const { data, error } = await supabase.rpc("empleado_buscar_clientes_pos", {
    p_session_token: tok,
    p_busqueda: soloDigitosTel(telefono),
    p_limit: 5,
  });
  if (error) return null;
  const rows = Array.isArray(data) ? data : [];
  const digits = soloDigitosTel(telefono);
  return rows.find((c) => telefonosMxEquivalentes(c.telefono, telefono)) || rows[0] || null;
}

async function crearClienteManual(nombre, telefono) {
  const tok = sessionStorage.getItem("farmacapital_session_token");
  if (!tok) throw new Error("Sesión expirada");
  const { data: resp, error } = await supabase.rpc("admin_crear_cliente_manual", {
    p_session_token: tok,
    p_nombre: nombre.trim(),
    p_telefono: normalizarTelefonoMxGuardar(telefono),
    p_email: null,
    p_notas: "Alta desde ticket POS / WhatsApp",
  });
  if (error) throw error;
  if (!resp?.success) throw new Error(resp?.error || "No se pudo registrar");
  const telNorm = normalizarTelefonoMxGuardar(telefono);
  return resp.cliente || { id: resp.cliente_id, nombre, telefono: telNorm, puntos: 0 };
}

async function acumularPuntosVenta(pedidoId, clienteId) {
  const tok = sessionStorage.getItem("farmacapital_session_token");
  if (!tok || !pedidoId || !clienteId) return null;
  const { data, error } = await supabase.rpc("empleado_acumular_puntos_venta_pos", {
    p_session_token: tok,
    p_pedido_id: pedidoId,
    p_cliente_id: clienteId,
  });
  if (error) {
    console.warn("[ticket] acumular puntos:", error);
    return null;
  }
  return data;
}

function WhatsAppTicketPanel({
  venta, productos, metodoPago, config, clienteInicial, pedidoId, onClienteActualizado, onSent, onOmitir,
}) {
  const [waTel, setWaTel] = useState(clienteInicial?.telefono || "");
  const [waNombre, setWaNombre] = useState("");
  const [modoRegistro, setModoRegistro] = useState(false);
  const [buscando, setBuscando] = useState(false);
  const [enviando, setEnviando] = useState(false);
  const [waErr, setWaErr] = useState("");
  const [enviadoOk, setEnviadoOk] = useState(null);
  const telRef = useRef(null);

  useEffect(() => {
    if (clienteInicial?.telefono) setWaTel(clienteInicial.telefono);
  }, [clienteInicial]);

  const enviarConCliente = useCallback(async (cli) => {
    if (!cli?.telefono) return;
    if (!pedidoId) {
      setWaErr("No hay folio de venta para enviar el ticket.");
      return;
    }
    setEnviando(true);
    setWaErr("");
    setEnviadoOk(null);
    let puntosGanados = Math.floor(Number(venta.total || 0) / 10);
    let saldoPuntos = cli.puntos ?? null;
    if (pedidoId && cli.id) {
      const ptsResp = await acumularPuntosVenta(pedidoId, cli.id);
      if (ptsResp?.success) {
        puntosGanados = ptsResp.puntos_ganados ?? puntosGanados;
        saldoPuntos = ptsResp.puntos_total ?? saldoPuntos;
        onClienteActualizado?.({ ...cli, puntos: saldoPuntos });
      }
    }
    const result = await notifyPosTicket({
      pedidoId,
      telefono: cli.telefono,
      total: venta?.total,
      metodoPago,
      productos,
      puntosGanados,
      saldoPuntos,
    });
    setEnviando(false);
    if (!result.sent) {
      const hint = formatWhatsAppSendError({
        reason: result.reason,
        detail: result.detail,
        telefono: cli.telefono,
      });
      setWaErr(hint);
      console.warn("[ticket] WhatsApp API:", result.reason, result.detail);
      return;
    }
    setEnviadoOk({
      telefono: cli.telefono,
      nombre: cli.nombre,
      puntosGanados,
      saldoPuntos,
    });
    showToast(
      puntosGanados > 0
        ? `Ticket enviado por WhatsApp · +${puntosGanados} pts`
        : "Ticket enviado por WhatsApp",
      "success"
    );
    onSent?.();
  }, [venta, productos, metodoPago, pedidoId, onClienteActualizado, onSent]);

  const iniciarEnvio = async () => {
    if (clienteInicial?.telefono && telefonoMxValido(clienteInicial.telefono)) {
      await enviarConCliente(clienteInicial);
      return;
    }
    if (!telefonoMxValido(waTel)) {
      setWaErr("Ingresa un teléfono de 10 dígitos.");
      telRef.current?.focus();
      return;
    }
    setBuscando(true);
    setWaErr("");
    try {
      const encontrado = await buscarClientePorTelefono(waTel);
      if (encontrado) { await enviarConCliente(encontrado); return; }
      setModoRegistro(true);
    } catch (e) {
      setWaErr(e.message || "Error al buscar cliente");
    } finally {
      setBuscando(false);
    }
  };

  const registrarYEnviar = async () => {
    if (!waNombre.trim()) { setWaErr("Escribe el nombre del cliente."); return; }
    setEnviando(true);
    setWaErr("");
    try {
      const nuevo = await crearClienteManual(waNombre, waTel);
      onClienteActualizado?.(nuevo);
      await enviarConCliente(nuevo);
      setModoRegistro(false);
    } catch (e) {
      if (String(e.message || "").includes("Ya existe")) {
        const existente = await buscarClientePorTelefono(waTel);
        if (existente) { await enviarConCliente(existente); setModoRegistro(false); return; }
      }
      setWaErr(e.message || "No se pudo registrar");
    } finally {
      setEnviando(false);
    }
  };

  const btnOmitir = (
    <button
      type="button"
      onClick={onOmitir}
      style={{
        width:"100%", marginTop:4, padding:"10px 12px", borderRadius:8,
        border:"1px solid #cbd5e1", background:"#fff", color:"#475569",
        fontWeight:700, fontSize:13, cursor:"pointer",
      }}
    >
      No, gracias — continuar como invitado
    </button>
  );

  if (enviadoOk) {
    return (
      <div style={{ background: "#dcfce7", border: "1px solid #86efac", borderRadius: 10, padding: 14 }}>
        <div style={{ fontWeight: 800, fontSize: 14, color: "#166534", marginBottom: 8 }}>✅ Ticket enviado por WhatsApp</div>
        <div style={{ fontSize: 12, color: "#15803d", lineHeight: 1.5 }}>
          {enviadoOk.nombre ? <div><strong>{enviadoOk.nombre}</strong></div> : null}
          <div>📱 {enviadoOk.telefono}</div>
          {enviadoOk.puntosGanados > 0 ? (
            <div>⭐ +{enviadoOk.puntosGanados} pts
              {enviadoOk.saldoPuntos != null ? ` · Saldo: ${enviadoOk.saldoPuntos} pts` : ""}
            </div>
          ) : null}
        </div>
        {btnOmitir}
      </div>
    );
  }

  if (clienteInicial?.telefono && !modoRegistro) {
    return (
      <div style={{display:"flex",flexDirection:"column",gap:8}}>
        <div style={{fontSize:11,color:"#475569"}}>
          Cliente: <strong>{clienteInicial.nombre}</strong> · {clienteInicial.telefono}
          {clienteInicial.puntos != null ? ` · ${clienteInicial.puntos} pts` : ""}
        </div>
        <button type="button" onClick={() => enviarConCliente(clienteInicial)} disabled={enviando}
          style={{padding:"12px",borderRadius:10,border:"none",background:"#25D366",color:"#fff",fontWeight:800,fontSize:14,cursor:"pointer",opacity:enviando?0.7:1}}>
          {enviando ? "Enviando por WhatsApp…" : "📱 Enviar ticket por WhatsApp"}
        </button>
        {btnOmitir}
        {waErr ? <div style={{color:"#ef4444",fontSize:11}}>{waErr}</div> : null}
      </div>
    );
  }

  return (
    <div style={{background:"#f0fdf4",border:"1px solid #bbf7d0",borderRadius:10,padding:12}}>
      <div style={{fontWeight:700,fontSize:13,color:"#166534",marginBottom:8}}>📱 Enviar ticket por WhatsApp</div>
      {!modoRegistro ? (
        <>
          <input ref={telRef} type="tel" inputMode="numeric" value={waTel}
            onChange={(e) => { setWaTel(e.target.value); setWaErr(""); }}
            onKeyDown={(e) => { if (e.key === "Enter") iniciarEnvio(); }}
            placeholder="Teléfono (10 dígitos)"
            style={{width:"100%",boxSizing:"border-box",padding:"10px 12px",borderRadius:8,border:"1px solid #86efac",fontSize:16,marginBottom:8}}/>
          <button type="button" onClick={iniciarEnvio} disabled={buscando||enviando}
            style={{width:"100%",padding:"11px",borderRadius:8,border:"none",background:"#25D366",color:"#fff",fontWeight:800,fontSize:13,cursor:"pointer",opacity:(buscando||enviando)?0.7:1}}>
            {buscando ? "Buscando…" : "Continuar →"}
          </button>
          {btnOmitir}
        </>
      ) : (
        <>
          <div style={{fontSize:11,color:"#166534",marginBottom:8,lineHeight:1.5}}>
            ¿Registrar al cliente para acumular puntos? (opcional)
          </div>
          <input value={waNombre} onChange={(e) => setWaNombre(e.target.value)} placeholder="Nombre completo"
            style={{width:"100%",boxSizing:"border-box",padding:"9px 12px",borderRadius:8,border:"1px solid #86efac",fontSize:14,marginBottom:8}}/>
          <div style={{display:"flex",gap:8}}>
            <button type="button" onClick={registrarYEnviar} disabled={enviando || !waNombre.trim()}
              style={{flex:1,padding:"10px",borderRadius:8,border:"none",background:"#25D366",color:"#fff",fontWeight:800,cursor:"pointer",opacity:(enviando||!waNombre.trim())?0.6:1}}>
              {enviando ? "Enviando…" : "Registrar y enviar"}
            </button>
          </div>
          {btnOmitir}
        </>
      )}
      {waErr ? <div style={{color:"#ef4444",fontSize:11,marginTop:8}}>{waErr}</div> : null}
    </div>
  );
}

export default function TicketPreviewModal({
  open, venta={}, productos=[], cliente: clienteProp=null,
  metodoPago="Efectivo", config={}, promoMsg=null,
  origen="tienda", autoWhatsApp=false,
  onClose, onNuevaVenta,
}) {
  const ticketRef = useRef(null);
  const panelRef = useRef(null);
  const [showFactura, setShowFactura] = useState(false);
  const [clienteLocal, setClienteLocal] = useState(clienteProp);
  const [mostrarWaPanel, setMostrarWaPanel] = useState(false);

  useEffect(() => { setClienteLocal(clienteProp); }, [clienteProp, open]);

  useEffect(() => {
    if (!open) { setShowFactura(false); setMostrarWaPanel(false); return undefined; }
    const prev = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    const onKey = (e) => {
      if (e.key === "Escape") { e.preventDefault(); onClose?.(); }
    };
    document.addEventListener("keydown", onKey);
    const t = setTimeout(() => panelRef.current?.querySelector("[data-ticket-close]")?.focus?.(), 0);
    return () => {
      document.body.style.overflow = prev || "auto";
      document.removeEventListener("keydown", onKey);
      clearTimeout(t);
    };
  }, [open, onClose]);

  useEffect(() => {
    if (open && autoWhatsApp) setMostrarWaPanel(true);
  }, [open, autoWhatsApp]);

  if (!open) return null;

  const handlePrint = () => printTicket("farmacapital-ticket");
  const esTienda = origen === "tienda" || origen === "consulta";
  const pedidoId = venta?.id;
  const { ticketUrl, loading: ticketUrlLoading } = usePedidoTicketUrl(pedidoId, open);
  const esInvitado = !clienteLocal?.id && !clienteLocal?.telefono;

  const omitirWhatsApp = () => {
    setMostrarWaPanel(false);
    showToast("Venta registrada · cliente invitado", "info");
  };

  const btnBase = {
    padding:"11px 12px", borderRadius:10, fontWeight:700, fontSize:13,
    cursor:"pointer", display:"flex", alignItems:"center", justifyContent:"center", gap:6,
    width:"100%", boxSizing:"border-box",
  };

  return (
    <div
      role="presentation"
      style={{
      position:"fixed", inset:0, zIndex:9000, background:"rgba(15,23,42,.6)", backdropFilter:"blur(4px)",
      display:"flex", alignItems:"center", justifyContent:"center",
      padding:"max(8px, env(safe-area-inset-top)) max(8px, env(safe-area-inset-right)) max(8px, env(safe-area-inset-bottom)) max(8px, env(safe-area-inset-left))",
      boxSizing:"border-box",
    }} onClick={(e) => e.target === e.currentTarget && onClose?.()}>
      <div
        ref={panelRef}
        role="dialog"
        aria-modal="true"
        aria-labelledby="ticket-preview-title"
        style={{
        background:"#fff", borderRadius:16, width:"min(440px, 100%)", maxHeight:"min(96dvh, 100vh)",
        boxShadow:"0 24px 80px rgba(15,45,110,.2)", display:"flex", flexDirection:"column", minWidth:0, overflow:"hidden",
      }} onClick={(e) => e.stopPropagation()}>
        <div style={{
          padding:"14px 18px", flexShrink:0, borderBottom:"1px solid #e2e8f0",
          display:"flex", justifyContent:"space-between", alignItems:"center",
          background:"linear-gradient(135deg,#0D1B2A,#1E3ABA)", borderRadius:"16px 16px 0 0",
        }}>
          <div id="ticket-preview-title" style={{color:"#fff", fontWeight:800, fontSize:15}}>
            ✅ Venta registrada — Ticket #{venta.id || "—"}
          </div>
          <button type="button" data-ticket-close onClick={onClose} aria-label="Cerrar" style={{
            background:"rgba(255,255,255,.2)", border:"none", color:"#fff",
            width:32, height:32, borderRadius:"50%", cursor:"pointer", fontSize:18,
          }}>✕</button>
        </div>

        {esTienda && (
          <div style={{flexShrink:0,padding:"10px 16px",background:"#eff6ff",borderBottom:"1px solid #bfdbfe",fontSize:12,color:"#1e40af",lineHeight:1.45}}>
            La venta <strong>ya quedó guardada</strong> en el sistema
            {venta?.folio ? ` (${venta.folio})` : pedidoId ? ` (#${pedidoId})` : ""}.
            Pregunta: <strong>¿ticket impreso o por WhatsApp?</strong> Si no quiere, continúa como <strong>invitado</strong>.
          </div>
        )}
        {esTienda && esInvitado && !mostrarWaPanel && (
          <div style={{flexShrink:0,padding:"8px 16px",background:"#f8fafc",borderBottom:"1px solid #e2e8f0",fontSize:11,color:"#64748b"}}>
            👤 Cliente invitado — sin registro ni puntos. Puedes imprimir ticket abajo si lo pide.
          </div>
        )}
        {autoWhatsApp && (
          <div style={{flexShrink:0,padding:"10px 16px",background:"#f0fdf4",borderBottom:"1px solid #bbf7d0",fontSize:12,color:"#166534"}}>
            Pedido en línea — confirma el envío del recibo por WhatsApp abajo.
          </div>
        )}

        <div style={{
          flex:"1 1 auto", minHeight:0, overflowY:"auto", WebkitOverflowScrolling:"touch",
          padding:12, background:"#f8fafc", display:"flex", justifyContent:"center",
        }}>
          <div style={{background:"#fff",boxShadow:"0 2px 12px rgba(0,0,0,.08)",borderRadius:4,padding:4}}>
            <TicketVenta ref={ticketRef} venta={venta} productos={productos} cliente={clienteLocal}
              metodoPago={metodoPago} config={config} promoMsg={promoMsg} ticketUrl={ticketUrl}/>
          </div>
        </div>

        <div style={{
          flexShrink:0, padding:"12px 14px 14px", borderTop:"1px solid #e2e8f0", background:"#fff",
          display:"flex", flexDirection:"column", gap:8,
          maxHeight:"min(52vh, 420px)", overflowY:"auto", WebkitOverflowScrolling:"touch",
        }}>
          {(mostrarWaPanel || autoWhatsApp) ? (
            <WhatsAppTicketPanel venta={venta} productos={productos} metodoPago={metodoPago} config={config}
              clienteInicial={clienteLocal} pedidoId={pedidoId} onClienteActualizado={setClienteLocal}
              onSent={() => setMostrarWaPanel(true)} onOmitir={omitirWhatsApp}/>
          ) : (
            <button type="button" onClick={() => setMostrarWaPanel(true)}
              style={{...btnBase,border:"1px solid #25D366",background:"#dcfce7",color:"#15803d"}}>
              📱 Enviar ticket por WhatsApp (opcional)
            </button>
          )}

          <button type="button" onClick={handlePrint} disabled={Boolean(pedidoId && ticketUrlLoading)}
            style={{...btnBase,border:"none",background:"linear-gradient(135deg,#0D1B2A,#1E3ABA)",color:"#fff",fontWeight:800,opacity:(pedidoId && ticketUrlLoading)?0.65:1}}>
            {pedidoId && ticketUrlLoading ? "Preparando QR…" : `🖨️ Imprimir ticket ${esInvitado ? "(si el cliente lo pide)" : ""}`}
          </button>

          <div style={{display:"grid",gridTemplateColumns:"1fr 1fr",gap:8}}>
            <button type="button" onClick={() => setShowFactura((v) => !v)}
              style={{...btnBase,border:"1px solid #0D1B2A",background:"#eff6ff",color:"#0D1B2A"}}>
              🧾 Factura CFDI
            </button>
            <button type="button" onClick={() => downloadFacturaPDF({venta,productos,cliente:clienteLocal,config,metodoPago})}
              style={{...btnBase,border:"1px solid #7c3aed",background:"#ede9fe",color:"#7c3aed"}}>
              📄 PDF
            </button>
          </div>

          {showFactura && <FacturaInlineForm venta={venta} cliente={clienteLocal} onClose={() => setShowFactura(false)}/>}

          <button type="button" onClick={onNuevaVenta || onClose}
            style={{...btnBase,border:"none",background:"#16a34a",color:"#fff",fontWeight:800,fontSize:14,minHeight:48}}>
            ✅ Nueva venta
          </button>
        </div>
      </div>
    </div>
  );
}
