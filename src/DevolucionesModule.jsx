import { useState, useEffect, useCallback } from "react";
import { C_LIGHT, C_DARK } from "./constants";
import { useTheme } from "./themeContext";
import { supabase } from "./supabase";

const BRAND = { primary:"#0052cc", secondary:"#0099e6", gradient:"linear-gradient(135deg,#0052cc,#0099e6)" };
const fmt = n => `$${parseFloat(n||0).toLocaleString("es-MX",{minimumFractionDigits:2,maximumFractionDigits:2})}`;
const fmtDT = s => { if(!s)return"—"; const d=new Date(s); return d.toLocaleDateString("es-MX",{day:"2-digit",month:"short",year:"numeric"})+" "+d.toLocaleTimeString("es-MX",{hour:"2-digit",minute:"2-digit"}); };

const mkInpS = (C) => ({ width:"100%", boxSizing:"border-box", padding:"9px 12px", borderRadius:8, border:`1px solid ${C.border}`, background:C.card, color:C.text, fontSize:13, outline:"none" });
const mkLabelS = (C) => ({ color:C.textMid, fontSize:11, fontWeight:700, display:"block", marginBottom:4 });
const mkBtnPrimary = (C) => ({ padding:"9px 20px", borderRadius:8, border:"none", background:BRAND.gradient, color:"#fff", fontWeight:700, fontSize:13, cursor:"pointer" });
const mkBtnOutline = (C) => ({ padding:"9px 20px", borderRadius:8, border:`1px solid ${C.border}`, background:"transparent", color:C.textMid, fontWeight:700, fontSize:13, cursor:"pointer" });
const btnSmall = (col) => ({ padding:"4px 10px", borderRadius:6, border:`1px solid ${col}30`, background:col+"15", color:col, cursor:"pointer", fontSize:11, fontWeight:700 });

const estCol = (e, C) => e==="aprobada"?C.green:e==="rechazada"?C.red:C.amber;

