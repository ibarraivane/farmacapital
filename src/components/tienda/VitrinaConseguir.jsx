import { useMemo } from "react";
import RecompraStrip from "../RecompraStrip";
import {
  FASE2_INCLUIR_ANAQUEL,
  RUBROS_BAJO_PEDIDO,
  marcasDestacadas,
  filtrarSeccion,
  filtrarVitrina,
  seccionConseguirPorId,
} from "../../lib/bajoPedido";
import { V, leadStyle, pageTitle, quietStyle } from "./vitrinaUi";

/**
 * Página de categoría. Título como el catálogo; una frase; luego las piezas.
 */
export default function VitrinaConseguir({
  productos,
  loading,
  stack,
  renderProducto,
  seccion = "",
  rubro = "",
  setPage,
  formulario = null,
}) {
  const sec = seccionConseguirPorId(seccion);
  const rubrosSeccion = sec ? RUBROS_BAJO_PEDIDO.filter((r) => sec.rubros.includes(r.id)) : [];
  const esBandas = rubrosSeccion.length > 1;

  const pool = useMemo(
    () => filtrarSeccion(productos, seccion, { incluirAnaquel: FASE2_INCLUIR_ANAQUEL }),
    [productos, seccion]
  );
  const lista = useMemo(
    () => (rubro ? filtrarSeccion(productos, seccion, { rubro, incluirAnaquel: FASE2_INCLUIR_ANAQUEL }) : pool),
    [productos, seccion, rubro, pool]
  );
  const conteo = useMemo(() => {
    const m = { "": pool.length };
    rubrosSeccion.forEach((r) => {
      m[r.id] = filtrarVitrina(productos, r.id).length;
    });
    return m;
  }, [productos, pool.length, rubrosSeccion]);

  const hayAlgo = pool.length > 0;
  const vacio = !loading && !hayAlgo;
  const marcas = marcasDestacadas(productos, seccion, 4);

  const irChip = (id) => {
    if (typeof setPage !== "function" || !sec) return;
    setPage(sec.page, { rubro: id, replace: true, search: "" });
  };

  const titulo = sec ? sec.titulo : "Pedidos especiales";
  const lead = marcas.length ? marcas.join(", ") : (sec?.desc || "");

  const chip = (id, label) => {
    const on = rubro === id;
    return (
      <button
        key={id || "todos"}
        type="button"
        role="tab"
        aria-selected={on}
        onClick={() => irChip(id)}
        style={{
          flexShrink: 0,
          padding: "7px 12px",
          borderRadius: 8,
          border: `1px solid ${on ? V.ink : V.border}`,
          background: on ? V.ink : "#fff",
          color: on ? "#fff" : V.ink,
          fontWeight: 700,
          fontSize: 13,
          cursor: "pointer",
          fontFamily: V.body,
          minHeight: 36,
        }}
      >
        {label}
        {conteo[id] ? <span style={{ opacity: 0.7, marginLeft: 6 }}>{conteo[id]}</span> : null}
      </button>
    );
  };

  const grid = (items) =>
    items.length ? (
      <div
        style={{
          display: "grid",
          gap: stack ? 16 : 18,
          gridTemplateColumns: stack ? "1fr" : "repeat(auto-fill, minmax(min(100%, 220px), 1fr))",
          alignItems: "stretch",
          marginBottom: 8,
        }}
      >
        {items.map((p) => renderProducto(p))}
      </div>
    ) : (
      <p style={{ color: V.mid, fontSize: 14, padding: "4px 0 16px", lineHeight: 1.5 }}>
        En este rubro no hay piezas. Anota cuál buscas abajo.
      </p>
    );

  return (
    <section
      style={{ maxWidth: 1120, margin: "0 auto", padding: stack ? "20px 16px 40px" : "28px 20px 56px" }}
      aria-labelledby="vitrina-conseguir-titulo"
    >
      <h1 id="vitrina-conseguir-titulo" style={pageTitle}>
        {titulo}
      </h1>
      {lead ? <p style={leadStyle}>{lead}</p> : null}
      <p style={quietStyle}>
        Si no está en el anaquel, lo pedimos en 24-48 h. Apartas con tarjeta y se cobra cuando llega; si no lo conseguimos, no pagas. Si el carrito ya tiene cosas de la tienda, el encargo va en otro pedido.
      </p>

      {esBandas ? (
        <div
          role="tablist"
          aria-label="Rubros"
          style={{ display: "flex", gap: 8, overflowX: "auto", padding: "16px 0 8px", margin: "8px 0 12px" }}
        >
          {chip("", "Todos")}
          {rubrosSeccion.map((r) => chip(r.id, r.label))}
        </div>
      ) : (
        <div style={{ height: 20 }} />
      )}

      {loading && !hayAlgo ? (
        <div aria-busy="true" aria-live="polite">
          <p style={{ color: V.dim, fontSize: 13, margin: "0 0 12px" }}>Cargando productos…</p>
          <div
            style={{
              display: "grid",
              gap: 16,
              gridTemplateColumns: stack ? "1fr 1fr" : "repeat(4, 220px)",
            }}
          >
            {[0, 1, 2, 3].map((i) => (
              <div
                key={i}
                style={{
                  height: 260,
                  maxWidth: 220,
                  borderRadius: 10,
                  background: "#f1e8dd",
                  border: `1px solid ${V.border}`,
                }}
              />
            ))}
          </div>
        </div>
      ) : null}

      {vacio ? (
        <p style={{ color: V.mid, fontSize: 15, lineHeight: 1.5, margin: "0 0 20px" }}>
          No hay piezas cargadas. Anota la marca o el nombre.
        </p>
      ) : null}

      {!loading && !vacio && (rubro || !esBandas) ? grid(lista) : null}

      {!loading && !vacio && !rubro && esBandas
        ? rubrosSeccion.map((r) => {
            const items = filtrarVitrina(productos, r.id);
            if (!items.length) return null;
            return (
              <RecompraStrip
                key={r.id}
                title={r.label}
                actionLabel="Ver todo"
                onAction={() => irChip(r.id)}
              >
                {items.map((p) => renderProducto(p))}
              </RecompraStrip>
            );
          })
        : null}

      {!loading && formulario ? (
        <div style={{ marginTop: hayAlgo ? 32 : 8, paddingTop: hayAlgo ? 24 : 0, borderTop: hayAlgo ? `1px solid ${V.border}` : "none" }}>
          {formulario}
        </div>
      ) : null}
    </section>
  );
}
