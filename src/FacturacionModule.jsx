import { useState, useEffect, useCallback } from "react";
import { Plus, Receipt } from "lucide-react";
import { C_LIGHT } from "./constants";
import { SegmentedNav } from "./components/SegmentedNav";
import { PageHero } from "./components/AdminChrome";
import { supabase } from "./supabase";
import { downloadFacturaPDF } from "./utils/generateFacturaPDF";

const BRAND = { primary:"#0D1B2A", secondary:"#1E3ABA", gradient:"linear-gradient(135deg,#0D1B2A,#1E3ABA)" };
const fmt = n => `$${parseFloat(n||0).toLocaleString("es-MX",{minimumFractionDigits:2,maximumFractionDigits:2})}`;
const fmtDT = s => { if(!s)return"—"; const d=new Date(s); return d.toLocaleDateString("es-MX",{day:"2-digit",month:"short",year:"numeric"}); };

const mkInpS = (C) => ({ width:"100%", boxSizing:"border-box", padding:"9px 12px", borderRadius:8, border:`1px solid ${C.border}`, background:C.card, color:C.text, fontSize:13, outline:"none" });
const mkLabelS = (C) => ({ color:C.textMid, fontSize:11, fontWeight:700, display:"block", marginBottom:4 });
const mkBtnPrimary = (C) => ({ padding:"9px 20px", borderRadius:8, border:"none", background:BRAND.gradient, color:"#fff", fontWeight:700, fontSize:13, cursor:"pointer" });
const mkBtnOutline = (C) => ({ padding:"9px 20px", borderRadius:8, border:`1px solid ${C.border}`, background:"transparent", color:C.textMid, fontWeight:700, fontSize:13, cursor:"pointer" });

// ── Config PAC — SW Sapien (pay-per-CFDI, sin mensualidad) ────
// Variables de entorno en Vercel:
//   SW_USER, SW_PASSWORD, SW_SANDBOX (true/false)
//   RFC_EMISOR, NOMBRE_EMISOR, REGIMEN_EMISOR, CP_EXPEDICION
//
// Pasos para activar:
//   1. Crea cuenta gratis en https://sw.com.mx (sandbox sin costo)
//   2. Agrega las variables de entorno en Vercel → Settings → Env Vars
//   3. Cambia modo a "sw_sapien" abajo
//   4. Para producción: registra tu CSD (.cer/.key) en panel SW Sapien
const PAC_CONFIG = {
  modo: "sw_sapien", // "simulado" | "sw_sapien"
  endpoint: "/api/cfdi/timbrar",
};

const USO_CFDI = [
  {val:"G01", label:"G01 — Adquisición de mercancias"},
  {val:"G03", label:"G03 — Gastos en general"},
  {val:"D01", label:"D01 — Honorarios médicos y dentales"},
  {val:"S01", label:"S01 — Sin efectos fiscales"},
  {val:"CP01", label:"CP01 — Pagos"},
];

const REGIMEN_FISCAL = [
  {val:"601", label:"601 — General de Ley Personas Morales"},
  {val:"603", label:"603 — Personas Morales con Fines no Lucrativos"},
  {val:"612", label:"612 — Personas Físicas con Actividades Empresariales"},
  {val:"616", label:"616 — Sin obligaciones fiscales"},
  {val:"621", label:"621 — Incorporación Fiscal"},
  {val:"625", label:"625 — Régimen de las Actividades Empresariales (RIF)"},
  {val:"626", label:"626 — Régimen Simplificado de Confianza (RESICO)"},
];

