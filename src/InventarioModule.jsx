import { useState, useEffect, useCallback } from "react";
import { useMediaQuery } from "./hooks/useMediaQuery";
import { C_LIGHT } from "./constants";
import { supabase } from "./supabase";
import { logAudit } from "./utils";
import { SkeletonTable, Paginador, SearchDropdown, HorizontalScrollSync } from "./ui";
import { showToast } from "./ui";
import OnboardingTour from "./components/OnboardingTour";
import { idEmpleadoUsuarios } from "./utils/usuarioId";
import { uploadProductImage, deleteProductImageStorageFolder } from "./utils/storageFarmax";

const leerSesion = () => {
  try {
    return JSON.parse(sessionStorage.getItem("farmax_admin_user") || "{}");
  } catch {
    return {};
  }
};

const BRAND = { primary:"#0052cc", secondary:"#0099e6", gradient:"linear-gradient(135deg,#0052cc,#0099e6)" };
const CATEGORIAS = [
  "Analgésico","Antiinflamatorio","Antibiótico","Gastro","Diabetes",
  "Hipertensión","Alergia","Vitaminas","Hidratación","Cardiovascular",
  "Respiratorio","Botiquín","Higiene","Bebidas","Básicos","Cuidado personal","Otro",
];
const EMPTY = {
  nombre:"", sku:"", codigo_barras:"", categoria:"Otro", precio:"", costo:"", venta_unidad:false, unidades_por_caja:"", precio_unidad:"", stock_unidades:"",
  stock:"", stock_minimo:"", tipo:"generico", proveedor:"", lote:"",
  fecha_caducidad:"", descuento_pct:"0", activo:true, imagen_url:"",
};

// F4: campos lote/fecha_caducidad ya NO viven en productos; son del lote.
// Para productos ya existentes derivamos min_caducidad desde lotes activos.
const minCaducidadLotes = (lotes) => {
  const activos = (lotes || []).filter(l => l.activo !== false && (l.cantidad_actual || 0) > 0 && l.fecha_caducidad);
  return activos.reduce((m, l) => (!m || l.fecha_caducidad < m) ? l.fecha_caducidad : m, null);
};

const mkInputStyle = (C) => ({ width:"100%", padding:"8px 10px", borderRadius:7, border:`1px solid ${C.border}`, background:C.bg, color:C.text, fontSize:12, outline:"none", boxSizing:"border-box" });
const mkLabelStyle = (C) => ({ color:C.textMid, fontSize:11, fontWeight:600, marginBottom:3, display:"block" });
const mkBtnPrimary = (C) => ({ padding:"9px 18px", borderRadius:8, border:"none", cursor:"pointer", background:BRAND.gradient, color:"#fff", fontWeight:700, fontSize:12 });
const mkBtnOutline = (C) => ({ padding:"8px 16px", borderRadius:8, cursor:"pointer", fontWeight:700, fontSize:12, border:`1px solid ${C.blue}`, background:"transparent", color:C.blue });
const mkBtnGreen = (C) => ({ padding:"9px 18px", borderRadius:8, border:"none", cursor:"pointer", background:C.green, color:"#fff", fontWeight:700, fontSize:12 });
const mkBtnSecondary = (C) => ({ padding:"9px 18px", borderRadius:8, cursor:"pointer", fontWeight:700, fontSize:12, border:`1px solid ${C.border}`, background:"transparent", color:C.textMid });

const margen = (pv, co) => {
  const p = parseFloat(pv), c = parseFloat(co);
  if (!c || c === 0) return "—";
  return ((p - c) / c * 100).toFixed(1) + "%";
};

const diasParaCaducar = (fecha) => {
  if (!fecha) return null;
  const diff = (new Date(fecha) - new Date()) / (1000 * 60 * 60 * 24);
  return Math.ceil(diff);
};

const descargarPlantilla = () => {
  const headers = ["SKU","Nombre","Categoria","Tipo","Stock","Stock_Minimo","Precio_Venta","Costo","Proveedor","Lote","Fecha_Caducidad","Descuento_Porcentaje"];
  const ejemplo = [
    ["FAR001","Paracetamol 500mg c/20","Analgésico","generico","50","10","45.00","22.00","Nadro","L2024-01","2026-12-31","0"],
    ["FAR002","Omeprazol 20mg c/14","Gastro","generico","30","5","89.00","40.00","Marzam","L2024-02","2026-06-30","0"],
    ["FAR003","Amoxicilina 500mg c/12","Antibiótico","generico","20","8","120.00","55.00","Casa Saba","L2024-03","2025-12-31","0"],
  ];
  const csv = [headers, ...ejemplo].map(r=>r.map(v=>`"${v}"`).join(",")).join("\n");
  const blob = new Blob(["\uFEFF"+csv],{type:"text/csv;charset=utf-8;"});
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href=url; a.download="plantilla_inventario_farmax.csv";
  a.click(); URL.revokeObjectURL(url);
};

