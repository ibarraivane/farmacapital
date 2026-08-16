import { useState, useEffect, useCallback } from "react";
import { C_LIGHT } from "./constants";
import { supabase } from "./supabase";
import { showToast } from "./ui";
import OnboardingTour from "./components/OnboardingTour";

const BRAND = { primary:"#0D1B2A", secondary:"#1E3ABA", gradient:"linear-gradient(135deg,#0D1B2A,#1E3ABA)" };

const fmt  = (n) => `$${parseFloat(n||0).toFixed(2)}`;

const mkInputStyle = (C) => ({ width:"100%", padding:"9px 12px", borderRadius:8, border:`1px solid ${C.border}`, background:C.bg, color:C.text, fontSize:13, outline:"none", boxSizing:"border-box" });
const mkLabelStyle = (C) => ({ color:C.textMid, fontSize:11, fontWeight:700, marginBottom:4, display:"block", letterSpacing:.5 });
const mkBtnSecondary = (C) => ({ padding:"10px 22px", borderRadius:8, cursor:"pointer", fontWeight:700, fontSize:13, border:`1px solid ${C.border}`, background:"transparent", color:C.textMid });

const getRango = (turno) => {
  const hoy = new Date();
  const y = hoy.getFullYear(), m = hoy.getMonth(), d = hoy.getDate();
  if (turno === "matutino") return { inicio: new Date(y,m,d,8,0,0).toISOString(), fin: new Date(y,m,d,15,59,59).toISOString() };
  return { inicio: new Date(y,m,d,16,0,0).toISOString(), fin: new Date(y,m,d,21,59,59).toISOString() };
};

const getRangoFiltro = (filtro) => {
  const hoy = new Date();
  const y = hoy.getFullYear(), mo = hoy.getMonth(), d = hoy.getDate();
  if (filtro === "hoy")    return { desde: new Date(y,mo,d,0,0,0).toISOString(),  hasta: new Date(y,mo,d,23,59,59).toISOString() };
  if (filtro === "semana") { const l=new Date(hoy); l.setDate(d-hoy.getDay()); l.setHours(0,0,0); return { desde:l.toISOString(), hasta:hoy.toISOString() }; }
  if (filtro === "mes")    return { desde: new Date(y,mo,1).toISOString(), hasta: hoy.toISOString() };
  return null;
};

