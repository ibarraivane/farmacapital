import React, { useState, useEffect, useRef, useCallback, lazy, Suspense } from "react";
import { useMediaQuery } from "./hooks/useMediaQuery";
import useSidebarBadges from "./hooks/useSidebarBadges";
import { supabase, isSupabaseLocalMisconfigured } from "./supabase";
import { C as _C, C_LIGHT, BRAND, NEG, NAV_ADMIN, NAV_VENDEDOR, NAV_DOCTORA, NAV_ITEMS, ADMIN_NAV_SECTIONS } from "./constants";
import { $, dC, cC, abc, aCol, nCol, hashPwd, hashPwdLegacy, generateSalt, primerNombre, saludoUsuario, normalizarSesionLoginResp } from "./utils";
import { validarPasswordTienda, PASSWORD_RULES_TEXT } from "./utils/passwordPolicy";
import { Logo, Box, Tag, Btn, Inp, KPI, Modal, NotificacionesToast, showToast, ToastProvider, ConfirmDialog, SkeletonTable, SkeletonKPIs, SkeletonCard, Paginador, GlobalHoverStyles } from "./ui";
import { sincronizarVentasPendientes, contarVentasPendientes } from "./utils/offlineQueue";
import { esPedidoTiendaWebPendiente, fetchPedidosTiendaPendientesMerged } from "./utils/pedidosTiendaWeb";
import AgendaConsultasModule from "./modules/clinical/AgendaConsultasModule";
import TransaccionesTab from "./TransaccionesTab";
import ExpedientesDoctora from "./modules/clinical/patients/ExpedientesDoctora";
import { loadAdminNavOrder } from "./utils/adminNavOrder";
import { puedeVerModulo, modulosPermitidosParaRol } from "./utils/permissions";
import { adminPathnameToPageId, pageIdToAdminPath, pathnameSuggestsPosTab } from "./shared/adminRoutes";
import { initBillingListeners } from "./modules/billing/core/initBillingListeners";
import { canAccessRoute } from "./core/security/routeGuard";
import ImageUploader from "./components/ImageUploader";

// Fallback estático para estilos fuera de componentes (evita undefined en import).
const C = C_LIGHT;

