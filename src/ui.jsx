import React, { useRef, useState, useLayoutEffect, useCallback } from "react";
// FARMACAPITAL — Componentes UI base
import { C_LIGHT, BRAND } from "./constants";
import { RADIO, SOMBRA } from "./theme/tokens";
import { logoFullStyle, logoIconStyle, logoFullSrc, logoFullSrcSet, logoAspect } from "./brand";
import { useLogoOnDark } from "./hooks/useLogoOnDark";
import { productMatchesSearchQuery, tiendaProductMatchesBusqueda, tiendaSearchRelevanceRank, inventarioProductMatchesBusqueda, inventarioSearchRelevanceRank } from "./utils/fuzzySearch";
import { unlockInputForTouchKeyboard, lockInputAfterTouchKeyboard, armInputForTouchKeyboard } from "./utils/touchKeyboard";

export function Logo({ size = 36, showText = true, light, sub = "", iconOnly = false, variant = "default", auto = true }) {
  const autoDetect = auto && light === undefined;
  const { ref, onDark } = useLogoOnDark(autoDetect);
  const useLight = light ?? (auto ? onDark : false);
  const fsSub = Math.round(size * 0.22);
  const subColor = useLight ? "rgba(255,255,255,0.65)" : BRAND.primary;
  const useIcon = iconOnly || !showText;
  const showSub = Boolean(sub) && variant !== "admin";

  const img = (
    <img
      src={logoFullSrc({ iconOnly: useIcon, variant, light: useLight })}
      srcSet={useIcon ? undefined : logoFullSrcSet({ variant, light: useLight })}
      sizes={useIcon ? undefined : `${Math.round(size * logoAspect(variant))}px`}
      alt="FarmaCapital"
      decoding="async"
      draggable={false}
      style={useIcon ? logoIconStyle(size) : logoFullStyle(size, { variant })}
    />
  );

  const inner = (
    <>
      {img}
      {showSub && (
        <div style={{ color: subColor, fontSize: fsSub, letterSpacing: "2px", textTransform: "uppercase", marginTop: 4, fontWeight: 500 }}>
          {sub}
        </div>
      )}
    </>
  );

  return (
    <div ref={ref} style={{ display: "flex", alignItems: "center", gap: 8, minWidth: 0 }}>
      <div style={{ display: "flex", flexDirection: "column", lineHeight: 1, minWidth: 0, alignItems: variant === "admin" ? "center" : undefined }}>
        {inner}
      </div>
    </div>
  );
}

/** Pantalla de carga — mismo tratamiento que header (azul + logo light) */
export function BrandSplash({ subtitle = "Farmacia & Salud", variant = "default", size = 56 }) {
  return (
    <div
      data-brand-surface="dark"
      style={{
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        minHeight: "100dvh",
        background: BRAND.primary,
        flexDirection: "column",
        gap: 20,
        padding: 24,
      }}
    >
      <Logo size={size} variant={variant} />
      {subtitle ? (
        <div style={{ color: "rgba(255,255,255,0.72)", fontSize: 12, letterSpacing: 2, textTransform: "uppercase", fontWeight: 600 }}>
          {subtitle}
        </div>
      ) : null}
      <div style={{ width: 48, height: 3, background: "rgba(255,255,255,0.25)", borderRadius: 2, overflow: "hidden" }}>
        <div
          style={{
            height: "100%",
            width: "40%",
            background: "#ffffff",
            borderRadius: 2,
            animation: "farmacapital-splash-bar 1.2s ease-in-out infinite",
          }}
        />
      </div>
      <style>{`@keyframes farmacapital-splash-bar { 0%{transform:translateX(-120%)} 100%{transform:translateX(320%)} }`}</style>
    </div>
  );
}

export function Box({children,style,onClick,ac,className}){
  const C = C_LIGHT;
  const useCssHover = className && String(className).includes("farmacapital-product-card");
  return(
  <div
    className={className||undefined}
    onClick={onClick}
    style={{background:C.card,borderRadius:RADIO.md,border:`1px solid ${ac?ac+"40":C.border}`,boxShadow:SOMBRA.sm,transition:"border-color .2s,box-shadow .2s",cursor:onClick?"pointer":"default",...style}}
    onMouseEnter={!useCssHover&&onClick?(e=>{ e.currentTarget.style.borderColor=ac||C.borderHi; }):undefined}
    onMouseLeave={!useCssHover&&onClick?(e=>{ e.currentTarget.style.borderColor=ac?ac+"40":C.border; }):undefined}
  >
    {children}
  </div>
  );
};

export function Tag({col,children,sm}){
  const C = C_LIGHT;
  return(

  <span style={{background:col+"15",color:col,border:`1px solid ${col}30`,borderRadius:RADIO.pill,padding:sm?"2px 8px":"3px 11px",fontSize:sm?9:11,fontWeight:700,letterSpacing:.5,textTransform:"uppercase",whiteSpace:"nowrap",display:"inline-block"}}>{children}</span>

  );
};

