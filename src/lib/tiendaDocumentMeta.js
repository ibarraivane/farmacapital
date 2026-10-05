import { pageIdToTiendaPath } from "../shared/tiendaRoutes";
import { SECCIONES_VITRINA, slugSeccion } from "../constants/vitrinaTienda";
import { nombrePublicoTienda, presentacionPublicaTienda } from "../utils/tiendaFarmaciaCatalogo";

export const SITIO_CANONICO = "https://www.farmacapital.mx";
export const OG_IMAGEN_DEFAULT = `${SITIO_CANONICO}/icons/og-icon.png`;

const DESC_INICIO = "FarmaCapital — Medicamentos genéricos y de marca, consultorio médico y tienda en línea. Chinampac de Juárez, Iztapalapa, CDMX.";

const META_PAGINA = {
  home: { title: "FarmaCapital · Farmacia en línea", description: DESC_INICIO },
  catalogo: { title: "Catálogo · FarmaCapital", description: "Medicamentos, dermocosmética, vitaminas y botiquín listos para recoger en sucursal CDMX." },
  promo: { title: "Promociones · FarmaCapital", description: "Ofertas vigentes de FarmaCapital: medicamentos y cuidado personal en sucursal y en línea." },
  faq: { title: "Preguntas frecuentes · FarmaCapital", description: "Horarios, receta, envíos, puntos y cómo pedir en FarmaCapital." },
  envios: { title: "Política de envíos · FarmaCapital", description: "Recoger en sucursal y envío cotizado en CDMX. Cómo confirmamos y entregamos tu pedido." },
  privacidad: { title: "Aviso de privacidad · FarmaCapital", description: "Cómo FarmaCapital trata tus datos personales." },
  terminos: { title: "Términos y condiciones · FarmaCapital", description: "Condiciones de uso de la tienda en línea FarmaCapital." },
  puntos: { title: "Puntos FarmaCapital", description: "Programa de puntos de FarmaCapital." },
  "terminos-puntos": { title: "Términos del programa de puntos · FarmaCapital", description: "Reglas del programa de puntos FarmaCapital." },
  cotizar: { title: "Cotizar especializado · FarmaCapital", description: "Te cotizamos medicamentos de alta especialidad y presentaciones difíciles de conseguir." },
  conseguir: { title: "Te lo conseguimos · FarmaCapital", description: "Productos por encargo: dermatología, vitaminas y más. Confirmamos precio y fecha antes de cobrar." },
  cita: { title: "Agendar consulta · FarmaCapital", description: "Consulta médica general en sucursal FarmaCapital, Iztapalapa." },
  tarjeta: { title: "FarmaCapital", description: DESC_INICIO },
  notfound: { title: "Página no encontrada · FarmaCapital", description: "Esta dirección no existe en FarmaCapital.", robots: "noindex,follow" },
  carrito: { title: "Carrito · FarmaCapital", description: "Tu carrito de FarmaCapital.", robots: "noindex,nofollow" },
  checkout: { title: "Checkout · FarmaCapital", description: "Confirma tu pedido en FarmaCapital.", robots: "noindex,nofollow" },
  cuenta: { title: "Mi cuenta · FarmaCapital", description: "Tu cuenta FarmaCapital.", robots: "noindex,nofollow" },
  login: { title: "Iniciar sesión · FarmaCapital", description: "Entra a tu cuenta FarmaCapital.", robots: "noindex,nofollow" },
  registro: { title: "Crear cuenta · FarmaCapital", description: "Crea tu cuenta FarmaCapital.", robots: "noindex,nofollow" },
  pagar: { title: "Pagar pedido · FarmaCapital", description: "Paga tu pedido FarmaCapital.", robots: "noindex,nofollow" },
  "reset-password": { title: "Recuperar contraseña · FarmaCapital", description: "Restablece tu contraseña FarmaCapital.", robots: "noindex,nofollow" },
  "auth-callback": { title: "FarmaCapital", description: DESC_INICIO, robots: "noindex,nofollow" },
};

const META_SECCION = Object.fromEntries(SECCIONES_VITRINA.map((s) => [s.nombre, {
  title: `${s.nombre} · FarmaCapital`,
  description: `Compra ${s.nombre.toLowerCase()} en FarmaCapital. Recoge en sucursal CDMX o pide por encargo.`,
}]));

