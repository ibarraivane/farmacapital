import { C_LIGHT } from "../constants";

export function nombreQuienPide(pedido) {
  return String(pedido?.clientes?.nombre || pedido?.guest_nombre || "").trim() || "—";
}

/** Una línea: el nombre no se encoge a cero aunque el folio y el total no quepan. */
export default function FilaPedidoUnaLinea({ abierto, onToggle, nombre, pedidoId, total }) {
  const C = C_LIGHT;
  return (
    <button
      type="button"
      aria-expanded={abierto}
      onClick={onToggle}
      style={{
        width: "100%",
        display: "grid",
        gridTemplateColumns: "auto minmax(7.5rem, 1fr) auto",
        alignItems: "center",
        columnGap: 8,
        background: "none",
        border: "none",
        padding: 0,
        cursor: "pointer",
        textAlign: "left",
        colorScheme: "light",
        minWidth: 0,
      }}
    >
      <span style={{ color: C.textDim, fontWeight: 800, fontSize: 14 }}>{abierto ? "▾" : "▸"}</span>
      <span
        title={nombre}
        style={{
          minWidth: 0,
          overflow: "hidden",
          textOverflow: "ellipsis",
          whiteSpace: "nowrap",
          color: C.text,
          fontSize: 13,
          fontWeight: 800,
        }}
      >
        {nombre}
      </span>
      <span style={{ display: "inline-flex", alignItems: "center", gap: 8, justifyContent: "flex-end" }}>
        <span style={{ color: C.text, fontWeight: 800, fontSize: 13, whiteSpace: "nowrap" }}>Pedido #{pedidoId}</span>
        <span style={{ color: C.blue, fontWeight: 900, fontSize: 14, whiteSpace: "nowrap" }}>{total}</span>
      </span>
    </button>
  );
}
