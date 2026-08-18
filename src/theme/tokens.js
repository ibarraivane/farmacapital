// ═══════════════════════════════════════════════════════════════
// FARMACAPITAL — Tokens del sistema visual
// Fuente única de verdad para color, forma, sombra y tipografía.
//
// Los tres colores de marca están muestreados del PNG del logotipo
// registrado (public/brand/farmacapital-logo-full@1x.png). No se
// modifican sin actualizar antes la ficha de marca.
// ═══════════════════════════════════════════════════════════════

/** Colores exactos del logotipo registrado. */
export const MARCA = {
  ink:      "#001534", // wordmark "Farma" + contorno de la cruz
  blue:     "#054ABC", // "Capital" + trazo azul de la cruz
  jade:     "#02A158", // trazo verde de la cruz
};

export const TOKENS = {
  // ── Marca ────────────────────────────────────────────────
  ink:        MARCA.ink,
  inkSoft:    "#0A2547",
  blue:       MARCA.blue,
  blueDeep:   "#043A96",
  blueDim:    "#EAF0FB",
  jade:       MARCA.jade,
  jadeDim:    "#E4F5EC",

  // ── Superficies (marfil cálido, no gris Tailwind) ────────
  canvas:     "#F4ECE2",
  surface:    "#FBFAF8",
  surface2:   "#F1E8DD",
  border:     "#E4D9CA",
  borderHi:   "#CFC0AC",

  // ── Acento / llamadas a la acción ────────────────────────
  // 4.82:1 contra texto blanco — WCAG AA completo.
  accent:      "#C9451F",
  accentHover: "#A93715",
  accentDim:   "#FBEDE7",

  // ── Texto ────────────────────────────────────────────────
  text:       MARCA.ink,
  textMid:    "#5A6472",
  textDim:    "#9A9184",

  // ── Estado ───────────────────────────────────────────────
  red:        "#C62828",
  redDim:     "#FBEAE8",
  amber:      "#B26A00",
  amberDim:   "#FDF1DC",

  // ── Gradiente del hero ───────────────────────────────────
  gradient:   "linear-gradient(100deg,#001534 0%,#032A52 46%,#0D4A7A 100%)",
};

/** Escala de radios — cuatro valores, no dieciséis. */
export const RADIO = { sm: 8, md: 14, lg: 22, pill: 999 };

/** Sombras teñidas con la tinta de marca, no con negro neutro. */
export const SOMBRA = {
  sm: "0 1px 2px rgba(0,21,52,.05), 0 8px 24px -12px rgba(0,21,52,.22)",
  md: "0 2px 4px rgba(0,21,52,.06), 0 18px 40px -16px rgba(0,21,52,.30)",
  lg: "0 4px 10px rgba(0,21,52,.08), 0 30px 60px -20px rgba(0,21,52,.36)",
};

export const TIPO = {
  display: "'Fraunces', Georgia, 'Times New Roman', serif",
  body:    "'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif",
};

/**
 * Publica los tokens como variables CSS en :root para que las hojas
 * de estilo (index.css, inventario.css, ticket.css) usen los mismos
 * valores que los estilos en línea de React.
 */
export function aplicarTokensCSS() {
  if (typeof document === "undefined") return;
  const r = document.documentElement.style;
  Object.entries(TOKENS).forEach(([k, v]) => {
    r.setProperty(`--fc-${k.replace(/[A-Z]/g, (m) => "-" + m.toLowerCase())}`, v);
  });
  Object.entries(RADIO).forEach(([k, v]) => r.setProperty(`--fc-r-${k}`, typeof v === "number" ? `${v}px` : v));
  Object.entries(SOMBRA).forEach(([k, v]) => r.setProperty(`--fc-shadow-${k}`, v));
  r.setProperty("--fc-display", TIPO.display);
  r.setProperty("--fc-body", TIPO.body);
}
