import { useState, useEffect, useCallback, useMemo } from "react";
import { C_LIGHT } from "./constants";
import { supabase } from "./supabase";
import { showToast, HorizontalScrollSync, SkeletonTable, TABLA_SCROLL_MAX } from "./ui";
import { useMediaQuery } from "./hooks/useMediaQuery";
import {
  buildReferenciasPorProducto,
  dedupeReferenciasActuales,
  calcMejorCompra,
  calcMejorTienda,
  fmtPrecioRef,
} from "./lib/preciosReferencia";
import { asignarPedidosPorTienda } from "./lib/asignarPedidosPorTienda";
import { descargarPedidoTienda, descargarPedidosWorkbook } from "./lib/exportarPedidoProveedor";
import {
  agruparLotesPorProducto,
  enriquecerProductoConLotes,
  fetchLotesInventario,
  fetchProductosPaginados,
} from "./lib/inventarioHubData";
import { DIAS_CADUCIDAD_ALERTA } from "./lib/caducidad";
import { inventarioProductMatchesBusqueda } from "./utils/fuzzySearch";

const BRAND = { primary:"#0D1B2A", gradient:"linear-gradient(135deg,#0D1B2A,#1E3ABA)" };
const fmt = n => `$${parseFloat(n||0).toLocaleString("es-MX",{minimumFractionDigits:2})}`;
const STOCK_MIN_DEFAULT = 5;

const stockDe = (p) => Number(p.stock_peps ?? p.stock) || 0;
const stockMinimoEfectivo = (p) => (Number(p.stock_minimo) > 0 ? Number(p.stock_minimo) : STOCK_MIN_DEFAULT);

const calcStockUrgencia = (p, C) => {
  const min = stockMinimoEfectivo(p);
  const stock = stockDe(p);
  const pct = stock / min;
  if (stock === 0) return { nivel:"AGOTADO", col:C.red, bg:C.redDim, icon:"🚨" };
  if (pct <= 0.5)    return { nivel:"CRÍTICO", col:C.red, bg:C.redDim, icon:"🔴" };
  if (pct <= 1)      return { nivel:"BAJO",    col:C.amber, bg:C.amberDim, icon:"🟡" };
  if (pct <= 1.5)    return { nivel:"PRONTO",  col:"#0891b2", bg:"#cffafe", icon:"🔵" };
  return null;
};

const calcCaducidadUrgencia = (p, C) => {
  const dias = p.diasCaducidad;
  if (dias != null && dias < 0) return { nivel:"VENCIDO", col:C.red, bg:C.redDim, icon:"⛔" };
  if (dias != null && dias <= DIAS_CADUCIDAD_ALERTA) {
    return { nivel:"CADUCA", col:C.amber, bg:C.amberDim, icon:"⏳" };
  }
  return null;
};

