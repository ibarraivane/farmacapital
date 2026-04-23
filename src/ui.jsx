import React from "react";
// FARMAX — Componentes UI base
import { C_LIGHT, BRAND } from "./constants";

export function Logo({size=36,showText=true,light=false}){
  const C = C_LIGHT;
  const t=light?C.card:BRAND.primary, s=light?"rgba(255,255,255,.7)":BRAND.secondary;
  return(
    <div style={{display:"flex",alignItems:"center",gap:10}}>
      <div style={{width:size,height:size,borderRadius:Math.round(size*.25),background:BRAND.gradient,display:"flex",alignItems:"center",justifyContent:"center",flexShrink:0}}>
        <div style={{width:size*.38,height:size*.65,borderRadius:size*.19,overflow:"hidden",display:"flex",flexDirection:"column"}}>
          <div style={{flex:1,background:"rgba(255,255,255,1)"}}/>
          <div style={{flex:1,background:"rgba(255,255,255,.35)"}}/>
        </div>
      </div>
      {showText&&<div style={{display:"flex",flexDirection:"column",lineHeight:1}}>
        <div style={{color:t,fontWeight:800,fontSize:size*.44,fontFamily:"'Plus Jakarta Sans',sans-serif",letterSpacing:"-0.5px"}}>FAR<span style={{color:s}}>MAX</span></div>
        <div style={{color:s,fontSize:size*.22,letterSpacing:"2px",textTransform:"uppercase",marginTop:2,fontWeight:600}}>Sistema</div>
      </div>}
    </div>
  );
}

export function Box({children,style,onClick,ac,className}){
  const C = C_LIGHT;
  const useCssHover = className && String(className).includes("farmax-product-card");
  return(
  <div
    className={className||undefined}
    onClick={onClick}
    style={{background:C.card,borderRadius:14,border:`1px solid ${ac?ac+"40":C.border}`,boxShadow:"0 1px 4px rgba(0,0,0,.06)",transition:"border-color .2s,box-shadow .2s",cursor:onClick?"pointer":"default",...style}}
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

  <span style={{background:col+"15",color:col,border:`1px solid ${col}30`,borderRadius:20,padding:sm?"2px 8px":"3px 11px",fontSize:sm?9:11,fontWeight:700,letterSpacing:.5,textTransform:"uppercase",whiteSpace:"nowrap",display:"inline-block"}}>{children}</span>

  );
};

export function Btn({children,onClick,col,sm,ol,dis,full,style}){
  const C = C_LIGHT;
  return(

  <button onClick={onClick} disabled={dis} style={{padding:sm?"7px 14px":"10px 18px",borderRadius:8,border:`1px solid ${ol?(col||BRAND.primary):"transparent"}`,background:ol?"transparent":dis?C.border:(col||BRAND.primary),color:ol?(col||BRAND.primary):dis?C.textMid:C.card,fontWeight:700,fontSize:sm?12:14,cursor:dis?"not-allowed":"pointer",fontFamily:"'Plus Jakarta Sans',sans-serif",opacity:dis?.5:1,width:full?"100%":undefined,minHeight:sm?36:40,transition:"opacity .15s",...style}}>{children}</button>

  );
};

export function Inp({value,onChange,placeholder,style,type,onKeyDown,disabled}){
  const C = C_LIGHT;
  return(

  <input value={value} onChange={onChange} disabled={disabled} placeholder={placeholder} type={type||"text"} onKeyDown={onKeyDown}
    style={{background:C.bg,border:`1px solid ${C.border}`,borderRadius:8,color:C.text,padding:"10px 14px",fontSize:16,lineHeight:1.25,outline:"none",fontFamily:"'Plus Jakarta Sans',sans-serif",opacity:disabled?0.6:1,cursor:disabled?"not-allowed":"text",minHeight:44,boxSizing:"border-box",...style}}
    onFocus={e=>{e.target.style.borderColor=C.blue;e.target.style.boxShadow="0 0 0 3px "+C.blueDim;}} onBlur={e=>{e.target.style.borderColor=C.border;e.target.style.boxShadow="none;"}}/>

  );
};

