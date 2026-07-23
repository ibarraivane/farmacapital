import { useState, useEffect, useCallback } from "react";
import { C_LIGHT } from "./constants";
import { supabase } from "./supabase";
import { productMatchesSearchQuery } from "./utils/fuzzySearch";
import { fixLegacyFarmaxBrand } from "./utils/brandText";

const BRAND = { primary:"#0D1B2A", secondary:"#1E3ABA", gradient:"linear-gradient(135deg,#0D1B2A,#1E3ABA)" };

const fmtDate  = (s) => s ? new Date(s).toLocaleDateString("es-MX",{day:"2-digit",month:"short",year:"numeric"}) : "Sin fecha";
const mkInputStyle = (C) => ({ width:"100%", padding:"8px 11px", borderRadius:7, border:`1px solid ${C.border}`, background:C.bg, color:C.text, fontSize:12, outline:"none", boxSizing:"border-box" });
const mkLabelStyle = (C) => ({ color:C.textMid, fontSize:10, fontWeight:700, marginBottom:3, display:"block" });
const mkBtnPrimary = (C) => ({ padding:"9px 18px", borderRadius:8, border:"none", cursor:"pointer", background:BRAND.gradient, color:"#fff", fontWeight:700, fontSize:12 });
const mkBtnSecondary = (C) => ({ padding:"8px 14px", borderRadius:8, cursor:"pointer", fontWeight:700, fontSize:12, border:`1px solid ${C.border}`, background:"transparent", color:C.textMid });
const mkBtnSmBlue  = (C) => ({ padding:"5px 12px", borderRadius:6, cursor:"pointer", background:C.blueDim, color:C.blue, fontWeight:700, fontSize:11, border:`1px solid ${C.blue}30` });

const ALERTAS_DEFAULT = [
  { nombre:"Aviso de funcionamiento COFEPRIS", descripcion:"Aviso de funcionamiento farmacia" },
  { nombre:"Licencia sanitaria", descripcion:"Licencia sanitaria del establecimiento" },
  { nombre:"ALFA médico - Dra. Lourdes Lucio Falcón", descripcion:"Certificación médica responsable sanitario" },
  { nombre:"Registro de marca FarmaCapital (IMPI)", descripcion:"IMPI - clase 44" },
  { nombre:"Alta SAT / RFC", descripcion:"Régimen fiscal activo" },
];

const diasRestantes = (fecha) => {
  if (!fecha) return null;
  return Math.ceil((new Date(fecha) - new Date()) / (1000*60*60*24));
};
const semaforoCol = (dias, C) => {
  if (dias===null) return C.textDim;
  if (dias<0)  return C.red;
  if (dias<30) return C.red;
  if (dias<60) return C.amber;
  return C.green;
};
const getRangoFecha = (f) => {
  const h=new Date(),y=h.getFullYear(),m=h.getMonth(),d=h.getDate();
  if (f==="hoy")    return { desde:new Date(y,m,d,0,0,0).toISOString(),  hasta:new Date(y,m,d,23,59,59).toISOString() };
  if (f==="semana") { const l=new Date(h);l.setDate(d-h.getDay());l.setHours(0,0,0);return{desde:l.toISOString(),hasta:h.toISOString()}; }
  if (f==="mes")    return { desde:new Date(y,m,1).toISOString(), hasta:h.toISOString() };
  return null;
};
const exportarCSV = (rows, cols, filename) => {
  const csv=[cols.map(c=>c.label),...rows.map(r=>cols.map(c=>`"${(r[c.key]||"").toString().replace(/"/g,'""')}`))].map(r=>r.join(",")).join("\n");
  const a=document.createElement("a");
  a.href=URL.createObjectURL(new Blob([csv],{type:"text/csv;charset=utf-8;"}));
  a.download=filename; a.click();
};

