import { useState, useEffect, useCallback, useMemo, useRef } from "react";
import { C_LIGHT } from "./constants";
import { supabase } from "./supabase";
import { showToast, HorizontalScrollSync, TABLA_SCROLL_MAX } from "./ui";
import { inventarioProductMatchesBusqueda, inventarioSearchRelevanceRank, normalizeCatalogSearchQuery } from "./utils/fuzzySearch";
import { normalizeForSearch } from "./utils";
import { findProductExactScan } from "./utils/barcodeProductLookup";
import { etiquetaProductoInventario } from "./utils/parseNombreProducto";
import {
  compararLotesPeps,
  fechaCaducidadInvalida,
  fetchLotesInventario,
  fetchProductosPaginados,
  PRODUCTOS_SELECT_LOTES,
} from "./lib/inventarioHubData";
import { DIAS_CADUCIDAD_ALERTA, DIAS_CADUCIDAD_CRITICO } from "./lib/caducidad";

const BRAND = { primary:"#0D1B2A", secondary:"#1E3ABA", gradient:"linear-gradient(135deg,#0D1B2A,#1E3ABA)" };
const fmt = n => `$${parseFloat(n||0).toFixed(2)}`;
const mkInpS = (C) => ({width:"100%",boxSizing:"border-box",padding:"8px 12px",borderRadius:8,border:`1px solid ${C.border}`,background:C.card,color:C.text,fontSize:13,outline:"none"});

/** Producto enriquecido para búsqueda / etiqueta en fila de lote. */
function loteRowProducto(lote, prodById) {
  const fromCatalog = prodById[String(lote.producto_id)] || {};
  const fromRpc = lote.productos || {};
  return { ...fromRpc, ...fromCatalog };
}

