import { clasificarDisponibilidad } from "./estadoDisponibilidad";

export default function EstadoDisponibilidad({ producto, className = "" }) {
  const info = clasificarDisponibilidad(producto);
  if (!info) return null;
  return (
    <span className={`fc-state${info.inStock ? " fc-in-stock" : ""}${className ? ` ${className}` : ""}`}>
      {info.label}
    </span>
  );
}
