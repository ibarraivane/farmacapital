/** Tabla clave → valor. Omite renglones sin dato. */
export default function FichaTecnica({ filas = [] }) {
  const rows = (filas || []).filter((r) => r && String(r.valor || "").trim());
  if (!rows.length) return null;
  return (
    <div className="spec">
      {rows.map((r) => (
        <div className="r" key={r.clave}>
          <span className="k">{r.clave}</span>
          <span className="v">{r.valor}</span>
        </div>
      ))}
    </div>
  );
}