// ── Modal Solicitar Factura ───────────────────────────────────
function SolicitarFacturaModal({pedido, onClose, onSaved }) {
  const C = C_LIGHT;
  const labelS = mkLabelS(C);
  const inpS = mkInpS(C);
  const btnPrimary = mkBtnPrimary(C);
  const btnOutline = mkBtnOutline(C);
  const [rfc,          setRfc]    = useState(pedido?.clientes?.rfc||"");
  const [razon,        setRazon]  = useState(pedido?.clientes?.razon_social||"");
  const [usoCfdi,      setUso]    = useState("G03");
  const [regimen,      setReg]    = useState("616");
  const [email,        setEmail]  = useState(pedido?.clientes?.email||"");
  const [cpReceptor,   setCp]     = useState("");
  const [saving,       setSaving] = useState(false);
  const [error,        setError]  = useState("");
  const [success,      setSuccess]= useState(false);
  const [folioFiscal,  setFolioFiscal] = useState("");

  const validarRFC = (r) => /^[A-ZÑ&]{3,4}\d{6}[A-Z0-9]{3}$/i.test(r.trim());

  const timbrar = async () => {
    if (!rfc.trim()) { setError("El RFC es requerido."); return; }
    if (!validarRFC(rfc)) { setError("El RFC no tiene un formato válido."); return; }
    if (!razon.trim()) { setError("La razón social es requerida."); return; }
    setSaving(true); setError("");

    try {
      const tok = sessionStorage.getItem("farmacapital_session_token");
      if (!tok) throw new Error("Sesión expirada. Inicia sesión de nuevo.");

      if (PAC_CONFIG.modo === "simulado") {
        // ── Modo prueba local (sin PAC real) ─────────────────
        await new Promise(r => setTimeout(r, 1200));
        const { data: resp, error: rpcErr } = await supabase.rpc("crear_factura", {
          p_session_token:  tok,
          p_pedido_id:      pedido.id,
          p_rfc:            rfc.trim().toUpperCase(),
          p_razon_social:   razon.trim().toUpperCase(),
          p_uso_cfdi:       usoCfdi,
          p_regimen_fiscal: regimen,
          p_folio_fiscal:   "SIM-" + Date.now(),
          p_pac_proveedor:  "simulado",
          p_email:          email || null,
        });
        if (rpcErr) throw rpcErr;
        if (!resp?.success) throw new Error(resp?.error || "No se pudo guardar la factura");
        setSuccess(true);

      } else if (PAC_CONFIG.modo === "sw_sapien") {
        // ── Modo real: timbrado vía SW Sapien ─────────────────
        const res = await fetch(PAC_CONFIG.endpoint, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            session_token:    tok,
            pedido_id:        pedido.id,
            rfc_receptor:     rfc.trim().toUpperCase(),
            nombre_receptor:  razon.trim().toUpperCase(),
            uso_cfdi:         usoCfdi,
            regimen_receptor: regimen,
            cp_receptor:      cpReceptor || "",
            email_receptor:   email || null,
          }),
        });
        const data = await res.json();
        if (!res.ok || !data?.ok) {
          throw new Error(data?.error || `Error del servidor (${res.status})`);
        }
        setFolioFiscal(data.uuid);
        setSuccess(true);

      } else {
        throw new Error("PAC_CONFIG.modo no reconocido: " + PAC_CONFIG.modo);
      }
    } catch (e) {
      setError("Error al timbrar: " + e.message);
    }
    setSaving(false);
  };

  if (success) return (
    <div style={{position:"fixed",inset:0,background:"rgba(15,23,42,.45)",backdropFilter:"blur(4px)",zIndex:500,display:"flex",alignItems:"center",justifyContent:"center",padding:20}}>
      <div style={{background:C.card,borderRadius:14,width:"min(480px,95vw)",padding:32,textAlign:"center",boxShadow:"0 20px 60px rgba(0,82,204,.15)"}}>
        <div style={{fontSize:56,marginBottom:16}}>{PAC_CONFIG.modo==="simulado"?"🧪":"✅"}</div>
        <h3 style={{color:C.text,fontSize:18,fontWeight:800,marginBottom:8}}>
          {PAC_CONFIG.modo==="simulado" ? "Factura registrada (modo prueba)" : "¡CFDI timbrado correctamente!"}
        </h3>
        {PAC_CONFIG.modo==="simulado" ? (
          <div style={{background:C.amberDim,border:`1px solid ${C.amber}30`,borderRadius:8,padding:"10px 14px",marginBottom:16,fontSize:12,color:"#92400e"}}>
            ⚠️ Modo simulado — el CFDI <strong>no es válido ante el SAT</strong>. Configura las variables SW_USER/SW_PASSWORD en Vercel para activar el timbrado real.
          </div>
        ) : (
          <div style={{background:C.greenDim,border:`1px solid ${C.green}30`,borderRadius:8,padding:"10px 14px",marginBottom:16,fontSize:12,color:"#15803d",wordBreak:"break-all"}}>
            <div style={{fontWeight:700,marginBottom:4}}>Folio Fiscal (UUID SAT):</div>
            <div style={{fontFamily:"monospace",fontSize:11}}>{folioFiscal}</div>
          </div>
        )}
        <p style={{color:C.textMid,fontSize:14,marginBottom:24}}>RFC: <strong>{rfc.toUpperCase()}</strong> · Total: <strong>{fmt(pedido.total)}</strong></p>
        <button style={btnPrimary} onClick={()=>{onSaved();onClose();}}>Cerrar</button>
      </div>
    </div>
  );

  return (
    <div style={{position:"fixed",inset:0,background:"rgba(15,23,42,.45)",backdropFilter:"blur(4px)",zIndex:500,display:"flex",alignItems:"center",justifyContent:"center",padding:20}}
      onClick={e=>e.target===e.currentTarget&&onClose()}>
      <div style={{background:C.card,borderRadius:14,width:"min(520px,95vw)",maxHeight:"90vh",overflowY:"auto",padding:28,boxShadow:"0 20px 60px rgba(0,82,204,.15)"}}>
        <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:20}}>
          <h3 style={{margin:0,color:C.text,fontSize:16,fontWeight:800}}>🧾 Solicitar factura CFDI</h3>
          <button onClick={onClose} style={{background:"none",border:"none",color:C.textMid,fontSize:22,cursor:"pointer"}}>✕</button>
        </div>

        {PAC_CONFIG.modo==="simulado" ? (
          <div style={{background:C.amberDim,border:`1px solid ${C.amber}30`,borderRadius:8,padding:"10px 14px",marginBottom:16,fontSize:12,color:"#92400e"}}>
            ⚠️ <strong>Modo prueba:</strong> Las facturas no se timbran con el SAT. Configura <strong>SW_USER</strong> y <strong>SW_PASSWORD</strong> en Vercel para timbrado real.
          </div>
        ) : (
          <div style={{background:C.greenDim,border:`1px solid ${C.green}30`,borderRadius:8,padding:"8px 12px",marginBottom:16,fontSize:11,color:"#15803d"}}>
            ✅ <strong>Timbrado real activo (SW Sapien)</strong> — El CFDI se enviará al SAT.
          </div>
        )}

        <div style={{background:C.cardDark,borderRadius:8,padding:"10px 14px",marginBottom:16,fontSize:12}}>
          <strong>Pedido #{pedido.id}</strong> · {fmtDT(pedido.created_at)} · <strong style={{color:C.green}}>{fmt(pedido.total)}</strong>
        </div>

        <div style={{display:"grid",gridTemplateColumns:"1fr 1fr",gap:12,marginBottom:12}}>
          <div style={{gridColumn:"1/-1"}}>
            <label style={labelS}>RFC *</label>
            <input style={{...inpS,textTransform:"uppercase"}} value={rfc} onChange={e=>setRfc(e.target.value.toUpperCase())} placeholder="XAXX010101000"/>
            {rfc&&!validarRFC(rfc)&&<div style={{color:C.red,fontSize:10,marginTop:2}}>Formato inválido</div>}
          </div>
          <div style={{gridColumn:"1/-1"}}>
            <label style={labelS}>RAZÓN SOCIAL *</label>
            <input style={{...inpS,textTransform:"uppercase"}} value={razon} onChange={e=>setRazon(e.target.value.toUpperCase())} placeholder="NOMBRE O EMPRESA SA DE CV"/>
          </div>
          <div>
            <label style={labelS}>USO CFDI</label>
            <select style={inpS} value={usoCfdi} onChange={e=>setUso(e.target.value)}>
              {USO_CFDI.map(u=><option key={u.val} value={u.val}>{u.label}</option>)}
            </select>
          </div>
          <div>
            <label style={labelS}>RÉGIMEN FISCAL</label>
            <select style={inpS} value={regimen} onChange={e=>setReg(e.target.value)}>
              {REGIMEN_FISCAL.map(r=><option key={r.val} value={r.val}>{r.label}</option>)}
            </select>
          </div>
          <div>
            <label style={labelS}>C.P. RECEPTOR {PAC_CONFIG.modo==="sw_sapien"&&<span style={{color:"#ef4444"}}>*</span>}</label>
            <input style={inpS} value={cpReceptor} onChange={e=>setCp(e.target.value.replace(/\D/g,"").slice(0,5))} placeholder="09208" maxLength={5} inputMode="numeric"/>
            <div style={{color:C_LIGHT.textDim,fontSize:9,marginTop:2}}>C.P. del domicilio fiscal del receptor (requerido SAT)</div>
          </div>
          <div style={{gridColumn:"1/-1"}}>
            <label style={labelS}>EMAIL (para enviar factura)</label>
            <input style={inpS} type="email" value={email} onChange={e=>setEmail(e.target.value)} placeholder="cliente@empresa.com"/>
          </div>
        </div>

        {error&&<div style={{background:C.redDim,borderRadius:8,padding:"10px 12px",marginBottom:12,color:C.red,fontSize:13}}>{error}</div>}

        <div style={{display:"flex",gap:10,justifyContent:"flex-end"}}>
          <button style={btnOutline} onClick={onClose}>Cancelar</button>
          <button style={btnPrimary} onClick={timbrar} disabled={saving}>
            {saving?"Procesando…":"🧾 Generar CFDI"}
          </button>
        </div>
      </div>
    </div>
  );
}

