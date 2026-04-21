import { useState, useEffect, useCallback } from "react";
import { C_LIGHT } from "./constants";
import { supabase } from "./supabase";
import { SkeletonTable, Paginador, SearchDropdown, showToast } from "./ui";

const BRAND = { primary:"#0052cc", secondary:"#0099e6", gradient:"linear-gradient(135deg,#0052cc,#0099e6)" };

const fmt     = (n) => `$${parseFloat(n||0).toLocaleString("es-MX",{minimumFractionDigits:2,maximumFractionDigits:2})}`;
const fmtDate = (s) => s ? new Date(s).toLocaleDateString("es-MX",{day:"2-digit",month:"short",year:"numeric"}) : "—";

const mkInputStyle = (C) => ({ width:"100%", padding:"8px 11px", borderRadius:7, border:`1px solid ${C.border}`, background:C.bg, color:C.text, fontSize:12, outline:"none", boxSizing:"border-box" });
const mkLabelStyle = (C) => ({ color:C.textMid, fontSize:10, fontWeight:700, marginBottom:3, display:"block", letterSpacing:.4 });
const mkBtnPrimary = (C) => ({ padding:"9px 18px", borderRadius:8, border:"none", cursor:"pointer", background:BRAND.gradient, color:"#fff", fontWeight:700, fontSize:12 });
const mkBtnSecondary = (C) => ({ padding:"8px 16px", borderRadius:8, cursor:"pointer", fontWeight:700, fontSize:12, border:`1px solid ${C.border}`, background:"transparent", color:C.textMid });
const mkBtnGreen = (C) => ({ padding:"9px 18px", borderRadius:8, border:"none", cursor:"pointer", background:C.green, color:"#fff", fontWeight:700, fontSize:12 });

function Avatar({nombre, puntos, size=36 }) {
  const C = C_LIGHT;
  const inputStyle = mkInputStyle(C);
  const labelStyle = mkLabelStyle(C);
  const btnSecondary = mkBtnSecondary(C);
  const btnPrimary = mkBtnPrimary(C);
  const btnGreen = mkBtnGreen(C);
  const col = puntos > 100 ? C.green : puntos > 0 ? C.blue : C.textMid;
  return (
    <div style={{ width:size, height:size, borderRadius:"50%", background:col+"22",
      border:`2px solid ${col}40`, display:"flex", alignItems:"center", justifyContent:"center",
      color:col, fontWeight:800, fontSize:size*0.4, flexShrink:0 }}>
      {(nombre||"?")[0].toUpperCase()}
    </div>
  );
}

function AgregarCliente({ onSaved, onCancel }) {
  const C = C_LIGHT;
  const [form, setForm]     = useState({ nombre:"", telefono:"", email:"", notas:"" });
  const [errors, setErrors] = useState({});
  const [saving, setSaving] = useState(false);
  const set = (k,v) => setForm(f=>({...f,[k]:v}));
  const handleSave = async () => {
    const e = {};
    if (!form.nombre.trim())   e.nombre   = "Requerido";
    if (!form.telefono.trim()) e.telefono = "Requerido";
    if (Object.keys(e).length) { setErrors(e); return; }
    setSaving(true);
    const tok = sessionStorage.getItem("farmax_session_token");
    if (!tok) { setSaving(false); showToast("Sesión expirada.","error"); return; }
    const { data: resp, error } = await supabase.rpc("admin_crear_cliente_manual", {
      p_session_token: tok,
      p_nombre:   form.nombre.trim(),
      p_telefono: form.telefono.trim(),
      p_email:    form.email.trim() || null,
      p_notas:    form.notas.trim() || null,
    });
    setSaving(false);
    if (error || !resp?.success) {
      showToast("Error al guardar cliente: "+(resp?.error||error?.message),"error");
      return;
    }
    onSaved(resp.cliente || resp);
  };
  const field = (label, key, type="text", required=false, multiline=false) => (
    <div style={{ marginBottom:14 }}>
      <label style={labelStyle}>{label}{required&&<span style={{color:C.red}}> *</span>}</label>
      {multiline
        ? <textarea value={form[key]} onChange={e=>set(key,e.target.value)} rows={3} style={{...inputStyle,resize:"vertical",lineHeight:1.5}}/>
        : <input type={type} value={form[key]} onChange={e=>set(key,e.target.value)} style={{...inputStyle,borderColor:errors[key]?C.red:C.border}}/>
      }
      {errors[key]&&<span style={{color:C.red,fontSize:10}}>{errors[key]}</span>}
    </div>
  );
  return (
    <div style={{ padding:24 }}>
      <div style={{ display:"flex", justifyContent:"space-between", alignItems:"center", marginBottom:20 }}>
        <h2 style={{ margin:0, color:C.text, fontSize:16, fontWeight:800 }}>➕ Agregar cliente</h2>
        <button onClick={onCancel} style={{ background:"none", border:"none", color:C.textMid, fontSize:18, cursor:"pointer" }}>✕</button>
      </div>
      {field("Nombre completo","nombre","text",true)}
      {field("Teléfono","telefono","tel",true)}
      {field("Email","email","email")}
      {field("Notas","notas","text",false,true)}
      <div style={{ display:"flex", gap:10, justifyContent:"flex-end", marginTop:8 }}>
        <button style={btnSecondary} onClick={onCancel}>Cancelar</button>
        <button style={btnPrimary} onClick={handleSave} disabled={saving}>{saving?"Guardando…":"💾 Guardar cliente"}</button>
      </div>
    </div>
  );
}

