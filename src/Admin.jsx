import React, { useState, useEffect, useRef, useCallback, lazy, Suspense } from "react";
import { useMediaQuery } from "./hooks/useMediaQuery";
import useSidebarBadges from "./hooks/useSidebarBadges";
import TicketVenta from "./components/tickets/TicketVenta";
import MercadoPagoModal from "./components/MercadoPagoModal";
import TicketPreviewModal from "./components/tickets/TicketPreviewModal";
import { printTicket } from "./utils/printTicket";
import { supabase } from "./supabase";
import { C as _C, C_LIGHT, BRAND, NEG, NAV_ADMIN, NAV_VENDEDOR, NAV_DOCTORA, NAV_ITEMS } from "./constants";
import { $, dC, cC, abc, aCol, nCol, hashPwd, hashPwdLegacy, generateSalt, logAudit, logMovimiento, primerNombre, saludoUsuario, normalizarSesionLoginResp } from "./utils";
import { Logo, Box, Tag, Btn, Inp, KPI, Modal, NotificacionesToast, showToast, ToastProvider, ConfirmDialog, SkeletonTable, SkeletonKPIs, SkeletonCard, Paginador, SearchDropdown, GlobalHoverStyles } from "./ui";
import { getSiguienteFolio } from "./utils/folioGenerator";
import { guardarVentaPendiente, sincronizarVentasPendientes, contarVentasPendientes } from "./utils/offlineQueue";
import { idEmpleadoUsuarios } from "./utils/usuarioId";
import { CONSULTA_PRECIO_DEFAULT, CONSULTA_PARTE_DOCTOR, repartoConsulta, citaPagoPendiente, citaPagoOk, citaEstaPagada, labelCanal } from "./utils/consultaConstants";
import { horariosDisponiblesCita, puedeCancelarCitaNoShow, addDaysSv, formatFechaAgendaLargaEs } from "./utils/citasAgenda";
import { fetchProductosConsumiblesConsultorio } from "./utils/consumiblesConsultorio";
import { esPedidoTiendaWebPendiente, fetchPedidosTiendaPendientesMerged } from "./utils/pedidosTiendaWeb";
import { CitaFichaModal } from "./CitaFichaDoctora";
import { desgloseCambioMN, sugerenciasPagoCliente } from "./utils/cambioCaja";
import { loadAdminNavOrder, saveAdminNavOrder, reorderNavIds, mergeAdminNavOrder, clearAdminNavOrder } from "./utils/adminNavOrder";
import { puedeVerModulo, modulosPermitidosParaRol } from "./utils/permissions";
import { marcarMedicamentosRecetaFarmaxSurtidos } from "./utils/recetaCitaSync";
import OnboardingTour from "./components/OnboardingTour";

// Fallback estático para estilos fuera de componentes (evita undefined en import).
const C = C_LIGHT;

// ── Lazy loading — módulos se cargan solo cuando se necesitan ──
const RRHHModule       = lazy(()=>import("./RRHHModule"));
const InventarioHub    = lazy(()=>import("./InventarioHub"));
const MiDia            = lazy(()=>import("./MiDia"));
const CorteCajaModule  = lazy(()=>import("./CorteCajaModule"));
const ClientesModule   = lazy(()=>import("./ClientesModule"));
const ConsultorioModule= lazy(()=>import("./ConsultorioModule"));
const ConfigConsultorioModule = lazy(()=>import("./ConfigConsultorioModule"));
const COFEPRISModule   = lazy(()=>import("./COFEPRISModule"));
const AsistenteIA      = lazy(()=>import("./AsistenteIA"));
const PromocionesModule= lazy(()=>import("./PromocionesModule"));
const DevolucionesModule=lazy(()=>import("./DevolucionesModule"));
const FacturacionModule= lazy(()=>import("./FacturacionModule"));
const DashboardModule  = lazy(()=>import("./DashboardModule"));
const InstalarPWA      = lazy(()=>import("./InstalarPWA"));

// ── ErrorBoundary para módulos lazy ──────────────────────────
class ModuleErrorBoundary extends React.Component {
  constructor(props) { super(props); this.state = { hasError:false, error:null }; }
  static getDerivedStateFromError(error) { return { hasError:true, error }; }
  componentDidCatch(error, info) { console.error("[Farmax] Error en módulo:", error, info); }
  render() {
    if(this.state.hasError) return(
      <div style={{padding:40,textAlign:"center"}}>
        <div style={{fontSize:48,marginBottom:16}}>⚠️</div>
        <div style={{color:"#0f172a",fontWeight:700,fontSize:16,marginBottom:8}}>Error al cargar este módulo</div>
        <div style={{color:"#475569",fontSize:12,marginBottom:20,maxWidth:400,margin:"0 auto 20px",fontFamily:"monospace",background:"#f8fafc",padding:"8px 12px",borderRadius:6}}>{this.state.error?.message}</div>
        <button onClick={()=>this.setState({hasError:false,error:null})}
          style={{padding:"9px 20px",borderRadius:8,border:"none",background:"linear-gradient(135deg,#0052cc,#0099e6)",color:"#fff",fontWeight:700,cursor:"pointer"}}>
          🔄 Reintentar
        </button>
      </div>
    );
    return this.props.children;
  }
}

// ── Skeleton loader para módulos cargando ─────────────────────
function ModuleSkeleton() {
  const C = C_LIGHT;
  return (
    <div style={{padding:40,display:"flex",flexDirection:"column",gap:16,animation:"pulse 1.5s infinite"}}>
      {[1,2,3].map(i=>(
        <div key={i} style={{height:i===1?40:80,borderRadius:12,background:"linear-gradient(90deg,#f0f4f9 25%,#e2e8f0 50%,#f0f4f9 75%)",backgroundSize:"200% 100%"}}/>
      ))}
      <style>{`@keyframes pulse{0%,100%{opacity:1}50%{opacity:.7}}`}</style>
    </div>
  );
}
// ═══════════════════════════════════════════════════════════════
// FARMAX — Sistema Admin v2
// Login por perfil · Admin · Vendedor · Doctora
// Conectado a Supabase + Tienda en línea
// ═══════════════════════════════════════════════════════════════

// ← constantes movidas a src/constants.js
// ← utils movidos a src/utils.js
// ← NotificacionesToast movido a src/ui.jsx

// ← logAudit y logMovimiento movidos a src/utils.js

// ← hashPwd movido a src/utils.js

// ← UI base (Logo,Box,Tag,Btn,Inp,KPI,Modal) movidos a src/ui.jsx

// ── PUENTE ONLINE ─────────────────────────────────────────────
function PuenteOnline({count,label,color}){
  const C = C_LIGHT;
  if(!count) return null;
  return(
    <div style={{background:color+"12",border:`1px solid ${color}30`,borderRadius:10,padding:"10px 16px",display:"flex",alignItems:"center",gap:12,marginBottom:12}}>
      <div style={{width:8,height:8,borderRadius:"50%",background:color,flexShrink:0}}/>
      <div style={{flex:1,color:C.text,fontSize:13,fontWeight:700}}>{label}</div>
      <span style={{background:color,color:"#fff",borderRadius:20,padding:"2px 10px",fontSize:11,fontWeight:800}}>{count}</span>
    </div>
  );
}

// ══════════════════════════════════════════════════════════════
// PANTALLA LOGIN
// ══════════════════════════════════════════════════════════════
function LoginScreen({onLogin}){
  const C = C_LIGHT;
  const [email,setEmail] = useState("");
  const [pwd,setPwd]     = useState("");
  const [error,setError] = useState("");
  const [errorDetail,setErrorDetail] = useState("");
  const [loading,setLoad]= useState(false);

  const entrar = async () => {
    if(!email||!pwd) return;
    if(pwd.length < 6) { setError("La contraseña debe tener al menos 6 caracteres."); return; }
    const idNorm = email.trim().toLowerCase();

    const bloqueoKey  = "farmax_login_bloqueo_"+idNorm;
    const intentosKey = "farmax_login_intentos_"+idNorm;
    const bloqueoHasta = localStorage.getItem(bloqueoKey);
    if(bloqueoHasta && Date.now() < parseInt(bloqueoHasta)) {
      const mins = Math.ceil((parseInt(bloqueoHasta)-Date.now())/60000);
      setError(`Demasiados intentos. Intenta en ${mins} minuto${mins>1?"s":""}.`);
      return;
    }

    setLoad(true); setError(""); setErrorDetail("");
    try {
      const { data: raw, error: rpcErr } = await supabase.rpc("login_empleado", {
        p_identificador: idNorm,
        p_password:      pwd,
        p_user_agent:    navigator.userAgent || null,
      });

      if (rpcErr) {
        const tech = rpcErr.message || String(rpcErr);
        const low = tech.toLowerCase();
        let msg = "No pudimos conectar con el servidor de datos.";
        if (low.includes("failed to fetch") || low.includes("network")) {
          msg = "No hay conexión a internet o la dirección del servidor no coincide con tu proyecto en Supabase.";
        } else if (rpcErr.code === "PGRST202" || low.includes("could not find the function")) {
          msg = "Falta actualizar la base de datos (función de inicio de sesión no encontrada).";
        } else if (rpcErr.code === "42501" || low.includes("permission denied")) {
          msg = "El servidor rechazó el inicio de sesión por permisos. Hay que reaplicar los permisos de la función login en Supabase.";
        }
        setError(msg);
        setErrorDetail(tech.length > 120 ? tech.slice(0, 120) + "…" : tech);
        setLoad(false);
        return;
      }

      const resp = normalizarSesionLoginResp(raw);

      if (!resp?.success) {
        const intentos = parseInt(localStorage.getItem(intentosKey)||"0") + 1;
        localStorage.setItem(intentosKey, intentos);
        if (intentos >= 5) {
          localStorage.setItem(bloqueoKey, Date.now() + 15*60*1000);
          localStorage.removeItem(intentosKey);
          setError("Cuenta bloqueada 15 minutos por demasiados intentos.");
        } else {
          setError(`${resp?.error || "Credenciales inválidas"} (${intentos}/5)`);
        }
        setLoad(false);
        return;
      }

      localStorage.removeItem(intentosKey);
      localStorage.removeItem(bloqueoKey);

      if (!resp.session_token) {
        setError("La base respondió bien pero sin token de sesión. Revisa la versión del código y de la función login_empleado.");
        setLoad(false);
        return;
      }

      const u = resp.user || {};
      const data = {
        id:             u.id,
        nombre:         u.nombre || idNorm,
        email:          u.email || null,
        telefono:       u.telefono || "",
        rol:            u.rol || "vendedor",
        activo:         true,
        loginTimestamp: Date.now(),
      };

      sessionStorage.setItem("farmax_session_token", String(resp.session_token));
      sessionStorage.setItem("farmax_admin_user", JSON.stringify(data));
      localStorage.setItem("farmax_last_login_"+data.id, new Date().toLocaleString("es-MX"));
      onLogin(data);
    } catch(e) {
      setError("No pudimos conectar. Revisa tu internet o vuelve a intentar en unos segundos.");
      setErrorDetail(e?.message ? String(e.message) : "");
    }
    setLoad(false);
  };

  return(
    <div style={{minHeight:"100vh",background:"linear-gradient(135deg,#f0f4ff 0%,#f7f9fc 50%,#e8f4fd 100%)",display:"flex",alignItems:"center",justifyContent:"center",padding:"clamp(12px,4vw,20px)",boxSizing:"border-box",overflowX:"hidden"}}>
      <div style={{width:"100%",maxWidth:400,minWidth:0}}>
        <div style={{textAlign:"center",marginBottom:32}}>
          <div style={{display:"flex",justifyContent:"center",marginBottom:16}}><Logo size={48}/></div>
          <div style={{color:C.textMid,fontSize:14}}>Sistema de gestión · Acceso interno</div>
        </div>
        <Box style={{padding:32,boxShadow:"0 4px 24px rgba(0,82,204,.10)"}}>
          <div style={{color:C.text,fontWeight:800,fontSize:18,marginBottom:24}}>Iniciar sesión</div>
          <div style={{marginBottom:14}}>
            <div style={{color:C.textMid,fontSize:11,marginBottom:6,fontWeight:700}}>EMAIL</div>
            <Inp value={email} onChange={e=>setEmail(e.target.value)} placeholder="tu@email.com" type="email" style={{width:"100%",boxSizing:"border-box"}}/>
          </div>
          <div style={{marginBottom:20}}>
            <div style={{color:C.textMid,fontSize:11,marginBottom:6,fontWeight:700}}>CONTRASEÑA</div>
            <Inp value={pwd} onChange={e=>setPwd(e.target.value)} onKeyDown={e=>e.key==="Enter"&&entrar()} placeholder="••••••••" type="password" style={{width:"100%",boxSizing:"border-box"}}/>
          </div>
          {error&&<div style={{background:C.redDim,border:`1px solid ${C.red}30`,borderRadius:8,padding:"10px 12px",marginBottom:16,color:C.red,fontSize:13}}>
            <div>{error}</div>
            {errorDetail ? <div style={{marginTop:8,fontSize:11,opacity:0.9,wordBreak:"break-word"}}>{errorDetail}</div> : null}
          </div>}
          <Btn onClick={entrar} full col={BRAND.primary} dis={!email||!pwd||loading}>{loading?"Verificando...":"Entrar →"}</Btn>
          <div style={{marginTop:16,textAlign:"center"}}>
            <div style={{fontSize:11,color:C.textDim,textAlign:"center"}}>
              ¿Olvidaste tu contraseña?{" "}
              <span
                style={{color:C.blue,cursor:"pointer",textDecoration:"underline",fontWeight:600}}
                onClick={async()=>{
                  const contacto = email.trim()||"";
                  if(!contacto){ alert("Escribe tu email o teléfono primero."); return; }
                  try {
                    const { data:resp, error:err } = await supabase.rpc("solicitar_reset_password", {
                      p_identificador: contacto,
                      p_mensaje: `Solicitud de reset desde login de admin.`,
                      p_user_agent: navigator.userAgent,
                    });
                    if (err || !resp?.success) throw new Error(resp?.error || err?.message || "Error");
                    alert("✅ Solicitud enviada. El administrador te contactará.");
                  } catch(e) {
                    alert("Contacta directamente a: ibarra.ivan@outlook.com");
                  }
                }}>
                Contacta al admin
              </span>
            </div>
          </div>
        </Box>
      </div>
    </div>
  );
}

// ══════════════════════════════════════════════════════════════
// SIDEBAR
// ══════════════════════════════════════════════════════════════
function SidebarBadge({count, critical}) {
  if (!count) return null;
  const C = C_LIGHT;
  const col = critical ? C.red : C.amber;
  const txt = count > 99 ? "99+" : String(count);
  return (
    <span
      title={`${count} pendiente${count!==1?"s":""}`}
      style={{
        minWidth: 18, height: 18, padding: "0 5px",
        display: "inline-flex", alignItems: "center", justifyContent: "center",
        background: col, color: "#fff",
        borderRadius: 999, fontSize: 10, fontWeight: 800,
        marginLeft: "auto", flexShrink: 0, letterSpacing: .2,
      }}
    >{txt}</span>
  );
}

function Sidebar({active,setActive,negocio,setNegocio,usuario,onLogout,alertas,ventasOffline=0,mobile=false,navOpen=false,badgeCounts={},badgeCritical={}}){
  const C = C_LIGHT;
  const isAdmin = usuario.rol==="admin";
  const [adminOrder, setAdminOrder] = useState(() => (isAdmin ? loadAdminNavOrder(usuario) : null));
  const [draggingId, setDraggingId] = useState(null);
  const [dragOverId, setDragOverId] = useState(null);
  /** Evita que el clic después de arrastrar active la misma fila. */
  const skipClickForIdRef = useRef(null);

  useEffect(() => {
    if (!isAdmin) {
      setAdminOrder(null);
      return;
    }
    setAdminOrder(loadAdminNavOrder(usuario));
  }, [isAdmin, usuario?.id]);

  // Si el usuario tiene modulos_custom configurado, respétalo por encima del default del rol.
  // (Un admin no puede recibir modulos_custom restringido — siempre ve todo su NAV_ADMIN.)
  const customActivos = Array.isArray(usuario.modulos_custom?.activos) ? usuario.modulos_custom.activos : null;
  const navIdsRaw = isAdmin
    ? (adminOrder ?? NAV_ADMIN)
    : (customActivos && customActivos.length > 0)
      ? customActivos
      : usuario.rol==="vendedor"
        ? NAV_VENDEDOR
        : NAV_DOCTORA;
  // Defensa en profundidad: aunque alguien haya guardado un módulo prohibido
  // en modulos_custom, filtramos aquí contra la whitelist del rol.
  const navIds = isAdmin ? navIdsRaw : navIdsRaw.filter((id) => puedeVerModulo(usuario, id));
  const navItems = navIds.map((id) => NAV_ITEMS.find((n) => n.id === id)).filter(Boolean);
  const rolColor = usuario.rol==="admin"?C.purple:usuario.rol==="vendedor"?C.blue:C.green;

  const onNavDrop = (e, targetId) => {
    e.preventDefault();
    e.stopPropagation();
    const fromId = (e.dataTransfer.getData("application/x-farmax-nav") || e.dataTransfer.getData("text/plain") || "").trim();
    if (!fromId || fromId === targetId) {
      setDraggingId(null);
      setDragOverId(null);
      return;
    }
    setAdminOrder((prev) => {
      const base = prev ?? [...NAV_ADMIN];
      const next = reorderNavIds(base, fromId, targetId);
      saveAdminNavOrder(usuario, next);
      return next;
    });
    setDraggingId(null);
    setDragOverId(null);
  };

  const handleNavDragOver = (e, rowId) => {
    e.preventDefault();
    e.dataTransfer.dropEffect = "move";
    setDragOverId(rowId);
  };

  return(
    <div style={{
      width:220,height:"100vh",maxHeight:"100vh",flexShrink:0,background:C.card,borderRight:`1px solid ${C.border}`,
      boxShadow: mobile?"4px 0 24px rgba(0,0,0,.12)":"2px 0 8px rgba(0,0,0,.06)",
      display:"flex",flexDirection:"column",position:"fixed",left:mobile?(navOpen?0:-220):0,top:0,
      zIndex:mobile?1001:100,overflow:"hidden",transition:"left .22s ease",
    }}>
      <div style={{padding:"18px 14px 14px",borderBottom:`1px solid ${C.border}`}}>
        <Logo size={32} showText={true}/>
      {usuario.rol==="admin"&&(
          <div style={{display:"flex",gap:4,marginTop:12}}>
            {/* MINISUPER OCULTO — segunda fase
            {Object.entries(NEG).map(([k,n])=>(
              <button key={k}>...</button>
            ))}
            */}
          </div>
      )}
      </div>

      {/* Usuario actual */}
      <div style={{padding:"10px 14px",borderBottom:`1px solid ${C.border}`,display:"flex",alignItems:"center",gap:10}}>
        <div style={{width:32,height:32,borderRadius:"50%",background:rolColor+"30",border:`1px solid ${rolColor}40`,display:"flex",alignItems:"center",justifyContent:"center",color:rolColor,fontWeight:800,fontSize:13,flexShrink:0}}>
          {(primerNombre(usuario.nombre)||"U")[0].toUpperCase()}
        </div>
        <div style={{flex:1,minWidth:0}}>
          <div style={{color:C.text,fontWeight:700,fontSize:12,overflow:"hidden",textOverflow:"ellipsis",whiteSpace:"nowrap"}}>{saludoUsuario(usuario.nombre)}</div>
          <Tag col={rolColor} sm>{usuario.rol}</Tag>
        </div>
      </div>

      <div style={{flex:1,padding:"8px 8px",overflowY:"auto",scrollbarWidth:"thin",scrollbarColor:`${BRAND.primary}30 transparent`}}>
        {navItems.map((n) => {
          const rowActive = active === n.id;
          const rowDrop = isAdmin && dragOverId === n.id && draggingId && draggingId !== n.id;
          const btnStyle = {
            flex:1,minWidth:0,
            display:"flex",alignItems:"center",gap:10,
            padding:"8px 10px",borderRadius:8,border:"none",cursor:"pointer",
            textAlign:"left",fontSize:12,fontWeight:600,fontFamily:"'Plus Jakarta Sans',sans-serif",
            background:rowActive?BRAND.primary+"18":"transparent",
            color:rowActive?BRAND.primary:C.textMid,
            borderLeft:`3px solid ${rowActive?BRAND.primary:"transparent"}`,
            transition:"all .15s",
          };
          if (!isAdmin) {
            return (
              <button key={n.id} onClick={()=>setActive(n.id)}
                onMouseEnter={e=>{if(!rowActive){e.currentTarget.style.background=BRAND.primary+"10";e.currentTarget.style.color=BRAND.primary;e.currentTarget.style.borderLeftColor=BRAND.primary+"50";}}}
                onMouseLeave={e=>{if(!rowActive){e.currentTarget.style.background="transparent";e.currentTarget.style.color=C.textMid;e.currentTarget.style.borderLeftColor="transparent";}}}
                style={{...btnStyle,width:"100%",marginBottom:2}}>
                <span style={{width:18,height:18,display:"inline-flex",alignItems:"center",justifyContent:"center",flexShrink:0}}>
                  {typeof n.icon === "string"
                    ? <span style={{fontSize:12}}>{n.icon}</span>
                    : n.icon ? <n.icon size={16} strokeWidth={2.1} /> : null}
                </span>
                <span style={{overflow:"hidden",textOverflow:"ellipsis",whiteSpace:"nowrap",flex:1}}>{n.label}</span>
                <SidebarBadge count={badgeCounts[n.id]} critical={badgeCritical[n.id]} />
              </button>
            );
          }
          return (
            <div
              key={n.id}
              draggable
              role="row"
              aria-grabbed={draggingId===n.id}
              onDragStart={(e)=>{
                e.dataTransfer.setData("text/plain", n.id);
                e.dataTransfer.setData("application/x-farmax-nav", n.id);
                e.dataTransfer.effectAllowed = "move";
                setDraggingId(n.id);
              }}
              onDragEnd={()=>{
                skipClickForIdRef.current = n.id;
                setDraggingId(null);
                setDragOverId(null);
                window.setTimeout(() => {
                  if (skipClickForIdRef.current === n.id) skipClickForIdRef.current = null;
                }, 400);
              }}
              onDragOver={(e)=>handleNavDragOver(e, n.id)}
              onDragLeave={(e)=>{ if (!e.currentTarget.contains(e.relatedTarget)) setDragOverId((d)=>d===n.id?null:d); }}
              onDrop={(e)=>onNavDrop(e, n.id)}
              onClick={(e)=>{
                if (skipClickForIdRef.current === n.id) {
                  skipClickForIdRef.current = null;
                  e.preventDefault();
                  return;
                }
                setActive(n.id);
              }}
              style={{
                display:"flex",alignItems:"stretch",gap:0,marginBottom:2,width:"100%",
                borderRadius:8,
                outline:rowDrop?`2px dashed ${BRAND.primary}`:"none",
                outlineOffset:1,
                opacity:draggingId===n.id?0.55:1,
                cursor:draggingId===n.id?"grabbing":"grab",
                userSelect:"none",
              }}
            >
              <div style={{...btnStyle,width:"100%",margin:0}}>
                <span style={{width:18,height:18,display:"inline-flex",alignItems:"center",justifyContent:"center",flexShrink:0}}>
                  {typeof n.icon === "string"
                    ? <span style={{fontSize:12}}>{n.icon}</span>
                    : n.icon ? <n.icon size={16} strokeWidth={2.1} /> : null}
                </span>
                <span style={{overflow:"hidden",textOverflow:"ellipsis",whiteSpace:"nowrap",flex:1}}>{n.label}</span>
                <SidebarBadge count={badgeCounts[n.id]} critical={badgeCritical[n.id]} />
              </div>
            </div>
          );
        })}
        {isAdmin && (
          <button
            type="button"
            onClick={()=>{
              clearAdminNavOrder(usuario);
              setAdminOrder(mergeAdminNavOrder(null));
              showToast("Orden del menú restaurado", "info");
            }}
            style={{
              width:"100%",marginTop:10,padding:"6px 8px",borderRadius:8,
              border:`1px dashed ${C.border}`,background:"transparent",color:C.textDim,
              fontSize:10,fontWeight:600,cursor:"pointer",
            }}
          >
            Restaurar orden predeterminado
          </button>
        )}
      </div>

      {/* Alertas y logout */}
      <div style={{padding:"0 8px 16px"}}>
        {/* "bajo stock" ahora se muestra como badge junto a Inventario en el sidebar. */}
        {alertas.pedidos>0&&<div style={{background:C.blueDim,border:`1px solid ${C.blue}20`,borderRadius:8,padding:"8px 12px",marginBottom:6}}><div style={{color:C.blue,fontSize:11,fontWeight:700}}>🌐 {alertas.pedidos} pedidos online</div></div>}
        {alertas.citas>0&&<div style={{background:C.greenDim,border:`1px solid ${C.green}20`,borderRadius:8,padding:"8px 12px",marginBottom:6}}><div style={{color:C.green,fontSize:11,fontWeight:700}}>📅 {alertas.citas} citas nuevas</div></div>}
        {ventasOffline>0&&(
          <div style={{background:C.amberDim,border:`1px solid ${C.amber}30`,borderRadius:8,padding:"6px 10px",marginBottom:4,fontSize:10,color:C.amber,fontWeight:700,textAlign:"center"}}>
            📵 {ventasOffline} venta{ventasOffline>1?"s":""} offline pendiente{ventasOffline>1?"s":""}
          </div>
        )}
        <button onClick={onLogout} style={{width:"100%",padding:"7px",borderRadius:8,border:`1px solid ${C.border}`,background:"transparent",color:C.textMid,fontSize:11,fontWeight:700,cursor:"pointer",marginTop:4}}>⎋ Cerrar sesión</button>
      </div>
    </div>
  );
}