export default function ReabastoModule() {
  const C = C_LIGHT;
  const isMobile = useMediaQuery("(max-width: 900px)");
  const [productos,   setProductos]   = useState([]);
  const [loading,     setLoading]     = useState(true);
  const [ordenesEnv,  setOrdenesEnv]  = useState([]);
  const [tab,         setTab]         = useState("alertas");
  const [selProds,    setSelProds]    = useState({});
  const [generando,   setGenerando]   = useState(false);
  const [busqueda,    setBusqueda]    = useState("");
  const [filtroTienda, setFiltroTienda] = useState("todas");
  const [filtroUrgencia, setFiltroUrgencia] = useState("");

  const fetchProductos = useCallback(async () => {
    setLoading(true);
    const tok = sessionStorage.getItem("farmacapital_session_token");
    const [prodRes, lotesRes, viewRes] = await Promise.all([
      fetchProductosPaginados({ activosSolo: true, order: "nombre" }),
      fetchLotesInventario(tok),
      supabase.from("producto_precios_referencia_actual").select("*"),
    ]);

    if (prodRes.error) {
      showToast("No se pudo cargar inventario: " + prodRes.error.message, "error");
      setProductos([]);
      setLoading(false);
      return;
    }
    if (lotesRes.error) {
      showToast("No se pudieron cargar lotes PEPS: " + lotesRes.error.message, "warning");
    }

    const byProducto = agruparLotesPorProducto(lotesRes.data);

    let refRows = viewRes.data || [];
    if (viewRes.error) {
      const rawRes = await supabase
        .from("producto_precios_referencia")
        .select("producto_id,fuente,tipo,precio,fecha,origen,confianza,created_at,nombre_fuente,notas")
        .order("fecha", { ascending: false })
        .limit(10000);
      refRows = rawRes.error ? [] : dedupeReferenciasActuales(rawRes.data);
    }
    const refsByProduct = buildReferenciasPorProducto(refRows);

    const rows = (prodRes.data || []).map((p) => {
      const enriched = enriquecerProductoConLotes(p, byProducto[p.id] || []);
      return {
        ...enriched,
        stock: enriched.stock_peps,
        mejorTienda: calcMejorTienda(refsByProduct[p.id]),
        mejorCompra: calcMejorCompra(
          (refsByProduct[p.id]?.ultima_compra?.precio ?? p.costo),
          refsByProduct[p.id],
          refsByProduct[p.id]?.ultima_compra
            ? { proveedor: refsByProduct[p.id].ultima_compra.nombre_fuente, origen: "compra" }
            : {}
        ),
      };
    });
    setProductos(rows);
    setLoading(false);
  }, []);

  useEffect(()=>{ fetchProductos(); },[fetchProductos]);

  const alertas = useMemo(() => (
    productos
      .map(p=>({...p, urgencia: calcStockUrgencia(p, C)}))
      .filter(p=>p.urgencia)
      .sort((a,b)=>{
        const ord={AGOTADO:0,CRÍTICO:1,BAJO:2,PRONTO:3};
        return (ord[a.urgencia.nivel]??9)-(ord[b.urgencia.nivel]??9);
      })
  ), [productos, C]);

  const colaCaduca = useMemo(() => (
    productos
      .map(p=>({
        ...p,
        caducidad: calcCaducidadUrgencia(p, C),
        urgencia: calcCaducidadUrgencia(p, C) || calcStockUrgencia(p, C),
      }))
      .filter(p=>p.caducidad)
      .sort((a,b)=>(a.diasCaducidad ?? 9999)-(b.diasCaducidad ?? 9999))
  ), [productos, C]);

  const menores = useMemo(() => (
    [...productos].sort((a,b)=>stockDe(a)-stockDe(b)).slice(0, 40)
  ), [productos]);
  const filasStock = useMemo(() => (
    alertas.length
      ? alertas
      : menores.map(p=>({...p, urgencia: calcStockUrgencia(p, C) || { nivel:"OK", col:C.textMid, bg:C.cardDark, icon:"·" }}))
  ), [alertas, menores, C]);
  const filasFuente = filtroUrgencia === "CADUCA" ? colaCaduca : filasStock;
  const filasTienda = useMemo(() => {
    const q = busqueda.trim();
    let list = q ? filasFuente.filter((p) => inventarioProductMatchesBusqueda(p, q)) : filasFuente;
    if (filtroTienda === "levic") list = list.filter((p) => p.mejorTienda?.fuente === "levic");
    else if (filtroTienda === "otras") list = list.filter((p) => p.mejorTienda && p.mejorTienda.fuente !== "levic");
    else if (filtroTienda === "sin") list = list.filter((p) => !p.mejorTienda);
    return list;
  }, [filasFuente, busqueda, filtroTienda]);
  const filasAlertas = useMemo(() => {
    if (filtroUrgencia === "elegidos") return filasTienda.filter((p) => selProds[p.id] > 0);
    if (filtroUrgencia === "CADUCA") return filasTienda;
    if (filtroUrgencia) return filasTienda.filter((p) => p.urgencia?.nivel === filtroUrgencia);
    return filasTienda;
  }, [filasTienda, filtroUrgencia, selProds]);
  const listaVacia = !loading && !productos.length;
  const nMarcados = Object.values(selProds).filter((v) => v > 0).length;
  const nAgotados = productos.filter((p) => calcStockUrgencia(p, C)?.nivel === "AGOTADO").length;
  const nCriticos = productos.filter((p) => calcStockUrgencia(p, C)?.nivel === "CRÍTICO").length;
  const nCaduca = colaCaduca.length;
  const nBajo = productos.filter((p) => calcStockUrgencia(p, C)?.nivel === "BAJO").length;
  const nPronto = productos.filter((p) => calcStockUrgencia(p, C)?.nivel === "PRONTO").length;

  const cantidadSugerida = (p) => {
    const min = stockMinimoEfectivo(p);
    const base = Math.max(min * 3 - stockDe(p), 0);
    return Math.max(base, 1);
  };

  const toggleSel = (id) => {
    const fila = filasAlertas.find(p=>p.id===id) || productos.find(p=>p.id===id) || {};
    setSelProds((prev) => {
      if (prev[id] > 0) {
        const next = { ...prev };
        delete next[id];
        return next;
      }
      return { ...prev, [id]: cantidadSugerida(fila) };
    });
  };

  const inputPedir = (p) => (
    <input
      type="number"
      min="1"
      inputMode="numeric"
      placeholder={String(cantidadSugerida(p))}
      value={selProds[p.id] ?? ""}
      onChange={(e) => setCantidad(p.id, e.target.value)}
      onClick={(e) => e.stopPropagation()}
      style={inpS}
      aria-label={`Piezas a pedir de ${p.nombre}`}
    />
  );

  const setCantidad = (id, raw) => {
    const n = parseInt(String(raw).replace(/\D/g, ""), 10);
    setSelProds((prev) => {
      if (!Number.isFinite(n) || n <= 0) {
        const next = { ...prev };
        delete next[id];
        return next;
      }
      return { ...prev, [id]: n };
    });
  };

  const generarOrden = async () => {
    const items = Object.entries(selProds)
      .filter(([,qty])=>qty>0)
      .map(([id,qty])=>({
        producto: productos.find(p=>p.id===parseInt(id)),
        cantidad: qty,
      }))
      .filter(x=>x.producto);

    if (!items.length) {
      showToast("Marca al menos un producto y pon cuántas piezas pedir","warning");
      return;
    }
    setGenerando(true);

    const ordenes = asignarPedidosPorTienda(items);
    setOrdenesEnv(ordenes);
    setTab("ordenes");
    setGenerando(false);
    try {
      await descargarPedidosWorkbook(ordenes);
    } catch (e) {
      showToast("La orden se armó, pero no se pudo bajar el Excel: " + (e.message || e), "warning");
      return;
    }
    const hayLevic = ordenes.some((o) => /levic/i.test(o.proveedor || o.fuente || ""));
    const nResto = ordenes.filter((o) => !/levic/i.test(o.proveedor || o.fuente || "")).reduce((a, o) => a + o.productos.length, 0);
    const nLevic = ordenes.filter((o) => /levic/i.test(o.proveedor || o.fuente || "")).reduce((a, o) => a + o.productos.length, 0);
    showToast(
      hayLevic
        ? `2 archivos: Pedido_Levic_portal (${nLevic} líneas, súbelo a Levic) y Pedido_otras_tiendas (${nResto} líneas).`
        : `Pedido_otras_tiendas.xlsx · ${nResto} líneas`,
      "success"
    );
  };

  const imprimirOrden = (orden) => {
    const w = window.open("","_blank","width=700,height=800");
    const rows = orden.productos.map(p=>`
      <tr>
        <td style="padding:8px 12px;border-bottom:1px solid #e2e8f0">${p.nombre}</td>
        <td style="padding:8px 12px;border-bottom:1px solid #e2e8f0;text-align:center">${p.sku||"—"}</td>
        <td style="padding:8px 12px;border-bottom:1px solid #e2e8f0;text-align:center">${p.stock}</td>
        <td style="padding:8px 12px;border-bottom:1px solid #e2e8f0;text-align:center">${p.min_caducidad_lotes||"—"}</td>
        <td style="padding:8px 12px;border-bottom:1px solid #e2e8f0;text-align:center;font-weight:700;color:#0D1B2A">${p.cantidadPedida}</td>
        <td style="padding:8px 12px;border-bottom:1px solid #e2e8f0;text-align:right">$${(((p.precioUnit ?? p.mejorCompra?.precio ?? p.costo)||0)*p.cantidadPedida).toFixed(2)}</td>
      </tr>`).join("");
    w.document.write(`<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8"><title>Orden de Reabasto</title>
      <style>body{font-family:Arial,sans-serif;font-size:13px;padding:24px;color:#0f172a}h2{color:#0D1B2A}table{width:100%;border-collapse:collapse}th{background:#f8fafc;padding:9px 12px;text-align:left;font-size:11px;color:#475569;border-bottom:2px solid #e2e8f0}.total{text-align:right;font-weight:800;font-size:16px;color:#16a34a;padding:12px 12px 0}</style>
      </head><body>
      <div style="display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:20px">
        <div><h2>📦 Orden de Reabasto — FARMACAPITAL</h2><div style="color:#475569">Chinampac de Juárez, CDMX · ${orden.fecha}</div></div>
        <div style="text-align:right"><div style="font-weight:700">Pedir en:</div><div style="color:#0D1B2A;font-weight:800;font-size:16px">${orden.proveedor}</div></div>
      </div>
      <table><thead><tr><th>Producto</th><th style="text-align:center">SKU</th><th style="text-align:center">Stock actual</th><th style="text-align:center">Caducidad PEPS</th><th style="text-align:center">Cantidad a pedir</th><th style="text-align:right">Costo estimado</th></tr></thead>
      <tbody>${rows}</tbody></table>
      <div class="total">Total estimado: $${orden.total.toFixed(2)} MXN</div>
      <div style="margin-top:32px;border-top:1px solid #e2e8f0;padding-top:16px;color:#94a3b8;font-size:11px">
        Generado automáticamente por FarmaCapital · ${new Date().toLocaleString("es-MX")}
      </div></body></html>`);
    w.document.close(); w.focus(); setTimeout(()=>w.print(),500);
  };

  const inpS = {
    width:"70px", padding:"8px 8px", borderRadius:6, border:`1px solid ${C.border}`,
    fontSize:isMobile?16:12, textAlign:"center", outline:"none",
    background:"#fff", color:C.text, WebkitTextFillColor:C.text, caretColor:C.text,
    colorScheme:"light",
  };
  const Caja = ({ checked, onChange, style }) => (
    <button type="button" role="checkbox" aria-checked={!!checked} onClick={onChange} style={{
      width:18, height:18, borderRadius:4, flexShrink:0, padding:0, cursor:"pointer",
      border:`1.5px solid ${checked ? BRAND.primary : "#94a3b8"}`,
      background:"#fff", colorScheme:"light",
      display:"inline-flex", alignItems:"center", justifyContent:"center",
      ...style,
    }}>
      {checked ? <span aria-hidden="true" style={{color:BRAND.primary,fontSize:13,fontWeight:800,lineHeight:1}}>✓</span> : null}
    </button>
  );

  const renderComprarEn = (p) => {
    const tienda = p.mejorTienda;
    if (!tienda) {
      return <span style={{color:C.textMid}}>Sin precio de tienda</span>;
    }
    const costo = Number(p.costo) || 0;
    const ahorra = costo > 0 && tienda.precio < costo - 0.01;
    return (
      <div>
        <div style={{fontWeight:800,color:ahorra ? C.green : C.text}}>{tienda.label}</div>
        <div style={{fontSize:10,color:ahorra ? C.green : C.textMid,marginTop:2}}>
          {fmtPrecioRef(tienda.precio)}
          {ahorra ? ` · ahorras ${fmtPrecioRef(costo - tienda.precio)}` : ""}
        </div>
      </div>
    );
  };

  return (
    <div style={{padding: isMobile ? "12px 16px 24px" : "16px 24px 24px", maxWidth: "100%", overflow: "hidden", colorScheme:"light"}}>
      <div style={{display:"flex",flexDirection:isMobile?"column":"row",justifyContent:"space-between",alignItems:isMobile?"stretch":"flex-start",marginBottom:16,gap:12}}>
        <div>
          <h1 style={{color:C.text,fontSize:isMobile?18:20,fontWeight:800,margin:0}}>Reabasto</h1>
        </div>
        <div style={{display:"flex",flexDirection:isMobile?"column":"row",gap:8,width:isMobile?"100%":"auto"}}>
          <button onClick={generarOrden} disabled={generando || nMarcados===0}
            style={{padding:"12px 16px",borderRadius:10,border:"none",background:BRAND.gradient,color:"#fff",fontWeight:700,fontSize:13,cursor:nMarcados? "pointer":"not-allowed",opacity:generando||!nMarcados?0.7:1,width:isMobile?"100%":"auto"}}>
            {generando?"Generando…": nMarcados ? `Descargar ${nMarcados} marcado${nMarcados===1?"":"s"}` : "Marca lo que quieres pedir"}
          </button>
        </div>
      </div>

      <div style={{display:"grid",gridTemplateColumns:isMobile?"repeat(2,minmax(0,1fr))":"repeat(auto-fit,minmax(120px,1fr))",gap:8,marginBottom:16}}>
        {[
          {id:"AGOTADO",label:"Agotados",value:nAgotados,col:C.red,icon:"🚨"},
          {id:"CRÍTICO",label:"Críticos",value:nCriticos,col:C.red,icon:"🔴"},
          {id:"CADUCA",label:`Caduca ${DIAS_CADUCIDAD_ALERTA}d`,value:nCaduca,col:C.amber,icon:"⏳"},
          {id:"BAJO",label:"Bajo",value:nBajo,col:C.amber,icon:"🟡"},
          {id:"PRONTO",label:"Pronto",value:nPronto,col:"#0891b2",icon:"🔵"},
          {id:"elegidos",label:"Elegidos",value:nMarcados,col:BRAND.primary,icon:"✅"},
        ].map(k=>{
          const on = filtroUrgencia === k.id;
          return (
          <button key={k.id} type="button" onClick={()=>{ setFiltroUrgencia(on ? "" : k.id); setTab("alertas"); }}
            style={{
              background: on ? k.col + "14" : C.card,
              border:`1.5px solid ${on ? k.col : C.border}`,
              borderRadius:12, padding:isMobile?"10px 12px":"12px 16px", minWidth:0,
              textAlign:"left", cursor:"pointer", colorScheme:"light",
            }}>
            <div style={{color:C.textDim,fontSize:10,fontWeight:700,letterSpacing:.3}}>{k.icon} {k.label.toUpperCase()}</div>
            <div style={{color:k.col,fontWeight:900,fontSize:isMobile?20:22,marginTop:4}}>{k.value}</div>
          </button>
          );
        })}
      </div>

      <div style={{display:"flex",gap:4,marginBottom:16,borderBottom:`1px solid ${C.border}`,overflowX:"auto"}}>
        {[["alertas", alertas.length ? `Alertas (${alertas.length})` : "Existencias"],["ordenes",`Órdenes (${ordenesEnv.length})`]].map(([id,label])=>(
          <button key={id} onClick={()=>setTab(id)} style={{
            padding:"8px 14px",border:"none",cursor:"pointer",fontWeight:700,fontSize:12,flexShrink:0,
            borderRadius:"8px 8px 0 0",background:"transparent",
            color:tab===id?BRAND.primary:C.textMid,
            borderBottom:tab===id?`2px solid ${BRAND.primary}`:"2px solid transparent",
          }}>{label}</button>
        ))}
      </div>

      {tab==="alertas"&&(
        loading?<SkeletonTable rows={6} cols={isMobile?4:8} />:(
          listaVacia?(
            <div style={{background:C.card,borderRadius:12,border:`1px solid ${C.border}`,padding:32,textAlign:"center"}}>
              <div style={{color:C.text,fontWeight:700,fontSize:16}}>Sin productos en catálogo</div>
              <div style={{color:C.textMid,fontSize:13,marginTop:4}}>Carga el inventario en Catálogo para ver reabasto aquí.</div>
            </div>
          ):(
            <div>
              <div style={{display:"flex",flexWrap:"wrap",gap:8,alignItems:"center",marginBottom:12}}>
                <input
                  value={busqueda}
                  onChange={(e)=>setBusqueda(e.target.value)}
                  placeholder="Producto, SKU o código…"
                  style={{
                    flex:"1 1 220px", maxWidth:320, padding:"8px 12px", borderRadius:8,
                    border:`1px solid ${C.border}`, background:"#fff", color:C.text,
                    WebkitTextFillColor:C.text, caretColor:C.text, colorScheme:"light",
                    fontSize:13, outline:"none",
                  }}
                />
                <div style={{color:C.textMid,fontSize:12,flex:"1 1 80px"}}>
                  {filasAlertas.length} producto{filasAlertas.length===1?"":"s"}
                </div>
                {[
                  ["todas", "Todas"],
                  ["levic", "Levic"],
                  ["otras", "Otras tiendas"],
                  ["sin", "Sin tienda"],
                ].map(([id, label]) => (
                  <button key={id} type="button" onClick={()=>setFiltroTienda(id)} style={{
                    padding:"6px 12px",borderRadius:20,fontSize:11,fontWeight:700,cursor:"pointer",
                    border:`1px solid ${filtroTienda===id?BRAND.primary:C.border}`,
                    background:filtroTienda===id?BRAND.primary+"18":"#fff",
                    color:filtroTienda===id?BRAND.primary:C.textMid,
                  }}>{label}</button>
                ))}
              </div>
              {isMobile ? (
                <div style={{display:"flex",flexDirection:"column",gap:10,maxHeight:"min(70dvh, 640px)",overflowY:"auto",WebkitOverflowScrolling:"touch",paddingRight:2}}>
                  {filasAlertas.map((p)=>(
                    <div key={p.id} style={{
                      background:C.card,border:`1px solid ${selProds[p.id]>0?C.blue:C.border}`,
                      borderRadius:12,padding:12,
                    }}>
                      <div style={{display:"flex",justifyContent:"space-between",gap:8,alignItems:"flex-start"}}>
                        <label style={{display:"flex",gap:8,minWidth:0,flex:1,alignItems:"flex-start",cursor:"pointer"}}>
                          <Caja checked={selProds[p.id]>0} onChange={()=>toggleSel(p.id)} style={{marginTop:3}}/>
                          <div style={{minWidth:0}}>
                            <div style={{color:C.text,fontWeight:700,fontSize:14,lineHeight:1.3}}>{p.nombre}</div>
                            <div style={{color:C.textMid,fontSize:11,marginTop:3}}>{p.sku||"sin SKU"}</div>
                          </div>
                        </label>
                        <span style={{padding:"3px 8px",borderRadius:20,fontSize:10,fontWeight:700,background:p.urgencia.bg,color:p.urgencia.col,flexShrink:0}}>
                          {p.urgencia.icon} {p.urgencia.nivel}
                        </span>
                      </div>
                      <div style={{display:"grid",gridTemplateColumns:"1fr 1fr 1fr",gap:8,marginTop:12}}>
                        <div>
                          <div style={{fontSize:10,color:C.textDim,fontWeight:700}}>STOCK ACTUAL</div>
                          <div style={{fontSize:16,fontWeight:800,color:p.stock===0?C.red:C.text}}>{p.stock}</div>
                        </div>
                        <div>
                          <div style={{fontSize:10,color:C.textDim,fontWeight:700}}>SUGERIDO</div>
                          <div style={{fontSize:16,fontWeight:800,color:C.textMid}}>{cantidadSugerida(p)}</div>
                        </div>
                        <div>
                          <div style={{fontSize:10,color:C.textDim,fontWeight:700}}>PEDIR</div>
                          {inputPedir(p)}
                        </div>
                      </div>
                      <div style={{marginTop:8,fontSize:12}}>{renderComprarEn(p)}</div>
                    </div>
                  ))}
                </div>
              ) : (
              <HorizontalScrollSync bodyMaxHeight={TABLA_SCROLL_MAX}>
                <table className="fc-tabla-sticky" style={{width:"100%",minWidth:980,borderCollapse:"separate",borderSpacing:0,fontSize:12}}>
                  <thead>
                    <tr>
                      <th style={{padding:"9px 12px",textAlign:"left",color:C.textMid,fontWeight:700,borderBottom:`1px solid ${C.border}`,position:"sticky",top:0,zIndex:4,background:C.cardDark,boxShadow:`0 1px 0 ${C.border}`}}>
                        <Caja
                          checked={filasAlertas.length>0 && filasAlertas.every(p=>selProds[p.id]>0)}
                          onChange={()=>{
                          const allOn = filasAlertas.length>0 && filasAlertas.every(p=>selProds[p.id]>0);
                          if(!allOn) {
                            setSelProds((prev) => ({
                              ...prev,
                              ...Object.fromEntries(filasAlertas.map((p) => [p.id, prev[p.id] > 0 ? prev[p.id] : cantidadSugerida(p)])),
                            }));
                          } else {
                            setSelProds((prev) => {
                              const next = { ...prev };
                              filasAlertas.forEach((p) => { delete next[p.id]; });
                              return next;
                            });
                          }
                        }}/>
                      </th>
                      {["Producto","SKU","Stock actual","Sugerido","Pedir","Comprar en","Urgencia"].map(h=>(
                        <th key={h} style={{padding:"9px 12px",textAlign:"left",color:C.textMid,fontWeight:700,borderBottom:`1px solid ${C.border}`,whiteSpace:"nowrap",position:"sticky",top:0,zIndex:4,background:C.cardDark,boxShadow:`0 1px 0 ${C.border}`}}>{h}</th>
                      ))}
                    </tr>
                  </thead>
                  <tbody>
                    {filasAlertas.map((p,i)=>(
                      <tr key={p.id} style={{background:i%2===0?"transparent":"#f8fafc"}}>
                        <td style={{padding:"9px 12px",borderBottom:`1px solid ${C.border}`}}>
                          <Caja checked={selProds[p.id]>0} onChange={()=>toggleSel(p.id)}/>
                        </td>
                        <td style={{padding:"9px 12px",color:C.text,fontWeight:600,borderBottom:`1px solid ${C.border}`}}>{p.nombre}</td>
                        <td style={{padding:"9px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`,fontFamily:"monospace",fontSize:10}}>{p.sku||"—"}</td>
                        <td style={{padding:"9px 12px",color:p.stock===0?C.red:C.amber,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{p.stock}</td>
                        <td style={{padding:"9px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{cantidadSugerida(p)}</td>
                        <td style={{padding:"9px 12px",borderBottom:`1px solid ${C.border}`}}>{inputPedir(p)}</td>
                        <td style={{padding:"9px 12px",borderBottom:`1px solid ${C.border}`}}>{renderComprarEn(p)}</td>
                        <td style={{padding:"9px 12px",borderBottom:`1px solid ${C.border}`}}>
                          <span style={{padding:"3px 8px",borderRadius:20,fontSize:10,fontWeight:700,background:p.urgencia.bg,color:p.urgencia.col}}>
                            {p.urgencia.icon} {p.urgencia.nivel}
                          </span>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </HorizontalScrollSync>
              )}
            </div>
          )
        )
      )}

      {tab==="ordenes"&&(
        !ordenesEnv.length?(
          <div style={{background:C.card,borderRadius:12,border:`1px solid ${C.border}`,padding:40,textAlign:"center",color:C.textMid}}>
            Genera una orden desde la pestaña "Alertas de stock".
          </div>
        ):(
          <div style={{display:"flex",flexDirection:"column",gap:16}}>
            <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",flexWrap:"wrap",gap:8}}>
              <div style={{color:C.textMid,fontSize:12,lineHeight:1.45,maxWidth:640}}>
                <strong>Pedido_Levic_portal.xlsx</strong> — súbelo a Levic. <strong>Pedido_otras_tiendas.xlsx</strong> — Exprezo, Scorpion y lo que no va al portal.
              </div>
              <button onClick={()=>descargarPedidosWorkbook(ordenesEnv)}
                style={{padding:"8px 14px",borderRadius:8,border:"none",background:BRAND.gradient,color:"#fff",fontWeight:700,fontSize:12,cursor:"pointer"}}>
                Bajar los 2 archivos
              </button>
            </div>
            {ordenesEnv.map((orden,i)=>(
              <div key={i} style={{background:C.card,borderRadius:12,border:`1px solid ${C.border}`,padding:20}}>
                <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:16,flexWrap:"wrap",gap:8}}>
                  <div>
                    <div style={{fontWeight:800,color:C.text,fontSize:15}}>Pedir en: {orden.proveedor}</div>
                    <div style={{color:C.textMid,fontSize:12,marginTop:2}}>
                      {orden.productos.length} productos · Total {fmt(orden.total)}
                      {orden.ahorroVsHabitual > 1 ? ` · ahorras ${fmt(orden.ahorroVsHabitual)} vs tu costo` : ""}
                      {/levic/i.test(orden.proveedor || orden.fuente || "")
                        ? " · Carga el Excel del portal; el envío llega mañana a la farmacia."
                        : ""}
                    </div>
                  </div>
                  <div style={{display:"flex",gap:8,flexWrap:"wrap"}}>
                    <button onClick={()=>descargarPedidoTienda(orden)} style={{padding:"7px 14px",borderRadius:8,border:`1px solid ${BRAND.primary}`,background:"#eff6ff",color:BRAND.primary,fontWeight:700,fontSize:12,cursor:"pointer"}}>
                      {/levic/i.test(orden.proveedor || orden.fuente || "")
                        ? "Bajar archivo Levic"
                        : "Bajar esta lista"}
                    </button>
                    <button onClick={()=>imprimirOrden(orden)} style={{padding:"7px 14px",borderRadius:8,border:`1px solid ${BRAND.primary}`,background:"#eff6ff",color:BRAND.primary,fontWeight:700,fontSize:12,cursor:"pointer"}}>
                      Imprimir
                    </button>
                    <button onClick={()=>{
                      const msg = `📦 *Orden de reabasto FARMACAPITAL*\n\nPedir en: ${orden.proveedor}\nFecha: ${orden.fecha}\n\n${orden.productos.map(p=>`• ${p.nombre} × ${p.cantidadPedida}`).join("\n")}\n\nTotal estimado: $${orden.total.toFixed(2)} MXN\n\n_Generado por sistema FarmaCapital_`;
                      window.open("https://wa.me/?text="+encodeURIComponent(msg),"_blank");
                    }} style={{padding:"7px 14px",borderRadius:8,border:"1px solid #25D366",background:"#dcfce7",color:"#16a34a",fontWeight:700,fontSize:12,cursor:"pointer"}}>
                      📱 WhatsApp
                    </button>
                  </div>
                </div>
                <HorizontalScrollSync bodyMaxHeight={TABLA_SCROLL_MAX}>
                  <table className="fc-tabla-sticky" style={{width:"100%",minWidth:640,borderCollapse:"separate",borderSpacing:0,fontSize:12}}>
                  <thead><tr style={{background:C.cardDark}}>{["Producto","SKU","Stock","Caducidad","Cantidad","Costo est."].map(h=><th key={h} style={{padding:"8px 12px",textAlign:"left",color:C.textMid,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{h}</th>)}</tr></thead>
                  <tbody>
                    {orden.productos.map((p,j)=>(
                      <tr key={j} style={{background:j%2===0?"transparent":"#f8fafc"}}>
                        <td style={{padding:"8px 12px",color:C.text,fontWeight:600,borderBottom:`1px solid ${C.border}`}}>
                          {p.nombre}
                          {p.motivoAgrupado && (
                            <div style={{fontSize:10,color:C.textMid,fontWeight:500,marginTop:2}}>{p.motivoAgrupado}</div>
                          )}
                        </td>
                        <td style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`,fontFamily:"monospace",fontSize:10}}>{p.sku||"—"}</td>
                        <td style={{padding:"8px 12px",color:C.amber,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{p.stock}</td>
                        <td style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{p.min_caducidad_lotes||"—"}</td>
                        <td style={{padding:"8px 12px",color:BRAND.primary,fontWeight:800,borderBottom:`1px solid ${C.border}`}}>{p.cantidadPedida}</td>
                        <td style={{padding:"8px 12px",color:C.green,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{fmt(((p.precioUnit ?? p.mejorCompra?.precio ?? p.costo)||0)*p.cantidadPedida)}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
                </HorizontalScrollSync>
              </div>
            ))}
          </div>
        )
      )}
    </div>
  );
}