function ClienteDetalle({ cliente, onReload }) {
  const C = C_LIGHT;
  const [tab,      setTab]     = useState("compras");
  const [pedidos,  setPedidos] = useState([]);
  const [citas,    setCitas]   = useState([]);
  const [loading,  setLoading] = useState(false);
  const [expanded, setExpanded]= useState(null);
  const [ajuste,   setAjuste]  = useState("");
  const [motivo,   setMotivo]  = useState("");
  const [nota,     setNota]    = useState(cliente.notas||"");
  const [saving,   setSaving]  = useState(false);
  const [msg,      setMsg]     = useState("");

  const fetchDetalle = useCallback(async () => {
    setLoading(true);
    const [{ data:ped }, { data:cit }] = await Promise.all([
      supabase.from("pedidos").select("*, pedido_items(*, productos(*))").eq("cliente_id", cliente.id).order("created_at",{ascending:false}).limit(20),
      supabase.from("citas").select("*").eq("telefono", cliente.telefono).order("created_at",{ascending:false}).limit(10),
    ]);
    setPedidos(ped||[]);
    setCitas(cit||[]);
    setLoading(false);
  }, [cliente.id, cliente.telefono]);

  useEffect(() => { fetchDetalle(); }, [fetchDetalle]);

  const topProductos = (() => {
    const freq = {};
    pedidos.forEach(p => (p.pedido_items||[]).forEach(it => {
      const n = it.productos?.nombre || it.nombre || "Producto";
      freq[n] = (freq[n]||0) + (it.cantidad||1);
    }));
    return Object.entries(freq).sort((a,b)=>b[1]-a[1]).slice(0,5);
  })();

  const aplicarAjuste = async () => {
    if (!ajuste || !motivo.trim()) { setMsg("⚠ Ingresa cantidad y motivo"); return; }
    setSaving(true);
    const tok = sessionStorage.getItem("farmax_session_token");
    const { data: resp, error } = await supabase.rpc("admin_ajustar_puntos", {
      p_session_token: tok,
      p_cliente_id:    cliente.id,
      p_delta:         parseInt(ajuste),
      p_motivo:        motivo.trim(),
    });
    setSaving(false);
    if (error || !resp?.success) { setMsg("Error: "+(resp?.error||error?.message)); return; }
    setMsg("✅ Puntos actualizados"); setAjuste(""); setMotivo("");
    setTimeout(()=>setMsg(""), 3000); onReload();
  };

  const guardarNota = async () => {
    setSaving(true);
    const tok = sessionStorage.getItem("farmax_session_token");
    const { data: resp, error } = await supabase.rpc("admin_ajustar_nota_cliente", {
      p_session_token: tok,
      p_cliente_id:    cliente.id,
      p_nota:          nota.trim() || null,
    });
    setSaving(false);
    if (error || !resp?.success) { setMsg("Error: "+(resp?.error||error?.message)); return; }
    setMsg("✅ Nota guardada"); setTimeout(()=>setMsg(""), 3000); onReload();
  };

  return (
    <div style={{ flex:1, overflowY:"auto", display:"flex", flexDirection:"column" }}>
      <div style={{ padding:"20px 24px", borderBottom:`1px solid ${C.border}`, background:C.card }}>
        <div style={{ display:"flex", alignItems:"center", gap:14, marginBottom:14 }}>
          <Avatar nombre={cliente.nombre} puntos={cliente.puntos} size={48}/>
          <div style={{ flex:1 }}>
            <div style={{ color:C.text, fontWeight:800, fontSize:16 }}>{cliente.nombre}</div>
            <div style={{ color:C.textMid, fontSize:12, marginTop:2 }}>
              📞 {cliente.telefono}{cliente.email&&<span style={{marginLeft:12}}>✉ {cliente.email}</span>}
            </div>
            <div style={{ color:C.textDim, fontSize:11, marginTop:2 }}>Registrado: {fmtDate(cliente.created_at||cliente.fecha_registro)}</div>
          </div>
        </div>
        <div style={{ display:"flex", gap:10, flexWrap:"wrap" }}>
          {[
            { label:"Puntos", val:(cliente.puntos||0).toLocaleString(), col:C.amber },
            { label:"Vale en pesos", val:`$${((cliente.puntos||0)*0.5).toFixed(2)}`, col:C.green },
            { label:"Total compras", val:fmt(cliente.total_compras), col:C.blue },
          ].map(s=>(
            <div key={s.label} style={{ background:C.bg, border:`1px solid ${C.border}`, borderRadius:8, padding:"8px 14px", minWidth:100 }}>
              <div style={{ color:s.col, fontWeight:800, fontSize:16 }}>{s.val}</div>
              <div style={{ color:C.textMid, fontSize:10 }}>{s.label}</div>
            </div>
          ))}
        </div>
        {topProductos.length>0&&(
          <div style={{ marginTop:12 }}>
            <div style={{ color:C.textDim, fontSize:10, fontWeight:700, marginBottom:6 }}>PRODUCTOS FRECUENTES</div>
            <div style={{ display:"flex", gap:6, flexWrap:"wrap" }}>
              {topProductos.map(([nombre,veces])=>(
                <span key={nombre} style={{ background:C.blueDim, color:C.blue, borderRadius:20, padding:"2px 10px", fontSize:10, fontWeight:700 }}>
                  {nombre} ×{veces}
                </span>
              ))}
            </div>
          </div>
        )}
      </div>

      <div style={{ display:"flex", gap:2, padding:"0 16px", borderBottom:`1px solid ${C.border}`, background:C.card }}>
        {[["compras","🛒 Compras"],["consultas","♥ Consultas"],["puntos","⭐ Puntos"]].map(([id,label])=>(
          <button key={id} onClick={()=>setTab(id)} style={{
            padding:"9px 16px", border:"none", cursor:"pointer", fontWeight:700, fontSize:12,
            background:"transparent", color:tab===id?C.blue:C.textMid,
            borderBottom:tab===id?`2px solid ${C.blue}`:"2px solid transparent",
          }}>{label}</button>
        ))}
      </div>

      <div style={{ flex:1, overflowY:"auto", padding:20 }}>
        {loading && <SkeletonTable rows={5} cols={5}/>}

        {!loading && tab==="compras" && (
          <div>
            {pedidos.length===0
              ? <div style={{ color:C.textMid, textAlign:"center", padding:32 }}>Sin compras registradas</div>
              : pedidos.map(p=>(
                  <div key={p.id} style={{ background:C.card, border:`1px solid ${C.border}`, borderRadius:10, marginBottom:8, overflow:"hidden" }}>
                    <div onClick={()=>setExpanded(expanded===p.id?null:p.id)}
                      style={{ padding:"10px 14px", cursor:"pointer", display:"flex", justifyContent:"space-between", alignItems:"center" }}>
                      <div>
                        <span style={{ color:C.text, fontWeight:700, fontSize:13 }}>{fmt(p.total)}</span>
                        <span style={{ color:C.textMid, fontSize:11, marginLeft:10 }}>{fmtDate(p.created_at)}</span>
                        <span style={{ color:C.textDim, fontSize:11, marginLeft:10 }}>{p.metodo_pago||"—"}</span>
                      </div>
                      <div style={{ display:"flex", alignItems:"center", gap:8 }}>
                        <span style={{ padding:"2px 8px", borderRadius:20, fontSize:10, fontWeight:700,
                          background:p.estado==="completado"?C.greenDim:C.amberDim,
                          color:p.estado==="completado"?C.green:C.amber }}>{p.estado||"—"}</span>
                        <span style={{ color:C.textMid, fontSize:12 }}>{expanded===p.id?"▲":"▼"}</span>
                      </div>
                    </div>
                    {expanded===p.id&&(
                      <div style={{ borderTop:`1px solid ${C.border}`, padding:"10px 14px", background:C.bg }}>
                        {(p.pedido_items||[]).length===0
                          ? <div style={{ color:C.textMid, fontSize:11 }}>Sin detalle disponible</div>
                          : (p.pedido_items||[]).map((it,idx)=>(
                              <div key={idx} style={{ display:"flex", justifyContent:"space-between", fontSize:11,
                                padding:"4px 0", borderBottom:`1px solid ${C.border}`, color:C.textMid }}>
                                <span style={{ color:C.text }}>{it.productos?.nombre||it.nombre||"Producto"}</span>
                                <span>×{it.cantidad} — {fmt(it.precio_unitario||it.precio||0)}</span>
                              </div>
                            ))
                        }
                      </div>
                    )}
                  </div>
                ))
            }
          </div>
        )}

        {!loading && tab==="consultas" && (
          <div>
            {citas.length===0
              ? <div style={{ color:C.textMid, textAlign:"center", padding:32 }}>Sin consultas registradas</div>
              : citas.map((c,i)=>(
                  <div key={c.id||i} style={{ background:C.card, border:`1px solid ${C.border}`, borderRadius:10, padding:"12px 16px", marginBottom:8 }}>
                    <div style={{ display:"flex", justifyContent:"space-between", alignItems:"flex-start" }}>
                      <div>
                        <div style={{ color:C.text, fontWeight:700, fontSize:13 }}>{c.motivo||"Consulta general"}</div>
                        <div style={{ color:C.textMid, fontSize:11, marginTop:3 }}>{fmtDate(c.fecha)}{c.hora?` · ${c.hora}`:""}</div>
                        {c.diagnostico&&<div style={{ color:C.textMid, fontSize:11, marginTop:6, fontStyle:"italic" }}>Dx: {c.diagnostico}</div>}
                      </div>
                      <span style={{ padding:"2px 10px", borderRadius:20, fontSize:10, fontWeight:700,
                        background:c.estado==="completada"?C.greenDim:C.blueDim,
                        color:c.estado==="completada"?C.green:C.blue }}>{c.estado||"—"}</span>
                    </div>
                  </div>
                ))
            }
          </div>
        )}

        {!loading && tab==="puntos" && (
          <div>
            <div style={{ background:C.card, border:`1px solid ${C.border}`, borderRadius:12, padding:20, marginBottom:16, textAlign:"center" }}>
              <div style={{ color:C.textMid, fontSize:11, fontWeight:700, marginBottom:6 }}>SALDO ACTUAL</div>
              <div style={{ color:C.amber, fontWeight:800, fontSize:40 }}>{(cliente.puntos||0).toLocaleString()}</div>
              <div style={{ color:C.textMid, fontSize:12, marginTop:4 }}>puntos · Vale {fmt((cliente.puntos||0)*0.5)}</div>
            </div>
            <div style={{ background:C.card, border:`1px solid ${C.border}`, borderRadius:12, padding:20, marginBottom:16 }}>
              <div style={{ color:C.text, fontWeight:700, fontSize:13, marginBottom:14 }}>⭐ Ajustar puntos</div>
              <div style={{ display:"grid", gridTemplateColumns:"1fr 1fr", gap:12, marginBottom:12 }}>
                <div>
                  <label style={labelStyle}>CANTIDAD (negativo para restar)</label>
                  <input type="number" value={ajuste} onChange={e=>setAjuste(e.target.value)} placeholder="Ej: 50 o -20" style={inputStyle}/>
                </div>
                <div>
                  <label style={labelStyle}>MOTIVO *</label>
                  <input value={motivo} onChange={e=>setMotivo(e.target.value)} placeholder="Corrección, promoción…" style={inputStyle}/>
                </div>
              </div>
              {ajuste&&<div style={{ color:C.textMid, fontSize:11, marginBottom:10 }}>
                Nuevo saldo: <strong style={{ color:C.amber }}>{((cliente.puntos||0)+parseInt(ajuste||0)).toLocaleString()} pts</strong>
              </div>}
              <button onClick={aplicarAjuste} disabled={saving} style={btnGreen}>{saving?"Guardando…":"✓ Aplicar ajuste"}</button>
            </div>
            <div style={{ background:C.card, border:`1px solid ${C.border}`, borderRadius:12, padding:20 }}>
              <div style={{ color:C.text, fontWeight:700, fontSize:13, marginBottom:12 }}>📝 Nota del cliente</div>
              <textarea value={nota} onChange={e=>setNota(e.target.value)} rows={4}
                placeholder="Alergias, preferencias, información importante…"
                style={{...inputStyle,resize:"vertical",lineHeight:1.6,marginBottom:10}}/>
              <button onClick={guardarNota} disabled={saving} style={btnPrimary}>{saving?"Guardando…":"💾 Guardar nota"}</button>
            </div>
            {msg&&<div style={{ marginTop:12, color:msg.startsWith("✅")?C.green:C.red, fontWeight:700, fontSize:12 }}>{msg}</div>}
          </div>
        )}
      </div>
    </div>
  );
}

