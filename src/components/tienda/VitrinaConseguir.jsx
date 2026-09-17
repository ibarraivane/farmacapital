import { useMemo, useState } from "react";
import { PackageSearch } from "lucide-react";
import { BRAND } from "../../constants";
import RecompraStrip from "../RecompraStrip";
import { CONSEGUIR_UI, RUBROS_BAJO_PEDIDO, STRIP_TOPE_CONSEGUIR, filtrarVitrina, rubroDeProducto } from "../../lib/bajoPedido";

/**
 * Vitrina de /conseguir: productos bajo pedido por rubro.
 * «Todos» = una banda por rubro (tarjetas de 220px, mismo RecompraStrip del home).
 * Un rubro = cuadrícula igual a la del catálogo.
 * `renderProducto` viene de Tienda.jsx para usar la misma ProductCard (Encargar / Cotizar).
 */
export default function VitrinaConseguir({ productos, loading, stack, renderProducto, onIrAFormulario }) {
  const [rubro, setRubro] = useState("");

  const conteo = useMemo(() => {
    const m = { "": filtrarVitrina(productos).length };
    RUBROS_BAJO_PEDIDO.forEach((r) => { m[r.id] = filtrarVitrina(productos, r.id).length; });
    return m;
  }, [productos]);

  const lista = useMemo(() => (rubro ? filtrarVitrina(productos, rubro) : []), [productos, rubro]);
  const hayAlgo = conteo[""] > 0;

  const chip = (id, label) => {
    const on = rubro === id;
    return (
      <button
        key={id || "todos"}
        type="button"
        role="tab"
        aria-selected={on}
        onClick={() => setRubro(id)}
        style={{
          flexShrink: 0,
          padding: "8px 14px",
          borderRadius: 999,
          border: `1px solid ${on ? BRAND.primary : "#e2e8f0"}`,
          background: on ? BRAND.primary : "#fff",
          color: on ? "#fff" : "#334155",
          fontWeight: 700,
          fontSize: 13,
          cursor: "pointer",
          fontFamily: "inherit",
          minHeight: 40,
        }}
      >
        {label}
        {conteo[id] ? <span style={{ opacity: 0.75, marginLeft: 6 }}>{conteo[id]}</span> : null}
      </button>
    );
  };

  if (!hayAlgo && !loading) return null;

  return (
    <section style={{ maxWidth: 1200, margin: "0 auto", padding: "clamp(20px,4vw,32px) 16px 8px" }} aria-labelledby="vitrina-conseguir-titulo">
      <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 6 }}>
        <div style={{ width: 40, height: 40, borderRadius: 12, background: CONSEGUIR_UI.amber, display: "grid", placeItems: "center", color: "#fff", flexShrink: 0 }}>
          <PackageSearch size={20} aria-hidden />
        </div>
        <h1 id="vitrina-conseguir-titulo" style={{ margin: 0, fontSize: "clamp(22px,5vw,26px)", fontWeight: 800, color: "#0f172a" }}>
          Te lo conseguimos
        </h1>
      </div>
      <p style={{ margin: "0 0 14px", color: "#475569", fontSize: 14, lineHeight: 1.6, maxWidth: 760 }}>
        Productos <strong>bajo pedido</strong>: te los conseguimos en 24-48 hrs. Con precio: encargas y apartas con
        tarjeta; se cobra cuando estén listos. Sin precio: te cotizamos.{" "}
        {typeof onIrAFormulario === "function" ? (
          <button type="button" onClick={onIrAFormulario} style={{ background: "none", border: "none", padding: 0, color: BRAND.secondary, fontWeight: 700, cursor: "pointer", fontSize: 14, fontFamily: "inherit" }}>
            ¿No está en la lista? Pídelo abajo.
          </button>
        ) : null}
      </p>

      <div role="tablist" aria-label="Rubros" className="farmacapital-home-services-scroll" style={{ display: "flex", gap: 8, overflowX: "auto", overflowY: "hidden", WebkitOverflowScrolling: "touch", overscrollBehaviorX: "contain", touchAction: "pan-x pan-y", paddingBottom: 6, marginBottom: 16 }}>
        {chip("", "Todos")}
        {RUBROS_BAJO_PEDIDO.map((r) => chip(r.id, r.label))}
      </div>

      {loading && !hayAlgo ? (
        <div style={{ color: "#64748b", fontSize: 14, padding: "12px 0 24px" }}>Cargando productos…</div>
      ) : rubro ? (
        lista.length ? (
          <div
            style={{
              display: "grid",
              gap: stack ? 16 : 18,
              gridTemplateColumns: stack ? "1fr" : "repeat(auto-fill, minmax(min(100%, 220px), 1fr))",
              alignItems: "stretch",
              marginBottom: 12,
            }}
          >
            {lista.map((p) => renderProducto(p))}
          </div>
        ) : (
          <div style={{ color: "#64748b", fontSize: 14, padding: "8px 0 20px" }}>
            Aún no hay productos en este rubro. Pídelo en el formulario de abajo.
          </div>
        )
      ) : (
        [...RUBROS_BAJO_PEDIDO, { id: "__otros", label: "Otros encargos" }].map((r) => {
          const items = r.id === "__otros"
            ? filtrarVitrina(productos).filter((p) => !rubroDeProducto(p))
            : filtrarVitrina(productos, r.id);
          const enBanda = items.slice(0, STRIP_TOPE_CONSEGUIR);
          const verTodo = items.length > 4 && r.id !== "__otros";
          return (
            <RecompraStrip
              key={r.id}
              title={r.label}
              empty={items.length === 0}
              actionLabel={verTodo ? "Ver todo" : undefined}
              onAction={verTodo ? () => setRubro(r.id) : undefined}
            >
              {enBanda.map((p) => renderProducto(p))}
            </RecompraStrip>
          );
        })
      )}
    </section>
  );
}
