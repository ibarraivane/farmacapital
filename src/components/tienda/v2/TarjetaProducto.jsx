import { useEffect, useState } from "react";
import { $peso } from "../../../utils";
import { tiendaCardImageUrl, urlImagenPublicaTienda } from "../../../utils/tiendaCardImage";
import { presentacionPublicaTienda } from "../../../utils/tiendaFarmaciaCatalogo";
import { esBajoPedido } from "../../../lib/bajoPedido";
import { useUrlsImagenesProducto, siguienteIndiceFotoTarjeta } from "../../../hooks/useProductoImagenes";
import EstadoDisponibilidad from "./EstadoDisponibilidad";
import { EstrellasDeProducto } from "../ResenasTienda";

function precioPublicado(prod) {
  const n = Number(prod?.precio);
  return Number.isFinite(n) && n > 0.01 ? n : null;
}

export default function TarjetaProducto({ prod, onClick }) {
  const [imgRota, setImgRota] = useState(false);
  const [fotoIdx, setFotoIdx] = useState(0);
  const urlsFotoDe = useUrlsImagenesProducto();
  const urlsFoto = urlsFotoDe(prod?.id);
  const fotoCatalogo = urlsFoto[fotoIdx] || urlsFoto[0] || "";
  const imgSrc = urlImagenPublicaTienda(fotoCatalogo)
    || urlImagenPublicaTienda(prod?.imagen_url)
    || "";
  const pres = presentacionPublicaTienda(prod);
  const precio = precioPublicado(prod);
  const marca = String(prod?.marca || "").trim();
  const encargo = esBajoPedido(prod);

  useEffect(() => { setFotoIdx(0); setImgRota(false); }, [prod?.id, urlsFoto.length]);
  useEffect(() => { setImgRota(false); }, [imgSrc]);

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
        onClick={abrir}
        aria-label={`Ver ${prod.nombre || "producto"}`}
      >
        {imgSrc && !imgRota ? (
          <img
            src={tiendaCardImageUrl(imgSrc)}
            alt=""
            loading="lazy"
            decoding="async"
            draggable={false}
            onError={() => {
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
