import { useState, useEffect, useMemo, createContext, useContext } from "react";
import { supabase } from "./supabase";
import { useTheme } from "./themeContext";
import { useMediaQuery } from "./hooks/useMediaQuery";
import { saludoUsuario, primerNombre, $, normalizarSesionLoginResp, nombreCompletoPacienteValido, telefonoMxValido, soloDigitosTel } from "./utils";
import { tiendaProductMatchesBusqueda, spellSuggestFromProducts, tiendaCatalogSearchSuggestions, tiendaSearchRelevanceRank } from "./utils/fuzzySearch";
import { CONSULTA_PRECIO_DEFAULT, citaPagoOk } from "./utils/consultaConstants";
import { fetchPrecioConsultaConfig } from "./utils/consumiblesConsultorio";
import {
  mapUiEntregaToRpc,
  validarCarritoParaEntrega,
} from "./utils/orderChannels";
import {
  productoPermitidoEnTiendaFarmaciaWeb,
  razonBloqueoProductoTiendaFarmacia,
  productoEsCategoriaMinisuperTienda,
} from "./utils/tiendaFarmaciaCatalogo";
import { showToast } from "./ui";

// ═══════════════════════════════════════════════════════════════
// FARMAX — Tienda en Línea v4
// Popup · Banners · Mapa · Footer legal · FAQ · Políticas
// ═══════════════════════════════════════════════════════════════

const BRAND = {
  primary:"#0052cc", secondary:"#0099e6", accent:"#00c46a",
  gradient:"linear-gradient(135deg,#0052cc,#0099e6)",
};
const C = {
  bg:"#f7f9fc", card:"#ffffff", cardDark:"#f0f4f9",
  border:"#e2e8f0", dark:"#0f172a", mid:"#475569",
  dim:"#94a3b8", white:"#ffffff", red:"#ef4444",
};

/** Id estable para Maps y RPC (PostgREST a veces mezcla string/bigint). */
function tiendaNormProductId(id) {
  const n = typeof id === "number" && Number.isFinite(id) ? id : parseInt(String(id), 10);
  return Number.isFinite(n) ? n : id;
}

/** Suma cantidad_actual de lotes activos por producto_id. */
function tiendaSumLotesByProduct(lotesRows) {
  const m = new Map();
  for (const row of lotesRows || []) {
    if (row?.activo === false) continue;
    const pid = tiendaNormProductId(row.producto_id);
    const add = Number(row.cantidad_actual) || 0;
    if (add <= 0) continue;
    m.set(pid, (m.get(pid) || 0) + add);
  }
  return m;
}

function checkoutAddressStorageKey(user) {
  const id = user?.id != null ? String(user.id) : "";
  const tel = user?.telefono ? String(user.telefono).replace(/\D/g, "") : "";
  const suffix = id || tel || "guest";
  return `farmax_checkout_address_${suffix}`;
}

/** Stock vendible: max(columna productos.stock, suma lotes) por si el trigger no sincronizó. */
function tiendaEffectiveStockFromDb(dbp, sumLotesMap) {
  const col = Number(dbp?.stock) || 0;
  const fromLotes = sumLotesMap.get(tiendaNormProductId(dbp.id)) || 0;
  return Math.max(col, fromLotes);
}

// ── CONTACTO (descomentar cuando tengas número) ───────────────
const CONTACTO = {
  telefono: null,           // "55 XXXX XXXX"
  whatsapp: null,           // "5512345678"
  email: "contacto@farmax.mx",
  direccion: "Radiodifusora 100, Chinampac de Juárez, Iztapalapa, CDMX, C.P. 09208",
  horario: "Lun–Vie 8:00–22:00 · Sáb 8:00–20:00 · Dom 9:00–18:00",
  maps_embed: "https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3763.5!2d-99.0518514!3d19.371062!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x85d1fd0b8b0fd10d%3A0x75316d7abacf16ae!2sRadiodifusora+100%2C+Iztapalapa!5e0!3m2!1ses!2smx!4v1",
};

// ── BANNERS ROTATIVOS ─────────────────────────────────────────
const BANNERS = [
  {
    id:1,
    titulo:"Genéricos Farmax",
    subtitulo:"Medicamentos desde $10",
    descripcion:"Misma fórmula, mejor precio. Certificados por COFEPRIS.",
    cta:"Ver genéricos",
    pagina:"catalogo",
    bg:"linear-gradient(135deg,#0052cc,#0099e6)",
    emoji:"💊",
  },
  {
    id:2,
    titulo:"Consulta médica",
    subtitulo:`$${CONSULTA_PRECIO_DEFAULT} por consulta`,
    descripcion:"O gratis con 160 puntos Farmax. Médico general disponible.",
    cta:"Agendar cita",
    pagina:"cita",
    bg:"linear-gradient(135deg,#009952,#00c46a)",
    emoji:"🏥",
  },
  {
    id:3,
    titulo:"Puntos Farmax",
    subtitulo:"Acumula y canjea",
    descripcion:"Gana 1 punto por cada $10 en farmacia, minisuper y consultorio.",
    cta:"Conocer más",
    pagina:"puntos",
    bg:"linear-gradient(135deg,#6d28d9,#9d6fff)",
    emoji:"⭐",
  },
];

/** Normaliza fila Supabase → props de UI; slot: hero | strip | tile */
function mapBannerFromRow(b){
  const s = String(b.slot||"hero").toLowerCase();
  const slot = s==="strip"||s==="tile" ? s : "hero";
  const em = b.emoji != null ? String(b.emoji).trim() : "";
  return {
    titulo: b.titulo,
    subtitulo: b.subtitulo||"",
    descripcion: b.descripcion||"",
    emoji: em,
    bg: b.bg||BRAND.gradient,
    cta: b.cta||"Ver más",
    pagina: b.pagina||"catalogo",
    slot,
    imagen_url: b.imagen_url || "",
    imagen_mobile_url: b.imagen_mobile_url || "",
  };
}

function bannerVisualUrl(b, stack){
  if (stack && b.imagen_mobile_url) return b.imagen_mobile_url;
  return b.imagen_url || "";
}

const TiendaPlaceholderCtx = createContext("");

/** Imagen de producto en catálogo / carrito: variante móvil si existe y viewport estrecho */
function productImageUrl(prod, narrow, placeholderFallback = ""){
  if (!prod) return placeholderFallback || "";
  if (narrow && prod.imagen_mobile_url) return prod.imagen_mobile_url;
  return prod.imagen_url || placeholderFallback || "";
}

// ── FAQ ───────────────────────────────────────────────────────
const FAQ_ITEMS = [
  { p:"¿Cómo hago un pedido en línea?", r:"Agrega los productos al carrito, selecciona tu tipo de entrega (pick-up o envío), ingresa tus datos y elige tu método de pago. Recibirás confirmación por WhatsApp." },
  { p:"¿Cuánto tarda el envío?", r:"En CDMX puedes elegir entrega express vía Rappi o Uber (al costo del servicio). Para el resto de México, enviamos por Skydropx en 2-5 días hábiles por $89." },
  { p:"¿Puedo recoger mi pedido en la farmacia?", r:"Sí. El pick-up es gratis y el mismo día. Recibirás un mensaje cuando tu pedido esté listo." },
  { p:"¿Cómo funcionan los Puntos Farmax?", r:"Ganas 1 punto por cada $10 de compra. 1 punto equivale a $0.50 de descuento. Puedes usarlos en farmacia, minisuper y consultorio." },
  { p:"¿Qué hago si necesito un medicamento con receta?", r:"Agrégalo al carrito normalmente. Al recoger o recibir tu pedido, presenta tu receta médica original. Para antibióticos y controlados es obligatorio por COFEPRIS." },
  { p:"¿Cómo puedo facturar mi compra?", r:"Solicita tu factura CFDI en el mostrador al momento de tu compra o escríbenos a contacto@farmax.mx dentro de las 24 horas siguientes." },
  { p:"¿Cuál es la política de devoluciones?", r:"Aceptamos devoluciones dentro de 72 horas si el producto está en perfecto estado y sin abrir. Medicamentos controlados y con receta no tienen devolución. Consulta nuestra política completa." },
  { p:"¿Tienen medicamentos genéricos?", r:"Sí. Tenemos una amplia variedad de genéricos intercambiables certificados por COFEPRIS, con el mismo principio activo que las marcas de patente pero a menor precio." },
];

const HORARIOS_DOCTORA = [
  { dia:"Lunes a Viernes", horario:"09:00 – 14:00 y 16:00 – 20:00" },
  { dia:"Sábado",          horario:"09:00 – 14:00" },
  { dia:"Domingo",         horario:"Cerrado" },
];
const TODOS_HORARIOS = ["09:00","09:30","10:00","10:30","11:00","11:30","16:00","16:30","17:00","17:30","18:00","18:30"];

function localISODate(d = new Date()) {
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, "0");
  const day = String(d.getDate()).padStart(2, "0");
  return `${y}-${m}-${day}`;
}

const ptsGana = p => Math.floor(p/10);
const labelPts = n => `${n} ${n===1?"punto":"puntos"} Farmax`;

function horariosDisponibles(fecha){
  if(!fecha) return TODOS_HORARIOS;
  const hoy = localISODate();
  if(fecha!==hoy) return TODOS_HORARIOS;
  const ahora=new Date();
  return TODOS_HORARIOS.filter(h=>{
    const [hh,mm]=h.split(":").map(Number);
    return hh>ahora.getHours()||(hh===ahora.getHours()&&mm>ahora.getMinutes());
  });
}

// ── LOGO ──────────────────────────────────────────────────────
function Logo({size=32,light=false}){
  const t=light?"#fff":BRAND.primary, s=light?"rgba(255,255,255,.8)":BRAND.secondary;
  return(
    <div style={{display:"flex",alignItems:"center",gap:9,cursor:"pointer"}}>
      <div style={{width:size,height:size,borderRadius:Math.round(size*.25),background:BRAND.gradient,display:"flex",alignItems:"center",justifyContent:"center",flexShrink:0}}>
        <div style={{width:size*.38,height:size*.65,borderRadius:size*.19,overflow:"hidden",display:"flex",flexDirection:"column"}}>
          <div style={{flex:1,background:"rgba(255,255,255,1)"}}/>
          <div style={{flex:1,background:"rgba(255,255,255,.35)"}}/>
        </div>
      </div>
      <div style={{display:"flex",flexDirection:"column",lineHeight:1}}>
        <div style={{color:t,fontWeight:800,fontSize:size*.5,fontFamily:"'Plus Jakarta Sans',sans-serif",letterSpacing:"-0.5px"}}>FAR<span style={{color:s}}>MAX</span></div>
        <div style={{color:s,fontSize:size*.22,letterSpacing:"1.5px",textTransform:"uppercase",marginTop:1,fontWeight:600}}>Farmacia</div>
      </div>
    </div>
  );
}

// ── UI BASE ───────────────────────────────────────────────────
const Btn=({children,onClick,col,outline,sm,full,disabled,style})=>(
  <button onClick={onClick} disabled={disabled} style={{padding:sm?"7px 16px":"12px 24px",borderRadius:10,border:`2px solid ${outline?(col||BRAND.primary):"transparent"}`,background:outline?"transparent":disabled?C.dim:(col||BRAND.primary),color:outline?(col||BRAND.primary):C.white,fontWeight:700,fontSize:sm?13:14,cursor:disabled?"not-allowed":"pointer",fontFamily:"'Plus Jakarta Sans',sans-serif",width:full?"100%":undefined,opacity:disabled?.6:1,transition:"all .15s",...style}}>{children}</button>
);
const Tag=({children,col,sm})=>(
  <span style={{background:col+"18",color:col,border:`1px solid ${col}30`,borderRadius:20,padding:sm?"2px 8px":"4px 12px",fontSize:sm?10:12,fontWeight:700,whiteSpace:"nowrap",display:"inline-block"}}>{children}</span>
);
const Inp=({value,onChange,placeholder,type,style,onKeyDown,onFocus,onBlur})=>(
  <input value={value} onChange={onChange} placeholder={placeholder} type={type||"text"} onKeyDown={onKeyDown}
    style={{background:C.white,border:`2px solid ${C.border}`,borderRadius:10,color:C.dark,padding:"11px 14px",fontSize:16,outline:"none",fontFamily:"'Plus Jakarta Sans',sans-serif",transition:"border-color .2s",...style}}
    onFocus={e=>{onFocus?.(e);e.target.style.borderColor=BRAND.primary}} onBlur={e=>{onBlur?.(e);e.target.style.borderColor=C.border}}/>
);

// ── POPUP BIENVENIDA ──────────────────────────────────────────
function PopupBienvenida({onClose,setPage,precioConsulta}){
  const C = useTheme();
  const stack = useMediaQuery("(max-width: 480px)");
  const pc = Math.round(Number(precioConsulta) || CONSULTA_PRECIO_DEFAULT);
  return(
    <div style={{position:"fixed",inset:0,background:"rgba(0,0,0,.55)",zIndex:500,display:"flex",alignItems:"center",justifyContent:"center",padding:16}}>
      <div style={{background:C.white,borderRadius:20,maxWidth:420,width:"100%",overflow:"hidden",boxShadow:"0 20px 60px rgba(0,0,0,.3)"}}>
        <div style={{background:BRAND.gradient,padding:"28px 20px",textAlign:"center",position:"relative"}}>
          <button type="button" onClick={onClose} style={{position:"absolute",top:12,right:16,background:"rgba(255,255,255,.2)",border:"none",color:C.white,width:28,height:28,borderRadius:"50%",cursor:"pointer",fontSize:16,display:"flex",alignItems:"center",justifyContent:"center"}}>×</button>
          <div style={{fontSize:48,marginBottom:12}}>⭐</div>
          <h2 style={{color:C.white,fontSize:"clamp(18px,4.5vw,22px)",fontWeight:800,fontFamily:"'Plus Jakarta Sans',sans-serif",marginBottom:8}}>¡Bienvenido a Farmax!</h2>
          <p style={{color:"rgba(255,255,255,.9)",fontSize:14,lineHeight:1.6}}>Regístrate hoy y gana <strong>10 puntos de bienvenida</strong> — equivalen a $5 de descuento en tu próxima compra.</p>
        </div>
        <div style={{padding:"20px 20px"}}>
          <div style={{display:"grid",gridTemplateColumns:stack?"1fr":"1fr 1fr",gap:10,marginBottom:20}}>
            {[["💊","Genéricos desde $10"],["📦","Envío a domicilio"],["🏥",`Consulta médica $${pc}`],["⭐","Acumula puntos"]].map(([e,t])=>(
              <div key={t} style={{display:"flex",alignItems:"center",gap:8}}>
                <span style={{fontSize:18}}>{e}</span>
                <span style={{color:C.mid,fontSize:12}}>{t}</span>
              </div>
            ))}
          </div>
          <Btn onClick={()=>{onClose();setPage("registro");}} col={BRAND.primary} full>Crear mi cuenta gratis →</Btn>
          <button onClick={onClose} style={{width:"100%",background:"none",border:"none",color:C.dim,fontSize:13,cursor:"pointer",marginTop:10,padding:8}}>Seguir comprando sin cuenta</button>
        </div>
      </div>
    </div>
  );
}

// ── CARRUSEL PRINCIPAL (zona hero) ────────────────────────────
/**
 * Fotos recomendadas (rellenan la franja horizontal con object-fit: cover):
 * - Escritorio (imagen_url): 1920×640 px o 2000×700 px (~3:1). Texto e imagen importantes centrados.
 * - Móvil (imagen_mobile_url, opcional): 1080×900 o 900×800 (~5:4 / 4:3), también centrado.
 * Mínimo útil: 1600×600. Más resolución = menos borroso en pantallas grandes.
 */
/** useStaticPlaceholder: solo si aún no hay datos de BD o no hay banners activos (evita ocultar cambios del admin). */
function HeroCarousel({setPage, items, precioConsulta, stack, useStaticPlaceholder=true}){
  const C = useTheme();
  const [idx,setIdx]=useState(0);
  const [pauseAuto,setPauseAuto]=useState(false);
  const banners = items.length
    ? items
    : useStaticPlaceholder
    ? BANNERS.map((b) =>
        b.id === 2 && precioConsulta
          ? {
              ...b,
              subtitulo: `$${Math.round(Number(precioConsulta) || CONSULTA_PRECIO_DEFAULT)} por consulta`,
            }
          : b
      )
    : [];
  useEffect(()=>{ setIdx(0); },[banners.length]);
  useEffect(()=>{
    if(banners.length<=1||pauseAuto) return undefined;
    const t=setInterval(()=>setIdx(i=>(i+1)%banners.length),4000);
    return ()=>clearInterval(t);
  },[banners.length,pauseAuto]);
  if (banners.length===0) return null;
  const b=banners[idx]||BANNERS[0];
  const heroImg = bannerVisualUrl(b, stack);
  const heroHasImg = !!heroImg;
  /** Franja ancha fija: la imagen cubre todo el ancho (cover), misma forma en todo el hero. */
  const heroStripH = stack
    ? "clamp(220px, 42vw, 340px)"
    : "clamp(300px, 20vw, 460px)";
  const textPad = heroHasImg ? "clamp(16px,3.5vw,28px) 16px" : "clamp(28px,8vw,48px) 16px";
  return(
    <div style={{position:"relative",width:"100%",overflow:"hidden"}}>
      {heroHasImg ? (
        <div style={{position:"relative",width:"100%",height:heroStripH,background:"#070f1a"}}>
          <img
            src={heroImg}
            alt=""
            decoding="async"
            style={{
              position:"absolute",
              inset:0,
              width:"100%",
              height:"100%",
              objectFit:"cover",
              objectPosition:"center center",
            }}
          />
          <div
            aria-hidden
            style={{
              position:"absolute",
              inset:0,
              zIndex:1,
              background:"linear-gradient(rgba(0,24,48,.48),rgba(0,24,48,.66))",
            }}
          />
          <div style={{
            position:"absolute",
            inset:0,
            zIndex:2,
            display:"flex",
            alignItems:"center",
            justifyContent:"center",
            padding:textPad,
            textAlign:"center",
            pointerEvents:"none",
          }}>
            <div style={{maxWidth:700,margin:"0 auto",width:"100%",pointerEvents:"auto"}}>
              <div style={{color:"rgba(255,255,255,.8)",fontSize:"clamp(11px, 3vw, 13px)",letterSpacing:2,textTransform:"uppercase",marginBottom:8}}>{b.subtitulo}</div>
              <h2 style={{color:C.white,fontSize:"clamp(20px, 5.5vw, 30px)",fontWeight:800,fontFamily:"'Plus Jakarta Sans',sans-serif",marginBottom:10,lineHeight:1.2}}>{b.titulo}</h2>
              <p style={{color:"rgba(255,255,255,.85)",fontSize:"clamp(13px, 3.2vw, 15px)",marginBottom:18,lineHeight:1.55}}>{b.descripcion}</p>
              <span
                onMouseEnter={()=>setPauseAuto(true)}
                onMouseLeave={()=>setPauseAuto(false)}
                style={{display:"inline-block"}}
              >
                <Btn onClick={()=>setPage(b.pagina)} style={{background:C.white,color:BRAND.primary,border:"none"}}>{b.cta}</Btn>
              </span>
            </div>
          </div>
          {banners.length>1&&(
          <>
          <div
            onMouseEnter={()=>setPauseAuto(true)}
            onMouseLeave={()=>setPauseAuto(false)}
            style={{position:"absolute",bottom:12,left:"50%",transform:"translateX(-50%)",display:"flex",gap:6,zIndex:3}}
          >
            {banners.map((_,i)=>(
              <button key={i} type="button" aria-label={`Banner ${i+1}`} onClick={()=>setIdx(i)} style={{width:i===idx?24:8,height:8,borderRadius:4,border:"none",background:i===idx?"rgba(255,255,255,.9)":"rgba(255,255,255,.4)",cursor:"pointer",transition:"all .3s",padding:0}}/>
            ))}
          </div>
          {[[-1,"←"],[1,"→"]].map(([d,icon])=>(
            <button key={d} type="button" onClick={()=>setIdx(i=>(i+d+banners.length)%banners.length)}
              onMouseEnter={()=>setPauseAuto(true)}
              onMouseLeave={()=>setPauseAuto(false)}
              onFocus={()=>setPauseAuto(true)}
              onBlur={()=>setPauseAuto(false)}
              style={{position:"absolute",top:"50%",transform:"translateY(-50%)",zIndex:3,...( d===-1?{left:12}:{right:12}),background:"rgba(255,255,255,.22)",border:"none",color:C.white,width:36,height:36,borderRadius:"50%",cursor:"pointer",fontSize:16,display:"flex",alignItems:"center",justifyContent:"center"}}>
              {icon}
            </button>
          ))}
          </>
          )}
        </div>
      ) : (
        <>
        <div style={{
          position:"relative",
          zIndex:1,
          padding:textPad,
          textAlign:"center",
          background:b.bg,
          transition:"background .35s",
        }}>
          <div style={{maxWidth:700,margin:"0 auto",width:"100%"}}>
            {!!(b.emoji&&String(b.emoji).trim())&&<div style={{fontSize:"clamp(40px, 12vw, 52px)",marginBottom:12}}>{b.emoji}</div>}
            <div style={{color:"rgba(255,255,255,.8)",fontSize:"clamp(11px, 3vw, 13px)",letterSpacing:2,textTransform:"uppercase",marginBottom:8}}>{b.subtitulo}</div>
            <h2 style={{color:C.white,fontSize:"clamp(22px, 6vw, 32px)",fontWeight:800,fontFamily:"'Plus Jakarta Sans',sans-serif",marginBottom:12,lineHeight:1.2}}>{b.titulo}</h2>
            <p style={{color:"rgba(255,255,255,.85)",fontSize:"clamp(14px, 3.5vw, 15px)",marginBottom:24,lineHeight:1.6}}>{b.descripcion}</p>
            <span
              onMouseEnter={()=>setPauseAuto(true)}
              onMouseLeave={()=>setPauseAuto(false)}
              style={{display:"inline-block"}}
            >
              <Btn onClick={()=>setPage(b.pagina)} style={{background:C.white,color:BRAND.primary,border:"none"}}>{b.cta}</Btn>
            </span>
          </div>
        </div>
        {banners.length>1&&(
        <>
        <div
          onMouseEnter={()=>setPauseAuto(true)}
          onMouseLeave={()=>setPauseAuto(false)}
          style={{position:"absolute",bottom:12,left:"50%",transform:"translateX(-50%)",display:"flex",gap:6}}
        >
          {banners.map((_,i)=>(
            <button key={i} type="button" aria-label={`Banner ${i+1}`} onClick={()=>setIdx(i)} style={{width:i===idx?24:8,height:8,borderRadius:4,border:"none",background:i===idx?"rgba(255,255,255,.9)":"rgba(255,255,255,.4)",cursor:"pointer",transition:"all .3s",padding:0}}/>
          ))}
        </div>
        {[[-1,"←"],[1,"→"]].map(([d,icon])=>(
          <button key={d} type="button" onClick={()=>setIdx(i=>(i+d+banners.length)%banners.length)}
            onMouseEnter={()=>setPauseAuto(true)}
            onMouseLeave={()=>setPauseAuto(false)}
            onFocus={()=>setPauseAuto(true)}
            onBlur={()=>setPauseAuto(false)}
            style={{position:"absolute",top:"50%",transform:"translateY(-50%)",...( d===-1?{left:16}:{right:16}),background:"rgba(255,255,255,.2)",border:"none",color:C.white,width:36,height:36,borderRadius:"50%",cursor:"pointer",fontSize:16,display:"flex",alignItems:"center",justifyContent:"center"}}>
            {icon}
          </button>
        ))}
        </>
        )}
        </>
      )}
    </div>
  );
}

// ── FRANJA: tarjetas anchas (zona strip) ─────────────────────
function HomeBannersStrip({setPage, items}){
  const C = useTheme();
  const stack = useMediaQuery("(max-width: 768px)");
  if(!items?.length) return null;
  return(
    <div style={{background:"linear-gradient(180deg,#f0f7ff,#f7f9fc)",borderBottom:`1px solid ${C.border}`,padding:"16px 12px"}}>
      <div style={{maxWidth:1200,margin:"0 auto",display:"flex",gap:12,flexWrap:"wrap",justifyContent:"center"}}>
        {items.map((b,i)=>{
          const u = bannerVisualUrl(b, stack);
          return(
          <button
            key={`${b.titulo}-${i}`}
            type="button"
            onClick={()=>setPage(b.pagina)}
            style={{
              position:"relative",
              overflow:"hidden",
              flex:"1 1 min(100%,280px)",maxWidth:420,minWidth:0,width:"100%",textAlign:"left",cursor:"pointer",border:"none",borderRadius:14,
              minHeight:u?118:undefined,
              background:u?"#0f172a":b.bg,
              color:"#fff",padding:"16px 18px",boxShadow:"0 4px 20px rgba(0,82,204,.12)",
              display:"flex",alignItems:"center",gap:14,transition:"transform .15s, box-shadow .15s",
            }}
            onMouseEnter={e=>{ e.currentTarget.style.transform="translateY(-2px)"; e.currentTarget.style.boxShadow="0 8px 28px rgba(0,82,204,.2)"; }}
            onMouseLeave={e=>{ e.currentTarget.style.transform="none"; e.currentTarget.style.boxShadow="0 4px 20px rgba(0,82,204,.12)"; }}
          >
            {u&&(
              <>
                <img src={u} alt="" decoding="async" style={{position:"absolute",inset:0,width:"100%",height:"100%",objectFit:"cover",objectPosition:"center center"}} />
                <div aria-hidden style={{position:"absolute",inset:0,background:"linear-gradient(90deg,rgba(0,0,0,.5),rgba(0,0,0,.22))"}} />
              </>
            )}
            {!u&&!!(b.emoji&&String(b.emoji).trim())&&<span style={{fontSize:36,flexShrink:0}}>{b.emoji}</span>}
            <div style={{flex:1,minWidth:0,position:"relative",zIndex:1}}>
              <div style={{fontWeight:800,fontSize:"clamp(14px,3.5vw,16px)",lineHeight:1.25,marginBottom:4}}>{b.titulo}</div>
              <div style={{fontSize:12,opacity:.9,lineHeight:1.35}}>{b.subtitulo||b.descripcion?.slice(0,80)}{(b.descripcion?.length>80?"…":"")}</div>
              <div style={{fontSize:11,fontWeight:700,marginTop:8,opacity:.95}}>{b.cta} →</div>
            </div>
          </button>
        );})}
      </div>
    </div>
  );
}

