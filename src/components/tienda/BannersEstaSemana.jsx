import { bannersEstaSemana, destinoBanner, plantillaBanner, precioBannerProducto, productosDeBanner } from "../../lib/bannersPlantilla";
import { $peso } from "../../utils";
import { urlImagenPublicaTienda } from "../../utils/tiendaCardImage";
import { irACatalogoCategoria } from "../../lib/tiendaCatalogoCategorias";

function fotoDe(prod) {
  return urlImagenPublicaTienda(prod?.imagen_url) || "";
}

function BannerProducto({ banner, producto, promos, onGo }) {
  const oferta = precioBannerProducto(producto, promos, banner.descuento_pct);
  const dest = destinoBanner({ ...banner, pagina: banner.destino || banner.pagina || "detalle" });
  return (
    <button
      type="button"
      className="farmacapital-bnr farmacapital-bnr-producto"
      onClick={() => onGo(dest, producto)}
    >
      <div className="farmacapital-bnr-txt">
        <span className="farmacapital-bnr-tag">Esta semana</span>
        <span className="farmacapital-bnr-t">{producto?.nombre || banner.titulo}</span>
        <span className="farmacapital-bnr-s">{producto?.presentacion || banner.subtitulo}</span>
        <span className="farmacapital-bnr-price">
          {oferta.hayOferta ? <s>{$peso(oferta.lista)}</s> : null}
          <strong>{$peso(oferta.oferta || producto?.precio)}</strong>
        </span>
      </div>
      {fotoDe(producto) ? (
        <span className="farmacapital-bnr-img">
          <img src={fotoDe(producto)} alt="" />
        </span>
      ) : null}
    </button>
  );
}

function BannerServicio({ banner, onGo }) {
  const dest = destinoBanner(banner);
  return (
    <button
      type="button"
      className="farmacapital-bnr farmacapital-bnr-servicio"
      onClick={() => onGo(dest)}
    >
      <div className="farmacapital-bnr-txt">
        <span className="farmacapital-bnr-tag">Servicio</span>
        <span className="farmacapital-bnr-t">{banner.titulo}</span>
        <span className="farmacapital-bnr-s">{banner.descripcion || banner.subtitulo}</span>
        {banner.cta ? <span className="farmacapital-bnr-cta">{banner.cta}</span> : null}
      </div>
    </button>
  );
}

function BannerCategoria({ banner, productos, onGo }) {
  const dest = destinoBanner(banner);
  const fotos = productos.slice(0, 3).map(fotoDe).filter(Boolean);
  return (
    <button
      type="button"
      className="farmacapital-bnr farmacapital-bnr-cat"
      onClick={() => onGo(dest)}
    >
      <div className="farmacapital-bnr-txt">
        <span className="farmacapital-bnr-tag">Categoría</span>
        <span className="farmacapital-bnr-t">{banner.titulo}</span>
        <span className="farmacapital-bnr-s">{banner.descripcion || banner.subtitulo}</span>
      </div>
      {fotos.length ? (
        <span className="farmacapital-bnr-imgs">
          {fotos.map((src) => <img key={src} src={src} alt="" />)}
        </span>
      ) : null}
    </button>
  );
}

export default function BannersEstaSemana({
  banners,
  productos = [],
  promosPorProducto,
  setPage,
  setProdDetalle,
}) {
  const porId = new Map((productos || []).map((p) => [Number(p.id), p]));
  const items = bannersEstaSemana(banners, porId);
  if (!items.length) return null;

  const onGo = (dest, producto) => {
    if (producto && setProdDetalle && (dest.page === "detalle" || !dest.page)) {
      setProdDetalle(producto);
      setPage("detalle", { productId: producto.id });
      return;
    }
    if (dest.categoria) {
      irACatalogoCategoria(setPage, dest.categoria);
      return;
    }
    if (dest.page) setPage(dest.page);
  };

  return (
    <section className="farmacapital-esta-semana" aria-label="Esta semana">
      <div className="farmacapital-esta-semana-head">
        <h2>Esta semana</h2>
        <span>Desliza</span>
      </div>
      <div className="farmacapital-bnr-row">
        {items.map((b) => {
          const plantilla = plantillaBanner(b.plantilla);
          const ids = productosDeBanner(b);
          const prods = ids.map((id) => porId.get(id)).filter(Boolean);
          const promos = promosPorProducto?.get?.(ids[0]) || null;
          return (
            <div className="farmacapital-bnr-cell" key={b.id}>
              {plantilla === "producto" ? (
                <BannerProducto banner={b} producto={prods[0]} promos={promos} onGo={onGo} />
              ) : plantilla === "categoria" ? (
                <BannerCategoria banner={b} productos={prods} onGo={onGo} />
              ) : (
                <BannerServicio banner={b} onGo={onGo} />
              )}
            </div>
          );
        })}
      </div>
    </section>
  );
}
