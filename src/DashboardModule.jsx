import { useState, useEffect, useCallback } from "react";
import { C_LIGHT, BRAND } from "./constants";
import { supabase } from "./supabase";
import { saludoUsuario, $ } from "./utils";
import { SkeletonKPIs, SkeletonTable, SkeletonCard, KPI, Box, Tag } from "./ui";
import { CONSULTA_PRECIO_DEFAULT } from "./utils/consultaConstants";
import TransaccionesTab from "./TransaccionesTab";
import { countPedidosTiendaPendientesHead } from "./utils/pedidosTiendaWeb";

const INVERSION = 710433;
const INVERSION_TOTAL = 710433;

const fmt     = (n) => `$${parseFloat(n||0).toLocaleString("es-MX",{minimumFractionDigits:2,maximumFractionDigits:2})}`;
const fmtK    = (n) => n>=1000?`$${(n/1000).toFixed(1)}k`:fmt(n);
const fmtDate = () => new Date().toLocaleDateString("es-MX",{weekday:"long",day:"2-digit",month:"long",year:"numeric"});

/** Cuenta renglones en medicamentos_prescritos (JSON) por surtido. */
function resumenLineasReceta(citasRows) {
  let farmax = 0;
  let externa = 0;
  let pend = 0;
  let conProductoId = 0;
  for (const c of citasRows || []) {
    const arr = Array.isArray(c.medicamentos_prescritos) ? c.medicamentos_prescritos : [];
    for (const m of arr) {
      if (m.producto_id != null) conProductoId++;
      const s = m.surtido || "pendiente";
      if (s === "farmax") farmax++;
      else if (s === "externa") externa++;
      else pend++;
    }
  }
  return { farmax, externa, pend, conProductoId };
}

const rangeToday = () => { const d=new Date(),y=d.getFullYear(),m=d.getMonth(),dd=d.getDate(); return {start:new Date(y,m,dd,0,0,0).toISOString(),end:new Date(y,m,dd,23,59,59).toISOString()}; };
const rangeWeek  = () => { const d=new Date(); d.setDate(d.getDate()-7); return {start:d.toISOString(),end:new Date().toISOString()}; };
const rangeMonth = () => { const d=new Date(),y=d.getFullYear(),m=d.getMonth(); return {start:new Date(y,m,1).toISOString(),end:new Date().toISOString()}; };
const rangeYesterday = () => { const d=new Date(),y=d.getFullYear(),m=d.getMonth(),dd=d.getDate()-1; return {start:new Date(y,m,dd,0,0,0).toISOString(),end:new Date(y,m,dd,23,59,59).toISOString()}; };
const rangeWeekPrev  = () => { const end=new Date(); end.setDate(end.getDate()-7); const start=new Date(end); start.setDate(start.getDate()-7); return {start:start.toISOString(),end:end.toISOString()}; };
const yesterdayLocal = () => { const d=new Date(); d.setDate(d.getDate()-1); return d.toLocaleDateString("sv-SE"); };

// Calcula el tramo transcurrido del mes actual (0..1) para proyectar metas.
function fraccionMesTranscurrido() {
  const d = new Date();
  const dia = d.getDate();
  const fin = new Date(d.getFullYear(), d.getMonth()+1, 0).getDate();
  return Math.min(Math.max(dia / fin, 0.01), 1);
}

function parseMeta(rows, clave, def) {
  const r = (rows || []).find(x => x.clave === clave);
  if (!r) return def;
  const v = parseFloat(r.valor);
  return Number.isFinite(v) && v > 0 ? v : def;
}

function pctCumplimiento(actual, meta) {
  if (!meta || meta <= 0) return 0;
  return Math.max(0, (actual / meta) * 100);
}

function trendDelta(actual, anterior) {
  if (anterior === 0 || anterior == null) return null;
  return ((actual - anterior) / anterior) * 100;
}

function KpiCard({label, value, col, sub, icon }) {
  const C = C_LIGHT;
  return (
    <div style={{background:C.card,border:`1px solid ${C.border}`,borderRadius:12,padding:"16px 20px"}}>
      <div style={{display:"flex",justifyContent:"space-between",alignItems:"flex-start",marginBottom:6}}>
        <div style={{color:C.textMid,fontSize:11,fontWeight:700,letterSpacing:.4}}>{label.toUpperCase()}</div>
        <span style={{fontSize:18}}>{icon}</span>
      </div>
      <div style={{color:col||C.blue,fontWeight:800,fontSize:26,marginBottom:2}}>{value}</div>
      {sub&&<div style={{color:C.textDim,fontSize:10}}>{sub}</div>}
    </div>
  );
}

function BarChart({ data, colorFn }) {
  const C = C_LIGHT;
  const max = Math.max(...data.map(d=>d.value),1);
  return (
    <div style={{display:"flex",flexDirection:"column",gap:10}}>
      {data.map((d,i)=>(
        <div key={i} style={{display:"flex",alignItems:"center",gap:12}}>
          <div style={{width:110,color:C.textMid,fontSize:12,textAlign:"right",flexShrink:0}}>{d.label}</div>
          <div style={{flex:1,background:C.bg,borderRadius:6,height:28,overflow:"hidden",position:"relative"}}>
            <div style={{position:"absolute",left:0,top:0,bottom:0,width:`${Math.max((d.value/max)*100,1)}%`,background:colorFn?colorFn(i):BRAND.gradient,borderRadius:6,transition:"width .6s ease",display:"flex",alignItems:"center",paddingLeft:8}}>
              {d.value>max*0.15&&<span style={{color:"#fff",fontSize:11,fontWeight:700}}>{fmtK(d.value)}</span>}
            </div>
            {d.value<=max*0.15&&<span style={{position:"absolute",left:`${(d.value/max)*100+1}%`,top:"50%",transform:"translateY(-50%)",color:C.textMid,fontSize:11,fontWeight:700}}>{fmtK(d.value)}</span>}
          </div>
          <div style={{width:80,color:C.text,fontSize:11,fontWeight:700,flexShrink:0}}>{fmt(d.value)}</div>
        </div>
      ))}
    </div>
  );
}

