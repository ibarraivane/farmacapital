import { useState, useEffect, useCallback } from "react";
import { useMediaQuery } from "../../hooks/useMediaQuery";
import { C_LIGHT } from "../../constants";
import { supabase } from "../../supabase";
import { showToast } from "../../ui";
import { fetchProductosConsumiblesConsultorio } from "../../utils/consumiblesConsultorio";
import { citaPagoOk, citaEstaPagada } from "../../utils/consultaConstants";
import OnboardingTour from "../../components/OnboardingTour";
import { Paciente } from "./Paciente";
import { Historial } from "./Historial";

const BRAND = { primary:"#0052cc", secondary:"#0099e6", gradient:"linear-gradient(135deg,#0052cc,#0099e6)" };

const fmt     = (n) => `$${parseFloat(n||0).toFixed(2)}`;
const fmtDate = (s) => s ? new Date(s).toLocaleDateString("es-MX",{day:"2-digit",month:"short",year:"numeric"}) : "—";
const horaVista = (h) => {
  const s = String(h ?? "").trim();
  if (!s) return "—";
  const m = s.match(/^(\d{1,2}):(\d{2})/);
  if (!m) return s;
  return `${String(parseInt(m[1], 10)).padStart(2, "0")}:${m[2]}`;
};
const todaySvLocal = () => new Date().toLocaleDateString("sv-SE");

const mkInputStyle = (C) => ({ width:"100%", padding:"8px 11px", borderRadius:7, border:`1px solid ${C.border}`, background:C.bg, color:C.text, fontSize:12, outline:"none", boxSizing:"border-box" });
const mkLabelStyle = (C) => ({ color:C.textMid, fontSize:10, fontWeight:700, marginBottom:3, display:"block", letterSpacing:.4 });
const mkBtnPrimary = (C) => ({ padding:"9px 18px", borderRadius:8, border:"none", cursor:"pointer", background:BRAND.gradient, color:"#fff", fontWeight:700, fontSize:12 });
const mkBtnSecondary = (C) => ({ padding:"8px 15px", borderRadius:8, cursor:"pointer", fontWeight:700, fontSize:12, border:`1px solid ${C.border}`, background:"transparent", color:C.textMid });
const mkBtnOutline = (C) => ({ padding:"8px 15px", borderRadius:8, cursor:"pointer", fontWeight:700, fontSize:12, border:`1px solid ${C.blue}`, background:"transparent", color:C.blue });
const mkBtnGreen = (C) => ({ padding:"9px 18px", borderRadius:8, border:"none", cursor:"pointer", background:C.green, color:"#fff", fontWeight:700, fontSize:12 });
const mkBtnSmBlue = (C) => ({ padding:"4px 10px", borderRadius:6, cursor:"pointer", background:C.blueDim, color:C.blue, fontWeight:700, fontSize:11, border:`1px solid ${C.blue}30` });
const mkBtnSmGreen = (C) => ({ padding:"4px 10px", borderRadius:6, cursor:"pointer", background:C.greenDim, color:C.green, fontWeight:700, fontSize:11, border:`1px solid ${C.green}30` });
const mkBtnSmRed = (C) => ({ padding:"4px 10px", borderRadius:6, cursor:"pointer", background:C.redDim, color:C.red, fontWeight:700, fontSize:11, border:`1px solid ${C.red}30` });

const DEFAULT_PROCEDIMIENTOS = [
  {nombre:"Toma de presión",precio:60},{nombre:"Glucometría",precio:80},
  {nombre:"Inyección IM",precio:120},{nombre:"Inyección IV",precio:180},
  {nombre:"Nebulización",precio:250},{nombre:"Curación simple",precio:200},
  {nombre:"Curación compleja",precio:380},{nombre:"Sutura simple (1-3 pts)",precio:500},
  {nombre:"Sutura compleja (4+ pts)",precio:750},{nombre:"Retiro de puntos",precio:150},
  {nombre:"Vendaje",precio:200},{nombre:"Lavado de oído",precio:180},
  {nombre:"Prueba de embarazo",precio:100},
];

function ProcedimientoModal({initial, onClose, onSaved }) {
  const C = C_LIGHT;
  const inputStyle = mkInputStyle(C);
  const labelStyle = mkLabelStyle(C);
  const btnSecondary = mkBtnSecondary(C);
  const btnPrimary = mkBtnPrimary(C);
  const btnGreen = mkBtnGreen(C);
  const empty = { nombre:"", precio:"", descripcion:"", activo:true };
  const [form, setForm] = useState(initial||empty);
  const [saving, setSaving] = useState(false);
  const set = (k,v) => setForm(f=>({...f,[k]:v}));
  const handleSave = async () => {
    if (!form.nombre.trim()||!form.precio) { showToast("Nombre y precio son requeridos.", "warning"); return; }
    setSaving(true);
    const payload = { nombre:form.nombre.trim(), precio:parseFloat(form.precio), descripcion:form.descripcion.trim()||null, activo:form.activo };
    const tok = sessionStorage.getItem("farmax_session_token");
    const { error: err } = await supabase.rpc("admin_upsert_procedimiento_medico", {
      p_session_token: tok,
      p_id:            form.id || null,
      p_payload:       payload,
    });
    setSaving(false);
    if (err) { showToast("Error al guardar: "+err.message, "error"); return; }
    onSaved();
  };
  return (
    <div style={{position:"fixed",inset:0,background:"#00000088",zIndex:1000,display:"flex",alignItems:"center",justifyContent:"center"}}>
      <div style={{background:C.card,border:`1px solid ${C.borderHi}`,borderRadius:14,width:"min(460px,95vw)",padding:24,boxShadow:"0 20px 60px #00000088"}}>
        <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:18}}>
          <h3 style={{margin:0,color:C.text,fontSize:15,fontWeight:800}}>{form.id?"✏️ Editar":"➕ Nuevo"} procedimiento</h3>
          <button onClick={onClose} style={{background:"none",border:"none",color:C.textMid,fontSize:18,cursor:"pointer"}}>✕</button>
        </div>
        <div style={{marginBottom:12}}><label style={labelStyle}>NOMBRE *</label><input value={form.nombre} onChange={e=>set("nombre",e.target.value)} style={inputStyle}/></div>
        <div style={{marginBottom:12}}><label style={labelStyle}>PRECIO *</label><input type="number" value={form.precio} onChange={e=>set("precio",e.target.value)} style={inputStyle}/></div>
        <div style={{marginBottom:12}}><label style={labelStyle}>DESCRIPCIÓN</label><input value={form.descripcion} onChange={e=>set("descripcion",e.target.value)} style={inputStyle}/></div>
        <div style={{marginBottom:16,display:"flex",alignItems:"center",gap:8}}>
          <input type="checkbox" id="proc_activo" checked={form.activo} onChange={e=>set("activo",e.target.checked)} style={{width:14,height:14}}/>
          <label htmlFor="proc_activo" style={{...labelStyle,margin:0,cursor:"pointer"}}>Activo</label>
        </div>
        <div style={{display:"flex",justifyContent:"flex-end",gap:10}}>
          <button style={btnSecondary} onClick={onClose}>Cancelar</button>
          <button style={btnPrimary} onClick={handleSave} disabled={saving}>{saving?"Guardando…":"💾 Guardar"}</button>
        </div>
      </div>
    </div>
  );
}

