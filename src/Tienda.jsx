import { useState, useEffect, useMemo, createContext, useContext, useRef } from "react";
import { supabase, isSupabaseProductionMisconfigured, isSupabaseLocalMisconfigured } from "./supabase";
import { useTheme } from "./themeContext";
import { useMediaQuery, useNarrowForBannerImage } from "./hooks/useMediaQuery";
import { saludoUsuario, primerNombre, $, normalizarSesionLoginResp, nombreCompletoPacienteValido, telefonoMxValido, soloDigitosTel, getClienteToken } from "./utils";
import {
  setClienteSession,
  clearClienteSession,
  getClienteUser,
  setPostLoginPage,
  getPostLoginPage,
  consumePostLoginPage,
  navigateToCita,
} from "./utils/clienteSession";
import { tiendaProductMatchesBusqueda, spellSuggestFromProducts, tiendaCatalogSearchSuggestions, tiendaSearchRelevanceRank } from "./utils/fuzzySearch";
import { CONSULTA_PRECIO_DEFAULT, citaPagoOk, labelEstadoPagoCita } from "./utils/consultaConstants";
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
import { showToast, Logo, BrandSplash } from "./ui";
import {
  formatFolioOnline,
  FARMACIA_WHATSAPP_DISPLAY,
  notifyOnlineOrderReceipt,
  openWhatsAppToFarmacia,
  buildCustomerToFarmaciaMessage,
} from "./utils/orderReceiptWhatsApp";
import { notifyCitaConfirmacion, formatTelefonoDisplay, formatCitaFecha } from "./utils/citaWhatsApp";
import { FARMACIA_FISCAL } from "./constants/farmaciaFiscal";
import { validarPasswordTienda, PASSWORD_RULES_TEXT, PASSWORD_MIN_LENGTH } from "./utils/passwordPolicy";
import {
  X, ShoppingCart, Pill, Tag as TagIcon, Stethoscope, Star,
  MapPin, Clock, Phone, Mail, HelpCircle, FileText,
  LogIn, UserPlus, ChevronRight, Menu, Package,
  Store, Bike, PackageCheck, Trophy, CreditCard, Search, Calendar
} from "lucide-react";

// ═══════════════════════════════════════════════════════════════
// FARMACAPITAL — Tienda en Línea v4
// Popup · Banners · Mapa · Footer legal · FAQ · Políticas
// ═══════════════════════════════════════════════════════════════

const BRAND = {
  primary:"#0D1B2A", secondary:"#1E3ABA", accent:"#16a34a",
  amber:"#f59e0b",
  gradient:"linear-gradient(135deg,#0D1B2A,#1E3ABA)",
};
const C = {
  bg:"#f7f9fc", card:"#ffffff", cardDark:"#f0f4f9",
  border:"#e2e8f0", borderHi:"#c7d4f5", dark:"#0f172a", mid:"#475569",
  dim:"#94a3b8", white:"#ffffff", red:"#ef4444", redDim:"#fee2e2",
  text:"#0f172a", textMid:"#475569", textDim:"#94a3b8", blueDim:"#eef1fb",
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
  return `farmacapital_checkout_address_${suffix}`;
}

/** Stock vendible: max(columna productos.stock, suma lotes) por si el trigger no sincronizó. */
function tiendaEffectiveStockFromDb(dbp, sumLotesMap) {
  const col = Number(dbp?.stock) || 0;
  const fromLotes = sumLotesMap.get(tiendaNormProductId(dbp.id)) || 0;
  return Math.max(col, fromLotes);
}

const productoAgotadoTienda = (p) => Number(p?.stock) <= 0;

/** Catálogo tienda: activos en línea (incluye agotados, como POS). */
const poolCatalogoTienda = (productos) =>
  (productos || []).filter((p) => p.activo !== false);

/** Orden: disponibles primero, agotados al final; respeta rank de búsqueda si aplica. */
function sortCatalogoTienda(arr, busq) {
  const q = String(busq || "").trim();
  return [...arr].sort((a, b) => {
    const agA = productoAgotadoTienda(a) ? 1 : 0;
    const agB = productoAgotadoTienda(b) ? 1 : 0;
    if (agA !== agB) return agA - agB;
    if (q) {
      const ra = tiendaSearchRelevanceRank(a, busq);
      const rb = tiendaSearchRelevanceRank(b, busq);
      if (ra !== rb) return ra - rb;
    }
    return String(a.nombre || "").localeCompare(String(b.nombre || ""), "es", { sensitivity: "base" });
  });
}

// ── CONTACTO (descomentar cuando tengas número) ───────────────
const CONTACTO = {
  telefono: FARMACIA_FISCAL.telefono_display,
  whatsapp: FARMACIA_FISCAL.telefono,
  whatsapp_display: FARMACIA_FISCAL.telefono_display,
  whatsapp_link: `https://wa.me/52${FARMACIA_FISCAL.telefono}`,
  email: FARMACIA_FISCAL.email,
  direccion: FARMACIA_FISCAL.direccion_comercial,
  horario: "Lun–Vie 8:00–22:00 · Sáb 8:00–20:00 · Dom 9:00–18:00",
  maps_url: FARMACIA_FISCAL.maps_url,
  maps_embed: FARMACIA_FISCAL.maps_embed,
};

// ── BANNERS ROTATIVOS ─────────────────────────────────────────
const BANNERS = [
  {
    id:1,
    titulo:"Genéricos FarmaCapital",
    subtitulo:"Medicamentos desde $10",
    descripcion:"Misma fórmula, mejor precio. Certificados por COFEPRIS.",
    cta:"Ver genéricos",
    pagina:"catalogo",
    bg:"linear-gradient(135deg,#0D1B2A,#1E3ABA)",
    emoji:"💊",
  },
  {
    id:2,
    titulo:"Consulta médica",
    subtitulo:`$${CONSULTA_PRECIO_DEFAULT} por consulta`,
    descripcion:"O gratis con 160 puntos FarmaCapital. Médico general disponible.",
    cta:"Agendar cita",
    pagina:"cita",
    bg:"linear-gradient(135deg,#009952,#16a34a)",
    emoji:"🏥",
  },
  {
    id:3,
    titulo:"Puntos FarmaCapital",
    subtitulo:"Acumula y canjea",
    descripcion:"Gana 1 punto por cada $10 en farmacia, minisuper y consultorio.",
    cta:"Conocer más",
    pagina:"puntos",
    bg:"linear-gradient(135deg,#6d28d9,#9d6fff)",
    emoji:"⭐",
  },
];

/** Texto limpio para banners (vacío = sin render en tienda). */
function bannerTxt(v){
  return v != null ? String(v).trim() : "";
}

/** Normaliza fila Supabase → props de UI; slot: hero | strip | tile | popup */
function mapBannerFromRow(b){
  const s = String(b.slot||"hero").toLowerCase();
  const slot = s==="strip"||s==="tile"||s==="popup" ? s : "hero";
  const em = b.emoji != null ? String(b.emoji).trim() : "";
  const modoRaw = String(b.modo_visualizacion || "").trim().toLowerCase();
  const modo_visualizacion = modoRaw === "imagen_fondo" ? "imagen_fondo" : "imagen_completa";
  const ctaRaw = b.cta;
  const ctaNorm =
    ctaRaw == null ? "Ver más" : bannerTxt(ctaRaw) === "" ? "" : bannerTxt(ctaRaw);
  return {
    id: b.id,
    titulo: bannerTxt(b.titulo),
    subtitulo: bannerTxt(b.subtitulo),
    descripcion: bannerTxt(b.descripcion),
    emoji: em,
    bg: b.bg||BRAND.gradient,
    cta: ctaNorm,
    pagina: b.pagina||"catalogo",
    slot,
    imagen_url: b.imagen_url || "",
    imagen_url_mobile: bannerTxt(b.imagen_url_mobile) || bannerTxt(b.imagen_mobile_url),
    imagen_mobile_url: b.imagen_mobile_url || "",
    video_url: (b.video_url != null && String(b.video_url).trim()) ? String(b.video_url).trim() : "",
    modo_visualizacion,
  };
}

/** Vista estrecha (<768px): prioriza imagen_url_mobile (mapeada desde BD nueva + legado imagen_mobile_url). */
function bannerVisualUrl(b, narrow){
  const raw = narrow && bannerTxt(b.imagen_url_mobile)
    ? bannerTxt(b.imagen_url_mobile)
    : (bannerTxt(b.imagen_url) || "");
  return bannerPublicUrl(raw);
}

/** Rompe caché CDN/navegador cuando la URL en Storage no cambió de nombre. */
function bannerPublicUrl(url) {
  const base = bannerTxt(url);
  if (!base) return "";
  if (/[?&](?:v|cb)=/.test(base)) return base;
  const file = base.split("/").pop()?.split("?")[0] || "";
  const stamp = file.match(/-(\d{10,13})\./)?.[1];
  if (stamp) return `${base}${base.includes("?") ? "&" : "?"}cb=${stamp}`;
  return base;
}

/** URL de video corto (MP4/WebM). Si existe, la tienda prioriza video sobre la imagen. */
function bannerVideoUrl(b){
  const v = b?.video_url;
  return v != null && String(v).trim() !== "" ? String(v).trim() : "";
}

/** Desktop 16:5 · móvil 1:1 — `<picture>` evita mostrar la imagen cuadrada en laptop o la panorámica en teléfono. */
function HeroBannerPicture({ banner, alt = "", style }) {
  const desktopUrl = bannerPublicUrl(banner?.imagen_url);
  const mobileUrl = bannerPublicUrl(banner?.imagen_url_mobile);
  const fallback = desktopUrl || mobileUrl;
  if (!fallback) return null;
  return (
    <picture style={{ display: "block", width: "100%", height: "100%" }}>
      {mobileUrl ? <source media="(max-width: 767px)" srcSet={mobileUrl} /> : null}
      <img
        src={desktopUrl || mobileUrl}
        alt={alt}
        decoding="async"
        draggable={false}
        style={style}
        onLoad={(e) => {
          const img = e.currentTarget;
          if (process.env.NODE_ENV === "development") {
            console.info("[HeroBanner]", alt || "banner", {
              naturalWidth: img.naturalWidth,
              naturalHeight: img.naturalHeight,
              src: img.currentSrc || img.src,
            });
          }
        }}
      />
    </picture>
  );
}

/** Video sin sonido + loop para autoplay en carrusel/banners (políticas del navegador). */
function BannerLoopVideo({ src, poster, style, "aria-label": ariaLabel }){
  return (
    <video
      src={src}
      poster={poster || undefined}
      muted
      playsInline
      loop
      autoPlay
      preload="metadata"
      aria-label={ariaLabel || "Banner en video"}
      style={style}
    />
  );
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
  { p:"¿Cuánto tarda el envío?", r:"En CDMX puedes elegir entrega express vía Rappi o Uber (al costo del servicio). Por el momento solo hacemos entregas dentro de CDMX." },
  { p:"¿Puedo recoger mi pedido en la farmacia?", r:"Sí. El pick-up es gratis y el mismo día. Recibirás un mensaje cuando tu pedido esté listo." },
  { p:"¿Cómo funcionan los Puntos FarmaCapital?", r:"Ganas 1 punto por cada $10 de compra. 1 punto equivale a $0.50 de descuento. Puedes usarlos en farmacia, minisuper y consultorio." },
  { p:"¿Qué hago si necesito un medicamento con receta?", r:"Agrégalo al carrito normalmente. Al recoger o recibir tu pedido, presenta tu receta médica original. Para antibióticos y controlados es obligatorio por COFEPRIS." },
  { p:"¿Cómo puedo facturar mi compra?", r:"Solicita tu factura CFDI en el mostrador al momento de tu compra o escríbenos a contacto@farmacapital.mx dentro de las 24 horas siguientes." },
  { p:"¿Cuál es la política de devoluciones?", r:"Aceptamos devoluciones dentro de 72 horas si el producto está en perfecto estado y sin abrir. Medicamentos controlados y con receta no tienen devolución. Consulta nuestra política completa." },
  { p:"¿Tienen medicamentos genéricos?", r:"Sí. Tenemos una amplia variedad de genéricos intercambiables certificados por COFEPRIS, con el mismo principio activo que las marcas de patente pero a menor precio." },
];

const HORARIOS_DOCTORA = [
  { dia:"Lunes a Viernes", horario:"09:00 – 14:00 y 16:00 – 20:00" },
  { dia:"Sábado",          horario:"09:00 – 14:00" },
  { dia:"Domingo",         horario:"Cerrado" },
];
const TODOS_HORARIOS = [
  "09:00","09:30","10:00","10:30","11:00","11:30",
  "12:00","12:30","13:00","13:30","14:00",
  "16:00","16:30","17:00","17:30","18:00","18:30",
];

function localISODate(d = new Date()) {
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, "0");
  const day = String(d.getDate()).padStart(2, "0");
  return `${y}-${m}-${day}`;
}

const ptsGana = p => Math.floor(p/10);
const labelPts = n => `${n} ${n===1?"punto":"puntos"} FarmaCapital`;

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

// ── UI BASE ───────────────────────────────────────────────────
const Btn=({children,onClick,col,outline,sm,full,disabled,style,type="button"})=>(
  <button type={type} onClick={onClick} disabled={disabled} style={{padding:sm?"7px 16px":"12px 24px",borderRadius:10,border:`2px solid ${outline?(col||BRAND.primary):"transparent"}`,background:outline?"transparent":disabled?C.dim:(col||BRAND.primary),color:outline?(col||BRAND.primary):C.white,fontWeight:700,fontSize:sm?13:14,cursor:disabled?"not-allowed":"pointer",fontFamily:"'Plus Jakarta Sans',sans-serif",width:full?"100%":undefined,opacity:disabled?.6:1,transition:"all .15s",...style}}>{children}</button>
);
const Tag=({children,col,sm})=>(
  <span style={{background:col+"18",color:col,border:`1px solid ${col}30`,borderRadius:20,padding:sm?"2px 8px":"4px 12px",fontSize:sm?10:12,fontWeight:700,whiteSpace:"nowrap",display:"inline-block"}}>{children}</span>
);
const tiendaFieldStyle=(overrides={},invalid=false)=>({
  background:C.white,
  border:`1px solid ${invalid?C.red:C.border}`,
  borderRadius:10,
  color:C.text,
  WebkitTextFillColor:C.text,
  caretColor:C.text,
  colorScheme:"light",
  padding:"11px 14px",
  fontSize:16,
  outline:"none",
  fontFamily:"'Plus Jakarta Sans',sans-serif",
  transition:"border-color .2s",
  width:"100%",
  boxSizing:"border-box",
  ...overrides,
});
const Inp=({value,onChange,placeholder,type,style,onKeyDown,onFocus,onBlur,name,autoComplete,className="",invalid=false})=>(
  <input
    className={`farmacapital-field-input ${className}`.trim()}
    name={name}
    autoComplete={autoComplete}
    value={value}
    onChange={onChange}
    placeholder={placeholder}
    type={type||"text"}
    onKeyDown={onKeyDown}
    style={tiendaFieldStyle(style,invalid)}
    onFocus={e=>{onFocus?.(e);e.target.style.borderColor=invalid?C.red:BRAND.primary}}
    onBlur={e=>{onBlur?.(e);e.target.style.borderColor=invalid?C.red:C.border}}
  />
);

// ── POPUP BIENVENIDA ──────────────────────────────────────────
function PopupBienvenida({onClose,setPage,precioConsulta,banner}){
  const C = useTheme();
  const stack = useMediaQuery("(max-width: 480px)");
  const mobilePopup = useMediaQuery("(max-width: 767px)");
  const pc = Math.round(Number(precioConsulta) || CONSULTA_PRECIO_DEFAULT);
  const hasBannerRow = !!(banner && banner.id != null);
  const modoCompletoPopup =
    hasBannerRow &&
    String(banner.modo_visualizacion || "").trim().toLowerCase() !== "imagen_fondo";

  const tituloRaw = bannerTxt(banner?.titulo);
  const subtituloRaw = bannerTxt(banner?.subtitulo);
  const descripcionRaw = bannerTxt(banner?.descripcion);
  const ctaRaw = bannerTxt(banner?.cta);
  const paginaRaw = bannerTxt(banner?.pagina);

  let titulo;
  let subtitulo;
  let descripcion;
  let cta;
  let ctaPage;
  if (!hasBannerRow) {
    titulo = tituloRaw || "¡Bienvenido a FarmaCapital!";
    subtitulo =
      subtituloRaw ||
      "Regístrate hoy y gana 10 puntos de bienvenida.";
    descripcion =
      descripcionRaw ||
      "Equivalen a $5 de descuento en tu próxima compra.";
    cta = ctaRaw || "Crear mi cuenta gratis";
    ctaPage = paginaRaw || "registro";
  } else {
    titulo = tituloRaw;
    subtitulo = subtituloRaw;
    descripcion = descripcionRaw;
    cta = ctaRaw;
    ctaPage = paginaRaw || "home";
  }

  const showOverlayCopy =
    !modoCompletoPopup &&
    !!(titulo || subtitulo || descripcion);

  const showBullets = !hasBannerRow || !modoCompletoPopup;

  const showPrimaryBtn = !hasBannerRow ? true : !!(cta && paginaRaw);

  const imgUrl = mobilePopup
    ? (bannerTxt(banner?.imagen_url_mobile) || bannerTxt(banner?.imagen_mobile_url) || bannerTxt(banner?.imagen_url))
    : (bannerTxt(banner?.imagen_url) || bannerTxt(banner?.imagen_url_mobile) || bannerTxt(banner?.imagen_mobile_url));

  const imgAlt =
    modoCompletoPopup && !tituloRaw
      ? "FarmaCapital"
      : titulo || "FarmaCapital";

  const overlayTone = modoCompletoPopup && imgUrl
    ? "transparent"
    : imgUrl
      ? "linear-gradient(180deg, rgba(2,6,23,.12), rgba(2,6,23,.42))"
      : "transparent";

  return(
    <div style={{position:"fixed",top:0,left:0,right:0,bottom:0,background:"rgba(2,6,23,.62)",backdropFilter:"blur(3px)",zIndex:500,display:"flex",alignItems:"center",justifyContent:"center",padding:16,overflowY:"auto",WebkitOverflowScrolling:"touch",pointerEvents:"auto"}}>
      <div style={{background:C.white,borderRadius:16,maxWidth:mobilePopup?420:640,width:"100%",maxHeight:"90vh",overflowY:"auto",boxShadow:"0 24px 70px rgba(2,6,23,.48)",border:"1px solid rgba(255,255,255,.4)"}}>
        <div style={{background:BRAND.gradient,padding:"28px 20px",textAlign:"center",position:"relative",overflow:"hidden"}}>
          {imgUrl ? (
            <img
              src={imgUrl}
              alt={imgAlt}
              style={{position:"absolute",inset:0,width:"100%",height:"100%",objectFit:"cover",objectPosition:"center center",zIndex:0,filter:"saturate(1.08) contrast(1.05)"}}
            />
          ) : null}
          <div
            style={{
              position:"absolute",
              inset:0,
              background:overlayTone,
              zIndex:1,
              pointerEvents:"none",
            }}
          />
          <div
            aria-hidden
            style={{
              position:"relative",
              width:"100%",
              aspectRatio: mobilePopup ? "1 / 1" : "16 / 9",
              zIndex:1,
              pointerEvents:"none",
            }}
          />
          <button type="button" onClick={(e)=>{ e.stopPropagation(); onClose(); }} aria-label="Cerrar" style={{position:"absolute",top:12,right:16,zIndex:30,background:"rgba(255,255,255,.25)",border:"none",color:C.white,width:36,height:36,borderRadius:"50%",cursor:"pointer",fontSize:18,lineHeight:1,display:"flex",alignItems:"center",justifyContent:"center",padding:0,pointerEvents:"auto",WebkitTapHighlightColor:"transparent"}}>×</button>
          {showOverlayCopy ? (
            <div style={{position:"relative",zIndex:2}}>
              {titulo ? (
                <h2 style={{color:C.white,fontSize:"clamp(18px,4.5vw,22px)",fontWeight:800,fontFamily:"'Plus Jakarta Sans',sans-serif",marginBottom:8}}>{titulo}</h2>
              ) : null}
              {(subtitulo || descripcion) ? (
                <p style={{color:"rgba(255,255,255,.98)",fontSize:14,lineHeight:1.6,textShadow:"0 1px 4px rgba(2,6,23,.7)"}}>
                  {subtitulo ? <strong>{subtitulo}</strong> : null}{subtitulo && descripcion ? " — " : ""}{descripcion || ""}
                </p>
              ) : null}
            </div>
          ) : null}
        </div>
        <div style={{padding:"20px 20px"}}>
          {showBullets ? (
            <div style={{display:"grid",gridTemplateColumns:stack?"1fr":"1fr 1fr",gap:10,marginBottom:20}}>
              {[["Genéricos desde $10"],["Envío a domicilio"],[`Consulta médica $${pc}`],["Acumula puntos"]].map(([t])=>(
                <div key={t} style={{display:"flex",alignItems:"center",gap:8}}>
                  <span style={{color:C.mid,fontSize:12}}>{t}</span>
                </div>
              ))}
            </div>
          ) : null}
          {showPrimaryBtn ? (
            <Btn onClick={()=>{onClose();setPage(ctaPage);}} col={BRAND.primary} full>{cta} →</Btn>
          ) : null}
          <button onClick={onClose} style={{width:"100%",background:"none",border:"none",color:C.dim,fontSize:13,cursor:"pointer",marginTop:showPrimaryBtn?10:0,padding:8}}>Seguir comprando sin cuenta</button>
        </div>
      </div>
    </div>
  );
}

