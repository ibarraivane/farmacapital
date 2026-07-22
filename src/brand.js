// Rutas del logotipo oficial FarmaCapital (public/brand + public/icons)
const BASE = process.env.PUBLIC_URL || "";

export const BRAND_LOGO = {
  full: `${BASE}/brand/farmacapital-logo-full.png`,
  fullLight: `${BASE}/brand/farmacapital-logo-light.png`,
  icon: `${BASE}/brand/farmacapital-icon.png`,
  iconLight: `${BASE}/brand/farmacapital-icon-light.png`,
  /** Ancho / alto del logo horizontal oficial */
  aspect: 472 / 112,
};

export function logoFullStyle(height, { light = false } = {}) {
  return {
    height,
    width: Math.round(height * BRAND_LOGO.aspect),
    display: "block",
    objectFit: "contain",
    flexShrink: 0,
  };
}

export function logoIconStyle(size, { light = false } = {}) {
  return {
    height: size,
    width: size,
    display: "block",
    objectFit: "contain",
    flexShrink: 0,
  };
}

export function logoFullSrc({ light = false, iconOnly = false } = {}) {
  if (iconOnly) return light ? BRAND_LOGO.iconLight : BRAND_LOGO.icon;
  return light ? BRAND_LOGO.fullLight : BRAND_LOGO.full;
}
