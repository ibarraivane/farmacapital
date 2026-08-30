/**
 * Precio de lista vs oferta para tienda (y la misma cuenta en POS ficha).
 *
 * `productos.precio` es el precio normal. Si hay `descuento_pct` o una
 * campaña vigente (promociones + promocion_productos), el público ve
 * ese monto tachado y paga el menor de los candidatos.
 *
 * 2×1 / combo no bajan el unitario: se anuncian en la página de promociones.
 */
import { cobroLinea, pesoPublico } from "../utils/pesoPublico";
import { hoyISOMexico } from "./fecha";

export function promoVigente(promo, hoy = hoyISOMexico()) {
  if (!promo || promo.activa === false) return false;
  const ini = promo.fecha_inicio ? String(promo.fecha_inicio).slice(0, 10) : "";
  const fin = promo.fecha_fin ? String(promo.fecha_fin).slice(0, 10) : "";
  if (ini && ini > hoy) return false;
  if (fin && fin < hoy) return false;
  return true;
}

export function precioDesdePromo(lista, promo) {
  if (!promo || !(lista > 0)) return null;
  if (promo.tipo === "descuento_pct") {
    const pct = Number(promo.valor) || 0;
    if (pct <= 0 || pct >= 100) return null;
    const n = cobroLinea(lista, 1, pct);
    return n > 0 && n < lista ? n : null;
  }
  if (promo.tipo === "descuento_fijo") {
    const off = Number(promo.valor) || 0;
    if (off <= 0) return null;
    const n = pesoPublico(lista - off);
    return n > 0 && n < lista ? n : null;
  }
  return null;
}

function listaDePromos(promos) {
  if (!promos) return [];
  return Array.isArray(promos) ? promos : [promos];
}

export function ofertaDeProducto(prod, promos, hoy = hoyISOMexico()) {
  const lista = pesoPublico(prod?.precio);
  const candidatos = [];

  const pctProd = Number(prod?.descuento_pct) || 0;
  if (lista > 0 && pctProd > 0 && pctProd < 100) {
    const oferta = cobroLinea(lista, 1, pctProd);
    if (oferta > 0 && oferta < lista) {
      candidatos.push({
        oferta,
        pct: Math.round(pctProd),
        etiqueta: `−${Math.round(pctProd)}%`,
        leyenda: "Precio especial",
        fuente: "producto",
      });
    }
  }

  for (const promo of listaDePromos(promos)) {
    if (!promoVigente(promo, hoy)) continue;
    const oferta = precioDesdePromo(lista, promo);
    if (oferta == null) continue;
    const pct = lista > 0 ? Math.round((1 - oferta / lista) * 100) : 0;
    candidatos.push({
      oferta,
      pct,
      etiqueta: promo.tipo === "descuento_pct"
        ? `−${Math.round(Number(promo.valor) || pct)}%`
        : "Oferta",
      leyenda: String(promo.nombre || "").trim() || "Precio especial",
      fuente: "campaña",
    });
  }

  const best = candidatos.sort((a, b) => a.oferta - b.oferta)[0];
  if (!best) {
    return {
      lista,
      oferta: lista,
      hayOferta: false,
      pct: 0,
      etiqueta: null,
      leyenda: null,
      fuente: null,
      ahorro: 0,
    };
  }
  return {
    lista,
    oferta: best.oferta,
    hayOferta: true,
    pct: best.pct,
    etiqueta: best.etiqueta,
    leyenda: best.leyenda,
    fuente: best.fuente,
    ahorro: lista - best.oferta,
  };
}

export function mapaPromosPorProducto(promos, links, hoy = hoyISOMexico()) {
  const vigentes = new Map(
    (promos || []).filter((p) => promoVigente(p, hoy)).map((p) => [p.id, p])
  );
  const map = new Map();
  for (const row of links || []) {
    const pr = vigentes.get(row.promocion_id);
    if (!pr) continue;
    const pid = row.producto_id;
    const arr = map.get(pid) || [];
    arr.push(pr);
    map.set(pid, arr);
  }
  return map;
}
