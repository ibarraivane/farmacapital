/**
 * Iconos del mostrador FarmaCapital.
 * Trazo de tinta de marca, no emoji ni Lucide Package/Pill.
 * Caja = cartón con cruz; pieza = una celda; bolsa = bolsa de papel.
 */

const STROKE = {
  fill: "none",
  stroke: "currentColor",
  strokeWidth: 1.7,
  strokeLinecap: "round",
  strokeLinejoin: "round",
};

function Icono({ size = 18, children, title }) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 24 24"
      aria-hidden={title ? undefined : true}
      role={title ? "img" : "presentation"}
      focusable="false"
      style={{ display: "block", flexShrink: 0 }}
    >
      {title ? <title>{title}</title> : null}
      {children}
    </svg>
  );
}

/** Cartón de mostrador con la cruz de la farmacia. */
export function IconoCaja({ size = 18 }) {
  return (
    <Icono size={size}>
      <path {...STROKE} d="M5 8.4 8.1 4.8h7.8L19 8.4v11.3H5V8.4Z" />
      <path {...STROKE} d="M5 8.4h14" />
      <path {...STROKE} d="M12 11.4v5.4M9.7 14.1h4.6" />
    </Icono>
  );
}

/** Una celda: la pieza que se entrega en la mano. */
export function IconoPieza({ size = 18 }) {
  return (
    <Icono size={size}>
      <rect {...STROKE} x="6.6" y="4.8" width="10.8" height="14.4" rx="2.2" />
      <circle {...STROKE} cx="12" cy="10.2" r="2.35" />
      <path {...STROKE} d="M8.4 16.4h7.2" />
    </Icono>
  );
}

/** Bolsa de papel del mostrador — el “carrito” de la farmacia. */
export function IconoBolsa({ size = 18 }) {
  return (
    <Icono size={size}>
      <path {...STROKE} d="M7.2 9.2 8.4 20.4h7.2l1.2-11.2H7.2Z" />
      <path {...STROKE} d="M9.1 9.2c.2-2.6 5.6-2.6 5.8 0" />
    </Icono>
  );
}

/** Anaquel: tres entrepaños, el producto en el de en medio. */
export function IconoAnaquel({ size = 16 }) {
  return (
    <Icono size={size}>
      <path {...STROKE} d="M5 5.6v13.2M19 5.6v13.2" />
      <path {...STROKE} d="M5 8h14M5 13h14M5 18.2h14" />
      <rect {...STROKE} x="10" y="13.35" width="4" height="3.5" rx="0.6" />
    </Icono>
  );
}

/** Lupa sobre barras: buscar o escanear. */
export function IconoBuscar({ size = 40 }) {
  return (
    <Icono size={size}>
      <circle {...STROKE} cx="9" cy="11" r="4.05" />
      <path {...STROKE} d="M12 14 15.6 17.6" />
      <path {...STROKE} d="M17.2 7.4v9.2M19 8.6v6.8M20.8 9.8v4.4" />
    </Icono>
  );
}

export function IconoChevron({ size = 12, direccion = "izq" }) {
  const d = direccion === "der" ? "M9 5.5 14.5 12 9 18.5" : "M15 5.5 9.5 12 15 18.5";
  return (
    <Icono size={size}>
      <path {...STROKE} d={d} />
    </Icono>
  );
}

export function filaIconoBtn(extra) {
  return {
    display: "inline-flex",
    alignItems: "center",
    justifyContent: "center",
    gap: 8,
    ...extra,
  };
}
