import { ArrowRight, FlaskConical } from "lucide-react";
import EstadoDisponibilidad from "./EstadoDisponibilidad";
import TarjetaProducto from "./TarjetaProducto";
import { mapearFichaTienda } from "../../../lib/catalogoFichas/mapearFichaTienda";
import { presentacionPublicaTienda } from "../../../utils/tiendaFarmaciaCatalogo";

/** Renglones de ficha técnica con dato. Vacíos no se muestran. */
export function fichaTecnicaDe(prod, ficha, monografia) {
  try {
    return mapearFichaTienda({ producto: prod, ficha, monografia }).fichaTecnica || [];
  } catch (_) {
    return [];
  }
}

/**
 * Ficha de producto con el diseño de ChatGPT (dos columnas en escritorio).
 * Solo presentación: la compra, el encargo y la política siguen en Tienda.jsx.
 */
export default function FichaV2({
  prod,
  imagen,
  categoriaLabel,
  precioSlot,
  estadoCompra,          // { agotado, permitidoWeb, esEncargo, textoBloqueo }
  requiereReceta = false,
  avisoReceta = "",
  added = false,
  onAgregar,
  onComprar,
  onCotizar,
  ficha = null,
  monografia = null,
  infoSlot = null,       // FichaProductoEnriquecida
  similares = [],
  onProducto,
  setPage,
}) {
  if (!prod) return null;
  const { agotado, permitidoWeb, esEncargo, textoBloqueo } = estadoCompra || {};
  const filas = fichaTecnicaDe(prod, ficha, monografia);
  const pres = presentacionPublicaTienda(prod);

  return (
    <div className="fc-body">
      <div className="fc-page-top">
        <button type="button" className="fc-textbtn" onClick={() => setPage?.("catalogo")}>
          ← {categoriaLabel || "Catálogo"}
        </button>
        {prod.marca ? <span className="fc-small">{prod.marca}</span> : null}
      </div>

      <section className="fc-detail">
        <div>
          <div className="fc-detail-photo">
            {imagen ? <img src={imagen} alt={prod.nombre || ""} /> : null}
          </div>
          {filas.length ? (
            <table className="fc-spec">
              <tbody>
                {filas.map((f) => (
                  <tr key={f.k}><th>{f.k}</th><td>{f.v}</td></tr>
                ))}
              </tbody>
            </table>
          ) : null}
        </div>

        <div className="fc-detail-summary">
          <EstadoDisponibilidad producto={prod} />
          <h1>{prod.nombre}</h1>
          {pres ? <p className="fc-description">{pres}</p> : null}

          <div>{precioSlot}</div>

          {requiereReceta && avisoReceta ? (
            <div className="fc-info-box">
              <strong>Requiere receta médica</strong>
              {avisoReceta}
            </div>
          ) : null}

          <div className="fc-info-box">
            <strong>
              {esEncargo
                ? "Este producto se consigue por encargo"
                : agotado
                  ? "Agotado por ahora"
                  : "Recoger en sucursal"}
            </strong>
            {esEncargo
              ? "Confirmamos disponibilidad y fecha con el proveedor antes de cobrar."
              : agotado
                ? "Puedes ver la ficha; cuando vuelva a haber existencia podrás agregarlo al carrito."
                : "Te avisamos cuando tu pedido esté listo. También puedes solicitar cotización de envío en CDMX."}
          </div>

          {esEncargo ? (
            <button type="button" className="fc-primary" onClick={onCotizar}>
              Pedir por encargo <ArrowRight aria-hidden="true" />
            </button>
          ) : (
            <div style={{ display: "flex", gap: 10, flexWrap: "wrap" }}>
              <button
                type="button"
                className="fc-primary"
                disabled={agotado || !permitidoWeb}
                onClick={onAgregar}
              >
                {agotado ? "Agotado" : !permitidoWeb ? (textoBloqueo || "Solo en mostrador") : added ? "✓ Agregado" : "Agregar al carrito"}
              </button>
              <button
                type="button"
                className="fc-secondary"
                disabled={agotado || !permitidoWeb}
                onClick={onComprar}
              >
                Comprar ahora
              </button>
            </div>
          )}

          <p className="fc-small">
            Precio en línea · IVA incluido. Si recoges y pagas en sucursal, aplica el precio de
            mostrador.
          </p>
        </div>
      </section>

      {infoSlot}

      {similares.length ? (
        <section className="fc-section">
          <div className="fc-section-top"><h2>Productos similares</h2></div>
          <div className="fc-grid">
            {similares.map((p) => <TarjetaProducto key={p.id} prod={p} onClick={onProducto} />)}
          </div>
        </section>
      ) : null}

      <button type="button" className="fc-quote-link" onClick={() => setPage?.("cotizar")}>
        <FlaskConical aria-hidden="true" />
        <span>
          <strong>¿Necesitas otra presentación o marca?</strong>
          Te la cotizamos sin costo, incluso si es de alta especialidad.
        </span>
        <ArrowRight aria-hidden="true" />
      </button>
    </div>
  );
}