// Tarjeta KPI "accionable": muestra valor, meta, % cumplimiento y tendencia vs período anterior.
function InsightCard({ label, icon, value, display, meta, metaLabel, delta, col, formatMeta, onAction, actionLabel }) {
  const C = C_LIGHT;
  const tieneMeta = Number.isFinite(meta) && meta > 0;
  const pct = tieneMeta ? pctCumplimiento(value, meta) : 0;
  const pctClamp = Math.min(pct, 100);
  const barColor = pct >= 100 ? C.green : pct >= 70 ? (col || C.blue) : pct >= 40 ? C.amber : C.red;
  const mainCol = col || C.blue;
  const hasTrend = Number.isFinite(delta);
  const up = hasTrend && delta >= 0;
  const fmtMeta = formatMeta || ((n) => n.toLocaleString("es-MX"));
  return (
    <div style={{background:C.card,border:`1px solid ${C.border}`,borderRadius:12,padding:"16px 18px",display:"flex",flexDirection:"column",gap:10}}>
      <div style={{display:"flex",justifyContent:"space-between",alignItems:"flex-start"}}>
        <div style={{color:C.textMid,fontSize:11,fontWeight:700,letterSpacing:.4}}>{label.toUpperCase()}</div>
        {icon && <span style={{fontSize:18}}>{icon}</span>}
      </div>
      <div style={{color:mainCol,fontWeight:800,fontSize:26,lineHeight:1.1}}>{display ?? value}</div>
      {tieneMeta && (
        <>
          <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",fontSize:10,color:C.textMid}}>
            <span>Meta {metaLabel || ""}: <strong style={{color:C.text}}>{fmtMeta(meta)}</strong></span>
            <span style={{fontWeight:800,color:barColor}}>{pct.toFixed(0)}%</span>
          </div>
          <div style={{background:C.bg,borderRadius:4,height:6,overflow:"hidden"}}>
            <div style={{height:"100%",width:`${pctClamp}%`,background:barColor,borderRadius:4,transition:"width .6s ease"}}/>
          </div>
        </>
      )}
      <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginTop:tieneMeta?0:4}}>
        {hasTrend ? (
          <span style={{fontSize:11,fontWeight:700,color:up?C.green:C.red}}>
            {up?"↑":"↓"} {Math.abs(delta).toFixed(1)}% <span style={{color:C.textDim,fontWeight:500}}>vs periodo anterior</span>
          </span>
        ) : <span style={{fontSize:11,color:C.textDim}}>Sin comparativo</span>}
        {onAction && (pct < 70 || !tieneMeta) && (
          <button onClick={onAction} style={{padding:"4px 10px",borderRadius:6,border:`1px solid ${mainCol}40`,background:"transparent",color:mainCol,cursor:"pointer",fontSize:10,fontWeight:700}}>
            {actionLabel || "Ver detalle →"}
          </button>
        )}
      </div>
    </div>
  );
}