export function KPI({label,value,sub,col,icon,trend}){
  const C = C_LIGHT;
  return(

  <Box style={{padding:"18px 20px",flex:"1 1 140px",minWidth:0}}>
    <div style={{display:"flex",justifyContent:"space-between",alignItems:"flex-start"}}>
      <div style={{flex:1,minWidth:0}}>
        <div style={{color:C.textDim,fontSize:9,letterSpacing:1.5,textTransform:"uppercase",marginBottom:8}}>{label}</div>
        <div style={{color:col||C.text,fontSize:22,fontWeight:800,lineHeight:1}}>{value}</div>
        {sub&&<div style={{color:C.textMid,fontSize:11,marginTop:4}}>{sub}</div>}
        {trend!==undefined&&<div style={{color:trend>=0?C.green:C.red,fontSize:11,marginTop:4,fontWeight:700}}>{trend>=0?"▲":"▼"} {Math.abs(trend)}% vs ayer</div>}
      </div>
      <div style={{fontSize:22,opacity:.5,marginLeft:8}}>{icon}</div>
    </div>
  </Box>

  );
};

export function Modal({open,onClose,title,children,ac,closeOnBackdrop=true}){
  const C = C_LIGHT;
  if(!open) return null;
  return(
    <div style={{position:"fixed",inset:0,background:"rgba(0,0,0,.45)",zIndex:1000,display:"flex",alignItems:"center",justifyContent:"center",padding:"max(12px, env(safe-area-inset-top, 0px)) max(12px, env(safe-area-inset-right, 0px)) max(12px, env(safe-area-inset-bottom, 0px)) max(12px, env(safe-area-inset-left, 0px))",boxSizing:"border-box"}} onClick={closeOnBackdrop ? onClose : undefined}>
      <div style={{background:C.card,borderRadius:16,padding:"clamp(18px, 4vw, 28px)",minWidth:0,maxWidth:560,width:"min(560px, 100%)",maxHeight:"min(90dvh, 92vh)",overflowY:"auto",WebkitOverflowScrolling:"touch",boxShadow:"0 8px 40px rgba(0,0,0,.18)",border:`1px solid ${C.border}`}} onClick={e=>e.stopPropagation()}>
        <div style={{display:"flex",alignItems:"center",justifyContent:"space-between",marginBottom:18}}>
          <div style={{fontWeight:800,fontSize:16,color:C.text}}>{title}</div>
          {!ac&&<button onClick={onClose} style={{background:"none",border:"none",fontSize:20,cursor:"pointer",color:C.textMid}}>✕</button>}
        </div>
        {children}
      </div>
    </div>
  );
}

