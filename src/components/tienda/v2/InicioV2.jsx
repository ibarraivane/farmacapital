import { useMemo } from "react";
import { Pill, Droplets, Leaf, HeartPulse, Bandage, Package, Store, Truck, MessagesSquare, ArrowRight, MessageCircleQuestion, BadgePercent, ShieldCheck } from "lucide-react";
import TarjetaProducto from "./TarjetaProducto";
import HeroCarrusel from "./HeroCarrusel";
import { esBajoPedido } from "../../../lib/bajoPedido";
import { irASeccionVitrina } from "../../../lib/tiendaCatalogoCategorias";
import { SECCIONES_VITRINA } from "../../../constants/vitrinaTienda";
import { urlImagenPublicaTienda, tiendaCardImageUrl } from "../../../utils/tiendaCardImage";
import { HORARIO_FARMACIA } from "../../../constants/turnos";
import { CONSULTA_PRECIO_DEFAULT } from "../../../utils/consultaConstants";
import { $peso } from "../../../utils";
import { nombrePublicoTienda, presentacionPublicaTienda } from "../../../utils/tiendaFarmaciaCatalogo";
import { normalizeCategoriaKey } from "../../../constants/categoriasProducto";

const MAX_FILA = 4;

/**
 * Marcas de dermocosmética real, para la foto del carrusel. "Cuidado personal"
 * también trae gel para el cabello y acetona; sin esta lista el carrusel podía
 * tocarle enseñar cualquiera de los dos al azar.
 */
const DERMO_MARCAS = [
  "la roche posay", "la roche-posay", "isdin", "bioderma", "sesderma",
  "eucerin", "avène", "avene", "cetaphil", "cerave", "martiderm",
  "neostrata", "uriage", "ducray", "a-derma", "aderma", "darrow",
];

function esDermoReal(prod) {
  return DERMO_MARCAS.includes(String(prod?.marca || "").trim().toLowerCase());
}

/** Dónde se busca genérico o marca original. Nunca en dermocosmética ni deportiva. */
const MED_CATEGORIAS_VITRINA = [
  "Medicamentos", "Medicamento", "Medicamentos OTC", "Analgésico", "Antiinflamatorio",
  "Antibiótico", "Antiviral", "Gastro", "Diabetes", "Hipertensión", "Cardiovascular",
  "Alergia", "Respiratorio", "Hormonales",
];

/**
 * Laboratorios genéricos mexicanos reconocibles en el inventario, verificados
 * contra el catálogo real. No es una lista legal de "genérico intercambiable":
 * es solo para elegir qué 3 fotos entran al carrusel.
 */
const GENERICO_MARCAS = [
  "maver", "amsa", "gelpharma", "cloxan", "collins", "serral", "quifa",
  "novag", "biomep", "son's", "alpharma", "ultra", "wermar", "quimpharma",
  "randall", "raam",
];

/** Marcas de patente reconocibles a nivel internacional. Misma idea: solo para la foto. */
const PATENTE_MARCAS = [
  "bayer", "aspirina", "tempra", "advil", "motrin", "theraflu", "afrin",
  "alka-seltzer", "tylenol", "flanax",
];

function normMarca(prod) {
  return String(prod?.marca || "").trim().toLowerCase();
}

function esMedVitrina(prod) {
  return MED_CATEGORIAS_VITRINA.some((c) => normalizeCategoriaKey(c) === normalizeCategoriaKey(prod?.categoria));
}

/**
 * Genérico real: laboratorio genérico conocido, en una categoría de
 * medicamento, y el nombre del producto es básicamente su sustancia activa
 * (no trae una marca de fantasía). Ese último punto es lo que de verdad
 * distingue a un genérico de una marca — no basta con el laboratorio.
 */
export function esGenericoReal(prod) {
  if (!esMedVitrina(prod) || !GENERICO_MARCAS.includes(normMarca(prod))) return false;
  const pa = normalizeCategoriaKey(prod?.principio_activo).replace(/\s+/g, "").slice(0, 8);
  const nombre = normalizeCategoriaKey(prod?.nombre).replace(/\s+/g, "");
  return pa.length > 3 && nombre.includes(pa);
}