const parsearCSV = (texto) => {
  const lineas = texto.trim().split("\n").map(l=>l.trim()).filter(Boolean);
  if(lineas.length<2) return {ok:false,msg:"El archivo está vacío o tiene solo encabezados",rows:[]};
  const headers = lineas[0].split(",").map(h=>h.replace(/"/g,"").trim().toLowerCase().replace(/ /g,"_"));
  const rows = [];
  const errores = [];
  for(let i=1;i<lineas.length;i++){
    const vals = lineas[i].split(",").map(v=>v.replace(/"/g,"").trim());
    const row = {};
    headers.forEach((h,j)=>{ row[h]=vals[j]||""; });
    // Validar campos requeridos
    if(!row.nombre&&!row["nombre"]) { errores.push(`Fila ${i+1}: Nombre es requerido`); continue; }
    rows.push({
      sku:           row.sku||row["sku"]||null,
      nombre:        row.nombre||row["nombre"]||"",
      categoria:     row.categoria||row["categoría"]||row["categoria"]||"Otro",
      tipo:          row.tipo||"generico",
      stock:         parseInt(row.stock||row["stock"])||0,
      stock_minimo:  parseInt(row.stock_minimo||row["stock_mínimo"]||row["stock_minimo"])||0,
      precio:  parseFloat(row.precio||row["precio"])||0,
      costo:         parseFloat(row.costo||"0")||0,
      proveedor:     row.proveedor||null,
      lote:          row.lote||null,
      fecha_caducidad: row.fecha_caducidad||row["fecha_caducidad"]||null,
      descuento_pct: parseFloat(row.descuento_pct||"0")||0,
      activo: true,
    });
  }
  return {ok:rows.length>0, msg:errores.length?`${errores.length} filas con error: ${errores.slice(0,3).join(", ")}`:null, rows};
};

const exportarCSV = (productos) => {
  const headers = ["SKU","Nombre","Categoría","Tipo","Stock","Stock Mín","Precio Venta","Costo","Margen%","Caducidad","Proveedor","Descuento%","Estado"];
  const rows = productos.map(p => [
    p.sku||"", p.nombre, p.categoria, p.tipo, p.stock, p.stock_minimo??0,
    parseFloat(p.precio||0).toFixed(2), parseFloat(p.costo||0).toFixed(2),
    margen(p.precio, p.costo), p.min_caducidad_lotes||"", p.proveedor||"",
    p.descuento_pct||0, p.activo?"Activo":"Inactivo",
  ]);
  const csv = [headers, ...rows].map(r => r.map(v => `"${v}"`).join(",")).join("\n");
  const blob = new Blob([csv], { type:"text/csv;charset=utf-8;" });
  const url  = URL.createObjectURL(blob);
  const a    = document.createElement("a");
  a.href = url; a.download = `inventario_farmax_${new Date().toISOString().slice(0,10)}.csv`;
  a.click(); URL.revokeObjectURL(url);
};

function ProductoModal({initial, onClose, onSaved }) {
  const C = C_LIGHT;
  const inputStyle = mkInputStyle(C);
  const labelStyle = mkLabelStyle(C);
  const btnSecondary = mkBtnSecondary(C);
  const btnPrimary = mkBtnPrimary(C);
  const btnOutline = mkBtnOutline(C);
  const btnGreen = mkBtnGreen(C);
  const [form, setForm]     = useState({ ...(initial || EMPTY), imagen_url: (initial || EMPTY).imagen_url || "" });
  const [errors, setErrors] = useState({});
  const [saving, setSaving] = useState(false);
  const [imgFile, setImgFile] = useState(null);
  const [imgPreview, setImgPreview] = useState("");
  const set = (k, v) => setForm(f => ({ ...f, [k]: v }));

  useEffect(() => {
    if (!imgFile) { setImgPreview(""); return undefined; }
    const u = URL.createObjectURL(imgFile);
    setImgPreview(u);
    return () => URL.revokeObjectURL(u);
  }, [imgFile]);
  const validate = () => {
    const e = {};
    if (!form.nombre.trim())                           e.nombre       = "Requerido";
    if (!form.precio||parseFloat(form.precio)<=0) e.precio = "Debe ser mayor a $0";
    if (!form.costo||parseFloat(form.costo)<0)         e.costo        = "Debe ser 0 o mayor";
    if (form.stock === "" || form.stock === null)       e.stock        = "Requerido";
    return e;
  };
  const handleSave = async () => {
    const e = validate();
    if (Object.keys(e).length) { setErrors(e); return; }
    setSaving(true);
    const stockInt = parseInt(form.stock) || 0;
    const costoNum = parseFloat(form.costo) || 0;

    // Campos del producto (sin stock/costo que viajan al lote en el alta)
    const productoFields = {
      nombre: form.nombre.trim(),
      sku: form.sku.trim() || null,
      codigo_barras: form.codigo_barras?.trim() || null,
      categoria: form.categoria,
      precio: parseFloat(form.precio),
      stock_minimo: form.stock_minimo !== "" ? parseInt(form.stock_minimo) : 0,
      tipo: form.tipo,
      proveedor: form.proveedor.trim() || null,
      descuento_pct: parseFloat(form.descuento_pct) || 0,
      activo: form.activo,
      venta_unidad: form.venta_unidad || false,
      unidades_por_caja: form.venta_unidad ? parseInt(form.unidades_por_caja) || 0 : 0,
      precio_unidad: form.venta_unidad ? Math.ceil(parseFloat(form.precio_unidad) || 0) : 0,
      stock_unidades: form.venta_unidad ? parseInt(form.stock_unidades) || 0 : 0,
    };

    const sesion = leerSesion();
    const empleadoId = await idEmpleadoUsuarios(sesion);

    const tok = sessionStorage.getItem("farmax_session_token");
    if (!tok) {
      setSaving(false);
      showToast("Sesión expirada. Inicia sesión de nuevo.", "error");
      return;
    }

    let err;
    if (form.id) {
      const patch = { ...productoFields, costo: costoNum };
      if (!imgFile) patch.imagen_url = (form.imagen_url || "").trim();
      const { error: editErr } = await supabase.rpc("admin_editar_producto", {
        p_session_token: tok,
        p_producto_id: form.id,
        p_patch: patch,
      });
      err = editErr;
      if (!err) {
        const { error: adjErr } = await supabase.rpc("adjust_stock_secure", {
          p_session_token: tok,
          p_producto_id: form.id,
          p_nuevo_stock: stockInt,
          p_motivo: "Edición manual desde Inventario",
        });
        if (adjErr) err = adjErr;
      }
      if (!err && imgFile) {
        try {
          const { publicUrl } = await uploadProductImage(supabase, form.id, imgFile);
          const { error: imgErr } = await supabase.rpc("admin_editar_producto", {
            p_session_token: tok,
            p_producto_id: form.id,
            p_patch: { imagen_url: publicUrl },
          });
          if (imgErr) throw imgErr;
        } catch (e) {
          err = e;
        }
      }
    } else {
      const pdata = { ...productoFields, costo: costoNum };
      if ((form.imagen_url || "").trim() && !imgFile) pdata.imagen_url = (form.imagen_url || "").trim();
      const { data: created, error: rpcErr } = await supabase.rpc("create_producto_secure", {
        p_session_token: tok,
        p_producto_data: pdata,
        p_cantidad_inicial: stockInt,
        p_numero_lote: form.lote.trim() || null,
        p_fecha_caducidad: form.fecha_caducidad || null,
        p_costo_unitario: costoNum || null,
        p_user_id: empleadoId,
      });
      err = rpcErr;
      const newId = created?.[0]?.producto_id;
      if (!err && imgFile && newId) {
        try {
          const { publicUrl } = await uploadProductImage(supabase, newId, imgFile);
          const { error: imgErr } = await supabase.rpc("admin_editar_producto", {
            p_session_token: tok,
            p_producto_id: newId,
            p_patch: { imagen_url: publicUrl },
          });
          if (imgErr) throw imgErr;
        } catch (e) {
          showToast("Producto creado; error al subir imagen: " + (e.message || String(e)), "warning");
        }
      }
    }
    setSaving(false);
    if (err) { showToast("Error al guardar: " + (err.message || String(err)), "error"); return; }
    // Fix 3: Audit log en cambios de precio/producto (sesion ya viene de leerSesion() arriba)
    if(form.id) {
      logAudit(sesion, "EDITAR_PRODUCTO", "productos", form.id, {
        nombre: form.nombre, precio: form.precio, costo: form.costo, stock: form.stock
      });
    } else {
      logAudit(sesion, "CREAR_PRODUCTO", "productos", "nuevo", {
        nombre: form.nombre, precio: form.precio
      });
    }
    onSaved();
  };
  const field = (label, key, type="text", required=false) => (
    <div style={{ marginBottom:12 }}>
      <label style={labelStyle}>{label}{required&&<span style={{color:C.red}}> *</span>}</label>
      <input type={type} value={form[key]} onChange={e=>set(key,e.target.value)}
        style={{...inputStyle, borderColor:errors[key]?C.red:C.border}}/>
      {errors[key]&&<span style={{color:C.red,fontSize:10}}>{errors[key]}</span>}
    </div>
  );
  return (
    <div style={{position:"fixed",inset:0,background:"#00000099",zIndex:1000,display:"flex",alignItems:"center",justifyContent:"center"}}>
      <div style={{background:C.card,border:`1px solid ${C.borderHi}`,borderRadius:14,width:"min(680px,95vw)",maxHeight:"90vh",overflowY:"auto",padding:28,boxShadow:"0 24px 60px #00000088"}}>
        <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:20}}>
          <h2 style={{margin:0,color:C.text,fontSize:16,fontWeight:800}}>{form.id?"✏️ Editar producto":"➕ Nuevo producto"}</h2>
          <button onClick={onClose} style={{background:"none",border:"none",color:C.textMid,fontSize:20,cursor:"pointer"}}>✕</button>
        </div>
        <div style={{display:"grid",gridTemplateColumns:"1fr 1fr",gap:"0 18px"}}>
          <div>
            {field("Nombre","nombre","text",true)}
            {field("SKU","sku")}
            {field("Código de barras","codigo_barras")}
            <div style={{marginBottom:12}}>
              <label style={labelStyle}>Categoría</label>
              <select value={form.categoria} onChange={e=>set("categoria",e.target.value)} style={{...inputStyle}}>
                {CATEGORIAS.map(c=><option key={c} value={c}>{c}</option>)}
              </select>
            </div>
            <div style={{marginBottom:12}}>
              <label style={labelStyle}>Tipo</label>
              <select value={form.tipo} onChange={e=>set("tipo",e.target.value)} style={{...inputStyle}}>
                <option value="generico">Genérico</option>
                <option value="marca">Marca</option>
              </select>
            </div>
            {field("Proveedor","proveedor")}
            {!form.id && field("Lote inicial","lote")}
            {!form.id && field("Fecha de caducidad (lote inicial)","fecha_caducidad","date")}
            {form.id && (
              <div style={{marginBottom:12,padding:"10px 12px",background:C.blueDim,borderRadius:8,fontSize:11,color:C.blue,lineHeight:1.5}}>
                💡 Lote y caducidad ahora viven en la tabla <strong>lotes</strong>.
                Para agregar un nuevo lote a este producto usa <strong>📦 Recibir mercancía</strong>.
              </div>
            )}
          </div>
          <div>
            {field("Precio de venta","precio","number",true)}
            {field("Costo","costo","number",true)}
            {field("Stock actual","stock","number",true)}
            {field("Stock mínimo","stock_minimo","number")}
            {field("Descuento %","descuento_pct","number")}
            <div style={{marginBottom:12,display:"flex",alignItems:"center",gap:10}}>
              <input type="checkbox" id="activo_chk" checked={form.activo}
                onChange={e=>set("activo",e.target.checked)} style={{width:16,height:16,cursor:"pointer"}}/>
              <label htmlFor="activo_chk" style={{...labelStyle,margin:0,cursor:"pointer"}}>Producto activo</label>
            </div>
          </div>
        </div>

        <div style={{marginTop:16,padding:16,borderRadius:10,border:`1px solid ${C.border}`,background:C.cardDark}}>
          <label style={{...labelStyle,fontSize:13,fontWeight:700}}>Foto del producto (tienda online)</label>
          <div style={{display:"flex",flexWrap:"wrap",gap:16,alignItems:"flex-start",marginTop:10}}>
            <div style={{width:120,height:120,borderRadius:10,border:`1px solid ${C.border}`,background:C.bg,overflow:"hidden",flexShrink:0}}>
              {(imgPreview || form.imagen_url)
                ? <img alt="" src={imgPreview || form.imagen_url} style={{width:"100%",height:"100%",objectFit:"cover"}}/>
                : <div style={{height:"100%",display:"flex",alignItems:"center",justifyContent:"center",fontSize:40,color:C.textMid}}>💊</div>}
            </div>
            <div style={{flex:1,minWidth:200}}>
              <input type="file" accept="image/jpeg,image/png,image/webp,image/gif" style={{fontSize:11,width:"100%",marginBottom:8}}
                onChange={e=>setImgFile(e.target.files?.[0]||null)}/>
              <div style={{marginBottom:8}}>
                <label style={{...labelStyle,fontSize:10}}>O URL de imagen</label>
                <input type="url" value={form.imagen_url||""} onChange={e=>set("imagen_url",e.target.value)}
                  placeholder="https://..." style={{...inputStyle,fontSize:11}} disabled={!!imgFile}/>
              </div>
              <button type="button" style={{...btnOutline,padding:"6px 12px",fontSize:11}}
                onClick={async()=>{
                  setImgFile(null);
                  set("imagen_url","");
                  if(form.id){
                    const t=sessionStorage.getItem("farmax_session_token");
                    if(!t)return;
                    try{
                      await deleteProductImageStorageFolder(supabase,form.id);
                      await supabase.rpc("admin_editar_producto",{p_session_token:t,p_producto_id:form.id,p_patch:{imagen_url:""}});
                      showToast("Imagen eliminada","info");
                    }catch(ex){showToast(ex.message||"Error","error");}
                  }
                }}>Quitar imagen</button>
              <div style={{color:C.textDim,fontSize:9,marginTop:8,lineHeight:1.4}}>
                Bucket <code>farmax-productos</code> en Supabase (ver <code>sql/storage_farmax_tienda.sql</code>).
              </div>
            </div>
          </div>
        </div>
        
        {/* ── Venta por unidad suelta ── */}
        <div style={{marginTop:16,padding:16,borderRadius:10,border:`1px solid ${C.border}`,background:C.cardDark}}>
          <div style={{display:"flex",alignItems:"center",gap:10,marginBottom:form.venta_unidad?14:0}}>
            <input type="checkbox" id="venta_unidad_chk" checked={form.venta_unidad||false}
              onChange={e=>set("venta_unidad",e.target.checked)} style={{width:16,height:16,cursor:"pointer"}}/>
            <label htmlFor="venta_unidad_chk" style={{...labelStyle,margin:0,cursor:"pointer",fontSize:13,fontWeight:700}}>
              💊 Permite venta por unidad suelta (caja abierta)
            </label>
          </div>
          {form.venta_unidad&&(
            <div style={{display:"grid",gridTemplateColumns:"1fr 1fr 1fr",gap:12,marginTop:12}}>
              <div>
                <label style={labelStyle}>Unidades por caja</label>
                <input type="number" min="1" value={form.unidades_por_caja}
                  onChange={e=>{ set("unidades_por_caja",e.target.value); const pv=parseFloat(form.precio)||0; const u=parseInt(e.target.value)||1; set("precio_unidad", Math.ceil(pv/u)); }}
                  style={inputStyle} placeholder="20"/>
              </div>
              <div>
                <label style={labelStyle}>Precio por unidad ($) <span style={{color:C.textDim,fontSize:9}}>AUTO↑</span></label>
                <input type="number" min="0" step="0.01" value={form.precio_unidad}
                  onChange={e=>set("precio_unidad",Math.ceil(parseFloat(e.target.value)||0))}
                  style={inputStyle} placeholder="3"/>
                <div style={{color:C.textDim,fontSize:9,marginTop:2}}>Se redondea hacia arriba (Math.ceil)</div>
              </div>
              <div>
                <label style={labelStyle}>Stock unidades sueltas</label>
                <input type="number" min="0" value={form.stock_unidades}
                  onChange={e=>set("stock_unidades",e.target.value)}
                  style={inputStyle} placeholder="0"/>
              </div>
              <div style={{gridColumn:"1/-1",background:C.blueDim,borderRadius:8,padding:"8px 12px",fontSize:11,color:C.blue}}>
                💡 SKU unidad: <strong>{(form.sku||"PROD")+"-UNIT"}</strong> · 
                Precio sugerido: <strong>${form.precio&&form.unidades_por_caja?Math.ceil(parseFloat(form.precio)/parseInt(form.unidades_por_caja)):"-"}</strong>/unidad
              </div>
            </div>
          )}
        </div>

        <div style={{display:"flex",justifyContent:"flex-end",gap:10,marginTop:8}}>
          <button style={btnSecondary} onClick={onClose}>Cancelar</button>
          <button style={btnPrimary} onClick={handleSave} disabled={saving}>{saving?"Guardando…":"💾 Guardar"}</button>
        </div>
      </div>
    </div>
  );
}

function RecibirModal({ productos, onClose, onSaved }) {
  const C = C_LIGHT;
  const inputStyle = mkInputStyle(C);
  const labelStyle = mkLabelStyle(C);
  const btnSecondary = mkBtnSecondary(C);
  const btnGreen = mkBtnGreen(C);
  const [busq,     setBusq]    = useState("");
  const [selId,    setSelId]   = useState("");
  const [cantidad, setCantidad]= useState("");
  const [lote,     setLote]    = useState("");
  const [caducidad,setCaduc]   = useState("");
  const [costo,    setCosto]   = useState("");
  const [proveedor,setProv]    = useState("");
  const [saving,   setSaving]  = useState(false);
  const [error,    setError]   = useState("");

  const prodsFilt = productos.filter(p => p.activo && p.nombre.toLowerCase().includes(busq.toLowerCase()));
  const selProd   = productos.find(p => p.id === parseInt(selId));

  const handleRecibir = async () => {
    if (!selId) { setError("Selecciona un producto"); return; }
    if (!cantidad || parseInt(cantidad) <= 0) { setError("Cantidad inválida"); return; }
    setSaving(true); setError("");
    const tok = sessionStorage.getItem("farmax_session_token");
    if (!tok) { setSaving(false); setError("Sesión expirada."); return; }
    const { error: err } = await supabase.rpc("receive_merchandise_secure", {
      p_session_token: tok,
      p_producto_id: selProd.id,
      p_cantidad: parseInt(cantidad),
      p_numero_lote: lote.trim() || null,
      p_fecha_caducidad: caducidad || null,
      p_costo_unitario: costo ? parseFloat(costo) : null,
      p_proveedor: proveedor.trim() || null,
    });
    setSaving(false);
    if (err) { setError("Error: " + err.message); return; }
    onSaved();
  };

  return (
    <div style={{position:"fixed",inset:0,background:"#00000099",zIndex:1000,display:"flex",alignItems:"center",justifyContent:"center"}}>
      <div style={{background:C.card,border:`1px solid ${C.borderHi}`,borderRadius:14,width:"min(520px,95vw)",maxHeight:"90vh",overflowY:"auto",padding:28,boxShadow:"0 24px 60px #00000088"}}>
        <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:20}}>
          <h2 style={{margin:0,color:C.text,fontSize:16,fontWeight:800}}>📦 Recibir mercancía</h2>
          <button onClick={onClose} style={{background:"none",border:"none",color:C.textMid,fontSize:20,cursor:"pointer"}}>✕</button>
        </div>
        <div style={{marginBottom:12}}>
          <label style={labelStyle}>Buscar producto <span style={{color:C.red}}>*</span></label>
          <input value={busq} onChange={e=>{setBusq(e.target.value);setSelId("");}}
            placeholder="Escribe nombre del producto…" style={inputStyle}/>
        </div>
        {busq && !selProd && (
          <div style={{background:C.bg,border:`1px solid ${C.border}`,borderRadius:8,marginBottom:12,maxHeight:160,overflowY:"auto"}}>
            {prodsFilt.length===0
              ? <div style={{padding:12,color:C.textMid,fontSize:12}}>Sin resultados</div>
              : prodsFilt.slice(0,8).map(p=>(
                  <div key={p.id} onClick={()=>{setSelId(String(p.id));setBusq(p.nombre);}}
                    style={{padding:"8px 12px",cursor:"pointer",color:C.text,fontSize:12,borderBottom:`1px solid ${C.border}`}}
                    onMouseEnter={e=>e.currentTarget.style.background=C.blueDim}
                    onMouseLeave={e=>e.currentTarget.style.background="transparent"}>
                    <strong>{p.nombre}</strong>
                    <span style={{color:C.textMid,marginLeft:8}}>Stock: <strong style={{color:C.amber}}>{p.stock}</strong></span>
                  </div>
                ))
            }
          </div>
        )}
        {selProd && (
          <div style={{background:C.blueDim,border:`1px solid ${C.blue}30`,borderRadius:8,padding:"10px 14px",marginBottom:16}}>
            <div style={{color:C.blue,fontWeight:700,fontSize:13}}>{selProd.nombre}</div>
            <div style={{color:C.textMid,fontSize:11,marginTop:4}}>
              Stock actual: <strong style={{color:C.amber}}>{selProd.stock}</strong>
              {selProd.stock_minimo ? ` · Mínimo: ${selProd.stock_minimo}` : ""}
              {selProd.min_caducidad_lotes ? ` · Próx. caduca: ${selProd.min_caducidad_lotes}` : ""}
            </div>
          </div>
        )}
        <div style={{display:"grid",gridTemplateColumns:"1fr 1fr",gap:"0 16px"}}>
          <div>
            <div style={{marginBottom:12}}>
              <label style={labelStyle}>Cantidad a recibir <span style={{color:C.red}}>*</span></label>
              <input type="number" value={cantidad} onChange={e=>setCantidad(e.target.value)} min="1" placeholder="0" style={inputStyle}/>
            </div>
            <div style={{marginBottom:12}}>
              <label style={labelStyle}>Nuevo lote</label>
              <input value={lote} onChange={e=>setLote(e.target.value)} placeholder="Ej. L-20250101" style={inputStyle}/>
            </div>
            <div style={{marginBottom:12}}>
              <label style={labelStyle}>Nueva fecha de caducidad</label>
              <input type="date" value={caducidad} onChange={e=>setCaduc(e.target.value)} style={inputStyle}/>
            </div>
          </div>
          <div>
            <div style={{marginBottom:12}}>
              <label style={labelStyle}>Nuevo costo unitario</label>
              <input type="number" value={costo} onChange={e=>setCosto(e.target.value)}
                placeholder={selProd?`Actual: $${selProd.costo}`:"$0.00"} style={inputStyle}/>
            </div>
            <div style={{marginBottom:12}}>
              <label style={labelStyle}>Proveedor</label>
              <input value={proveedor} onChange={e=>setProv(e.target.value)} placeholder="Nadro, Marzam…" style={inputStyle}/>
            </div>
            {selProd && cantidad && parseInt(cantidad)>0 && (
              <div style={{background:C.greenDim,border:`1px solid ${C.green}30`,borderRadius:8,padding:"10px 14px",marginTop:4}}>
                <div style={{color:C.textMid,fontSize:10,fontWeight:700}}>NUEVO STOCK</div>
                <div style={{color:C.green,fontWeight:800,fontSize:22}}>{(selProd.stock||0)+parseInt(cantidad)}</div>
                <div style={{color:C.textMid,fontSize:10}}>({selProd.stock} + {cantidad})</div>
              </div>
            )}
          </div>
        </div>
        {error && <div style={{color:C.red,fontSize:12,marginBottom:8}}>{error}</div>}
        <div style={{display:"flex",justifyContent:"flex-end",gap:10,marginTop:12}}>
          <button style={btnSecondary} onClick={onClose}>Cancelar</button>
          <button style={btnGreen} onClick={handleRecibir} disabled={saving||!selId||!cantidad}>
            {saving?"Guardando…":"📦 Recibir mercancía"}
          </button>
        </div>
      </div>
    </div>
  );
}

