/**
 * Aviso de anaquel para el POS: qué caja tomar.
 * No elige lote (eso es FEFO en el servidor). Solo dice la fecha.
 */

import { diasHastaCaducidad, esPorCaducar, etiquetaCaducidadIso } from "./caducidad";
import { ordenarLotesFefo, ymd } from "./precioVentaExclusivo";

function qtyLote(l) {
  return Number(l?.cantidad_actual ?? l?.cantidad_disponible ?? 0) || 0;
}

function cajasLabel(n) {
  const q = Number(n) || 0;
  return q === 1 ? "1 caja" : `${q} cajas`;
}

/** Lotes vendibles agrupados por mes/año, en orden FEFO. */
export function gruposCaducidadAnaquel(producto, hoy) {
  const lotes = ordenarLotesFefo(producto?.lotes || producto?.lotes_activos || [], hoy);
  const grupos = [];
  const porClave = new Map();
  for (const l of lotes) {
    const fecha = ymd(l.fecha_caducidad);
    const clave = fecha || "sin_fecha";
    let g = porClave.get(clave);
    if (!g) {
      g = {
        clave,
        fecha,
        cantidad: 0,
        etiqueta: fecha ? etiquetaCaducidadIso(fecha) : "sin fecha",
      };
      porClave.set(clave, g);
      grupos.push(g);
    }
    g.cantidad += qtyLote(l);
  }
  return grupos;
}

/**
 * Textos para ficha, carrito y tarjetas.
 * `multi` = hay más de una caducidad en anaquel (ahí sí hay que buscar).
 */
export function avisoLotesAnaquel(producto, hoy) {
  const grupos = gruposCaducidadAnaquel(producto, hoy);
  if (!grupos.length) {
    return {
      mostrar: false,
      multi: false,
      urgente: false,
      toma: null,
      otros: [],
      textoCorto: "",
      textoFichaTitulo: "",
      textoFichaOtros: "",
      textoCarrito: "",
    };
  }

  const toma = grupos[0];
  const otros = grupos.slice(1);
  const multi = grupos.length > 1;
  const dias = toma.fecha ? diasHastaCaducidad(toma.fecha, hoy) : null;
  const urgente = !toma.fecha || esPorCaducar(dias);

  let textoFichaTitulo;
  if (!toma.fecha) {
    textoFichaTitulo = `Toma las cajas sin fecha · ${cajasLabel(toma.cantidad)}`;
  } else if (multi) {
    textoFichaTitulo = `Toma el de ${toma.etiqueta} · ${cajasLabel(toma.cantidad)}`;
  } else {
    textoFichaTitulo = `Caduca ${toma.etiqueta} · ${cajasLabel(toma.cantidad)}`;
  }

  let textoFichaOtros = "";
  if (otros.length) {
    textoFichaOtros = `También hay ${otros.map((o) => `${o.etiqueta} · ${cajasLabel(o.cantidad)}`).join(" · ")}`;
  } else if (!toma.fecha) {
    textoFichaOtros = "Avisa para capturar MMAA. Si no, no se sabe qué caduca primero.";
  }

  const textoCorto = multi
    ? (toma.fecha ? `Toma ${toma.etiqueta}` : "Toma sin fecha")
    : "";

  let textoCarrito = "";
  if (multi) {
    textoCarrito = toma.fecha ? `Del anaquel: ${toma.etiqueta}` : "Del anaquel: sin fecha";
  } else if (toma.fecha) {
    textoCarrito = `Caduca ${toma.etiqueta}`;
  }

  return {
    mostrar: true,
    multi,
    urgente,
    toma,
    otros,
    textoCorto,
    textoFichaTitulo,
    textoFichaOtros,
    textoCarrito,
  };
}
