/** Tienda B2B Farma Integral (cuenta de la farmacia). Fotos públicas del shop. */
export const FARMA_INTEGRAL_SHOP = "https://farmacia-integral.odoo.com/shop";

export function urlFotoFarmaIntegral(productTemplateId, { size = 512 } = {}) {
  const id = Number(productTemplateId);
  if (!Number.isInteger(id) || id <= 0) return null;
  const s = size === 1920 ? 1920 : size === 1024 ? 1024 : 512;
  return `${FARMA_INTEGRAL_SHOP.replace("/shop", "")}/web/image/product.template/${id}/image_${s}`;
}
