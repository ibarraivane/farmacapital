export default function Pasos({ items = [], tono = "ink" }) {
  const list = (items || []).filter((s) => s && (s.titulo || s.texto));
  if (!list.length) return null;
  return (
    <div className="steps">
      {list.map((s, i) => (
        <div className="step" key={s.titulo || i}>
          <div className="rail">
            <span className={`num ${tono === "blue" ? "blue" : ""}`}>{s.num || i + 1}</span>
            {i < list.length - 1 ? <span className="bar2" /> : null}
          </div>
          <div className="txt">
            {s.titulo ? <div className="t">{s.titulo}</div> : null}
            {s.texto ? <div className="d">{s.texto}</div> : null}
          </div>
        </div>
      ))}
    </div>
  );
}
