import { useMemo } from "react";
import { Pill, Droplets, Leaf, HeartPulse, Bandage, Package, Store, Truck, MessagesSquare, ArrowRight } from "lucide-react";
import TarjetaProducto from "./TarjetaProducto";
import { esBajoPedido } from "../../../lib/bajoPedido";
import { irACatalogoCategoria } from "../../../lib/tiendaCatalogoCategorias";
import { urlImagenPublicaTienda, tiendaCardImageUrl } from "../../../utils/tiendaCardImage";
import { HORARIO_FARMACIA } from "../../../constants/turnos";
import { CONSULTA_PRECIO_DEFAULT } from "../../../utils/consultaConstants";
import { $peso } from "../../../utils";
import { nombrePublicoTienda, presentacionPublicaTienda } from "../../../utils/tiendaFarmaciaCatalogo";

const MAX_FILA = 4;

function fotoDe(prod) {
  const url = urlImagenPublicaTienda(prod?.imagen_url);
  return url ? tiendaCardImageUrl(url) : "";
}

function conFoto(prod) {
  return Boolean(fotoDe(prod));
}

/** Medicamentos con existencia real, para «Listos para recoger hoy». */
export function productosEnSucursal(productos, limite = MAX_FILA) {
  return (productos || [])
    .filter((p) => p && p.activo !== false && !esBajoPedido(p) && Number(p.stock) > 0 && Number(p.precio) > 0.01)
    .sort((a, b) => (conFoto(b) ? 1 : 0) - (conFoto(a) ? 1 : 0))
    .slice(0, limite);
}

/** Catálogo extendido: lo que se consigue por encargo. */
export function productosPorEncargo(productos, limite = MAX_FILA) {
  return (productos || [])
    .filter((p) => p && p.activo !== false && esBajoPedido(p))
    .sort((a, b) => (conFoto(b) ? 1 : 0) - (conFoto(a) ? 1 : 0))
    .slice(0, limite);
}

function TarjetaEncargo({ prod, onClick }) {
  const img = fotoDe(prod);
  const marca = String(prod?.marca || "").trim();
  const precio = Number(prod?.precio) > 0.01 ? $peso(Number(prod.precio)) : "Consultar";
  return (
    <button type="button" className="fc-encargo" onClick={() => onClick?.(prod)}>
      {img ? <img src={img} alt="" loading="lazy" decoding="async" /> : <span className="fc-encargo-ph" />}
      {marca ? <span className="fc-product-brand">{marca}</span> : null}
      <span className="fc-encargo-name">{nombrePublicoTienda(prod) || prod?.nombre}</span>
      <span className="fc-small">{presentacionPublicaTienda(prod) || ""}</span>
      <strong className="fc-price">{precio}</strong>
    </button>
  );
}

/**
 * Inicio del rediseño (diseño de ChatGPT). Fase B.
 * Cada bloque se oculta si no tiene datos reales: nunca se publican textos de ejemplo.
 */
