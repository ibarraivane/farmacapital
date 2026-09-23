import { ofertaDeProducto } from "./precioOferta";
import { hoyISOMexico } from "./fecha";
import { resolveTiendaPage } from "../shared/tiendaRoutes";

export const PLANTILLAS_BANNER = Object.freeze([
  "producto",
  "servicio",
  "categoria",
  "imagen_propia",
]);

export function plantillaBanner(raw) {
  const s = String(raw || "imagen_propia").trim().toLowerCase();
  return PLANTILLAS_BANNER.includes(s) ? s : "imagen_propia";
}

export function bannerVigente(banner, hoy = hoyISOMexico()) {
  if (!banner) return false;
  if (banner.activo === false) return false;
  const desde = banner.vigente_desde ? String(banner.vigente_desde).slice(0, 10) : "";
  const hasta = banner.vigente_hasta ? String(banner.vigente_hasta).slice(0, 10) : "";
  if (desde && desde > hoy) return false;
  if (hasta && hasta < hoy) return false;
  return true;
}

export function productosDeBanner(banner) {
  const ids = banner?.producto_ids;
  if (Array.isArray(ids)) return ids.map((n) => Number(n)).filter((n) => Number.isFinite(n) && n > 0);
  return [];
}

function stockProducto(p) {
  if (!p) return 0;
  if (p.bajo_pedido === true) return 1;
  const n = Number(p.stock);
  return Number.isFinite(n) ? n : 0;
}

/**
 * Un banner de plantilla `producto` se oculta si el producto se agotó
 * (salvo que ocultar_sin_stock sea false) o si requiere receta.
 */
export function bannerVisibleEnTienda(banner, productosPorId = new Map(), hoy = hoyISOMexico()) {
  if (!bannerVigente(banner, hoy)) return false;
  const plantilla = plantillaBanner(banner.plantilla);
  if (plantilla === "imagen_propia") return true;
  if (plantilla === "servicio") return true;

  const ids = productosDeBanner(banner);
  if (plantilla === "producto") {
    const p = productosPorId.get(ids[0]);
    if (!p) return false;
    if (p.requiere_receta) return false;
    if (banner.ocultar_sin_stock !== false && stockProducto(p) <= 0) return false;
    return true;
  }
  if (plantilla === "categoria") {
    const visibles = ids
      .map((id) => productosPorId.get(id))
      .filter((p) => p && (banner.ocultar_sin_stock === false || stockProducto(p) > 0));
    return visibles.length > 0 || ids.length === 0;
  }
  return true;
}

export function puedeCrearBannerProducto(producto) {
  if (!producto) return { ok: false, motivo: "Elige un producto." };
  if (producto.requiere_receta) {
    return { ok: false, motivo: "No se puede promocionar un medicamento que requiere receta." };
  }
  return { ok: true, motivo: "" };
}

export function destinoBanner(banner) {
  const raw = String(banner?.destino || banner?.pagina || "").trim();
  if (!raw) return { page: "catalogo", categoria: "", href: "" };
  if (raw === "cotizar") return { page: "cotizar", categoria: "", href: "" };
  if (raw === "consultorio") return { page: "cita", categoria: "", href: "" };
  if (raw.startsWith("categoria:")) {
    return { page: "catalogo", categoria: raw.slice("categoria:".length).trim(), href: "" };
  }
  const page = resolveTiendaPage(raw);
  if (page) return { page, categoria: "", href: "" };
  if (raw.startsWith("/")) return { page: "", categoria: "", href: raw };
  return { page: "catalogo", categoria: "", href: "" };
}

/**
 * Precio "ahora" del banner de producto: misma oferta que la ficha.
 * No se guarda en la fila `banners`.
 */
export function precioBannerProducto(producto, promos, descuentoPctBanner) {
  const conPct = descuentoPctBanner
    ? { ...producto, descuento_pct: Number(descuentoPctBanner) || producto?.descuento_pct }
    : producto;
  return ofertaDeProducto(conPct, promos);
}

export function bannersEstaSemana(banners, productosPorId, hoy = hoyISOMexico()) {
  return (banners || [])
    .filter((b) => {
      const plantilla = plantillaBanner(b.plantilla);
      const slot = String(b.slot || "").toLowerCase();
      const esSemana = slot === "semana" || plantilla !== "imagen_propia";
      return esSemana && bannerVisibleEnTienda(b, productosPorId, hoy);
    })
    .sort((a, b) => (Number(a.orden) || 0) - (Number(b.orden) || 0))
    .slice(0, 5);
}
