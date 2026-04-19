import { useState, useEffect, useCallback } from "react";
import { C_LIGHT } from "./constants";
import { supabase } from "./supabase";
import { showToast } from "./ui";

const BRAND = { primary:"#0052cc", secondary:"#0099e6", accent:"#00c46a", gradient:"linear-gradient(135deg,#0052cc,#0099e6)" };

const fmt = n => `$${parseFloat(n||0).toLocaleString("es-MX",{minimumFractionDigits:2,maximumFractionDigits:2})}`;
const pct = (a,b) => b>0 ? (((a-b)/b)*100).toFixed(1) : null;

const TIPOS = [
  {val:"descuento_pct",  label:"Descuento %"},
  {val:"descuento_fijo", label:"Descuento $"},
  {val:"2x1",            label:"2x1"},
  {val:"combo",          label:"Combo"},
];

const mkInpS = (C) => ({
  width:"100%", boxSizing:"border-box",
  padding:"9px 12px", borderRadius:8,
  border:`1px solid ${C.border}`,
  background:C.card, color:C.text,
  fontSize:13, outline:"none",
});
const mkLabelS = (C) => ({ color:C.textMid, fontSize:11, fontWeight:700, display:"block", marginBottom:4 });
const mkBtnPrimary = (C) => ({
  padding:"9px 20px", borderRadius:8, border:"none",
  background:BRAND.gradient, color:"#fff",
  fontWeight:700, fontSize:13, cursor:"pointer",
});
const mkBtnOutline = (C) => ({
  padding:"9px 20px", borderRadius:8,
  border:`1px solid ${C.border}`,
  background:"transparent", color:C.textMid,
  fontWeight:700, fontSize:13, cursor:"pointer",
});

