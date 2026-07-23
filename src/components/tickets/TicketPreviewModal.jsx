import React, { useRef, useEffect } from "react";
import TicketVenta from "./TicketVenta";
import { printTicket } from "../../utils/printTicket";
import { downloadFacturaPDF } from "../../utils/generateFacturaPDF";
import { FARMACIA_MAPS_URL } from "../../utils/orderReceiptWhatsApp";

/**
 * FARMACAPITAL — Modal de preview de ticket
 * Se muestra automáticamente después de una venta
 *
 * Props:
 * @param {boolean} open - Si el modal está abierto
 * @param {Object}  venta - Datos de la venta
 * @param {Array}   productos - Lista de productos vendidos
 * @param {Object}  cliente - Datos del cliente (opcional)
 * @param {string}  metodoPago - Método de pago usado
 * @param {Object}  config - Configuración de la farmacia
 * @param {Function} onClose - Callback al cerrar
 * @param {Function} onNuevaVenta - Callback para nueva venta
 */
// ── Importar supabase ────────────────────────────────────────
import { supabase } from "../../supabase";

// ── Formulario de solicitud de factura ───────────────────────
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
    fontFamily:"'Plus Jakarta Sans',sans-serif",
  };

  if(ok) return(
    <div style={{background:"#dcfce7",borderRadius:10,padding:16,textAlign:"center",margin:"8px 0"}}>
      <div style={{fontSize:32,marginBottom:8}}>✅</div>
      <div style={{color:"#16a34a",fontWeight:800,fontSize:14}}>¡Solicitud guardada!</div>
      <div style={{color:"#16a34a",fontSize:12,marginTop:4}}>RFC: <strong>{rfc.toUpperCase()}</strong></div>
      <div style={{color:"#475569",fontSize:11,marginTop:6,lineHeight:1.5}}>
        Tu solicitud de factura quedó registrada.<br/>
        Estado: <strong>PENDIENTE</strong><br/>
        Te contactaremos cuando esté lista.
      </div>
      <button onClick={onClose} style={{marginTop:12,padding:"7px 20px",borderRadius:8,border:"none",background:"#16a34a",color:"#fff",fontWeight:700,cursor:"pointer",fontSize:12}}>
        Cerrar
      </button>
    </div>
  );

  return(
    <div style={{background:"#f8fafc",borderRadius:10,padding:14,border:"1px solid #e2e8f0",margin:"8px 0"}}>
      <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:10}}>
        <div style={{color:"#0f172a",fontWeight:700,fontSize:13}}>🧾 Solicitar factura CFDI</div>
        <button onClick={onClose} style={{background:"none",border:"none",color:"#94a3b8",cursor:"pointer",fontSize:18,lineHeight:1}}>✕</button>
      </div>
      <div style={{color:"#64748b",fontSize:11,marginBottom:10,lineHeight:1.5}}>
        Completa los datos fiscales para generar tu factura.<br/>
        Estado inicial: <strong style={{color:"#f59e0b"}}>PENDIENTE</strong>
      </div>
      <input style={inpS} value={rfc} onChange={e=>setRfc(e.target.value.toUpperCase())}
        placeholder="RFC * (ej: XAXX010101000 o PEJJ800101XXX)"/>
      <input style={inpS} value={nombre} onChange={e=>setNombre(e.target.value)}
        placeholder="Nombre o Razón Social *"/>
      <input style={{...inpS}} type="email" value={email} onChange={e=>setEmail(e.target.value)}
        placeholder="Correo electrónico"/>
      <select style={inpS} value={uso} onChange={e=>setUso(e.target.value)}>
        {USO_CFDI.map(u=><option key={u.val} value={u.val}>{u.label}</option>)}
      </select>
      {err&&<div style={{color:"#ef4444",fontSize:11,marginBottom:8,padding:"4px 8px",background:"#fee2e2",borderRadius:6}}>{err}</div>}
      <div style={{background:"#fef3c7",borderRadius:6,padding:"6px 10px",marginBottom:10,fontSize:10,color:"#92400e"}}>
        ⚠️ Modo preparación — Se activará con PAC (Facturama) al lanzamiento oficial
      </div>
      <button onClick={solicitar} disabled={saving} style={{
        width:"100%",padding:"10px",borderRadius:8,border:"none",
        background:"linear-gradient(135deg,#0D1B2A,#1E3ABA)",
        color:"#fff",fontWeight:700,fontSize:13,cursor:"pointer",
        opacity:saving?0.6:1,
      }}>
        {saving?"Guardando…":"📤 Solicitar factura — Estado: PENDIENTE"}
      </button>
    </div>
  );
}