// ── CARRUSEL PRINCIPAL (zona hero) ────────────────────────────
/** Desktop 16:5 (1920×600) · móvil 1:1 (1080×1080). En imagen_completa no superpone título ni oscurece el arte. */
function HeroCarousel({setPage, items, precioConsulta, useStaticPlaceholder=true}){
  const C = useTheme();
  const [idx,setIdx]=useState(0);
  const [pauseAuto,setPauseAuto]=useState(false);
  const esMobile = useMediaQuery("(max-width: 767px)");

  const banners = items.length
    ? items
    : useStaticPlaceholder
    ? BANNERS.map((b) =>
        b.id === 2 && precioConsulta
          ? {...b, subtitulo:`$${Math.round(Number(precioConsulta)||CONSULTA_PRECIO_DEFAULT)} por consulta`}
          : b
      )
    : [];

  useEffect(()=>{ setIdx(0); },[banners.length]);
  useEffect(()=>{
    if(banners.length<=1||pauseAuto) return undefined;
    const t=setInterval(()=>setIdx(i=>(i+1)%banners.length),4000);
    return ()=>clearInterval(t);
  },[banners.length,pauseAuto]);

  if(banners.length===0) return null;

  const b=banners[idx]||BANNERS[0];
  const vid = bannerVideoUrl(b);
  const desktopImg = bannerPublicUrl(b.imagen_url);
  const mobileImg = bannerPublicUrl(b.imagen_url_mobile);
  const imagenFallback = desktopImg || mobileImg;
  const tieneImagen = !!(vid || imagenFallback);

  const modoCompleto =
    (bannerTxt(b.modo_visualizacion)||"imagen_completa")==="imagen_completa" && tieneImagen;

  const heroShellSx = {
    position: "relative",
    width: "100%",
    aspectRatio: esMobile ? "1 / 1" : "16 / 5",
    height: "auto",
    overflow: "hidden",
    background: "#0f172a",
  };

  const heroMediaSx = {
    width: "100%",
    height: "100%",
    display: "block",
    objectFit: "cover",
    objectPosition: "center center",
  };

  const heroOverlayCopySx = {
    position: "absolute",
    inset: 0,
    background: esMobile
      ? "linear-gradient(to top, rgba(0,0,0,0.5) 0%, rgba(0,0,0,0.18) 45%, transparent 70%)"
      : "linear-gradient(90deg, rgba(13,27,42,0.45) 0%, rgba(13,27,42,0.12) 55%, transparent 100%)",
    pointerEvents: "none",
    zIndex: 1,
  };

  const heroCtaDesktopSx = {
    position: "absolute",
    right: "clamp(24px, 5vw, 80px)",
    bottom: "clamp(28px, 7%, 55px)",
    zIndex: 3,
  };

  const heroCtaMobileSx = {
    position: "absolute",
    left: "50%",
    transform: "translateX(-50%)",
    bottom: "clamp(20px, 5%, 36px)",
    zIndex: 3,
    width: "max-content",
    maxWidth: "calc(100% - 32px)",
  };

  const carouselControls = banners.length > 1 && (
    <>
      <div
        role="tablist"
        aria-label="Banners del carrusel"
        onMouseEnter={()=>setPauseAuto(true)}
        onMouseLeave={()=>setPauseAuto(false)}
        style={{
          position:"absolute",
          bottom: esMobile ? 10 : 14,
          left: esMobile ? "50%" : "clamp(16px, 4vw, 48px)",
          transform: esMobile ? "translateX(-50%)" : undefined,
          display:"flex",
          gap:6,
          zIndex:4,
        }}
      >
        {banners.map((_,i)=>(
          <button
            key={i}
            type="button"
            role="tab"
            aria-selected={i===idx}
            aria-label={`Banner ${i+1}`}
            onClick={(e)=>{ e.stopPropagation(); setIdx(i); }}
            style={{
              width:i===idx?22:8,
              height:8,
              borderRadius:4,
              border:"none",
              background:i===idx?"rgba(255,255,255,.92)":"rgba(255,255,255,.45)",
              cursor:"pointer",
              padding:0,
              boxShadow:"0 1px 2px rgba(0,0,0,.25)",
            }}
          />
        ))}
      </div>
      {[[-1,"‹"],[1,"›"]].map(([d,icon])=>(
        <button
          key={d}
          type="button"
          aria-label={d===-1?"Banner anterior":"Banner siguiente"}
          onClick={(e)=>{ e.stopPropagation(); setIdx(i=>(i+d+banners.length)%banners.length); }}
          onMouseEnter={()=>setPauseAuto(true)}
          onMouseLeave={()=>setPauseAuto(false)}
          style={{
            position:"absolute",
            top:"50%",
            transform:"translateY(-50%)",
            ...(d===-1
              ? { left: esMobile ? 8 : 12 }
              : { right: esMobile ? 8 : "clamp(24px, 5vw, 80px)", top: esMobile ? "42%" : "38%" }),
            background:"rgba(13,27,42,0.35)",
            border:"1px solid rgba(255,255,255,0.25)",
            color:C.white,
            width:esMobile?30:36,
            height:esMobile?30:36,
            borderRadius:"50%",
            cursor:"pointer",
            fontSize:esMobile?18:22,
            fontWeight:600,
            display:"flex",
            alignItems:"center",
            justifyContent:"center",
            zIndex:4,
            paddingBottom:2,
          }}
        >
          {icon}
        </button>
      ))}
    </>
  );

  const heroCtaBtn = bannerTxt(b.cta) && b.pagina ? (
    <Btn
      onClick={(e)=>{ e.stopPropagation(); setPage(b.pagina); }}
      style={{
        background:"#fff",
        color:BRAND.primary,
        border:"none",
        fontWeight:700,
        boxShadow:"0 4px 14px rgba(0,0,0,.22)",
        padding: esMobile ? "11px 20px" : "13px 26px",
        fontSize: esMobile ? 14 : 15,
      }}
    >
      {b.cta}
    </Btn>
  ) : null;

  // ── imagen_completa: arte ya incluye copy; solo CTA opcional en zona segura ──
  if (modoCompleto) {
    return (
      <div className="hero-carousel" style={{ position:"relative", width:"100%", overflow:"hidden" }}>
        <div
          className="hero-carousel__frame"
          style={heroShellSx}
          onMouseEnter={()=>setPauseAuto(true)}
          onMouseLeave={()=>setPauseAuto(false)}
        >
          <button
            type="button"
            onClick={()=> b.pagina && setPage(b.pagina)}
            aria-label={bannerTxt(b.titulo) || "Ver banner"}
            style={{
              display:"block",
              width:"100%",
              height:"100%",
              border:"none",
              padding:0,
              margin:0,
              cursor: b.pagina ? "pointer" : "default",
              background:"transparent",
              position:"relative",
            }}
          >
            {vid ? (
              <BannerLoopVideo
                src={vid}
                poster={imagenFallback||undefined}
                aria-label={bannerTxt(b.titulo)||"Banner"}
                style={heroMediaSx}
              />
            ) : (
              <HeroBannerPicture
                banner={b}
                alt={bannerTxt(b.titulo)||"Banner FarmaCapital"}
                style={heroMediaSx}
              />
            )}
          </button>
          {heroCtaBtn ? (
            <div className="hero-cta" style={esMobile ? heroCtaMobileSx : heroCtaDesktopSx}>
              {heroCtaBtn}
            </div>
          ) : null}
          {carouselControls}
        </div>
      </div>
    );
  }

  // ── imagen_fondo / gradiente: copy superpuesto con overlay moderado ──
  return (
    <div className="hero-carousel" style={{ position:"relative", width:"100%", overflow:"hidden" }}>
      <div
        role="presentation"
        onClick={()=> b.pagina && setPage(b.pagina)}
        style={{
          ...heroShellSx,
          cursor: b.pagina ? "pointer" : "default",
          display:"flex",
          flexDirection:"column",
          justifyContent: esMobile ? "flex-end" : "flex-start",
        }}
      >
        {!vid && !tieneImagen ? (
          <div aria-hidden style={{position:"absolute",inset:0,background:b.bg,zIndex:0}}>
            <svg style={{position:"absolute",inset:0,width:"100%",height:"100%",opacity:.07}} aria-hidden>
              <defs>
                <pattern id="fc-grid" x="0" y="0" width="40" height="40" patternUnits="userSpaceOnUse">
                  <circle cx="20" cy="20" r="1.5" fill="white"/>
                </pattern>
              </defs>
              <rect width="100%" height="100%" fill="url(#fc-grid)"/>
            </svg>
          </div>
        ) : null}
        {!vid && tieneImagen ? (
          <div style={{ position:"absolute", inset:0, zIndex:0 }}>
            <HeroBannerPicture banner={b} alt="" style={{ ...heroMediaSx, pointerEvents:"none" }} />
          </div>
        ) : null}
        {vid ? (
          <div style={{position:"absolute",inset:0,zIndex:0}}>
            <BannerLoopVideo
              src={vid}
              poster={imagenFallback||undefined}
              aria-label={bannerTxt(b.titulo)||"Banner"}
              style={heroMediaSx}
            />
          </div>
        ) : null}

        {tieneImagen ? <div aria-hidden style={heroOverlayCopySx} /> : null}

        {esMobile ? (
          <div style={{ position:"relative", zIndex:2, padding:"16px 16px 52px", textAlign:"center" }}>
            {bannerTxt(b.titulo) ? (
              <h2 style={{
                color:"#fff", fontSize:"clamp(20px, 5vw, 26px)", fontWeight:800,
                margin:"0 0 6px", lineHeight:1.2, textShadow:"0 2px 8px rgba(0,0,0,.55)",
              }}>{b.titulo}</h2>
            ) : null}
            {bannerTxt(b.subtitulo) ? (
              <div style={{
                color:"rgba(255,255,255,.9)", fontSize:"clamp(10px, 2.5vw, 12px)",
                letterSpacing:1.5, textTransform:"uppercase", marginBottom:14, fontWeight:600,
                textShadow:"0 1px 3px rgba(0,0,0,.45)",
              }}>{b.subtitulo}</div>
            ) : null}
            {heroCtaBtn}
          </div>
        ) : (
          <>
            <div style={{ position:"relative", zIndex:2, padding:"clamp(20px, 4vw, 32px) clamp(16px, 4vw, 48px) 0", maxWidth:"58%" }}>
              {bannerTxt(b.titulo) ? (
                <h2 style={{
                  color:"#fff", fontSize:"clamp(24px, 3.5vw, 36px)", fontWeight:800,
                  margin:"0 0 8px", lineHeight:1.15, textShadow:"0 2px 8px rgba(0,0,0,.55)",
                }}>{b.titulo}</h2>
              ) : null}
              {bannerTxt(b.subtitulo) ? (
                <div style={{
                  color:"rgba(255,255,255,.9)", fontSize:"clamp(11px, 1.4vw, 14px)",
                  letterSpacing:1.8, textTransform:"uppercase", fontWeight:600,
                  textShadow:"0 1px 3px rgba(0,0,0,.45)",
                }}>{b.subtitulo}</div>
              ) : null}
            </div>
            {heroCtaBtn ? (
              <div style={heroCtaDesktopSx}>{heroCtaBtn}</div>
            ) : null}
          </>
        )}
        {carouselControls}
      </div>
    </div>
  );
}

// ── FRANJA: tarjetas anchas (zona strip) ─────────────────────
function HomeBannersStrip({setPage, items}){
  const C = useTheme();
  const stack = useMediaQuery("(max-width: 768px)");
  const narrowImg = useNarrowForBannerImage();
  if(!items?.length) return null;
  return(
    <div style={{background:"linear-gradient(180deg,#f0f7ff,#f7f9fc)",borderBottom:`1px solid ${C.border}`,padding:"16px 12px"}}>
      <div style={{maxWidth:1200,margin:"0 auto",display:"flex",gap:12,flexWrap:"wrap",justifyContent:"center"}}>
        {items.map((b,i)=>{
          const vid = bannerVideoUrl(b);
          const imgUrl = bannerVisualUrl(b, narrowImg);
          const modo = b.modo_visualizacion === "imagen_fondo" ? "imagen_fondo" : "imagen_completa";
          const soloImg = modo === "imagen_completa" && (!!vid || !!imgUrl);
          const stripHasCopy = !!(b.titulo||b.subtitulo||b.descripcion||b.cta);
          if (soloImg) {
            return (
              <button
                key={`strip-${b.id ?? i}-${i}`}
                type="button"
                onClick={()=>setPage(b.pagina)}
                style={{
                  flex:"1 1 min(100%,280px)",
                  maxWidth:420,
                  minWidth:0,
                  width:"100%",
                  padding:0,
                  border:"none",
                  borderRadius:14,
                  overflow:"hidden",
                  cursor:"pointer",
                  background:"#0f172a",
                  boxShadow:"0 4px 20px rgba(15,45,110,.12)",
                  transition:"transform .15s, box-shadow .15s",
                  display:"block",
                }}
                onMouseEnter={e=>{ e.currentTarget.style.transform="translateY(-2px)"; e.currentTarget.style.boxShadow="0 8px 28px rgba(15,45,110,.2)"; }}
                onMouseLeave={e=>{ e.currentTarget.style.transform="none"; e.currentTarget.style.boxShadow="0 4px 20px rgba(15,45,110,.12)"; }}
              >
                {vid ? (
                  <BannerLoopVideo
                    src={vid}
                    poster={imgUrl || undefined}
                    aria-label={bannerTxt(b.titulo) || "Banner"}
                    style={{
                      width:"100%",
                      height:"auto",
                      display:"block",
                      maxHeight:220,
                      objectFit:"contain",
                    }}
                  />
                ) : (
                  <img
                    src={imgUrl}
                    alt={bannerTxt(b.titulo)||""}
                    decoding="async"
                    style={{
                      width:"100%",
                      height:"auto",
                      display:"block",
                      maxHeight:220,
                      objectFit:"contain",
                    }}
                  />
                )}
              </button>
            );
          }
          return(
          <button
            key={`strip-${b.id ?? i}-${i}`}
            type="button"
            onClick={()=>setPage(b.pagina)}
            style={{
              position:"relative",
              overflow:"hidden",
              flex:"1 1 min(100%,280px)",maxWidth:420,minWidth:0,width:"100%",textAlign:"left",cursor:"pointer",border:"none",borderRadius:14,
              background:(vid||imgUrl)?"#0f172a":b.bg,
              color:"#fff",padding:(vid||imgUrl)?0:"16px 18px",boxShadow:"0 4px 20px rgba(15,45,110,.12)",
              display:"flex",alignItems:(vid||imgUrl)?"stretch":"center",gap:(vid||imgUrl)?0:14,
              transition:"transform .15s, box-shadow .15s",
            }}
            onMouseEnter={e=>{ e.currentTarget.style.transform="translateY(-2px)"; e.currentTarget.style.boxShadow="0 8px 28px rgba(15,45,110,.2)"; }}
            onMouseLeave={e=>{ e.currentTarget.style.transform="none"; e.currentTarget.style.boxShadow="0 4px 20px rgba(15,45,110,.12)"; }}
          >
            {(vid||imgUrl) ? (
              stripHasCopy ? (
              <>
                <div style={{
                  width:stack?"36%":"40%",
                  maxWidth:176,
                  flexShrink:0,
                  background:"#0f172a",
                  display:"flex",
                  alignItems:"center",
                  justifyContent:"center",
                  padding:"10px 8px",
                }}>
                  {vid ? (
                    <BannerLoopVideo
                      src={vid}
                      poster={imgUrl || undefined}
                      aria-label={bannerTxt(b.titulo)||""}
                      style={{
                        width:"100%",
                        height:"auto",
                        display:"block",
                        objectFit:"contain",
                        maxHeight:124,
                      }}
                    />
                  ) : (
                    <img
                      src={imgUrl}
                      alt=""
                      decoding="async"
                      style={{
                        width:"100%",
                        height:"auto",
                        display:"block",
                        objectFit:"contain",
                        maxHeight:124,
                      }}
                    />
                  )}
                </div>
                <div style={{
                  flex:1,
                  minWidth:0,
                  padding:"14px 16px",
                  display:"flex",
                  flexDirection:"column",
                  justifyContent:"center",
                  background:"linear-gradient(90deg,rgba(15,23,42,.95),rgba(30,58,138,.82))",
                }}>
                  {b.titulo?<div style={{fontWeight:800,fontSize:"clamp(14px,3.5vw,16px)",lineHeight:1.25,marginBottom:4}}>{b.titulo}</div>:null}
                  {(b.subtitulo||b.descripcion)?<div style={{fontSize:12,opacity:.92,lineHeight:1.35}}>{b.subtitulo||b.descripcion?.slice(0,80)}{(b.descripcion?.length>80?"…":"")}</div>:null}
                  {b.cta?<div style={{fontSize:11,fontWeight:700,marginTop:8,opacity:.95}}>{b.cta} →</div>:null}
                </div>
              </>
              ) : (
                <div style={{width:"100%",background:"#0f172a",display:"flex",alignItems:"center",justifyContent:"center",padding:"10px 8px"}}>
                  {vid ? (
                    <BannerLoopVideo
                      src={vid}
                      poster={imgUrl || undefined}
                      aria-label={bannerTxt(b.titulo)||"Banner"}
                      style={{
                        width:"100%",
                        height:"auto",
                        display:"block",
                        objectFit:"contain",
                        maxHeight:140,
                      }}
                  />
                  ) : (
                    <img
                      src={imgUrl}
                      alt=""
                      decoding="async"
                      style={{
                        width:"100%",
                        height:"auto",
                        display:"block",
                        objectFit:"contain",
                        maxHeight:140,
                      }}
                    />
                  )}
                </div>
              )
            ) : (
              <>
                <div style={{flex:1,minWidth:0}}>
                  {b.titulo?<div style={{fontWeight:800,fontSize:"clamp(14px,3.5vw,16px)",lineHeight:1.25,marginBottom:4}}>{b.titulo}</div>:null}
                  {(b.subtitulo||b.descripcion)?<div style={{fontSize:12,opacity:.9,lineHeight:1.35}}>{b.subtitulo||b.descripcion?.slice(0,80)}{(b.descripcion?.length>80?"…":"")}</div>:null}
                  {b.cta?<div style={{fontSize:11,fontWeight:700,marginTop:8,opacity:.95}}>{b.cta} →</div>:null}
                </div>
              </>
            )}
          </button>
        );})}
      </div>
    </div>
  );
}

// ── MOSAICO: rejilla compacta (zona tile) ─────────────────────
function HomeBannersTiles({setPage, items, stack}){
  const C = useTheme();
  const narrowImg = useNarrowForBannerImage();
  if(!items?.length) return null;
  return(
    <div style={{maxWidth:1200,margin:"0 auto",padding:"0 12px 20px"}}>
      <div style={{
        display:"grid",
        gridTemplateColumns:stack?"repeat(2, 1fr)":"repeat(auto-fill, minmax(min(100%, 200px), 1fr))",
        gap:12,
      }}>
        {items.map((b,i)=>{
          const vid = bannerVideoUrl(b);
          const imgUrl = bannerVisualUrl(b, narrowImg);
          const modo = b.modo_visualizacion === "imagen_fondo" ? "imagen_fondo" : "imagen_completa";
          const soloImg = modo === "imagen_completa" && (!!vid || !!imgUrl);
          const tileHasCopy = !!(b.titulo||b.subtitulo||b.cta);
          if (soloImg) {
            return (
              <button
                key={`tile-${b.id ?? i}-${i}`}
                type="button"
                onClick={()=>setPage(b.pagina)}
                style={{
                  position:"relative",
                  overflow:"hidden",
                  textAlign:"center",
                  cursor:"pointer",
                  border:`1px solid ${C.border}`,
                  borderRadius:14,
                  background:"#0f172a",
                  color:"#fff",
                  padding:0,
                  minHeight:120,
                  display:"flex",
                  alignItems:"center",
                  justifyContent:"center",
                  boxShadow:"0 2px 12px rgba(0,0,0,.06)",
                  transition:"transform .15s",
                }}
                onMouseEnter={e=>{ e.currentTarget.style.transform="translateY(-2px)"; }}
                onMouseLeave={e=>{ e.currentTarget.style.transform="none"; }}
              >
                {vid ? (
                  <BannerLoopVideo
                    src={vid}
                    poster={imgUrl || undefined}
                    aria-label={bannerTxt(b.titulo)||""}
                    style={{
                      width:"100%",
                      height:"auto",
                      display:"block",
                      maxHeight:200,
                      objectFit:"contain",
                    }}
                  />
                ) : (
                  <img
                    src={imgUrl}
                    alt={bannerTxt(b.titulo)||""}
                    decoding="async"
                    style={{
                      width:"100%",
                      height:"auto",
                      display:"block",
                      maxHeight:200,
                      objectFit:"contain",
                    }}
                  />
                )}
              </button>
            );
          }
          return(
          <button
            key={`tile-${b.id ?? i}-${i}`}
            type="button"
            onClick={()=>setPage(b.pagina)}
            style={{
              position:"relative",
              overflow:"hidden",
              textAlign:"left",cursor:"pointer",border:`1px solid ${C.border}`,borderRadius:14,
              background:(vid||imgUrl)?"#0f172a":b.bg,
              color:"#fff",padding:(vid||imgUrl)?0:16,minHeight:(vid||imgUrl)?undefined:120,
              display:"flex",flexDirection:"column",justifyContent:(vid||imgUrl)?"flex-start":"space-between",gap:(vid||imgUrl)?0:8,
              boxShadow:"0 2px 12px rgba(0,0,0,.06)",transition:"transform .15s",
            }}
            onMouseEnter={e=>{ e.currentTarget.style.transform="translateY(-2px)"; }}
            onMouseLeave={e=>{ e.currentTarget.style.transform="none"; }}
          >
            {(vid||imgUrl) ? (
              <div style={{position:"relative",width:"100%",background:"#0f172a"}}>
                {vid ? (
                  <BannerLoopVideo
                    src={vid}
                    poster={imgUrl || undefined}
                    aria-label={bannerTxt(b.titulo)||""}
                    style={{
                      width:"100%",
                      height:"auto",
                      display:"block",
                      verticalAlign:"top",
                      objectFit:"contain",
                      maxHeight:stack?200:260,
                    }}
                  />
                ) : (
                  <img
                    src={imgUrl}
                    alt=""
                    decoding="async"
                    style={{
                      width:"100%",
                      height:"auto",
                      display:"block",
                      verticalAlign:"top",
                      objectFit:"contain",
                      maxHeight:stack?200:260,
                    }}
                  />
                )}
                {tileHasCopy ? (
                <>
                <div aria-hidden style={{
                  position:"absolute",
                  inset:0,
                  background:"linear-gradient(180deg,rgba(0,0,0,.12),rgba(0,0,0,.78))",
                  pointerEvents:"none",
                }} />
                <div style={{
                  position:"absolute",
                  left:0,
                  right:0,
                  bottom:0,
                  padding:"12px 14px",
                  zIndex:1,
                  display:"flex",
                  flexDirection:"column",
                  gap:5,
                }}>
                  {b.titulo?<div style={{fontWeight:800,fontSize:14,lineHeight:1.25}}>{b.titulo}</div>:null}
                  {b.subtitulo?<div style={{fontSize:11,opacity:.95,lineHeight:1.3}}>{b.subtitulo}</div>:null}
                  {b.cta?<div style={{fontSize:11,fontWeight:700}}>{b.cta} →</div>:null}
                </div>
                </>
                ) : null}
              </div>
            ) : (
              <>
                <div>
                  {b.titulo?<div style={{fontWeight:800,fontSize:14,lineHeight:1.25}}>{b.titulo}</div>:null}
                  {b.subtitulo&&<div style={{fontSize:11,opacity:.9,marginTop:4,lineHeight:1.3}}>{b.subtitulo}</div>}
                </div>
                {b.cta?<div style={{fontSize:11,fontWeight:700}}>{b.cta} →</div>:null}
              </>
            )}
          </button>
        );})}
      </div>
    </div>
  );
}