export function NotificacionesToast({ notifs, onDismiss }) {
  const C = C_LIGHT;
  if(!notifs?.length) return null;
  return (
    <div style={{position:"fixed",top:"max(12px, env(safe-area-inset-top, 0px))",left:12,right:12,zIndex:9999,display:"flex",flexDirection:"column",gap:8,alignItems:"stretch",maxWidth:400,margin:"0 auto",pointerEvents:"none",boxSizing:"border-box"}}>
      {notifs.map(n=>(
        <div key={n.id} style={{background:C.card,borderRadius:12,padding:"12px 16px",boxShadow:"0 8px 32px rgba(0,82,204,.18)",border:`2px solid ${n.col||"#0052cc"}`,display:"flex",alignItems:"flex-start",gap:10,pointerEvents:"auto"}}>
          <span style={{fontSize:20,flexShrink:0}}>{n.icon||"🔔"}</span>
          <div style={{flex:1}}>
            <div style={{color:C.text,fontWeight:700,fontSize:13}}>{n.titulo}</div>
            <div style={{color:C.textMid,fontSize:12,marginTop:2}}>{n.mensaje}</div>
            <div style={{color:"#94a3b8",fontSize:10,marginTop:4}}>{n.hora}</div>
          </div>
          <button onClick={()=>onDismiss(n.id)} style={{background:"none",border:"none",color:"#94a3b8",cursor:"pointer",fontSize:16,padding:0,flexShrink:0}}>✕</button>
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
  if(!open) return null;
  return(
    <div style={{position:"fixed",inset:0,background:"rgba(15,23,42,.5)",backdropFilter:"blur(4px)",zIndex:9997,display:"flex",alignItems:"center",justifyContent:"center",padding:"max(16px, env(safe-area-inset-top, 0px)) max(16px, env(safe-area-inset-right, 0px)) max(16px, env(safe-area-inset-bottom, 0px)) max(16px, env(safe-area-inset-left, 0px))",boxSizing:"border-box"}}>
      <div style={{background:C.card,borderRadius:14,padding:"clamp(20px, 5vw, 28px)",width:"min(400px, 100%)",maxHeight:"min(90dvh, 92vh)",overflowY:"auto",boxShadow:"0 20px 60px rgba(0,0,0,.2)"}}>
        <div style={{fontSize:32,textAlign:"center",marginBottom:12}}>{danger?"⚠️":"❓"}</div>
        <div style={{color:C.text,fontWeight:800,fontSize:16,textAlign:"center",marginBottom:8}}>{titulo}</div>
        <div style={{color:C.textMid,fontSize:13,textAlign:"center",marginBottom:24,lineHeight:1.6}}>{mensaje}</div>
        <div className="farmax-confirm-actions" style={{display:"flex",gap:10,justifyContent:"center",flexWrap:"wrap"}}>
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
    <div style={{display:"flex",gap:12,flexWrap:"wrap",marginBottom:20}}>
      {Array(count).fill(0).map((_,i)=>(
        <div key={i} style={{flex:"1 1 160px",minWidth:0,borderRadius:14,border:"1px solid #e2e8f0",padding:"18px 20px",background:C.card}}>
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
              style={{padding:"4px 10px",borderRadius:6,border:`1px solid ${p===pagina?"#0052cc":"#e2e8f0"}`,background:p===pagina?"#0052cc":C.card,color:p===pagina?C.card:C.textMid,cursor:"pointer",fontSize:11,fontWeight:700,minWidth:32}}>
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
  style={}, maxResults=8, emptyMsg="Sin resultados"
}) {
  const C = C_LIGHT;
  const [open, setOpen] = React.useState(false);
  const [idx,  setIdx]  = React.useState(-1);
  const ref = React.useRef(null);

  const filtered = !value ? [] : items.filter(item=>{
    const label = (item[labelKey]||"").toLowerCase();
    const sub   = subKey?(item[subKey]||"").toLowerCase():"";
    const q     = value.toLowerCase();
    return label.includes(q)||sub.includes(q);
  }).slice(0,maxResults);

  React.useEffect(()=>{
    const handler = e => { if(ref.current&&!ref.current.contains(e.target)) setOpen(false); };
    document.addEventListener("mousedown", handler);
    return ()=>document.removeEventListener("mousedown", handler);
  },[]);

  const handleKey = e => {
    if(!open||!filtered.length) return;
    if(e.key==="ArrowDown"){ e.preventDefault(); setIdx(i=>Math.min(i+1,filtered.length-1)); }
    if(e.key==="ArrowUp"){ e.preventDefault(); setIdx(i=>Math.max(i-1,0)); }
    if(e.key==="Enter"&&idx>=0){ e.preventDefault(); onSelect(filtered[idx]); setOpen(false); setIdx(-1); }
    if(e.key==="Escape"){ setOpen(false); setIdx(-1); }
  };

  return (
    <div ref={ref} style={{position:"relative",...style}}>
      <input
        value={value}
        onChange={e=>{ onChange(e.target.value); setOpen(true); setIdx(-1); }}
        onFocus={()=>value&&setOpen(true)}
        onKeyDown={handleKey}
        placeholder={placeholder}
        style={{width:"100%",boxSizing:"border-box",padding:"10px 14px",borderRadius:8,border:"1px solid #e2e8f0",background:"#f7f9fc",color:C.text,fontSize:16,lineHeight:1.25,minHeight:44,outline:"none",fontFamily:"'Plus Jakarta Sans',sans-serif"}}
        onBlur={e=>{ if(ref.current&&!ref.current.contains(e.relatedTarget)) setTimeout(()=>setOpen(false),150); }}
      />
      {open&&filtered.length>0&&(
        <div style={{position:"absolute",top:"calc(100% + 4px)",left:0,right:0,zIndex:500,background:C.card,borderRadius:10,border:"1px solid #e2e8f0",boxShadow:"0 8px 32px rgba(0,82,204,.12)",overflow:"hidden",maxHeight:320,overflowY:"auto"}}>
          {filtered.map((item,i)=>(
            <div key={i} onMouseDown={()=>{ onSelect(item); setOpen(false); setIdx(-1); }}
              style={{padding:"10px 14px",cursor:"pointer",background:i===idx?"#eff6ff":C.card,borderBottom:"1px solid #f0f4f9",display:"flex",alignItems:"center",gap:10,transition:"background .1s"}}
              onMouseEnter={()=>setIdx(i)}>
              <div style={{flex:1,minWidth:0}}>
                <div style={{color:C.text,fontWeight:600,fontSize:13,whiteSpace:"nowrap",overflow:"hidden",textOverflow:"ellipsis"}}>{item[labelKey]}</div>
                {subKey&&item[subKey]&&<div style={{color:"#94a3b8",fontSize:11,marginTop:1}}>{item[subKey]}</div>}
              </div>
              {badgeKey&&item[badgeKey]!==undefined&&(
                <span style={{padding:"2px 8px",borderRadius:20,fontSize:10,fontWeight:700,background:(badgeCol||"#0099e6")+"18",color:badgeCol||"#0099e6",flexShrink:0,whiteSpace:"nowrap"}}>
                  {item[badgeKey]}
                </span>
              )}
            </div>
          ))}
        </div>
      )}
      {open&&value&&filtered.length===0&&(
        <div style={{position:"absolute",top:"calc(100% + 4px)",left:0,right:0,zIndex:500,background:C.card,borderRadius:10,border:"1px solid #e2e8f0",boxShadow:"0 8px 32px rgba(0,82,204,.12)",padding:"16px 14px",textAlign:"center",color:"#94a3b8",fontSize:12}}>
          {emptyMsg}
        </div>
      )}
    </div>
  );
}

// ── Estilos globales de hover ─────────────────────────────────
export const hoverStyles = `
  /* Filas de tabla */
  .farmax-table-row { transition: background .12s, box-shadow .12s; }
  .farmax-table-row:hover { background: #eff6ff !important; }

  /* Cards KPI */
  .farmax-kpi-card { transition: border-color .15s, box-shadow .15s, transform .15s; }
  .farmax-kpi-card:hover {
    border-color: #0052cc !important;
    box-shadow: 0 4px 16px rgba(0,82,204,.12) !important;
    transform: translateY(-1px);
  }

  /* Cards de producto en POS (clic en toda la tarjeta) */
  .farmax-product-card { transition: border-color .15s, box-shadow .15s, transform .12s, background .12s; }
  .farmax-product-card:hover {
    border-color: #0052cc !important;
    box-shadow: 0 4px 16px rgba(0,82,204,.14) !important;
    transform: translateY(-1px);
    background: #fbfdff !important;
  }

  /* Botones secundarios */
  .farmax-btn-secondary { transition: background .12s, color .12s, border-color .12s; }
  .farmax-btn-secondary:hover {
    background: #eff6ff !important;
    color: #0052cc !important;
    border-color: #0052cc !important;
  }

  /* Cards generales */
  .farmax-card-hover { transition: box-shadow .15s, border-color .15s; }
  .farmax-card-hover:hover {
    box-shadow: 0 4px 20px rgba(0,82,204,.10) !important;
    border-color: #bfdbfe !important;
  }

  /* Tooltip PEPS */
  .peps-tooltip-container:hover .peps-tooltip { display:block !important; }

  /* Scrollbar global */
  ::-webkit-scrollbar { width: 5px; height: 5px; }
  ::-webkit-scrollbar-track { background: transparent; }
  ::-webkit-scrollbar-thumb { background: #bfdbfe; border-radius: 3px; }
  ::-webkit-scrollbar-thumb:hover { background: #0099e6; }
`;

export function GlobalHoverStyles() {
  const C = C_LIGHT;
  return React.createElement('style', null, hoverStyles);
}