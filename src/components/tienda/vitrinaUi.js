import { RADIO, TOKENS as T } from "../../theme/tokens";

/** Misma escala que Catálogo / “Explora por categoría”, no un hero de revista. */
export const V = {
  ink: T.ink,
  inkSoft: T.inkSoft,
  mid: T.textMid,
  dim: T.textDim,
  canvas: T.canvas,
  surface: T.surface,
  surface2: T.surface2,
  border: T.border,
  body: "var(--fc-body)",
  radius: RADIO.md,
  pill: RADIO.pill,
};

export const pageTitle = {
  margin: 0,
  fontFamily: "var(--fc-body)",
  fontSize: "clamp(22px, 5vw, 28px)",
  fontWeight: 800,
  lineHeight: 1.2,
  color: T.ink,
};

export const sectionTitle = {
  margin: 0,
  fontFamily: "var(--fc-body)",
  fontSize: "clamp(20px, 4.5vw, 24px)",
  fontWeight: 800,
  lineHeight: 1.25,
  color: T.ink,
};

export const leadStyle = {
  margin: "8px 0 0",
  maxWidth: "36em",
  color: T.textMid,
  fontSize: 15,
  lineHeight: 1.5,
  fontFamily: "var(--fc-body)",
};

export const quietStyle = {
  margin: "10px 0 0",
  color: T.textDim,
  fontSize: 13,
  lineHeight: 1.45,
  fontFamily: "var(--fc-body)",
};

export function irAFormularioPedido() {
  (document.getElementById("pedido-especial-form") || document.getElementById("conseguir-form"))
    ?.scrollIntoView({ behavior: "smooth", block: "start" });
}
