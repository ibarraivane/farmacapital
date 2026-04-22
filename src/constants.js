// FARMAX — Constantes globales
export const C_LIGHT = {
  bg:"#f7f9fc",     card:"#ffffff",     cardDark:"#f0f4f9",
  border:"#e2e8f0", borderHi:"#bfdbfe",
  blue:"#0099e6",   blueDark:"#0052cc", blueDim:"#eff6ff",
  green:"#00c46a",  greenDark:"#009952",greenDim:"#dcfce7",
  amber:"#f59e0b",  amberDim:"#fef3c7",
  red:"#ef4444",    redDim:"#fee2e2",
  purple:"#7c3aed", purpleDim:"#ede9fe",
  teal:"#0891b2",   tealDim:"#cffafe",
  text:"#0f172a",   textMid:"#475569",  textDim:"#94a3b8",
  white:"#ffffff",  mid:"#475569",      dim:"#94a3b8",
  /** Fondo oscuro (footer tienda, bloques hero). useTheme() expone C_LIGHT; sin esto C.dark queda undefined. */
  dark:"#0f172a",
};

// C se exporta dinámico — se sobreescribe en runtime desde Admin.jsx
export let C = {...C_LIGHT};

export const BRAND = {
  primary:"#0052cc", secondary:"#0099e6", accent:"#00c46a",
  gradient:"linear-gradient(135deg,#0052cc,#0099e6)",
};

export const NEG = {
  farmacia:  { label:"Farmax Farmacia",   icon:"💊", color:C.blue,  owner:"Luis Ventura QFB" },
  minisuper: { label:"Minisuper Yolanda", icon:"🛒", color:C.green, owner:"Yolanda Ventura"  },
};

// ── Navegación agrupada por área ────────────────────────────
// VENTAS: pos, cons_cobro (mismo POS; cons_cobro abre pestaña Consultas)
// DOCTORA (también admin): cons_dr, exp_dr
// INVENTARIO: inv (hub con tabs catálogo/reabasto/lotes)
// OPERACIONES: caja, cons (consultorio + procedimientos), cli
// NEGOCIO: dash, promo, fact
// COMPLIANCE: cof
// EQUIPO: rrhh, usuarios
// SISTEMA: banners, bot, pwa, dev
export const NAV_ADMIN = [
  "dash",
  "pos","cons_cobro",
  "cons_dr","exp_dr",
  "inv",
  "caja","cons","config_cons","cli",
  "rrhh",
  "cof",
  "promo","dev","fact",
  "banners","bot","pwa","usuarios"
];
export const NAV_VENDEDOR = ["midia","pos","cons_cobro"];
export const NAV_DOCTORA  = ["cons_dr","exp_dr"];

// Iconos: usamos lucide-react (componentes) en vez de emojis para look consistente.
// El render del Sidebar acepta tanto componentes como strings (compatibilidad).
import {
  LayoutDashboard, ShoppingCart, Package,
  Wallet, Stethoscope, Users, UserCog, ShieldCheck,
  Target, Undo2, Receipt, Image as ImageIcon, Sparkles,
  Download, UserPlus, Settings, CreditCard, HeartPulse,
  SlidersHorizontal, Gauge, FolderOpen,
} from "lucide-react";

export const NAV_ITEMS = [
  // ══ INICIO VENDEDOR ════════════════════════
  {id:"midia",      icon: Gauge,           label:"Mi Día"},
  // ══ VENTAS ════════════════════════════════
  {id:"pos",        icon: ShoppingCart,    label:"Punto de Venta"},
  // ══ INVENTARIO (hub con tabs catálogo/reabasto/lotes) ══
  {id:"inv",        icon: Package,         label:"Inventario"},
  // ══ OPERACIONES ═══════════════════════════
  {id:"caja",       icon: Wallet,          label:"Corte de Caja"},
  {id:"cons",       icon: Stethoscope,     label:"Consultorio"},
  {id:"config_cons",icon: SlidersHorizontal,label:"Metas y Precios"},
  {id:"cli",        icon: Users,           label:"Clientes & Puntos"},
  // ══ EQUIPO ════════════════════════════════
  {id:"rrhh",       icon: UserCog,         label:"RR.HH."},
  // ══ COMPLIANCE ════════════════════════════
  {id:"cof",        icon: ShieldCheck,     label:"COFEPRIS"},
  // ══ NEGOCIO ═══════════════════════════════
  {id:"dash",       icon: LayoutDashboard, label:"Dashboard"},
  {id:"promo",      icon: Target,          label:"Promociones"},
  {id:"dev",        icon: Undo2,           label:"Devoluciones"},
  {id:"fact",       icon: Receipt,         label:"Facturación"},
  // ══ SISTEMA ═══════════════════════════════
  {id:"banners",    icon: ImageIcon,       label:"Banners"},
  {id:"bot",        icon: Sparkles,        label:"Asistente IA"},
  {id:"pwa",        icon: Download,        label:"Instalar app"},
  {id:"usuarios",   icon: UserPlus,        label:"Usuarios"},
  // ══ ROLES ESPECIALES (vendedor / doctora) ══
  {id:"cons_cobro", icon: CreditCard,      label:"Cobrar Consulta"},
  {id:"cons_dr",    icon: HeartPulse,      label:"Mi Consultorio"},
  {id:"exp_dr",     icon: FolderOpen,      label:"Expedientes"},
];