function absUrl(path) {
  if (!path) return `${SITIO_CANONICO}/`;
  if (/^https?:\/\//i.test(path)) return path;
  return `${SITIO_CANONICO}${path.startsWith("/") ? path : `/${path}`}`;
}

function precioPublicado(prod) {
  const n = Number(prod?.precio);
  return Number.isFinite(n) && n > 0.01 ? n : null;
}

export function metaDeRutaTienda({ page, seccion = "", prod = null, pathname = "", search = "" } = {}) {
  if (page === "detalle" && prod) {
    const nombre = nombrePublicoTienda(prod) || prod.nombre || "Producto";
    const marca = String(prod.marca || "").trim();
    const pres = presentacionPublicaTienda(prod);
    const precio = precioPublicado(prod);
    const title = [nombre, marca, "FarmaCapital"].filter(Boolean).join(" · ");
    const description = [nombre, pres, precio != null ? `$${precio.toFixed(2)} MXN` : "Consulta el precio"].filter(Boolean).join(" · ");
    const image = String(prod.imagen_url || "").trim();
    const canonical = absUrl(pageIdToTiendaPath("detalle", { productId: prod.id }));
    const availability = Number(prod.stock) > 0
      ? "https://schema.org/InStock"
      : "https://schema.org/OutOfStock";
    const jsonLd = {
      "@context": "https://schema.org",
      "@type": "Product",
      name: nombre,
      image: image || undefined,
      brand: marca ? { "@type": "Brand", name: marca } : undefined,
      offers: precio != null ? {
        "@type": "Offer",
        price: Number(precio.toFixed(2)),
        priceCurrency: "MXN",
        availability,
        url: canonical,
      } : undefined,
    };
    return {
      title,
      description,
      canonical,
      ogTitle: title,
      ogImage: image || OG_IMAGEN_DEFAULT,
      robots: "index,follow",
      jsonLd,
    };
  }

  const sec = seccion || "";
  const base = (page === "catalogo" && META_SECCION[sec]) || META_PAGINA[page] || META_PAGINA.home;
  const path = page === "notfound" && pathname
    ? pathname
    : pageIdToTiendaPath(page === "catalogo" ? "catalogo" : page, {
      seccion: page === "catalogo" ? sec : "",
      search: page === "catalogo" || page === "conseguir"
        ? (new URLSearchParams(search || "").get("q") || "")
        : "",
      productId: page === "detalle" ? (new URLSearchParams(search || "").get("id") || "") : "",
    });
  return {
    title: base.title,
    description: base.description,
    canonical: absUrl(path),
    ogTitle: base.title,
    ogImage: OG_IMAGEN_DEFAULT,
    robots: base.robots || "index,follow",
    jsonLd: null,
  };
}

export function aplicarDocumentMeta(meta) {
  if (typeof document === "undefined" || !meta) return;
  if (meta.title) document.title = meta.title;
  setNamedMeta("description", meta.description);
  setNamedMeta("robots", meta.robots || "index,follow");
  setLinkRel("canonical", meta.canonical);
  setPropMeta("og:title", meta.ogTitle || meta.title);
  setPropMeta("og:description", meta.description);
  setPropMeta("og:url", meta.canonical);
  setPropMeta("og:image", meta.ogImage || OG_IMAGEN_DEFAULT);
  setPropMeta("og:image:secure_url", meta.ogImage || OG_IMAGEN_DEFAULT);
  setNamedMeta("twitter:title", meta.ogTitle || meta.title);
  setNamedMeta("twitter:description", meta.description);
  setNamedMeta("twitter:image", meta.ogImage || OG_IMAGEN_DEFAULT);
  setJsonLd("fc-jsonld-page", meta.jsonLd);
}

function setNamedMeta(name, content) {
  if (!content) return;
  let el = document.head.querySelector(`meta[name="${name}"]`);
  if (!el) {
    el = document.createElement("meta");
    el.setAttribute("name", name);
    document.head.appendChild(el);
  }
  el.setAttribute("content", content);
}

function setPropMeta(property, content) {
  if (!content) return;
  let el = document.head.querySelector(`meta[property="${property}"]`);
  if (!el) {
    el = document.createElement("meta");
    el.setAttribute("property", property);
    document.head.appendChild(el);
  }
  el.setAttribute("content", content);
}

function setLinkRel(rel, href) {
  if (!href) return;
  let el = document.head.querySelector(`link[rel="${rel}"]`);
  if (!el) {
    el = document.createElement("link");
    el.setAttribute("rel", rel);
    document.head.appendChild(el);
  }
  el.setAttribute("href", href);
}

function setJsonLd(id, data) {
  let el = document.getElementById(id);
  if (!data) {
    if (el) el.remove();
    return;
  }
  if (!el) {
    el = document.createElement("script");
    el.id = id;
    el.type = "application/ld+json";
    document.head.appendChild(el);
  }
  el.textContent = JSON.stringify(data);
}

export function slugSeccionPublica(nombre) {
  return slugSeccion(nombre);
}
