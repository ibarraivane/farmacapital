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
import { V, displayTitle, eyebrowStyle, heroBand, irAFormularioPedido } from "./vitrinaUi";

/**
 * Página de categoría: Dermocosmética o Vitaminas y suplementos.
 * Vitrina primero; el formulario es el cierre, no el centro.
 */
export default function VitrinaConseguir({
  productos,
  loading,
  stack,
  renderProducto,
  onIrAFormulario,
  seccion = "",
  rubro = "",
  setPage,
  formulario = null,
}) {
  const sec = seccionConseguirPorId(seccion);
  const rubrosSeccion = sec ? RUBROS_BAJO_PEDIDO.filter((r) => sec.rubros.includes(r.id)) : [];
  const esDerma = sec?.id === "dermatologia";
  const esNutri = sec?.id === "nutricion";

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
  const irForm = typeof onIrAFormulario === "function" ? onIrAFormulario : irAFormularioPedido;

  const irChip = (id) => {
    if (typeof setPage !== "function" || !sec) return;
    setPage(sec.page, { rubro: id, replace: true, search: "" });
  };

  const titulo = sec ? sec.titulo : "Pedidos especiales";
  const lead = sec?.desc || "";

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
          padding: "9px 16px",
          borderRadius: V.pill,
          border: "none",
          background: on ? V.ink : "transparent",
          color: on ? V.surface : V.inkSoft,
          fontWeight: 600,
          fontSize: 13,
          cursor: "pointer",
          fontFamily: V.body,
          minHeight: 40,
        }}
      >
        {label}
        {conteo[id] ? (
          <span style={{ opacity: on ? 0.72 : 0.5, marginLeft: 7, fontWeight: 600 }}>{conteo[id]}</span>
        ) : null}
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
      <p style={{ color: V.mid, fontSize: 15, padding: "8px 0 12px", lineHeight: 1.55 }}>
        Aún no hay productos en este rubro. Pídelo en el formulario.
      </p>
    );

  return (
    <div>
      <header style={{ ...heroBand, padding: stack ? "28px 16px 22px" : "40px 24px 28px" }}>
        <div style={{ maxWidth: 1120, margin: "0 auto" }}>
          <p style={eyebrowStyle}>Sobre pedido · 24-48 h</p>
          <h1
            id="vitrina-conseguir-titulo"
            style={{ ...displayTitle, fontSize: stack ? 34 : 46 }}
          >
            {titulo}
          </h1>
          {lead ? (
            <p style={{ margin: "14px 0 0", maxWidth: 540, color: V.mid, fontSize: 16, lineHeight: 1.55 }}>
              {lead}
            </p>
          ) : null}
          {marcas.length ? (
            <p style={{ margin: "16px 0 0", color: V.ink, fontSize: 14, letterSpacing: "0.01em", lineHeight: 1.5 }}>
              {marcas.join("  ·  ")}
            </p>
          ) : null}

          <ul
            style={{
              listStyle: "none",
              margin: "22px 0 0",
              padding: "16px 0 0",
              borderTop: `1px solid ${V.border}`,
              display: "grid",
              gridTemplateColumns: stack ? "1fr" : "repeat(3, minmax(0, 1fr))",
              gap: stack ? 12 : 20,
            }}
          >
            <li style={{ color: V.mid, fontSize: 13, lineHeight: 1.45 }}>
              <strong style={{ display: "block", color: V.ink, fontWeight: 600, marginBottom: 2 }}>En tienda y sobre pedido</strong>
              Anaquel primero; si no está, lo pedimos.
            </li>
            <li style={{ color: V.mid, fontSize: 13, lineHeight: 1.45 }}>
              <strong style={{ display: "block", color: V.ink, fontWeight: 600, marginBottom: 2 }}>Reserva en tarjeta de crédito</strong>
              Solo se cobra cuando llega. Si no, no pagas.
            </li>
            <li style={{ color: V.mid, fontSize: 13, lineHeight: 1.45 }}>
              <strong style={{ display: "block", color: V.ink, fontWeight: 600, marginBottom: 2 }}>Receta en mostrador</strong>
              Se presenta en tienda. No encargamos controlados.
            </li>
          </ul>
        </div>
      </header>

      <section
        style={{ maxWidth: 1120, margin: "0 auto", padding: stack ? "22px 16px 48px" : "28px 24px 64px" }}
        aria-labelledby="vitrina-conseguir-titulo"
      >
        {esNutri && rubrosSeccion.length > 1 ? (
          <div
            role="tablist"
            aria-label="Rubros"
            style={{
              display: "flex",
              gap: 4,
              overflowX: "auto",
              padding: 4,
              margin: "0 0 22px",
              background: V.surface2,
              borderRadius: V.pill,
              width: "fit-content",
              maxWidth: "100%",
            }}
          >
            {chip("", "Todos")}
            {rubrosSeccion.map((r) => chip(r.id, r.label))}
          </div>
        ) : null}

        {loading && !hayAlgo ? (
          <div aria-busy="true" aria-live="polite">
            <p style={{ color: V.dim, fontSize: 13, margin: "0 0 16px" }}>Cargando productos…</p>
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
                    height: 280,
                    maxWidth: 220,
                    borderRadius: V.radiusMd,
                    background: V.surface2,
                    border: `1px solid ${V.border}`,
                  }}
                />
              ))}
            </div>
          </div>
        ) : null}

        {vacio ? (
          <div
            style={{
              padding: stack ? "28px 20px" : "40px 36px",
              borderRadius: V.radius,
              background: V.surface,
              border: `1px solid ${V.border}`,
              boxShadow: V.shadow,
              marginBottom: 28,
            }}
          >
            <p style={{ ...eyebrowStyle, marginBottom: 8 }}>Vitrina</p>
            <h2 style={{ ...displayTitle, fontSize: 28, margin: 0 }}>
              Aún no hay productos en esta página
            </h2>
            <p style={{ margin: "12px 0 0", color: V.mid, fontSize: 15, lineHeight: 1.55, maxWidth: 420 }}>
              Cuéntanos qué necesitas. Lo pedimos y te escribimos con el costo.
            </p>
            <button
              type="button"
              onClick={irForm}
              style={{
                marginTop: 20,
                padding: "12px 20px",
                borderRadius: V.pill,
                border: "none",
                background: V.ink,
                color: V.surface,
                fontWeight: 700,
                fontSize: 14,
                cursor: "pointer",
                fontFamily: V.body,
              }}
            >
              Pedirlo
            </button>
          </div>
        ) : null}

        {!vacio && (rubro || esDerma) ? grid(lista) : null}

        {!vacio && !rubro && esNutri
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
          <div
            style={{
              marginTop: hayAlgo || vacio ? 36 : 0,
              paddingTop: 28,
              borderTop: `1px solid ${V.border}`,
            }}
          >
            {formulario}
          </div>
        ) : null}
      </section>
    </div>
  );
}