export default function InicioV2({
  productos = [],
  loadingProductos = false,
  setPage,
  setProdDetalle,
  precioConsulta,
  bannersSlot = null,
}) {
  const enSucursal = useMemo(() => productosEnSucursal(productos), [productos]);
  const porEncargo = useMemo(() => productosPorEncargo(productos), [productos]);
  const consulta = Math.round(Number(precioConsulta) || CONSULTA_PRECIO_DEFAULT);

  const abrirProducto = (prod) => {
    if (!prod) return;
    setProdDetalle?.(prod);
    setPage?.("detalle");
  };
  const irCategoria = (cat) => irACatalogoCategoria(setPage, cat);
  const irCotizar = () => setPage?.("cotizar");

  const categorias = [
    { icon: <Pill aria-hidden="true" />, titulo: "Medicamentos", desc: "Por nombre o sustancia", go: () => irCategoria("Medicamentos") },
    { icon: <Droplets aria-hidden="true" />, titulo: "Dermocosmética", desc: "Limpieza, hidratación y más", go: () => irCategoria("Dermocosmética") },
    { icon: <Leaf aria-hidden="true" />, titulo: "Nutrición", desc: "Vitaminas y suplementos", go: () => irCategoria("Nutrición") },
    { icon: <HeartPulse aria-hidden="true" />, titulo: "Dispositivos médicos", desc: "Glucómetros, tiras y aparatos", go: () => irCategoria("Dispositivos médicos") },
    { icon: <Bandage aria-hidden="true" />, titulo: "Botiquín", desc: "Gasas, vendas y curación", go: () => irCategoria("Botiquín") },
    { icon: <Package aria-hidden="true" />, titulo: "Farmacia", desc: "Higiene, sueros y el resto", go: () => irCategoria("Farmacia") },
  ];

  const packshots = porEncargo.filter(conFoto).slice(0, 2);

  return (
    <div className="fc-body fc-inicio">
      <section className="fc-hero">
        <div className="fc-hero-copy">
          <div className="fc-eyebrow">Tu farmacia, también en línea</div>
          <h1>
            Tu receta.<br />Tu rutina.<br />
            <span className="fc-serif">Tu farmacia.</span>
          </h1>
          <p className="fc-description">
            Medicamentos, cuidado de la piel y nutrición, con el respaldo de nuestra sucursal.
          </p>
          <button type="button" className="fc-primary" onClick={() => irCategoria("Medicamentos")}>
            Buscar medicamento <ArrowRight aria-hidden="true" />
          </button>
        </div>
        <div className="fc-studio">
          <div>
            <div className="fc-eyebrow">Cuidado de la piel</div>
            <h2>
              Un espacio para<br />
              <span className="fc-serif">tu rutina.</span>
            </h2>
          </div>
          {packshots.length ? (
            <div className="fc-packshots">
              {packshots.map((p) => (
                <img key={p.id} src={fotoDe(p)} alt="" loading="lazy" decoding="async" />
              ))}
            </div>
          ) : null}
          <div className="fc-studio-note">
            <span>Catálogo por encargo</span>
            <button type="button" className="fc-textbtn" onClick={() => setPage?.("conseguir")}>Descubrir →</button>
          </div>
        </div>
      </section>

      <div className="fc-benefits">
        <div className="fc-benefit">
          <Store aria-hidden="true" />
          <div><strong>Recoge en sucursal</strong><span>Te avisamos cuando esté listo</span></div>
        </div>
        <div className="fc-benefit">
          <Truck aria-hidden="true" />
          <div><strong>Envío cotizado en CDMX</strong><span>Conoce el total antes de pagar</span></div>
        </div>
        <div className="fc-benefit">
          <MessagesSquare aria-hidden="true" />
          <div><strong>Atención de farmacia</strong><span>Contáctanos si necesitas ayuda</span></div>
        </div>
      </div>

      <section className="fc-quote">
        <div>
          <div className="fc-eyebrow">Medicamentos especializados</div>
          <h2>
            ¿No encuentras tu medicamento?<br />
            <span className="fc-serif">Te lo cotizamos.</span>
          </h2>
          <p>
            Mándanos el nombre o la foto de tu receta. Te respondemos con precio, disponibilidad y
            fecha antes de cobrar nada.
          </p>
          <button type="button" className="fc-secondary" onClick={irCotizar}>
            Cotizar mi medicamento <ArrowRight aria-hidden="true" />
          </button>
        </div>
        <ol className="fc-quote-steps">
          <li><strong>Nos dices qué necesitas</strong><span>Nombre, sustancia o receta.</span></li>
          <li><strong>Te cotizamos</strong><span>Precio, disponibilidad y fecha.</span></li>
          <li><strong>Apartas y lo recibes</strong><span>En sucursal o con envío cotizado.</span></li>
        </ol>
      </section>

      <section className="fc-section">
        <div className="fc-section-top"><h2>¿Qué estás buscando?</h2></div>
        <div className="fc-categories">
          {categorias.map((c) => (
            <button type="button" key={c.titulo} className="fc-category" onClick={c.go}>
              {c.icon}
              <span>{c.titulo}<small>{c.desc}</small></span>
            </button>
          ))}
        </div>
      </section>

      {bannersSlot}

      {enSucursal.length ? (
        <section className="fc-section">
          <div className="fc-section-top">
            <div>
              <div className="fc-eyebrow" style={{ marginBottom: 7 }}>Medicamentos · En sucursal</div>
              <h2>Listos para recoger hoy.</h2>
            </div>
            <button type="button" className="fc-textbtn" onClick={() => irCategoria("Medicamentos")}>
              Ver medicamentos →
            </button>
          </div>
          <div className="fc-grid">
            {enSucursal.map((p) => (
              <TarjetaProducto key={p.id} prod={p} onClick={abrirProducto} />
            ))}
          </div>
        </section>
      ) : null}

      {porEncargo.length ? (
        <section className="fc-section">
          <div className="fc-section-top">
            <div>
              <div className="fc-eyebrow" style={{ marginBottom: 7 }}>Catálogo extendido · Por encargo</div>
              <h2>Tu cuidado, a tu manera.</h2>
            </div>
            <button type="button" className="fc-textbtn" onClick={() => setPage?.("conseguir")}>Ver catálogo →</button>
          </div>
          <div className="fc-grid">
            {porEncargo.map((p) => (
              <TarjetaEncargo key={p.id} prod={p} onClick={abrirProducto} />
            ))}
          </div>
          <p className="fc-small" style={{ marginTop: 13 }}>
            La disponibilidad y la fecha de llegada se confirman con el proveedor.
          </p>
        </section>
      ) : null}

      {loadingProductos && !enSucursal.length && !porEncargo.length ? (
        <section className="fc-section">
          <div className="fc-grid">
            {[0, 1, 2, 3].map((i) => <div key={i} className="fc-skeleton" />)}
          </div>
        </section>
      ) : null}

      <section className="fc-bottom">
        <div>
          <div className="fc-eyebrow">Farmacia física · Nueva en la Ciudad de México</div>
          <h2>También estamos<br />al otro lado del mostrador.</h2>
          <p className="fc-description" style={{ fontSize: 14 }}>
            Abrimos en agosto de 2026. Recoge tus pedidos, consulta a nuestro personal y conoce el
            consultorio.
          </p>
          <button type="button" className="fc-textbtn" onClick={() => setPage?.("faq")}>
            Ver ubicación y horarios →
          </button>
        </div>
        <div className="fc-clinic">
          <div className="fc-eyebrow">Consultorio en sucursal</div>
          <h2>Consulta médica general</h2>
          <p className="fc-small">
            Consulta ${consulta} · Todos los días {HORARIO_FARMACIA.apertura}–{HORARIO_FARMACIA.cierre}
          </p>
          <button type="button" className="fc-secondary" style={{ marginTop: 18 }} onClick={() => setPage?.("cita")}>
            Agendar consulta
          </button>
        </div>
      </section>
    </div>
  );
}
