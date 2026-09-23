import { useEffect, useRef, useState } from "react";
import { ArrowRight, FlaskConical } from "lucide-react";
import EstadoDisponibilidad from "./EstadoDisponibilidad";
import TarjetaProducto from "./TarjetaProducto";
import { mapearFichaTienda } from "../../../lib/catalogoFichas/mapearFichaTienda";
import { presentacionPublicaTienda } from "../../../utils/tiendaFarmaciaCatalogo";
import { EstrellasDeProducto, ListaResenasPublicas } from "../ResenasTienda";

/** Renglones de ficha técnica con dato. Vacíos no se muestran. */
export function fichaTecnicaDe(prod, ficha, monografia) {
  try {
    return mapearFichaTienda({ producto: prod, ficha, monografia }).fichaTecnica || [];
  } catch (_) {
    return [];
  }
}

/**
 * Texto de entrega de la caja de compra.
 * Una sola línea: el cliente necesita saber cuándo lo tiene, no leer un párrafo.
 */
export function entregaFicha({ esEncargo, agotado, permitidoWeb, textoBloqueo }) {
  if (esEncargo) {
    return { titulo: "Por encargo · 24-48 hrs", detalle: "Confirmamos precio y fecha con el proveedor antes de cobrar." };
  }
  if (agotado) {
    return { titulo: "Agotado por ahora", detalle: "Escríbenos y te avisamos en cuanto llegue." };
  }
  if (!permitidoWeb) {
    return { titulo: textoBloqueo || "Solo en mostrador", detalle: "Este producto se entrega únicamente en la sucursal." };
  }
  return { titulo: "Listo para recoger hoy", detalle: "En sucursal CDMX. También cotizamos envío a domicilio." };
}

/**
 * Ficha de producto (rediseño).
 * Orden fijo en toda pantalla: nombre → foto → precio y compra → información.
 * La caja de compra se queda a la vista mientras el cliente lee la ficha.
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
  const cajaRef = useRef(null);
  const [barra, setBarra] = useState(false);

  // La barra fija de celular solo aparece cuando la caja de compra ya no se ve,
  // para no repetir el mismo botón dos veces en pantalla ni en el lector de voz.
  useEffect(() => {
    const el = cajaRef.current;
    if (!el || typeof IntersectionObserver !== "function") return undefined;
    const obs = new IntersectionObserver(([e]) => setBarra(!e.isIntersecting), { threshold: 0 });
    obs.observe(el);
    return () => obs.disconnect();
  }, [prod?.id]);

  if (!prod) return null;
  const { agotado, permitidoWeb, esEncargo, textoBloqueo } = estadoCompra || {};
  const filas = fichaTecnicaDe(prod, ficha, monografia);
  const pres = presentacionPublicaTienda(prod);
  const entrega = entregaFicha({ esEncargo, agotado, permitidoWeb, textoBloqueo });
  const sePuedeComprar = !esEncargo && !agotado && permitidoWeb;
  const subtitulo = [prod.marca, pres].map((x) => String(x || "").trim()).filter(Boolean).join(" · ");

  const accionPrincipal = esEncargo ? (
    <button type="button" className="fc-primary" onClick={onCotizar}>
      Pedir por encargo <ArrowRight aria-hidden="true" />
    </button>
  ) : (
    <button type="button" className="fc-primary" disabled={!sePuedeComprar} onClick={onAgregar}>
      {agotado ? "Agotado" : !permitidoWeb ? (textoBloqueo || "Solo en mostrador") : added ? "✓ Agregado" : "Agregar al carrito"}
    </button>
  );

  return (
    <div className="fc-body fc-ficha">
      <nav className="fc-crumbs" aria-label="Dónde estás">
        <button type="button" onClick={() => setPage?.("home")}>Inicio</button>
        <span aria-hidden="true">/</span>
        <button type="button" onClick={() => setPage?.("catalogo")}>{categoriaLabel || "Catálogo"}</button>
      </nav>

      <section className="fc-detail">
        <header className="fc-detail-head">
          <EstadoDisponibilidad producto={prod} />
          <h1>{prod.nombre}</h1>
          <EstrellasDeProducto prod={prod} />
          {subtitulo ? <p className="fc-description">{subtitulo}</p> : null}
        </header>

        <div className="fc-detail-media">
          <div className="fc-detail-photo">
            {imagen
              ? <img src={imagen} alt={prod.nombre || ""} />
              : <span className="fc-small">Foto no disponible</span>}
          </div>
        </div>

        <aside className="fc-buybox" aria-label="Precio y compra" ref={cajaRef}>
          <div className="fc-buybox-precio">
            {precioSlot || <span className="fc-buybox-cotiza">Te cotizamos el precio</span>}
          </div>

          <p className="fc-buybox-entrega">
            <strong>{entrega.titulo}</strong>
            {entrega.detalle}
          </p>

          <div className="fc-buybox-acciones">
            {accionPrincipal}
            {sePuedeComprar ? (
              <button type="button" className="fc-secondary" onClick={onComprar}>Comprar ahora</button>
            ) : null}
          </div>

          {requiereReceta && avisoReceta ? (
            <p className="fc-buybox-receta"><strong>Requiere receta médica.</strong> {avisoReceta}</p>
          ) : null}

          <p className="fc-small">Precio en línea · IVA incluido. Si pagas en mostrador aplica el precio de sucursal.</p>
        </aside>

        <div className="fc-detail-info">
          {filas.length ? (
            <>
              <h2 className="fc-detail-h2">Ficha técnica</h2>
              <table className="fc-spec">
                <tbody>
                  {filas.map((f) => (
                    <tr key={f.k}><th>{f.k}</th><td>{f.v}</td></tr>
                  ))}
                </tbody>
              </table>
            </>
          ) : null}
          {infoSlot}
          <ListaResenasPublicas prod={prod} />
        </div>
      </section>

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

      {/* En celular la compra siempre queda a la mano, sin buscar el botón. */}
      {barra ? (
        <div className="fc-buybar">
          <div className="fc-buybar-precio">
            {precioSlot || <span className="fc-small">Te cotizamos el precio</span>}
          </div>
          {accionPrincipal}
        </div>
      ) : null}
    </div>
  );
}
