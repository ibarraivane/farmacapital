import { useState, useEffect, useCallback } from "react";
import { C_LIGHT } from "./constants";
import { supabase } from "./supabase";
import { showToast, HorizontalScrollSync } from "./ui";
import { productMatchesSearchQuery } from "./utils/fuzzySearch";

const BRAND = { primary:"#0D1B2A", secondary:"#1E3ABA", gradient:"linear-gradient(135deg,#0D1B2A,#1E3ABA)" };
const fmt = n => `$${parseFloat(n||0).toFixed(2)}`;
const mkInpS = (C) => ({width:"100%",boxSizing:"border-box",padding:"8px 12px",borderRadius:8,border:`1px solid ${C.border}`,background:C.card,color:C.text,fontSize:13,outline:"none"});

export default function LotesModule() {
  const C = C_LIGHT;
  const inpS = mkInpS(C);
  const [lotes,       setLotes]       = useState([]);
  const [productos,   setProductos]   = useState([]);
  const [proveedores, setProveedores] = useState([]);
  const [loading,     setLoading]     = useState(true);
  const [modal,       setModal]       = useState(false);
  const [filtroP,     setFiltroP]     = useState("");
  const [filtroVenc,  setFiltroV]     = useState("todos");
  const [form,        setForm]        = useState({
    producto_id:"", numero_lote:"", fecha_caducidad:"",
    cantidad_inicial:"", costo_unitario:"", proveedor_id:"",
    fecha_recepcion: new Date().toLocaleDateString("sv-SE"),
  });
  const [saving, setSaving] = useState(false);

  const fetchData = useCallback(async()=>{
    setLoading(true);
    const tok = sessionStorage.getItem("farmacapital_session_token");
    const [{ data: ls }, { data: ps }, { data: pv }] = tok
      ? await Promise.all([
          supabase.rpc("empleado_listar_lotes_inventario", { p_session_token: tok }),
          supabase.rpc("empleado_listar_productos_min_activos", { p_session_token: tok }),
          supabase.rpc("empleado_listar_proveedores_catalogo", { p_session_token: tok }),
        ])
      : [{ data: [] }, { data: [] }, { data: [] }];
    const lotRows = Array.isArray(ls) ? ls : [];
    lotRows.sort((a, b) => {
      const fa = a.fecha_caducidad ? new Date(a.fecha_caducidad).getTime() : 0;
      const fb = b.fecha_caducidad ? new Date(b.fecha_caducidad).getTime() : 0;
      return fa - fb;
    });
    setLotes(lotRows);
    setProductos(Array.isArray(ps) ? ps : []);
    setProveedores(Array.isArray(pv) ? pv : []);
    setLoading(false);
  },[]);

  useEffect(()=>{ fetchData(); },[fetchData]);

  const diasRestantes = fecha => {
    if(!fecha) return null;
    return Math.floor((new Date(fecha)-new Date())/86400000);
  };

  const colCad = d => d===null?"#94a3b8":d<0?C.red:d<=15?C.red:d<=30?C.amber:C.green;
  const txtCad = d => d===null?"Sin fecha":d<0?"VENCIDO":d===0?"HOY":d<=30?`${d} días`:`${d} días`;

  const lotesFiltrados = lotes.filter(l=>{
    const matchP = !filtroP || productMatchesSearchQuery(l.productos || {}, filtroP, [(x) => x.nombre, (x) => x.sku]);
    const dias   = diasRestantes(l.fecha_caducidad);
    const matchV =
      filtroVenc==="todos"    ? true :
      filtroVenc==="vencidos" ? (dias!==null&&dias<0) :
      filtroVenc==="criticos" ? (dias!==null&&dias>=0&&dias<=15) :
      filtroVenc==="pronto"   ? (dias!==null&&dias>15&&dias<=30) : true;
    return matchP && matchV;
  });

  const guardar = async()=>{
    if(!form.producto_id||!form.numero_lote||!form.cantidad_inicial){ showToast("Completa producto, lote y cantidad","warning"); return; }
    setSaving(true);
    const qty = parseInt(form.cantidad_inicial)||0;
    const tok = sessionStorage.getItem("farmacapital_session_token");
    if (!tok) { showToast("Sesión expirada","error"); setSaving(false); return; }
    const { error } = await supabase.rpc("admin_crear_lote", {
      p_session_token:  tok,
      p_producto_id:    parseInt(form.producto_id),
      p_numero_lote:    form.numero_lote.trim(),
      p_cantidad:       qty,
      p_fecha_caducidad: form.fecha_caducidad || null,
      p_costo_unitario: parseFloat(form.costo_unitario) || null,
      p_proveedor_id:   form.proveedor_id ? parseInt(form.proveedor_id) : null,
    });
    if(error){ showToast("Error: "+error.message,"error"); }
    else { showToast("✅ Lote registrado","success"); setModal(false); fetchData(); }
    setSaving(false);
  };

  const desactivar = async(id)=>{
    if(!window.confirm("¿Desactivar este lote?")) return;
    const tok = sessionStorage.getItem("farmacapital_session_token");
    const { error } = await supabase.rpc("admin_desactivar_lote", {
      p_session_token: tok, p_lote_id: id, p_motivo: "Desactivación manual",
    });
    if (error) showToast("Error: "+error.message, "error");
    else { showToast("Lote desactivado","info"); fetchData(); }
  };

  const vencidos  = lotes.filter(l=>{ const d=diasRestantes(l.fecha_caducidad); return d!==null&&d<0; }).length;
  const criticos  = lotes.filter(l=>{ const d=diasRestantes(l.fecha_caducidad); return d!==null&&d>=0&&d<=15; }).length;
  const pronto    = lotes.filter(l=>{ const d=diasRestantes(l.fecha_caducidad); return d!==null&&d>15&&d<=30; }).length;

  return(
    <div>
      <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:20,flexWrap:"wrap",gap:10}}>
        <div style={{display:"flex",alignItems:"center",gap:10}}>
        <h1 style={{color:C.text,fontSize:20,fontWeight:800,margin:0}}>📦 Lotes — PEPS</h1>
        <div style={{position:"relative",display:"inline-block"}} className="peps-tooltip-container">
          <span style={{
            background:"#eff6ff",color:"#0D1B2A",
            border:"1px solid #bfdbfe",borderRadius:20,
            padding:"2px 10px",fontSize:11,fontWeight:700,cursor:"help"
          }}>ℹ️ ¿Qué es PEPS?</span>
          <div className="peps-tooltip" style={{
            display:"none",position:"absolute",top:"calc(100% + 8px)",left:0,
            background:"#0f172a",color:"#f9fafb",borderRadius:10,
            padding:"10px 14px",fontSize:12,lineHeight:1.6,
            width:280,zIndex:999,boxShadow:"0 8px 24px rgba(0,0,0,.2)",
          }}>
            <strong>PEPS — Primero en Caducar, Primero en Salir</strong><br/>
            El sistema selecciona automáticamente el lote que caduca primero,
            para evitar pérdidas por vencimiento y cumplir con normativa COFEPRIS.
          </div>
        </div>
      </div>
        <button onClick={()=>setModal(true)} style={{padding:"9px 18px",borderRadius:8,border:"none",background:BRAND.gradient,color:"#fff",fontWeight:700,fontSize:13,cursor:"pointer"}}>
          + Registrar lote
        </button>
      </div>

      {/* KPIs */}
      <div style={{display:"flex",gap:12,marginBottom:20,flexWrap:"wrap"}}>
        {[
          {label:"Vencidos",    val:vencidos,     col:C.red,   filter:"vencidos"},
          {label:"Críticos ≤15d",val:criticos,    col:C.amber, filter:"criticos"},
          {label:"Por vencer ≤30d",val:pronto,    col:"#f59e0b",filter:"pronto"},
          {label:"Total lotes", val:lotes.length, col:C.blue,  filter:"todos"},
        ].map(k=>(
          <div key={k.label} onClick={()=>setFiltroV(k.filter)}
            style={{background:C.card,border:`2px solid ${filtroVenc===k.filter?k.col:C.border}`,borderRadius:12,padding:"12px 18px",flex:1,minWidth:120,cursor:"pointer"}}>
            <div style={{color:C.textDim,fontSize:10,fontWeight:700}}>{k.label.toUpperCase()}</div>
            <div style={{color:k.col,fontWeight:900,fontSize:22,marginTop:4}}>{k.val}</div>
          </div>
        ))}
      </div>

      {/* Filtros */}
      <div style={{display:"flex",gap:8,marginBottom:16,flexWrap:"wrap"}}>
        <input placeholder="🔍 Producto o SKU..." value={filtroP} onChange={e=>setFiltroP(e.target.value)}
          style={{...inpS,maxWidth:220,width:"auto"}}/>
        {["todos","vencidos","criticos","pronto"].map(f=>(
          <button key={f} onClick={()=>setFiltroV(f)} style={{
            padding:"6px 14px",borderRadius:20,fontSize:11,fontWeight:700,cursor:"pointer",
            border:`1px solid ${filtroVenc===f?BRAND.primary:C.border}`,
            background:filtroVenc===f?BRAND.primary+"18":"transparent",
            color:filtroVenc===f?BRAND.primary:C.textMid,
          }}>{f.charAt(0).toUpperCase()+f.slice(1)}</button>
        ))}
      </div>

      {/* Tabla */}
      {loading?<div style={{color:C.textMid,textAlign:"center",padding:40}}>Cargando…</div>:(
        <HorizontalScrollSync>
          <table style={{width:"100%",minWidth:980,borderCollapse:"collapse",fontSize:12}}>
            <thead>
              <tr style={{background:C.cardDark}}>
                {["Producto","SKU","Lote","Caducidad","Días","Stock actual","Costo","Proveedor","Acciones"].map(h=>(
                  <th key={h} style={{padding:"9px 12px",textAlign:"left",color:C.textMid,fontWeight:700,borderBottom:`1px solid ${C.border}`,whiteSpace:"nowrap"}}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {!lotesFiltrados.length&&<tr><td colSpan={9} style={{textAlign:"center",padding:32,color:C.textMid}}>Sin lotes</td></tr>}
              {lotesFiltrados.map((l,i)=>{
                const dias = diasRestantes(l.fecha_caducidad);
                const col  = colCad(dias);
                return(
                  <tr key={l.id} style={{background:dias!==null&&dias<0?"#fff5f5":i%2===0?"transparent":"#f8fafc"}}>
                    <td style={{padding:"8px 12px",color:C.text,fontWeight:600,borderBottom:`1px solid ${C.border}`}}>{l.productos?.nombre||"—"}</td>
                    <td style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`,fontFamily:"monospace",fontSize:10}}>{l.productos?.sku||"—"}</td>
                    <td style={{padding:"8px 12px",color:C.text,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{l.numero_lote}</td>
                    <td style={{padding:"8px 12px",color:col,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{l.fecha_caducidad||"—"}</td>
                    <td style={{padding:"8px 12px",borderBottom:`1px solid ${C.border}`}}>
                      <span style={{padding:"2px 8px",borderRadius:20,fontSize:10,fontWeight:700,background:col+"20",color:col}}>{txtCad(dias)}</span>
                    </td>
                    <td style={{padding:"8px 12px",color:l.cantidad_actual<=0?C.red:C.blue,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{l.cantidad_actual}</td>
                    <td style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{fmt(l.costo_unitario)}</td>
                    <td style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{l.proveedores?.nombre||"—"}</td>
                    <td style={{padding:"8px 12px",borderBottom:`1px solid ${C.border}`}}>
                      <button onClick={()=>desactivar(l.id)} style={{padding:"4px 10px",borderRadius:6,border:`1px solid ${C.red}30`,background:C.redDim,color:C.red,fontSize:10,fontWeight:700,cursor:"pointer"}}>
                        Desactivar
                      </button>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </HorizontalScrollSync>
      )}

      {/* Modal nuevo lote */}
      {modal&&(
        <div style={{position:"fixed",inset:0,background:"rgba(15,23,42,.45)",backdropFilter:"blur(4px)",zIndex:500,display:"flex",alignItems:"center",justifyContent:"center",padding:20}}
          onClick={e=>e.target===e.currentTarget&&setModal(false)}>
          <div style={{background:C.card,borderRadius:14,width:"min(520px,95vw)",maxHeight:"90vh",overflowY:"auto",padding:28,boxShadow:"0 20px 60px rgba(15,45,110,.15)"}}>
            <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:20}}>
              <h3 style={{margin:0,color:C.text,fontSize:16,fontWeight:800}}>📦 Registrar lote (FEFO)</h3>
              <button onClick={()=>setModal(false)} style={{background:"none",border:"none",color:C.textMid,fontSize:22,cursor:"pointer"}}>✕</button>
            </div>
            <div style={{display:"grid",gridTemplateColumns:"1fr 1fr",gap:12}}>
              <div style={{gridColumn:"1/-1"}}>
                <label style={{color:C.textMid,fontSize:11,fontWeight:700,display:"block",marginBottom:4}}>PRODUCTO *</label>
                <select style={inpS} value={form.producto_id} onChange={e=>setForm(p=>({...p,producto_id:e.target.value}))}>
                  <option value="">Seleccionar producto...</option>
                  {productos.map(p=><option key={p.id} value={p.id}>{p.nombre} {p.sku?`(${p.sku})`:""}</option>)}
                </select>
              </div>
              {[
                ["NÚMERO DE LOTE *","numero_lote","text","Ej: L2024-001"],
                ["FECHA DE CADUCIDAD","fecha_caducidad","date",""],
                ["CANTIDAD INICIAL *","cantidad_inicial","number","0"],
                ["COSTO UNITARIO","costo_unitario","number","0.00"],
                ["FECHA DE RECEPCIÓN","fecha_recepcion","date",""],
              ].map(([label,key,type,ph])=>(
                <div key={key}>
                  <label style={{color:C.textMid,fontSize:11,fontWeight:700,display:"block",marginBottom:4}}>{label}</label>
                  <input type={type} style={inpS} value={form[key]||""} onChange={e=>setForm(p=>({...p,[key]:e.target.value}))} placeholder={ph}/>
                </div>
              ))}
              <div>
                <label style={{color:C.textMid,fontSize:11,fontWeight:700,display:"block",marginBottom:4}}>PROVEEDOR</label>
                <select style={inpS} value={form.proveedor_id} onChange={e=>setForm(p=>({...p,proveedor_id:e.target.value}))}>
                  <option value="">Sin proveedor</option>
                  {proveedores.map(pv=><option key={pv.id} value={pv.id}>{pv.nombre}</option>)}
                </select>
              </div>
            </div>
            <div style={{display:"flex",gap:10,justifyContent:"flex-end",marginTop:16}}>
              <button onClick={()=>setModal(false)} style={{padding:"9px 20px",borderRadius:8,border:`1px solid ${C.border}`,background:"transparent",color:C.textMid,fontWeight:700,cursor:"pointer"}}>Cancelar</button>
              <button onClick={guardar} disabled={saving} style={{padding:"9px 20px",borderRadius:8,border:"none",background:BRAND.gradient,color:"#fff",fontWeight:700,cursor:"pointer",opacity:saving?.6:1}}>
                {saving?"Guardando…":"💾 Guardar lote"}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
