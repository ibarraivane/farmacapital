import { useState, useEffect, useCallback } from 'react';
import { useMediaQuery } from './hooks/useMediaQuery';
import { supabase } from './supabase';
import { showToast } from './ui';
import { C_LIGHT, BRAND } from "./constants";

const fmt = (n) =>
  new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(n || 0);

const DIAS = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

function getQuincena() {
  const hoy = new Date();
  const y = hoy.getFullYear(), m = hoy.getMonth();
  if (hoy.getDate() <= 15) {
    return { inicio: new Date(y,m,1).toISOString().slice(0,10), fin: new Date(y,m,15).toISOString().slice(0,10) };
  }
  const lastDay = new Date(y, m+1, 0).getDate();
  return { inicio: new Date(y,m,16).toISOString().slice(0,10), fin: new Date(y,m,lastDay).toISOString().slice(0,10) };
}

const mkS = (C) => ({
  wrap:    { background:C.bg, minHeight:'100dvh', padding:'24px', fontFamily:"'Plus Jakarta Sans', Inter, sans-serif", color:C.text },
  section: { background:C.card, border:`1px solid ${C.border}`, borderRadius:12, padding:'24px', marginBottom:24 },
  h2:      { fontSize:16, fontWeight:700, color:C.blue, marginBottom:16, display:'flex', alignItems:'center', gap:8 },
  label:   { display:'block', fontSize:11, color:C.textMid, marginBottom:4, fontWeight:700, textTransform:'uppercase', letterSpacing:'0.05em' },
  input:   { width:'100%', background:C.bg, border:`1px solid ${C.border}`, borderRadius:8, padding:'9px 12px', color:C.text, fontSize:13, boxSizing:'border-box', outline:'none' },
  select:  { width:'100%', background:C.bg, border:`1px solid ${C.border}`, borderRadius:8, padding:'9px 12px', color:C.text, fontSize:13, boxSizing:'border-box', outline:'none' },
  btnBlue: { background:C.blue,    color:'#fff', border:'none', borderRadius:8, padding:'9px 18px', fontSize:13, fontWeight:700, cursor:'pointer' },
  btnGreen:{ background:C.green,   color:'#fff', border:'none', borderRadius:8, padding:'9px 18px', fontSize:13, fontWeight:700, cursor:'pointer' },
  th:      { padding:'8px 12px', textAlign:'left', fontSize:10, fontWeight:700, color:C.textMid, textTransform:'uppercase', letterSpacing:'0.06em', borderBottom:`1px solid ${C.border}` },
  td:      { padding:'9px 12px', fontSize:13, borderBottom:`1px solid ${C.border}` },
});

const actionBtnBase = {
  width: 18,
  height: 18,
  borderRadius: 5,
  display: "inline-flex",
  alignItems: "center",
  justifyContent: "center",
  cursor: "pointer",
  padding: 0,
  marginLeft: 1,
};