export function esPatenteReal(prod) {
  return esMedVitrina(prod) && PATENTE_MARCAS.includes(normMarca(prod));
}

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
  const fotosDermo = useMemo(
    () => (productos || []).filter((p) => p?.activo !== false && esDermoReal(p) && conFoto(p)).slice(0, 3),
    [productos]
  );
  const fotosGenericos = useMemo(
    () => (productos || []).filter((p) => p?.activo !== false && esGenericoReal(p) && conFoto(p)).slice(0, 3),
    [productos]
  );
  const fotosPatente = useMemo(
    () => (productos || []).filter((p) => p?.activo !== false && esPatenteReal(p) && conFoto(p)).slice(0, 3),
    [productos]
  );

  const abrirProducto = (prod) => {
    if (!prod) return;
    setProdDetalle?.(prod);
    setPage?.("detalle");
  };
  const irCategoria = (nombre) => irASeccionVitrina(setPage, nombre);
  const irCotizar = () => setPage?.("cotizar");
  const iconoSeccion = {
    "nutricion-deportiva": <Leaf aria-hidden="true" />,
    dermocosmetica: <Droplets aria-hidden="true" />,
    medicamentos: <Pill aria-hidden="true" />,
    higiene: <Package aria-hidden="true" />,
    vitaminas: <HeartPulse aria-hidden="true" />,
    botiquin: <Bandage aria-hidden="true" />,
  };
  const descSeccion = {
    "nutricion-deportiva": "Por marca",
    dermocosmetica: "Por marca y solar",
    medicamentos: "Por necesidad",
    higiene: "Cabello, bucal y el día a día",
    vitaminas: "Vitaminas, herbolarios y clínica",
    botiquin: "Curación y aparatos",
  };

  const categorias = SECCIONES_VITRINA.map((sec) => ({
    icon: iconoSeccion[sec.id],
    titulo: sec.nombre,
    desc: descSeccion[sec.id],
    go: () => irCategoria(sec.nombre),
  }));

  const slidesHero = [
    {
      id: "dermo",
      tono: "cream",
      eyebrow: "Cuidado de la piel",
      titulo: "Un espacio para",
      acento: "tu rutina.",
      imagenes: fotosDermo.length ? fotosDermo.map((p) => ({ id: p.id, src: fotoDe(p), marca: String(p.marca || "").trim() })) : undefined,
      icono: <Droplets aria-hidden="true" />,
      nota: "Catálogo por encargo",
      cta: "Descubrir",
      onIr: () => setPage?.("conseguir"),
    },
    {
      id: "cotizar",
      tono: "ink",
      eyebrow: "Cotización sin costo",
      titulo: "Dinos qué buscas,",
      acento: "te lo cotizamos.",
      icono: <MessageCircleQuestion aria-hidden="true" />,
      nota: "Precio y disponibilidad por WhatsApp",
      cta: "Cotizar",
      onIr: irCotizar,
    },
    // Copy de genéricos y marca original aprobado para producción (2026-09-25).
    {
      id: "genericos",
      tono: "jade",
      eyebrow: "Mismo principio activo",
      titulo: "El genérico,",
      acento: "otra opción de precio.",
      imagenes: fotosGenericos.length >= 2
        ? fotosGenericos.map((p) => ({ id: p.id, src: fotoDe(p), marca: String(p.marca || "").trim() }))
        : undefined,
      icono: <BadgePercent aria-hidden="true" />,
      nota: "Pregunta por la alternativa a tu receta",
      cta: "Ver medicamentos",
      onIr: () => irCategoria("Medicamentos"),
    },
    {
      id: "patente",
      tono: "terra",
      eyebrow: "Marca original",
      titulo: "El medicamento",
      acento: "que ya conoces.",
      imagenes: fotosPatente.length >= 2
        ? fotosPatente.map((p) => ({ id: p.id, src: fotoDe(p), marca: String(p.marca || "").trim() }))
        : undefined,
      icono: <ShieldCheck aria-hidden="true" />,
      nota: "Laboratorio original, disponibilidad en sucursal",
      cta: "Ver medicamentos",
      onIr: () => irCategoria("Medicamentos"),
    },
  ];

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
        <HeroCarrusel slides={slidesHero} />
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