export function Btn({children,onClick,col,sm,ol,dis,full,style,type="button"}){
  const C = C_LIGHT;
  return(

  <button type={type} onClick={onClick} disabled={dis} style={{padding:sm?"7px 16px":"10px 22px",borderRadius:RADIO.pill,border:`1px solid ${ol?(col||BRAND.primary):"transparent"}`,background:ol?"transparent":dis?C.border:(col||BRAND.primary),color:ol?(col||BRAND.primary):dis?C.textMid:C.card,fontWeight:700,fontSize:sm?12:14,cursor:dis?"not-allowed":"pointer",fontFamily:"var(--fc-body)",opacity:dis?.5:1,width:full?"100%":undefined,minHeight:sm?36:40,transition:"opacity .15s",...style}}>{children}</button>

  );
};

export function Inp({value,onChange,placeholder,style,type,onKeyDown,disabled,name,autoComplete,className="",invalid=false}){
  const C = C_LIGHT;
  return(

  <input
    className={`farmacapital-field-input ${className}`.trim()}
    value={value}
    onChange={onChange}
    disabled={disabled}
    placeholder={placeholder}
    type={type||"text"}
    onKeyDown={onKeyDown}
    name={name}
    autoComplete={autoComplete}
    style={{
      background:"#ffffff",
      border:`1px solid ${invalid?C.red:C.border}`,
      borderRadius:RADIO.sm,
      color:C.text,
      WebkitTextFillColor:C.text,
      caretColor:C.text,
      colorScheme:"light",
      padding:"10px 14px",
      fontSize:16,
      lineHeight:1.25,
      outline:"none",
      fontFamily:"var(--fc-body)",
      opacity:disabled?0.6:1,
      cursor:disabled?"not-allowed":"text",
      minHeight:44,
      boxSizing:"border-box",
      width:"100%",
      touchAction:"manipulation",
      ...style,
    }}
    onFocus={e=>{e.target.style.borderColor=invalid?C.red:C.blue;e.target.style.boxShadow="0 0 0 3px "+C.blueDim;}}
    onBlur={e=>{e.target.style.borderColor=invalid?C.red:C.border;e.target.style.boxShadow="none";}}
  />

  );
};

/** Fila de KPIs: cada tarjeta tiene ancho mínimo y el monto no se parte. */
export const KPI_ROW = {
  display: "grid",
  gridTemplateColumns: "repeat(auto-fit, minmax(min(100%, 168px), 1fr))",
  gap: 12,
  marginBottom: 20,
  alignItems: "stretch",
};

/** Baja el tamaño de letra hasta que el valor quepa en una sola línea. */
function FitValue({ children, color, maxPx = 22, minPx = 13 }) {
  const wrapRef = useRef(null);
  const textRef = useRef(null);
  const [px, setPx] = useState(maxPx);

  const recalc = useCallback(() => {
    const wrap = wrapRef.current;
    const text = textRef.current;
    if (!wrap || !text) return;
    const avail = wrap.clientWidth;
    if (avail <= 0) return;
    let lo = minPx;
    let hi = maxPx;
    let best = minPx;
    while (lo <= hi) {
      const mid = (lo + hi) >> 1;
      text.style.fontSize = `${mid}px`;
      if (text.scrollWidth <= avail) {
        best = mid;
        lo = mid + 1;
      } else {
        hi = mid - 1;
      }
    }
    text.style.fontSize = `${best}px`;
    setPx((prev) => (prev === best ? prev : best));
  }, [children, maxPx, minPx]);

  useLayoutEffect(() => {
    recalc();
    const wrap = wrapRef.current;
    if (!wrap || typeof ResizeObserver === "undefined") return undefined;
    const ro = new ResizeObserver(recalc);
    ro.observe(wrap);
    return () => ro.disconnect();
  }, [recalc]);

  return (
    <div ref={wrapRef} style={{ width: "100%", minWidth: 0, overflow: "hidden" }}>
      <div
        ref={textRef}
        title={typeof children === "string" || typeof children === "number" ? String(children) : undefined}
        style={{
          color,
          fontSize: px,
          fontWeight: 800,
          lineHeight: 1.15,
          whiteSpace: "nowrap",
          fontVariantNumeric: "tabular-nums",
        }}
      >
        {children}
      </div>
    </div>
  );
}

