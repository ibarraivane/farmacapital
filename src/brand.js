// Logotipo oficial FarmaCapital — un solo PNG por contexto, sin variantes rotas.
const BASE = process.env.PUBLIC_URL || "";
const V = "3"; // cache-bust CDN tras regenerar assets

export const BRAND_LOGO = {
  full: `${BASE}/brand/farmacapital-logo-full.png?v=${V}`,
  admin: `${BASE}/brand/farmacapital-logo-admin.png?v=${V}`,
  icon: `${BASE}/brand/farmacapital-icon.png?v=${V}`,
};

export function logoFullSrc({ iconOnly = false, variant = "default" } = {}) {
  if (iconOnly) return BRAND_LOGO.icon;
  return variant === "admin" ? BRAND_LOGO.admin : BRAND_LOGO.full;
}

export function logoAspect(variant = "default") {
  return variant === "admin" ? 471 / 89 : 471 / 50;
}

export function logoFullStyle(height, { variant = "default" } = {}) {
  const aspect = logoAspect(variant);
  return {
    height,
    width: Math.round(height * aspect),
    maxWidth: "min(100%, 320px)",
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