export default function InventarioModule() {
  const C = C_LIGHT;
  const inputStyle = mkInputStyle(C);
  const labelStyle = mkLabelStyle(C);
  const btnPrimary = mkBtnPrimary(C);
  const btnOutline = mkBtnOutline(C);
  const btnGreen = mkBtnGreen(C);
  const btnSecondary = mkBtnSecondary(C);
  const isMobileInv = useMediaQuery("(max-width: 768px)");
  const [productos,       setProductos]       = useState([]);
  const [loading,         setLoading]         = useState(true);
  const [busqueda,        setBusqueda]        = useState("");
  const [verInactivos,    setVerInactivos]    = useState(false);
  const [filtroCategoria, setFiltroCategoria] = useState("todas");
  const [filtroAlerta,    setFiltroAlerta]    = useState("todos");
  const [modal,           setModal]           = useState(null);
  const [modalRecibir,    setModalRecibir]    = useState(false);
  const [modalImportar,   setModalImportar]   = useState(false);
  const [importando,      setImportando]      = useState(false);
  const [importResult,    setImportResult]    = useState(null);
  const [paginaInv, setPaginaInv] = useState(1);
  const [modalLotes, setModalLotes] = useState(null);
  // N8: Resetear página al cambiar filtros
  useEffect(()=>{ setPaginaInv(1); },[filtroCategoria,filtroAlerta,busqueda]);
  const INV_POR_PAG = 50;

  const procesarArchivo = (file) => {
    const reader = new FileReader();
    reader.onload = e => {
      const texto = e.target.result;
      const result = parsearCSV(texto);
      if(!result.ok && result.rows.length===0){
        setImportResult({error: result.msg||"No se pudieron leer productos del archivo. Verifica el formato."});
      } else {
        setImportResult(result);
      }
    };
    reader.onerror = () => setImportResult({error:"Error al leer el archivo."});
    reader.readAsText(file, "UTF-8");
  };

  const confirmarImport = async () => {
    if(!importResult?.rows?.length) return;
    setImportando(true);
    const tok = sessionStorage.getItem("farmax_session_token");
    if (!tok) { setImportando(false); showToast("Sesión expirada.", "error"); return; }
    let ok = 0, err = 0;
    for (const row of importResult.rows) {
      const { stock, lote, fecha_caducidad, costo, ...resto } = row;
      const { error: rpcErr } = await supabase.rpc("create_producto_secure", {
        p_session_token: tok,
        p_producto_data: { ...resto, costo: costo ?? null },
        p_cantidad_inicial: stock || 0,
        p_numero_lote: lote || null,
        p_fecha_caducidad: fecha_caducidad || null,
        p_costo_unitario: costo ?? null,
      });
      if (rpcErr) { err++; console.error("Import error:", rpcErr); }
      else ok++;
    }
    setImportando(false);
    setModalImportar(false);
    setImportResult(null);
    fetchProductos();
    if (err > 0) showToast(`Importados ${ok} productos. ${err} con error.`, "warning");
    else showToast(`✅ ${ok} productos importados correctamente`, "success");
  };

  const liquidar = async (prod) => {
    const pct = window.prompt(`¿Qué % de descuento aplicar para liquidar "${prod.nombre}"?\nPrecio actual: $${prod.precio}`, "30");
    if (!pct || isNaN(pct) || parseFloat(pct)<=0 || parseFloat(pct)>=100) return;
    const tok = sessionStorage.getItem("farmax_session_token");
    const { error } = await supabase.rpc("admin_editar_producto", {
      p_session_token: tok,
      p_producto_id: prod.id,
      p_patch: { descuento_pct: parseFloat(pct) },
    });
    if (error) { showToast("Error al liquidar: "+error.message, "error"); return; }
    showToast(`✅ ${prod.nombre} liquidado con ${pct}% descuento. Nuevo precio: $${nuevoPrecio}`, "success");
    fetchProductos();
  };

  const fetchProductos = useCallback(async () => {
    setLoading(true);
    let q = supabase.from("productos")
      .select("*, lotes(id,numero_lote,fecha_caducidad,cantidad_actual,costo_unitario,activo)")
      .order("nombre");
    if (!verInactivos) q = q.eq("activo", true);
    const { data, error } = await q;
    if (!error) {
      const enriched = (data || []).map(p => ({
        ...p,
        min_caducidad_lotes: minCaducidadLotes(p.lotes),
        lotes_activos: (p.lotes || []).filter(l => l.activo !== false && (l.cantidad_actual || 0) > 0),
      }));
      setProductos(enriched);
    }
    setLoading(false);
  }, [verInactivos]);

  useEffect(() => { fetchProductos(); }, [fetchProductos]);

  const filtradosTodosInv = productos.filter(p => {
    const q   = busqueda.toLowerCase();
    const txt = p.nombre?.toLowerCase().includes(q) || p.sku?.toLowerCase().includes(q);
    const cat = filtroCategoria === "todas" || p.categoria === filtroCategoria;
    const dias = diasParaCaducar(p.min_caducidad_lotes);
    const alerta =
      filtroAlerta === "todos"       ? true :
      filtroAlerta === "bajo_stock"  ? (p.stock <= (p.stock_minimo??0)) :
      filtroAlerta === "por_caducar" ? (dias !== null && dias <= 30 && dias >= 0) : true;
    return txt && cat && alerta;
  });
  const filtrados = filtradosTodosInv.slice((paginaInv-1)*INV_POR_PAG, paginaInv*INV_POR_PAG);

  const activos    = productos.filter(p => p.activo).length;
  const bajoStock  = productos.filter(p => p.activo && p.stock<=(p.stock_minimo??0)).length;
  const porCaducar = productos.filter(p => { const d=diasParaCaducar(p.min_caducidad_lotes); return d!==null&&d<=30&&d>=0; }).length;
  const inactivos  = productos.filter(p => !p.activo).length;

  const desactivar = async (id) => {
    if (!window.confirm("¿Desactivar este producto?")) return;
    const tok = sessionStorage.getItem("farmax_session_token");
    const { error } = await supabase.rpc("admin_toggle_producto", {
      p_session_token: tok, p_producto_id: id, p_activo: false,
    });
    if (error) showToast("Error: "+error.message, "error");
    fetchProductos();
  };
  const reactivar = async (id) => {
    const tok = sessionStorage.getItem("farmax_session_token");
    const { error } = await supabase.rpc("admin_toggle_producto", {
      p_session_token: tok, p_producto_id: id, p_activo: true,
    });
    if (error) showToast("Error: "+error.message, "error");
    fetchProductos();
  };

  return (
    <div style={{padding:24,background:C.bg,minHeight:"100vh",fontFamily:"'Plus Jakarta Sans',sans-serif"}}>

      <div style={{
        display:"flex",
        flexDirection:isMobileInv?"column":"row",
        justifyContent:"space-between",
        alignItems:isMobileInv?"stretch":"center",
        marginBottom:20,
        flexWrap:isMobileInv?"nowrap":"wrap",
        gap:12,
      }}>
        <div style={{ minWidth: 0 }}>
          <h1 style={{margin:0,color:C.text,fontSize:20,fontWeight:800}}>▤ Inventario</h1>
          <p style={{margin:"4px 0 0",color:C.textMid,fontSize:12}}>Gestión de productos · Farmax</p>
        </div>
        <div style={isMobileInv ? {
          display:"grid",
          gridTemplateColumns:"1fr 1fr",
          gap:8,
          width:"100%",
        } : { display:"flex", gap:8, flexWrap:"wrap" }}>
          <button data-tour="inv-agregar" style={{...btnPrimary, ...(isMobileInv ? { gridColumn:"1 / -1", padding:"11px 16px", fontSize:13 } : {})}} onClick={()=>setModal(EMPTY)}>
            ➕ Nuevo producto
          </button>
          <button style={btnOutline} onClick={()=>setModalRecibir(true)}>
            {isMobileInv ? "📦 Recibir" : "📦 Recibir mercancía"}
          </button>
          <button style={btnOutline} onClick={()=>setModalImportar(true)}>
            {isMobileInv ? "📥 Importar" : "📥 Importar CSV"}
          </button>
          <button style={btnOutline} onClick={descargarPlantilla}>📋 Plantilla</button>
          <button style={btnOutline} onClick={()=>exportarCSV(filtrados)}>
            {isMobileInv ? "⬇ Exportar" : "⬇ Exportar CSV"}
          </button>
        </div>
      </div>

      <div style={{display:"flex",gap:12,marginBottom:20,flexWrap:"wrap"}}>
        {[
          {label:"Activos",     val:activos,    col:C.blue},
          {label:"Bajo stock",  val:bajoStock,  col:C.amber, click:()=>setFiltroAlerta("bajo_stock")},
          {label:"Por caducar", val:porCaducar, col:C.red,   click:()=>setFiltroAlerta("por_caducar")},
          {label:"Inactivos",   val:inactivos,  col:C.textMid},
        ].map(s=>(
          <div key={s.label} onClick={s.click} style={{
            background:C.card,border:`1px solid ${C.border}`,borderRadius:10,
            padding:"10px 18px",minWidth:110,cursor:s.click?"pointer":"default"}}
            onMouseEnter={e=>{if(s.click)e.currentTarget.style.border=`1px solid ${s.col}`;}}
            onMouseLeave={e=>{if(s.click)e.currentTarget.style.border=`1px solid ${C.border}`;}}>
            <div style={{color:s.col,fontWeight:800,fontSize:22}}>{s.val}</div>
            <div style={{color:C.textMid,fontSize:11}}>{s.label}</div>
          </div>
        ))}
      </div>

      <div data-tour="inv-buscar" style={{display:"flex",gap:10,marginBottom:16,flexWrap:"wrap",alignItems:"center"}}>
        <SearchDropdown value={busqueda} onChange={setBusqueda} onSelect={p=>setBusqueda(p.nombre)} placeholder="🔍 Nombre o SKU…" items={productos} labelKey="nombre" subKey="sku" badgeKey="stock" badgeCol="#0099e6" style={{flex:1}} emptyMsg="Sin productos"/>
        <select value={filtroCategoria} onChange={e=>setFiltroCategoria(e.target.value)} style={{...inputStyle,maxWidth:180}}>
          <option value="todas">Todas las categorías</option>
          {CATEGORIAS.map(c=><option key={c} value={c}>{c}</option>)}
        </select>
        <select value={filtroAlerta} onChange={e=>setFiltroAlerta(e.target.value)} style={{...inputStyle,maxWidth:180}}>
          <option value="todos">Todas las alertas</option>
          <option value="bajo_stock">⚠ Bajo stock</option>
          <option value="por_caducar">⏰ Por caducar (30d)</option>
        </select>
        <label style={{display:"flex",alignItems:"center",gap:7,cursor:"pointer",color:C.textMid,fontSize:12,fontWeight:600}}>
          <div onClick={()=>setVerInactivos(v=>!v)} style={{width:36,height:20,borderRadius:10,cursor:"pointer",
            background:verInactivos?C.blue:C.border,position:"relative",transition:"background .2s"}}>
            <div style={{position:"absolute",top:3,left:verInactivos?18:3,width:14,height:14,borderRadius:"50%",background:C.card,transition:"left .2s"}}/>
          </div>
          Ver inactivos
        </label>
        {(filtroCategoria!=="todas"||filtroAlerta!=="todos"||busqueda)&&(
          <button onClick={()=>{setFiltroCategoria("todas");setFiltroAlerta("todos");setBusqueda("");}}
            style={{...btnSecondary,padding:"7px 12px",fontSize:11}}>✕ Limpiar filtros</button>
        )}
        <span style={{color:C.textMid,fontSize:11,marginLeft:"auto"}}>
          {filtrados.length} producto{filtrados.length!==1?"s":""}
        </span>
      </div>

      {loading ? (
        <SkeletonTable rows={8} cols={7}/>
      ) : (
        <HorizontalScrollSync data-tour="inv-tabla">
          <table style={{width:"100%",minWidth:1100,borderCollapse:"collapse",fontSize:12}}>
            <thead>
              <tr style={{background:C.card}}>
                {["SKU","Nombre","Categoría","Tipo","Stock","Mín","Precio","Costo","Margen%","Cad. (días)","Agot. (días)","Desc%","Estado","Acciones"].map(h=>(
                  <th key={h} style={{padding:"10px 12px",textAlign:"left",color:C.textMid,fontWeight:700,
                    borderBottom:`1px solid ${C.border}`,whiteSpace:"nowrap"}}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {filtrados.length===0&&(
                <tr><td colSpan={13} style={{textAlign:"center",padding:32,color:C.textMid}}>
                  Sin productos{busqueda?` para "${busqueda}"`:""}. Agrega el primero con ➕
                </td></tr>
              )}
              {filtrados.map((p,_rowIdx)=>{
                const bajo    = p.activo && p.stock<=(p.stock_minimo??0);
                const inact   = !p.activo;
                const dias    = diasParaCaducar(p.min_caducidad_lotes);
                const nearCad = dias!==null && dias<=30 && dias>=0;
                const mgn     = margen(p.precio, p.costo);
                const mgnNum  = parseFloat(mgn);
                const mgnCol  = isNaN(mgnNum)?C.textMid:mgnNum>=30?C.green:mgnNum>=15?C.amber:C.red;
                return (
                  <tr key={p.id} className="farmax-table-row" style={{opacity:inact?0.45:1,background:bajo?C.amberDim:nearCad?C.redDim:"transparent"}}>
                    <td style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{p.sku||"—"}</td>
                    <td style={{padding:"8px 12px",color:inact?C.textDim:C.text,fontWeight:600,borderBottom:`1px solid ${C.border}`}}>{p.nombre}</td>
                    <td style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{p.categoria}</td>
                    <td style={{padding:"8px 12px",borderBottom:`1px solid ${C.border}`}}>
                      <span style={{padding:"2px 8px",borderRadius:20,fontSize:10,fontWeight:700,
                        background:p.tipo==="marca"?"#9d6fff18":C.blueDim,color:p.tipo==="marca"?"#9d6fff":C.blue}}>{p.tipo}</span>
                    </td>
                    <td style={{padding:"8px 12px",fontWeight:700,borderBottom:`1px solid ${C.border}`,color:bajo?C.amber:C.green}}>{p.stock}</td>
                    <td style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{p.stock_minimo??0}</td>
                    <td style={{padding:"8px 12px",color:C.text,borderBottom:`1px solid ${C.border}`}}>${parseFloat(p.precio||0).toFixed(2)}</td>
                    <td style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>${parseFloat(p.costo||0).toFixed(2)}</td>
                    <td style={{padding:"8px 12px",fontWeight:700,borderBottom:`1px solid ${C.border}`,color:mgnCol}}>{mgn}</td>
                    <td style={{padding:"8px 12px",borderBottom:`1px solid ${C.border}`,whiteSpace:"nowrap"}}>
                      {dias===null?"—":(
                        <span style={{color:nearCad?C.red:dias<=60?C.amber:C.textMid,fontWeight:nearCad?700:400}}>
                          {dias<0?"Vencido":dias===0?"Hoy":dias+" d"}
                        </span>
                      )}
                    </td>
                    <td style={{padding:"8px 12px",borderBottom:`1px solid ${C.border}`}}>
                      {(()=>{
                        if(!p.stock||!p.stock_minimo) return "—";
                        const ventaDiaria = Math.max(p.stock_minimo*0.15,0.5);
                        const diasAgot = Math.floor(p.stock/ventaDiaria);
                        const col = diasAgot<7?C.red:diasAgot<15?C.amber:C.green;
                        return <span style={{color:col,fontWeight:700,fontSize:11}}>~{diasAgot}d</span>;
                      })()}
                    </td>
                    <td style={{padding:"8px 12px",borderBottom:`1px solid ${C.border}`}}>
                      {p.descuento_pct>0?<span style={{color:C.amber,fontWeight:700}}>{p.descuento_pct}%</span>:"—"}
                    </td>
                    <td style={{padding:"8px 12px",borderBottom:`1px solid ${C.border}`}}>
                      <span style={{padding:"2px 8px",borderRadius:20,fontSize:10,fontWeight:700,
                        background:p.activo?C.greenDim:C.redDim,color:p.activo?C.green:C.red}}>
                        {p.activo?"Activo":"Inactivo"}</span>
                    </td>
                    <td style={{padding:"8px 12px",borderBottom:`1px solid ${C.border}`,whiteSpace:"nowrap"}}>
                      <button onClick={()=>setModal(p)} style={{background:C.blueDim,border:`1px solid ${C.blue}30`,
                        color:C.blue,borderRadius:6,padding:"4px 10px",cursor:"pointer",fontSize:11,fontWeight:700,marginRight:6}}>
                        ✏️ Editar</button>
                      <button onClick={()=>setModalLotes(p)} style={{background:"#f1f5f9",border:`1px solid ${C.border}`,
                        color:C.textMid,borderRadius:6,padding:"4px 10px",cursor:"pointer",fontSize:11,fontWeight:700,marginRight:6}}>
                        📦 Lotes ({(p.lotes_activos||[]).length})</button>
                      {p.min_caducidad_lotes && diasParaCaducar(p.min_caducidad_lotes)<=30 && diasParaCaducar(p.min_caducidad_lotes)>=0 && (
                        <button onClick={()=>liquidar(p)}
                          style={{...btnSecondary,padding:"5px 10px",fontSize:10,color:C.red,borderColor:C.red,background:C.redDim,marginLeft:4}}>
                          🏷️ Liquidar
                        </button>
                      )}
                      {p.activo?(
                        <button onClick={()=>desactivar(p.id)} style={{background:C.redDim,border:`1px solid ${C.red}30`,
                          color:C.red,borderRadius:6,padding:"4px 10px",cursor:"pointer",fontSize:11,fontWeight:700}}>
                          🔴 Desactivar</button>
                      ):(
                        <button onClick={()=>reactivar(p.id)} style={{background:C.greenDim,border:`1px solid ${C.green}30`,
                          color:C.green,borderRadius:6,padding:"4px 10px",cursor:"pointer",fontSize:11,fontWeight:700}}>
                          ✅ Reactivar</button>
                      )}
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </HorizontalScrollSync>
      )}

      {modal!==null&&(
        <ProductoModal key={modal.id ?? "nuevo"} initial={modal} onClose={()=>setModal(null)}
          onSaved={()=>{setModal(null);fetchProductos();}}/>
      )}
      {modalLotes&&(
        <div style={{position:"fixed",inset:0,background:"rgba(15,23,42,.45)",backdropFilter:"blur(4px)",zIndex:1000,display:"flex",alignItems:"center",justifyContent:"center",padding:20}}
          onClick={e=>e.target===e.currentTarget&&setModalLotes(null)}>
          <div style={{background:C.card,borderRadius:14,width:"min(720px,95vw)",maxHeight:"85vh",overflowY:"auto",padding:24,boxShadow:"0 20px 60px rgba(0,82,204,.15)"}}>
            <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:16}}>
              <div>
                <h3 style={{margin:0,color:C.text,fontSize:15,fontWeight:800}}>📦 Lotes de {modalLotes.nombre}</h3>
                <div style={{color:C.textMid,fontSize:11,marginTop:2}}>
                  Stock total: <strong style={{color:C.blue}}>{modalLotes.stock}</strong>
                  {` · ${(modalLotes.lotes_activos||[]).length} lote(s) activo(s)`}
                </div>
              </div>
              <button onClick={()=>setModalLotes(null)} style={{background:"none",border:"none",color:C.textMid,fontSize:20,cursor:"pointer"}}>✕</button>
            </div>
            {(modalLotes.lotes_activos||[]).length===0 ? (
              <div style={{textAlign:"center",padding:40,color:C.textMid,fontSize:13}}>
                Este producto no tiene lotes activos. Usa <strong>📦 Recibir mercancía</strong> para agregar uno.
              </div>
            ) : (
              <table style={{width:"100%",borderCollapse:"collapse",fontSize:12}}>
                <thead>
                  <tr style={{background:C.cardDark}}>
                    {["Lote","Caducidad","Días","Cantidad","Costo unit."].map(h=>(
                      <th key={h} style={{padding:"8px 12px",textAlign:"left",color:C.textMid,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{h}</th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {(modalLotes.lotes_activos||[])
                    .slice()
                    .sort((a,b)=>{
                      if(!a.fecha_caducidad) return 1;
                      if(!b.fecha_caducidad) return -1;
                      return a.fecha_caducidad.localeCompare(b.fecha_caducidad);
                    })
                    .map((l,i)=>{
                      const dias = diasParaCaducar(l.fecha_caducidad);
                      const col  = dias===null?C.textMid:dias<0?C.red:dias<=15?C.red:dias<=30?C.amber:C.green;
                      return (
                        <tr key={l.id} style={{background:i%2===0?"transparent":"#f8fafc"}}>
                          <td style={{padding:"8px 12px",color:C.text,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{l.numero_lote||"—"}</td>
                          <td style={{padding:"8px 12px",color:col,fontWeight:600,borderBottom:`1px solid ${C.border}`}}>{l.fecha_caducidad||"—"}</td>
                          <td style={{padding:"8px 12px",borderBottom:`1px solid ${C.border}`}}>
                            {dias===null?"—":<span style={{padding:"2px 8px",borderRadius:20,fontSize:10,fontWeight:700,background:col+"20",color:col}}>{dias<0?"Vencido":dias===0?"Hoy":`${dias}d`}</span>}
                          </td>
                          <td style={{padding:"8px 12px",color:C.blue,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{l.cantidad_actual}</td>
                          <td style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>${parseFloat(l.costo_unitario||0).toFixed(2)}</td>
                        </tr>
                      );
                    })}
                </tbody>
              </table>
            )}
          </div>
        </div>
      )}
      {modalRecibir&&(
        <RecibirModal productos={productos} onClose={()=>setModalRecibir(false)}
          onSaved={()=>{setModalRecibir(false);fetchProductos();}}/>
      )}

      {/* Modal Importar CSV */}
      {modalImportar&&(
        <div style={{position:"fixed",inset:0,background:"rgba(15,23,42,.45)",backdropFilter:"blur(4px)",zIndex:1000,display:"flex",alignItems:"center",justifyContent:"center",padding:20}}
          onClick={e=>e.target===e.currentTarget&&setModalImportar(false)}>
          <div style={{background:C.card,borderRadius:14,width:"min(580px,95vw)",maxHeight:"90vh",overflowY:"auto",padding:28,boxShadow:"0 20px 60px rgba(0,82,204,.15)"}}>
            <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:20}}>
              <h2 style={{margin:0,color:C.text,fontSize:16,fontWeight:800}}>📥 Importar productos desde CSV</h2>
              <button onClick={()=>{setModalImportar(false);setImportResult(null);}} style={{background:"none",border:"none",color:C.textMid,fontSize:22,cursor:"pointer"}}>✕</button>
            </div>
            <div style={{background:"#eff6ff",border:"1px solid #bfdbfe",borderRadius:10,padding:14,marginBottom:16}}>
              <div style={{color:"#1d4ed8",fontWeight:700,fontSize:13,marginBottom:8}}>📋 Instrucciones</div>
              <ol style={{color:"#1d4ed8",fontSize:12,paddingLeft:18,lineHeight:1.8,margin:0}}>
                <li>Descarga la plantilla con el botón de abajo</li>
                <li>Ábrela en Excel o Google Sheets</li>
                <li>Agrega tus productos (una fila por producto)</li>
                <li>Guarda como CSV (separado por comas)</li>
                <li>Sube el archivo aquí</li>
              </ol>
            </div>
            <button onClick={descargarPlantilla} style={{width:"100%",padding:"10px",borderRadius:8,border:"1px solid #0052cc",background:"#eff6ff",color:"#0052cc",fontWeight:700,fontSize:13,cursor:"pointer",marginBottom:16,display:"flex",alignItems:"center",justifyContent:"center",gap:8}}>
              📋 Descargar plantilla Excel/CSV
            </button>
            <div style={{border:"2px dashed #e2e8f0",borderRadius:10,padding:24,textAlign:"center",marginBottom:16,cursor:"pointer",background:C.cardDark}}
              onClick={()=>document.getElementById("csv_input").click()}
              onDragOver={e=>{e.preventDefault();e.currentTarget.style.borderColor="#0052cc";}}
              onDragLeave={e=>{e.currentTarget.style.borderColor="#e2e8f0";}}
              onDrop={e=>{e.preventDefault();e.currentTarget.style.borderColor="#e2e8f0";const f=e.dataTransfer.files[0];if(f)procesarArchivo(f);}}>
              <div style={{fontSize:36,marginBottom:8}}>📄</div>
              <div style={{color:C.text,fontWeight:700,fontSize:14,marginBottom:4}}>Arrastra tu archivo CSV aquí</div>
              <div style={{color:C.textMid,fontSize:12}}>o haz clic para seleccionar · .csv o .txt</div>
              <input id="csv_input" type="file" accept=".csv,.txt" style={{display:"none"}}
                onChange={e=>{const f=e.target.files[0];if(f)procesarArchivo(f);e.target.value="";}}/>
            </div>
            {importResult&&(
              <div>
                {importResult.error?(
                  <div style={{background:"#fee2e2",border:"1px solid #fca5a5",borderRadius:8,padding:12,marginBottom:12,color:"#dc2626",fontSize:13}}>❌ {importResult.error}</div>
                ):(
                  <div>
                    <div style={{background:"#dcfce7",border:"1px solid #86efac",borderRadius:8,padding:12,marginBottom:12}}>
                      <div style={{color:"#16a34a",fontWeight:700,fontSize:13}}>✅ {importResult.rows.length} productos listos para importar</div>
                      {importResult.msg&&<div style={{color:"#16a34a",fontSize:11,marginTop:4}}>⚠️ {importResult.msg}</div>}
                    </div>
                    <div style={{maxHeight:200,overflowY:"auto",border:`1px solid ${C.border}`,borderRadius:8,marginBottom:16}}>
                      <table style={{width:"100%",borderCollapse:"collapse",fontSize:11}}>
                        <thead><tr style={{background:C.cardDark}}>
                          {["Nombre","SKU","Categoría","Stock","Precio","Caducidad"].map(h=><th key={h} style={{padding:"6px 10px",textAlign:"left",color:C.textMid,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{h}</th>)}
                        </tr></thead>
                        <tbody>
                          {importResult.rows.slice(0,20).map((r,i)=>(
                            <tr key={i} style={{background:i%2===0?"transparent":"#f8fafc"}}>
                              <td style={{padding:"5px 10px",color:C.text,fontWeight:600,borderBottom:`1px solid ${C.border}`}}>{r.nombre}</td>
                              <td style={{padding:"5px 10px",color:C.textMid,borderBottom:`1px solid ${C.border}`,fontFamily:"monospace"}}>{r.sku||"—"}</td>
                              <td style={{padding:"5px 10px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{r.categoria}</td>
                              <td style={{padding:"5px 10px",color:"#0099e6",fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{r.stock}</td>
                              <td style={{padding:"5px 10px",color:"#00c46a",fontWeight:700,borderBottom:`1px solid ${C.border}`}}>${r.precio}</td>
                              <td style={{padding:"5px 10px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{r.fecha_caducidad||"—"}</td>
                            </tr>
                          ))}
                          {importResult.rows.length>20&&<tr><td colSpan={6} style={{padding:"6px 10px",color:C.textDim,fontSize:10,textAlign:"center"}}>...y {importResult.rows.length-20} más</td></tr>}
                        </tbody>
                      </table>
                    </div>
                    <button onClick={confirmarImport} disabled={importando}
                      style={{width:"100%",padding:"12px",borderRadius:8,border:"none",background:"linear-gradient(135deg,#0052cc,#0099e6)",color:"#fff",fontWeight:700,fontSize:14,cursor:"pointer",opacity:importando?.6:1}}>
                      {importando?`Importando... (${importResult.rows.length} productos)`:"✅ Confirmar importación"}
                    </button>
                  </div>
                )}
              </div>
            )}
          </div>
        </div>
      )}
      <OnboardingTour tourId="inv" />
    </div>
  );
}
