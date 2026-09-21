// ═══════════════════════════════════════════════════════════════
// FARMACAPITAL — Tokens del rediseño v2 (SOLO TIENDA)
//
// No reemplaza src/theme/tokens.js: Admin y POS siguen usando los
// tokens actuales. La tienda nueva lee estos valores y publica sus
// variables CSS dentro de .fc-v2 (ver aplicarTiendaV2).
// Referencia visual: docs/rediseno-v2/referencia/prototipo-v3.html
// ═══════════════════════════════════════════════════════════════

export const V2 = {
  // Marca (colores exactos del logotipo)
  ink: "#001534",       // texto principal, encabezado, botón principal
  ink2: "#0A2547",      // franja superior del encabezado
  blue: "#054ABC",      // todo lo interactivo: enlaces, foco, "por encargo"
  blueDim: "#EAF0FB",
  jade: "#02A158",      // SOLO disponibilidad y confirmación (nunca decorativo)
  jadeTxt: "#017A43",   // jade para texto pequeño (contraste AA)
  jadeDim: "#E4F5EC",

  // Superficies: blanco con neutros fríos
  page: "#FFFFFF",
  mist: "#F3F5F8",      // fondos de bloque, fotos de producto
  line: "#DCE2EA",      // bordes y divisores
  lineHi: "#C3CCDA",    // borde de campos de formulario

  // Calidez puntual (idea de ChatGPT): SOLO dermocosmética
  cream: "#F4ECE2",
  creamLine: "#E6D9C8",
  creamTxt: "#7A4A1E",

  // Texto
  body: "#3A4B63",
  muted: "#4A5A70",

  // Estados
  red: "#B42318",
  redBg: "#FDF3F2",
  redLine: "#F1C4BF",

  // Tipografía
  sans: "'Archivo', system-ui, -apple-system, sans-serif",
  serif: "'Fraunces', Georgia, serif",          // solo el acento en cursiva de los titulares
  mono: "'IBM Plex Mono', ui-monospace, monospace", // solo folios
};

/** Radios: 8 (botones, campos), 10–12 (tarjetas), 14 (bloques), 999 (chips). */
export const V2_RADIO = { btn: 8, card: 10, block: 12, hero: 14, pill: 999 };

/** Escala tipográfica fija (px). Celular / escritorio. */
export const V2_TIPO = {
  h1: { mobile: 36, desktop: 64, weight: 760, stretch: "112%", lineHeight: 1.02, tracking: "-0.015em" },
  h2: { mobile: 24, desktop: 30, weight: 740, stretch: "110%", lineHeight: 1.08, tracking: "-0.01em" },
  body: { size: 16, lineHeight: 1.5 },
  small: 13,
  eyebrow: { size: 12, weight: 700, tracking: "0.09em" },
  price: { card: 18, ficha: 34, weight: 750 },
};

/** Movimiento: una sola curva para todo el sitio. */
export const V2_MOV = {
  curva: "cubic-bezier(.2,.7,.2,1)",
  micro: 120,   // presionar botón
  panel: 200,   // menús, acordeones
  pagina: 320,  // transiciones de vista
};

/** Publica las variables CSS de v2 SOLO dentro del contenedor de la tienda. */
export function aplicarTiendaV2(el) {
  if (!el || !el.style) return;
  const map = {
    ink: V2.ink, ink2: V2.ink2, blue: V2.blue, "blue-dim": V2.blueDim,
    jade: V2.jade, "jade-txt": V2.jadeTxt, "jade-dim": V2.jadeDim,
    mist: V2.mist, line: V2.line, "line-hi": V2.lineHi,
    cream: V2.cream, "cream-line": V2.creamLine, "cream-txt": V2.creamTxt,
    body: V2.body, muted: V2.muted, red: V2.red, "red-bg": V2.redBg, "red-line": V2.redLine,
    sans: V2.sans, serif: V2.serif, mono: V2.mono,
  };
  Object.entries(map).forEach(([k, v]) => el.style.setProperty(`--${k}`, v));
}

function queryV2() {
  if (typeof window === "undefined") return null;
  try {
    return new URLSearchParams(window.location.search).get("v2");
  } catch (_) {
    return null;
  }
}

function sessionV2() {
  try {
    return sessionStorage.getItem("fc_v2") === "1";
  } catch (_) {
    return false;
  }
}

function setSessionV2(on) {
  try {
    if (on) sessionStorage.setItem("fc_v2", "1");
    else sessionStorage.removeItem("fc_v2");
  } catch (_) { /* noop */ }
}

/** Interruptor: la tienda nueva solo se ve si REACT_APP_TIENDA_V2=1 (o ?v2=1 en la vista previa). */
export function tiendaV2Activa() {
  try {
    if (process.env.REACT_APP_TIENDA_V2 === "1") return true;
    if (typeof window !== "undefined") {
      const q = queryV2();
      if (q === "1") { setSessionV2(true); return true; }
      if (q === "0") { setSessionV2(false); return false; }
      return sessionV2();
    }
  } catch (_) {}
  return false;
}