function MedicoModal({ initial, onClose, onSaved }) {
  const C = C_LIGHT;
  const inputStyle = mkInputStyle(C);
  const labelStyle = mkLabelStyle(C);
  const btnSecondary = mkBtnSecondary(C);
  const btnPrimary = mkBtnPrimary(C);
  const empty = { nombre:"", especialidad:"Medicina General", cedula:"", turno:"", modelo_pago:"porcentaje", monto_fijo:"", porcentaje:"70", activo:true };
  const [form, setForm] = useState(initial||empty);
  const [saving, setSaving] = useState(false);
  const set = (k,v) => setForm(f=>({...f,[k]:v}));
  const handleSave = async () => {
    if (!form.nombre.trim()) { showToast("El nombre del médico es requerido.", "warning"); return; }
    setSaving(true);
    const payload = { nombre:form.nombre.trim(), especialidad:form.especialidad||"Medicina General", cedula:form.cedula.trim()||null, turno:form.turno.trim()||null, modelo_pago:form.modelo_pago, monto_fijo:parseFloat(form.monto_fijo)||0, porcentaje:parseFloat(form.porcentaje)||70, activo:form.activo };
    const tok = sessionStorage.getItem("farmax_session_token");
    const { error: err } = await supabase.rpc("admin_upsert_medico", {
      p_session_token: tok,
      p_id:            form.id || null,
      p_payload:       payload,
    });
    setSaving(false);
    if (err) { alert("Error: "+err.message); return; }
    onSaved();
  };
  return (
    <div style={{position:"fixed",inset:0,background:"#00000088",zIndex:1000,display:"flex",alignItems:"center",justifyContent:"center"}}>
      <div style={{background:C.card,border:`1px solid ${C.borderHi}`,borderRadius:14,width:"min(520px,95vw)",padding:24,boxShadow:"0 20px 60px #00000088"}}>
        <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:18}}>
          <h3 style={{margin:0,color:C.text,fontSize:15,fontWeight:800}}>{form.id?"✏️ Editar":"➕ Nuevo"} médico</h3>
          <button onClick={onClose} style={{background:"none",border:"none",color:C.textMid,fontSize:18,cursor:"pointer"}}>✕</button>
        </div>
        <div style={{display:"grid",gridTemplateColumns:"1fr 1fr",gap:"0 16px"}}>
          <div style={{marginBottom:12}}><label style={labelStyle}>NOMBRE *</label><input value={form.nombre} onChange={e=>set("nombre",e.target.value)} style={inputStyle}/></div>
          <div style={{marginBottom:12}}><label style={labelStyle}>ESPECIALIDAD</label><input value={form.especialidad} onChange={e=>set("especialidad",e.target.value)} style={inputStyle}/></div>
          <div style={{marginBottom:12}}><label style={labelStyle}>CÉDULA PROFESIONAL</label><input value={form.cedula} onChange={e=>set("cedula",e.target.value)} style={inputStyle}/></div>
          <div style={{marginBottom:12}}><label style={labelStyle}>TURNO</label><input value={form.turno} onChange={e=>set("turno",e.target.value)} placeholder="Ej: Lun-Vie 9-14h" style={inputStyle}/></div>
          <div style={{marginBottom:12}}>
            <label style={labelStyle}>MODELO DE PAGO</label>
            <select value={form.modelo_pago} onChange={e=>set("modelo_pago",e.target.value)} style={inputStyle}>
              <option value="fijo">Sueldo fijo</option>
              <option value="porcentaje">Porcentaje por consulta</option>
            </select>
          </div>
          <div style={{marginBottom:12}}>
            {form.modelo_pago==="fijo"
              ? <><label style={labelStyle}>MONTO FIJO (MXN)</label><input type="number" value={form.monto_fijo} onChange={e=>set("monto_fijo",e.target.value)} style={inputStyle}/></>
              : <><label style={labelStyle}>PORCENTAJE (%)</label><input type="number" value={form.porcentaje} onChange={e=>set("porcentaje",e.target.value)} style={inputStyle}/></>
            }
          </div>
        </div>
        <div style={{marginBottom:16,display:"flex",alignItems:"center",gap:8}}>
          <input type="checkbox" id="med_activo" checked={form.activo} onChange={e=>set("activo",e.target.checked)} style={{width:14,height:14}}/>
          <label htmlFor="med_activo" style={{...labelStyle,margin:0,cursor:"pointer"}}>Médico activo</label>
        </div>
        <div style={{display:"flex",justifyContent:"flex-end",gap:10}}>
          <button style={btnSecondary} onClick={onClose}>Cancelar</button>
          <button style={btnPrimary} onClick={handleSave} disabled={saving}>{saving?"Guardando…":"💾 Guardar"}</button>
        </div>
      </div>
    </div>
  );
}