// ── Lazy loading — módulos se cargan solo cuando se necesitan ──
const RRHHModule       = lazy(()=>import("./RRHHModule"));
const InventarioHub    = lazy(()=>import("./InventarioHub"));
const MiDia            = lazy(()=>import("./modules/sales/MiDia"));
const POS              = lazy(()=>import("./modules/sales/pos/POS"));
const CorteCajaModule  = lazy(()=>import("./CorteCajaModule"));
const ClientesModule   = lazy(()=>import("./ClientesModule"));
const ConsultorioModule= lazy(()=>import("./modules/clinical/ConsultorioModule"));
const ConfigConsultorioModule = lazy(()=>import("./modules/clinical/ConfigConsultorioModule"));
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
  componentDidCatch(error, info) { console.error("[FarmaCapital] Error en módulo:", error, info); }
  render() {
    if(this.state.hasError) return(
      <div style={{padding:40,textAlign:"center"}}>
        <div style={{fontSize:48,marginBottom:16}}>⚠️</div>
        <div style={{color:"#0f172a",fontWeight:700,fontSize:16,marginBottom:8}}>Error al cargar este módulo</div>
        <div style={{color:"#475569",fontSize:12,marginBottom:20,maxWidth:400,margin:"0 auto 20px",fontFamily:"monospace",background:"#f8fafc",padding:"8px 12px",borderRadius:6}}>{this.state.error?.message}</div>
        <button onClick={()=>this.setState({hasError:false,error:null})}
          style={{padding:"9px 20px",borderRadius:8,border:"none",background:"linear-gradient(135deg,#0D1B2A,#1E3ABA)",color:"#fff",fontWeight:700,cursor:"pointer"}}>
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
// FARMACAPITAL — Sistema Admin v2
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
  const [retryMsg,setRetryMsg] = useState("");

  const entrar = async () => {
    if(!email||!pwd) return;
    if(pwd.length < 6) { setError("La contraseña debe tener al menos 6 caracteres."); return; }
    const idNorm = email.trim().toLowerCase();

    const bloqueoKey  = "farmacapital_login_bloqueo_"+idNorm;
    const intentosKey = "farmacapital_login_intentos_"+idNorm;
    const bloqueoHasta = localStorage.getItem(bloqueoKey);
    if(bloqueoHasta && Date.now() < parseInt(bloqueoHasta)) {
      const mins = Math.ceil((parseInt(bloqueoHasta)-Date.now())/60000);
      setError(`Demasiados intentos. Intenta en ${mins} minuto${mins>1?"s":""}.`);
      return;
    }

    setLoad(true); setError(""); setErrorDetail(""); setRetryMsg("");

    // Reintenta hasta 4 veces (60 s total) para sobrevivir el cold start de Supabase Postgres
    const MAX = 4;
    const tryRpc = async (attempt = 1) => {
      if (attempt > 1) setRetryMsg(`Conectando con el servidor… (intento ${attempt} de ${MAX})`);
      const rpcPromise = supabase.rpc("login_empleado", {
        p_identificador: idNorm,
        p_password:      pwd,
        p_user_agent:    navigator.userAgent || null,
      });
      const timeoutPromise = new Promise((_, reject) =>
        setTimeout(() => reject(new Error("timeout")), 18000)
      );
      try {
        const result = await Promise.race([rpcPromise, timeoutPromise]);
        const { error: rpcErr } = result;
        const isDbTimeout = rpcErr && (rpcErr.message || "").toLowerCase().includes("upstream request timeout");
        if (isDbTimeout && attempt < MAX) {
          await new Promise(r => setTimeout(r, 1500));
          return tryRpc(attempt + 1);
        }
        return result;
      } catch(e) {
        // Nuestro timer de 18 s disparó antes que Supabase — Postgres aún despertando
        if (e?.message === "timeout" && attempt < MAX) {
          await new Promise(r => setTimeout(r, 1000));
          return tryRpc(attempt + 1);
        }
        throw e;
      }
    };

    try {
      const { data: raw, error: rpcErr } = await tryRpc();
      setRetryMsg("");

      if (rpcErr) {
        const tech = rpcErr.message || String(rpcErr);
        const low = tech.toLowerCase();
        let msg = "No pudimos conectar con el servidor de datos.";
        if (isSupabaseLocalMisconfigured) {
          msg =
            "Supabase no está configurado para desarrollo: en la carpeta del proyecto (donde está package.json) editá el archivo .env y poné REACT_APP_SUPABASE_URL y REACT_APP_SUPABASE_ANON_KEY desde Supabase → Settings → API. Guardá, detené el servidor (Ctrl+C) y ejecutá npm start de nuevo.";
        } else if (low.includes("failed to fetch") || low.includes("network")) {
          msg = "No se pudo llegar al servidor. Revisa tu conexión a internet.";
        } else if (rpcErr.code === "PGRST202" || low.includes("could not find the function")) {
          msg = "Falta actualizar la base de datos (función de inicio de sesión no encontrada).";
        } else if (rpcErr.code === "42501" || low.includes("permission denied")) {
          msg = "El servidor rechazó el inicio de sesión por permisos.";
        } else if (low.includes("upstream request timeout")) {
          msg = "El servidor está ocupado. Espera unos segundos y vuelve a intentar.";
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

      sessionStorage.setItem("farmacapital_session_token", String(resp.session_token));
      sessionStorage.setItem("farmacapital_admin_user", JSON.stringify(data));
      localStorage.setItem("farmacapital_last_login_"+data.id, new Date().toLocaleString("es-MX"));
      onLogin(data);
    } catch(e) {
      const isTimeout = e?.message === "timeout";
      setError(
        isTimeout
          ? "El servidor tardó demasiado en responder. Espera 30 s y vuelve a intentar."
          : isSupabaseLocalMisconfigured
            ? "Revisá el archivo .env en la raíz del proyecto: URL y anon key desde Supabase → Settings → API, guardá y volvé a ejecutar npm start."
            : "No pudimos conectar. Revisa tu internet o vuelve a intentar en unos segundos."
      );
      setErrorDetail(!isTimeout && e?.message ? String(e.message) : "");
      setRetryMsg("");
    }
    setLoad(false);
  };

  return(
    <>
    <style>{`.farmacapital-login-screen{min-height:100vh;min-height:100dvh}`}</style>
    <div className="farmacapital-login-screen" data-brand-surface="light" style={{background:"linear-gradient(135deg,#f0f4ff 0%,#f7f9fc 50%,#e8f4fd 100%)",display:"flex",alignItems:"center",justifyContent:"center",padding:"max(clamp(12px,4vw,20px), env(safe-area-inset-top, 0px)) max(clamp(12px,4vw,20px), env(safe-area-inset-right, 0px)) max(clamp(12px,4vw,20px), env(safe-area-inset-bottom, 0px)) max(clamp(12px,4vw,20px), env(safe-area-inset-left, 0px))",boxSizing:"border-box",overflowX:"hidden"}}>
      <div style={{width:"100%",maxWidth:400,minWidth:0}}>
        <div style={{textAlign:"center",marginBottom:32}}>
          <div style={{display:"flex",justifyContent:"center",marginBottom:16}}><Logo size={56} variant="admin"/></div>
          <div style={{color:C.textMid,fontSize:14}}>Acceso interno · Gestión de farmacia</div>
        </div>
        <Box style={{padding:32,boxShadow:"0 4px 24px rgba(15,45,110,.10)"}}>
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
          <Btn onClick={entrar} full col={BRAND.primary} dis={!email||!pwd||loading}>{loading ? (retryMsg ? "Conectando…" : "Verificando…") : "Entrar →"}</Btn>
          {retryMsg && <div style={{marginTop:8,textAlign:"center",fontSize:12,color:C.textDim}}>{retryMsg}</div>}
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
                      p_ip: null,
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
    </>
  );
}

// ══════════════════════════════════════════════════════════════
// SIDEBAR
// ══════════════════════════════════════════════════════════════
/** Agrupa entradas del admin por área de trabajo (orden fijo por sección). */
function groupAdminNavForRender(navIds) {
  const used = new Set();
  const out = [];
  for (const sec of ADMIN_NAV_SECTIONS) {
    const ids = navIds.filter((id) => sec.ids.includes(id));
    ids.forEach((id) => used.add(id));
    if (ids.length) {
      out.push({ type: "section", title: sec.title });
      ids.forEach((id) => out.push({ type: "item", id }));
    }
  }
  const extra = navIds.filter((id) => !used.has(id));
  if (extra.length) {
    out.push({ type: "section", title: "Otros" });
    extra.forEach((id) => out.push({ type: "item", id }));
  }
  return out;
}

function farmacapitalNavLabel(item, usuario) {
  if (!item) return "";
  if (item.id === "agenda" && usuario?.rol === "vendedor") return "Consultas del día";
  if (item.id === "cons_dr" && usuario?.rol === "doctora") return "Agenda médica";
  return item.label;
}

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

function AdminNavSidebar({active,setActive,negocio,setNegocio,usuario,onLogout,alertas,ventasOffline=0,mobile=false,navOpen=false,badgeCounts={},badgeCritical={}}){
  const C = C_LIGHT;
  const isAdmin = usuario.rol==="admin";
  const [adminOrder, setAdminOrder] = useState(() => (isAdmin ? loadAdminNavOrder(usuario) : null));

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

  const btnStyleBase = (rowActive) => ({
    flex:1,minWidth:0,
    display:"flex",alignItems:"center",gap:10,
    padding:"8px 10px",borderRadius:8,border:"none",cursor:"pointer",
    textAlign:"left",fontSize:12,fontWeight:600,fontFamily:"'Plus Jakarta Sans',sans-serif",
    background:rowActive?BRAND.primary+"18":"transparent",
    color:rowActive?BRAND.primary:C.textMid,
    borderLeft:`3px solid ${rowActive?BRAND.primary:"transparent"}`,
    transition:"all .15s",
  });

  return(
    <div
      className="farmacapital-admin-sidebar"
      style={{
      width:220,flexShrink:0,background:C.card,borderRight:`1px solid ${C.border}`,
      boxShadow: mobile?"4px 0 24px rgba(0,0,0,.12)":"2px 0 8px rgba(0,0,0,.06)",
      display:"flex",flexDirection:"column",position:"fixed",left:mobile?(navOpen?0:-220):0,top:0,
      height:"100vh",maxHeight:"100dvh",zIndex:mobile?1001:100,overflow:"hidden",transition:"left .22s ease",
    }}>
      <div style={{flexShrink:0,padding:"18px 14px 14px",borderBottom:`1px solid ${C.border}`}}>
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
      <div style={{flexShrink:0,padding:"10px 14px",borderBottom:`1px solid ${C.border}`,display:"flex",alignItems:"center",gap:10}}>
        <div style={{width:32,height:32,borderRadius:"50%",background:rolColor+"30",border:`1px solid ${rolColor}40`,display:"flex",alignItems:"center",justifyContent:"center",color:rolColor,fontWeight:800,fontSize:13,flexShrink:0}}>
          {(primerNombre(usuario.nombre)||"U")[0].toUpperCase()}
        </div>
        <div style={{flex:1,minWidth:0}}>
          <div style={{color:C.text,fontWeight:700,fontSize:12,overflow:"hidden",textOverflow:"ellipsis",whiteSpace:"nowrap"}}>{saludoUsuario(usuario.nombre)}</div>
          <Tag col={rolColor} sm>{usuario.rol}</Tag>
        </div>
      </div>

      <div style={{flex:1,minHeight:0,padding:"8px 8px",overflowY:"auto",WebkitOverflowScrolling:"touch",overscrollBehaviorY:"contain",scrollbarWidth:"thin",scrollbarColor:`${BRAND.primary}30 transparent`}}>
        {isAdmin
          ? <>
            {groupAdminNavForRender(navIds).map((row, idx) => {
              if (row.type === "section") {
                return (
                  <div
                    key={`sec-${row.title}-${idx}`}
                    style={{
                      padding: "12px 10px 4px",
                      color: C.textDim,
                      fontSize: 10,
                      fontWeight: 800,
                      letterSpacing: 0.5,
                      textTransform: "uppercase",
                    }}
                  >
                    {row.title}
                  </div>
                );
              }
              const n = NAV_ITEMS.find((x) => x.id === row.id);
              if (!n) return null;
              const rowActive = active === n.id;
              const btnStyle = btnStyleBase(rowActive);
              return (
                <button
                  key={n.id}
                  type="button"
                  onClick={() => setActive(n.id)}
                  onMouseEnter={(e) => {
                    if (!rowActive) {
                      e.currentTarget.style.background = BRAND.primary + "10";
                      e.currentTarget.style.color = BRAND.primary;
                      e.currentTarget.style.borderLeftColor = BRAND.primary + "50";
                    }
                  }}
                  onMouseLeave={(e) => {
                    if (!rowActive) {
                      e.currentTarget.style.background = "transparent";
                      e.currentTarget.style.color = C.textMid;
                      e.currentTarget.style.borderLeftColor = "transparent";
                    }
                  }}
                  style={{ ...btnStyle, width: "100%", marginBottom: 2 }}
                >
                  <span style={{ width: 18, height: 18, display: "inline-flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
                    {typeof n.icon === "string" ? (
                      <span style={{ fontSize: 12 }}>{n.icon}</span>
                    ) : n.icon ? (
                      <n.icon size={16} strokeWidth={2.1} />
                    ) : null}
                  </span>
                  <span style={{ overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap", flex: 1 }}>{farmacapitalNavLabel(n, usuario)}</span>
                  <SidebarBadge count={badgeCounts[n.id]} critical={badgeCritical[n.id]} />
                </button>
              );
            })}
          </>
          : navItems.map((n) => {
            const rowActive = active === n.id;
            const btnStyle = btnStyleBase(rowActive);
            return (
              <button
                key={n.id}
                onClick={() => setActive(n.id)}
                onMouseEnter={(e) => {
                  if (!rowActive) {
                    e.currentTarget.style.background = BRAND.primary + "10";
                    e.currentTarget.style.color = BRAND.primary;
                    e.currentTarget.style.borderLeftColor = BRAND.primary + "50";
                  }
                }}
                onMouseLeave={(e) => {
                  if (!rowActive) {
                    e.currentTarget.style.background = "transparent";
                    e.currentTarget.style.color = C.textMid;
                    e.currentTarget.style.borderLeftColor = "transparent";
                  }
                }}
                style={{ ...btnStyle, width: "100%", marginBottom: 2 }}
              >
                <span style={{ width: 18, height: 18, display: "inline-flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
                  {typeof n.icon === "string" ? (
                    <span style={{ fontSize: 12 }}>{n.icon}</span>
                  ) : n.icon ? (
                    <n.icon size={16} strokeWidth={2.1} />
                  ) : null}
                </span>
                <span style={{ overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap", flex: 1 }}>{farmacapitalNavLabel(n, usuario)}</span>
                <SidebarBadge count={badgeCounts[n.id]} critical={badgeCritical[n.id]} />
              </button>
            );
          })}
      </div>

      {/* Alertas y logout */}
      <div style={{flexShrink:0,padding:"0 8px 16px"}}>
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
        const adminTok = sessionStorage.getItem("farmacapital_session_token");
        const [
          pedsRes,
          homeRes,
        ] = await Promise.all([
          fetchPedidosTiendaPendientesMerged(supabase, pedidosTiendaSelect, { perBranchLimit: 80, maxRows: 200 }),
          adminTok
            ? supabase.rpc("empleado_admin_home_snapshot", {
                p_session_token: adminTok,
                p_hoy_local: hoyLocal,
                p_today_start: t0.toISOString(),
                p_today_end: t1.toISOString(),
                p_week_start: weekAgo.toISOString(),
                p_month_start: monthStart.toISOString(),
              })
            : Promise.resolve({ data: null, error: null }),
        ]);

        if (pedsRes?.error) console.error("[Dashboard] Pedidos:", pedsRes.error);
        if (homeRes?.error) console.error("[Dashboard] Home snapshot:", homeRes.error);

        setPedOn((pedsRes?.data || []).filter(esPedidoTiendaWebPendiente));
        const H = homeRes?.data || {};
        setCitasH(H.citas_agenda_hoy || []);

        const hoy = (H.ventas_hoy || []).reduce((a, p) => a + parseFloat(p.total || 0), 0);
        const semana = (H.ventas_semana || []).reduce((a, p) => a + parseFloat(p.total || 0), 0);
        const mes = (H.ventas_mes || []).reduce((a, p) => a + parseFloat(p.total || 0), 0);
        const consultas = (H.citas_completadas_hoy || []).length;

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
// GESTIÓN DE USUARIOS (solo Admin)
// ══════════════════════════════════════════════════════════════
function BannersAdmin(){
  const C = C_LIGHT;
  const [banners,setBanners] = useState([]);
  const [loading,setLoad]   = useState(true);
  const [modal,setModal]    = useState(null);
  const [form,setForm]      = useState({titulo:"",subtitulo:"",descripcion:"",emoji:"💊",bg:"linear-gradient(135deg,#0D1B2A,#1E3ABA)",cta:"Ver más →",pagina:"catalogo",orden:0,activo:true,slot:"hero",imagen_url:"",imagen_url_mobile:"",video_url:"",modo_visualizacion:"imagen_fondo"});
  const [saving,setSaving]  = useState(false);

  const fetch = async()=>{
    setLoad(true);
    const tok = sessionStorage.getItem("farmacapital_session_token");
    const { data, error } = await supabase.rpc("admin_listar_banners", {
      p_session_token: tok,
    });
    if (error) {
      console.warn("[BannersAdmin] admin_listar_banners:", error.message);
      const { data: fallback } = await supabase.from("banners").select("*").order("orden");
      setBanners(fallback || []);
    } else {
      setBanners(data || []);
    }
    setLoad(false);
  };
  useEffect(()=>{ fetch(); },[]);

  const guardar = async()=>{
    setSaving(true);
    const tok = sessionStorage.getItem("farmacapital_session_token");
    const payload = {
      ...form,
      imagen_mobile_url: form.imagen_url_mobile || "",
      imagen_url_mobile: form.imagen_url_mobile || "",
    };
    const { error } = await supabase.rpc("admin_upsert_banner", {
      p_session_token: tok,
      p_id:            modal === "new" ? null : modal.id,
      p_payload:       payload,
    });
    if (error) {
      setSaving(false);
      showToast("Error: "+error.message, "error");
      return;
    }
    setSaving(false);
    setModal(null); fetch();
    showToast("Banner guardado correctamente","success");
  };

  const eliminar = async(id)=>{
    if(!window.confirm("¿Eliminar este banner?")) return;
    const tok = sessionStorage.getItem("farmacapital_session_token");
    const { error } = await supabase.rpc("admin_eliminar_banner", {
      p_session_token: tok, p_id: id,
    });
    if (error) { showToast("Error: "+error.message, "error"); return; }
    fetch(); showToast("Banner eliminado","info");
  };

  const toggleActivo = async(b)=>{
    const tok = sessionStorage.getItem("farmacapital_session_token");
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
        <Btn col={BRAND.primary} onClick={()=>{setForm({titulo:"",subtitulo:"",descripcion:"",emoji:"💊",bg:BRAND.gradient,cta:"Ver más →",pagina:"promo",orden:banners.length+1,activo:true,slot:"hero",imagen_url:"",imagen_url_mobile:"",video_url:"",modo_visualizacion:"imagen_fondo"});setModal("new");}}>+ Nuevo banner</Btn>
      </div>
      <div style={{background:"#eff6ff",border:"1px solid #bfdbfe",borderRadius:10,padding:"10px 16px",marginBottom:16,fontSize:12,color:"#1d4ed8",lineHeight:1.55}}>
        💡 <strong>Zona:</strong> <em>Carrusel</em> (arriba, rotación automática) · <em>Franja</em> (tarjetas anchas bajo la barra de servicios) · <em>Mosaico</em> (rejilla bajo la búsqueda) · <em>Popup</em> (ventana de bienvenida al entrar).
        {" "}En <strong>Página destino</strong>: <code style={{background:"#fff",padding:"1px 6px",borderRadius:4}}>promo</code>, <code style={{background:"#fff",padding:"1px 6px",borderRadius:4}}>catalogo</code>, <code style={{background:"#fff",padding:"1px 6px",borderRadius:4}}>cita</code>…
        {" "}Si no ves el campo <strong>Zona</strong> en Supabase, ejecutá <code style={{background:"#fff",padding:"1px 6px",borderRadius:4}}>sql/banners_slot.sql</code>.
      </div>
      {loading?<SkeletonTable rows={5} cols={5}/>:(
        <div style={{display:"flex",flexDirection:"column",gap:10}}>
          {!banners.length&&<div style={{color:C.textMid,textAlign:"center",padding:40,background:C.card,borderRadius:12,border:`1px solid ${C.border}`}}>Sin banners. Crea el primero.</div>}
          {banners.map(b=>(
            <div key={b.id} style={{background:C.card,borderRadius:12,border:`1px solid ${C.border}`,padding:16,display:"flex",gap:16,alignItems:"center",flexWrap:"wrap"}}>
              <div style={{
                width:80,height:45,borderRadius:10,
                background:b.imagen_url?`url(${b.imagen_url}) center/cover`:b.bg,
                display:"flex",alignItems:"center",justifyContent:"center",fontSize:24,flexShrink:0,overflow:"hidden",
              }}>
                {!b.imagen_url&&b.emoji}
              </div>
              <div style={{flex:"1 1 200px",minWidth:0}}>
                <div style={{fontWeight:800,color:C.text,fontSize:14}}>{(b.titulo&&String(b.titulo).trim())?b.titulo:"(Sin título)"}</div>
                <div style={{color:C.textMid,fontSize:12,marginTop:2}}>{b.subtitulo} · {b.descripcion?.slice(0,60)}{b.descripcion?.length>60?"…":""}</div>
                <div style={{color:C.textDim,fontSize:11,marginTop:4}}>
                  {(b.slot==="strip"?"▤ Franja":b.slot==="tile"?"▦ Mosaico":b.slot==="popup"?"◉ Popup":"▶ Carrusel")} · Orden: {b.orden} · {b.pagina} · {b.cta}{b.video_url?" · ▶ Video":""}
                </div>
              </div>
              <div style={{display:"flex",gap:8,flexShrink:0}}>
                <button onClick={()=>toggleActivo(b)} style={{padding:"5px 10px",borderRadius:6,border:`1px solid ${b.activo?C.green:C.border}`,background:b.activo?C.greenDim:"transparent",color:b.activo?C.green:C.textMid,fontSize:11,fontWeight:700,cursor:"pointer"}}>{b.activo?"✓ Activo":"○ Inactivo"}</button>
                <button onClick={()=>{setForm({...b,imagen_url:b.imagen_url||"",imagen_url_mobile:(b.imagen_url_mobile||b.imagen_mobile_url)||"",video_url:b.video_url||"",modo_visualizacion:b.modo_visualizacion||"imagen_fondo"});setModal(b);}} style={{padding:"5px 10px",borderRadius:6,border:`1px solid ${C.amber}`,background:C.amberDim,color:C.amber,fontSize:11,fontWeight:700,cursor:"pointer"}}>✏️ Editar</button>
                <button onClick={()=>eliminar(b.id)} style={{padding:"5px 10px",borderRadius:6,border:`1px solid ${C.red}`,background:C.redDim,color:C.red,fontSize:11,fontWeight:700,cursor:"pointer"}}>🗑️</button>
              </div>
            </div>
          ))}
        </div>
      )}
      {modal&&(
        <div style={{position:"fixed",inset:0,background:"rgba(15,23,42,.45)",backdropFilter:"blur(4px)",zIndex:500,display:"flex",alignItems:"center",justifyContent:"center",padding:"max(12px, env(safe-area-inset-top, 0px)) max(12px, env(safe-area-inset-right, 0px)) max(12px, env(safe-area-inset-bottom, 0px)) max(12px, env(safe-area-inset-left, 0px))",boxSizing:"border-box"}} onClick={e=>e.target===e.currentTarget&&setModal(null)}>
          <div style={{background:C.card,borderRadius:14,width:"min(520px,95vw)",maxHeight:"90vh",overflowY:"auto",padding:28,boxShadow:"0 20px 60px rgba(15,45,110,.15)"}}>
            <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:20}}>
              <h3 style={{margin:0,color:C.text,fontSize:16,fontWeight:800}}>{modal==="new"?"➕ Nuevo":"✏️ Editar"} Banner</h3>
              <button onClick={()=>setModal(null)} style={{background:"none",border:"none",color:C.textMid,fontSize:22,cursor:"pointer"}}>✕</button>
            </div>
            <div style={{display:"grid",gridTemplateColumns:"1fr",gap:12,marginBottom:16}}>
              <div style={{padding:14,background:C.bg,borderRadius:10,border:`1px solid ${C.border}`}}>
                <label style={{color:C.textMid,fontSize:11,fontWeight:700,display:"block",marginBottom:8}}>
                  IMAGEN DESKTOP (1920×600px · ratio ~16:5)
                </label>
                <ImageUploader
                  bucket="banners"
                  maxSizeMB={12}
                  currentUrl={form.imagen_url}
                  onUploaded={(url)=>setForm((p)=>({...p,imagen_url:url}))}
                  onRemoved={()=>{
                    setForm((p)=>({...p,imagen_url:""}));
                    if(modal&&modal!=="new"&&modal?.id){
                      const tok=sessionStorage.getItem("farmacapital_session_token");
                      if(tok){
                        supabase.rpc("admin_upsert_banner",{p_session_token:tok,p_id:modal.id,p_payload:{imagen_url:""}})
                          .then(({error})=>{ if(error)showToast(error.message,"error"); else { showToast("Imagen desktop quitada","info"); fetch(); }});
                      }
                    }
                  }}
                  aspectRatio="16:9"
                  filenamePrefix={`${(form.titulo||"banner").toLowerCase().replace(/\s/g,"-")}-desktop`}
                  size="medium"
                />
              <div style={{fontSize:11,color:C.textDim,marginTop:6,lineHeight:1.4}}>
                Imagen rectangular ancha para laptop/tablet. La tienda la ajusta automáticamente (recomendado 1600×900px o similar). Bucket <code style={{background:C.card,padding:"1px 4px",borderRadius:4}}>banners</code>.
              </div>
              </div>
              <div style={{padding:14,background:C.bg,borderRadius:10,border:`1px solid ${C.border}`}}>
                <label style={{color:C.textMid,fontSize:11,fontWeight:700,display:"block",marginBottom:8}}>
                  IMAGEN MOBILE (1080×1080px · 1:1)
                </label>
                <ImageUploader
                  bucket="banners"
                  maxSizeMB={12}
                  currentUrl={form.imagen_url_mobile}
                  onUploaded={(url)=>setForm((p)=>({...p,imagen_url_mobile:url}))}
                  onRemoved={()=>{
                    setForm((p)=>({...p,imagen_url_mobile:""}));
                    if(modal&&modal!=="new"&&modal?.id){
                      const tok=sessionStorage.getItem("farmacapital_session_token");
                      if(tok){
                        supabase.rpc("admin_upsert_banner",{p_session_token:tok,p_id:modal.id,p_payload:{imagen_url_mobile:"",imagen_mobile_url:""}})
                          .then(({error})=>{ if(error)showToast(error.message,"error"); else { showToast("Imagen mobile quitada","info"); fetch(); }});
                      }
                    }
                  }}
                  aspectRatio="1:1"
                  filenamePrefix={`${(form.titulo||"banner").toLowerCase().replace(/\s/g,"-")}-mobile`}
                  size="medium"
                />
                <div style={{fontSize:11,color:C.textDim,marginTop:6,lineHeight:1.4}}>
                  Cuadrada para celular (recomendado 1080×1080). Si no subís una, la tienda usa la desktop. Se ajusta sola al marco.
                </div>
              </div>
            </div>
            <div style={{marginBottom:16,padding:14,background:C.bg,borderRadius:10,border:`1px solid ${C.border}`}}>
              <label style={{color:C.textMid,fontSize:11,fontWeight:700,display:"block",marginBottom:8}}>
                ▶ VIDEO CORTO (OPCIONAL)
              </label>
              <input
                style={inpS}
                type="url"
                inputMode="url"
                placeholder="https://…tu-archivo.mp4"
                value={form.video_url || ""}
                onChange={(e)=>setForm((p)=>({...p,video_url:e.target.value}))}
              />
              <div style={{fontSize:11,color:C.textDim,marginTop:8,lineHeight:1.45}}>
                💡 URL pública <strong>MP4</strong> o <strong>WebM</strong> (idealmente sin audio o silenciado en el archivo). Podés subir el archivo al bucket{" "}
                <code style={{background:C.card,padding:"1px 4px",borderRadius:4}}>banners</code>{" "}
                en Storage y pegar el enlace. Si hay video, la tienda lo muestra en lugar de la imagen; la imagen puede servir de <strong>poster</strong> mientras carga.
                {" "}GIF animados o WebP animados seguís usándolos como imagen normal (sin este campo).
              </div>
            </div>
            <div style={{marginBottom:14,padding:14,background:C.bg,borderRadius:10,border:`1px solid ${C.border}`}}>
              <label style={{color:C.textMid,fontSize:11,fontWeight:700,display:"block",marginBottom:8}}>
                🎨 MODO DE VISUALIZACIÓN
              </label>
              <select
                style={inpS}
                value={form.modo_visualizacion || "imagen_fondo"}
                onChange={(e)=>setForm((p)=>({...p,modo_visualizacion:e.target.value}))}
              >
                <option value="imagen_fondo">🖼️ Imagen como fondo + texto editable encima</option>
                <option value="imagen_completa">📷 Solo imagen (sin texto encima)</option>
              </select>
              <div style={{fontSize:11,color:C.textDim,marginTop:6,lineHeight:1.4}}>
                💡 <strong>Imagen completa:</strong> diseño con texto incluido (Canva, etc.). La tienda muestra la imagen entera sin recortar bordes.
                <br/>
                💡 <strong>Imagen de fondo:</strong> la imagen llena el marco y vos editás el texto encima desde Admin.
                <br/>
                Las medidas indicadas son recomendadas; cualquier proporción se adapta automáticamente.
              </div>
            </div>
            {[["Título (opcional)","titulo"],["Subtítulo","subtitulo"],["Descripción","descripcion"],["Emoji (si no hay imagen)","emoji"],["Texto del botón","cta"],["Página destino","pagina"]].map(([l,k])=>(
              <div key={k}><label style={{color:C.textMid,fontSize:11,fontWeight:700,display:"block",marginBottom:3}}>{l.toUpperCase()}</label><input style={inpS} value={form[k]||""} onChange={e=>setForm(p=>({...p,[k]:e.target.value}))} placeholder={l}/></div>
            ))}
            <div>
              <label style={{color:C.textMid,fontSize:11,fontWeight:700,display:"block",marginBottom:3}}>ZONA EN EL HOME</label>
              <select style={{...inpS,marginBottom:10}} value={form.slot||"hero"} onChange={e=>setForm(p=>({...p,slot:e.target.value}))}>
                <option value="hero">▶ Carrusel principal (arriba)</option>
                <option value="strip">▤ Franja (bajo iconos de servicio)</option>
                <option value="tile">▦ Mosaico (bajo la barra de búsqueda)</option>
                <option value="popup">◉ Popup de bienvenida (al entrar)</option>
              </select>
            </div>
            <div><label style={{color:C.textMid,fontSize:11,fontWeight:700,display:"block",marginBottom:3}}>COLOR DE FONDO (CSS gradient)</label><input style={inpS} value={form.bg||""} onChange={e=>setForm(p=>({...p,bg:e.target.value}))} placeholder="linear-gradient(...)"/></div>
            <div><label style={{color:C.textMid,fontSize:11,fontWeight:700,display:"block",marginBottom:3}}>ORDEN</label><input type="number" style={inpS} value={form.orden||0} onChange={e=>setForm(p=>({...p,orden:parseInt(e.target.value)||0}))}/></div>
            <div style={{display:"flex",gap:10,justifyContent:"flex-end",marginTop:8}}>
              <button onClick={()=>setModal(null)} style={{padding:"9px 20px",borderRadius:8,border:`1px solid ${C.border}`,background:"transparent",color:C.textMid,fontWeight:700,cursor:"pointer"}}>Cancelar</button>
              <button onClick={guardar} disabled={saving} style={{padding:"9px 20px",borderRadius:8,border:"none",background:BRAND.gradient,color:"#fff",fontWeight:700,cursor:"pointer"}}>{saving?"Guardando…":"💾 Guardar"}</button>
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

function PasswordResetSolicitudesModal({ open, onClose }) {
  const C = C_LIGHT;
  const [solicitudes, setSolicitudes] = useState([]);
  const [loading, setLoading] = useState(true);
  const [guardando, setGuardando] = useState(null);
  const [nuevaClave, setNuevaClave] = useState({});
  const [error, setError] = useState("");

  const cargar = useCallback(async () => {
    setLoading(true);
    setError("");
    const tok = sessionStorage.getItem("farmacapital_session_token");
    const { data, error: err } = await supabase.rpc("admin_listar_password_resets_pendientes", {
      p_session_token: tok,
    });
    if (err) {
      setError(err.message);
      setSolicitudes([]);
    } else {
      setSolicitudes((data || []).map((row) => (typeof row === "string" ? JSON.parse(row) : row)));
    }
    setLoading(false);
  }, []);

  useEffect(() => {
    if (open) cargar();
  }, [open, cargar]);

  const marcarAtendido = async (id) => {
    setGuardando(id);
    const tok = sessionStorage.getItem("farmacapital_session_token");
    const { data: resp, error: err } = await supabase.rpc("admin_atender_password_reset", {
      p_session_token: tok,
      p_request_id: id,
    });
    if (err || !resp?.success) {
      showToast("Error: " + (resp?.error || err?.message || "No se pudo marcar"), "error");
    } else {
      setSolicitudes((p) => p.filter((s) => s.id !== id));
      showToast("Solicitud marcada como atendida", "success");
    }
    setGuardando(null);
  };

  const asignarClaveCliente = async (req) => {
    const clave = (nuevaClave[req.id] || "").trim();
    const val = validarPasswordTienda(clave);
    if (!val.ok) {
      showToast(val.error, "warning");
      return;
    }
    const ident = String(req.email_o_telefono || "").trim();
    if (!ident) {
      showToast("Solicitud sin teléfono ni correo", "warning");
      return;
    }
    setGuardando(req.id);
    const tok = sessionStorage.getItem("farmacapital_session_token");
    const { data: cliente, error: cliErr } = await supabase.rpc("admin_resolver_cliente_por_identificador", {
      p_session_token: tok,
      p_identificador: ident,
    });
    if (cliErr || !cliente?.id) {
      showToast(
        "No encontramos cuenta de tienda con ese teléfono o correo. Verifica el dato, crea la cuenta en Clientes o envía el enlace de reset.",
        "warning"
      );
      setGuardando(null);
      return;
    }
    const { data: resp, error: err } = await supabase.rpc("admin_asignar_password_cliente", {
      p_session_token: tok,
      p_cliente_id: cliente.id,
      p_nueva_password: clave,
    });
    if (err || !resp?.success) {
      showToast("Error: " + (resp?.error || err?.message || "No se pudo asignar"), "error");
      setGuardando(null);
      return;
    }
    await marcarAtendido(req.id);
    setNuevaClave((p) => ({ ...p, [req.id]: "" }));
    showToast(`Contraseña asignada a ${cliente.nombre || ident}`, "success");
    setGuardando(null);
  };

  const enviarLinkReset = async (req) => {
    setGuardando(req.id);
    const tok = sessionStorage.getItem("farmacapital_session_token");
    const { data: resp, error: err } = await supabase.rpc("admin_generar_link_reset_password", {
      p_session_token: tok,
      p_request_id: req.id,
    });
    if (err || !resp?.success) {
      showToast(resp?.error || err?.message || "No se pudo generar el enlace", "warning");
      setGuardando(null);
      return;
    }
    const origin = window.location.origin.replace(/\/$/, "");
    const resetUrl = `${origin}/?reset=${resp.token}`;
    const digits = String(resp.telefono || req.email_o_telefono || "").replace(/\D/g, "");
    const msg =
      `🔐 *FarmaCapital — Restablecer contraseña*\n\n` +
      `Hola, usa este enlace (válido 2 horas) para crear tu nueva contraseña de la tienda en línea:\n${resetUrl}\n\n` +
      `Si no lo pediste, ignora este mensaje.`;
    if (digits.length >= 10) {
      window.open(`https://wa.me/52${digits}?text=${encodeURIComponent(msg)}`, "_blank", "noopener,noreferrer");
      showToast("WhatsApp abierto con el enlace de reset", "success");
    } else {
      try {
        await navigator.clipboard.writeText(resetUrl);
        showToast("Enlace copiado (la cuenta no tiene teléfono válido)", "success");
      } catch {
        showToast(`Enlace: ${resetUrl}`, "info");
      }
    }
    setGuardando(null);
  };

  const contactarWhatsApp = (ident) => {
    const digits = String(ident || "").replace(/\D/g, "");
    if (digits.length < 10) {
      showToast("Este identificador no parece un teléfono válido", "warning");
      return;
    }
    const msg = "Hola, recibimos tu solicitud para restablecer tu contraseña en FarmaCapital. ¿En qué podemos ayudarte?";
    window.open(`https://wa.me/52${digits}?text=${encodeURIComponent(msg)}`, "_blank", "noopener,noreferrer");
  };

  return (
    <Modal open={open} onClose={onClose} title="Solicitudes de contraseña">
      <div style={{ color: C.textMid, fontSize: 12, marginBottom: 12, lineHeight: 1.5 }}>
        Clientes que pidieron restablecer contraseña. Envía el enlace por WhatsApp (self-service), asigna una clave manualmente o marca como atendido.
        <div style={{ marginTop: 6, color: C.textDim, fontSize: 11 }}>{PASSWORD_RULES_TEXT}</div>
      </div>
      {error && (
        <div style={{ background: "#fef2f2", border: "1px solid #fecaca", borderRadius: 8, padding: 10, marginBottom: 12, fontSize: 12, color: "#b91c1c" }}>
          {error}
        </div>
      )}
      {loading ? (
        <SkeletonTable rows={2} cols={3} />
      ) : solicitudes.length === 0 ? (
        <div style={{ color: C.textMid, padding: 24, textAlign: "center" }}>✓ Sin solicitudes pendientes</div>
      ) : (
        solicitudes.map((req) => (
          <Box key={req.id} style={{ padding: 14, marginBottom: 10 }}>
            <div style={{ display: "flex", justifyContent: "space-between", gap: 10, flexWrap: "wrap", marginBottom: 10 }}>
              <div>
                <div style={{ color: C.text, fontWeight: 800, fontSize: 14 }}>{req.email_o_telefono || "—"}</div>
                <div style={{ color: C.textDim, fontSize: 11, marginTop: 4 }}>
                  {req.created_at ? new Date(req.created_at).toLocaleString("es-MX") : ""}
                </div>
              </div>
              <Tag col={C.amber} sm>Pendiente</Tag>
            </div>
            <div style={{ display: "flex", gap: 8, flexWrap: "wrap", alignItems: "center" }}>
              <button
                type="button"
                onClick={() => enviarLinkReset(req)}
                disabled={guardando === req.id}
                style={{ display: "flex", alignItems: "center", gap: 6, padding: "7px 12px", borderRadius: 8, border: "none", background: BRAND.primary, color: "#fff", fontWeight: 700, fontSize: 12, cursor: "pointer", opacity: guardando === req.id ? 0.6 : 1 }}
              >
                🔗 Enviar link reset
              </button>
              <button
                type="button"
                onClick={() => contactarWhatsApp(req.email_o_telefono)}
                style={{ display: "flex", alignItems: "center", gap: 6, padding: "7px 12px", borderRadius: 8, border: "none", background: "#25D366", color: "#fff", fontWeight: 700, fontSize: 12, cursor: "pointer" }}
              >
                💬 WhatsApp
              </button>
              <Inp
                type="password"
                placeholder={`Nueva contraseña (${PASSWORD_RULES_TEXT})`}
                value={nuevaClave[req.id] || ""}
                onChange={(e) => setNuevaClave((p) => ({ ...p, [req.id]: e.target.value }))}
                style={{ flex: "1 1 160px", minWidth: 140 }}
              />
              <Btn sm col={C.blue} dis={guardando === req.id} onClick={() => asignarClaveCliente(req)}>
                Asignar clave
              </Btn>
              <Btn sm ol col={C.green} dis={guardando === req.id} onClick={() => marcarAtendido(req.id)}>
                Marcar atendido
              </Btn>
            </div>
          </Box>
        ))
      )}
      <div style={{ display: "flex", justifyContent: "flex-end", marginTop: 12 }}>
        <Btn ol onClick={onClose}>Cerrar</Btn>
      </div>
    </Modal>
  );
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
    const tok = sessionStorage.getItem("farmacapital_session_token");
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
      const tok = sessionStorage.getItem("farmacapital_session_token");
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
      console.error("[FarmaCapital] Error crear usuario:", e);
      setError("Error al crear usuario: " + e.message);
    }
    setGuard(false);
  };

  const toggle = async (id,activo) => {
    const tok = sessionStorage.getItem("farmacapital_session_token");
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
      const tok = sessionStorage.getItem("farmacapital_session_token");
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
    const tok = sessionStorage.getItem("farmacapital_session_token");
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
    const tok = sessionStorage.getItem("farmacapital_session_token");
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
    const tok = sessionStorage.getItem("farmacapital_session_token");
    const { data: resp, error } = await supabase.rpc("admin_reset_password", {
      p_session_token: tok, p_usuario_id: u.id, p_nueva_password: nueva,
    });
    if (error || !resp?.success) { showToast("Error: "+(resp?.error||error?.message),"error"); return; }
    showToast(`✅ Contraseña de ${u.nombre} actualizada`,"success");
  };

  const eliminar = async (id,nombre) => {
    const sesion = JSON.parse(sessionStorage.getItem("farmacapital_admin_user")||"{}");
    if(sesion.id===id) { showToast("No puedes eliminar tu propio usuario.", "warning"); return; }
    showConfirm("Eliminar usuario",`¿Eliminar al usuario ${nombre}? Esta acción no se puede deshacer.`, async()=>{
      const tok = sessionStorage.getItem("farmacapital_session_token");
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
                <div style={{display:"grid", gridTemplateColumns:"repeat(auto-fit, minmax(min(100%, 200px), 1fr))", gap:6}}>
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
                  <div style={{display:"grid", gridTemplateColumns:"repeat(auto-fit, minmax(min(100%, 200px), 1fr))", gap:6}}>
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
function DevSupabaseEnvBanner() {
  if (!isSupabaseLocalMisconfigured) return null;
  return (
    <div
      role="status"
      style={{
        background: "#fff7ed",
        borderBottom: "1px solid #fdba74",
        padding: "10px 16px",
        fontSize: 13,
        color: "#9a3412",
        textAlign: "center",
        lineHeight: 1.45,
      }}
    >
      <strong>Desarrollo:</strong> falta configuración válida de Supabase en el archivo{" "}
      <code style={{ background: "#ffedd5", padding: "1px 6px", borderRadius: 4 }}>.env</code>{" "}
      (misma carpeta que <code style={{ background: "#ffedd5", padding: "1px 6px", borderRadius: 4 }}>package.json</code>):{" "}
      <code style={{ background: "#ffedd5", padding: "1px 6px", borderRadius: 4 }}>REACT_APP_SUPABASE_URL</code> + anon key desde{" "}
      <strong>Supabase → Settings → API</strong> (no uses <code style={{ background: "#ffedd5", padding: "1px 6px", borderRadius: 4 }}>replace_me</code>).{" "}
      Tras guardar, <strong>detené el servidor (Ctrl+C) y volvé a ejecutar npm start</strong> para que React lea las variables.{" "}
      Si ya están bien en <code style={{ background: "#ffedd5", padding: "1px 6px", borderRadius: 4 }}>.env</code> pero en la consola ves{" "}
      <code style={{ background: "#ffedd5", padding: "1px 6px", borderRadius: 4 }}>dev-bootstrap.invalid</code>, la terminal puede tener{" "}
      <code style={{ background: "#ffedd5", padding: "1px 6px", borderRadius: 4 }}>REACT_APP_SUPABASE_*</code> vacías exportadas (CRA no las pisa):{" "}
      <code style={{ background: "#ffedd5", padding: "1px 6px", borderRadius: 4 }}>unset REACT_APP_SUPABASE_URL REACT_APP_SUPABASE_ANON_KEY</code> y volvé a{" "}
      <code style={{ background: "#ffedd5", padding: "1px 6px", borderRadius: 4 }}>npm start</code>.
    </div>
  );
}

export default function FarmaCapitalAdmin(){
  const C = C_LIGHT;
  const [usuario,setUsuario] = useState(()=>{
    try{
      const u = sessionStorage.getItem("farmacapital_admin_user");
      if (!u) return null;
      const data = JSON.parse(u);
      // Verificar expiración (8 horas)
      if (data.loginTimestamp && Date.now() - data.loginTimestamp > 8*60*60*1000) {
        sessionStorage.removeItem("farmacapital_admin_user");
        sessionStorage.removeItem("farmacapital_session_token");
        return null;
      }
      return data;
    } catch{ return null; }
  });
  // Migración: ids antiguos "rea" y "lotes" ahora son tabs dentro de "inv".
  // También migramos "rep" al dashboard (legacy).
  function migratePageId(p) {
    if (!p || p === "rep") return { page: "dash", invTab: null, posTab: null };
    if (p === "rea")   return { page: "inv",  invTab: "reabasto", posTab: null };
    if (p === "lotes") return { page: "inv",  invTab: "lotes", posTab: null };
    if (p === "cons_cobro") return { page: "pos", invTab: null, posTab: "consultas" };
    return { page: p, invTab: null, posTab: null };
  }
  function applyPosTabHint(posTab) {
    if (!posTab) return;
    try {
      sessionStorage.setItem("farmacapital_pos_initial_tab", posTab);
    } catch (_) { /* noop */ }
  }
  const [page, setPage] = useState(() => {
    const fromUrl = adminPathnameToPageId(window.location.pathname);
    const raw0 = fromUrl || sessionStorage.getItem("farmacapital_active_page") || "dash";
    const { page: p, invTab, posTab } = migratePageId(raw0);
    applyPosTabHint(posTab);
    const pathHint = pathnameSuggestsPosTab(window.location.pathname);
    if (pathHint) applyPosTabHint(pathHint);
    if (invTab) {
      try {
        sessionStorage.setItem("farmacapital_inv_tab", invTab);
        sessionStorage.setItem("farmacapital_active_page", p);
      } catch (_) { /* noop */ }
    }
    return p;
  });
  const [invInitialTab, setInvInitialTab] = useState(() => {
    try { return sessionStorage.getItem("farmacapital_inv_tab") || null; } catch { return null; }
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
      sessionStorage.setItem("farmacapital_active_page", next);
      if (next === "inv" && tabHint) {
        sessionStorage.setItem("farmacapital_inv_tab", tabHint);
        setInvInitialTab(tabHint);
      } else if (next !== "inv") {
        // Al salir de inv, no borramos farmacapital_inv_tab — al volver recordará la última tab.
      }
    } catch (_) { /* noop */ }
    setPage(next);
    try {
      const url = pageIdToAdminPath(next);
      if (window.location.pathname !== url) {
        window.history.pushState({ farmacapitalPage: next }, "", url);
      }
    } catch (_) { /* noop */ }
    if (isMobileLayout) setMobileNavOpen(false);
  };

  useEffect(() => {
    if (!isMobileLayout) setMobileNavOpen(false);
  }, [isMobileLayout]);

  useEffect(() => {
    initBillingListeners();
  }, []);

  useEffect(() => {
    const onPop = () => {
      const id = adminPathnameToPageId(window.location.pathname);
      if (!id) return;
      const migrated = migratePageId(id);
      applyPosTabHint(migrated.posTab);
      const pathHint = pathnameSuggestsPosTab(window.location.pathname);
      if (pathHint) applyPosTabHint(pathHint);
      try {
        sessionStorage.setItem("farmacapital_active_page", migrated.page);
      } catch (_) { /* noop */ }
      setPage(migrated.page);
      if (migrated.page === "inv" && migrated.invTab) {
        try {
          sessionStorage.setItem("farmacapital_inv_tab", migrated.invTab);
        } catch (_) { /* noop */ }
        setInvInitialTab(migrated.invTab);
      }
    };
    window.addEventListener("popstate", onPop);
    return () => window.removeEventListener("popstate", onPop);
  }, []);
  const [notifs,setNotifs]         = useState([]);
  const [passwordResetOpen,setPasswordResetOpen] = useState(false);
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
          console.log("[FarmaCapital] SW registrado:", reg.scope);
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
        .catch(e=>console.warn("[FarmaCapital] SW error:", e));
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
        new Notification(titulo,{ body:cuerpo, icon:"/icons/farmacapital-192.png" });
      }
    }
  };

  // ── Verificar solicitudes de reset pendientes ──────────────
  useEffect(()=>{
    if(!usuario || usuario.rol !== "admin") return;
    const checkResets = async() => {
      const tok = sessionStorage.getItem("farmacapital_session_token");
      const { data } = await supabase.rpc("admin_contar_password_resets_pendientes", {
        p_session_token: tok,
      });
      const count = data || 0;
      if(count > 0) {
        addNotif(
          `🔑 ${count} solicitud${count>1?"es":""} de contraseña pendiente${count>1?"s":""}`,
          "Toca aquí para ver y atender la solicitud",
          "🔑","#f59e0b",
          "password_reset"
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
        addNotif(`📶 Conexión restaurada`,`Sincronizando ${pendientes} venta(s) pendiente(s)...`,"📶","#16a34a");
        const result = await sincronizarVentasPendientes(supabase, usuario);
        setVentasOff(0);
        if(result.ok > 0) showToast(`✅ ${result.ok} venta(s) sincronizada(s)`, "success");
        if(result.err > 0) showToast(`⚠️ ${result.err} venta(s) con error`, "warning");
      } else {
        addNotif("📶 Conexión restaurada","Sistema en línea","📶","#16a34a");
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
      const u = sessionStorage.getItem("farmacapital_admin_user");
      if (!u) return;
      try {
        const data = JSON.parse(u);
        if (data.loginTimestamp && Date.now() - data.loginTimestamp > 8*60*60*1000) {
          sessionStorage.removeItem("farmacapital_admin_user");
          sessionStorage.removeItem("farmacapital_session_token");
          setUsuario(null);
          showToast("Tu sesión expiró. Por favor inicia sesión de nuevo.", "warning");
        }
      } catch(e) {
        sessionStorage.removeItem("farmacapital_admin_user");
        sessionStorage.removeItem("farmacapital_session_token");
        setUsuario(null);
      }
    };
    const interval = setInterval(check, 60*1000); // cada minuto
    return () => clearInterval(interval);
  },[]);
  const notifId = useRef(0);

  const addNotif = useCallback((titulo,mensaje,icon="🔔",col="#0D1B2A",action=null)=>{
    const id=++notifId.current;
    const hora=new Date().toLocaleTimeString("es-MX",{hour:"2-digit",minute:"2-digit"});
    setNotifs(p=>[{id,titulo,mensaje,icon,col,hora,action},...p].slice(0,5));
    setTimeout(()=>setNotifs(p=>p.filter(n=>n.id!==id)),8000);
  },[]);

  const dismissNotif = useCallback(id=>setNotifs(p=>p.filter(n=>n.id!==id)),[]);

  const handleNotifAction = useCallback((n)=>{
    if(n.action==="password_reset") setPasswordResetOpen(true);
    setNotifs(p=>p.filter(x=>x.id!==n.id));
  },[]);

  useEffect(()=>{
    if(!usuario) return;
    const ch=supabase.channel("farmacapital-rt")
      .on("postgres_changes",{event:"INSERT",schema:"public",table:"password_reset_requests"},
        payload=>{
          const req = payload.new;
          addNotif(
            "🔑 Solicitud de contraseña",
            `Usuario: ${req.email_o_telefono} — toca para atender`,
            "🔑","#f59e0b",
            "password_reset"
          );
          showToast(`🔑 Solicitud de reset: ${req.email_o_telefono}`,"warning");
        })
      .on("postgres_changes",{event:"INSERT",schema:"public",table:"pedidos"},
        pl=>{
          const row = pl.new;
          if (!row || row.estado !== "pendiente" || !esPedidoTiendaWebPendiente(row)) return;
          addNotif("🛒 Nuevo pedido online",`Pedido #${row.id} · $${parseFloat(row.total||0).toFixed(2)}`,"🛒","#0D1B2A");
          pushNotif("🛒 Nuevo pedido online",`Pedido #${row.id} · $${parseFloat(row.total||0).toFixed(2)} · Pendiente de surtir`,"/admin");
        })
      .on("postgres_changes",{event:"INSERT",schema:"public",table:"citas"},
        pl=>{ addNotif("📅 Nueva cita",`${pl.new?.nombre||"Paciente"} · ${pl.new?.fecha||""} ${pl.new?.hora||""}`,"📅","#7c3aed");
          pushNotif("📅 Nueva cita agendada",`${pl.new?.nombre||"Paciente"} · ${pl.new?.fecha||""} ${pl.new?.hora||""}`,"/admin"); })
      .on("postgres_changes",{event:"UPDATE",schema:"public",table:"pedidos"},
        pl=>{ if(pl.new?.estado==="listo") addNotif("✅ Pedido listo",`Pedido #${pl.new.id} listo para entrega`,"✅","#16a34a"); })
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
      const tok = sessionStorage.getItem("farmacapital_session_token");
      const { data: snap } = tok
        ? await supabase.rpc("empleado_admin_alertas_snapshot", { p_session_token: tok, p_hoy: hoy })
        : { data: null };
      const pendPedidos = snap?.pend_pedidos || [];
      setAlr({
        stock: typeof snap?.stock_bajo === "number" ? snap.stock_bajo : 0,
        pedidos: pendPedidos.filter(esPedidoTiendaWebPendiente).length,
        citas: typeof snap?.citas_web_hoy === "number" ? snap.citas_web_hoy : 0,
      });
    };
    cargar();
    const interval = setInterval(cargar, 30000); // cada 30 seg
    return ()=>clearInterval(interval);
  },[usuario]);

  // Admin ya no usa el id cons_dr en menú; deep links y sesiones viejas se redirigen a agenda.
  useEffect(() => {
    if (!usuario || usuario.rol !== "admin") return;
    if (page !== "cons_dr") return;
    setPageAndSave("agenda");
  }, [usuario, page]);

  // Página inicial: deep link /admin/consultorio, etc. tiene prioridad; si no, default por rol.
  useEffect(() => {
    if (!usuario) return;
    const fromUrl = adminPathnameToPageId(window.location.pathname);
    if (fromUrl) {
      const migrated = migratePageId(fromUrl);
      let next = migrated.page;
      if (usuario.rol === "admin" && next === "cons_dr") next = "agenda";
      applyPosTabHint(migrated.posTab);
      const pathHint = pathnameSuggestsPosTab(window.location.pathname);
      if (pathHint) applyPosTabHint(pathHint);
      try {
        sessionStorage.setItem("farmacapital_active_page", next);
        if (next === "inv" && migrated.invTab) {
          sessionStorage.setItem("farmacapital_inv_tab", migrated.invTab);
          setInvInitialTab(migrated.invTab);
        }
      } catch (_) { /* noop */ }
      setPage(next);
      try {
        const url = pageIdToAdminPath(next);
        if (window.location.pathname !== url) {
          window.history.replaceState({ farmacapitalPage: next }, "", url);
        }
      } catch (_) { /* noop */ }
      return;
    }
    if (usuario.rol === "vendedor") setPage("midia");
    else if (usuario.rol === "doctora") setPage("cons_dr");
    else setPage("dash");
  }, [usuario]);

  // Sesiones antiguas o /admin/consultorio: redirigir a agenda médica.
  useEffect(() => {
    if (!usuario || usuario.rol !== "doctora") return;
    if (page === "cons" || page === "pwa") setPageAndSave("cons_dr");
  }, [usuario, page]);

  const logout = async () => {
    const tok = sessionStorage.getItem("farmacapital_session_token");
    if (tok) {
      try { await supabase.rpc("logout_empleado", { p_token: tok }); } catch(e) {}
    }
    sessionStorage.removeItem("farmacapital_session_token");
    sessionStorage.removeItem("farmacapital_admin_user");
    localStorage.removeItem("farmacapital_pos_favs");
    localStorage.removeItem("farmacapital_busqs");
    localStorage.removeItem("farmacapital_last_login_"+usuario?.id);
    setUsuario(null);
    showToast("Sesión cerrada correctamente","info");
  };

  if (!usuario) {
    return (
      <>
        <DevSupabaseEnvBanner />
        <LoginScreen onLogin={u=>{ sessionStorage.setItem("farmacapital_admin_user",JSON.stringify(u)); setUsuario(u); }}/>
      </>
    );
  }

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
      case "pos":
        if (!canAccessRoute(usuario.rol, "/pos")) {
          return <div>No autorizado</div>;
        }
        return <POS negocio={neg} usuario={usuario} initialTab="venta" onNavigate={setPageAndSave}/>;
      case "cons":      return <ConsultorioModule usuario={usuario}/>;
      case "config_cons": return <ConfigConsultorioModule />;
      case "cons_cobro":return <POS negocio={neg} usuario={usuario} initialTab="consultas" onNavigate={setPageAndSave}/>;
      case "agenda":
      case "cons_dr":
        return <AgendaConsultasModule usuario={usuario} onNavigate={setPageAndSave} />;
      case "exp_dr":    return <ExpedientesDoctora />;
      case "trans":     return <TransaccionesTab usuario={usuario} showConfirm={showConfirm} />;
      case "ped_online":
        return <POS negocio={neg} usuario={usuario} initialTab="online" onNavigate={setPageAndSave} />;
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
    <NotificacionesToast notifs={notifs} onDismiss={dismissNotif} onAction={handleNotifAction}/>
    <PasswordResetSolicitudesModal open={passwordResetOpen} onClose={()=>setPasswordResetOpen(false)}/>
    <ToastProvider/>
    <ConfirmDialog
      open={confirmDlg.open}
      titulo={confirmDlg.titulo}
      mensaje={confirmDlg.mensaje}
      danger={confirmDlg.danger}
      onConfirm={()=>{ confirmDlg.onConfirm?.(); setConfirmDlg(p=>({...p,open:false})); }}
      onCancel={()=>setConfirmDlg(p=>({...p,open:false}))}
    />
    <div className="farmacapital-admin-root" style={{background:C.bg,fontFamily:"'Plus Jakarta Sans',sans-serif",transition:"background .3s,color .3s",color:C.text,overflowX:"hidden",touchAction:"pan-y"}}>
      <style>{`@import url('https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap');
*{box-sizing:border-box;margin:0;padding:0}
html,body,#root{height:100%;-webkit-text-size-adjust:100%;text-size-adjust:100%}
body{
  overflow-x:hidden;
  overflow-y:auto;
  touch-action:pan-y;
  overscroll-behavior-y:auto;
}
.farmacapital-admin-root{min-height:100vh;min-height:100dvh}
.farmacapital-admin-main{
  min-height:100vh;min-height:100dvh;box-sizing:border-box;
  overflow-wrap:break-word;word-wrap:break-word;
  touch-action:pan-y;
  -webkit-overflow-scrolling:touch;
}
.farmacapital-admin-sidebar{
  box-sizing:border-box;
  height:100vh;
  max-height:100dvh;
  overflow:hidden;
  padding-bottom:env(safe-area-inset-bottom,0px);
  touch-action:pan-y;
}
@media (max-width: 1100px){
  /* Fase 3: evitar shell rígido en móvil (viewport manda). */
  .farmacapital-admin-root,
  .farmacapital-admin-main{
    height:auto !important;
    max-height:none !important;
    overflow-y:visible !important;
  }
}`}</style>
      <DevSupabaseEnvBanner />
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
            position:"fixed",
            top:"calc(12px + env(safe-area-inset-top, 0px))",
            left:"calc(12px + env(safe-area-inset-left, 0px))",
            zIndex:10,
            width:48,height:48,borderRadius:12,
            border:`1px solid ${C.border}`,background:C.card,
            boxShadow:"0 4px 20px rgba(0,0,0,.08)",cursor:"pointer",
            fontSize:20,lineHeight:1,display:"flex",alignItems:"center",justifyContent:"center",
            color:C.text,
            pointerEvents:"auto",
            touchAction:"manipulation",
          }}
        >
          ☰
        </button>
      )}
      <AdminNavSidebar
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
      <main className="farmacapital-admin-main" style={{
        marginLeft:isMobileLayout?0:220,
        padding:isMobileLayout
          ? "calc(56px + env(safe-area-inset-top, 0px)) max(16px, env(safe-area-inset-right, 0px)) calc(20px + env(safe-area-inset-bottom, 0px)) max(16px, env(safe-area-inset-left, 0px))"
          : "clamp(16px, 3vw, 28px)",
        /* En escritorio: NO usar width:100% con marginLeft (provoca overflow horizontal al redimensionar). */
        ...(isMobileLayout
          ? { width: "100%", maxWidth: "100%" }
          : { width: "auto", maxWidth: "none", minWidth: 0 }),
        overflowX:"hidden",
        touchAction:"pan-y",
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