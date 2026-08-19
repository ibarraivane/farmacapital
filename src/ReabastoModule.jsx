import { useState, useEffect, useCallback, useMemo } from "react";
import { C_LIGHT } from "./constants";
import { supabase } from "./supabase";
import { showToast, HorizontalScrollSync, SkeletonTable } from "./ui";
import { useMediaQuery } from "./hooks/useMediaQuery";
import {
  buildReferenciasPorProducto,
  dedupeReferenciasActuales,
  calcMejorCompra,
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
import { inventarioProductMatchesBusqueda } from "./utils/fuzzySearch";

const BRAND = { primary:"#0D1B2A", gradient:"linear-gradient(135deg,#0D1B2A,#1E3ABA)" };
const fmt = n => `$${parseFloat(n||0).toLocaleString("es-MX",{minimumFractionDigits:2})}`;
const STOCK_MIN_DEFAULT = 5;

const stockDe = (p) => Number(p.stock_peps ?? p.stock) || 0;
const stockMinimoEfectivo = (p) => (Number(p.stock_minimo) > 0 ? Number(p.stock_minimo) : STOCK_MIN_DEFAULT);

const calcUrgencia = (p, C) => {
  const dias = p.diasCaducidad;
  let cad = null;
  if (dias != null && dias < 0) cad = { nivel:"VENCIDO", col:C.red, bg:C.redDim, icon:"⛔" };
  else if (dias != null && dias <= 30) cad = { nivel:"CADUCA", col:C.amber, bg:C.amberDim, icon:"⏳" };

  let stockU = null;
  const min = stockMinimoEfectivo(p);
  const stock = stockDe(p);
  const pct = stock / min;
  if (stock === 0) stockU = { nivel:"AGOTADO", col:C.red, bg:C.redDim, icon:"🚨" };
  else if (pct <= 0.5)    stockU = { nivel:"CRÍTICO", col:C.red, bg:C.redDim, icon:"🔴" };
  else if (pct <= 1)      stockU = { nivel:"BAJO",    col:C.amber, bg:C.amberDim, icon:"🟡" };
  else if (pct <= 1.5)    stockU = { nivel:"PRONTO",  col:"#0891b2", bg:"#cffafe", icon:"🔵" };

  if (stockU && cad) {
    const ord = { AGOTADO:0, VENCIDO:1, CRÍTICO:2, CADUCA:3, BAJO:4, PRONTO:5 };
    return (ord[stockU.nivel] ?? 9) <= (ord[cad.nivel] ?? 9) ? stockU : cad;
  }
  return stockU || cad;
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
        mejorCompra: calcMejorCompra(p.costo, refsByProduct[p.id]),
      };
    });
    setProductos(rows);
    setLoading(false);
  }, []);

  useEffect(()=>{ fetchProductos(); },[fetchProductos]);

  const alertas = useMemo(() => (
    productos
      .map(p=>({...p, urgencia:calcUrgencia(p, C)}))
      .filter(p=>p.urgencia)
      .sort((a,b)=>{
        const ord={AGOTADO:0,VENCIDO:1,CRÍTICO:2,CADUCA:3,BAJO:4,PRONTO:5};
        return (ord[a.urgencia.nivel]??9)-(ord[b.urgencia.nivel]??9);
      })
  ), [productos, C]);

  const menores = useMemo(() => (
    [...productos].sort((a,b)=>stockDe(a)-stockDe(b)).slice(0, 40)
  ), [productos]);
  const filasBase = useMemo(() => (
    alertas.length
      ? alertas
      : menores.map(p=>({...p, urgencia: calcUrgencia(p, C) || { nivel:"OK", col:C.textMid, bg:C.cardDark, icon:"·" }}))
  ), [alertas, menores, C]);
  const filasAlertas = useMemo(() => {
    const q = busqueda.trim();
    if (!q) return filasBase;
    return filasBase.filter((p) => inventarioProductMatchesBusqueda(p, q));
  }, [filasBase, busqueda]);
  const listaVacia = !loading && !productos.length;

  const cantidadSugerida = (p) => {
    const min = stockMinimoEfectivo(p);
    const base = Math.max(min * 3 - stockDe(p), 0);
    if (p.urgencia?.nivel === "VENCIDO" || p.urgencia?.nivel === "CADUCA") {
      return Math.max(base, min);
    }
    return Math.max(base, 1);
  };

  const toggleSel = (id) => {
    const fila = alertas.find(p=>p.id===id) || productos.find(p=>p.id===id) || {};
    setSelProds(prev=>({
      ...prev,
      [id]: prev[id]!==undefined ? undefined : cantidadSugerida(fila)
    }));
  };

  const generarOrden = async (todosAlertas = false) => {
    let items = Object.entries(selProds)
      .filter(([,qty])=>qty>0)
      .map(([id,qty])=>({
        producto: filasAlertas.find(p=>p.id===parseInt(id)) || productos.find(p=>p.id===parseInt(id)),
        cantidad: qty,
      }))
      .filter(x=>x.producto);

    if (!items.length || todosAlertas) {
      items = filasAlertas
        .filter((p) => (selProds[p.id] || cantidadSugerida(p)) > 0)
        .map((p) => ({ producto: p, cantidad: selProds[p.id] || cantidadSugerida(p) }));
    }

    if (!items.length) { showToast("No hay productos para pedir","warning"); return; }
    setGenerando(true);

    const ordenes = asignarPedidosPorTienda(items);
    setOrdenesEnv(ordenes);
    setTab("ordenes");
    setGenerando(false);
    try {
      descargarPedidosWorkbook(ordenes);
    } catch (e) {
      showToast("La orden se armó, pero no se pudo bajar el Excel: " + (e.message || e), "warning");
      return;
    }
    const hayLevic = ordenes.some((o) => /levic/i.test(o.proveedor || o.fuente || ""));
    showToast(
      hayLevic
        ? `${ordenes.length} pedido(s). También se bajó Pedido_Levic_portal.xlsx — cárgalo en Levic; llega mañana.`
        : `${ordenes.length} pedido(s) · Excel listo`,
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

  const inpS = {width:"70px",padding:"8px 8px",borderRadius:6,border:`1px solid ${C.border}`,fontSize:isMobile?16:12,textAlign:"center",outline:"none"};

  const renderComprarEn = (p) => {
    const mejor = p.mejorCompra;
    if (mejor?.masBaratoQueTuCosto) {
      return (
        <div>
          <div style={{fontWeight:800,color:C.green}}>{mejor.label}</div>
          <div style={{fontSize:10,color:C.green,marginTop:2}}>
            {fmtPrecioRef(mejor.precio)} · ahorras {fmtPrecioRef(mejor.ahorroVsTuCosto)}
          </div>
        </div>
      );
    }
    if (mejor && !mejor.esTuCosto) {
      return (
        <div>
          <div style={{fontWeight:700,color:C.text}}>{mejor.label}</div>
          <div style={{fontSize:10,color:C.textMid,marginTop:2}}>{fmtPrecioRef(mejor.precio)}</div>
        </div>
      );
    }
    return <span style={{color:C.textMid}}>{p.proveedor || "—"}</span>;
  };

  return (
    <div style={{padding: isMobile ? "12px 16px 24px" : "16px 24px 24px", maxWidth: "100%", overflow: "hidden"}}>
      <div style={{display:"flex",flexDirection:isMobile?"column":"row",justifyContent:"space-between",alignItems:isMobile?"stretch":"flex-start",marginBottom:16,gap:12}}>
        <div>
          <h1 style={{color:C.text,fontSize:isMobile?18:20,fontWeight:800,margin:0}}>Reabasto</h1>
          <p style={{margin:"6px 0 0",color:C.textMid,fontSize:12,maxWidth:720,lineHeight:1.45}}>
            Mismo catálogo que Inventario. El stock y la caducidad salen de Lotes PEPS.
            Si un producto no tiene mínimo, se usa {STOCK_MIN_DEFAULT} piezas. «Comprar en» toma el más barato; Levic baja su plantilla del portal.
          </p>
        </div>
        <div style={{display:"flex",flexDirection:isMobile?"column":"row",gap:8,width:isMobile?"100%":"auto"}}>
          <button onClick={()=>generarOrden(false)} disabled={generando || (!Object.values(selProds).some(v=>v>0) && !filasAlertas.length)}
            style={{padding:"12px 16px",borderRadius:10,border:"none",background:BRAND.gradient,color:"#fff",fontWeight:700,fontSize:13,cursor:"pointer",opacity:generando?0.7:1,width:isMobile?"100%":"auto"}}>
            {generando?"Generando…":"Obtener documento de resurtido"}
          </button>
        </div>
      </div>

      <div style={{display:"grid",gridTemplateColumns:isMobile?"repeat(2,minmax(0,1fr))":"repeat(auto-fit,minmax(120px,1fr))",gap:8,marginBottom:16}}>
        {[
          {label:"Agotados",value:alertas.filter(p=>p.urgencia.nivel==="AGOTADO").length,col:C.red,icon:"🚨"},
          {label:"Críticos",value:alertas.filter(p=>p.urgencia.nivel==="CRÍTICO").length,col:C.red,icon:"🔴"},
          {label:"Caduca",value:alertas.filter(p=>p.urgencia.nivel==="CADUCA"||p.urgencia.nivel==="VENCIDO").length,col:C.amber,icon:"⏳"},
          {label:"Bajo",value:alertas.filter(p=>p.urgencia.nivel==="BAJO").length,col:C.amber,icon:"🟡"},
          {label:"Pronto",value:alertas.filter(p=>p.urgencia.nivel==="PRONTO").length,col:"#0891b2",icon:"🔵"},
          {label:"Elegidos",value:Object.values(selProds).filter(v=>v>0).length,col:BRAND.primary,icon:"✅"},
        ].map(k=>(
          <div key={k.label} style={{background:C.card,border:`1px solid ${C.border}`,borderRadius:12,padding:isMobile?"10px 12px":"12px 16px",minWidth:0}}>
            <div style={{color:C.textDim,fontSize:10,fontWeight:700,letterSpacing:.3}}>{k.icon} {k.label.toUpperCase()}</div>
            <div style={{color:k.col,fontWeight:900,fontSize:isMobile?20:22,marginTop:4}}>{k.value}</div>
          </div>
        ))}
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
                  style={{flex:"1 1 220px",maxWidth:320,padding:"8px 12px",borderRadius:8,border:`1px solid ${C.border}`,fontSize:13,outline:"none"}}
                />
                <div style={{color:C.textMid,fontSize:12,lineHeight:1.45,flex:"2 1 280px"}}>
                  {alertas.length
                    ? `${filasAlertas.length} de ${alertas.length} alertas · marca lo que quieres pedir y genera la orden.`
                    : "Nadie está bajo el umbral. Se muestran las existencias más bajas para que puedas pedir igual."}
                </div>
              </div>
              {isMobile ? (
                <div style={{display:"flex",flexDirection:"column",gap:10}}>
                  {filasAlertas.map((p)=>(
                    <div key={p.id} onClick={()=>toggleSel(p.id)} style={{
                      background:C.card,border:`1px solid ${selProds[p.id]!==undefined?C.blue:C.border}`,
                      borderRadius:12,padding:12,cursor:"pointer",
                    }}>
                      <div style={{display:"flex",justifyContent:"space-between",gap:8,alignItems:"flex-start"}}>
                        <div style={{minWidth:0,flex:1}}>
                          <div style={{color:C.text,fontWeight:700,fontSize:14,lineHeight:1.3}}>{p.nombre}</div>
                          <div style={{color:C.textMid,fontSize:11,marginTop:3}}>{p.sku||"sin SKU"} · mín. {stockMinimoEfectivo(p)}</div>
                        </div>
                        <span style={{padding:"3px 8px",borderRadius:20,fontSize:10,fontWeight:700,background:p.urgencia.bg,color:p.urgencia.col,flexShrink:0}}>
                          {p.urgencia.icon} {p.urgencia.nivel}
                        </span>
                      </div>
                      <div style={{display:"flex",flexWrap:"wrap",gap:"10px 16px",marginTop:10,fontSize:12,color:C.textMid}}>
                        <span>Stock <strong style={{color:p.stock===0?C.red:C.text}}>{p.stock}</strong></span>
                        {p.min_caducidad_lotes && <span>Caduca {p.min_caducidad_lotes}</span>}
                        {p.sinLotePeps && <span style={{color:C.amber,fontWeight:700}}>Sin lote PEPS</span>}
                      </div>
                      <div style={{marginTop:8,fontSize:12}}>{renderComprarEn(p)}</div>
                      <div style={{marginTop:10}} onClick={e=>e.stopPropagation()}>
                        {selProds[p.id]!==undefined?(
                          <label style={{display:"flex",alignItems:"center",gap:8,fontSize:12,color:C.textMid}}>
                            Pedir
                            <input type="number" min="1" inputMode="numeric" value={selProds[p.id]}
                              onChange={e=>setSelProds(prev=>({...prev,[p.id]:parseInt(e.target.value)||1}))}
                              style={inpS}/>
                          </label>
                        ):(
                          <span style={{color:C.textDim,fontSize:12}}>{cantidadSugerida(p)} sugeridas</span>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              ) : (
              <HorizontalScrollSync>
                <table style={{width:"100%",minWidth:1080,borderCollapse:"collapse",fontSize:12}}>
                  <thead>
                    <tr style={{background:C.cardDark}}>
                      <th style={{padding:"9px 12px",textAlign:"left",color:C.textMid,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>
                        <input type="checkbox" onChange={e=>{
                          if(e.target.checked) setSelProds(Object.fromEntries(filasAlertas.map(p=>[p.id,cantidadSugerida(p)])));
                          else setSelProds({});
                        }} style={{cursor:"pointer"}}/>
                      </th>
                      {["Producto","SKU","Categoría","Stock","Mín.","Caducidad PEPS","Urgencia","Pedir (sugerido)","Comprar en"].map(h=>(
                        <th key={h} style={{padding:"9px 12px",textAlign:"left",color:C.textMid,fontWeight:700,borderBottom:`1px solid ${C.border}`,whiteSpace:"nowrap"}}>{h}</th>
                      ))}
                    </tr>
                  </thead>
                  <tbody>
                    {filasAlertas.map((p,i)=>(
                      <tr key={p.id} style={{background:i%2===0?"transparent":"#f8fafc",cursor:"pointer"}} onClick={()=>toggleSel(p.id)}>
                        <td style={{padding:"9px 12px",borderBottom:`1px solid ${C.border}`}}>
                          <input type="checkbox" checked={selProds[p.id]!==undefined} onChange={()=>toggleSel(p.id)} onClick={e=>e.stopPropagation()} style={{cursor:"pointer"}}/>
                        </td>
                        <td style={{padding:"9px 12px",color:C.text,fontWeight:600,borderBottom:`1px solid ${C.border}`}}>{p.nombre}</td>
                        <td style={{padding:"9px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`,fontFamily:"monospace",fontSize:10}}>{p.sku||"—"}</td>
                        <td style={{padding:"9px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{p.categoria||"—"}</td>
                        <td style={{padding:"9px 12px",color:p.stock===0?C.red:C.amber,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{p.stock}</td>
                        <td style={{padding:"9px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{stockMinimoEfectivo(p)}{!p.stock_minimo ? " *" : ""}</td>
                        <td style={{padding:"9px 12px",borderBottom:`1px solid ${C.border}`,whiteSpace:"nowrap"}}>
                          {p.min_caducidad_lotes ? (
                            <span style={{
                              color: p.diasCaducidad < 0 ? C.red : p.diasCaducidad <= 30 ? C.amber : C.textMid,
                              fontWeight: p.diasCaducidad != null && p.diasCaducidad <= 30 ? 700 : 500,
                            }}>
                              {p.min_caducidad_lotes}{p.diasCaducidad != null ? ` (${p.diasCaducidad}d)` : ""}
                            </span>
                          ) : p.sinLotePeps ? (
                            <span style={{color:C.amber,fontWeight:700}}>Sin lote PEPS</span>
                          ) : "—"}
                        </td>
                        <td style={{padding:"9px 12px",borderBottom:`1px solid ${C.border}`}}>
                          <span style={{padding:"3px 8px",borderRadius:20,fontSize:10,fontWeight:700,background:p.urgencia.bg,color:p.urgencia.col}}>
                            {p.urgencia.icon} {p.urgencia.nivel}
                          </span>
                        </td>
                        <td style={{padding:"9px 12px",borderBottom:`1px solid ${C.border}`}} onClick={e=>e.stopPropagation()}>
                          {selProds[p.id]!==undefined?(
                            <input type="number" min="1" value={selProds[p.id]}
                              onChange={e=>setSelProds(prev=>({...prev,[p.id]:parseInt(e.target.value)||1}))}
                              style={inpS}/>
                          ):(
                            <span style={{color:C.textDim,fontSize:11}}>{cantidadSugerida(p)} sugeridas</span>
                          )}
                        </td>
                        <td style={{padding:"9px 12px",borderBottom:`1px solid ${C.border}`}}>{renderComprarEn(p)}</td>
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
                Pedidos agrupados para no hacer viajes de más. Si hay Levic, se baja también <strong>Pedido_Levic_portal.xlsx</strong>: ese es el que subes al portal (llega mañana).
              </div>
              <button onClick={()=>descargarPedidosWorkbook(ordenesEnv)}
                style={{padding:"8px 14px",borderRadius:8,border:"none",background:BRAND.gradient,color:"#fff",fontWeight:700,fontSize:12,cursor:"pointer"}}>
                Bajar Excel de todos
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
                        ? "Excel listo para cargar en Levic"
                        : "Excel de esta tienda"}
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
                <HorizontalScrollSync>
                  <table style={{width:"100%",minWidth:640,borderCollapse:"collapse",fontSize:12}}>
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
