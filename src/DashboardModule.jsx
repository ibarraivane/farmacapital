import { useState, useEffect, useCallback, useRef, useMemo } from "react";
import { useMediaQuery } from "./hooks/useMediaQuery";
import { C_LIGHT, BRAND } from "./constants";
import { supabase } from "./supabase";
import { saludoUsuario, $ } from "./utils";
import { SkeletonKPIs, SkeletonTable, SkeletonCard, KPI, KPI_ROW, Box, Tag, Btn } from "./ui";
import { CONSULTA_PRECIO_DEFAULT } from "./utils/consultaConstants";
import { resumenLineasReceta } from "./utils/recetaLineas";
import TransaccionesTab from "./TransaccionesTab";
import { countPedidosTiendaPendientesHead } from "./utils/pedidosTiendaWeb";
import { rolEsAdmin } from "./utils/permissions";
import { fixLegacyFarmaxBrand } from "./utils/brandText";
import { parseRpcJsonArray, parseRpcJsonObject } from "./utils/rpcJson";
import { pedidoEsTipoFisica, pedidoEsTipoOnline, pedidoEsTipoConsulta } from "./utils/orderChannels";
import { costoLineaVenta, ingresoLineaVenta } from "./utils/margenVenta";
import { DIAS_CADUCIDAD_ALERTA } from "./lib/caducidad";
import VentasVsMetaChart from "./VentasVsMetaChart";
import { agruparVentasPorDia, porDiaDesdeSerieRpc, ymdMexico } from "./lib/ventasVsMeta";
import { addDaysISO, hoyISOMexico } from "./lib/fecha";
import { cargarConfigMetas, mezclarCfgMetas } from "./utils/turnosMetas";

function rpcBundleRows(bundle, key) {
  return parseRpcJsonArray(parseRpcJsonObject(bundle)[key]);
}

function rpcFirstRows(bundle, ...keys) {
  for (const key of keys) {
    const rows = rpcBundleRows(bundle, key);
    if (rows.length) return rows;
  }
  return [];
}

function ventasRowsOrFallback(primaryBundle, primaryKey, fallbackBundle, fallbackKey) {
  const primary = rpcBundleRows(primaryBundle, primaryKey);
  if (primary.length) return primary;
  return rpcBundleRows(fallbackBundle, fallbackKey);
}

function pedidosCompletados(rows) {
  return parseRpcJsonArray(rows).filter((p) => String(p.estado || "").toLowerCase() === "completado");
}

function sumPedidosTotal(pedidos) {
  return (pedidos || []).reduce((a, p) => a + parseFloat(p.total || 0), 0);
}

function loadDashboardInitialTab(fallback = "operacion") {
  try {
    const t = sessionStorage.getItem("farmacapital_dashboard_tab");
    if (t) sessionStorage.removeItem("farmacapital_dashboard_tab");
    if (t && [...DASHBOARD_TABS_DEFAULT, "proyecto"].includes(t)) return t;
  } catch { /* noop */ }
  return fallback;
}

const STORAGE_PROYECTO_CAPEX = "farmacapital_proyecto_capex_v1";

/** Valores iniciales del CAPEX (se pueden editar en UI; persisten en localStorage del navegador). */
const DEFAULT_PROYECTO_CAPEX_LINEAS = [
  { id: "capex-obra", label: "Construcción y acondicionamiento del local", nota: "Obra civil, instalaciones y acabados", monto: 464_999 },
  { id: "capex-mob-venta", label: "Mobiliario y equipamiento — área de venta", nota: "Mostrador, vitrinas, estantería, punto de venta", monto: 8_899 },
  { id: "capex-cons", label: "Equipamiento — consultorio médico", nota: "Mobiliario y equipo clínico", monto: 21_650 },
  { id: "capex-inv", label: "Inventario inicial de farmacia", nota: "Compra de stock de apertura", monto: 134_000 },
  { id: "capex-tram", label: "Trámites, licencias y gastos legales", nota: "Permisos, registros y asesoría", monto: 16_300 },
  { id: "capex-cont", label: "Contingencia e imprevistos", nota: "Reserva del proyecto", monto: 64_585 },
];

function cloneDefaultCapex() {
  return DEFAULT_PROYECTO_CAPEX_LINEAS.map((r) => ({ ...r }));
}

/** Normaliza filas guardadas (migración desde JSON sin `id`). */
function normalizeCapexRows(raw) {
  if (!Array.isArray(raw) || raw.length === 0) return cloneDefaultCapex();
  return raw.map((r, i) => ({
    id: String(r.id || `rubro-${i}-${(r.label || "").slice(0, 12)}`).replace(/\s+/g, "-"),
    label: String(r.label || "Rubro").trim() || "Rubro",
    nota: String(r.nota || "").trim(),
    monto: Math.max(0, Math.round((parseFloat(r.monto) || 0) * 100) / 100),
  }));
}

function loadCapexLineas() {
  try {
    const raw = localStorage.getItem(STORAGE_PROYECTO_CAPEX);
    if (!raw) return cloneDefaultCapex();
    const p = JSON.parse(raw);
    const lineas = Array.isArray(p) ? p : p.lineas;
    return normalizeCapexRows(lineas);
  } catch {
    return cloneDefaultCapex();
  }
}

function saveCapexLineas(lineas) {
  try {
    localStorage.setItem(STORAGE_PROYECTO_CAPEX, JSON.stringify({ lineas: normalizeCapexRows(lineas) }));
  } catch (e) {
    console.warn("[Dashboard] No se pudo guardar CAPEX:", e);
  }
}

function sumCapexMontos(lineas) {
  return normalizeCapexRows(lineas).reduce((a, r) => a + r.monto, 0);
}

/** Pestañas operativas; «Proyecto / inversión» va aparte para no mezclar CAPEX con el día a día. */
const DASHBOARD_TABS_DEFAULT = ["operacion", "resumen", "transacciones", "margen"];
const DASHBOARD_TAB_LABELS_MOBILE = {
  proyecto: "💼 Proyecto",
  operacion: "📊 Operación",
  resumen: "📈 Resumen",
  transacciones: "🔄 Movimientos",
  margen: "💹 Margen",
};
const DASHBOARD_TAB_LABELS = {
  proyecto: "💼 Proyecto Farma · inversión",
  operacion: "📊 Operación — farmacia",
  resumen: "📈 Resumen por período",
  transacciones: "🔄 Transacciones",
  margen: "💹 Margen por categoría",
};

function loadDashboardTabOrder() {
  try {
    const raw = localStorage.getItem("farmacapital_dashboard_tab_order");
    if (!raw) return [...DASHBOARD_TABS_DEFAULT];
    const p = JSON.parse(raw);
    if (!Array.isArray(p)) return [...DASHBOARD_TABS_DEFAULT];
    const sinProyecto = p.filter((id) => id !== "proyecto");
    const ok = sinProyecto.filter((id) => DASHBOARD_TABS_DEFAULT.includes(id));
    const miss = DASHBOARD_TABS_DEFAULT.filter((id) => !ok.includes(id));
    return [...ok, ...miss];
  } catch {
    return [...DASHBOARD_TABS_DEFAULT];
  }
}

