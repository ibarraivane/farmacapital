import { useEffect, useRef, useState } from "react";
import { $peso } from "../../../utils";
import { tiendaCardImageUrl } from "../../../utils/tiendaCardImage";
import { presentacionPublicaTienda } from "../../../utils/tiendaFarmaciaCatalogo";
import { esBajoPedido } from "../../../lib/bajoPedido";
import { politicaProducto } from "../../../config/politicaMedicamentos";
import { useUrlsImagenesProducto, siguienteIndiceFotoTarjeta, productoTieneFotoInventario, fotoGuardadaMandaEnTienda, resolverFotoTienda } from "../../../hooks/useProductoImagenes";
import { useZoomPackshot } from "../../../hooks/useZoomPackshot";
import EstadoDisponibilidad from "./EstadoDisponibilidad";
import { EstrellasDeProducto } from "../ResenasTienda";
import { pageIdToTiendaPath } from "../../../shared/tiendaRoutes";
import EnlaceTienda from "./EnlaceTienda";

function precioPublicado(prod) {
  const n = Number(prod?.precio);
  return Number.isFinite(n) && n > 0.01 ? n : null;
}

export function sePuedeAgregarEnTarjeta(prod) {
  if (!prod || prod.activo === false || esBajoPedido(prod)) return false;
  if (precioPublicado(prod) == null) return false;
  if (Number(prod.stock) <= 0) return false;
  const pol = politicaProducto(prod);
  return Boolean(pol.ventaEnLinea);
}

export default function TarjetaProducto({ prod, onClick, onAgregar }) {
  const [imgRota, setImgRota] = useState(false);
  const [added, setAdded] = useState(false);
  const [fotoIdx, setFotoIdx] = useState(0);
  const fotoRef = useRef(null);
  const urlsFotoDe = useUrlsImagenesProducto();
  const urlsFoto = productoTieneFotoInventario(prod) && !fotoGuardadaMandaEnTienda(prod) ? urlsFotoDe(prod?.id) : [];
  const fotoCatalogo = urlsFoto[fotoIdx] || urlsFoto[0] || "";
  const imgSrc = resolverFotoTienda(prod, fotoCatalogo);
  const zoom = useZoomPackshot(imgSrc && !imgRota ? imgSrc : "", fotoRef);
  const pres = presentacionPublicaTienda(prod);
  const precio = precioPublicado(prod);
  const marca = String(prod?.marca || "").trim();
  const encargo = esBajoPedido(prod);

  useEffect(() => { setFotoIdx(0); setImgRota(false); setAdded(false); }, [prod?.id, urlsFoto.length]);
  useEffect(() => { setImgRota(false); }, [imgSrc]);

  if (!prod) return null;

  const abrir = () => { onClick?.(prod); };
  const href = pageIdToTiendaPath("detalle", { productId: prod.id });
  const puedeAgregar = typeof onAgregar === "function" && sePuedeAgregarEnTarjeta(prod);
  const agregar = (e) => {
    e?.preventDefault?.();
    e?.stopPropagation?.();
    const ok = onAgregar?.(prod);
    if (ok !== false) setAdded(true);
  };
  const presLinea = [pres, prod.requiere_receta ? "Requiere receta" : ""]
    .filter(Boolean)
    .join(" · ");

  return (
    <article className="fc-product">
      <EnlaceTienda
        className="fc-photo"
        href={href}
        ref={fotoRef}
        onNavigate={abrir}
        aria-label={`Ver ${prod.nombre || "producto"}`}
      >
        {imgSrc && !imgRota ? (
          <img
            src={tiendaCardImageUrl(imgSrc)}
            alt=""
            loading="lazy"
            decoding="async"
            draggable={false}
            style={zoom > 1 ? { "--fc-pack-zoom": String(zoom) } : undefined}
            onError={() => {
              const siguiente = siguienteIndiceFotoTarjeta(urlsFoto, fotoIdx);
              if (siguiente >= 0) { setFotoIdx(siguiente); return; }
              setImgRota(true);
            }}
          />
        ) : (
          <span className="fc-photo-ph">Imagen próximamente</span>
        )}
      </EnlaceTienda>
      <EstadoDisponibilidad producto={prod} />
      {marca ? <div className="fc-product-brand">{marca}</div> : null}
      <EnlaceTienda className="fc-product-name" href={href} onNavigate={abrir}>
        {prod.nombre}
      </EnlaceTienda>
      <EstrellasDeProducto prod={prod} />
      {presLinea ? <div className="fc-small">{presLinea}</div> : null}
      <div className="fc-price-row">
        <strong className="fc-price">{precio != null ? $peso(precio) : "Consultar"}</strong>
        {puedeAgregar ? (
          <button type="button" className="fc-add fc-add--cart" onClick={agregar}>
            {added ? "✓ Agregado" : "+ Agregar"}
          </button>
        ) : (
          <EnlaceTienda className="fc-add" href={href} onNavigate={abrir}>
            {encargo ? "Consultar →" : "Ver producto →"}
          </EnlaceTienda>
        )}
      </div>
    </article>
  );
}
