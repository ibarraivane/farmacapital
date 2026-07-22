// Rutas del logotipo oficial FarmaCapital (public/brand + public/icons)
const BASE = process.env.PUBLIC_URL || "";

export const BRAND_LOGO = {
  /** Tienda, sidebar, tickets — solo FarmaCapital */
  full: `${BASE}/brand/farmacapital-logo-full.png`,
  full2x: `${BASE}/brand/farmacapital-logo-full@2x.png`,
  fullLight: `${BASE}/brand/farmacapital-logo-light.png`,
  fullLight2x: `${BASE}/brand/farmacapital-logo-light@2x.png`,
  /** Admin login — incluye SISTEMA en el PNG */
  admin: `${BASE}/brand/farmacapital-logo-admin.png`,
  admin2x: `${BASE}/brand/farmacapital-logo-admin@2x.png`,
  adminLight: `${BASE}/brand/farmacapital-logo-admin-light.png`,
  adminLight2x: `${BASE}/brand/farmacapital-logo-admin-light@2x.png`,
  icon: `${BASE}/brand/farmacapital-icon.png`,
  iconLight: `${BASE}/brand/farmacapital-icon-light.png`,
  /** Ancho / alto (actualizado al regenerar assets) */
  aspect: 944 / 98,
  aspectAdmin: 944 / 176,
};

export function logoFullSrc({ light = false, iconOnly = false, variant = "default" } = {}) {
  if (iconOnly) return light ? BRAND_LOGO.iconLight : BRAND_LOGO.icon;
  if (variant === "admin") return light ? BRAND_LOGO.adminLight : BRAND_LOGO.admin;
  return light ? BRAND_LOGO.fullLight : BRAND_LOGO.full;
}

export function logoFullSrcSet({ light = false, iconOnly = false, variant = "default" } = {}) {
  if (iconOnly) {
    const s = light ? BRAND_LOGO.iconLight : BRAND_LOGO.icon;
    return `${s} 512w`;
  }
  if (variant === "admin") {
    const a = light ? BRAND_LOGO.adminLight : BRAND_LOGO.admin;
    const b = light ? BRAND_LOGO.adminLight2x : BRAND_LOGO.admin2x;
    return `${a} 1x, ${b} 2x`;
  }
  const a = light ? BRAND_LOGO.fullLight : BRAND_LOGO.full;
  const b = light ? BRAND_LOGO.fullLight2x : BRAND_LOGO.full2x;
  return `${a} 1x, ${b} 2x`;
}

export function logoAspect(variant = "default") {
  return variant === "admin" ? BRAND_LOGO.aspectAdmin : BRAND_LOGO.aspect;
}

export function logoFullStyle(height, { variant = "default" } = {}) {
  const aspect = logoAspect(variant);
  return {
    height,
    width: Math.round(height * aspect),
    display: "block",
    objectFit: "contain",
    flexShrink: 0,
    imageRendering: "auto",
  };
}

export function logoIconStyle(size) {
  return {
    height: size,
    width: size,
    display: "block",
    objectFit: "contain",
    flexShrink: 0,
    imageRendering: "auto",
  };
}