// ══════════════════════════════════════════════════════════════
// DASHBOARD (Admin)
// ══════════════════════════════════════════════════════════════
function Dashboard({negocio,alertas,setPage}){
  const C = C_LIGHT;
  const [kpis,setKpis]       = useState({hoy:0,semana:0,mes:0,consultas:0});
  const [pedOnline,setPedOn] = useState([]);
  const [citasHoy,setCitasH] = useState([]);
  const [loading,setLoad]    = useState(true);

  useEffect(()=>{
    const cargar = async () => {
      setLoad(true);
      try {
        const hoyLocal = new Date().toLocaleDateString("sv-SE");
        const t0 = new Date();
        t0.setHours(0, 0, 0, 0);
        const t1 = new Date();
        t1.setHours(23, 59, 59, 999);
        const weekAgo = new Date(Date.now() - 7 * 86400000);
        const monthStart = new Date(new Date().getFullYear(), new Date().getMonth(), 1);

        const pedidosTiendaSelect = `
            id,total,created_at,tipo,metodo_pago,estado,
            clientes(nombre,telefono),
            pedido_items(cantidad,precio_unitario,productos(nombre,sku))
          `;
        const [
          pedsRes,
          citasRes,
          ventasHoyRes,
          ventasSemanaRes,
          ventasMesRes,
          citasComplRes,
        ] = await Promise.all([
          fetchPedidosTiendaPendientesMerged(supabase, pedidosTiendaSelect, { perBranchLimit: 80, maxRows: 200 }),
          supabase.from("citas").select(`
            id,nombre,telefono,hora,fecha,motivo,estado,pago_estado,
            consumibles_consulta!cita_id(id,cantidad,precio,cobrado,productos!producto_id(nombre))
          `).eq("fecha", hoyLocal).in("estado",["confirmada","en_consulta","completada","pagada"]),
          supabase.from("pedidos").select("total").eq("estado","completado").gte("created_at", t0.toISOString()).lte("created_at", t1.toISOString()),
          supabase.from("pedidos").select("total").eq("estado","completado").gte("created_at", weekAgo.toISOString()),
          supabase.from("pedidos").select("total").eq("estado","completado").gte("created_at", monthStart.toISOString()),
          supabase.from("citas").select("id").eq("fecha", hoyLocal).neq("estado", "cancelada").or("estado.eq.completada,estado.eq.pagada,pago_estado.eq.pagada"),
        ]);

        if (pedsRes?.error) console.error("[Dashboard] Pedidos:", pedsRes.error);
        if (citasRes?.error) console.error("[Dashboard] Citas:", citasRes.error);
        if (citasComplRes?.error) console.warn("[Dashboard] Citas realizadas hoy:", citasComplRes.error);

        setPedOn((pedsRes?.data || []).filter(esPedidoTiendaWebPendiente));
        setCitasH(citasRes?.data || []);

        const hoy = (ventasHoyRes?.data || []).reduce((a, p) => a + parseFloat(p.total || 0), 0);
        const semana = (ventasSemanaRes?.data || []).reduce((a, p) => a + parseFloat(p.total || 0), 0);
        const mes = (ventasMesRes?.data || []).reduce((a, p) => a + parseFloat(p.total || 0), 0);
        const consultas = (citasComplRes?.data || []).length;

        setKpis({ hoy, semana, mes, consultas });
      } catch (e) {
        console.error("[Dashboard] cargar:", e);
        setPedOn([]);
        setCitasH([]);
        setKpis({ hoy: 0, semana: 0, mes: 0, consultas: 0 });
      } finally {
        setLoad(false);
      }
    };
    cargar();
  },[]);


  return(
    <div>
      <div style={{display:"flex",justifyContent:"space-between",alignItems:"flex-start",marginBottom:24}}>
        <div>
          <h1 style={{color:C.text,fontSize:22,fontWeight:800,margin:0}}>{NEG[negocio].icon} {NEG[negocio].label}</h1>
          <div style={{color:C.textMid,fontSize:12,marginTop:4}}>{NEG[negocio].owner} · {new Date().toLocaleDateString("es-MX",{weekday:"long",year:"numeric",month:"long",day:"numeric"})}</div>
        </div>
        <Tag col={C.green}>● Sistema activo</Tag>
      </div>

      {/* Alertas online */}
      {alertas.pedidos>0&&<PuenteOnline count={alertas.pedidos} label={`${alertas.pedidos} pedidos nuevos desde la tienda web`} color={C.blue}/>}
      {alertas.citas>0&&<PuenteOnline count={alertas.citas} label={`${alertas.citas} citas agendadas en línea hoy`} color={C.green}/>}

      {/* KPIs */}
      <div style={{display:"flex",gap:12,marginBottom:20,flexWrap:"wrap"}}>
        <KPI label="Ventas hoy"    value={$(kpis.hoy)}    col={C.blue}   icon="💵" trend={12}/>
        <KPI label="Esta semana"   value={$(kpis.semana)} col={C.teal}   icon="📈"/>
        <KPI label="Este mes"      value={$(kpis.mes)}    col={C.green}  icon="📊"/>
        <KPI label="Consultas hoy" value={kpis.consultas} col={C.purple} icon="🏥" sub="completadas"/>
        {alertas.stock>0&&<KPI label="Bajo stock" value={alertas.stock} col={C.red} icon="⚠️" sub="productos"/>}
      </div>

      <div style={{display:"grid",gridTemplateColumns:"1fr 1fr",gap:16,marginBottom:16}}>
        {/* Pedidos online pendientes */}
        <Box style={{padding:20}}>
          <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:14}}>
            <div style={{color:C.text,fontWeight:700,fontSize:13}}>🌐 Pedidos online pendientes</div>
            {pedOnline.length>0&&<Btn sm col={C.blue} onClick={()=>setPage("pos")}>Ver todos</Btn>}
          </div>
          {loading?<SkeletonCard height={40} style={{margin:"8px 0"}}/>:
           !pedOnline.length?<div style={{color:C.textMid,fontSize:12}}>✓ Sin pedidos pendientes</div>:
           pedOnline.map(p=>(
            <div key={p.id} style={{background:C.blueDim,border:`1px solid ${C.blue}30`,borderRadius:8,padding:"10px 12px",marginBottom:8}}>
              <div style={{display:"flex",justifyContent:"space-between"}}>
                <span style={{color:C.text,fontSize:12,fontWeight:700}}>Pedido #{p.id}</span>
                <Tag col={C.blue} sm>Online</Tag>
              </div>
              <div style={{color:C.textMid,fontSize:11,marginTop:3}}>{p.clientes?.nombre||"Cliente"} · {$(p.total)}</div>
            </div>
          ))}
        </Box>

        {/* Agenda del día */}
        <Box style={{padding:20}}>
          <div style={{color:C.text,fontWeight:700,fontSize:13,marginBottom:14}}>📅 Consultorio hoy — Dra. Lourdes</div>
          {loading?<div style={{color:C.textMid,fontSize:12}}>Cargando...</div>:
           !citasHoy.length?<div style={{color:C.textMid,fontSize:12}}>Sin citas agendadas hoy</div>:
           citasHoy.map(c=>(
            <div key={c.id} style={{display:"flex",alignItems:"center",gap:10,padding:"7px 0",borderBottom:`1px solid ${C.border}`}}>
              <span style={{color:C.blue,fontWeight:800,fontSize:12,width:44,flexShrink:0}}>{c.hora}</span>
              <div style={{flex:1}}>
                <div style={{color:C.text,fontSize:12,fontWeight:600}}>{c.nombre}</div>
                <div style={{color:C.textMid,fontSize:10}}>{c.motivo||"Consulta general"}</div>
              </div>
              <Tag col={c.estado==="completada"?C.green:c.estado==="confirmada"?C.blue:C.amber} sm>{c.estado||"pendiente"}</Tag>
            </div>
          ))}
        </Box>
      </div>
    </div>
  );
}

