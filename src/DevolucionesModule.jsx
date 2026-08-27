import { useState, useEffect, useCallback, useRef } from "react";
import { C_LIGHT } from "./constants";
import { supabase } from "./supabase";
import { productMatchesSearchQuery } from "./utils/fuzzySearch";
import { queryRpcDevolucion } from "./utils/busquedaDevolucion";
import { formatFolioPOS } from "./utils/orderReceiptWhatsApp";
import { showToast } from "./ui";
import { rolEsAdmin } from "./utils/permissions";
import { useHidBarcodeWedge } from "./hooks/useHidBarcodeWedge";
import {
  findProductExactScan,
  looksLikeBarcodeInput,
  looksLikeInternalSku,
  normalizeBarcodeRaw,
  shouldReplaceScanInput,
} from "./utils/barcodeProductLookup";

const BRAND = { primary:"#0D1B2A", secondary:"#1E3ABA", gradient:"linear-gradient(135deg,#0D1B2A,#1E3ABA)" };
const fmt = n => `$${parseFloat(n||0).toLocaleString("es-MX",{minimumFractionDigits:2,maximumFractionDigits:2})}`;
const fmtDT = s => { if(!s)return"—"; const d=new Date(s); return d.toLocaleDateString("es-MX",{day:"2-digit",month:"short",year:"numeric"})+" "+d.toLocaleTimeString("es-MX",{hour:"2-digit",minute:"2-digit"}); };

const mkInpS = (C) => ({ width:"100%", boxSizing:"border-box", padding:"9px 12px", borderRadius:8, border:`1px solid ${C.border}`, background:C.card, color:C.text, fontSize:13, outline:"none" });
const mkLabelS = (C) => ({ color:C.textMid, fontSize:11, fontWeight:700, display:"block", marginBottom:4 });
const mkBtnPrimary = (C) => ({ padding:"9px 20px", borderRadius:8, border:"none", background:BRAND.gradient, color:"#fff", fontWeight:700, fontSize:13, cursor:"pointer" });
const mkBtnOutline = (C) => ({ padding:"9px 20px", borderRadius:8, border:`1px solid ${C.border}`, background:"transparent", color:C.textMid, fontWeight:700, fontSize:13, cursor:"pointer" });
const btnSmall = (col) => ({ padding:"4px 10px", borderRadius:6, border:`1px solid ${col}30`, background:col+"15", color:col, cursor:"pointer", fontSize:11, fontWeight:700 });

const estCol = (e, C) => e==="aprobada"?C.green:e==="rechazada"?C.red:C.amber;