function AlertasLegales() {
  const C = C_LIGHT;
  const inputStyle = mkInputStyle(C);
  const labelStyle = mkLabelStyle(C);
  const btnSecondary = mkBtnSecondary(C);
  const btnPrimary = mkBtnPrimary(C);
  const btnSmBlue = mkBtnSmBlue(C);
  const [alertas,   setAlertas]   = useState([]);
  const [loading,   setLoading]   = useState(true);
  const [editId,    setEditId]    = useState(null);
  const [editFecha, setEditFecha] = useState("");
  const [saving,    setSaving]    = useState(false);

  const fetchAlertas = useCallback(async () => {
    setLoading(true);
    const tok = sessionStorage.getItem("farmacapital_session_token");
    if (!tok) {
      setAlertas([]);
      setLoading(false);
      return;
    }
    const { data, error } = await supabase.rpc("admin_listar_alertas_legales", {
      p_session_token: tok,
    });
    let rows = Array.isArray(data) ? data : [];
    if (!error) {
      if (rows.some((r) => /\bfarmax\b/i.test(r.nombre || ""))) {
        await supabase.rpc("admin_corregir_marca_alertas_legales", { p_session_token: tok });
        const { data: dFix } = await supabase.rpc("admin_listar_alertas_legales", { p_session_token: tok });
        rows = Array.isArray(dFix) ? dFix : rows;
      }
      if (rows.length === 0) {
        await supabase.rpc("admin_seed_alertas_legales", {
          p_session_token: tok,
          p_items: ALERTAS_DEFAULT,
        });
        const { data: d2 } = await supabase.rpc("admin_listar_alertas_legales", {
          p_session_token: tok,
        });
        rows = Array.isArray(d2) ? d2 : [];
      }
      setAlertas(rows);
    }
    setLoading(false);
  }, []);

  useEffect(() => { fetchAlertas(); }, [fetchAlertas]);

  const actualizarFecha = async (id) => {
    if (!editFecha) return;
    setSaving(true);
    const tok = sessionStorage.getItem("farmacapital_session_token");
    await supabase.rpc("admin_actualizar_alerta_legal", {
      p_session_token:     tok,
      p_id:                id,
      p_fecha_vencimiento: editFecha,
    });
    setSaving(false); setEditId(null); setEditFecha(""); fetchAlertas();
  };

  if (loading) return <div style={{color:C.textMid,textAlign:"center",padding:40}}>Cargando…</div>;

  return (
    <div style={{display:"grid",gridTemplateColumns:"repeat(auto-fill,minmax(min(100%,300px),1fr))",gap:16}}>
      {alertas.map(a=>{
        const dias=diasRestantes(a.fecha_vencimiento);
        const col=semaforoCol(dias, C, C);
        const isEdit=editId===a.id;
        return (
          <div key={a.id} style={{background:C.card,border:`1px solid ${dias!==null&&dias<30?col+"60":C.border}`,borderRadius:12,padding:20,position:"relative"}}>
            <div style={{position:"absolute",top:16,right:16,width:14,height:14,borderRadius:"50%",background:col,boxShadow:`0 0 8px ${col}80`}}/>
            <div style={{color:C.text,fontWeight:800,fontSize:13,marginBottom:4,paddingRight:24}}>{fixLegacyFarmaxBrand(a.nombre)}</div>
            {a.descripcion&&<div style={{color:C.textMid,fontSize:11,marginBottom:12}}>{fixLegacyFarmaxBrand(a.descripcion)}</div>}
            <div style={{display:"flex",gap:16,marginBottom:12}}>
              <div>
                <div style={{color:C.textDim,fontSize:10,fontWeight:700}}>VENCIMIENTO</div>
                <div style={{color:C.text,fontWeight:700,fontSize:12}}>{fmtDate(a.fecha_vencimiento)}</div>
              </div>
              <div>
                <div style={{color:C.textDim,fontSize:10,fontWeight:700}}>DÍAS</div>
                <div style={{color:col,fontWeight:800,fontSize:12}}>
                  {dias===null?"Sin fecha":dias<0?"⚠ Vencido":dias===0?"Hoy":dias+" días"}
                </div>
              </div>
            </div>
            {!isEdit
              ? <button onClick={()=>{setEditId(a.id);setEditFecha(a.fecha_vencimiento||"");}} style={btnSmBlue}>📅 Actualizar fecha</button>
              : <div style={{display:"flex",gap:8,alignItems:"center"}}>
                  <input type="date" value={editFecha} onChange={e=>setEditFecha(e.target.value)} style={{...inputStyle,flex:1}}/>
                  <button onClick={()=>actualizarFecha(a.id)} disabled={saving} style={{...btnPrimary,padding:"7px 14px"}}>{saving?"…":"✓"}</button>
                  <button onClick={()=>setEditId(null)} style={{...btnSecondary,padding:"7px 12px"}}>✕</button>
                </div>
            }
          </div>
        );
      })}
    </div>
  );
}

