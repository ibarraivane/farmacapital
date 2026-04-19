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
// VENTAS: pos
// INVENTARIO: inv, rea, lotes
// OPERACIONES: caja, cons, cli
// NEGOCIO: dash, rep, promo, fact
// COMPLIANCE: cof
// EQUIPO: rrhh, usuarios
// SISTEMA: banners, bot, pwa, dev
export const NAV_ADMIN = [
  "dash",
  "pos",
  "inv","rea","lotes",
  "caja","cons","cli",
  "rrhh",
  "cof",
  "promo","dev","fact",
  "banners","bot","pwa","usuarios"
];
export const NAV_VENDEDOR = ["pos","cons_cobro"];
export const NAV_DOCTORA  = ["cons_dr","rep_dr"];

export const NAV_ITEMS = [
  // ══ VENTAS ════════════════════════════════
  {id:"pos",        icon:"⊡", label:"Punto de Venta"},
  // ══ INVENTARIO ════════════════════════════
  {id:"inv",        icon:"▤", label:"Inventario"},
  {id:"rea",        icon:"📦", label:"Reabasto"},
  {id:"lotes",      icon:"🏷️", label:"Lotes PEPS"},
  // ══ OPERACIONES ═══════════════════════════
  {id:"caja",       icon:"⊞", label:"Corte de Caja"},
  {id:"cons",       icon:"♥", label:"Consultorio"},
  {id:"cli",        icon:"◉", label:"Clientes & Puntos"},
  // ══ EQUIPO ════════════════════════════════
  {id:"rrhh",       icon:"◑", label:"RR.HH."},
  // ══ COMPLIANCE ════════════════════════════
  {id:"cof",        icon:"⚕", label:"COFEPRIS"},
  // ══ NEGOCIO ═══════════════════════════════
  {id:"dash",       icon:"◈", label:"Dashboard & Reportes"},
  {id:"promo",      icon:"🎯", label:"Promociones"},
  {id:"dev",        icon:"↩️", label:"Devoluciones"},
  {id:"fact",       icon:"🧾", label:"Facturación"},
  // ══ SISTEMA ═══════════════════════════════
  {id:"banners",    icon:"🖼️", label:"Banners"},
  {id:"bot",        icon:"✦", label:"Asistente IA"},
  {id:"pwa",        icon:"📱", label:"Instalar app"},
  {id:"usuarios",   icon:"👤", label:"Usuarios"},
  // ══ ROLES ESPECIALES ══════════════════════
  {id:"cons_cobro", icon:"💳", label:"Cobrar Consulta"},
  {id:"cons_dr",    icon:"♥", label:"Mi Consultorio"},
  {id:"rep_dr",     icon:"◧", label:"Mis Reportes"},
];