export default function ClientesModule() {
  const C = C_LIGHT;
  const inputStyle = mkInputStyle(C);
  const labelStyle = mkLabelStyle(C);
  const btnPrimary = mkBtnPrimary(C);
  const btnSecondary = mkBtnSecondary(C);
  const btnGreen = mkBtnGreen(C);
  const [clientes,   setClientes]   = useState([]);
  const [loading,    setLoading]    = useState(true);
  const [paginaCli, setPaginaCli] = useState(1);
  const CLI_POR_PAG = 50;
  const [busqueda,   setBusqueda]   = useState("");
  const [clienteSel, setClienteSel] = useState(null);
  const [mode,       setMode]       = useState("idle");

  const fetchClientes = useCallback(async () => {
    setLoading(true);
    const tok = sessionStorage.getItem("farmax_session_token");
    if (!tok) {
      showToast("Sesión expirada. Entra de nuevo al admin para ver clientes.", "error");
      setClientes([]);
      setLoading(false);
      return;
    }
    const { data, error } = await supabase.rpc("admin_listar_clientes", { p_session_token: tok });
    if (error) {
      const detail = [error.message, error.details, error.hint].filter(Boolean).join(" — ");
      console.warn("[Clientes] admin_listar_clientes:", detail || error);
      showToast("No se pudo cargar clientes: " + (detail || error.message || "error"), "error");
      setClientes([]);
    } else {
      setClientes(Array.isArray(data) ? data : []);
    }
    setLoading(false);
  }, []);

  useEffect(() => { fetchClientes(); }, [fetchClientes]);

  const reloadSel = async () => {
    await fetchClientes();
    if (clienteSel) {
      const tok = sessionStorage.getItem("farmax_session_token");
      const { data } = await supabase.rpc("admin_obtener_cliente", {
        p_session_token: tok, p_cliente_id: clienteSel.id,
      });
      if (data) setClienteSel(data);
    }
  };

  const filtrados = clientes.filter(c => {
    const q = busqueda.toLowerCase();
    return c.nombre?.toLowerCase().includes(q) || c.telefono?.includes(q);
  });

  return (
    <div style={{ display:"flex", height:"100vh", background:C.bg, fontFamily:"'Plus Jakarta Sans',sans-serif", overflow:"hidden" }}>

      {/* Panel izquierdo */}
      <div style={{ width:360, minWidth:280, borderRight:`1px solid ${C.border}`, display:"flex", flexDirection:"column", background:C.card }}>
        <div style={{ padding:"18px 16px 12px", borderBottom:`1px solid ${C.border}` }}>
          <h1 style={{ margin:"0 0 10px", color:C.text, fontSize:17, fontWeight:800 }}>◉ Clientes</h1>
          <SearchDropdown value={busqueda} onChange={setBusqueda} onSelect={c=>{setBusqueda(c.nombre);setClienteSel(c);}} placeholder="🔍 Buscar por nombre o teléfono…" items={clientes} labelKey="nombre" subKey="telefono" badgeKey="puntos" badgeCol="#7c3aed" style={{flex:1}} emptyMsg="Sin clientes con ese nombre/teléfono"/>
          <div style={{ color:C.textDim, fontSize:10, marginTop:6 }}>{filtrados.length} cliente{filtrados.length!==1?"s":""}</div>
        </div>
        <div style={{ flex:1, overflowY:"auto" }}>
          {loading&&<SkeletonTable rows={5} cols={5}/>}
          {!loading&&filtrados.length===0&&(
            <div style={{ color:C.textMid, textAlign:"center", padding:32 }}>
              {busqueda?`Sin resultados para "${busqueda}"`:"Sin clientes registrados"}
            </div>
          )}
          {filtrados.map(c=>(
            <div key={c.id} onClick={()=>{ setClienteSel(c); setMode("idle"); }}
              style={{ display:"flex", alignItems:"center", gap:12, padding:"11px 16px", cursor:"pointer",
                borderBottom:`1px solid ${C.border}`,
                background:clienteSel?.id===c.id?C.blueDim:"transparent",
                borderLeft:clienteSel?.id===c.id?`3px solid ${C.blue}`:"3px solid transparent",
                transition:"all .12s" }}
              onMouseEnter={e=>{ if(clienteSel?.id!==c.id) e.currentTarget.style.background=C.bg; }}
              onMouseLeave={e=>{ if(clienteSel?.id!==c.id) e.currentTarget.style.background="transparent"; }}>
              <Avatar nombre={c.nombre} puntos={c.puntos} size={36}/>
              <div style={{ flex:1, minWidth:0 }}>
                <div style={{ color:C.text, fontWeight:700, fontSize:13, overflow:"hidden", textOverflow:"ellipsis", whiteSpace:"nowrap" }}>{c.nombre}</div>
                <div style={{ color:C.textMid, fontSize:11 }}>{c.telefono}</div>
              </div>
              {c.puntos>0&&(
                <span style={{ background:C.amberDim, color:C.amber, borderRadius:20, padding:"2px 8px", fontSize:10, fontWeight:700, flexShrink:0 }}>
                  {(c.puntos||0).toLocaleString()} pts
                </span>
              )}
            </div>
          ))}
        </div>
        <div style={{ padding:"12px 16px", borderTop:`1px solid ${C.border}` }}>
          <button onClick={()=>{ setMode("agregar"); setClienteSel(null); }} style={{ ...btnPrimary, width:"100%" }}>
            ➕ Agregar cliente
          </button>
        </div>
      </div>

      {/* Panel derecho */}
      <div style={{ flex:1, overflow:"hidden", display:"flex", flexDirection:"column" }}>
        {mode==="agregar"&&(
          <AgregarCliente onCancel={()=>setMode("idle")}
            onSaved={async (nuevo)=>{ await fetchClientes(); setClienteSel(nuevo); setMode("idle"); }}/>
        )}
        {mode==="idle"&&clienteSel&&(
          <ClienteDetalle key={clienteSel.id} cliente={clienteSel} onReload={reloadSel}/>
        )}
        {mode==="idle"&&!clienteSel&&(
          <div style={{ flex:1, display:"flex", flexDirection:"column", alignItems:"center", justifyContent:"center", color:C.textMid }}>
            <div style={{ fontSize:48, marginBottom:16 }}>◉</div>
            <div style={{ fontSize:16, fontWeight:700, color:C.text }}>Selecciona un cliente</div>
            <div style={{ fontSize:12, marginTop:6 }}>o agrega uno nuevo con el botón de abajo</div>
          </div>
        )}
      </div>
    </div>
  );
}