function loteRowMatchesBusqueda(lote, product, queryRaw) {
  const q = String(queryRaw || "").trim();
  if (!q) return true;
  if (product && inventarioProductMatchesBusqueda(product, q)) return true;
  const qn = normalizeCatalogSearchQuery(q);
  if (!qn) return true;
  const hay = [
    product?.nombre,
    product?.marca,
    product?.sku,
    product?.codigo_barras,
    product?.categoria,
    product?.presentacion,
    lote?.numero_lote,
  ]
    .map((v) => normalizeForSearch(v))
    .filter(Boolean);
  return hay.some((h) => h.includes(qn));
}

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
  const [filtroCat,   setFiltroCat]   = useState("catalogo");
  const [form,        setForm]        = useState({
    producto_id:"", numero_lote:"", fecha_caducidad:"",
    cantidad_inicial:"", costo_unitario:"", proveedor_id:"",
    fecha_recepcion: new Date().toLocaleDateString("sv-SE"),
  });
  const [prodBusq, setProdBusq] = useState("");
  const [scanErr, setScanErr] = useState("");
  const prodBusqRef = useRef(null);
  const cantidadRef = useRef(null);
  const caducidadRef = useRef(null);
  const [saving, setSaving] = useState(false);

  const fetchData = useCallback(async()=>{
    setLoading(true);
    const tok = sessionStorage.getItem("farmacapital_session_token");
    if (!tok) {
      setLotes([]);
      setProductos([]);
      setProveedores([]);
      setLoading(false);
      return;
    }
    const [lsRes, psRes, pvRes] = await Promise.all([
      fetchLotesInventario(tok),
      fetchProductosPaginados({ select: PRODUCTOS_SELECT_LOTES, activosSolo: false, order: "nombre" }),
      supabase.rpc("empleado_listar_proveedores_catalogo", { p_session_token: tok }),
    ]);
    if (lsRes.error) showToast("No se pudieron cargar lotes: " + lsRes.error.message, "error");
    if (psRes.error) showToast("No se pudo cargar catálogo: " + psRes.error.message, "error");
    const lotRows = Array.isArray(lsRes.data) ? [...lsRes.data] : [];
    lotRows.sort(compararLotesPeps);
    setLotes(lotRows);
    setProductos(Array.isArray(psRes.data) ? psRes.data : []);
    setProveedores(Array.isArray(pvRes.data) ? pvRes.data : []);
    setLoading(false);
  },[]);

  useEffect(()=>{ fetchData(); },[fetchData]);

  const diasRestantes = fecha => {
    if(!fecha) return null;
    if (fechaCaducidadInvalida(fecha)) return "invalida";
    return Math.floor((new Date(fecha)-new Date())/86400000);
  };

  const colCad = d => d===null?"#94a3b8":d==="invalida"?C.amber:d<0?C.red:d<=DIAS_CADUCIDAD_CRITICO?C.red:d<=DIAS_CADUCIDAD_ALERTA?C.amber:C.green;
  const txtCad = d => d===null?"Sin fecha":d==="invalida"?"Revisar año":d<0?"VENCIDO":d===0?"HOY":`${d} días`;

  const prodById = useMemo(
    () => Object.fromEntries(productos.map((p) => [String(p.id), p])),
    [productos]
  );

  const lotesFiltrados = useMemo(() => {
    const q = filtroP.trim();
    const list = lotes.filter((l) => {
      const prod = loteRowProducto(l, prodById);
      const enCatalogo = prod.activo !== false;
      const matchCat =
        filtroCat === "todos" ? true :
        filtroCat === "catalogo" ? enCatalogo :
        filtroCat === "fuera" ? !enCatalogo : true;
      const matchP = loteRowMatchesBusqueda(l, prod, q);
      const dias = diasRestantes(l.fecha_caducidad);
      const matchV =
        filtroVenc === "todos" ? true :
        filtroVenc === "vencidos" ? (typeof dias === "number" && dias < 0) :
        filtroVenc === "criticos" ? (typeof dias === "number" && dias >= 0 && dias <= DIAS_CADUCIDAD_CRITICO) :
        filtroVenc === "pronto" ? (typeof dias === "number" && dias > DIAS_CADUCIDAD_CRITICO && dias <= DIAS_CADUCIDAD_ALERTA) : true;
      return matchCat && matchP && matchV;
    });
    if (!q) return list;
    return list.sort(
      (a, b) =>
        inventarioSearchRelevanceRank(loteRowProducto(a, prodById), q)
        - inventarioSearchRelevanceRank(loteRowProducto(b, prodById), q)
    );
  }, [lotes, filtroP, filtroVenc, filtroCat, prodById]);

  const selProducto = productos.find((p) => String(p.id) === String(form.producto_id));

  const prodsFiltModal = useMemo(
    () =>
      productos
        .filter((p) => p.activo !== false)
        .filter((p) => inventarioProductMatchesBusqueda(p, prodBusq))
        .sort((a, b) => inventarioSearchRelevanceRank(a, prodBusq) - inventarioSearchRelevanceRank(b, prodBusq)),
    [productos, prodBusq]
  );

  const selectProductoScan = (p) => {
    if (!p) return;
    setForm((prev) => ({ ...prev, producto_id: String(p.id) }));
    setProdBusq(p.nombre);
    setScanErr("");
    setTimeout(() => cantidadRef.current?.focus(), 40);
  };

  const trySelectFromScan = (raw) => {
    const trimmed = raw.trim();
    if (!trimmed) return false;
    const exact = findProductExactScan(productos.filter((p) => p.activo !== false), trimmed);
    if (exact) {
      selectProductoScan(exact);
      return true;
    }
    if (prodsFiltModal.length === 1) {
      selectProductoScan(prodsFiltModal[0]);
      return true;
    }
    return false;
  };

  const openRegistrarModal = () => {
    setForm({
      producto_id: "",
      numero_lote: "",
      fecha_caducidad: "",
      cantidad_inicial: "",
      costo_unitario: "",
      proveedor_id: "",
      fecha_recepcion: new Date().toLocaleDateString("sv-SE"),
    });
    setProdBusq("");
    setScanErr("");
    setModal(true);
    setTimeout(() => prodBusqRef.current?.focus(), 80);
  };

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
    else {
      showToast("✅ Lote registrado","success");
      setForm({
        producto_id: "",
        numero_lote: "",
        fecha_caducidad: "",
        cantidad_inicial: "",
        costo_unitario: "",
        proveedor_id: form.proveedor_id,
        fecha_recepcion: new Date().toLocaleDateString("sv-SE"),
      });
      setProdBusq("");
      setScanErr("");
      fetchData();
      setTimeout(() => prodBusqRef.current?.focus(), 80);
    }
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

  const vencidos  = lotes.filter(l=>{ const d=diasRestantes(l.fecha_caducidad); return typeof d==="number"&&d<0; }).length;
  const criticos  = lotes.filter(l=>{ const d=diasRestantes(l.fecha_caducidad); return typeof d==="number"&&d>=0&&d<=DIAS_CADUCIDAD_CRITICO; }).length;
  const pronto    = lotes.filter(l=>{ const d=diasRestantes(l.fecha_caducidad); return typeof d==="number"&&d>DIAS_CADUCIDAD_CRITICO&&d<=DIAS_CADUCIDAD_ALERTA; }).length;
  const lotesFueraCatalogo = lotes.filter((l) => {
    const prod = loteRowProducto(l, prodById);
    return prod.activo === false;
  }).length;
  const idsConLote = useMemo(() => new Set(lotes.map((l) => String(l.producto_id))), [lotes]);
  const catalogoSinLote = productos.filter((p) => p.activo !== false && !idsConLote.has(String(p.id))).length;

  return(
    <div>
      <div style={{background:"#eff6ff",border:"1px solid #bfdbfe",borderRadius:10,padding:"10px 14px",marginBottom:14,fontSize:12,color:"#1e3a8a",lineHeight:1.5}}>
        <strong>Mismos productos que Catálogo.</strong> El nombre y el SKU salen de ahí; el stock de cada fila es el lote PEPS.
        {catalogoSinLote > 0 && (
          <> Hay <strong>{catalogoSinLote}</strong> producto{catalogoSinLote === 1 ? "" : "s"} del catálogo sin lote — usa + Registrar lote o la pestaña Recibir.</>
        )}
        {lotesFueraCatalogo > 0 && (
          <> Hay <strong>{lotesFueraCatalogo}</strong> lote{lotesFueraCatalogo === 1 ? "" : "s"} de productos dados de baja — filtro «Fuera de catálogo».</>
        )}
      </div>
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
        <button onClick={openRegistrarModal} style={{padding:"9px 18px",borderRadius:8,border:"none",background:BRAND.gradient,color:"#fff",fontWeight:700,fontSize:13,cursor:"pointer"}}>
          + Registrar lote
        </button>
      </div>

      {/* KPIs */}
      <div style={{display:"flex",gap:12,marginBottom:20,flexWrap:"wrap"}}>
        {[
          {label:"Vencidos",    val:vencidos,     col:C.red,   filter:"vencidos"},
          {label:`Críticos ≤${DIAS_CADUCIDAD_CRITICO}d`,val:criticos,    col:C.amber, filter:"criticos"},
          {label:`Por vencer ≤${DIAS_CADUCIDAD_ALERTA}d`,val:pronto,    col:"#f59e0b",filter:"pronto"},
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
        <input placeholder="🔍 Producto, SKU o código de barras…" value={filtroP} onChange={e=>setFiltroP(e.target.value)}
          style={{...inpS,maxWidth:220,width:"auto"}}/>
        {filtroP.trim() && (
          <span style={{ fontSize: 11, color: C.textMid, alignSelf: "center" }}>
            {lotesFiltrados.length} de {lotes.length} lote{lotes.length !== 1 ? "s" : ""}
          </span>
        )}
        {["todos","vencidos","criticos","pronto"].map(f=>(
          <button key={f} onClick={()=>setFiltroV(f)} style={{
            padding:"6px 14px",borderRadius:20,fontSize:11,fontWeight:700,cursor:"pointer",
            border:`1px solid ${filtroVenc===f?BRAND.primary:C.border}`,
            background:filtroVenc===f?BRAND.primary+"18":"transparent",
            color:filtroVenc===f?BRAND.primary:C.textMid,
          }}>{f.charAt(0).toUpperCase()+f.slice(1)}</button>
        ))}
        {[
          ["catalogo", "Catálogo"],
          ["fuera", `Fuera de catálogo${lotesFueraCatalogo ? ` (${lotesFueraCatalogo})` : ""}`],
          ["todos", "Todos los lotes"],
        ].map(([id, label]) => (
          <button key={id} onClick={()=>setFiltroCat(id)} style={{
            padding:"6px 14px",borderRadius:20,fontSize:11,fontWeight:700,cursor:"pointer",
            border:`1px solid ${filtroCat===id?BRAND.primary:C.border}`,
            background:filtroCat===id?BRAND.primary+"18":"transparent",
            color:filtroCat===id?BRAND.primary:C.textMid,
          }}>{label}</button>
        ))}
      </div>

      {/* Tabla */}
      {loading?<div style={{color:C.textMid,textAlign:"center",padding:40}}>Cargando…</div>:(
        <HorizontalScrollSync bodyMaxHeight={TABLA_SCROLL_MAX}>
          <table className="fc-tabla-sticky" style={{width:"100%",minWidth:980,borderCollapse:"separate",borderSpacing:0,fontSize:12}}>
            <thead>
              <tr style={{background:C.cardDark}}>
                {["Producto","SKU","Lote","Caducidad","Días","Stock actual","Costo","Proveedor","Acciones"].map((h, hi)=>(
                  <th key={h} data-sticky-col={hi===0?"":undefined} style={{padding:"9px 12px",textAlign:"left",color:C.textMid,fontWeight:700,borderBottom:`1px solid ${C.border}`,whiteSpace:"nowrap"}}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {!lotesFiltrados.length && (
                <tr>
                  <td colSpan={9} style={{ textAlign: "center", padding: 32, color: C.textMid, lineHeight: 1.55 }}>
                    {filtroP.trim() ? (
                      <>
                        Sin lotes para «{filtroP.trim()}».
                        <br />
                        <span style={{ fontSize: 11 }}>
                          Si el producto está en <strong>Catálogo</strong> pero no aparece aquí, aún no tiene lote PEPS — usa <strong>+ Registrar lote</strong> o la pestaña <strong>Recibir</strong>.
                        </span>
                      </>
                    ) : (
                      "Sin lotes"
                    )}
                  </td>
                </tr>
              )}
              {lotesFiltrados.map((l,i)=>{
                const dias = diasRestantes(l.fecha_caducidad);
                const col  = colCad(dias);
                const prod = loteRowProducto(l, prodById);
                const etiqueta = etiquetaProductoInventario(prod);
                return(
                  <tr key={l.id} style={{background:dias!==null&&dias<0?"#fff5f5":i%2===0?"#ffffff":"#f8fafc"}}>
                    <td data-sticky-col="" style={{padding:"8px 12px",borderBottom:`1px solid ${C.border}`,maxWidth:280,background:dias!==null&&dias<0?"#fff5f5":i%2===0?"#ffffff":"#f8fafc"}}>
                      <div style={{color:C.text,fontWeight:600,lineHeight:1.35}} title={prod.nombre}>{prod.nombre || etiqueta || "—"}</div>
                      {(prod.marca || prod.presentacion || prod.forma_farmaceutica) && (
                        <div style={{color:C.textMid,fontSize:10,marginTop:2}}>
                          {[prod.forma_farmaceutica, prod.marca, prod.presentacion].filter(Boolean).join(" · ")}
                        </div>
                      )}
                      {prod.activo === false && (
                        <div style={{color:C.amber,fontSize:10,fontWeight:700,marginTop:2}}>Fuera de catálogo</div>
                      )}
                    </td>
                    <td style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`,fontFamily:"monospace",fontSize:10}}>{prod.sku||"—"}</td>
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
                <label style={{color:C.textMid,fontSize:11,fontWeight:700,display:"block",marginBottom:4}}>PRODUCTO * — escanea o busca</label>
                <input
                  ref={prodBusqRef}
                  value={prodBusq}
                  onChange={(e) => {
                    setProdBusq(e.target.value);
                    setForm((p) => ({ ...p, producto_id: "" }));
                    setScanErr("");
                  }}
                  onKeyDown={(e) => {
                    if (e.key !== "Enter") return;
                    e.preventDefault();
                    if (trySelectFromScan(prodBusq)) return;
                    if (prodsFiltModal.length > 1) {
                      setScanErr("Varios resultados — elige uno o escanea el código exacto.");
                      return;
                    }
                    setScanErr("Producto no encontrado. Regístralo en Catálogo con su código de barras.");
                  }}
                  placeholder="🔫 Código de barras, SKU o nombre…"
                  style={{...inpS, fontSize:16}}
                />
                {scanErr ? <div style={{color:C.red,fontSize:11,marginTop:6}}>{scanErr}</div> : null}
                {prodBusq && !selProducto && prodsFiltModal.length > 0 && (
                  <div style={{marginTop:8,border:`1px solid ${C.border}`,borderRadius:8,maxHeight:120,overflowY:"auto"}}>
                    {prodsFiltModal.slice(0, 6).map((p) => (
                      <div
                        key={p.id}
                        role="button"
                        tabIndex={0}
                        onClick={() => selectProductoScan(p)}
                        onKeyDown={(e) => { if (e.key === "Enter") selectProductoScan(p); }}
                        style={{padding:"7px 10px",fontSize:11,cursor:"pointer",borderBottom:`1px solid ${C.border}`,color:C.text}}
                      >
                        <strong>{p.nombre}</strong>
                        {p.codigo_barras ? <span style={{marginLeft:8,color:C.textMid,fontFamily:"monospace"}}>{p.codigo_barras}</span> : null}
                      </div>
                    ))}
                  </div>
                )}
                {selProducto && (
                  <div style={{marginTop:8,padding:"8px 10px",background:"#eff6ff",borderRadius:8,fontSize:11,color:"#1e40af"}}>
                    ✓ {selProducto.nombre}
                    {selProducto.codigo_barras ? ` · ${selProducto.codigo_barras}` : ""}
                  </div>
                )}
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
                  <input
                    ref={key === "cantidad_inicial" ? cantidadRef : key === "fecha_caducidad" ? caducidadRef : undefined}
                    type={type}
                    style={inpS}
                    value={form[key]||""}
                    onChange={e=>setForm(p=>({...p,[key]:e.target.value}))}
                    onKeyDown={key === "cantidad_inicial" ? (e) => {
                      if (e.key === "Enter") { e.preventDefault(); caducidadRef.current?.focus(); }
                    } : key === "fecha_caducidad" ? (e) => {
                      if (e.key === "Enter" && form.producto_id && form.numero_lote && form.cantidad_inicial) {
                        e.preventDefault();
                        guardar();
                      }
                    } : undefined}
                    placeholder={ph}
                  />
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