function ListaEspera({ onLlamoPaciente }) {
  const C = C_LIGHT;
  const btnSecondary = mkBtnSecondary(C);
  const btnPrimary = mkBtnPrimary(C);
  const btnOutline = mkBtnOutline(C);
  const btnGreen = mkBtnGreen(C);
  const [citas,   setCitas]   = useState([]);
  const [loading, setLoading] = useState(true);

  const [historialMap, setHistorialMap] = useState({});

  const fetchCitas = useCallback(async () => {
    const hoy = todaySvLocal();
    // crear_cita / tienda guardan estado "agendada"; al cobrar en POS solo cambia pago_estado (no a "confirmada").
    // Sin incluir "agendada" las citas pagadas desaparecían de esta lista.
    const { data, error } = await supabase
      .from("citas")
      .select("*")
      .eq("fecha", hoy)
      .in("estado", ["agendada", "confirmada", "en_consulta", "completada", "pagada"])
      .order("hora");
    if (error) {
      console.error("[Consultorio] citas hoy:", error);
      setCitas([]);
    } else {
      const list = (data || []).filter((c) => (c.estado === "agendada" ? citaPagoOk(c) : true));
      setCitas(list);
      // L1: Cargar historial de cada paciente
      const tels = [...new Set(list.map((c) => c.telefono).filter(Boolean))];
      const map = {};
      await Promise.all(
        tels.map(async (tel) => {
          const { data: hist } = await supabase
            .from("citas")
            .select("fecha,diagnostico")
            .eq("telefono", tel)
            .eq("estado", "completada")
            .order("fecha", { ascending: false })
            .limit(5);
          if (hist && hist.length) map[tel] = { count: hist.length, ultima: hist[0].fecha, dx: hist[0].diagnostico };
        })
      );
      setHistorialMap(map);
    }
    setLoading(false);
  }, []);

  useEffect(() => {
    fetchCitas();
    const iv = setInterval(fetchCitas, 30000);
    return () => clearInterval(iv);
  }, [fetchCitas]);

  const cambiarEstado = async (id, nuevoEstado) => {
    const tok = sessionStorage.getItem("farmax_session_token");
    if (!tok) { alert("Sesión expirada."); return; }
    const { error } = await supabase.rpc("actualizar_estado_cita", {
      p_session_token: tok, p_cita_id: id, p_estado: nuevoEstado,
    });
    if (error) {
      alert("Error: "+error.message);
      return;
    }
    if (nuevoEstado === "en_consulta") onLlamoPaciente?.();
    fetchCitas();
  };

  const esperando =
    citas.filter((c) => c.estado === "confirmada" || (c.estado === "agendada" && citaPagoOk(c))).length;
  const enConsulta  = citas.filter(c=>c.estado==="en_consulta").length;
  const completadas = citas.filter(c=>c.estado==="completada").length;

  const badgeListaEspera = (c) => {
    if (c.estado === "en_consulta") return { bg:C.blueDim, col:C.blue, txt:"🩺 En consulta" };
    if (c.estado === "completada") return { bg:C.greenDim, col:C.green, txt:"✅ Completada" };
    if (c.estado === "pagada") return { bg:"#dcfce7", col:"#16a34a", txt:"💰 Pagada" };
    if (c.estado === "confirmada")
      return { bg:C.amberDim, col:C.amber, txt: citaPagoOk(c) ? "⏳ Esperando" : "⏳ Sin pago" };
    if (c.estado === "agendada" && citaPagoOk(c)) return { bg:C.amberDim, col:C.amber, txt:"⏳ Listo (pagó en caja)" };
    if (c.estado === "agendada")
      return { bg:C.card, col:C.textMid, txt:"Agendada" };
    return { bg:C.border, col:C.textMid, txt:c.estado || "—" };
  };

  return (
    <div>
      <div data-tour="cons-kpis" style={{display:"flex",gap:12,marginBottom:20,flexWrap:"wrap"}}>
        {[["⏳ Esperando",esperando,C.amber],["🩺 En consulta",enConsulta,C.blue],["✅ Completadas",completadas,C.green],["💰 Pagadas (cobro)",citas.filter((c) => citaEstaPagada(c)).length,"#16a34a"]].map(([lbl,val,col])=>(
          <div key={lbl} style={{background:C.card,border:`1px solid ${C.border}`,borderRadius:10,padding:"10px 18px",minWidth:130}}>
            <div style={{color:col,fontWeight:800,fontSize:22}}>{val}</div>
            <div style={{color:C.textMid,fontSize:11}}>{lbl}</div>
          </div>
        ))}
        <button onClick={fetchCitas} style={{...btnSecondary,marginLeft:"auto",alignSelf:"center"}}>🔄 Actualizar</button>
      </div>
      {loading ? <div style={{color:C.textMid,textAlign:"center",padding:40}}>Cargando…</div> : (
        <div data-tour="cons-lista" style={{overflowX:"auto",borderRadius:12,border:`1px solid ${C.border}`}}>
          <table style={{width:"100%",borderCollapse:"collapse",fontSize:12}}>
            <thead>
              <tr style={{background:C.card}}>
                {["Hora","Nombre","Teléfono","Motivo","Estado","Acciones"].map(h=>(
                  <th key={h} style={{padding:"10px 14px",textAlign:"left",color:C.textMid,fontWeight:700,borderBottom:`1px solid ${C.border}`,whiteSpace:"nowrap"}}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {citas.length===0&&<tr><td colSpan={6} style={{textAlign:"center",padding:40,color:C.textMid}}>Sin citas para hoy</td></tr>}
              {citas.map((c,i)=>{
                const s = badgeListaEspera(c);
                return (
                  <tr key={c.id||i} style={{background:i%2===0?"transparent":C.card+"60"}}>
                    <td style={{padding:"10px 14px",color:C.text,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{horaVista(c.hora)}</td>
                    <td style={{padding:"10px 14px",color:C.text,fontWeight:600,borderBottom:`1px solid ${C.border}`}}>
                      {c.nombre||c.paciente||"—"}
                      {historialMap[c.telefono]&&<span style={{marginLeft:6,fontSize:9,background:C.blueDim,color:C.blue,borderRadius:4,padding:"1px 5px",fontWeight:700}}>{historialMap[c.telefono].count} visita{historialMap[c.telefono].count>1?"s":""}</span>}
                    </td>
                    <td style={{padding:"10px 14px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{c.telefono||"—"}</td>
                    <td style={{padding:"10px 14px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{c.motivo||"—"}</td>
                    <td style={{padding:"10px 14px",borderBottom:`1px solid ${C.border}`}}>
                      <span style={{padding:"3px 10px",borderRadius:20,fontSize:10,fontWeight:700,background:s.bg,color:s.col}}>{s.txt}</span>
                    </td>
                    <td style={{padding:"10px 14px",borderBottom:`1px solid ${C.border}`,whiteSpace:"nowrap"}}>
                      {(c.estado === "confirmada" || (c.estado === "agendada" && citaPagoOk(c))) && (
                        <button onClick={()=>{
                          const resumen = historialMap[c.telefono];
                          if(resumen) {
                            const msg = `Paciente: ${c.nombre}\nVisitas previas: ${resumen.count}\nÚltima: ${resumen.ultima}\nÚltimo diagnóstico: ${resumen.dx||"—"}`;
                            if(!window.confirm(`📋 Historial previo:\n\n${msg}\n\n¿Llamar al paciente?`)) return;
                          }
                          cambiarEstado(c.id,"en_consulta");
                        }} style={{...mkBtnSmBlue(C),marginRight:6,fontWeight:800}}>📞 Llamar</button>
                      )}
                      {c.estado==="en_consulta"&&<button onClick={()=>cambiarEstado(c.id,"completada")} style={mkBtnSmGreen(C)}>Terminar consulta</button>}
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

function EnConsulta() {
  const C = C_LIGHT;
  const inputStyle = mkInputStyle(C);
  const labelStyle = mkLabelStyle(C);
  const btnSecondary = mkBtnSecondary(C);
  const btnPrimary = mkBtnPrimary(C);
  const btnOutline = mkBtnOutline(C);
  const btnGreen = mkBtnGreen(C);
  const [citaActual,     setCitaActual]     = useState(null);
  const [historial,      setHistorial]      = useState([]);
  const [procedimientos, setProcedimientos] = useState([]);
  const [botiquin,       setBotiquin]       = useState([]);
  const [loading,        setLoading]        = useState(true);
  const [saving,         setSaving]         = useState(false);
  const [saved,          setSaved]          = useState(false);
  const [diagnostico,    setDiagnostico]    = useState("");
  const [medicamentos,   setMedicamentos]   = useState([{medicamento:"",dosis:"",indicaciones:""}]);
  const [alergias,       setAlergias]       = useState("");
  const [antecedentes,   setAntecedentes]   = useState("");
  const [editExpediente, setEditExp]        = useState(false);
  const [procSel,        setProcSel]        = useState([]);
  const [consumibles,    setConsumibles]    = useState([]);
  const [notasMedico,    setNotasMedico]    = useState("");

  const fetchActual = useCallback(async () => {
    setLoading(true);
    const hoy = todaySvLocal();
    const { data } = await supabase.from("citas").select("*").eq("estado","en_consulta").eq("fecha", hoy).limit(1);
    const cita = data?.[0]||null;
    setCitaActual(cita);
    if (cita) {
      const tok = sessionStorage.getItem("farmax_session_token");
      const [{ data:hist },{ data:procs },bot,{ data:cliente }] = await Promise.all([
        supabase.from("citas").select("*").eq("telefono",cita.telefono).eq("estado","completada").order("fecha",{ascending:false}).limit(5),
        supabase.from("procedimientos_medicos").select("*").eq("activo",true).order("nombre"),
        fetchProductosConsumiblesConsultorio(supabase),
        supabase.rpc("admin_obtener_cliente_por_telefono", {
          p_session_token: tok, p_telefono: cita.telefono,
        }),
      ]);
      setHistorial(hist||[]); setProcedimientos(procs||[]); setBotiquin(bot||[]);
      // J6: Cargar alergias y antecedentes previos del cliente
      if (cliente?.notas) {
        const notasTxt = cliente.notas;
        const alergiasMatch = notasTxt.match(/ALERGIAS:\s*([^|]+)/i);
        const antecMatch    = notasTxt.match(/ANTECEDENTES:\s*([^|]+)/i);
        if (alergiasMatch) setAlergias(alergiasMatch[1].trim());
        if (antecMatch)    setAntecedentes(antecMatch[1].trim());
      }
    }
    setLoading(false);
  }, []);

  useEffect(() => { fetchActual(); }, [fetchActual]);

  const addMed    = () => setMedicamentos(m=>[...m,{medicamento:"",dosis:"",indicaciones:""}]);
  const removeMed = (idx) => setMedicamentos(m=>m.filter((_,i)=>i!==idx));
  const setMed    = (idx,k,v) => setMedicamentos(m=>m.map((it,i)=>i===idx?{...it,[k]:v}:it));
  const toggleProc = (proc) => setProcSel(s=>s.find(p=>p.id===proc.id)?s.filter(p=>p.id!==proc.id):[...s,proc]);
  const addConsumible   = (prod) => { if(!consumibles.find(c=>c.id===prod.id)) setConsumibles(c=>[...c,{...prod,cantidad:1}]); };
  const setConsQty      = (id,qty) => setConsumibles(c=>c.map(it=>it.id===id?{...it,cantidad:parseInt(qty)||1}:it));
  const removeConsumible= (id) => setConsumibles(c=>c.filter(it=>it.id!==id));

  const imprimirReceta = () => {
    if (!citaActual) return;
    const medsHTML = medicamentos.filter(m=>m.medicamento.trim()).map(m=>`
      <tr>
        <td style="padding:8px 12px;border-bottom:1px solid #e2e8f0;font-weight:600">${m.medicamento}</td>
        <td style="padding:8px 12px;border-bottom:1px solid #e2e8f0">${m.dosis||"—"}</td>
        <td style="padding:8px 12px;border-bottom:1px solid #e2e8f0">${m.indicaciones||"—"}</td>
      </tr>`).join("");
    const html = `<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8"/>
  <title>Receta Médica — Farmax</title>
  <style>
    * { margin:0; padding:0; box-sizing:border-box; }
    body { font-family: Arial, sans-serif; font-size: 13px; color: #0f172a; padding: 32px; max-width: 700px; margin: 0 auto; }
    .header { display:flex; justify-content:space-between; align-items:flex-start; border-bottom: 2px solid #0052cc; padding-bottom: 16px; margin-bottom: 20px; }
    .logo { font-size: 22px; font-weight: 900; color: #0052cc; }
    .logo span { color: #00c46a; }
    .clinic { text-align:right; font-size:11px; color:#475569; }
    .medico { background:#f0f4f9; border-radius:8px; padding:12px 16px; margin-bottom:20px; }
    .medico h3 { color:#0052cc; font-size:14px; margin-bottom:6px; }
    .paciente { display:grid; grid-template-columns:1fr 1fr; gap:12px; margin-bottom:20px; padding:12px 16px; border:1px solid #e2e8f0; border-radius:8px; }
    .field label { font-size:10px; color:#94a3b8; font-weight:700; text-transform:uppercase; }
    .field p { font-size:13px; color:#0f172a; font-weight:600; margin-top:2px; }
    h4 { color:#0052cc; font-size:12px; font-weight:700; text-transform:uppercase; letter-spacing:0.5px; margin-bottom:10px; }
    table { width:100%; border-collapse:collapse; margin-bottom:20px; }
    thead tr { background:#f8fafc; }
    th { padding:8px 12px; text-align:left; font-size:11px; color:#475569; font-weight:700; border-bottom:1px solid #e2e8f0; }
    .dx { background:#f8fafc; border-radius:8px; padding:12px 16px; margin-bottom:20px; }
    .notas { border:1px solid #e2e8f0; border-radius:8px; padding:12px 16px; margin-bottom:32px; }
    .firma { display:grid; grid-template-columns:1fr 1fr; gap:40px; margin-top:40px; }
    .firma-box { text-align:center; border-top:1px solid #0f172a; padding-top:8px; font-size:11px; color:#475569; }
    .footer { text-align:center; font-size:10px; color:#94a3b8; border-top:1px solid #e2e8f0; padding-top:12px; margin-top:20px; }
    @media print { body { padding:16px; } }
  </style>
</head>
<body>
  <div class="header">
    <div>
      <div class="logo">Far<span>max</span></div>
      <div style="font-size:11px;color:#475569;margin-top:4px">Farmacia · Consultorio Médico</div>
    </div>
    <div class="clinic">
      <div>Chinampac de Juárez, Iztapalapa</div>
      <div>Ciudad de México</div>
      <div style="margin-top:4px"><strong>Fecha:</strong> ${new Date().toLocaleDateString("es-MX",{year:"numeric",month:"long",day:"numeric"})}</div>
      <div><strong>Folio:</strong> RX-${citaActual.id||Date.now()}</div>
    </div>
  </div>

  <div class="medico">
    <h3>👩‍⚕️ Médico tratante</h3>
    <div style="font-weight:700;font-size:14px">Dra. Lourdes Lucio Falcón</div>
    <div style="color:#475569;font-size:12px">Médico General · Cédula profesional: __________________</div>
  </div>

  <div class="paciente">
    <div class="field"><label>Paciente</label><p>${citaActual.nombre||"—"}</p></div>
    <div class="field"><label>Teléfono</label><p>${citaActual.telefono||"—"}</p></div>
    <div class="field"><label>Fecha consulta</label><p>${citaActual.fecha||new Date().toLocaleDateString("es-MX")}</p></div>
    <div class="field"><label>Hora</label><p>${horaVista(citaActual.hora)}</p></div>
    <div class="field" style="grid-column:1/-1"><label>Motivo de consulta</label><p>${citaActual.motivo||"Consulta general"}</p></div>
  </div>

  <div class="dx">
    <h4>📋 Diagnóstico</h4>
    <p style="line-height:1.6">${diagnostico||"—"}</p>
  </div>

  ${medsHTML ? `
  <h4>💊 Medicamentos prescritos</h4>
  <table>
    <thead><tr><th>Medicamento</th><th>Dosis</th><th>Indicaciones</th></tr></thead>
    <tbody>${medsHTML}</tbody>
  </table>` : ""}

  ${notasMedico ? `
  <div class="notas">
    <h4>📝 Notas del médico</h4>
    <p style="line-height:1.6;margin-top:8px">${notasMedico}</p>
  </div>` : ""}

  <div class="firma">
    <div class="firma-box">Firma del médico<br/><strong>Dra. Lourdes Lucio Falcón</strong></div>
    <div class="firma-box">Sello del consultorio<br/><strong>Farmax · Consultorio Médico</strong></div>
  </div>

  <div class="footer">
    Este documento es una receta médica oficial. Válida para surtir en Farmax Farmacia.<br/>
    Chinampac de Juárez, Iztapalapa, CDMX · farmax.mx
  </div>
</body>
</html>`;
    const win = window.open("","_blank","width=750,height=900");
    win.document.write(html);
    win.document.close();
    win.focus();
    setTimeout(()=>win.print(), 500);
  };

  const guardarConsulta = async () => {
    if (!diagnostico.trim()) { showToast("El diagnóstico es requerido para guardar.", "warning"); return; }
    setSaving(true);
    const tok = sessionStorage.getItem("farmax_session_token");
    if (!tok) { showToast("Sesión expirada.", "error"); setSaving(false); return; }

    const { data: resp, error } = await supabase.rpc("doctora_completar_consulta", {
      p_session_token:  tok,
      p_cita_id:        citaActual.id,
      p_diagnostico:    diagnostico.trim(),
      p_medicamentos:   medicamentos.filter(m => m.medicamento.trim()),
      p_procedimientos: procSel,
      p_notas_medico:   notasMedico.trim() || null,
      p_alergias:       alergias.trim() || null,
      p_antecedentes:   antecedentes.trim() || null,
      p_consumibles:    consumibles.map(c => ({
        producto_id: c.id,
        cantidad:    c.cantidad,
        precio:      c.precio || 0,
      })),
    });
    if (error || !resp?.success) {
      showToast("Error al guardar consulta: "+(resp?.error||error?.message), "error");
      setSaving(false); return;
    }

    setSaving(false); setSaved(true);
    setDiagnostico(""); setMedicamentos([{medicamento:"",dosis:"",indicaciones:""}]);
    setProcSel([]); setConsumibles([]); setNotasMedico("");
    setTimeout(()=>{ setSaved(false); fetchActual(); }, 2000);
  };

  if (loading) return <div style={{color:C.textMid,textAlign:"center",padding:60}}>Cargando…</div>;
  if (!citaActual) return (
    <div style={{textAlign:"center",padding:60}}>
      <div style={{fontSize:48,marginBottom:16}}>🏥</div>
      <div style={{color:C.text,fontWeight:700,fontSize:16,marginBottom:8}}>Nadie en sala todavía</div>
      <div style={{color:C.textMid,fontSize:13,maxWidth:420,margin:"0 auto",lineHeight:1.5}}>
        En <strong>Lista de espera</strong> pulsa <strong>📞 Llamar</strong> en un paciente pagado; entonces se abre su ficha aquí. Ahí documentás diagnóstico, receta, procedimientos y material usado, y con <strong>Guardar consulta</strong> cerrás.
      </div>
      <button onClick={fetchActual} style={{...btnSecondary,marginTop:16}}>🔄 Actualizar</button>
    </div>
  );

  return (
    <div>
      {saved&&<div style={{background:C.greenDim,border:`1px solid ${C.green}40`,borderRadius:10,padding:"12px 18px",marginBottom:20,color:C.green,fontWeight:700}}>✅ Consulta guardada correctamente</div>}
      <div style={{display:"grid",gridTemplateColumns:"1fr 1.6fr",gap:20}}>
        <div>
          <Paciente
            citaActual={citaActual}
            editExpediente={editExpediente}
            onToggleExpediente={() => setEditExp((p) => !p)}
            alergias={alergias}
            setAlergias={setAlergias}
            antecedentes={antecedentes}
            setAntecedentes={setAntecedentes}
            inputStyle={inputStyle}
            C={C}
          />
          <Historial items={historial} fmtDate={fmtDate} C={C} />
        </div>
        <div style={{display:"flex",flexDirection:"column",gap:14}}>
          <div style={{background:C.card,border:`1px solid ${C.border}`,borderRadius:12,padding:18}}>
            <label style={{...labelStyle,fontSize:12,marginBottom:8}}>DIAGNÓSTICO *</label>
            <div style={{display:"flex",gap:4,flexWrap:"wrap",marginBottom:8}}>
              {["Infección respiratoria aguda","Gastroenteritis aguda","Hipertensión arterial controlada","Diabetes mellitus tipo 2","Infección urinaria","Cefalea tensional","Lumbalgia aguda","Consulta de seguimiento"].map(dx=>(
                <button key={dx} onClick={()=>setDiagnostico(dx)}
                  style={{padding:"3px 8px",borderRadius:20,fontSize:9,fontWeight:600,cursor:"pointer",
                    background:diagnostico===dx?C.blue:C.bg,
                    border:`1px solid ${diagnostico===dx?C.blue:C.border}`,
                    color:diagnostico===dx?"#fff":C.textMid}}>
                  {dx}
                </button>
              ))}
            </div>
            <textarea value={diagnostico} onChange={e=>setDiagnostico(e.target.value)} rows={3}
              placeholder="Descripción del diagnóstico…" style={{...inputStyle,resize:"vertical",lineHeight:1.6}}/>
          </div>
          <div style={{background:C.card,border:`1px solid ${C.border}`,borderRadius:12,padding:18}}>
            <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:12}}>
              <div style={{color:C.textMid,fontSize:12,fontWeight:700,letterSpacing:.5}}>MEDICAMENTOS PRESCRITOS</div>
              <button onClick={addMed} style={mkBtnSmBlue(C)}>+ Agregar</button>
            </div>
            <datalist id="lista-medicamentos">
              {botiquin.map(p=><option key={p.id} value={p.nombre}/>)}
            </datalist>
            {medicamentos.map((m,idx)=>(
              <div key={idx} style={{display:"grid",gridTemplateColumns:"1fr 1fr 1.5fr auto",gap:8,marginBottom:8,alignItems:"center"}}>
                <input value={m.medicamento} onChange={e=>setMed(idx,"medicamento",e.target.value)}
                  placeholder="Medicamento" list="lista-medicamentos" style={{...inputStyle,fontSize:11}}/>
                <input value={m.dosis} onChange={e=>setMed(idx,"dosis",e.target.value)} placeholder="Dosis" style={{...inputStyle,fontSize:11}}/>
                <input value={m.indicaciones} onChange={e=>setMed(idx,"indicaciones",e.target.value)} placeholder="Indicaciones" style={{...inputStyle,fontSize:11}}/>
                <button onClick={()=>removeMed(idx)} style={{...mkBtnSmRed(C),padding:"4px 8px"}}>×</button>
              </div>
            ))}
          </div>
          {procedimientos.length>0&&(
            <div style={{background:C.card,border:`1px solid ${C.border}`,borderRadius:12,padding:18}}>
              <div style={{color:C.textMid,fontSize:12,fontWeight:700,letterSpacing:.5,marginBottom:12}}>PROCEDIMIENTOS REALIZADOS</div>
              <div style={{display:"flex",flexWrap:"wrap",gap:8}}>
                {procedimientos.map(p=>{
                  const sel=procSel.find(s=>s.id===p.id);
                  return (
                    <div key={p.id} onClick={()=>toggleProc(p)} style={{
                      padding:"5px 12px",borderRadius:20,cursor:"pointer",fontSize:11,fontWeight:700,
                      background:sel?BRAND.gradient:C.bg, color:sel?"#fff":C.textMid,
                      border:`1px solid ${sel?C.blue:C.border}`, transition:"all .15s",
                    }}>{p.nombre} — {fmt(p.precio)}</div>
                  );
                })}
              </div>
              {procSel.length>0&&<div style={{marginTop:10,color:C.textMid,fontSize:11}}>
                Total: <strong style={{color:C.green}}>{fmt(procSel.reduce((a,p)=>a+parseFloat(p.precio||0),0))}</strong>
              </div>}
            </div>
          )}
          {botiquin.length>0&&(
            <div style={{background:C.card,border:`1px solid ${C.border}`,borderRadius:12,padding:18}}>
              <div style={{color:C.textMid,fontSize:12,fontWeight:700,letterSpacing:.5,marginBottom:12}}>CONSUMIBLES (material de curación)</div>
              <div style={{color:C.textDim,fontSize:10,marginBottom:8,lineHeight:1.35}}>Gasas, jeringas, guantes, etc. — no medicamentos de venta. La lista viene de Inventario según categorías en Metas y Precios.</div>
              <select onChange={e=>{ const p=botiquin.find(b=>b.id===parseInt(e.target.value)); if(p)addConsumible(p); e.target.value=""; }} style={{...inputStyle,marginBottom:10}}>
                <option value="">Seleccionar consumible…</option>
                {botiquin.map(b=><option key={b.id} value={b.id}>{b.nombre} (stock: {b.stock})</option>)}
              </select>
              {consumibles.map(c=>(
                <div key={c.id} style={{display:"flex",alignItems:"center",gap:8,marginBottom:6}}>
                  <span style={{flex:1,color:C.text,fontSize:12}}>{c.nombre}</span>
                  <input type="number" min="1" value={c.cantidad} onChange={e=>setConsQty(c.id,e.target.value)} style={{...inputStyle,width:60,textAlign:"center"}}/>
                  <button onClick={()=>removeConsumible(c.id)} style={mkBtnSmRed(C)}>×</button>
                </div>
              ))}
            </div>
          )}
          <div style={{background:C.card,border:`1px solid ${C.border}`,borderRadius:12,padding:18}}>
            <label style={labelStyle}>NOTAS DEL MÉDICO</label>
            <textarea value={notasMedico} onChange={e=>setNotasMedico(e.target.value)} rows={2}
              placeholder="Observaciones adicionales…" style={{...inputStyle,resize:"vertical",lineHeight:1.5}}/>
          </div>
          <div style={{display:"flex",gap:10}}>
            <button onClick={guardarConsulta} disabled={saving||!diagnostico.trim()} style={{
              ...btnGreen, padding:"13px", fontSize:14, flex:2, opacity:saving||!diagnostico.trim()?.6:1,
            }}>{saving?"Guardando…":"💾 Guardar consulta"}</button>
            <button onClick={imprimirReceta} disabled={!diagnostico.trim()} style={{
              padding:"13px", fontSize:14, flex:1, borderRadius:8, border:"1px solid #0052cc",
              background:"#eff6ff", color:"#0052cc", cursor:!diagnostico.trim()?"not-allowed":"pointer",
              fontWeight:700, opacity:!diagnostico.trim()?.5:1,
            }}>🖨️ Imprimir receta</button>
          </div>
        </div>
      </div>
    </div>
  );
}

function Procedimientos({ readOnly }) {
  const C = C_LIGHT;
  const btnSecondary = mkBtnSecondary(C);
  const btnPrimary = mkBtnPrimary(C);
  const btnOutline = mkBtnOutline(C);
  const btnGreen = mkBtnGreen(C);
  const [procs,   setProcs]   = useState([]);
  const [loading, setLoading] = useState(true);
  const [modal,   setModal]   = useState(null);

  const fetchProcs = useCallback(async () => {
    setLoading(true);
    const { data, error } = await supabase.from("procedimientos_medicos").select("*").order("nombre");
    if (!error) {
      if ((data || []).length === 0) {
        if (readOnly) {
          setProcs([]);
        } else {
          const tok = sessionStorage.getItem("farmax_session_token");
          if (tok) {
            await supabase.rpc("admin_seed_procedimientos_medicos", {
              p_session_token: tok,
              p_items:         DEFAULT_PROCEDIMIENTOS,
            });
          }
          const { data: d2 } = await supabase.from("procedimientos_medicos").select("*").order("nombre");
          setProcs(d2 || []);
        }
      } else setProcs(data || []);
    }
    setLoading(false);
  }, [readOnly]);

  useEffect(() => { fetchProcs(); }, [fetchProcs]);

  const toggleActivo = async (p) => {
    const tok = sessionStorage.getItem("farmax_session_token");
    await supabase.rpc("admin_toggle_procedimiento_medico", {
      p_session_token: tok, p_id: p.id, p_activo: !p.activo,
    });
    fetchProcs();
  };

  return (
    <div>
      <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:16}}>
        <div style={{color:C.textMid,fontSize:12}}>{procs.length} procedimientos</div>
        {!readOnly && <button style={btnPrimary} onClick={()=>setModal({})}>➕ Nuevo procedimiento</button>}
      </div>
      {loading ? <div style={{color:C.textMid,textAlign:"center",padding:40}}>Cargando…</div> : (
        <div style={{overflowX:"auto",borderRadius:12,border:`1px solid ${C.border}`}}>
          <table style={{width:"100%",borderCollapse:"collapse",fontSize:12}}>
            <thead>
              <tr style={{background:C.card}}>
                {(readOnly
                  ? ["Nombre", "Precio", "Descripción", "Estado"]
                  : ["Nombre", "Precio", "Descripción", "Estado", "Acciones"]
                ).map((h) => (
                  <th key={h} style={{ padding: "10px 14px", textAlign: "left", color: C.textMid, fontWeight: 700, borderBottom: `1px solid ${C.border}` }}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {procs.map((p,i)=>(
                <tr key={p.id||i} style={{background:i%2===0?"transparent":C.card+"60",opacity:p.activo?1:.5}}>
                  <td style={{padding:"9px 14px",color:C.text,fontWeight:600,borderBottom:`1px solid ${C.border}`}}>{p.nombre}</td>
                  <td style={{padding:"9px 14px",color:C.green,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{fmt(p.precio)}</td>
                  <td style={{padding:"9px 14px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{p.descripcion||"—"}</td>
                  <td style={{padding:"9px 14px",borderBottom:`1px solid ${C.border}`}}>
                    <span style={{padding:"2px 8px",borderRadius:20,fontSize:10,fontWeight:700,background:p.activo?C.greenDim:C.redDim,color:p.activo?C.green:C.red}}>{p.activo?"Activo":"Inactivo"}</span>
                  </td>
                  {!readOnly && (
                  <td style={{padding:"9px 14px",borderBottom:`1px solid ${C.border}`,whiteSpace:"nowrap"}}>
                    <button onClick={()=>setModal(p)} style={{...mkBtnSmBlue(C),marginRight:6}}>✏️ Editar</button>
                    <button onClick={()=>toggleActivo(p)} style={p.activo?mkBtnSmRed(C):mkBtnSmGreen(C)}>{p.activo?"Desactivar":"Reactivar"}</button>
                  </td>
                  )}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
      {modal!==null&&<ProcedimientoModal initial={modal} onClose={()=>setModal(null)} onSaved={()=>{setModal(null);fetchProcs();}}/>}
    </div>
  );
}

function Medicos() {
  const C = C_LIGHT;
  const btnSecondary = mkBtnSecondary(C);
  const btnPrimary = mkBtnPrimary(C);
  const btnOutline = mkBtnOutline(C);
  const btnGreen = mkBtnGreen(C);
  const [medicos,  setMedicos]  = useState([]);
  const [loading,  setLoading]  = useState(true);
  const [modal,    setModal]    = useState(null);

  const fetchMedicos = useCallback(async () => {
    setLoading(true);
    const { data, error } = await supabase.from("medicos").select("*").order("nombre");
    if (!error) setMedicos(data||[]);
    setLoading(false);
  }, []);

  useEffect(() => { fetchMedicos(); }, [fetchMedicos]);

  const toggleActivo = async (m) => {
    const tok = sessionStorage.getItem("farmax_session_token");
    await supabase.rpc("admin_toggle_medico", {
      p_session_token: tok, p_id: m.id, p_activo: !m.activo,
    });
    fetchMedicos();
  };

  return (
    <div>
      <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:16}}>
        <div style={{color:C.textMid,fontSize:12}}>{medicos.length} médico{medicos.length!==1?"s":""}</div>
        <button style={btnPrimary} onClick={()=>setModal({})}>➕ Nuevo médico</button>
      </div>
      {loading ? <div style={{color:C.textMid,textAlign:"center",padding:40}}>Cargando…</div> : (
        medicos.length===0
          ? <div style={{color:C.textMid,textAlign:"center",padding:40}}>Sin médicos. Agrega el primero.</div>
          : <div style={{overflowX:"auto",borderRadius:12,border:`1px solid ${C.border}`}}>
              <table style={{width:"100%",borderCollapse:"collapse",fontSize:12}}>
                <thead>
                  <tr style={{background:C.card}}>
                    {["Nombre","Especialidad","Cédula","Turno","Modelo pago","Estado","Acciones"].map(h=>(
                      <th key={h} style={{padding:"10px 14px",textAlign:"left",color:C.textMid,fontWeight:700,borderBottom:`1px solid ${C.border}`,whiteSpace:"nowrap"}}>{h}</th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {medicos.map((m,i)=>(
                    <tr key={m.id||i} style={{background:i%2===0?"transparent":C.card+"60",opacity:m.activo?1:.5}}>
                      <td style={{padding:"9px 14px",color:C.text,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{m.nombre}</td>
                      <td style={{padding:"9px 14px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{m.especialidad}</td>
                      <td style={{padding:"9px 14px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{m.cedula||"—"}</td>
                      <td style={{padding:"9px 14px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{m.turno||"—"}</td>
                      <td style={{padding:"9px 14px",borderBottom:`1px solid ${C.border}`}}>
                        {m.modelo_pago==="fijo"
                          ? <span style={{color:C.blue,fontWeight:700}}>Fijo ${m.monto_fijo}</span>
                          : <span style={{color:C.purple,fontWeight:700}}>{m.porcentaje}% consulta</span>}
                      </td>
                      <td style={{padding:"9px 14px",borderBottom:`1px solid ${C.border}`}}>
                        <span style={{padding:"2px 8px",borderRadius:20,fontSize:10,fontWeight:700,background:m.activo?C.greenDim:C.redDim,color:m.activo?C.green:C.red}}>{m.activo?"Activo":"Inactivo"}</span>
                      </td>
                      <td style={{padding:"9px 14px",borderBottom:`1px solid ${C.border}`,whiteSpace:"nowrap"}}>
                        <button onClick={()=>setModal(m)} style={{...mkBtnSmBlue(C),marginRight:6}}>✏️ Editar</button>
                        <button onClick={()=>toggleActivo(m)} style={m.activo?mkBtnSmRed(C):mkBtnSmGreen(C)}>{m.activo?"Desactivar":"Reactivar"}</button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
      )}
      {modal!==null&&<MedicoModal initial={modal} onClose={()=>setModal(null)} onSaved={()=>{setModal(null);fetchMedicos();}}/>}
    </div>
  );
}

export default function ConsultorioModule({ usuario }) {
  const C = C_LIGHT;
  const isMobile = useMediaQuery("(max-width: 768px)");
  const isDoctora = usuario?.rol === "doctora";
  const inputStyle = mkInputStyle(C);
  const labelStyle = mkLabelStyle(C);
  const btnPrimary = mkBtnPrimary(C);
  const btnSecondary = mkBtnSecondary(C);
  const btnGreen = mkBtnGreen(C);
  const btnSmBlue = mkBtnSmBlue(C);
  const btnSmGreen = mkBtnSmGreen(C);
  const btnSmRed = mkBtnSmRed(C);
  const [tab, setTab] = useState("espera");
  const TABS_ALL = isMobile
    ? [["espera","⏳ Lista"],["consulta","🏥 Consulta"],["procedimientos","⚕ Procedim."],["medicos","👨‍⚕️ Médicos"]]
    : [["espera","⏳ Lista de espera"],["consulta","🏥 En consulta"],["procedimientos","⚕ Procedimientos"],["medicos","👨‍⚕️ Médicos"]];
  const TABS = isDoctora ? TABS_ALL.filter(([id]) => id !== "medicos") : TABS_ALL;
  useEffect(() => {
    if (isDoctora && tab === "medicos") setTab("espera");
  }, [isDoctora, tab]);
  return (
    <div style={{padding:24,background:C.bg,minHeight:"100vh",fontFamily:"'Plus Jakarta Sans',sans-serif"}}>
      <div style={{marginBottom:20}}>
        <h1 style={{margin:0,color:C.text,fontSize:20,fontWeight:800}}>♥ Consultorio</h1>
        <p style={{margin:"4px 0 0",color:C.textMid,fontSize:12}}>Gestión médica · Farmax</p>
        {isDoctora && (
          <div
            style={{
              marginTop: 12,
              padding: "12px 14px",
              borderRadius: 10,
              border: `1px solid ${C.blue}35`,
              background: C.blueDim,
              color: C.text,
              fontSize: 12,
              lineHeight: 1.45,
            }}
          >
            <strong>Atender un paciente:</strong> en <em>Lista de espera</em> elige a quien ya pagó caja y pulsa{" "}
            <strong>📞 Llamar</strong> (pasa a <em>en consulta</em> y se abre la pestaña <strong>En consulta</strong>). Ahí ves la
            ficha, diagnóstico, medicamentos, procedimientos y <strong>Guardar consulta</strong>. Tu 70% de ingresos: menú{" "}
            <strong>Consultas e ingresos</strong>.
          </div>
        )}
      </div>
      <div style={{
        display:"flex",
        gap:6,
        marginBottom:24,
        borderBottom:`1px solid ${C.border}`,
        overflowX:isMobile?"auto":"visible",
        WebkitOverflowScrolling:"touch",
        flexWrap:"nowrap",
        scrollbarWidth:"thin",
      }}>
        {TABS.map(([id,label])=>(
          <button key={id} onClick={()=>setTab(id)} style={{
            padding:isMobile?"10px 14px":"9px 18px",
            border:"none",
            cursor:"pointer",
            fontWeight:700,
            fontSize:isMobile?13:12,
            borderRadius:"8px 8px 0 0",
            background:tab===id?C.card:"transparent",
            color:tab===id?C.blue:C.textMid,
            borderBottom:tab===id?`2px solid ${C.blue}`:"2px solid transparent",
            flexShrink:0,
            whiteSpace:"nowrap",
            lineHeight:1.2,
          }}>{label}</button>
        ))}
      </div>
      {tab === "espera" && <ListaEspera onLlamoPaciente={() => setTab("consulta")} />}
      {tab === "consulta" && <EnConsulta />}
      {tab === "procedimientos" && <Procedimientos readOnly={isDoctora} />}
      {tab === "medicos" && !isDoctora && <Medicos />}
      <OnboardingTour tourId="cons" usuario={usuario} />
    </div>
  );
}
