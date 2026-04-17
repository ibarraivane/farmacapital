import { useState, useEffect, useCallback } from "react";
import { C_LIGHT, C_DARK } from "./constants";
import { useTheme } from "./themeContext";
import { supabase } from "./supabase";
import { downloadFacturaPDF } from "./utils/generateFacturaPDF";

const BRAND = { primary:"#0052cc", secondary:"#0099e6", gradient:"linear-gradient(135deg,#0052cc,#0099e6)" };
const fmt = n => `$${parseFloat(n||0).toLocaleString("es-MX",{minimumFractionDigits:2,maximumFractionDigits:2})}`;
const fmtDT = s => { if(!s)return"—"; const d=new Date(s); return d.toLocaleDateString("es-MX",{day:"2-digit",month:"short",year:"numeric"}); };

const mkInpS = (C) => ({ width:"100%", boxSizing:"border-box", padding:"9px 12px", borderRadius:8, border:`1px solid ${C.border}`, background:C.card, color:C.text, fontSize:13, outline:"none" });
const mkLabelS = (C) => ({ color:C.textMid, fontSize:11, fontWeight:700, display:"block", marginBottom:4 });
const mkBtnPrimary = (C) => ({ padding:"9px 20px", borderRadius:8, border:"none", background:BRAND.gradient, color:"#fff", fontWeight:700, fontSize:13, cursor:"pointer" });
const mkBtnOutline = (C) => ({ padding:"9px 20px", borderRadius:8, border:`1px solid ${C.border}`, background:"transparent", color:C.textMid, fontWeight:700, fontSize:13, cursor:"pointer" });

