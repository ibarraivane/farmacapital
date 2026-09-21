import { clasificarDisponibilidad } from "./estadoDisponibilidad";

export default function EstadoDisponibilidad({
  producto,
  estado,
  recolectaHoy = false,
  confirmarFecha = false,
  className = "",
}) {
  const info = clasificarDisponibilidad(producto, { estado, recolectaHoy, confirmarFecha });
  return (
    <span className={`state ${className}`.trim()} style={{ color: info.color }}>
      {info.mark ? <span className={`sq ${info.mark}`} aria-hidden /> : null}
      {info.label}
    </span>
  );
}