// ── MENU LATERAL TIENDA ───────────────────────────────────────
function MenuTienda({ abierto, onClose, setPage, usuario, onLogout }) {
  const C = useTheme();

  if (!abierto) return null;

  const ahora = new Date();
  const dia = ahora.getDay();
  const hora = ahora.getHours();

  let estaAbierto = false;
  let horaCierre = "";
  let horarioHoy = "";

  if (dia === 0) {
    estaAbierto = hora >= 9 && hora < 18;
    horaCierre = "18:00";
    horarioHoy = "9:00 - 18:00";
  } else if (dia === 6) {
    estaAbierto = hora >= 8 && hora < 20;
    horaCierre = "20:00";
    horarioHoy = "8:00 - 20:00";
  } else {
    estaAbierto = hora >= 8 && hora < 22;
    horaCierre = "22:00";
    horarioHoy = "8:00 - 22:00";
  }

  const navItems = [
    { icon: ShoppingCart, label: "Inicio", page: "home" },
    { icon: Pill, label: "Catálogo", page: "catalogo" },
    { icon: TagIcon, label: "Promociones", page: "promo" },
    { icon: Stethoscope, label: "Consulta médica", page: "cita" },
    { icon: Star, label: "Puntos FarmaCapital", page: "puntos" },
  ];

  const ayudaItems = [
    { icon: HelpCircle, label: "Preguntas frecuentes", page: "faq" },
    { icon: FileText, label: "Política de privacidad", page: "privacidad" },
    { icon: FileText, label: "Términos y condiciones", page: "terminos" },
  ];

  const handleNav = (page) => {
    if (page === "cita") navigateToCita(setPage);
    else setPage(page);
    onClose();
  };

  return (
    <div
      onClick={onClose}
      style={{
        position: "fixed", inset: 0,
        background: "rgba(15,23,42,.5)",
        zIndex: 1000,
        display: "flex", justifyContent: "flex-end",
      }}
    >
      <div
        onClick={(e) => e.stopPropagation()}
        style={{
          background: C.card,
          width: "min(420px, 100vw)",
          height: "100vh",
          overflowY: "auto",
          boxShadow: "-8px 0 32px rgba(0,0,0,.2)",
          display: "flex",
          flexDirection: "column",
        }}
      >
        <div style={{
          padding: "20px 24px 16px",
          borderBottom: `1px solid ${C.border}`,
          display: "flex",
          alignItems: "center",
          justifyContent: "space-between",
          gap: 16,
        }}>
          <div>
            <div style={{
              fontSize: 18, fontWeight: 800, color: C.text,
              marginBottom: 2,
            }}>
              {usuario ? `Hola, ${primerNombre(usuario.nombre || "Cliente")}` : "Hola, ¿qué buscas?"}
            </div>
            <div style={{
              fontSize: 12, color: C.textMid,
              display: "flex", alignItems: "center", gap: 6,
            }}>
              <span style={{
                width: 8, height: 8, borderRadius: "50%",
                background: estaAbierto ? "#16a34a" : "#ff3d5a",
              }}/>
              {estaAbierto ? `Abierto · cierra a las ${horaCierre}` : "Cerrado ahora"}
            </div>
          </div>
          <button
            type="button"
            onClick={onClose}
            style={{
              background: C.bg, border: "none",
              width: 36, height: 36, borderRadius: "50%",
              cursor: "pointer",
              display: "flex", alignItems: "center", justifyContent: "center",
            }}
          >
            <X size={20} color={C.textMid} />
          </button>
        </div>

        {!usuario && (
          <div style={{padding: "16px 24px", borderBottom: `1px solid ${C.border}`}}>
            <div style={{display: "grid", gridTemplateColumns: "1fr 1fr", gap: 8}}>
              <button
                type="button"
                onClick={() => handleNav("registro")}
                style={{
                  padding: "12px 8px",
                  borderRadius: 10,
                  border: "none",
                  background: BRAND.accent,
                  color: "#fff",
                  fontWeight: 700, fontSize: 14,
                  cursor: "pointer",
                  display: "flex", alignItems: "center", justifyContent: "center", gap: 6,
                }}
              >
                <UserPlus size={16}/>
                Crear cuenta
              </button>
              <button
                type="button"
                onClick={() => handleNav("login")}
                style={{
                  padding: "12px 8px",
                  borderRadius: 10,
                  border: `1.5px solid ${BRAND.primary}`,
                  background: "transparent",
                  color: BRAND.primary,
                  fontWeight: 700, fontSize: 14,
                  cursor: "pointer",
                  display: "flex", alignItems: "center", justifyContent: "center", gap: 6,
                }}
              >
                <LogIn size={16}/>
                Iniciar sesión
              </button>
            </div>
          </div>
        )}

        <div style={{padding: "16px 0"}}>
          <div style={{
            padding: "0 24px 8px",
            fontSize: 11, fontWeight: 800, letterSpacing: 1.5,
            color: C.textDim, textTransform: "uppercase",
          }}>
            Explora
          </div>
          {navItems.map((item) => (
            <button
              key={item.page}
              type="button"
              onClick={() => handleNav(item.page)}
              style={{
                width: "100%",
                padding: "12px 24px",
                background: "transparent",
                border: "none",
                cursor: "pointer",
                display: "flex",
                alignItems: "center",
                gap: 14,
                color: C.text,
                fontSize: 15,
                fontWeight: 600,
                textAlign: "left",
                transition: "background .15s",
              }}
              onMouseEnter={(e) => { e.currentTarget.style.background = C.bg; }}
              onMouseLeave={(e) => { e.currentTarget.style.background = "transparent"; }}
            >
              <item.icon size={20} color={BRAND.primary}/>
              <span style={{flex: 1}}>{item.label}</span>
              <ChevronRight size={16} color={C.textDim}/>
            </button>
          ))}
        </div>

        <div style={{
          padding: "16px 24px",
          borderTop: `1px solid ${C.border}`,
          background: C.bg,
        }}>
          <div style={{
            fontSize: 11, fontWeight: 800, letterSpacing: 1.5,
            color: C.textDim, textTransform: "uppercase",
            marginBottom: 12,
          }}>
            Información
          </div>

          <div style={{display: "flex", gap: 12, marginBottom: 14}}>
            <MapPin size={18} color={BRAND.primary} style={{flexShrink: 0, marginTop: 2}}/>
            <a
              href={CONTACTO.maps_url}
              target="_blank"
              rel="noopener noreferrer"
              style={{ textDecoration: "none", color: "inherit" }}
            >
              <div style={{fontSize: 14, fontWeight: 700, color: C.text}}>
                Iztapalapa, CDMX
              </div>
              <div style={{fontSize: 12, color: BRAND.primary, lineHeight: 1.4, fontWeight: 600}}>
                {CONTACTO.direccion} · Ver en Google Maps →
              </div>
            </a>
          </div>

          <div style={{display: "flex", gap: 12, marginBottom: 14}}>
            <Clock size={18} color={BRAND.primary} style={{flexShrink: 0, marginTop: 2}}/>
            <div>
              <div style={{fontSize: 14, fontWeight: 700, color: C.text}}>
                Hoy: {horarioHoy}
              </div>
              <div style={{fontSize: 12, color: C.textMid, lineHeight: 1.6}}>
                Lun-Vie: 8:00 - 22:00<br/>
                Sábado: 8:00 - 20:00<br/>
                Domingo: 9:00 - 18:00
              </div>
            </div>
          </div>

          <a
            href={CONTACTO.whatsapp_link}
            target="_blank"
            rel="noopener noreferrer"
            style={{
              display: "flex", alignItems: "center", gap: 12,
              padding: "10px 12px",
              borderRadius: 8,
              background: "#25D36612",
              border: "1px solid #25D36630",
              textDecoration: "none",
              marginBottom: 8,
            }}
          >
            <Phone size={18} color="#25D366"/>
            <div style={{flex: 1}}>
              <div style={{fontSize: 13, fontWeight: 700, color: "#25D366"}}>
                WhatsApp
              </div>
              <div style={{fontSize: 12, color: C.textMid}}>
                {CONTACTO.whatsapp_display} · Hablar con nosotros
              </div>
            </div>
            <ChevronRight size={16} color="#25D366"/>
          </a>

          <a
            href="mailto:contacto@farmacapital.mx"
            style={{
              display: "flex", alignItems: "center", gap: 12,
              padding: "10px 12px",
              borderRadius: 8,
              background: BRAND.primary + "10",
              border: `1px solid ${BRAND.primary}30`,
              textDecoration: "none",
            }}
          >
            <Mail size={18} color={BRAND.primary}/>
            <div style={{flex: 1}}>
              <div style={{fontSize: 13, fontWeight: 700, color: BRAND.primary}}>
                Email
              </div>
              <div style={{fontSize: 12, color: C.textMid}}>
                contacto@farmacapital.mx
              </div>
            </div>
            <ChevronRight size={16} color={BRAND.primary}/>
          </a>
        </div>

        <div style={{padding: "16px 0"}}>
          <div style={{
            padding: "0 24px 8px",
            fontSize: 11, fontWeight: 800, letterSpacing: 1.5,
            color: C.textDim, textTransform: "uppercase",
          }}>
            Ayuda
          </div>
          {ayudaItems.map((item) => (
            <button
              key={item.page}
              type="button"
              onClick={() => handleNav(item.page)}
              style={{
                width: "100%",
                padding: "10px 24px",
                background: "transparent",
                border: "none",
                cursor: "pointer",
                display: "flex",
                alignItems: "center",
                gap: 14,
                color: C.textMid,
                fontSize: 13,
                textAlign: "left",
                transition: "background .15s",
              }}
              onMouseEnter={(e) => { e.currentTarget.style.background = C.bg; }}
              onMouseLeave={(e) => { e.currentTarget.style.background = "transparent"; }}
            >
              <item.icon size={16} color={C.textDim}/>
              <span>{item.label}</span>
            </button>
          ))}
        </div>

        {usuario && (
          <div style={{
            padding: "16px 24px",
            borderTop: `1px solid ${C.border}`,
          }}>
            <button
              type="button"
              onClick={() => { onLogout?.(); onClose(); }}
              style={{
                width: "100%", padding: 12,
                borderRadius: 10,
                border: `1px solid ${C.border}`,
                background: "transparent",
                color: "#ff3d5a",
                fontWeight: 700, fontSize: 14,
                cursor: "pointer",
              }}
            >
              Cerrar sesión
            </button>
          </div>
        )}

        <div style={{
          marginTop: "auto",
          padding: "20px 24px",
          background: C.bg,
          borderTop: `1px solid ${C.border}`,
        }}>
          <div style={{display: "flex", alignItems: "center", gap: 8, marginBottom: 8}}>
            <Logo size={24}/>
            <span style={{fontSize: 11, color: C.textDim}}>
              © 2026 FarmaCapital
            </span>
          </div>
          <div style={{fontSize: 10, color: C.textDim, lineHeight: 1.4}}>
            Todos los derechos reservados.<br/>
            Aviso COFEPRIS: las imágenes de productos son referenciales.
          </div>
        </div>
      </div>
    </div>
  );
}

// ── HEADER ────────────────────────────────────────────────────

function Header({page,setPage,cart,user,setUser}){
  const C = useTheme();
  const [menuOpen, setMenuOpen] = useState(false);
  const n=cart.reduce((a,c)=>a+c.qty,0);

  useEffect(()=>{ setMenuOpen(false); }, [page]);

  const go = (id) => {
    setMenuOpen(false);
    setPage(id);
  };

  const logout = async () => {
    const tok = getClienteToken();
    if (tok) { try { await supabase.rpc("logout_cliente", { p_session_token: tok }); } catch(e){} }
    clearClienteSession();
    setUser(null);
    setMenuOpen(false);
    setPage("home");
  };

  return(
    <>
      <header data-brand-surface="dark" style={{
        background:BRAND.primary,
        borderBottom:"none",
        padding:"10px 16px",
        paddingLeft:"max(16px, env(safe-area-inset-left, 0px))",
        paddingRight:"max(16px, env(safe-area-inset-right, 0px))",
        paddingTop:"max(10px, env(safe-area-inset-top, 0px))",
        display:"flex",
        alignItems:"center",
        justifyContent:"space-between",
        gap:12,
        position:"sticky",
        top:0,
        zIndex:50,
      }}>
        <button
          type="button"
          onClick={()=>{ setMenuOpen(false); setPage("home"); }}
          style={{
            background:"none",border:"none",padding:0,
            cursor:"pointer",display:"flex",alignItems:"center",gap:8,
          }}
          aria-label="Inicio FarmaCapital"
        >
          <Logo size={40} />
        </button>

        <div className="farmacapital-header-info-desktop" style={{
          display:"none",
          alignItems:"center",gap:16,fontSize:12,color:"rgba(255,255,255,.7)",flex:"1 1 auto",
          justifyContent:"center",minWidth:0,
        }}>
          <span>Iztapalapa, CDMX</span>
          <span>Abierto hasta 22:00</span>
        </div>

        <div style={{display:"flex",alignItems:"center",gap:8,flexShrink:0}}>
          <button
            type="button"
            aria-label="Ir al carrito"
            onClick={()=>setPage("carrito")}
            style={{
              background:n>0?"rgba(255,255,255,.15)":"transparent",
              border:"none",padding:8,borderRadius:8,
              cursor:"pointer",position:"relative",
              display:"flex",alignItems:"center",justifyContent:"center",
            }}
          >
            <ShoppingCart size={22} color="#fff"/>
            {n>0&&(
              <span style={{
                position:"absolute",top:0,right:0,
                background:BRAND.accent,color:"#fff",
                fontSize:10,fontWeight:800,
                minWidth:18,height:18,borderRadius:9,
                display:"flex",alignItems:"center",justifyContent:"center",
                padding:"0 5px",
              }}>{n}</span>
            )}
          </button>
          <button
            type="button"
            aria-label={menuOpen?"Cerrar menú":"Abrir menú"}
            aria-expanded={menuOpen}
            onClick={()=>setMenuOpen((o)=>!o)}
            style={{
              background:"rgba(255,255,255,.12)",border:"1px solid rgba(255,255,255,.2)",
              padding:8,borderRadius:8,cursor:"pointer",
              display:"flex",alignItems:"center",justifyContent:"center",
            }}
          >
            <Menu size={22} color="#fff"/>
          </button>
        </div>
      </header>

      <MenuTienda
        abierto={menuOpen}
        onClose={() => setMenuOpen(false)}
        setPage={setPage}
        usuario={user}
        onLogout={logout}
      />

      <style>{`
        @media (min-width: 768px) {
          .farmacapital-header-info-desktop { display: flex !important; }
        }
      `}</style>
    </>
  );
}