export default function CorteCajaModule({usuario }) {
  const C = C_LIGHT;
  const inputStyle = mkInputStyle(C);
  const labelStyle = mkLabelStyle(C);
  const btnSecondary = mkBtnSecondary(C);
  const [tab, setTab] = useState("nuevo");

  // Nuevo corte
  const [turno,              setTurno]   = useState("matutino");
  const [efectivo_declarado, setEfDec]   = useState("");
  const [tarjeta,            setTarjeta] = useState("");
  const [mercadopago,        setMp]      = useState("");
  const [notas,              setNotas]   = useState("");
  const [efectivo_sistema,   setEfSis]   = useState(0);
  const [loadingSis,         setLoadSis] = useState(false);
  const [saving,             setSaving]  = useState(false);
  const [saved,              setSaved]   = useState(false);
  const [resumenServicios,   setResumenServicios] = useState(null);

  // Historial
  const [cortes,      setCortes]      = useState([]);
  const [loadingHist, setLoadingHist] = useState(false);
  const [filtroTurno, setFiltroTurno] = useState("todos");
  const [filtroFecha, setFiltroFecha] = useState("todos");

  // Calculados
  const efDec   = parseFloat(efectivo_declarado||0);
  const tar     = parseFloat(tarjeta||0);
  const mp      = parseFloat(mercadopago||0);
  const diferencia    = efDec - efectivo_sistema;
  const total_general = efDec + tar + mp;

  const fetchEfectivoSistema = useCallback(async () => {
    setLoadSis(true);
    try {
      // RPC server-side para reconciliación correcta (normalizado)
      const { data:rpc, error:rpcErr } = await supabase.rpc("reconcile_shift_cash",{
        p_turno: turno,
        p_fecha: new Date().toLocaleDateString("sv-SE"),
      });
      if(!rpcErr && rpc?.efectivo_sistema !== undefined) {
        setEfSis(rpc.efectivo_sistema);
        // Tarjeta y MercadoPago los conoce el sistema con exactitud (no se cuentan
        // físicamente), así que se autocompletan desde el RPC. Siguen siendo editables.
        if (rpc.tarjeta != null)     setTarjeta(String(rpc.tarjeta));
        if (rpc.mercadopago != null) setMp(String(rpc.mercadopago));
      } else {
        const tok = sessionStorage.getItem("farmacapital_session_token");
        const { inicio, fin } = getRango(turno);
        const { data: ej } = tok
          ? await supabase.rpc("empleado_sum_efectivo_pedidos_rango", {
              p_session_token: tok,
              p_desde: inicio,
              p_hasta: fin,
            })
          : { data: null };
        const sum = ej?.efectivo_sistema != null ? parseFloat(ej.efectivo_sistema) : 0;
        if (Number.isFinite(sum)) setEfSis(sum);
      }
    } catch(e) { console.error("[CorteCaja]", e); }
    setLoadSis(false);
  }, [turno]);

  useEffect(() => { fetchEfectivoSistema(); }, [fetchEfectivoSistema]);

  const fetchResumenServicios = useCallback(async () => {
    try {
      const tok = sessionStorage.getItem("farmacapital_session_token");
      const { inicio, fin } = getRango(turno);
      const { data, error } = tok
        ? await supabase.rpc("empleado_resumen_pagos_servicio_rango", {
            p_session_token: tok,
            p_desde: inicio,
            p_hasta: fin,
          })
        : { data: null, error: null };
      if (!error && data) setResumenServicios(data);
    } catch (e) {
      console.error("[CorteCaja servicios]", e);
    }
  }, [turno]);

  useEffect(() => { fetchResumenServicios(); }, [fetchResumenServicios]);

  const fetchCortes = useCallback(async () => {
    setLoadingHist(true);
    const tok = sessionStorage.getItem("farmacapital_session_token");
    const rango = getRangoFiltro(filtroFecha);
    const fd = rango ? rango.desde.slice(0, 10) : null;
    const fh = rango ? rango.hasta.slice(0, 10) : null;
    const { data: rows, error } = tok
      ? await supabase.rpc("empleado_listar_cortes_caja", {
          p_session_token: tok,
          p_limite: 30,
          p_fecha_desde: fd,
          p_fecha_hasta: fh,
          p_turno: filtroTurno,
        })
      : { data: [], error: null };
    if (!error) setCortes(Array.isArray(rows) ? rows : []);
    setLoadingHist(false);
  }, [filtroFecha, filtroTurno]);

  useEffect(() => { if (tab==="historial") fetchCortes(); }, [tab, fetchCortes]);

  // P3.4: Función para verificar si hay turno activo (usada desde POS)
  // Esta función se puede llamar externamente via ref o contexto
  const verificarTurnoActivo = async () => {
    const tok = sessionStorage.getItem("farmacapital_session_token");
    const hoy = new Date().toLocaleDateString("sv-SE");
    const { data } = tok
      ? await supabase.rpc("empleado_corte_turno_en_fecha", {
          p_session_token: tok,
          p_fecha: hoy,
          p_turno: turno,
        })
      : { data: null };
    return !!(data?.existe);
  };

  const guardarCorte = async () => {
    if (!efectivo_declarado) { alert("Ingresa el efectivo declarado"); return; }
    const tok = sessionStorage.getItem("farmacapital_session_token");
    if (!tok) { alert("Sesión expirada. Inicia sesión de nuevo."); return; }
    // J8: Validar turno duplicado
    const hoy = new Date().toLocaleDateString("sv-SE");
    const { data: exSnap } = await supabase.rpc("empleado_corte_turno_en_fecha", {
      p_session_token: tok,
      p_fecha: hoy,
      p_turno: turno,
    });
    if (exSnap?.existe) {
      const ok = window.confirm(`Ya existe un corte del turno ${turno} de hoy. ¿Guardar otro de todas formas?`);
      if (!ok) return;
    }
    setSaving(true);
    const { error } = await supabase.rpc("registrar_corte_caja", {
      p_session_token: tok,
      p_turno: turno,
      p_efectivo_declarado: efDec,
      p_efectivo_sistema: efectivo_sistema,
      p_tarjeta: tar,
      p_mercadopago: mp,
      p_diferencia: diferencia,
      p_total_general: total_general,
      p_notas: notas.trim() || null,
    });
    setSaving(false);
    if (error) { showToast("Error al guardar corte: "+error.message, "error"); return; }
    setSaved(true);
    setEfDec(""); setTarjeta(""); setMp(""); setNotas("");
    setTimeout(()=>setSaved(false), 3500);
    fetchEfectivoSistema();
  };

  const difCol = diferencia===0 ? C.green : diferencia>0 ? C.amber : C.red;
  const difTxt = diferencia===0 ? "✓ Cuadrado" : diferencia>0 ? `▲ Sobrante: +${fmt(diferencia)}` : `▼ Faltante: ${fmt(diferencia)}`;
  const difBg  = diferencia===0 ? C.greenDim : diferencia>0 ? C.amberDim : C.redDim;

  const sumEf  = cortes.reduce((a,c)=>a+parseFloat(c.efectivo_declarado||0),0);
  const sumTar = cortes.reduce((a,c)=>a+parseFloat(c.tarjeta||0),0);
  const sumMp  = cortes.reduce((a,c)=>a+parseFloat(c.mercadopago||0),0);
  const sumTot = cortes.reduce((a,c)=>a+parseFloat(c.total_general||0),0);

  return (
    <div style={{padding:24,background:C.bg,minHeight:"100dvh",fontFamily:"'Plus Jakarta Sans',sans-serif"}}>

      <div style={{marginBottom:24}}>
        <h1 style={{margin:0,color:C.text,fontSize:20,fontWeight:800}}>⊞ Corte de Caja</h1>
        <p style={{margin:"4px 0 0",color:C.textMid,fontSize:12}}>Control de turnos · FarmaCapital</p>
      </div>

      {/* Tabs */}
      <div style={{display:"flex",gap:4,marginBottom:24,borderBottom:`1px solid ${C.border}`}}>
        {[["nuevo","➕ Nuevo Corte"],["historial","📋 Historial"]].map(([id,label])=>(
          <button key={id} onClick={()=>setTab(id)} style={{
            padding:"9px 20px",border:"none",cursor:"pointer",fontWeight:700,fontSize:13,
            borderRadius:"8px 8px 0 0", background:tab===id?C.card:"transparent",
            color:tab===id?C.blue:C.textMid,
            borderBottom:tab===id?`2px solid ${C.blue}`:"2px solid transparent",
          }}>{label}</button>
        ))}
      </div>

      {/* ══ NUEVO CORTE ══ */}
      {tab==="nuevo" && (
        <div>
          {saved && (
            <div style={{background:C.greenDim,border:`1px solid ${C.green}40`,borderRadius:10,
              padding:"12px 18px",marginBottom:20,color:C.green,fontWeight:700,fontSize:14}}>
              ✅ Corte guardado correctamente
            </div>
          )}

          {/* Selector turno */}
          <div data-tour="caja-turno" style={{marginBottom:24}}>
            <label style={labelStyle}>TURNO</label>
            <div style={{display:"flex",gap:10}}>
              {[["matutino","🌅 Matutino","8:00 – 16:00h"],["vespertino","🌆 Vespertino","16:00 – 22:00h"]].map(([val,label,hora])=>(
                <button key={val} onClick={()=>setTurno(val)} style={{
                  flex:1,padding:"14px 20px",borderRadius:10,cursor:"pointer",textAlign:"left",
                  border:turno===val?`2px solid ${C.blue}`:`2px solid ${C.border}`,
                  background:turno===val?C.blueDim:C.card,
                  color:turno===val?C.blue:C.textMid,transition:"all .15s",
                }}>
                  <div style={{fontWeight:800,fontSize:14}}>{label}</div>
                  <div style={{fontSize:11,marginTop:2,opacity:.7}}>{hora}</div>
                </button>
              ))}
            </div>
          </div>

          {/* Grid */}
          <div style={{display:"grid",gridTemplateColumns:"1fr 1fr",gap:20}}>

            {/* Inputs */}
            <div data-tour="caja-declarado" style={{background:C.card,borderRadius:12,border:`1px solid ${C.border}`,padding:20}}>
              <div style={{color:C.text,fontWeight:800,fontSize:14,marginBottom:16}}>💵 Ingresos del turno</div>

              <div style={{marginBottom:14}}>
                <label style={labelStyle}>EFECTIVO DECLARADO</label>
                <input type="number" value={efectivo_declarado} onChange={e=>setEfDec(e.target.value)}
                  placeholder="0.00" style={{...inputStyle,fontSize:18,fontWeight:700,color:C.green}}/>
                <div style={{color:C.textDim,fontSize:10,marginTop:4}}>Lo que cuenta físicamente el cajero</div>
              </div>

              <div style={{marginBottom:14}}>
                <label style={labelStyle}>TARJETA</label>
                <input type="number" value={tarjeta} onChange={e=>setTarjeta(e.target.value)} placeholder="0.00" style={inputStyle}/>
              </div>

              <div style={{marginBottom:14}}>
                <label style={labelStyle}>MERCADOPAGO</label>
                <input type="number" value={mercadopago} onChange={e=>setMp(e.target.value)} placeholder="0.00" style={inputStyle}/>
              </div>

              <div>
                <label style={labelStyle}>NOTAS</label>
                <textarea value={notas} onChange={e=>setNotas(e.target.value)}
                  placeholder="Observaciones del turno, incidencias, etc."
                  rows={3} style={{...inputStyle,resize:"vertical",lineHeight:1.5}}/>
              </div>
            </div>

            {/* Resumen */}
            <div style={{display:"flex",flexDirection:"column",gap:12}}>

              <div style={{background:C.card,borderRadius:12,border:`1px solid ${C.border}`,padding:20}}>
                <div style={{color:C.textMid,fontSize:11,fontWeight:700,letterSpacing:.5,marginBottom:8}}>EFECTIVO EN SISTEMA</div>
                <div style={{color:C.blue,fontWeight:800,fontSize:28}}>{loadingSis?"…":fmt(efectivo_sistema)}</div>
                <div style={{color:C.textDim,fontSize:11,marginTop:4}}>Ventas en efectivo · turno {turno}</div>
              </div>

              {resumenServicios?.operaciones > 0 && (
                <div style={{background:C.amberDim,borderRadius:12,border:`1px solid ${C.amber}35`,padding:16}}>
                  <div style={{color:C.amber,fontSize:11,fontWeight:700,letterSpacing:.5,marginBottom:6}}>PAGOS DE SERVICIO (POS)</div>
                  <div style={{color:C.text,fontSize:12,lineHeight:1.45}}>
                    {resumenServicios.operaciones} operación(es) · cobrado {fmt(resumenServicios.total_cobrado)} · comisión farmacia {fmt(resumenServicios.total_comision)}
                  </div>
                  <div style={{color:C.textDim,fontSize:10,marginTop:6}}>
                    Efectivo {fmt(resumenServicios.efectivo)} · Tarjeta Point {fmt(resumenServicios.tarjeta)} — inclúyelos en los campos de arriba al cerrar turno.
                  </div>
                </div>
              )}

              <div data-tour="caja-diferencia" style={{background:difBg,borderRadius:12,border:`1px solid ${difCol}30`,padding:20}}>
                <div style={{color:C.textMid,fontSize:11,fontWeight:700,letterSpacing:.5,marginBottom:8}}>DIFERENCIA</div>
                <div style={{color:difCol,fontWeight:800,fontSize:24}}>{difTxt}</div>
                <div style={{color:C.textDim,fontSize:11,marginTop:4}}>Declarado {fmt(efDec)} — Sistema {fmt(efectivo_sistema)}</div>
              </div>

              <div style={{background:C.card,borderRadius:12,border:`1px solid ${C.border}`,padding:20}}>
                <div style={{color:C.textMid,fontSize:11,fontWeight:700,letterSpacing:.5,marginBottom:12}}>DESGLOSE</div>
                {[["Efectivo",efDec,C.green],["Tarjeta",tar,C.blue],["MercadoPago",mp,C.amber]].map(([lbl,val,col])=>(
                  <div key={lbl} style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:8}}>
                    <span style={{color:C.textMid,fontSize:12}}>{lbl}</span>
                    <span style={{color:col,fontWeight:700,fontSize:13}}>{fmt(val)}</span>
                  </div>
                ))}
                <div style={{borderTop:`1px solid ${C.border}`,marginTop:8,paddingTop:10,display:"flex",justifyContent:"space-between",alignItems:"center"}}>
                  <span style={{color:C.text,fontWeight:800,fontSize:13}}>TOTAL GENERAL</span>
                  <span style={{fontWeight:800,fontSize:22,background:BRAND.gradient,WebkitBackgroundClip:"text",WebkitTextFillColor:"transparent"}}>
                    {fmt(total_general)}
                  </span>
                </div>
              </div>

              <button data-tour="caja-guardar" onClick={guardarCorte} disabled={saving||!efectivo_declarado} style={{
                width:"100%",padding:"14px",borderRadius:10,border:"none",cursor:"pointer",
                background:saving||!efectivo_declarado?C.border:C.green,
                color:"#fff",fontWeight:800,fontSize:15,transition:"all .2s",
                opacity:saving||!efectivo_declarado?.5:1,
              }}>
                {saving?"Guardando…":"💾 Guardar corte"}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* ══ HISTORIAL ══ */}
      {tab==="historial" && (
        <div>
          <div style={{display:"flex",gap:10,marginBottom:16,flexWrap:"wrap",alignItems:"center"}}>
            <select value={filtroTurno} onChange={e=>setFiltroTurno(e.target.value)} style={{...inputStyle,maxWidth:160}}>
              <option value="todos">Todos los turnos</option>
              <option value="matutino">🌅 Matutino</option>
              <option value="vespertino">🌆 Vespertino</option>
            </select>
            <select value={filtroFecha} onChange={e=>setFiltroFecha(e.target.value)} style={{...inputStyle,maxWidth:160}}>
              <option value="todos">Todo el período</option>
              <option value="hoy">Hoy</option>
              <option value="semana">Esta semana</option>
              <option value="mes">Este mes</option>
            </select>
            <button onClick={fetchCortes} style={{...btnSecondary,padding:"8px 14px",fontSize:12}}>🔄 Actualizar</button>
            <span style={{color:C.textMid,fontSize:11,marginLeft:"auto"}}>{cortes.length} corte{cortes.length!==1?"s":""}</span>
          </div>

          {loadingHist ? (
            <div style={{color:C.textMid,textAlign:"center",padding:40}}>Cargando historial…</div>
          ) : (
            <div style={{overflowX:"auto",borderRadius:12,border:`1px solid ${C.border}`}}>
              <table style={{width:"100%",borderCollapse:"collapse",fontSize:12}}>
                <thead>
                  <tr style={{background:C.card}}>
                    {["Fecha/Hora","Turno","Cajero","Ef. Declarado","Ef. Sistema","Diferencia","Tarjeta","MP","Total","Notas"].map(h=>(
                      <th key={h} style={{padding:"10px 12px",textAlign:"left",color:C.textMid,fontWeight:700,borderBottom:`1px solid ${C.border}`,whiteSpace:"nowrap"}}>{h}</th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {cortes.length===0&&(
                    <tr><td colSpan={10} style={{textAlign:"center",padding:32,color:C.textMid}}>Sin cortes en este período</td></tr>
                  )}
                  {cortes.map((c,i)=>{
                    const dif    = parseFloat(c.diferencia||0);
                    const dc     = dif===0?C.green:dif>0?C.amber:C.red;
                    const dt     = dif===0?"✓":dif>0?`▲ +${fmt(dif)}`:`▼ ${fmt(dif)}`;
                    const fecha  = new Date(c.fecha);
                    return (
                      <tr key={c.id||i} style={{background:i%2===0?"transparent":C.card+"80"}}>
                        <td style={{padding:"9px 12px",borderBottom:`1px solid ${C.border}`,whiteSpace:"nowrap"}}>
                          <div style={{fontWeight:600,color:C.text}}>{fecha.toLocaleDateString("es-MX")}</div>
                          <div style={{color:C.textMid,fontSize:10}}>{fecha.toLocaleTimeString("es-MX",{hour:"2-digit",minute:"2-digit"})}</div>
                        </td>
                        <td style={{padding:"9px 12px",borderBottom:`1px solid ${C.border}`}}>
                          <span style={{padding:"2px 8px",borderRadius:20,fontSize:10,fontWeight:700,
                            background:c.turno==="matutino"?C.blueDim:C.amberDim,
                            color:c.turno==="matutino"?C.blue:C.amber}}>
                            {c.turno==="matutino"?"🌅 Mat":"🌆 Vesp"}
                          </span>
                        </td>
                        <td style={{padding:"9px 12px",color:C.text,fontWeight:600,borderBottom:`1px solid ${C.border}`}}>{c.cajero||"—"}</td>
                        <td style={{padding:"9px 12px",color:C.green,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{fmt(c.efectivo_declarado)}</td>
                        <td style={{padding:"9px 12px",color:C.blue,borderBottom:`1px solid ${C.border}`}}>{fmt(c.efectivo_sistema)}</td>
                        <td style={{padding:"9px 12px",borderBottom:`1px solid ${C.border}`}}><span style={{color:dc,fontWeight:700}}>{dt}</span></td>
                        <td style={{padding:"9px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{fmt(c.tarjeta)}</td>
                        <td style={{padding:"9px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{fmt(c.mercadopago)}</td>
                        <td style={{padding:"9px 12px",color:C.text,fontWeight:800,borderBottom:`1px solid ${C.border}`}}>{fmt(c.total_general)}</td>
                        <td style={{padding:"9px 12px",color:C.textDim,fontSize:11,borderBottom:`1px solid ${C.border}`,maxWidth:130,overflow:"hidden",textOverflow:"ellipsis",whiteSpace:"nowrap"}}>{c.notas||"—"}</td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          )}

          {cortes.length>0&&(
            <div style={{marginTop:16,background:C.card,borderRadius:12,border:`1px solid ${C.border}`,padding:20}}>
              <div style={{color:C.text,fontWeight:800,fontSize:13,marginBottom:14}}>
                📊 Resumen del período — {cortes.length} corte{cortes.length!==1?"s":""}
              </div>
              <div style={{display:"flex",gap:12,flexWrap:"wrap"}}>
                {[["Efectivo",sumEf,C.green],["Tarjeta",sumTar,C.blue],["MercadoPago",sumMp,C.amber],["Gran total",sumTot,C.text]].map(([lbl,val,col])=>(
                  <div key={lbl} style={{background:C.bg,borderRadius:10,padding:"12px 18px",minWidth:130,border:`1px solid ${C.border}`}}>
                    <div style={{color:C.textMid,fontSize:10,fontWeight:700,marginBottom:4}}>{lbl.toUpperCase()}</div>
                    <div style={{color:col,fontWeight:800,fontSize:18}}>{fmt(val)}</div>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      )}
      <OnboardingTour tourId="caja" usuario={usuario} />
    </div>
  );
}
