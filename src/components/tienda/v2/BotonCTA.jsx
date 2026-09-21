export default function BotonCTA({
  children,
  variant = "dark",
  type = "button",
  className = "",
  disabled,
  onClick,
  href,
  ...rest
}) {
  const cls = `cta ${variant} btn ${className}`.trim();
  if (href && !disabled) {
    return (
      <a className={cls} href={href} onClick={onClick} {...rest}>
        {children}
      </a>
    );
  }
  return (
    <button type={type} className={cls} disabled={disabled} onClick={onClick} {...rest}>
      {children}
    </button>
  );
}
