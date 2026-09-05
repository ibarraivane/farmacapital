import { useState, useEffect, useCallback } from "react";
import { Tag, TrendingUp } from "lucide-react";
import { C_LIGHT } from "./constants";
import { SegmentedNav } from "./components/SegmentedNav";
import { PageHero } from "./components/AdminChrome";
import { supabase } from "./supabase";
import { showToast } from "./ui";
import { hoyISOMexico } from "./lib/fecha";

const BRAND = { primary:"#0D1B2A", secondary:"#1E3ABA", accent:"#16a34a", gradient:"linear-gradient(135deg,#0D1B2A,#1E3ABA)" };

const fmt = n => `$${parseFloat(n||0).toLocaleString("es-MX",{minimumFractionDigits:2,maximumFractionDigits:2})}`;

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
      const payload = {
        nombre: form.nombre.trim(),
        tipo: form.tipo,
        valor: parseFloat(form.valor),
        descripcion: form.descripcion.trim()||null,
        fecha_inicio: form.fecha_inicio||null,
        fecha_fin: form.fecha_fin||null,
        activa: form.activa,
      };
      const tok = sessionStorage.getItem("farmacapital_session_token");
      const { error: rpcErr } = await supabase.rpc("admin_upsert_promocion", {
        p_session_token: tok,
        p_id:            initial?.id || null,
        p_payload:       payload,
        p_productos_ids: selProds.length ? selProds : [],
      });
      if (rpcErr) throw rpcErr;
      onSaved();
    } catch(e) { setError("Error al guardar: " + e.message); }
    setSaving(false);
  };

  return (
    <div style={{position:"fixed",inset:0,background:"rgba(15,23,42,.45)",backdropFilter:"blur(4px)",zIndex:500,display:"flex",alignItems:"center",justifyContent:"center",padding:20}}
      onClick={e=>e.target===e.currentTarget&&onClose()}>
      <div style={{background:C.card,borderRadius:14,width:"min(560px,95vw)",maxHeight:"90vh",overflowY:"auto",padding:28,boxShadow:"0 20px 60px rgba(15,45,110,.15)"}}>
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
          <div style={{maxHeight:180,overflowY:"visible",border:`1px solid ${C.border}`,borderRadius:8,padding:8,display:"flex",flexWrap:"wrap",gap:6}}>
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
    const tok = sessionStorage.getItem("farmacapital_session_token");
    const { error } = await supabase.rpc("admin_toggle_promocion", {
      p_session_token: tok, p_id: p.id, p_activa: !p.activa,
    });
    if (error) { showToast("Error: "+error.message,"error"); return; }
    setPromos(prev=>prev.map(x=>x.id===p.id?{...x,activa:!x.activa}:x));
  };

  const eliminar = async (p) => {
    if (!window.confirm(`¿Eliminar la promoción "${p.nombre}"?`)) return;
    const tok = sessionStorage.getItem("farmacapital_session_token");
    const { error } = await supabase.rpc("admin_eliminar_promocion", {
      p_session_token: tok, p_id: p.id,
    });
    if (error) { showToast("Error: "+error.message,"error"); return; }
    setPromos(prev=>prev.filter(x=>x.id!==p.id));
  };

  const tipoLabel = t => TIPOS.find(x=>x.val===t)?.label||t;
  const tipoColor = t => t==="descuento_pct"?C.blue:t==="descuento_fijo"?C.green:t==="2x1"?C.purple:C.amber;

  const hoy = hoyISOMexico();
  const vigente = p => p.activa && (!p.fecha_fin || p.fecha_fin >= hoy) && (!p.fecha_inicio || p.fecha_inicio <= hoy);

  return (
    <div>
      <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:16,flexWrap:"wrap",gap:12}}>
        <div style={{flex:"1 1 auto",minWidth:0}}>
          <div style={{color:C.textMid,fontSize:12}}>
            <span style={{color:C.green,fontWeight:700}}>{promos.filter(vigente).length}</span> activas ·{" "}
            <span style={{color:C.textMid}}>{promos.length} total</span>
          </div>
        </div>
        <button type="button" style={{...btnPrimary,flexShrink:0}} onClick={()=>setModal("new")}>➕ Nueva promoción</button>
      </div>

      {loading ? <div style={{color:C.textMid,textAlign:"center",padding:40}}>Cargando…</div> : (
        <div style={{display:"grid",gap:12}}>
          {!promos.length && <div style={{color:C.textMid,textAlign:"center",padding:40,background:C.card,borderRadius:12,border:`1px solid ${C.border}`}}>Sin promociones. Crea la primera.</div>}
          {promos.map(p=>(
              <div key={p.id} style={{background:C.card,border:`1px solid ${vigente(p)?C.green:C.border}`,borderRadius:12,padding:16,display:"flex",gap:16,alignItems:"center",flexWrap:"wrap"}}>
              <div style={{flex:"1 1 200px",minWidth:0}}>
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

// ── Redirige a Inventario → Referencias de precio ─────────────
function ReferenciasPrecioRedirect({ onNavigate }) {
  const C = C_LIGHT;
  const ir = () => {
    if (onNavigate) {
      onNavigate("inv", { tab: "precios" });
      return;
    }
    try { sessionStorage.setItem("farmacapital_inv_tab", "precios"); } catch (_) { /* noop */ }
    showToast("Abre Inventario → pestaña «Referencias de precio»", "info");
  };

  return (
    <div style={{
      background: C.card, borderRadius: 12, border: `1px solid ${C.border}`,
      padding: 32, textAlign: "center", maxWidth: 480, margin: "0 auto",
    }}>
      <div style={{ fontSize: 40, marginBottom: 12 }}>📊</div>
      <div style={{ color: C.text, fontWeight: 800, fontSize: 16, marginBottom: 8 }}>
        Precios vs competencia se movieron
      </div>
      <p style={{ color: C.textMid, fontSize: 13, lineHeight: 1.5, margin: "0 0 20px" }}>
        Compra (Exprezo, Marzam, Nadro, Levic) y venta (Del Ahorro, Similares) viven en{" "}
        <strong>Inventario → Referencias de precio</strong>.
      </p>
      <button type="button" onClick={ir} style={{
        padding: "10px 20px", borderRadius: 8, border: "none",
        background: BRAND.gradient, color: "#fff", fontWeight: 700, fontSize: 13, cursor: "pointer",
      }}>
        Ir a Referencias de precio
      </button>
    </div>
  );
}

// ── Módulo principal ──────────────────────────────────────────
export default function PromocionesModule({ onNavigate }) {
  const C = C_LIGHT;
  const inpS = mkInpS(C);
  const labelS = mkLabelS(C);
  const btnPrimary = mkBtnPrimary(C);
  const btnOutline = mkBtnOutline(C);
  const [tab,       setTab]      = useState("promos");
  const [productos, setProductos]= useState([]);

  const fetchProds = useCallback(async () => {
    const { data, error } = await supabase
      .from("productos")
      .select("id,nombre,precio")
      .eq("activo", true)
      .order("nombre");
    if (error) {
      showToast("Error cargando productos: " + error.message, "error");
      return;
    }
    setProductos(data || []);
  }, []);

  useEffect(() => { fetchProds(); }, [fetchProds]);

  return (
    <div>
      <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:20}}>
        <PageHero Icon={Tag}>Promociones</PageHero>
      </div>

      <div style={{ marginBottom: 20 }}>
        <SegmentedNav
          size="md"
          activation="auto"
          ariaLabel="Secciones de promociones"
          value={tab}
          onChange={setTab}
          items={[
            { id: "promos", label: "Promociones activas", Icon: Tag },
            { id: "precios", label: "Precios vs competencia", Icon: TrendingUp },
          ]}
        />
      </div>

      {tab==="promos"  && <Promociones productos={productos}/>}
      {tab==="precios" && <ReferenciasPrecioRedirect onNavigate={onNavigate}/>}
    </div>
  );
}