// "Lo que necesitas hacer hoy" — lista de pendientes accionables con navegación al módulo destino.
function TodoHoy({ items }) {
  const C = C_LIGHT;
  const pendientes = items.filter(i => i.count > 0);
  const total = pendientes.reduce((a, i) => a + i.count, 0);
  return (
    <div style={{background:C.card,border:`1px solid ${C.border}`,borderRadius:14,padding:20,marginBottom:24}}>
      <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:14}}>
        <div>
          <div style={{color:C.text,fontWeight:800,fontSize:15,display:"flex",alignItems:"center",gap:8}}>
            📌 Lo que necesitas hacer hoy
          </div>
          <div style={{color:C.textMid,fontSize:11,marginTop:2}}>
            {total === 0 ? "Nada pendiente. Todo en orden ✅" : `${total} pendiente${total !== 1 ? "s" : ""} entre ${pendientes.length} área${pendientes.length !== 1 ? "s" : ""}`}
          </div>
        </div>
        {total === 0 && <span style={{padding:"4px 10px",borderRadius:999,background:C.greenDim,color:C.green,fontSize:11,fontWeight:800}}>✓ Al día</span>}
      </div>
      {total === 0 ? (
        <div style={{color:C.textDim,fontSize:12,padding:"8px 0"}}>
          No hay tareas críticas en inventario, caja, pedidos en línea ni documentos COFEPRIS.
        </div>
      ) : (
        <div style={{display:"grid",gridTemplateColumns:"repeat(auto-fill,minmax(260px,1fr))",gap:10}}>
          {pendientes.map(i => (
            <div key={i.id} style={{display:"flex",alignItems:"center",gap:12,padding:"10px 12px",background:i.col+"10",border:`1px solid ${i.col}30`,borderRadius:10}}>
              <div style={{fontSize:22,width:32,textAlign:"center"}}>{i.icon}</div>
              <div style={{flex:1,minWidth:0}}>
                <div style={{color:i.col,fontWeight:800,fontSize:13,display:"flex",alignItems:"center",gap:6}}>
                  <span style={{background:i.col,color:"#fff",borderRadius:999,padding:"1px 8px",fontSize:11}}>{i.count}</span>
                  {i.label}
                </div>
                {i.sub && <div style={{color:C.textMid,fontSize:11,marginTop:2,whiteSpace:"nowrap",overflow:"hidden",textOverflow:"ellipsis"}}>{i.sub}</div>}
              </div>
              {i.onAction && (
                <button onClick={i.onAction} style={{padding:"5px 10px",borderRadius:6,border:`1px solid ${i.col}40`,background:"#fff",color:i.col,cursor:"pointer",fontSize:11,fontWeight:700,whiteSpace:"nowrap"}}>
                  {i.actionLabel || "Resolver →"}
                </button>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

export default function DashboardModule({ usuario, setPage, showConfirm }) {
  const C = C_LIGHT;
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [panelTab, setPanelTab] = useState("operacion");
  const [periodo, setPeriodo] = useState("mes");
  const [rep, setRep] = useState(null);
  const [repLoading, setRepLoading] = useState(false);

  const fetchAll = useCallback(async () => {
    setLoading(true);
    const today = rangeToday(), week = rangeWeek(), month = rangeMonth();
    const yesterday = rangeYesterday();
    const weekPrev = rangeWeekPrev();
    const hoyLocal = new Date().toLocaleDateString("sv-SE");
    const ayerLocal = yesterdayLocal();
    const inicioMesLocal = new Date(new Date().getFullYear(), new Date().getMonth(), 1).toLocaleDateString("sv-SE");
    const cofeprisLimite = new Date(Date.now() + 30 * 86400000).toISOString().slice(0, 10);
    const adminTok = sessionStorage.getItem("farmax_session_token");
    const cofeprisRpc = adminTok
      ? supabase.rpc("admin_alertas_cofepris_ventana", {
          p_session_token: adminTok,
          p_limite: cofeprisLimite,
          p_hoy: new Date().toISOString().slice(0, 10),
        })
      : Promise.resolve({ data: null, error: { message: "sin sesión" } });
    const [
      { data: pedHoy }, { data: pedAyer }, { data: pedSemana }, { data: pedSemanaAnt }, { data: pedMes }, { data: pedTodos }, { data: pedMesAnt },
      { data: citasHoy, error: errCitasHoy },
      { data: citasAyer, error: errCitasAyer },
      { count: onlinePendCount, error: errOnlinePend },
      { data: pedMesTipo },
      { data: pedItems }, { data: bajoStock }, { data: porCaducar },
      { data: cortesConDif },
      { data: pedRecetaFarmax },
      { count: citasRecetaExternaMes, error: errRecetaExt },
      { data: cfgRows },
      { data: citasKpiMes },
      { data: cofeprisRpcData, error: errAlertasCof },
    ] = await Promise.all([
      supabase.from("pedidos").select("total").eq("estado", "completado").gte("created_at", today.start).lte("created_at", today.end),
      supabase.from("pedidos").select("total").eq("estado", "completado").gte("created_at", yesterday.start).lte("created_at", yesterday.end),
      supabase.from("pedidos").select("total").eq("estado", "completado").gte("created_at", week.start),
      supabase.from("pedidos").select("total").eq("estado", "completado").gte("created_at", weekPrev.start).lte("created_at", weekPrev.end),
      supabase.from("pedidos").select("total,atendido_por").eq("estado", "completado").gte("created_at", month.start),
      supabase.from("pedidos").select("total").eq("estado", "completado"),
      supabase.from("pedidos").select("total").eq("estado", "completado").gte("created_at", new Date(new Date().getFullYear(), new Date().getMonth() - 1, 1).toISOString()).lte("created_at", new Date(new Date().getFullYear(), new Date().getMonth(), 0).toISOString()),
      supabase.from("citas").select("id").eq("fecha", hoyLocal).neq("estado", "cancelada").or("estado.eq.completada,estado.eq.pagada,pago_estado.eq.pagada"),
      supabase.from("citas").select("id").eq("fecha", ayerLocal).neq("estado", "cancelada").or("estado.eq.completada,estado.eq.pagada,pago_estado.eq.pagada"),
      countPedidosTiendaPendientesHead(supabase),
      supabase.from("pedidos").select("total,tipo").eq("estado", "completado").gte("created_at", month.start),
      supabase.from("pedido_items").select("cantidad,precio_unitario,productos(nombre)").limit(1000),
      supabase.from("productos").select("id,nombre,stock,stock_minimo").lte("stock", 0).eq("activo", true).limit(5),
      supabase.from("lotes").select("producto_id").eq("activo", true).gt("cantidad_actual", 0).lte("fecha_caducidad", new Date(Date.now() + 30 * 86400000).toISOString().slice(0, 10)).not("fecha_caducidad", "is", null),
      supabase.from("cortes_caja").select("id,diferencia").neq("diferencia", 0).limit(10),
      supabase.from("pedidos").select("total").eq("estado", "completado").eq("receta_origen", "medico_farmax").gte("created_at", month.start),
      supabase
        .from("citas")
        .select("id", { count: "exact", head: true })
        .eq("receta_surtido_en", "externa")
        .gte("fecha", inicioMesLocal)
        .neq("estado", "cancelada")
        .or("estado.eq.completada,estado.eq.pagada,pago_estado.eq.pagada"),
      supabase.from("configuracion").select("clave,valor").in("clave", [
        "estimado_receta_externa",
        "meta_ventas_dia", "meta_ventas_semana", "meta_ventas_mes",
        "meta_ticket_prom", "meta_consultas_dia", "meta_consultas_mes",
      ]),
      supabase.from("citas").select("medicamentos_prescritos,duracion_consulta_segundos").gte("fecha", inicioMesLocal).neq("estado", "cancelada"),
      cofeprisRpc,
    ]);
    if (errCitasHoy) console.warn("[Dashboard] citas hoy:", errCitasHoy.message);
    if (errCitasAyer) console.warn("[Dashboard] citas ayer:", errCitasAyer.message);
    if (errOnlinePend) console.warn("[Dashboard] online pendientes:", errOnlinePend.message);
    if (errRecetaExt) console.warn("[Dashboard] citas receta externa (mes):", errRecetaExt.message);
    if (errAlertasCof) console.warn("[Dashboard] alertas legales cofepris:", errAlertasCof.message);

    const alertasCofepris = Array.isArray(cofeprisRpcData?.items) ? cofeprisRpcData.items : [];

    const ventasHoy = (pedHoy || []).reduce((a, p) => a + parseFloat(p.total || 0), 0);
    const ventasAyer = (pedAyer || []).reduce((a, p) => a + parseFloat(p.total || 0), 0);
    const ventasSemana = (pedSemana || []).reduce((a, p) => a + parseFloat(p.total || 0), 0);
    const ventasSemanaAnt = (pedSemanaAnt || []).reduce((a, p) => a + parseFloat(p.total || 0), 0);
    const ventasMes = (pedMes || []).reduce((a, p) => a + parseFloat(p.total || 0), 0);
    const totalPedMes = (pedMes || []).length;
    const ticketProm = totalPedMes > 0 ? ventasMes / totalPedMes : 0;
    const recuperado = (pedTodos || []).reduce((a, p) => a + parseFloat(p.total || 0), 0);
    const pctRecuperado = Math.min((recuperado / INVERSION) * 100, 100);
    const gananciaMes = ventasMes * 0.55;
    const ventasMesAnt = (pedMesAnt || []).reduce((a, p) => a + parseFloat(p.total || 0), 0);
    const ticketPromMesAnt = (pedMesAnt || []).length > 0 ? ventasMesAnt / (pedMesAnt || []).length : 0;
    const crecimiento = ventasMesAnt > 0 ? ((ventasMes - ventasMesAnt) / ventasMesAnt * 100).toFixed(1) : null;
    const restante = INVERSION - recuperado;
    const paybackMeses = gananciaMes > 0 ? Math.max(Math.ceil(restante / gananciaMes), 0) : null;

    const metas = {
      ventasDia:     parseMeta(cfgRows, "meta_ventas_dia", 3000),
      ventasSemana:  parseMeta(cfgRows, "meta_ventas_semana", 20000),
      ventasMes:     parseMeta(cfgRows, "meta_ventas_mes", 80000),
      ticketProm:    parseMeta(cfgRows, "meta_ticket_prom", 250),
      consultasDia:  parseMeta(cfgRows, "meta_consultas_dia", 8),
      consultasMes:  parseMeta(cfgRows, "meta_consultas_mes", 180),
    };
    const trends = {
      ventasHoy:     trendDelta(ventasHoy, ventasAyer),
      ventasSemana:  trendDelta(ventasSemana, ventasSemanaAnt),
      ventasMes:     trendDelta(ventasMes, ventasMesAnt),
      ticketProm:    trendDelta(ticketProm, ticketPromMesAnt),
      consultasHoy:  null,
    };

    const hoyISO = new Date().toISOString().slice(0,10);
    const cofeprisItems = (alertasCofepris || []).map(a => ({
      id: a.id, nombre: a.nombre, fecha: a.fecha_vencimiento,
      vencida: a.fecha_vencimiento && a.fecha_vencimiento < hoyISO,
    }));
    const cofeprisVencidas = cofeprisItems.filter(c => c.vencida).length;
    const cofeprisPorVencer = cofeprisItems.length;

    const fisica = (pedMesTipo || []).filter((p) => !p.tipo || p.tipo === "fisica").reduce((a, p) => a + parseFloat(p.total || 0), 0);
    const online2 = (pedMesTipo || []).filter((p) => p.tipo === "online").reduce((a, p) => a + parseFloat(p.total || 0), 0);
    const consult = (pedMesTipo || []).filter((p) => p.tipo === "consulta").reduce((a, p) => a + parseFloat(p.total || 0), 0);

    const byEmp = {};
    (pedMes || []).forEach((p) => { const k = p.atendido_por || "Sin asignar"; byEmp[k] = (byEmp[k] || 0) + parseFloat(p.total || 0); });
    const empleados = Object.entries(byEmp).sort((a, b) => b[1] - a[1]).slice(0, 5);

    const byProd = {};
    (pedItems || []).forEach((it) => { const n = it.productos?.nombre || "Producto"; if (!byProd[n]) byProd[n] = { unidades: 0, ingreso: 0 }; byProd[n].unidades += parseInt(it.cantidad || 1); byProd[n].ingreso += parseFloat(it.precio_unitario || 0) * parseInt(it.cantidad || 1); });
    const topProductos = Object.entries(byProd).sort((a, b) => b[1].unidades - a[1].unidades).slice(0, 10);

    const onlinePend = onlinePendCount ?? 0;
    const sinAtender = onlinePend;

    const ventasRecetaMedicoFarmaxMes = (pedRecetaFarmax || []).reduce((a, p) => a + parseFloat(p.total || 0), 0);
    const cfgEst = (cfgRows || []).find(r => r.clave === "estimado_receta_externa");
    const estCfg = parseFloat(cfgEst?.valor);
    const estimadoRecetaExterna = Number.isFinite(estCfg) && estCfg >= 0 ? estCfg : 350;
    const nRecetasExternasMes = citasRecetaExternaMes ?? 0;
    const oportunidadPerdidaRecetaEst = nRecetasExternasMes * estimadoRecetaExterna;

    const lineasRec = resumenLineasReceta(citasKpiMes);
    const durVals = (citasKpiMes || []).map((c) => c.duracion_consulta_segundos).filter((n) => Number.isFinite(n) && n > 0);
    const tiempoPromConsultaMin = durVals.length ? durVals.reduce((a, b) => a + b, 0) / durVals.length / 60 : null;

    const consultasHoy = (citasHoy || []).length;
    const consultasAyer = (citasAyer || []).length;
    trends.consultasHoy = trendDelta(consultasHoy, consultasAyer);

    setData({
      ventasHoy, ventasAyer, ventasSemana, ventasSemanaAnt, ventasMes, ventasMesAnt, crecimiento, ticketProm, consultasHoy, consultasAyer, onlinePend,
      recuperado, pctRecuperado, gananciaMes, paybackMeses, restante,
      metas, trends,
      fuentes: [{ label: "Farmacia física", value: fisica }, { label: "Tienda online", value: online2 }, { label: "Consultorio", value: consult }],
      empleados, topProductos,
      ventasRecetaMedicoFarmaxMes,
      nRecetasExternasMes,
      oportunidadPerdidaRecetaEst,
      estimadoRecetaExternaUnit: estimadoRecetaExterna,
      lineasRecetaFarmax: lineasRec.farmax,
      lineasRecetaExterna: lineasRec.externa,
      lineasRecetaPendiente: lineasRec.pend,
      lineasRecetaConCatalogo: lineasRec.conProductoId,
      tiempoPromConsultaMin,
      alertas: {
        bajoStock: (bajoStock || []).length,
        bajoStockNombres: (bajoStock || []).map((p) => p.nombre).slice(0, 3),
        porCaducar: new Set((porCaducar || []).map(l => l.producto_id)).size,
        sinAtender,
        cortesConDif: (cortesConDif || []).length,
        cofeprisVencidas,
        cofeprisPorVencer,
        cofeprisItems,
      },
    });
    setLoading(false);
  }, []);

  const fetchRep = useCallback(async () => {
    setRepLoading(true);
    const dias = periodo === "dia" ? 1 : periodo === "semana" ? 7 : 30;
    const desde = new Date(Date.now() - dias * 86400000).toISOString();
    const desdeFecha = new Date(Date.now() - dias * 86400000).toISOString().split("T")[0];
    const [
      { data: peds }, { count: clientesNuevos }, { data: cons }, { data: ponl }, { data: devs }, { data: pedsCat },
      { data: pedsRecetaFarmax },
      { count: citasRecetaExternaPeriod },
    ] = await Promise.all([
      supabase.from("pedidos").select("total,created_at,tipo,atendido_por,usuarios(nombre)").gte("created_at", desde).eq("estado", "completado"),
      supabase.rpc("admin_contar_clientes_desde", {
        p_session_token: sessionStorage.getItem("farmax_session_token"),
        p_desde:         desde,
      }).then(r => ({ count: r.data || 0 })),
      supabase.from("citas").select("id").gte("fecha", desdeFecha).neq("estado", "cancelada").or("estado.eq.completada,estado.eq.pagada,pago_estado.eq.pagada"),
      supabase.from("pedidos").select("total").gte("created_at", desde).eq("tipo", "online").eq("estado", "completado"),
      supabase.from("devoluciones").select("total_devuelto").gte("created_at", desde).eq("estado", "aprobada"),
      supabase.from("pedidos").select("total,productos:pedido_items(precio_unitario,cantidad,productos(categoria,costo))").gte("created_at", desde).eq("estado", "completado"),
      supabase.from("pedidos").select("total").gte("created_at", desde).eq("estado", "completado").eq("receta_origen", "medico_farmax"),
      supabase
        .from("citas")
        .select("id", { count: "exact", head: true })
        .gte("fecha", desdeFecha)
        .eq("receta_surtido_en", "externa")
        .neq("estado", "cancelada")
        .or("estado.eq.completada,estado.eq.pagada,pago_estado.eq.pagada"),
    ]);
    const totalDevoluciones = (devs || []).reduce((a, d) => a + parseFloat(d.total_devuelto || 0), 0);
    const margenCat = {};
    (pedsCat || []).forEach((ped) => {
      (ped.productos || []).forEach((item) => {
        const cat = item.productos?.categoria || "Sin categoría";
        const ingreso = parseFloat(item.precio_unitario || 0) * parseInt(item.cantidad || 1);
        const costo = parseFloat(item.productos?.costo || 0) * parseInt(item.cantidad || 1);
        if (!margenCat[cat]) margenCat[cat] = { ingreso: 0, costo: 0 };
        margenCat[cat].ingreso += ingreso;
        margenCat[cat].costo += costo;
      });
    });
    const margenPorCat = Object.entries(margenCat).map(([cat, v]) => ({
      cat, ingreso: v.ingreso, costo: v.costo,
      margen: v.ingreso > 0 ? ((v.ingreso - v.costo) / v.ingreso * 100).toFixed(1) : 0,
      ganancia: v.ingreso - v.costo,
    })).sort((a, b) => b.ingreso - a.ingreso);
    let precioConsulta = CONSULTA_PRECIO_DEFAULT;
    let estimadoRecetaExternaCfg = 350;
    const { data: cfgRows } = await supabase.from("configuracion").select("clave,valor").in("clave", ["precio_consulta", "estimado_receta_externa"]);
    (cfgRows || []).forEach((r) => {
      if (r.clave === "precio_consulta") {
        const pc = parseFloat(r.valor);
        if (Number.isFinite(pc) && pc > 0) precioConsulta = pc;
      }
      if (r.clave === "estimado_receta_externa") {
        const ex = parseFloat(r.valor);
        if (Number.isFinite(ex) && ex >= 0) estimadoRecetaExternaCfg = ex;
      }
    });
    const ventasRecetaFarmaxPeriod = (pedsRecetaFarmax || []).reduce((a, p) => a + parseFloat(p.total || 0), 0);
    const nExt = citasRecetaExternaPeriod ?? 0;
    setRep({
      ventas: peds || [], clientes: clientesNuevos ?? 0,
      consultas: cons?.length || 0, online: (ponl || []).reduce((a, p) => a + parseFloat(p.total || 0), 0),
      totalDevoluciones, margenPorCat, precioConsulta,
      ventasRecetaFarmaxPeriod,
      nRecetasExternasPeriod: nExt,
      oportunidadPerdidaRecetaPeriod: nExt * estimadoRecetaExternaCfg,
      estimadoRecetaExternaUnit: estimadoRecetaExternaCfg,
    });
    setRepLoading(false);
  }, [periodo]);

  useEffect(() => { fetchAll(); }, [fetchAll]);
  useEffect(() => {
    if (panelTab === "resumen" || panelTab === "margen") fetchRep();
  }, [panelTab, periodo, fetchRep]);

  if (loading) return (
    <div style={{padding:24}}>
      <SkeletonKPIs count={5}/>
      <div style={{display:"grid",gridTemplateColumns:"1fr 1fr",gap:16,marginBottom:16}}>
        <SkeletonCard height={200}/>
        <SkeletonCard height={200}/>
      </div>
      <SkeletonTable rows={5} cols={4}/>
    </div>
  );

  const {ventasHoy,ventasSemana,ventasMes,ventasMesAnt,crecimiento,ticketProm,consultasHoy,onlinePend,recuperado,pctRecuperado,gananciaMes,paybackMeses,restante,fuentes,empleados,topProductos,alertas,ventasRecetaMedicoFarmaxMes,nRecetasExternasMes,oportunidadPerdidaRecetaEst,estimadoRecetaExternaUnit,lineasRecetaFarmax,lineasRecetaExterna,lineasRecetaPendiente,lineasRecetaConCatalogo,tiempoPromConsultaMin,metas,trends} = data;
  const fracMes = fraccionMesTranscurrido();
  const metaVentasMesProrrateada = Math.round((metas?.ventasMes || 0) * fracMes);
  const metaConsultasMesProrrateada = Math.round((metas?.consultasMes || 0) * fracMes);
  const goToPage = (id, opts) => { if (setPage) setPage(id, opts); };
  const todoItems = [
    { id:"stock",    icon:"📦", count: alertas.bajoStock,      col: C.red,    label: "Reordenar productos",                sub: alertas.bajoStockNombres.join(", ") || "stock en 0",          onAction: () => goToPage("inv", {tab:"reabasto"}), actionLabel: "Ir a reabasto →" },
    { id:"caduca",   icon:"⏰", count: alertas.porCaducar,     col: C.amber,  label: "Próximos a caducar (30 días)",       sub: "Revisa lotes y aplica descuentos",                            onAction: () => goToPage("inv", {tab:"lotes"}), actionLabel: "Ver lotes →" },
    { id:"cortes",   icon:"💰", count: alertas.cortesConDif,   col: C.red,    label: "Cortes de caja con diferencia",       sub: "Revisa faltantes o sobrantes",                                onAction: () => goToPage("caja"), actionLabel: "Ver cortes →" },
    { id:"online",   icon:"🌐", count: alertas.sinAtender,     col: C.amber,  label: "Pedidos online pendientes",           sub: "Clientes esperando preparación",                              onAction: () => goToPage("pos"), actionLabel: "Atender →" },
    { id:"cofepris", icon:"⚖️", count: alertas.cofeprisPorVencer, col: (alertas.cofeprisVencidas > 0 ? C.red : C.amber), label: alertas.cofeprisVencidas > 0 ? `COFEPRIS · ${alertas.cofeprisVencidas} vencido${alertas.cofeprisVencidas!==1?"s":""}` : "Documentos COFEPRIS por vencer", sub: (alertas.cofeprisItems||[]).slice(0,2).map(x=>x.nombre).join(" · "), onAction: () => goToPage("cof"), actionLabel: "Ver alertas →" },
  ];
  const roiCol = pctRecuperado>=75?C.green:pctRecuperado>=40?C.amber:C.red;
  const totalEmp = empleados.reduce((a,e)=>a+e[1],0);

  const totalVentas = rep ? (rep.ventas||[]).reduce((a,p)=>a+parseFloat(p.total||0),0) : 0;
  const totalOnline = rep ? rep.online : 0;
  const ticketPromedio = rep && rep.ventas?.length ? totalVentas/rep.ventas.length : 0;
  const ingresoConsultas = rep ? rep.consultas * (rep.precioConsulta || CONSULTA_PRECIO_DEFAULT) : 0;
  const porEmpleado = rep ? rep.ventas.reduce((acc,p)=>{
    const nombre = p.usuarios?.nombre||"Sin asignar";
    acc[nombre]=(acc[nombre]||0)+parseFloat(p.total||0);
    return acc;
  },{}) : {};

  return (
    <div style={{padding:24,background:C.bg,minHeight:"100vh",fontFamily:"'Plus Jakarta Sans',sans-serif"}}>
      <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:16,flexWrap:"wrap",gap:12}}>
        <div>
          <h1 style={{margin:0,color:C.text,fontSize:20,fontWeight:800}}>◈ Dashboard y reportes</h1>
          <p style={{margin:"4px 0 0",color:C.textMid,fontSize:12,textTransform:"capitalize"}}>{fmtDate()}</p>
        </div>
        <div style={{display:"flex",gap:10,alignItems:"center"}}>
          <div style={{color:C.textMid,fontSize:12}}><strong style={{color:C.text}}>{saludoUsuario(usuario?.nombre)}</strong> 👋</div>
          <button type="button" onClick={()=>{ fetchAll(); if(panelTab==="resumen"||panelTab==="margen") fetchRep(); }} style={{padding:"7px 14px",borderRadius:8,border:`1px solid ${C.border}`,background:"transparent",color:C.textMid,cursor:"pointer",fontWeight:700,fontSize:12}}>🔄 Actualizar</button>
        </div>
      </div>

      <div style={{display:"flex",gap:6,flexWrap:"wrap",marginBottom:20,borderBottom:`1px solid ${C.border}`,paddingBottom:12}}>
        {[
          ["operacion","📊 Operación"],
          ["resumen","📈 Resumen por período"],
          ["transacciones","🔄 Transacciones"],
          ["margen","💹 Margen por categoría"],
        ].map(([id,label])=>(
          <button key={id} type="button" onClick={()=>setPanelTab(id)} style={{
            padding:"8px 14px",borderRadius:8,border:`1px solid ${panelTab===id?BRAND.primary:C.border}`,
            background:panelTab===id?BRAND.primary+"22":"transparent",color:panelTab===id?BRAND.primary:C.textMid,
            fontWeight:700,fontSize:12,cursor:"pointer",
          }}>{label}</button>
        ))}
      </div>

      {panelTab==="transacciones" && (
        <TransaccionesTab usuario={usuario} showConfirm={showConfirm} />
      )}

      {panelTab==="resumen" && (
        <div>
          <div style={{display:"flex",gap:6,marginBottom:16,flexWrap:"wrap"}}>
            {[["dia","Hoy"],["semana","7 días"],["mes","30 días"]].map(([v,l])=>(
              <button key={v} type="button" onClick={()=>setPeriodo(v)} style={{padding:"6px 14px",borderRadius:8,border:`1px solid ${periodo===v?BRAND.primary:C.border}`,background:periodo===v?BRAND.primary+"18":"transparent",color:periodo===v?BRAND.secondary:C.textMid,fontSize:12,fontWeight:700,cursor:"pointer"}}>{l}</button>
            ))}
          </div>
          {repLoading||!rep?<SkeletonKPIs count={5}/>:(
            <>
              <div style={{display:"flex",gap:12,marginBottom:20,flexWrap:"wrap"}}>
                <KPI label="Ventas totales" value={$(totalVentas)} col={C.blue} icon="💵"/>
                <KPI label="Ventas online" value={$(totalOnline)} col={C.teal} icon="🌐"/>
                <KPI label="Consultas" value={$(ingresoConsultas)} col={C.purple} icon="🏥" sub={`${rep.consultas} citas`}/>
                <KPI label="Ventas receta médico Farmax" value={$(rep.ventasRecetaFarmaxPeriod || 0)} col={C.purple} icon="📋" sub="POS en el período"/>
                <KPI label="Oportunidad perdida (est.)" value={$(rep.oportunidadPerdidaRecetaPeriod || 0)} col={(rep.nRecetasExternasPeriod || 0) > 0 ? C.amber : C.green} icon="📤" sub={`${rep.nRecetasExternasPeriod || 0} recetas fuera × ${fmt(rep.estimadoRecetaExternaUnit || 350)}`}/>
                <KPI label="Ticket promedio" value={$(ticketPromedio)} col={C.green} icon="🧾"/>
                <KPI label="Clientes nuevos" value={rep.clientes} col={C.amber} icon="👤"/>
              </div>
              <div style={{display:"grid",gridTemplateColumns:"1fr 1fr",gap:16,marginBottom:16}}>
                <Box style={{padding:20}}>
                  <div style={{color:C.text,fontWeight:700,fontSize:14,marginBottom:16}}>📈 ROI — Retorno de inversión</div>
                  <div style={{color:C.textDim,fontSize:10,letterSpacing:1,textTransform:"uppercase",marginBottom:12}}>Inversión total del proyecto</div>
                  {[
                    ["Construcción",464999,C.blue],
                    ["Equipo farmacia",8899,C.teal],
                    ["Equipo consultorio",21650,C.green],
                    ["Inventario inicial",134000,C.amber],
                    ["Trámites y legales",16300,C.purple],
                    ["Imprevistos",64585,C.red],
                  ].map(([l,v,col])=>(
                    <div key={l} style={{display:"flex",justifyContent:"space-between",padding:"5px 0",borderBottom:`1px solid ${C.border}`}}>
                      <span style={{color:C.textMid,fontSize:12}}>{l}</span>
                      <span style={{color:col,fontSize:12,fontWeight:700}}>{$(v)}</span>
                    </div>
                  ))}
                  <div style={{display:"flex",justifyContent:"space-between",padding:"10px 0",marginTop:4}}>
                    <span style={{color:C.text,fontWeight:800,fontSize:14}}>TOTAL INVERTIDO</span>
                    <span style={{color:C.red,fontWeight:900,fontSize:16}}>{$(INVERSION_TOTAL)}</span>
                  </div>
                  <div style={{background:C.greenDim,border:`1px solid ${C.green}30`,borderRadius:8,padding:"10px 12px",marginTop:4}}>
                    <div style={{color:C.green,fontSize:12,fontWeight:700}}>
                      Recuperado hasta hoy: {$(totalVentas)} ({((totalVentas/INVERSION_TOTAL)*100).toFixed(2)}%)
                    </div>
                  </div>
                </Box>
                <Box style={{padding:20}}>
                  <div style={{color:C.text,fontWeight:700,fontSize:14,marginBottom:16}}>📊 Ingresos por fuente</div>
                  {[
                    ["Farmacia física", totalVentas-totalOnline-ingresoConsultas, C.blue],
                    ["Tienda en línea", totalOnline, C.teal],
                    ["Consultorio", ingresoConsultas, C.purple],
                  ].map(([l,v,col])=>{
                    const pct = totalVentas>0?Math.round((v/totalVentas)*100):0;
                    return(
                      <div key={l} style={{marginBottom:12}}>
                        <div style={{display:"flex",justifyContent:"space-between",marginBottom:4}}>
                          <span style={{color:C.textMid,fontSize:12}}>{l}</span>
                          <span style={{color:col,fontWeight:700,fontSize:12}}>{$(v)}</span>
                        </div>
                        <div style={{background:C.border,borderRadius:4,height:8,overflow:"hidden"}}>
                          <div style={{width:`${pct}%`,height:"100%",background:col,borderRadius:4}}/>
                        </div>
                        <div style={{color:C.textDim,fontSize:10,marginTop:2}}>{pct}% del total</div>
                      </div>
                    );
                  })}
                </Box>
              </div>
              <Box style={{padding:20}}>
                <div style={{color:C.text,fontWeight:700,fontSize:14,marginBottom:14}}>👥 Ventas por empleado</div>
                {!Object.keys(porEmpleado).length?<div style={{color:C.textMid,fontSize:12}}>Sin datos en este periodo</div>:
                  Object.entries(porEmpleado).sort((a,b)=>b[1]-a[1]).map(([nombre,total])=>(
                    <div key={nombre} style={{display:"flex",justifyContent:"space-between",alignItems:"center",padding:"8px 0",borderBottom:`1px solid ${C.border}`}}>
                      <span style={{color:C.text,fontSize:13,fontWeight:600}}>{nombre}</span>
                      <div style={{display:"flex",gap:10,alignItems:"center"}}>
                        <span style={{color:C.green,fontWeight:800,fontSize:14}}>{$(total)}</span>
                        <Tag col={C.green} sm>{totalVentas>0?((total/totalVentas)*100).toFixed(0):0}%</Tag>
                      </div>
                    </div>
                  ))}
              </Box>
            </>
          )}
        </div>
      )}

      {panelTab==="margen" && (
        <div>
          <div style={{display:"flex",gap:6,marginBottom:16,flexWrap:"wrap"}}>
            {[["dia","Hoy"],["semana","7 días"],["mes","30 días"]].map(([v,l])=>(
              <button key={v} type="button" onClick={()=>setPeriodo(v)} style={{padding:"6px 14px",borderRadius:8,border:`1px solid ${periodo===v?BRAND.primary:C.border}`,background:periodo===v?BRAND.primary+"18":"transparent",color:periodo===v?BRAND.secondary:C.textMid,fontSize:12,fontWeight:700,cursor:"pointer"}}>{l}</button>
            ))}
          </div>
          {repLoading||!rep?<SkeletonTable rows={5} cols={5}/>:(
            <div>
              <div style={{display:"flex",gap:12,marginBottom:20,flexWrap:"wrap"}}>
                <KPI label="Ventas brutas" value={$(totalVentas)} col={C.blue} icon="💵"/>
                <KPI label="Devoluciones" value={$(rep.totalDevoluciones||0)} col={C.red} icon="↩️"/>
                <KPI label="Ventas netas" value={$(totalVentas-(rep.totalDevoluciones||0))} col={C.green} icon="✅"/>
                <KPI label="% devuelto" value={totalVentas>0?((rep.totalDevoluciones||0)/totalVentas*100).toFixed(1)+"%":"0%"} col={C.amber} icon="📊"/>
              </div>
              <div style={{background:C.card,border:`1px solid ${C.border}`,borderRadius:12,overflow:"hidden"}}>
                <div style={{padding:"14px 16px",borderBottom:`1px solid ${C.border}`,fontWeight:700,color:C.text,fontSize:14}}>📈 Margen por categoría</div>
                <table style={{width:"100%",borderCollapse:"collapse",fontSize:12}}>
                  <thead>
                    <tr style={{background:C.cardDark}}>
                      {["Categoría","Ingreso","Costo","Ganancia","Margen %"].map(h=>(
                        <th key={h} style={{padding:"9px 14px",textAlign:"left",color:C.textMid,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{h}</th>
                      ))}
                    </tr>
                  </thead>
                  <tbody>
                    {!(rep.margenPorCat||[]).length&&<tr><td colSpan={5} style={{padding:32,textAlign:"center",color:C.textMid}}>Sin datos en este período</td></tr>}
                    {(rep.margenPorCat||[]).map((r,i)=>(
                      <tr key={r.cat} style={{background:i%2===0?"transparent":"#f8fafc"}}>
                        <td style={{padding:"9px 14px",fontWeight:600,color:C.text,borderBottom:`1px solid ${C.border}`}}>{r.cat}</td>
                        <td style={{padding:"9px 14px",color:C.blue,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{$(r.ingreso)}</td>
                        <td style={{padding:"9px 14px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{$(r.costo)}</td>
                        <td style={{padding:"9px 14px",color:r.ganancia>=0?C.green:C.red,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{$(r.ganancia)}</td>
                        <td style={{padding:"9px 14px",borderBottom:`1px solid ${C.border}`}}>
                          <div style={{display:"flex",alignItems:"center",gap:8}}>
                            <div style={{flex:1,height:6,background:"#f1f5f9",borderRadius:3,overflow:"hidden"}}>
                              <div style={{height:"100%",width:`${Math.min(parseFloat(r.margen),100)}%`,background:parseFloat(r.margen)>30?C.green:parseFloat(r.margen)>15?C.amber:C.red,borderRadius:3}}/>
                            </div>
                            <span style={{fontWeight:700,color:parseFloat(r.margen)>30?C.green:parseFloat(r.margen)>15?C.amber:C.red,minWidth:40}}>{r.margen}%</span>
                          </div>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}
        </div>
      )}

      {panelTab==="operacion" && (<>
      <TodoHoy items={todoItems}/>

      <div style={{color:C.textDim,fontSize:10,fontWeight:700,letterSpacing:1.5,marginBottom:12}}>KPIS ACCIONABLES · VENTAS Y ACTIVIDAD</div>
      <div style={{display:"grid",gridTemplateColumns:"repeat(auto-fill,minmax(220px,1fr))",gap:12,marginBottom:16}}>
        <InsightCard
          label="Ventas hoy" icon="💵" col={C.green}
          value={ventasHoy} display={fmtK(ventasHoy)}
          meta={metas?.ventasDia} metaLabel="diaria" formatMeta={fmtK}
          delta={trends?.ventasHoy}
          onAction={() => goToPage("pos")} actionLabel="Ir a POS →"
        />
        <InsightCard
          label="Ventas esta semana" icon="📈" col={C.blue}
          value={ventasSemana} display={fmtK(ventasSemana)}
          meta={metas?.ventasSemana} metaLabel="7 días" formatMeta={fmtK}
          delta={trends?.ventasSemana}
          onAction={() => setPanelTab("resumen")} actionLabel="Ver resumen →"
        />
        <InsightCard
          label="Ventas del mes" icon="📅" col={C.blue}
          value={ventasMes} display={fmtK(ventasMes)}
          meta={metaVentasMesProrrateada || metas?.ventasMes} metaLabel={`prorrateada (${(fracMes*100).toFixed(0)}% del mes)`} formatMeta={fmtK}
          delta={trends?.ventasMes}
          onAction={() => setPanelTab("resumen")} actionLabel="Ver detalle →"
        />
        <InsightCard
          label="Ticket promedio" icon="🧾" col={C.purple}
          value={ticketProm} display={fmtK(ticketProm)}
          meta={metas?.ticketProm} metaLabel="por venta" formatMeta={fmtK}
          delta={trends?.ticketProm}
          onAction={() => setPanelTab("margen")} actionLabel="Ver margen →"
        />
        <InsightCard
          label="Consultas hoy" icon="🩺" col={C.teal}
          value={consultasHoy} display={consultasHoy.toString()}
          meta={metas?.consultasDia} metaLabel="diaria"
          delta={trends?.consultasHoy}
          onAction={() => goToPage("cons")} actionLabel="Ir al consultorio →"
        />
        <InsightCard
          label="Online pendientes" icon="🌐" col={onlinePend>0?C.amber:C.green}
          value={onlinePend} display={onlinePend.toString()}
          onAction={() => goToPage("pos")} actionLabel="Atender →"
        />
      </div>

      <div style={{color:C.textDim,fontSize:10,fontWeight:700,letterSpacing:1.5,marginBottom:12}}>RECETAS MÉDICAS · IMPACTO EN VENTAS</div>
      <div style={{display:"grid",gridTemplateColumns:"repeat(auto-fill,minmax(200px,1fr))",gap:12,marginBottom:24}}>
        <KpiCard label="Mes anterior"      value={fmtK(ventasMesAnt)} col={C.textMid} icon="📆" sub={crecimiento?`${crecimiento>0?"+":""}${crecimiento}% vs este mes`:"Sin datos"}/>
        <KpiCard label="Ventas con receta Farmax" value={fmtK(ventasRecetaMedicoFarmaxMes||0)} col={C.purple} icon="📋" sub="POS · receta de médico del consultorio · mes"/>
        <KpiCard label="Oportunidad perdida (est.)" value={fmtK(oportunidadPerdidaRecetaEst||0)} col={nRecetasExternasMes>0?C.amber:C.green} icon="📤" sub={`${nRecetasExternasMes||0} recetas surtidas fuera × ${fmt(estimadoRecetaExternaUnit||350)}`}/>
      </div>

      <div style={{color:C.textDim,fontSize:10,fontWeight:700,letterSpacing:1.5,marginBottom:12}}>CONSULTORIO · RECETA (DETALLE) Y DURACIÓN</div>
      <div style={{display:"grid",gridTemplateColumns:"repeat(auto-fill,minmax(160px,1fr))",gap:12,marginBottom:24}}>
        <KpiCard label="Ítems surtidos en Farmax" value={lineasRecetaFarmax ?? 0} col={C.green} icon="✓" sub="renglones marcados farmax · mes"/>
        <KpiCard label="Ítems otra farmacia / pendiente" value={(lineasRecetaExterna ?? 0) + (lineasRecetaPendiente ?? 0)} col={C.amber} icon="⚠" sub={`${lineasRecetaExterna ?? 0} otra · ${lineasRecetaPendiente ?? 0} pend.`}/>
        <KpiCard label="Renglones con catálogo" value={lineasRecetaConCatalogo ?? 0} col={C.blue} icon="🔗" sub="vinculados a producto · mes"/>
        <KpiCard label="Tiempo prom. consulta" value={tiempoPromConsultaMin != null ? `${tiempoPromConsultaMin.toFixed(1)} min` : "—"} col={C.teal} icon="⏱" sub="inicio → terminar · mes"/>
      </div>

      <div style={{color:C.textDim,fontSize:10,fontWeight:700,letterSpacing:1.5,marginBottom:12}}>INVERSIÓN Y RETORNO</div>
      <div style={{background:C.card,border:`1px solid ${roiCol}30`,borderRadius:14,padding:24,marginBottom:24}}>
        <div style={{display:"grid",gridTemplateColumns:"repeat(auto-fill,minmax(180px,1fr))",gap:20,marginBottom:20}}>
          <div><div style={{color:C.textMid,fontSize:11,fontWeight:700,marginBottom:4}}>INVERSIÓN TOTAL</div><div style={{color:C.text,fontWeight:800,fontSize:22}}>{fmt(INVERSION)}</div></div>
          <div><div style={{color:C.textMid,fontSize:11,fontWeight:700,marginBottom:4}}>TOTAL RECUPERADO</div><div style={{color:roiCol,fontWeight:800,fontSize:22}}>{fmt(recuperado)}</div></div>
          <div><div style={{color:C.textMid,fontSize:11,fontWeight:700,marginBottom:4}}>GANANCIA NETA EST./MES</div><div style={{color:C.green,fontWeight:800,fontSize:18}}>{fmt(gananciaMes)}</div></div>
          <div><div style={{color:C.textMid,fontSize:11,fontWeight:700,marginBottom:4}}>PAYBACK RESTANTE</div><div style={{color:restante<=0?C.green:C.amber,fontWeight:800,fontSize:18}}>{restante<=0?"✅ Recuperada":paybackMeses?`~${paybackMeses} meses`:"Calculando…"}</div></div>
        </div>
        <div style={{marginBottom:8,display:"flex",justifyContent:"space-between"}}>
          <div style={{color:C.textMid,fontSize:12}}>Progreso de recuperación</div>
          <div style={{color:roiCol,fontWeight:800,fontSize:18}}>{pctRecuperado.toFixed(1)}%</div>
        </div>
        <div style={{background:C.bg,borderRadius:8,height:20,overflow:"hidden"}}>
          <div style={{height:"100%",width:`${pctRecuperado}%`,background:roiCol===C.green?"linear-gradient(90deg,#00c46a,#00e87d)":roiCol===C.amber?"linear-gradient(90deg,#ffaa00,#ffd000)":"linear-gradient(90deg,#ff3d5a,#ff6b7a)",borderRadius:8,transition:"width 1s ease",display:"flex",alignItems:"center",justifyContent:"flex-end",paddingRight:8}}>
            {pctRecuperado>15&&<span style={{color:"#fff",fontSize:10,fontWeight:800}}>{fmt(recuperado)}</span>}
          </div>
        </div>
        <div style={{color:C.textDim,fontSize:10,marginTop:6}}>Recuperado {fmt(recuperado)} de {fmt(INVERSION)} · Resta {fmt(Math.max(restante,0))}</div>
      </div>

      <div style={{display:"grid",gridTemplateColumns:"1fr 1fr",gap:20,marginBottom:24}}>
        <div style={{background:C.card,border:`1px solid ${C.border}`,borderRadius:12,padding:20}}>
          <div style={{color:C.textDim,fontSize:10,fontWeight:700,letterSpacing:1.5,marginBottom:16}}>INGRESOS POR FUENTE — ESTE MES</div>
          <BarChart data={fuentes} colorFn={(i)=>[`linear-gradient(90deg,${C.blue},${C.blueDark})`,`linear-gradient(90deg,${C.purple},#b57aff)`,`linear-gradient(90deg,${C.green},#00e87d)`][i]}/>
          <div style={{marginTop:14,borderTop:`1px solid ${C.border}`,paddingTop:12,display:"flex",justifyContent:"space-between"}}>
            <span style={{color:C.textMid,fontSize:11}}>Total mes</span>
            <span style={{color:C.text,fontWeight:800,fontSize:13}}>{fmt(fuentes.reduce((a,f)=>a+f.value,0))}</span>
          </div>
        </div>
        <div style={{background:C.card,border:`1px solid ${C.border}`,borderRadius:12,padding:20}}>
          <div style={{color:C.textDim,fontSize:10,fontWeight:700,letterSpacing:1.5,marginBottom:16}}>VENTAS POR EMPLEADO — ESTE MES</div>
          {empleados.length===0
            ? <div style={{color:C.textMid,fontSize:12,textAlign:"center",padding:20}}>Sin datos este mes</div>
            : <table style={{width:"100%",borderCollapse:"collapse",fontSize:12}}>
                <thead><tr>{["Empleado","Ventas","%"].map(h=><th key={h} style={{padding:"6px 8px",textAlign:"left",color:C.textMid,fontWeight:700,borderBottom:`1px solid ${C.border}`,fontSize:10}}>{h}</th>)}</tr></thead>
                <tbody>
                  {empleados.map(([nombre,total],i)=>(
                    <tr key={i}>
                      <td style={{padding:"8px",color:C.text,borderBottom:`1px solid ${C.border}`,fontWeight:600}}>{nombre}</td>
                      <td style={{padding:"8px",color:C.green,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{fmt(total)}</td>
                      <td style={{padding:"8px",borderBottom:`1px solid ${C.border}`}}>
                        <span style={{padding:"2px 8px",borderRadius:12,fontSize:10,fontWeight:700,background:C.blueDim,color:C.blue}}>{totalEmp>0?((total/totalEmp)*100).toFixed(0):0}%</span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
          }
        </div>
      </div>

      <div style={{background:C.card,border:`1px solid ${C.border}`,borderRadius:12,padding:20,marginBottom:24}}>
        <div style={{color:C.textDim,fontSize:10,fontWeight:700,letterSpacing:1.5,marginBottom:16}}>🏆 TOP 10 PRODUCTOS MÁS VENDIDOS</div>
        {topProductos.length===0
          ? <div style={{color:C.textMid,fontSize:12,textAlign:"center",padding:20}}>Sin datos de ventas</div>
          : <div style={{overflowX:"auto"}}>
              <table style={{width:"100%",borderCollapse:"collapse",fontSize:12}}>
                <thead><tr style={{background:C.bg}}>{["#","Producto","Unidades","Ingreso total"].map(h=><th key={h} style={{padding:"8px 12px",textAlign:"left",color:C.textMid,fontWeight:700,borderBottom:`1px solid ${C.border}`,whiteSpace:"nowrap"}}>{h}</th>)}</tr></thead>
                <tbody>
                  {topProductos.map(([nombre,stats],i)=>(
                    <tr key={i} style={{background:i%2===0?"transparent":C.bg}}>
                      <td style={{padding:"8px 12px",borderBottom:`1px solid ${C.border}`}}>
                        <span style={{display:"inline-flex",alignItems:"center",justifyContent:"center",width:22,height:22,borderRadius:"50%",fontSize:10,fontWeight:800,background:i<3?BRAND.gradient:C.border,color:i<3?"#fff":C.textMid}}>{i+1}</span>
                      </td>
                      <td style={{padding:"8px 12px",color:C.text,fontWeight:600,borderBottom:`1px solid ${C.border}`}}>{nombre}</td>
                      <td style={{padding:"8px 12px",color:C.amber,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{stats.unidades.toLocaleString()}</td>
                      <td style={{padding:"8px 12px",color:C.green,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{fmt(stats.ingreso)}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
        }
      </div>

      </>)}
    </div>
  );
}
