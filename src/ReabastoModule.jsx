import { useState, useEffect, useCallback } from "react";
import { C_LIGHT, C_DARK } from "./constants";
import { useTheme } from "./themeContext";
import { supabase } from "./supabase";
import { showToast } from "./ui";

const BRAND = { primary:"#0052cc", gradient:"linear-gradient(135deg,#0052cc,#0099e6)" };
const fmt = n => `$${parseFloat(n||0).toLocaleString("es-MX",{minimumFractionDigits:2})}`;

const PROVEEDORES_COMUNES = ["Nadro","Marzam","Casa Saba","Fármacos Nacionales","Proveedor local","Otro"];

export default function ReabastoModule() {
  const C = useTheme();
  const [productos,   setProductos]   = useState([]);
  const [loading,     setLoading]     = useState(true);
  const [ordenesEnv,  setOrdenesEnv]  = useState([]);
  const [tab,         setTab]         = useState("alertas");
  const [selProds,    setSelProds]    = useState({});
  const [generando,   setGenerando]   = useState(false);

  const fetchProductos = useCallback(async () => {
    setLoading(true);
    const { data } = await supabase
      .from("productos")
      .select("id,nombre,sku,categoria,stock,stock_minimo,costo,proveedor,activo")
      .eq("activo", true)
      .order("stock");
    setProductos(data||[]);
    setLoading(false);
  },[]);

  useEffect(()=>{ fetchProductos(); },[fetchProductos]);

  // Calcular urgencia
  const calcUrgencia = (p) => {
    if (!p.stock_minimo) return null;
    const pct = p.stock / p.stock_minimo;
    if (p.stock === 0) return { nivel:"AGOTADO", col:C.red, bg:C.redDim, icon:"🚨" };
    if (pct <= 0.5)    return { nivel:"CRÍTICO", col:C.red, bg:C.redDim, icon:"🔴" };
    if (pct <= 1)      return { nivel:"BAJO",    col:C.amber, bg:C.amberDim, icon:"🟡" };
    if (pct <= 1.5)    return { nivel:"PRONTO",  col:"#0891b2", bg:"#cffafe", icon:"🔵" };
    return null;
  };

  const alertas = productos
    .map(p=>({...p, urgencia:calcUrgencia(p)}))
    .filter(p=>p.urgencia)
    .sort((a,b)=>{
      const ord={AGOTADO:0,CRÍTICO:1,BAJO:2,PRONTO:3};
      return (ord[a.urgencia.nivel]||9)-(ord[b.urgencia.nivel]||9);
    });

  const cantidadSugerida = (p) => Math.max((p.stock_minimo||0)*3 - p.stock, 1);

  const toggleSel = (id) => setSelProds(prev=>({
    ...prev,
    [id]: prev[id]!==undefined ? undefined : cantidadSugerida(alertas.find(p=>p.id===id)||{})
  }));

  const generarOrden = async () => {
    const items = Object.entries(selProds)
      .filter(([,qty])=>qty>0)
      .map(([id,qty])=>({
        producto: alertas.find(p=>p.id===parseInt(id)),
        cantidad: qty,
      }))
      .filter(x=>x.producto);

    if (!items.length) { showToast("Selecciona al menos un producto","warning"); return; }
    setGenerando(true);

    // Agrupar por proveedor
    const porProveedor = {};
    items.forEach(({producto,cantidad})=>{
      const prov = producto.proveedor||"Sin proveedor";
      if(!porProveedor[prov]) porProveedor[prov]=[];
      porProveedor[prov].push({...producto,cantidadPedida:cantidad});
    });

    // Generar texto de orden
    const ordenes = Object.entries(porProveedor).map(([prov,prods])=>{
      const total = prods.reduce((a,p)=>a+(p.costo||0)*p.cantidadPedida,0);
      return { proveedor:prov, productos:prods, total, fecha:new Date().toLocaleDateString("es-MX") };
    });

    setOrdenesEnv(ordenes);
    setTab("ordenes");
    setGenerando(false);
    showToast(`✅ ${ordenes.length} orden(es) de reabasto generada(s)`,"success");
  };

  const imprimirOrden = (orden) => {
    const w = window.open("","_blank","width=700,height=800");
    const rows = orden.productos.map(p=>`
      <tr>
        <td style="padding:8px 12px;border-bottom:1px solid #e2e8f0">${p.nombre}</td>
        <td style="padding:8px 12px;border-bottom:1px solid #e2e8f0;text-align:center">${p.sku||"—"}</td>
        <td style="padding:8px 12px;border-bottom:1px solid #e2e8f0;text-align:center">${p.stock}</td>
        <td style="padding:8px 12px;border-bottom:1px solid #e2e8f0;text-align:center;font-weight:700;color:#0052cc">${p.cantidadPedida}</td>
        <td style="padding:8px 12px;border-bottom:1px solid #e2e8f0;text-align:right">$${((p.costo||0)*p.cantidadPedida).toFixed(2)}</td>
      </tr>`).join("");
    w.document.write(`<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8"><title>Orden de Reabasto</title>
      <style>body{font-family:Arial,sans-serif;font-size:13px;padding:24px;color:#0f172a}h2{color:#0052cc}table{width:100%;border-collapse:collapse}th{background:#f8fafc;padding:9px 12px;text-align:left;font-size:11px;color:#475569;border-bottom:2px solid #e2e8f0}.total{text-align:right;font-weight:800;font-size:16px;color:#00c46a;padding:12px 12px 0}</style>
      </head><body>
      <div style="display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:20px">
        <div><h2>📦 Orden de Reabasto — FARMAX</h2><div style="color:#475569">Chinampac de Juárez, CDMX · ${orden.fecha}</div></div>
        <div style="text-align:right"><div style="font-weight:700">Proveedor:</div><div style="color:#0052cc;font-weight:800;font-size:16px">${orden.proveedor}</div></div>
      </div>
      <table><thead><tr><th>Producto</th><th style="text-align:center">SKU</th><th style="text-align:center">Stock actual</th><th style="text-align:center">Cantidad a pedir</th><th style="text-align:right">Costo estimado</th></tr></thead>
      <tbody>${rows}</tbody></table>
      <div class="total">Total estimado: $${orden.total.toFixed(2)} MXN</div>
      <div style="margin-top:32px;border-top:1px solid #e2e8f0;padding-top:16px;color:#94a3b8;font-size:11px">
        Generado automáticamente por Farmax · ${new Date().toLocaleString("es-MX")}
      </div></body></html>`);
    w.document.close(); w.focus(); setTimeout(()=>w.print(),500);
  };

  const inpS = {width:"70px",padding:"4px 8px",borderRadius:6,border:`1px solid ${C.border}`,fontSize:12,textAlign:"center",outline:"none"};

  return (
    <div>
      <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:20}}>
        <h1 style={{color:C.text,fontSize:20,fontWeight:800,margin:0}}>📦 Reabasto automático</h1>
        <button onClick={generarOrden} disabled={!Object.values(selProds).some(v=>v>0)||generando}
          style={{padding:"9px 20px",borderRadius:8,border:"none",background:BRAND.gradient,color:"#fff",fontWeight:700,fontSize:13,cursor:"pointer",opacity:!Object.values(selProds).some(v=>v>0)?0.5:1}}>
          {generando?"Generando…":"📋 Generar orden de compra"}
        </button>
      </div>

      {/* KPIs */}
      <div style={{display:"flex",gap:12,marginBottom:20,flexWrap:"wrap"}}>
        {[
          {label:"Agotados",value:alertas.filter(p=>p.urgencia.nivel==="AGOTADO").length,col:C.red,icon:"🚨"},
          {label:"Críticos",value:alertas.filter(p=>p.urgencia.nivel==="CRÍTICO").length,col:C.red,icon:"🔴"},
          {label:"Bajo stock",value:alertas.filter(p=>p.urgencia.nivel==="BAJO").length,col:C.amber,icon:"🟡"},
          {label:"Pedir pronto",value:alertas.filter(p=>p.urgencia.nivel==="PRONTO").length,col:"#0891b2",icon:"🔵"},
          {label:"Seleccionados",value:Object.values(selProds).filter(v=>v>0).length,col:BRAND.primary,icon:"✅"},
        ].map(k=>(
          <div key={k.label} style={{background:C.card,border:`1px solid ${C.border}`,borderRadius:12,padding:"12px 18px",flex:1,minWidth:110}}>
            <div style={{color:C.textDim,fontSize:10,fontWeight:700}}>{k.icon} {k.label.toUpperCase()}</div>
            <div style={{color:k.col,fontWeight:900,fontSize:22,marginTop:4}}>{k.value}</div>
          </div>
        ))}
      </div>

      {/* Tabs */}
      <div style={{display:"flex",gap:4,marginBottom:20,borderBottom:`1px solid ${C.border}`}}>
        {[["alertas","🚨 Alertas de stock"],["ordenes",`📋 Órdenes (${ordenesEnv.length})`]].map(([id,label])=>(
          <button key={id} onClick={()=>setTab(id)} style={{
            padding:"8px 18px",border:"none",cursor:"pointer",fontWeight:700,fontSize:12,
            borderRadius:"8px 8px 0 0",background:"transparent",
            color:tab===id?BRAND.primary:C.textMid,
            borderBottom:tab===id?`2px solid ${BRAND.primary}`:"2px solid transparent",
          }}>{label}</button>
        ))}
      </div>

      {/* Tab alertas */}
      {tab==="alertas"&&(
        loading?<div style={{color:C.textMid,textAlign:"center",padding:40}}>Cargando…</div>:(
          !alertas.length?(
            <div style={{background:C.card,borderRadius:12,border:`1px solid ${C.border}`,padding:40,textAlign:"center"}}>
              <div style={{fontSize:48,marginBottom:12}}>✅</div>
              <div style={{color:C.text,fontWeight:700,fontSize:16}}>¡Todo en orden!</div>
              <div style={{color:C.textMid,fontSize:13,marginTop:4}}>No hay productos que requieran reabasto en este momento.</div>
            </div>
          ):(
            <div>
              <div style={{color:C.textMid,fontSize:12,marginBottom:12}}>
                Selecciona los productos que quieres pedir y ajusta la cantidad. Luego haz clic en "Generar orden de compra".
              </div>
              <div style={{overflowX:"auto",borderRadius:12,border:`1px solid ${C.border}`}}>
                <table style={{width:"100%",borderCollapse:"collapse",fontSize:12}}>
                  <thead>
                    <tr style={{background:C.cardDark}}>
                      <th style={{padding:"9px 12px",textAlign:"left",color:C.textMid,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>
                        <input type="checkbox" onChange={e=>{
                          if(e.target.checked) setSelProds(Object.fromEntries(alertas.map(p=>[p.id,cantidadSugerida(p)])));
                          else setSelProds({});
                        }} style={{cursor:"pointer"}}/>
                      </th>
                      {["Producto","SKU","Categoría","Stock actual","Mínimo","Urgencia","Pedir (sugerido)","Proveedor"].map(h=>(
                        <th key={h} style={{padding:"9px 12px",textAlign:"left",color:C.textMid,fontWeight:700,borderBottom:`1px solid ${C.border}`,whiteSpace:"nowrap"}}>{h}</th>
                      ))}
                    </tr>
                  </thead>
                  <tbody>
                    {alertas.map((p,i)=>(
                      <tr key={p.id} style={{background:i%2===0?"transparent":"#f8fafc",cursor:"pointer"}} onClick={()=>toggleSel(p.id)}>
                        <td style={{padding:"9px 12px",borderBottom:`1px solid ${C.border}`}}>
                          <input type="checkbox" checked={selProds[p.id]!==undefined} onChange={()=>toggleSel(p.id)} onClick={e=>e.stopPropagation()} style={{cursor:"pointer"}}/>
                        </td>
                        <td style={{padding:"9px 12px",color:C.text,fontWeight:600,borderBottom:`1px solid ${C.border}`}}>{p.nombre}</td>
                        <td style={{padding:"9px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`,fontFamily:"monospace",fontSize:10}}>{p.sku||"—"}</td>
                        <td style={{padding:"9px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{p.categoria||"—"}</td>
                        <td style={{padding:"9px 12px",color:p.stock===0?C.red:C.amber,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{p.stock}</td>
                        <td style={{padding:"9px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{p.stock_minimo||"—"}</td>
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
                        <td style={{padding:"9px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{p.proveedor||"—"}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )
        )
      )}

      {/* Tab órdenes */}
      {tab==="ordenes"&&(
        !ordenesEnv.length?(
          <div style={{background:C.card,borderRadius:12,border:`1px solid ${C.border}`,padding:40,textAlign:"center",color:C.textMid}}>
            Genera una orden desde la pestaña "Alertas de stock".
          </div>
        ):(
          <div style={{display:"flex",flexDirection:"column",gap:16}}>
            {ordenesEnv.map((orden,i)=>(
              <div key={i} style={{background:C.card,borderRadius:12,border:`1px solid ${C.border}`,padding:20}}>
                <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:16,flexWrap:"wrap",gap:8}}>
                  <div>
                    <div style={{fontWeight:800,color:C.text,fontSize:15}}>📦 Proveedor: {orden.proveedor}</div>
                    <div style={{color:C.textMid,fontSize:12,marginTop:2}}>{orden.productos.length} productos · Total estimado: <strong style={{color:C.green}}>{fmt(orden.total)}</strong></div>
                  </div>
                  <div style={{display:"flex",gap:8}}>
                    <button onClick={()=>imprimirOrden(orden)} style={{padding:"7px 14px",borderRadius:8,border:`1px solid ${BRAND.primary}`,background:"#eff6ff",color:BRAND.primary,fontWeight:700,fontSize:12,cursor:"pointer"}}>
                      🖨️ Imprimir orden
                    </button>
                    <button onClick={()=>{
                      const msg = `📦 *Orden de reabasto FARMAX*\n\nProveedor: ${orden.proveedor}\nFecha: ${orden.fecha}\n\n${orden.productos.map(p=>`• ${p.nombre} × ${p.cantidadPedida}`).join("\n")}\n\nTotal estimado: $${orden.total.toFixed(2)} MXN\n\n_Generado por sistema Farmax_`;
                      window.open("https://wa.me/?text="+encodeURIComponent(msg),"_blank");
                    }} style={{padding:"7px 14px",borderRadius:8,border:"1px solid #25D366",background:"#dcfce7",color:"#16a34a",fontWeight:700,fontSize:12,cursor:"pointer"}}>
                      📱 WhatsApp
                    </button>
                  </div>
                </div>
                <table style={{width:"100%",borderCollapse:"collapse",fontSize:12}}>
                  <thead><tr style={{background:C.cardDark}}>{["Producto","SKU","Stock actual","Cantidad pedida","Costo est."].map(h=><th key={h} style={{padding:"8px 12px",textAlign:"left",color:C.textMid,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{h}</th>)}</tr></thead>
                  <tbody>
                    {orden.productos.map((p,j)=>(
                      <tr key={j} style={{background:j%2===0?"transparent":"#f8fafc"}}>
                        <td style={{padding:"8px 12px",color:C.text,fontWeight:600,borderBottom:`1px solid ${C.border}`}}>{p.nombre}</td>
                        <td style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`,fontFamily:"monospace",fontSize:10}}>{p.sku||"—"}</td>
                        <td style={{padding:"8px 12px",color:C.amber,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{p.stock}</td>
                        <td style={{padding:"8px 12px",color:BRAND.primary,fontWeight:800,borderBottom:`1px solid ${C.border}`}}>{p.cantidadPedida}</td>
                        <td style={{padding:"8px 12px",color:C.green,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{fmt((p.costo||0)*p.cantidadPedida)}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            ))}
          </div>
        )
      )}
    </div>
  );
}
