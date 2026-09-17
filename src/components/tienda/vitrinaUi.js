import { RADIO, SOMBRA, TIPO, TOKENS as T } from "../../theme/tokens";

/** Lenguaje visual de las páginas Sobre pedido (no el slate de un admin). */
export const V = {
  ink: T.ink,
  inkSoft: T.inkSoft,
  mid: T.textMid,
  dim: T.textDim,
  canvas: T.canvas,
  surface: T.surface,
  surface2: T.surface2,
  border: T.border,
  jade: T.jade,
  blue: T.blue,
  display: TIPO.display,
  body: TIPO.body,
  radius: RADIO.lg,
  radiusMd: RADIO.md,
  pill: RADIO.pill,
  shadow: SOMBRA.sm,
};

export const heroBand = {
  background: `linear-gradient(180deg, ${T.canvas} 0%, #f7f9fc 100%)`,
  borderBottom: `1px solid ${T.border}`,
};

export const eyebrowStyle = {
  margin: 0,
  fontFamily: TIPO.body,
  fontSize: 11,
  fontWeight: 700,
  letterSpacing: "0.16em",
  textTransform: "uppercase",
  color: T.jade,
};

export const displayTitle = {
  margin: "10px 0 0",
  fontFamily: TIPO.display,
  fontWeight: 600,
  letterSpacing: "-0.02em",
  lineHeight: 1.12,
  color: T.ink,
};

export function irAFormularioPedido() {
  (document.getElementById("pedido-especial-form") || document.getElementById("conseguir-form"))
    ?.scrollIntoView({ behavior: "smooth", block: "start" });
}
