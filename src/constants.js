// FARMACAPITAL — Constantes globales
export const C_LIGHT = {
  bg:"#f7f9fc",     card:"#ffffff",     cardDark:"#f0f4f9",
  border:"#e2e8f0", borderHi:"#c7d4f5",
  blue:"#1E3ABA",   blueDark:"#0D1B2A", blueDim:"#eef1fb",
  green:"#22C55E",  greenDark:"#16a34a",greenDim:"#dcfce7",
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

// Colores oficiales FarmaCapital — Ficha Técnica v1.0 (Mayo 2024)
export const BRAND = {
  dark:     "#0D1B2A",  // Azul Oscuro — PANTONE 2955 C
  primary:  "#1E3ABA",  // Azul Corporativo — PANTONE 7687 C
  accent:   "#22C55E",  // Verde Salud — PANTONE 7481 C
  amber:    "#f59e0b",
  gradient: "linear-gradient(135deg,#0D1B2A,#1E3ABA)",
  // Alias para compatibilidad con código existente
  secondary:"#1E3ABA",
};

export const NEG = {
  farmacia:  { label:"FarmaCapital",   icon:"💊", color:C.blue,  owner:"Luis Ventura QFB" },
  minisuper: { label:"Minisuper Yolanda", icon:"🛒", color:C.green, owner:"Yolanda Ventura"  },
};

// ── Navegación agrupada por área ────────────────────────────
// Admin: ver ADMIN_NAV_SECTIONS (sidebar con títulos de sección).
// agenda = calendario de consultas (admin/vendedor); cons_dr = misma vista, id reservado a doctora.
// trans = Transacciones (listado de pedidos); ped_online = POS pestaña pedidos web.
// VENTAS: pos (consultas en POS), ped_online
// INVENTARIO: inv (hub catálogo / lotes / reabasto)
// DOCTORA: agenda (cons_dr) + expedientes; sin PWA ni consultorio duplicado
export const NAV_ADMIN = [
  "dash", "pos", "cli", "caja", "ped_online",
  "inv",
  "agenda", "cons", "exp_dr",
  "cof", "dev", "fact",
  "promo", "banners", "bot", "config_cons",
  "usuarios", "rrhh",
  "pwa",
];

/** Títulos del sidebar admin (sin mezclar “vistas por rol”; solo agrupa trabajo). */
export const ADMIN_NAV_SECTIONS = [
  { title: "Operación diaria", ids: ["dash", "pos", "cli", "caja", "ped_online"] },
  { title: "Inventario", ids: ["inv"] },
  { title: "Consultorio", ids: ["agenda", "cons", "exp_dr"] },
  { title: "Control y cumplimiento", ids: ["cof", "dev", "fact"] },
  { title: "Comercial y crecimiento", ids: ["promo", "banners", "bot", "config_cons"] },
  { title: "Administración interna", ids: ["usuarios", "rrhh"] },
  { title: "Sistema", ids: ["pwa"] },
];

export const NAV_VENDEDOR = [
  "midia", "pos", "agenda", "cli", "inv", "caja", "cof", "ped_online", "pwa",
];
export const NAV_DOCTORA = ["cons_dr", "exp_dr"];

// Iconos: usamos lucide-react (componentes) en vez de emojis para look consistente.
// El render del Sidebar acepta tanto componentes como strings (compatibilidad).
import {
  LayoutDashboard, ShoppingCart, Package,
  Wallet, Stethoscope, Users, UserCog, ShieldCheck,
  Target, Undo2, Receipt, Image as ImageIcon, Sparkles,
  Download, UserPlus, HeartPulse,
  SlidersHorizontal, Gauge, FolderOpen, CalendarDays, Globe,
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
  {id:"agenda",     icon: CalendarDays,    label:"Agenda de consultas"},
  {id:"cons_dr",    icon: HeartPulse,      label:"Agenda médica"},
  {id:"exp_dr",     icon: FolderOpen,      label:"Expedientes"},
  {id:"ped_online", icon: Globe,           label:"Pedidos online"},
];
