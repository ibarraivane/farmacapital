/** `<details>` nativo. Si no hay cuerpo, no se pinta. */
export default function Acordeon({ titulo, children, abierto = false }) {
  if (children == null || children === false || children === "") return null;
  return (
    <details className="acc" open={abierto || undefined}>
      <summary>
        <span>{titulo}</span>
        <span className="chev" aria-hidden />
      </summary>
      <div className="accb">{children}</div>
    </details>
  );
}
