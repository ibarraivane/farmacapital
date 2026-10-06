import { forwardRef } from "react";
import { clickNavegacionTienda } from "../../../lib/enlaceTienda";

/**
 * Enlace real (`<a href>`) que, en un clic normal, hace preventDefault y
 * navega por la SPA. Clic derecho / pestaña nueva / Ctrl+clic usan el href.
 */
const EnlaceTienda = forwardRef(function EnlaceTienda({
  href,
  onNavigate,
  children,
  className,
  onClick,
  ...rest
}, ref) {
  return (
    <a
      ref={ref}
      href={href || "/"}
      className={className}
      onClick={(e) => {
        onClick?.(e);
        if (clickNavegacionTienda(e)) onNavigate?.();
      }}
      {...rest}
    >
      {children}
    </a>
  );
});

export default EnlaceTienda;