// ── Modal Nueva Devolución ────────────────────────────────────
export function NuevaDevolucionModal({ usuario, onClose, onSaved, initialQuery = "" }) {
  const C = C_LIGHT;
  const labelS = mkLabelS(C);
  const inpS = mkInpS(C);
  const btnPrimary = mkBtnPrimary(C);
  const btnOutline = mkBtnOutline(C);
  const [step,      setStep]    = useState(1);
  const [busqPed,   setBusqPed] = useState(() => String(initialQuery || "").trim());
  const [pedidos,   setPedidos] = useState([]);
  const [buscado,   setBuscado] = useState(false);
  const [buscando,  setBuscando]= useState(false);
  const [pedSel,    setPedSel]  = useState(null);
  const [items,     setItems]   = useState([]);
  const [selItems,  setSelItems]= useState({});
  const [motivo,    setMotivo]  = useState("");
  const [tipo,      setTipo]    = useState("reembolso");
  const [metodo,    setMetodo]  = useState("efectivo");
  const [cobroDiff, setCobroDiff] = useState("efectivo");
  const [presente,  setPresente]= useState(true);
  const [telCredito,setTelCredito] = useState("");
  const [nuevos,    setNuevos]  = useState([]);
  const [busqProd,  setBusqProd]= useState("");
  const [hitsProd,  setHitsProd]= useState([]);
  const [scanRaw, setScanRaw] = useState("");
  const [scanProd, setScanProd] = useState(null);
  const [scanPendientes, setScanPendientes] = useState([]);
  const [scanAmbiguo, setScanAmbiguo] = useState(false);
  const scanLastKeyTs = useRef(0);
  const scanPendientesRef = useRef([]);
  const [notas,     setNotas]   = useState("");
  const [saving,    setSaving]  = useState(false);
  const [error,     setError]   = useState("");

  const buscarPedido = async (qOverride) => {
    const q = String(qOverride ?? busqPed).trim();
    if (!q) return;
    setBuscando(true);
    setError("");
    const tok = sessionStorage.getItem("farmacapital_session_token");
    const { data } = tok
      ? await supabase.rpc("empleado_buscar_pedidos_devolucion", {
          p_session_token: tok,
          p_busqueda: queryRpcDevolucion(q),
          p_limite: 10,
        })
      : { data: [] };
    setPedidos(Array.isArray(data) ? data : []);
    setBuscado(true);
    setBuscando(false);
  };

  useEffect(() => {
    const q = String(initialQuery || "").trim();
    if (q) buscarPedido(q);
    // Solo al abrir con folio/teléfono ya capturado (POS).
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [initialQuery]);

  const anotarPendiente = (producto) => {
    if (!producto?.id) return {};
    const prev = scanPendientesRef.current;
    const i = prev.findIndex((x) => String(x.id) === String(producto.id));
    const next = i >= 0
      ? prev.map((x, idx) => idx === i ? { ...x, n: x.n + 1 } : x)
      : [...prev, { id: producto.id, n: 1, nombre: producto.nombre }];
    scanPendientesRef.current = next;
    setScanPendientes(next);
    const m = {};
    next.forEach((s) => { m[String(s.id)] = s.n; });
    return m;
  };

  const selPedido = (p, extraMap) => {
    setPedSel(p);
    const lines = p.pedido_items || [];
    setItems(lines);
    const extra = extraMap || {};
    const init = {};
    lines.forEach((i) => {
      const pid = String(i.productos?.id ?? "");
      const n = extra[pid];
      init[i.id] = n ? Math.min(i.cantidad, n) : 0;
    });
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

  const identificarProducto = async (raw) => {
    const tok = sessionStorage.getItem("farmacapital_session_token");
    if (!tok) return null;
    const code = normalizeBarcodeRaw(raw) || String(raw || "").trim();
    const { data } = await supabase.rpc("empleado_identificar_producto_codigo", {
      p_session_token: tok,
      p_codigo: code,
    });
    if (data && data.id) return data;
    const { data: list } = await supabase.rpc("empleado_buscar_productos_venta", {
      p_session_token: tok,
      p_busqueda: code,
      p_limite: 20,
    });
    const rows = Array.isArray(list) ? list : [];
    return findProductExactScan(rows, code, { activeOnly: false }) || null;
  };

  const agregarLineaEnTicket = (producto) => {
    const line = items.find((i) => String(i.productos?.id) === String(producto.id));
    if (!line) {
      setError("Ese producto no está en este ticket. Busca el folio o el teléfono.");
      return false;
    }
    setCantidad(line.id, (selItems[line.id] || 0) + 1, line.cantidad);
    return true;
  };

  const agregarProductoNuevo = (producto) => {
    setNuevos((prev) => {
      const i = prev.findIndex((x) => String(x.id) === String(producto.id));
      if (i >= 0) return prev.map((x, idx) => idx === i ? { ...x, qty: x.qty + 1 } : x);
      return [...prev, { id: producto.id, nombre: producto.nombre, precio: producto.precio, qty: 1 }];
    });
    setBusqProd("");
    setHitsProd([]);
  };

  const procesarScan = async (raw) => {
    const code = normalizeBarcodeRaw(raw) || String(raw || "").trim();
    if (!code) return;
    setError("");
    setBuscando(true);
    try {
      const prod = await identificarProducto(code);
      if (!prod) {
        setScanAmbiguo(true);
        setError("No reconocí ese código. Pide el folio o el teléfono.");
        return;
      }
      setScanProd(prod);
      setScanRaw("");

      if (step === 2 && pedSel && tipo === "cambio_producto") {
        agregarProductoNuevo(prod);
        return;
      }
      if (step === 2 && pedSel) {
        agregarLineaEnTicket(prod);
        return;
      }

      anotarPendiente(prod);
      const tok = sessionStorage.getItem("farmacapital_session_token");
      const { data, error } = tok
        ? await supabase.rpc("empleado_buscar_venta_reciente_por_producto", {
            p_session_token: tok,
            p_producto_id: prod.id,
            p_dias: 15,
          })
        : { data: [], error: null };
      if (error) throw error;
      const ventas = Array.isArray(data) ? data : [];
      setPedidos(ventas);
      setBuscado(true);
      setScanAmbiguo(ventas.length !== 1);
    } catch (e) {
      setScanAmbiguo(true);
      setError(e.message || "No se pudo buscar esa venta");
    } finally {
      setBuscando(false);
    }
  };

  useHidBarcodeWedge({
    enabled: true,
    onScan: (raw) => { void procesarScan(raw); },
  });

  const totalDevolver = items.reduce((a,i) => a + (selItems[i.id]||0) * i.precio_unitario, 0);
  const itemsSel = items.filter(i=>(selItems[i.id]||0)>0);
  const totalNuevo = nuevos.reduce((a, p) => a + (p.qty || 0) * (p.precio || 0), 0);
  const diferencia = tipo === "cambio_producto" ? totalNuevo - totalDevolver : 0;
  const necesitaTel = (metodo === "credito" || (tipo === "cambio_producto" && diferencia > 0 && cobroDiff === "credito"))
    && !pedSel?.clientes?.telefono && !pedSel?.cliente_id;

  useEffect(() => {
    const q = String(busqProd || "").trim();
    if (q.length < 2) { setHitsProd([]); return; }
    const t = setTimeout(async () => {
      const tok = sessionStorage.getItem("farmacapital_session_token");
      if (!tok) return;
      const { data } = await supabase.rpc("empleado_buscar_productos_venta", {
        p_session_token: tok,
        p_busqueda: q,
        p_limite: 12,
      });
      setHitsProd(Array.isArray(data) ? data : []);
    }, 280);
    return () => clearTimeout(t);
  }, [busqProd]);

  const guardar = async () => {
    if (!itemsSel.length) { setError("Selecciona al menos un producto."); return; }
    if (!motivo) { setError("Indica el motivo de la devolución."); return; }
    if (tipo === "cambio_producto" && !nuevos.length) {
      setError("Agrega el producto que se lleva el cliente."); return;
    }
    if (necesitaTel && String(telCredito).replace(/\D/g, "").length < 10) {
      setError("Para crédito hace falta el teléfono a 10 dígitos."); return;
    }
    setSaving(true); setError("");
    try {
      const tok = sessionStorage.getItem("farmacapital_session_token");
      if (!tok) { setError("Sesión expirada. Inicia sesión de nuevo."); setSaving(false); return; }

      const payloadItems = itemsSel.map(i => ({
        pedido_item_id:  i.id,
        producto_id:     i.productos?.id || null,
        producto_nombre: i.productos?.nombre || "Producto",
        lote_id:         i.lote_id || null,
        cantidad:        selItems[i.id],
        precio_unitario: i.precio_unitario,
      }));
      const payloadNuevos = nuevos.map((p) => ({
        producto_id: p.id,
        cantidad: p.qty,
      }));

      const payload = {
        p_session_token:    tok,
        p_pedido_id:        pedSel.id,
        p_motivo:           motivo,
        p_metodo_reembolso: metodo,
        p_items:            payloadItems,
        p_notas:            notas || null,
        p_tipo:             tipo,
        p_items_nuevos:     payloadNuevos,
        p_cliente_presente: presente,
        p_telefono_credito: telCredito || null,
        p_metodo_cobro_diferencia: cobroDiff,
      };
      let { data: resp, error: rpcErr } = await supabase.rpc("crear_devolucion", payload);
      if (rpcErr && /could not find|schema cache|does not exist/i.test(rpcErr.message || "")) {
        ({ data: resp, error: rpcErr } = await supabase.rpc("crear_devolucion", {
          p_session_token: tok,
          p_pedido_id: pedSel.id,
          p_motivo: motivo,
          p_metodo_reembolso: metodo,
          p_items: payloadItems,
          p_notas: notas || null,
        }));
      }

      if (rpcErr) throw rpcErr;
      if (!resp?.success) throw new Error(resp?.error || "Error al crear devolución");

      if (resp.estado === "pendiente") {
        showToast("Quedó pendiente: un admin la aprueba. No se entregó dinero ni se movió inventario.", "warning");
      } else if (resp.monto_efectivo > 0) {
        showToast(`Entrega ${fmt(resp.monto_efectivo)} en efectivo. El corte lo va a restar.`, "success");
      } else if (resp.monto_credito > 0) {
        showToast(`Crédito ${fmt(resp.monto_credito)} en el teléfono del cliente.`, "success");
      }
      onSaved(resp);
    } catch(e) { setError("Error al guardar: "+e.message); }
    setSaving(false);
  };

  return (
    <div style={{position:"fixed",inset:0,background:"rgba(15,23,42,.45)",backdropFilter:"blur(4px)",zIndex:500,display:"flex",alignItems:"center",justifyContent:"center",padding:20}}
      onClick={e=>e.target===e.currentTarget&&onClose()}>
      <div style={{background:C.card,borderRadius:14,width:"min(680px,95vw)",maxHeight:"90vh",overflowY:"auto",padding:28,boxShadow:"0 20px 60px rgba(0,82,204,.15)"}}>
        <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:20}}>
          <h3 style={{margin:0,color:C.text,fontSize:16,fontWeight:800}}>↩️ Nueva Devolución</h3>
          <button type="button" onClick={onClose} aria-label="Cerrar" style={{background:"none",border:"none",color:C.textMid,fontSize:22,cursor:"pointer",width:36,height:36}}>✕</button>
        </div>

        {/* Step 1: Buscar pedido */}
        {step===1&&(
          <div>
            <label style={labelS}>ESCANEA EL PRODUCTO QUE DEVUELVE</label>
            <p style={{margin:"0 0 10px",color:C.textMid,fontSize:12,lineHeight:1.45}}>
              La pistola identifica el producto. El sistema busca si se vendió aquí en los últimos 15 días, con el precio y el lote de esa venta — no basta el código de barras.
            </p>
            <div style={{display:"flex",gap:8,marginBottom:12}}>
              <input
                className="farmacapital-pos-srch"
                style={{...inpS,flex:1,fontFamily:"ui-monospace,monospace"}}
                value={scanRaw}
                onChange={(e)=>{
                  const now = Date.now();
                  const next = e.target.value;
                  if (shouldReplaceScanInput(scanRaw, scanLastKeyTs.current, now)) {
                    setScanRaw(normalizeBarcodeRaw(next.slice(-14)) || next);
                  } else {
                    setScanRaw(next);
                  }
                  scanLastKeyTs.current = now;
                }}
                onKeyDown={(e)=>{
                  if (e.key==="Enter") {
                    e.preventDefault();
                    void procesarScan(scanRaw);
                  }
                }}
                placeholder="Apunta la pistola al EAN"
                autoFocus
                autoComplete="off"
              />
              <button type="button" style={btnPrimary} onClick={()=>procesarScan(scanRaw)} disabled={buscando || !scanRaw.trim()}>
                {buscando ? "Buscando…" : "Escanear"}
              </button>
            </div>
            {scanProd&&(
              <div style={{background:BRAND.primary+"10",border:`1px solid ${BRAND.primary}30`,borderRadius:8,padding:"10px 12px",marginBottom:12,fontSize:12}}>
                Escaneaste: <strong>{scanProd.nombre}</strong>
                {scanProd.sku ? ` · ${scanProd.sku}` : ""}
              </div>
            )}

            {pedidos.length===1 && !scanAmbiguo && (
              <div style={{marginBottom:16}}>
                <p style={{margin:"0 0 8px",color:C.text,fontSize:13,lineHeight:1.45}}>
                  Encontramos que se compró el {fmtDT(pedidos[0].created_at)} en el ticket{" "}
                  <strong>{formatFolioPOS(pedidos[0].id)}</strong>
                  {pedidos[0].clientes?.nombre ? ` · ${pedidos[0].clientes.nombre}` : ""}.
                  ¿Es correcto?
                </p>
                <button type="button" onClick={()=>{
                  const extra = {};
                  scanPendientesRef.current.forEach((s)=>{ extra[String(s.id)] = s.n; });
                  selPedido(pedidos[0], extra);
                }} style={{...btnPrimary,width:"100%"}}>
                  Sí, es esta venta · {fmt(pedidos[0].total)}
                </button>
              </div>
            )}

            {(scanAmbiguo || pedidos.length>1) && pedidos.length>0 && (
              <p style={{margin:"0 0 8px",color:C.textMid,fontSize:12,lineHeight:1.4}}>
                Hay varias ventas con ese producto. Elige la correcta, o busca por folio o teléfono.
              </p>
            )}
            {buscado && pedidos.length===0 && !buscando && scanProd && (
              <div style={{color:C.textMid,fontSize:13,padding:"8px 0 12px",lineHeight:1.45}}>
                No hay una venta de ese producto en los últimos 15 días. Pide el folio del ticket o el celular — así confirmamos que se compró aquí.
              </div>
            )}

            <label style={labelS}>O BUSCA POR TICKET O TELÉFONO</label>
            <p style={{margin:"0 0 10px",color:C.textMid,fontSize:12,lineHeight:1.45}}>
              Folio (<strong>VTA-00000123</strong>) o celular a 10 dígitos. Sigue haciendo falta si el escaneo no calza con una sola venta.
            </p>
            <div style={{display:"flex",gap:8,marginBottom:16}}>
              <input
                style={{...inpS,flex:1}}
                value={busqPed}
                onChange={e=>setBusqPed(e.target.value)}
                onKeyDown={e=>e.key==="Enter"&&buscarPedido()}
                placeholder="VTA-00000123 o 55 3727 5035"
              />
              <button type="button" style={btnPrimary} onClick={()=>buscarPedido()} disabled={buscando || !busqPed.trim()}>
                {buscando ? "Buscando…" : "Buscar"}
              </button>
            </div>
            {pedidos.length>0&&!(pedidos.length===1 && !scanAmbiguo)&&(
              <div style={{display:"flex",flexDirection:"column",gap:8}}>
                {pedidos.map((p, idx)=>(
                  <button
                    type="button"
                    key={p.id}
                    onClick={()=>{
                      const extra = {};
                      scanPendientesRef.current.forEach((s)=>{ extra[String(s.id)] = s.n; });
                      selPedido(p, extra);
                    }}
                    style={{padding:14,borderRadius:10,border:`1px solid ${idx===0?BRAND.primary:C.border}`,cursor:"pointer",background:idx===0?BRAND.primary+"10":C.cardDark,textAlign:"left",font:"inherit"}}
                  >
                    <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",gap:8}}>
                      <span style={{fontWeight:700,color:C.text}}>{formatFolioPOS(p.id) || `Pedido #${p.id}`}</span>
                      <span style={{color:C.green,fontWeight:700}}>{fmt(p.total)}</span>
                    </div>
                    <div style={{color:C.textMid,fontSize:12,marginTop:4}}>
                      {idx===0 && pedidos.length>1 ? "Más reciente · " : ""}
                      {p.clientes?.nombre||"Sin cliente"}
                      {p.clientes?.telefono ? ` · ${p.clientes.telefono}` : ""}
                      {" · "}{fmtDT(p.created_at)}
                    </div>
                    {(p.pedido_items||[]).length>0&&(
                      <div style={{color:C.text,fontSize:12,marginTop:8,lineHeight:1.4}}>
                        {(p.pedido_items||[]).slice(0,4).map((it)=>(
                          <div key={it.id}>{it.productos?.nombre||"Producto"} ×{it.cantidad}</div>
                        ))}
                        {(p.pedido_items||[]).length>4 && (
                          <div style={{color:C.textMid,fontSize:11}}>+{(p.pedido_items||[]).length-4} más</div>
                        )}
                      </div>
                    )}
                  </button>
                ))}
              </div>
            )}
            {buscado&&pedidos.length===0&&!buscando&&!scanProd&&(
              <div style={{color:C.textMid,fontSize:13,textAlign:"center",padding:20}}>
                No hay una venta completada con ese dato. Prueba el folio del ticket o el celular con el que se cobró.
              </div>
            )}
            {error&&step===1&&<div style={{background:C.redDim,borderRadius:8,padding:"10px 12px",marginTop:12,color:C.red,fontSize:13}}>{error}</div>}
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
            <p style={{margin:"0 0 10px",color:C.textMid,fontSize:12,lineHeight:1.4}}>
              Puedes escanear otro producto de este mismo ticket para sumarlo, sin volver a buscar el folio.
            </p>
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
                <option value="Producto en mal estado">Producto en mal estado (error de farmacia)</option>
                <option value="Producto incorrecto">Producto incorrecto (error de farmacia)</option>
                <option value="Error en la venta">Error en la venta</option>
                <option value="Cobro duplicado">Cobro duplicado</option>
                <option value="Medicamento no necesario">Ya no lo necesita / se equivocó (sellado)</option>
                <option value="Otro">Otro</option>
              </select>
            </div>
            <div style={{marginBottom:12}}>
              <label style={labelS}>QUÉ HACE EL CLIENTE</label>
              <div style={{display:"flex",gap:8,flexWrap:"wrap"}}>
                {[["reembolso","Le regresamos el dinero o crédito"],["cambio_producto","Cambia por otro producto"]].map(([v,l])=>(
                  <button key={v} type="button" onClick={()=>setTipo(v)}
                    style={{padding:"8px 12px",borderRadius:8,border:`1px solid ${tipo===v?BRAND.primary:C.border}`,background:tipo===v?BRAND.primary+"14":"transparent",color:tipo===v?BRAND.primary:C.textMid,fontSize:12,fontWeight:700,cursor:"pointer"}}>
                    {l}
                  </button>
                ))}
              </div>
            </div>
            {tipo==="cambio_producto"&&(
              <div style={{marginBottom:14,padding:12,borderRadius:10,border:`1px solid ${C.border}`,background:C.cardDark}}>
                <label style={labelS}>PRODUCTO QUE SE LLEVA</label>
                <p style={{margin:"0 0 8px",color:C.textMid,fontSize:12}}>Escanea el producto nuevo o búscalo por nombre.</p>
                <input className="farmacapital-pos-srch" style={inpS} value={busqProd}
                  onChange={e=>setBusqProd(e.target.value)}
                  onKeyDown={(e)=>{
                    if (e.key!=="Enter") return;
                    const v = e.target.value;
                    if (looksLikeBarcodeInput(v) || looksLikeInternalSku(v)) {
                      e.preventDefault();
                      void procesarScan(v);
                    }
                  }}
                  placeholder="Pistola, nombre, SKU o EAN…"/>
                {hitsProd.length>0&&(
                  <div style={{marginTop:8,display:"flex",flexDirection:"column",gap:6,maxHeight:160,overflowY:"auto"}}>
                    {hitsProd.map(p=>(
                      <button key={p.id} type="button"
                        onClick={()=>{
                          setNuevos((prev)=>{
                            const i = prev.findIndex(x=>x.id===p.id);
                            if (i>=0) return prev.map((x,idx)=>idx===i?{...x,qty:x.qty+1}:x);
                            return [...prev,{id:p.id,nombre:p.nombre,precio:p.precio,qty:1}];
                          });
                          setBusqProd(""); setHitsProd([]);
                        }}
                        style={{textAlign:"left",padding:"8px 10px",borderRadius:8,border:`1px solid ${C.border}`,background:C.card,cursor:"pointer",font:"inherit"}}>
                        <div style={{fontWeight:700,fontSize:12,color:C.text}}>{p.nombre}</div>
                        <div style={{fontSize:11,color:C.textMid}}>{fmt(p.precio)} · stock {p.stock}</div>
                      </button>
                    ))}
                  </div>
                )}
                {nuevos.map(p=>(
                  <div key={p.id} style={{display:"flex",alignItems:"center",gap:8,marginTop:8}}>
                    <div style={{flex:1,fontSize:12,fontWeight:600}}>{p.nombre}</div>
                    <button type="button" onClick={()=>setNuevos(n=>n.map(x=>x.id===p.id?{...x,qty:Math.max(1,x.qty-1)}:x))}
                      style={{width:24,height:24,borderRadius:4,border:`1px solid ${C.border}`,background:"none",cursor:"pointer"}}>−</button>
                    <span style={{fontWeight:700,minWidth:16,textAlign:"center"}}>{p.qty}</span>
                    <button type="button" onClick={()=>setNuevos(n=>n.map(x=>x.id===p.id?{...x,qty:x.qty+1}:x))}
                      style={{width:24,height:24,borderRadius:4,border:`1px solid ${C.border}`,background:"none",cursor:"pointer"}}>+</button>
                    <span style={{fontWeight:700,minWidth:56,textAlign:"right"}}>{fmt(p.qty*p.precio)}</span>
                    <button type="button" onClick={()=>setNuevos(n=>n.filter(x=>x.id!==p.id))}
                      style={{background:"none",border:"none",color:C.red,cursor:"pointer"}}>×</button>
                  </div>
                ))}
                {totalDevolver>0&&nuevos.length>0&&(
                  <div style={{marginTop:10,fontSize:12,color:C.textMid}}>
                    Devuelve {fmt(totalDevolver)} · se lleva {fmt(totalNuevo)} ·{" "}
                    <strong style={{color:diferencia===0?C.green:diferencia>0?C.blue:C.amber}}>
                      {diferencia===0?"cambio parejo":diferencia>0?`cliente paga ${fmt(diferencia)}`:`regresamos ${fmt(Math.abs(diferencia))}`}
                    </strong>
                  </div>
                )}
              </div>
            )}
            {!(tipo==="cambio_producto" && diferencia===0)&&(
            <div style={{marginBottom:12}}>
              <label style={labelS}>
                {tipo==="cambio_producto" && diferencia>0 ? "CÓMO PAGA LA DIFERENCIA" : "CÓMO SE LO REGRESAMOS"}
              </label>
              <p style={{margin:"0 0 8px",color:C.textMid,fontSize:12,lineHeight:1.4}}>
                El cliente elige. Crédito no sale del cajón; efectivo sí, y el corte lo resta aunque la venta original haya sido con terminal.
              </p>
              <select style={inpS}
                value={tipo==="cambio_producto" && diferencia>0 ? cobroDiff : metodo}
                onChange={e=>{
                  if (tipo==="cambio_producto" && diferencia>0) setCobroDiff(e.target.value);
                  else setMetodo(e.target.value);
                }}>
                <option value="efectivo">Efectivo</option>
                <option value="credito">Crédito FarmaCapital (en su teléfono)</option>
                {tipo==="cambio_producto" && diferencia>0 && (
                  <option value="tarjeta">Terminal (cobras la diferencia en Point/BBVA)</option>
                )}
              </select>
            </div>
            )}
            {necesitaTel&&(
              <div style={{marginBottom:12}}>
                <label style={labelS}>TELÉFONO PARA EL CRÉDITO *</label>
                <input style={inpS} value={telCredito} onChange={e=>setTelCredito(e.target.value)}
                  placeholder="10 dígitos" inputMode="tel"/>
              </div>
            )}
            <label style={{display:"flex",alignItems:"center",gap:8,marginBottom:12,fontSize:12,color:C.text,cursor:"pointer"}}>
              <input type="checkbox" checked={presente} onChange={e=>setPresente(e.target.checked)}/>
              El cliente está en el mostrador con el ticket
            </label>
            <div style={{marginBottom:16}}>
              <label style={labelS}>NOTAS (opcional)</label>
              <textarea value={notas} onChange={e=>setNotas(e.target.value)} rows={2}
                style={{...inpS,resize:"vertical"}} placeholder="Sello intacto, caducado, etc."/>
            </div>
            {totalDevolver>0&&tipo==="reembolso"&&(
              <div style={{background:C.greenDim,border:`1px solid ${C.green}30`,borderRadius:8,padding:"12px 16px",marginBottom:16,display:"flex",justifyContent:"space-between",alignItems:"center"}}>
                <span style={{color:C.greenDark,fontWeight:700}}>
                  {metodo==="credito"?"Crédito a abonar:":"Efectivo a entregar:"}
                </span>
                <span style={{color:C.green,fontWeight:900,fontSize:20}}>{fmt(totalDevolver)}</span>
              </div>
            )}
            {totalDevolver>800&&(
              <div style={{background:C.amber+"18",borderRadius:8,padding:"10px 12px",marginBottom:12,color:C.amber,fontSize:12,lineHeight:1.4}}>
                Arriba de $800 queda pendiente de un admin. No entregues dinero hasta que la aprueben.
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
  const C = C_LIGHT;
  const inpS = mkInpS(C);
  const labelS = mkLabelS(C);
  const btnPrimary = mkBtnPrimary(C);
  const btnOutline = mkBtnOutline(C);
  const [devoluciones, setDev]    = useState([]);
  const [loading,      setLoad]   = useState(true);
  const [modal,        setModal]  = useState(false);
  const [filtro,       setFiltro] = useState("todos");
  const [busq,         setBusq]   = useState("");

  const esAdmin = rolEsAdmin(usuario?.rol);

  const fetch = useCallback(async () => {
    setLoad(true);
    const tok = sessionStorage.getItem("farmacapital_session_token");
    const { data } = tok
      ? await supabase.rpc("empleado_listar_devoluciones", { p_session_token: tok, p_limite: 100 })
      : { data: [] };
    setDev(Array.isArray(data) ? data : []);
    setLoad(false);
  },[]);

  useEffect(()=>{ fetch(); },[fetch]);

  const resolver = async (d, accion) => {
    const tok = sessionStorage.getItem("farmacapital_session_token");
    if (!tok) { showToast("Sesión expirada", "warning"); return; }
    try {
      if (accion === "aprobar") {
        const { error } = await supabase.rpc("aprobar_devolucion", {
          p_session_token: tok, p_devolucion_id: d.id,
        });
        if (error) throw error;
        showToast("Devolución aprobada. Ya se movió inventario y dinero.", "success");
      } else {
        const { error } = await supabase.rpc("rechazar_devolucion", {
          p_session_token: tok, p_devolucion_id: d.id, p_motivo: "Rechazada en mostrador",
        });
        if (error) throw error;
        showToast("Devolución rechazada. No se movió nada.", "success");
      }
      fetch();
    } catch (e) {
      showToast(e.message || "No se pudo resolver", "error");
    }
  };

  const fil = devoluciones.filter(d=>{
    const matchF = filtro==="todos" || d.estado===filtro;
    const matchB = !busq.trim() || d.id?.toString().includes(busq.trim()) || (d.clientes && productMatchesSearchQuery(d.clientes, busq, [(x) => x.nombre]));
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
          <div key={k.label} style={{background:C.card,border:`1px solid ${C.border}`,borderRadius:12,padding:"14px 16px",flex:"1 1 140px",minWidth:0}}>
            <div style={{color:C.textDim,fontSize:10,fontWeight:700,marginBottom:4}}>{k.label.toUpperCase()}</div>
            <div className="fc-kpi-value" style={{color:k.col,fontWeight:900,fontSize:22}}>{k.value}</div>
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
          <table className="fc-tabla-cards" style={{width:"100%",borderCollapse:"collapse",fontSize:12}}>
            <thead>
              <tr style={{background:C.cardDark}}>
                {["ID","Fecha","Cliente","Pedido orig.","Productos","Total","Método","Estado","Acciones"].map(h=>(
                  <th key={h} style={{padding:"9px 12px",textAlign:"left",color:C.textMid,fontWeight:700,borderBottom:`1px solid ${C.border}`,whiteSpace:"nowrap"}}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {!fil.length&&<tr><td colSpan={9} style={{textAlign:"center",padding:32,color:C.textMid}}>Sin devoluciones registradas</td></tr>}
              {fil.map((d,i)=>(
                <tr key={d.id} style={{background:i%2===0?"transparent":"#f8fafc"}}>
                  <td data-label="ID" data-primary style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`,fontFamily:"monospace"}}>#{d.id}</td>
                  <td data-label="Fecha" style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`,whiteSpace:"nowrap"}}>{fmtDT(d.created_at)}</td>
                  <td data-label="Cliente" style={{padding:"8px 12px",color:C.text,fontWeight:600,borderBottom:`1px solid ${C.border}`}}>{d.clientes?.nombre||"—"}</td>
                  <td data-label="Pedido" style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>#{d.pedido_id||"—"}</td>
                  <td data-label="Productos" data-wide style={{padding:"8px 12px",borderBottom:`1px solid ${C.border}`,maxWidth:180}}>
                    {(d.devolucion_items||[]).map((it,idx)=>(
                      <div key={idx} style={{color:C.text,fontSize:11}}>{it.producto_nombre} ×{it.cantidad}</div>
                    ))}
                  </td>
                  <td data-label="Total" className="fc-nowrap-money" style={{padding:"8px 12px",color:C.red,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{fmt(d.total_devuelto)}</td>
                  <td data-label="Método" style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{d.metodo_reembolso||"—"}</td>
                  <td data-label="Estado" style={{padding:"8px 12px",borderBottom:`1px solid ${C.border}`}}>
                    <span style={{padding:"2px 8px",borderRadius:20,fontSize:10,fontWeight:700,background:estCol(d.estado, C)+"20",color:estCol(d.estado, C)}}>
                      {d.estado}
                    </span>
                  </td>
                  <td data-label="Acciones" data-actions style={{padding:"8px 12px",borderBottom:`1px solid ${C.border}`,whiteSpace:"nowrap"}}>
                    {d.estado==="pendiente" && esAdmin ? (
                      <div style={{display:"flex",gap:6}}>
                        <button type="button" onClick={()=>resolver(d,"aprobar")} style={btnSmall(C.green)}>Aprobar</button>
                        <button type="button" onClick={()=>resolver(d,"rechazar")} style={btnSmall(C.red)}>Rechazar</button>
                      </div>
                    ) : d.estado==="pendiente" ? (
                      <span style={{color:C.textDim,fontSize:11}}>Espera admin</span>
                    ) : "—"}
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
