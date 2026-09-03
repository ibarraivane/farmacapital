import { useMemo } from "react";
import { opcionesPrincipioActivo } from "../lib/principioActivo";

export default function FiltroPrincipioActivo({ value, onChange, productos, style, id }) {
  const opciones = useMemo(() => opcionesPrincipioActivo(productos), [productos]);
  return (
    <select
      id={id}
      aria-label="Filtrar por principio activo"
      value={value}
      onChange={(e) => onChange(e.target.value)}
      style={style}
    >
      <option value="todos">Todos los principios activos</option>
      <option value="sin">Sin principio activo</option>
      {opciones.map((o) => (
        <option key={o.clave} value={o.clave}>{o.label}</option>
      ))}
    </select>
  );
}
