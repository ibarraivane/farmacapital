import { useEffect, useRef } from "react";
import { supabase } from "../supabase";
import { suscribirCatalogoVivo } from "../utils/catalogoVivo";
import { invalidarImagenesProducto } from "./useProductoImagenes";

/**
 * Refresca el catálogo/inventario en el módulo actual.
 * No cambia de página ni recarga el documento.
 */
export function useCatalogoVivo(refetch, opts = {}) {
  const { enabled = true, debounceMs, pausado } = opts;
  const refetchRef = useRef(refetch);
  refetchRef.current = refetch;
  const pausadoRef = useRef(pausado);
  pausadoRef.current = pausado;

  useEffect(() => {
    if (!enabled) return undefined;
    return suscribirCatalogoVivo((detalle) => {
      const hold = pausadoRef.current;
      if (typeof hold === "function" ? hold() : hold) return;
      if (detalle?.table === "producto_imagenes") invalidarImagenesProducto();
      refetchRef.current?.(detalle);
    }, { supabase, debounceMs });
  }, [enabled, debounceMs]);
}