// ── PRODUCT CARD ──────────────────────────────────────────────
function ProductCard({prod,addToCart,onClick}){
  const C = useTheme();
  const narrow = useMediaQuery("(max-width: 768px)");
  const [added,setAdded]=useState(false);
  const agotado = productoAgotadoTienda(prod);
  const d=prod.disponible||(prod.stock>0?"inmediato":"48hrs");
  const placeholderUrl = useContext(TiendaPlaceholderCtx);
  const imgSrc = productImageUrl(prod, narrow, placeholderUrl);
  const handleDetailClick = () => { onClick?.(); };
  const handleAddClick = (e) => {
    e.stopPropagation();
    if(agotado)return;
    if(!productoPermitidoEnTiendaFarmaciaWeb(prod)){
      alert(productoEsCategoriaMinisuperTienda(prod)?"Artículo de minisuper: no está en la tienda farmacia en línea. Disponible en sucursal.":"Este producto no está disponible para compra en línea (receta, controlado o no publicado en tienda).");
      return;
    }
    addToCart(prod);
    setAdded(true);
    setTimeout(()=>setAdded(false),1500);
  };
  return(
    <div style={{
      background:C.white,
      borderRadius:12,
      border:`1px solid ${agotado ? C.border : C.border}`,
      overflow:"hidden",
      display:"flex",
      flexDirection:"column",
      width:"100%",
      maxWidth:"100%",
      minWidth:0,
      cursor:narrow?"default":"pointer",
      opacity:agotado ? 0.42 : 1,
      transition:"border-color .2s, transform .15s, opacity .15s",
    }}
      {...(!narrow ? { onClick: handleDetailClick } : {})}
      onMouseEnter={agotado ? undefined : (e=>{ e.currentTarget.style.borderColor=BRAND.secondary; e.currentTarget.style.transform="translateY(-2px)"; })}
      onMouseLeave={agotado ? undefined : (e=>{ e.currentTarget.style.borderColor=C.border; e.currentTarget.style.transform="translateY(0)"; })}
    >
      <div
        style={{
          background:C.cardDark,
          overflow:"hidden",
          minHeight:152,
          height:152,
          display:"flex",
          alignItems:"center",
          justifyContent:"center",
          padding:"10px 12px",
          WebkitTapHighlightColor:"transparent",
        }}
      >
        {imgSrc ? (
          <img
            src={imgSrc}
            alt=""
            draggable={false}
            style={{maxWidth:"100%",maxHeight:"100%",width:"auto",height:"auto",objectFit:"contain",display:"block"}}
          />
        ) : (
          <div style={{padding:"24px",display:"flex",alignItems:"center",justifyContent:"center",color:C.dim}}>
            <Package size={44} strokeWidth={1.25} aria-hidden/>
          </div>
        )}
      </div>
      <div
        style={{
          padding:"14px",
          flex:1,
          display:"flex",
          flexDirection:"column",
          WebkitTapHighlightColor:"transparent",
        }}
      >
        <div style={{display:"flex",gap:4,flexWrap:"wrap",marginBottom:8}}>
          {agotado
            ? <Tag col={C.red} sm>Agotado</Tag>
            : prod.stock<=3
              ? <Tag col="#f59e0b" sm>Últimas {prod.stock}</Tag>
              : <Tag col={d==="inmediato"?BRAND.accent:"#f59e0b"} sm>{d==="inmediato"?"Hoy":"24-48 hrs"}</Tag>
          }
          {prod.tipo==="generico"&&<Tag col={BRAND.secondary} sm>Genérico</Tag>}
          {prod.requiere_receta&&<Tag col={C.red} sm>Rx</Tag>}
          {prod.descuento_pct>0&&<span style={{background:C.red,color:"#fff",fontSize:9,fontWeight:800,borderRadius:4,padding:"2px 6px"}}>-{prod.descuento_pct}% OFF</span>}
        </div>
        <div style={{color:C.dark,fontWeight:700,fontSize:14,marginBottom:4,lineHeight:1.3,pointerEvents:"none"}}>{prod.nombre}</div>
        <div style={{color:C.dim,fontSize:11,marginBottom:8,flex:1}}>{prod.descripcion}</div>
        <div style={{marginBottom:10}}>
          <div style={{display:"flex",alignItems:"baseline",gap:8}}>
            <span style={{color:BRAND.primary,fontWeight:900,fontSize:20}}>{$(prod.precio||prod.precio||0)}</span>
            {prod.precio_marca&&<span style={{color:C.dim,fontSize:11,textDecoration:"line-through"}}>{$(prod.precio_marca)}</span>}
          </div>
          {prod.tipo==="generico"&&prod.precio_marca&&<div style={{color:BRAND.accent,fontSize:11,fontWeight:600}}>Ahorras {$(prod.precio_marca-prod.precio)}</div>}
        </div>
        <div style={{color:C.dim,fontSize:10,marginBottom:10}}>+{labelPts(ptsGana(prod.precio||prod.precio||0))}</div>
        <div style={{display:"flex",gap:8}}>
          <Btn onClick={handleDetailClick} outline col={BRAND.primary} sm style={{flex:1}}>Ver detalle</Btn>
          <Btn onClick={handleAddClick} col={agotado||!productoPermitidoEnTiendaFarmaciaWeb(prod)?"#94a3b8":added?BRAND.secondary:BRAND.primary} sm style={{flex:1,opacity:(agotado||!productoPermitidoEnTiendaFarmaciaWeb(prod))?0.6:1,cursor:agotado||!productoPermitidoEnTiendaFarmaciaWeb(prod)?"not-allowed":"pointer"}}>{agotado?"Agotado":!productoPermitidoEnTiendaFarmaciaWeb(prod)?(productoEsCategoriaMinisuperTienda(prod)?"Solo minisuper":"Solo en mostrador"):added?"✓ Listo":"+ Carrito"}</Btn>
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
  const poolCatalogo = useMemo(
    ()=>poolCatalogoTienda(productos),
    [productos]
  );
  const suggestions = useMemo(
    ()=>(busqFocus&&String(busqHero||"").trim().length>=2?tiendaCatalogSearchSuggestions(poolCatalogo,busqHero,{limit:8}):[]),
    [poolCatalogo,busqHero,busqFocus]
  );
  const irACatalogoBusqueda = ()=>{
    const q = String(busqHero||"").trim();
    setBusqFocus(false);
    try { if (q) sessionStorage.setItem("farmacapital_busq", q); } catch (err) { /* ignore */ }
    setPage("catalogo");
    requestAnimationFrame(()=>{
      document.getElementById("farmacapital-catalogo-resultados")?.scrollIntoView({ behavior: "smooth", block: "start" });
    });
  };
  if(!prod) return null;
  const agotado = productoAgotadoTienda(prod);
  const similares=productos.filter(p=>p.categoria===prod.categoria&&p.id!==prod.id).slice(0,4);
  const d=prod.disponible||(prod.stock>0?"inmediato":"48hrs");
  const imgSrc = productImageUrl(prod, stack, placeholderUrl);
  return(
    <div style={{maxWidth:1100,margin:"0 auto",padding:"clamp(20px, 4vw, 32px) 16px"}}>
      <div style={{background:C.white,borderRadius:14,border:`1px solid ${C.border}`,padding:16,marginBottom:20}}>
        <TiendaBusquedaBar
          compact
          value={busqHero||""}
          onChange={(e)=>{
            const v = e.target.value;
            setBusqHero?.(v);
            try { if (v.trim()) sessionStorage.setItem("farmacapital_busq", v); } catch (err) { /* ignore */ }
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
          placeholder="Buscar otro producto (nombre, principio activo, SKU…)"
          suggestions={suggestions}
          productos={productos}
          onPickSuggestion={(row)=>{
            if (row){
              setProdDetalle(row);
              setBusqFocus(false);
              window.scrollTo({ top: 0, behavior: "smooth" });
            }
          }}
          setPage={setPage}
          stack={stack}
        />
        <div style={{display:"flex",flexWrap:"wrap",gap:10,alignItems:"center",marginTop:12}}>
          <Btn sm col={BRAND.primary} onClick={irACatalogoBusqueda}>Ver resultados en catálogo</Btn>
          <span style={{color:C.dim,fontSize:12}}>Enter también abre el catálogo filtrado</span>
        </div>
      </div>
      <button type="button" onClick={()=>{ setProdDetalle(null); setPage("catalogo"); }} style={{background:"none",border:"none",color:BRAND.primary,cursor:"pointer",fontSize:14,fontWeight:700,marginBottom:20,display:"flex",alignItems:"center",gap:6}}>← Volver al catálogo</button>
      <div style={{display:"grid",gridTemplateColumns:stack?"1fr":"1fr 1fr",gap:stack?24:32,marginBottom:48,opacity:agotado?0.85:1}}>
        <div style={{background:C.cardDark,borderRadius:20,overflow:"hidden",display:"flex",alignItems:"center",justifyContent:"center",minHeight:stack?220:280,padding:stack?16:20,opacity:agotado?0.42:1}}>
          {imgSrc ? (
            <img src={imgSrc} alt="" style={{maxWidth:"100%",maxHeight:stack?360:420,width:"auto",height:"auto",objectFit:"contain",display:"block"}}/>
          ) : (
            <div style={{padding:stack?32:48,display:"flex",alignItems:"center",justifyContent:"center"}}>
              <Package size={88} strokeWidth={1} color={C.dim} aria-hidden/>
            </div>
          )}
        </div>
        <div>
          <div style={{display:"flex",gap:8,marginBottom:12,flexWrap:"wrap"}}>
            {agotado
              ? <Tag col={C.red}>Agotado</Tag>
              : <Tag col={d==="inmediato"?BRAND.accent:"#f59e0b"}>{d==="inmediato"?"✓ Disponible hoy":"📦 24-48 hrs"}</Tag>
            }
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
            <div style={{color:"#92400e",fontWeight:700}}>Ganas {labelPts(ptsGana(prod.precio))} con esta compra</div>
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
          {agotado&&(
            <div style={{background:C.red+"10",border:`1px solid ${C.red}30`,borderRadius:10,padding:"10px 14px",marginBottom:16}}>
              <div style={{color:C.red,fontWeight:700,fontSize:13}}>Producto agotado por el momento. Puedes ver la ficha; cuando haya stock podrás agregarlo al carrito.</div>
            </div>
          )}
          <div style={{display:"flex",gap:12,flexWrap:"wrap"}}>
            <Btn onClick={()=>{ if(agotado) return; addToCart(prod);setAdded(true);setTimeout(()=>setAdded(false),1500); }} disabled={agotado} col={agotado?"#94a3b8":added?BRAND.secondary:BRAND.primary} style={{flex:"1 1 min(100%,200px)",minWidth:0}}>{agotado?"Agotado":added?"✓ Agregado":"Agregar al carrito"}</Btn>
            <Btn onClick={()=>{ if(agotado) return; addToCart(prod);setPage("carrito"); }} disabled={agotado} outline col={BRAND.primary} style={{flex:"1 1 min(100%,200px)",minWidth:0}}>Comprar ahora</Btn>
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
      sessionStorage.removeItem("farmacapital_cat");
      sessionStorage.removeItem("farmacapital_busq");
      sessionStorage.removeItem("farmacapital_tipo");
    } catch (_) { /* noop */ }
    setPage("catalogo");
  };
  return(
    <footer data-brand-surface="dark" style={{background:C.dark,marginTop:48}}>
      {/* Links principales */}
      <div style={{maxWidth:1200,margin:"0 auto",padding:"48px 24px 32px",display:"grid",gridTemplateColumns:stack?"1fr":"repeat(4,1fr)",gap:stack?28:32}}>
        {/* FarmaCapital */}
        <div>
          <div style={{marginBottom:16}}><Logo size={28} /></div>
          <p style={{color:"rgba(255,255,255,.6)",fontSize:13,lineHeight:1.7,marginBottom:16}}>Tu farmacia de confianza en Chinampac de Juárez. Medicamentos genéricos y de marca certificados por COFEPRIS.</p>
          <div style={{color:"rgba(255,255,255,.5)",fontSize:12,marginBottom:8}}>{CONTACTO.direccion}</div>
          <a href={CONTACTO.maps_url} target="_blank" rel="noopener noreferrer" style={{color:"rgba(255,255,255,.75)",fontSize:12,fontWeight:700,textDecoration:"none"}}>
            📍 Ver en Google Maps →
          </a>
        </div>
        {/* Atención a clientes */}
        <div>
          <div style={{color:C.white,fontWeight:700,fontSize:14,marginBottom:16,textTransform:"uppercase",letterSpacing:1}}>Atención a clientes</div>
          {[
            ["Teléfono / WhatsApp", CONTACTO.whatsapp_display, () => window.open(CONTACTO.whatsapp_link, "_blank", "noopener,noreferrer")],
            ["Correo", CONTACTO.email, () => { window.location.href = `mailto:${CONTACTO.email}`; }],
            ["Horario", CONTACTO.horario, null],
            ["Dirección", CONTACTO.direccion, () => window.open(CONTACTO.maps_url, "_blank", "noopener,noreferrer")],
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
          {[["Agendar cita","cita"],["Preguntas frecuentes","faq"],["Surtir receta","catalogo"],["Mis puntos FarmaCapital","puntos"],["Mi cuenta","cuenta"]].map(([l,pg])=>(
            <button key={l} onClick={()=> l==="Surtir receta" ? goSurtirReceta() : l==="Agendar cita" ? navigateToCita(setPage) : setPage(pg)} style={{display:"block",background:"none",border:"none",color:"rgba(255,255,255,.6)",fontSize:13,cursor:"pointer",marginBottom:8,textAlign:"left",padding:0,fontFamily:"'Plus Jakarta Sans',sans-serif"}}
              onMouseEnter={e=>(e.currentTarget.style.color="rgba(255,255,255,.9)")}
              onMouseLeave={e=>(e.currentTarget.style.color="rgba(255,255,255,.6)")}>{l}</button>
          ))}
        </div>
        {/* Políticas */}
        <div>
          <div style={{color:C.white,fontWeight:700,fontSize:14,marginBottom:16,textTransform:"uppercase",letterSpacing:1}}>Información legal</div>
          {[["Aviso de privacidad","privacidad"],["Términos y condiciones","terminos"],["Política de envíos","envios"],["Programa Puntos FarmaCapital","terminos-puntos"]].map(([l,pg])=>(
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
            © 2026 FarmaCapital — Todos los derechos reservados
          </div>
        </div>
      </div>
    </footer>
  );
}

// ── HOME: SERVICIOS — helpers de contenido modal ──────────────
const sStrong = { color:"inherit", fontWeight:700 };
const sH4 = (color)=>({
  color,
  fontSize:13,
  fontWeight:800,
  textTransform:"uppercase",
  letterSpacing:1,
  marginTop:18,
  marginBottom:8,
});
const sList = { margin:"8px 0", paddingLeft:20 };
const sListItem = { marginBottom:6 };

function ContenidoPickup({ C, color }){
  return (
    <>
      <p style={{margin:"0 0 12px"}}>
        Pide en línea y recoge personalmente en FarmaCapital. Sin costo de envío y disponible el mismo día.
      </p>
      <h4 style={sH4(color)}>¿Cómo funciona?</h4>
      <ol style={sList}>
        <li style={sListItem}>Haz tu pedido en línea y elige &quot;Pick-up en farmacia&quot;</li>
        <li style={sListItem}>Realiza el pago (efectivo al recoger, tarjeta o Mercado Pago)</li>
        <li style={sListItem}>Recibe confirmación cuando tu pedido esté listo (15–30 minutos)</li>
        <li style={sListItem}>Pasa por él en nuestro horario de atención</li>
      </ol>
      <h4 style={sH4(color)}>Dirección</h4>
      <p style={{margin:"0 0 12px"}}>
        {CONTACTO.direccion}{" "}
        <a href={CONTACTO.maps_url} target="_blank" rel="noopener noreferrer" style={{color,fontWeight:700}}>
          Ver en Google Maps →
        </a>
      </p>
      <h4 style={sH4(color)}>Horario</h4>
      <ul style={sList}>
        <li style={sListItem}>Lunes a Viernes: 8:00 – 22:00</li>
        <li style={sListItem}>Sábado: 8:00 – 20:00</li>
        <li style={sListItem}>Domingo: 9:00 – 18:00</li>
      </ul>
      <h4 style={sH4(color)}>Importante</h4>
      <p style={{margin:0,color:C.textMid,fontSize:13}}>
        Trae una identificación oficial y el número de pedido. Si pagas en efectivo al recoger, ten lista la cantidad exacta cuando sea posible.
      </p>
    </>
  );
}

function ContenidoCDMX({ color }){
  return (
    <>
      <p style={{margin:"0 0 12px"}}>
        Recibe tu pedido en tu domicilio en menos de 60 minutos dentro de la Ciudad de México con nuestros aliados de mensajería.
      </p>
      <h4 style={sH4(color)}>¿Cómo funciona?</h4>
      <ol style={sList}>
        <li style={sListItem}>Haz tu pedido en línea y elige &quot;Entrega CDMX express&quot;</li>
        <li style={sListItem}>El costo de envío se calcula según tu zona y peso (lo verás antes de pagar)</li>
        <li style={sListItem}>Un repartidor de Rappi o Uber recoge tu pedido en la farmacia</li>
        <li style={sListItem}>Llega a tu domicilio en 30–60 minutos</li>
      </ol>
      <h4 style={sH4(color)}>Cobertura</h4>
      <p style={{margin:"0 0 12px"}}>
        Toda la Ciudad de México y zonas metropolitanas cubiertas por Rappi y Uber Connect.
      </p>
      <h4 style={sH4(color)}>Costo</h4>
      <p style={{margin:"0 0 12px"}}>
        Variable según distancia. Lo calculamos automáticamente al confirmar tu pedido.
      </p>
      <h4 style={sH4(color)}>Horario de servicio</h4>
      <p style={{margin:"0 0 12px"}}>
        Disponible durante el horario de atención de la farmacia.
      </p>
      <h4 style={sH4(color)}>Recomendación</h4>
      <p style={{margin:0,color:C.textMid,fontSize:13}}>
        Para entregas de medicamentos refrigerados o productos frágiles, considera hacer tu pedido al inicio de nuestro horario para mayor frescura.
      </p>
    </>
  );
}

function ContenidoPago({ C, color }){
  return (
    <>
      <p style={{margin:"0 0 12px"}}>
        En FarmaCapital aceptamos varias formas de pago para tu comodidad.
      </p>
      <h4 style={sH4(color)}>En línea (a través de Mercado Pago)</h4>
      <ul style={sList}>
        <li style={sListItem}>Tarjetas de crédito (Visa, Mastercard, American Express)</li>
        <li style={sListItem}>Tarjetas de débito</li>
        <li style={sListItem}>Transferencia bancaria SPEI</li>
        <li style={sListItem}>OXXO Pay (paga en cualquier OXXO)</li>
        <li style={sListItem}>Mercado Crédito (a meses sin intereses según tu cuenta)</li>
      </ul>
      <h4 style={sH4(color)}>En la farmacia (al recoger pick-up)</h4>
      <ul style={sList}>
        <li style={sListItem}>Efectivo</li>
        <li style={sListItem}>Tarjetas de crédito y débito</li>
        <li style={sListItem}>Transferencia bancaria SPEI</li>
      </ul>
      <h4 style={sH4(color)}>Seguridad</h4>
      <p style={{margin:"0 0 12px",color:C.textMid,fontSize:13}}>
        Mercado Pago es una pasarela externa certificada. Tus datos bancarios nunca se almacenan en FarmaCapital. Todo el proceso de pago en línea es manejado directamente por Mercado Pago con cifrado de extremo a extremo.
      </p>
      <h4 style={sH4(color)}>Reembolsos</h4>
      <p style={{margin:0,color:C.textMid,fontSize:13}}>
        Si necesitas un reembolso, te lo procesamos por el mismo medio de pago que usaste, en un plazo de 3–7 días hábiles.
      </p>
    </>
  );
}

function ServicioModal({ abierto, onClose, titulo, color, contenido: Contenido }){
  const C = useTheme();
  if (!abierto) return null;
  return (
    <div
      role="presentation"
      onClick={onClose}
      style={{
        position:"fixed",
        inset:0,
        background:"rgba(15,23,42,.6)",
        display:"flex",
        alignItems:"center",
        justifyContent:"center",
        zIndex:1000,
        padding:16,
        backdropFilter:"blur(2px)",
      }}
    >
      <div
        role="dialog"
        aria-modal="true"
        aria-labelledby="farmacapital-servicio-modal-titulo"
        onClick={(e)=>e.stopPropagation()}
        style={{
          background:C.card,
          borderRadius:16,
          maxWidth:560,
          width:"100%",
          maxHeight:"85vh",
          overflowY:"auto",
          boxShadow:"0 20px 60px rgba(0,0,0,.3)",
        }}
      >
        <div style={{
          background:`linear-gradient(135deg, ${color}, ${color}dd)`,
          padding:"20px 24px",
          color:"#fff",
          position:"relative",
          borderRadius:"16px 16px 0 0",
        }}>
          <button
            type="button"
            aria-label="Cerrar"
            onClick={onClose}
            style={{
              position:"absolute",
              top:12,
              right:12,
              background:"rgba(255,255,255,.2)",
              border:"none",
              color:"#fff",
              width:32,
              height:32,
              borderRadius:"50%",
              cursor:"pointer",
              fontSize:18,
              display:"flex",
              alignItems:"center",
              justifyContent:"center",
            }}
          >
            ×
          </button>
          <h3 id="farmacapital-servicio-modal-titulo" style={{
            margin:0,
            fontSize:20,
            fontWeight:800,
            paddingRight:32,
            lineHeight:1.3,
            fontFamily:"'Plus Jakarta Sans',sans-serif",
          }}>
            {titulo}
          </h3>
        </div>
        <div style={{
          padding:24,
          color:C.text,
          fontSize:14,
          lineHeight:1.7,
          fontFamily:"'Plus Jakarta Sans',sans-serif",
        }}>
          <Contenido C={C} color={color}/>
        </div>
        <div style={{
          padding:"16px 24px 24px",
          borderTop:`1px solid ${C.border}`,
        }}>
          <button
            type="button"
            onClick={onClose}
            style={{
              width:"100%",
              padding:12,
              borderRadius:10,
              border:"none",
              background:color,
              color:"#fff",
              fontWeight:700,
              fontSize:14,
              cursor:"pointer",
              fontFamily:"'Plus Jakarta Sans',sans-serif",
            }}
          >
            Entendido
          </button>
        </div>
      </div>
    </div>
  );
}

// ── HOME: SERVICIOS (carrusel móvil / grid escritorio) ────────
function HomeServices({setPage}){
  const C = useTheme();
  const [modalAbierto,setModalAbierto]=useState(null);
  const servicios = [
    { key:"pickup", titulo:"Pick-up gratis", desc:"Recoge hoy", color:BRAND.primary, tipo:"modal", icon:Store },
    { key:"cdmx", titulo:"CDMX express", desc:"Rappi & Uber", color:BRAND.secondary, tipo:"modal", icon:Bike },

    { key:"puntos", titulo:"Tus puntos", desc:"Acumula y canjea", color:"#f59e0b", tipo:"page", destino:"puntos", icon:Trophy },
    { key:"pago", titulo:"Pago online", desc:"Mercado Pago", color:"#8b5cf6", tipo:"modal", icon:CreditCard },
  ];
  const handleClick = (s)=>{
    if (s.tipo==="page") setPage(s.destino);
    else setModalAbierto(s.key);
  };
  return (
    <>
      <div style={{padding:16,background:C.bg,borderBottom:`1px solid ${C.border}`}}>
        <div className="farmacapital-home-services-scroll" style={{
          display:"flex",
          gap:12,
          overflowX:"auto",
          scrollSnapType:"x mandatory",
          paddingBottom:4,
          scrollbarWidth:"none",
          WebkitOverflowScrolling:"touch",
        }}>
          {servicios.map((s)=>(
            <button
              key={s.key}
              type="button"
              onClick={()=>handleClick(s)}
              style={{
                flex:"0 0 auto",
                width:"min(160px, 38vw)",
                padding:"14px",
                borderRadius:12,
                border:"none",
                background:s.color+"14",
                cursor:"pointer",
                scrollSnapAlign:"start",
                textAlign:"left",
                display:"flex",
                flexDirection:"column",
                gap:6,
                transition:"transform .15s, background .15s",
                fontFamily:"'Plus Jakarta Sans',sans-serif",
              }}
              onMouseEnter={(e)=>{
                e.currentTarget.style.transform="translateY(-2px)";
                e.currentTarget.style.background=s.color+"22";
              }}
              onMouseLeave={(e)=>{
                e.currentTarget.style.transform="translateY(0)";
                e.currentTarget.style.background=s.color+"14";
              }}
            >
              <div style={{width:34,height:34,borderRadius:9,background:s.color+"22",display:"flex",alignItems:"center",justifyContent:"center"}}>
                {s.icon && <s.icon size={18} color={s.color} strokeWidth={2}/>}
              </div>
              <div style={{color:C.dark,fontSize:13,fontWeight:700,lineHeight:1.2}}>{s.titulo}</div>
              <div style={{color:s.color,fontSize:11,fontWeight:600,lineHeight:1.3}}>{s.desc}</div>
            </button>
          ))}
        </div>
        <style>{`
          .farmacapital-home-services-scroll::-webkit-scrollbar { display: none; }
          @media (min-width: 769px) {
            .farmacapital-home-services-scroll {
              display: grid !important;
              grid-template-columns: repeat(5, minmax(0, 1fr));
              overflow-x: visible !important;
              scroll-snap-type: none;
            }
            .farmacapital-home-services-scroll > button {
              width: auto !important;
              min-width: 0;
            }
          }
        `}</style>
      </div>
      <ServicioModal
        abierto={modalAbierto==="pickup"}
        onClose={()=>setModalAbierto(null)}
        titulo="Recoge tu pedido en la farmacia"
        color={BRAND.primary}
        contenido={ContenidoPickup}
      />
      <ServicioModal
        abierto={modalAbierto==="cdmx"}
        onClose={()=>setModalAbierto(null)}
        titulo="Entrega rápida en CDMX"
        color={BRAND.secondary}
        contenido={ContenidoCDMX}
      />
      <ServicioModal
        abierto={modalAbierto==="pago"}
        onClose={()=>setModalAbierto(null)}
        titulo="Métodos de pago aceptados"
        color="#8b5cf6"
        contenido={ContenidoPago}
      />
    </>
  );
}

function promoTipoBadgeStyles(tipo){
  if (tipo==="descuento_pct") return { bg:"#eff6ff", fg:BRAND.primary };
  if (tipo==="2x1") return { bg:"#ede9fe", fg:"#7c3aed" };
  if (tipo==="descuento_fijo") return { bg:"#dcfce7", fg:"#16a34a" };
  return { bg:"#dcfce7", fg:"#16a34a" };
}

/** Solo home: oculta bloque si no hay promos activas (respuesta ya filtrada por fecha en Home). */
function HomePromociones({promos,setPage}){
  const C = useTheme();
  const activas = useMemo(()=> (promos||[]).filter((p)=> p.activa !== false), [promos]);
  if (!activas.length) return null;
  return (
    <div style={{padding:"16px",maxWidth:1200,margin:"0 auto"}}>
      <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",gap:12,marginBottom:12,flexWrap:"wrap"}}>
        <h3 style={{
          fontSize:18,fontWeight:800,color:C.text,margin:0,
          fontFamily:"'Plus Jakarta Sans',sans-serif",
        }}>
          Promociones y descuentos
        </h3>
        <Btn onClick={()=>setPage("promo")} outline col={BRAND.primary} sm>Ver todas</Btn>
      </div>
      <div className="farmacapital-home-promos-scroll" style={{
        display:"flex",
        gap:12,
        overflowX:"auto",
        scrollSnapType:"x mandatory",
        scrollbarWidth:"none",
        WebkitOverflowScrolling:"touch",
        paddingBottom:4,
      }}>
        {activas.map((p,i)=>{
          const img = p.imagen_url != null && String(p.imagen_url).trim() !== "" ? String(p.imagen_url).trim() : "";
          const badge = promoTipoBadgeStyles(p.tipo);
          const chip =
            p.tipo==="descuento_pct" ? `${p.valor}% OFF`
            : p.tipo==="descuento_fijo" ? `$${p.valor} OFF`
            : p.tipo==="2x1" ? "2×1"
            : "Combo";
          return (
            <button
              key={p.id ?? i}
              type="button"
              onClick={()=>setPage("promo")}
              style={{
                flex:"0 0 auto",
                width:"min(280px, 75vw)",
                borderRadius:12,
                overflow:"hidden",
                border:`1px solid ${C.border}`,
                background:C.card,
                cursor:"pointer",
                scrollSnapAlign:"start",
                padding:0,
                textAlign:"left",
                fontFamily:"'Plus Jakarta Sans',sans-serif",
              }}
            >
              {img ? (
                <img src={img} alt={p.nombre || ""} style={{
                  width:"100%",aspectRatio:"16/9",objectFit:"cover",display:"block",
                }}/>
              ) : (
                <div style={{
                  aspectRatio:"16/9",
                  background:BRAND.gradient,
                  display:"flex",alignItems:"center",justifyContent:"center",
                  color:"#fff",fontWeight:700,fontSize:16,
                  padding:16,textAlign:"center",lineHeight:1.35,
                }}>
                  {p.nombre || "Promoción"}
                </div>
              )}
              <div style={{padding:12}}>
                <div style={{display:"flex",justifyContent:"space-between",alignItems:"flex-start",gap:8}}>
                  <div style={{fontWeight:700,fontSize:14,color:C.text,lineHeight:1.3,flex:1,minWidth:0}}>{p.nombre}</div>
                  <span style={{
                    padding:"3px 8px",borderRadius:20,fontSize:10,fontWeight:700,flexShrink:0,
                    background:badge.bg,color:badge.fg,
                  }}>{chip}</span>
                </div>
                {p.descripcion ? (
                  <div style={{fontSize:12,color:C.textMid,marginTop:6,lineHeight:1.45}}>{p.descripcion}</div>
                ) : null}
                {p.fecha_fin ? (
                  <div style={{fontSize:11,color:C.textDim,marginTop:8}}>
                    Válido hasta: {p.fecha_fin}
                  </div>
                ) : null}
              </div>
            </button>
          );
        })}
      </div>
      <style>{`
        .farmacapital-home-promos-scroll::-webkit-scrollbar { display: none; }
      `}</style>
    </div>
  );
}

function TiendaSearchSuggestions({ suggestions, productos, onPick, C }) {
  if (!suggestions?.length) return null;
  return (
    <div
      role="listbox"
      aria-label="Sugerencias de búsqueda"
      style={{
        position: "absolute",
        left: 0,
        right: 0,
        top: "100%",
        marginTop: 6,
        background: C.white,
        border: `1px solid ${C.border}`,
        borderRadius: 14,
        boxShadow: "0 16px 48px rgba(15,23,42,.14)",
        maxHeight: "min(50vh, 300px)",
        overflowY: "auto",
        WebkitOverflowScrolling: "touch",
        zIndex: 50,
      }}
    >
      {suggestions.map((s) => {
        const row = productos.find((x) => x.id === s.id);
        return (
          <button
            key={s.id}
            type="button"
            role="option"
            onPointerDown={(e) => {
              if (e.pointerType === "mouse") e.preventDefault();
            }}
            onClick={() => onPick(row, s)}
            style={{
              display: "block",
              width: "100%",
              textAlign: "left",
              padding: "10px 14px",
              border: "none",
              borderBottom: `1px solid ${C.border}`,
              background: "transparent",
              cursor: "pointer",
              fontFamily: "'Plus Jakarta Sans',sans-serif",
            }}
          >
            <div style={{ color: C.dark, fontWeight: 700, fontSize: 13, lineHeight: 1.35 }}>{s.nombre}</div>
            <div style={{ color: C.dim, fontSize: 11, marginTop: 3, display: "flex", flexWrap: "wrap", gap: 8 }}>
              {s.sku ? <span>SKU <strong style={{ color: BRAND.primary }}>{s.sku}</strong></span> : null}
              {s.codigo_barras ? <span>Cód. {s.codigo_barras}</span> : null}
              {Number(s.stock) <= 0 ? <span style={{ color: C.red }}>Agotado</span> : null}
            </div>
          </button>
        );
      })}
    </div>
  );
}

/** Buscador de catálogo + CTA consultorio (icono fijo, texto legible en dark mode OS). */
function TiendaBusquedaBar({
  value,
  onChange,
  onFocus,
  onBlur,
  onKeyDown,
  placeholder = "Nombre, principio activo, SKU o código de barras…",
  suggestions = [],
  productos = [],
  onPickSuggestion,
  setPage,
  stack,
  compact = false,
}) {
  const C = useTheme();
  const q = String(value || "").trim();

  return (
    <div
      style={{
        display: "flex",
        flexDirection: stack ? "column" : "row",
        gap: stack ? 10 : 12,
        alignItems: stack ? "stretch" : "center",
        width: "100%",
        marginBottom: compact ? 16 : 0,
      }}
    >
      <div style={{ position: "relative", flex: 1, minWidth: 0, zIndex: 30 }}>
        <Search
          size={18}
          strokeWidth={2.25}
          aria-hidden
          style={{
            position: "absolute",
            left: compact ? 12 : 16,
            top: "50%",
            transform: "translateY(-50%)",
            color: q ? BRAND.primary : C.textDim,
            pointerEvents: "none",
            zIndex: 1,
          }}
        />
        <input
          type="search"
          value={value}
          onChange={onChange}
          onFocus={onFocus}
          onBlur={onBlur}
          onKeyDown={onKeyDown}
          placeholder={placeholder}
          autoComplete="off"
          enterKeyHint="search"
          style={{
            width: "100%",
            boxSizing: "border-box",
            padding: compact ? "12px 14px 12px 40px" : "16px 20px 16px 44px",
            borderRadius: compact ? 10 : 30,
            border: compact ? `1px solid ${C.border}` : `2px solid ${BRAND.primary}30`,
            fontSize: 16,
            lineHeight: 1.25,
            fontFamily: "'Plus Jakarta Sans',sans-serif",
            outline: "none",
            background: C.white,
            color: C.text,
            WebkitTextFillColor: C.text,
            caretColor: BRAND.primary,
            colorScheme: "light",
            boxShadow: compact ? "none" : "0 4px 20px rgba(15,45,110,.1)",
          }}
        />
        <TiendaSearchSuggestions
          suggestions={suggestions}
          productos={productos}
          onPick={onPickSuggestion}
          C={C}
        />
      </div>
      <button
        type="button"
        onClick={() => navigateToCita(setPage)}
        style={{
          flexShrink: 0,
          display: "inline-flex",
          alignItems: "center",
          justifyContent: "center",
          gap: 8,
          padding: stack ? "13px 18px" : "14px 20px",
          borderRadius: compact ? 10 : 30,
          border: "none",
          background: BRAND.gradient,
          color: "#fff",
          fontWeight: 800,
          fontSize: stack ? 14 : 15,
          fontFamily: "'Plus Jakarta Sans',sans-serif",
          cursor: "pointer",
          boxShadow: "0 4px 16px rgba(30,58,186,.22)",
          whiteSpace: "nowrap",
          minHeight: compact ? 44 : 52,
        }}
      >
        <Stethoscope size={18} strokeWidth={2.25} aria-hidden />
        Agendar cita
      </button>
    </div>
  );
}

// ── HOME ──────────────────────────────────────────────────────
function Home({setPage,addToCart,productos,setProdDetalle,busqHero,setBusqHero,precioConsulta,loadingProductos}){
  const C = useTheme();
  const stack = useMediaQuery("(max-width: 768px)");
  const [promos, setPromos] = useState([]);
  const [bannerZones, setBannerZones] = useState({hero:[], strip:[], tile:[]});
  const [bannerMeta, setBannerMeta] = useState({ status: "loading", total: 0 });
  const [heroBusqFocus, setHeroBusqFocus] = useState(false);
  const poolHeroStock = useMemo(
    () => poolCatalogoTienda(productos),
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
        useStaticPlaceholder={useStaticHero}
      />

      <HomeServices setPage={setPage}/>

      <HomeBannersStrip setPage={setPage} items={bannerZones.strip}/>

      {/* Barra búsqueda + cita */}
      <div style={{background:`linear-gradient(180deg,${BRAND.primary}10,transparent)`,padding:"24px 16px"}}>
        <div style={{maxWidth:920,margin:"0 auto"}}>
          <TiendaBusquedaBar
            value={busqHero}
            onChange={(e)=>setBusqHero(e.target.value)}
            onFocus={()=>setHeroBusqFocus(true)}
            onBlur={()=>setTimeout(()=>setHeroBusqFocus(false),280)}
            onKeyDown={(e)=>{
              if(e.key==="Enter"&&busqHero.trim()){
                try{
                  const t=busqHero.trim();
                  sessionStorage.setItem("farmacapital_busq",t);
                  const p=JSON.parse(localStorage.getItem("farmacapital_busqs")||"[]");
                  localStorage.setItem("farmacapital_busqs",JSON.stringify([t,...p.filter(b=>b!==t)].slice(0,5)));
                }catch(err){}
                setPage("catalogo");
              }
            }}
            suggestions={heroSuggestions}
            productos={productos}
            onPickSuggestion={(row)=>{
              if(row){ setProdDetalle(row); setPage("detalle"); }
              setHeroBusqFocus(false);
            }}
            setPage={setPage}
            stack={stack}
          />
        </div>
      </div>

      <HomeBannersTiles setPage={setPage} items={bannerZones.tile} stack={stack}/>

      <HomePromociones promos={promos} setPage={setPage}/>

      {/* Más vendidos */}
      <div style={{maxWidth:1200,margin:"0 auto",padding:"0 16px 48px"}}>
        <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:24,flexWrap:"wrap",gap:12}}>
          <h2 style={{color:C.dark,fontSize:"clamp(20px,4.5vw,24px)",fontWeight:800,margin:0}}>Más vendidos en FarmaCapital</h2>
          <Btn onClick={()=>setPage("catalogo")} outline col={BRAND.primary} sm>Ver catálogo →</Btn>
        </div>
        <div style={{display:"grid",gridTemplateColumns:"repeat(auto-fill,minmax(min(100%,220px),1fr))",gap:16}}>
          {loadingProductos && productos.length===0
            ? Array.from({length:6}).map((_,i)=>(
                <div key={i} style={{borderRadius:12,background:C.surface,height:260,animation:"pulse 1.4s ease-in-out infinite",opacity:0.7}}/>
              ))
            : sortCatalogoTienda(productos, "")
                .slice(0, 6)
                .map(p=><ProductCard key={p.id} prod={p} addToCart={addToCart} onClick={()=>{setProdDetalle(p);setPage("detalle");}}/>)
          }
        </div>
      </div>

      {/* Consultorio */}
      <div style={{background:BRAND.primary+"12",padding:"48px 24px"}}>
        <div style={{maxWidth:800,margin:"0 auto",textAlign:"center"}}>
          <h2 style={{color:C.dark,fontSize:28,fontWeight:800,marginBottom:12}}>Consultorio médico FarmaCapital</h2>
          <p style={{color:C.mid,fontSize:16,lineHeight:1.7,marginBottom:28}}>Atención médica general · <strong>{$(precioConsulta ?? CONSULTA_PRECIO_DEFAULT)} por consulta</strong> · O gratis con <strong style={{color:BRAND.primary}}>160 puntos FarmaCapital</strong>. Al terminar tu consulta, surte tu receta con <strong>10% de descuento</strong>.</p>
          <Btn onClick={()=>navigateToCita(setPage)} col={BRAND.primary}>Agendar cita online</Btn>
        </div>
      </div>

      {/* Puntos FarmaCapital */}
      <div style={{maxWidth:1200,margin:"48px auto",padding:"0 16px"}}>
        <div style={{background:C.dark,borderRadius:20,padding:stack?"28px 20px":"40px",display:"grid",gridTemplateColumns:stack?"1fr":"1fr 1fr",gap:stack?28:40,alignItems:"center"}}>
          <div>
            <div style={{color:BRAND.secondary,fontWeight:700,fontSize:13,letterSpacing:2,textTransform:"uppercase",marginBottom:12}}>Programa de lealtad</div>
            <h2 style={{color:C.white,fontSize:"clamp(22px,5vw,28px)",fontWeight:800,marginBottom:16}}>Puntos FarmaCapital</h2>
            <p style={{color:"rgba(255,255,255,.75)",fontSize:15,lineHeight:1.7,marginBottom:24}}>Acumula puntos en farmacia, minisuper y consultorio. Canjéalos por descuentos o consultas gratis.</p>
            <Btn onClick={()=>setPage("puntos")} style={{background:BRAND.accent,color:C.white,border:"none"}}>Ver programa de puntos</Btn>
          </div>
          <div style={{display:"grid",gridTemplateColumns:stack?"1fr":"1fr 1fr",gap:12}}>
            {[["$10 en FarmaCapital","1 punto",BRAND.secondary],["1 consulta","5 puntos",BRAND.accent],["160 puntos","Consulta gratis","#ffaa00"],["100 puntos","$50 descuento","#9d6fff"]].map(([a,b,col])=>(
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
          <h2 style={{color:C.dark,fontSize:"clamp(18px,4vw,22px)",fontWeight:800,margin:0}}>Preguntas frecuentes</h2>
          <Btn onClick={()=>setPage("faq")} outline col={BRAND.primary} sm>Ver todas →</Btn>
        </div>
        <div style={{display:"grid",gridTemplateColumns:stack?"1fr":"1fr 1fr",gap:12}}>
          {FAQ_ITEMS.slice(0,4).map((f,i)=>(
            <div key={i} style={{background:C.white,borderRadius:12,border:`1px solid ${C.border}`,padding:16,cursor:"pointer"}} onClick={()=>setPage("faq")}>
              <div style={{color:C.dark,fontWeight:700,fontSize:14,marginBottom:6}}>{f.p}</div>
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
function Catalogo({addToCart,productos,setProdDetalle,setPage,busqHero,setBusqHero,loadingProductos}){
  const C = useTheme();
  const stack = useMediaQuery("(max-width: 768px)");
  /** Safari iOS: sticky lateral + scroll del documento suele causar rebote/“lock”; solo usar sticky en escritorio ancho. */
  const categoriasStickyDesktop = useMediaQuery("(min-width: 1025px)");
  const [cat,setCat]=useState(()=>sessionStorage.getItem("farmacapital_cat")||"Todos");
  const [busq,setBusq]=useState(busqHero||sessionStorage.getItem("farmacapital_busq")||"");
  const [tipo,setTipo]=useState(()=>sessionStorage.getItem("farmacapital_tipo")||"todos");
  const [openCategorias, setOpenCategorias] = useState(false);
  const [busqFocus,setBusqFocus]=useState(false);
  useEffect(()=>{ sessionStorage.setItem("farmacapital_cat",cat); },[cat]);
  useEffect(()=>{ sessionStorage.setItem("farmacapital_busq",busq); },[busq]);
  useEffect(()=>{ sessionStorage.setItem("farmacapital_tipo",tipo); },[tipo]);
  useEffect(()=>{
    const t = busqHero != null && String(busqHero).trim();
    if (t) {
      setBusq(busqHero);
      setTipo("todos");
      setCat("Todos");
    }
  },[busqHero]);
  const cats=["Todos",...new Set(poolCatalogoTienda(productos).map(p=>p.categoria).filter(Boolean))];
  const basePool = useMemo(()=>poolCatalogoTienda(productos)
    .filter(p=>cat==="Todos"||p.categoria===cat)
    .filter(p=>tipo==="todos"||p.tipo===tipo),
  [productos,cat,tipo]);
  const fil = useMemo(()=>{
    const arr = basePool.filter((p)=>tiendaProductMatchesBusqueda(p, busq));
    return sortCatalogoTienda(arr, busq);
  }, [basePool, busq]);
  const poolCatalogo = useMemo(
    ()=>poolCatalogoTienda(productos),
    [productos]
  );
  const suggestions = useMemo(
    ()=>(busqFocus&&busq.trim().length>=2?tiendaCatalogSearchSuggestions(poolCatalogo,busq,{limit:8}):[]),
    [poolCatalogo,busq,busqFocus]
  );
  const hayCoincidenciasSinFiltrosLaterales = useMemo(()=>{
    if (!busq.trim()) return false;
    return poolCatalogoTienda(productos).some(p=>tiendaProductMatchesBusqueda(p,busq));
  },[productos,busq]);
  const filtrosLateralesActivos = cat!=="Todos"||tipo!=="todos";
  const spellHints = useMemo(
    ()=>(busq.trim().length>=3&&fil.length===0?spellSuggestFromProducts(poolCatalogo,busq):[]),
    [poolCatalogo,busq,fil.length]
  );
  const disponiblesCount = useMemo(()=>fil.filter(p=>!productoAgotadoTienda(p)).length,[fil]);
  const agotadosCount = fil.length - disponiblesCount;
  const limpiarFiltrosLaterales = ()=>{
    setCat("Todos"); setTipo("todos");
  };
  const busqActiva = busq.trim().length > 0;
  return(
    <div style={{maxWidth:1200,margin:"0 auto",padding:"clamp(20px,4vw,32px) 16px",width:"100%",minHeight:"100dvh",overflowX:"hidden"}}>
      <h1 style={{color:C.dark,fontSize:"clamp(22px,5vw,28px)",fontWeight:800,marginBottom:6}}>Catálogo FarmaCapital</h1>
      <div style={{color:C.dim,fontSize:14,marginBottom:24}}>
        {busqActiva
          ? `${fil.length} resultado${fil.length === 1 ? "" : "s"}${agotadosCount > 0 ? ` · ${disponiblesCount} disponible${disponiblesCount === 1 ? "" : "s"}, ${agotadosCount} agotado${agotadosCount === 1 ? "" : "s"}` : ""} · refiná con filtros o escribí más palabras (ej. «ácido fólico»)`
          : agotadosCount > 0
            ? `${fil.length} productos · ${disponiblesCount} disponibles, ${agotadosCount} agotados`
            : `${fil.length} productos disponibles`}
      </div>
      <div style={{background:C.white,borderRadius:14,border:`1px solid ${C.border}`,padding:20,marginBottom:20}}>
        <TiendaBusquedaBar
          compact
          value={busq}
          onChange={(e)=>{
            const v = e.target.value;
            setBusq(v);
            setBusqHero?.(v);
            try {
              if (v.trim()) sessionStorage.setItem("farmacapital_busq", v);
            } catch (err) { /* ignore */ }
          }}
          onKeyDown={(e)=>{
            if (e.key === "Enter") {
              e.preventDefault();
              const q = busq.trim();
              setBusqFocus(false);
              try {
                if (q) sessionStorage.setItem("farmacapital_busq", q);
              } catch (err) { /* ignore */ }
              setBusqHero?.(busq);
              requestAnimationFrame(()=>{
                document.getElementById("farmacapital-catalogo-resultados")?.scrollIntoView({ behavior: "smooth", block: "start" });
              });
            }
            if (e.key === "Escape") setBusqFocus(false);
          }}
          onFocus={()=>setBusqFocus(true)}
          onBlur={()=>setTimeout(()=>setBusqFocus(false),280)}
          placeholder="Nombre, principio activo, marca, SKU o código…"
          suggestions={suggestions}
          productos={productos}
          onPickSuggestion={(row)=>{
            if (row){ setProdDetalle(row); setPage("detalle"); }
            setBusqFocus(false);
          }}
          setPage={setPage}
          stack={stack}
        />
        {fil.length===0&&busq.trim()&&hayCoincidenciasSinFiltrosLaterales&&filtrosLateralesActivos&&(
          <div style={{marginBottom:14,padding:"10px 12px",borderRadius:10,background:"#fef3c7",border:"1px solid #f59e0b40",fontSize:13,color:"#92400e",lineHeight:1.5}}>
            Hay resultados para tu búsqueda pero los filtros de categoría o tipo los ocultan.{" "}
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
          {[["todos","Todos"],["generico","Genérico"],["marca","Marca"]].map(([v,l])=>(
            <button key={v} onClick={()=>setTipo(v)} style={{padding:"5px 12px",borderRadius:20,border:`1px solid ${tipo===v?BRAND.primary:C.border}`,background:tipo===v?BRAND.primary+"18":"transparent",color:tipo===v?BRAND.primary:C.mid,fontSize:12,cursor:"pointer",fontWeight:600}}>{l}</button>
          ))}
        </div>
      </div>
      <div style={{
        display: "grid",
        gap: 20,
        alignItems: "start",
        gridTemplateColumns: stack ? "1fr" : "180px 1fr",
        gridTemplateAreas: stack ? '"resultados" "categorias"' : '"categorias resultados"',
        width: "100%",
      }}>
        <div
          id="farmacapital-catalogo-resultados"
          style={{
            width: "100%",
            height: "auto",
            overflow: "visible",
            position: "relative",
            display: "grid",
            gap: stack ? 16 : 18,
            /** Móvil: una columna; laptop/desktop: rejilla tipo “antes”, varias tarjetas por fila */
            gridTemplateColumns: stack
              ? "1fr"
              : "repeat(auto-fill, minmax(min(100%, 220px), 1fr))",
            alignItems: "stretch",
          }}
        >
          {loadingProductos && productos.length===0
            ? Array.from({length:8}).map((_,i)=>(
                <div key={i} style={{borderRadius:12,background:"#f0f4f9",height:260,animation:"pulse 1.4s ease-in-out infinite",opacity:0.7}}/>
              ))
            : fil.length===0
              ? <div style={{padding:40,textAlign:"center",color:C.mid,gridColumn:"1/-1"}}>{busq ? `Sin resultados para "${busq}"` : "No hay productos disponibles por el momento."}</div>
              : fil.map(p=><ProductCard key={p.id} prod={p} addToCart={addToCart} onClick={()=>{setProdDetalle(p);setPage("detalle");}}/>)
          }
        </div>
        {stack && busqActiva ? (
          <div
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
            <button
              type="button"
              onClick={() => setOpenCategorias(v => !v)}
              style={{
                width: "100%",
                cursor: "pointer",
                color: C.dark,
                fontWeight: 700,
                fontSize: 14,
                padding: "8px 4px",
                border: "none",
                background: "transparent",
                textAlign: "left",
              }}
            >
              Categorías {cat !== "Todos" ? `· ${cat}` : ""} <span style={{ color: C.dim, fontWeight: 600, fontSize: 12 }}>(tocá para filtrar)</span>
            </button>
            {openCategorias && (
              <div style={{ marginTop: 8, maxHeight: "min(50vh, 320px)", overflowY: "visible" }}>
                {cats.map((c) => (
                  <button key={c} type="button" onClick={() => setCat(c)} style={{
                    width: "100%", textAlign: "left", padding: "8px 10px", borderRadius: 8, border: "none",
                    background: cat === c ? BRAND.primary + "18" : "transparent", color: cat === c ? BRAND.primary : C.mid, fontSize: 13, fontWeight: cat === c ? 700 : 400, cursor: "pointer", marginBottom: 2,
                  }}>{c}</button>
                ))}
              </div>
            )}
          </div>
        ) : (
          <div style={{
            gridArea: "categorias",
            background: C.white,
            borderRadius: 14,
            border: `1px solid ${C.border}`,
            padding: 16,
            height: "fit-content",
            position: categoriasStickyDesktop ? "sticky" : "relative",
            top: categoriasStickyDesktop ? "calc(env(safe-area-inset-top, 0px) + 100px)" : undefined,
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
  const qtyBtnStyle = {
    width: qtyTouch,
    height: qtyTouch,
    borderRadius: 8,
    border: `1px solid ${C.border}`,
    background: C.white,
    color: C.dark,
    cursor: "pointer",
    fontSize: stack ? 22 : 18,
    fontWeight: 800,
    lineHeight: 1,
    fontFamily: "'Poppins', -apple-system, BlinkMacSystemFont, sans-serif",
    colorScheme: "light",
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    padding: 0,
    flexShrink: 0,
  };
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
                  <button type="button" aria-label="Disminuir cantidad" onClick={()=>upd(item.id,-1)} style={qtyBtnStyle}>-</button>
                  <span style={{color:C.dark,fontWeight:700,fontSize:15,minWidth:24,textAlign:"center"}}>{item.qty}</span>
                  <button type="button" aria-label="Aumentar cantidad" onClick={()=>upd(item.id,1)} style={qtyBtnStyle}>+</button>
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
          <div role="radiogroup" aria-label="Tipo de entrega">
          {[["pickup","🏪 Pick-up en FarmaCapital","Gratis · Mismo día"],["cdmx","🛵 Reparto CDMX","Rappi/Uber · Costo del servicio"]].map(([v,l,s])=>(
            <button
              key={v}
              type="button"
              role="radio"
              aria-checked={entrega===v}
              onClick={()=>setEntrega(v)}
              style={{width:"100%",textAlign:"left",padding:"12px 14px",borderRadius:10,border:`2px solid ${entrega===v?BRAND.primary:C.border}`,background:entrega===v?BRAND.primary+"18":C.white,cursor:"pointer",marginBottom:8}}
            >
              <div style={{color:entrega===v?BRAND.primary:C.dark,fontWeight:700,fontSize:14}}>{l}</div>
              <div style={{color:C.dim,fontSize:12,marginTop:2}}>{s}</div>
            </button>
          ))}
          </div>
          {entrega==="cdmx"&&(<div style={{background:"#fef3c7",border:"1px solid #f59e0b30",borderRadius:8,padding:"10px 12px",marginBottom:8}}><div style={{color:"#92400e",fontSize:12}}>🛵 El repartidor irá a FarmaCapital y entregará en tu domicilio al costo que muestre la app de Rappi o Uber.</div></div>)}
          {entrega==="cdmx"&&(
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
  const [metodo,setMetodo]=useState("mercadopago");
  const [conf,setConf]=useState(false);
  const [lastOrder,setLastOrder]=useState(null);
  const [guardando,setG]=useState(false);
  const [checkoutMsg,setCheckoutMsg]=useState(null);
  const [enviarReciboWhatsApp,setEnviarReciboWhatsApp]=useState(()=>{
    try {
      const saved = localStorage.getItem("farmacapital_whatsapp_recibo_optin");
      return saved == null ? true : saved === "1";
    } catch {
      return true;
    }
  });
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
        showToast("Tu carrito quedó vacío. Vuelve al catálogo.", "info");
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

  useEffect(() => {
    try {
      localStorage.setItem("farmacapital_whatsapp_recibo_optin", enviarReciboWhatsApp ? "1" : "0");
    } catch (_) { /* noop */ }
  }, [enviarReciboWhatsApp]);

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
  const faltantesCheckout = useMemo(() => {
    const f = [];
    if (!nombreOk) f.push("nombre completo (mín. 3 letras)");
    if (!telOk) f.push("teléfono de 10 dígitos");
    if (!emailOk) f.push("correo válido");
    if (!direccionOk && tipoEntregaRpc === "envio") f.push("dirección (calle, colonia y CP)");
    return f;
  }, [nombreOk, telOk, emailOk, direccionOk, tipoEntregaRpc]);

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
      const numericIds = productIds.filter((id) => Number.isFinite(Number(id))).map((id) => Number(id));
      const [{ data: stockRows }, { data: lotesRowsRaw }] = await Promise.all([
        supabase
          .from("productos")
          .select("id,stock,precio,activo,requiere_receta,categoria")
          .in("id", productIds),
        supabase.rpc("tienda_public_lotes_resumen_checkout", { p_producto_ids: numericIds }),
      ]);
      const lotesRows = Array.isArray(lotesRowsRaw) ? lotesRowsRaw : [];
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

      const tokCli = getClienteToken();
      const esInvitado = !tokCli;

      // Si tiene sesión, persistir datos al perfil para no reescribir en próximas compras
      if (!esInvitado) {
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
      }

      const p_cart = reconciled.map(c => ({
        producto_id: tiendaNormProductId(c.id),
        cantidad:    Number(c.qty),
      }));

      const { data: resp, error: rpcErr } = await supabase.rpc("cliente_crear_pedido_online", {
        p_session_token: esInvitado ? null : tokCli,
        p_cart,
        p_metodo_pago: metodo,
        p_tipo_entrega: tipo_entrega,
        p_direccion: tipo_entrega === "envio" ? direccionStr : null,
        p_guest_nombre: esInvitado ? String(datos.nombre || "").trim() || null : null,
        p_guest_telefono: esInvitado ? String(datos.tel || "").trim() || null : null,
        p_guest_email: esInvitado ? String(datos.email || "").trim() || null : null,
        p_reservation_session_id: null,
        p_whatsapp_recibo: Boolean(enviarReciboWhatsApp),
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
            ...(tokCli ? { Authorization: `Bearer ${tokCli}` } : {}),
          },
          body: JSON.stringify({
            pedidoId: resp.pedido_id,
            amount: subSnap,
            baseUrl,
            guest: esInvitado,
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
            whatsappRecibo: enviarReciboWhatsApp,
          });
          setConf(true);
          setCart([]);
          setG(false);
          return;
        }
        try {
          sessionStorage.setItem(`fc_wa_recibo_${resp.pedido_id}`, enviarReciboWhatsApp ? "1" : "0");
        } catch (_) { /* noop */ }
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
        metodoPago: metodo,
        whatsappRecibo: enviarReciboWhatsApp,
      });
      if (enviarReciboWhatsApp) {
        notifyOnlineOrderReceipt({
          pedidoId: resp.pedido_id,
          sessionToken: tokCli || null,
          phoneVerify: tokCli ? null : soloDigitosTel(datos.tel).slice(-4),
        }).catch((e) => console.warn("[Checkout] WhatsApp recibo:", e));
      }
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
  if(conf&&lastOrder){
    const folio = formatFolioOnline(lastOrder.pedidoId);
    const esPickup = lastOrder.tipo_entrega==="recoger";
    const reenviarReciboWhatsApp = () => {
      openWhatsAppToFarmacia(buildCustomerToFarmaciaMessage({
        pedidoId: lastOrder.pedidoId,
        total: lastOrder.sub,
        customerTel: lastOrder.datosTel,
      }));
    };
    const instruccionEntrega = esPickup
      ? `Muestra este folio en farmacia o menciona tu teléfono. Prepararemos tu pedido y te avisamos cuando esté listo.`
      : "Coordinaremos el reparto con Rappi o Uber. Te contactamos por WhatsApp para confirmar hora y dirección.";
    const iconoEntrega = esPickup ? "🏪" : "🛵";
    return(
      <div style={{maxWidth:560,margin:"clamp(32px,10vw,72px) auto",padding:"0 16px",textAlign:"center"}}>
        <div style={{fontSize:"clamp(48px,14vw,68px)",marginBottom:12}}>✅</div>
        <h1 style={{color:C.dark,fontSize:"clamp(20px,5vw,26px)",fontWeight:800,marginBottom:8,lineHeight:1.2}}>¡Pedido confirmado!</h1>
        {folio&&(
          <div style={{background:BRAND.primary,borderRadius:14,padding:"18px 24px",margin:"18px 0",display:"inline-block",minWidth:200}}>
            <div style={{color:"rgba(255,255,255,0.75)",fontSize:11,fontWeight:600,letterSpacing:2,textTransform:"uppercase",marginBottom:4}}>Tu folio</div>
            <div style={{color:"#fff",fontSize:"clamp(24px,7vw,34px)",fontWeight:900,letterSpacing:1}}>{folio}</div>
          </div>
        )}
        <div style={{background:C.white,border:`1px solid ${C.border}`,borderRadius:12,padding:"16px 20px",marginBottom:16,textAlign:"left"}}>
          <div style={{display:"flex",gap:10,alignItems:"flex-start"}}>
            <span style={{fontSize:24,flexShrink:0}}>{iconoEntrega}</span>
            <div>
              <div style={{color:C.dark,fontWeight:700,fontSize:14,marginBottom:4}}>
                {esPickup?"Pick-up en FarmaCapital":"Reparto CDMX (Rappi/Uber)"}
              </div>
              <div style={{color:C.mid,fontSize:13,lineHeight:1.5}}>{instruccionEntrega}</div>
              {esPickup && (
                <a href={CONTACTO.maps_url} target="_blank" rel="noopener noreferrer" style={{display:"inline-block",marginTop:8,color:BRAND.primary,fontWeight:700,fontSize:13,textDecoration:"none"}}>
                  📍 Cómo llegar (Google Maps) →
                </a>
              )}
            </div>
          </div>
        </div>
        {lastOrder.lines?.length>0&&(
          <div style={{background:C.white,border:`1px solid ${C.border}`,borderRadius:12,padding:"12px 16px",marginBottom:16,textAlign:"left"}}>
            {lastOrder.lines.map((i,idx)=>(
              <div key={idx} style={{display:"flex",justifyContent:"space-between",padding:"5px 0",borderBottom:idx<lastOrder.lines.length-1?`1px solid ${C.border}`:"none"}}>
                <span style={{color:C.dark,fontSize:13}}>{i.nombre} ×{i.qty}</span>
                <span style={{color:BRAND.primary,fontWeight:700,fontSize:13}}>${(Number(i.precio)*Number(i.qty)).toFixed(2)}</span>
              </div>
            ))}
            <div style={{display:"flex",justifyContent:"space-between",paddingTop:8,marginTop:4,borderTop:`1px solid ${C.border}`}}>
              <span style={{color:C.dark,fontWeight:800}}>Total pagado</span>
              <span style={{color:BRAND.primary,fontWeight:900}}>${Number(lastOrder.sub).toFixed(2)}</span>
            </div>
          </div>
        )}
        <div style={{display:"flex",gap:10,justifyContent:"center",flexWrap:"wrap",marginBottom:16}}>
          <Btn onClick={()=>setPage("home")} col={BRAND.primary}>Ir al inicio</Btn>
          {user&&<Btn onClick={()=>setPage("cuenta")} outline col={BRAND.primary}>Ver mis pedidos</Btn>}
          {lastOrder.datosTel && (
            <Btn onClick={reenviarReciboWhatsApp} outline col="#25D366">💬 Contactar por WhatsApp</Btn>
          )}
        </div>
        <div style={{background:"#f0fdf4",border:"1px solid #86efac",borderRadius:10,padding:"12px 16px",fontSize:13,color:"#166534",lineHeight:1.6}}>
          {lastOrder.whatsappRecibo !== false ? (
            <>
              📱 Enviaremos el recibo a <strong>{lastOrder.datosTel}</strong> por WhatsApp desde la farmacia ({FARMACIA_WHATSAPP_DISPLAY}).
              {" "}Si no lo recibes en unos minutos, usa el botón de arriba o escríbenos con tu folio {folio}.
            </>
          ) : (
            <>
              Tu pedido quedó registrado con folio <strong>{folio}</strong>.
              {" "}Si prefieres el recibo por WhatsApp, usa el botón de arriba para escribirnos.
            </>
          )}
        </div>
      </div>
    );
  }
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
          {step===1&&(()=>{
            const necesitaDireccion = entrega !== "pickup";
            const camposContacto = [["Nombre completo","nombre"],["Teléfono","tel"],["Correo electrónico","email"]];
            const camposDireccion = [["Calle y número","calle"],["Colonia","colonia"],["Código postal","cp"]];
            const esInvitadoUI = !getClienteToken();
            return(
              <div style={{background:C.white,borderRadius:14,border:`1px solid ${C.border}`,padding:stack?20:24}}>
                {esInvitadoUI&&(
                  <div style={{background:"#f0fdf4",border:"1px solid #86efac",borderRadius:10,padding:"10px 14px",marginBottom:18,display:"flex",alignItems:"center",gap:10}}>
                    <span style={{fontSize:18}}>👤</span>
                    <div>
                      <div style={{color:"#166534",fontWeight:700,fontSize:13}}>Comprando como invitado</div>
                      <div style={{color:"#166534",fontSize:12,marginTop:2,opacity:0.85}}>No necesitas cuenta. Solo llena tus datos y paga.</div>
                    </div>
                  </div>
                )}
                <div style={{color:C.dark,fontWeight:700,fontSize:"clamp(16px,4vw,18px)",marginBottom:18}}>📋 Datos de contacto</div>
                <div style={{display:"grid",gridTemplateColumns:stack?"1fr":"1fr 1fr",gap:14,marginBottom:14}}>
                  {camposContacto.map(([l,k])=>(
                    <div key={k} style={{gridColumn:!stack&&k==="email"?"1/-1":undefined}}>
                      <div style={{color:C.mid,fontSize:12,marginBottom:6,fontWeight:600}}>{l} <span style={{color:C.red}}>*</span></div>
                      <Inp value={datos[k]} onChange={e=>setDatos(p=>({...p,[k]:e.target.value}))} placeholder={l} style={{width:"100%",boxSizing:"border-box",fontSize:16}}/>
                    </div>
                  ))}
                </div>
                {necesitaDireccion&&(
                  <>
                    <div style={{color:C.dark,fontWeight:700,fontSize:15,margin:"4px 0 14px",paddingTop:14,borderTop:`1px solid ${C.border}`}}>
                      📍 Dirección de entrega
                    </div>
                    <div style={{display:"grid",gridTemplateColumns:stack?"1fr":"1fr 1fr",gap:14}}>
                      {camposDireccion.map(([l,k])=>(
                        <div key={k} style={{gridColumn:!stack&&k==="calle"?"1/-1":undefined}}>
                          <div style={{color:C.mid,fontSize:12,marginBottom:6,fontWeight:600}}>{l} <span style={{color:C.red}}>*</span></div>
                          <Inp value={datos[k]} onChange={e=>setDatos(p=>({...p,[k]:e.target.value}))} placeholder={l} style={{width:"100%",boxSizing:"border-box",fontSize:16}}/>
                        </div>
                      ))}
                    </div>
                    <div style={{marginTop:8,fontSize:11,color:C.textMid}}>Tu dirección se guarda localmente para tu próxima compra.</div>
                  </>
                )}
                {!necesitaDireccion&&(
                  <div style={{background:"#eff6ff",border:`1px solid ${BRAND.secondary}30`,borderRadius:8,padding:"9px 12px",fontSize:12,color:BRAND.primary,lineHeight:1.5}}>
                    🏪 <strong>Pick-up en farmacia:</strong> Al confirmar el pago recibirás un folio. Preséntalo en farmacia para recoger tu pedido.
                    <a href={CONTACTO.maps_url} target="_blank" rel="noopener noreferrer" style={{display:"block",marginTop:6,color:BRAND.primary,fontWeight:700,textDecoration:"none"}}>
                      📍 {CONTACTO.direccion} · Ver en Google Maps →
                    </a>
                  </div>
                )}
                <div style={{background:C.bg,borderRadius:10,padding:"12px 14px",marginTop:16,fontSize:12,color:C.mid,lineHeight:1.5}}>
                  <div style={{color:C.dark,fontWeight:700,marginBottom:4}}>💳 Pago con Mercado Pago</div>
                  Tarjeta, transferencia o efectivo · Checkout seguro. FarmaCapital no captura datos de tarjeta.
                </div>
                <label
                  style={{
                    display: "flex",
                    alignItems: "flex-start",
                    gap: 10,
                    marginTop: 16,
                    padding: "12px 14px",
                    borderRadius: 10,
                    border: `1px solid ${enviarReciboWhatsApp ? "#86efac" : C.border}`,
                    background: enviarReciboWhatsApp ? "#f0fdf4" : C.bg,
                    cursor: "pointer",
                    fontSize: 13,
                    lineHeight: 1.5,
                    color: C.dark,
                  }}
                >
                  <input
                    type="checkbox"
                    checked={enviarReciboWhatsApp}
                    onChange={(e) => setEnviarReciboWhatsApp(e.target.checked)}
                    style={{ marginTop: 3, accentColor: "#25D366", width: 16, height: 16, flexShrink: 0 }}
                  />
                  <span>
                    <strong style={{ color: "#166534" }}>📱 Enviar recibo por WhatsApp</strong>
                    <span style={{ display: "block", color: C.mid, fontSize: 12, marginTop: 2 }}>
                      Al número {datos.tel || "que indiques"} · Confirmación y folio de tu pedido ({FARMACIA_WHATSAPP_DISPLAY})
                    </span>
                  </span>
                </label>
                {!datosCheckoutCompletos && faltantesCheckout.length > 0 && (
                  <div style={{marginTop:12,padding:"10px 12px",background:"#fef3c7",border:"1px solid #fcd34d",borderRadius:8,fontSize:12,color:"#92400e",lineHeight:1.45}}>
                    Para continuar completa: <strong>{faltantesCheckout.join(", ")}</strong>
                  </div>
                )}
                <Btn onClick={()=>{ setMetodo("mercadopago"); setStep(2); }} col={BRAND.primary} style={{marginTop:20,width:stack?"100%":undefined}} disabled={!datosCheckoutCompletos}>
                  Revisar y pagar →
                </Btn>
              </div>
            );
          })()}
          {step===2&&(
            <div style={{background:C.white,borderRadius:14,border:`1px solid ${C.border}`,padding:stack?20:24}}>
              <div style={{color:C.dark,fontWeight:700,fontSize:"clamp(16px,4vw,18px)",marginBottom:16}}>✅ Confirmar pedido</div>
              <div style={{background:C.bg,borderRadius:10,padding:"10px 14px",marginBottom:14,fontSize:12,color:C.mid}}>
                <div><strong style={{color:C.dark}}>{datos.nombre}</strong> · {datos.tel} · {datos.email}</div>
                {entrega!=="pickup"&&datos.calle&&<div style={{marginTop:3}}>{datos.calle}, {datos.colonia}, CP {datos.cp}</div>}
                <div style={{marginTop:3}}>
                  {entrega==="pickup"?"🏪 Pick-up en FarmaCapital":"🛵 Reparto CDMX"}
                </div>
                <div style={{marginTop:6,color:BRAND.primary,fontWeight:600}}>💳 Mercado Pago (tarjeta, transferencia o efectivo)</div>
                {enviarReciboWhatsApp && (
                  <div style={{marginTop:4,color:"#166534",fontWeight:600}}>📱 Recibo por WhatsApp a {datos.tel}</div>
                )}
              </div>
              {cart.map(item=>(
                <div key={item.id} style={{display:"flex",justifyContent:"space-between",alignItems:"flex-start",gap:12,padding:"8px 0",borderBottom:`1px solid ${C.border}`}}>
                  <span style={{color:C.dark,fontSize:13,fontWeight:600,flex:1,minWidth:0,wordBreak:"break-word"}}>{item.nombre} ×{item.qty}</span>
                  <span style={{color:BRAND.primary,fontWeight:700,flexShrink:0}}>{$(item.precio*item.qty)}</span>
                </div>
              ))}
              {!cart.length&&<div style={{fontSize:12,color:C.textMid,padding:"6px 0"}}>Tu carrito está vacío.</div>}
              <div style={{display:"flex",justifyContent:"space-between",marginTop:12,paddingTop:10,borderTop:`1px solid ${C.border}`}}>
                <span style={{color:C.dark,fontWeight:800}}>Total</span>
                <span style={{color:BRAND.primary,fontWeight:900,fontSize:18}}>{$(sub)}</span>
              </div>
              <div style={{display:"flex",gap:10,marginTop:16,flexWrap:"wrap"}}>
                <Btn onClick={()=>setStep(1)} outline col={C.mid} sm>← Atrás</Btn>
                <Btn onClick={confirmar} col={BRAND.primary} disabled={guardando||!cart.length||sub<=0||!datosCheckoutCompletos} style={{flex:stack?1:undefined,minWidth:0}}>
                  {guardando?"Procesando pago...":"💳 Pagar y confirmar "+$(sub)}
                </Btn>
              </div>
            </div>
          )}
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
  const [citaId,setCitaId]=useState(null);
  const [waStatus,setWaStatus]=useState(null);
  const [guardando,setG]=useState(false);
  const [horasOcupadas,setHorasOcupadas]=useState([]);
  const [draftMsg, setDraftMsg] = useState("");
  const fechaInputRef = useRef(null);
  const horarios=horariosDisponibles(fecha);
  const horariosLibres=horarios.filter(h=>!horasOcupadas.includes(h));

  useEffect(() => {
    if (!getClienteToken()) {
      setPostLoginPage("cita");
      setPage("login");
    }
  }, [setPage]);

  useEffect(() => {
    if (user?.nombre) setNombre(user.nombre);
    if (user?.telefono) setTel(user.telefono);
  }, [user?.nombre, user?.telefono]);

  const abrirCalendarioFecha = () => {
    const el = fechaInputRef.current;
    if (!el) return;
    try {
      if (typeof el.showPicker === "function") {
        el.showPicker();
        return;
      }
    } catch (_) { /* requiere gesto del usuario en algunos navegadores */ }
    el.focus();
  };

  useEffect(()=>{
    try {
      const raw = sessionStorage.getItem("farmacapital_cita_draft");
      if (!raw) return;
      const d = JSON.parse(raw);
      if (d?.nombre) setNombre(String(d.nombre));
      if (d?.tel) setTel(String(d.tel));
      if (d?.fecha) setFecha(String(d.fecha));
      if (d?.hora) setHora(String(d.hora));
      if (d?.motivo) setMotivo(String(d.motivo));
      setDraftMsg("Estamos precargando tu cita para reagendarla. Puedes ajustar fecha/hora y confirmar.");
      sessionStorage.removeItem("farmacapital_cita_draft");
    } catch (_) { /* noop */ }
  },[]);

  // J5: Cargar horarios ya ocupados para la fecha seleccionada (RPC público mínimo)
  useEffect(()=>{
    if(!fecha){ setHorasOcupadas([]); return; }
    supabase.rpc("public_listar_horas_ocupadas_citas", { p_fecha: fecha })
      .then(({ data })=>{
        const rows = Array.isArray(data) ? data : [];
        setHorasOcupadas(rows.map((c)=> (c && typeof c === "object" && "hora" in c ? c.hora : String(c))));
      });
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
    const { data: occ } = await supabase.rpc("public_cita_horario_ocupado", { p_fecha: fecha, p_hora: hora });
    if (occ?.ocupado === true){
      alert("Lo sentimos, ese horario ya no está disponible. Por favor elige otro.");
      setHora(""); return;
    }
    setG(true);
    try{
      const tokCli = getClienteToken();
      if (!tokCli) { setPostLoginPage("cita"); setPage("login"); setG(false); return; }
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
      const newCitaId = resp.cita_id ?? resp.citaId ?? null;
      setCitaId(newCitaId);
      setG(false);
      setConf(true);
      setWaStatus("sending");
      notifyCitaConfirmacion({
        citaId: newCitaId,
        telefono: tel,
        nombre,
        fecha,
        hora,
        motivo,
        sessionToken: tokCli,
      }).then((r) => {
        if (r.sent) setWaStatus("sent");
        else if (r.notConfigured) setWaStatus("not_configured");
        else setWaStatus("failed");
      }).catch(() => setWaStatus("failed"));
      return;
    }catch(e){ alert("No se pudo agendar. Intenta de nuevo."); console.warn(e); }
    setG(false);
  };
  if (!getClienteToken()) return null;
  if(conf) return(
    <div style={{maxWidth:500,margin:"clamp(40px,12vw,80px) auto",padding:"0 16px",textAlign:"center"}}>
      <div style={{fontSize:"clamp(48px,14vw,64px)",marginBottom:16}}>📅</div>
      <h1 style={{color:C.dark,fontSize:"clamp(22px,5vw,26px)",fontWeight:800,marginBottom:16,lineHeight:1.2}}>¡Cita confirmada!</h1>
      {waStatus === "sending" && (
        <p style={{color:C.mid,marginBottom:24,fontSize:"clamp(14px,3.5vw,16px)",lineHeight:1.5}}>
          📲 Enviando confirmación a tu WhatsApp…
        </p>
      )}
      {waStatus === "sent" && (
        <p style={{color:C.mid,marginBottom:24,fontSize:"clamp(14px,3.5vw,16px)",lineHeight:1.5}}>
          ✅ Confirmación enviada a <strong style={{color:C.text}}>{formatTelefonoDisplay(tel || user?.telefono)}</strong> por WhatsApp.
          <br />
          <span style={{fontSize:14,color:C.textMid}}>Te recordaremos 24 hrs antes de tu cita.</span>
        </p>
      )}
      {(waStatus === "not_configured" || waStatus === "failed" || waStatus == null) && waStatus !== "sending" && (
        <p style={{color:C.mid,marginBottom:24,fontSize:"clamp(14px,3.5vw,16px)",lineHeight:1.5}}>
          {waStatus === "failed"
            ? "Tu cita quedó registrada, pero no pudimos enviar el WhatsApp automático."
            : "Tu cita quedó registrada. Te contactaremos por WhatsApp desde la farmacia."}
          <br />
          <span style={{fontSize:14,color:C.textMid}}>
            🗓 {formatCitaFecha(fecha) || fecha} · 🕐 {hora}
            {citaId ? ` · #CITA-${String(citaId).padStart(4, "0")}` : ""}
          </span>
        </p>
      )}
      <div style={{display:"flex",gap:12,justifyContent:"center",flexWrap:"wrap",marginBottom:16}}>
        <Btn onClick={()=>setPage("cuenta")} col={BRAND.primary}>Ver mis citas</Btn>
        <Btn onClick={()=>setPage("catalogo")} outline col={BRAND.primary}>Ver catálogo</Btn>
      </div>
      {waStatus === "failed" && (
        <Btn
          onClick={()=>{
            openWhatsAppToFarmacia(
              `Hola, acabo de agendar cita${citaId ? ` #CITA-${String(citaId).padStart(4,"0")}` : ""} ` +
              `(${fecha} ${hora}). Mi teléfono: ${tel || user?.telefono || ""}. ¿Me confirman por favor?`
            );
          }}
          col="#25D366"
          sm
        >
          💬 Escribir a la farmacia
        </Btn>
      )}
    </div>
  );
  return(
    <div style={{maxWidth:900,margin:"0 auto",padding:"clamp(24px,5vw,40px) 16px"}}>
      <div style={{textAlign:"center",marginBottom:32}}>
        <div style={{fontSize:"clamp(40px,11vw,48px)",marginBottom:12}}>🏥</div>
        <h1 style={{color:C.dark,fontSize:"clamp(22px,5vw,28px)",fontWeight:800,marginBottom:8,lineHeight:1.2}}>Consultorio FarmaCapital</h1>
        <p style={{color:C.mid,fontSize:"clamp(14px,3.5vw,15px)",lineHeight:1.5}}>Médico general · $80 por consulta (pago en farmacia el día de la cita) · O gratis con 160 puntos FarmaCapital</p>
      </div>
      <div style={{display:"grid",gridTemplateColumns:stack?"1fr":"1fr 1fr",gap:24,marginBottom:24}}>
        {/* Info doctora */}
        <div style={{background:C.white,borderRadius:16,border:`1px solid ${C.border}`,padding:24}}>
          <div style={{display:"flex",alignItems:"center",gap:16,marginBottom:16}}>
            <div style={{width:56,height:56,borderRadius:"50%",background:BRAND.gradient,display:"flex",alignItems:"center",justifyContent:"center",fontSize:28}}>👩‍⚕️</div>
            <div><div style={{color:C.dark,fontWeight:800,fontSize:16}}>Médico general en turno</div><div style={{color:C.mid,fontSize:13,marginTop:2}}>Consultorio adyacente a FarmaCapital</div></div>
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
            <div style={{color:"#92400e",fontSize:12}}>💊 Surte tu receta en FarmaCapital con <strong>10% de descuento especial</strong> tras tu consulta.</div>
          </div>
        </div>
        {/* Mapa */}
        <div style={{background:C.white,borderRadius:16,border:`1px solid ${C.border}`,overflow:"hidden"}}>
          <div style={{padding:"16px 20px",borderBottom:`1px solid ${C.border}`}}>
            <div style={{color:C.dark,fontWeight:700,fontSize:14}}>📍 Cómo llegar</div>
            <div style={{color:C.mid,fontSize:12,marginTop:4}}>{CONTACTO.direccion}</div>
          </div>
          <iframe
            title="Ubicación FarmaCapital"
            src={CONTACTO.maps_embed}
            width="100%" height="280" style={{border:"none",display:"block"}}
            allowFullScreen loading="lazy"/>
          <div style={{padding:"12px 16px"}}>
            <a href={CONTACTO.maps_url} target="_blank" rel="noopener noreferrer"
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
          <div>
            <div style={{color:C.mid,fontSize:12,fontWeight:700,marginBottom:6}}>Fecha</div>
            <div style={{position:"relative"}}>
              <input
                ref={fechaInputRef}
                className="farmacapital-field-input"
                type="date"
                lang="es-MX"
                value={fecha}
                onChange={e=>setFecha(e.target.value)}
                onClick={abrirCalendarioFecha}
                min={localISODate()}
                aria-label="Fecha de la cita"
                style={tiendaFieldStyle({
                  padding:"9px 44px 9px 13px",
                  cursor:"pointer",
                  WebkitAppearance:"none",
                  appearance:"none",
                })}
              />
              <button
                type="button"
                onClick={abrirCalendarioFecha}
                aria-label="Abrir calendario"
                style={{
                  position:"absolute",
                  right:4,
                  top:"50%",
                  transform:"translateY(-50%)",
                  display:"flex",
                  alignItems:"center",
                  justifyContent:"center",
                  width:36,
                  height:36,
                  border:"none",
                  borderRadius:8,
                  background:"transparent",
                  color:BRAND.secondary,
                  cursor:"pointer",
                }}
              >
                <Calendar size={18} strokeWidth={2.25} aria-hidden="true"/>
              </button>
            </div>
          </div>
          <div>
            <div style={{color:C.mid,fontSize:12,fontWeight:700,marginBottom:6}}>Horario {fecha&&horarios.length===0?"— Sin disponibilidad hoy":""}</div>
            <select
              className="farmacapital-field-input farmacapital-field-select"
              value={hora}
              onChange={e=>setHora(e.target.value)}
              style={tiendaFieldStyle({
                color:hora?C.text:C.dim,
                WebkitAppearance:"none",
                appearance:"none",
                cursor:"pointer",
              })}
            >
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
        <h1 style={{color:C.dark,fontSize:"clamp(24px,5.5vw,30px)",fontWeight:800,marginBottom:8,lineHeight:1.2}}>Promociones vigentes</h1>
        <p style={{color:C.mid,fontSize:"clamp(14px,3.5vw,15px)",lineHeight:1.6,maxWidth:640}}>
          Ofertas y campañas activas en FarmaCapital. Los banners del inicio pueden enlazar aquí: en administración, en el campo <strong>Página destino</strong> escribe <code style={{background:C.cardDark,padding:"2px 6px",borderRadius:4}}>promo</code>.
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
        <p style={{color:C.mid,fontSize:"clamp(14px,3.5vw,15px)",lineHeight:1.5}}>Todo lo que necesitas saber sobre FarmaCapital</p>
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
          <a href="mailto:contacto@farmacapital.mx" style={{color:BRAND.primary,fontWeight:700,fontSize:14,textDecoration:"none"}}>📧 contacto@farmacapital.mx</a>
          <a href={CONTACTO.whatsapp_link} target="_blank" rel="noopener noreferrer" style={{color:"#25D366",fontWeight:700,fontSize:14,textDecoration:"none"}}>💬 WhatsApp {CONTACTO.whatsapp_display}</a>
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
      <div style={{color:C.dim,fontSize:"clamp(12px,3vw,13px)",marginBottom:24,lineHeight:1.5}}>Última actualización: Abril 2026 · FarmaCapital · Iztapalapa, CDMX</div>
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
      <p style={{color:C.dark,fontWeight:700,marginBottom:16}}>De conformidad con la Ley Federal de Protección de Datos Personales en Posesión de los Particulares (LFPDPPP) y su Reglamento, FarmaCapital pone a su disposición el presente Aviso de Privacidad.</p>
      {[
        ["1. Responsable del tratamiento de sus datos","Luis Angel Palillero Ventura (RFC PAVL911030NC8), operando bajo el nombre comercial FarmaCapital, con domicilio en Radiodifusora 100, Chinampac de Juárez, Iztapalapa, Ciudad de México, C.P. 09208, es responsable del uso y protección de sus datos personales."],
        ["2. Datos personales que recabamos","Recabamos los siguientes datos personales: nombre completo, número de teléfono, correo electrónico, domicilio de entrega, e historial de compras y citas médicas. No recabamos datos sensibles salvo los necesarios para la atención médica en nuestro consultorio, los cuales se tratan con el máximo nivel de confidencialidad."],
        ["3. Finalidades del tratamiento","Sus datos se utilizan para: procesar sus pedidos y entregas, gestionar su cuenta y programa de puntos FarmaCapital, agendar y dar seguimiento a consultas médicas, enviarle comunicaciones relacionadas con sus pedidos, y cumplir con obligaciones legales ante COFEPRIS."],
        ["4. Transferencia de datos","Sus datos no serán transferidos a terceros sin su consentimiento, salvo en los casos previstos por la ley o cuando sea necesario para el cumplimiento del servicio contratado (ej. empresas de mensajería)."],
        ["5. Derechos ARCO","Usted tiene derecho a Acceder, Rectificar, Cancelar u Oponerse al tratamiento de sus datos (derechos ARCO). Para ejercerlos, envíe un correo a contacto@farmacapital.mx indicando su nombre, el derecho que desea ejercer y los datos a los que se refiere. Responderemos en un plazo máximo de 20 días hábiles."],
        ["6. Cambios al aviso de privacidad","FarmaCapital se reserva el derecho de modificar el presente aviso. Cualquier cambio será notificado a través de nuestro sitio web farmacapital.com.mx."],
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
        ["1. Aceptación","Al utilizar la plataforma de FarmaCapital, el usuario acepta los presentes Términos y Condiciones. Si no está de acuerdo, le pedimos que no utilice nuestros servicios."],
        ["2. Productos y precios","Los precios mostrados en la plataforma incluyen IVA y están sujetos a disponibilidad. FarmaCapital se reserva el derecho de modificar precios sin previo aviso, respetando siempre el precio vigente al momento de confirmar el pedido."],
        ["3. Disponibilidad de productos","Indicamos claramente si un producto está disponible de forma inmediata o en 24-48 horas. En caso de no poder surtir un pedido, notificaremos al cliente y realizaremos el reembolso correspondiente en un plazo no mayor a 5 días hábiles."],
        ["4. Medicamentos con receta","Los medicamentos que requieren receta médica serán entregados únicamente al presentar la receta original vigente. FarmaCapital se reserva el derecho de cancelar pedidos de medicamentos controlados que no cumplan con los requisitos de COFEPRIS."],
        ["5. Responsabilidad","FarmaCapital no se hace responsable del uso incorrecto de los medicamentos. Se recomienda siempre consultar a un profesional de la salud. La información en nuestra plataforma es de carácter informativo y no sustituye la opinión médica."],
        ["6. Propiedad intelectual","El contenido de la plataforma de FarmaCapital, incluyendo textos, imágenes y logotipos, es propiedad de FarmaCapital y está protegido por las leyes de propiedad intelectual vigentes en México."],
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
        ["Tipos de entrega disponibles","• Pick-up en FarmaCapital: Gratis. Disponible el mismo día. Te avisamos cuando tu pedido esté listo.\n• Reparto express CDMX: Mediante Rappi o Uber Connect. El costo es el que muestre la aplicación al momento del servicio."],
        ["Política de devoluciones","Aceptamos devoluciones dentro de las 72 horas siguientes a la entrega, siempre que el producto esté en perfecto estado, sin abrir y con su empaque original. No se aceptan devoluciones de: medicamentos controlados, productos refrigerados, ni artículos de uso personal."],
        ["Proceso de devolución","Para iniciar una devolución, contáctanos a contacto@farmacapital.mx dentro del plazo indicado. Una vez aprobada la devolución, el reembolso se realizará en un plazo máximo de 5 días hábiles al mismo método de pago utilizado."],
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
    <PaginaLegal titulo="⭐ Términos del Programa Puntos FarmaCapital" setPage={setPage}>
      {[
        ["¿Qué son los Puntos FarmaCapital?","Los Puntos FarmaCapital son un beneficio exclusivo para clientes registrados en la plataforma de FarmaCapital. No tienen valor monetario en efectivo y solo pueden canjearse bajo los términos aquí descritos."],
        ["Acumulación de puntos","Se otorga 1 punto por cada $10 de compra en precio normal (no aplica en productos con descuento previo). Las consultas médicas otorgan 5 puntos. El registro nuevo otorga 10 puntos de bienvenida. Las compras en línea otorgan 1.5× puntos. En el mes de cumpleaños se otorga 2× puntos."],
        ["Canje de puntos","20 puntos = $10 de descuento en FarmaCapital. 50 puntos = envío gratis en compra en línea. 100 puntos = $50 de descuento. 160 puntos = consulta médica gratis. 200 puntos = producto gratis (sujeto a catálogo disponible). 1 punto equivale a $0.50 de valor de descuento."],
        ["Vigencia","Los puntos vencen a los 12 meses de inactividad en la cuenta. FarmaCapital se reserva el derecho de modificar las condiciones del programa con previo aviso de 30 días."],
        ["Restricciones","Los puntos no son transferibles entre cuentas, no se pueden convertir en efectivo, y no aplican en combinación con otras promociones salvo indicación expresa. FarmaCapital se reserva el derecho de cancelar cuentas o puntos obtenidos de forma fraudulenta."],
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
    if(pwd.length < PASSWORD_MIN_LENGTH) { setError(`La contraseña debe tener al menos ${PASSWORD_MIN_LENGTH} caracteres.`); return; }
    const valPwd = validarPasswordTienda(pwd);
    if (!valPwd.ok) { setError(valPwd.error); return; }
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
      setClienteSession(resp.session_token, nuevo);
      setUser(nuevo);
      setPage(consumePostLoginPage() || "cuenta");
    }catch(e){setError("Error al crear cuenta. Intenta de nuevo.");}
    setC(false);
  };
  return(
    <div style={{maxWidth:440,margin:"80px auto",padding:"0 24px"}}>
      <div style={{background:C.white,borderRadius:20,border:`1px solid ${C.border}`,padding:40}}>
        <div style={{display:"flex",justifyContent:"center",marginBottom:20}}><Logo size={40}/></div>
        <h1 style={{color:C.dark,fontSize:24,fontWeight:800,marginBottom:6,textAlign:"center"}}>Crear cuenta FarmaCapital</h1>
        {getPostLoginPage() === "cita" ? (
          <p style={{color:C.textMid,fontSize:14,marginBottom:20,textAlign:"center",lineHeight:1.5}}>
            Creá tu cuenta para <strong style={{color:BRAND.primary}}>agendar tu cita médica</strong>.
          </p>
        ) : (
          <p style={{color:C.mid,fontSize:14,marginBottom:28,textAlign:"center"}}>Regístrate y gana <strong style={{color:BRAND.accent}}>10 puntos de bienvenida ⭐</strong></p>
        )}
        <p style={{color:C.textMid,fontSize:12,marginBottom:20,textAlign:"center",lineHeight:1.5}}>Usá <strong style={{color:C.text}}>correo</strong>, <strong style={{color:C.text}}>teléfono</strong> o <strong style={{color:C.text}}>ambos</strong> para tu cuenta (necesitamos al menos uno).</p>
        <form className="farmacapital-login-form" autoComplete="on" onSubmit={(e)=>{ e.preventDefault(); registrar(); }}>
        <div style={{marginBottom:14}}><div style={{color:C.mid,fontSize:12,fontWeight:700,marginBottom:6}}>Nombre completo <span style={{color:C.red}}>*</span></div><Inp name="name" autoComplete="name" value={nombre} onChange={e=>setNombre(e.target.value)} placeholder="Tu nombre"/></div>
        <div style={{marginBottom:14}}><div style={{color:C.mid,fontSize:12,fontWeight:700,marginBottom:6}}>Teléfono {correoTiendaValido(email)?"(opcional)":"(o completá correo abajo)"}</div><Inp name="tel" autoComplete="tel" value={tel} onChange={e=>setTel(e.target.value)} placeholder="55XXXXXXXX — 10 dígitos" type="tel"/></div>
        <div style={{marginBottom:14}}><div style={{color:C.mid,fontSize:12,fontWeight:700,marginBottom:6}}>Correo electrónico {telefonoMxValido(tel)?"(opcional)":"(o completá teléfono arriba)"}</div><Inp name="email" autoComplete="email" value={email} onChange={e=>setEmail(e.target.value)} placeholder="tu@correo.com" type="email"/></div>
        <div style={{marginBottom:14}}>
          <div style={{color:C.mid,fontSize:12,fontWeight:700,marginBottom:6}}>Contraseña <span style={{color:C.red}}>*</span> <span style={{color:C.dim,fontWeight:400}}>({PASSWORD_RULES_TEXT})</span></div>
          <Inp name="password" autoComplete="new-password" value={pwd} onChange={e=>setPwd(e.target.value)} placeholder="••••••••" type="password" invalid={pwd.length>0&&!validarPasswordTienda(pwd).ok}/>
          {pwd.length>0&&!validarPasswordTienda(pwd).ok&&<div style={{color:C.red,fontSize:11,marginTop:4}}>{validarPasswordTienda(pwd).error}</div>}
        </div>
        <div style={{marginBottom:20}}>
          <div style={{color:C.mid,fontSize:12,fontWeight:700,marginBottom:6}}>Confirmar contraseña <span style={{color:C.red}}>*</span></div>
          <Inp name="password-confirm" autoComplete="new-password" value={pwd2} onChange={e=>setPwd2(e.target.value)} placeholder="••••••••" type="password" invalid={pwd2.length>0&&pwd!==pwd2}/>
          {pwd2.length>0&&pwd!==pwd2&&<div style={{color:C.red,fontSize:11,marginTop:4}}>Las contraseñas no coinciden</div>}
        </div>
        {error&&<div style={{background:C.redDim,border:`1px solid ${C.red}30`,borderRadius:8,padding:"10px 12px",marginBottom:14,color:C.red,fontSize:13}}>{error}</div>}
        <div style={{display:"flex",alignItems:"flex-start",gap:10,marginBottom:16,padding:"12px 14px",background:C.blueDim,borderRadius:10,border:`1px solid ${C.borderHi}`}}>
          <input type="checkbox" id="acepto_privacidad" checked={acepto} onChange={e=>setAcepto(e.target.checked)}
            style={{width:16,height:16,marginTop:2,cursor:"pointer",flexShrink:0,accentColor:BRAND.primary}}/>
          <label htmlFor="acepto_privacidad" style={{color:C.textMid,fontSize:12,lineHeight:1.5,cursor:"pointer"}}>
            He leído y acepto el{" "}
            <button type="button" onClick={()=>setPage("privacidad")} style={{background:"none",border:"none",color:BRAND.primary,fontWeight:700,fontSize:12,cursor:"pointer",padding:0,textDecoration:"underline"}}>
              Aviso de Privacidad
            </button>
            {" "}de FarmaCapital. Autorizo el uso de mis datos para gestionar mi cuenta y programa de puntos. <span style={{color:C.red,fontWeight:700}}>*</span>
          </label>
        </div>
        <Btn type="submit" col={BRAND.primary} full disabled={!nombre||!contactoOk||!pwd||!pwd2||pwd!==pwd2||!validarPasswordTienda(pwd).ok||creando||!acepto}>{creando?"Creando cuenta...":"Crear mi cuenta →"}</Btn>
        </form>
        <div style={{textAlign:"center",marginTop:16}}><span style={{color:C.mid,fontSize:13}}>¿Ya tienes cuenta? </span><button onClick={()=>setPage("login")} style={{background:"none",border:"none",color:BRAND.primary,fontWeight:700,fontSize:13,cursor:"pointer"}}>Iniciar sesión</button></div>
      </div>
    </div>
  );
}

// ── RESTABLECER CONTRASEÑA (enlace WhatsApp) ─────────────────
function RestablecerPassword({ token, setPage }) {
  const C = useTheme();
  const [validando, setValidando] = useState(true);
  const [valido, setValido] = useState(false);
  const [nombre, setNombre] = useState("");
  const [errorToken, setErrorToken] = useState("");
  const [pwd, setPwd] = useState("");
  const [pwd2, setPwd2] = useState("");
  const [msg, setMsg] = useState(null);
  const [guardando, setGuardando] = useState(false);

  useEffect(() => {
    let cancelled = false;
    (async () => {
      setValidando(true);
      setErrorToken("");
      try {
        const { data, error } = await supabase.rpc("cliente_validar_reset_token", {
          p_token: token,
        });
        if (cancelled) return;
        if (error || !data?.valid) {
          setValido(false);
          setErrorToken(data?.error || error?.message || "Enlace no válido o expirado.");
          return;
        }
        setValido(true);
        setNombre(String(data.nombre || "Cliente"));
      } catch (e) {
        if (!cancelled) setErrorToken("No se pudo validar el enlace. Intenta solicitar uno nuevo.");
      } finally {
        if (!cancelled) setValidando(false);
      }
    })();
    return () => { cancelled = true; };
  }, [token]);

  const guardar = async () => {
    const val = validarPasswordTienda(pwd);
    if (!val.ok) { setMsg({ ok: false, txt: val.error }); return; }
    if (pwd !== pwd2) { setMsg({ ok: false, txt: "Las contraseñas no coinciden." }); return; }
    setGuardando(true);
    setMsg(null);
    try {
      const { data, error } = await supabase.rpc("cliente_completar_reset_password", {
        p_token: token,
        p_password: pwd,
        p_confirm: pwd2,
      });
      if (error || !data?.success) {
        setMsg({ ok: false, txt: data?.error || error?.message || "No se pudo guardar la contraseña." });
        setGuardando(false);
        return;
      }
      setMsg({ ok: true, txt: "✅ Contraseña actualizada. Ya puedes iniciar sesión." });
      setTimeout(() => {
        try {
          const u = new URL(window.location.href);
          u.searchParams.delete("reset");
          window.history.replaceState({ page: "login" }, "", u.pathname + (u.search || ""));
        } catch (_) { /* noop */ }
        setPage("login");
      }, 1200);
    } catch (e) {
      setMsg({ ok: false, txt: "Error de conexión. Intenta de nuevo." });
    }
    setGuardando(false);
  };

  const inp = tiendaFieldStyle();

  return (
    <div style={{ maxWidth: 440, margin: "80px auto", padding: "0 24px" }}>
      <div style={{ background: C.white, borderRadius: 20, border: `1px solid ${C.border}`, padding: 40 }}>
        <div style={{ display: "flex", justifyContent: "center", marginBottom: 20 }}><Logo size={40}/></div>
        <h1 style={{ color: C.dark, fontSize: 24, fontWeight: 800, marginBottom: 8, textAlign: "center" }}>Nueva contraseña</h1>
        {validando ? (
          <p style={{ color: C.mid, textAlign: "center" }}>Validando enlace…</p>
        ) : !valido ? (
          <>
            <p style={{ color: C.red, fontSize: 14, textAlign: "center", lineHeight: 1.5, marginBottom: 20 }}>{errorToken}</p>
            <Btn onClick={() => setPage("login")} col={BRAND.primary} full>Ir a iniciar sesión</Btn>
          </>
        ) : (
          <>
            <p style={{ color: C.mid, fontSize: 14, marginBottom: 20, textAlign: "center", lineHeight: 1.5 }}>
              Hola{ nombre ? ` ${nombre}` : "" }, crea tu nueva contraseña para la tienda FarmaCapital.
            </p>
            <p style={{ color: C.textMid, fontSize: 12, marginBottom: 16, textAlign: "center" }}>{PASSWORD_RULES_TEXT}</p>
            <div style={{ marginBottom: 14 }}>
              <div style={{ color: C.mid, fontSize: 12, fontWeight: 700, marginBottom: 6 }}>Nueva contraseña *</div>
              <input type="password" className="farmacapital-field-input" value={pwd} onChange={(e) => setPwd(e.target.value)} autoComplete="new-password" style={inp}/>
            </div>
            <div style={{ marginBottom: 16 }}>
              <div style={{ color: C.mid, fontSize: 12, fontWeight: 700, marginBottom: 6 }}>Confirmar contraseña *</div>
              <input type="password" className="farmacapital-field-input" value={pwd2} onChange={(e) => setPwd2(e.target.value)} autoComplete="new-password" style={inp}/>
            </div>
            {msg && (
              <div style={{
                background: msg.ok ? "#ecfdf5" : C.red + "10",
                border: `1px solid ${msg.ok ? "#6ee7b7" : C.red + "30"}`,
                borderRadius: 8, padding: "10px 12px", marginBottom: 12,
                color: msg.ok ? "#047857" : C.red, fontSize: 13,
              }}>{msg.txt}</div>
            )}
            <Btn onClick={guardar} col={BRAND.primary} full disabled={guardando || !pwd || !pwd2}>{guardando ? "Guardando…" : "Guardar contraseña"}</Btn>
          </>
        )}
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
      setClienteSession(resp.session_token, cliente);
      setUser(cliente);
      setPage(consumePostLoginPage() || "cuenta");
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
    const identNorm = correoTiendaValido(raw) ? raw.toLowerCase() : (telefonoMxValido(raw) ? soloDigitosTel(raw) : "");
    if (!identNorm) {
      setRecMsg({ ok: false, txt: "Escribí un correo válido o un teléfono con al menos 10 dígitos." });
      return;
    }
    setRecBusy(true);
    setRecMsg(null);
    try {
      const resp = await fetch("/api/auth/password-reset-request", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ identificador: identNorm }),
      });
      const data = await resp.json().catch(() => ({}));
      if (!resp.ok || !data?.ok) throw new Error(data?.error || "request_failed");
      setRecMsg({
        ok: true,
        txt: data.message ||
          "Si tu correo o teléfono está registrado, recibirás un enlace por WhatsApp en unos minutos para crear tu nueva contraseña.",
      });
    } catch (_) {
      setRecMsg({ ok: false, txt: "No se pudo enviar la solicitud. Intentá de nuevo o escribinos a contacto@farmacapital.mx." });
    }
    setRecBusy(false);
  };

  return(
    <div style={{maxWidth:420,margin:"80px auto",padding:"0 24px"}}>
      <div style={{background:C.white,borderRadius:20,border:`1px solid ${C.border}`,padding:40}}>
        <div style={{display:"flex",justifyContent:"center",marginBottom:20}}><Logo size={40}/></div>
        <h1 style={{color:C.dark,fontSize:24,fontWeight:800,marginBottom:6,textAlign:"center"}}>Iniciar sesión</h1>
        {getPostLoginPage() === "cita" ? (
          <p style={{color:C.textMid,fontSize:14,marginBottom:28,textAlign:"center",lineHeight:1.5}}>
            Ingresá con tu correo o teléfono para <strong style={{color:BRAND.primary}}>agendar tu cita</strong>.
          </p>
        ) : (
          <p style={{color:C.mid,fontSize:14,marginBottom:28,textAlign:"center"}}>Accede a tus puntos, pedidos e historial</p>
        )}

        {recMode ? (
          <>
            <p style={{color:C.textMid,fontSize:13,marginBottom:16,lineHeight:1.5}}>
              Indicá el <strong>mismo correo o teléfono</strong> de tu cuenta FarmaCapital (incluido el celular que diste en mostrador).
              Si está registrado, te enviaremos un <strong>enlace por WhatsApp</strong> para crear tu nueva contraseña.
            </p>
            <div style={{marginBottom:12}}>
              <div style={{color:C.mid,fontSize:12,fontWeight:700,marginBottom:6}}>Correo o teléfono</div>
              <input className="farmacapital-field-input" value={recIdent} onChange={e=>setRecIdent(e.target.value)}
                onKeyDown={e=>e.key==="Enter"&&enviarRecuperar()} placeholder="tu@correo.com o 55XXXXXXXX" type="text"
                style={tiendaFieldStyle()}/>
            </div>
            {recMsg && (
              <div style={{
                background: recMsg.ok ? "#ecfdf5" : C.red+"10",
                border: `1px solid ${recMsg.ok ? "#6ee7b7" : C.red+"30"}`,
                borderRadius: 8, padding: "10px 12px", marginBottom: 12,
                color: recMsg.ok ? "#047857" : C.red, fontSize: 13, lineHeight: 1.45,
              }}>{recMsg.txt}</div>
            )}
            <Btn onClick={enviarRecuperar} col={BRAND.primary} full disabled={recBusy || !recIdent.trim()}>{recBusy ? "Enviando…" : "Enviar enlace de recuperación"}</Btn>
            <div style={{textAlign:"center",marginTop:14}}>
              <button type="button" onClick={()=>{ setRecMode(false); setRecMsg(null); }} style={{background:"none",border:"none",color:C.mid,fontSize:13,cursor:"pointer",textDecoration:"underline"}}>Volver al inicio de sesión</button>
            </div>
          </>
        ) : (
          <form className="farmacapital-login-form" autoComplete="on" onSubmit={(e)=>{ e.preventDefault(); entrar(); }}>
        <div style={{marginBottom:12}}>
          <div style={{color:C.mid,fontSize:12,fontWeight:700,marginBottom:6}}>Correo o teléfono</div>
          <input className="farmacapital-field-input" name="username" autoComplete="username email" value={ident} onChange={e=>setIdent(e.target.value)}
            placeholder="tu@correo.com o 55XXXXXXXX" type="text"
            style={tiendaFieldStyle()}/>
        </div>
        <div style={{marginBottom:20}}>
          <div style={{color:C.mid,fontSize:12,fontWeight:700,marginBottom:6}}>Contraseña</div>
          <input className="farmacapital-field-input" name="password" autoComplete="current-password" value={pwd} onChange={e=>setPwd(e.target.value)}
            placeholder="••••••••" type="password"
            style={tiendaFieldStyle()}/>
        </div>
        {error&&(
          <div style={{background:C.red+"10",border:`1px solid ${C.red}30`,borderRadius:8,padding:"10px 12px",marginBottom:12,color:C.red,fontSize:13,lineHeight:1.45}}>
            <div>{error}</div>
            {error.includes("necesita una contraseña") && (
              <div style={{marginTop:10}}>
                <p style={{margin:"0 0 8px",color:C.textMid,fontSize:12}}>
                  Tu correo ya está registrado en FarmaCapital (por ejemplo desde mostrador), pero aún no tiene clave para la tienda web.
                </p>
                <button type="button" onClick={()=>{ setRecMode(true); setRecIdent(ident.trim()); setRecMsg(null); setError(""); }}
                  style={{background:"none",border:"none",color:BRAND.primary,fontWeight:700,fontSize:13,cursor:"pointer",textDecoration:"underline",padding:0}}>
                  Crear mi contraseña por WhatsApp →
                </button>
              </div>
            )}
            {!error.includes("necesita una contraseña") && (
              <button type="button" onClick={()=>setPage("registro")} style={{background:"none",border:"none",color:BRAND.primary,fontWeight:700,fontSize:13,cursor:"pointer",textDecoration:"underline",marginTop:6,padding:0}}>Crear cuenta</button>
            )}
          </div>
        )}
        <Btn type="submit" col={BRAND.primary} full disabled={!ident.trim()||!pwd||buscando}>{buscando?"Buscando...":"Entrar →"}</Btn>
        <div style={{textAlign:"center",marginTop:14}}>
          <button type="button" onClick={abrirRecuperar} style={{background:"none",border:"none",color:BRAND.primary,fontWeight:700,fontSize:13,cursor:"pointer",textDecoration:"underline"}}>¿Olvidaste tu contraseña o no tenés clave para la tienda?</button>
        </div>
        <div style={{textAlign:"center",marginTop:16}}><span style={{color:C.mid,fontSize:13}}>¿No tienes cuenta? </span><button type="button" onClick={()=>setPage("registro")} style={{background:"none",border:"none",color:BRAND.primary,fontWeight:700,fontSize:13,cursor:"pointer"}}>Regístrate aquí</button></div>
          </form>
        )}
      </div>
    </div>
  );
}

// ── BOTÓN FLOTANTE WHATSAPP ────────────────────────────────────
const WHATSAPP_FLOAT_MSG = "Hola FarmaCapital, tengo una consulta sobre ";

function WhatsAppFloatingButton() {
  const abrir = () => {
    openWhatsAppToFarmacia(WHATSAPP_FLOAT_MSG);
  };

  return (
    <button
      type="button"
      onClick={abrir}
      aria-label={`Escribir por WhatsApp a FarmaCapital (${CONTACTO.whatsapp_display})`}
      title={`WhatsApp ${CONTACTO.whatsapp_display}`}
      style={{
        position: "fixed",
        right: "max(16px, env(safe-area-inset-right, 0px))",
        bottom: "max(20px, env(safe-area-inset-bottom, 0px))",
        zIndex: 950,
        width: 56,
        height: 56,
        borderRadius: "50%",
        border: "none",
        cursor: "pointer",
        background: "#25D366",
        color: "#fff",
        boxShadow: "0 4px 20px rgba(37, 211, 102, 0.45)",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        transition: "transform 0.2s ease, box-shadow 0.2s ease",
      }}
      onMouseEnter={(e) => {
        e.currentTarget.style.transform = "scale(1.06)";
        e.currentTarget.style.boxShadow = "0 6px 24px rgba(37, 211, 102, 0.55)";
      }}
      onMouseLeave={(e) => {
        e.currentTarget.style.transform = "scale(1)";
        e.currentTarget.style.boxShadow = "0 4px 20px rgba(37, 211, 102, 0.45)";
      }}
    >
      <svg width="28" height="28" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
        <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.435 9.884-9.884 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/>
      </svg>
    </button>
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
    const val = validarPasswordTienda(pwdN);
    if (!val.ok) { setMsg({ok:false,txt:val.error}); return; }
    if(pwdN!==pwdN2) { setMsg({ok:false,txt:"Las contraseñas no coinciden"}); return; }
    setCarg(true); setMsg(null);
    try {
      const tok = getClienteToken();
      if (!tok) { setMsg({ok:false,txt:"Sesión expirada. Inicia sesión de nuevo."}); setCarg(false); return; }
      const { data:resp, error:err } = await supabase.rpc("cliente_cambiar_password", {
        p_session_token: tok,
        p_actual: pwdA,
        p_nueva: pwdN,
      });
      if (err) throw err;
      if (!resp?.success) { setMsg({ok:false,txt:resp?.error || "No se pudo cambiar"}); setCarg(false); return; }
      setMsg({ok:true,txt:"✅ Contraseña cambiada correctamente"});
      setPwdA(""); setPwdN(""); setPwdN2("");
    } catch(e) { setMsg({ok:false,txt:"Error: "+e.message}); }
    setCarg(false);
  };

  const inpS = tiendaFieldStyle({ marginBottom: 8 });

  return(
    <div>
      <input type="password" className="farmacapital-field-input" placeholder="Contraseña actual" value={pwdA} onChange={e=>setPwdA(e.target.value)} style={inpS} autoComplete="current-password"/>
      <input type="password" className="farmacapital-field-input" placeholder={`Nueva contraseña (${PASSWORD_RULES_TEXT})`} value={pwdN} onChange={e=>setPwdN(e.target.value)} style={inpS} autoComplete="new-password"/>
      <input type="password" className="farmacapital-field-input" placeholder="Confirmar nueva contraseña" value={pwdN2} onChange={e=>setPwdN2(e.target.value)} style={{...inpS,marginBottom:10}} autoComplete="new-password"/>
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
    const tokCli = getClienteToken();
    if (!tokCli) { setPeds([]); setCitas([]); setC(false); return; }
    Promise.all([
      supabase.rpc("cliente_listar_mis_pedidos", { p_session_token: tokCli, p_limite: 150 }),
      supabase.rpc("cliente_listar_mis_citas", { p_session_token: tokCli }),
    ]).then(([pRes, cRes])=>{
      setPeds(Array.isArray(pRes.data) ? pRes.data : []);
      setCitas(Array.isArray(cRes.data) ? cRes.data : []);
      setC(false);
    });
  },[user]);
  const refreshCitas = async ()=>{
    if(!user?.id) return;
    const tokCli = getClienteToken();
    if (!tokCli) return;
    const { data } = await supabase.rpc("cliente_listar_mis_citas", { p_session_token: tokCli });
    setCitas(Array.isArray(data) ? data : []);
  };
  const cancelarCita = async (cita)=>{
    const tok = getClienteToken();
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
      sessionStorage.setItem("farmacapital_cita_draft", JSON.stringify({
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
    const tokCli = getClienteToken();
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
        <div style={{textAlign:"center"}}><div style={{color:"#ffaa00",fontWeight:900,fontSize:36}}>{user.puntos||0}</div><div style={{color:"rgba(255,255,255,.8)",fontSize:13}}>puntos FarmaCapital</div><div style={{color:"rgba(255,255,255,.6)",fontSize:11}}>= ${((user.puntos||0)*0.5).toFixed(0)} en descuentos</div></div>
      </div>
      <div style={{display:"flex",gap:6,marginBottom:20,background:C.white,borderRadius:12,padding:6,border:`1px solid ${C.border}`}}>
        {[["pedidos","📦 Mis pedidos"],["citas","📅 Mis citas"],["canjear","⭐ Canjear"],["datos","👤 Mis datos"]].map(([v,l])=>(
          <button key={v} onClick={()=>setTab(v)} style={{flex:1,padding:"10px",borderRadius:8,border:"none",background:tab===v?BRAND.primary:"transparent",color:tab===v?C.white:C.mid,fontWeight:tab===v?700:500,cursor:"pointer",fontSize:13,transition:"all .15s"}}>{l}</button>
        ))}
      </div>
      {tab==="pedidos"&&(cargando?<div style={{textAlign:"center",padding:40,color:C.mid}}>Cargando pedidos...</div>:!pedidos.length?(
        <div style={{background:C.white,borderRadius:14,border:`1px solid ${C.border}`,padding:40,textAlign:"center"}}><div style={{fontSize:40,marginBottom:12}}>📦</div><div style={{color:C.mid,fontSize:15}}>Aún no tienes pedidos en FarmaCapital</div><Btn onClick={()=>setPage("catalogo")} col={BRAND.primary} sm style={{marginTop:16}}>Hacer mi primer pedido</Btn></div>
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
        <div style={{background:C.white,borderRadius:14,border:`1px solid ${C.border}`,padding:40,textAlign:"center"}}><div style={{fontSize:40,marginBottom:12}}>📅</div><div style={{color:C.mid,fontSize:15}}>No tienes citas agendadas</div><Btn onClick={()=>navigateToCita(setPage)} col={BRAND.primary} sm style={{marginTop:16}}>Agendar consulta médica</Btn></div>
      ):citas.map(c=>{
        const ev = etiquetaEstadoCitaCliente(c);
        const pagoEv = labelEstadoPagoCita(c);
        const meds = lineasMedicamentosCita(c);
        const vit = lineasVitalsCita(c);
        const mostrarResumen = c.estado === "completada" || c.estado === "no_asistio";
        return (
        <div key={c.id} style={{background:C.white,borderRadius:14,border:`1px solid ${C.border}`,padding:20,marginBottom:12}}>
          <div style={{display:"flex",justifyContent:"space-between",alignItems:"flex-start",marginBottom:10}}>
            <div><div style={{color:C.dark,fontWeight:700,fontSize:15}}>📅 Consulta médica</div><div style={{color:BRAND.primary,fontWeight:700,fontSize:14,marginTop:4}}>{c.fecha} · {c.hora} hrs</div></div>
            <div style={{display:"flex",flexDirection:"column",gap:6,alignItems:"flex-end"}}>
              <Tag col={ev.col} sm>{ev.label}</Tag>
              {c.estado !== "completada" && c.estado !== "cancelada" && c.estado !== "no_asistio" && (
                <Tag col={pagoEv.col} sm>{pagoEv.label}</Tag>
              )}
            </div>
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
          {[{pts:20,ben:"$10 descuento en FarmaCapital",col:BRAND.accent,icon:"💊"},{pts:50,ben:"Envío gratis",col:BRAND.secondary,icon:"📦"},{pts:100,ben:"$50 descuento",col:BRAND.primary,icon:"🎁"},{pts:160,ben:"Consulta médica gratis",col:"#f59e0b",icon:"🏥"},{pts:200,ben:"Producto gratis",col:C.red,icon:"⭐"}].map(r=>(
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
          {[["Nombre",user.nombre],["Teléfono",user.telefono],["Correo",user.email||"No registrado"],["Puntos",`${user.puntos||0} pts FarmaCapital`]].map(([l,v])=>(<div key={l} style={{display:"flex",justifyContent:"space-between",alignItems:"center",padding:"12px 0",borderBottom:`1px solid ${C.border}`}}><span style={{color:C.mid,fontSize:13}}>{l}</span><span style={{color:C.dark,fontSize:14,fontWeight:700}}>{v}</span></div>))}
          <div style={{marginTop:16,padding:16,background:"#f8fafc",borderRadius:10,border:`1px solid ${C.border}`}}>
            <div style={{color:C.dark,fontWeight:700,fontSize:13,marginBottom:12}}>🔑 Cambiar contraseña</div>
            <CambiarPwdCliente user={user}/>
          </div>
          <div style={{marginTop:16}}><Btn sm col={C.red} outline onClick={async()=>{
            const tok = getClienteToken();
            if (tok) { try { await supabase.rpc("logout_cliente", { p_session_token: tok }); } catch(e){} }
            clearClienteSession();
            setUser(null); setPage("home");
          }}>⎋ Cerrar sesión</Btn></div>
        </div>
      )}
    </div>
  );
}

// ── APP PRINCIPAL ─────────────────────────────────────────────
export default function TiendaFarmaCapital(){
  const C = useTheme();
  const initialResetToken = (() => {
    try { return new URLSearchParams(window.location.search).get("reset") || ""; } catch { return ""; }
  })();
  const [resetToken, setResetToken] = useState(initialResetToken);
  const [page,setPageRaw] = useState(() => (initialResetToken ? "reset-password" : "home"));
  const setPage = (p) => {
    let target = p;
    if (p === "cita" && !getClienteToken()) {
      setPostLoginPage("cita");
      target = "login";
    }
    try {
      const u = new URL(window.location.href);
      if (target !== "reset-password") u.searchParams.delete("reset");
      const qs = u.searchParams.toString();
      window.history.pushState({ page: target }, "", u.pathname + (qs ? `?${qs}` : ""));
    } catch {
      window.history.pushState({ page: target }, "", window.location.pathname);
    }
    setPageRaw(target);
  };
  useEffect(()=>{
    const h=(e)=>{
      let p = e.state?.page||"home";
      if (p === "cita" && !getClienteToken()) {
        setPostLoginPage("cita");
        p = "login";
        try {
          window.history.replaceState({ page: "login" }, "", window.location.pathname);
        } catch (_) { /* noop */ }
      }
      setPageRaw(p);
    };
    window.addEventListener("popstate",h);
    try {
      const params = new URLSearchParams(window.location.search);
      const reset = params.get("reset");
      if (reset) {
        setResetToken(reset);
        setPageRaw("reset-password");
        window.history.replaceState({ page: "reset-password" }, "", `${window.location.pathname}?reset=${encodeURIComponent(reset)}`);
      } else {
        window.history.replaceState({ page: "home" }, "", window.location.pathname);
      }
    } catch {
      window.history.replaceState({ page: "home" }, "", window.location.pathname);
    }
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
  const [user,setUser]           = useState(()=> getClienteUser());
  const [productos,setProductos] = useState(()=>{
    try {
      const cached = localStorage.getItem("farmacapital_productos_cache");
      if (cached) { const p = JSON.parse(cached); if (Array.isArray(p) && p.length) return p; }
    } catch(_) {}
    return [];
  });
  const [cargando,setCargando]   = useState(false);
  const [loadingProductos,setLoadingProductos] = useState(productos.length === 0);
  const [prodDetalle,setProdD]   = useState(null);
  const [busqHero,setBusqHero]   = useState("");
  const [showPopup,setShowPopup] = useState(false);
  const [popupBanner,setPopupBanner] = useState(null);
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

  // Sesión persistente en localStorage
  useEffect(()=>{
    if (user) {
      try { localStorage.setItem("farmacapital_user", JSON.stringify(user)); } catch (_) { /* noop */ }
    } else if (!getClienteToken()) {
      try { localStorage.removeItem("farmacapital_user"); } catch (_) { /* noop */ }
    }
  },[user]);

  // Cargar productos con timeout y reintentos para sobrevivir cold start de Supabase
  useEffect(()=>{
    let cancelled = false;
    const MAX_INTENTOS = 4;
    const loadProductos = async (intento = 1)=>{
      try {
        const queryPromise = supabase.from("productos").select("*").eq("activo",true).order("id");
        const timeoutPromise = new Promise((_,r)=>setTimeout(()=>r(new Error("timeout")),20000));
        const {data,error} = await Promise.race([queryPromise,timeoutPromise]);
        if (cancelled) return;
        if (error) {
          const isTimeout = (error.message||"").toLowerCase().includes("upstream request timeout");
          if (isTimeout && intento < MAX_INTENTOS) { await new Promise(r=>setTimeout(r,1500)); return loadProductos(intento+1); }
          console.error("[Tienda] productos:", error);
          setLoadingProductos(false);
          return;
        }
        if (data?.length) {
          setProductos(data);
          try { localStorage.setItem("farmacapital_productos_cache", JSON.stringify(data)); } catch(_) {}
        } else if (data && data.length === 0) {
          setProductos([]);
          try { localStorage.removeItem("farmacapital_productos_cache"); } catch(_) {}
        }
        setLoadingProductos(false);
      } catch(e) {
        if (cancelled) return;
        if (e?.message === "timeout" && intento < MAX_INTENTOS) { await new Promise(r=>setTimeout(r,1500)); return loadProductos(intento+1); }
        setLoadingProductos(false);
      }
    };
    loadProductos();
    const onVis = ()=>{ if (document.visibilityState==="visible") loadProductos(); };
    document.addEventListener("visibilitychange", onVis);
    return ()=>{ cancelled = true; document.removeEventListener("visibilitychange", onVis); };
  },[]);

  // Mostrar popup 1 vez por sesión si no está logueado
  useEffect(()=>{
    if(!cargando&&!user){
      const t=setTimeout(()=>{setShowPopup(true);},2000);
      return ()=>clearTimeout(t);
    }
  },[cargando,user]);

  useEffect(()=>{
    let cancelled = false;
    const loadPopupBanner = ()=>{
      supabase
        .from("banners")
        .select("*")
        .eq("activo", true)
        .eq("slot", "popup")
        .order("orden")
        .limit(1)
        .then(({data, error})=>{
          if (cancelled) return;
          if (error) {
            console.warn("[Tienda] popup banner:", error.message);
            setPopupBanner(null);
            return;
          }
          const row = Array.isArray(data) && data.length ? mapBannerFromRow(data[0]) : null;
          setPopupBanner(row);
        });
    };
    loadPopupBanner();
    const onVis = ()=>{ if (document.visibilityState==="visible") loadPopupBanner(); };
    document.addEventListener("visibilitychange", onVis);
    return ()=>{ cancelled = true; document.removeEventListener("visibilitychange", onVis); };
  },[]);

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

  if(cargando) return <BrandSplash subtitle="Cargando tienda…" size={52} />;

  const puntosPage=(
    <div style={{maxWidth:700,margin:"0 auto",padding:"40px 24px"}}>
      <div style={{textAlign:"center",marginBottom:40}}>
        <div style={{fontSize:56,marginBottom:12}}>⭐</div>
        <h1 style={{color:C.dark,fontSize:32,fontWeight:800,marginBottom:12}}>Programa Puntos FarmaCapital</h1>
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
    home:          <Home setPage={setPage} addToCart={addToCart} productos={productosVistaTiendaFarmacia} setProdDetalle={setProdD} busqHero={busqHero} setBusqHero={setBusqHero} precioConsulta={precioConsultaCfg} loadingProductos={loadingProductos}/>,
    catalogo:      <Catalogo addToCart={addToCart} productos={productosVistaTiendaFarmacia} setProdDetalle={setProdD} setPage={setPage} busqHero={busqHero} setBusqHero={setBusqHero} loadingProductos={loadingProductos}/>,
    promo:         <PromocionesPage setPage={setPage}/>,
    detalle:       <DetalleProducto prod={prodDetalle} productos={productosVistaTiendaFarmacia} addToCart={addToCart} setPage={setPage} setProdDetalle={setProdD} busqHero={busqHero} setBusqHero={setBusqHero}/>,
    carrito:       <Carrito cart={cart} setCart={setCart} setPage={setPage} setEntregaGlobal={setEntregaCheckout}/>,
    checkout:      <Checkout cart={cart} setCart={setCart} setPage={setPage} user={user} setUser={setUser} entrega={entregaCheckout} catalogoProductos={productosVistaTiendaFarmacia}/>,
    cita:          <AgendarCita setPage={setPage} user={user}/>,
    login:         <Login setUser={setUser} setPage={setPage}/>,
    registro:      <Registro setUser={setUser} setPage={setPage}/>,
    "reset-password": <RestablecerPassword token={resetToken} setPage={setPage}/>,
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
        body{
          background:${C.bg};
          font-family:'Plus Jakarta Sans',sans-serif;
          color:${C.dark};
          overflow-x:hidden;
          overflow-y:auto;
          overscroll-behavior-y:auto;
        }
        /* Header sticky: debe quedar FUERA de un padre con overflow-x:hidden (rompe sticky en móvil). */
        main{
          overflow-x:hidden;
          width:100%;
          max-width:100%;
          padding-bottom:env(safe-area-inset-bottom, 0px);
          -webkit-overflow-scrolling:touch;
        }
        img,svg,video,canvas{max-width:100%;height:auto;}
        ::-webkit-scrollbar{width:6px;}::-webkit-scrollbar-track{background:${C.bg};}::-webkit-scrollbar-thumb{background:${C.border};border-radius:4px;}
        button,select{font-family:'Plus Jakarta Sans',sans-serif;}
      `}</style>

      {/* Popup bienvenida */}
      {showPopup&&<PopupBienvenida onClose={()=>setShowPopup(false)} setPage={setPage} precioConsulta={precioConsultaCfg} banner={popupBanner}/>}

      <Header page={page} setPage={setPage} cart={cart} user={user} setUser={setUser}/>

      {(isSupabaseProductionMisconfigured || isSupabaseLocalMisconfigured) && (
        <div style={{
          background: "#fef3c7",
          borderBottom: "1px solid #f59e0b",
          color: "#92400e",
          padding: "10px 16px",
          fontSize: 13,
          lineHeight: 1.45,
          textAlign: "center",
        }}>
          {isSupabaseProductionMisconfigured
            ? "La tienda no puede conectar con la base de datos (configuración del servidor). Avísale al administrador para revisar las variables de Supabase en Vercel."
            : "Modo desarrollo sin Supabase configurado: la tienda se ve, pero catálogo y login no cargarán hasta poner REACT_APP_SUPABASE_* en .env."}
        </div>
      )}

      <div className="farmacapital-tienda-shell" style={{width:"100%",minHeight:"min-content"}}>
        <main style={{background:C.bg}}>
          {pages[page]||pages.home}
        </main>
        {!sinFooter.includes(page)&&<Footer setPage={setPage}/>}
      </div>
      <WhatsAppFloatingButton />
    </>
    </TiendaPlaceholderCtx.Provider>
  );
}