const fmt     = (n) => `$${parseFloat(n||0).toLocaleString("es-MX",{minimumFractionDigits:2,maximumFractionDigits:2})}`;
const fmtK    = (n) => n>=1000?`$${(n/1000).toFixed(1)}k`:fmt(n);
const fmtDate = () => new Date().toLocaleDateString("es-MX",{weekday:"long",day:"2-digit",month:"long",year:"numeric"});

/** Grilla 2 columnas que en ventanas estrechas pasa a 1 columna (Chrome / escritorio redimensionado). */
const GRID_RESP_2COL = "repeat(auto-fit, minmax(min(100%, 280px), 1fr))";

const rangeToday = () => { const d=new Date(),y=d.getFullYear(),m=d.getMonth(),dd=d.getDate(); return {start:new Date(y,m,dd,0,0,0).toISOString(),end:new Date(y,m,dd,23,59,59).toISOString()}; };
const rangeWeek  = () => { const d=new Date(); d.setDate(d.getDate()-7); return {start:d.toISOString(),end:new Date().toISOString()}; };
const rangeMonth = () => { const d=new Date(),y=d.getFullYear(),m=d.getMonth(); return {start:new Date(y,m,1).toISOString(),end:new Date().toISOString()}; };
const rangeYesterday = () => { const d=new Date(),y=d.getFullYear(),m=d.getMonth(),dd=d.getDate()-1; return {start:new Date(y,m,dd,0,0,0).toISOString(),end:new Date(y,m,dd,23,59,59).toISOString()}; };
const rangeWeekPrev  = () => { const end=new Date(); end.setDate(end.getDate()-7); const start=new Date(end); start.setDate(start.getDate()-7); return {start:start.toISOString(),end:end.toISOString()}; };
const yesterdayLocal = () => addDaysISO(hoyISOMexico(), -1);

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
        <div key={i} style={{display:"flex",alignItems:"center",gap:12,flexWrap:"wrap"}}>
          <div style={{flex:"0 1 100px",minWidth:0,maxWidth:"100%",color:C.textMid,fontSize:12,textAlign:"right"}}>{d.label}</div>
          <div style={{flex:"1 1 120px",minWidth:80,background:C.bg,borderRadius:6,height:28,overflow:"hidden",position:"relative"}}>
            <div style={{position:"absolute",left:0,top:0,bottom:0,width:`${Math.max((d.value/max)*100,1)}%`,background:colorFn?colorFn(i):BRAND.gradient,borderRadius:6,transition:"width .6s ease",display:"flex",alignItems:"center",paddingLeft:8}}>
              {d.value>max*0.15&&<span style={{color:"#fff",fontSize:11,fontWeight:700}}>{fmtK(d.value)}</span>}
            </div>
            {d.value<=max*0.15&&<span style={{position:"absolute",left:`${(d.value/max)*100+1}%`,top:"50%",transform:"translateY(-50%)",color:C.textMid,fontSize:11,fontWeight:700}}>{fmtK(d.value)}</span>}
          </div>
          <div style={{flex:"0 1 auto",minWidth:0,color:C.text,fontSize:11,fontWeight:700}}>{fmt(d.value)}</div>
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
        {onAction && (
          <button type="button" onClick={onAction} style={{padding:"4px 10px",borderRadius:6,border:`1px solid ${mainCol}40`,background:"transparent",color:mainCol,cursor:"pointer",fontSize:10,fontWeight:700}}>
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
        <div style={{display:"grid",gridTemplateColumns:"repeat(auto-fill,minmax(min(100%,260px),1fr))",gap:10}}>
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

export default function DashboardModule({ usuario, setPage, showConfirm, initialTab }) {
  const C = C_LIGHT;
  const isMobileDash = useMediaQuery("(max-width: 768px)");
  const soloTransacciones = usuario?.rol === "vendedor";
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [panelTab, setPanelTab] = useState(() => loadDashboardInitialTab(initialTab || (soloTransacciones ? "transacciones" : "operacion")));
  const [tabOrder, setTabOrder] = useState(loadDashboardTabOrder);
  const dragTabId = useRef(null);
  const [periodo, setPeriodo] = useState("mes");
  const [rep, setRep] = useState(null);
  const [repLoading, setRepLoading] = useState(false);
  const [capexLineas, setCapexLineas] = useState(loadCapexLineas);
  const inversionTotal = useMemo(() => sumCapexMontos(capexLineas), [capexLineas]);
  const puedeEditarCapex = rolEsAdmin(usuario?.rol);

  useEffect(() => {
    saveCapexLineas(capexLineas);
  }, [capexLineas]);

  useEffect(() => {
    localStorage.setItem("farmacapital_dashboard_tab_order", JSON.stringify(tabOrder));
  }, [tabOrder]);

  const reorderTabs = (draggedId, targetId) => {
    if (!draggedId || !targetId || draggedId === targetId) return;
    setTabOrder((ord) => {
      const i = ord.indexOf(draggedId);
      const j = ord.indexOf(targetId);
      if (i < 0 || j < 0) return ord;
      const next = [...ord];
      next.splice(i, 1);
      next.splice(j, 0, draggedId);
      return next;
    });
  };

  const fetchAll = useCallback(async () => {
    setLoading(true);
    const today = rangeToday(), week = rangeWeek(), month = rangeMonth();
    const yesterday = rangeYesterday();
    const weekPrev = rangeWeekPrev();
    const hoyLocal = hoyISOMexico();
    const ayerLocal = yesterdayLocal();
    const inicioMesLocal = `${hoyLocal.slice(0, 7)}-01`;
    const cofeprisLimite = addDaysISO(hoyLocal, 30);
    const adminTok = sessionStorage.getItem("farmacapital_session_token");
    const cofeprisRpc = adminTok
      ? supabase.rpc("admin_alertas_cofepris_ventana", {
          p_session_token: adminTok,
          p_limite: cofeprisLimite,
          p_hoy: hoyLocal,
        })
      : Promise.resolve({ data: null, error: { message: "sin sesión" } });
    const bundleCtx = {
      today_start: today.start,
      today_end: today.end,
      yesterday_start: yesterday.start,
      yesterday_end: yesterday.end,
      week_start: week.start,
      week_prev_start: weekPrev.start,
      week_prev_end: weekPrev.end,
      month_start: month.start,
      month_prev_start: new Date(new Date().getFullYear(), new Date().getMonth() - 1, 1).toISOString(),
      month_prev_end: new Date(new Date().getFullYear(), new Date().getMonth(), 0, 23, 59, 59).toISOString(),
      hoy_local: hoyLocal,
      ayer_local: ayerLocal,
      inicio_mes_local: inicioMesLocal,
    };
    const desdeSerie = new Date();
    desdeSerie.setDate(desdeSerie.getDate() - 92);
    const desdeSerieYmd = ymdMexico(desdeSerie);
    const [
      bundleRes,
      homeRes,
      { count: onlinePendCount, error: errOnlinePend },
      { data: cofeprisRpcData, error: errAlertasCof },
      caducarRes,
      serieRes,
      metasTurnoCfg,
    ] = await Promise.all([
      adminTok
        ? supabase.rpc("empleado_dashboard_operacion_bundle", {
            p_session_token: adminTok,
            p_ctx: bundleCtx,
          })
        : Promise.resolve({ data: null, error: null }),
      adminTok
        ? supabase.rpc("empleado_admin_home_snapshot", {
            p_session_token: adminTok,
            p_hoy_local: hoyLocal,
            p_today_start: today.start,
            p_today_end: today.end,
            p_week_start: week.start,
            p_month_start: month.start,
          })
        : Promise.resolve({ data: null, error: null }),
      countPedidosTiendaPendientesHead(supabase, adminTok),
      cofeprisRpc,
      adminTok
        ? supabase.rpc("empleado_contar_por_caducar", {
            p_session_token: adminTok,
            p_dias: DIAS_CADUCIDAD_ALERTA,
          })
        : Promise.resolve({ data: null, error: null }),
      adminTok
        ? supabase.rpc("empleado_dashboard_ventas_serie", {
            p_session_token: adminTok,
            p_desde: desdeSerieYmd,
          })
        : Promise.resolve({ data: null, error: null }),
      cargarConfigMetas(),
    ]);
    const B = parseRpcJsonObject(bundleRes.data);
    const H = parseRpcJsonObject(homeRes.data);

    let ventasPorDia = porDiaDesdeSerieRpc(parseRpcJsonArray(serieRes?.data));
    if (!Object.keys(ventasPorDia).length) {
      if (serieRes?.error) console.warn("[Dashboard] ventas serie:", serieRes.error.message);
      if (adminTok) {
        const { data: raw90, error: err90 } = await supabase.rpc("empleado_listar_pedidos_transacciones", {
          p_session_token: adminTok,
          p_created_desde: new Date(Date.now() - 92 * 86400000).toISOString(),
          p_limite: 800,
        });
        if (err90) console.warn("[Dashboard] ventas serie fallback:", err90.message);
        ventasPorDia = agruparVentasPorDia(pedidosCompletados(raw90));
      }
    }

    // Totales desde el bundle (sin límite). ped_mes en vivo aún no trae
    // usuarios.nombre hasta aplicar sql/migrations/20260828_t3_ped_mes_empleado.sql
    const pedHoy = ventasRowsOrFallback(B, "ped_hoy", H, "ventas_hoy");
    const pedAyer = rpcBundleRows(B, "ped_ayer");
    const pedSemana = ventasRowsOrFallback(B, "ped_semana", H, "ventas_semana");
    const pedSemanaAnt = rpcBundleRows(B, "ped_semana_ant");
    const pedMes = ventasRowsOrFallback(B, "ped_mes", H, "ventas_mes");
    const pedTodos = rpcBundleRows(B, "ped_todos");
    const pedMesAnt = rpcBundleRows(B, "ped_mes_ant");
    const pedMesTipo = rpcBundleRows(B, "ped_mes_tipo");
    const pedItems = rpcBundleRows(B, "ped_items_top");
    const bajoStock = rpcBundleRows(B, "bajo_stock");
    const caducarJs = parseRpcJsonObject(caducarRes?.data);
    if (caducarRes?.error) console.warn("[Dashboard] por caducar 90d:", caducarRes.error.message);
    const porCaducar = caducarRes?.error
      ? rpcBundleRows(B, "por_caducar")
      : (Array.isArray(caducarJs.productos) ? caducarJs.productos : rpcBundleRows(B, "por_caducar"));
    const cortesConDif = rpcBundleRows(B, "cortes_con_dif");
    const pedRecetaFarmaCapital = rpcFirstRows(B, "ped_receta_farmacapital", "ped_receta_farmax");
    const citasRecetaExternaMes = B.citas_receta_ext_mes_count ?? 0;
    const cfgRows = rpcBundleRows(B, "cfg_rows");
    const citasKpiMes = rpcBundleRows(B, "citas_kpi_mes");
    const citasHoyRaw = rpcBundleRows(B, "citas_hoy");
    const citasHoy = citasHoyRaw.length ? citasHoyRaw : rpcBundleRows(H, "citas_completadas_hoy");
    const citasAyer = rpcBundleRows(B, "citas_ayer");
    const bundleErr = bundleRes.error;
    const homeErr = homeRes.error;
    if (bundleErr) console.warn("[Dashboard] bundle operación:", bundleErr.message);
    if (homeErr) console.warn("[Dashboard] home snapshot:", homeErr.message);

    const ventasMesTotal = (pedMes || []).reduce((a, p) => a + parseFloat(p.total || 0), 0);
    const ventasCargadas = (pedMes || []).length > 0 && ventasMesTotal > 0;
    const dashboardLoadWarning = !adminTok
      ? "Sesión expirada. Vuelve a iniciar sesión."
      : !ventasCargadas && bundleErr && homeErr
        ? "No se pudieron cargar ventas del dashboard. Revisa que los RPC estén aplicados en Supabase."
        : !ventasCargadas && (bundleErr || homeErr)
          ? "No se pudieron cargar ventas. Revisa la sesión o el listado de transacciones."
          : null;
    if (errOnlinePend) console.warn("[Dashboard] online pendientes:", errOnlinePend.message);
    if (errAlertasCof) console.warn("[Dashboard] alertas legales cofepris:", errAlertasCof.message);

    const alertasCofepris = Array.isArray(cofeprisRpcData?.items) ? cofeprisRpcData.items : [];

    const ventasHoy = (pedHoy || []).reduce((a, p) => a + parseFloat(p.total || 0), 0);
    const ventasAyer = (pedAyer || []).reduce((a, p) => a + parseFloat(p.total || 0), 0);
    const ventasSemana = (pedSemana || []).reduce((a, p) => a + parseFloat(p.total || 0), 0);
    const ventasSemanaAnt = (pedSemanaAnt || []).reduce((a, p) => a + parseFloat(p.total || 0), 0);
    const ventasMes = ventasMesTotal;
    const totalPedMes = (pedMes || []).length;
    const ticketProm = totalPedMes > 0 ? ventasMes / totalPedMes : 0;
    const recuperado = (pedTodos || []).reduce((a, p) => a + parseFloat(p.total || 0), 0);
    const gananciaMes = ventasMes * 0.55;
    const ventasMesAnt = (pedMesAnt || []).reduce((a, p) => a + parseFloat(p.total || 0), 0);
    const ticketPromMesAnt = (pedMesAnt || []).length > 0 ? ventasMesAnt / (pedMesAnt || []).length : 0;
    const crecimiento = ventasMesAnt > 0 ? ((ventasMes - ventasMesAnt) / ventasMesAnt * 100).toFixed(1) : null;

    const metas = {
      ventasDia:     parseMeta(cfgRows, "meta_ventas_dia", 4000),
      ventasSemana:  parseMeta(cfgRows, "meta_ventas_semana", 27200),
      ventasMes:     parseMeta(cfgRows, "meta_ventas_mes", 110000),
      ticketProm:    parseMeta(cfgRows, "meta_ticket_prom", 120),
      consultasDia:  parseMeta(cfgRows, "meta_consultas_dia", 6),
      consultasMes:  parseMeta(cfgRows, "meta_consultas_mes", 120),
    };
    const trends = {
      ventasHoy:     trendDelta(ventasHoy, ventasAyer),
      ventasSemana:  trendDelta(ventasSemana, ventasSemanaAnt),
      ventasMes:     trendDelta(ventasMes, ventasMesAnt),
      ticketProm:    trendDelta(ticketProm, ticketPromMesAnt),
      consultasHoy:  null,
    };

    const hoyISO = hoyISOMexico();
    const cofeprisItems = (alertasCofepris || []).map(a => ({
      id: a.id, nombre: fixLegacyFarmaxBrand(a.nombre), fecha: a.fecha_vencimiento,
      vencida: a.fecha_vencimiento && a.fecha_vencimiento < hoyISO,
    }));
    const cofeprisVencidas = cofeprisItems.filter(c => c.vencida).length;
    const cofeprisPorVencer = cofeprisItems.length;

    const fisica = (pedMesTipo || []).filter((p) => pedidoEsTipoFisica(p.tipo)).reduce((a, p) => a + parseFloat(p.total || 0), 0);
    const online2 = (pedMesTipo || []).filter((p) => pedidoEsTipoOnline(p.tipo)).reduce((a, p) => a + parseFloat(p.total || 0), 0);
    const consult = (pedMesTipo || []).filter((p) => pedidoEsTipoConsulta(p.tipo)).reduce((a, p) => a + parseFloat(p.total || 0), 0);

    const byEmp = {};
    (pedMes || []).forEach((p) => {
      const k = p.usuarios?.nombre || p.atendido_por || "Sin asignar";
      byEmp[k] = (byEmp[k] || 0) + parseFloat(p.total || 0);
    });
    const empleados = Object.entries(byEmp).sort((a, b) => b[1] - a[1]).slice(0, 5);

    const byProd = {};
    (pedItems || []).forEach((it) => { const n = it.productos?.nombre || "Producto"; if (!byProd[n]) byProd[n] = { unidades: 0, ingreso: 0 }; byProd[n].unidades += parseInt(it.cantidad || 1); byProd[n].ingreso += parseFloat(it.precio_unitario || 0) * parseInt(it.cantidad || 1); });
    const topProductos = Object.entries(byProd).sort((a, b) => b[1].unidades - a[1].unidades).slice(0, 10);

    const onlinePend = onlinePendCount ?? 0;
    const sinAtender = onlinePend;

    const ventasRecetaMedicoFarmaCapitalMes = (pedRecetaFarmaCapital || []).reduce((a, p) => a + parseFloat(p.total || 0), 0);
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

    const metasChartCfg = mezclarCfgMetas(metasTurnoCfg, cfgRows);

    setData({
      ventasPorDia, metasTurnoCfg: metasChartCfg,
      ventasHoy, ventasAyer, ventasSemana, ventasSemanaAnt, ventasMes, ventasMesAnt, crecimiento, ticketProm, consultasHoy, consultasAyer, onlinePend,
      recuperado, gananciaMes,
      dashboardLoadWarning,
      metas, trends,
      fuentes: [{ label: "Farmacia física", value: fisica }, { label: "Tienda online", value: online2 }, { label: "Consultorio", value: consult }],
      empleados, topProductos,
      ventasRecetaMedicoFarmaCapitalMes,
      nRecetasExternasMes,
      oportunidadPerdidaRecetaEst,
      estimadoRecetaExternaUnit: estimadoRecetaExterna,
      lineasRecetaFarmaCapital: lineasRec.farmacapital,
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
    const desdeFecha = addDaysISO(hoyISOMexico(), -dias);
    const sessionTok = sessionStorage.getItem("farmacapital_session_token");
    const [
      repBundleRes,
      { count: clientesNuevos },
    ] = await Promise.all([
      sessionTok
        ? supabase.rpc("empleado_dashboard_reporte_bundle", {
            p_session_token: sessionTok,
            p_desde: desde,
            p_desde_fecha: desdeFecha,
          })
        : Promise.resolve({ data: null }),
      sessionTok
        ? supabase.rpc("admin_contar_clientes_desde", { p_session_token: sessionTok, p_desde: desde }).then((r) => {
            if (r.error) console.warn("[Dashboard] admin_contar_clientes_desde:", r.error.message);
            return { count: r.error ? 0 : (r.data ?? 0) };
          })
        : Promise.resolve({ count: 0 }),
    ]);
    const RB = parseRpcJsonObject(repBundleRes.data);
    const peds = rpcBundleRows(RB, "peds");
    const cons = rpcBundleRows(RB, "cons");
    const ponl = rpcBundleRows(RB, "ponl");
    const devs = rpcBundleRows(RB, "devs");
    const pedsCat = rpcBundleRows(RB, "peds_cat");
    const pedsRecetaFarmaCapital = rpcFirstRows(RB, "peds_receta_farmacapital", "peds_receta_farmax");
    const citasRecetaExternaPeriod = RB.citas_receta_ext_period_count ?? 0;
    if (repBundleRes.error) console.warn("[Dashboard] reporte bundle:", repBundleRes.error.message);
    const totalDevoluciones = (devs || []).reduce((a, d) => a + parseFloat(d.total_devuelto || 0), 0);
    const margenCat = {};
    (pedsCat || []).forEach((ped) => {
      (ped.productos || []).forEach((item) => {
        const cat = item.productos?.categoria || "Sin categoría";
        const ingreso = ingresoLineaVenta(item);
        const costo = costoLineaVenta(item);
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
    const ventasRecetaFarmaCapitalPeriod = (pedsRecetaFarmaCapital || []).reduce((a, p) => a + parseFloat(p.total || 0), 0);
    const nExt = citasRecetaExternaPeriod ?? 0;
    setRep({
      ventas: peds || [], clientes: clientesNuevos ?? 0,
      consultas: cons?.length || 0, online: (ponl || []).reduce((a, p) => a + parseFloat(p.total || 0), 0),
      totalDevoluciones, margenPorCat, precioConsulta,
      ventasRecetaFarmaCapitalPeriod,
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
    <div style={{padding:"clamp(12px, 3vw, 24px)",overflowX:"hidden"}}>
      <SkeletonKPIs count={5}/>
      <div style={{display:"grid",gridTemplateColumns:GRID_RESP_2COL,gap:16,marginBottom:16}}>
        <SkeletonCard height={200}/>
        <SkeletonCard height={200}/>
      </div>
      <SkeletonTable rows={5} cols={4}/>
    </div>
  );

  const {ventasHoy,ventasSemana,ventasMes,crecimiento,ticketProm,consultasHoy,onlinePend,recuperado,gananciaMes,fuentes,empleados,topProductos,alertas,metas,trends,dashboardLoadWarning,ventasPorDia,metasTurnoCfg} = data;
  const pctRecuperado = inversionTotal > 0 ? Math.min((recuperado / inversionTotal) * 100, 100) : 0;
  const restante = inversionTotal - recuperado;
  const paybackMeses = gananciaMes > 0 ? Math.max(Math.ceil(restante / gananciaMes), 0) : null;
  const fracMes = fraccionMesTranscurrido();
  const metaVentasMesProrrateada = Math.round((metas?.ventasMes || 0) * fracMes);
  const metaConsultasMesProrrateada = Math.round((metas?.consultasMes || 0) * fracMes);
  const goToPage = (id, opts) => { if (setPage) setPage(id, opts); };
  const todoItems = [
    { id:"stock",    icon:"📦", count: alertas.bajoStock,      col: C.red,    label: "Reordenar productos",                sub: alertas.bajoStockNombres.join(", ") || "stock en 0",          onAction: () => goToPage("inv", {tab:"reabasto"}), actionLabel: "Ir a reabasto →" },
    { id:"caduca",   icon:"⏰", count: alertas.porCaducar,     col: C.amber,  label: `Próximos a caducar (${DIAS_CADUCIDAD_ALERTA} días)`,       sub: "Todavía alcanza a devolver, rematar o empujar en mostrador",                            onAction: () => goToPage("inv", {tab:"lotes"}), actionLabel: "Ver lotes →" },
    { id:"cortes",   icon:"💰", count: alertas.cortesConDif,   col: C.red,    label: "Cortes de caja con diferencia",       sub: "Revisa faltantes o sobrantes",                                onAction: () => goToPage("caja"), actionLabel: "Ver cortes →" },
    { id:"online",   icon:"🌐", count: alertas.sinAtender,     col: C.amber,  label: "Pedidos online pendientes",           sub: "Clientes esperando preparación",                              onAction: () => goToPage("pos", { posTab: "online" }), actionLabel: "Atender →" },
    { id:"cofepris", icon:"⚖️", count: alertas.cofeprisPorVencer, col: (alertas.cofeprisVencidas > 0 ? C.red : C.amber), label: alertas.cofeprisVencidas > 0 ? `COFEPRIS · ${alertas.cofeprisVencidas} vencido${alertas.cofeprisVencidas!==1?"s":""}` : "Documentos COFEPRIS por vencer", sub: (alertas.cofeprisItems||[]).slice(0,2).map(x=>x.nombre).join(" · "), onAction: () => goToPage("cof"), actionLabel: "Ver alertas →" },
  ];
  const roiCol = pctRecuperado>=75?C.green:pctRecuperado>=40?C.amber:C.red;
  const totalEmp = empleados.reduce((a,e)=>a+e[1],0);

  const updateCapexRow = (id, patch) => {
    setCapexLineas((rows) => normalizeCapexRows(rows.map((r) => (r.id === id ? { ...r, ...patch } : r))));
  };
  const removeCapexRow = (id) => {
    setCapexLineas((rows) => {
      const next = rows.filter((r) => r.id !== id);
      return next.length ? normalizeCapexRows(next) : cloneDefaultCapex();
    });
  };
  const addCapexRow = () => {
    const id = `rubro-${Date.now()}`;
    setCapexLineas((rows) => normalizeCapexRows([...rows, { id, label: "Nuevo rubro", nota: "", monto: 0 }]));
  };
  const resetCapexDefaults = () => {
    const run = () => {
      localStorage.removeItem(STORAGE_PROYECTO_CAPEX);
      setCapexLineas(cloneDefaultCapex());
    };
    if (showConfirm) showConfirm("Restaurar inversión del proyecto", "Se restaurarán los rubros y montos iniciales. Se perderá la personalización guardada en este navegador.", run, true);
    else if (window.confirm("¿Restaurar rubros y montos por defecto? Se borrará la versión guardada en este navegador.")) run();
  };
  const inpCapex = { width: "100%", maxWidth: "100%", padding: "6px 8px", borderRadius: 6, border: `1px solid ${C.border}`, fontSize: 12, color: C.text, background: C.card, boxSizing: "border-box" };

  const totalVentas = rep ? (rep.ventas||[]).reduce((a,p)=>a+parseFloat(p.total||0),0) : 0;
  const totalOnline = rep ? rep.online : 0;
  const ticketPromedio = rep && rep.ventas?.length ? totalVentas/rep.ventas.length : 0;
  const ingresoConsultas = rep ? rep.consultas * (rep.precioConsulta || CONSULTA_PRECIO_DEFAULT) : 0;
  const porEmpleado = rep ? rep.ventas.reduce((acc,p)=>{
    const nombre = p.usuarios?.nombre||"Sin asignar";
    acc[nombre]=(acc[nombre]||0)+parseFloat(p.total||0);
    return acc;
  },{}) : {};

  const tabsOperativas = soloTransacciones ? ["transacciones"] : tabOrder;

  return (
    <div style={{padding:"clamp(12px, 3vw, 24px)",background:C.bg,minHeight:"100dvh",fontFamily:"var(--fc-body)",overflowX:"hidden",overflowWrap:"break-word"}}>
      <div style={{display:"flex",justifyContent:"space-between",alignItems:"flex-start",marginBottom:16,flexWrap:"wrap",gap:12}}>
        <div style={{minWidth:0,flex:"1 1 200px"}}>
          <h1 style={{margin:0,color:C.text,fontSize:"clamp(17px, 2.5vw, 20px)",fontWeight:800,lineHeight:1.2}}>
            {soloTransacciones ? "◈ Transacciones" : "◈ Dashboard y reportes"}
          </h1>
          <p style={{margin:"4px 0 0",color:C.textMid,fontSize:12,textTransform:"capitalize"}}>{fmtDate()}</p>
        </div>
        <div style={{display:"flex",gap:10,alignItems:"center",flexShrink:0,flexWrap:"wrap"}}>
          <div style={{color:C.textMid,fontSize:12}}><strong style={{color:C.text}}>{saludoUsuario(usuario?.nombre)}</strong> 👋</div>
          <button type="button" onClick={()=>{ fetchAll(); if(panelTab==="resumen"||panelTab==="margen") fetchRep(); }} style={{padding:"7px 14px",borderRadius:8,border:`1px solid ${C.border}`,background:"transparent",color:C.textMid,cursor:"pointer",fontWeight:700,fontSize:12}}>🔄 Actualizar</button>
        </div>
      </div>

      <div style={{
        display:"flex",
        alignItems:"center",
        gap:8,
        flexWrap:isMobileDash?"nowrap":"wrap",
        marginBottom:20,
        borderBottom:`1px solid ${C.border}`,
        paddingBottom:12,
        overflowX:isMobileDash?"auto":"visible",
        WebkitOverflowScrolling:"touch",
        scrollbarWidth:"thin",
      }}>
        {!soloTransacciones && (
        <button
          type="button"
          onClick={()=>setPanelTab("proyecto")}
          style={{
            padding:"8px 14px",
            borderRadius:8,
            border:`1px solid ${panelTab==="proyecto"?BRAND.primary:C.border}`,
            background:panelTab==="proyecto"?BRAND.primary+"22":"transparent",
            color:panelTab==="proyecto"?BRAND.primary:C.textMid,
            fontWeight:700,
            fontSize:12,
            cursor:"pointer",
            whiteSpace:"nowrap",
            flexShrink:0,
          }}
        >
          {(isMobileDash?DASHBOARD_TAB_LABELS_MOBILE:DASHBOARD_TAB_LABELS).proyecto}
        </button>
        )}
        {!soloTransacciones && !isMobileDash && (
          <span style={{color:C.textDim,fontSize:11,marginRight:4,flexShrink:0}} title="Arrastra ⋮⋮ para cambiar el orden de las pestañas">Orden:</span>
        )}
        {tabsOperativas.map((id) => (
          <div
            key={id}
            style={{display:"flex",alignItems:"center",gap:2,flexShrink:0}}
            onDragOver={(e) => e.preventDefault()}
            onDrop={(e) => {
              e.preventDefault();
              const from = e.dataTransfer.getData("text/dashboard-tab") || dragTabId.current;
              reorderTabs(from, id);
              dragTabId.current = null;
            }}
          >
            {!soloTransacciones && !isMobileDash && (
              <span
                draggable
                onDragStart={(e) => {
                  dragTabId.current = id;
                  e.dataTransfer.setData("text/dashboard-tab", id);
                  e.dataTransfer.effectAllowed = "move";
                }}
                onDragEnd={() => { dragTabId.current = null; }}
                title="Arrastrar para reordenar pestañas"
                style={{
                  cursor: "grab",
                  color: C.textDim,
                  fontSize: 12,
                  padding: "6px 4px",
                  userSelect: "none",
                  lineHeight: 1,
                }}
                aria-hidden
              >⋮⋮</span>
            )}
            <button type="button" onClick={()=>setPanelTab(id)} style={{
              padding:"8px 14px",borderRadius:8,border:`1px solid ${panelTab===id?BRAND.primary:C.border}`,
              background:panelTab===id?BRAND.primary+"22":"transparent",color:panelTab===id?BRAND.primary:C.textMid,
              fontWeight:700,fontSize:12,cursor:"pointer",whiteSpace:"nowrap",
            }}>{(isMobileDash?DASHBOARD_TAB_LABELS_MOBILE:DASHBOARD_TAB_LABELS)[id]}</button>
          </div>
        ))}
      </div>

      {panelTab==="proyecto" && (
        <div>
          <p style={{ margin: "0 0 20px", color: C.textMid, fontSize: 13, lineHeight: 1.55, maxWidth: 720 }}>
            Indicadores <strong style={{ color: C.text }}>macro del proyecto</strong>: capital invertido en apertura (obra, mobiliario, stock inicial, trámites) y recuperación frente a ventas acumuladas.
            Para el día a día de mostrador, consultorio y metas, usa <strong style={{ color: C.text }}>Operación</strong> y <strong style={{ color: C.text }}>Resumen</strong>.
          </p>

          <div style={{ color: C.textDim, fontSize: 10, fontWeight: 700, letterSpacing: 1.2, marginBottom: 10 }}>DESGLOSE DE INVERSIÓN (CAPEX APERTURA)</div>
          {puedeEditarCapex ? (
            <div style={{ display: "flex", gap: 8, flexWrap: "wrap", marginBottom: 12, alignItems: "center" }}>
              <Btn sm col={BRAND.primary} onClick={addCapexRow}>+ Agregar rubro</Btn>
              <Btn sm ol col={C.textMid} onClick={resetCapexDefaults}>Restaurar valores por defecto</Btn>
              <span style={{ fontSize: 11, color: C.textDim, lineHeight: 1.4 }}>
                Los cambios se guardan en este navegador. La barra de recuperación y el payback usan la suma de la tabla.
              </span>
            </div>
          ) : (
            <p style={{ fontSize: 12, color: C.textMid, margin: "0 0 12px", lineHeight: 1.45 }}>
              Solo <strong style={{ color: C.text }}>administradores</strong> pueden editar rubros y montos. Si necesitas un cambio, pide que un admin actualice esta pestaña o edita los valores por defecto en código (<code style={{ fontSize: 11 }}>DEFAULT_PROYECTO_CAPEX_LINEAS</code>).
            </p>
          )}
          <Box style={{ padding: 0, marginBottom: 20, overflow: "auto" }}>
            <table style={{ width: "100%", minWidth: puedeEditarCapex ? 520 : 0, borderCollapse: "collapse", fontSize: 12 }}>
              <thead>
                <tr style={{ background: C.cardDark }}>
                  <th style={{ padding: "10px 14px", textAlign: "left", color: C.textMid, fontWeight: 700, borderBottom: `1px solid ${C.border}` }}>Concepto</th>
                  <th style={{ padding: "10px 14px", textAlign: "right", color: C.textMid, fontWeight: 700, borderBottom: `1px solid ${C.border}`, whiteSpace: "nowrap" }}>% del total</th>
                  <th style={{ padding: "10px 14px", textAlign: "right", color: C.textMid, fontWeight: 700, borderBottom: `1px solid ${C.border}`, whiteSpace: "nowrap" }}>Monto</th>
                  {puedeEditarCapex && (
                    <th style={{ padding: "10px 14px", textAlign: "center", color: C.textMid, fontWeight: 700, borderBottom: `1px solid ${C.border}`, width: 88 }}> </th>
                  )}
                </tr>
              </thead>
              <tbody>
                {capexLineas.map((row, i) => {
                  const pct = inversionTotal > 0 ? (row.monto / inversionTotal) * 100 : 0;
                  return (
                    <tr key={row.id} style={{ background: i % 2 === 0 ? "transparent" : C.bg }}>
                      <td style={{ padding: "10px 14px", borderBottom: `1px solid ${C.border}`, verticalAlign: "top" }}>
                        {puedeEditarCapex ? (
                          <>
                            <input value={row.label} onChange={(e) => updateCapexRow(row.id, { label: e.target.value })} style={{ ...inpCapex, fontWeight: 600, marginBottom: 6 }} />
                            <input value={row.nota} onChange={(e) => updateCapexRow(row.id, { nota: e.target.value })} placeholder="Nota / detalle" style={{ ...inpCapex, color: C.textMid, fontSize: 11 }} />
                          </>
                        ) : (
                          <>
                            <div style={{ color: C.text, fontWeight: 600 }}>{row.label}</div>
                            <div style={{ color: C.textDim, fontSize: 11, marginTop: 4, lineHeight: 1.35 }}>{row.nota}</div>
                          </>
                        )}
                      </td>
                      <td style={{ padding: "10px 14px", borderBottom: `1px solid ${C.border}`, textAlign: "right", color: C.textMid, fontWeight: 700 }}>{pct.toFixed(1)}%</td>
                      <td style={{ padding: "10px 14px", borderBottom: `1px solid ${C.border}`, textAlign: "right", color: C.blue, fontWeight: 800, verticalAlign: "middle" }}>
                        {puedeEditarCapex ? (
                          <input
                            type="number"
                            min={0}
                            step={1}
                            value={Number.isFinite(row.monto) ? row.monto : 0}
                            onChange={(e) => updateCapexRow(row.id, { monto: Math.max(0, parseFloat(e.target.value) || 0) })}
                            style={{ ...inpCapex, textAlign: "right", fontWeight: 800, maxWidth: 140, marginLeft: "auto", display: "block" }}
                          />
                        ) : (
                          $(row.monto)
                        )}
                      </td>
                      {puedeEditarCapex && (
                        <td style={{ padding: "10px 8px", borderBottom: `1px solid ${C.border}`, textAlign: "center", verticalAlign: "middle" }}>
                          <button
                            type="button"
                            title="Quitar rubro"
                            disabled={capexLineas.length <= 1}
                            onClick={() => removeCapexRow(row.id)}
                            style={{
                              padding: "4px 8px",
                              borderRadius: 6,
                              border: `1px solid ${C.red}40`,
                              background: C.redDim,
                              color: C.red,
                              fontSize: 10,
                              fontWeight: 700,
                              cursor: capexLineas.length <= 1 ? "not-allowed" : "pointer",
                              opacity: capexLineas.length <= 1 ? 0.45 : 1,
                            }}
                          >
                            Quitar
                          </button>
                        </td>
                      )}
                    </tr>
                  );
                })}
                <tr style={{ background: C.amberDim }}>
                  <td style={{ padding: "12px 14px", fontWeight: 800, color: C.text, fontSize: 13 }}>TOTAL INVERTIDO (PROYECTO)</td>
                  <td style={{ padding: "12px 14px", textAlign: "right", fontWeight: 800, color: C.text }}>100%</td>
                  <td style={{ padding: "12px 14px", textAlign: "right", fontWeight: 900, color: C.red, fontSize: 15 }}>{$(inversionTotal)}</td>
                  {puedeEditarCapex && <td style={{ padding: "12px 8px", background: C.amberDim }} />}
                </tr>
              </tbody>
            </table>
          </Box>

          <div style={{ color: C.textDim, fontSize: 10, fontWeight: 700, letterSpacing: 1.2, marginBottom: 10 }}>RETORNO Y RECUPERACIÓN (VS. VENTAS ACUMULADAS)</div>
          <div style={{ background: C.card, border: `1px solid ${roiCol}30`, borderRadius: 14, padding: 24, marginBottom: 16 }}>
            <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill,minmax(min(100%,180px),1fr))", gap: 20, marginBottom: 20 }}>
              <div><div style={{ color: C.textMid, fontSize: 11, fontWeight: 700, marginBottom: 4 }}>INVERSIÓN TOTAL</div><div style={{ color: C.text, fontWeight: 800, fontSize: 22 }}>{fmt(inversionTotal)}</div></div>
              <div><div style={{ color: C.textMid, fontSize: 11, fontWeight: 700, marginBottom: 4 }}>TOTAL RECUPERADO</div><div style={{ color: roiCol, fontWeight: 800, fontSize: 22 }}>{fmt(recuperado)}</div></div>
              <div><div style={{ color: C.textMid, fontSize: 11, fontWeight: 700, marginBottom: 4 }}>GANANCIA NETA EST. / MES</div><div style={{ color: C.green, fontWeight: 800, fontSize: 18 }}>{fmt(gananciaMes)}</div><div style={{ color: C.textDim, fontSize: 10, marginTop: 4 }}>Aprox. operativa (55% ventas del mes)</div></div>
              <div><div style={{ color: C.textMid, fontSize: 11, fontWeight: 700, marginBottom: 4 }}>PAYBACK RESTANTE</div><div style={{ color: restante <= 0 ? C.green : C.amber, fontWeight: 800, fontSize: 18 }}>{restante <= 0 ? "✅ Recuperada" : paybackMeses ? `~${paybackMeses} meses` : "Calculando…"}</div></div>
            </div>
            <div style={{ marginBottom: 8, display: "flex", justifyContent: "space-between" }}>
              <div style={{ color: C.textMid, fontSize: 12 }}>Progreso de recuperación vs. inversión total</div>
              <div style={{ color: roiCol, fontWeight: 800, fontSize: 18 }}>{pctRecuperado.toFixed(1)}%</div>
            </div>
            <div style={{ background: C.bg, borderRadius: 8, height: 20, overflow: "hidden" }}>
              <div style={{ height: "100%", width: `${pctRecuperado}%`, background: roiCol === C.green ? "linear-gradient(90deg,#00c46a,#00e87d)" : roiCol === C.amber ? "linear-gradient(90deg,#ffaa00,#ffd000)" : "linear-gradient(90deg,#ff3d5a,#ff6b7a)", borderRadius: 8, transition: "width 1s ease", display: "flex", alignItems: "center", justifyContent: "flex-end", paddingRight: 8 }}>
                {pctRecuperado > 15 && <span style={{ color: "#fff", fontSize: 10, fontWeight: 800 }}>{fmt(recuperado)}</span>}
              </div>
            </div>
            <div style={{ color: C.textDim, fontSize: 10, marginTop: 8, lineHeight: 1.45 }}>
              Recuperado {fmt(recuperado)} de {fmt(inversionTotal)} · Resta {fmt(Math.max(restante, 0))}.
              {puedeEditarCapex ? " Edita el desglose arriba; se guarda en localStorage de este equipo." : " El total invertido lo define un admin en la tabla de arriba (o los valores por defecto del sistema)."}
            </div>
          </div>
        </div>
      )}

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
              <div style={KPI_ROW}>
                <KPI label="Ventas totales" value={$(totalVentas)} col={C.blue} icon="💵"/>
                <KPI label="Ventas online" value={$(totalOnline)} col={C.teal} icon="🌐"/>
                <KPI label="Consultas" value={$(ingresoConsultas)} col={C.purple} icon="🏥" sub={`${rep.consultas} citas`}/>
                <KPI label="Ventas receta médico FarmaCapital" value={$(rep.ventasRecetaFarmaCapitalPeriod || 0)} col={C.purple} icon="📋" sub="POS en el período"/>
                <KPI label="Oportunidad perdida (est.)" value={$(rep.oportunidadPerdidaRecetaPeriod || 0)} col={(rep.nRecetasExternasPeriod || 0) > 0 ? C.amber : C.green} icon="📤" sub={`${rep.nRecetasExternasPeriod || 0} recetas fuera × ${fmt(rep.estimadoRecetaExternaUnit || 350)}`}/>
                <KPI label="Ticket promedio" value={$(ticketPromedio)} col={C.green} icon="🧾"/>
                <KPI label="Clientes nuevos" value={rep.clientes} col={C.amber} icon="👤"/>
              </div>
              <Box style={{padding:20,minWidth:0,marginBottom:16}}>
                <div style={{color:C.text,fontWeight:700,fontSize:14,marginBottom:16}}>📊 Ingresos por fuente</div>
                {[
                  ["Farmacia física", Math.max(0, totalVentas - totalOnline), C.blue],
                  ["Tienda en línea", totalOnline, C.teal],
                  ["Consultorio", ingresoConsultas, C.purple],
                ].map(([l,v,col])=>{
                  const totalFuentes = Math.max(0, totalVentas - totalOnline) + totalOnline + ingresoConsultas;
                  const pct = totalFuentes > 0 ? Math.round((v / totalFuentes) * 100) : 0;
                  return(
                    <div key={l} style={{marginBottom:12}}>
                      <div style={{display:"flex",justifyContent:"space-between",marginBottom:4}}>
                        <span style={{color:C.textMid,fontSize:12}}>{l}</span>
                        <span style={{color:col,fontWeight:700,fontSize:12,whiteSpace:"nowrap",fontVariantNumeric:"tabular-nums"}}>{$(v)}</span>
                      </div>
                      <div style={{background:C.border,borderRadius:4,height:8,overflow:"hidden"}}>
                        <div style={{width:`${pct}%`,height:"100%",background:col,borderRadius:4}}/>
                      </div>
                      <div style={{color:C.textDim,fontSize:10,marginTop:2}}>{pct}% del total</div>
                    </div>
                  );
                })}
              </Box>
              <Box style={{padding:20}}>
                <div style={{color:C.text,fontWeight:700,fontSize:14,marginBottom:14}}>👥 Ventas por empleado</div>
                {!Object.keys(porEmpleado).length?<div style={{color:C.textMid,fontSize:12}}>Sin datos en este periodo</div>:
                  Object.entries(porEmpleado).sort((a,b)=>b[1]-a[1]).map(([nombre,total])=>(
                    <div key={nombre} style={{display:"flex",justifyContent:"space-between",alignItems:"center",padding:"8px 0",borderBottom:`1px solid ${C.border}`}}>
                      <span style={{color:C.text,fontSize:13,fontWeight:600}}>{nombre}</span>
                      <div style={{display:"flex",gap:10,alignItems:"center"}}>
                        <span style={{color:C.green,fontWeight:800,fontSize:14,whiteSpace:"nowrap",fontVariantNumeric:"tabular-nums"}}>{$(total)}</span>
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
              <div style={KPI_ROW}>
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

      {dashboardLoadWarning && (
        <div style={{ background: "#fef3c7", border: "1px solid #fcd34d", borderRadius: 10, padding: "10px 14px", marginBottom: 14, fontSize: 12, color: "#92400e", lineHeight: 1.5 }}>
          ⚠️ {dashboardLoadWarning}
        </div>
      )}

      <div style={{color:C.textDim,fontSize:10,fontWeight:700,letterSpacing:1.5,marginBottom:12}}>KPIS ACCIONABLES · VENTAS Y ACTIVIDAD</div>
      <div style={{display:"grid",gridTemplateColumns:"repeat(auto-fill,minmax(min(100%,220px),1fr))",gap:12,marginBottom:16}}>
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
          onAction={() => goToPage("agenda")} actionLabel="Ir a la agenda →"
        />
        <InsightCard
          label="Online pendientes" icon="🌐" col={onlinePend>0?C.amber:C.green}
          value={onlinePend} display={onlinePend.toString()}
          onAction={() => goToPage("pos", { posTab: "online" })} actionLabel="Atender →"
        />
      </div>

      <VentasVsMetaChart
        porDia={ventasPorDia}
        cfg={metasTurnoCfg}
        hoyYmd={ymdMexico()}
        onEditarMetas={() => goToPage("config_cons")}
      />

      <div style={{display:"grid",gridTemplateColumns:GRID_RESP_2COL,gap:20,marginBottom:24}}>
        <div style={{background:C.card,border:`1px solid ${C.border}`,borderRadius:12,padding:20,minWidth:0}}>
          <div style={{color:C.textDim,fontSize:10,fontWeight:700,letterSpacing:1.5,marginBottom:16}}>INGRESOS POR FUENTE — ESTE MES</div>
          <BarChart data={fuentes} colorFn={(i)=>[`linear-gradient(90deg,${C.blue},${C.blueDark})`,`linear-gradient(90deg,${C.purple},#b57aff)`,`linear-gradient(90deg,${C.green},#00e87d)`][i]}/>
          <div style={{marginTop:14,borderTop:`1px solid ${C.border}`,paddingTop:12,display:"flex",justifyContent:"space-between"}}>
            <span style={{color:C.textMid,fontSize:11}}>Total mes</span>
            <span style={{color:C.text,fontWeight:800,fontSize:13}}>{fmt(fuentes.reduce((a,f)=>a+f.value,0))}</span>
          </div>
        </div>
        <div style={{background:C.card,border:`1px solid ${C.border}`,borderRadius:12,padding:20,minWidth:0}}>
          <div style={{color:C.textDim,fontSize:10,fontWeight:700,letterSpacing:1.5,marginBottom:16}}>VENTAS POR EMPLEADO — ESTE MES</div>
          {empleados.length===0
            ? <div style={{color:C.textMid,fontSize:12,textAlign:"center",padding:20}}>Sin datos este mes</div>
            : <table className="fc-tabla-compact" style={{width:"100%",borderCollapse:"collapse",fontSize:12}}>
                <thead><tr>{["Empleado","Ventas","%"].map(h=><th key={h} style={{padding:"6px 8px",textAlign:"left",color:C.textMid,fontWeight:700,borderBottom:`1px solid ${C.border}`,fontSize:10}}>{h}</th>)}</tr></thead>
                <tbody>
                  {empleados.map(([nombre,total],i)=>(
                    <tr key={i}>
                      <td data-label="Empleado" style={{padding:"8px",color:C.text,borderBottom:`1px solid ${C.border}`,fontWeight:600}}>{nombre}</td>
                      <td data-label="Ventas" className="fc-nowrap-money" style={{padding:"8px",color:C.green,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{fmt(total)}</td>
                      <td data-label="%" style={{padding:"8px",borderBottom:`1px solid ${C.border}`}}>
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
              <table className="fc-tabla-compact" style={{width:"100%",borderCollapse:"collapse",fontSize:12}}>
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