export function KPI({label,value,sub,col,icon,trend}){
  const C = C_LIGHT;
  return(

  <Box style={{padding:"16px 16px 14px",minWidth:0,width:"100%",boxSizing:"border-box"}}>
    <div style={{display:"flex",justifyContent:"space-between",alignItems:"flex-start",gap:8}}>
      <div style={{flex:1,minWidth:0}}>
        <div style={{color:C.textDim,fontSize:9,letterSpacing:1.2,textTransform:"uppercase",marginBottom:8,lineHeight:1.35,display:"-webkit-box",WebkitLineClamp:2,WebkitBoxOrient:"vertical",overflow:"hidden"}}>{label}</div>
        <FitValue color={col||C.text}>{value}</FitValue>
        {sub&&<div style={{color:C.textMid,fontSize:11,marginTop:6,lineHeight:1.35}}>{sub}</div>}
        {trend!==undefined&&<div style={{color:trend>=0?C.green:C.red,fontSize:11,marginTop:4,fontWeight:700}}>{trend>=0?"▲":"▼"} {Math.abs(trend)}% vs ayer</div>}
      </div>
      {icon ? <div style={{fontSize:18,opacity:.45,flexShrink:0,lineHeight:1}}>{icon}</div> : null}
    </div>
  </Box>

  );
};

export function Modal({open,onClose,title,children,ac,closeOnBackdrop=true}){
  const C = C_LIGHT;
  const panelRef = useRef(null);
  const onCloseRef = useRef(onClose);
  const titleId = React.useId();
  onCloseRef.current = onClose;

  React.useEffect(()=>{
    if(!open) return undefined;
    const prev = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return ()=>{ document.body.style.overflow = prev || "auto"; };
  },[open]);

  React.useEffect(()=>{
    if(!open) return undefined;
    const onKey = (e)=>{
      if(e.key==="Escape"){ e.preventDefault(); onCloseRef.current?.(); }
    };
    document.addEventListener("keydown", onKey);
    const t = setTimeout(()=>{
      const panel = panelRef.current;
      if(!panel) return;
      const active = document.activeElement;
      if(active && panel.contains(active) && active !== panel) return;
      const firstField = panel.querySelector("input:not([type=hidden]):not([disabled]), select:not([disabled]), textarea:not([disabled])");
      (firstField || panel).focus?.();
    }, 0);
    return ()=>{ document.removeEventListener("keydown", onKey); clearTimeout(t); };
  },[open]);

  if(!open) return null;
  return(
    <div
      role="presentation"
      style={{position:"fixed",inset:0,background:"rgba(0,0,0,.45)",zIndex:1000,display:"flex",alignItems:"center",justifyContent:"center",padding:"max(12px, env(safe-area-inset-top, 0px)) max(12px, env(safe-area-inset-right, 0px)) max(12px, env(safe-area-inset-bottom, 0px)) max(12px, env(safe-area-inset-left, 0px))",boxSizing:"border-box",overscrollBehavior:"contain"}}
      onClick={closeOnBackdrop ? onClose : undefined}
    >
      <div
        ref={panelRef}
        role="dialog"
        aria-modal="true"
        aria-labelledby={title ? titleId : undefined}
        tabIndex={-1}
        style={{background:C.card,borderRadius:16,padding:"clamp(18px, 4vw, 28px)",minWidth:0,maxWidth:560,width:"min(560px, 100%)",maxHeight:"min(90dvh, 92vh)",overflowY:"auto",WebkitOverflowScrolling:"touch",overscrollBehaviorY:"contain",boxShadow:"0 8px 40px rgba(0,0,0,.18)",border:`1px solid ${C.border}`,outline:"none"}}
        onClick={e=>e.stopPropagation()}
      >
        <div style={{display:"flex",alignItems:"center",justifyContent:"space-between",marginBottom:18}}>
          <div id={titleId} style={{fontWeight:800,fontSize:16,color:C.text}}>{title}</div>
          {!ac&&<button type="button" data-modal-close onClick={onClose} aria-label="Cerrar" style={{background:"none",border:"none",fontSize:20,cursor:"pointer",color:C.textMid,width:36,height:36,borderRadius:8,display:"inline-flex",alignItems:"center",justifyContent:"center",flexShrink:0,lineHeight:1}}>✕</button>}
        </div>
        {children}
      </div>
    </div>
  );
}

export function NotificacionesToast({ notifs, onDismiss, onAction }) {
  const C = C_LIGHT;
  if(!notifs?.length) return null;
  return (
    <div style={{position:"fixed",top:"max(12px, env(safe-area-inset-top, 0px))",left:12,right:12,zIndex:9999,display:"flex",flexDirection:"column",gap:8,alignItems:"stretch",maxWidth:400,margin:"0 auto",pointerEvents:"none",boxSizing:"border-box"}}>
      {notifs.map(n=>(
        <div
          key={n.id}
          role={n.action ? "button" : undefined}
          tabIndex={n.action ? 0 : undefined}
          onClick={()=>{ if(n.action) onAction?.(n); }}
          onKeyDown={(e)=>{ if(n.action && (e.key==="Enter"||e.key===" ")){ e.preventDefault(); onAction?.(n); } }}
          style={{
            background:C.card,borderRadius:12,padding:"12px 16px",boxShadow:"0 8px 32px rgba(15,45,110,.18)",
            border:`2px solid ${n.col||"#0D1B2A"}`,display:"flex",alignItems:"flex-start",gap:10,
            pointerEvents:"auto",cursor:n.action?"pointer":"default",
          }}
        >
          <span style={{fontSize:20,flexShrink:0}}>{n.icon||"🔔"}</span>
          <div style={{flex:1}}>
            <div style={{color:C.text,fontWeight:700,fontSize:13}}>{n.titulo}</div>
            <div style={{color:C.textMid,fontSize:12,marginTop:2}}>{n.mensaje}</div>
            <div style={{color:"#94a3b8",fontSize:10,marginTop:4}}>{n.hora}</div>
          </div>
          <button onClick={(e)=>{ e.stopPropagation(); onDismiss(n.id); }} style={{background:"none",border:"none",color:"#94a3b8",cursor:"pointer",fontSize:16,padding:0,flexShrink:0}}>✕</button>
        </div>
      ))}
    </div>
  );
}