// ── Modal Crear/Editar Promoción ──────────────────────────────
function PromoModal({initial, productos, onClose, onSaved }) {
  const C = C_LIGHT;
  const inpS = mkInpS(C);
  const labelS = mkLabelS(C);
  const btnPrimary = mkBtnPrimary(C);
  const btnOutline = mkBtnOutline(C);
  const empty = { nombre:"", tipo:"descuento_pct", valor:"", descripcion:"", fecha_inicio:"", fecha_fin:"", activa:true };
  const [form,    setForm]    = useState(initial || empty);
  const [selProds,setSelProds]= useState([]);
  const [saving,  setSaving]  = useState(false);
  const [error,   setError]   = useState("");

  useEffect(() => {
    if (initial?.id) {
      supabase.from("promocion_productos").select("producto_id").eq("promocion_id", initial.id)
        .then(({ data }) => setSelProds((data||[]).map(x=>x.producto_id)));
    }
  }, [initial]);

  const set = (k,v) => setForm(f=>({...f,[k]:v}));

  const toggleProd = id => setSelProds(p => p.includes(id) ? p.filter(x=>x!==id) : [...p,id]);

  const guardar = async () => {
    if (!form.nombre || !form.tipo || form.valor==="") { setError("Completa nombre, tipo y valor."); return; }
    setSaving(true); setError("");
    try {
      let promoId = initial?.id;
      const payload = {
        nombre: form.nombre.trim(),
        tipo: form.tipo,
        valor: parseFloat(form.valor),
        descripcion: form.descripcion.trim()||null,
        fecha_inicio: form.fecha_inicio||null,
        fecha_fin: form.fecha_fin||null,
        activa: form.activa,
      };
      if (promoId) {
        await supabase.from("promociones").update(payload).eq("id", promoId);
      } else {
        const { data } = await supabase.from("promociones").insert(payload).select().single();
        promoId = data.id;
      }
      // Sincronizar productos
      await supabase.from("promocion_productos").delete().eq("promocion_id", promoId);
      if (selProds.length) {
        await supabase.from("promocion_productos").insert(selProds.map(pid=>({ promocion_id:promoId, producto_id:pid })));
      }
      onSaved();
    } catch(e) { setError("Error al guardar: " + e.message); }
    setSaving(false);
  };

  return (
    <div style={{position:"fixed",inset:0,background:"rgba(15,23,42,.45)",backdropFilter:"blur(4px)",zIndex:500,display:"flex",alignItems:"center",justifyContent:"center",padding:20}}
      onClick={e=>e.target===e.currentTarget&&onClose()}>
      <div style={{background:C.card,borderRadius:14,width:"min(560px,95vw)",maxHeight:"90vh",overflowY:"auto",padding:28,boxShadow:"0 20px 60px rgba(0,82,204,.15)"}}>
        <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:20}}>
          <h3 style={{margin:0,color:C.text,fontSize:16,fontWeight:800}}>{initial?"✏️ Editar":"➕ Nueva"} Promoción</h3>
          <button onClick={onClose} style={{background:"none",border:"none",color:C.textMid,fontSize:22,cursor:"pointer"}}>✕</button>
        </div>

        <div style={{display:"grid",gridTemplateColumns:"1fr 1fr",gap:12,marginBottom:12}}>
          <div style={{gridColumn:"1/-1"}}>
            <label style={labelS}>NOMBRE *</label>
            <input style={inpS} value={form.nombre} onChange={e=>set("nombre",e.target.value)} placeholder="Ej: 2x1 en vitaminas"/>
          </div>
          <div>
            <label style={labelS}>TIPO *</label>
            <select style={inpS} value={form.tipo} onChange={e=>set("tipo",e.target.value)}>
              {TIPOS.map(t=><option key={t.val} value={t.val}>{t.label}</option>)}
            </select>
          </div>
          <div>
            <label style={labelS}>VALOR * {form.tipo==="descuento_pct"?"(%)":form.tipo==="descuento_fijo"?"($)":""}</label>
            <input style={inpS} type="number" min="0" value={form.valor} onChange={e=>set("valor",e.target.value)} placeholder={form.tipo==="descuento_pct"?"10":form.tipo==="descuento_fijo"?"20":"1"}/>
          </div>
          <div>
            <label style={labelS}>FECHA INICIO</label>
            <input style={inpS} type="date" value={form.fecha_inicio} onChange={e=>set("fecha_inicio",e.target.value)}/>
          </div>
          <div>
            <label style={labelS}>FECHA FIN</label>
            <input style={inpS} type="date" value={form.fecha_fin} onChange={e=>set("fecha_fin",e.target.value)}/>
          </div>
          <div style={{gridColumn:"1/-1"}}>
            <label style={labelS}>DESCRIPCIÓN (visible al cliente)</label>
            <input style={inpS} value={form.descripcion} onChange={e=>set("descripcion",e.target.value)} placeholder="Ej: Lleva 2 y paga 1 en vitaminas seleccionadas"/>
          </div>
          <div style={{gridColumn:"1/-1",display:"flex",alignItems:"center",gap:10}}>
            <input type="checkbox" id="activa" checked={form.activa} onChange={e=>set("activa",e.target.checked)} style={{width:16,height:16,cursor:"pointer"}}/>
            <label htmlFor="activa" style={{...labelS,marginBottom:0,cursor:"pointer"}}>PROMOCIÓN ACTIVA</label>
          </div>
        </div>

        <div style={{marginBottom:16}}>
          <label style={labelS}>PRODUCTOS APLICABLES ({selProds.length} seleccionados)</label>
          <div style={{maxHeight:180,overflowY:"auto",border:`1px solid ${C.border}`,borderRadius:8,padding:8,display:"flex",flexWrap:"wrap",gap:6}}>
            {productos.map(p=>(
              <div key={p.id} onClick={()=>toggleProd(p.id)}
                style={{padding:"4px 10px",borderRadius:20,fontSize:11,fontWeight:600,cursor:"pointer",
                  background:selProds.includes(p.id)?BRAND.primary+"18":"#f8fafc",
                  border:`1px solid ${selProds.includes(p.id)?BRAND.primary:C.border}`,
                  color:selProds.includes(p.id)?BRAND.primary:C.textMid}}>
                {p.nombre}
              </div>
            ))}
            {!productos.length && <span style={{color:C.textDim,fontSize:12}}>No hay productos activos</span>}
          </div>
          <div style={{color:C.textDim,fontSize:10,marginTop:4}}>Si no seleccionas ninguno, aplica a todos los productos.</div>
        </div>

        {error && <div style={{background:C.redDim,border:`1px solid ${C.red}30`,borderRadius:8,padding:"10px 12px",marginBottom:12,color:C.red,fontSize:13}}>{error}</div>}

        <div style={{display:"flex",gap:10,justifyContent:"flex-end"}}>
          <button style={btnOutline} onClick={onClose}>Cancelar</button>
          <button style={btnPrimary} onClick={guardar} disabled={saving}>{saving?"Guardando…":"💾 Guardar"}</button>
        </div>
      </div>
    </div>
  );
}

