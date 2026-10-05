import { useEffect, useRef, useState } from "react";
import { $peso } from "../../../utils";
import { tiendaCardImageUrl, urlImagenPublicaTienda } from "../../../utils/tiendaCardImage";
import { presentacionPublicaTienda } from "../../../utils/tiendaFarmaciaCatalogo";
import { esBajoPedido } from "../../../lib/bajoPedido";
import { useUrlsImagenesProducto, siguienteIndiceFotoTarjeta, productoTieneFotoInventario, fotoGuardadaMandaEnTienda, resolverFotoTienda } from "../../../hooks/useProductoImagenes";
import { useZoomPackshot } from "../../../hooks/useZoomPackshot";
import { usePlaceholderProducto } from "../tiendaPlaceholder";
import EstadoDisponibilidad from "./EstadoDisponibilidad";
import { EstrellasDeProducto } from "../ResenasTienda";

function precioPublicado(prod) {
  const n = Number(prod?.precio);
  return Number.isFinite(n) && n > 0.01 ? n : null;
}

export default function TarjetaProducto({ prod, onClick }) {
  const [imgRota, setImgRota] = useState(false);
  const [phRoto, setPhRoto] = useState(false);
  const [fotoIdx, setFotoIdx] = useState(0);
  const fotoRef = useRef(null);
  const urlsFotoDe = useUrlsImagenesProducto();
  const urlsFoto = productoTieneFotoInventario(prod) && !fotoGuardadaMandaEnTienda(prod) ? urlsFotoDe(prod?.id) : [];
  const fotoCatalogo = urlsFoto[fotoIdx] || urlsFoto[0] || "";
  const fotoReal = resolverFotoTienda(prod, fotoCatalogo);
  const placeholder = urlImagenPublicaTienda(usePlaceholderProducto());
  // La ficha ya cae a «Imagen próximamente». La tarjeta tiene que usar el mismo archivo:
  // si no, el recuadro de afuera se queda gris.
  const mostrarPlaceholder = Boolean(placeholder) && !phRoto && (imgRota || !fotoReal);
  const imgSrc = mostrarPlaceholder ? placeholder : (imgRota ? "" : fotoReal);
  const zoom = useZoomPackshot(imgSrc, fotoRef);
  const pres = presentacionPublicaTienda(prod);
  const precio = precioPublicado(prod);
  const marca = String(prod?.marca || "").trim();
  const encargo = esBajoPedido(prod);

  useEffect(() => { setFotoIdx(0); setImgRota(false); setPhRoto(false); }, [prod?.id, urlsFoto.length]);
  useEffect(() => { setImgRota(false); }, [fotoReal]);

  if (!prod) return null;

  const abrir = () => { onClick?.(prod); };
  const presLinea = [pres, prod.requiere_receta ? "Requiere receta" : ""]
    .filter(Boolean)
    .join(" · ");

  return (
    <article className="fc-product">
      <button
        type="button"
        className="fc-photo"
        ref={fotoRef}
        onClick={abrir}
        aria-label={`Ver ${prod.nombre || "producto"}`}
      >
        {imgSrc ? (
          <img
            className={mostrarPlaceholder ? "fc-photo-ph" : undefined}
            src={tiendaCardImageUrl(imgSrc)}
            alt={mostrarPlaceholder ? "Imagen próximamente" : ""}
            loading="lazy"
            decoding="async"
            draggable={false}
            style={zoom > 1 ? { "--fc-pack-zoom": String(zoom) } : undefined}
            onError={() => {
              if (mostrarPlaceholder) { setPhRoto(true); return; }
              const siguiente = siguienteIndiceFotoTarjeta(urlsFoto, fotoIdx);
              if (siguiente >= 0) { setFotoIdx(siguiente); return; }
              setImgRota(true);
            }}
          />
        ) : null}
      </button>
      <EstadoDisponibilidad producto={prod} />
      {marca ? <div className="fc-product-brand">{marca}</div> : null}
      <button type="button" className="fc-product-name" onClick={abrir}>
        {prod.nombre}
      </button>
      <EstrellasDeProducto prod={prod} />
      {presLinea ? <div className="fc-small">{presLinea}</div> : null}
      <div className="fc-price-row">
        <strong className="fc-price">{precio != null ? $peso(precio) : "Consultar"}</strong>
        <button type="button" className="fc-add" onClick={abrir}>
          {encargo ? "Ver encargo →" : "Ver producto →"}
        </button>
      </div>
    </article>
  );
}