// ── Sistema de Toast global ───────────────────────────────────
let _toastFn = null;
export const registerToast = fn => { _toastFn = fn; };
export const showToast = (msg, tipo="info") => {
  if (_toastFn) _toastFn(msg, tipo);
  else console.warn("Toast:", tipo, msg);
};

export function ToastProvider() {
  const C = C_LIGHT;
  const [toasts, setToasts] = React.useState([]);
  React.useEffect(()=>{
    registerToast((msg, tipo)=>{
      const id = Date.now()+Math.random();
      setToasts(p=>[...p,{id,msg,tipo}].slice(-5));
      setTimeout(()=>setToasts(p=>p.filter(t=>t.id!==id)), 4000);
    });
  },[]);
  const cols = { success:C.green, error:C.red, warning:C.amber, info:C.blue };
  const icons = { success:"✅", error:"❌", warning:"⚠️", info:"ℹ️" };
  const toastText = (msg, tipo) => {
    if (typeof msg !== "string") return msg;
    const lead = icons[tipo] || "";
    if (lead && msg.startsWith(lead)) return msg.slice(lead.length).trimStart();
    return msg;
  };
  if (!toasts.length) return null;
  return (
    <div style={{position:"fixed",bottom:"max(16px, env(safe-area-inset-bottom, 0px))",left:12,right:12,zIndex:9998,display:"flex",flexDirection:"column",gap:8,alignItems:"stretch",maxWidth:400,margin:"0 auto",pointerEvents:"none",boxSizing:"border-box"}}>
      {toasts.map(t=>(
        <div key={t.id} style={{
          background:C.card,borderRadius:12,padding:"12px 16px",
          boxShadow:"0 8px 32px rgba(0,0,0,.15)",
          border:`2px solid ${cols[t.tipo]||C.blue}`,
          display:"flex",alignItems:"center",gap:10,
          animation:"slideUp .3s ease",
          pointerEvents:"auto",
        }}>
          <span style={{fontSize:18,flexShrink:0}}>{icons[t.tipo]||"ℹ️"}</span>
          <span style={{color:C.text,fontSize:13,fontWeight:600,flex:1}}>{toastText(t.msg, t.tipo)}</span>
        </div>
      ))}
    </div>
  );
}

// ── Confirm dialog elegante ───────────────────────────────────
export function ConfirmDialog({open,titulo,mensaje,onConfirm,onCancel,danger=false}){
  const C = C_LIGHT;
  React.useEffect(()=>{
    if(!open) return undefined;
    const prev = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return ()=>{ document.body.style.overflow = prev || "auto"; };
  },[open]);
  if(!open) return null;
  return(
    <div style={{position:"fixed",inset:0,background:"rgba(15,23,42,.5)",backdropFilter:"blur(4px)",zIndex:9997,display:"flex",alignItems:"center",justifyContent:"center",padding:"max(16px, env(safe-area-inset-top, 0px)) max(16px, env(safe-area-inset-right, 0px)) max(16px, env(safe-area-inset-bottom, 0px)) max(16px, env(safe-area-inset-left, 0px))",boxSizing:"border-box",overscrollBehavior:"contain"}}>
      <div style={{background:C.card,borderRadius:14,padding:"clamp(20px, 5vw, 28px)",width:"min(400px, 100%)",maxHeight:"min(90dvh, 92vh)",overflowY:"auto",WebkitOverflowScrolling:"touch",overscrollBehaviorY:"contain",boxShadow:"0 20px 60px rgba(0,0,0,.2)"}}>
        <div style={{fontSize:32,textAlign:"center",marginBottom:12}}>{danger?"⚠️":"❓"}</div>
        <div style={{color:C.text,fontWeight:800,fontSize:16,textAlign:"center",marginBottom:8}}>{titulo}</div>
        <div style={{color:C.textMid,fontSize:13,textAlign:"center",marginBottom:24,lineHeight:1.6}}>{mensaje}</div>
        <div className="farmacapital-confirm-actions" style={{display:"flex",gap:10,justifyContent:"center",flexWrap:"wrap"}}>
          <button type="button" onClick={onCancel} style={{padding:"10px 20px",borderRadius:8,border:`1px solid ${C.border}`,background:"transparent",color:C.textMid,fontWeight:700,fontSize:14,cursor:"pointer",minHeight:44,flex:"1 1 140px"}}>Cancelar</button>
          <button type="button" onClick={onConfirm} style={{padding:"10px 20px",borderRadius:8,border:"none",background:danger?C.red:C.green,color:C.card,fontWeight:700,fontSize:14,cursor:"pointer",minHeight:44,flex:"1 1 140px"}}>{danger?"Eliminar":"Confirmar"}</button>
        </div>
      </div>
    </div>
  );
}