// ── Config PAC (activar cuando se contrate) ───────────────────
const PAC_CONFIG = {
  // MODO: "simulado" = sin PAC real | "facturama" = PAC real
  modo: "simulado",
  // Cuando tengas Facturama:
  // usuario: "TU_USUARIO_FACTURAMA",
  // password: "TU_PASSWORD_FACTURAMA",
  // url: "https://www.api.facturama.com.mx",
  // url_sandbox: "https://apisandbox.facturama.com.mx",
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
  const C = useTheme();
  const labelS = mkLabelS(C);
  const inpS = mkInpS(C);
  const btnPrimary = mkBtnPrimary(C);
  const btnOutline = mkBtnOutline(C);
  const [rfc,          setRfc]    = useState(pedido?.clientes?.rfc||"");
  const [razon,        setRazon]  = useState(pedido?.clientes?.razon_social||"");
  const [usoCfdi,      setUso]    = useState("G03");
  const [regimen,      setReg]    = useState("616");
  const [email,        setEmail]  = useState(pedido?.clientes?.email||"");
  const [saving,       setSaving] = useState(false);
  const [error,        setError]  = useState("");
  const [success,      setSuccess]= useState(false);

  const validarRFC = (r) => /^[A-ZÑ&]{3,4}\d{6}[A-Z0-9]{3}$/i.test(r.trim());

  const timbrar = async () => {
    if (!rfc.trim()) { setError("El RFC es requerido."); return; }
    if (!validarRFC(rfc)) { setError("El RFC no tiene un formato válido."); return; }
    if (!razon.trim()) { setError("La razón social es requerida."); return; }
    setSaving(true); setError("");

    try {
      if (PAC_CONFIG.modo === "simulado") {
        // Modo simulado: guarda en BD sin timbrar realmente
        await new Promise(r=>setTimeout(r,1500)); // simula delay
        const folioSimulado = "SIM-"+Date.now();
        const { error: dbErr } = await supabase.from("facturas").insert({
          pedido_id: pedido.id,
          cliente_id: pedido.cliente_id||null,
          rfc: rfc.trim().toUpperCase(),
          razon_social: razon.trim().toUpperCase(),
          uso_cfdi: usoCfdi,
          regimen_fiscal: regimen,
          total: pedido.total,
          estado: "pendiente",
          folio_fiscal: folioSimulado,
          pac_proveedor: "simulado",
        });
        if (dbErr) throw dbErr;

        // Actualizar RFC en cliente si existe
        if (pedido.cliente_id) {
          await supabase.from("clientes").update({
            rfc: rfc.trim().toUpperCase(),
            razon_social: razon.trim().toUpperCase(),
            regimen_fiscal: regimen,
            uso_cfdi: usoCfdi,
          }).eq("id", pedido.cliente_id);
        }
        setSuccess(true);
      } else {
        // ── Modo real con Facturama ──────────────────────────
        // TODO: implementar cuando se tenga cuenta PAC
        // const resp = await fetch(`${PAC_CONFIG.url}/api/3/cfdis`, {
        //   method: "POST",
        //   headers: { "Authorization": "Basic "+btoa(PAC_CONFIG.usuario+":"+PAC_CONFIG.password), "Content-Type": "application/json" },
        //   body: JSON.stringify({ /* CFDI payload */ })
        // });
        setError("PAC no configurado. Activa el modo real en PAC_CONFIG.");
      }
    } catch(e) { setError("Error al timbrar: "+e.message); }
    setSaving(false);
  };

  if (success) return (
    <div style={{position:"fixed",inset:0,background:"rgba(15,23,42,.45)",backdropFilter:"blur(4px)",zIndex:500,display:"flex",alignItems:"center",justifyContent:"center",padding:20}}>
      <div style={{background:C.card,borderRadius:14,width:"min(480px,95vw)",padding:32,textAlign:"center",boxShadow:"0 20px 60px rgba(0,82,204,.15)"}}>
        <div style={{fontSize:56,marginBottom:16}}>✅</div>
        <h3 style={{color:C.text,fontSize:18,fontWeight:800,marginBottom:8}}>
          {PAC_CONFIG.modo==="simulado"?"Factura registrada (modo prueba)":"¡Factura timbrada!"}
        </h3>
        {PAC_CONFIG.modo==="simulado"&&(
          <div style={{background:C.amberDim,border:`1px solid ${C.amber}30`,borderRadius:8,padding:"10px 14px",marginBottom:16,fontSize:12,color:"#92400e"}}>
            ⚠️ Modo simulado activo. Cuando contrates un PAC (Facturama, SW Sapien, etc.), activa el modo real en <code>PAC_CONFIG</code>.
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

        {PAC_CONFIG.modo==="simulado"&&(
          <div style={{background:C.amberDim,border:`1px solid ${C.amber}30`,borderRadius:8,padding:"10px 14px",marginBottom:16,fontSize:12,color:"#92400e"}}>
            ⚠️ <strong>Modo prueba:</strong> Las facturas se guardan en BD pero no se timbran con el SAT. Activa el PAC real cuando lo contrates.
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
  const [facturas,  setFacturas] = useState([]);
  const [loading,   setLoading]  = useState(true);
  const [modal,     setModal]    = useState(null);
  const [pedidos,   setPedidos]  = useState([]);
  const [busqPed,   setBusqPed]  = useState("");
  const [loadPed,   setLoadPed]  = useState(false);
  const [tab,       setTab]      = useState("facturas");

  const fetchFacturas = useCallback(async () => {
    setLoading(true);
    const { data } = await supabase.from("facturas")
      .select("*, clientes(nombre,telefono)")
      .order("created_at",{ascending:false})
      .limit(100);
    setFacturas(data||[]);
    setLoading(false);
  },[]);

  useEffect(()=>{ fetchFacturas(); },[fetchFacturas]);

  const buscarPedidos = async () => {
    if (!busqPed) return;
    setLoadPed(true);
    const { data } = await supabase.from("pedidos")
      .select("*, clientes(nombre,telefono,rfc,razon_social,email)")
      .or(`id.eq.${isNaN(busqPed)?0:busqPed},clientes.telefono.eq.${busqPed}`)
      .eq("estado","completado")
      .order("created_at",{ascending:false})
      .limit(10);
    setPedidos(data||[]);
    setLoadPed(false);
  };

  const estCol = e => e==="timbrada"?C.green:e==="cancelada"?C.red:e==="error"?C.red:C.amber;

  const totalTimbradas = facturas.filter(f=>f.estado==="timbrada"||f.estado==="pendiente").reduce((a,f)=>a+parseFloat(f.total||0),0);

  return (
    <div>
      <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:20}}>
        <h1 style={{color:C.text,fontSize:20,fontWeight:800,margin:0}}>🧾 Facturación CFDI</h1>
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
      <div style={{display:"flex",gap:4,marginBottom:20,borderBottom:`1px solid ${C.border}`}}>
        {[["facturas","🧾 Facturas emitidas"],["nueva","➕ Nueva factura"]].map(([id,label])=>(
          <button key={id} onClick={()=>setTab(id)} style={{
            padding:"8px 18px",border:"none",cursor:"pointer",fontWeight:700,fontSize:12,
            borderRadius:"8px 8px 0 0",background:"transparent",
            color:tab===id?BRAND.primary:C.textMid,
            borderBottom:tab===id?`2px solid ${BRAND.primary}`:"2px solid transparent",
          }}>{label}</button>
        ))}
      </div>

      {/* Tab: Facturas */}
      {tab==="facturas"&&(
        loading?<div style={{color:C.textMid,textAlign:"center",padding:40}}>Cargando…</div>:(
          <div style={{overflowX:"auto",borderRadius:12,border:`1px solid ${C.border}`}}>
            <table style={{width:"100%",borderCollapse:"collapse",fontSize:12}}>
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
                    <td style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`,fontFamily:"monospace"}}>#{f.id}</td>
                    <td style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`,whiteSpace:"nowrap"}}>{fmtDT(f.created_at)}</td>
                    <td style={{padding:"8px 12px",color:C.text,fontWeight:700,borderBottom:`1px solid ${C.border}`,fontFamily:"monospace"}}>{f.rfc}</td>
                    <td style={{padding:"8px 12px",color:C.text,borderBottom:`1px solid ${C.border}`,maxWidth:180}}>{f.razon_social}</td>
                    <td style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>#{f.pedido_id||"—"}</td>
                    <td style={{padding:"8px 12px",color:C.green,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{fmt(f.total)}</td>
                    <td style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{f.pac_proveedor||"—"}</td>
                    <td style={{padding:"8px 12px",borderBottom:`1px solid ${C.border}`}}>
                      <span style={{padding:"2px 8px",borderRadius:20,fontSize:10,fontWeight:700,background:estCol(f.estado)+"20",color:estCol(f.estado)}}>{f.estado}</span>
                    </td>
                    <td style={{padding:"8px 12px",borderBottom:`1px solid ${C.border}`,whiteSpace:"nowrap"}}>
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