// ── MOSAICO: rejilla compacta (zona tile) ─────────────────────
function HomeBannersTiles({setPage, items, stack}){
  const C = useTheme();
  if(!items?.length) return null;
  return(
    <div style={{maxWidth:1200,margin:"0 auto",padding:"0 12px 20px"}}>
      <div style={{
        display:"grid",
        gridTemplateColumns:stack?"repeat(2, 1fr)":"repeat(auto-fill, minmax(min(100%, 200px), 1fr))",
        gap:12,
      }}>
        {items.map((b,i)=>{
          const u = bannerVisualUrl(b, stack);
          return(
          <button
            key={`${b.titulo}-${i}`}
            type="button"
            onClick={()=>setPage(b.pagina)}
            style={{
              position:"relative",
              overflow:"hidden",
              textAlign:"left",cursor:"pointer",border:`1px solid ${C.border}`,borderRadius:14,
              background:u?"#0f172a":b.bg,
              color:"#fff",padding:16,minHeight:u?148:120,
              aspectRatio:u?"4 / 3":undefined,
              display:"flex",flexDirection:"column",justifyContent:"space-between",gap:8,
              boxShadow:"0 2px 12px rgba(0,0,0,.06)",transition:"transform .15s",
            }}
            onMouseEnter={e=>{ e.currentTarget.style.transform="translateY(-2px)"; }}
            onMouseLeave={e=>{ e.currentTarget.style.transform="none"; }}
          >
            {u&&(
              <>
                <img src={u} alt="" decoding="async" style={{position:"absolute",inset:0,width:"100%",height:"100%",objectFit:"cover",objectPosition:"center center"}} />
                <div aria-hidden style={{position:"absolute",inset:0,background:"linear-gradient(180deg,rgba(0,0,0,.52),rgba(0,0,0,.32))"}} />
              </>
            )}
            {!u&&!!(b.emoji&&String(b.emoji).trim())&&<span style={{fontSize:28,position:"relative",zIndex:1}}>{b.emoji}</span>}
            <div style={{position:"relative",zIndex:1}}>
              <div style={{fontWeight:800,fontSize:14,lineHeight:1.25}}>{b.titulo}</div>
              {b.subtitulo&&<div style={{fontSize:11,opacity:.9,marginTop:4,lineHeight:1.3}}>{b.subtitulo}</div>}
            </div>
            <div style={{fontSize:11,fontWeight:700,position:"relative",zIndex:1}}>{b.cta} →</div>
          </button>
        );})}
      </div>
    </div>
  );
}

// ── HEADER ────────────────────────────────────────────────────
const NAV_LINKS = [["home","Inicio"],["catalogo","Catálogo"],["promo","Promociones"],["cita","Consulta médica"],["puntos","Puntos Farmax"],["faq","Ayuda"]];

function Header({page,setPage,cart,user,setUser}){
  const C = useTheme();
  const narrow = useMediaQuery("(max-width: 900px)");
  const compactNav = useMediaQuery("(max-width: 420px)");
  const [mobileMenu, setMobileMenu] = useState(false);
  const n=cart.reduce((a,c)=>a+c.qty,0);

  useEffect(()=>{ setMobileMenu(false); }, [page]);

  const navBtn = (id,l)=>(
    <button key={id} type="button" onClick={()=>setPage(id)} style={{
      padding:"8px 14px",borderRadius:8,border:"none",
      background:page===id?BRAND.primary+"18":"transparent",
      color:page===id?BRAND.primary:C.mid,fontWeight:page===id?700:500,
      fontSize:narrow?13:14,cursor:"pointer",fontFamily:"'Plus Jakarta Sans',sans-serif",
      textAlign:narrow?"left":"center",width:narrow?"100%":"auto",
    }}>{l}</button>
  );

  return(
    <div
      style={{
        position: "sticky",
        top: 0,
        zIndex: 200,
        background: C.white,
        boxShadow: "0 2px 14px rgba(15,23,42,.08)",
      }}
    >
      <div style={{
        background: BRAND.primary,
        padding: "6px 12px 8px",
        paddingTop: "max(6px, env(safe-area-inset-top, 0px))",
        textAlign: "center",
      }}>
        <div style={{
          maxWidth:1200,margin:"0 auto",display:"flex",justifyContent:"center",alignItems:"center",
          flexWrap:"wrap",gap:"6px 10px",fontSize:"clamp(10px, 2.6vw, 12px)",lineHeight:1.35,
        }}>
          <span style={{color:"rgba(255,255,255,.85)"}}>📍 Radiodifusora 100, Iztapalapa, CDMX</span>
          <span style={{color:"rgba(255,255,255,.85)"}}>🕐 Lun–Vie 8:00–22:00 · Sáb 8:00–20:00 · Dom 9:00–18:00</span>
          <span style={{color:"rgba(255,255,255,.75)"}}>📧 contacto@farmax.mx</span>
        </div>
      </div>
      <header style={{background:C.white,borderBottom:`1px solid ${C.border}`}}>
        <div style={{
          maxWidth:1200,margin:"0 auto",padding:"8px 12px 10px",paddingLeft:"max(12px, env(safe-area-inset-left, 0px))",paddingRight:"max(12px, env(safe-area-inset-right, 0px))",
          display:"flex",flexDirection:narrow?"column":"row",alignItems:narrow?"stretch":"center",
          justifyContent:"space-between",gap:narrow?10:8,flexWrap:narrow?"nowrap":"wrap",minHeight:52,
        }}>
          <div style={{display:"flex",alignItems:"center",justifyContent:"space-between",gap:10,width:narrow?"100%":"auto",minWidth:0}}>
            <div style={{display:"flex",alignItems:"center",gap:10,flex:"1 1 auto",minWidth:0}}>
              <div onClick={()=>setPage("home")} style={{cursor:"pointer",flexShrink:0}}><Logo size={narrow?28:32}/></div>
              {!narrow && (
                <nav style={{display:"flex",gap:4,flexWrap:"wrap"}}>{NAV_LINKS.map(([id,l])=>navBtn(id,l))}</nav>
              )}
            </div>
            {narrow && (
              <div style={{display:"flex",alignItems:"center",gap:6,flexShrink:0}}>
                <button type="button" aria-label="Ir al carrito" onClick={()=>setPage("carrito")} style={{position:"relative",background:"none",border:"none",cursor:"pointer",padding:8}}>
                  <span style={{fontSize:22}}>🛒</span>
                  {n>0&&<span style={{position:"absolute",top:2,right:2,background:C.red,color:C.white,borderRadius:"50%",width:18,height:18,fontSize:10,fontWeight:800,display:"flex",alignItems:"center",justifyContent:"center"}}>{n}</span>}
                </button>
                <button
                  type="button"
                  aria-label={mobileMenu?"Cerrar menú":"Abrir menú"}
                  aria-expanded={mobileMenu}
                  onClick={()=>setMobileMenu(m=>!m)}
                  style={{
                    width:44,height:40,borderRadius:10,border:`1px solid ${C.border}`,background:C.card,
                    cursor:"pointer",fontSize:18,color:C.dark,flexShrink:0,
                  }}
                >☰</button>
              </div>
            )}
          </div>
          <div style={{display:"flex",alignItems:"center",gap:8,flexShrink:0,flexWrap:"wrap",justifyContent:narrow?"stretch":"flex-end",width:narrow?"100%":"auto"}}>
            {user?(
              <div style={{display:"flex",alignItems:"center",gap:6,flexWrap:"wrap",width:narrow?"100%":"auto"}}>
                <div onClick={()=>setPage("cuenta")} style={{display:"flex",alignItems:"center",gap:8,cursor:"pointer",padding:"6px 10px",borderRadius:10,background:BRAND.primary+"18",maxWidth:narrow?"100%":undefined,minWidth:0,flex:"1 1 auto"}}>
                  <div style={{width:28,height:28,borderRadius:"50%",background:BRAND.gradient,display:"flex",alignItems:"center",justifyContent:"center",color:C.white,fontWeight:800,fontSize:13,flexShrink:0}}>{(primerNombre(user.nombre)||"C")[0].toUpperCase()}</div>
                  <div style={{minWidth:0,overflow:"hidden",flex:1}}>
                    <div style={{color:BRAND.primary,fontWeight:700,fontSize:12,lineHeight:1,whiteSpace:"nowrap",textOverflow:"ellipsis",overflow:"hidden",maxWidth:"100%"}}>{saludoUsuario(user.nombre)}</div>
                    <div style={{color:BRAND.secondary,fontSize:10}}>⭐ {user.puntos||0} pts</div>
                  </div>
                </div>
                <button type="button" onClick={async()=>{
                  const tok = sessionStorage.getItem("farmax_cliente_token");
                  if (tok) { try { await supabase.rpc("logout_cliente", { p_session_token: tok }); } catch(e){} }
                  sessionStorage.removeItem("farmax_cliente_token");
                  sessionStorage.removeItem("farmax_user");
                  setUser(null); setPage("home");
                }}
                  title="Cerrar sesión"
                  style={{padding:"6px 10px",borderRadius:8,border:`1px solid ${C.border}`,background:"transparent",color:C.mid,fontSize:12,fontWeight:700,cursor:"pointer",display:"flex",alignItems:"center",gap:4}}>
                  ⎋ <span style={{fontSize:11}}>Salir</span>
                </button>
                {!narrow && (
                  <>
                    <button type="button" aria-label="Ir al carrito" onClick={()=>setPage("carrito")} style={{position:"relative",background:"none",border:"none",cursor:"pointer",padding:8}}>
                      <span style={{fontSize:22}}>🛒</span>
                      {n>0&&<span style={{position:"absolute",top:2,right:2,background:C.red,color:C.white,borderRadius:"50%",width:18,height:18,fontSize:10,fontWeight:800,display:"flex",alignItems:"center",justifyContent:"center"}}>{n}</span>}
                    </button>
                  </>
                )}
              </div>
            ):(
              <div style={{
                display:"flex",
                gap:compactNav?6:8,
                flexWrap:narrow?"nowrap":"wrap",
                alignItems:"center",
                width:narrow?"100%":"auto",
              }}>
                <Btn onClick={()=>setPage("registro")} col={BRAND.accent} sm style={{
                  ...(compactNav?{padding:"6px 10px",fontSize:12}:{}),
                  ...(narrow?{flex:1,minWidth:0}:{}),
                }}>{compactNav?"Registro":"Crear cuenta"}</Btn>
                <Btn onClick={()=>setPage("login")} outline col={BRAND.primary} sm style={{
                  ...(compactNav?{padding:"6px 10px",fontSize:12}:{}),
                  ...(narrow?{flex:1,minWidth:0}:{}),
                }}>{compactNav?"Entrar":"Iniciar sesión"}</Btn>
              </div>
            )}
            {!narrow && !user && (
              <button type="button" aria-label="Ir al carrito" onClick={()=>setPage("carrito")} style={{position:"relative",background:"none",border:"none",cursor:"pointer",padding:8}}>
                <span style={{fontSize:22}}>🛒</span>
                {n>0&&<span style={{position:"absolute",top:2,right:2,background:C.red,color:C.white,borderRadius:"50%",width:18,height:18,fontSize:10,fontWeight:800,display:"flex",alignItems:"center",justifyContent:"center"}}>{n}</span>}
              </button>
            )}
          </div>
        </div>
        {narrow && mobileMenu && (
          <nav style={{
            borderTop:`1px solid ${C.border}`,padding:"8px 16px 14px",
            display:"flex",flexDirection:"column",gap:2,background:C.white,
          }}>
            {NAV_LINKS.map(([id,l])=>navBtn(id,l))}
          </nav>
        )}
      </header>
    </div>
  );
}

// ── PRODUCT CARD ──────────────────────────────────────────────
function ProductCard({prod,addToCart,onClick}){
  const C = useTheme();
  const narrow = useMediaQuery("(max-width: 768px)");
  const [added,setAdded]=useState(false);
  const d=prod.disponible||(prod.stock>0?"inmediato":"48hrs");
  const placeholderUrl = useContext(TiendaPlaceholderCtx);
  const imgSrc = productImageUrl(prod, narrow, placeholderUrl);
  return(
    <div style={{background:C.white,borderRadius:14,border:`1px solid ${C.border}`,overflow:"hidden",display:"flex",flexDirection:"column",cursor:"pointer",transition:"box-shadow .2s"}}
      onMouseEnter={e=>(e.currentTarget.style.boxShadow="0 4px 20px #0002")}
      onMouseLeave={e=>(e.currentTarget.style.boxShadow="none")}>
      <div
        onClick={onClick}
        style={{
          background:C.cardDark,
          overflow:"hidden",
          minHeight:152,
          height:152,
          display:"flex",
          alignItems:"center",
          justifyContent:"center",
          padding:"10px 12px",
        }}
      >
        {imgSrc ? (
          <img
            src={imgSrc}
            alt=""
            style={{maxWidth:"100%",maxHeight:"100%",width:"auto",height:"auto",objectFit:"contain",display:"block"}}
          />
        ) : (
          <div style={{padding:"24px",textAlign:"center",fontSize:48}}>💊</div>
        )}
      </div>
      <div style={{padding:"14px",flex:1,display:"flex",flexDirection:"column"}}>
        <div style={{display:"flex",gap:4,flexWrap:"wrap",marginBottom:8}}>
          {prod.stock===0
            ? <Tag col={C.red} sm>⛔ Agotado</Tag>
            : prod.stock<=3
              ? <Tag col="#f59e0b" sm>⚡ Últimas {prod.stock}</Tag>
              : <Tag col={d==="inmediato"?BRAND.accent:"#f59e0b"} sm>{d==="inmediato"?"✓ Hoy":"📦 24-48 hrs"}</Tag>
          }
          {prod.tipo==="generico"&&<Tag col={BRAND.secondary} sm>Genérico</Tag>}
          {prod.requiere_receta&&<Tag col={C.red} sm>Rx</Tag>}
          {prod.descuento_pct>0&&<span style={{background:C.red,color:"#fff",fontSize:9,fontWeight:800,borderRadius:4,padding:"2px 6px"}}>-{prod.descuento_pct}% OFF</span>}
        </div>
        <div onClick={onClick} style={{color:C.dark,fontWeight:700,fontSize:14,marginBottom:4,lineHeight:1.3}}>{prod.nombre}</div>
        <div style={{color:C.dim,fontSize:11,marginBottom:8,flex:1}}>{prod.descripcion}</div>
        <div style={{marginBottom:10}}>
          <div style={{display:"flex",alignItems:"baseline",gap:8}}>
            <span style={{color:BRAND.primary,fontWeight:900,fontSize:20}}>{$(prod.precio||prod.precio||0)}</span>
            {prod.precio_marca&&<span style={{color:C.dim,fontSize:11,textDecoration:"line-through"}}>{$(prod.precio_marca)}</span>}
          </div>
          {prod.tipo==="generico"&&prod.precio_marca&&<div style={{color:BRAND.accent,fontSize:11,fontWeight:600}}>Ahorras {$(prod.precio_marca-prod.precio)}</div>}
        </div>
        <div style={{color:C.dim,fontSize:10,marginBottom:10}}>⭐ +{labelPts(ptsGana(prod.precio||prod.precio||0))}</div>
        <div style={{display:"flex",gap:8}}>
          <Btn onClick={onClick} outline col={BRAND.primary} sm style={{flex:1}}>Ver detalle</Btn>
          <Btn onClick={e=>{e.stopPropagation();if(prod.stock===0)return;if(!productoPermitidoEnTiendaFarmaciaWeb(prod)){alert(productoEsCategoriaMinisuperTienda(prod)?"Artículo de minisuper: no está en la tienda farmacia en línea. Disponible en sucursal.":"Este producto no está disponible para compra en línea (receta, controlado o no publicado en tienda).");return;}addToCart(prod);setAdded(true);setTimeout(()=>setAdded(false),1500);}} col={prod.stock===0||!productoPermitidoEnTiendaFarmaciaWeb(prod)?"#94a3b8":added?BRAND.secondary:BRAND.primary} sm style={{flex:1,opacity:(prod.stock===0||!productoPermitidoEnTiendaFarmaciaWeb(prod))?0.6:1,cursor:prod.stock===0||!productoPermitidoEnTiendaFarmaciaWeb(prod)?"not-allowed":"pointer"}}>{prod.stock===0?"Agotado":!productoPermitidoEnTiendaFarmaciaWeb(prod)?(productoEsCategoriaMinisuperTienda(prod)?"Solo minisuper":"Solo en mostrador"):added?"✓ Listo":"+ Carrito"}</Btn>
        </div>
      </div>
    </div>
  );
}

// ── DETALLE PRODUCTO ──────────────────────────────────────────
function DetalleProducto({prod,productos,addToCart,setPage,setProdDetalle,busqHero,setBusqHero}){
  const C = useTheme();
  const stack = useMediaQuery("(max-width: 700px)");
  const narrowSuggest = useMediaQuery("(max-width: 768px)");
  const [busqFocus,setBusqFocus]=useState(false);
  const [added,setAdded]=useState(false);
  const placeholderUrl = useContext(TiendaPlaceholderCtx);
  const poolSoloStock = useMemo(
    ()=>productos.filter(p=>p.activo!==false&&Number(p.stock)>0),
    [productos]
  );
  const suggestions = useMemo(
    ()=>(busqFocus&&String(busqHero||"").trim().length>=2?tiendaCatalogSearchSuggestions(poolSoloStock,busqHero,{limit:8}):[]),
    [poolSoloStock,busqHero,busqFocus]
  );
  const irACatalogoBusqueda = ()=>{
    const q = String(busqHero||"").trim();
    setBusqFocus(false);
    try { if (q) sessionStorage.setItem("farmax_busq", q); } catch (err) { /* ignore */ }
    setPage("catalogo");
    requestAnimationFrame(()=>{
      document.getElementById("farmax-catalogo-resultados")?.scrollIntoView({ behavior: "smooth", block: "start" });
    });
  };
  if(!prod) return null;
  const similares=productos.filter(p=>p.categoria===prod.categoria&&p.id!==prod.id).slice(0,4);
  const d=prod.disponible||(prod.stock>0?"inmediato":"48hrs");
  const imgSrc = productImageUrl(prod, stack, placeholderUrl);
  return(
    <div style={{maxWidth:1100,margin:"0 auto",padding:"clamp(20px, 4vw, 32px) 16px"}}>
      <div style={{background:C.white,borderRadius:14,border:`1px solid ${C.border}`,padding:16,marginBottom:20}}>
        <div style={{position:"relative",zIndex:25}}>
          <Inp
            value={busqHero||""}
            onChange={(e)=>{
              const v = e.target.value;
              setBusqHero?.(v);
              try { if (v.trim()) sessionStorage.setItem("farmax_busq", v); } catch (err) { /* ignore */ }
            }}
            onKeyDown={(e)=>{
              if (e.key === "Enter") {
                e.preventDefault();
                irACatalogoBusqueda();
              }
              if (e.key === "Escape") setBusqFocus(false);
            }}
            onFocus={()=>setBusqFocus(true)}
            onBlur={()=>setTimeout(()=>setBusqFocus(false),280)}
            placeholder="🔍 Buscar otro producto (nombre, principio activo, SKU…)"
            style={{width:"100%",boxSizing:"border-box",fontSize:16,marginBottom:0}}
          />
          {suggestions.length>0&&(
            <div role="listbox" aria-label="Sugerencias de búsqueda" style={{
              position:"absolute",left:0,right:0,top:"calc(100% + 4px)",
              background:C.white,border:`1px solid ${C.border}`,borderRadius:10,
              boxShadow:"0 16px 48px rgba(15,23,42,.12)",maxHeight:narrowSuggest?260:320,overflowY:"auto",
            }}>
              {suggestions.map((s)=>(
                <button
                  key={s.id}
                  type="button"
                  role="option"
                  onMouseDown={(e)=>e.preventDefault()}
                  onClick={()=>{
                    const row = productos.find((x)=>x.id===s.id);
                    if (row){
                      setProdDetalle(row);
                      setBusqFocus(false);
                      window.scrollTo({ top: 0, behavior: "smooth" });
                    }
                  }}
                  style={{
                    display:"block",width:"100%",textAlign:"left",padding:"10px 14px",border:"none",
                    borderBottom:`1px solid ${C.border}`,background:"transparent",cursor:"pointer",
                    fontFamily:"'Plus Jakarta Sans',sans-serif",
                  }}
                >
                  <div style={{color:C.dark,fontWeight:700,fontSize:13,lineHeight:1.35}}>{s.nombre}</div>
                  <div style={{color:C.dim,fontSize:11,marginTop:3,display:"flex",flexWrap:"wrap",gap:8}}>
                    {s.sku?<span>SKU <strong style={{color:BRAND.primary}}>{s.sku}</strong></span>:null}
                    {s.codigo_barras?<span>Cód. {s.codigo_barras}</span>:null}
                    {Number(s.stock)<=0?<span style={{color:C.red}}>Agotado</span>:null}
                  </div>
                </button>
              ))}
            </div>
          )}
        </div>
        <div style={{display:"flex",flexWrap:"wrap",gap:10,alignItems:"center",marginTop:12}}>
          <Btn sm col={BRAND.primary} onClick={irACatalogoBusqueda}>Ver resultados en catálogo</Btn>
          <span style={{color:C.dim,fontSize:12}}>Enter también abre el catálogo filtrado</span>
        </div>
      </div>
      <button type="button" onClick={()=>{ setProdDetalle(null); setPage("catalogo"); }} style={{background:"none",border:"none",color:BRAND.primary,cursor:"pointer",fontSize:14,fontWeight:700,marginBottom:20,display:"flex",alignItems:"center",gap:6}}>← Volver al catálogo</button>
      <div style={{display:"grid",gridTemplateColumns:stack?"1fr":"1fr 1fr",gap:stack?24:32,marginBottom:48}}>
        <div style={{background:C.cardDark,borderRadius:20,overflow:"hidden",display:"flex",alignItems:"center",justifyContent:"center",minHeight:stack?220:280,padding:stack?16:20}}>
          {imgSrc ? (
            <img src={imgSrc} alt="" style={{maxWidth:"100%",maxHeight:stack?360:420,width:"auto",height:"auto",objectFit:"contain",display:"block"}}/>
          ) : (
            <span style={{fontSize:"clamp(64px, 22vw, 120px)",padding:stack?32:48}}>💊</span>
          )}
        </div>
        <div>
          <div style={{display:"flex",gap:8,marginBottom:12,flexWrap:"wrap"}}>
            <Tag col={d==="inmediato"?BRAND.accent:"#f59e0b"}>{d==="inmediato"?"✓ Disponible hoy":"📦 24-48 hrs"}</Tag>
            {prod.tipo==="generico"&&<Tag col={BRAND.secondary}>Genérico</Tag>}
            {prod.requiere_receta&&<Tag col={C.red}>Requiere receta</Tag>}
            <Tag col={C.mid} sm>{prod.categoria}</Tag>
          </div>
          <h1 style={{color:C.dark,fontSize:"clamp(20px, 5vw, 28px)",fontWeight:800,marginBottom:8,lineHeight:1.25}}>{prod.nombre}</h1>
          {prod.marca&&<div style={{color:C.mid,fontSize:14,marginBottom:16}}>Marca de referencia: {prod.marca}</div>}
          <div style={{marginBottom:20}}>
            <div style={{display:"flex",alignItems:"baseline",gap:12,flexWrap:"wrap"}}>
              <span style={{color:BRAND.primary,fontWeight:900,fontSize:"clamp(26px, 7vw, 36px)"}}>{$(prod.precio||prod.precio||0)}</span>
              {prod.precio_marca&&<span style={{color:C.dim,fontSize:16,textDecoration:"line-through"}}>{$(prod.precio_marca)} marca</span>}
            </div>
            {prod.tipo==="generico"&&prod.precio_marca&&(
              <div style={{background:BRAND.accent+"18",border:`1px solid ${BRAND.accent}30`,borderRadius:8,padding:"8px 12px",marginTop:8,display:"inline-block"}}>
                <span style={{color:BRAND.accent,fontWeight:700}}>Ahorras {$(prod.precio_marca-(prod.precio||prod.precio||0))} vs marca</span>
              </div>
            )}
          </div>
          <div style={{background:"#fef3c7",border:"1px solid #f59e0b30",borderRadius:10,padding:"10px 14px",marginBottom:20}}>
            <div style={{color:"#92400e",fontWeight:700}}>⭐ Ganas {labelPts(ptsGana(prod.precio))} con esta compra</div>
          </div>
          {prod.descripcion&&(
            <div style={{background:C.cardDark,borderRadius:12,padding:16,marginBottom:20}}>
              <div style={{color:C.dark,fontWeight:700,fontSize:14,marginBottom:6}}>Descripción</div>
              <div style={{color:C.mid,fontSize:14,lineHeight:1.7}}>{prod.descripcion}</div>
            </div>
          )}
          {prod.requiere_receta&&(
            <div style={{background:C.red+"10",border:`1px solid ${C.red}30`,borderRadius:10,padding:"10px 14px",marginBottom:16}}>
              <div style={{color:C.red,fontWeight:700,fontSize:13}}>⚕ Requiere receta médica. Se solicitará al entregar.</div>
            </div>
          )}
          <div style={{display:"flex",gap:12,flexWrap:"wrap"}}>
            <Btn onClick={()=>{addToCart(prod);setAdded(true);setTimeout(()=>setAdded(false),1500);}} col={added?BRAND.secondary:BRAND.primary} style={{flex:"1 1 min(100%,200px)",minWidth:0}}>{added?"✓ Agregado":"Agregar al carrito"}</Btn>
            <Btn onClick={()=>{addToCart(prod);setPage("carrito");}} outline col={BRAND.primary} style={{flex:"1 1 min(100%,200px)",minWidth:0}}>Comprar ahora</Btn>
          </div>
        </div>
      </div>
      {similares.length>0&&(
        <div>
          <h2 style={{color:C.dark,fontSize:20,fontWeight:800,marginBottom:16}}>Productos similares</h2>
          <div style={{display:"grid",gridTemplateColumns:"repeat(auto-fill,minmax(min(100%,200px),1fr))",gap:14}}>
            {similares.map(p=><ProductCard key={p.id} prod={p} addToCart={addToCart} onClick={()=>{setProdDetalle(p);window.scrollTo({top:0,behavior:'smooth'});}}/>)}
          </div>
        </div>
      )}
    </div>
  );
}