// ── Skeleton Loaders ──────────────────────────────────────────
export function SkeletonRow({ cols=4, height=40 }) {
  const C = C_LIGHT;
  return (
    <tr>
      {Array(cols).fill(0).map((_,i)=>(
        <td key={i} style={{padding:"10px 14px",borderBottom:"1px solid #e2e8f0"}}>
          <div style={{height:height*0.4,borderRadius:6,background:"linear-gradient(90deg,#f0f4f9 25%,#e2e8f0 50%,#f0f4f9 75%)",backgroundSize:"200% 100%",animation:"shimmer 1.5s infinite"}}/>
        </td>
      ))}
      <style>{`@keyframes shimmer{0%{background-position:200% 0}100%{background-position:-200% 0}}`}</style>
    </tr>
  );
}

export function SkeletonCard({ height=80, style={} }) {
  const C = C_LIGHT;
  return (
    <div style={{borderRadius:12,background:"linear-gradient(90deg,#f0f4f9 25%,#e2e8f0 50%,#f0f4f9 75%)",backgroundSize:"200% 100%",animation:"shimmer 1.5s infinite",height,...style}}>
      <style>{`@keyframes shimmer{0%{background-position:200% 0}100%{background-position:-200% 0}}`}</style>
    </div>
  );
}

/**
 * Contenedor con scroll horizontal sincronizado: barra arriba y abajo (misma posición).
 */
export function HorizontalScrollSync({ children, style = {}, topBarHeight = 12, bodyMaxHeight, ...rest }) {
  const C = C_LIGHT;
  const topRef = useRef(null);
  const bottomRef = useRef(null);
  const innerRef = useRef(null);
  const [trackW, setTrackW] = useState(0);
  const syncing = useRef(false);

  const measure = useCallback(() => {
    const bottom = bottomRef.current;
    const inner = innerRef.current;
    if (!bottom) return;
    const w = inner ? Math.max(inner.scrollWidth, inner.offsetWidth) : bottom.scrollWidth;
    setTrackW(w);
  }, []);

  useLayoutEffect(() => {
    measure();
    const t = requestAnimationFrame(measure);
    return () => cancelAnimationFrame(t);
  }, [measure, children]);

  useLayoutEffect(() => {
    const inner = innerRef.current;
    if (!inner || typeof ResizeObserver === "undefined") return;
    const ro = new ResizeObserver(() => measure());
    ro.observe(inner);
    return () => ro.disconnect();
  }, [measure]);

  useLayoutEffect(() => {
    const onResize = () => measure();
    window.addEventListener("resize", onResize);
    return () => window.removeEventListener("resize", onResize);
  }, [measure]);

  const onTopScroll = (e) => {
    if (syncing.current) return;
    syncing.current = true;
    const left = e.target.scrollLeft;
    if (bottomRef.current) bottomRef.current.scrollLeft = left;
    requestAnimationFrame(() => {
      syncing.current = false;
    });
  };
  const onBottomScroll = (e) => {
    if (syncing.current) return;
    syncing.current = true;
    const left = e.target.scrollLeft;
    if (topRef.current) topRef.current.scrollLeft = left;
    requestAnimationFrame(() => {
      syncing.current = false;
    });
  };

  return (
    <div {...rest} style={{ borderRadius: 12, border: `1px solid ${C.border}`, overflow: "hidden", ...style }}>
      <div
        ref={topRef}
        onScroll={onTopScroll}
        title="Desplazar tabla horizontalmente"
        style={{
          overflowX: "auto",
          overflowY: "hidden",
          height: topBarHeight + 6,
          maxHeight: topBarHeight + 6,
          flexShrink: 0,
          borderBottom: `1px solid ${C.border}`,
          background: C.cardDark,
          WebkitOverflowScrolling: "touch",
          scrollbarWidth: "thin",
        }}
      >
        <div style={{ width: trackW > 0 ? trackW : "100%", height: 1, pointerEvents: "none" }} aria-hidden />
      </div>
      <div
        ref={bottomRef}
        onScroll={onBottomScroll}
        style={{
          overflowX: "auto",
          overflowY: bodyMaxHeight ? "auto" : "hidden",
          maxHeight: bodyMaxHeight,
          WebkitOverflowScrolling: "touch",
          scrollbarWidth: "thin",
        }}
      >
        <div ref={innerRef} style={{ minWidth: "min-content" }}>
          {children}
        </div>
      </div>
    </div>
  );
}

