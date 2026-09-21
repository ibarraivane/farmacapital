import { useEffect, useState } from "react";
import { Check, Plus } from "lucide-react";
import { $peso } from "../../../utils";
import { tiendaCardImageUrl, urlImagenPublicaTienda } from "../../../utils/tiendaCardImage";
import {
  presentacionPublicaTienda,
  productoPermitidoEnTiendaFarmaciaWeb,
  razonBloqueoProductoTiendaFarmacia,
} from "../../../utils/tiendaFarmaciaCatalogo";
import { ctaBajoPedido, esBajoPedido, rubroDeProducto } from "../../../lib/bajoPedido";
import { ofertaDeProducto } from "../../../lib/precioOferta";
import { useUrlsImagenesProducto, siguienteIndiceFotoTarjeta } from "../../../hooks/useProductoImagenes";
import EstadoDisponibilidad from "./EstadoDisponibilidad";

function IconPlus() {
  return <Plus size={20} strokeWidth={2.4} aria-hidden />;
}
function IconCheck() {
  return <Check size={20} strokeWidth={2.6} aria-hidden />;
}

export default function TarjetaProducto({
  prod,
  addToCart,
  onClick,
  recolectaHoy = false,
  confirmarFecha = false,
  width,
}) {
  const [added, setAdded] = useState(false);
  const [imgRota, setImgRota] = useState(false);
  const [fotoIdx, setFotoIdx] = useState(0);
  const urlsFotoDe = useUrlsImagenesProducto();
  const urlsFoto = urlsFotoDe(prod?.id);
  const fotoCatalogo = urlsFoto[fotoIdx] || urlsFoto[0] || "";
  const imgSrc = urlImagenPublicaTienda(fotoCatalogo)
    || urlImagenPublicaTienda(prod?.imagen_url)
    || "";
  const cta = ctaBajoPedido(prod);
  const agotado = Number(prod?.stock) <= 0 && !esBajoPedido(prod);
  const dermo = rubroDeProducto(prod) === "dermatologia";
  const oferta = ofertaDeProducto(prod, null);
  const precio = Number(oferta?.oferta ?? prod?.precio) || 0;
  const pres = presentacionPublicaTienda(prod);

  useEffect(() => { setFotoIdx(0); setImgRota(false); }, [prod?.id, urlsFoto.length]);
  useEffect(() => { setImgRota(false); }, [imgSrc]);

  if (!prod) return null;

  const abrir = () => { onClick?.(prod); };

  const handleAdd = (e) => {
    e.stopPropagation();
    if (cta === "ordenar") { abrir(); return; }
    if (agotado) return;
    if (!productoPermitidoEnTiendaFarmaciaWeb(prod)) {
      if (typeof window.alert === "function") {
        window.alert(razonBloqueoProductoTiendaFarmacia(prod));
      }
      return;
    }
    if (addToCart?.(prod) === false) return;
    setAdded(true);
    window.setTimeout(() => setAdded(false), 1600);
  };

  return (
    <div className="card lift" style={width ? { flexShrink: 0, width } : undefined}>
      <button type="button" className={`ph${dermo ? " cream" : ""}`} onClick={abrir} aria-label={`Ver ${prod.nombre || "producto"}`}>
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
      <EstadoDisponibilidad
        producto={prod}
        recolectaHoy={recolectaHoy}
        confirmarFecha={confirmarFecha || esBajoPedido(prod)}
      />
      <button type="button" className="name" onClick={abrir}>{prod.nombre}</button>
      {pres ? <span className="pres">{pres}</span> : null}
      <div className="row-price">
        {precio > 0 ? <span className="price">{$peso(precio)}</span> : <span />}
        {!agotado ? (
          <button
            type="button"
            className={`add btn${added ? " on pop" : ""}`}
            aria-label={added ? "En tu carrito" : (cta === "ordenar" ? "Ver producto" : "Agregar al carrito")}
            onClick={handleAdd}
          >
            {added ? <IconCheck /> : <IconPlus />}
          </button>
        ) : null}
      </div>
    </div>
  );
}