export default function RRHHModule() {
  const C = C_LIGHT;
  const s = mkS(C);
  const S = mkS(C);
  const isMobile = useMediaQuery("(max-width: 768px)");
  const [horarioAbierto, setHorarioAbierto] = useState(null);
  const [empleados, setEmpleados] = useState([]);
  const [loading, setLoading]     = useState(true);
  const emptyForm = { nombre:'', telefono:'', rol:'vendedor', turno:'matutino', salario_quincenal:'' };
  const [form, setForm]           = useState(emptyForm);
  const [formMsg, setFormMsg]     = useState(null);
  const [schedule, setSchedule]   = useState({});
  const [selEmpId, setSelEmpId]   = useState('');
  const [calcBase, setCalcBase]   = useState(0);
  const [calcHE, setCalcHE]       = useState(0);
  const [calcPD, setCalcPD]       = useState(0);
  const [calcBono, setCalcBono]   = useState(0);
  const [nominaMsg, setNominaMsg] = useState(null);
  const [comisiones, setComisiones] = useState([]);
  const [loadCom, setLoadCom]       = useState(false);
  const [periCom, setPeriCom]       = useState("mes"); // dia|semana|mes
  const [pctCom, setPctCom]         = useState(3); // % comisión configurable

  const fetchComisiones = async () => {
    setLoadCom(true);
    const dias = periCom==="dia"?1:periCom==="semana"?7:30;
    const desde = new Date(Date.now()-dias*86400000).toISOString();
    const tok = sessionStorage.getItem("farmacapital_session_token");
    const { data } = tok
      ? await supabase.rpc("empleado_rrhh_comisiones_pedidos", {
          p_session_token: tok,
          p_desde: desde,
        })
      : { data: [] };
    // Agrupar por empleado
    const map = {};
    (data||[]).forEach(p=>{
      const nombre = p.usuarios?.nombre || "Sin asignar";
      const uid    = p.atendido_por || 0;
      if (!map[uid]) map[uid] = { nombre, ventas:0, transacciones:0 };
      map[uid].ventas += parseFloat(p.total||0);
      map[uid].transacciones++;
    });
    const arr = Object.entries(map).map(([uid,v])=>({
      uid, nombre:v.nombre,
      ventas:v.ventas,
      transacciones:v.transacciones,
      comision: v.ventas * (pctCom/100),
    })).sort((a,b)=>b.ventas-a.ventas);
    setComisiones(arr);
    setLoadCom(false);
  };

  const fetchEmpleados = async () => {
    setLoading(true);
    const tok = sessionStorage.getItem("farmacapital_session_token");
    const { data, error } = await supabase.rpc("admin_listar_empleados", { p_session_token: tok });
    if (!error && data) {
      setEmpleados(data);
      setSchedule(prev => {
        const updated = { ...prev };
        data.forEach(e => { if (!updated[e.id]) updated[e.id] = Array(7).fill(false); });
        return updated;
      });
    }
    setLoading(false);
  };

  useEffect(() => { fetchEmpleados(); }, []);

  const toggleEstado = async (emp) => {
    const tok = sessionStorage.getItem("farmacapital_session_token");
    const { error } = await supabase.rpc("admin_toggle_empleado", {
      p_session_token: tok, p_empleado_id: emp.id, p_estado: !emp.estado,
    });
    if (error) alert("Error: "+error.message);
    fetchEmpleados();
  };

  const deleteEmp = async (id) => {
    if (!window.confirm('¿Eliminar este empleado? Esta acción no se puede deshacer.')) return;
    const tok = sessionStorage.getItem("farmacapital_session_token");
    const { error } = await supabase.rpc("admin_eliminar_empleado", {
      p_session_token: tok, p_empleado_id: id,
    });
    if (error) alert("Error: "+error.message);
    fetchEmpleados();
  };

  const handleFormSubmit = async (e) => {
    e.preventDefault(); setFormMsg(null);
    if (!form.nombre.trim()) { setFormMsg({ ok:false, text:'El nombre es obligatorio.' }); return; }
    const tok = sessionStorage.getItem("farmacapital_session_token");
    if (!tok) { setFormMsg({ ok:false, text:'Sesión expirada.' }); return; }
    const { error } = await supabase.rpc("admin_crear_empleado", {
      p_session_token: tok,
      p_nombre: form.nombre.trim(),
      p_telefono: form.telefono.trim() || null,
      p_rol: form.rol,
      p_turno: form.turno,
      p_salario_quincenal: parseFloat(form.salario_quincenal) || 0,
    });
    if (error) setFormMsg({ ok:false, text:`Error: ${error.message}` });
    else { setFormMsg({ ok:true, text:'✅ Empleado registrado.' }); setForm(emptyForm); fetchEmpleados(); }
  };

  const selEmp = empleados.find(e => String(e.id) === String(selEmpId));
  useEffect(() => { if (selEmp) setCalcBase(parseFloat(selEmp.salario_quincenal) || 0); }, [selEmpId]);

  const imss         = calcBase * 0.02375;
  const isr          = calcBase * 0.08;
  const montoHE      = calcHE * 50;
  const percepciones = calcBase + montoHE + parseFloat(calcPD || 0) + parseFloat(calcBono || 0);
  const deducciones  = imss + isr;
  const neto         = percepciones - deducciones;

  const guardarNomina = async () => {
    if (!selEmp) { setNominaMsg({ ok:false, text:'Selecciona un empleado.' }); return; }
    const { inicio, fin } = getQuincena();
    const tok = sessionStorage.getItem("farmacapital_session_token");
    if (!tok) { setNominaMsg({ ok:false, text:'Sesión expirada.' }); return; }
    const { error } = await supabase.rpc("registrar_nomina", {
      p_session_token: tok,
      p_empleado_id: selEmp.id,
      p_periodo_inicio: inicio,
      p_periodo_fin: fin,
      p_salario_base: calcBase,
      p_horas_extra: parseFloat(calcHE) || 0,
      p_prima_dominical: parseFloat(calcPD) || 0,
      p_bono: parseFloat(calcBono) || 0,
      p_total_percepciones: percepciones,
      p_imss_obrero: imss,
      p_isr: isr,
      p_total_deducciones: deducciones,
      p_neto_pagar: neto,
    });
    if (error) setNominaMsg({ ok:false, text:`Error: ${error.message}` });
    else       setNominaMsg({ ok:true,  text:`✅ Nómina guardada para ${selEmp.nombre}.` });
  };

  const exportarTXT = () => {
    if (!selEmp) return;
    const { inicio, fin } = getQuincena();
    const L = '─'.repeat(44);
    const txt = [
      '╔══════════════════════════════════════════╗',
      '║         FARMACAPITAL — NÓMINA QUINCENAL        ║',
      '╚══════════════════════════════════════════╝',
      '', `Empleado : ${selEmp.nombre}`, `Rol      : ${selEmp.rol}`,
      `Turno    : ${selEmp.turno}`, `Periodo  : ${inicio}  →  ${fin}`, '',
      L, 'PERCEPCIONES', L,
      `  Salario base          : ${fmt(calcBase)}`,
      `  Horas extra (${calcHE}h × $50) : ${fmt(montoHE)}`,
      `  Prima dominical       : ${fmt(calcPD)}`,
      `  Bono                  : ${fmt(calcBono)}`,
      `  TOTAL PERCEPCIONES    : ${fmt(percepciones)}`, '',
      L, 'DEDUCCIONES', L,
      `  IMSS obrero (2.375%)  : ${fmt(imss)}`,
      `  ISR estimado (8%)     : ${fmt(isr)}`,
      `  TOTAL DEDUCCIONES     : ${fmt(deducciones)}`, '',
      L, `  NETO A PAGAR          : ${fmt(neto)}`, L, '',
      `Generado: ${new Date().toLocaleString('es-MX')}`,
      'FarmaCapital · Chinampac de Juárez · CDMX',
    ].join('\n');
    const blob = new Blob([txt], { type:'text/plain;charset=utf-8' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a'); a.href = url; a.download = `nomina_${selEmp.nombre.replace(/ /g,'_')}_${inicio}.txt`; a.click();
    URL.revokeObjectURL(url);
  };

  const rolColor = r => ({ admin:'#9d6fff', vendedor:C.blue, doctora:C.green, farmaceutico:C.amber }[r] || C.textMid);

  return (
    <>
    <div style={S.wrap}>
      <div style={{ marginBottom:24 }}>
        <h1 style={{ fontSize:22, fontWeight:800, color:C.text, margin:0 }}>◑ Recursos Humanos</h1>
        <p style={{ color:C.textMid, margin:'4px 0 0', fontSize:13 }}>Empleados · Horarios · Nómina quincenal — FarmaCapital</p>
      </div>

      {/* LISTA EMPLEADOS */}
      <div style={S.section}>
        <div style={S.h2}>📋 Empleados registrados</div>
        {loading ? <p style={{ color:C.textMid }}>Cargando…</p> :
         !empleados.length ? <p style={{ color:C.textMid }}>No hay empleados. Registra el primero abajo.</p> : isMobile ? (
          <div style={{ display:'flex', flexDirection:'column', gap:12 }}>
            {empleados.map(emp => (
              <div
                key={emp.id}
                style={{
                  border:`1px solid ${C.border}`,
                  borderRadius:12,
                  padding:14,
                  background:C.bg,
                }}
              >
                <div style={{ fontWeight:800, fontSize:15, color:C.text, lineHeight:1.35, wordBreak:'break-word', marginBottom:10 }}>
                  {emp.nombre}
                </div>
                <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap:8, fontSize:12, marginBottom:10 }}>
                  <div>
                    <div style={{ ...S.label, marginBottom:2 }}>Teléfono</div>
                    <div style={{ color:C.textMid, wordBreak:'break-all' }}>{emp.telefono || '—'}</div>
                  </div>
                  <div>
                    <div style={{ ...S.label, marginBottom:2 }}>Rol</div>
                    <span style={{ background:rolColor(emp.rol)+'22', color:rolColor(emp.rol), padding:'3px 10px', borderRadius:20, fontSize:11, fontWeight:700, textTransform:'capitalize', display:'inline-block' }}>{emp.rol}</span>
                  </div>
                  <div>
                    <div style={{ ...S.label, marginBottom:2 }}>Turno</div>
                    <div style={{ color:C.textMid, textTransform:'capitalize' }}>{emp.turno}</div>
                  </div>
                  <div>
                    <div style={{ ...S.label, marginBottom:2 }}>Salario qna.</div>
                    <div style={{ fontWeight:700, color:C.green }}>{fmt(emp.salario_quincenal)}</div>
                  </div>
                </div>
                <div style={{ display:'flex', flexWrap:'wrap', alignItems:'center', justifyContent:'space-between', gap:8, paddingTop:10, borderTop:`1px solid ${C.border}` }}>
                  <span style={{ background: emp.estado?'#16a34a22':'#e0525222', color:emp.estado?C.green:C.red, padding:'4px 10px', borderRadius:20, fontSize:11, fontWeight:700 }}>
                    {emp.estado ? '● Activo' : '● Inactivo'}
                  </span>
                  <div style={{ display:'flex', gap:6, alignItems:'center' }}>
                    <button
                      type="button"
                      onClick={() => toggleEstado(emp)}
                      title={emp.estado ? "Desactivar" : "Activar"}
                      aria-label={emp.estado ? "Desactivar empleado" : "Activar empleado"}
                      style={{
                        ...actionBtnBase,
                        marginLeft: 0,
                        width:36,
                        height:36,
                        border: `1px solid ${emp.estado ? C.red : C.green}`,
                        background: "transparent",
                        color: emp.estado ? C.red : C.green,
                      }}
                    >
                      {emp.estado ? (
                        <svg width="11" height="11" viewBox="0 0 24 24" fill="none" aria-hidden="true">
                          <circle cx="12" cy="12" r="9" stroke="currentColor" strokeWidth="2"/>
                          <path d="M8 8l8 8" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
                        </svg>
                      ) : (
                        <svg width="11" height="11" viewBox="0 0 24 24" fill="none" aria-hidden="true">
                          <circle cx="12" cy="12" r="9" stroke="currentColor" strokeWidth="2"/>
                          <path d="M8 12l3 3 5-6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
                        </svg>
                      )}
                    </button>
                    <button
                      type="button"
                      onClick={() => deleteEmp(emp.id)}
                      title="Eliminar empleado"
                      aria-label="Eliminar empleado"
                      style={{
                        ...actionBtnBase,
                        width:36,
                        height:36,
                        border: `1px solid ${C.red}30`,
                        background: C.redDim,
                        color: C.red,
                      }}
                    >
                      <svg width="11" height="11" viewBox="0 0 24 24" fill="none" aria-hidden="true">
                        <path d="M3 6h18" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
                        <path d="M8 6V4h8v2M7 6l1 14h8l1-14" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
                      </svg>
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        ) : (
          <div style={{ overflowX:'auto' }}>
            <table style={{ width:'100%', borderCollapse:'collapse' }}>
              <thead><tr>
                {['Nombre','Teléfono','Rol','Turno','Salario Qna.','Estado','Acciones'].map(h =>
                  <th key={h} style={S.th}>{h}</th>)}
              </tr></thead>
              <tbody>
                {empleados.map(emp => (
                  <tr key={emp.id}
                    onMouseEnter={e=>{ e.currentTarget.style.background = C.blueDim; }}
                    onMouseLeave={e=>{ e.currentTarget.style.background = "transparent"; }}>
                    <td style={{ ...S.td, fontWeight:700 }}>{emp.nombre}</td>
                    <td style={{ ...S.td, color:C.textMid }}>{emp.telefono || '—'}</td>
                    <td style={S.td}>
                      <span style={{ background:rolColor(emp.rol)+'22', color:rolColor(emp.rol), padding:'3px 10px', borderRadius:20, fontSize:11, fontWeight:700, textTransform:'capitalize' }}>{emp.rol}</span>
                    </td>
                    <td style={{ ...S.td, color:C.textMid, fontSize:12, textTransform:'capitalize' }}>{emp.turno}</td>
                    <td style={{ ...S.td, fontWeight:700, color:C.green }}>{fmt(emp.salario_quincenal)}</td>
                    <td style={S.td}>
                      <span style={{ background: emp.estado?'#16a34a22':'#e0525222', color:emp.estado?C.green:C.red, padding:'3px 10px', borderRadius:20, fontSize:11, fontWeight:700 }}>
                        {emp.estado ? '● Activo' : '● Inactivo'}
                      </span>
                    </td>
                    <td style={{ ...S.td }}>
                      <div style={{ display:'flex', gap:6, alignItems:'center' }}>
                        <button
                          type="button"
                          onClick={() => toggleEstado(emp)}
                          title={emp.estado ? "Desactivar" : "Activar"}
                          aria-label={emp.estado ? "Desactivar empleado" : "Activar empleado"}
                          style={{
                            ...actionBtnBase,
                            marginLeft: 0,
                            border: `1px solid ${emp.estado ? C.red : C.green}`,
                            background: "transparent",
                            color: emp.estado ? C.red : C.green,
                          }}
                        >
                          {emp.estado ? (
                            <svg width="11" height="11" viewBox="0 0 24 24" fill="none" aria-hidden="true">
                              <circle cx="12" cy="12" r="9" stroke="currentColor" strokeWidth="2"/>
                              <path d="M8 8l8 8" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
                            </svg>
                          ) : (
                            <svg width="11" height="11" viewBox="0 0 24 24" fill="none" aria-hidden="true">
                              <circle cx="12" cy="12" r="9" stroke="currentColor" strokeWidth="2"/>
                              <path d="M8 12l3 3 5-6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
                            </svg>
                          )}
                        </button>
                        <button
                          type="button"
                          onClick={() => deleteEmp(emp.id)}
                          title="Eliminar empleado"
                          aria-label="Eliminar empleado"
                          style={{
                            ...actionBtnBase,
                            border: `1px solid ${C.red}30`,
                            background: C.redDim,
                            color: C.red,
                          }}
                        >
                          <svg width="11" height="11" viewBox="0 0 24 24" fill="none" aria-hidden="true">
                            <path d="M3 6h18" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
                            <path d="M8 6V4h8v2M7 6l1 14h8l1-14" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
                          </svg>
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* NUEVO EMPLEADO */}
      <div style={S.section}>
        <div style={S.h2}>➕ Registrar nuevo empleado</div>
        <form onSubmit={handleFormSubmit}>
          <div style={{ display:'grid', gridTemplateColumns:'repeat(auto-fit, minmax(min(100%, 170px), 1fr))', gap:14, marginBottom:14 }}>
            <div><label style={S.label}>Nombre completo *</label>
              <input style={S.input} value={form.nombre} onChange={e=>setForm({...form,nombre:e.target.value})} placeholder="Ana García López"/></div>
            <div><label style={S.label}>Teléfono</label>
              <input style={S.input} value={form.telefono} onChange={e=>setForm({...form,telefono:e.target.value})} placeholder="5512345678"/></div>
            <div><label style={S.label}>Rol *</label>
              <select style={S.select} value={form.rol} onChange={e=>setForm({...form,rol:e.target.value})}>
                <option value="vendedor">Vendedor</option>
                <option value="doctora">Doctora / Doctor</option>
                <option value="farmaceutico">Farmacéutico</option>
                <option value="admin">Administrador</option>
              </select></div>
            <div><label style={S.label}>Turno *</label>
              <select style={S.select} value={form.turno} onChange={e=>setForm({...form,turno:e.target.value})}>
                <option value="matutino">Matutino 8:00–16:00</option>
                <option value="vespertino">Vespertino 16:00–22:00</option>
                <option value="nocturno">Nocturno 22:00–8:00</option>
              </select></div>
            <div><label style={S.label}>Salario quincenal *</label>
              <input style={S.input} type="number" min="0" step="0.01" value={form.salario_quincenal} onChange={e=>setForm({...form,salario_quincenal:e.target.value})} placeholder="3500.00"/></div>
          </div>
          <button type="submit" style={{ ...S.btnBlue, width:'100%', padding:12, fontSize:14 }}>➕ Registrar empleado</button>
          {formMsg && <p style={{ marginTop:10, color:formMsg.ok?C.green:C.red, fontSize:13, fontWeight:700 }}>{formMsg.text}</p>}
        </form>
      </div>

      {/* HORARIO SEMANAL */}
      <div style={S.section}>
        <div style={S.h2}>📅 Horario semanal</div>
        {!empleados.length ? <p style={{ color:C.textMid }}>Registra empleados primero.</p> : isMobile ? (
          <div style={{ display:'flex', flexDirection:'column', gap:8 }}>
            {empleados.map(emp => {
              const dias = schedule[emp.id] || Array(7).fill(false);
              const total = dias.filter(Boolean).length;
              const open = horarioAbierto === emp.id;
              return (
                <div key={emp.id} style={{ border:`1px solid ${C.border}`, borderRadius:12, overflow:'hidden', background:C.bg }}>
                  <button
                    type="button"
                    onClick={() => setHorarioAbierto(open ? null : emp.id)}
                    style={{
                      width:'100%',
                      display:'flex',
                      alignItems:'center',
                      justifyContent:'space-between',
                      gap:12,
                      padding:'12px 14px',
                      border:'none',
                      background:C.card,
                      cursor:'pointer',
                      textAlign:'left',
                      fontFamily:"inherit",
                    }}
                  >
                    <span style={{ fontWeight:700, color:C.text, fontSize:14, lineHeight:1.35, wordBreak:'break-word', flex:1, minWidth:0 }}>{emp.nombre}</span>
                    <span style={{
                      fontWeight:800,
                      fontSize:12,
                      color:total>=5?C.green:total>=3?C.amber:C.textMid,
                      flexShrink:0,
                    }}>{total} días {open ? '▲' : '▼'}</span>
                  </button>
                  {open && (
                    <div style={{ padding:'12px 14px 14px', borderTop:`1px solid ${C.border}` }}>
                      {DIAS.map((d, idx) => (
                        <label
                          key={d}
                          style={{
                            display:'flex',
                            alignItems:'center',
                            gap:12,
                            padding:'8px 0',
                            borderBottom: idx < DIAS.length - 1 ? `1px solid ${C.border}` : 'none',
                            cursor:'pointer',
                            fontSize:13,
                            color:C.text,
                          }}
                        >
                          <input
                            type="checkbox"
                            checked={dias[idx]}
                            style={{ accentColor:C.green, width:18, height:18, cursor:'pointer', flexShrink:0 }}
                            onChange={()=>{
                              const updated=[...dias]; updated[idx]=!updated[idx];
                              setSchedule(prev=>({ ...prev, [emp.id]:updated }));
                            }}
                          />
                          <span style={{ fontWeight:600 }}>{d}</span>
                        </label>
                      ))}
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        ) : (
          <div style={{ overflowX:'auto' }}>
            <table style={{ width:'100%', borderCollapse:'collapse' }}>
              <thead><tr>
                <th style={S.th}>Empleado</th>
                {DIAS.map(d=><th key={d} style={{ ...S.th, textAlign:'center' }}>{d}</th>)}
                <th style={{ ...S.th, textAlign:'center' }}>Días</th>
              </tr></thead>
              <tbody>
                {empleados.map(emp => {
                  const dias = schedule[emp.id] || Array(7).fill(false);
                  const total = dias.filter(Boolean).length;
                  return (
                    <tr key={emp.id}
                      onMouseEnter={e=>{ e.currentTarget.style.background = C.blueDim; }}
                      onMouseLeave={e=>{ e.currentTarget.style.background = "transparent"; }}>
                      <td style={{ ...S.td, fontWeight:700, whiteSpace:'nowrap' }}>{emp.nombre}</td>
                      {dias.map((checked,idx)=>(
                        <td key={idx} style={{ ...S.td, textAlign:'center' }}>
                          <input type="checkbox" checked={checked} style={{ accentColor:C.green, width:16, height:16, cursor:'pointer' }}
                            onChange={()=>{
                              const updated=[...dias]; updated[idx]=!updated[idx];
                              setSchedule(prev=>({ ...prev, [emp.id]:updated }));
                            }}/>
                        </td>
                      ))}
                      <td style={{ ...S.td, textAlign:'center', fontWeight:800,
                        color:total>=5?C.green:total>=3?C.amber:C.textMid }}>{total}d</td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* CALCULADORA NÓMINA */}
      <div style={S.section}>
        <div style={S.h2}>💰 Calculadora nómina quincenal</div>
        <div style={{ display:'grid', gridTemplateColumns:'repeat(auto-fit, minmax(min(100%, 160px), 1fr))', gap:14, marginBottom:20 }}>
          <div><label style={S.label}>Empleado</label>
            <select style={S.select} value={selEmpId} onChange={e=>setSelEmpId(e.target.value)}>
              <option value="">— Seleccionar —</option>
              {empleados.map(e=><option key={e.id} value={e.id}>{e.nombre}</option>)}
            </select></div>
          <div><label style={S.label}>Salario base</label>
            <input style={S.input} type="number" min="0" step="0.01" value={calcBase} onChange={e=>setCalcBase(parseFloat(e.target.value)||0)}/></div>
          <div><label style={S.label}>Horas extra</label>
            <input style={S.input} type="number" min="0" step="0.5" value={calcHE} onChange={e=>setCalcHE(parseFloat(e.target.value)||0)} placeholder="0"/></div>
          <div><label style={S.label}>Prima dominical</label>
            <input style={S.input} type="number" min="0" step="0.01" value={calcPD} onChange={e=>setCalcPD(e.target.value)} placeholder="0"/></div>
          <div><label style={S.label}>Bono</label>
            <input style={S.input} type="number" min="0" step="0.01" value={calcBono} onChange={e=>setCalcBono(e.target.value)} placeholder="0"/></div>
        </div>

        <div style={{ background:C.bg, border:`1px solid ${C.border}`, borderRadius:10, padding:20, marginBottom:16 }}>
          <div style={{
            display:isMobile ? 'flex' : 'grid',
            flexDirection:isMobile ? 'column' : undefined,
            gridTemplateColumns:isMobile ? undefined : '1fr 1fr',
            gap:isMobile ? 20 : '0 32px',
          }}>
            <div style={{ minWidth:0 }}>
              <p style={{ fontSize:11, color:C.textMid, fontWeight:700, textTransform:'uppercase', marginBottom:12 }}>📈 Percepciones</p>
              {[['Salario base',fmt(calcBase)],[`Horas extra (${calcHE}h × $50)`,fmt(montoHE)],['Prima dominical',fmt(calcPD)],['Bono',fmt(calcBono)]].map(([lbl,val])=>(
                <div key={lbl} style={{ display:'flex', justifyContent:'space-between', alignItems:'flex-start', gap:10, padding:'5px 0', borderBottom:`1px solid ${C.border}` }}>
                  <span style={{ fontSize:12, color:C.textMid, flex:'1 1 auto', minWidth:0, lineHeight:1.4 }}>{lbl}</span>
                  <span style={{ fontSize:12, color:C.text, fontWeight:600, flexShrink:0, textAlign:'right' }}>{val}</span>
                </div>
              ))}
              <div style={{ display:'flex', justifyContent:'space-between', gap:10, padding:'10px 0 0', flexWrap:'wrap' }}>
                <span style={{ fontWeight:700, color:C.green, fontSize:13 }}>Total percepciones</span>
                <span style={{ fontWeight:800, color:C.green, fontSize:15 }}>{fmt(percepciones)}</span>
              </div>
            </div>
            <div style={{ minWidth:0, paddingTop:isMobile ? 4 : 0, borderTop:isMobile ? `1px solid ${C.border}` : 'none' }}>
              <p style={{ fontSize:11, color:C.textMid, fontWeight:700, textTransform:'uppercase', marginBottom:12, marginTop:isMobile ? 4 : 0 }}>📉 Deducciones</p>
              {[['IMSS obrero (2.375%)',fmt(imss)],['ISR estimado (8%)',fmt(isr)]].map(([lbl,val])=>(
                <div key={lbl} style={{ display:'flex', justifyContent:'space-between', alignItems:'flex-start', gap:10, padding:'5px 0', borderBottom:`1px solid ${C.border}` }}>
                  <span style={{ fontSize:12, color:C.textMid, flex:'1 1 auto', minWidth:0, lineHeight:1.4 }}>{lbl}</span>
                  <span style={{ fontSize:12, color:C.red, fontWeight:600, flexShrink:0, textAlign:'right' }}>{val}</span>
                </div>
              ))}
              <div style={{ display:'flex', justifyContent:'space-between', gap:10, padding:'8px 0', borderBottom:`1px solid ${C.border}`, flexWrap:'wrap' }}>
                <span style={{ fontWeight:700, color:C.red, fontSize:13 }}>Total deducciones</span>
                <span style={{ fontWeight:800, color:C.red, fontSize:14 }}>{fmt(deducciones)}</span>
              </div>
              <div style={{ display:'flex', justifyContent:'space-between', alignItems:'baseline', gap:10, padding:'14px 0 0', flexWrap:'wrap' }}>
                <span style={{ fontWeight:800, fontSize:15, color:C.text }}>💵 Neto a pagar</span>
                <span style={{ fontWeight:900, fontSize: isMobile ? 18 : 20, color:C.green, wordBreak:'break-word', textAlign:'right' }}>{fmt(neto)}</span>
              </div>
            </div>
          </div>
        </div>

        <div style={{ display:'flex', gap:10, flexWrap:'wrap' }}>
          <button style={S.btnBlue} onClick={guardarNomina}>💾 Guardar nómina</button>
          <button style={{ ...S.btnGreen, opacity:selEmp?1:.5, cursor:selEmp?'pointer':'not-allowed' }} onClick={exportarTXT} disabled={!selEmp}>📥 Exportar TXT</button>
        </div>
        {nominaMsg && <p style={{ marginTop:10, color:nominaMsg.ok?C.green:C.red, fontSize:13, fontWeight:700 }}>{nominaMsg.text}</p>}
      </div>
    </div>

    {/* ── COMISIONES POR VENTAS ── */}
    <div style={{background:C.card,border:`1px solid ${C.border}`,borderRadius:14,padding:24,marginTop:24}}>
      <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:16,flexWrap:"wrap",gap:10}}>
        <h2 style={{margin:0,color:C.text,fontSize:16,fontWeight:800}}>💰 Comisiones por ventas</h2>
        <div style={{display:"flex",gap:8,alignItems:"center",flexWrap:"wrap"}}>
          {[["dia","Hoy"],["semana","7 días"],["mes","30 días"]].map(([v,l])=>(
            <button key={v} onClick={()=>setPeriCom(v)} style={{
              padding:"5px 12px",borderRadius:20,border:`1px solid ${periCom===v?C.blue:C.border}`,
              background:periCom===v?C.blueDim:"transparent",color:periCom===v?C.blue:C.textMid,
              fontSize:11,fontWeight:700,cursor:"pointer"
            }}>{l}</button>
          ))}
          <div style={{display:"flex",alignItems:"center",gap:6}}>
            <span style={{color:C.textMid,fontSize:11}}>% comisión:</span>
            <input type="number" min="0" max="20" step="0.5" value={pctCom}
              onChange={e=>setPctCom(parseFloat(e.target.value)||0)}
              style={{width:56,padding:"4px 8px",borderRadius:6,border:`1px solid ${C.border}`,fontSize:12,outline:"none",background:C.card,color:C.text}}/>
          </div>
          <button onClick={fetchComisiones} style={{padding:"6px 14px",borderRadius:8,border:"none",background:C.blue,color:"#fff",fontWeight:700,fontSize:12,cursor:"pointer"}}>
            {loadCom?"Cargando…":"🔄 Calcular"}
          </button>
        </div>
      </div>
      {comisiones.length===0?(
        <div style={{color:C.textMid,textAlign:"center",padding:32,fontSize:13}}>
          Presiona "Calcular" para ver las comisiones del período.
        </div>
      ):(
        <>
        <div style={{overflowX:"auto",borderRadius:10,border:`1px solid ${C.border}`,marginBottom:16}}>
          <table style={{width:"100%",borderCollapse:"collapse",fontSize:13}}>
            <thead>
              <tr style={{background:C.cardDark}}>
                {["Empleado","Ventas","Transacciones","Ticket prom.",`Comisión (${pctCom}%)`].map(h=>(
                  <th key={h} style={{padding:"9px 14px",textAlign:"left",color:C.textMid,fontWeight:700,borderBottom:`1px solid ${C.border}`,whiteSpace:"nowrap"}}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {comisiones.map((c,i)=>(
                <tr key={c.uid} style={{background:i%2===0?"transparent":"#f8fafc"}}>
                  <td style={{padding:"10px 14px",color:C.text,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{c.nombre}</td>
                  <td style={{padding:"10px 14px",color:C.green,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{fmt(c.ventas)}</td>
                  <td style={{padding:"10px 14px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{c.transacciones}</td>
                  <td style={{padding:"10px 14px",color:C.blue,borderBottom:`1px solid ${C.border}`}}>{fmt(c.transacciones?c.ventas/c.transacciones:0)}</td>
                  <td style={{padding:"10px 14px",borderBottom:`1px solid ${C.border}`}}>
                    <span style={{background:C.greenDim,color:C.green,fontWeight:800,padding:"3px 10px",borderRadius:8}}>{fmt(c.comision)}</span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        <div style={{display:"flex",gap:12,flexWrap:"wrap"}}>
          {[
            {label:"Total ventas",value:fmt(comisiones.reduce((a,c)=>a+c.ventas,0)),col:C.blue},
            {label:"Total comisiones",value:fmt(comisiones.reduce((a,c)=>a+c.comision,0)),col:C.green},
            {label:"Empleados",value:comisiones.length,col:C.purple},
          ].map(k=>(
            <div key={k.label} style={{background:C.card,border:`1px solid ${C.border}`,borderRadius:10,padding:"12px 18px",flex:1,minWidth:120}}>
              <div style={{color:C.textDim,fontSize:10,fontWeight:700}}>{k.label.toUpperCase()}</div>
              <div style={{color:k.col,fontWeight:900,fontSize:20,marginTop:4}}>{k.value}</div>
            </div>
          ))}
        </div>
        </>
      )}
    </div>
  </>
  );
}