// ══════════════════════════════════════════════════════════════
// POS — Punto de Venta (Admin + Vendedor)
// Incluye pedidos online + cobro de consultas
// initialTab: "consultas" al entrar por menú «Cobrar consulta» (cons_cobro)
// onNavigate: ir a otros módulos (p. ej. Corte de caja)
// ══════════════════════════════════════════════════════════════
function POS({negocio,usuario,initialTab="venta",onNavigate}){
  const C = C_LIGHT;
  const [tab,setTab]         = useState(initialTab); // venta | online | consultas
  const [productos,setProds] = useState([]);
  const [cart,setCart]       = useState([]);
  const [srch,setSrch]       = useState("");
  const srchRef = useRef(null);
  useEffect(()=>{ if(tab==="venta" && srchRef.current) srchRef.current.focus(); },[tab]);
  const [favs,setFavs]       = useState(()=>{ try{ return JSON.parse(localStorage.getItem("farmax_pos_favs")||"[]"); }catch{ return []; } });
  const toggleFav = id => {
    setFavs(p=>{
      const n = p.includes(id)?p.filter(x=>x!==id):[...p,id].slice(0,8);
      localStorage.setItem("farmax_pos_favs", JSON.stringify(n));
      return n;
    });
  };
  const [pay,setPay]         = useState("efectivo");
  const [montoRecibido, setMontoRecibido] = useState("");
  const [tel,setTel]         = useState("");
  const [cli,setCli]         = useState(null);
  const [ticket,setTicket]   = useState(null);
  const ticketRef = useRef(null);
  const [rxM,setRxM]         = useState(null);
  const [rx,setRx]           = useState({receta:"",medico:"",cedula:"",paciente:"",indicaciones:""});
  const [pedOnline,setPedOn] = useState([]);
  const [consxCobrar,setConsCobrar] = useState([]);
  const [citasAgenda,setCitasAgenda] = useState([]);
  /** Vista de agenda en pestaña Consultas: hoy | un día elegido (calendario) | semana (lun–dom). Una sola doctora → un cupo por horario. */
  const [rangoAgendaPOS, setRangoAgendaPOS] = useState("hoy");
  const [fechaAgendaElegida, setFechaAgendaElegida] = useState(() =>
    addDaysSv(new Date().toLocaleDateString("sv-SE"), 1)
  );
  const [nuevaCita,setNuevaCita] = useState(()=>({
    nombre:"",telefono:"",fecha:new Date().toLocaleDateString("sv-SE"),hora:"",motivo:"",
  }));
  /** Conteo de citas por hora para la fecha del formulario (máx. 1 por slot — una doctora). */
  const [ocupacionPorHora, setOcupacionPorHora] = useState({});
  const [loading,setLoad]    = useState(false);
  const [guardando,setGuard] = useState(false);
  const [cartOpen,setCartOpen]   = useState(true);
  const [mpModal,setMpModal]     = useState(false);
  const [mpFolio,setMpFolio]     = useState("");
  /** Tras elegir origen de receta, cobro con tarjeta (Point) usa este valor al confirmar el pago. */
  const recetaOrigenPendienteRef = useRef("no_aplica");
  const [modalRecetaVenta, setModalRecetaVenta] = useState(false);
  const [modalRecetaModo, setModalRecetaModo] = useState(null);
  const [recetaOrigenSel, setRecetaOrigenSel] = useState("no_aplica");
  /** Si no es null, el modal MP cobra esa cita (no venta de carrito). */
  const mpCitaRef = useRef(null);
  const [ventasDia,setVentasDia] = useState({total:0,count:0});
  const [folioActual,setFolioActual] = useState("VTA-00000000");
  const [promoTicket,setPromoTicket] = useState(null);
  const [loadErr,setLoadErr] = useState("");
  const [config,setConfig]   = useState({precio_consulta:CONSULTA_PRECIO_DEFAULT,nombre_doctor:"Dra. Lourdes Lucio Falcón",nombre_farmacia:"Farmax",telefono_farmacia:"",direccion_farmacia:"Chinampac de Juárez, Iztapalapa, CDMX"});

  useEffect(()=>{ setTab(initialTab); },[initialTab]);

  useEffect(()=>{
    supabase.from("configuracion").select("*").then(({ data: cfg }) => {
      if (cfg && cfg.length) {
        const map = {};
        cfg.forEach((r) => {
          map[r.clave] = r.valor;
        });
        setConfig((p) => ({
          ...p,
          precio_consulta: parseFloat(map.precio_consulta) || CONSULTA_PRECIO_DEFAULT,
          nombre_doctor: map.nombre_doctor || p.nombre_doctor,
          nombre_farmacia: map.nombre_farmacia || p.nombre_farmacia,
          telefono_farmacia: map.telefono_farmacia || "",
          direccion_farmacia: map.direccion_farmacia || p.direccion_farmacia,
        }));
      }
    });
  }, []);

  const fechasAgendaPOS = useCallback(() => {
    const hoy = new Date();
    const y = hoy.getFullYear();
    const m = hoy.getMonth();
    const d = hoy.getDate();
    const pad = (n) => String(n).padStart(2, "0");
    const toSv = (dt) => `${dt.getFullYear()}-${pad(dt.getMonth() + 1)}-${pad(dt.getDate())}`;
    if (rangoAgendaPOS === "hoy") {
      const x = new Date(y, m, d);
      return { desde: toSv(x), hasta: toSv(x) };
    }
    if (rangoAgendaPOS === "dia") {
      const f = fechaAgendaElegida || new Date().toLocaleDateString("sv-SE");
      return { desde: f, hasta: f };
    }
    const day = hoy.getDay();
    const diffToMon = day === 0 ? -6 : 1 - day;
    const mon = new Date(y, m, d + diffToMon);
    const sun = new Date(mon);
    sun.setDate(mon.getDate() + 6);
    return { desde: toSv(mon), hasta: toSv(sun) };
  }, [rangoAgendaPOS, fechaAgendaElegida]);

  const refrescarCitasPOS = useCallback(async () => {
    const { desde, hasta } = fechasAgendaPOS();
    const { data, error } = await supabase
      .from("citas")
      .select(`
        id,nombre,telefono,hora,fecha,motivo,estado,canal,pago_estado,pedido_consulta_id,precio_consulta_cobrado,ingreso_doctor,ingreso_farmacia,
        consumibles_consulta!cita_id(id,cantidad,precio,cobrado,productos!producto_id(nombre))
      `)
      .gte("fecha", desde)
      .lte("fecha", hasta)
      .not("estado", "eq", "cancelada");
    if (error) {
      console.error("[POS] Citas:", error);
      setCitasAgenda([]);
      setConsCobrar([]);
      return;
    }
    const citas = data || [];
    setCitasAgenda(citas);
    setConsCobrar(
      citas.filter((c) => {
        const pendientePago = citaPagoPendiente(c);
        const consumiblesPend = (c.consumibles_consulta || []).some((x) => !x.cobrado);
        return pendientePago || consumiblesPend;
      })
    );
  }, [fechasAgendaPOS]);

  const hoyStrPOS = new Date().toLocaleDateString("sv-SE");
  useEffect(() => {
    if (!nuevaCita.fecha) {
      setOcupacionPorHora({});
      return;
    }
    if (nuevaCita.fecha === hoyStrPOS) {
      const counts = {};
      (citasAgenda || []).forEach((c) => {
        if (c.fecha !== nuevaCita.fecha) return;
        const k = c.hora;
        if (!k) return;
        counts[k] = (counts[k] || 0) + 1;
      });
      setOcupacionPorHora(counts);
      return;
    }
    supabase
      .from("citas")
      .select("hora")
      .eq("fecha", nuevaCita.fecha)
      .not("estado", "eq", "cancelada")
      .then(({ data }) => {
        const counts = {};
        (data || []).forEach((c) => {
          const k = c.hora;
          if (!k) return;
          counts[k] = (counts[k] || 0) + 1;
        });
        setOcupacionPorHora(counts);
      });
  }, [nuevaCita.fecha, citasAgenda, hoyStrPOS]);

  useEffect(() => {
    const libres = horariosDisponiblesCita(nuevaCita.fecha).filter(
      (h) => (ocupacionPorHora[h] || 0) < 1
    );
    if (nuevaCita.hora && !libres.includes(nuevaCita.hora)) {
      setNuevaCita((p) => ({ ...p, hora: "" }));
    }
  }, [nuevaCita.fecha, nuevaCita.hora, ocupacionPorHora]);

  useEffect(()=>{
    const cargar = async () => {
      setLoad(true);
      if (typeof setLoadErr === "function") setLoadErr("");
      try {
        const pedidosTiendaSelectPos = `
            id,total,created_at,tipo,metodo_pago,estado,
            clientes(nombre,telefono),
            pedido_items(cantidad,precio_unitario,productos(nombre,sku))
          `;
        const [prodsRes, pedsRes] = await Promise.all([
          supabase.from("productos")
            .select("*, lotes(fecha_caducidad,cantidad_actual,activo)")
            .eq("activo",true).order("nombre"),
          fetchPedidosTiendaPendientesMerged(supabase, pedidosTiendaSelectPos, { perBranchLimit: 100, maxRows: 300 }),
        ]);

        const errs = [];
        if (prodsRes?.error) errs.push(`Productos (${prodsRes.status||"?"}): ${prodsRes.error.message}`);
        if (pedsRes?.error)  errs.push(`Pedidos online (${pedsRes.status||"?"}): ${pedsRes.error.message}`);

        if (errs.length) {
          console.error("[POS] Errores de carga:", { prodsRes, pedsRes });
          if (typeof setLoadErr === "function") setLoadErr(errs.join(" | "));
        }

        const prodsConCad = (prodsRes?.data || []).map(p => {
          const activos = (p.lotes || []).filter(l => l.activo !== false && (l.cantidad_actual || 0) > 0 && l.fecha_caducidad);
          const minCad = activos.reduce((m, l) => (!m || l.fecha_caducidad < m) ? l.fecha_caducidad : m, null);
          return { ...p, min_caducidad_lotes: minCad };
        });
        setProds(prodsConCad);
        setPedOn((pedsRes?.data || []).filter(esPedidoTiendaWebPendiente));

      } catch (e) {
        console.error("[POS] Excepción cargando datos:", e);
        if (typeof setLoadErr === "function") setLoadErr("Error inesperado cargando datos. Revisa consola.");
        setProds([]); setPedOn([]); setConsCobrar([]); setCitasAgenda([]);
      } finally {
        setLoad(false);
      }
    };
    cargar();
  },[refrescarCitasPOS]);

  useEffect(() => {
    refrescarCitasPOS();
  }, [refrescarCitasPOS]);


  const buscarCli = async (t) => {
  setTel(t);
  if (t.length < 10) { if(t.length===0) setCli(null); return; }

  const { data, error } = await supabase
    .from("clientes")
    .select("*")
    .eq("telefono", t)
    .maybeSingle();

  if (error) {
    console.error("Error buscando cliente:", error);
    setCli(null);
    return;
  }

  setCli(data || null);
};


  const fil = productos.filter(p=>
    (negocio==="farmacia"?["Analgésico","Antiinflamatorio","Gastro","Antibiótico","Diabetes","Hipertensión","Alergia","Vitaminas","Hidratación","Cardiovascular","Respiratorio","Botiquín"].includes(p.categoria):true)&&
    (p.nombre.toLowerCase().includes(srch.toLowerCase())||
     p.sku?.toLowerCase().includes(srch.toLowerCase())||
     p.codigo_barras?.includes(srch.trim())) // P2.1: filtro por código de barras
  );

  const paymentLabel = (method) => ({
    efectivo: "Efectivo",
    tarjeta: "Tarjeta",
    spei: "SPEI",
    mercadopago: "Tarjeta",
  }[method] || "Otro");

  const totalCobroConsulta = (cita) => {
    const precioBase = parseFloat(config?.precio_consulta) || CONSULTA_PRECIO_DEFAULT;
    const yaPagoConsulta =
      cita.pago_estado === "pagada" || cita.estado === "pagada" || !!cita.pedido_consulta_id;
    const consumibles = (cita.consumibles_consulta || []).filter((c) => !c.cobrado);
    const totalCons = consumibles.reduce((a, c) => a + c.precio * c.cantidad, 0);
    return (yaPagoConsulta ? 0 : precioBase) + totalCons;
  };

  const add = (item, esUnidad=false) => {
    // Validar que el lote FEFO activo más próximo no esté vencido
    if(item.min_caducidad_lotes) {
      const hoy = new Date().toLocaleDateString("sv-SE");
      if(item.min_caducidad_lotes < hoy) {
        showToast(`⚠️ ${item.nombre} tiene lote VENCIDO (${item.min_caducidad_lotes}). No se puede vender.`, "error");
        return;
      }
    }
    if((item.requiere_receta || item.categoria==="Antibiótico") && !esUnidad) { setRxM(item); return; }
    if (esUnidad) {
      if ((item.stock_unidades || 0) <= 0) {
        showToast("Sin unidades disponibles para venta suelta.", "warning");
        return;
      }
      const keyU = item.id+"_unit";
      setCart(p=>{
        const ex = p.find(c=>c.id===keyU);
        if (ex && ex.qty >= (item.stock_unidades || 0)) {
          showToast(`Máx unidades sueltas: ${item.stock_unidades || 0}`, "warning");
          return p;
        }
        return ex
          ? p.map(c=>c.id===keyU?{...c,qty:c.qty+1}:c)
          : [...p,{...item,id:keyU,producto_id:item.id,qty:1,rxI:null,esUnidad:true,precio:Math.ceil(item.precio_unidad||0),nombre:item.nombre+" (unidad)"}];
      });
    } else {
      if ((item.stock || 0) <= 0) {
        showToast("Producto agotado.", "warning");
        return;
      }
      setCart(p=>{
        const ex=p.find(c=>c.id===item.id);
        if(ex){
          if(ex.qty>=(item.stock||99)){ showToast(`Stock máximo: ${item.stock} unidades`,"warning"); return p; }
          return p.map(c=>c.id===item.id?{...c,qty:c.qty+1}:c);
        }
        return [...p,{...item,producto_id:item.id,qty:1,rxI:null,esUnidad:false}];
      });
    }
  };

  const abrirCaja = async (item) => {
    if (item.stock <= 0) { showToast("Sin stock de cajas disponibles.", "warning"); return; }
    const tok = sessionStorage.getItem("farmax_session_token");
    if (!tok) { showToast("Sesión expirada.", "error"); return; }
    const { data, error } = await supabase.rpc("abrir_caja_secure", {
      p_session_token: tok,
      p_producto_id: item.id,
    });
    if (error) {
      showToast(`Error al abrir caja: ${error.message}`, "error");
      return;
    }
    const nuevasUnidades =
      data?.[0]?.stock_unidades_nuevo ??
      ((item.stock_unidades || 0) + (item.unidades_por_caja || 0));
    showToast(`Caja abierta. Unidades disponibles: ${nuevasUnidades}`, "success");
  };

  const RX_IND_PRESETS = ["Cada 8 hrs con alimentos","Cada 12 hrs, completar tratamiento","En ayunas, 30 min antes de desayuno","Solo por la noche antes de dormir","No exceder dosis indicada por médico"];

  const toggleRxIndicacion = (t) => {
    setRx((p) => {
      const parts = (p.indicaciones || "").split(/\s*;\s*/).map((s) => s.trim()).filter(Boolean);
      const i = parts.indexOf(t);
      if (i >= 0) parts.splice(i, 1);
      else parts.push(t);
      return { ...p, indicaciones: parts.join("; ") };
    });
  };

  const rxPresetActiva = (t) =>
    (rx.indicaciones || "")
      .split(/\s*;\s*/)
      .map((s) => s.trim())
      .filter(Boolean)
      .includes(t);

  const confRx = () => {
    if(!rx.receta||!rx.medico||!rx.cedula||!rx.paciente) return;
    setCart(p=>[...p,{...rxM,qty:1,rxI:{...rx}}]);
    setRxM(null); setRx({receta:"",medico:"",cedula:"",paciente:"",indicaciones:""});
  };

  // P2.2: Calcular total con promociones activas aplicadas
  const calcularTotalConPromos = () => {
    return cart.reduce((a,c) => {
      let precio = c.precio;
      // Si el producto tiene descuento_pct, aplicarlo
      if(c.descuento_pct>0) {
        precio = precio * (1 - c.descuento_pct/100);
      }
      return a + precio * c.qty;
    }, 0);
  };
  const sub   = calcularTotalConPromos();
  const ptsG  = Math.floor(sub/10);
  const total = sub;

  const parseMontoEfectivo = (s) => {
    const x = String(s ?? "").replace(/,/g, "").trim().replace(/^\$/, "");
    const n = parseFloat(x);
    return Number.isFinite(n) ? Math.round(n * 100) / 100 : NaN;
  };
  const recibidoNum = parseMontoEfectivo(montoRecibido);
  const cambioNum = pay === "efectivo" && Number.isFinite(recibidoNum) ? Math.round(Math.max(0, recibidoNum - total) * 100) / 100 : null;

  const abrirModalRecetaVenta = (modo) => {
    if (!cart.length) return;
    if (modo === "efectivo") {
      const rec = parseMontoEfectivo(montoRecibido);
      if (!Number.isFinite(rec) || rec < total) {
        showToast(`Indica cuánto te entregó el cliente en efectivo (mínimo ${$(total)}).`, "warning");
        return;
      }
    }
    setRecetaOrigenSel("no_aplica");
    setModalRecetaModo(modo);
    setModalRecetaVenta(true);
  };

  const ejecutarCobrar = async (recetaOrigen = "no_aplica") => {
    if(!cart.length) return;
    if (pay === "efectivo") {
      const rec = parseMontoEfectivo(montoRecibido);
      if (!Number.isFinite(rec) || rec < total) {
        showToast(`Indica cuánto te entregó el cliente en efectivo (mínimo ${$(total)}).`, "warning");
        return;
      }
    }
    setGuard(true);
    try {
      const tok = sessionStorage.getItem("farmax_session_token");
      if (!tok) {
        alert("Sesión expirada. Inicia sesión de nuevo.");
        setGuard(false);
        return;
      }

      const cartItemsMapped = cart.map(c=>({
        producto_id: c.producto_id ?? c.id,
        cantidad: c.qty,
        precio_unitario: c.precio,
        modo_venta: c.esUnidad ? "unidad" : "caja",
      }));

      const { data: rpcData, error: rpcError } = await supabase.rpc("create_sale_transaction_secure", {
        p_session_token: tok,
        p_metodo_pago: pay,
        p_total: total,
        p_cart_items: cartItemsMapped,
        p_cliente_id: cli?.id ?? null,
        p_tipo: "pos",
        p_tipo_entrega: null,
        p_direccion: null,
      });

      if (rpcError) throw rpcError;

      const rpcRow = Array.isArray(rpcData) ? rpcData[0] : rpcData;
      const pedidoId = rpcRow?.pedido_id;
      const ok = rpcRow?.success === true;
      if (!pedidoId || !ok) {
        throw new Error("RPC create_sale_transaction_secure devolvió una respuesta inválida");
      }

      const ro = recetaOrigen === "medico_farmax" || recetaOrigen === "medico_externo" ? recetaOrigen : "no_aplica";
      const tokRo = sessionStorage.getItem("farmax_session_token");
      if (tokRo) {
        const { error: uErr } = await supabase.rpc("admin_set_receta_origen_pedido", {
          p_session_token: tokRo, p_pedido_id: pedidoId, p_receta_origen: ro,
        });
        if (uErr) console.warn("[POS] receta_origen:", uErr);
      }

      if (ro === "medico_farmax") {
        const fechaSv = new Date().toLocaleDateString("sv-SE");
        try {
          await marcarMedicamentosRecetaFarmaxSurtidos(supabase, {
            p_session_token: tokRo,
            fechaCitaLocal: fechaSv,
            telefonoCliente: cli?.telefono,
            clienteId: cli?.id ?? null,
            pedidoId,
            items: cart.map((c) => ({ producto_id: c.producto_id ?? c.id, qty: c.qty })),
          });
        } catch (e) {
          console.warn("[POS] sync receta-cita:", e);
        }
      }

      setFolioActual(`VTA-${String(pedidoId).padStart(8,"0")}`);

      const { data: pedidoItems, error: pedidoItemsError } = await supabase
        .from("pedido_items")
        .select("producto_id,cantidad,precio_unitario,lote_id,productos(nombre,sku),lotes(numero_lote,fecha_caducidad)")
        .eq("pedido_id", pedidoId)
        .order("id", { ascending: true });
      if (pedidoItemsError) throw pedidoItemsError;

      const rxItems = cart.filter(c=>c.rxI);
      if(rxItems.length) {
        const loteByProd = new Map();
        (pedidoItems || []).forEach((it) => {
          if (it.producto_id && it.lotes?.numero_lote && !loteByProd.has(it.producto_id)) {
            loteByProd.set(it.producto_id, {
              numero: it.lotes.numero_lote,
              caducidad: it.lotes.fecha_caducidad || null,
            });
          }
        });
        const tokCof = sessionStorage.getItem("farmax_session_token");
        if (tokCof) {
          await supabase.rpc("admin_registrar_bitacora_cofepris", {
            p_session_token: tokCof,
            p_items: rxItems.map(c => {
              const loteInfo = loteByProd.get(c.producto_id ?? c.id) || {};
              return {
                medicamento: c.nombre,
                lote:        loteInfo.numero || "",
                caducidad:   loteInfo.caducidad || null,
                cantidad:    c.qty,
                receta:      c.rxI.receta,
                medico:      c.rxI.medico,
                cedula_medico: c.rxI.cedula,
                paciente:    c.rxI.paciente,
              };
            }),
          });
        }
      }

      const ticketItems = (pedidoItems || []).map((it) => ({
        nombre: it.productos?.nombre || "Producto",
        sku: it.productos?.sku || "",
        qty: it.cantidad || 1,
        precio: it.precio_unitario || 0,
        lote: it.lotes?.numero_lote || null,
        caducidad: it.lotes?.fecha_caducidad || null,
      }));

      const ivaAmt = parseFloat((total * 0.16 / 1.16).toFixed(2));
      const netoAmt = parseFloat((total - ivaAmt).toFixed(2));
      const folioVenta = `VTA-${String(pedidoId).padStart(8,"0")}`;
      const recEf = pay === "efectivo" ? parseMontoEfectivo(montoRecibido) : null;
      const cambioEf = pay === "efectivo" && Number.isFinite(recEf) ? Math.round(Math.max(0, recEf - total) * 100) / 100 : null;
      const desgloseEf = pay === "efectivo" && cambioEf != null && cambioEf > 0 ? desgloseCambioMN(cambioEf) : "";
      setTicket({
        id:pedidoId,
        folio:folioVenta,
        items:ticketItems.length ? ticketItems : [...cart],
        sub,
        total,
        neto:netoAmt,
        iva:ivaAmt,
        pay:paymentLabel(pay),
        cli,
        ptsG,
        ...(pay === "efectivo" && Number.isFinite(recEf)
          ? { recibido: recEf, cambio: cambioEf, cambioDesglose: desgloseEf }
          : {}),
      });
      setVentasDia(p=>({total:p.total+total, count:p.count+1}));
      logAudit(usuario, "VENTA", "pedidos", pedidoId, {
        total, metodo_pago: pay, items: cart.length,
        ...(pay === "efectivo" && Number.isFinite(recEf) ? { efectivo_recibido: recEf, cambio: cambioEf } : {}),
      });
      showToast("Venta registrada correctamente", "success");
      setCart([]); setTel(""); setCli(null);
      setMontoRecibido("");
      setTimeout(() => printTicket("farmax-ticket"), 500);
    } catch(e) {
      console.error(e);
      const msg = e?.message || e?.details || String(e);
      const lower = msg.toLowerCase();
      if (lower.includes("stock") || lower.includes("insuficiente")) {
        alert("Stock insuficiente o no se pudo completar el descuento de inventario.");
      } else {
        alert(`No se pudo completar la venta.\n\n${msg}`);
      }
    }
    setGuard(false);
  };

  const cobrar = () => abrirModalRecetaVenta("efectivo");

  const confirmarRecetaVentaYContinuar = () => {
    const ro = recetaOrigenSel === "medico_farmax" || recetaOrigenSel === "medico_externo" ? recetaOrigenSel : "no_aplica";
    setModalRecetaVenta(false);
    const modo = modalRecetaModo;
    setModalRecetaModo(null);
    if (modo === "tarjeta") {
      mpCitaRef.current = null;
      recetaOrigenPendienteRef.current = ro;
      setMpFolio(folioActual || "VTA-PENDIENTE");
      setMpModal(true);
    } else if (modo === "efectivo") {
      ejecutarCobrar(ro);
    }
  };

  const surtirOnline = async (pedido) => {
    setGuard(true);
    try {
      const tok = sessionStorage.getItem("farmax_session_token");
      if (!tok) { alert("Sesión expirada."); setGuard(false); return; }
      // F6b: marcar_pedido_listo ya descuenta stock FEFO internamente
      const { data: resp, error: rpcErr } = await supabase.rpc("marcar_pedido_listo", {
        p_session_token: tok, p_pedido_id: pedido.id,
      });
      if (rpcErr) throw rpcErr;
      if (!resp?.success) throw new Error(resp?.error || "No se pudo surtir");
      setPedOn(p=>p.filter(x=>x.id!==pedido.id));
      // L4: Notificar al cliente por WhatsApp cuando pedido está listo
      const telCli = pedido.clientes?.telefono;
      if(telCli) {
        const msg = `🏥 *Farmax Farmacia*\n\n✅ ¡Tu pedido #${pedido.id} está listo!\n\nPuedes pasar a recogerlo en:\n📍 Chinampac de Juárez, Iztapalapa, CDMX\n\n¡Te esperamos! 💊`;
        showToast(`Pedido listo. ${telCli?"Puedes notificar al cliente por WhatsApp":""}`, "success");
        // Botón manual para no abrir sin permiso
      }
    } catch(e) { console.error(e); }
    setGuard(false);
  };

  const guardarNuevaCitaMostrador = async () => {
    if (!nuevaCita.nombre?.trim() || !nuevaCita.fecha || !nuevaCita.hora) {
      showToast("Nombre, fecha y hora son obligatorios.", "warning");
      return;
    }
    setGuard(true);
    try {
      const { data: ocupado } = await supabase
        .from("citas")
        .select("id")
        .eq("fecha", nuevaCita.fecha)
        .eq("hora", nuevaCita.hora)
        .not("estado", "eq", "cancelada");
      if (ocupado && ocupado.length >= 1) {
        alert("Ese horario ya no está disponible. Elige otro.");
        setGuard(false);
        return;
      }
      const tok = sessionStorage.getItem("farmax_session_token");
      if (!tok) throw new Error("Sesión expirada");
      const { data: resp, error } = await supabase.rpc("crear_cita", {
        p_session_token: tok,
        p_nombre: nuevaCita.nombre.trim(),
        p_telefono: nuevaCita.telefono.trim() || null,
        p_fecha: nuevaCita.fecha,
        p_hora: nuevaCita.hora,
        p_motivo: nuevaCita.motivo.trim() || null,
        p_canal: "mostrador",
      });
      if (error) throw error;
      if (!resp?.success) throw new Error(resp?.error || "No se pudo crear la cita");
      showToast("Cita registrada. Cobrar la consulta abajo para que la doctora vea «Pagado».", "success");
      setNuevaCita({
        nombre: "",
        telefono: "",
        fecha: new Date().toLocaleDateString("sv-SE"),
        hora: "",
        motivo: "",
      });
      await refrescarCitasPOS();
    } catch (e) {
      console.error(e);
      alert("No se pudo guardar la cita: " + (e?.message || e));
    }
    setGuard(false);
  };

  const cancelarCitaPorNoShow = async (cita) => {
    if (!puedeCancelarCitaNoShow(cita)) return;
    if (!window.confirm(`¿Cancelar la cita de ${cita.nombre} (${cita.hora}) y liberar el horario? Solo aplica si pasaron 10 min del inicio sin pago en caja.`)) return;
    setGuard(true);
    try {
      const tok = sessionStorage.getItem("farmax_session_token");
      const { data: resp, error } = await supabase.rpc("actualizar_estado_cita", {
        p_session_token: tok, p_cita_id: cita.id, p_estado: "cancelada",
      });
      if (error) throw error;
      if (!resp?.success) throw new Error(resp?.error || "No se pudo cancelar");
      showToast("Cita cancelada. El horario queda libre.", "info");
      await refrescarCitasPOS();
    } catch (e) {
      console.error(e);
      alert("No se pudo cancelar: " + (e?.message || e));
    }
    setGuard(false);
  };

  const cobrarConsulta = async (cita) => {
    setGuard(true);
    try {
      const tok = sessionStorage.getItem("farmax_session_token");
      if (!tok) throw new Error("Sesión expirada");
      const { data: resp, error } = await supabase.rpc("cobrar_consulta", {
        p_session_token: tok,
        p_cita_id:       cita.id,
        p_cliente_id:    cli?.id || null,
        p_metodo_pago:   pay,
      });
      if (error) throw error;
      if (!resp?.success) throw new Error(resp?.error || "No se pudo cobrar");

      const precioBase = parseFloat(config?.precio_consulta) || CONSULTA_PRECIO_DEFAULT;
      const yaPagoConsulta =
        cita.pago_estado === "pagada" || cita.estado === "pagada" || !!cita.pedido_consulta_id;
      const consumibles = (cita.consumibles_consulta || []).filter((c) => !c.cobrado);
      const baseCobrar = yaPagoConsulta ? 0 : precioBase;
      const totalFinal = resp.total || 0;

      await refrescarCitasPOS();
      const itemsConsulta =
        baseCobrar > 0
          ? [{ nombre: "Consulta médica", qty: 1, precio: precioBase }]
          : [];
      setTicket({
        id: resp.pedido_id || Date.now(),
        items: [
          ...itemsConsulta,
          ...consumibles.map((c) => ({
            nombre: c.productos?.nombre || "Consumible",
            qty: c.cantidad,
            precio: c.precio,
          })),
        ],
        sub: totalFinal,
        total: totalFinal,
        pay: paymentLabel(pay),
        cli,
        ptsG: Math.floor(totalFinal / 10),
      });
      setTimeout(() => printTicket("farmax-ticket"), 500);
    } catch (e) {
      console.error(e);
      alert("No se pudo cobrar la consulta: " + (e?.message || e));
    }
    setGuard(false);
  };

  return(
    <div>
      <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:20}}>
        {loadErr && (
        <div style={{
          background:"#ff000022",
          border:"1px solid #ff4444",
          borderRadius:8,
          padding:"10px 16px",
          marginBottom:16,
          color:"#ff6666",
          fontSize:12,
          fontWeight:600,
          display:"flex",
          justifyContent:"space-between",
          alignItems:"center"
        }}>
          <span>⚠️ {loadErr}</span>
          <button onClick={()=>setLoadErr("")} style={{background:"transparent",border:"none",color:"#ff6666",cursor:"pointer",fontSize:14}}>✕</button>
        </div>
      )}
      <div style={{display:"flex",alignItems:"center",gap:16,flexWrap:"wrap"}}>
        <div style={{display:"flex",alignItems:"center",gap:10,flexWrap:"wrap"}}>
          <h1 style={{color:C.text,fontSize:20,fontWeight:800,margin:0}}>
            ⊡ Punto de Venta
            {initialTab==="consultas"&&(
              <span style={{fontWeight:700,fontSize:14,color:C.purple}}> · Cobro de consultas</span>
            )}
          </h1>
          {folioActual!=="VTA-00000000"&&(
            <span style={{padding:"3px 10px",borderRadius:20,fontSize:10,fontWeight:700,background:C.blueDim,color:C.blue}}>
              Último folio: {folioActual}
            </span>
          )}
        </div>
        {ventasDia.count>0&&(
          <div style={{display:"flex",gap:12,alignItems:"center",background:C.greenDim,border:`1px solid ${C.green}30`,borderRadius:10,padding:"6px 14px",flexWrap:"wrap"}}>
            <div style={{textAlign:"center"}}>
              <div style={{color:C.textDim,fontSize:9,fontWeight:700,textTransform:"uppercase"}}>Mi día</div>
              <div style={{color:C.green,fontWeight:900,fontSize:16}}>{$(ventasDia.total)}</div>
            </div>
            <div style={{width:1,height:28,background:C.border}}/>
            <div style={{textAlign:"center"}}>
              <div style={{color:C.textDim,fontSize:9,fontWeight:700,textTransform:"uppercase"}}>Ventas</div>
              <div style={{color:C.green,fontWeight:900,fontSize:16}}>{ventasDia.count}</div>
            </div>
            <div style={{width:1,height:28,background:C.border}}/>
            <div style={{textAlign:"center"}}>
              <div style={{color:C.textDim,fontSize:9,fontWeight:700,textTransform:"uppercase"}}>Ticket prom.</div>
              <div style={{color:C.blue,fontWeight:900,fontSize:16}}>{$(ventasDia.count?ventasDia.total/ventasDia.count:0)}</div>
            </div>
            <div style={{width:1,height:28,background:C.border}}/>
            <div style={{textAlign:"center"}}>
              <div style={{color:C.textDim,fontSize:9,fontWeight:700,textTransform:"uppercase"}}>En carrito</div>
              <div style={{color:C.amber,fontWeight:900,fontSize:16}}>{cart.length}</div>
            </div>
          </div>
        )}
      </div>
        <div style={{display:"flex",gap:6,alignItems:"center"}}>
          {[["venta","Venta normal"],["online",`Online (${pedOnline.length})`],["consultas",`Consultas (${citasAgenda.length})`]].map(([v,l])=>(
            <button key={v} onClick={()=>setTab(v)} style={{padding:"6px 14px",borderRadius:8,border:`1px solid ${tab===v?BRAND.primary:C.border}`,background:tab===v?BRAND.primary+"18":"transparent",color:tab===v?BRAND.secondary:C.textMid,fontSize:12,fontWeight:700,cursor:"pointer"}}>
              {l}
            </button>
          ))}
          <button type="button" onClick={()=>onNavigate?.("caja")} style={{
            padding:"6px 14px",borderRadius:8,border:`1px solid ${C.amber}`,
            background:C.amberDim,color:C.amber,fontSize:12,fontWeight:700,
            cursor:"pointer",marginLeft:8,
          }}>⊞ Cerrar turno</button>
        </div>
      </div>

      {/* Modal RX */}
      <Modal open={!!rxM} onClose={()=>setRxM(null)} title="⚕ Medicamento con Receta — COFEPRIS" ac={C.amber}>
        <div style={{color:C.textMid,fontSize:13,marginBottom:14}}><strong style={{color:C.text}}>{rxM?.nombre}</strong> — se registrará en bitácora COFEPRIS/SICAD</div>
        {[["Número de receta","receta","RX-2024-XXX"],["Médico prescriptor","medico","Dr. Nombre Completo"],["Cédula profesional","cedula","Número cédula SEP"],["Nombre del paciente","paciente","Nombre completo"]].map(([l,k,ph])=>(
          <div key={k} style={{marginBottom:12}}>
            <div style={{color:C.textMid,fontSize:11,marginBottom:4}}>{l} *</div>
            <Inp value={rx[k]} onChange={e=>setRx(p=>({...p,[k]:e.target.value}))} placeholder={ph} style={{width:"100%",boxSizing:"border-box"}}/>
          </div>
        ))}
        {/* Indicaciones */}
        <div style={{marginBottom:12}}>
          <div style={{color:C.textMid,fontSize:11,marginBottom:6}}>Indicaciones / Precauciones (opcional)</div>
          <div style={{color:C.textDim,fontSize:10,marginBottom:6}}>Toca varias opciones para combinarlas (se unen con «;»). Puedes editar el texto abajo.</div>
          <div style={{display:"flex",gap:4,flexWrap:"wrap",marginBottom:6}}>
            {RX_IND_PRESETS.map((t)=>(
              <button key={t} type="button" onClick={()=>toggleRxIndicacion(t)}
                style={{padding:"3px 8px",borderRadius:20,fontSize:10,fontWeight:600,cursor:"pointer",
                  background:rxPresetActiva(t)?C.amberDim:"#f8fafc",
                  border:`1px solid ${rxPresetActiva(t)?C.amber:C.border}`,
                  color:rxPresetActiva(t)?C.amber:C.textMid}}>{t}</button>
            ))}
          </div>
          <textarea value={rx.indicaciones} onChange={e=>setRx(p=>({...p,indicaciones:e.target.value}))}
            rows={3} maxLength={500} placeholder="Texto final (editable): combina frases de arriba o escribe libremente..."
            style={{width:"100%",boxSizing:"border-box",padding:"8px 10px",borderRadius:8,
              border:`1px solid ${C.border}`,background:C.card,color:C.text,
              fontSize:12,outline:"none",resize:"vertical",fontFamily:"inherit"}}/>
        </div>
        <div style={{display:"flex",gap:8}}>
          <Btn onClick={()=>setRxM(null)} ol col={C.textMid} sm>Cancelar</Btn>
          <Btn onClick={confRx} col={C.amber} dis={!rx.receta||!rx.medico||!rx.cedula||!rx.paciente}>✓ Registrar y agregar</Btn>
        </div>
      </Modal>

      {/* Origen de receta (POS) — antes de registrar la venta */}
      <Modal
        open={modalRecetaVenta}
        onClose={()=>{ setModalRecetaVenta(false); setModalRecetaModo(null); }}
        title="¿La receta es de un médico de Farmax?"
        ac={C.blue}
      >
        <div style={{color:C.textMid,fontSize:13,marginBottom:14,lineHeight:1.45}}>
          Indica si el medicamento surtido corresponde a receta prescrita por algún médico o médica que atiende en el consultorio Farmax. Así medimos ventas ligadas a consultas y estimamos oportunidad cuando el paciente surte fuera.
        </div>
        <div style={{display:"flex",flexDirection:"column",gap:8,marginBottom:16}}>
          {[
            ["no_aplica", "No aplica / venta sin receta de consultorio"],
            ["medico_farmax", "Sí — receta de doctor(a) de Farmax"],
            ["medico_externo", "Receta de otro médico (externo)"],
          ].map(([val, lab])=>(
            <label key={val} style={{display:"flex",alignItems:"flex-start",gap:10,cursor:"pointer",padding:"8px 10px",borderRadius:8,border:`1px solid ${recetaOrigenSel===val?C.blue:C.border}`,background:recetaOrigenSel===val?C.blueDim:C.card}}>
              <input type="radio" name="recetaOrigenPos" checked={recetaOrigenSel===val} onChange={()=>setRecetaOrigenSel(val)} style={{marginTop:3}} />
              <span style={{color:C.text,fontSize:13,fontWeight:600}}>{lab}</span>
            </label>
          ))}
        </div>
        <div style={{display:"flex",gap:8,justifyContent:"flex-end"}}>
          <Btn ol col={C.textMid} sm onClick={()=>{ setModalRecetaVenta(false); setModalRecetaModo(null); }}>Cancelar</Btn>
          <Btn col={C.green} onClick={confirmarRecetaVentaYContinuar} dis={guardando}>Continuar</Btn>
        </div>
      </Modal>

      {/* Modal ticket — TicketPreviewModal (aparece automáticamente después de venta) */}
      {/* Mercado Pago Point Smart 2 Modal */}
      <MercadoPagoModal
        open={mpModal}
        total={mpCitaRef.current ? totalCobroConsulta(mpCitaRef.current) : total}
        folio={mpCitaRef.current ? `CONS-${mpCitaRef.current.id}` : mpFolio}
        hint="El terminal recibe el monto; el cajero confirma en el Point; al aprobarse el pago se registra la operación y se imprime el ticket."
        onSuccess={async ()=>{
          setMpModal(false);
          const citaMp = mpCitaRef.current;
          mpCitaRef.current = null;
          if (citaMp) await cobrarConsulta(citaMp);
          else {
            const ro = recetaOrigenPendienteRef.current || "no_aplica";
            recetaOrigenPendienteRef.current = "no_aplica";
            await ejecutarCobrar(ro);
          }
        }}
        onCancel={()=>{ setMpModal(false); mpCitaRef.current = null; recetaOrigenPendienteRef.current = "no_aplica"; }}
      />

      {ticket&&<TicketPreviewModal
        open={!!ticket}
        venta={{id:ticket.id, folio:ticket.folio, total:ticket.total, created_at:new Date().toISOString(), metodo_pago:ticket.pay}}
        productos={ticket.items}
        cliente={ticket.cli}
        metodoPago={ticket.pay}
        config={config}
        promoMsg={promoTicket}
        onClose={()=>setTicket(null)}
        onNuevaVenta={()=>{ setTicket(null); setCart([]); setTel(""); setCli(null); }}
      />}
      

      {/* TAB: VENTA NORMAL */}
      {tab==="venta"&&(
        <div style={{display:"grid",gridTemplateColumns:cartOpen?"1fr 320px":"1fr",gap:16,alignItems:"start",position:"relative"}}>
          <div>
            <div style={{display:"flex",gap:8,marginBottom:12,alignItems:"center"}}>
              <input ref={srchRef} value={srch} onChange={e=>setSrch(e.target.value)}
                data-tour="pos-buscador"
                onKeyDown={e=>{
                  if(e.key==="Enter"){
                    const q = srch.toLowerCase().trim();
                    // P2.1: Buscar por codigo_barras primero, luego SKU
                    const exact = productos.find(p=>
                      (p.codigo_barras&&p.codigo_barras===srch.trim()) ||
                      (p.sku&&p.sku.toLowerCase()===q)
                    );
                    if(exact){add(exact,false);setSrch("");e.preventDefault();}
                  }
                }}
                placeholder="🔍 Buscar por nombre o SKU · Enter para agregar"
                style={{flex:1,boxSizing:"border-box",padding:"9px 13px",borderRadius:8,border:`1px solid ${C.border}`,background:C.bg,color:C.text,fontSize:13,outline:"none",fontFamily:"'Plus Jakarta Sans',sans-serif"}}/>
              <button onClick={()=>setCartOpen(p=>!p)} style={{
                padding:"9px 14px",borderRadius:8,border:`1px solid ${C.border}`,
                background:cart.length?BRAND.primary+"18":"transparent",
                color:cart.length?BRAND.primary:C.textMid,
                fontWeight:700,fontSize:12,cursor:"pointer",whiteSpace:"nowrap",flexShrink:0,
              }}>🛒{cart.length>0?` (${cart.length})`:""} {cartOpen?"▶":"◀"}</button>
            </div>
            {favs.length>0&&(
              <div data-tour="pos-favoritos" style={{marginBottom:12}}>
                <div style={{color:C.textDim,fontSize:10,fontWeight:700,letterSpacing:1,textTransform:"uppercase",marginBottom:6}}>⭐ Favoritos</div>
                <div style={{display:"flex",gap:6,flexWrap:"wrap"}}>
                  {productos.filter(p=>favs.includes(p.id)&&p.activo).map(p=>(
                    <button key={p.id} onClick={()=>add(p,false)}
                      style={{padding:"5px 10px",borderRadius:8,border:`1px solid ${C.amber}`,background:C.amberDim,color:"#92400e",fontSize:11,fontWeight:700,cursor:"pointer",maxWidth:130,overflow:"hidden",textOverflow:"ellipsis",whiteSpace:"nowrap"}}>
                      ⭐ {p.nombre.split(" ").slice(0,3).join(" ")}
                    </button>
                  ))}
                </div>
              </div>
            )}
            <div style={{display:"grid",gridTemplateColumns:"repeat(auto-fill,minmax(140px,1fr))",gap:8}}>
              {fil.map(item=>{
                const posCardClick = (e)=>{
                  if(e.target.closest("button")) return;
                  if(item.stock===0&&(!item.venta_unidad||item.stock_unidades===0)){
                    showToast("Sin stock disponible.","warning"); return;
                  }
                  if(item.venta_unidad){
                    if(item.stock>0) add(item,false);
                    else if(item.stock_unidades>0) add(item,true);
                    else if(item.stock>0) abrirCaja(item);
                    else showToast("Sin stock disponible.","warning");
                  }else if(item.stock>0){
                    add(item,false);
                  }
                };
                return(
                <Box key={item.id} className="farmax-product-card"
                  onClick={posCardClick}
                  style={{padding:12,opacity:item.stock===0&&(!item.venta_unidad||item.stock_unidades===0)?.5:1}}>
                  <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:3}}>
                    <div style={{color:C.textDim,fontSize:9,letterSpacing:1}}>{item.sku}</div>
                    <button type="button" onClick={e=>{e.stopPropagation();toggleFav(item.id);}} style={{background:"none",border:"none",cursor:"pointer",fontSize:12,padding:0,lineHeight:1}} title="Favorito">
                      {favs.includes(item.id)?"⭐":"☆"}
                    </button>
                  </div>
                  <div style={{color:C.text,fontSize:11,fontWeight:700,lineHeight:1.3,marginBottom:6,minHeight:28}}>{item.nombre}</div>
                  <div style={{display:"flex",gap:4,flexWrap:"wrap",marginBottom:6}}>
                    {item.requiere_receta&&<span style={{background:C.amber,color:"#fff",fontSize:9,fontWeight:800,borderRadius:4,padding:"2px 6px"}}>⚕ RX</span>}
                    {item.tipo==="generico"&&<Tag col={C.teal} sm>Gen</Tag>}
                  </div>
                  {item.venta_unidad?(
                    <div style={{display:"flex",flexDirection:"column",gap:4}}>
                      <button type="button"
                        disabled={item.stock===0}
                        onClick={e=>{e.stopPropagation();add(item,false);}}
                        style={{padding:"4px 6px",borderRadius:6,border:`1px solid ${C.blue}30`,background:"#eff6ff",color:C.blue,cursor:item.stock===0?"not-allowed":"pointer",fontSize:10,fontWeight:700,opacity:item.stock===0?.4:1}}>
                        📦 Caja {$(item.precio||item.precio)} · {item.stock} cajas
                      </button>
                      <button type="button"
                        disabled={item.stock_unidades===0&&item.stock===0}
                        onClick={e=>{e.stopPropagation();
                          if(item.stock_unidades>0){ add(item,true); }
                          else if(item.stock>0){ abrirCaja(item); }
                          else { showToast("Sin stock disponible.", "warning"); }
                        }}
                        style={{padding:"4px 6px",borderRadius:6,border:`1px solid ${C.green}30`,background:C.greenDim,color:C.greenDark,cursor:(item.stock_unidades===0&&item.stock===0)?"not-allowed":"pointer",fontSize:10,fontWeight:700,opacity:(item.stock_unidades===0&&item.stock===0)?.4:1}}>
                        💊 x1 {$(Math.ceil(item.precio_unidad||0))} · {item.stock_unidades} sueltas
                      </button>
                    </div>
                  ):(
                    <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",pointerEvents:"none"}}>
                      <div>
                        {item.descuento_pct>0?(
                          <>
                            <span style={{color:C.textDim,fontSize:10,textDecoration:"line-through",display:"block"}}>{$(item.precio||item.precio)}</span>
                            <span style={{color:C.red,fontWeight:900,fontSize:15}}>{$(Math.round((item.precio||item.precio)*(1-item.descuento_pct/100)))}</span>
                            <span style={{background:C.red,color:"#fff",fontSize:8,fontWeight:700,borderRadius:4,padding:"1px 4px",marginLeft:4}}>-{item.descuento_pct}%</span>
                          </>
                        ):(
                          <span style={{color:C.blue,fontWeight:800,fontSize:15}}>{$(item.precio)}</span>
                        )}
                      </div>
                      <Tag col={item.stock===0?C.red:item.stock<item.stock_minimo?C.amber:C.green} sm>{item.stock===0?"Agotado":item.stock}</Tag>
                    </div>
                  )}
                </Box>
                );
              })}
            </div>
          </div>
          {/* Carrito */}
          {cartOpen&&<div data-tour="pos-carrito" style={{position:"sticky",top:20}}>
            <Box style={{padding:16,marginBottom:12}}>
              <div style={{color:C.text,fontWeight:700,fontSize:13,marginBottom:12}}>🛒 Carrito</div>
              <div data-tour="pos-cliente">
              <SearchDropdown
                value={tel}
                onChange={t=>buscarCli(t)}
                onSelect={c=>{ setTel(c.telefono||""); setCli(c); }}
                placeholder="📱 Teléfono o nombre del cliente"
                items={[]}
                labelKey="nombre"
                subKey="telefono"
                badgeKey="puntos"
                badgeCol="#7c3aed"
                style={{marginBottom:8}}
                emptyMsg="Escribe el teléfono completo (10 dígitos)"
              />
              </div>
              {cli&&<div style={{background:C.purpleDim,border:`1px solid ${C.purple}30`,borderRadius:8,padding:"8px 10px",marginBottom:10}}>
                <div style={{color:C.purple,fontWeight:700,fontSize:12}}>{cli.nombre}</div>
                <div style={{color:C.textMid,fontSize:10}}>⭐ {cli.puntos||0} puntos Farmax</div>
              </div>}
              {!cart.length?<div style={{color:C.textMid,fontSize:12,textAlign:"center",padding:"20px 0"}}>Agrega productos</div>:
               cart.map(item=>(
                <div key={item.id} style={{marginBottom:10,paddingBottom:10,borderBottom:`1px solid ${C.border}`}}>
                  <div style={{display:"flex",justifyContent:"space-between",alignItems:"flex-start",gap:6,marginBottom:6}}>
                    <div style={{color:C.text,fontSize:11,fontWeight:700,flex:1}}>{item.nombre}</div>
                    <button onClick={()=>setCart(p=>p.filter(c=>c.id!==item.id))} style={{background:"none",border:"none",color:C.red,cursor:"pointer",fontSize:14}}>×</button>
                  </div>
                  <div style={{display:"flex",justifyContent:"space-between",alignItems:"center"}}>
                    <div style={{display:"flex",alignItems:"center",gap:6}}>
                      <button onClick={()=>setCart(p=>p.map(c=>c.id===item.id?{...c,qty:Math.max(1,c.qty-1)}:c))} style={{width:22,height:22,borderRadius:4,border:`1px solid ${C.border}`,background:"none",color:C.text,cursor:"pointer",fontSize:13}}>−</button>
                      <span style={{color:C.text,fontSize:12,fontWeight:700}}>{item.qty}</span>
                  <button onClick={()=>setCart(p=>p.map(c=>c.id===item.id?((c.esUnidad&&c.qty>=(item.stock_unidades||0))?(showToast(`Máx unidades: ${item.stock_unidades||0}`,"warning"),c):(!c.esUnidad&&c.qty>=(item.stock||99)?(showToast(`Máx: ${item.stock}`,"warning"),c):{...c,qty:c.qty+1})):c))} style={{width:22,height:22,borderRadius:4,border:`1px solid ${C.border}`,background:"none",color:C.text,cursor:"pointer",fontSize:13}}>+</button>
                    </div>
                    <span style={{color:C.blue,fontWeight:700,fontSize:13}}>{$(item.precio*item.qty)}</span>
                  </div>
                </div>
              ))}
            </Box>
            {/* Sugerencias */}
            {cart.length>0&&(()=>{
              const cats = [...new Set(cart.map(i=>i.categoria).filter(Boolean))];
              const idsEnCart = new Set(cart.map(i=>typeof i.id==="string"?i.id:String(i.id)));
              const sugs = productos.filter(p=>
                cats.includes(p.categoria) &&
                !idsEnCart.has(String(p.id)) &&
                p.activo && p.stock>0
              ).slice(0,4);
              if(!sugs.length) return null;
              return (
                <Box style={{padding:12,marginBottom:12}}>
                  <div style={{color:C.textMid,fontSize:10,fontWeight:700,letterSpacing:1,textTransform:"uppercase",marginBottom:8}}>💡 Sugeridos</div>
                  <div style={{display:"flex",flexDirection:"column",gap:6}}>
                    {sugs.map(p=>(
                      <div key={p.id} style={{display:"flex",justifyContent:"space-between",alignItems:"center",padding:"6px 8px",borderRadius:7,background:C.bg,cursor:"pointer"}}
                        onClick={()=>add(p,false)}
                        onMouseEnter={e=>e.currentTarget.style.background=C.blueDim}
                        onMouseLeave={e=>e.currentTarget.style.background=C.bg}>
                        <div style={{flex:1}}>
                          <div style={{color:C.text,fontSize:11,fontWeight:600,lineHeight:1.3}}>{p.nombre}</div>
                          <div style={{color:C.textDim,fontSize:9}}>{p.categoria}</div>
                        </div>
                        <div style={{display:"flex",alignItems:"center",gap:6,flexShrink:0}}>
                          <span style={{color:C.blue,fontWeight:700,fontSize:11}}>{$(p.precio||p.precio||0)}</span>
                          <span style={{color:C.green,fontSize:14,fontWeight:700}}>+</span>
                        </div>
                      </div>
                    ))}
                  </div>
                </Box>
              );
            })()}

            {/* Método pago */}
            <Box style={{padding:14,marginBottom:12}}>
              <div style={{color:C.textDim,fontSize:10,letterSpacing:1.5,textTransform:"uppercase",marginBottom:8}}>Método de pago</div>
              <div style={{display:"flex",gap:5,flexWrap:"wrap"}}>
                {[["efectivo","Efectivo"],["tarjeta","Tarjeta (Point)"]].map(([v,l])=>(
                  <button key={v} type="button" onClick={()=>{ setPay(v); if(v!=="efectivo") setMontoRecibido(""); }} style={{padding:"4px 10px",borderRadius:20,border:`1px solid ${pay===v?C.blue:C.border}`,background:pay===v?C.blueDim:"transparent",color:pay===v?C.blue:C.textMid,fontSize:10,fontWeight:700,cursor:"pointer"}}>{l}</button>
                ))}
              </div>
            </Box>
            {pay==="efectivo"&&cart.length>0&&(
              <Box style={{padding:14,marginBottom:12,background:C.greenDim,border:`1px solid ${C.green}25`}}>
                <div style={{color:C.textDim,fontSize:10,letterSpacing:1.2,textTransform:"uppercase",marginBottom:8}}>Efectivo</div>
                <div style={{color:C.textMid,fontSize:11,marginBottom:8}}>¿Cuánto te entregó el cliente?</div>
                <Inp
                  value={montoRecibido}
                  onChange={(e)=>setMontoRecibido(e.target.value)}
                  placeholder={`Mínimo ${$(total)}`}
                  inputMode="decimal"
                  style={{width:"100%",boxSizing:"border-box",marginBottom:8,fontSize:16,fontWeight:700}}
                />
                <div style={{display:"flex",gap:6,flexWrap:"wrap",marginBottom:10}}>
                  <button type="button" onClick={()=>setMontoRecibido(String(total))} style={{padding:"4px 10px",borderRadius:8,border:`1px solid ${C.green}`,background:"#fff",color:C.green,fontSize:10,fontWeight:700,cursor:"pointer"}}>Exacto {$(total)}</button>
                  {sugerenciasPagoCliente(total).map(({billete,cambio})=>(
                    <button key={billete} type="button" onClick={()=>setMontoRecibido(String(billete))} style={{padding:"4px 10px",borderRadius:8,border:`1px solid ${C.border}`,background:C.card,fontSize:10,fontWeight:600,cursor:"pointer",color:C.text}}>
                      ${billete} → cambio {$(cambio)}
                    </button>
                  ))}
                </div>
                {Number.isFinite(recibidoNum)&&recibidoNum>=total&&(
                  <div style={{marginBottom:8}}>
                    <div style={{display:"flex",justifyContent:"space-between",alignItems:"baseline"}}>
                      <span style={{color:C.textMid,fontSize:12}}>Cambio a entregar</span>
                      <span style={{color:C.green,fontWeight:900,fontSize:22}}>{$(cambioNum)}</span>
                    </div>
                    {cambioNum>0&&desgloseCambioMN(cambioNum)&&(
                      <div style={{color:C.textMid,fontSize:10,marginTop:4,lineHeight:1.4}}>
                        <strong style={{color:C.text}}>Sugerido:</strong> {desgloseCambioMN(cambioNum)}
                      </div>
                    )}
                  </div>
                )}
                {Number.isFinite(recibidoNum)&&recibidoNum>0&&recibidoNum<total&&(
                  <div style={{color:C.red,fontSize:11,fontWeight:700}}>Falta ${(total-recibidoNum).toFixed(2)}</div>
                )}
                <div style={{color:C.textDim,fontSize:9,marginTop:6,lineHeight:1.35}}>
                  Consejo caja: si te quedas sin billetes chicos, pide al cliente pagar con el monto exacto o con billetes que dejen un cambio “redondo” (usa los botones de arriba). Para control fino por denominación usa el corte de caja al cerrar turno.
                </div>
              </Box>
            )}
            {/* Total */}
            <div data-tour="pos-cobrar">
            <Box style={{padding:16}}>
              <div style={{display:"flex",justifyContent:"space-between",marginBottom:4}}>
                <span style={{color:C.textMid,fontSize:13}}>Total</span>
                <span style={{color:C.blue,fontWeight:900,fontSize:20}}>{$(total)}</span>
              </div>
              {cli&&<div style={{color:C.purple,fontSize:11,fontWeight:700,marginBottom:10}}>+{ptsG} puntos → {cli.nombre}</div>}
              {pay==="efectivo" ? (
                <Btn onClick={cobrar} full col={C.green} dis={!cart.length||guardando||(!Number.isFinite(recibidoNum)||recibidoNum<total)}
                  onKeyDown={e=>e.key==="Enter"&&!guardando&&cart.length&&Number.isFinite(recibidoNum)&&recibidoNum>=total&&cobrar()}
                >{guardando?"Procesando...":"✅ Cobrar "+$(total)}</Btn>
              ) : (
                <div>
                  <Btn onClick={()=>abrirModalRecetaVenta("tarjeta")}
                    full col="#009ee3" dis={!cart.length||guardando}
                  >💳 Cobrar con tarjeta (terminal Point)</Btn>
                  <div style={{color:C.textDim,fontSize:10,marginTop:10,lineHeight:1.45}}>
                    La app <strong>espera</strong> a que el Point Smart 2 confirme el pago con tarjeta. Recién entonces se registra la venta y se envía el ticket a la impresora Epson (mismo flujo que al cobrar en efectivo).
                  </div>
                </div>
              )}
            </Box>
            </div>
          </div>}
        </div>
      )}

      {/* TAB: PEDIDOS ONLINE */}
      {tab==="online"&&(
        <div>
          {loading?<SkeletonTable rows={3} cols={4}/>:
           !pedOnline.length?<div style={{color:C.textMid,padding:40,textAlign:"center"}}>✓ Sin pedidos online pendientes</div>:
           pedOnline.map(p=>(
            <Box key={p.id} style={{padding:20,marginBottom:12}}>
              <div style={{display:"flex",justifyContent:"space-between",alignItems:"flex-start",marginBottom:12}}>
                <div>
                  <div style={{color:C.text,fontWeight:800,fontSize:15}}>Pedido #{p.id} — Online</div>
                  <div style={{color:C.textMid,fontSize:12,marginTop:3}}>{p.clientes?.nombre} · {p.clientes?.telefono}</div>
                  <div style={{color:C.textDim,fontSize:11,marginTop:2}}>{new Date(p.created_at).toLocaleString("es-MX")}</div>
                </div>
                <div style={{textAlign:"right"}}>
                  <div style={{color:C.blue,fontWeight:900,fontSize:18}}>{$(p.total)}</div>
                  <Tag col={C.amber} sm>Pendiente</Tag>
                </div>
              </div>
              <div style={{background:C.bg,borderRadius:8,padding:"10px 14px",marginBottom:12}}>
                <div style={{color:C.textDim,fontSize:10,letterSpacing:1,textTransform:"uppercase",marginBottom:6}}>Productos</div>
                {(p.pedido_items||[]).map((item,i)=>(
                  <div key={i} style={{display:"flex",justifyContent:"space-between",marginBottom:4}}>
                    <span style={{color:C.text,fontSize:12}}>{item.productos?.nombre} ×{item.cantidad}</span>
                    <span style={{color:C.blue,fontSize:12,fontWeight:700}}>{$(item.precio_unitario*item.cantidad)}</span>
                  </div>
                ))}
              </div>
              <div style={{display:"flex",gap:8}}>
                <Btn onClick={()=>surtirOnline(p)} col={C.green} dis={guardando}>✓ Surtir y marcar listo</Btn>
                <Btn ol col={C.red} sm onClick={async()=>{
                  const tok = sessionStorage.getItem("farmax_session_token");
                  const { error } = await supabase.rpc("admin_cancelar_pedido", {
                    p_session_token: tok, p_pedido_id: p.id,
                  });
                  if (error) showToast("Error: "+error.message, "error");
                  setPedOn(x=>x.filter(z=>z.id!==p.id));
                }}>Cancelar</Btn>
              </div>
            </Box>
          ))}
        </div>
      )}

      {/* TAB: COBRAR CONSULTAS */}
      {tab==="consultas"&&(
        <div>
          <div style={{background:C.blueDim,border:`1px solid ${C.blue}30`,borderRadius:10,padding:"12px 16px",marginBottom:16}}>
            <div style={{color:C.blue,fontSize:13,fontWeight:700,lineHeight:1.45}}>
              ℹ Agenda del día: citas en línea y en mostrador. Las citas hechas <strong>en la tienda en línea</strong> quedan <strong>pendientes de pago</strong> hasta que el paciente pague en caja. Cobrar aquí para que la doctora vea el nombre y <strong>Pagado</strong>. Consulta {$(parseFloat(config?.precio_consulta)||CONSULTA_PRECIO_DEFAULT)}.
              {usuario?.rol==="admin" && (
                <span style={{display:"block",marginTop:8,fontSize:11,color:C.textMid,fontWeight:600}}>
                  Reparto interno (solo admin): 70% médico / 30% farmacia sobre el monto de la consulta.
                </span>
              )}
            </div>
          </div>

          {/* Agenda de hoy (todas las citas activas) */}
          <Box style={{padding:18,marginBottom:16}}>
            <div style={{display:"flex",flexWrap:"wrap",alignItems:"center",gap:10,marginBottom:10}}>
              <div style={{color:C.text,fontWeight:800,fontSize:14}}>📅 Agenda</div>
              <div style={{display:"flex",gap:6,flexWrap:"wrap"}}>
                {[
                  ["hoy","Hoy"],
                  ["dia","Elegir día"],
                  ["semana","Esta semana"],
                ].map(([v,l])=>(
                  <button key={v} type="button" onClick={()=>setRangoAgendaPOS(v)} style={{
                    padding:"5px 12px",borderRadius:20,border:`1px solid ${rangoAgendaPOS===v?BRAND.primary:C.border}`,
                    background:rangoAgendaPOS===v?BRAND.primary+"18":"transparent",color:rangoAgendaPOS===v?BRAND.secondary:C.textMid,
                    fontSize:11,fontWeight:700,cursor:"pointer",
                  }}>{l}</button>
                ))}
              </div>
            </div>
            {rangoAgendaPOS==="dia"&&(
              <div style={{marginBottom:12,padding:"10px 12px",background:C.bg,borderRadius:10,border:`1px solid ${C.border}`}}>
                <div style={{color:C.textDim,fontSize:10,fontWeight:700,letterSpacing:.5,marginBottom:8}}>VER OTRO DÍA</div>
                <div style={{display:"flex",flexWrap:"wrap",alignItems:"center",gap:8}}>
                  <button type="button" onClick={()=>setFechaAgendaElegida((p)=>addDaysSv(p,-1))} title="Día anterior"
                    style={{padding:"6px 10px",borderRadius:8,border:`1px solid ${C.border}`,background:C.card,cursor:"pointer",fontWeight:800}}>◀</button>
                  <input type="date" value={fechaAgendaElegida} onChange={(e)=>setFechaAgendaElegida(e.target.value)}
                    style={{padding:"6px 10px",borderRadius:8,border:`1px solid ${C.border}`,fontSize:13,fontWeight:600,color:C.text}} />
                  <button type="button" onClick={()=>setFechaAgendaElegida((p)=>addDaysSv(p,1))} title="Día siguiente"
                    style={{padding:"6px 10px",borderRadius:8,border:`1px solid ${C.border}`,background:C.card,cursor:"pointer",fontWeight:800}}>▶</button>
                  <button type="button" onClick={()=>setFechaAgendaElegida(new Date().toLocaleDateString("sv-SE"))} style={{padding:"6px 10px",borderRadius:8,border:`1px solid ${C.blue}40`,background:C.blueDim,color:C.blue,cursor:"pointer",fontSize:11,fontWeight:700}}>Ir a hoy</button>
                  <button type="button" onClick={()=>setFechaAgendaElegida(addDaysSv(new Date().toLocaleDateString("sv-SE"),1))} style={{padding:"6px 10px",borderRadius:8,border:`1px solid ${C.green}40`,background:C.greenDim,color:C.greenDark,cursor:"pointer",fontSize:11,fontWeight:700}}>Mañana</button>
                </div>
                <div style={{color:C.textMid,fontSize:12,marginTop:8,textTransform:"capitalize"}}>{formatFechaAgendaLargaEs(fechaAgendaElegida)}</div>
                <div style={{color:C.textDim,fontSize:10,marginTop:6,lineHeight:1.4}}>El campo de fecha abre el calendario del sistema (móvil o escritorio). Las flechas cambian un día.</div>
              </div>
            )}
            <div style={{color:C.textMid,fontSize:11,marginBottom:12}}>
              {citasAgenda.length} cita{citasAgenda.length!==1?"s":""} en el período. Un solo cupo por horario (una doctora). Tras hora + 10 min sin pago, puedes cancelar y liberar el espacio.
            </div>
            {!citasAgenda.length ? (
              <div style={{color:C.textDim,fontSize:13}}>
                {rangoAgendaPOS==="hoy"&&"Sin citas para hoy."}
                {rangoAgendaPOS==="dia"&&"Sin citas para el día seleccionado."}
                {rangoAgendaPOS==="semana"&&"Sin citas en esta semana (lun–dom)."}
              </div>
            ) : (
              <div style={{display:"grid",gap:8}}>
                {[...citasAgenda].sort((a,b)=>{
                  const df = String(a.fecha||"").localeCompare(String(b.fecha||""));
                  if (df !== 0) return df;
                  return String(a.hora||"").localeCompare(String(b.hora||""));
                }).map((c)=>(
                  <div key={c.id} style={{display:"flex",flexWrap:"wrap",alignItems:"center",gap:10,justifyContent:"space-between",padding:"10px 12px",background:C.bg,borderRadius:8,border:`1px solid ${C.border}`}}>
                    <div style={{minWidth:200}}>
                      {rangoAgendaPOS==="semana"&&c.fecha&&(
                        <div style={{color:C.textDim,fontSize:10,marginBottom:2}}>{c.fecha}</div>
                      )}
                      <span style={{color:C.blue,fontWeight:800,fontSize:13}}>{c.hora}</span>
                      <span style={{color:C.text,fontWeight:700,marginLeft:10}}>{c.nombre}</span>
                      <div style={{color:C.textMid,fontSize:11,marginTop:2}}>{c.telefono||"—"} · {c.motivo||"Consulta"}</div>
                      <div style={{display:"flex",gap:6,flexWrap:"wrap",marginTop:6}}>
                        {citaPagoPendiente(c) && <Tag col={C.amber} sm>Pendiente de pago</Tag>}
                        {citaEstaPagada(c) && <Tag col={C.green} sm>Pagada</Tag>}
                        {c.canal && <Tag col={C.teal} sm>{labelCanal(c)}</Tag>}
                        <Tag col={C.textDim} sm>{c.estado}</Tag>
                      </div>
                    </div>
                    <div style={{display:"flex",gap:8,flexWrap:"wrap"}}>
                      {puedeCancelarCitaNoShow(c) && (
                        <Btn sm ol col={C.red} onClick={()=>cancelarCitaPorNoShow(c)} dis={guardando}>Cancelar (no asistió)</Btn>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            )}
          </Box>

          {/* Nueva cita mostrador */}
          <Box style={{padding:18,marginBottom:16}}>
            <div style={{color:C.text,fontWeight:800,fontSize:14,marginBottom:12}}>➕ Nueva cita (mostrador)</div>
            <div style={{display:"grid",gridTemplateColumns:"repeat(auto-fill,minmax(200px,1fr))",gap:12}}>
              <div><div style={{color:C.textMid,fontSize:11,marginBottom:4}}>Nombre</div><Inp value={nuevaCita.nombre} onChange={e=>setNuevaCita(p=>({...p,nombre:e.target.value}))} placeholder="Paciente" style={{width:"100%"}}/></div>
              <div><div style={{color:C.textMid,fontSize:11,marginBottom:4}}>Teléfono</div><Inp value={nuevaCita.telefono} onChange={e=>setNuevaCita(p=>({...p,telefono:e.target.value}))} placeholder="55…" type="tel" style={{width:"100%"}}/></div>
              <div><div style={{color:C.textMid,fontSize:11,marginBottom:4}}>Fecha</div><input type="date" value={nuevaCita.fecha} onChange={e=>setNuevaCita(p=>({...p,fecha:e.target.value}))} min={new Date().toLocaleDateString("sv-SE")} style={{width:"100%",padding:"9px 11px",borderRadius:8,border:`1px solid ${C.border}`,fontSize:13}}/></div>
              <div>
                <div style={{color:C.textMid,fontSize:11,marginBottom:4}}>Hora</div>
                <select value={nuevaCita.hora} onChange={e=>setNuevaCita(p=>({...p,hora:e.target.value}))} style={{width:"100%",padding:"9px 11px",borderRadius:8,border:`1px solid ${C.border}`,fontSize:13}}>
                  <option value="">Seleccionar…</option>
                  {horariosDisponiblesCita(nuevaCita.fecha).filter((h)=>(ocupacionPorHora[h]||0)<1).map((h)=>(
                    <option key={h} value={h}>{h}</option>
                  ))}
                </select>
              </div>
            </div>
            <div style={{marginTop:12}}><div style={{color:C.textMid,fontSize:11,marginBottom:4}}>Motivo (opcional)</div><Inp value={nuevaCita.motivo} onChange={e=>setNuevaCita(p=>({...p,motivo:e.target.value}))} placeholder="Ej. control, dolor…" style={{width:"100%",maxWidth:480}}/></div>
            <Btn col={BRAND.primary} style={{marginTop:14}} onClick={guardarNuevaCitaMostrador} dis={guardando}>Guardar cita</Btn>
          </Box>

          <div style={{color:C.text,fontWeight:800,fontSize:14,marginBottom:10}}>💳 Cobrar en caja</div>
          <div style={{color:C.textMid,fontSize:12,marginBottom:14}}>Solo aparecen citas con consulta o consumibles pendientes de cobro.</div>

          {!consxCobrar.length?<div style={{color:C.textMid,padding:24,textAlign:"center"}}>✓ Nada pendiente de cobro en caja</div>:
           consxCobrar.map(cita=>{
            const precioBase = parseFloat(config?.precio_consulta) || CONSULTA_PRECIO_DEFAULT;
            const yaPagoConsulta =
              cita.pago_estado === "pagada" || cita.estado === "pagada" || !!cita.pedido_consulta_id;
            const consumibles=(cita.consumibles_consulta||[]).filter(c=>!c.cobrado);
            const totalCons=consumibles.reduce((a,c)=>a+c.precio*c.cantidad,0);
            const totalCobro = (yaPagoConsulta ? 0 : precioBase) + totalCons;
            return(
              <Box key={cita.id} style={{padding:20,marginBottom:12}}>
                <div style={{display:"flex",justifyContent:"space-between",marginBottom:12}}>
                  <div>
                    <div style={{display:"flex",alignItems:"center",gap:8,flexWrap:"wrap"}}>
                      <div style={{color:C.text,fontWeight:800,fontSize:15}}>Consulta — {cita.nombre}</div>
                      {citaPagoPendiente(cita) && <Tag col={C.amber} sm>Pendiente de pago</Tag>}
                      {cita.canal && <Tag col={C.blue} sm>{labelCanal(cita)}</Tag>}
                    </div>
                    <div style={{color:C.textMid,fontSize:12,marginTop:2}}>{cita.hora} hrs · {cita.motivo||"Consulta general"}</div>
                  </div>
                  <div style={{textAlign:"right"}}>
                    <div style={{color:C.green,fontWeight:900,fontSize:18}}>{$(totalCobro)}</div>
                    <div style={{color:C.textDim,fontSize:10}}>
                      {yaPagoConsulta ? `Solo consumibles · ` : `Consulta ${$(precioBase)} + consumibles · `}
                      {totalCons>0?$(totalCons):"$0.00"}
                    </div>
                  </div>
                </div>
                {consumibles.length>0&&(
                  <div style={{background:C.bg,borderRadius:8,padding:"10px 14px",marginBottom:12}}>
                    <div style={{color:C.textDim,fontSize:10,letterSpacing:1,marginBottom:6}}>CONSUMIBLES USADOS</div>
                    {consumibles.map((c,i)=>(
                      <div key={i} style={{display:"flex",justifyContent:"space-between",marginBottom:3}}>
                        <span style={{color:C.text,fontSize:12}}>{c.productos?.nombre} ×{c.cantidad}</span>
                        <span style={{color:C.amber,fontSize:12,fontWeight:700}}>{$(c.precio*c.cantidad)}</span>
                      </div>
                    ))}
                  </div>
                )}
                <Inp value={tel} onChange={e=>buscarCli(e.target.value)} placeholder="📱 Teléfono cliente (puntos)" type="tel" style={{width:"100%",boxSizing:"border-box",marginBottom:8}}/>
                {cli&&<div style={{background:C.purpleDim,border:`1px solid ${C.purple}30`,borderRadius:6,padding:"6px 10px",marginBottom:8}}><span style={{color:C.purple,fontSize:11,fontWeight:700}}>{cli.nombre} · {cli.puntos||0} pts</span></div>}
                <div style={{display:"flex",gap:6,marginBottom:10,flexWrap:"wrap"}}>
                  {[["efectivo","Efectivo"],["tarjeta","Tarjeta (Point)"]].map(([v,l])=>(
                    <button key={v} type="button" onClick={()=>setPay(v)} style={{padding:"4px 10px",borderRadius:20,border:`1px solid ${pay===v?C.green:C.border}`,background:pay===v?C.greenDim:"transparent",color:pay===v?C.green:C.textMid,fontSize:10,fontWeight:700,cursor:"pointer"}}>{l}</button>
                  ))}
                </div>
                <div style={{display:"flex",gap:8,flexWrap:"wrap",alignItems:"center"}}>
                  {pay==="efectivo" ? (
                    <Btn onClick={()=>cobrarConsulta(cita)} col={C.green} dis={guardando} style={{flex:"1 1 200px"}}>✅ Cobrar {$(totalCobro)}</Btn>
                  ) : (
                    <div style={{flex:1,minWidth:220}}>
                      <Btn
                        onClick={()=>{
                          setPay("tarjeta");
                          mpCitaRef.current = cita;
                          setMpFolio(`CONS-${cita.id}`);
                          setMpModal(true);
                        }}
                        col="#009ee3"
                        dis={guardando||totalCobro<=0}
                        full
                      >💳 Cobrar con tarjeta (terminal Point)</Btn>
                      <div style={{color:C.textDim,fontSize:10,marginTop:8,lineHeight:1.4}}>
                        Mismo flujo que en venta: se espera la aprobación en el Point; luego se marca pagada la consulta y se imprime el ticket.
                      </div>
                    </div>
                  )}
                </div>
              </Box>
            );
          })}
        </div>
      )}
      <OnboardingTour tourId="pos" usuario={usuario} />
    </div>
  );
}

// ══════════════════════════════════════════════════════════════
// CONSULTORIO — Vista Admin (agenda + expedientes)
// ══════════════════════════════════════════════════════════════
function Consultorio(){
  const C = C_LIGHT;
  const [citas,setCitas]   = useState([]);
  const [exps,setExps]     = useState([]);
  const [tab,setTab]       = useState("agenda");
  const [loading,setLoad]  = useState(true);
  const hoy = new Date().toISOString().split("T")[0];

  useEffect(()=>{
    const cargar = async () => {
      setLoad(true);
      try {
        const hoyLocal = new Date().toLocaleDateString("sv-SE");
        const citasRes = await supabase.from("citas").select(`
            id,nombre,telefono,hora,fecha,motivo,estado,cliente_id,canal,pago_estado,
            consumibles_consulta!cita_id(id,cantidad,precio,cobrado,productos!producto_id(nombre))
          `).eq("fecha", hoyLocal).in("estado",["confirmada","en_consulta","completada","pagada"]);

        if (citasRes?.error) console.error("[Consultorio] Citas:", citasRes.error);
        setCitas(citasRes?.data || []);
      } catch (e) {
        console.error("[Consultorio] cargar:", e);
        setCitas([]);
      } finally {
        setLoad(false);
      }
    };
    cargar();
  },[]);


  return(
    <div>
      <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:20}}>
        <h1 style={{color:C.text,fontSize:20,fontWeight:800,margin:0}}>♥ Consultorio — Dra. Lourdes Lucio Falcón</h1>
        <Tag col={C.green}>Médico General</Tag>
      </div>
      {/* Alerta citas online */}
      {citas.filter(c=>c.cliente_id).length>0&&(
        <div style={{background:C.blueDim,border:`1px solid ${C.blue}30`,borderRadius:10,padding:"10px 16px",marginBottom:14}}>
          <div style={{color:C.blue,fontSize:13,fontWeight:700}}>🌐 {citas.filter(c=>c.cliente_id).length} citas agendadas desde la tienda web farmax-seven.vercel.app</div>
        </div>
      )}
      <div style={{display:"flex",gap:6,marginBottom:16}}>
        {[["agenda","📅 Agenda hoy"],["expedientes","📋 Clientes"]].map(([v,l])=>(
          <button key={v} onClick={()=>setTab(v)} style={{padding:"7px 14px",borderRadius:8,border:`1px solid ${tab===v?BRAND.primary:C.border}`,background:tab===v?BRAND.primary+"18":"transparent",color:tab===v?BRAND.secondary:C.textMid,fontSize:12,fontWeight:700,cursor:"pointer"}}>{l}</button>
        ))}
      </div>
      {tab==="agenda"&&(
        loading?<SkeletonTable rows={4} cols={5}/>:
        !citas.length?<Box style={{padding:40,textAlign:"center"}}><div style={{color:C.textMid}}>Sin citas agendadas para hoy</div></Box>:
        <div style={{display:"grid",gap:10}}>
          {citas.map(c=>(
            <Box key={c.id} style={{padding:18}}>
              <div style={{display:"flex",alignItems:"center",gap:14}}>
                <div style={{color:C.blue,fontWeight:800,fontSize:16,width:50,flexShrink:0}}>{c.hora}</div>
                <div style={{flex:1}}>
                  <div style={{color:C.text,fontWeight:700,fontSize:14}}>{c.nombre}</div>
                  <div style={{color:C.textMid,fontSize:12,marginTop:2}}>{c.motivo||"Consulta general"} {c.telefono&&`· ${c.telefono}`}</div>
                  <div style={{display:"flex",gap:6,flexWrap:"wrap",marginTop:6}}>
                    {c.cliente_id&&<Tag col={C.blue} sm>App web</Tag>}
                    {citaPagoPendiente(c) && <Tag col={C.amber} sm>Pendiente de pago</Tag>}
                    {c.canal && <Tag col={C.teal} sm>{labelCanal(c)}</Tag>}
                  </div>
                </div>
                <Tag col={c.estado==="completada"?C.green:c.estado==="confirmada"?C.blue:c.estado==="pagada"?C.purple:C.amber} sm>{c.estado||"pendiente"}</Tag>
              </div>
            </Box>
          ))}
        </div>
      )}
      {tab==="expedientes"&&(
        <Box>
          <table style={{width:"100%",borderCollapse:"collapse"}}>
            <thead><tr>{["Nombre","Teléfono","Registrado"].map(h=><th key={h} style={{padding:"8px 14px",color:C.textDim,fontSize:9,textAlign:"left",letterSpacing:1.5,textTransform:"uppercase",borderBottom:`1px solid ${C.border}`}}>{h}</th>)}</tr></thead>
            <tbody>
              {exps.map(e=>(
                <tr key={e.id}>
                  <td style={{padding:"10px 14px",color:C.text,fontWeight:700,fontSize:13}}>{e.nombre}</td>
                  <td style={{padding:"10px 14px",color:C.textMid,fontSize:12}}>{e.telefono}</td>
                  <td style={{padding:"10px 14px",color:C.textDim,fontSize:11}}>{new Date(e.created_at).toLocaleDateString("es-MX")}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </Box>
      )}
    </div>
  );
}

// ══════════════════════════════════════════════════════════════
// MÓDULO DOCTORA — Su vista propia
// Agenda + ficha + consumibles / procedimientos
// ══════════════════════════════════════════════════════════════
function ConsDoctora() {
  const C = C_LIGHT;
  const [citas, setCitas] = useState([]);
  const [loading, setLoad] = useState(true);
  const [citaSel, setCitaSel] = useState(null);
  const [prodList, setProdList] = useState([]);
  const [procsList, setProcsList] = useState([]);
  const [guardando, setGuard] = useState(false);
  const [fichaCita, setFichaCita] = useState(null);
  const hoyLocal = new Date().toLocaleDateString("sv-SE");

  const recargar = useCallback(async () => {
    const [consumibles, citasRes, procRes] = await Promise.all([
      fetchProductosConsumiblesConsultorio(supabase),
      supabase.from("citas").select(`
          id,nombre,telefono,hora,fecha,motivo,estado,canal,pago_estado,cliente_id,
          confirmada_inicio_at,
          consumibles_consulta!cita_id(id,cantidad,precio,cobrado,productos!producto_id(nombre))
        `)
        .eq("fecha", hoyLocal)
        .in("estado", ["confirmada", "en_consulta", "completada", "pagada"]),
      supabase.from("procedimientos_medicos").select("*").eq("activo", true).order("nombre"),
    ]);
    if (citasRes?.error) console.error("[ConsDoctora] Citas:", citasRes.error);
    if (procRes?.error) console.error("[ConsDoctora] Procedimientos:", procRes.error);
    setProdList(consumibles || []);
    setCitas(citasRes?.data || []);
    setProcsList(procRes?.data || []);
  }, [hoyLocal]);

  useEffect(() => {
    (async () => {
      setLoad(true);
      try {
        await recargar();
      } catch (e) {
        console.error("[ConsDoctora] cargar:", e);
        setProdList([]);
        setCitas([]);
        setProcsList([]);
      } finally {
        setLoad(false);
      }
    })();
  }, [recargar]);

  const agregarConsumible = async (cita, prod, qty) => {
    setGuard(true);
    try {
      const tok = sessionStorage.getItem("farmax_session_token");
      if (!tok) throw new Error("Sesión expirada");
      const { data: resp, error } = await supabase.rpc("agregar_consumible_cita", {
        p_session_token: tok,
        p_cita_id: cita.id,
        p_producto_id: prod.id,
        p_cantidad: qty,
        p_precio: prod.precio,
      });
      if (error) throw error;
      if (!resp?.success) throw new Error(resp?.error || "No se pudo agregar");
      await recargar();
      const { data: fresh } = await supabase
        .from("citas")
        .select(`*,consumibles_consulta(*,productos!producto_id(nombre))`)
        .eq("id", cita.id)
        .single();
      if (fresh) setCitaSel(fresh);
    } catch (e) {
      console.error(e);
    }
    setGuard(false);
  };

  const confirmarInicio = async (cita) => {
    if (!citaPagoOk(cita)) return;
    const otraEnConsulta = citas.some((x) => x.id !== cita.id && x.estado === "en_consulta");
    if (otraEnConsulta) {
      showToast("Termina la consulta en curso (o márcala como terminada) antes de iniciar otra.", "warning");
      return;
    }
    setGuard(true);
    try {
      const tok = sessionStorage.getItem("farmax_session_token");
      const { error } = await supabase.rpc("actualizar_estado_cita", {
        p_session_token: tok, p_cita_id: cita.id, p_estado: "en_consulta",
      });
      if (error) throw error;
      await recargar();
    } catch (e) {
      console.error(e);
      alert("No se pudo confirmar el inicio: " + (e?.message || e));
    }
    setGuard(false);
  };

  const completarCita = async (cita) => {
    setGuard(true);
    try {
      const tok = sessionStorage.getItem("farmax_session_token");
      const diag = (cita.diagnostico && String(cita.diagnostico).trim())
        ? String(cita.diagnostico).trim()
        : "Consulta finalizada.";
      const meds = Array.isArray(cita.medicamentos_prescritos) ? cita.medicamentos_prescritos : [];
      const procs = Array.isArray(cita.procedimientos_realizados) ? cita.procedimientos_realizados : [];
      const { error } = await supabase.rpc("doctora_completar_consulta", {
        p_session_token: tok,
        p_cita_id: cita.id,
        p_diagnostico: diag,
        p_medicamentos: meds,
        p_procedimientos: procs,
        p_completar: true,
      });
      if (error) throw error;
      setCitaSel(null);
      await recargar();
      showToast("Consulta terminada.", "success");
    } catch (e) {
      console.error(e);
      showToast("No se pudo terminar la consulta: " + (e?.message || e), "error");
    }
    setGuard(false);
  };

  const pagoEtiqueta = (c) => {
    if (citaPagoPendiente(c)) return { col: C.amber, txt: "Pendiente de pago" };
    if (citaPagoOk(c) || c.estado === "pagada") return { col: C.green, txt: "Pagada" };
    return { col: C.textDim, txt: "—" };
  };

  const puedeConsumibles = (c) =>
    c.estado !== "completada" && (c.estado === "en_consulta" || c.estado === "confirmada" || c.estado === "pagada");

  return (
    <div>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 20 }}>
        <div>
          <h1 style={{ color: C.text, fontSize: 20, fontWeight: 800, margin: 0 }}>♥ Mi Consultorio</h1>
          <div style={{ color: C.textMid, fontSize: 12, marginTop: 4 }}>
            Dra. Lourdes Lucio Falcón · Médico General · {new Date().toLocaleDateString("es-MX")}
          </div>
        </div>
        <Tag col={C.green}>En turno</Tag>
      </div>

      <CitaFichaModal
        cita={fichaCita}
        open={!!fichaCita}
        onClose={() => setFichaCita(null)}
        prodList={prodList}
        procsList={procsList}
        onSaved={recargar}
      />

      <Modal open={!!citaSel} onClose={() => setCitaSel(null)} title="➕ Registrar consumibles usados" ac={C.amber}>
        {citaSel && (
          <>
            <div style={{ color: C.textMid, fontSize: 13, marginBottom: 16 }}>
              Paciente:{" "}
              <strong style={{ color: C.text }}>{citaSel.nombre}</strong>
            </div>
            <div style={{ color: C.textDim, fontSize: 10, letterSpacing: 1, textTransform: "uppercase", marginBottom: 8 }}>Seleccionar consumible</div>
            <div style={{ display: "grid", gap: 6, maxHeight: 300, overflowY: "auto" }}>
              {prodList.map((p) => (
                <div
                  key={p.id}
                  style={{
                    display: "flex",
                    justifyContent: "space-between",
                    alignItems: "center",
                    padding: "8px 12px",
                    background: C.bg,
                    borderRadius: 8,
                    border: `1px solid ${C.border}`,
                  }}
                >
                  <div>
                    <div style={{ color: C.text, fontSize: 12, fontWeight: 700 }}>{p.nombre}</div>
                    <div style={{ color: C.textMid, fontSize: 11 }}>
                      {$(p.precio)}/ud
                    </div>
                  </div>
                  <div style={{ display: "flex", gap: 4 }}>
                    {[1, 2, 3].map((qty) => (
                      <button
                        key={qty}
                        onClick={() => agregarConsumible(citaSel, p, qty)}
                        disabled={guardando}
                        style={{
                          padding: "4px 10px",
                          borderRadius: 6,
                          border: `1px solid ${C.blue}`,
                          background: C.blueDim,
                          color: C.blue,
                          fontSize: 11,
                          fontWeight: 700,
                          cursor: "pointer",
                        }}
                      >
                        +{qty}
                      </button>
                    ))}
                  </div>
                </div>
              ))}
            </div>
            {(citaSel.consumibles_consulta || []).length > 0 && (
              <div style={{ marginTop: 16 }}>
                <div style={{ color: C.textDim, fontSize: 10, letterSpacing: 1, textTransform: "uppercase", marginBottom: 8 }}>Ya registrado</div>
                {citaSel.consumibles_consulta.map((c, i) => (
                  <div key={i} style={{ display: "flex", justifyContent: "space-between", padding: "5px 0", borderBottom: `1px solid ${C.border}` }}>
                    <span style={{ color: C.text, fontSize: 12 }}>
                      {c.productos?.nombre} ×{c.cantidad}
                    </span>
                    <span style={{ color: C.amber, fontSize: 12, fontWeight: 700 }}>{$(c.precio * c.cantidad)}</span>
                  </div>
                ))}
              </div>
            )}
            <div style={{ display: "flex", gap: 8, marginTop: 16 }}>
              <Btn onClick={() => setCitaSel(null)} ol col={C.textMid} sm>
                Cerrar
              </Btn>
              <Btn onClick={() => completarCita(citaSel)} col={C.green} dis={guardando}>
                ✓ Terminar consulta
              </Btn>
            </div>
          </>
        )}
      </Modal>

      {loading ? (
        <SkeletonTable rows={3} cols={3} />
      ) : !citas.length ? (
        <Box style={{ padding: 40, textAlign: "center" }}>
          <div style={{ color: C.textMid, fontSize: 14 }}>Sin citas para hoy</div>
        </Box>
      ) : (
        <div style={{ display: "grid", gap: 10 }}>
          {citas.map((c) => {
            const pe = pagoEtiqueta(c);
            return (
              <Box
                key={c.id}
                style={{
                  padding: 18,
                  borderColor:
                    c.estado === "en_consulta" ? C.amber + "60" : c.estado === "completada" ? C.green + "40" : C.border,
                }}
              >
                <div style={{ display: "flex", alignItems: "flex-start", gap: 14, flexWrap: "wrap" }}>
                  <div style={{ color: C.blue, fontWeight: 800, fontSize: 18, width: 55, flexShrink: 0 }}>{c.hora}</div>
                  <div style={{ flex: 1, minWidth: 200 }}>
                    <button
                      type="button"
                      onClick={() => setFichaCita(c)}
                      style={{
                        background: "none",
                        border: "none",
                        padding: 0,
                        cursor: "pointer",
                        textAlign: "left",
                      }}
                    >
                      <div style={{ color: BRAND.primary, fontWeight: 700, fontSize: 15, textDecoration: "underline" }}>{c.nombre}</div>
                    </button>
                    <div style={{ color: C.textMid, fontSize: 12, marginTop: 2 }}>{c.motivo || "Consulta general"}</div>
                    <div style={{ display: "flex", gap: 6, flexWrap: "wrap", marginTop: 8 }}>
                      <Tag col={pe.col} sm>
                        {pe.txt}
                      </Tag>
                      {c.canal && (
                        <Tag col={C.blue} sm>
                          {labelCanal(c)}
                        </Tag>
                      )}
                      <Tag
                        col={
                          c.estado === "completada" ? C.green : c.estado === "en_consulta" ? C.amber : c.estado === "pagada" ? C.purple : C.blue
                        }
                        sm
                      >
                        {c.estado || "confirmada"}
                      </Tag>
                    </div>
                    {(c.consumibles_consulta || []).length > 0 && (
                      <div style={{ color: C.amber, fontSize: 11, marginTop: 4 }}>+ {(c.consumibles_consulta || []).length} consumibles registrados</div>
                    )}
                  </div>
                  <div style={{ display: "flex", gap: 8, alignItems: "center", flexWrap: "wrap" }}>
                    {citaPagoOk(c) && c.estado === "confirmada" && (
                      <Btn sm col={C.green} onClick={() => confirmarInicio(c)} dis={guardando}>
                        Confirmar inicio
                      </Btn>
                    )}
                    {c.estado === "en_consulta" && (
                      <Btn sm col={C.green} onClick={() => completarCita(c)} dis={guardando}>
                        Terminar consulta
                      </Btn>
                    )}
                    {puedeConsumibles(c) && c.estado !== "completada" && (
                      <Btn sm col={C.amber} onClick={() => setCitaSel(c)}>
                        + Consumibles
                      </Btn>
                    )}
                  </div>
                </div>
              </Box>
            );
          })}
        </div>
      )}
    </div>
  );
}


// ══════════════════════════════════════════════════════════════
// REPORTE DOCTORA — Vista simplificada
// ══════════════════════════════════════════════════════════════
function ReporteDoctora(){
  const C = C_LIGHT;
  const [citas,setCitas] = useState([]);
  const [loading,setLoad]= useState(true);
  const [periodo,setPer] = useState("semana");

  useEffect(()=>{
    const cargar = async () => {
      const dias = periodo==="dia"?1:periodo==="semana"?7:30;
      const desde = new Date(Date.now()-dias*86400000).toISOString().split("T")[0];
      const {data} = await supabase.from("citas").select(`
        id,nombre,fecha,hora,motivo,estado,ingreso_doctor,ingreso_farmacia,precio_consulta_cobrado,receta_surtido_en,
        consumibles_consulta(precio,cantidad,cobrado)
      `).gte("fecha",desde).order("fecha",{ascending:false});
      setCitas(data||[]); setLoad(false);
    };
    cargar();
  },[periodo]);

  const completadas = citas.filter(c=>c.estado==="completada"||c.estado==="pagada");
  const ingresoDoctorSum = completadas.reduce((a,c)=>{
    const v = parseFloat(c.ingreso_doctor);
    if (Number.isFinite(v)) return a+v;
    return a + (CONSULTA_PRECIO_DEFAULT * CONSULTA_PARTE_DOCTOR);
  },0);
  const recetasExternas = citas.filter(c=>c.receta_surtido_en==="externa").length;
  const recetasFarmax = citas.filter(c=>c.receta_surtido_en==="farmax").length;

  return(
    <div>
      <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:20}}>
        <h1 style={{color:C.text,fontSize:20,fontWeight:800,margin:0}}>◧ Mis Reportes</h1>
        <div style={{display:"flex",gap:6}}>
          {[["dia","Hoy"],["semana","Esta semana"],["mes","Este mes"]].map(([v,l])=>(
            <button key={v} onClick={()=>setPer(v)} style={{padding:"6px 12px",borderRadius:8,border:`1px solid ${periodo===v?BRAND.primary:C.border}`,background:periodo===v?BRAND.primary+"18":"transparent",color:periodo===v?BRAND.secondary:C.textMid,fontSize:12,fontWeight:700,cursor:"pointer"}}>{l}</button>
          ))}
        </div>
      </div>
      <div style={{display:"flex",gap:12,marginBottom:20,flexWrap:"wrap"}}>
        <KPI label="Consultas atendidas" value={completadas.length} col={C.green} icon="🏥"/>
        <KPI label="Tu parte acumulada (consulta)" value={$(ingresoDoctorSum)} col={C.purple} icon="⭐" sub="desde ingreso_doctor por cita"/>
        <KPI label="Recetas surtidas en Farmax" value={recetasFarmax} col={C.blue} icon="💊"/>
        <KPI label="Recetas en otra farmacia" value={recetasExternas} col={C.amber} icon="↗️" sub="seguimiento de desviación"/>
      </div>
      {loading?<SkeletonTable rows={4} cols={4}/>:(
        <Box>
          <table style={{width:"100%",borderCollapse:"collapse"}}>
            <thead><tr>{["Fecha","Hora","Paciente","Motivo","Estado","Tu parte","Receta"].map(h=><th key={h} style={{padding:"8px 14px",color:C.textDim,fontSize:9,textAlign:"left",letterSpacing:1.5,textTransform:"uppercase",borderBottom:`1px solid ${C.border}`}}>{h}</th>)}</tr></thead>
            <tbody>
              {citas.map(c=>(
                <tr key={c.id}>
                  <td style={{padding:"9px 14px",color:C.textMid,fontSize:11}}>{c.fecha}</td>
                  <td style={{padding:"9px 14px",color:C.blue,fontWeight:700,fontSize:12}}>{c.hora}</td>
                  <td style={{padding:"9px 14px",color:C.text,fontWeight:700,fontSize:13}}>{c.nombre}</td>
                  <td style={{padding:"9px 14px",color:C.textMid,fontSize:12}}>{c.motivo||"Consulta general"}</td>
                  <td style={{padding:"9px 14px"}}><Tag col={c.estado==="pagada"?C.green:c.estado==="completada"?C.blue:C.amber} sm>{c.estado}</Tag></td>
                  <td style={{padding:"9px 14px",color:C.purple,fontWeight:700,fontSize:12}}>
                    {(c.estado==="completada"||c.estado==="pagada")
                      ? $(parseFloat(c.ingreso_doctor)||CONSULTA_PRECIO_DEFAULT*CONSULTA_PARTE_DOCTOR)
                      : "—"}
                  </td>
                  <td style={{padding:"9px 14px",fontSize:11,color:C.textMid}}>{c.receta_surtido_en==="farmax"?"Farmax":c.receta_surtido_en==="externa"?"Otra":"—"}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </Box>
      )}
    </div>
  );
}

// ══════════════════════════════════════════════════════════════
// GESTIÓN DE USUARIOS (solo Admin)
// ══════════════════════════════════════════════════════════════
function BannersAdmin(){
  const C = C_LIGHT;
  const [banners,setBanners] = useState([]);
  const [loading,setLoad]   = useState(true);
  const [modal,setModal]    = useState(null);
  const [form,setForm]      = useState({titulo:"",subtitulo:"",descripcion:"",emoji:"💊",bg:"linear-gradient(135deg,#0052cc,#0099e6)",cta:"Ver más →",pagina:"catalogo",orden:0,activo:true,slot:"hero"});
  const [saving,setSaving]  = useState(false);

  const fetch = async()=>{ setLoad(true); const{data}=await supabase.from("banners").select("*").order("orden"); setBanners(data||[]); setLoad(false); };
  useEffect(()=>{ fetch(); },[]);

  const guardar = async()=>{
    setSaving(true);
    const tok = sessionStorage.getItem("farmax_session_token");
    const { error } = await supabase.rpc("admin_upsert_banner", {
      p_session_token: tok,
      p_id:            modal === "new" ? null : modal.id,
      p_payload:       form,
    });
    setSaving(false);
    if (error) { showToast("Error: "+error.message, "error"); return; }
    setModal(null); fetch();
    showToast("Banner guardado correctamente","success");
  };

  const eliminar = async(id)=>{
    if(!window.confirm("¿Eliminar este banner?")) return;
    const tok = sessionStorage.getItem("farmax_session_token");
    const { error } = await supabase.rpc("admin_eliminar_banner", {
      p_session_token: tok, p_id: id,
    });
    if (error) { showToast("Error: "+error.message, "error"); return; }
    fetch(); showToast("Banner eliminado","info");
  };

  const toggleActivo = async(b)=>{
    const tok = sessionStorage.getItem("farmax_session_token");
    const { error } = await supabase.rpc("admin_toggle_banner", {
      p_session_token: tok, p_id: b.id, p_activo: !b.activo,
    });
    if (error) showToast("Error: "+error.message, "error");
    fetch();
  };

  const inpS = {width:"100%",boxSizing:"border-box",padding:"8px 12px",borderRadius:8,border:`1px solid ${C.border}`,background:C.card,color:C.text,fontSize:13,outline:"none",marginBottom:10};

  return(
    <div>
      <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:20}}>
        <h1 style={{color:C.text,fontSize:20,fontWeight:800,margin:0}}>🖼️ Banners de la tienda</h1>
        <Btn col={BRAND.primary} onClick={()=>{setForm({titulo:"",subtitulo:"",descripcion:"",emoji:"💊",bg:BRAND.gradient,cta:"Ver más →",pagina:"promo",orden:banners.length+1,activo:true,slot:"hero"});setModal("new");}}>+ Nuevo banner</Btn>
      </div>
      <div style={{background:"#eff6ff",border:"1px solid #bfdbfe",borderRadius:10,padding:"10px 16px",marginBottom:16,fontSize:12,color:"#1d4ed8",lineHeight:1.55}}>
        💡 <strong>Zona:</strong> <em>Carrusel</em> (arriba, rotación automática) · <em>Franja</em> (tarjetas anchas bajo la barra de servicios) · <em>Mosaico</em> (rejilla bajo la búsqueda). Ordená con <strong>Orden</strong>.
        {" "}En <strong>Página destino</strong>: <code style={{background:"#fff",padding:"1px 6px",borderRadius:4}}>promo</code>, <code style={{background:"#fff",padding:"1px 6px",borderRadius:4}}>catalogo</code>, <code style={{background:"#fff",padding:"1px 6px",borderRadius:4}}>cita</code>…
        {" "}Si no ves el campo <strong>Zona</strong> en Supabase, ejecutá <code style={{background:"#fff",padding:"1px 6px",borderRadius:4}}>sql/banners_slot.sql</code>.
      </div>
      {loading?<SkeletonTable rows={5} cols={5}/>:(
        <div style={{display:"flex",flexDirection:"column",gap:10}}>
          {!banners.length&&<div style={{color:C.textMid,textAlign:"center",padding:40,background:C.card,borderRadius:12,border:`1px solid ${C.border}`}}>Sin banners. Crea el primero.</div>}
          {banners.map(b=>(
            <div key={b.id} style={{background:C.card,borderRadius:12,border:`1px solid ${C.border}`,padding:16,display:"flex",gap:16,alignItems:"center",flexWrap:"wrap"}}>
              <div style={{width:48,height:48,borderRadius:10,background:b.bg,display:"flex",alignItems:"center",justifyContent:"center",fontSize:24,flexShrink:0}}>{b.emoji}</div>
              <div style={{flex:1,minWidth:200}}>
                <div style={{fontWeight:800,color:C.text,fontSize:14}}>{b.titulo}</div>
                <div style={{color:C.textMid,fontSize:12,marginTop:2}}>{b.subtitulo} · {b.descripcion?.slice(0,60)}{b.descripcion?.length>60?"…":""}</div>
                <div style={{color:C.textDim,fontSize:11,marginTop:4}}>
                  {(b.slot==="strip"?"▤ Franja":b.slot==="tile"?"▦ Mosaico":"▶ Carrusel")} · Orden: {b.orden} · {b.pagina} · {b.cta}
                </div>
              </div>
              <div style={{display:"flex",gap:8,flexShrink:0}}>
                <button onClick={()=>toggleActivo(b)} style={{padding:"5px 10px",borderRadius:6,border:`1px solid ${b.activo?C.green:C.border}`,background:b.activo?C.greenDim:"transparent",color:b.activo?C.green:C.textMid,fontSize:11,fontWeight:700,cursor:"pointer"}}>{b.activo?"✓ Activo":"○ Inactivo"}</button>
                <button onClick={()=>{setForm({...b});setModal(b);}} style={{padding:"5px 10px",borderRadius:6,border:`1px solid ${C.amber}`,background:C.amberDim,color:C.amber,fontSize:11,fontWeight:700,cursor:"pointer"}}>✏️ Editar</button>
                <button onClick={()=>eliminar(b.id)} style={{padding:"5px 10px",borderRadius:6,border:`1px solid ${C.red}`,background:C.redDim,color:C.red,fontSize:11,fontWeight:700,cursor:"pointer"}}>🗑️</button>
              </div>
            </div>
          ))}
        </div>
      )}
      {modal&&(
        <div style={{position:"fixed",inset:0,background:"rgba(15,23,42,.45)",backdropFilter:"blur(4px)",zIndex:500,display:"flex",alignItems:"center",justifyContent:"center",padding:20}} onClick={e=>e.target===e.currentTarget&&setModal(null)}>
          <div style={{background:C.card,borderRadius:14,width:"min(520px,95vw)",maxHeight:"90vh",overflowY:"auto",padding:28,boxShadow:"0 20px 60px rgba(0,82,204,.15)"}}>
            <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:20}}>
              <h3 style={{margin:0,color:C.text,fontSize:16,fontWeight:800}}>{modal==="new"?"➕ Nuevo":"✏️ Editar"} Banner</h3>
              <button onClick={()=>setModal(null)} style={{background:"none",border:"none",color:C.textMid,fontSize:22,cursor:"pointer"}}>✕</button>
            </div>
            {[["Título *","titulo"],["Subtítulo","subtitulo"],["Descripción","descripcion"],["Emoji","emoji"],["Texto del botón","cta"],["Página destino","pagina"]].map(([l,k])=>(
              <div key={k}><label style={{color:C.textMid,fontSize:11,fontWeight:700,display:"block",marginBottom:3}}>{l.toUpperCase()}</label><input style={inpS} value={form[k]||""} onChange={e=>setForm(p=>({...p,[k]:e.target.value}))} placeholder={l}/></div>
            ))}
            <div>
              <label style={{color:C.textMid,fontSize:11,fontWeight:700,display:"block",marginBottom:3}}>ZONA EN EL HOME</label>
              <select style={{...inpS,marginBottom:10}} value={form.slot||"hero"} onChange={e=>setForm(p=>({...p,slot:e.target.value}))}>
                <option value="hero">▶ Carrusel principal (arriba)</option>
                <option value="strip">▤ Franja (bajo iconos de servicio)</option>
                <option value="tile">▦ Mosaico (bajo la barra de búsqueda)</option>
              </select>
            </div>
            <div><label style={{color:C.textMid,fontSize:11,fontWeight:700,display:"block",marginBottom:3}}>COLOR DE FONDO (CSS gradient)</label><input style={inpS} value={form.bg||""} onChange={e=>setForm(p=>({...p,bg:e.target.value}))} placeholder="linear-gradient(...)"/></div>
            <div><label style={{color:C.textMid,fontSize:11,fontWeight:700,display:"block",marginBottom:3}}>ORDEN</label><input type="number" style={inpS} value={form.orden||0} onChange={e=>setForm(p=>({...p,orden:parseInt(e.target.value)||0}))}/></div>
            <div style={{display:"flex",gap:10,justifyContent:"flex-end",marginTop:8}}>
              <button onClick={()=>setModal(null)} style={{padding:"9px 20px",borderRadius:8,border:`1px solid ${C.border}`,background:"transparent",color:C.textMid,fontWeight:700,cursor:"pointer"}}>Cancelar</button>
              <button onClick={guardar} disabled={saving||!form.titulo} style={{padding:"9px 20px",borderRadius:8,border:"none",background:BRAND.gradient,color:"#fff",fontWeight:700,cursor:"pointer"}}>{saving?"Guardando…":"💾 Guardar"}</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

function candidatosPorRolTmp(rol) {
  // Usa la whitelist de permissions.js como fuente de verdad.
  const permitidos = modulosPermitidosParaRol(rol);
  if (permitidos === "all") return NAV_ADMIN;
  return Array.isArray(permitidos) ? permitidos : [];
}

function defaultIdsPorRol(rol) {
  if (rol === "admin")    return NAV_ADMIN;
  if (rol === "vendedor") return NAV_VENDEDOR;
  if (rol === "doctora")  return NAV_DOCTORA;
  return [];
}

function GestionUsuarios(){
  const C = C_LIGHT;
  const [usuarios,setUsers] = useState([]);
  const [modal,setModal]    = useState(false);
  const [editModal,setEditModal] = useState(false);
  const [form,setForm]      = useState({nombre:"",email:"",telefono:"",password:"",rol:"vendedor",notas:""});
  const [editForm,setEditForm] = useState({id:null,nombre:"",email:"",telefono:"",rol:"vendedor",notas:"",activo:true});
  const [loading,setLoad]   = useState(true);
  const [guardando,setGuard]= useState(false);
  const [guardandoEdit,setGuardandoEdit] = useState(false);
  const [error,setError]    = useState("");
  const [editError,setEditError] = useState("");
  // Modal de permisos por usuario
  const [modulosModal,setModulosModal] = useState(null); // objeto usuario o null
  const [modulosCheck,setModulosCheck] = useState(() => new Set());
  const [guardandoModulos,setGuardandoModulos] = useState(false);

  useEffect(()=>{
    const tok = sessionStorage.getItem("farmax_session_token");
    if (!tok) { setLoad(false); return; }
    supabase.rpc("admin_listar_usuarios", { p_session_token: tok }).then(({ data, error })=>{
      if (error) console.warn("[GestionUsuarios] admin_listar_usuarios:", error.message);
      setUsers(data || []);
      setLoad(false);
    });
  },[]);

  const crear = async () => {
    const emailUsuario = (form.email || "").trim().toLowerCase();
    const telefonoLimpio = (form.telefono || "").trim();
    const telefonoValor = telefonoLimpio || null;
    if(!form.nombre||!emailUsuario||!form.password) return;
    if(!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(emailUsuario)) {
      setError("Ingresa un correo electrónico válido.");
      return;
    }
    if((form.password || "").length < 6) {
      setError("La contraseña debe tener al menos 6 caracteres.");
      return;
    }
    setGuard(true); setError("");
    try {
      const tok = sessionStorage.getItem("farmax_session_token");
      if (!tok) { setError("Sesión expirada."); setGuard(false); return; }
      const { data: resp, error: err } = await supabase.rpc("admin_crear_usuario", {
        p_session_token: tok,
        p_nombre:    form.nombre.trim(),
        p_email:     emailUsuario,
        p_telefono:  telefonoValor,
        p_password:  form.password,
        p_rol:       form.rol,
        p_notas:     form.notas?.trim() || null,
      });
      if (err || !resp?.success) {
        setError("Error: " + (resp?.error || err?.message || "desconocido"));
        setGuard(false); return;
      }
      const nuevo = resp.user;
      setUsers(p => [...p, nuevo]);
      setModal(false);
      setForm({nombre:"",email:"",telefono:"",password:"",rol:"vendedor",notas:""});
      showToast(`✅ Usuario ${form.nombre} creado correctamente`, "success");
    } catch(e){
      console.error("[Farmax] Error crear usuario:", e);
      setError("Error al crear usuario: " + e.message);
    }
    setGuard(false);
  };

  const toggle = async (id,activo) => {
    const tok = sessionStorage.getItem("farmax_session_token");
    const { error } = await supabase.rpc("admin_toggle_usuario", {
      p_session_token: tok,
      p_target_id: id,
    });
    if (error) { showToast("Error: "+error.message, "error"); return; }
    setUsers(p=>p.map(u=>u.id===id?{...u,activo:!activo}:u));
  };

  // ── MÓDULOS PERSONALIZADOS ─────────────────────────────────
  const abrirModulos = (u) => {
    const activos = Array.isArray(u.modulos_custom?.activos) && u.modulos_custom.activos.length > 0
      ? u.modulos_custom.activos
      : defaultIdsPorRol(u.rol);
    setModulosCheck(new Set(activos));
    setModulosModal(u);
  };

  const toggleModulo = (id) => {
    setModulosCheck((prev) => {
      const n = new Set(prev);
      if (n.has(id)) n.delete(id); else n.add(id);
      return n;
    });
  };

  const restablecerModulos = () => {
    if (!modulosModal) return;
    setModulosCheck(new Set(defaultIdsPorRol(modulosModal.rol)));
  };

  const guardarModulos = async () => {
    if (!modulosModal) return;
    setGuardandoModulos(true);
    try {
      const seleccionados = [...modulosCheck];
      const defaults = defaultIdsPorRol(modulosModal.rol);
      // Si la selección es exactamente igual al default del rol, guardamos NULL (limpio).
      const igualAlDefault = seleccionados.length === defaults.length
        && seleccionados.every((id) => defaults.includes(id));
      const payload = igualAlDefault ? null : { activos: seleccionados };
      const tok = sessionStorage.getItem("farmax_session_token");
      const { data: modData, error: err } = await supabase.rpc("admin_set_usuario_modulos_custom", {
        p_session_token: tok,
        p_usuario_id: modulosModal.id,
        p_modulos_custom: payload,
      });
      if (err) throw err;
      if (!modData?.success) throw new Error(modData?.error || "Error al guardar módulos");
      setUsers((prev) => prev.map((u) => u.id === modulosModal.id ? { ...u, modulos_custom: payload } : u));
      showToast(igualAlDefault ? "Restablecido al default del rol." : "Permisos guardados.", "success");
      setModulosModal(null);
    } catch (e) {
      console.error("[Usuarios] guardarModulos:", e);
      showToast("No se pudo guardar: " + (e?.message || JSON.stringify(e)), "error");
    }
    setGuardandoModulos(false);
  };

  const abrirEditar = (u) => {
    setEditError("");
    setEditForm({
      id: u.id,
      nombre: u.nombre || "",
      email: u.email || "",
      telefono: u.telefono || "",
      rol: u.rol || "vendedor",
      notas: u.notas || "",
      activo: u.activo !== false,
    });
    setEditModal(true);
  };

  const guardarEdicion = async () => {
    if (!editForm.id) return;
    if (!editForm.nombre?.trim()) {
      setEditError("El nombre es obligatorio.");
      return;
    }
    setGuardandoEdit(true);
    setEditError("");
    const emailNuevo = (editForm.email || "").trim().toLowerCase();
    if (!emailNuevo) {
      setEditError("El correo de acceso es obligatorio.");
      setGuardandoEdit(false);
      return;
    }
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(emailNuevo)) {
      setEditError("Ingresa un correo electrónico válido.");
      setGuardandoEdit(false);
      return;
    }
    const tok = sessionStorage.getItem("farmax_session_token");
    const { data, error: err } = await supabase.rpc("admin_actualizar_usuario_datos", {
      p_session_token: tok,
      p_usuario_id: editForm.id,
      p_nombre: editForm.nombre.trim(),
      p_email: emailNuevo,
      p_telefono: (editForm.telefono || "").trim() || null,
      p_rol: editForm.rol,
      p_notas: editForm.notas?.trim() || null,
      p_activo: !!editForm.activo,
    });
    if (err) {
      if (err.code === "23502" && String(err.message || "").includes("telefono")) {
        setEditError("La base aún exige teléfono obligatorio. Ejecuta sql/alter_usuarios_telefono_opcional.sql en Supabase, o ingresa un teléfono.");
        setGuardandoEdit(false);
        return;
      }
      if (err.code === "23505" && /telefono/i.test(String(err.message || ""))) {
        setEditError("Ese teléfono ya está registrado. Usa otro o deja el campo vacío (tras aplicar el script de teléfono opcional).");
        setGuardandoEdit(false);
        return;
      }
      if (err.code === "23505" && /email/i.test(String(err.message || ""))) {
        setEditError("Ese correo ya está registrado en otro usuario.");
        setGuardandoEdit(false);
        return;
      }
      setEditError(`Error: ${err.message}`);
      setGuardandoEdit(false);
      return;
    }
    if (!data?.success) {
      setEditError(data?.error || "No se pudo guardar");
      setGuardandoEdit(false);
      return;
    }
    const row = data.user;
    setUsers((prev) => prev.map((u) => (u.id === editForm.id ? { ...u, ...row } : u)));
    setEditModal(false);
    setGuardandoEdit(false);
    showToast("✅ Usuario actualizado", "success");
  };

  const cambiarMiPwd = async () => {
    const tok = sessionStorage.getItem("farmax_session_token");
    if (!tok) { showToast("Sesión expirada. Entra de nuevo.", "error"); return; }
    const actual = prompt("Contraseña actual:");
    if (!actual) return;
    const nueva = prompt("Nueva contraseña (mínimo 6 caracteres):");
    if (!nueva || nueva.length < 6) { showToast("La contraseña debe tener al menos 6 caracteres","warning"); return; }
    const nueva2 = prompt("Confirma la nueva contraseña:");
    if (nueva !== nueva2) { showToast("Las contraseñas no coinciden","error"); return; }

    const { data: resp, error } = await supabase.rpc("empleado_cambiar_password", {
      p_session_token:   tok,
      p_password_actual: actual,
      p_password_nueva:  nueva,
    });
    if (error || !resp?.success) {
      showToast("Error: " + (resp?.error || error?.message || "desconocido"), "error");
      return;
    }
    showToast("✅ Contraseña actualizada", "success");
  };

  const resetPwd = async (u) => {
    const nueva = prompt(`Nueva contraseña para ${u.nombre} (mínimo 6 caracteres):`);
    if (!nueva || nueva.length < 6) { showToast("Contraseña muy corta (mínimo 6 caracteres)","warning"); return; }
    const tok = sessionStorage.getItem("farmax_session_token");
    const { data: resp, error } = await supabase.rpc("admin_reset_password", {
      p_session_token: tok, p_usuario_id: u.id, p_nueva_password: nueva,
    });
    if (error || !resp?.success) { showToast("Error: "+(resp?.error||error?.message),"error"); return; }
    showToast(`✅ Contraseña de ${u.nombre} actualizada`,"success");
  };

  const eliminar = async (id,nombre) => {
    const sesion = JSON.parse(sessionStorage.getItem("farmax_admin_user")||"{}");
    if(sesion.id===id) { showToast("No puedes eliminar tu propio usuario.", "warning"); return; }
    showConfirm("Eliminar usuario",`¿Eliminar al usuario ${nombre}? Esta acción no se puede deshacer.`, async()=>{
      const tok = sessionStorage.getItem("farmax_session_token");
      const { data: resp, error } = await supabase.rpc("admin_eliminar_usuario", {
        p_session_token: tok, p_usuario_id: id,
      });
      if (error || !resp?.success) { showToast("Error: "+(resp?.error||error?.message),"error"); return; }
      setUsers(p=>p.filter(u=>u.id!==id));
      showToast(`Usuario ${nombre} eliminado.`,"info");
    }, true);
  };

  const rolColor = r => r==="admin"?C.purple:r==="vendedor"?C.blue:C.green;
  const actionBtnBase = {
    width: 18,
    height: 18,
    borderRadius: 5,
    display: "inline-flex",
    alignItems: "center",
    justifyContent: "center",
    cursor: "pointer",
    padding: 0,
    marginLeft: 1,
  };

  return(
    <div>
      <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:20,flexWrap:"wrap",gap:10}}>
        <h1 style={{color:C.text,fontSize:20,fontWeight:800,margin:0}}>👤 Gestión de Usuarios</h1>
        <div style={{display:"flex",gap:8}}>
          <Btn col={BRAND.primary} onClick={()=>setModal(true)}>+ Nuevo usuario</Btn>
        </div>
      </div>

      <Modal open={modal} onClose={()=>setModal(false)} title="Crear nuevo usuario" closeOnBackdrop={false}>
        <div style={{marginBottom:12}}>
          <div style={{color:C.textMid,fontSize:11,marginBottom:4}}>Nombre completo *</div>
          <Inp value={form.nombre} onChange={e=>setForm(p=>({...p,nombre:e.target.value}))} placeholder="Nombre del empleado" style={{width:"100%",boxSizing:"border-box"}}/>
        </div>
        <div style={{marginBottom:12}}>
          <div style={{color:C.textMid,fontSize:11,marginBottom:4}}>Correo electrónico (será su usuario) *</div>
          <Inp value={form.email} onChange={e=>setForm(p=>({...p,email:e.target.value}))} placeholder="usuario@empresa.com" type="email" style={{width:"100%",boxSizing:"border-box"}}/>
        </div>
        <div style={{marginBottom:12}}>
          <div style={{color:C.textMid,fontSize:11,marginBottom:4}}>Teléfono (opcional)</div>
          <Inp value={form.telefono} onChange={e=>setForm(p=>({...p,telefono:e.target.value}))} placeholder="55XXXXXXXX" type="tel" style={{width:"100%",boxSizing:"border-box"}}/>
        </div>
        <div style={{marginBottom:12}}>
          <div style={{color:C.textMid,fontSize:11,marginBottom:4}}>Contraseña *</div>
          <Inp value={form.password} onChange={e=>setForm(p=>({...p,password:e.target.value}))} placeholder="Mínimo 6 caracteres" type="password" style={{width:"100%",boxSizing:"border-box"}}/>
        </div>
        <div style={{marginBottom:12}}>
          <div style={{color:C.textMid,fontSize:11,marginBottom:4}}>Perfil *</div>
          <select value={form.rol} onChange={e=>setForm(p=>({...p,rol:e.target.value}))}
            style={{width:"100%",background:C.bg,border:`1px solid ${C.border}`,borderRadius:8,color:C.text,padding:"9px 13px",fontSize:13,outline:"none"}}>
            <option value="vendedor">🏪 Vendedor — POS + cobros</option>
            <option value="doctora">👩‍⚕️ Doctora — Consultorio</option>
            <option value="admin">👑 Admin — Acceso total</option>
          </select>
        </div>
        {error&&<div style={{background:C.redDim,border:`1px solid ${C.red}30`,borderRadius:8,padding:"10px 12px",marginBottom:12,color:C.red,fontSize:13}}>{error}</div>}
        <div style={{marginBottom:12}}>
          <div style={{color:C.textMid,fontSize:11,marginBottom:4}}>Notas / Turno</div>
          <Inp value={form.notas} onChange={e=>setForm(p=>({...p,notas:e.target.value}))} placeholder="Turno, observaciones, etc." style={{width:"100%",boxSizing:"border-box"}}/>
        </div>
        <div style={{background:C.amberDim,border:`1px solid ${C.amber}30`,borderRadius:8,padding:"10px 12px",marginBottom:16}}>
          <div style={{color:C.amber,fontSize:11}}>El usuario iniciará sesión con su correo electrónico y esta contraseña. Compártela de forma segura.</div>
        </div>
        <div style={{display:"flex",gap:8}}>
          <Btn onClick={()=>setModal(false)} ol col={C.textMid}>Cancelar</Btn>
          <Btn
            onClick={crear}
            col={BRAND.primary}
            dis={!form.nombre||!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test((form.email||"").trim())||!form.password||form.password.length<6||guardando}
          >
            {guardando?"Creando...":"Crear usuario"}
          </Btn>
        </div>
      </Modal>

      <Modal open={editModal} onClose={()=>setEditModal(false)} title="Editar usuario" closeOnBackdrop={false}>
        <div style={{marginBottom:12}}>
          <div style={{color:C.textMid,fontSize:11,marginBottom:4}}>Nombre completo *</div>
          <Inp value={editForm.nombre} onChange={e=>setEditForm(p=>({...p,nombre:e.target.value}))} placeholder="Nombre del empleado" style={{width:"100%",boxSizing:"border-box"}}/>
        </div>
        <div style={{marginBottom:12}}>
          <div style={{color:C.textMid,fontSize:11,marginBottom:4}}>Correo de acceso</div>
          <Inp
            value={editForm.email}
            onChange={e=>setEditForm(p=>({...p,email:e.target.value}))}
            placeholder="tu@correo.com"
            type="email"
            style={{width:"100%",boxSizing:"border-box"}}
          />
          <div style={{color:C.textDim,fontSize:10,marginTop:4}}>Puedes corregir el correo para que inicie sesión con email + contraseña.</div>
        </div>
        <div style={{marginBottom:12}}>
          <div style={{color:C.textMid,fontSize:11,marginBottom:4}}>Teléfono</div>
          <Inp value={editForm.telefono} onChange={e=>setEditForm(p=>({...p,telefono:e.target.value}))} placeholder="55XXXXXXXX" type="tel" style={{width:"100%",boxSizing:"border-box"}}/>
        </div>
        <div style={{marginBottom:12}}>
          <div style={{color:C.textMid,fontSize:11,marginBottom:4}}>Perfil *</div>
          <select value={editForm.rol} onChange={e=>setEditForm(p=>({...p,rol:e.target.value}))}
            style={{width:"100%",background:C.bg,border:`1px solid ${C.border}`,borderRadius:8,color:C.text,padding:"9px 13px",fontSize:13,outline:"none"}}>
            <option value="vendedor">🏪 Vendedor — POS + cobros</option>
            <option value="doctora">👩‍⚕️ Doctora — Consultorio</option>
            <option value="admin">👑 Admin — Acceso total</option>
          </select>
        </div>
        <div style={{marginBottom:12}}>
          <div style={{color:C.textMid,fontSize:11,marginBottom:4}}>Notas / Turno</div>
          <Inp value={editForm.notas} onChange={e=>setEditForm(p=>({...p,notas:e.target.value}))} placeholder="Turno, observaciones, etc." style={{width:"100%",boxSizing:"border-box"}}/>
        </div>
        <div style={{marginBottom:16}}>
          <label style={{display:"flex",alignItems:"center",gap:8,color:C.textMid,fontSize:12,fontWeight:600}}>
            <input type="checkbox" checked={editForm.activo} onChange={e=>setEditForm(p=>({...p,activo:e.target.checked}))}/>
            Usuario activo
          </label>
        </div>
        {editError&&<div style={{background:C.redDim,border:`1px solid ${C.red}30`,borderRadius:8,padding:"10px 12px",marginBottom:12,color:C.red,fontSize:13}}>{editError}</div>}
        <div style={{display:"flex",gap:8}}>
          <Btn onClick={()=>setEditModal(false)} ol col={C.textMid}>Cancelar</Btn>
          <Btn onClick={guardarEdicion} col={BRAND.primary} dis={!editForm.nombre||guardandoEdit}>
            {guardandoEdit?"Guardando...":"Guardar cambios"}
          </Btn>
        </div>
      </Modal>

      {/* ── MODAL: MÓDULOS / PERMISOS ───────────────────────── */}
      <Modal open={!!modulosModal} onClose={()=>setModulosModal(null)} title={modulosModal ? `Módulos de ${modulosModal.nombre}` : "Módulos"} closeOnBackdrop={!guardandoModulos}>
        {modulosModal && (() => {
          const defaults = defaultIdsPorRol(modulosModal.rol);
          const candidatos = candidatosPorRolTmp(modulosModal.rol);
          // adicionales = candidatos que NO están en el default
          const adicionales = candidatos.filter((id) => !defaults.includes(id));
          const tieneCustom = Array.isArray(modulosModal.modulos_custom?.activos) && modulosModal.modulos_custom.activos.length > 0;

          return (
            <>
              <div style={{marginBottom:14, padding:"10px 12px", background:C.bg, border:`1px solid ${C.border}`, borderRadius:8}}>
                <div style={{color:C.textMid, fontSize:11, fontWeight:700, letterSpacing:0.6, textTransform:"uppercase", marginBottom:4}}>
                  Rol: {modulosModal.rol}
                </div>
                <div style={{color:C.textDim, fontSize:12}}>
                  {tieneCustom
                    ? "Este usuario tiene permisos personalizados activos."
                    : "Este usuario usa los módulos default de su rol. Puedes personalizar."}
                </div>
              </div>

              <div style={{marginBottom:16}}>
                <div style={{color:C.textDim, fontSize:10, fontWeight:700, letterSpacing:1.5, textTransform:"uppercase", marginBottom:8}}>
                  Default del rol
                </div>
                <div style={{display:"grid", gridTemplateColumns:"repeat(auto-fit, minmax(200px, 1fr))", gap:6}}>
                  {defaults.map((id) => {
                    const item = NAV_ITEMS.find((n) => n.id === id);
                    if (!item) return null;
                    const checked = modulosCheck.has(id);
                    return (
                      <label key={id} style={{display:"flex", alignItems:"center", gap:8, padding:"8px 10px", background:checked?C.greenDim:C.bg, border:`1px solid ${checked?C.green+"50":C.border}`, borderRadius:8, cursor:"pointer", fontSize:13, color:C.text}}>
                        <input type="checkbox" checked={checked} onChange={()=>toggleModulo(id)}/>
                        <span style={{fontWeight:600}}>{item.label}</span>
                      </label>
                    );
                  })}
                </div>
              </div>

              {adicionales.length > 0 && (
                <div style={{marginBottom:16}}>
                  <div style={{color:C.textDim, fontSize:10, fontWeight:700, letterSpacing:1.5, textTransform:"uppercase", marginBottom:8}}>
                    Módulos adicionales
                  </div>
                  <div style={{display:"grid", gridTemplateColumns:"repeat(auto-fit, minmax(200px, 1fr))", gap:6}}>
                    {adicionales.map((id) => {
                      const item = NAV_ITEMS.find((n) => n.id === id);
                      if (!item) return null;
                      const checked = modulosCheck.has(id);
                      return (
                        <label key={id} style={{display:"flex", alignItems:"center", gap:8, padding:"8px 10px", background:checked?C.blueDim:C.bg, border:`1px solid ${checked?C.blue+"50":C.border}`, borderRadius:8, cursor:"pointer", fontSize:13, color:C.text}}>
                          <input type="checkbox" checked={checked} onChange={()=>toggleModulo(id)}/>
                          <span style={{fontWeight:600}}>{item.label}</span>
                        </label>
                      );
                    })}
                  </div>
                </div>
              )}

              <div style={{display:"flex", gap:8, justifyContent:"flex-end", marginTop:10}}>
                <Btn onClick={restablecerModulos} ol col={C.textMid} dis={guardandoModulos}>🔄 Restablecer default</Btn>
                <Btn onClick={guardarModulos} col={BRAND.primary} dis={guardandoModulos}>
                  {guardandoModulos?"Guardando...":"💾 Guardar"}
                </Btn>
              </div>
            </>
          );
        })()}
      </Modal>

      {loading?<SkeletonTable rows={4} cols={5}/>:(
        <Box>
          <table style={{width:"100%",borderCollapse:"collapse"}}>
            <thead><tr>{["Nombre","Usuario (correo)","Perfil","Notas","Estado","Acciones"].map(h=><th key={h} style={{padding:"8px 14px",color:C.textDim,fontSize:9,textAlign:"left",letterSpacing:1.5,textTransform:"uppercase",borderBottom:`1px solid ${C.border}`}}>{h}</th>)}</tr></thead>
            <tbody>
              {usuarios.map(u=>(
                <tr key={u.id}>
                  <td style={{padding:"10px 14px",color:C.text,fontWeight:700,fontSize:13}}>{u.nombre}</td>
                  <td style={{padding:"10px 14px",color:C.textMid,fontSize:12}}>{u.email||u.telefono||"—"}</td>
                  <td style={{padding:"10px 14px"}}><Tag col={rolColor(u.rol)} sm>{u.rol}</Tag></td>
                  <td style={{padding:"10px 14px",color:C.textMid,fontSize:12}}>{u.notas||"—"}</td>
                  <td style={{padding:"10px 14px"}}><Tag col={u.activo?C.green:C.red} sm>{u.activo?"Activo":"Inactivo"}</Tag></td>
                  <td style={{padding:"10px 14px"}}>
                    <button
                      onClick={()=>abrirEditar(u)}
                      title="Editar usuario"
                      aria-label="Editar usuario"
                      style={{...actionBtnBase, border:`1px solid ${C.amber}30`, background:C.amberDim, color:C.amber, marginLeft:0}}
                    >
                      <svg width="11" height="11" viewBox="0 0 24 24" fill="none" aria-hidden="true">
                        <path d="M12 20h9" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
                        <path d="M16.5 3.5a2.12 2.12 0 1 1 3 3L7 19l-4 1 1-4 12.5-12.5z" stroke="currentColor" strokeWidth="2" strokeLinejoin="round"/>
                      </svg>
                    </button>
                    {u.rol !== "admin" && (
                      <button
                        onClick={()=>abrirModulos(u)}
                        title="Módulos y permisos"
                        aria-label="Módulos y permisos"
                        style={{...actionBtnBase, border:`1px solid ${C.purple}40`, background:C.purpleDim, color:C.purple}}
                      >
                        <svg width="11" height="11" viewBox="0 0 24 24" fill="none" aria-hidden="true">
                          <path d="M3 9l3-3 3 3M3 15l3 3 3-3M18 9l3-3-3-3M18 15l3 3-3 3" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
                          <path d="M9 12h12" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
                        </svg>
                      </button>
                    )}
                    <button onClick={()=>toggle(u.id,u.activo)}
                      title={u.activo?"Desactivar usuario":"Activar usuario"}
                      aria-label={u.activo?"Desactivar usuario":"Activar usuario"}
                      style={{...actionBtnBase,border:`1px solid ${u.activo?C.red:C.green}`,background:"transparent",color:u.activo?C.red:C.green}}>
                      {u.activo ? (
                        <svg width="11" height="11" viewBox="0 0 24 24" fill="none" aria-hidden="true">
                          <circle cx="12" cy="12" r="9" stroke="currentColor" strokeWidth="2"/>
                          <path d="M8 8l8 8" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
                        </svg>
                      ) : (
                        <svg width="11" height="11" viewBox="0 0 24 24" fill="none" aria-hidden="true">
                          <circle cx="12" cy="12" r="9" stroke="currentColor" strokeWidth="2"/>
                          <path d="M8 12l3 3 5-6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
                        </svg>
                      )}
                    </button>
                    <button
                      onClick={()=>resetPwd(u)}
                      title="Resetear contraseña"
                      aria-label="Resetear contraseña"
                      style={{...actionBtnBase,border:`1px solid ${C.blue}`,background:C.blueDim,color:C.blue}}
                    >
                      <svg width="11" height="11" viewBox="0 0 24 24" fill="none" aria-hidden="true">
                        <circle cx="8" cy="12" r="3" stroke="currentColor" strokeWidth="2"/>
                        <path d="M11 12h10M17 12v3M20 12v2" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
                      </svg>
                    </button>
                    <button onClick={()=>eliminar(u.id,u.nombre)}
                      title="Eliminar usuario"
                      aria-label="Eliminar usuario"
                      style={{...actionBtnBase,border:`1px solid ${C.red}30`,background:C.redDim,color:C.red}}>
                      <svg width="11" height="11" viewBox="0 0 24 24" fill="none" aria-hidden="true">
                        <path d="M3 6h18" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
                        <path d="M8 6V4h8v2M7 6l1 14h8l1-14" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
                      </svg>
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </Box>
      )}
    </div>
  );
}

// ══════════════════════════════════════════════════════════════
// APP PRINCIPAL
// ══════════════════════════════════════════════════════════════
export default function FarmaxAdmin(){
  const C = C_LIGHT;
  const [usuario,setUsuario] = useState(()=>{
    try{
      const u = sessionStorage.getItem("farmax_admin_user");
      if (!u) return null;
      const data = JSON.parse(u);
      // Verificar expiración (8 horas)
      if (data.loginTimestamp && Date.now() - data.loginTimestamp > 8*60*60*1000) {
        sessionStorage.removeItem("farmax_admin_user");
        sessionStorage.removeItem("farmax_session_token");
        return null;
      }
      return data;
    } catch{ return null; }
  });
  // Migración: ids antiguos "rea" y "lotes" ahora son tabs dentro de "inv".
  // También migramos "rep" al dashboard (legacy).
  function migratePageId(p) {
    if (!p || p === "rep") return { page: "dash", invTab: null };
    if (p === "rea")   return { page: "inv",  invTab: "reabasto" };
    if (p === "lotes") return { page: "inv",  invTab: "lotes" };
    return { page: p, invTab: null };
  }
  const [page, setPage] = useState(() => {
    const raw = sessionStorage.getItem("farmax_active_page") || "dash";
    const { page: p, invTab } = migratePageId(raw);
    if (invTab) {
      try {
        sessionStorage.setItem("farmax_inv_tab", invTab);
        sessionStorage.setItem("farmax_active_page", p);
      } catch (_) { /* noop */ }
    }
    return p;
  });
  const [invInitialTab, setInvInitialTab] = useState(() => {
    try { return sessionStorage.getItem("farmax_inv_tab") || null; } catch { return null; }
  });

  const { counts: badgeCounts, critical: badgeCritical } = useSidebarBadges(usuario ? page : undefined);

  const isMobileLayout = useMediaQuery("(max-width: 900px)");
  const [mobileNavOpen, setMobileNavOpen] = useState(false);

  // setPageAndSave(id) o setPageAndSave(id, { tab: "reabasto" }) para deep-link a tabs del hub.
  const setPageAndSave = (p, opts = {}) => {
    const migrated = migratePageId(p);
    const next = migrated.page;
    const tabHint = opts?.tab ?? migrated.invTab ?? null;
    try {
      sessionStorage.setItem("farmax_active_page", next);
      if (next === "inv" && tabHint) {
        sessionStorage.setItem("farmax_inv_tab", tabHint);
        setInvInitialTab(tabHint);
      } else if (next !== "inv") {
        // Al salir de inv, no borramos farmax_inv_tab — al volver recordará la última tab.
      }
    } catch (_) { /* noop */ }
    setPage(next);
    if (isMobileLayout) setMobileNavOpen(false);
  };

  useEffect(() => {
    if (!isMobileLayout) setMobileNavOpen(false);
  }, [isMobileLayout]);
  const [notifs,setNotifs]         = useState([]);
  const [ventasOffline,setVentasOff] = useState(0);
  const [confirmDlg, setConfirmDlg] = useState({open:false,titulo:"",mensaje:"",onConfirm:null,danger:false});
  const showConfirm = (titulo,mensaje,onConfirm,danger=false) => setConfirmDlg({open:true,titulo,mensaje,onConfirm,danger});

  // ── M4: Registrar Service Worker + solicitar permiso push ──
  useEffect(()=>{
    if(!usuario) return;
    // Registrar SW
    if("serviceWorker" in navigator){
      navigator.serviceWorker.register("/service-worker.js")
        .then(reg=>{
          console.log("[Farmax] SW registrado:", reg.scope);
          // Solicitar permiso de notificaciones
          if("Notification" in window && Notification.permission==="default"){
            setTimeout(()=>{
              Notification.requestPermission().then(perm=>{
                if(perm==="granted"){
                  showToast("✅ Notificaciones activadas. Te avisaremos de pedidos nuevos.","success");
                }
              });
            }, 3000); // esperar 3s para no interrumpir el login
          }
        })
        .catch(e=>console.warn("[Farmax] SW error:", e));
    }
    // Escuchar mensajes del SW (sync complete)
    const handler = e=>{
      if(e.data?.type==="SYNC_COMPLETE"){
        showToast(`✅ ${e.data.count} registros sincronizados (${e.data.entity})`,"success");
      }
    };
    navigator.serviceWorker?.addEventListener("message", handler);
    return ()=>navigator.serviceWorker?.removeEventListener("message", handler);
  },[usuario]);

  // ── M4: Función para mostrar notificación push manual ──────
  const pushNotif = (titulo, cuerpo, url="/admin") => {
    if("Notification" in window && Notification.permission==="granted"){
      if(navigator.serviceWorker.controller){
        navigator.serviceWorker.controller.postMessage({
          type:"SHOW_NOTIFICATION", titulo, cuerpo, url
        });
      } else {
        new Notification(titulo,{ body:cuerpo, icon:"/icons/farmax-192.png" });
      }
    }
  };

  // ── Verificar solicitudes de reset pendientes ──────────────
  useEffect(()=>{
    if(!usuario || usuario.rol !== "admin") return;
    const checkResets = async() => {
      const tok = sessionStorage.getItem("farmax_session_token");
      const { data } = await supabase.rpc("admin_contar_password_resets_pendientes", {
        p_session_token: tok,
      });
      const count = data || 0;
      if(count > 0) {
        addNotif(
          `🔑 ${count} solicitud${count>1?"es":""} de contraseña pendiente${count>1?"s":""}`,
          "Ve a Supabase para ver los detalles y contactar al usuario",
          "🔑","#f59e0b"
        );
      }
    };
    checkResets();
    const iv = setInterval(checkResets, 60000);
    return ()=>clearInterval(iv);
  },[usuario]);

  // ── P2.3: Detector online/offline + sincronización automática ──
  useEffect(()=>{
    if(!usuario) return;
    // Contar ventas pendientes al cargar
    contarVentasPendientes().then(n=>setVentasOff(n));

    const handleOnline = async () => {
      const pendientes = await contarVentasPendientes();
      if(pendientes > 0) {
        addNotif(`📶 Conexión restaurada`,`Sincronizando ${pendientes} venta(s) pendiente(s)...`,"📶","#00c46a");
        const result = await sincronizarVentasPendientes(supabase, usuario);
        setVentasOff(0);
        if(result.ok > 0) showToast(`✅ ${result.ok} venta(s) sincronizada(s)`, "success");
        if(result.err > 0) showToast(`⚠️ ${result.err} venta(s) con error`, "warning");
      } else {
        addNotif("📶 Conexión restaurada","Sistema en línea","📶","#00c46a");
      }
    };
    const handleOffline = () => {
      addNotif("📵 Sin conexión","Las ventas se guardarán localmente","📵","#f59e0b");
      showToast("Sin internet — modo offline activo","warning");
    };
    window.addEventListener("online",  handleOnline);
    window.addEventListener("offline", handleOffline);
    return ()=>{
      window.removeEventListener("online",  handleOnline);
      window.removeEventListener("offline", handleOffline);
    };
  },[usuario]);

  // ── E5: Guard de sesión — verificar expiración cada minuto ──
  useEffect(()=>{
    const check = () => {
      const u = sessionStorage.getItem("farmax_admin_user");
      if (!u) return;
      try {
        const data = JSON.parse(u);
        if (data.loginTimestamp && Date.now() - data.loginTimestamp > 8*60*60*1000) {
          sessionStorage.removeItem("farmax_admin_user");
          sessionStorage.removeItem("farmax_session_token");
          setUsuario(null);
          showToast("Tu sesión expiró. Por favor inicia sesión de nuevo.", "warning");
        }
      } catch(e) {
        sessionStorage.removeItem("farmax_admin_user");
        sessionStorage.removeItem("farmax_session_token");
        setUsuario(null);
      }
    };
    const interval = setInterval(check, 60*1000); // cada minuto
    return () => clearInterval(interval);
  },[]);
  const notifId = useRef(0);

  const addNotif = useCallback((titulo,mensaje,icon="🔔",col="#0052cc")=>{
    const id=++notifId.current;
    const hora=new Date().toLocaleTimeString("es-MX",{hour:"2-digit",minute:"2-digit"});
    setNotifs(p=>[{id,titulo,mensaje,icon,col,hora},...p].slice(0,5));
    setTimeout(()=>setNotifs(p=>p.filter(n=>n.id!==id)),8000);
  },[]);

  const dismissNotif = useCallback(id=>setNotifs(p=>p.filter(n=>n.id!==id)),[]);

  useEffect(()=>{
    if(!usuario) return;
    const ch=supabase.channel("farmax-rt")
      .on("postgres_changes",{event:"INSERT",schema:"public",table:"password_reset_requests"},
        payload=>{
          const req = payload.new;
          addNotif(
            "🔑 Solicitud de contraseña",
            `Usuario: ${req.email_o_telefono} necesita reset de contraseña`,
            "🔑","#f59e0b"
          );
          showToast(`🔑 Solicitud de reset: ${req.email_o_telefono}`,"warning");
        })
      .on("postgres_changes",{event:"INSERT",schema:"public",table:"pedidos"},
        pl=>{
          const row = pl.new;
          if (!row || row.estado !== "pendiente" || !esPedidoTiendaWebPendiente(row)) return;
          addNotif("🛒 Nuevo pedido online",`Pedido #${row.id} · $${parseFloat(row.total||0).toFixed(2)}`,"🛒","#0052cc");
          pushNotif("🛒 Nuevo pedido online",`Pedido #${row.id} · $${parseFloat(row.total||0).toFixed(2)} · Pendiente de surtir`,"/admin");
        })
      .on("postgres_changes",{event:"INSERT",schema:"public",table:"citas"},
        pl=>{ addNotif("📅 Nueva cita",`${pl.new?.nombre||"Paciente"} · ${pl.new?.fecha||""} ${pl.new?.hora||""}`,"📅","#7c3aed");
          pushNotif("📅 Nueva cita agendada",`${pl.new?.nombre||"Paciente"} · ${pl.new?.fecha||""} ${pl.new?.hora||""}`,"/admin"); })
      .on("postgres_changes",{event:"UPDATE",schema:"public",table:"pedidos"},
        pl=>{ if(pl.new?.estado==="listo") addNotif("✅ Pedido listo",`Pedido #${pl.new.id} listo para entrega`,"✅","#00c46a"); })
      .subscribe();
    return ()=>supabase.removeChannel(ch);
  },[usuario,addNotif]);
  const [neg,setNeg]     = useState("farmacia");
  const [alertas,setAlr] = useState({stock:0,pedidos:0,citas:0});

  // Cargar alertas
  useEffect(()=>{
    if(!usuario) return;
    const cargar = async () => {
      const hoy = new Date().toISOString().split("T")[0];
      const [{ data: prods }, { data: pendPedidos }, { data: cits }] = await Promise.all([
        supabase.from("productos").select("id,stock,stock_minimo"),
        supabase.from("pedidos").select("id,tipo,metodo_pago,estado").eq("estado", "pendiente"),
        supabase.from("citas").select("id").eq("fecha",hoy).not("cliente_id","is",null),
      ]);
      setAlr({
        stock: (prods||[]).filter(p=>p.stock<p.stock_minimo).length,
        pedidos: (pendPedidos||[]).filter(esPedidoTiendaWebPendiente).length,
        citas: (cits||[]).length,
      });
    };
    cargar();
    const interval = setInterval(cargar, 30000); // cada 30 seg
    return ()=>clearInterval(interval);
  },[usuario]);

  // Setear página inicial según rol
  useEffect(()=>{
    if(!usuario) return;
    if(usuario.rol==="vendedor") setPage("midia");
    else if(usuario.rol==="doctora") setPage("cons_dr");
    else setPage("dash");
  },[usuario]);

  const logout = async () => {
    const tok = sessionStorage.getItem("farmax_session_token");
    if (tok) {
      try { await supabase.rpc("logout_empleado", { p_session_token: tok }); } catch(e) {}
    }
    sessionStorage.removeItem("farmax_session_token");
    sessionStorage.removeItem("farmax_admin_user");
    localStorage.removeItem("farmax_pos_favs");
    localStorage.removeItem("farmax_busqs");
    localStorage.removeItem("farmax_last_login_"+usuario?.id);
    setUsuario(null);
    showToast("Sesión cerrada correctamente","info");
  };

  if(!usuario) return <LoginScreen onLogin={u=>{ sessionStorage.setItem("farmax_admin_user",JSON.stringify(u)); setUsuario(u); }}/>;

  const renderPage = () => {
    // Guard de permisos: bloquea acceso a módulos fuera del rol.
    if (!puedeVerModulo(usuario, page)) {
      return (
        <div style={{padding:60, maxWidth:520, margin:"0 auto", textAlign:"center", background:C_LIGHT.bg, minHeight:"70vh"}}>
          <div style={{fontSize:56, marginBottom:16}}>🔒</div>
          <h2 style={{color:C_LIGHT.text, fontSize:22, fontWeight:800, marginBottom:10}}>Acceso restringido</h2>
          <p style={{color:C_LIGHT.textMid, fontSize:14, lineHeight:1.5, marginBottom:20}}>
            Este módulo no está disponible para tu perfil. Si crees que deberías tener
            acceso, pídele al administrador que lo habilite desde Usuarios → 🔧 Módulos.
          </p>
          <button
            type="button"
            onClick={()=>setPageAndSave(usuario.rol==="vendedor"?"midia":usuario.rol==="doctora"?"cons_dr":"dash")}
            style={{padding:"10px 20px", background:BRAND.primary, color:"#fff", border:"none", borderRadius:8, fontSize:13, fontWeight:700, cursor:"pointer"}}
          >
            ← Volver al inicio
          </button>
        </div>
      );
    }

    switch(page){
      case "midia":     return <MiDia usuario={usuario} setPage={setPageAndSave}/>;
      case "dash":      return <DashboardModule usuario={usuario} setPage={setPageAndSave} showConfirm={showConfirm}/>;
      case "pos":       return <POS negocio={neg} usuario={usuario} initialTab="venta" onNavigate={setPageAndSave}/>;
      case "cons":      return <ConsultorioModule usuario={usuario}/>;
      case "config_cons": return <ConfigConsultorioModule />;
      case "cons_cobro":return <POS negocio={neg} usuario={usuario} initialTab="consultas" onNavigate={setPageAndSave}/>;
      case "cons_dr":   return <ConsDoctora />;
      case "rep_dr":    return <ReporteDoctora/>;
      case "inv":  return <InventarioHub initialTab={invInitialTab}/>;
      case "rrhh": return <RRHHModule/>;
      case "caja":  return <CorteCajaModule usuario={usuario}/>;
      case "cof":      return <COFEPRISModule/>;
      case "promo":    return <PromocionesModule/>;
      case "dev":      return <DevolucionesModule usuario={usuario}/>;
      case "fact":     return <FacturacionModule/>;
      case "banners": return <BannersAdmin/>;
      case "bot":      return <AsistenteIA/>;
      case "cli":   return <ClientesModule/>;
      case "pwa":       return <InstalarPWA/>;
      case "usuarios":  return <GestionUsuarios/>;
      default: return <div style={{color:C.textMid,padding:40,textAlign:"center"}}>Módulo en construcción...</div>;
    }
  };

  return(
    <>
    <GlobalHoverStyles/>
    <NotificacionesToast notifs={notifs} onDismiss={dismissNotif}/>
    <ToastProvider/>
    <ConfirmDialog
      open={confirmDlg.open}
      titulo={confirmDlg.titulo}
      mensaje={confirmDlg.mensaje}
      danger={confirmDlg.danger}
      onConfirm={()=>{ confirmDlg.onConfirm?.(); setConfirmDlg(p=>({...p,open:false})); }}
      onCancel={()=>setConfirmDlg(p=>({...p,open:false}))}
    />
    <div style={{background:C.bg,minHeight:"100vh",fontFamily:"'Plus Jakarta Sans',sans-serif",transition:"background .3s,color .3s",color:C.text,overflowX:"hidden"}}>
      <style>{`@import url('https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap');*{box-sizing:border-box;margin:0;padding:0;}`}</style>
      {isMobileLayout && mobileNavOpen && (
        <div
          role="presentation"
          onClick={()=>setMobileNavOpen(false)}
          style={{
            position:"fixed",inset:0,zIndex:1000,
            background:"rgba(15,23,42,.45)",backdropFilter:"blur(2px)",cursor:"pointer",
          }}
        />
      )}
      {isMobileLayout && (
        <button
          type="button"
          aria-label="Abrir menú de navegación"
          aria-expanded={mobileNavOpen}
          onClick={()=>setMobileNavOpen(o=>!o)}
          style={{
            position:"fixed",top:12,left:12,zIndex:999,
            width:44,height:44,borderRadius:10,
            border:`1px solid ${C.border}`,background:C.card,
            boxShadow:"0 4px 20px rgba(0,0,0,.08)",cursor:"pointer",
            fontSize:20,lineHeight:1,display:"flex",alignItems:"center",justifyContent:"center",
            color:C.text,
          }}
        >
          ☰
        </button>
      )}
      <Sidebar
        active={page} setActive={setPageAndSave}
        negocio={neg} setNegocio={setNeg}
        usuario={usuario} onLogout={logout}
        alertas={alertas}
        ventasOffline={ventasOffline}
        mobile={isMobileLayout}
        navOpen={mobileNavOpen}
        badgeCounts={badgeCounts}
        badgeCritical={badgeCritical}
      />
      <main style={{
        marginLeft:isMobileLayout?0:220,
        padding:isMobileLayout?"56px 16px 20px":28,
        minHeight:"100vh",
        maxWidth:isMobileLayout?"100%":"calc(100vw - 220px)",
        width:"100%",
        overflowX:"hidden",
        boxSizing:"border-box",
      }}>
        <ModuleErrorBoundary>
        <Suspense fallback={<ModuleSkeleton/>}>
        {renderPage()}
        </Suspense>
        </ModuleErrorBoundary>
      </main>
    </div>
  </>
  );
}