function BitacoraAntibioticos() {
  const C = C_LIGHT;
  const inputStyle = mkInputStyle(C);
  const btnSecondary = mkBtnSecondary(C);
  const [registros,   setRegistros]   = useState([]);
  const [loading,     setLoading]     = useState(true);
  const [busqueda,    setBusqueda]    = useState("");
  const [filtroFecha, setFiltroFecha] = useState("todos");

  const fetchRegistros = useCallback(async () => {
    setLoading(true);
    const tok = sessionStorage.getItem("farmacapital_session_token");
    const rango = getRangoFecha(filtroFecha);
    const { data, error } = tok
      ? await supabase.rpc("empleado_listar_bitacora_cofepris", {
          p_session_token: tok,
          p_limite: 800,
          p_created_desde: rango?.desde ?? null,
          p_created_hasta: rango?.hasta ?? null,
        })
      : { data: [], error: null };
    if (!error) setRegistros(Array.isArray(data) ? data : []);
    setLoading(false);
  }, [filtroFecha]);

  useEffect(() => { fetchRegistros(); }, [fetchRegistros]);

  const filtrados = registros.filter(r =>
    !busqueda.trim() || productMatchesSearchQuery(r, busqueda, [(x) => x.medicamento, (x) => x.paciente])
  );

  const cols = [
    {key:"fecha_str",label:"Fecha"},{key:"medicamento",label:"Medicamento"},
    {key:"cantidad",label:"Cantidad"},{key:"lote",label:"Lote"},
    {key:"caducidad",label:"Caducidad"},{key:"medico",label:"Médico"},
    {key:"cedula_medico",label:"Cédula"},{key:"paciente",label:"Paciente"},
    {key:"receta",label:"Folio Rx"},
  ];

  const handleExport = () => {
    const rows = filtrados.map(r=>({...r, fecha_str:r.created_at?new Date(r.created_at).toLocaleString("es-MX"):""}));
    exportarCSV(rows, cols, `bitacora_cofepris_${new Date().toISOString().slice(0,10)}.csv`);
  };

  return (
    <div>
      <div style={{display:"flex",gap:10,marginBottom:16,flexWrap:"wrap",alignItems:"center"}}>
        <input placeholder="🔍 Medicamento o paciente…" value={busqueda} onChange={e=>setBusqueda(e.target.value)} style={{...inputStyle,maxWidth:220}}/>
        <select value={filtroFecha} onChange={e=>setFiltroFecha(e.target.value)} style={{...inputStyle,maxWidth:160}}>
          <option value="todos">Todo el tiempo</option>
          <option value="hoy">Hoy</option>
          <option value="semana">Esta semana</option>
          <option value="mes">Este mes</option>
        </select>
        <button onClick={handleExport} style={{...btnSecondary,marginLeft:"auto"}}>⬇ Exportar CSV</button>
        <span style={{color:C.textMid,fontSize:11}}>{filtrados.length} registro{filtrados.length!==1?"s":""}</span>
      </div>
      {loading ? <div style={{color:C.textMid,textAlign:"center",padding:40}}>Cargando…</div> : (
        <div style={{overflowX:"auto",borderRadius:12,border:`1px solid ${C.border}`}}>
          <table style={{width:"100%",borderCollapse:"collapse",fontSize:11}}>
            <thead>
              <tr style={{background:C.card}}>
                {["Fecha","Medicamento","Cant.","Lote","Caducidad","Médico","Cédula","Paciente","Folio Rx"].map(h=>(
                  <th key={h} style={{padding:"9px 12px",textAlign:"left",color:C.textMid,fontWeight:700,borderBottom:`1px solid ${C.border}`,whiteSpace:"nowrap"}}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {filtrados.length===0&&<tr><td colSpan={9} style={{textAlign:"center",padding:40,color:C.textMid}}>{busqueda?"Sin resultados":"Sin registros en la bitácora"}</td></tr>}
              {filtrados.map((r,i)=>(
                <tr key={r.id||i} style={{background:i%2===0?"transparent":C.card+"60"}}>
                  <td style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`,whiteSpace:"nowrap"}}>
                    {r.created_at?new Date(r.created_at).toLocaleDateString("es-MX"):"—"}
                    <div style={{fontSize:9,color:C.textDim}}>{r.created_at?new Date(r.created_at).toLocaleTimeString("es-MX",{hour:"2-digit",minute:"2-digit"}):""}</div>
                  </td>
                  <td style={{padding:"8px 12px",color:C.text,fontWeight:600,borderBottom:`1px solid ${C.border}`}}>{r.medicamento||"—"}</td>
                  <td style={{padding:"8px 12px",color:C.amber,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{r.cantidad||"—"}</td>
                  <td style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{r.lote||"—"}</td>
                  <td style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{r.caducidad||"—"}</td>
                  <td style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{r.medico||"—"}</td>
                  <td style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{r.cedula_medico||"—"}</td>
                  <td style={{padding:"8px 12px",color:C.text,borderBottom:`1px solid ${C.border}`}}>{r.paciente||"—"}</td>
                  <td style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{r.receta||"—"}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

function Controlados() {
  const C = C_LIGHT;
  const btnSecondary = mkBtnSecondary(C);
  const [registros, setRegistros] = useState([]);
  const [loading,   setLoading]   = useState(true);

  const fetchControlados = useCallback(async () => {
    setLoading(true);
    const tok = sessionStorage.getItem("farmacapital_session_token");
    const { data, error } = tok
      ? await supabase.rpc("empleado_listar_bitacora_cofepris", {
          p_session_token: tok,
          p_limite: 800,
          p_created_desde: null,
          p_created_hasta: null,
        })
      : { data: [], error: null };
    if (!error) setRegistros(Array.isArray(data) ? data : []);
    setLoading(false);
  }, []);

  useEffect(() => { fetchControlados(); }, [fetchControlados]);

  const hoy = new Date();
  const mesActual = registros.filter(r=>{
    if(!r.created_at) return false;
    const d=new Date(r.created_at);
    return d.getMonth()===hoy.getMonth()&&d.getFullYear()===hoy.getFullYear();
  });
  const ultimo = registros[0];

  const exportMes = () => {
    const cols=[{key:"fecha_str",label:"Fecha"},{key:"medicamento",label:"Medicamento"},{key:"cantidad",label:"Cantidad"},{key:"medico",label:"Médico"},{key:"cedula_medico",label:"Cédula"},{key:"paciente",label:"Paciente"},{key:"receta",label:"Folio Rx"}];
    exportarCSV(mesActual.map(r=>({...r,fecha_str:r.created_at?new Date(r.created_at).toLocaleString("es-MX"):""})),cols,`controlados_${hoy.getFullYear()}_${String(hoy.getMonth()+1).padStart(2,"0")}.csv`);
  };

  return (
    <div>
      <div style={{display:"flex",gap:12,marginBottom:20,flexWrap:"wrap"}}>
        {[{label:"Total registros",val:registros.length,col:C.blue},{label:"Este mes",val:mesActual.length,col:C.amber},{label:"Último registro",val:ultimo?new Date(ultimo.created_at).toLocaleDateString("es-MX"):"—",col:C.green}].map(s=>(
          <div key={s.label} style={{background:C.card,border:`1px solid ${C.border}`,borderRadius:10,padding:"10px 18px",minWidth:140}}>
            <div style={{color:s.col,fontWeight:800,fontSize:s.label==="Último registro"?13:22}}>{s.val}</div>
            <div style={{color:C.textMid,fontSize:11}}>{s.label}</div>
          </div>
        ))}
        <button onClick={exportMes} style={{...btnSecondary,alignSelf:"center",marginLeft:"auto"}}>📄 Reporte mensual</button>
      </div>
      <div style={{background:C.amberDim,border:`1px solid ${C.amber}30`,borderRadius:10,padding:"10px 16px",marginBottom:16,fontSize:12,color:C.amber,fontWeight:600}}>
        ⚠ Mostrando todos los registros con receta médica de la bitácora COFEPRIS.
      </div>
      {loading ? <div style={{color:C.textMid,textAlign:"center",padding:40}}>Cargando…</div> : (
        <div style={{overflowX:"auto",borderRadius:12,border:`1px solid ${C.border}`}}>
          <table style={{width:"100%",borderCollapse:"collapse",fontSize:11}}>
            <thead>
              <tr style={{background:C.card}}>
                {["Fecha","Medicamento","Cantidad","Médico","Cédula","Paciente","Folio Rx"].map(h=>(
                  <th key={h} style={{padding:"9px 12px",textAlign:"left",color:C.textMid,fontWeight:700,borderBottom:`1px solid ${C.border}`,whiteSpace:"nowrap"}}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {registros.length===0&&<tr><td colSpan={7} style={{textAlign:"center",padding:40,color:C.textMid}}>Sin registros de medicamentos controlados</td></tr>}
              {registros.map((r,i)=>(
                <tr key={r.id||i} style={{background:i%2===0?"transparent":C.card+"60"}}>
                  <td style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`,whiteSpace:"nowrap"}}>{r.created_at?new Date(r.created_at).toLocaleDateString("es-MX"):"—"}</td>
                  <td style={{padding:"8px 12px",color:C.text,fontWeight:600,borderBottom:`1px solid ${C.border}`}}>{r.medicamento||"—"}</td>
                  <td style={{padding:"8px 12px",color:C.amber,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{r.cantidad||"—"}</td>
                  <td style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{r.medico||"—"}</td>
                  <td style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{r.cedula_medico||"—"}</td>
                  <td style={{padding:"8px 12px",color:C.text,borderBottom:`1px solid ${C.border}`}}>{r.paciente||"—"}</td>
                  <td style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{r.receta||"—"}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

export default function COFEPRISModule() {
  const C = C_LIGHT;
  const inputStyle = mkInputStyle(C);
  const labelStyle = mkLabelStyle(C);
  const btnPrimary = mkBtnPrimary(C);
  const btnSecondary = mkBtnSecondary(C);
  const btnSmBlue = mkBtnSmBlue(C);
  const [tab, setTab] = useState("alertas");
  const TABS = [["alertas","🚦 Alertas legales"],["bitacora","📋 Bitácora antibióticos"],["controlados","💊 Controlados"]];
  return (
    <div style={{padding:24,background:C.bg,minHeight:"100dvh",fontFamily:"'Plus Jakarta Sans',sans-serif"}}>
      <div style={{marginBottom:20}}>
        <h1 style={{margin:0,color:C.text,fontSize:20,fontWeight:800}}>⚕ COFEPRIS</h1>
        <p style={{margin:"4px 0 0",color:C.textMid,fontSize:12}}>Cumplimiento regulatorio · FarmaCapital</p>
      </div>
      <div style={{display:"flex",gap:4,marginBottom:24,borderBottom:`1px solid ${C.border}`}}>
        {TABS.map(([id,label])=>(
          <button key={id} onClick={()=>setTab(id)} style={{
            padding:"9px 18px",border:"none",cursor:"pointer",fontWeight:700,fontSize:12,
            borderRadius:"8px 8px 0 0",background:tab===id?C.card:"transparent",
            color:tab===id?C.blue:C.textMid,
            borderBottom:tab===id?`2px solid ${C.blue}`:"2px solid transparent",
          }}>{label}</button>
        ))}
      </div>
      {tab==="alertas"     && <AlertasLegales/>}
      {tab==="bitacora"    && <BitacoraAntibioticos/>}
      {tab==="controlados" && <Controlados/>}
    </div>
  );
}