// ── FOOTER COMPLETO ───────────────────────────────────────────
function Footer({setPage}){
  const C = useTheme();
  const stack = useMediaQuery("(max-width: 768px)");
  const goSurtirReceta = () => {
    try {
      sessionStorage.removeItem("farmax_cat");
      sessionStorage.removeItem("farmax_busq");
      sessionStorage.removeItem("farmax_tipo");
    } catch (_) { /* noop */ }
    setPage("catalogo");
  };
  return(
    <footer style={{background:C.dark,marginTop:48}}>
      {/* Links principales */}
      <div style={{maxWidth:1200,margin:"0 auto",padding:"48px 24px 32px",display:"grid",gridTemplateColumns:stack?"1fr":"repeat(4,1fr)",gap:stack?28:32}}>
        {/* Farmax */}
        <div>
          <div style={{marginBottom:16}}><Logo size={28} light/></div>
          <p style={{color:"rgba(255,255,255,.6)",fontSize:13,lineHeight:1.7,marginBottom:16}}>Tu farmacia de confianza en Chinampac de Juárez. Medicamentos genéricos y de marca certificados por COFEPRIS.</p>
          <div style={{color:"rgba(255,255,255,.5)",fontSize:12}}>📍 {CONTACTO.direccion}</div>
        </div>
        {/* Atención a clientes */}
        <div>
          <div style={{color:C.white,fontWeight:700,fontSize:14,marginBottom:16,textTransform:"uppercase",letterSpacing:1}}>Atención a clientes</div>
          {[
            // ["📞 Teléfono", "55 XXXX XXXX", null],        // Descomentar cuando tengas número
            // ["💬 WhatsApp", "55 XXXX XXXX", null],        // Descomentar cuando tengas WhatsApp
            ["📧 Correo", "contacto@farmax.mx", null],
            ["🕐 Horario", CONTACTO.horario, null],
            ["📍 Dirección", "Radiodifusora 100, Iztapalapa", ()=>setPage("cita")],
          ].map(([l,v,fn])=>(
            <div key={l} style={{marginBottom:10}}>
              <div style={{color:"rgba(255,255,255,.5)",fontSize:11,marginBottom:2}}>{l}</div>
              <div onClick={fn||undefined} style={{color:fn?"rgba(255,255,255,.8)":"rgba(255,255,255,.7)",fontSize:13,cursor:fn?"pointer":"default",textDecoration:fn?"underline":"none"}}>{v}</div>
            </div>
          ))}
        </div>
        {/* Mi consultorio */}
        <div>
          <div style={{color:C.white,fontWeight:700,fontSize:14,marginBottom:16,textTransform:"uppercase",letterSpacing:1}}>Mi consultorio</div>
          {[["📅 Agendar cita","cita"],["📋 Preguntas frecuentes","faq"],["💊 Surtir receta","catalogo"],["⭐ Mis puntos Farmax","puntos"],["👤 Mi cuenta","cuenta"]].map(([l,pg])=>(
            <button key={l} onClick={()=> l==="💊 Surtir receta" ? goSurtirReceta() : setPage(pg)} style={{display:"block",background:"none",border:"none",color:"rgba(255,255,255,.6)",fontSize:13,cursor:"pointer",marginBottom:8,textAlign:"left",padding:0,fontFamily:"'Plus Jakarta Sans',sans-serif"}}
              onMouseEnter={e=>(e.currentTarget.style.color="rgba(255,255,255,.9)")}
              onMouseLeave={e=>(e.currentTarget.style.color="rgba(255,255,255,.6)")}>{l}</button>
          ))}
        </div>
        {/* Políticas */}
        <div>
          <div style={{color:C.white,fontWeight:700,fontSize:14,marginBottom:16,textTransform:"uppercase",letterSpacing:1}}>Información legal</div>
          {[["📄 Aviso de privacidad","privacidad"],["📋 Términos y condiciones","terminos"],["📦 Política de envíos","envios"],["⭐ Programa Puntos Farmax","terminos-puntos"]].map(([l,pg])=>(
            <button key={l} onClick={()=>setPage(pg)} style={{display:"block",background:"none",border:"none",color:"rgba(255,255,255,.6)",fontSize:13,cursor:"pointer",marginBottom:8,textAlign:"left",padding:0,fontFamily:"'Plus Jakarta Sans',sans-serif"}}
              onMouseEnter={e=>(e.currentTarget.style.color="rgba(255,255,255,.9)")}
              onMouseLeave={e=>(e.currentTarget.style.color="rgba(255,255,255,.6)")}>{l}</button>
          ))}
        </div>
      </div>
      {/* Métodos de pago */}
      <div style={{borderTop:"1px solid rgba(255,255,255,.1)",padding:"20px 24px"}}>
        <div style={{maxWidth:1200,margin:"0 auto",display:"flex",justifyContent:"space-between",alignItems:"center",flexWrap:"wrap",gap:16}}>
          <div style={{display:"flex",gap:10,alignItems:"center",flexWrap:"wrap"}}>
            <span style={{color:"rgba(255,255,255,.5)",fontSize:12}}>Métodos de pago:</span>
            {["🔵 Mercado Pago"].map(m=>(
              <span key={m} style={{background:"rgba(255,255,255,.1)",color:"rgba(255,255,255,.7)",fontSize:11,padding:"3px 10px",borderRadius:20}}>{m}</span>
            ))}
          </div>
          <div style={{color:"rgba(255,255,255,.3)",fontSize:11,textAlign:"right"}}>
            Responsable sanitario: Q.F.B. · COFEPRIS<br/>
            © 2026 Farmax — Todos los derechos reservados
          </div>
        </div>
      </div>
    </footer>
  );
}

// ── HOME ──────────────────────────────────────────────────────
function Home({setPage,addToCart,productos,setProdDetalle,busqHero,setBusqHero,precioConsulta}){
  const C = useTheme();
  const stack = useMediaQuery("(max-width: 768px)");
  const [promos, setPromos] = useState([]);
  const [bannerZones, setBannerZones] = useState({hero:[], strip:[], tile:[]});
  const [bannerMeta, setBannerMeta] = useState({ status: "loading", total: 0 });
  const [heroBusqFocus, setHeroBusqFocus] = useState(false);
  const poolHeroStock = useMemo(
    () => productos.filter((p) => p.activo !== false),
    [productos]
  );
  const heroSuggestions = useMemo(
    () =>
      heroBusqFocus && busqHero.trim().length >= 2
        ? tiendaCatalogSearchSuggestions(poolHeroStock, busqHero, { limit: 8 })
        : [],
    [poolHeroStock, busqHero, heroBusqFocus]
  );

  useEffect(()=>{
    const hoy = new Date().toISOString().split("T")[0];
    supabase.from("promociones").select("*")
      .eq("activa",true)
      .or(`fecha_fin.is.null,fecha_fin.gte.${hoy}`)
      .then(({data})=>setPromos(data||[]));
  },[]);

  useEffect(()=>{
    let cancelled = false;
    const loadBanners = ()=>{
      supabase.from("banners").select("*").eq("activo",true).order("orden").then(({data, error})=>{
        if (cancelled) return;
        if (error) {
          console.warn("[Tienda] banners:", error.message);
          setBannerMeta({ status: "error", total: 0 });
          setBannerZones({hero:[], strip:[], tile:[]});
          return;
        }
        const rows = (data||[]).map(mapBannerFromRow);
        setBannerMeta({ status: "ok", total: rows.length });
        setBannerZones({
          hero: rows.filter(r=>r.slot==="hero"),
          strip: rows.filter(r=>r.slot==="strip"),
          tile: rows.filter(r=>r.slot==="tile"),
        });
      });
    };
    loadBanners();
    const onVis = ()=>{ if (document.visibilityState==="visible") loadBanners(); };
    document.addEventListener("visibilitychange", onVis);
    return ()=>{ cancelled = true; document.removeEventListener("visibilitychange", onVis); };
  },[]);

  const useStaticHero =
    bannerMeta.status !== "ok" || bannerMeta.total === 0;

  return(
    <div>
      <HeroCarousel
        setPage={setPage}
        items={bannerZones.hero}
        precioConsulta={precioConsulta}
        stack={stack}
        useStaticPlaceholder={useStaticHero}
      />

      {/* Badges */}
      <div style={{background:C.white,borderBottom:`1px solid ${C.border}`,padding:"14px clamp(12px,4vw,24px)"}}>
        <div style={{maxWidth:1200,margin:"0 auto",display:"flex",gap:"clamp(10px,3vw,24px)",justifyContent:"center",flexWrap:"wrap"}}>
          {[["🚀","Pick-up gratis","Recoge hoy en Farmax"],["🛵","CDMX express","Rappi & Uber Connect"],["📦","Envío foráneo","$89 · Skydropx"],["⭐","Puntos Farmax","Acumula en cada compra"],["💳","Pago online","Mercado Pago (pasarela externa)"]].map(([icon,t,s])=>(
            <div key={t} style={{display:"flex",alignItems:"center",gap:8}}>
              <div style={{fontSize:20}}>{icon}</div>
              <div><div style={{color:C.dark,fontWeight:700,fontSize:12}}>{t}</div><div style={{color:C.dim,fontSize:11}}>{s}</div></div>
            </div>
          ))}
        </div>
      </div>

      <HomeBannersStrip setPage={setPage} items={bannerZones.strip}/>

      {/* Barra búsqueda */}
      <div style={{background:`linear-gradient(180deg,${BRAND.primary}10,transparent)`,padding:"24px 16px"}}>
        <div style={{maxWidth:600,margin:"0 auto",position:"relative",zIndex:30}}>
          <input
            value={busqHero}
            onChange={(e)=>setBusqHero(e.target.value)}
            onFocus={()=>setHeroBusqFocus(true)}
            onBlur={()=>setTimeout(()=>setHeroBusqFocus(false),280)}
            onKeyDown={(e)=>{
              if(e.key==="Enter"&&busqHero.trim()){
                try{
                  const t=busqHero.trim();
                  sessionStorage.setItem("farmax_busq",t);
                  const p=JSON.parse(localStorage.getItem("farmax_busqs")||"[]");
                  localStorage.setItem("farmax_busqs",JSON.stringify([t,...p.filter(b=>b!==t)].slice(0,5)));
                }catch(err){}
                setPage("catalogo");
              }
            }}
            placeholder="🔍 Nombre, principio activo, SKU o código de barras…"
            autoComplete="off"
            style={{width:"100%",boxSizing:"border-box",padding:"16px 56px 16px 20px",borderRadius:30,border:`2px solid ${BRAND.primary}30`,fontSize:16,fontFamily:"'Plus Jakarta Sans',sans-serif",outline:"none",background:C.white,boxShadow:"0 4px 20px rgba(0,82,204,.1)"}}
          />
          <button
            type="button"
            onClick={()=>{
              const t=busqHero.trim();
              if(!t)return;
              try{sessionStorage.setItem("farmax_busq",t);}catch(e){}
              setPage("catalogo");
            }}
            style={{position:"absolute",right:6,top:"50%",transform:"translateY(-50%)",background:BRAND.gradient,border:"none",borderRadius:24,width:44,height:44,cursor:"pointer",color:C.white,fontSize:18,display:"flex",alignItems:"center",justifyContent:"center"}}
          >→</button>
          {heroSuggestions.length>0&&(
            <div role="listbox" aria-label="Sugerencias de búsqueda" style={{
              position:"absolute",left:0,right:0,top:"calc(100% + 6px)",
              background:C.white,border:`1px solid ${C.border}`,borderRadius:14,
              boxShadow:"0 16px 48px rgba(15,23,42,.14)",maxHeight:stack?260:300,overflowY:"auto",
            }}>
              {heroSuggestions.map((s)=>{
                const row=productos.find((x)=>x.id===s.id);
                return(
                  <button
                    key={s.id}
                    type="button"
                    role="option"
                    onMouseDown={(e)=>e.preventDefault()}
                    onClick={()=>{
                      if(row){ setProdDetalle(row); setPage("detalle"); }
                      setHeroBusqFocus(false);
                    }}
                    style={{
                      display:"block",width:"100%",textAlign:"left",padding:"10px 14px",border:"none",
                      borderBottom:`1px solid ${C.border}`,background:"transparent",cursor:"pointer",
                      fontFamily:"'Plus Jakarta Sans',sans-serif",
                    }}
                  >
                    <div style={{color:C.dark,fontWeight:700,fontSize:13,lineHeight:1.35}}>{s.nombre}</div>
                    <div style={{color:C.dim,fontSize:11,marginTop:3,display:"flex",flexWrap:"wrap",gap:8}}>
                      {s.sku?<span>SKU <strong style={{color:BRAND.primary}}>{s.sku}</strong></span>:null}
                      {Number(s.stock)<=0?<span style={{color:C.red}}>Agotado</span>:null}
                    </div>
                  </button>
                );
              })}
            </div>
          )}
        </div>
      </div>

      <HomeBannersTiles setPage={setPage} items={bannerZones.tile} stack={stack}/>

      {/* Promociones y descuentos (tabla promociones + Admin módulo Promociones) */}
      <div style={{maxWidth:1200,margin:"0 auto",padding:"8px 16px 32px"}}>
        <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:16,flexWrap:"wrap",gap:12}}>
          <div>
            <h2 style={{color:C.dark,fontSize:"clamp(18px,4.2vw,22px)",fontWeight:800,margin:0}}>🏷️ Promociones y descuentos</h2>
            <p style={{color:C.mid,fontSize:12,margin:"6px 0 0",maxWidth:520}}>
              Ofertas activas gestionadas en el panel <strong>Promociones</strong>. Los banners del inicio pueden enviar a la página <button type="button" onClick={()=>setPage("promo")} style={{background:"none",border:"none",padding:0,color:BRAND.primary,fontWeight:700,cursor:"pointer",textDecoration:"underline"}}>Promociones</button>.
            </p>
          </div>
          <Btn onClick={()=>setPage("promo")} outline col={BRAND.primary} sm>Ver todas →</Btn>
        </div>
        {promos.length>0 ? (
          <div style={{display:"grid",gridTemplateColumns:"repeat(auto-fill,minmax(min(100%,260px),1fr))",gap:12}}>
            {promos.map(p=>(
              <div key={p.id} style={{background:"#fff",borderRadius:14,border:`2px solid ${BRAND.primary}25`,padding:18,display:"flex",flexDirection:"column",gap:8,boxShadow:"0 2px 12px rgba(0,82,204,.06)"}}>
                <div style={{display:"flex",justifyContent:"space-between",alignItems:"flex-start",gap:8}}>
                  <span style={{fontWeight:800,color:C.dark,fontSize:15,lineHeight:1.3}}>{p.nombre}</span>
                  <span style={{padding:"3px 10px",borderRadius:20,fontSize:11,fontWeight:700,flexShrink:0,
                    background:p.tipo==="descuento_pct"?"#eff6ff":p.tipo==="2x1"?"#ede9fe":"#dcfce7",
                    color:p.tipo==="descuento_pct"?BRAND.primary:p.tipo==="2x1"?"#7c3aed":"#16a34a"}}>
                    {p.tipo==="descuento_pct"?`${p.valor}% OFF`:p.tipo==="descuento_fijo"?`$${p.valor} OFF`:p.tipo==="2x1"?"2×1":"Combo"}
                  </span>
                </div>
                {p.descripcion&&<p style={{color:C.mid,fontSize:13,margin:0,lineHeight:1.5}}>{p.descripcion}</p>}
                {p.fecha_fin&&<div style={{color:C.dim,fontSize:11}}>⏰ Válido hasta: {p.fecha_fin}</div>}
                <div style={{display:"flex",gap:8,flexWrap:"wrap",marginTop:4}}>
                  <Btn onClick={()=>setPage("catalogo")} col={BRAND.primary} sm>Ver productos</Btn>
                  <Btn onClick={()=>setPage("promo")} outline col={BRAND.primary} sm>Detalle</Btn>
                </div>
              </div>
            ))}
          </div>
        ) : (
          <div style={{background:C.cardDark,borderRadius:14,border:`1px dashed ${C.border}`,padding:28,textAlign:"center"}}>
            <div style={{fontSize:32,marginBottom:8}}>📣</div>
            <div style={{color:C.dark,fontWeight:700,fontSize:15,marginBottom:6}}>Próximamente nuevas ofertas</div>
            <div style={{color:C.mid,fontSize:13,marginBottom:16,maxWidth:400,marginLeft:"auto",marginRight:"auto",lineHeight:1.5}}>
              Cuando cargues promociones en administración aparecerán aquí. Mientras tanto, explorá el catálogo o activá banners con destino <strong>promo</strong>.
            </div>
            <div style={{display:"flex",gap:10,justifyContent:"center",flexWrap:"wrap"}}>
              <Btn onClick={()=>setPage("catalogo")} col={BRAND.primary} sm>Ir al catálogo</Btn>
              <Btn onClick={()=>setPage("promo")} outline col={BRAND.primary} sm>Página promociones</Btn>
            </div>
          </div>
        )}
      </div>

      {/* Más vendidos */}
      <div style={{maxWidth:1200,margin:"0 auto",padding:"0 16px 48px"}}>
        <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:24,flexWrap:"wrap",gap:12}}>
          <h2 style={{color:C.dark,fontSize:"clamp(20px,4.5vw,24px)",fontWeight:800,margin:0}}>🔥 Más vendidos en Farmax</h2>
          <Btn onClick={()=>setPage("catalogo")} outline col={BRAND.primary} sm>Ver catálogo →</Btn>
        </div>
        <div style={{display:"grid",gridTemplateColumns:"repeat(auto-fill,minmax(min(100%,220px),1fr))",gap:16}}>
          {productos.slice(0,6).map(p=><ProductCard key={p.id} prod={p} addToCart={addToCart} onClick={()=>{setProdDetalle(p);setPage("detalle");}}/>)}
        </div>
      </div>

      {/* Consultorio */}
      <div style={{background:BRAND.primary+"12",padding:"48px 24px"}}>
        <div style={{maxWidth:800,margin:"0 auto",textAlign:"center"}}>
          <div style={{fontSize:48,marginBottom:16}}>🏥</div>
          <h2 style={{color:C.dark,fontSize:28,fontWeight:800,marginBottom:12}}>Consultorio médico Farmax</h2>
          <p style={{color:C.mid,fontSize:16,lineHeight:1.7,marginBottom:28}}>Atención médica general · <strong>{$(precioConsulta ?? CONSULTA_PRECIO_DEFAULT)} por consulta</strong> · O gratis con <strong style={{color:BRAND.primary}}>160 puntos Farmax</strong>. Al terminar tu consulta, surte tu receta con <strong>10% de descuento</strong>.</p>
          <Btn onClick={()=>setPage("cita")} col={BRAND.primary}>📅 Agendar cita online</Btn>
        </div>
      </div>

      {/* Puntos Farmax */}
      <div style={{maxWidth:1200,margin:"48px auto",padding:"0 16px"}}>
        <div style={{background:C.dark,borderRadius:20,padding:stack?"28px 20px":"40px",display:"grid",gridTemplateColumns:stack?"1fr":"1fr 1fr",gap:stack?28:40,alignItems:"center"}}>
          <div>
            <div style={{color:BRAND.secondary,fontWeight:700,fontSize:13,letterSpacing:2,textTransform:"uppercase",marginBottom:12}}>Programa de lealtad</div>
            <h2 style={{color:C.white,fontSize:"clamp(22px,5vw,28px)",fontWeight:800,marginBottom:16}}>⭐ Puntos Farmax</h2>
            <p style={{color:"rgba(255,255,255,.75)",fontSize:15,lineHeight:1.7,marginBottom:24}}>Acumula puntos en farmacia, minisuper y consultorio. Canjéalos por descuentos o consultas gratis.</p>
            <Btn onClick={()=>setPage("puntos")} style={{background:BRAND.accent,color:C.white,border:"none"}}>Ver programa de puntos</Btn>
          </div>
          <div style={{display:"grid",gridTemplateColumns:stack?"1fr":"1fr 1fr",gap:12}}>
            {[["$10 en Farmax","1 punto",BRAND.secondary],["1 consulta","5 puntos",BRAND.accent],["160 puntos","Consulta gratis","#ffaa00"],["100 puntos","$50 descuento","#9d6fff"]].map(([a,b,col])=>(
              <div key={a} style={{background:"rgba(255,255,255,.08)",borderRadius:12,padding:16,border:"1px solid rgba(255,255,255,.1)"}}>
                <div style={{color:col,fontWeight:700,fontSize:13,marginBottom:4}}>{b}</div>
                <div style={{color:"rgba(255,255,255,.6)",fontSize:12}}>{a}</div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* FAQ preview */}
      <div style={{maxWidth:1200,margin:"0 auto 48px",padding:"0 16px"}}>
        <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:20,flexWrap:"wrap",gap:12}}>
          <h2 style={{color:C.dark,fontSize:"clamp(18px,4vw,22px)",fontWeight:800,margin:0}}>❓ Preguntas frecuentes</h2>
          <Btn onClick={()=>setPage("faq")} outline col={BRAND.primary} sm>Ver todas →</Btn>
        </div>
        <div style={{display:"grid",gridTemplateColumns:stack?"1fr":"1fr 1fr",gap:12}}>
          {FAQ_ITEMS.slice(0,4).map((f,i)=>(
            <div key={i} style={{background:C.white,borderRadius:12,border:`1px solid ${C.border}`,padding:16,cursor:"pointer"}} onClick={()=>setPage("faq")}>
              <div style={{color:C.dark,fontWeight:700,fontSize:14,marginBottom:6}}>❓ {f.p}</div>
              <div style={{color:C.mid,fontSize:13,lineHeight:1.6}}>{f.r.slice(0,80)}...</div>
            </div>
          ))}
        </div>
      </div>

      <Footer setPage={setPage}/>
    </div>
  );
}