// ── Modal Nueva Devolución ────────────────────────────────────
function NuevaDevolucionModal({usuario, onClose, onSaved }) {
  const C = useTheme();
  const labelS = mkLabelS(C);
  const inpS = mkInpS(C);
  const btnPrimary = mkBtnPrimary(C);
  const btnOutline = mkBtnOutline(C);
  const [step,      setStep]    = useState(1);
  const [busqPed,   setBusqPed] = useState("");
  const [pedidos,   setPedidos] = useState([]);
  const [pedSel,    setPedSel]  = useState(null);
  const [items,     setItems]   = useState([]);
  const [selItems,  setSelItems]= useState({});
  const [motivo,    setMotivo]  = useState("");
  const [metodo,    setMetodo]  = useState("efectivo");
  const [notas,     setNotas]   = useState("");
  const [saving,    setSaving]  = useState(false);
  const [error,     setError]   = useState("");

  const buscarPedido = async () => {
    if (!busqPed) return;
    const { data } = await supabase.from("pedidos")
      .select("*, clientes(nombre,telefono), pedido_items(id,cantidad,precio_unitario,productos(id,nombre,stock))")
      .or(`id.eq.${isNaN(busqPed)?0:busqPed},clientes.telefono.eq.${busqPed}`)
      .eq("estado","completado")
      .order("created_at",{ascending:false})
      .limit(10);
    setPedidos(data||[]);
  };

  const selPedido = (p) => {
    setPedSel(p);
    setItems(p.pedido_items||[]);
    const init = {};
    (p.pedido_items||[]).forEach(i=>{ init[i.id]=0; });
    setSelItems(init);
    setStep(2);
  };

  const toggleItem = (id, max) => {
    setSelItems(p=>({ ...p, [id]: p[id]>0 ? 0 : max }));
  };

  const setCantidad = (id, val, max) => {
    const n = Math.min(Math.max(0, parseInt(val)||0), max);
    setSelItems(p=>({ ...p, [id]: n }));
  };

  const totalDevolver = items.reduce((a,i) => a + (selItems[i.id]||0) * i.precio_unitario, 0);
  const itemsSel = items.filter(i=>(selItems[i.id]||0)>0);

  const guardar = async () => {
    if (!itemsSel.length) { setError("Selecciona al menos un producto."); return; }
    if (!motivo) { setError("Indica el motivo de la devolución."); return; }
    setSaving(true); setError("");
    try {
      const { data: dev } = await supabase.from("devoluciones").insert({
        pedido_id: pedSel.id,
        cliente_id: pedSel.cliente_id||null,
        motivo, estado:"aprobada",
        total_devuelto: totalDevolver,
        metodo_reembolso: metodo,
        notas: notas||null,
        atendido_por: usuario?.id||null,
      }).select().single();

      if (dev) {
        await supabase.from("devolucion_items").insert(
          itemsSel.map(i=>({
            devolucion_id: dev.id,
            producto_id: i.productos?.id||null,
            producto_nombre: i.productos?.nombre||"Producto",
            cantidad: selItems[i.id],
            precio_unitario: i.precio_unitario,
          }))
        );
        // Restaurar stock
        for (const i of itemsSel) {
          if (i.productos?.id) {
            const nuevoStock = (i.productos.stock||0) + (selItems[i.id]||0);
            await supabase.from("productos").update({stock:nuevoStock}).eq("id",i.productos.id);
          }
        }
        // Audit log
        await supabase.from("audit_log").insert({
          usuario_id: usuario?.id||null,
          usuario_nombre: usuario?.nombre||"Sistema",
          accion: "DEVOLUCION",
          tabla: "devoluciones",
          registro_id: String(dev.id),
          detalle: { pedido_id:pedSel.id, total:totalDevolver, items:itemsSel.length },
        });
      }
      onSaved();
    } catch(e) { setError("Error al guardar: "+e.message); }
    setSaving(false);
  };

  return (
    <div style={{position:"fixed",inset:0,background:"rgba(15,23,42,.45)",backdropFilter:"blur(4px)",zIndex:500,display:"flex",alignItems:"center",justifyContent:"center",padding:20}}
      onClick={e=>e.target===e.currentTarget&&onClose()}>
      <div style={{background:C.card,borderRadius:14,width:"min(620px,95vw)",maxHeight:"90vh",overflowY:"auto",padding:28,boxShadow:"0 20px 60px rgba(0,82,204,.15)"}}>
        <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:20}}>
          <h3 style={{margin:0,color:C.text,fontSize:16,fontWeight:800}}>↩️ Nueva Devolución</h3>
          <button onClick={onClose} style={{background:"none",border:"none",color:C.textMid,fontSize:22,cursor:"pointer"}}>✕</button>
        </div>

        {/* Step 1: Buscar pedido */}
        {step===1&&(
          <div>
            <label style={labelS}>BUSCAR PEDIDO (por ID o teléfono del cliente)</label>
            <div style={{display:"flex",gap:8,marginBottom:16}}>
              <input style={{...inpS,flex:1}} value={busqPed} onChange={e=>setBusqPed(e.target.value)}
                onKeyDown={e=>e.key==="Enter"&&buscarPedido()}
                placeholder="Ej: 123 o 5537275035"/>
              <button style={btnPrimary} onClick={buscarPedido}>Buscar</button>
            </div>
            {pedidos.length>0&&(
              <div style={{display:"flex",flexDirection:"column",gap:8}}>
                {pedidos.map(p=>(
                  <div key={p.id} onClick={()=>selPedido(p)}
                    style={{padding:14,borderRadius:10,border:`1px solid ${C.border}`,cursor:"pointer",background:C.cardDark}}
                    onMouseEnter={e=>e.currentTarget.style.borderColor=BRAND.primary}
                    onMouseLeave={e=>e.currentTarget.style.borderColor=C.border}>
                    <div style={{display:"flex",justifyContent:"space-between"}}>
                      <span style={{fontWeight:700,color:C.text}}>Pedido #{p.id}</span>
                      <span style={{color:C.green,fontWeight:700}}>{fmt(p.total)}</span>
                    </div>
                    <div style={{color:C.textMid,fontSize:12,marginTop:4}}>
                      {p.clientes?.nombre||"Sin cliente"} · {fmtDT(p.created_at)}
                    </div>
                  </div>
                ))}
              </div>
            )}
            {pedidos.length===0&&busqPed&&<div style={{color:C.textMid,fontSize:13,textAlign:"center",padding:20}}>Sin resultados. Solo se pueden devolver pedidos completados.</div>}
          </div>
        )}

        {/* Step 2: Seleccionar items */}
        {step===2&&(
          <div>
            <div style={{background:C.cardDark,borderRadius:8,padding:"10px 14px",marginBottom:16,fontSize:12}}>
              <strong>Pedido #{pedSel.id}</strong> · {pedSel.clientes?.nombre||"Sin cliente"} · {fmt(pedSel.total)}
              <button onClick={()=>{setStep(1);setPedSel(null);setPedidos([]);}} style={{marginLeft:12,background:"none",border:"none",color:BRAND.primary,cursor:"pointer",fontSize:11,fontWeight:700}}>Cambiar</button>
            </div>
            <label style={labelS}>SELECCIONA PRODUCTOS A DEVOLVER</label>
            <div style={{marginBottom:16}}>
              {items.map(i=>(
                <div key={i.id} style={{display:"flex",alignItems:"center",gap:12,padding:"10px 0",borderBottom:`1px solid ${C.border}`}}>
                  <input type="checkbox" checked={(selItems[i.id]||0)>0}
                    onChange={()=>toggleItem(i.id,i.cantidad)}
                    style={{width:16,height:16,cursor:"pointer"}}/>
                  <div style={{flex:1}}>
                    <div style={{color:C.text,fontWeight:600,fontSize:13}}>{i.productos?.nombre||"Producto"}</div>
                    <div style={{color:C.textMid,fontSize:11}}>{fmt(i.precio_unitario)} c/u · Compró: {i.cantidad}</div>
                  </div>
                  {(selItems[i.id]||0)>0&&(
                    <div style={{display:"flex",alignItems:"center",gap:6}}>
                      <button onClick={()=>setCantidad(i.id,(selItems[i.id]||0)-1,i.cantidad)} style={{width:24,height:24,borderRadius:4,border:`1px solid ${C.border}`,background:"none",cursor:"pointer"}}>−</button>
                      <span style={{fontWeight:700,fontSize:13,minWidth:20,textAlign:"center"}}>{selItems[i.id]}</span>
                      <button onClick={()=>setCantidad(i.id,(selItems[i.id]||0)+1,i.cantidad)} style={{width:24,height:24,borderRadius:4,border:`1px solid ${C.border}`,background:"none",cursor:"pointer"}}>+</button>
                    </div>
                  )}
                  <span style={{color:C.green,fontWeight:700,fontSize:13,minWidth:60,textAlign:"right"}}>{fmt((selItems[i.id]||0)*i.precio_unitario)}</span>
                </div>
              ))}
            </div>
            <div style={{marginBottom:12}}>
              <label style={labelS}>MOTIVO DE DEVOLUCIÓN *</label>
              <select style={inpS} value={motivo} onChange={e=>setMotivo(e.target.value)}>
                <option value="">Seleccionar motivo...</option>
                <option value="Producto en mal estado">Producto en mal estado</option>
                <option value="Producto incorrecto">Producto incorrecto</option>
                <option value="Error en la venta">Error en la venta</option>
                <option value="Medicamento no necesario">Medicamento no necesario</option>
                <option value="Cobro duplicado">Cobro duplicado</option>
                <option value="Otro">Otro</option>
              </select>
            </div>
            <div style={{marginBottom:12}}>
              <label style={labelS}>MÉTODO DE REEMBOLSO</label>
              <select style={inpS} value={metodo} onChange={e=>setMetodo(e.target.value)}>
                <option value="efectivo">Efectivo</option>
                <option value="tarjeta">Tarjeta (reverso)</option>
                <option value="puntos">Puntos Farmax</option>
                <option value="credito">Crédito en farmacia</option>
              </select>
            </div>
            <div style={{marginBottom:16}}>
              <label style={labelS}>NOTAS (opcional)</label>
              <textarea value={notas} onChange={e=>setNotas(e.target.value)} rows={2}
                style={{...inpS,resize:"vertical"}} placeholder="Observaciones adicionales..."/>
            </div>
            {totalDevolver>0&&(
              <div style={{background:C.greenDim,border:`1px solid ${C.green}30`,borderRadius:8,padding:"12px 16px",marginBottom:16,display:"flex",justifyContent:"space-between",alignItems:"center"}}>
                <span style={{color:C.greenDark,fontWeight:700}}>Total a reembolsar:</span>
                <span style={{color:C.green,fontWeight:900,fontSize:20}}>{fmt(totalDevolver)}</span>
              </div>
            )}
            {error&&<div style={{background:C.redDim,borderRadius:8,padding:"10px 12px",marginBottom:12,color:C.red,fontSize:13}}>{error}</div>}
            <div style={{display:"flex",gap:10,justifyContent:"flex-end"}}>
              <button style={btnOutline} onClick={()=>setStep(1)}>← Atrás</button>
              <button style={btnPrimary} onClick={guardar} disabled={saving||!itemsSel.length||!motivo}>
                {saving?"Procesando…":"↩️ Confirmar devolución"}
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

// ── Módulo principal ──────────────────────────────────────────
export default function DevolucionesModule({ usuario }) {
  const C = useTheme();
  const [devoluciones, setDev]    = useState([]);
  const [loading,      setLoad]   = useState(true);
  const [modal,        setModal]  = useState(false);
  const [filtro,       setFiltro] = useState("todos");
  const [busq,         setBusq]   = useState("");

  const fetch = useCallback(async () => {
    setLoad(true);
    const { data } = await supabase.from("devoluciones")
      .select("*, clientes(nombre,telefono), pedidos(id,total), devolucion_items(id,producto_nombre,cantidad,precio_unitario)")
      .order("created_at",{ascending:false})
      .limit(100);
    setDev(data||[]);
    setLoad(false);
  },[]);

  useEffect(()=>{ fetch(); },[fetch]);

  const fil = devoluciones.filter(d=>{
    const matchF = filtro==="todos" || d.estado===filtro;
    const matchB = !busq || d.id?.toString().includes(busq) || d.clientes?.nombre?.toLowerCase().includes(busq.toLowerCase());
    return matchF && matchB;
  });

  const totalMes = devoluciones.filter(d=>{
    const hace30 = new Date(Date.now()-30*86400000);
    return new Date(d.created_at)>=hace30 && d.estado==="aprobada";
  }).reduce((a,d)=>a+parseFloat(d.total_devuelto||0),0);

  return (
    <div>
      <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:20}}>
        <h1 style={{color:C.text,fontSize:20,fontWeight:800,margin:0}}>↩️ Devoluciones</h1>
        <button style={btnPrimary} onClick={()=>setModal(true)}>+ Nueva devolución</button>
      </div>

      {/* KPIs */}
      <div style={{display:"flex",gap:12,marginBottom:20,flexWrap:"wrap"}}>
        {[
          {label:"Total este mes",value:fmt(totalMes),col:C.red},
          {label:"Pendientes",value:devoluciones.filter(d=>d.estado==="pendiente").length,col:C.amber},
          {label:"Aprobadas",value:devoluciones.filter(d=>d.estado==="aprobada").length,col:C.green},
          {label:"Total registradas",value:devoluciones.length,col:C.blue},
        ].map(k=>(
          <div key={k.label} style={{background:C.card,border:`1px solid ${C.border}`,borderRadius:12,padding:"14px 20px",flex:1,minWidth:120}}>
            <div style={{color:C.textDim,fontSize:10,fontWeight:700,marginBottom:4}}>{k.label.toUpperCase()}</div>
            <div style={{color:k.col,fontWeight:900,fontSize:22}}>{k.value}</div>
          </div>
        ))}
      </div>

      {/* Filtros */}
      <div style={{display:"flex",gap:8,marginBottom:16,flexWrap:"wrap",alignItems:"center"}}>
        <input placeholder="🔍 ID o cliente…" value={busq} onChange={e=>setBusq(e.target.value)}
          style={{...inpS,maxWidth:200,width:"auto"}}/>
        {["todos","pendiente","aprobada","rechazada"].map(f=>(
          <button key={f} onClick={()=>setFiltro(f)} style={{padding:"6px 14px",borderRadius:20,border:`1px solid ${filtro===f?BRAND.primary:C.border}`,background:filtro===f?BRAND.primary+"18":"transparent",color:filtro===f?BRAND.primary:C.textMid,fontSize:12,fontWeight:600,cursor:"pointer"}}>
            {f.charAt(0).toUpperCase()+f.slice(1)}
          </button>
        ))}
        <span style={{color:C.textMid,fontSize:11,marginLeft:"auto"}}>{fil.length} devoluciones</span>
      </div>

      {/* Tabla */}
      {loading?<div style={{color:C.textMid,textAlign:"center",padding:40}}>Cargando…</div>:(
        <div style={{overflowX:"auto",borderRadius:12,border:`1px solid ${C.border}`}}>
          <table style={{width:"100%",borderCollapse:"collapse",fontSize:12}}>
            <thead>
              <tr style={{background:C.cardDark}}>
                {["ID","Fecha","Cliente","Pedido orig.","Productos","Total devuelto","Método","Estado"].map(h=>(
                  <th key={h} style={{padding:"9px 12px",textAlign:"left",color:C.textMid,fontWeight:700,borderBottom:`1px solid ${C.border}`,whiteSpace:"nowrap"}}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {!fil.length&&<tr><td colSpan={8} style={{textAlign:"center",padding:32,color:C.textMid}}>Sin devoluciones registradas</td></tr>}
              {fil.map((d,i)=>(
                <tr key={d.id} style={{background:i%2===0?"transparent":"#f8fafc"}}>
                  <td style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`,fontFamily:"monospace"}}>#{d.id}</td>
                  <td style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`,whiteSpace:"nowrap"}}>{fmtDT(d.created_at)}</td>
                  <td style={{padding:"8px 12px",color:C.text,fontWeight:600,borderBottom:`1px solid ${C.border}`}}>{d.clientes?.nombre||"—"}</td>
                  <td style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>#{d.pedido_id||"—"}</td>
                  <td style={{padding:"8px 12px",borderBottom:`1px solid ${C.border}`,maxWidth:180}}>
                    {(d.devolucion_items||[]).map((it,idx)=>(
                      <div key={idx} style={{color:C.text,fontSize:11}}>{it.producto_nombre} ×{it.cantidad}</div>
                    ))}
                  </td>
                  <td style={{padding:"8px 12px",color:C.red,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{fmt(d.total_devuelto)}</td>
                  <td style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{d.metodo_reembolso||"—"}</td>
                  <td style={{padding:"8px 12px",borderBottom:`1px solid ${C.border}`}}>
                    <span style={{padding:"2px 8px",borderRadius:20,fontSize:10,fontWeight:700,background:estCol(d.estado, C)+"20",color:estCol(d.estado, C)}}>
                      {d.estado}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {modal&&<NuevaDevolucionModal usuario={usuario} onClose={()=>setModal(false)} onSaved={()=>{setModal(false);fetch();}}/>}
    </div>
  );
}