// ── Sección 1: Promociones ────────────────────────────────────
function Promociones({ productos }) {
  const C = C_LIGHT;
  const btnPrimary = mkBtnPrimary(C);
  const [promos,   setPromos]  = useState([]);
  const [loading,  setLoading] = useState(true);
  const [modal,    setModal]   = useState(null); // null | "new" | promo obj

  const fetch = useCallback(async () => {
    setLoading(true);
    const { data } = await supabase.from("promociones").select("*").order("created_at",{ascending:false});
    setPromos(data||[]);
    setLoading(false);
  }, []);

  useEffect(() => { fetch(); }, [fetch]);

  const toggle = async (p) => {
    await supabase.from("promociones").update({activa:!p.activa}).eq("id",p.id);
    setPromos(prev=>prev.map(x=>x.id===p.id?{...x,activa:!x.activa}:x));
  };

  const eliminar = async (p) => {
    if (!window.confirm(`¿Eliminar la promoción "${p.nombre}"?`)) return; // TODO: ConfirmDialog
    await supabase.from("promociones").delete().eq("id",p.id);
    setPromos(prev=>prev.filter(x=>x.id!==p.id));
  };

  const tipoLabel = t => TIPOS.find(x=>x.val===t)?.label||t;
  const tipoColor = t => t==="descuento_pct"?C.blue:t==="descuento_fijo"?C.green:t==="2x1"?C.purple:C.amber;

  const hoy = new Date().toISOString().split("T")[0];
  const vigente = p => p.activa && (!p.fecha_fin || p.fecha_fin >= hoy) && (!p.fecha_inicio || p.fecha_inicio <= hoy);

  return (
    <div>
      <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:16}}>
        <div>
          <div style={{color:C.textMid,fontSize:12}}>
            <span style={{color:C.green,fontWeight:700}}>{promos.filter(vigente).length}</span> activas ·{" "}
            <span style={{color:C.textMid}}>{promos.length} total</span>
          </div>
        </div>
        <button style={btnPrimary} onClick={()=>setModal("new")}>➕ Nueva promoción</button>
      </div>

      {loading ? <div style={{color:C.textMid,textAlign:"center",padding:40}}>Cargando…</div> : (
        <div style={{display:"grid",gap:12}}>
          {!promos.length && <div style={{color:C.textMid,textAlign:"center",padding:40,background:C.card,borderRadius:12,border:`1px solid ${C.border}`}}>Sin promociones. Crea la primera.</div>}
          {promos.map(p=>(
            <div key={p.id} style={{background:C.card,border:`1px solid ${vigente(p)?C.green:C.border}`,borderRadius:12,padding:16,display:"flex",gap:16,alignItems:"center",flexWrap:"wrap"}}>
              <div style={{flex:1,minWidth:200}}>
                <div style={{display:"flex",alignItems:"center",gap:8,marginBottom:4}}>
                  <span style={{fontWeight:800,color:C.text,fontSize:14}}>{p.nombre}</span>
                  <span style={{padding:"2px 8px",borderRadius:20,fontSize:10,fontWeight:700,background:tipoColor(p.tipo)+"18",color:tipoColor(p.tipo)}}>{tipoLabel(p.tipo)}</span>
                  {vigente(p) && <span style={{padding:"2px 8px",borderRadius:20,fontSize:10,fontWeight:700,background:C.greenDim,color:C.green}}>✓ Vigente</span>}
                  {!p.activa && <span style={{padding:"2px 8px",borderRadius:20,fontSize:10,fontWeight:700,background:C.cardDark,color:C.textMid}}>Inactiva</span>}
                </div>
                {p.descripcion && <div style={{color:C.textMid,fontSize:12,marginBottom:4}}>{p.descripcion}</div>}
                <div style={{display:"flex",gap:12,fontSize:11,color:C.textDim}}>
                  <span>Valor: <strong style={{color:C.text}}>{p.tipo==="descuento_pct"?`${p.valor}%`:p.tipo==="descuento_fijo"?fmt(p.valor):p.valor}</strong></span>
                  {p.fecha_inicio && <span>Desde: {p.fecha_inicio}</span>}
                  {p.fecha_fin && <span>Hasta: {p.fecha_fin}</span>}
                </div>
              </div>
              <div style={{display:"flex",gap:8,flexShrink:0}}>
                <button onClick={()=>setModal(p)} style={{padding:"6px 12px",borderRadius:7,border:`1px solid ${C.amber}30`,background:"#fef3c7",color:C.amber,cursor:"pointer",fontSize:12,fontWeight:700}}>✏️</button>
                <button onClick={()=>toggle(p)} style={{padding:"6px 12px",borderRadius:7,border:`1px solid ${p.activa?C.red:C.green}30`,background:p.activa?C.redDim:C.greenDim,color:p.activa?C.red:C.green,cursor:"pointer",fontSize:12,fontWeight:700}}>{p.activa?"⏸ Pausar":"▶ Activar"}</button>
                <button onClick={()=>eliminar(p)} style={{padding:"6px 12px",borderRadius:7,border:`1px solid ${C.red}30`,background:C.redDim,color:C.red,cursor:"pointer",fontSize:12,fontWeight:700}}>🗑️</button>
              </div>
            </div>
          ))}
        </div>
      )}

      {modal && (
        <PromoModal
          initial={modal==="new"?null:modal}
          productos={productos}
          onClose={()=>setModal(null)}
          onSaved={()=>{ setModal(null); fetch(); }}
        />
      )}
    </div>
  );
}