export function SkeletonTable({ rows=5, cols=5 }) {
  const C = C_LIGHT;
  return (
    <div style={{borderRadius:12,border:"1px solid #e2e8f0",overflow:"hidden"}}>
      <table style={{width:"100%",borderCollapse:"collapse"}}>
        <thead>
          <tr style={{background:"#f8fafc"}}>
            {Array(cols).fill(0).map((_,i)=>(
              <th key={i} style={{padding:"10px 14px",borderBottom:"1px solid #e2e8f0"}}>
                <div style={{height:12,borderRadius:4,background:"#e2e8f0",width:`${60+Math.random()*30}%`}}/>
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {Array(rows).fill(0).map((_,i)=><SkeletonRow key={i} cols={cols}/>)}
        </tbody>
      </table>
    </div>
  );
}

export function SkeletonKPIs({ count=4 }) {
  const C = C_LIGHT;
  return (
    <div style={KPI_ROW}>
      {Array(count).fill(0).map((_,i)=>(
        <div key={i} style={{minWidth:0,borderRadius:14,border:"1px solid #e2e8f0",padding:"16px",background:C.card}}>
          <div style={{height:10,borderRadius:4,background:"linear-gradient(90deg,#f0f4f9 25%,#e2e8f0 50%,#f0f4f9 75%)",backgroundSize:"200% 100%",animation:"shimmer 1.5s infinite",width:"60%",marginBottom:12}}/>
          <div style={{height:24,borderRadius:4,background:"linear-gradient(90deg,#f0f4f9 25%,#e2e8f0 50%,#f0f4f9 75%)",backgroundSize:"200% 100%",animation:"shimmer 1.5s infinite",width:"80%"}}/>
          <style>{`@keyframes shimmer{0%{background-position:200% 0}100%{background-position:-200% 0}}`}</style>
        </div>
      ))}
    </div>
  );
}

// ── Paginador ─────────────────────────────────────────────────
export function Paginador({ total, porPagina=50, pagina, setPagina }) {
  const C = C_LIGHT;
  const totalPags = Math.ceil(total / porPagina);
  if (totalPags <= 1) return null;
  const desde = (pagina-1)*porPagina+1;
  const hasta = Math.min(pagina*porPagina, total);
  return (
    <div style={{display:"flex",alignItems:"center",justifyContent:"space-between",padding:"12px 16px",borderTop:"1px solid #e2e8f0",flexWrap:"wrap",gap:8}}>
      <span style={{color:C.textMid,fontSize:12}}>
        Mostrando <strong>{desde}–{hasta}</strong> de <strong>{total}</strong>
      </span>
      <div style={{display:"flex",gap:4,alignItems:"center"}}>
        <button onClick={()=>setPagina(1)} disabled={pagina===1}
          style={{padding:"4px 8px",borderRadius:6,border:"1px solid #e2e8f0",background:pagina===1?"#f8fafc":C.card,color:pagina===1?"#94a3b8":C.textMid,cursor:pagina===1?"default":"pointer",fontSize:11,fontWeight:700}}>«</button>
        <button onClick={()=>setPagina(p=>Math.max(1,p-1))} disabled={pagina===1}
          style={{padding:"4px 10px",borderRadius:6,border:"1px solid #e2e8f0",background:pagina===1?"#f8fafc":C.card,color:pagina===1?"#94a3b8":C.textMid,cursor:pagina===1?"default":"pointer",fontSize:11,fontWeight:700}}>‹ Ant</button>
        {Array.from({length:Math.min(5,totalPags)},(_,i)=>{
          let p;
          if(totalPags<=5) p=i+1;
          else if(pagina<=3) p=i+1;
          else if(pagina>=totalPags-2) p=totalPags-4+i;
          else p=pagina-2+i;
          return(
            <button key={p} onClick={()=>setPagina(p)}
              style={{padding:"4px 10px",borderRadius:6,border:`1px solid ${p===pagina?"#0D1B2A":"#e2e8f0"}`,background:p===pagina?"#0D1B2A":C.card,color:p===pagina?C.card:C.textMid,cursor:"pointer",fontSize:11,fontWeight:700,minWidth:32}}>
              {p}
            </button>
          );
        })}
        <button onClick={()=>setPagina(p=>Math.min(totalPags,p+1))} disabled={pagina===totalPags}
          style={{padding:"4px 10px",borderRadius:6,border:"1px solid #e2e8f0",background:pagina===totalPags?"#f8fafc":C.card,color:pagina===totalPags?"#94a3b8":C.textMid,cursor:pagina===totalPags?"default":"pointer",fontSize:11,fontWeight:700}}>Sig ›</button>
        <button onClick={()=>setPagina(totalPags)} disabled={pagina===totalPags}
          style={{padding:"4px 8px",borderRadius:6,border:"1px solid #e2e8f0",background:pagina===totalPags?"#f8fafc":C.card,color:pagina===totalPags?"#94a3b8":C.textMid,cursor:pagina===totalPags?"default":"pointer",fontSize:11,fontWeight:700}}>»</button>
      </div>
    </div>
  );
}

// ── SearchDropdown — Buscador con dropdown predictivo ─────────
export function SearchDropdown({
  value, onChange, onSelect, placeholder="🔍 Buscar...",
  items=[], labelKey="nombre", subKey=null, badgeKey=null, badgeCol=null,
  extraSearchKeys=[],
  matchFn=null,
  rankFn=null,
  /** "catalog" = tienda/POS · "inventario" = catálogo admin · null = genérico */
  searchMode=null,
  style={}, maxResults=8, emptyMsg="Sin resultados"
}) {
  const C = C_LIGHT;
  const [open, setOpen] = React.useState(false);
  const [idx,  setIdx]  = React.useState(-1);
  const ref = React.useRef(null);
  const inputRef = React.useRef(null);
  const [panelW, setPanelW] = React.useState(0);

  const searchGetters = React.useMemo(() => {
    const extra = (extraSearchKeys || []).map((k) => (it) => it[k]);
    return [(it) => it[labelKey], ...(subKey ? [(it) => it[subKey]] : []), ...extra];
  }, [labelKey, subKey, (extraSearchKeys || []).join("\0")]);

  const resolvedMatchFn = matchFn
    || (searchMode === "inventario" ? inventarioProductMatchesBusqueda : null)
    || (searchMode === "catalog" ? tiendaProductMatchesBusqueda : null);
  const resolvedRankFn = rankFn
    || (searchMode === "inventario" ? inventarioSearchRelevanceRank : null)
    || (searchMode === "catalog" ? tiendaSearchRelevanceRank : null);

  const filtered = !value?.trim() ? [] : items
    .filter((item) =>
      resolvedMatchFn
        ? resolvedMatchFn(item, value)
        : productMatchesSearchQuery(item, value, searchGetters)
    )
    .sort((a, b) =>
      resolvedRankFn ? resolvedRankFn(a, value) - resolvedRankFn(b, value) : 0
    )
    .slice(0, maxResults);

  const measurePanel = React.useCallback(() => {
    const el = inputRef.current;
    if (el) setPanelW(Math.max(el.offsetWidth, 240));
  }, []);

  React.useLayoutEffect(() => {
    if (!open) return;
    measurePanel();
    const onResize = () => measurePanel();
    window.addEventListener("resize", onResize);
    return () => window.removeEventListener("resize", onResize);
  }, [open, value, filtered.length, measurePanel]);

  React.useEffect(()=>{
    armInputForTouchKeyboard(inputRef.current);
  },[]);

  React.useEffect(()=>{
    const handler = e => { if(ref.current&&!ref.current.contains(e.target)) setOpen(false); };
    document.addEventListener("mousedown", handler);
    return ()=>document.removeEventListener("mousedown", handler);
  },[]);

  const handleKey = e => {
    if (e.key === "Escape") {
      setOpen(false);
      setIdx(-1);
      return;
    }
    if (e.key === "Enter") {
      e.preventDefault();
      if (open && filtered.length > 0 && idx >= 0) {
        onSelect(filtered[idx]);
      }
      setOpen(false);
      setIdx(-1);
      return;
    }
    if (!open || !filtered.length) return;
    if (e.key === "ArrowDown") { e.preventDefault(); setIdx(i => Math.min(i + 1, filtered.length - 1)); }
    if (e.key === "ArrowUp") { e.preventDefault(); setIdx(i => Math.max(i - 1, 0)); }
  };

  const panelStyle = {
    position: "absolute",
    top: "calc(100% + 4px)",
    left: 0,
    zIndex: 6000,
    width: panelW > 0 ? panelW : "100%",
    minWidth: panelW > 0 ? panelW : "min(100%, 100vw - 32px)",
    maxWidth: "min(100vw - 24px, 560px)",
    boxSizing: "border-box",
    background: C.card,
    borderRadius: 10,
    border: "1px solid #e2e8f0",
    boxShadow: "0 8px 32px rgba(15,45,110,.12)",
    overflow: "hidden",
    maxHeight: 320,
    overflowY: "auto",
  };

  return (
    <div ref={ref} style={{position:"relative",minWidth:0,...style}}>
      <input
        ref={inputRef}
        value={value}
        inputMode="search"
        enterKeyHint="search"
        autoComplete="off"
        autoCorrect="off"
        autoCapitalize="off"
        spellCheck={false}
        onTouchStart={(e)=>unlockInputForTouchKeyboard(e.currentTarget)}
        onMouseDown={(e)=>unlockInputForTouchKeyboard(e.currentTarget)}
        onChange={e=>{ onChange(e.target.value); setOpen(true); setIdx(-1); }}
        onFocus={(e)=>{ unlockInputForTouchKeyboard(e.currentTarget); setOpen(!!value?.trim()); measurePanel(); }}
        onKeyDown={handleKey}
        placeholder={placeholder}
        style={{width:"100%",boxSizing:"border-box",padding:"10px 14px",borderRadius:8,border:"1px solid #e2e8f0",background:"#f7f9fc",color:C.text,fontSize:16,lineHeight:1.25,minHeight:44,outline:"none",fontFamily:"var(--fc-body)",touchAction:"manipulation"}}
        onBlur={e=>{
          lockInputAfterTouchKeyboard(e.currentTarget);
          if(ref.current&&!ref.current.contains(e.relatedTarget)) setTimeout(()=>setOpen(false),150);
        }}
      />
      {open&&filtered.length>0&&(
        <div style={panelStyle}>
          {filtered.map((item,i)=>(
            <div key={i} onMouseDown={()=>{ onSelect(item); setOpen(false); setIdx(-1); }}
              style={{padding:"10px 14px",cursor:"pointer",background:i===idx?"#eff6ff":C.card,borderBottom:"1px solid #f0f4f9",display:"flex",alignItems:"center",gap:10,transition:"background .1s"}}
              onMouseEnter={()=>setIdx(i)}>
              <div style={{flex:1,minWidth:0}}>
                <div style={{color:C.text,fontWeight:600,fontSize:13,whiteSpace:"nowrap",overflow:"hidden",textOverflow:"ellipsis"}}>{item[labelKey]}</div>
                {subKey&&item[subKey]&&<div style={{color:"#94a3b8",fontSize:11,marginTop:1}}>{item[subKey]}</div>}
              </div>
              {badgeKey&&item[badgeKey]!==undefined&&(
                <span style={{padding:"2px 8px",borderRadius:20,fontSize:10,fontWeight:700,background:(badgeCol||"#1E3ABA")+"18",color:badgeCol||"#1E3ABA",flexShrink:0,whiteSpace:"nowrap"}}>
                  {item[badgeKey]}
                </span>
              )}
            </div>
          ))}
        </div>
      )}
      {open&&value&&filtered.length===0&&(
        <div style={{...panelStyle,padding:"16px 14px",textAlign:"center",color:"#94a3b8",fontSize:12,maxHeight:"none",overflowY:"visible"}}>
          {emptyMsg}
        </div>
      )}
    </div>
  );
}

// ── Estilos globales de hover ─────────────────────────────────
export const hoverStyles = `
  /* Filas de tabla */
  .farmacapital-table-row { transition: background .12s, box-shadow .12s; }
  .farmacapital-table-row:hover { background: #eff6ff !important; }

  /* Cards KPI */
  .farmacapital-kpi-card { transition: border-color .15s, box-shadow .15s, transform .15s; }
  .farmacapital-kpi-card:hover {
    border-color: #0D1B2A !important;
    box-shadow: 0 4px 16px rgba(15,45,110,.12) !important;
    transform: translateY(-1px);
  }

  /* Cards de producto en POS (clic en toda la tarjeta) */
  .farmacapital-product-card { transition: border-color .15s, box-shadow .15s, transform .12s, background .12s; }
  .farmacapital-product-card:hover {
    border-color: #0D1B2A !important;
    box-shadow: 0 4px 16px rgba(15,45,110,.14) !important;
    transform: translateY(-1px);
    background: #fbfdff !important;
  }

  /* Botones secundarios */
  .farmacapital-btn-secondary { transition: background .12s, color .12s, border-color .12s; }
  .farmacapital-btn-secondary:hover {
    background: #eff6ff !important;
    color: #0D1B2A !important;
    border-color: #0D1B2A !important;
  }

  /* Cards generales */
  .farmacapital-card-hover { transition: box-shadow .15s, border-color .15s; }
  .farmacapital-card-hover:hover {
    box-shadow: 0 4px 20px rgba(15,45,110,.10) !important;
    border-color: #bfdbfe !important;
  }

  /* Tooltip PEPS */
  .peps-tooltip-container:hover .peps-tooltip { display:block !important; }

  /* Scrollbar global */
  ::-webkit-scrollbar { width: 5px; height: 5px; }
  ::-webkit-scrollbar-track { background: transparent; }
  ::-webkit-scrollbar-thumb { background: #bfdbfe; border-radius: 3px; }
  ::-webkit-scrollbar-thumb:hover { background: #1E3ABA; }
`;

export function GlobalHoverStyles() {
  const C = C_LIGHT;
  return React.createElement('style', null, hoverStyles);
}