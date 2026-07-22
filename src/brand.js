// Logotipo oficial FarmaCapital — PNG maestro HD (1754×897)
const BASE = process.env.PUBLIC_URL || "";
const V = "6";

export const BRAND_LOGO = {
  /** Recorte HD ~1623×358 — escalar hacia abajo = nítido */
  full: `${BASE}/brand/farmacapital-logo-full.png?v=${V}`,
  full1x: `${BASE}/brand/farmacapital-logo-full@1x.png?v=${V}`,
  fullLight: `${BASE}/brand/farmacapital-logo-full-light.png?v=${V}`,
  fullLight1x: `${BASE}/brand/farmacapital-logo-full-light@1x.png?v=${V}`,
  admin: `${BASE}/brand/farmacapital-logo-admin.png?v=${V}`,
  icon: `${BASE}/brand/farmacapital-icon.png?v=${V}`,
  iconLight: `${BASE}/brand/farmacapital-icon-light.png?v=${V}`,
  aspect: 1623 / 358,
  aspectAdmin: 1623 / 358,
};

export function logoFullSrc({ iconOnly = false, variant = "default", light = false } = {}) {
  if (iconOnly) return light ? BRAND_LOGO.iconLight : BRAND_LOGO.icon;
  if (light) return BRAND_LOGO.fullLight;
  return variant === "admin" ? BRAND_LOGO.admin : BRAND_LOGO.full;
}

export function logoFullSrcSet({ iconOnly = false, variant = "default", light = false } = {}) {
  if (iconOnly) return `${light ? BRAND_LOGO.iconLight : BRAND_LOGO.icon} 512w`;
  if (light) return `${BRAND_LOGO.fullLight1x} 812w, ${BRAND_LOGO.fullLight} 1623w`;
  const main = variant === "admin" ? BRAND_LOGO.admin : BRAND_LOGO.full;
  return `${BRAND_LOGO.full1x} 812w, ${main} 1623w`;
}

export function logoAspect(variant = "default") {
  return variant === "admin" ? BRAND_LOGO.aspectAdmin : BRAND_LOGO.aspect;
}

export function logoFullStyle(height, { variant = "default" } = {}) {
  return {
    height,
    width: Math.round(height * logoAspect(variant)),
    maxWidth: "min(100vw - 32px, 420px)",
    display: "block",
    objectFit: "contain",
    flexShrink: 0,
  };
}

export function logoIconStyle(size) {
  return {
    height: size,
    width: size,
    display: "block",
    objectFit: "contain",
    flexShrink: 0,
  };
}
