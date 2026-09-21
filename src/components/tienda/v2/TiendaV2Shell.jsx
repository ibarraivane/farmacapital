import { useEffect, useRef } from "react";
import { aplicarTiendaV2 } from "../../../theme/tiendaV2";

/** Contenedor con tokens v2. Solo se monta cuando el interruptor está activo. */
export default function TiendaV2Shell({ children }) {
  const ref = useRef(null);
  useEffect(() => { aplicarTiendaV2(ref.current); }, []);
  return (
    <div className="fc-v2" ref={ref} data-tienda-v2="1">
      {children}
    </div>
  );
}