// ── CATÁLOGO ──────────────────────────────────────────────────
function Catalogo({addToCart,productos,setProdDetalle,setPage,busqHero,setBusqHero}){
  const C = useTheme();
  const stack = useMediaQuery("(max-width: 768px)");
  const [cat,setCat]=useState(()=>sessionStorage.getItem("farmax_cat")||"Todos");
  const [busq,setBusq]=useState(busqHero||sessionStorage.getItem("farmax_busq")||"");
  const [tipo,setTipo]=useState(()=>sessionStorage.getItem("farmax_tipo")||"todos");
  const [precioMax,setPrecioMax]=useState("");
  const [precioMin,setPrecioMin]=useState("");
  const [verAgotados,setVerAgotados]=useState(false);
  const [busqFocus,setBusqFocus]=useState(false);
  useEffect(()=>{ sessionStorage.setItem("farmax_cat",cat); },[cat]);
  useEffect(()=>{ sessionStorage.setItem("farmax_busq",busq); },[busq]);
  useEffect(()=>{ sessionStorage.setItem("farmax_tipo",tipo); },[tipo]);
  useEffect(()=>{
    const t = busqHero != null && String(busqHero).trim();
    if (t) {
      setBusq(busqHero);
      setTipo("todos");
      setCat("Todos");
    }
  },[busqHero]);
  const cats=["Todos",...new Set(productos.map(p=>p.categoria).filter(Boolean))];
  const basePool = useMemo(()=>productos
    .filter(p=>verAgotados?true:p.stock>0)
    .filter(p=>cat==="Todos"||p.categoria===cat)
    .filter(p=>tipo==="todos"||p.tipo===tipo)
    .filter(p=>!precioMin||parseFloat(p.precio)>=parseFloat(precioMin))
    .filter(p=>!precioMax||parseFloat(p.precio)<=parseFloat(precioMax)),
  [productos,verAgotados,cat,tipo,precioMin,precioMax]);
  const fil = useMemo(()=>{
    const q = busq.trim();
    const arr = basePool.filter((p)=>tiendaProductMatchesBusqueda(p, busq));
    if (!q) return arr;
    return [...arr].sort((a, b)=>{
      const ra = tiendaSearchRelevanceRank(a, busq);
      const rb = tiendaSearchRelevanceRank(b, busq);
      if (ra !== rb) return ra - rb;
      return String(a.nombre || "").localeCompare(String(b.nombre || ""), "es", { sensitivity: "base" });
    });
  }, [basePool, busq]);
  const poolSoloStock = useMemo(
    ()=>productos.filter(p=>p.activo!==false&&(verAgotados||Number(p.stock)>0)),
    [productos,verAgotados]
  );
  const suggestions = useMemo(
    ()=>(busqFocus&&busq.trim().length>=2?tiendaCatalogSearchSuggestions(poolSoloStock,busq,{limit:8}):[]),
    [poolSoloStock,busq,busqFocus]
  );
  const hayCoincidenciasSinFiltrosLaterales = useMemo(()=>{
    if (!busq.trim()) return false;
    const limpio = productos.filter(p=>p.activo!==false&&(verAgotados||Number(p.stock)>0));
    return limpio.some(p=>tiendaProductMatchesBusqueda(p,busq));
  },[productos,verAgotados,busq]);
  const filtrosLateralesActivos = cat!=="Todos"||tipo!=="todos"||!!String(precioMin).trim()||!!String(precioMax).trim();
  const spellHints = useMemo(
    ()=>(busq.trim().length>=3&&fil.length===0?spellSuggestFromProducts(poolSoloStock,busq):[]),
    [poolSoloStock,busq,fil.length]
  );
  const limpiarFiltrosLaterales = ()=>{
    setCat("Todos"); setTipo("todos"); setPrecioMin(""); setPrecioMax("");
  };
  const busqActiva = busq.trim().length > 0;
  return(
    <div style={{maxWidth:1200,margin:"0 auto",padding:"clamp(20px,4vw,32px) 16px"}}>
      <h1 style={{color:C.dark,fontSize:"clamp(22px,5vw,28px)",fontWeight:800,marginBottom:6}}>Catálogo Farmax</h1>
      <div style={{color:C.dim,fontSize:14,marginBottom:24}}>
        {busqActiva
          ? `${fil.length} resultado${fil.length === 1 ? "" : "s"} · refiná con filtros o escribí más palabras (ej. «ácido fólico»)`
          : `${fil.length} productos disponibles`}
      </div>
      <div style={{background:C.white,borderRadius:14,border:`1px solid ${C.border}`,padding:20,marginBottom:20}}>
        <div style={{position:"relative",marginBottom:16,zIndex:25}}>
        <Inp
          value={busq}
          onChange={(e)=>{
            const v = e.target.value;
            setBusq(v);
            setBusqHero?.(v);
            try {
              if (v.trim()) sessionStorage.setItem("farmax_busq", v);
            } catch (err) { /* ignore */ }
          }}
          onKeyDown={(e)=>{
            if (e.key === "Enter") {
              e.preventDefault();
              const q = busq.trim();
              setBusqFocus(false);
              try {
                if (q) sessionStorage.setItem("farmax_busq", q);
              } catch (err) { /* ignore */ }
              setBusqHero?.(busq);
              requestAnimationFrame(()=>{
                document.getElementById("farmax-catalogo-resultados")?.scrollIntoView({ behavior: "smooth", block: "start" });
              });
            }
            if (e.key === "Escape") setBusqFocus(false);
          }}
          onFocus={()=>setBusqFocus(true)}
          onBlur={()=>setTimeout(()=>setBusqFocus(false),280)}
          placeholder="🔍 Nombre, principio activo, marca, SKU o código…"
          style={{width:"100%",boxSizing:"border-box",fontSize:16,marginBottom:0}}
        />
        {suggestions.length>0&&(
          <div role="listbox" aria-label="Sugerencias de búsqueda" style={{
            position:"absolute",left:0,right:0,top:"calc(100% + 4px)",
            background:C.white,border:`1px solid ${C.border}`,borderRadius:10,
            boxShadow:"0 16px 48px rgba(15,23,42,.12)",maxHeight:stack?260:320,overflowY:"auto",
          }}>
            {suggestions.map((s)=>(
              <button
                key={s.id}
                type="button"
                role="option"
                onMouseDown={(e)=>e.preventDefault()}
                onClick={()=>{
                  const row = productos.find((x)=>x.id===s.id);
                  if (row){ setProdDetalle(row); setPage("detalle"); }
                  setBusqFocus(false);
                }}
                style={{
                  display:"block",width:"100%",textAlign:"left",padding:"10px 14px",border:"none",
                  borderBottom:`1px solid ${C.border}`,background:"transparent",cursor:"pointer",
                  fontFamily:"'Plus Jakarta Sans',sans-serif",
                }}
              >
                <div style={{color:C.dark,fontWeight:700,fontSize:13,lineHeight:1.35}}>{s.nombre}</div>
                <div style={{color:C.dim,fontSize:11,marginTop:3,display:"flex",flexWrap:"wrap",gap:8}}>
                  {s.sku?<span>SKU <strong style={{color:BRAND.primary}}>{s.sku}</strong></span>:null}
                  {s.codigo_barras?<span>Cód. {s.codigo_barras}</span>:null}
                  {Number(s.stock)<=0?<span style={{color:C.red}}>Agotado</span>:null}
                </div>
              </button>
            ))}
          </div>
        )}
        </div>
        {fil.length===0&&busq.trim()&&hayCoincidenciasSinFiltrosLaterales&&filtrosLateralesActivos&&(
          <div style={{marginBottom:14,padding:"10px 12px",borderRadius:10,background:"#fef3c7",border:"1px solid #f59e0b40",fontSize:13,color:"#92400e",lineHeight:1.5}}>
            Hay resultados para tu búsqueda pero los filtros de categoría, tipo o precio los ocultan.{" "}
            <button type="button" onClick={limpiarFiltrosLaterales} style={{background:"none",border:"none",padding:0,cursor:"pointer",color:BRAND.primary,fontWeight:800,textDecoration:"underline",fontSize:"inherit"}}>
              Quitar filtros y mostrar coincidencias
            </button>
          </div>
        )}
        {spellHints.length>0&&(
          <div style={{marginBottom:14,padding:"10px 12px",borderRadius:10,background:BRAND.primary+"12",border:`1px solid ${BRAND.primary}35`,fontSize:13,color:C.dark,lineHeight:1.5}}>
            <span style={{fontWeight:700,color:BRAND.primary}}>¿Quisiste decir? </span>
            {spellHints.map((h,i)=>(
              <span key={h.label}>
                {i>0&&" · "}
                <button type="button" onClick={()=>setBusq(h.label)} style={{background:"none",border:"none",padding:0,cursor:"pointer",color:BRAND.primary,fontWeight:700,textDecoration:"underline",fontSize:"inherit"}}>{h.label}</button>
              </span>
            ))}
          </div>
        )}
        <div style={{display:"flex",gap:6,flexWrap:"wrap",alignItems:"center"}}>
          {[["todos","Todos"],["generico","💊 Genérico"],["marca","® Marca"]].map(([v,l])=>(
            <button key={v} onClick={()=>setTipo(v)} style={{padding:"5px 12px",borderRadius:20,border:`1px solid ${tipo===v?BRAND.primary:C.border}`,background:tipo===v?BRAND.primary+"18":"transparent",color:tipo===v?BRAND.primary:C.mid,fontSize:12,cursor:"pointer",fontWeight:600}}>{l}</button>
          ))}
          <div style={{display:"flex",alignItems:"center",gap:6,marginLeft:"auto",flexWrap:"wrap"}}>
            <span style={{color:C.mid,fontSize:12}}>Precio:</span>
            <input type="number" placeholder="Min $" value={precioMin} onChange={e=>setPrecioMin(e.target.value)}
              style={{width:70,padding:"4px 8px",borderRadius:8,border:`1px solid ${C.border}`,fontSize:16,outline:"none"}}/>
            <span style={{color:C.dim,fontSize:12}}>—</span>
            <input type="number" placeholder="Max $" value={precioMax} onChange={e=>setPrecioMax(e.target.value)}
              style={{width:70,padding:"4px 8px",borderRadius:8,border:`1px solid ${C.border}`,fontSize:16,outline:"none"}}/>
            <button onClick={()=>setVerAgotados(p=>!p)} style={{
              padding:"4px 12px",borderRadius:20,fontSize:11,fontWeight:700,cursor:"pointer",
              border:`1px solid ${verAgotados?C.red:C.border}`,
              background:verAgotados?C.red+"15":"transparent",
              color:verAgotados?C.red:C.mid,
            }}>{verAgotados?"⛔ Ocultar agotados":"👁 Ver agotados"}</button>
          </div>
        </div>
      </div>
      <div style={{
        display: "grid",
        gap: 20,
        alignItems: "start",
        gridTemplateColumns: stack ? "1fr" : "180px 1fr",
        gridTemplateAreas: stack ? '"resultados" "categorias"' : '"categorias resultados"',
      }}>
        <div
          id="farmax-catalogo-resultados"
          style={{
            gridArea: "resultados",
            display: "grid",
            gridTemplateColumns: "repeat(auto-fill,minmax(min(100%, 200px), 1fr))",
            gap: 14,
            minWidth: 0,
            scrollMarginTop: 16,
          }}
        >
          {fil.length===0?(<div style={{padding:40,textAlign:"center",color:C.mid,gridColumn:"1/-1"}}>Sin resultados para "{busq}"</div>):fil.map(p=><ProductCard key={p.id} prod={p} addToCart={addToCart} onClick={()=>{setProdDetalle(p);setPage("detalle");}}/>)}
        </div>
        {stack && busqActiva ? (
          <details
            style={{
              gridArea: "categorias",
              width: "100%",
              background: C.white,
              borderRadius: 14,
              border: `1px solid ${C.border}`,
              padding: "8px 12px 12px",
              boxSizing: "border-box",
            }}
          >
            <summary style={{
              cursor: "pointer",
              color: C.dark,
              fontWeight: 700,
              fontSize: 14,
              padding: "8px 4px",
              listStyle: "none",
            }}>
              Categorías {cat !== "Todos" ? `· ${cat}` : ""} <span style={{ color: C.dim, fontWeight: 600, fontSize: 12 }}>(tocá para filtrar)</span>
            </summary>
            <div style={{ marginTop: 8, maxHeight: "min(50vh, 320px)", overflowY: "auto" }}>
              {cats.map((c) => (
                <button key={c} type="button" onClick={() => setCat(c)} style={{
                  width: "100%", textAlign: "left", padding: "8px 10px", borderRadius: 8, border: "none",
                  background: cat === c ? BRAND.primary + "18" : "transparent", color: cat === c ? BRAND.primary : C.mid, fontSize: 13, fontWeight: cat === c ? 700 : 400, cursor: "pointer", marginBottom: 2,
                }}>{c}</button>
              ))}
            </div>
          </details>
        ) : (
          <div style={{
            gridArea: "categorias",
            background: C.white,
            borderRadius: 14,
            border: `1px solid ${C.border}`,
            padding: 16,
            height: "fit-content",
            position: stack ? "relative" : "sticky",
            top: "calc(env(safe-area-inset-top, 0px) + 100px)",
          }}>
            <div style={{ color: C.dark, fontWeight: 700, fontSize: 13, marginBottom: 12 }}>Categorías</div>
            {cats.map((c) => (
              <button key={c} type="button" onClick={() => setCat(c)} style={{
                width: "100%", textAlign: "left", padding: "8px 10px", borderRadius: 8, border: "none",
                background: cat === c ? BRAND.primary + "18" : "transparent", color: cat === c ? BRAND.primary : C.mid, fontSize: 13, fontWeight: cat === c ? 700 : 400, cursor: "pointer", marginBottom: 2,
              }}>{c}</button>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

// ── CARRITO ───────────────────────────────────────────────────
function Carrito({cart,setCart,setPage,setEntregaGlobal}){
  const C = useTheme();
  const stack = useMediaQuery("(max-width: 768px)");
  const placeholderUrl = useContext(TiendaPlaceholderCtx);
  const [entrega,setEntrega]=useState("pickup");
  useEffect(()=>{ setEntregaGlobal?.(entrega); },[entrega,setEntregaGlobal]);
  const sub=cart.reduce((a,c)=>a+c.precio*c.qty,0);
  const qtyTouch = stack ? 44 : 28;
  const upd=(id,d)=>setCart(p=>p.map(c=>{
    if(c.id!==id) return c;
    const next = Math.max(1,c.qty+d);
    const max = Number(c.stock||next);
    return {...c,qty:Math.min(next,max)};
  }));
  const rm=id=>setCart(p=>p.filter(c=>c.id!==id));
  if(!cart.length) return(<div style={{maxWidth:600,margin:"80px auto",padding:"0 24px",textAlign:"center"}}><div style={{fontSize:64,marginBottom:16}}>🛒</div><h2 style={{color:C.dark,fontSize:24,fontWeight:800,marginBottom:16}}>Carrito vacío</h2><Btn onClick={()=>setPage("catalogo")} col={BRAND.primary}>Ver catálogo</Btn></div>);
  return(
    <div style={{maxWidth:1100,margin:"0 auto",padding:"clamp(20px,4vw,32px) 16px"}}>
      <h1 style={{color:C.dark,fontSize:"clamp(22px,5vw,26px)",fontWeight:800,marginBottom:24}}>🛒 Tu carrito</h1>
      <div style={{display:"grid",gridTemplateColumns:stack?"1fr":"1fr min(340px, 100%)",gap:24,alignItems:"start"}}>
        <div style={{minWidth:0}}>
          {cart.map(item=>{
            const lineImg = productImageUrl(item, stack, placeholderUrl);
            return (
            <div key={item.id} style={{background:C.white,borderRadius:14,border:`1px solid ${C.border}`,padding:16,marginBottom:12,display:"flex",gap:16,alignItems:"center",flexWrap:"wrap"}}>
              <div style={{background:C.cardDark,borderRadius:10,width:64,height:64,overflow:"hidden",flexShrink:0,display:"flex",alignItems:"center",justifyContent:"center"}}>
                {lineImg ? (
                  <img src={lineImg} alt="" style={{width:"100%",height:"100%",objectFit:"cover"}}/>
                ) : (
                  <span style={{fontSize:28}}>💊</span>
                )}
              </div>
              <div style={{flex:1}}><div style={{color:C.dark,fontWeight:700,fontSize:15}}>{item.nombre}</div><div style={{color:C.dim,fontSize:11,marginTop:4}}>+{labelPts(ptsGana(item.precio*item.qty))}</div></div>
              <div style={{display:"flex",alignItems:"center",gap:10,flexShrink:0,flexWrap:"wrap",marginLeft:"auto"}}>
                <div style={{display:"flex",alignItems:"center",gap:8}}>
                  <button type="button" aria-label="Disminuir cantidad" onClick={()=>upd(item.id,-1)} style={{width:qtyTouch,height:qtyTouch,borderRadius:8,border:`1px solid ${C.border}`,background:C.white,cursor:"pointer",fontSize:18,display:"flex",alignItems:"center",justifyContent:"center",padding:0}}>−</button>
                  <span style={{color:C.dark,fontWeight:700,fontSize:15,minWidth:24,textAlign:"center"}}>{item.qty}</span>
                  <button type="button" aria-label="Aumentar cantidad" onClick={()=>upd(item.id,1)} style={{width:qtyTouch,height:qtyTouch,borderRadius:8,border:`1px solid ${C.border}`,background:C.white,cursor:"pointer",fontSize:18,display:"flex",alignItems:"center",justifyContent:"center",padding:0}}>+</button>
                </div>
                <div style={{color:BRAND.primary,fontWeight:800,fontSize:18,minWidth:60,textAlign:"right"}}>{$(item.precio*item.qty)}</div>
                <button type="button" onClick={()=>rm(item.id)} style={{background:"none",border:"none",color:C.dim,cursor:"pointer",fontSize:18}}>🗑️</button>
              </div>
            </div>
          );})}
          <Btn onClick={()=>setPage("catalogo")} outline col={BRAND.primary} sm>← Seguir comprando</Btn>
        </div>
        <div style={{background:C.white,borderRadius:14,border:`1px solid ${C.border}`,padding:24,position:stack?"relative":"sticky",top:"calc(env(safe-area-inset-top, 0px) + 100px)"}}>
          <div style={{color:C.dark,fontWeight:800,fontSize:16,marginBottom:14}}>Tipo de entrega</div>
          {[["pickup","🏪 Pick-up en Farmax","Gratis · Mismo día"],["cdmx","🛵 Reparto CDMX","Rappi/Uber · Costo del servicio"],["foraneo","📦 Envío foráneo","$89 · 2-5 días · Skydropx"]].map(([v,l,s])=>(
            <div key={v} onClick={()=>setEntrega(v)} style={{padding:"12px 14px",borderRadius:10,border:`2px solid ${entrega===v?BRAND.primary:C.border}`,background:entrega===v?BRAND.primary+"18":C.white,cursor:"pointer",marginBottom:8}}>
              <div style={{color:entrega===v?BRAND.primary:C.dark,fontWeight:700,fontSize:14}}>{l}</div>
              <div style={{color:C.dim,fontSize:12,marginTop:2}}>{s}</div>
            </div>
          ))}
          {entrega==="cdmx"&&(<div style={{background:"#fef3c7",border:"1px solid #f59e0b30",borderRadius:8,padding:"10px 12px",marginBottom:8}}><div style={{color:"#92400e",fontSize:12}}>🛵 El repartidor irá a Farmax y entregará en tu domicilio al costo que muestre la app de Rappi o Uber.</div></div>)}
          {(entrega==="cdmx"||entrega==="foraneo")&&(
            <div style={{background:"#eff6ff",border:`1px solid ${BRAND.secondary}35`,borderRadius:8,padding:"10px 12px",marginBottom:8}}>
              <div style={{color:BRAND.primary,fontSize:11,lineHeight:1.45}}>
                Algunos productos no se envían (controlados, con receta u omitidos para delivery). Si el checkout los rechaza, quítalos o elige <strong>pick-up en tienda</strong>.
              </div>
            </div>
          )}
          <div style={{borderTop:`1px solid ${C.border}`,paddingTop:14,marginTop:8,marginBottom:14}}>
            <div style={{display:"flex",justifyContent:"space-between"}}><span style={{color:C.dark,fontWeight:800,fontSize:16}}>Total</span><span style={{color:BRAND.primary,fontWeight:900,fontSize:22}}>{$(sub)}</span></div>
            <div style={{color:"#92400e",fontSize:12,fontWeight:700,marginTop:6}}>⭐ +{labelPts(Math.floor(sub/10))}</div>
          </div>
          <Btn onClick={()=>setPage("checkout")} col={BRAND.primary} full>Proceder al pago →</Btn>
          <div style={{color:C.dim,fontSize:11,textAlign:"center",marginTop:10}}>🔒 Pago 100% seguro · SSL</div>
        </div>
      </div>
    </div>
  );
}

// ── CHECKOUT ──────────────────────────────────────────────────
function Checkout({cart,setCart,setPage,user,setUser,entrega="pickup",catalogoProductos=[]}){
  const C = useTheme();
  const stack = useMediaQuery("(max-width: 768px)");
  const [step,setStep]=useState(1);
  const [datos,setDatos]=useState(()=>({
    nombre:user?.nombre||"",
    tel:user?.telefono||"",
    email:user?.email||"",
    calle:user?.calle||"",
    colonia:user?.colonia||"",
    cp:user?.cp||"",
  }));
  const [metodo,setMetodo]=useState("tarjeta");
  const [conf,setConf]=useState(false);
  const [lastOrder,setLastOrder]=useState(null);
  const [guardando,setG]=useState(false);
  const [checkoutMsg,setCheckoutMsg]=useState(null);
  const sub=cart.reduce((a,c)=>a+(Number(c.precio)||0)*(Number(c.qty)||0),0);
  const ptsG=Math.floor(sub/10);

  const catalogoById = useMemo(() => {
    const m = new Map();
    for (const p of catalogoProductos || []) {
      m.set(tiendaNormProductId(p.id), p);
    }
    return m;
  }, [catalogoProductos]);

  useEffect(() => {
    if (!catalogoById.size || !cart.length) return;
    setCart((prev) => {
      const next = [];
      const msgs = [];
      let changed = false;
      for (const line of prev) {
        const id = tiendaNormProductId(line.id);
        const live = catalogoById.get(id);
        if (!live) {
          msgs.push(`"${line.nombre}" ya no está en catálogo.`);
          changed = true;
          continue;
        }
        if (!live.activo) {
          msgs.push(`"${line.nombre}" ya no está disponible.`);
          changed = true;
          continue;
        }
        const stCol = Number(live.stock) || 0;
        const want = Number(line.qty) || 0;
        let qty = want;
        if (stCol > 0) {
          qty = Math.min(want, stCol);
          if (qty <= 0) {
            changed = true;
            continue;
          }
          if (qty < want) {
            msgs.push(`"${line.nombre}": cantidad ${want} → ${qty}.`);
            changed = true;
          }
        } else if (want <= 0) {
          changed = true;
          continue;
        }
        const precio = Number(live.precio) || Number(line.precio) || 0;
        if (precio !== Number(line.precio)) changed = true;
        next.push({
          ...line,
          id,
          qty,
          stock: stCol > 0 ? stCol : Number(line.stock) || 0,
          precio,
          activo: live.activo,
        });
      }
      if (!changed) return prev;
      if (msgs.length) showToast(msgs.slice(0, 4).join(" ") + (msgs.length > 4 ? "…" : ""), "warning");
      if (next.length === 0 && prev.length > 0) {
        showToast("Tu carrito quedó vacío. Volvé al catálogo.", "info");
      }
      return next;
    });
  }, [catalogoById, setCart, cart.length]);

  const notifyCheckout = (msg, type = "warning") => {
    setCheckoutMsg({ text: String(msg || ""), type });
    showToast(msg, type);
  };

  useEffect(() => {
    const fallback = {
      nombre: user?.nombre || "",
      tel: user?.telefono || "",
      email: user?.email || "",
      calle: user?.calle || "",
      colonia: user?.colonia || "",
      cp: user?.cp || "",
    };
    let merged = { ...fallback };
    try {
      const raw = localStorage.getItem(checkoutAddressStorageKey(user));
      if (raw) {
        const saved = JSON.parse(raw);
        merged = {
          ...merged,
          calle: String(saved?.calle || merged.calle || ""),
          colonia: String(saved?.colonia || merged.colonia || ""),
          cp: String(saved?.cp || merged.cp || ""),
        };
      }
    } catch (_) { /* noop */ }
    setDatos((prev) => ({ ...prev, ...merged }));
  }, [user?.id, user?.telefono, user?.nombre, user?.email, user?.calle, user?.colonia, user?.cp]);

  useEffect(() => {
    const payload = {
      calle: String(datos.calle || "").trim(),
      colonia: String(datos.colonia || "").trim(),
      cp: String(datos.cp || "").trim(),
    };
    try {
      localStorage.setItem(checkoutAddressStorageKey(user), JSON.stringify(payload));
    } catch (_) { /* noop */ }
  }, [datos.calle, datos.colonia, datos.cp, user?.id, user?.telefono]);

  const nombreOk = String(datos.nombre || "").trim().length >= 3;
  const telOk = soloDigitosTel(datos.tel || "").length >= 10;
  const emailOk = correoTiendaValido(datos.email || "");
  const tipoEntregaRpc = mapUiEntregaToRpc(entrega).tipo_entrega;
  const direccionOk = tipoEntregaRpc !== "envio" || (
    String(datos.calle || "").trim().length >= 5 &&
    String(datos.colonia || "").trim().length >= 3 &&
    String(datos.cp || "").trim().length >= 5
  );
  const datosCheckoutCompletos = nombreOk && telOk && emailOk && direccionOk;

  const confirmar=async()=>{
    if (!cart.length) return;
    const invalidItems = cart.filter(c => !Number.isFinite(Number(c.precio)) || Number(c.precio) <= 0 || !Number.isFinite(Number(c.qty)) || Number(c.qty) <= 0);
    if (invalidItems.length) {
      notifyCheckout("Hay productos con precio o cantidad inválidos. Revisa tu carrito.", "warning");
      return;
    }
    if (!datosCheckoutCompletos) {
      notifyCheckout(
        tipoEntregaRpc === "envio"
          ? "Completa nombre, telefono, correo y direccion (calle, colonia y CP) antes de confirmar."
          : "Completa nombre, telefono y correo antes de confirmar.",
        "warning"
      );
      return;
    }
    setG(true);
    try{
      const productIds = [...new Set(cart.map(c => tiendaNormProductId(c.id)))];
      const [{ data: stockRows }, { data: lotesRows }] = await Promise.all([
        supabase
          .from("productos")
          .select("id,stock,precio,activo,requiere_receta,controlado,visible_tienda,delivery_allowed,categoria")
          .in("id", productIds),
        supabase
          .from("lotes")
          .select("producto_id,cantidad_actual,activo")
          .in("producto_id", productIds),
      ]);
      const sumLotes = tiendaSumLotesByProduct(lotesRows);
      const stockMap = new Map((stockRows||[]).map(p=>[tiendaNormProductId(p.id), p]));
      // Reconciliación automática de carrito contra inventario vivo:
      // evita bloquear al usuario por productos obsoletos.
      const reconciled = [];
      const cambios = [];
      for (const c of cart) {
        const id = tiendaNormProductId(c.id);
        const dbp = stockMap.get(id);
        if (!dbp) {
          cambios.push(`• ${c.nombre}: ya no disponible`);
          continue;
        }
        if (!dbp.activo) {
          cambios.push(`• ${c.nombre}: producto inactivo`);
          continue;
        }
        const eff = tiendaEffectiveStockFromDb(dbp, sumLotes);
        const qtyReq = Number(c.qty || 0);
        if (eff <= 0) {
          cambios.push(`• ${c.nombre}: sin stock`);
          continue;
        }
        if (eff < qtyReq) {
          cambios.push(`• ${c.nombre}: ${qtyReq} → ${eff}`);
        }
        reconciled.push({
          ...c,
          id,
          qty: Math.min(qtyReq, eff),
          stock: eff,
          precio: Number(dbp.precio ?? c.precio ?? 0),
          activo: dbp.activo,
        });
      }
      if (!reconciled.length) {
        setCart([]);
        notifyCheckout("Tu carrito quedó sin productos disponibles. Vuelve al catálogo para agregar nuevos.", "warning");
        setStep(1);
        setPage("carrito");
        setG(false);
        return;
      }
      if (cambios.length) {
        setCart(reconciled);
        const detalle = cambios.slice(0, 4).join("\n");
        notifyCheckout(`Actualizamos tu carrito con inventario real:\n${detalle}${cambios.length > 4 ? "\n…" : ""}\n\nRevisa y confirma de nuevo.`, "warning");
        setG(false);
        return;
      }

      const { ok, bloqueados } = validarCarritoParaEntrega(reconciled, entrega, stockMap, {
        permiteEnTiendaWeb: productoPermitidoEnTiendaFarmaciaWeb,
        razonNoPermitidoTienda: razonBloqueoProductoTiendaFarmacia,
      });
      if (!ok) {
        notifyCheckout(`Hay productos no permitidos para esta entrega:\n${bloqueados.map(b=>`• ${b.nombre}: ${b.razon}`).join("\n")}`, "warning");
        setG(false);
        return;
      }

      const { tipo_entrega, order_channel, fulfillment_type, ui_entrega } = mapUiEntregaToRpc(entrega);
      const direccionStr = [datos.calle, datos.colonia, datos.cp].filter(Boolean).join(", ").trim() || null;
      if (tipo_entrega === "envio" && (!direccionStr || direccionStr.length < 8)) {
        notifyCheckout("Para envío a domicilio completa calle, colonia y código postal.", "warning");
        setG(false);
        return;
      }

      const tokCli = sessionStorage.getItem("farmax_cliente_token");
      if (!tokCli) {
        notifyCheckout("Inicia sesión para confirmar tu pedido.", "warning");
        setPage("login");
        setG(false); return;
      }

      // Persistir datos de contacto/dirección al perfil del cliente para no reescribir cada compra.
      try {
        await supabase.rpc("cliente_actualizar_perfil", {
          p_session_token: tokCli,
          p_nombre: String(datos.nombre || "").trim() || null,
          p_email: String(datos.email || "").trim() || null,
          p_calle: String(datos.calle || "").trim() || null,
          p_colonia: String(datos.colonia || "").trim() || null,
          p_cp: String(datos.cp || "").trim() || null,
          p_rfc: null,
          p_razon_social: null,
        });
        if (typeof setUser === "function") {
          setUser((prev) => ({
            ...(prev || {}),
            nombre: String(datos.nombre || "").trim() || prev?.nombre || "",
            email: String(datos.email || "").trim() || prev?.email || "",
            calle: String(datos.calle || "").trim() || prev?.calle || "",
            colonia: String(datos.colonia || "").trim() || prev?.colonia || "",
            cp: String(datos.cp || "").trim() || prev?.cp || "",
          }));
        }
      } catch (e) {
        console.warn("[Checkout] cliente_actualizar_perfil:", e);
      }

      const p_cart = reconciled.map(c => ({
        producto_id: tiendaNormProductId(c.id),
        cantidad:    Number(c.qty),
      }));

      const { data: resp, error: rpcErr } = await supabase.rpc("cliente_crear_pedido_online", {
        p_session_token: tokCli,
        p_cart,
        p_metodo_pago: metodo,
        p_tipo_entrega: tipo_entrega,
        p_direccion: tipo_entrega === "envio" ? direccionStr : null,
        p_guest_nombre: null,
        p_guest_telefono: null,
        p_guest_email: null,
        p_reservation_session_id: null,
      });
      if (rpcErr) throw rpcErr;
      if (!resp?.success) {
        notifyCheckout(resp?.error || "No se pudo crear el pedido", "error");
        setG(false); return;
      }

      const subSnap = reconciled.reduce((a,c)=>a+(Number(c.precio)||0)*(Number(c.qty)||0),0);

      if (metodo === "mercadopago") {
        const baseUrl = window.location.origin;
        const mpResp = await fetch("/api/payments/mp/create-preference", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${tokCli}`,
          },
          body: JSON.stringify({
            pedidoId: resp.pedido_id,
            amount: subSnap,
            baseUrl,
            payer: {
              name: String(datos.nombre || "").trim() || null,
              email: String(datos.email || "").trim() || null,
            },
            items: reconciled.map((c) => ({
              title: c.nombre || "Producto",
              quantity: Number(c.qty) || 1,
              unit_price: Number(c.precio) || 0,
            })),
          }),
        });
        const mpData = await mpResp.json().catch(() => ({}));
        if (!mpResp.ok || !mpData?.ok || !(mpData.initPoint || mpData.sandboxInitPoint)) {
          notifyCheckout(
            "Pedido creado, pero no se pudo iniciar Mercado Pago. Puedes reintentar desde Mis pedidos.",
            "warning"
          );
          setLastOrder({
            sub: subSnap,
            ptsG: Math.floor(subSnap/10),
            lines: reconciled.map(c=>({ nombre:c.nombre, qty:c.qty, precio:c.precio })),
            entregaUi: entrega,
            tipo_entrega,
            order_channel,
            fulfillment_type,
            ui_entrega: ui_entrega || null,
            datosTel: datos.tel,
            pedidoId: resp.pedido_id,
          });
          setConf(true);
          setCart([]);
          setG(false);
          return;
        }
        setCart([]);
        window.location.href = mpData.initPoint || mpData.sandboxInitPoint;
        return;
      }

      setLastOrder({
        sub: subSnap,
        ptsG: Math.floor(subSnap/10),
        lines: reconciled.map(c=>({ nombre:c.nombre, qty:c.qty, precio:c.precio })),
        entregaUi: entrega,
        tipo_entrega,
        order_channel,
        fulfillment_type,
        ui_entrega: ui_entrega || null,
        datosTel: datos.tel,
        pedidoId: resp.pedido_id,
      });
      setG(false);
      setConf(true);
      setCart([]);
      return;
    }catch(e){
      console.warn(e);
      const msg = e?.message || e?.error_description || (typeof e === "string" ? e : "");
      if (msg && (msg.includes("Stock insuficiente") || msg.includes("stock insuficiente"))) {
        notifyCheckout(msg, "warning");
      } else {
        notifyCheckout(msg ? `No se pudo confirmar: ${msg}` : "No se pudo confirmar el pedido. Intenta nuevamente.", "error");
      }
    }
    setG(false);
  };
  if(conf&&lastOrder) return(<div style={{maxWidth:600,margin:"clamp(40px,12vw,80px) auto",padding:"0 16px",textAlign:"center"}}><div style={{fontSize:"clamp(48px,15vw,72px)",marginBottom:16}}>✅</div><h1 style={{color:C.dark,fontSize:"clamp(22px,5vw,28px)",fontWeight:800,marginBottom:8,lineHeight:1.2}}>¡Pedido confirmado!</h1><p style={{color:C.mid,fontSize:"clamp(14px,3.5vw,16px)",marginBottom:24,lineHeight:1.5}}>
        {lastOrder.tipo_entrega==="recoger"
          ? "Te avisamos por WhatsApp cuando esté listo para recoger en farmacia."
          : "Te contactamos para coordinar el envío. Próximamente podrás enlazar Uber Direct / paquetería desde tu panel."}
      </p>
      {lastOrder.pedido_id!=null&&<p style={{color:C.dim,fontSize:12,marginBottom:16}}>Pedido #{lastOrder.pedido_id}</p>}
      <div style={{background:"#fef3c7",border:"1px solid #f59e0b30",borderRadius:12,padding:16,marginBottom:24}}><div style={{color:"#92400e",fontWeight:700,fontSize:"clamp(13px,3.2vw,15px)"}}>⭐ +{labelPts(lastOrder.ptsG)} agregados a tu cuenta</div></div><div style={{display:"flex",gap:12,justifyContent:"center",flexWrap:"wrap"}}>
          <Btn onClick={()=>setPage("home")} col={BRAND.primary}>Ir al inicio</Btn>
          <Btn onClick={()=>setPage("cuenta")} outline col={BRAND.primary}>Ver mis pedidos</Btn>
        </div>
        {lastOrder.datosTel&&(
          <div style={{marginTop:16}}>
            <button type="button" onClick={()=>{
              const items=lastOrder.lines.map(i=>`• ${i.nombre} ×${i.qty} = $${(Number(i.precio)*Number(i.qty)).toFixed(2)}`).join("\n");
              const entregaTxt = lastOrder.tipo_entrega==="recoger" ? "Pick-up en Farmax" : `Envío (${lastOrder.entregaUi||"domicilio"})`;
              const msg=`🏥 *Farmax Farmacia*\nChinampac de Juárez, CDMX\n\n✅ *Pedido confirmado*\n\n${items}\n\n💰 *Total: $${lastOrder.sub.toFixed(2)}*\n📦 *Entrega:* ${entregaTxt}\n\n¡Gracias por tu preferencia! 💊`;
              window.open("https://wa.me/52"+String(lastOrder.datosTel).replace(/\D/g,"")+"?text="+encodeURIComponent(msg),"_blank");
            }} style={{display:"flex",alignItems:"center",gap:8,margin:"0 auto",padding:"10px 24px",borderRadius:10,border:"none",background:"#25D366",color:"#fff",fontWeight:700,fontSize:14,cursor:"pointer"}}>
              📱 Enviar confirmación por WhatsApp
            </button>
          </div>
        )}</div>);
  return(
    <div style={{maxWidth:900,margin:"0 auto",padding:"clamp(20px,4vw,32px) 16px"}}>
      <h1 style={{color:C.dark,fontSize:"clamp(22px,5vw,26px)",fontWeight:800,marginBottom:24,lineHeight:1.2}}>Finalizar compra</h1>
      {checkoutMsg?.text && (
        <div
          style={{
            marginBottom: 14,
            padding: "10px 12px",
            borderRadius: 10,
            border: `1px solid ${checkoutMsg.type === "error" ? C.red + "50" : "#f59e0b55"}`,
            background: checkoutMsg.type === "error" ? C.redDim : "#fef3c7",
            color: checkoutMsg.type === "error" ? C.red : "#92400e",
            fontSize: 13,
            whiteSpace: "pre-line",
            lineHeight: 1.45,
          }}
        >
          {checkoutMsg.text}
        </div>
      )}
      <div style={{display:"grid",gridTemplateColumns:stack?"1fr":"1fr min(300px,100%)",gap:24,alignItems:"start"}}>
        <div style={{minWidth:0}}>
          {step===1&&(<div style={{background:C.white,borderRadius:14,border:`1px solid ${C.border}`,padding:stack?20:24}}><div style={{color:C.dark,fontWeight:700,fontSize:"clamp(16px,4vw,18px)",marginBottom:20}}>📋 Datos de contacto</div><div style={{display:"grid",gridTemplateColumns:stack?"1fr":"1fr 1fr",gap:14}}>{[["Nombre completo","nombre"],["Teléfono","tel"],["Correo electrónico","email"],["Calle y número","calle"],["Colonia","colonia"],["Código postal","cp"]].map(([l,k])=>(<div key={k} style={{gridColumn:!stack&&(k==="email"||k==="calle")?"1/-1":undefined}}><div style={{color:C.mid,fontSize:12,marginBottom:6,fontWeight:600}}>{l}</div><Inp value={datos[k]} onChange={e=>setDatos(p=>({...p,[k]:e.target.value}))} placeholder={l} style={{width:"100%",boxSizing:"border-box",fontSize:16}}/></div>))}</div><div style={{marginTop:10,fontSize:12,color:C.textMid,lineHeight:1.45}}>La dirección se guarda para tu próxima compra y se sincroniza con tu perfil.</div><Btn onClick={()=>setStep(2)} col={BRAND.primary} style={{marginTop:20,width:stack?"100%":undefined}} disabled={!datosCheckoutCompletos}>Continuar al pago →</Btn></div>)}
          {step===2&&(<div style={{background:C.white,borderRadius:14,border:`1px solid ${C.border}`,padding:stack?20:24}}><div style={{color:C.dark,fontWeight:700,fontSize:"clamp(16px,4vw,18px)",marginBottom:20}}>💳 Método de pago</div>{[["mercadopago","🔵 Mercado Pago","Checkout seguro de Mercado Pago"]].map(([v,l,s])=>(<div key={v} onClick={()=>setMetodo(v)} style={{padding:"14px 16px",borderRadius:10,border:`2px solid ${metodo===v?BRAND.primary:C.border}`,background:metodo===v?BRAND.primary+"18":C.white,cursor:"pointer",marginBottom:10}}><div style={{color:metodo===v?BRAND.primary:C.dark,fontWeight:700,fontSize:"clamp(13px,3.2vw,14px)"}}>{l}</div><div style={{color:C.dim,fontSize:12,marginTop:2}}>{s}</div></div>))}<div style={{color:C.textDim,fontSize:11,lineHeight:1.45,marginBottom:10}}>El cobro online se procesa en Mercado Pago. Farmax no captura datos de tarjeta directamente.</div><div style={{display:"flex",gap:10,marginTop:8,flexWrap:"wrap"}}><Btn onClick={()=>setStep(1)} outline col={C.mid} sm>← Atrás</Btn><Btn onClick={()=>setStep(3)} col={BRAND.primary} style={{flex:stack?1:undefined,minWidth:stack?0:undefined}} disabled={!datosCheckoutCompletos}>Revisar pedido →</Btn></div></div>)}
          {step===3&&(<div style={{background:C.white,borderRadius:14,border:`1px solid ${C.border}`,padding:stack?20:24}}><div style={{color:C.dark,fontWeight:700,fontSize:"clamp(16px,4vw,18px)",marginBottom:16}}>✅ Confirmar pedido</div>{cart.map(item=>(<div key={item.id} style={{display:"flex",justifyContent:"space-between",alignItems:"flex-start",gap:12,padding:"8px 0",borderBottom:`1px solid ${C.border}`}}><span style={{color:C.dark,fontSize:13,fontWeight:600,flex:1,minWidth:0,wordBreak:"break-word"}}>{item.nombre} ×{item.qty}</span><span style={{color:BRAND.primary,fontWeight:700,flexShrink:0}}>{$(item.precio*item.qty)}</span></div>))}{!cart.length&&(<div style={{fontSize:12,color:C.textMid,padding:"6px 0 2px"}}>Tu carrito quedó vacío. Regresa al catálogo para continuar.</div>)}<div style={{display:"flex",gap:10,marginTop:16,flexWrap:"wrap"}}><Btn onClick={()=>setStep(2)} outline col={C.mid} sm>← Atrás</Btn><Btn onClick={confirmar} col={BRAND.primary} disabled={guardando||!cart.length||sub<=0||!datosCheckoutCompletos} style={{flex:stack?1:undefined,minWidth:0}}>{guardando?"Procesando pago...":"💳 Pagar y confirmar "+$(sub)}</Btn></div></div>)}
        </div>
        <div style={{background:C.white,borderRadius:14,border:`1px solid ${C.border}`,padding:20,position:stack?"relative":"sticky",top:"calc(env(safe-area-inset-top, 0px) + 100px)"}}>
          <div style={{color:C.dark,fontWeight:700,fontSize:15,marginBottom:14}}>Tu pedido</div>
          {cart.map(item=>(<div key={item.id} style={{display:"flex",justifyContent:"space-between",marginBottom:8}}><span style={{color:C.mid,fontSize:13}}>{item.nombre} ×{item.qty}</span><span style={{color:C.dark,fontSize:13,fontWeight:600}}>{$(item.precio*item.qty)}</span></div>))}
          <div style={{borderTop:`1px solid ${C.border}`,marginTop:12,paddingTop:12}}><div style={{display:"flex",justifyContent:"space-between"}}><span style={{color:C.dark,fontWeight:800}}>Total</span><span style={{color:BRAND.primary,fontWeight:900,fontSize:20}}>{$(sub)}</span></div></div>
        </div>
      </div>
    </div>
  );
}

// ── CONSULTORIO CON MAPA ──────────────────────────────────────
function AgendarCita({setPage,user}){
  const C = useTheme();
  const stack = useMediaQuery("(max-width: 768px)");
  const [nombre,setNombre]=useState(user?.nombre||"");
  const [tel,setTel]=useState(user?.telefono||"");
  const [fecha,setFecha]=useState("");
  const [hora,setHora]=useState("");
  const [motivo,setMotivo]=useState("");
  const [conf,setConf]=useState(false);
  const [guardando,setG]=useState(false);
  const [horasOcupadas,setHorasOcupadas]=useState([]);
  const [draftMsg, setDraftMsg] = useState("");
  const horarios=horariosDisponibles(fecha);
  const horariosLibres=horarios.filter(h=>!horasOcupadas.includes(h));

  useEffect(()=>{
    try {
      const raw = sessionStorage.getItem("farmax_cita_draft");
      if (!raw) return;
      const d = JSON.parse(raw);
      if (d?.nombre) setNombre(String(d.nombre));
      if (d?.tel) setTel(String(d.tel));
      if (d?.fecha) setFecha(String(d.fecha));
      if (d?.hora) setHora(String(d.hora));
      if (d?.motivo) setMotivo(String(d.motivo));
      setDraftMsg("Estamos precargando tu cita para reagendarla. Puedes ajustar fecha/hora y confirmar.");
      sessionStorage.removeItem("farmax_cita_draft");
    } catch (_) { /* noop */ }
  },[]);

  // J5: Cargar horarios ya ocupados para la fecha seleccionada
  useEffect(()=>{
    if(!fecha){ setHorasOcupadas([]); return; }
    supabase.from("citas").select("hora").eq("fecha",fecha).not("estado","eq","cancelada")
      .then(({data})=>{ setHorasOcupadas((data||[]).map(c=>c.hora)); });
  },[fecha]);

  useEffect(()=>{if(hora&&!horariosLibres.includes(hora))setHora("");},[fecha,horariosLibres]);

  const confirmar=async()=>{
    if(!nombre?.trim()||!fecha||!hora)return;
    if(!nombreCompletoPacienteValido(nombre)){
      alert("Escribe el nombre completo del paciente (nombre y apellido).");
      return;
    }
    if(!telefonoMxValido(tel)){
      alert("El teléfono de contacto es obligatorio (al menos 10 dígitos).");
      return;
    }
    // J5: Verificar disponibilidad en tiempo real antes de confirmar
    const {data:ocupado}=await supabase.from("citas").select("id").eq("fecha",fecha).eq("hora",hora).not("estado","eq","cancelada");
    if(ocupado&&ocupado.length>=1){
      alert("Lo sentimos, ese horario ya no está disponible. Por favor elige otro.");
      setHora(""); return;
    }
    setG(true);
    try{
      const tokCli = sessionStorage.getItem("farmax_cliente_token");
      if (!tokCli) { alert("Inicia sesión para agendar tu cita."); setG(false); return; }
      const { data: resp, error } = await supabase.rpc("cliente_agendar_cita", {
        p_session_token: tokCli,
        p_nombre:        nombre,
        p_telefono:      tel,
        p_fecha:         fecha,
        p_hora:          hora,
        p_motivo:        motivo || null,
      });
      if (error) throw error;
      if (!resp?.success) { alert(resp?.error || "No se pudo agendar"); setG(false); return; }
    }catch(e){ alert("No se pudo agendar. Intenta de nuevo."); console.warn(e); }
    setG(false);setConf(true);
  };
  if(conf) return(
    <div style={{maxWidth:500,margin:"clamp(40px,12vw,80px) auto",padding:"0 16px",textAlign:"center"}}>
      <div style={{fontSize:"clamp(48px,14vw,64px)",marginBottom:16}}>📅</div>
      <h1 style={{color:C.dark,fontSize:"clamp(22px,5vw,26px)",fontWeight:800,marginBottom:16,lineHeight:1.2}}>¡Cita confirmada!</h1>
      <p style={{color:C.mid,marginBottom:24,fontSize:"clamp(14px,3.5vw,16px)",lineHeight:1.5}}>📲 Te enviamos recordatorio por WhatsApp 24 hrs antes.</p>
      <div style={{display:"flex",gap:12,justifyContent:"center",flexWrap:"wrap",marginBottom:16}}>
        <Btn onClick={()=>setPage("cuenta")} col={BRAND.primary}>Ver mis citas</Btn>
        <Btn onClick={()=>setPage("catalogo")} outline col={BRAND.primary}>Ver catálogo</Btn>
      </div>
      {(tel||user?.telefono)&&(
        <button type="button" onClick={()=>{
          const t = tel||user?.telefono||"";
          const msg = `📅 *Cita confirmada en Farmax*\n\nHola${nombre?" "+nombre:""}! Tu cita médica ha sido registrada.\n\n🗓 Fecha: ${fecha}\n🕐 Hora: ${hora}\n👩‍⚕️ Médico general\n📍 Chinampac de Juárez, Iztapalapa, CDMX\n\n${motivo?"Motivo: "+motivo+"\n\n":""}💊 Al terminar tu consulta, surte tu receta en Farmax con 10% de descuento.\n\n¡Te esperamos! 🏥`;
          window.open("https://wa.me/52"+t.replace(/\D/g,"")+"?text="+encodeURIComponent(msg),"_blank");
        }} style={{display:"flex",alignItems:"center",gap:8,margin:"0 auto",padding:"10px 24px",borderRadius:10,border:"none",background:"#25D366",color:"#fff",fontWeight:700,fontSize:14,cursor:"pointer"}}>
          📱 Enviar confirmación por WhatsApp
        </button>
      )}
    </div>
  );
  return(
    <div style={{maxWidth:900,margin:"0 auto",padding:"clamp(24px,5vw,40px) 16px"}}>
      <div style={{textAlign:"center",marginBottom:32}}>
        <div style={{fontSize:"clamp(40px,11vw,48px)",marginBottom:12}}>🏥</div>
        <h1 style={{color:C.dark,fontSize:"clamp(22px,5vw,28px)",fontWeight:800,marginBottom:8,lineHeight:1.2}}>Consultorio Farmax</h1>
        <p style={{color:C.mid,fontSize:"clamp(14px,3.5vw,15px)",lineHeight:1.5}}>Médico general · $80 por consulta (pago en farmacia el día de la cita) · O gratis con 160 puntos Farmax</p>
      </div>
      <div style={{display:"grid",gridTemplateColumns:stack?"1fr":"1fr 1fr",gap:24,marginBottom:24}}>
        {/* Info doctora */}
        <div style={{background:C.white,borderRadius:16,border:`1px solid ${C.border}`,padding:24}}>
          <div style={{display:"flex",alignItems:"center",gap:16,marginBottom:16}}>
            <div style={{width:56,height:56,borderRadius:"50%",background:BRAND.gradient,display:"flex",alignItems:"center",justifyContent:"center",fontSize:28}}>👩‍⚕️</div>
            <div><div style={{color:C.dark,fontWeight:800,fontSize:16}}>Médico general en turno</div><div style={{color:C.mid,fontSize:13,marginTop:2}}>Consultorio adyacente a Farmax</div></div>
          </div>
          <div style={{display:"grid",gap:10,marginBottom:16}}>
            {HORARIOS_DOCTORA.map(h=>(
              <div key={h.dia} style={{background:h.dia==="Domingo"?C.cardDark:BRAND.primary+"10",borderRadius:10,padding:"10px 14px",border:`1px solid ${h.dia==="Domingo"?C.border:BRAND.primary+"30"}`}}>
                <div style={{color:h.dia==="Domingo"?C.dim:BRAND.primary,fontWeight:700,fontSize:13,marginBottom:2}}>{h.dia}</div>
                <div style={{color:h.dia==="Domingo"?C.dim:C.dark,fontSize:12}}>{h.horario}</div>
              </div>
            ))}
          </div>
          <div style={{background:"#fef3c7",border:"1px solid #f59e0b30",borderRadius:8,padding:"10px 12px"}}>
            <div style={{color:"#92400e",fontSize:12}}>💊 Surte tu receta en Farmax con <strong>10% de descuento especial</strong> tras tu consulta.</div>
          </div>
        </div>
        {/* Mapa */}
        <div style={{background:C.white,borderRadius:16,border:`1px solid ${C.border}`,overflow:"hidden"}}>
          <div style={{padding:"16px 20px",borderBottom:`1px solid ${C.border}`}}>
            <div style={{color:C.dark,fontWeight:700,fontSize:14}}>📍 Cómo llegar</div>
            <div style={{color:C.mid,fontSize:12,marginTop:4}}>Radiodifusora 100, Chinampac de Juárez, Iztapalapa, CDMX</div>
          </div>
          <iframe
            title="Ubicación Farmax"
            src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3763.5!2d-99.05669!3d19.37106!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x85d1fd0b8b0fd10d%3A0x75316d7abacf16ae!2sRadiodifusora+100%2C+Chinampac+de+Ju%C3%A1rez%2C+09208+Ciudad+de+M%C3%A9xico%2C+CDMX!5e0!3m2!1ses-419!2smx!4v1713000000000!5m2!1ses-419!2smx"
            width="100%" height="280" style={{border:"none",display:"block"}}
            allowFullScreen loading="lazy"/>
          <div style={{padding:"12px 16px"}}>
            <a href="https://maps.app.goo.gl/Xyj2WV9UWdbVBctZ7" target="_blank" rel="noopener noreferrer"
              style={{color:BRAND.primary,fontSize:13,fontWeight:700,textDecoration:"none"}}>
              📱 Abrir en Google Maps →
            </a>
          </div>
        </div>
      </div>
      {/* Formulario */}
      <div style={{background:C.white,borderRadius:16,border:`1px solid ${C.border}`,padding:"clamp(20px,4vw,32px)"}}>
        <div style={{color:C.dark,fontWeight:700,fontSize:"clamp(15px,3.8vw,16px)",marginBottom:16}}>Agendar mi cita</div>
        {draftMsg&&(
          <div style={{background:"#fff7ed",border:"1px solid #fdba74",borderRadius:8,padding:"10px 12px",marginBottom:12,color:"#9a3412",fontSize:12}}>
            {draftMsg}
          </div>
        )}
        {user&&(<div style={{background:BRAND.primary+"10",border:`1px solid ${BRAND.primary}30`,borderRadius:8,padding:"10px 12px",marginBottom:16}}><div style={{color:BRAND.primary,fontSize:13}}>✓ Datos precargados de tu cuenta. Puedes editarlos si la cita es para otra persona.</div></div>)}
        <div style={{display:"grid",gridTemplateColumns:stack?"1fr":"1fr 1fr",gap:16,marginBottom:16}}>
          <div><div style={{color:C.mid,fontSize:12,fontWeight:700,marginBottom:6}}>Nombre completo <span style={{color:"#ef4444"}}>*</span></div><Inp value={nombre} onChange={e=>setNombre(e.target.value)} placeholder="Nombre y apellido" style={{width:"100%",boxSizing:"border-box"}}/></div>
          <div><div style={{color:C.mid,fontSize:12,fontWeight:700,marginBottom:6}}>Teléfono <span style={{color:"#ef4444"}}>*</span></div><Inp value={tel} onChange={e=>setTel(e.target.value)} placeholder="10+ dígitos" type="tel" style={{width:"100%",boxSizing:"border-box"}}/></div>
          <div><div style={{color:C.mid,fontSize:12,fontWeight:700,marginBottom:6}}>Fecha</div><input type="date" value={fecha} onChange={e=>setFecha(e.target.value)} min={localISODate()} style={{width:"100%",boxSizing:"border-box",padding:"9px 13px",borderRadius:8,border:`1px solid ${C.border}`,background:C.white,color:C.dark,fontSize:16,outline:"none",fontFamily:"'Plus Jakarta Sans',sans-serif"}}/></div>
          <div>
            <div style={{color:C.mid,fontSize:12,fontWeight:700,marginBottom:6}}>Horario {fecha&&horarios.length===0?"— Sin disponibilidad hoy":""}</div>
            <select value={hora} onChange={e=>setHora(e.target.value)} style={{width:"100%",padding:"11px 14px",borderRadius:10,border:`2px solid ${C.border}`,color:hora?C.dark:C.dim,fontSize:16,outline:"none",fontFamily:"'Plus Jakarta Sans',sans-serif"}}>
              <option value="">Seleccionar horario</option>
              {horariosLibres.length===0&&fecha?<option value="">Sin disponibilidad este día</option>:horariosLibres.map(h=><option key={h} value={h}>{h} hrs{horasOcupadas.includes(h)?" (ocupado)":""}</option>)}
            </select>
            {fecha&&horarios.length===0&&<div style={{color:C.red,fontSize:11,marginTop:4}}>No hay horarios disponibles. Selecciona otra fecha.</div>}
          </div>
          <div style={{gridColumn:stack?undefined:"1/-1"}}><div style={{color:C.mid,fontSize:12,fontWeight:700,marginBottom:6}}>Motivo de consulta (opcional)</div><Inp value={motivo} onChange={e=>setMotivo(e.target.value)} placeholder="Ej: revisión general, control de presión..." style={{width:"100%",boxSizing:"border-box"}}/></div>
        </div>
        <Btn onClick={confirmar} col={BRAND.primary} full disabled={!nombre?.trim()||!telefonoMxValido(tel)||!nombreCompletoPacienteValido(nombre)||!fecha||!hora||guardando}>{guardando?"Guardando...":"📅 Confirmar cita"}</Btn>
      </div>
    </div>
  );
}

// ── PROMOCIONES (página dedicada; los banners pueden usar pagina: "promo") ──
function PromocionesPage({setPage}){
  const C = useTheme();
  const stack = useMediaQuery("(max-width: 768px)");
  const [promos, setPromos] = useState([]);
  const [load, setLoad] = useState(true);
  useEffect(()=>{
    const hoy = new Date().toISOString().split("T")[0];
    supabase.from("promociones").select("*")
      .eq("activa",true)
      .or(`fecha_fin.is.null,fecha_fin.gte.${hoy}`)
      .then(({data})=>{ setPromos(data||[]); setLoad(false); });
  },[]);
  return(
    <div style={{maxWidth:1200,margin:"0 auto",padding:"clamp(24px,5vw,40px) 16px"}}>
      <button type="button" onClick={()=>setPage("home")} style={{background:"none",border:"none",color:BRAND.primary,cursor:"pointer",fontSize:14,fontWeight:700,marginBottom:16,display:"flex",alignItems:"center",gap:6}}>← Inicio</button>
      <div style={{marginBottom:28}}>
        <h1 style={{color:C.dark,fontSize:"clamp(24px,5.5vw,30px)",fontWeight:800,marginBottom:8,lineHeight:1.2}}>🏷️ Promociones vigentes</h1>
        <p style={{color:C.mid,fontSize:"clamp(14px,3.5vw,15px)",lineHeight:1.6,maxWidth:640}}>
          Ofertas y campañas activas en Farmax. Los banners del inicio pueden enlazar aquí: en administración, en el campo <strong>Página destino</strong> escribe <code style={{background:C.cardDark,padding:"2px 6px",borderRadius:4}}>promo</code>.
        </p>
      </div>
      {load ? (
        <div style={{color:C.mid,fontSize:14}}>Cargando promociones…</div>
      ) : promos.length===0 ? (
        <div style={{background:C.white,borderRadius:14,border:`1px solid ${C.border}`,padding:40,textAlign:"center",color:C.mid}}>
          No hay promociones activas en este momento. Revisa el catálogo o vuelve pronto.
        </div>
      ) : (
        <div style={{display:"grid",gridTemplateColumns:stack?"1fr":"repeat(auto-fill,minmax(min(100%,260px),1fr))",gap:14}}>
          {promos.map(p=>(
            <div key={p.id} style={{background:"#fff",borderRadius:14,border:`2px solid ${BRAND.primary}20`,padding:20,display:"flex",flexDirection:"column",gap:8}}>
              <div style={{display:"flex",justifyContent:"space-between",alignItems:"flex-start",gap:8}}>
                <span style={{fontWeight:800,color:C.dark,fontSize:15}}>{p.nombre}</span>
                <span style={{padding:"3px 10px",borderRadius:20,fontSize:11,fontWeight:700,flexShrink:0,
                  background:p.tipo==="descuento_pct"?"#eff6ff":p.tipo==="2x1"?"#ede9fe":"#dcfce7",
                  color:p.tipo==="descuento_pct"?BRAND.primary:p.tipo==="2x1"?"#7c3aed":"#16a34a"}}>
                  {p.tipo==="descuento_pct"?`${p.valor}% OFF`:p.tipo==="descuento_fijo"?`$${p.valor} OFF`:p.tipo==="2x1"?"2×1":"Combo"}
                </span>
              </div>
              {p.descripcion&&<p style={{color:C.mid,fontSize:13,margin:0,lineHeight:1.5}}>{p.descripcion}</p>}
              {p.fecha_fin&&<div style={{color:C.dim,fontSize:11}}>⏰ Válido hasta: {p.fecha_fin}</div>}
              <Btn onClick={()=>setPage("catalogo")} col={BRAND.primary} sm style={{marginTop:4}}>Ver productos →</Btn>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

// ── FAQ ───────────────────────────────────────────────────────
function FAQPage({setPage}){
  const C = useTheme();
  const [abierto,setAbierto]=useState(null);
  return(
    <div style={{maxWidth:800,margin:"0 auto",padding:"clamp(24px,5vw,40px) 16px"}}>
      <div style={{textAlign:"center",marginBottom:32}}>
        <div style={{fontSize:"clamp(40px,12vw,48px)",marginBottom:12}}>❓</div>
        <h1 style={{color:C.dark,fontSize:"clamp(22px,5vw,28px)",fontWeight:800,marginBottom:8,lineHeight:1.2}}>Preguntas frecuentes</h1>
        <p style={{color:C.mid,fontSize:"clamp(14px,3.5vw,15px)",lineHeight:1.5}}>Todo lo que necesitas saber sobre Farmax</p>
      </div>
      <div style={{display:"grid",gap:10,marginBottom:32}}>
        {FAQ_ITEMS.map((f,i)=>(
          <div key={i} style={{background:C.white,borderRadius:12,border:`1px solid ${abierto===i?BRAND.primary+"40":C.border}`,overflow:"hidden",transition:"border-color .2s"}}>
            <button type="button" onClick={()=>setAbierto(abierto===i?null:i)} style={{width:"100%",padding:"14px 16px",background:"none",border:"none",cursor:"pointer",display:"flex",justifyContent:"space-between",alignItems:"flex-start",gap:12,fontFamily:"'Plus Jakarta Sans',sans-serif",textAlign:"left"}}>
              <span style={{color:C.dark,fontWeight:700,fontSize:"clamp(14px,3.5vw,15px)",lineHeight:1.35,wordBreak:"break-word"}}>{f.p}</span>
              <span style={{color:BRAND.primary,fontSize:18,flexShrink:0,lineHeight:1.2}}>{abierto===i?"−":"+"}</span>
            </button>
            {abierto===i&&(
              <div style={{padding:"0 16px 16px",color:C.mid,fontSize:"clamp(13px,3.2vw,14px)",lineHeight:1.7,borderTop:`1px solid ${C.border}`,wordBreak:"break-word",overflowWrap:"break-word"}}>
                <div style={{paddingTop:12}}>{f.r}</div>
              </div>
            )}
          </div>
        ))}
      </div>
      <div style={{background:BRAND.primary+"10",border:`1px solid ${BRAND.primary}30`,borderRadius:14,padding:"clamp(18px,4vw,24px)",textAlign:"center"}}>
        <div style={{color:C.dark,fontWeight:700,fontSize:"clamp(15px,3.8vw,16px)",marginBottom:8}}>¿No encontraste tu respuesta?</div>
        <div style={{color:C.mid,fontSize:"clamp(13px,3.2vw,14px)",marginBottom:16,lineHeight:1.5}}>Escríbenos y te respondemos a la brevedad.</div>
        <div style={{display:"flex",gap:12,justifyContent:"center",flexWrap:"wrap"}}>
          <a href="mailto:contacto@farmax.mx" style={{color:BRAND.primary,fontWeight:700,fontSize:14,textDecoration:"none"}}>📧 contacto@farmax.mx</a>
          {/* Descomentar cuando tengas WhatsApp:
          <a href="https://wa.me/52XXXXXXXXXX" style={{color:BRAND.accent,fontWeight:700,fontSize:14,textDecoration:"none"}}>💬 WhatsApp</a>
          */}
        </div>
      </div>
    </div>
  );
}

// ── PÁGINAS LEGALES ───────────────────────────────────────────
function PaginaLegal({titulo,children,setPage}){
  const C = useTheme();
  return(
    <div style={{maxWidth:800,margin:"0 auto",padding:"clamp(24px,5vw,40px) 16px"}}>
      <button type="button" onClick={()=>setPage("home")} style={{background:"none",border:"none",color:BRAND.primary,cursor:"pointer",fontSize:14,fontWeight:700,marginBottom:20,display:"flex",alignItems:"center",gap:6}}>← Volver al inicio</button>
      <h1 style={{color:C.dark,fontSize:"clamp(20px,4.8vw,26px)",fontWeight:800,marginBottom:8,lineHeight:1.2,wordBreak:"break-word"}}>{titulo}</h1>
      <div style={{color:C.dim,fontSize:"clamp(12px,3vw,13px)",marginBottom:24,lineHeight:1.5}}>Última actualización: Abril 2026 · Farmax Farmacia · Iztapalapa, CDMX</div>
      <div style={{background:C.white,borderRadius:14,border:`1px solid ${C.border}`,padding:"clamp(20px,4vw,32px)",lineHeight:1.8,color:C.mid,fontSize:"clamp(13px,3.2vw,14px)",wordBreak:"break-word",overflowWrap:"break-word"}}>
        {children}
      </div>
    </div>
  );
}

function AvisoPrivacidad({setPage}){
  const C = useTheme();
  return(
    <PaginaLegal titulo="📄 Aviso de Privacidad" setPage={setPage}>
      <p style={{color:C.dark,fontWeight:700,marginBottom:16}}>De conformidad con la Ley Federal de Protección de Datos Personales en Posesión de los Particulares (LFPDPPP) y su Reglamento, Farmax Farmacia pone a su disposición el presente Aviso de Privacidad.</p>
      {[
        ["1. Responsable del tratamiento de sus datos","Farmax Farmacia, con domicilio en Radiodifusora 100, Chinampac de Juárez, Iztapalapa, Ciudad de México, C.P. 09208, es responsable del uso y protección de sus datos personales."],
        ["2. Datos personales que recabamos","Recabamos los siguientes datos personales: nombre completo, número de teléfono, correo electrónico, domicilio de entrega, e historial de compras y citas médicas. No recabamos datos sensibles salvo los necesarios para la atención médica en nuestro consultorio, los cuales se tratan con el máximo nivel de confidencialidad."],
        ["3. Finalidades del tratamiento","Sus datos se utilizan para: procesar sus pedidos y entregas, gestionar su cuenta y programa de puntos Farmax, agendar y dar seguimiento a consultas médicas, enviarle comunicaciones relacionadas con sus pedidos, y cumplir con obligaciones legales ante COFEPRIS."],
        ["4. Transferencia de datos","Sus datos no serán transferidos a terceros sin su consentimiento, salvo en los casos previstos por la ley o cuando sea necesario para el cumplimiento del servicio contratado (ej. empresas de mensajería)."],
        ["5. Derechos ARCO","Usted tiene derecho a Acceder, Rectificar, Cancelar u Oponerse al tratamiento de sus datos (derechos ARCO). Para ejercerlos, envíe un correo a contacto@farmax.mx indicando su nombre, el derecho que desea ejercer y los datos a los que se refiere. Responderemos en un plazo máximo de 20 días hábiles."],
        ["6. Cambios al aviso de privacidad","Farmax se reserva el derecho de modificar el presente aviso. Cualquier cambio será notificado a través de nuestro sitio web farmax.com.mx."],
      ].map(([t,c])=>(
        <div key={t} style={{marginBottom:20}}>
          <div style={{color:C.dark,fontWeight:700,marginBottom:6}}>{t}</div>
          <p>{c}</p>
        </div>
      ))}
    </PaginaLegal>
  );
}

function TerminosCondiciones({setPage}){
  const C = useTheme();
  return(
    <PaginaLegal titulo="📋 Términos y Condiciones" setPage={setPage}>
      {[
        ["1. Aceptación","Al utilizar la plataforma de Farmax Farmacia, el usuario acepta los presentes Términos y Condiciones. Si no está de acuerdo, le pedimos que no utilice nuestros servicios."],
        ["2. Productos y precios","Los precios mostrados en la plataforma incluyen IVA y están sujetos a disponibilidad. Farmax se reserva el derecho de modificar precios sin previo aviso, respetando siempre el precio vigente al momento de confirmar el pedido."],
        ["3. Disponibilidad de productos","Indicamos claramente si un producto está disponible de forma inmediata o en 24-48 horas. En caso de no poder surtir un pedido, notificaremos al cliente y realizaremos el reembolso correspondiente en un plazo no mayor a 5 días hábiles."],
        ["4. Medicamentos con receta","Los medicamentos que requieren receta médica serán entregados únicamente al presentar la receta original vigente. Farmax se reserva el derecho de cancelar pedidos de medicamentos controlados que no cumplan con los requisitos de COFEPRIS."],
        ["5. Responsabilidad","Farmax no se hace responsable del uso incorrecto de los medicamentos. Se recomienda siempre consultar a un profesional de la salud. La información en nuestra plataforma es de carácter informativo y no sustituye la opinión médica."],
        ["6. Propiedad intelectual","El contenido de la plataforma de Farmax, incluyendo textos, imágenes y logotipos, es propiedad de Farmax Farmacia y está protegido por las leyes de propiedad intelectual vigentes en México."],
        ["7. Jurisdicción","Para cualquier controversia derivada del uso de esta plataforma, las partes se someten a la jurisdicción de los tribunales competentes de la Ciudad de México."],
      ].map(([t,c])=>(
        <div key={t} style={{marginBottom:20}}>
          <div style={{color:C.dark,fontWeight:700,marginBottom:6}}>{t}</div>
          <p>{c}</p>
        </div>
      ))}
    </PaginaLegal>
  );
}

function PoliticaEnvios({setPage}){
  const C = useTheme();
  return(
    <PaginaLegal titulo="📦 Política de Envíos y Devoluciones" setPage={setPage}>
      {[
        ["Tipos de entrega disponibles","• Pick-up en Farmax: Gratis. Disponible el mismo día. Te avisamos cuando tu pedido esté listo.\n• Reparto express CDMX: Mediante Rappi o Uber Connect. El costo es el que muestre la aplicación al momento del servicio.\n• Envío foráneo: $89 a través de Skydropx. Tiempo estimado: 2-5 días hábiles."],
        ["Política de devoluciones","Aceptamos devoluciones dentro de las 72 horas siguientes a la entrega, siempre que el producto esté en perfecto estado, sin abrir y con su empaque original. No se aceptan devoluciones de: medicamentos controlados, productos refrigerados, ni artículos de uso personal."],
        ["Proceso de devolución","Para iniciar una devolución, contáctanos a contacto@farmax.mx dentro del plazo indicado. Una vez aprobada la devolución, el reembolso se realizará en un plazo máximo de 5 días hábiles al mismo método de pago utilizado."],
        ["Productos dañados o incorrectos","Si recibes un producto dañado o diferente al solicitado, contáctanos de inmediato. Haremos el reemplazo o reembolso sin costo adicional para ti."],
        ["Medicamentos con receta","Los medicamentos que requieren receta médica no tienen devolución una vez entregados, en cumplimiento con la normativa COFEPRIS."],
      ].map(([t,c])=>(
        <div key={t} style={{marginBottom:20}}>
          <div style={{color:C.dark,fontWeight:700,marginBottom:6}}>{t}</div>
          <p style={{whiteSpace:"pre-line"}}>{c}</p>
        </div>
      ))}
    </PaginaLegal>
  );
}

function TerminosPuntos({setPage}){
  const C = useTheme();
  return(
    <PaginaLegal titulo="⭐ Términos del Programa Puntos Farmax" setPage={setPage}>
      {[
        ["¿Qué son los Puntos Farmax?","Los Puntos Farmax son un beneficio exclusivo para clientes registrados en la plataforma de Farmax Farmacia. No tienen valor monetario en efectivo y solo pueden canjearse bajo los términos aquí descritos."],
        ["Acumulación de puntos","Se otorga 1 punto por cada $10 de compra en precio normal (no aplica en productos con descuento previo). Las consultas médicas otorgan 5 puntos. El registro nuevo otorga 10 puntos de bienvenida. Las compras en línea otorgan 1.5× puntos. En el mes de cumpleaños se otorga 2× puntos."],
        ["Canje de puntos","20 puntos = $10 de descuento en Farmax. 50 puntos = envío gratis en compra en línea. 100 puntos = $50 de descuento. 160 puntos = consulta médica gratis. 200 puntos = producto gratis (sujeto a catálogo disponible). 1 punto equivale a $0.50 de valor de descuento."],
        ["Vigencia","Los puntos vencen a los 12 meses de inactividad en la cuenta. Farmax se reserva el derecho de modificar las condiciones del programa con previo aviso de 30 días."],
        ["Restricciones","Los puntos no son transferibles entre cuentas, no se pueden convertir en efectivo, y no aplican en combinación con otras promociones salvo indicación expresa. Farmax se reserva el derecho de cancelar cuentas o puntos obtenidos de forma fraudulenta."],
      ].map(([t,c])=>(
        <div key={t} style={{marginBottom:20}}>
          <div style={{color:C.dark,fontWeight:700,marginBottom:6}}>{t}</div>
          <p>{c}</p>
        </div>
      ))}
    </PaginaLegal>
  );
}

function correoTiendaValido(s) {
  const t = String(s || "").trim();
  if (!t) return false;
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(t);
}

// ── REGISTRO ──────────────────────────────────────────────────
function Registro({setUser,setPage}){
  const C = useTheme();
  const [nombre,  setNombre] = useState("");
  const [tel,     setTel]    = useState("");
  const [email,   setEmail]  = useState("");
  const [pwd,     setPwd]    = useState("");
  const [pwd2,    setPwd2]   = useState("");
  const [creando, setC]      = useState(false);
  const [error,   setError]  = useState("");
  const [acepto,  setAcepto] = useState(false);

  const contactoOk = telefonoMxValido(tel) || correoTiendaValido(email);

  const registrar = async () => {
    if(!nombre||!pwd) return;
    if(!contactoOk) {
      setError("Indicá un teléfono válido (10 dígitos) o un correo electrónico válido (podés poner ambos).");
      return;
    }
    if(pwd.length < 6) { setError("La contraseña debe tener al menos 6 caracteres."); return; }
    if(pwd !== pwd2) { setError("Las contraseñas no coinciden."); return; }
    setC(true); setError("");
    try{
      const telDigits = soloDigitosTel(tel);
      const { data: raw, error: err } = await supabase.rpc("registrar_cliente", {
        p_nombre:   nombre.trim(),
        p_telefono: telefonoMxValido(tel) ? telDigits : "",
        p_password: pwd,
        p_email:    correoTiendaValido(email) ? email.trim() : null,
        p_user_agent: navigator.userAgent || null,
      });
      if (err) throw err;
      const resp = normalizarSesionLoginResp(raw);
      if (!resp?.success) {
        setError(resp?.error || "No se pudo crear la cuenta.");
        setC(false); return;
      }
      const nuevo = resp.user || {};
      sessionStorage.setItem("farmax_cliente_token", String(resp.session_token));
      sessionStorage.setItem("farmax_user", JSON.stringify(nuevo));
      setUser(nuevo);
      setPage("cuenta");
    }catch(e){setError("Error al crear cuenta. Intenta de nuevo.");}
    setC(false);
  };
  return(
    <div style={{maxWidth:440,margin:"80px auto",padding:"0 24px"}}>
      <div style={{background:C.white,borderRadius:20,border:`1px solid ${C.border}`,padding:40}}>
        <div style={{display:"flex",justifyContent:"center",marginBottom:20}}><Logo size={40}/></div>
        <h1 style={{color:C.dark,fontSize:24,fontWeight:800,marginBottom:6,textAlign:"center"}}>Crear cuenta Farmax</h1>
        <p style={{color:C.mid,fontSize:14,marginBottom:28,textAlign:"center"}}>Regístrate y gana <strong style={{color:BRAND.accent}}>10 puntos de bienvenida ⭐</strong></p>
        <p style={{color:C.textMid,fontSize:12,marginBottom:20,textAlign:"center",lineHeight:1.5}}>Usá <strong>correo</strong>, <strong>teléfono</strong> o <strong>ambos</strong> para tu cuenta (necesitamos al menos uno).</p>
        <div style={{marginBottom:14}}><div style={{color:C.mid,fontSize:12,fontWeight:700,marginBottom:6}}>Nombre completo *</div><Inp value={nombre} onChange={e=>setNombre(e.target.value)} placeholder="Tu nombre" style={{width:"100%",boxSizing:"border-box"}}/></div>
        <div style={{marginBottom:14}}><div style={{color:C.mid,fontSize:12,fontWeight:700,marginBottom:6}}>Teléfono {correoTiendaValido(email)?"(opcional)":"(o completá correo abajo)"}</div><Inp value={tel} onChange={e=>setTel(e.target.value)} placeholder="55XXXXXXXX — 10 dígitos" type="tel" style={{width:"100%",boxSizing:"border-box"}}/></div>
        <div style={{marginBottom:14}}><div style={{color:C.mid,fontSize:12,fontWeight:700,marginBottom:6}}>Correo electrónico {telefonoMxValido(tel)?"(opcional)":"(o completá teléfono arriba)"}</div><Inp value={email} onChange={e=>setEmail(e.target.value)} placeholder="tu@correo.com" type="email" style={{width:"100%",boxSizing:"border-box"}}/></div>
        <div style={{marginBottom:14}}>
          <div style={{color:C.mid,fontSize:12,fontWeight:700,marginBottom:6}}>Contraseña * <span style={{color:C.dim,fontWeight:400}}>(mínimo 6 caracteres)</span></div>
          <input name="password" autoComplete="new-password" value={pwd} onChange={e=>setPwd(e.target.value)} placeholder="••••••••" type="password"
            style={{width:"100%",boxSizing:"border-box",padding:"9px 13px",borderRadius:8,border:`1px solid ${pwd.length>0&&pwd.length<6?C.red:C.border}`,background:C.white,color:C.dark,fontSize:16,outline:"none",fontFamily:"'Plus Jakarta Sans',sans-serif"}}/>
          {pwd.length>0&&pwd.length<6&&<div style={{color:C.red,fontSize:11,marginTop:4}}>Mínimo 6 caracteres</div>}
        </div>
        <div style={{marginBottom:20}}>
          <div style={{color:C.mid,fontSize:12,fontWeight:700,marginBottom:6}}>Confirmar contraseña *</div>
          <input name="password" autoComplete="new-password" value={pwd2} onChange={e=>setPwd2(e.target.value)} placeholder="••••••••" type="password"
            style={{width:"100%",boxSizing:"border-box",padding:"9px 13px",borderRadius:8,border:`1px solid ${pwd2.length>0&&pwd!==pwd2?C.red:C.border}`,background:C.white,color:C.dark,fontSize:16,outline:"none",fontFamily:"'Plus Jakarta Sans',sans-serif"}}/>
          {pwd2.length>0&&pwd!==pwd2&&<div style={{color:C.red,fontSize:11,marginTop:4}}>Las contraseñas no coinciden</div>}
        </div>
        {error&&<div style={{background:C.red+"10",border:`1px solid ${C.red}30`,borderRadius:8,padding:"10px 12px",marginBottom:14,color:C.red,fontSize:13}}>{error}</div>}
        <div style={{display:"flex",alignItems:"flex-start",gap:10,marginBottom:16,padding:"12px 14px",background:"#eff6ff",borderRadius:10,border:"1px solid #bfdbfe"}}>
          <input type="checkbox" id="acepto_privacidad" checked={acepto} onChange={e=>setAcepto(e.target.checked)}
            style={{width:16,height:16,marginTop:2,cursor:"pointer",flexShrink:0,accentColor:BRAND.primary}}/>
          <label htmlFor="acepto_privacidad" style={{color:"#1d4ed8",fontSize:12,lineHeight:1.5,cursor:"pointer"}}>
            He leído y acepto el{" "}
            <button onClick={()=>setPage("privacidad")} style={{background:"none",border:"none",color:BRAND.primary,fontWeight:700,fontSize:12,cursor:"pointer",padding:0,textDecoration:"underline"}}>
              Aviso de Privacidad
            </button>
            {" "}de Farmax. Autorizo el uso de mis datos para gestionar mi cuenta y programa de puntos. <span style={{color:"#ef4444",fontWeight:700}}>*</span>
          </label>
        </div>
        <Btn onClick={registrar} col={BRAND.primary} full disabled={!nombre||!contactoOk||!pwd||!pwd2||pwd!==pwd2||pwd.length<6||creando||!acepto}>{creando?"Creando cuenta...":"Crear mi cuenta →"}</Btn>
        <div style={{textAlign:"center",marginTop:16}}><span style={{color:C.mid,fontSize:13}}>¿Ya tienes cuenta? </span><button onClick={()=>setPage("login")} style={{background:"none",border:"none",color:BRAND.primary,fontWeight:700,fontSize:13,cursor:"pointer"}}>Iniciar sesión</button></div>
      </div>
    </div>
  );
}

// ── LOGIN ─────────────────────────────────────────────────────
function Login({setUser,setPage}){
  const C = useTheme();
  const [ident,     setIdent]  = useState("");
  const [pwd,     setPwd]  = useState("");
  const [buscando,setBusc] = useState(false);
  const [error,   setError]= useState("");
  const [intentos,setInt]  = useState(0);
  const [recMode, setRecMode] = useState(false);
  const [recIdent, setRecIdent] = useState("");
  const [recBusy, setRecBusy] = useState(false);
  const [recMsg, setRecMsg] = useState(null);

  const entrar = async () => {
    const id = ident.trim();
    if(!id||!pwd) return;
    if(intentos>=5){ setError("Demasiados intentos. Espera unos minutos."); return; }
    setBusc(true); setError("");
    try{
      const { data: raw, error: err } = await supabase.rpc("login_cliente", {
        p_telefono: correoTiendaValido(id) ? id : soloDigitosTel(id),
        p_password: pwd,
        p_user_agent: navigator.userAgent || null,
      });
      if (err) {
        setError("Error de conexión. Intenta de nuevo.");
        setBusc(false); return;
      }
      const resp = normalizarSesionLoginResp(raw);
      if (!resp?.success) {
        setInt(i=>i+1);
        setError(`${resp?.error || "Credenciales inválidas"} (${intentos+1}/5)`);
        setBusc(false); return;
      }
      const cliente = resp.user || {};
      setInt(0);
      sessionStorage.setItem("farmax_cliente_token", String(resp.session_token));
      sessionStorage.setItem("farmax_user", JSON.stringify(cliente));
      setUser(cliente);
      setPage("cuenta");
    }catch(e){setError("Error de conexión. Intenta de nuevo.");}
    setBusc(false);
  };

  const abrirRecuperar = () => {
    setRecMode(true);
    setRecMsg(null);
    setRecIdent(ident.trim());
  };

  const enviarRecuperar = async () => {
    const raw = recIdent.trim();
    const identNorm = correoTiendaValido(raw) ? raw : (telefonoMxValido(raw) ? soloDigitosTel(raw) : "");
    if (!identNorm) {
      setRecMsg({ ok: false, txt: "Escribí un correo válido o un teléfono con al menos 10 dígitos." });
      return;
    }
    setRecBusy(true);
    setRecMsg(null);
    try {
      const { data: resp, error: err } = await supabase.rpc("solicitar_reset_password", {
        p_identificador: identNorm,
        p_ip: null,
      });
      if (err || resp?.success === false) throw err || new Error(resp?.error || "rpc");
      setRecMsg({
        ok: true,
        txt: "Listo. Recibimos tu solicitud: el equipo de Farmax te contactará para activar tu contraseña de tienda. Si ya sos cliente de sucursal y no tenías clave web, también podés pedirla en mostrador.",
      });
    } catch (_) {
      setRecMsg({ ok: false, txt: "No se pudo enviar la solicitud. Intentá de nuevo o escribinos a contacto@farmax.mx." });
    }
    setRecBusy(false);
  };

  return(
    <div style={{maxWidth:420,margin:"80px auto",padding:"0 24px"}}>
      <div style={{background:C.white,borderRadius:20,border:`1px solid ${C.border}`,padding:40}}>
        <div style={{display:"flex",justifyContent:"center",marginBottom:20}}><Logo size={40}/></div>
        <h1 style={{color:C.dark,fontSize:24,fontWeight:800,marginBottom:6,textAlign:"center"}}>Iniciar sesión</h1>
        <p style={{color:C.mid,fontSize:14,marginBottom:28,textAlign:"center"}}>Accede a tus puntos, pedidos e historial</p>

        {recMode ? (
          <>
            <p style={{color:C.textMid,fontSize:13,marginBottom:16,lineHeight:1.5}}>
              Indicá el <strong>mismo correo o teléfono</strong> que usás en Farmax. Te avisaremos cuando tu cuenta tenga contraseña para la tienda.
            </p>
            <div style={{marginBottom:12}}>
              <div style={{color:C.mid,fontSize:12,fontWeight:700,marginBottom:6}}>Correo o teléfono</div>
              <input value={recIdent} onChange={e=>setRecIdent(e.target.value)}
                onKeyDown={e=>e.key==="Enter"&&enviarRecuperar()} placeholder="tu@correo.com o 55XXXXXXXX" type="text"
                style={{width:"100%",boxSizing:"border-box",padding:"9px 13px",borderRadius:8,border:`1px solid ${C.border}`,background:C.white,color:C.dark,fontSize:16,outline:"none",fontFamily:"'Plus Jakarta Sans',sans-serif"}}/>
            </div>
            {recMsg && (
              <div style={{
                background: recMsg.ok ? "#ecfdf5" : C.red+"10",
                border: `1px solid ${recMsg.ok ? "#6ee7b7" : C.red+"30"}`,
                borderRadius: 8, padding: "10px 12px", marginBottom: 12,
                color: recMsg.ok ? "#047857" : C.red, fontSize: 13, lineHeight: 1.45,
              }}>{recMsg.txt}</div>
            )}
            <Btn onClick={enviarRecuperar} col={BRAND.primary} full disabled={recBusy || !recIdent.trim()}>{recBusy ? "Enviando…" : "Enviar solicitud"}</Btn>
            <div style={{textAlign:"center",marginTop:14}}>
              <button type="button" onClick={()=>{ setRecMode(false); setRecMsg(null); }} style={{background:"none",border:"none",color:C.mid,fontSize:13,cursor:"pointer",textDecoration:"underline"}}>Volver al inicio de sesión</button>
            </div>
          </>
        ) : (
          <>
        <div style={{marginBottom:12}}>
          <div style={{color:C.mid,fontSize:12,fontWeight:700,marginBottom:6}}>Correo o teléfono</div>
          <input name="username" autoComplete="username email" value={ident} onChange={e=>setIdent(e.target.value)}
            onKeyDown={e=>e.key==="Enter"&&entrar()} placeholder="tu@correo.com o 55XXXXXXXX" type="text"
            style={{width:"100%",boxSizing:"border-box",padding:"9px 13px",borderRadius:8,border:`1px solid ${C.border}`,background:C.white,color:C.dark,fontSize:16,outline:"none",fontFamily:"'Plus Jakarta Sans',sans-serif"}}/>
        </div>
        <div style={{marginBottom:20}}>
          <div style={{color:C.mid,fontSize:12,fontWeight:700,marginBottom:6}}>Contraseña</div>
          <input name="password" autoComplete="current-password" value={pwd} onChange={e=>setPwd(e.target.value)}
            onKeyDown={e=>e.key==="Enter"&&entrar()} placeholder="••••••••" type="password"
            style={{width:"100%",boxSizing:"border-box",padding:"9px 13px",borderRadius:8,border:`1px solid ${C.border}`,background:C.white,color:C.dark,fontSize:16,outline:"none",fontFamily:"'Plus Jakarta Sans',sans-serif"}}/>
        </div>
        {error&&(<div style={{background:C.red+"10",border:`1px solid ${C.red}30`,borderRadius:8,padding:"10px 12px",marginBottom:12,color:C.red,fontSize:13}}>{error} <button type="button" onClick={()=>setPage("registro")} style={{background:"none",border:"none",color:BRAND.primary,fontWeight:700,fontSize:13,cursor:"pointer",textDecoration:"underline"}}>Crear cuenta</button></div>)}
        <Btn onClick={entrar} col={BRAND.primary} full disabled={!ident.trim()||!pwd||buscando}>{buscando?"Buscando...":"Entrar →"}</Btn>
        <div style={{textAlign:"center",marginTop:14}}>
          <button type="button" onClick={abrirRecuperar} style={{background:"none",border:"none",color:BRAND.primary,fontWeight:700,fontSize:13,cursor:"pointer",textDecoration:"underline"}}>¿Olvidaste tu contraseña o no tenés clave para la tienda?</button>
        </div>
        <div style={{textAlign:"center",marginTop:16}}><span style={{color:C.mid,fontSize:13}}>¿No tienes cuenta? </span><button type="button" onClick={()=>setPage("registro")} style={{background:"none",border:"none",color:BRAND.primary,fontWeight:700,fontSize:13,cursor:"pointer"}}>Regístrate aquí</button></div>
          </>
        )}
      </div>
    </div>
  );
}

// ── CUENTA ────────────────────────────────────────────────────
function CambiarPwdCliente({user}) {
  const C = useTheme();
  const [pwdA,  setPwdA]  = useState("");
  const [pwdN,  setPwdN]  = useState("");
  const [pwdN2, setPwdN2] = useState("");
  const [msg,   setMsg]   = useState(null);
  const [carg,  setCarg]  = useState(false);

  const hashP = async p => {
    const buf = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(p));
    return Array.from(new Uint8Array(buf)).map(b=>b.toString(16).padStart(2,"0")).join("");
  };

  const cambiar = async () => {
    if(!pwdA||!pwdN||!pwdN2) { setMsg({ok:false,txt:"Completa todos los campos"}); return; }
    if(pwdN.length<6) { setMsg({ok:false,txt:"La nueva contraseña debe tener al menos 6 caracteres"}); return; }
    if(pwdN!==pwdN2) { setMsg({ok:false,txt:"Las contraseñas no coinciden"}); return; }
    setCarg(true); setMsg(null);
    try {
      const tok = sessionStorage.getItem("farmax_cliente_token");
      if (!tok) { setMsg({ok:false,txt:"Sesión expirada. Inicia sesión de nuevo."}); setCarg(false); return; }
      const { data:resp, error:err } = await supabase.rpc("cliente_cambiar_password", {
        p_session_token: tok,
        p_password_actual: pwdA,
        p_password_nueva:  pwdN,
      });
      if (err) throw err;
      if (!resp?.success) { setMsg({ok:false,txt:resp?.error || "No se pudo cambiar"}); setCarg(false); return; }
      setMsg({ok:true,txt:"✅ Contraseña cambiada correctamente"});
      setPwdA(""); setPwdN(""); setPwdN2("");
    } catch(e) { setMsg({ok:false,txt:"Error: "+e.message}); }
    setCarg(false);
  };

  const inpS = {width:"100%",boxSizing:"border-box",padding:"8px 12px",borderRadius:8,border:`1px solid ${C.border}`,background:C.white,color:C.dark,fontSize:16,outline:"none",marginBottom:8};

  return(
    <div>
      <input type="password" placeholder="Contraseña actual" value={pwdA} onChange={e=>setPwdA(e.target.value)} style={inpS} autoComplete="current-password"/>
      <input type="password" placeholder="Nueva contraseña (mín. 6 chars)" value={pwdN} onChange={e=>setPwdN(e.target.value)} style={inpS} autoComplete="new-password"/>
      <input type="password" placeholder="Confirmar nueva contraseña" value={pwdN2} onChange={e=>setPwdN2(e.target.value)} style={{...inpS,marginBottom:10}} autoComplete="new-password"/>
      {msg&&<div style={{padding:"8px 12px",borderRadius:8,marginBottom:8,fontSize:12,fontWeight:600,background:msg.ok?"#dcfce7":"#fee2e2",color:msg.ok?"#16a34a":"#dc2626"}}>{msg.txt}</div>}
      <Btn onClick={cambiar} col={BRAND.primary} sm dis={carg}>{carg?"Cambiando...":"Cambiar contraseña"}</Btn>
    </div>
  );
}

function parseJsonObjectTienda(raw) {
  if (raw && typeof raw === "object") return raw;
  if (typeof raw === "string" && raw.trim()) {
    try {
      const p = JSON.parse(raw);
      return typeof p === "object" && p !== null ? p : {};
    } catch {
      return {};
    }
  }
  return {};
}

function lineasMedicamentosCita(c) {
  const mp = c?.medicamentos_prescritos;
  if (mp == null) return [];
  if (Array.isArray(mp)) {
    return mp
      .map((m) => {
        const nom = String(m.medicamento || m.nombre || "").trim();
        if (!nom) return null;
        const bits = [nom];
        if (m.dosis) bits.push(String(m.dosis));
        if (m.indicaciones) bits.push(String(m.indicaciones));
        return bits.join(" · ");
      })
      .filter(Boolean);
  }
  if (typeof mp === "string" && mp.trim().startsWith("[")) {
    try {
      const a = JSON.parse(mp);
      if (Array.isArray(a)) return lineasMedicamentosCita({ medicamentos_prescritos: a });
    } catch { /* ignore */ }
  }
  if (typeof mp === "string")
    return mp
      .split("\n")
      .map((s) => s.trim())
      .filter(Boolean);
  return [];
}

function lineasVitalsCita(c) {
  const o = parseJsonObjectTienda(c?.signos_vitales);
  const order = [
    ["ta", "TA"],
    ["fc", "FC"],
    ["temp", "Temp."],
    ["sat", "SatO2"],
    ["peso", "Peso"],
    ["talla", "Talla"],
  ];
  return order
    .map(([k, lab]) => {
      const v = o[k];
      if (v == null || String(v).trim() === "") return null;
      return `${lab} ${v}`;
    })
    .filter(Boolean);
}

function etiquetaEstadoCitaCliente(c) {
  if (!c) return { label: "—", col: C.mid };
  if (c.estado === "cancelada") return { label: "Cancelada", col: C.red };
  if (c.estado === "no_asistio") return { label: "No asistió", col: C.dim };
  if (c.estado === "completada") return { label: "Atendida", col: BRAND.primary };
  if (c.estado === "en_consulta") return { label: "En consulta", col: "#d97706" };
  if (citaPagoOk(c)) return { label: "Confirmada", col: BRAND.accent };
  return { label: "Pendiente de pago", col: "#d97706" };
}

function etiquetaEstadoPagoPedido(p) {
  const muted = "#64748b";
  const s = String(p?.payment_status || "").toLowerCase();
  if (s === "approved") return { label: "Pago aprobado", col: BRAND.accent };
  if (["pending", "in_process", "initiated"].includes(s)) return { label: "Pago pendiente", col: "#d97706" };
  if (s) return { label: `Pago ${s}`, col: muted };
  if (String(p?.metodo_pago || "").toLowerCase() === "mercadopago") return { label: "Pago por confirmar", col: "#d97706" };
  return { label: "Sin pago online", col: muted };
}

function etiquetaLogisticaPedido(p) {
  const danger = "#ef4444";
  const ds = String(p?.delivery_status || "").toLowerCase();
  if (ds === "ready_for_pickup") return { label: "Listo para recoger", col: BRAND.accent };
  if (ds === "in_route") return { label: "En ruta", col: "#0ea5e9" };
  if (ds === "delivered") return { label: "Entregado", col: BRAND.primary };
  if (ds === "cancelled") return { label: "Entrega cancelada", col: danger };
  if (p?.tipo_entrega === "envio") {
    if (p?.estado === "listo") return { label: "Listo para envio", col: BRAND.accent };
    if (p?.estado === "completado") return { label: "Entregado", col: BRAND.primary };
    return { label: "Preparando envio", col: "#d97706" };
  }
  if (p?.estado === "listo") return { label: "Listo para recoger", col: BRAND.accent };
  if (p?.estado === "completado") return { label: "Entregado", col: BRAND.primary };
  return { label: "En preparacion", col: "#d97706" };
}

function Cuenta({user,setPage,setUser}){
  const C = useTheme();
  const [tab,setTab]=useState("pedidos");
  const [pedidos,setPeds]=useState([]);
  const [citas,setCitas]=useState([]);
  const [cargando,setC]=useState(true);
  const [busyCitaId,setBusyCitaId]=useState(null);
  const [busyPayPedidoId,setBusyPayPedidoId]=useState(null);
  useEffect(()=>{
    if(!user?.id){setC(false);return;}
    Promise.all([
      supabase.from("pedidos").select(`id,total,estado,tipo,metodo_pago,tipo_entrega,direccion,created_at,payment_provider,payment_status,payment_id,paid_at,delivery_provider,delivery_status,delivery_tracking_url,pedido_items(cantidad,precio_unitario,productos(nombre))`).eq("cliente_id",user.id).order("created_at",{ascending:false}),
      supabase.from("citas").select("*").eq("cliente_id",user.id).order("fecha",{ascending:false}),
    ]).then(([{data:peds},{data:cts}])=>{setPeds(peds||[]);setCitas(cts||[]);setC(false);});
  },[user]);
  const refreshCitas = async ()=>{
    if(!user?.id) return;
    const { data } = await supabase.from("citas").select("*").eq("cliente_id",user.id).order("fecha",{ascending:false});
    setCitas(data||[]);
  };
  const cancelarCita = async (cita)=>{
    const tok = sessionStorage.getItem("farmax_cliente_token");
    if (!tok) { alert("Tu sesión expiró. Inicia sesión de nuevo."); return; }
    if (!window.confirm(`¿Cancelar la cita del ${cita.fecha} a las ${cita.hora}?`)) return;
    setBusyCitaId(cita.id);
    try {
      const { data: resp, error } = await supabase.rpc("cliente_cancelar_cita", {
        p_session_token: tok,
        p_cita_id: cita.id,
      });
      if (error || !resp?.success) throw error || new Error(resp?.error || "No se pudo cancelar");
      await refreshCitas();
      alert("Cita cancelada.");
    } catch (e) {
      alert("No se pudo cancelar la cita.");
    }
    setBusyCitaId(null);
  };
  const reagendarCita = (cita)=>{
    try {
      sessionStorage.setItem("farmax_cita_draft", JSON.stringify({
        id: cita.id,
        fecha: cita.fecha || "",
        hora: cita.hora || "",
        motivo: cita.motivo || "",
        nombre: user?.nombre || "",
        tel: user?.telefono || "",
      }));
    } catch (_) { /* noop */ }
    setPage("cita");
  };
  const pagarPedidoMercadoPago = async (p) => {
    const tokCli = sessionStorage.getItem("farmax_cliente_token");
    if (!tokCli) { alert("Tu sesion expiro. Inicia sesion nuevamente."); setPage("login"); return; }
    setBusyPayPedidoId(p.id);
    try {
      const mpResp = await fetch("/api/payments/mp/create-preference", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${tokCli}`,
        },
        body: JSON.stringify({
          pedidoId: p.id,
          amount: Number(p.total || 0),
          baseUrl: window.location.origin,
          payer: {
            name: String(user?.nombre || "").trim() || null,
            email: String(user?.email || "").trim() || null,
          },
          items: (p.pedido_items || []).map((it) => ({
            title: it?.productos?.nombre || "Producto",
            quantity: Number(it?.cantidad) || 1,
            unit_price: Number(it?.precio_unitario) || 0,
          })),
        }),
      });
      const mpData = await mpResp.json().catch(() => ({}));
      if (!mpResp.ok || !mpData?.ok || !(mpData.initPoint || mpData.sandboxInitPoint)) {
        const msg = mpData?.error || "No se pudo iniciar Mercado Pago.";
        alert(msg);
        setBusyPayPedidoId(null);
        return;
      }
      window.location.href = mpData.initPoint || mpData.sandboxInitPoint;
    } catch (e) {
      alert("No se pudo iniciar Mercado Pago.");
      setBusyPayPedidoId(null);
    }
  };
  if(!user) return(<div style={{maxWidth:500,margin:"80px auto",padding:"0 24px",textAlign:"center"}}><div style={{fontSize:48,marginBottom:16}}>👤</div><h2 style={{color:C.dark,fontSize:22,fontWeight:800,marginBottom:16}}>Inicia sesión para ver tu cuenta</h2><div style={{display:"flex",gap:12,justifyContent:"center"}}><Btn onClick={()=>setPage("login")} col={BRAND.primary}>Iniciar sesión</Btn><Btn onClick={()=>setPage("registro")} outline col={BRAND.primary}>Crear cuenta</Btn></div></div>);
  const eCol=e=>({pendiente:"#f59e0b",confirmado:BRAND.accent,entregado:BRAND.primary,cancelado:C.red}[e]||C.mid);
  const citaPuedeGestionar = (c) =>
    c &&
    c.estado !== "cancelada" &&
    c.estado !== "completada" &&
    c.estado !== "no_asistio" &&
    c.estado !== "en_consulta";
  return(
    <div style={{maxWidth:900,margin:"0 auto",padding:"32px 24px"}}>
      <div style={{background:BRAND.gradient,borderRadius:16,padding:28,marginBottom:24,display:"flex",alignItems:"center",gap:20}}>
        <div style={{width:64,height:64,borderRadius:"50%",background:"rgba(255,255,255,.25)",display:"flex",alignItems:"center",justifyContent:"center",color:C.white,fontWeight:900,fontSize:26}}>{(primerNombre(user.nombre)||"C")[0].toUpperCase()}</div>
        <div style={{flex:1}}><div style={{color:C.white,fontWeight:800,fontSize:22}}>{saludoUsuario(user.nombre)}</div><div style={{color:"rgba(255,255,255,.8)",fontSize:14,marginTop:2}}>{user.telefono}</div></div>
        <div style={{textAlign:"center"}}><div style={{color:"#ffaa00",fontWeight:900,fontSize:36}}>{user.puntos||0}</div><div style={{color:"rgba(255,255,255,.8)",fontSize:13}}>puntos Farmax</div><div style={{color:"rgba(255,255,255,.6)",fontSize:11}}>= ${((user.puntos||0)*0.5).toFixed(0)} en descuentos</div></div>
      </div>
      <div style={{display:"flex",gap:6,marginBottom:20,background:C.white,borderRadius:12,padding:6,border:`1px solid ${C.border}`}}>
        {[["pedidos","📦 Mis pedidos"],["citas","📅 Mis citas"],["canjear","⭐ Canjear"],["datos","👤 Mis datos"]].map(([v,l])=>(
          <button key={v} onClick={()=>setTab(v)} style={{flex:1,padding:"10px",borderRadius:8,border:"none",background:tab===v?BRAND.primary:"transparent",color:tab===v?C.white:C.mid,fontWeight:tab===v?700:500,cursor:"pointer",fontSize:13,transition:"all .15s"}}>{l}</button>
        ))}
      </div>
      {tab==="pedidos"&&(cargando?<div style={{textAlign:"center",padding:40,color:C.mid}}>Cargando pedidos...</div>:!pedidos.length?(
        <div style={{background:C.white,borderRadius:14,border:`1px solid ${C.border}`,padding:40,textAlign:"center"}}><div style={{fontSize:40,marginBottom:12}}>📦</div><div style={{color:C.mid,fontSize:15}}>Aún no tienes pedidos en Farmax</div><Btn onClick={()=>setPage("catalogo")} col={BRAND.primary} sm style={{marginTop:16}}>Hacer mi primer pedido</Btn></div>
      ):pedidos.map(p=>(
        <div key={p.id} style={{background:C.white,borderRadius:14,border:`1px solid ${C.border}`,padding:20,marginBottom:12}}>
          <div style={{display:"flex",justifyContent:"space-between",alignItems:"flex-start",marginBottom:12}}>
            <div><div style={{color:C.dark,fontWeight:700,fontSize:15}}>Pedido #{p.id}</div><div style={{color:C.dim,fontSize:12,marginTop:2}}>{new Date(p.created_at).toLocaleDateString("es-MX",{year:"numeric",month:"long",day:"numeric"})}</div></div>
            <div style={{textAlign:"right"}}><div style={{color:BRAND.primary,fontWeight:800,fontSize:16}}>{$(p.total)}</div><Tag col={eCol(p.estado)} sm>{p.estado}</Tag></div>
          </div>
          <div style={{display:"flex",gap:8,flexWrap:"wrap",marginBottom:10}}>
            {(()=>{ const ep = etiquetaEstadoPagoPedido(p); return <Tag col={ep.col} sm>{ep.label}</Tag>; })()}
            {(()=>{ const el = etiquetaLogisticaPedido(p); return <Tag col={el.col} sm>{el.label}</Tag>; })()}
            {p.delivery_provider ? <Tag col={C.blue} sm>{String(p.delivery_provider).toUpperCase()}</Tag> : null}
          </div>
          {p.delivery_tracking_url ? (
            <div style={{fontSize:12,color:C.textMid,marginBottom:10}}>
              Tracking: <a href={p.delivery_tracking_url} target="_blank" rel="noreferrer" style={{color:BRAND.primary,fontWeight:700}}>Ver seguimiento</a>
            </div>
          ) : null}
          {String(p.metodo_pago || "").toLowerCase() === "mercadopago" && String(p.payment_status || "").toLowerCase() !== "approved" ? (
            <div style={{marginBottom:10}}>
              <Btn onClick={()=>pagarPedidoMercadoPago(p)} col={BRAND.primary} sm disabled={busyPayPedidoId===p.id}>
                {busyPayPedidoId===p.id ? "Abriendo pago..." : "Pagar ahora"}
              </Btn>
            </div>
          ) : null}
          <div style={{background:C.cardDark,borderRadius:10,padding:"10px 14px"}}>
            <div style={{color:C.mid,fontSize:11,fontWeight:700,marginBottom:8,textTransform:"uppercase",letterSpacing:1}}>Productos</div>
            {(p.pedido_items||[]).map((item,i)=>(<div key={i} style={{display:"flex",justifyContent:"space-between",marginBottom:4}}><span style={{color:C.dark,fontSize:13}}>{item.productos?.nombre||"Producto"} ×{item.cantidad}</span><span style={{color:BRAND.primary,fontSize:13,fontWeight:600}}>{$(item.precio_unitario*item.cantidad)}</span></div>))}
          </div>
        </div>
      )))}
      {tab==="citas"&&(cargando?<div style={{textAlign:"center",padding:40,color:C.mid}}>Cargando citas...</div>:!citas.length?(
        <div style={{background:C.white,borderRadius:14,border:`1px solid ${C.border}`,padding:40,textAlign:"center"}}><div style={{fontSize:40,marginBottom:12}}>📅</div><div style={{color:C.mid,fontSize:15}}>No tienes citas agendadas</div><Btn onClick={()=>setPage("cita")} col={BRAND.primary} sm style={{marginTop:16}}>Agendar consulta médica</Btn></div>
      ):citas.map(c=>{
        const ev = etiquetaEstadoCitaCliente(c);
        const meds = lineasMedicamentosCita(c);
        const vit = lineasVitalsCita(c);
        const mostrarResumen = c.estado === "completada" || c.estado === "no_asistio";
        return (
        <div key={c.id} style={{background:C.white,borderRadius:14,border:`1px solid ${C.border}`,padding:20,marginBottom:12}}>
          <div style={{display:"flex",justifyContent:"space-between",alignItems:"flex-start",marginBottom:10}}>
            <div><div style={{color:C.dark,fontWeight:700,fontSize:15}}>📅 Consulta médica</div><div style={{color:BRAND.primary,fontWeight:700,fontSize:14,marginTop:4}}>{c.fecha} · {c.hora} hrs</div></div>
            <Tag col={ev.col} sm>{ev.label}</Tag>
          </div>
          {c.motivo&&<div style={{background:C.cardDark,borderRadius:8,padding:"8px 12px",color:C.mid,fontSize:13}}>Motivo: {c.motivo}</div>}
          {mostrarResumen && (
            <div style={{ marginTop: 12, padding: "12px 14px", borderRadius: 10, background: C.cardDark, fontSize: 13, color: C.dark, lineHeight: 1.5 }}>
              <div style={{ fontWeight: 800, fontSize: 11, color: C.mid, marginBottom: 8, textTransform: "uppercase", letterSpacing: 0.5 }}>Resumen de tu visita</div>
              {c.diagnostico ? <div style={{ marginBottom: 8 }}><strong style={{ color: C.mid }}>Diagnóstico</strong> · {c.diagnostico}</div> : null}
              {meds.length > 0 ? (
                <div style={{ marginBottom: 8 }}>
                  <div style={{ fontWeight: 700, color: C.mid, fontSize: 12, marginBottom: 4 }}>Medicación indicada</div>
                  <ul style={{ margin: 0, paddingLeft: 18 }}>
                    {meds.map((line, i) => (
                      <li key={i} style={{ marginBottom: 2 }}>{line}</li>
                    ))}
                  </ul>
                </div>
              ) : null}
              {c.notas_medico ? <div style={{ marginBottom: 8 }}><strong style={{ color: C.mid }}>Indicaciones</strong> · {c.notas_medico}</div> : null}
              {vit.length > 0 ? (
                <div>
                  <div style={{ fontWeight: 700, color: C.mid, fontSize: 12, marginBottom: 4 }}>Signos vitales</div>
                  <div>{vit.join(" · ")}</div>
                </div>
              ) : null}
              {!c.diagnostico && meds.length === 0 && !c.notas_medico && vit.length === 0 && (
                <div style={{ color: C.dim, fontSize: 12 }}>Tu médico aún no registró notas de esta consulta o no aplican a tu resumen.</div>
              )}
            </div>
          )}
          {citaPuedeGestionar(c)&&(
            <div style={{display:"flex",gap:8,marginTop:12,flexWrap:"wrap"}}>
              <Btn sm outline col={BRAND.primary} onClick={()=>reagendarCita(c)}>Reagendar</Btn>
              <Btn sm outline col={C.red} onClick={()=>cancelarCita(c)} disabled={busyCitaId===c.id}>
                {busyCitaId===c.id?"Cancelando...":"Cancelar cita"}
              </Btn>
            </div>
          )}
        </div>
        );
      }))}
      {tab==="canjear"&&(
        <div style={{background:C.white,borderRadius:14,border:`1px solid ${C.border}`,padding:24}}>
          <div style={{color:C.dark,fontWeight:700,fontSize:16,marginBottom:16}}>Tienes {user.puntos||0} puntos = ${((user.puntos||0)*0.5).toFixed(0)} en valor</div>
          {[{pts:20,ben:"$10 descuento en Farmax",col:BRAND.accent,icon:"💊"},{pts:50,ben:"Envío gratis",col:BRAND.secondary,icon:"📦"},{pts:100,ben:"$50 descuento",col:BRAND.primary,icon:"🎁"},{pts:160,ben:"Consulta médica gratis",col:"#f59e0b",icon:"🏥"},{pts:200,ben:"Producto gratis",col:C.red,icon:"⭐"}].map(r=>(
            <div key={r.pts} style={{display:"flex",alignItems:"center",gap:14,padding:16,borderRadius:12,border:`1px solid ${(user.puntos||0)>=r.pts?r.col+"40":C.border}`,background:(user.puntos||0)>=r.pts?r.col+"08":C.cardDark,marginBottom:10}}>
              <div style={{fontSize:28}}>{r.icon}</div>
              <div style={{flex:1}}><div style={{color:C.dark,fontWeight:700,fontSize:14}}>{r.ben}</div><div style={{color:r.col,fontSize:12,fontWeight:700,marginTop:2}}>{r.pts} puntos</div></div>
              <Btn sm col={r.col} disabled={(user.puntos||0)<r.pts}>{(user.puntos||0)>=r.pts?"Canjear":"Faltan "+(r.pts-(user.puntos||0))}</Btn>
            </div>
          ))}
        </div>
      )}
      {tab==="datos"&&(
        <div style={{background:C.white,borderRadius:14,border:`1px solid ${C.border}`,padding:24}}>
          {[["Nombre",user.nombre],["Teléfono",user.telefono],["Correo",user.email||"No registrado"],["Puntos",`${user.puntos||0} pts Farmax`]].map(([l,v])=>(<div key={l} style={{display:"flex",justifyContent:"space-between",alignItems:"center",padding:"12px 0",borderBottom:`1px solid ${C.border}`}}><span style={{color:C.mid,fontSize:13}}>{l}</span><span style={{color:C.dark,fontSize:14,fontWeight:700}}>{v}</span></div>))}
          <div style={{marginTop:16,padding:16,background:"#f8fafc",borderRadius:10,border:`1px solid ${C.border}`}}>
            <div style={{color:C.dark,fontWeight:700,fontSize:13,marginBottom:12}}>🔑 Cambiar contraseña</div>
            <CambiarPwdCliente user={user}/>
          </div>
          <div style={{marginTop:16}}><Btn sm col={C.red} outline onClick={async()=>{
            const tok = sessionStorage.getItem("farmax_cliente_token");
            if (tok) { try { await supabase.rpc("logout_cliente", { p_session_token: tok }); } catch(e){} }
            sessionStorage.removeItem("farmax_cliente_token");
            sessionStorage.removeItem("farmax_user");
            setUser(null); setPage("home");
          }}>⎋ Cerrar sesión</Btn></div>
        </div>
      )}
    </div>
  );
}

// ── APP PRINCIPAL ─────────────────────────────────────────────
export default function TiendaFarmax(){
  const C = useTheme();
  const [page,setPageRaw] = useState("home");
  const setPage = (p) => { window.history.pushState({page:p},"",window.location.pathname); setPageRaw(p); };
  useEffect(()=>{
    const h=(e)=>setPageRaw(e.state?.page||"home");
    window.addEventListener("popstate",h);
    window.history.replaceState({page:"home"},"",window.location.pathname);
    return ()=>window.removeEventListener("popstate",h);
  },[]);
  useEffect(()=>{
    try {
      if ("scrollRestoration" in window.history) window.history.scrollRestoration = "manual";
    } catch (_) { /* noop */ }
  },[]);
  useEffect(()=>{
    const id = window.requestAnimationFrame(()=>{ window.scrollTo(0, 0); });
    return ()=>window.cancelAnimationFrame(id);
  },[page]);
  const [cart,setCart]           = useState([]);
  const [user,setUser]           = useState(()=>{ try{ const u=sessionStorage.getItem("farmax_user"); return u?JSON.parse(u):null; }catch{ return null; } });
  const [productos,setProductos] = useState([]);
  const [cargando,setCargando]   = useState(true);
  const [prodDetalle,setProdD]   = useState(null);
  const [busqHero,setBusqHero]   = useState("");
  const [showPopup,setShowPopup] = useState(false);
  const [entregaCheckout,setEntregaCheckout] = useState("pickup");
  const [precioConsultaCfg,setPrecioConsultaCfg] = useState(CONSULTA_PRECIO_DEFAULT);
  const [placeholderProductoUrl, setPlaceholderProductoUrl] = useState("");

  useEffect(() => {
    fetchPrecioConsultaConfig(supabase).then(setPrecioConsultaCfg);
  }, []);

  useEffect(() => {
    supabase
      .from("configuracion")
      .select("valor")
      .eq("clave", "placeholder_producto_url")
      .maybeSingle()
      .then(({ data }) => {
        const v = data?.valor != null ? String(data.valor).trim() : "";
        if (v) setPlaceholderProductoUrl(v);
      });
  }, []);

  // Sesión persistente
  useEffect(()=>{
    if(user) sessionStorage.setItem("farmax_user",JSON.stringify(user));
    else sessionStorage.removeItem("farmax_user");
  },[user]);

  // Cargar productos (mismas filas/columnas que inventario: imagen_url, imagen_mobile_url)
  useEffect(()=>{
    let cancelled = false;
    const loadProductos = ()=>{
      supabase.from("productos").select("*").eq("activo",true).order("id")
        .then(({data,error})=>{
          if (cancelled) return;
          if (error) console.error("[Tienda] productos:", error);
          if (data?.length) setProductos(data);
          else if (data && data.length === 0) setProductos([]);
          setCargando(false);
        });
    };
    loadProductos();
    const onVis = ()=>{ if (document.visibilityState==="visible") loadProductos(); };
    document.addEventListener("visibilitychange", onVis);
    return ()=>{ cancelled = true; document.removeEventListener("visibilitychange", onVis); };
  },[]);

  // Mostrar popup 1 vez por sesión si no está logueado
  useEffect(()=>{
    if(!cargando&&!user){
      const visto=sessionStorage.getItem("farmax_popup_visto");
      if(!visto){
        const t=setTimeout(()=>{setShowPopup(true);sessionStorage.setItem("farmax_popup_visto","1");},2000);
        return ()=>clearTimeout(t);
      }
    }
  },[cargando,user]);

  const addToCart=prod=>{
    if (!prod || !prod.activo || Number(prod.stock||0) <= 0) return;
    if (!productoPermitidoEnTiendaFarmaciaWeb(prod)) {
      alert(
        productoEsCategoriaMinisuperTienda(prod)
          ? "Artículo de minisuper: no está en la tienda farmacia en línea. Disponible en sucursal."
          : "Este producto no está disponible para compra en línea (receta, controlado o no publicado en tienda). Pásate por la farmacia."
      );
      return;
    }
    setCart(p=>{
      const ex=p.find(c=>c.id===prod.id);
      if (ex) {
        const nextQty = ex.qty + 1;
        if (nextQty > Number(prod.stock||0)) return p;
        return p.map(c=>c.id===prod.id?{...c,qty:nextQty}:c);
      }
      return [...p,{...prod,qty:1,precio:Number(prod.precio ?? prod.precio ?? 0)}];
    });
  };

  /** Catálogo visible en la tienda web de farmacia (sin líneas minisuper; ver `tiendaFarmaciaCatalogo.js`). */
  const productosVistaTiendaFarmacia = useMemo(
    () => productos.filter((p) => !productoEsCategoriaMinisuperTienda(p)),
    [productos]
  );

  if(cargando) return(<div style={{display:"flex",alignItems:"center",justifyContent:"center",minHeight:"100vh",background:C.bg,flexDirection:"column",gap:16}}><Logo size={48}/><div style={{color:C.mid,fontSize:15}}>Cargando Farmax...</div></div>);

  const puntosPage=(
    <div style={{maxWidth:700,margin:"0 auto",padding:"40px 24px"}}>
      <div style={{textAlign:"center",marginBottom:40}}>
        <div style={{fontSize:56,marginBottom:12}}>⭐</div>
        <h1 style={{color:C.dark,fontSize:32,fontWeight:800,marginBottom:12}}>Programa Puntos Farmax</h1>
        <p style={{color:C.mid,fontSize:16,lineHeight:1.7,maxWidth:500,margin:"0 auto 24px"}}>Gana puntos en cada compra y canjéalos por descuentos, envíos gratis o consultas médicas.</p>
        {user?(
          <div style={{background:BRAND.gradient,borderRadius:16,padding:24,display:"inline-flex",alignItems:"center",gap:20,marginBottom:8}}>
            <div style={{textAlign:"center"}}>
              <div style={{color:"#ffaa00",fontWeight:900,fontSize:48,lineHeight:1}}>{user.puntos||0}</div>
              <div style={{color:"rgba(255,255,255,.8)",fontSize:14}}>puntos disponibles</div>
              <div style={{color:"rgba(255,255,255,.6)",fontSize:12}}>= ${((user.puntos||0)*0.5).toFixed(0)} en valor</div>
            </div>
          </div>
        ):(
          <div style={{display:"flex",gap:12,justifyContent:"center"}}>
            <Btn onClick={()=>setPage("registro")} col={BRAND.primary}>Crear cuenta y ganar puntos →</Btn>
            <Btn onClick={()=>setPage("login")} outline col={BRAND.primary}>Ya tengo cuenta</Btn>
          </div>
        )}
      </div>
      <div style={{background:C.white,borderRadius:16,border:`1px solid ${C.border}`,padding:28,marginBottom:20}}>
        <h2 style={{color:C.dark,fontSize:18,fontWeight:800,marginBottom:20}}>💰 ¿Cómo ganar puntos?</h2>
        <div style={{display:"grid",gridTemplateColumns:"repeat(auto-fill,minmax(min(100%,160px),1fr))",gap:14}}>
          {[{icon:"🛒",t:"Compras farmacia",d:"1 punto / $10"},{icon:"💻",t:"Compras en línea",d:"1.5 puntos / $10"},{icon:"🏥",t:"Consulta médica",d:"5 puntos"},{icon:"🎂",t:"Mes cumpleaños",d:"2× puntos"},{icon:"👋",t:"Registro nuevo",d:"10 pts bienvenida"}].map(r=>(
            <div key={r.t} style={{background:"#f8fafc",borderRadius:12,padding:16,textAlign:"center"}}>
              <div style={{fontSize:28,marginBottom:8}}>{r.icon}</div>
              <div style={{color:C.dark,fontWeight:700,fontSize:13,marginBottom:4}}>{r.t}</div>
              <div style={{color:BRAND.primary,fontSize:12,fontWeight:700}}>{r.d}</div>
            </div>
          ))}
        </div>
      </div>
      <div style={{background:C.white,borderRadius:16,border:`1px solid ${C.border}`,padding:28,marginBottom:20}}>
        <h2 style={{color:C.dark,fontSize:18,fontWeight:800,marginBottom:20}}>🎁 ¿Qué puedes canjear?</h2>
        <div style={{display:"flex",flexDirection:"column",gap:10}}>
          {[{pts:20,ben:"$10 de descuento",icon:"💊",col:BRAND.secondary},{pts:50,ben:"Envío gratis",icon:"📦",col:BRAND.accent},{pts:100,ben:"$50 de descuento",icon:"🎁",col:BRAND.primary},{pts:160,ben:"Consulta médica gratis",icon:"🏥",col:"#f59e0b"},{pts:200,ben:"Producto gratis",icon:"⭐",col:"#9d6fff"}].map(r=>(
            <div key={r.pts} style={{display:"flex",alignItems:"center",gap:14,padding:14,borderRadius:12,border:`1px solid ${(user?.puntos||0)>=r.pts?r.col+"40":C.border}`,background:(user?.puntos||0)>=r.pts?r.col+"08":"#f8fafc"}}>
              <span style={{fontSize:28}}>{r.icon}</span>
              <div style={{flex:1}}>
                <div style={{color:C.dark,fontWeight:700,fontSize:14}}>{r.ben}</div>
                <div style={{color:r.col,fontSize:12,fontWeight:700,marginTop:2}}>{r.pts} puntos</div>
              </div>
              {user&&<span style={{padding:"4px 12px",borderRadius:20,fontSize:11,fontWeight:700,background:(user.puntos||0)>=r.pts?r.col+"20":"#e2e8f0",color:(user.puntos||0)>=r.pts?r.col:"#94a3b8"}}>{(user.puntos||0)>=r.pts?"✓ Disponible":`Faltan ${r.pts-(user.puntos||0)}`}</span>}
            </div>
          ))}
        </div>
        {user&&<div style={{marginTop:16,textAlign:"center"}}><Btn onClick={()=>setPage("cuenta")} col={BRAND.primary}>Ir a canjear →</Btn></div>}
      </div>
      <div style={{textAlign:"center"}}><button onClick={()=>setPage("terminos-puntos")} style={{background:"none",border:"none",color:C.mid,fontSize:12,cursor:"pointer",textDecoration:"underline"}}>Ver términos del programa</button></div>
    </div>
  );

  const pages={
    home:          <Home setPage={setPage} addToCart={addToCart} productos={productosVistaTiendaFarmacia} setProdDetalle={setProdD} busqHero={busqHero} setBusqHero={setBusqHero} precioConsulta={precioConsultaCfg}/>,
    catalogo:      <Catalogo addToCart={addToCart} productos={productosVistaTiendaFarmacia} setProdDetalle={setProdD} setPage={setPage} busqHero={busqHero} setBusqHero={setBusqHero}/>,
    promo:         <PromocionesPage setPage={setPage}/>,
    detalle:       <DetalleProducto prod={prodDetalle} productos={productosVistaTiendaFarmacia} addToCart={addToCart} setPage={setPage} setProdDetalle={setProdD} busqHero={busqHero} setBusqHero={setBusqHero}/>,
    carrito:       <Carrito cart={cart} setCart={setCart} setPage={setPage} setEntregaGlobal={setEntregaCheckout}/>,
    checkout:      <Checkout cart={cart} setCart={setCart} setPage={setPage} user={user} setUser={setUser} entrega={entregaCheckout} catalogoProductos={productosVistaTiendaFarmacia}/>,
    cita:          <AgendarCita setPage={setPage} user={user}/>,
    login:         <Login setUser={setUser} setPage={setPage}/>,
    registro:      <Registro setUser={setUser} setPage={setPage}/>,
    cuenta:        <Cuenta user={user} setPage={setPage} setUser={setUser}/>,
    puntos:        puntosPage,
    faq:           <FAQPage setPage={setPage}/>,
    privacidad:    <AvisoPrivacidad setPage={setPage}/>,
    terminos:      <TerminosCondiciones setPage={setPage}/>,
    envios:        <PoliticaEnvios setPage={setPage}/>,
    "terminos-puntos": <TerminosPuntos setPage={setPage}/>,
  };

  const sinFooter=["home"];

  return(
    <TiendaPlaceholderCtx.Provider value={placeholderProductoUrl}>
    <>
      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap');
        *{box-sizing:border-box;margin:0;padding:0;}
        html{-webkit-text-size-adjust:100%;}
        body{background:${C.bg};font-family:'Plus Jakarta Sans',sans-serif;color:${C.dark};}
        /* Header sticky: debe quedar FUERA de un padre con overflow-x:hidden (rompe sticky en móvil). */
        main{overflow-x:hidden;width:100%;max-width:100%;padding-bottom:env(safe-area-inset-bottom, 0px);}
        img,svg,video,canvas{max-width:100%;height:auto;}
        ::-webkit-scrollbar{width:6px;}::-webkit-scrollbar-track{background:${C.bg};}::-webkit-scrollbar-thumb{background:${C.border};border-radius:4px;}
        button,select{font-family:'Plus Jakarta Sans',sans-serif;}
      `}</style>

      {/* Popup bienvenida */}
      {showPopup&&<PopupBienvenida onClose={()=>setShowPopup(false)} setPage={setPage} precioConsulta={precioConsultaCfg}/>}

      <Header page={page} setPage={setPage} cart={cart} user={user} setUser={setUser}/>

      <div style={{width:"100%",minHeight:"min(100vh,100dvh)"}}>
        <main style={{minHeight:"min(100vh, 100dvh)",background:C.bg}}>
          {pages[page]||pages.home}
        </main>
        {!sinFooter.includes(page)&&<Footer setPage={setPage}/>}
      </div>
    </>
    </TiendaPlaceholderCtx.Provider>
  );
}