// ── Sección 2: Comparación de precios ────────────────────────
function CompetidoresPrecios({ productos, onReload }) {
  const C = C_LIGHT;
  const [editId,  setEditId]  = useState(null);
  const [editForm,setEditForm]= useState({precio_similares:"",precio_del_ahorro:""});
  const [saving,  setSaving]  = useState(false);
  const [busq,    setBusq]    = useState("");

  const fil = productos.filter(p=>p.nombre.toLowerCase().includes(busq.toLowerCase()));

  const abrirEditar = p => {
    setEditId(p.id);
    setEditForm({ precio_similares:p.precio_similares||"", precio_del_ahorro:p.precio_del_ahorro||"" });
  };

  const guardar = async (id) => {
    setSaving(true);
    await supabase.from("productos").update({
      precio_similares: editForm.precio_similares ? parseFloat(editForm.precio_similares) : null,
      precio_del_ahorro: editForm.precio_del_ahorro ? parseFloat(editForm.precio_del_ahorro) : null,
      fecha_actualizacion_precios: new Date().toISOString().split("T")[0],
    }).eq("id", id);
    setSaving(false);
    setEditId(null);
    onReload();
  };

  const masBarato  = fil.filter(p=>(p.precio_similares&&p.precio<p.precio_similares)||(p.precio_del_ahorro&&p.precio<p.precio_del_ahorro)).length;
  const masCaro    = fil.filter(p=>(p.precio_similares&&p.precio>p.precio_similares)||(p.precio_del_ahorro&&p.precio>p.precio_del_ahorro)).length;
  const sinDatos   = fil.filter(p=>!p.precio_similares&&!p.precio_del_ahorro).length;

  const diffColor = (farmax, comp) => {
    if (!comp) return null;
    return farmax < comp ? C.green : farmax > comp ? C.red : C.amber;
  };

  return (
    <div>
      <div style={{display:"flex",gap:12,marginBottom:16,flexWrap:"wrap",alignItems:"center"}}>
        <input placeholder="🔍 Buscar producto…" value={busq} onChange={e=>setBusq(e.target.value)}
          style={{...inpS,maxWidth:220,width:"auto"}}/>
        <div style={{display:"flex",gap:8,marginLeft:"auto",flexWrap:"wrap"}}>
          <span style={{padding:"4px 12px",borderRadius:20,fontSize:11,fontWeight:700,background:C.greenDim,color:C.green}}>✅ Más barato: {masBarato}</span>
          <span style={{padding:"4px 12px",borderRadius:20,fontSize:11,fontWeight:700,background:C.redDim,color:C.red}}>⚠️ Más caro: {masCaro}</span>
          <span style={{padding:"4px 12px",borderRadius:20,fontSize:11,fontWeight:700,background:C.cardDark,color:C.textMid}}>Sin datos: {sinDatos}</span>
        </div>
      </div>

      <div style={{overflowX:"auto",borderRadius:12,border:`1px solid ${C.border}`}}>
        <table style={{width:"100%",borderCollapse:"collapse",fontSize:12}}>
          <thead>
            <tr style={{background:C.cardDark}}>
              {["Producto","Precio Farmax","Similares","Dif. Similares","Del Ahorro","Dif. Del Ahorro","Actualizado","Acciones"].map(h=>(
                <th key={h} style={{padding:"9px 12px",textAlign:"left",color:C.textMid,fontWeight:700,borderBottom:`1px solid ${C.border}`,whiteSpace:"nowrap"}}>{h}</th>
              ))}
            </tr>
          </thead>
          <tbody>
            {!fil.length && <tr><td colSpan={8} style={{textAlign:"center",padding:32,color:C.textMid}}>Sin productos</td></tr>}
            {fil.map((p,i)=>{
              const dSim = pct(p.precio, p.precio_similares);
              const dAho = pct(p.precio, p.precio_del_ahorro);
              const cSim = diffColor(p.precio, p.precio_similares);
              const cAho = diffColor(p.precio, p.precio_del_ahorro);
              return (
                <tr key={p.id} style={{background:i%2===0?"transparent":"#f8fafc"}}>
                  <td style={{padding:"8px 12px",color:C.text,fontWeight:600,borderBottom:`1px solid ${C.border}`,maxWidth:180}}>{p.nombre}</td>
                  <td style={{padding:"8px 12px",color:C.blue,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{fmt(p.precio)}</td>
                  {editId===p.id ? (
                    <>
                      <td style={{padding:"8px 12px",borderBottom:`1px solid ${C.border}`}}>
                        <input type="number" value={editForm.precio_similares} onChange={e=>setEditForm(f=>({...f,precio_similares:e.target.value}))}
                          style={{...inpS,width:90,padding:"5px 8px"}} placeholder="0.00"/>
                      </td>
                      <td style={{padding:"8px 12px",borderBottom:`1px solid ${C.border}`}}>—</td>
                      <td style={{padding:"8px 12px",borderBottom:`1px solid ${C.border}`}}>
                        <input type="number" value={editForm.precio_del_ahorro} onChange={e=>setEditForm(f=>({...f,precio_del_ahorro:e.target.value}))}
                          style={{...inpS,width:90,padding:"5px 8px"}} placeholder="0.00"/>
                      </td>
                      <td style={{padding:"8px 12px",borderBottom:`1px solid ${C.border}`}}>—</td>
                      <td style={{padding:"8px 12px",borderBottom:`1px solid ${C.border}`}}>—</td>
                      <td style={{padding:"8px 12px",borderBottom:`1px solid ${C.border}`,whiteSpace:"nowrap"}}>
                        <button onClick={()=>guardar(p.id)} disabled={saving} style={{padding:"4px 10px",borderRadius:6,border:"none",background:BRAND.gradient,color:"#fff",cursor:"pointer",fontSize:11,fontWeight:700,marginRight:4}}>{saving?"…":"💾"}</button>
                        <button onClick={()=>setEditId(null)} style={{padding:"4px 10px",borderRadius:6,border:`1px solid ${C.border}`,background:"transparent",color:C.textMid,cursor:"pointer",fontSize:11,fontWeight:700}}>✕</button>
                      </td>
                    </>
                  ) : (
                    <>
                      <td style={{padding:"8px 12px",borderBottom:`1px solid ${C.border}`,color:cSim||C.textMid}}>{p.precio_similares?fmt(p.precio_similares):"—"}</td>
                      <td style={{padding:"8px 12px",borderBottom:`1px solid ${C.border}`}}>
                        {dSim ? <span style={{padding:"2px 8px",borderRadius:20,fontSize:10,fontWeight:700,background:(cSim||C.textMid)+"18",color:cSim||C.textMid}}>{dSim>0?"+":""}{dSim}%</span> : "—"}
                      </td>
                      <td style={{padding:"8px 12px",borderBottom:`1px solid ${C.border}`,color:cAho||C.textMid}}>{p.precio_del_ahorro?fmt(p.precio_del_ahorro):"—"}</td>
                      <td style={{padding:"8px 12px",borderBottom:`1px solid ${C.border}`}}>
                        {dAho ? <span style={{padding:"2px 8px",borderRadius:20,fontSize:10,fontWeight:700,background:(cAho||C.textMid)+"18",color:cAho||C.textMid}}>{dAho>0?"+":""}{dAho}%</span> : "—"}
                      </td>
                      <td style={{padding:"8px 12px",borderBottom:`1px solid ${C.border}`,color:C.textDim,fontSize:11}}>{p.fecha_actualizacion_precios||"—"}</td>
                      <td style={{padding:"8px 12px",borderBottom:`1px solid ${C.border}`}}>
                        <button onClick={()=>abrirEditar(p)} style={{padding:"4px 10px",borderRadius:6,border:`1px solid ${C.blue}30`,background:"#eff6ff",color:C.blue,cursor:"pointer",fontSize:11,fontWeight:700}}>✏️ Actualizar</button>
                      </td>
                    </>
                  )}
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
}

// ── Módulo principal ──────────────────────────────────────────
export default function PromocionesModule() {
  const C = C_LIGHT;
  const inpS = mkInpS(C);
  const labelS = mkLabelS(C);
  const btnPrimary = mkBtnPrimary(C);
  const btnOutline = mkBtnOutline(C);
  const [tab,       setTab]      = useState("promos");
  const [productos, setProductos]= useState([]);

  const fetchProds = useCallback(async () => {
    const fullCols = "id,nombre,precio,precio_similares,precio_del_ahorro,fecha_actualizacion_precios";
    const baseCols = "id,nombre,precio";
    const first = await supabase.from("productos").select(fullCols).eq("activo",true).order("nombre");
    if (first.error) {
      const fallback = await supabase.from("productos").select(baseCols).eq("activo",true).order("nombre");
      setProductos(fallback.data || []);
      return;
    }
    setProductos(first.data || []);
  }, []);

  useEffect(() => { fetchProds(); }, [fetchProds]);

  return (
    <div>
      <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:20}}>
        <h1 style={{color:C.text,fontSize:20,fontWeight:800,margin:0}}>🏷️ Promociones</h1>
      </div>

      <div style={{display:"flex",gap:4,marginBottom:20,borderBottom:`1px solid ${C.border}`}}>
        {[["promos","🏷️ Promociones activas"],["precios","📊 Precios vs competencia"]].map(([id,label])=>(
          <button key={id} onClick={()=>setTab(id)} style={{
            padding:"8px 18px",border:"none",cursor:"pointer",fontWeight:700,fontSize:12,
            borderRadius:"8px 8px 0 0",background:"transparent",
            color:tab===id?BRAND.primary:C.textMid,
            borderBottom:tab===id?`2px solid ${BRAND.primary}`:"2px solid transparent",
          }}>{label}</button>
        ))}
      </div>

      {tab==="promos"  && <Promociones productos={productos}/>}
      {tab==="precios" && <CompetidoresPrecios productos={productos} onReload={fetchProds}/>}
    </div>
  );
}
