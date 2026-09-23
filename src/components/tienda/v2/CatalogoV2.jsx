import { ArrowRight, FlaskConical } from "lucide-react";
import TarjetaProducto from "./TarjetaProducto";

const ORDENES = [
  { id: "relevancia", label: "Relevancia" },
  { id: "precio", label: "Menor precio" },
];

function precioDe(prod) {
  const n = Number(prod?.precio);
  return Number.isFinite(n) && n > 0.01 ? n : Infinity;
}

/** Orden del catálogo v2: relevancia (el que ya trae la lista) o menor precio. */
export function ordenarCatalogoV2(lista, orden) {
  if (orden !== "precio") return lista || [];
  return [...(lista || [])].sort((a, b) => precioDe(a) - precioDe(b));
}

/**
 * Catálogo con el diseño de ChatGPT (Fase D).
 * No filtra ni busca por su cuenta: recibe la lista ya filtrada por la tienda
 * y solo cambia la presentación, los chips de categoría y el orden.
 */
export default function CatalogoV2({
  titulo = "Catálogo",
  descripcion = "Revisa la presentación, disponibilidad y forma de entrega de cada producto.",
  productos = [],
  total = 0,
  categorias = [],
  categoria = "Todos",
  onCategoria,
  orden = "relevancia",
  onOrden,
  hayMas = false,
  onVerMas,
  loading = false,
  onProducto,
  setPage,
  avisoRx = null,
}) {
  const lista = ordenarCatalogoV2(productos, orden);

  return (
    <div className="fc-body">
      <div className="fc-page-top">
        <h1>{titulo}</h1>
        <button type="button" className="fc-textbtn" onClick={() => setPage?.("home")}>Inicio</button>
      </div>
      <p className="fc-description">{descripcion}</p>

      {avisoRx}

      {categorias.length > 1 ? (
        <div className="fc-filters">
          {categorias.map((c) => (
            <button
              key={c}
              type="button"
              className="fc-filter"
              aria-pressed={categoria === c}
              onClick={() => onCategoria?.(c)}
            >
              {c}
            </button>
          ))}
          <select
            className="fc-filter-select farmacapital-field-input farmacapital-field-select"
            aria-label="Ordenar productos"
            value={orden}
            onChange={(e) => onOrden?.(e.target.value)}
          >
            {ORDENES.map((o) => <option key={o.id} value={o.id}>{o.label}</option>)}
          </select>
        </div>
      ) : null}

      <p className="fc-small" role="status" style={{ marginBottom: 15 }}>
        {loading && !lista.length
          ? "Cargando catálogo…"
          : `${total || lista.length} producto${(total || lista.length) === 1 ? "" : "s"} · Precios en línea`}
      </p>

      {lista.length ? (
        <>
          <div className="fc-grid">
            {lista.map((p) => <TarjetaProducto key={p.id} prod={p} onClick={onProducto} />)}
          </div>
          {hayMas ? (
            <button type="button" className="fc-secondary" style={{ marginTop: 20 }} onClick={onVerMas}>
              Ver más productos
            </button>
          ) : null}
        </>
      ) : (
        <div className="fc-empty">
          <h2>No encontramos esa combinación.</h2>
          <p>Prueba con otra búsqueda, quita los filtros o pídenos que te lo consigamos.</p>
        </div>
      )}

      <button type="button" className="fc-quote-link" onClick={() => setPage?.("cotizar")}>
        <FlaskConical aria-hidden="true" />
        <span>
          <strong>¿No está aquí?</strong>
          Te cotizamos medicamentos especializados y difíciles de conseguir, sin costo.
        </span>
        <ArrowRight aria-hidden="true" />
      </button>
    </div>
  );
}
