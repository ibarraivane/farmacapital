// ═══════════════════════════════════════════════════════════════
// FARMACAPITAL — Tokens del rediseño v2 (SOLO TIENDA)
//
// No reemplaza src/theme/tokens.js: Admin y POS siguen usando los
// tokens actuales. La tienda nueva lee estos valores y publica sus
// variables CSS dentro de .fc-v2 (ver aplicarTiendaV2).
// Referencia visual: referencia/prototipo-chatgpt-ajustado.html (diseño de ChatGPT)
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
  mist: "#F4F6F8",      // fondos de bloque, fotos de producto (--fc-soft)
  line: "#DCE2EA",      // bordes y divisores
  lineHi: "#4D5D73",    // borde de botones sobre fondo tinta

  // Calidez puntual (idea de ChatGPT): SOLO dermocosmética
  cream: "#F4ECE2",
  creamLine: "#E6D9C8",
  creamTxt: "#7A4A1E",

  // Texto
  body: "#3A4B63",
  muted: "#536176",

  // Estados
  red: "#B42318",
  redBg: "#FDF3F2",
  redLine: "#F1C4BF",

  // Tipografía
  sans: "'Inter', Arial, sans-serif",
  serif: "'Fraunces', Georgia, serif",          // solo el acento en cursiva de los titulares
  mono: "ui-monospace, Menlo, monospace", // solo folios
};

/** Radios del diseño de ChatGPT: 5–8 px en botones, campos y tarjetas; 8 en bloques. */
export const V2_RADIO = { campo: 7, boton: 7, tarjeta: 6, bloque: 8, pill: 999 };

/** Tipografía: Inter para todo; Fraunces cursiva (500) solo en la frase final de los titulares (.fc-serif). */
export const V2_TIPO = {
  base: { size: 15, lineHeight: 1.5 },
  eyebrow: { size: 11, weight: 700, tracking: "0.12em" },
  small: 12,
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

/**
 * Interruptor del rediseño. ENCENDIDO por defecto en producción.
 * - REACT_APP_TIENDA_V2=0 lo apaga para todos (interruptor de emergencia en Vercel).
 * - ?v2=0 muestra la tienda anterior en esta sesión (para comparar); ?v2=1 la vuelve a encender.
 */
export function tiendaV2Activa() {
  try {
    if (process.env.REACT_APP_TIENDA_V2 === "0") return false;
    if (typeof window !== "undefined") {
      const q = new URLSearchParams(window.location.search);
      if (q.get("v2") === "0") { try { sessionStorage.setItem("fc_v2", "0"); } catch (_) {} return false; }
      if (q.get("v2") === "1") { try { sessionStorage.removeItem("fc_v2"); } catch (_) {} return true; }
      try { if (sessionStorage.getItem("fc_v2") === "0") return false; } catch (_) {}
    }
  } catch (_) {}
  return true;
}