// ── Módulo principal ──────────────────────────────────────────
export default function FacturacionModule() {
  const C = C_LIGHT;
  const inpS = mkInpS(C);
  const labelS = mkLabelS(C);
  const btnPrimary = mkBtnPrimary(C);
  const btnOutline = mkBtnOutline(C);
  const [facturas,  setFacturas] = useState([]);
  const [loading,   setLoading]  = useState(true);
  const [modal,     setModal]    = useState(null);
  const [pedidos,   setPedidos]  = useState([]);
  const [busqPed,   setBusqPed]  = useState("");
  const [loadPed,   setLoadPed]  = useState(false);
  const [tab,       setTab]      = useState("facturas");

  const fetchFacturas = useCallback(async () => {
    setLoading(true);
    const tok = sessionStorage.getItem("farmacapital_session_token");
    const { data } = tok
      ? await supabase.rpc("empleado_listar_facturas", { p_session_token: tok, p_limite: 100 })
      : { data: [] };
    setFacturas(Array.isArray(data) ? data : []);
    setLoading(false);
  },[]);

  useEffect(()=>{ fetchFacturas(); },[fetchFacturas]);

  const buscarPedidos = async () => {
    if (!busqPed) return;
    setLoadPed(true);
    const tok = sessionStorage.getItem("farmacapital_session_token");
    const { data } = tok
      ? await supabase.rpc("empleado_buscar_pedidos_facturacion", {
          p_session_token: tok,
          p_busqueda: String(busqPed).trim(),
          p_limite: 10,
        })
      : { data: [] };
    setPedidos(Array.isArray(data) ? data : []);
    setLoadPed(false);
  };

  const estCol = e => e==="timbrada"?C.green:e==="cancelada"?C.red:e==="error"?C.red:C.amber;

  const totalTimbradas = facturas.filter(f=>f.estado==="timbrada"||f.estado==="pendiente").reduce((a,f)=>a+parseFloat(f.total||0),0);

  return (
    <div>
      <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:20}}>
        <PageHero Icon={Receipt}>Facturación CFDI</PageHero>
        {PAC_CONFIG.modo==="simulado"&&(
          <span style={{padding:"4px 12px",borderRadius:20,fontSize:11,fontWeight:700,background:C.amberDim,color:"#92400e"}}>
            ⚠️ Modo prueba — Sin PAC real
          </span>
        )}
      </div>

      {/* Aviso de configuración */}
      <div style={{background:"#eff6ff",border:"1px solid #bfdbfe",borderRadius:12,padding:16,marginBottom:20}}>
        <div style={{color:BRAND.primary,fontWeight:700,fontSize:13,marginBottom:8}}>📋 Para activar facturación real necesitas:</div>
        <div style={{display:"grid",gridTemplateColumns:"1fr 1fr",gap:8,fontSize:12,color:C.textMid}}>
          {[
            ["1️⃣","Contratar un PAC autorizado SAT","Facturama (~$299/mes) · SW Sapien · Edicom"],
            ["2️⃣","Tener tu CSD (Certificado de Sello Digital)","Trámite gratuito en sat.gob.mx"],
            ["3️⃣","Configurar credenciales en PAC_CONFIG","En src/FacturacionModule.jsx línea ~20"],
            ["4️⃣","Cambiar modo a 'facturama'","PAC_CONFIG.modo = 'facturama'"],
          ].map(([n,t,s])=>(
            <div key={n} style={{background:C.card,borderRadius:8,padding:"10px 12px",border:"1px solid #bfdbfe"}}>
              <div style={{fontWeight:700,color:C.text,marginBottom:2}}>{n} {t}</div>
              <div style={{color:C.textDim,fontSize:11}}>{s}</div>
            </div>
          ))}
        </div>
      </div>

      {/* KPIs */}
      <div style={{display:"flex",gap:12,marginBottom:20,flexWrap:"wrap"}}>
        {[
          {label:"Total facturado",value:fmt(totalTimbradas),col:C.green},
          {label:"Facturas emitidas",value:facturas.length,col:C.blue},
          {label:"Pendientes",value:facturas.filter(f=>f.estado==="pendiente").length,col:C.amber},
          {label:"Este mes",value:facturas.filter(f=>new Date(f.created_at)>=new Date(new Date().getFullYear(),new Date().getMonth(),1)).length,col:C.purple},
        ].map(k=>(
          <div key={k.label} style={{background:C.card,border:`1px solid ${C.border}`,borderRadius:12,padding:"14px 20px",flex:1,minWidth:120}}>
            <div style={{color:C.textDim,fontSize:10,fontWeight:700}}>{k.label.toUpperCase()}</div>
            <div style={{color:k.col,fontWeight:900,fontSize:22,marginTop:4}}>{k.value}</div>
          </div>
        ))}
      </div>

      {/* Tabs */}
      <div style={{ marginBottom: 20 }}>
        <SegmentedNav
          size="md"
          activation="auto"
          ariaLabel="Secciones de facturación"
          value={tab}
          onChange={setTab}
          items={[
            { id: "facturas", label: "Facturas emitidas", Icon: Receipt },
            { id: "nueva", label: "Nueva factura", Icon: Plus },
          ]}
        />
      </div>

      {/* Tab: Facturas */}
      {tab==="facturas"&&(
        loading?<div style={{color:C.textMid,textAlign:"center",padding:40}}>Cargando…</div>:(
          <div style={{overflowX:"auto",borderRadius:12,border:`1px solid ${C.border}`}}>
            <table className="fc-tabla-cards" style={{width:"100%",borderCollapse:"collapse",fontSize:12}}>
              <thead>
                <tr style={{background:C.cardDark}}>
                  {["ID","Fecha","RFC","Razón social","Pedido","Total","PAC","Estado","Acciones"].map(h=>(
                    <th key={h} style={{padding:"9px 12px",textAlign:"left",color:C.textMid,fontWeight:700,borderBottom:`1px solid ${C.border}`,whiteSpace:"nowrap"}}>{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {!facturas.length&&<tr><td colSpan={9} style={{textAlign:"center",padding:32,color:C.textMid}}>Sin facturas emitidas</td></tr>}
                {facturas.map((f,i)=>(
                  <tr key={f.id} style={{background:i%2===0?"transparent":"#f8fafc"}}>
                    <td data-label="ID" data-primary style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`,fontFamily:"monospace"}}>#{f.id}</td>
                    <td data-label="Fecha" style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`,whiteSpace:"nowrap"}}>{fmtDT(f.created_at)}</td>
                    <td data-label="RFC" style={{padding:"8px 12px",color:C.text,fontWeight:700,borderBottom:`1px solid ${C.border}`,fontFamily:"monospace"}}>{f.rfc}</td>
                    <td data-label="Razón social" data-wide style={{padding:"8px 12px",color:C.text,borderBottom:`1px solid ${C.border}`,maxWidth:180}}>{f.razon_social}</td>
                    <td data-label="Pedido" style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>#{f.pedido_id||"—"}</td>
                    <td data-label="Total" style={{padding:"8px 12px",color:C.green,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{fmt(f.total)}</td>
                    <td data-label="PAC" style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{f.pac_proveedor||"—"}</td>
                    <td data-label="Estado" style={{padding:"8px 12px",borderBottom:`1px solid ${C.border}`}}>
                      <span style={{padding:"2px 8px",borderRadius:20,fontSize:10,fontWeight:700,background:estCol(f.estado)+"20",color:estCol(f.estado)}}>{f.estado}</span>
                    </td>
                    <td data-label="Acciones" data-actions style={{padding:"8px 12px",borderBottom:`1px solid ${C.border}`,whiteSpace:"nowrap"}}>
                      {f.xml_url&&<a href={f.xml_url} target="_blank" rel="noreferrer" style={{padding:"3px 8px",borderRadius:5,border:`1px solid ${C.blue}30`,background:"#eff6ff",color:C.blue,fontSize:10,fontWeight:700,marginRight:4,textDecoration:"none"}}>XML</a>}
                      {f.pdf_url&&<a href={f.pdf_url} target="_blank" rel="noreferrer" style={{padding:"3px 8px",borderRadius:5,border:`1px solid ${C.green}30`,background:C.greenDim,color:C.green,fontSize:10,fontWeight:700,textDecoration:"none"}}>PDF</a>}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )
      )}

      {/* Tab: Nueva factura */}
      {tab==="nueva"&&(
        <div>
          <div style={{marginBottom:16}}>
            <label style={labelS}>BUSCAR PEDIDO (por ID o teléfono del cliente)</label>
            <div style={{display:"flex",gap:8}}>
              <input style={{...inpS,flex:1}} value={busqPed} onChange={e=>setBusqPed(e.target.value)}
                onKeyDown={e=>e.key==="Enter"&&buscarPedidos()}
                placeholder="Ej: 123 o 5537275035"/>
              <button style={btnPrimary} onClick={buscarPedidos}>{loadPed?"Buscando…":"Buscar"}</button>
            </div>
          </div>
          {pedidos.length>0&&(
            <div style={{display:"flex",flexDirection:"column",gap:8}}>
              {pedidos.map(p=>(
                <div key={p.id} style={{padding:14,borderRadius:10,border:`1px solid ${C.border}`,background:C.cardDark,display:"flex",justifyContent:"space-between",alignItems:"center",flexWrap:"wrap",gap:10}}>
                  <div>
                    <div style={{fontWeight:700,color:C.text}}>Pedido #{p.id} · {fmtDT(p.created_at)}</div>
                    <div style={{color:C.textMid,fontSize:12,marginTop:2}}>{p.clientes?.nombre||"Sin cliente"} · {fmt(p.total)}</div>
                    {p.clientes?.rfc&&<div style={{color:C.textDim,fontSize:11,marginTop:2}}>RFC previo: {p.clientes.rfc}</div>}
                  </div>
                  <button style={btnPrimary} onClick={()=>setModal(p)}>🧾 Facturar</button>
                </div>
              ))}
            </div>
          )}
          {pedidos.length===0&&busqPed&&!loadPed&&(
            <div style={{color:C.textMid,fontSize:13,textAlign:"center",padding:32,background:C.card,borderRadius:12,border:`1px solid ${C.border}`}}>
              Sin pedidos completados con ese criterio.
            </div>
          )}
        </div>
      )}

      {modal&&(
        <SolicitarFacturaModal
          pedido={modal}
          onClose={()=>setModal(null)}
          onSaved={()=>{ fetchFacturas(); setTab("facturas"); }}
        />
      )}
    </div>
  );
}
