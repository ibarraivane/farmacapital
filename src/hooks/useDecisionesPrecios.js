import { useCallback, useEffect, useMemo, useState } from "react";
import { supabase } from "../supabase";
import {
  REFRESH_MS,
  clasificarDecisiones,
  dismissDecision,
  loadDismissed,
  resumenDecisiones,
} from "../lib/decisionesPrecios";
import { buildReferenciasPorProducto, dedupeReferenciasActuales } from "../lib/preciosReferencia";

const SELECT_PROD =
  "id,sku,nombre,categoria,tipo,costo,precio,stock,principio_activo,concentracion,presentacion,forma_farmaceutica,requiere_receta,marca";

async function fetchContexto() {
  const prodRes = await supabase
    .from("productos")
    .select(SELECT_PROD)
    .eq("activo", true)
    .order("nombre");
  if (prodRes.error) throw prodRes.error;

  let refRows = [];
  const viewRes = await supabase.from("producto_precios_referencia_actual").select("*");
  if (viewRes.error) {
    const rawRes = await supabase
      .from("producto_precios_referencia")
      .select("producto_id,fuente,tipo,precio,fecha,origen,confianza,created_at,nombre_fuente,notas")
      .order("fecha", { ascending: false })
      .limit(10000);
    if (rawRes.error) throw rawRes.error;
    refRows = dedupeReferenciasActuales(rawRes.data);
  } else {
    refRows = viewRes.data || [];
  }

  return {
    productos: prodRes.data || [],
    refsByProduct: buildReferenciasPorProducto(refRows),
  };
}

export function useDecisionesPrecios({ enabled = true, autoRefreshMs = REFRESH_MS } = {}) {
  const [productos, setProductos] = useState([]);
  const [refsByProduct, setRefsByProduct] = useState({});
  const [loading, setLoading] = useState(Boolean(enabled));
  const [error, setError] = useState(null);
  const [revisadoAt, setRevisadoAt] = useState(null);
  const [dismissed, setDismissed] = useState(() => loadDismissed());

  const refetch = useCallback(async ({ silent } = {}) => {
    if (!enabled) return;
    if (!silent) setLoading(true);
    try {
      const ctx = await fetchContexto();
      setProductos(ctx.productos);
      setRefsByProduct(ctx.refsByProduct);
      setDismissed(loadDismissed());
      setRevisadoAt(Date.now());
      setError(null);
    } catch (err) {
      setError(err);
    } finally {
      setLoading(false);
    }
  }, [enabled]);

  useEffect(() => {
    if (!enabled) return undefined;
    refetch();
    const t = setInterval(() => refetch({ silent: true }), autoRefreshMs);
    const onVis = () => {
      if (document.visibilityState === "visible") refetch({ silent: true });
    };
    document.addEventListener("visibilitychange", onVis);
    return () => {
      clearInterval(t);
      document.removeEventListener("visibilitychange", onVis);
    };
  }, [enabled, refetch, autoRefreshMs]);

  const decisiones = useMemo(
    () => clasificarDecisiones(productos, refsByProduct, {
      dismissedKeys: Object.keys(dismissed),
    }),
    [productos, refsByProduct, dismissed]
  );

  const resumen = useMemo(() => resumenDecisiones(decisiones), [decisiones]);

  const posponer = useCallback((clave) => {
    setDismissed(dismissDecision(clave));
  }, []);

  const marcarAplicado = useCallback((productoId, precio) => {
    setProductos((prev) => prev.map((p) => (p.id === productoId ? { ...p, precio } : p)));
  }, []);

  return {
    loading,
    error,
    productos,
    refsByProduct,
    decisiones,
    resumen,
    revisadoAt,
    refetch,
    posponer,
    marcarAplicado,
  };
}