export default function TicketPreviewModal({
  open, venta={}, productos=[], cliente=null,
  metodoPago="Efectivo", config={},
  promoMsg=null,
  onClose, onNuevaVenta
}) {
  const ticketRef = useRef(null);
  const [showFactura, setShowFactura] = React.useState(false);
  useEffect(() => {
    if (!open) return undefined;
    const prev = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return () => {
      document.body.style.overflow = prev || "auto";
    };
  }, [open]);

  // Auto-imprimir al abrir
  React.useEffect(() => { if(open) setTimeout(()=>printTicket("farmacapital-ticket"), 800); }, [open]);

  if (!open) return null;

  const handlePrint = () => printTicket("farmacapital-ticket");

  const handleWhatsApp = () => {
    const tel = cliente?.telefono || prompt("📱 Teléfono del cliente (10 dígitos):");
    if (!tel) return;
    const items = productos.map(p =>
      `• ${p.nombre} ×${p.qty||1} = $${(parseFloat(p.precio||0)*(p.qty||1)).toFixed(2)}`
    ).join("\n");
    const msg = `🏥 *${config?.nombre_farmacia||"FarmaCapital"}*\n${config?.direccion_farmacia||"Chinampac de Juárez, CDMX"}\n🗺 ${FARMACIA_MAPS_URL}\n\n*Ticket #${venta.id}*\n\n${items}\n\n💰 *Total: $${parseFloat(venta.total||0).toFixed(2)}*\n💳 ${metodoPago}\n\n¡Gracias por su preferencia! 💊`;
    window.open("https://wa.me/52" + tel.replace(/\D/g,"") + "?text=" + encodeURIComponent(msg), "_blank");
  };

  return (
    <div style={{
      position:"fixed", inset:0, zIndex:9000,
      background:"rgba(15,23,42,.6)",
      backdropFilter:"blur(4px)",
      display:"flex", alignItems:"center", justifyContent:"center",
      padding:"max(12px, env(safe-area-inset-top, 0px)) max(12px, env(safe-area-inset-right, 0px)) max(12px, env(safe-area-inset-bottom, 0px)) max(12px, env(safe-area-inset-left, 0px))",
      boxSizing:"border-box",
    }} onClick={e=>e.target===e.currentTarget&&onClose?.()}>
      <div style={{
        background:"#fff", borderRadius:16,
        width:"min(420px, 100%)", maxHeight:"min(92dvh, 95vh)",
        overflowY:"auto",
        WebkitOverflowScrolling:"touch",
        boxShadow:"0 24px 80px rgba(15,45,110,.2)",
        display:"flex", flexDirection:"column",
        minWidth:0,
      }}>
        {/* Header del modal */}
        <div style={{
          padding:"16px 20px",
          borderBottom:"1px solid #e2e8f0",
          display:"flex", justifyContent:"space-between", alignItems:"center",
          background:"linear-gradient(135deg,#0D1B2A,#1E3ABA)",
          borderRadius:"16px 16px 0 0",
        }}>
          <div style={{color:"#fff", fontWeight:800, fontSize:16}}>
            ✅ Venta registrada — Ticket #{venta.id||"—"}
          </div>
          <button onClick={onClose} style={{
            background:"rgba(255,255,255,.2)", border:"none",
            color:"#fff", width:28, height:28, borderRadius:"50%",
            cursor:"pointer", fontSize:16, display:"flex",
            alignItems:"center", justifyContent:"center",
          }}>✕</button>
        </div>

        {/* Preview del ticket */}
        <div style={{
          padding:16,
          background:"#f8fafc",
          display:"flex", justifyContent:"center",
          borderBottom:"1px solid #e2e8f0",
          overflowY:"visible",
          maxHeight:"55vh",
        }}>
          <div style={{
            background:"#fff",
            boxShadow:"0 2px 12px rgba(0,0,0,.1)",
            borderRadius:4,
            padding:4,
          }}>
            <TicketVenta
              ref={ticketRef}
              venta={venta}
              productos={productos}
              cliente={cliente}
              metodoPago={metodoPago}
              config={config}
              promoMsg={promoMsg}
            />
          </div>
        </div>

        {/* Acciones */}
        <div style={{padding:16, display:"flex", flexDirection:"column", gap:10}}>
          {/* Imprimir */}
          {/* Imprimir directo ESC/POS si QZ Tray está disponible */}
          {typeof window.qz !== "undefined" ? (
            <button onClick={async()=>{
              try{
                const{imprimirESCPOS}=await import("../../utils/escpos");
                await imprimirESCPOS({venta,productos,cliente,metodoPago,config});
              }catch(e){ alert("Error ESC/POS: "+e.message); handlePrint(); }
            }} style={{
              padding:"12px", borderRadius:10, border:"none",
              background:"linear-gradient(135deg,#0D1B2A,#1E3ABA)",
              color:"#fff", fontWeight:800, fontSize:15,
              cursor:"pointer", display:"flex",
              alignItems:"center", justifyContent:"center", gap:8,
            }}>
              ⚡ Imprimir directo (QZ Tray)
            </button>
          ) : (
            <button onClick={handlePrint} style={{
              padding:"12px", borderRadius:10, border:"none",
              background:"linear-gradient(135deg,#0D1B2A,#1E3ABA)",
              color:"#fff", fontWeight:800, fontSize:15,
              cursor:"pointer", display:"flex",
              alignItems:"center", justifyContent:"center", gap:8,
            }}>
              🖨️ Imprimir ticket (Epson TM-T20III)
            </button>
          )}

          {/* Solicitar factura */}
          <button onClick={()=>setShowFactura(true)} style={{
            padding:"10px", borderRadius:10,
            border:"1px solid #0D1B2A",
            background:"#eff6ff", color:"#0D1B2A",
            fontWeight:700, fontSize:13, cursor:"pointer",
            display:"flex", alignItems:"center", justifyContent:"center", gap:8,
          }}>
            🧾 Solicitar factura CFDI
          </button>

          {/* Descargar PDF */}
          <button onClick={()=>downloadFacturaPDF({
            venta, productos, cliente, config, metodoPago
          })} style={{
            padding:"10px", borderRadius:10,
            border:"1px solid #7c3aed",
            background:"#ede9fe", color:"#7c3aed",
            fontWeight:700, fontSize:13, cursor:"pointer",
            display:"flex", alignItems:"center", justifyContent:"center", gap:8,
          }}>
            📄 Descargar PDF
          </button>

          {/* WhatsApp */}
          <button onClick={handleWhatsApp} style={{
            padding:"10px", borderRadius:10,
            border:"1px solid #25D366",
            background:"#dcfce7", color:"#16a34a",
            fontWeight:700, fontSize:13, cursor:"pointer",
            display:"flex", alignItems:"center", justifyContent:"center", gap:8,
          }}>
            📱 Enviar por WhatsApp
          </button>

          <div style={{display:"flex", gap:8, flexWrap:"wrap"}}>
            {/* Reimprimir después */}
            <button type="button" onClick={handlePrint} style={{
              flex:"1 1 120px", minHeight:44, padding:"10px", borderRadius:10,
              border:"1px solid #e2e8f0", background:"#f8fafc",
              color:"#475569", fontWeight:700, fontSize:13, cursor:"pointer",
            }}>
              🔄 Reimprimir
            </button>

            {/* Nueva venta */}
            <button type="button" onClick={onNuevaVenta||onClose} style={{
              flex:"2 1 160px", minHeight:44, padding:"10px", borderRadius:10, border:"none",
              background:"#16a34a", color:"#fff",
              fontWeight:800, fontSize:14, cursor:"pointer",
            }}>
              ✅ Nueva venta
            </button>
          </div>

          {/* Mini form de factura */}
          {showFactura&&(
            <FacturaInlineForm
              venta={venta}
              cliente={cliente}
              onClose={()=>setShowFactura(false)}
            />
          )}

          {/* Info impresora Epson TM-T20III */}
          <details style={{marginTop:4}}>
            <summary style={{
              fontSize:11, color:"#1d4ed8", cursor:"pointer",
              background:"#eff6ff", padding:"6px 10px",
              borderRadius:8, listStyle:"none", userSelect:"none",
            }}>
              🖨️ Guía de configuración Epson TM-T20III
            </summary>
            <div style={{
              background:"#f8fafc", border:"1px solid #e2e8f0",
              borderRadius:"0 0 8px 8px", padding:"10px 12px",
              fontSize:10, color:"#475569", lineHeight:1.7,
            }}>
              <div style={{fontWeight:700,color:"#0f172a",marginBottom:4}}>Pasos para imprimir correctamente:</div>
              <div>1️⃣ Click en "Imprimir ticket"</div>
              <div>2️⃣ En "Impresora" selecciona <strong>Epson TM-T20III</strong></div>
              <div>3️⃣ En "Más configuraciones" → Tamaño de papel: <strong>Roll Paper 80x297mm</strong></div>
              <div>4️⃣ Márgenes: <strong>Sin márgenes (None)</strong></div>
              <div>5️⃣ Escala: <strong>100%</strong></div>
              <div>6️⃣ Click en <strong>Imprimir</strong></div>
              <div style={{marginTop:6,padding:"4px 8px",background:"#fef3c7",borderRadius:4,color:"#92400e"}}>
                ⚠️ Si el ticket se ve cortado, reduce la escala a 90%
              </div>
            </div>
          </details>
        </div>
      </div>
    </div>
  );
}
