/**
 * Lecturas del catálogo.
 *
 * Suplementos y dermatología (bajo_pedido) siguen en `productos`. No se bajan
 * en la consulta del anaquel: la tienda, el POS y el inventario piden solo el
 * medicamento, y la vitrina aparte cuando hace falta.
 */

/**
 * Páginas chicas a propósito. `select *` de 1000 filas, en frío, se acerca
 * al statement timeout de Supabase (~8 s, código 57014). Si esa página
 * falla, la tienda tira todo el catálogo y el anaquel se ve vacío.
 */
export const PAGE_CATALOGO = 400;

/** PostgREST: null y false son anaquel. true es la vitrina. */
export const FILTRO_ANAQUEL = "bajo_pedido.eq.false,bajo_pedido.is.null";

const REINTENTOS_PAGINA = 3;

/** Timeout de Postgres o del gateway: el siguiente intento suele salir del caché. */
export function esErrorCatalogoReintentable(error) {
  if (!error) return false;
  const code = String(error.code || error.status || "");
  const msg = `${error.message || ""} ${error.details || ""}`.toLowerCase();
  if (code === "57014") return true;
  if (/^5\d\d$/.test(code)) return true;
  return (
    msg.includes("statement timeout")
    || msg.includes("canceling statement")
    || msg.includes("upstream request timeout")
    || msg.includes("timeout")
    || msg.includes("failed to fetch")
    || msg.includes("networkerror")
    || msg.includes("load failed")
  );
}

function esperar(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

export function aplicarModoCatalogo(q, modo = "anaquel") {
  if (!q) return q;
  if (modo === "vitrina") return q.eq("bajo_pedido", true);
  if (modo === "todos") return q;
  return q.or(FILTRO_ANAQUEL);
}

/**
 * Páginas de productos activos.
 * modo "anaquel" omite la vitrina. "vitrina" trae solo esa. limite 0 = todas.
 */
async function pedirPagina(client, { modo, select, order, desde, pedidas }) {
  let q = client.from("productos").select(select).eq("activo", true);
  q = aplicarModoCatalogo(q, modo);
  return q.order(order).order("id").range(desde, desde + pedidas - 1);
}

export async function traerProductosActivos(client, {
  modo = "anaquel",
  select = "*",
  limite = 0,
  pageSize = PAGE_CATALOGO,
  order = "id",
  esperaReintento = (intento) => esperar(400 * intento),
} = {}) {
  const filas = [];
  const tope = limite > 0 ? limite : Infinity;
  for (let desde = 0; filas.length < tope; desde += pageSize) {
    const pedidas = Math.min(pageSize, tope - filas.length);
    let data = null;
    let error = null;
    for (let intento = 1; intento <= REINTENTOS_PAGINA; intento += 1) {
      const res = await pedirPagina(client, { modo, select, order, desde, pedidas });
      data = res?.data;
      error = res?.error || null;
      if (!error) break;
      if (!esErrorCatalogoReintentable(error) || intento === REINTENTOS_PAGINA) break;
      await esperaReintento(intento);
    }
    if (error) return { data: null, error };
    const lote = data || [];
    filas.push(...lote);
    if (lote.length < pedidas) break;
  }
  return { data: limite > 0 ? filas.slice(0, limite) : filas, error: null };
}
