/**
 * Política de dispensación de medicamentos — FUENTE ÚNICA para la tienda web.
 *
 * FAQ, Términos, ficha, tarjeta, catálogo, carrito y checkout leen de aquí.
 * No escribir textos de receta a mano en otros archivos.
 *
 * Espejo en servidor: tabla public.fc_politica_dispensacion y función
 * public.fc_validar_dispensacion_online (sql/patch_politica_dispensacion_*.sql).
 * Si cambias un switch aquí, cambia también la fila en esa tabla.
 *
 * Switches [CONFIGURABLE] (variables de entorno en Vercel):
 *   REACT_APP_ANTIBIOTICOS_CANAL_EN_LINEA   "habilitado" | "suspendido"   (default: habilitado)
 *   REACT_APP_ANTIBIOTICOS_ENVIO_DOMICILIO  "true" | "false"              (default: false)
 *
 * El switch controla el CANAL de venta. La receta de antibióticos se exige siempre
 * que se venda; lo que cambia es si se ofrece en línea y si puede ir a domicilio.
 * El procedimiento de surtido lo valida el responsable sanitario.
 */

import { esCategoriaAntibiotico, esMedicamentoControlado } from "../constants/categoriasProducto.js";

function strEnv(keys, fallback) {
  for (const k of keys) {
    const raw = typeof process !== "undefined" ? process.env?.[k] : undefined;
    if (raw == null || String(raw).trim() === "") continue;
    return String(raw).trim().toLowerCase();
  }
  return fallback;
}

export const CANAL_HABILITADO = "habilitado";
export const CANAL_SUSPENDIDO = "suspendido";

/** "habilitado" | "suspendido". Valores desconocidos → habilitado (no romper ventas por un typo). */
export function antibioticosCanalEnLinea() {
  const v = strEnv(
    ["REACT_APP_ANTIBIOTICOS_CANAL_EN_LINEA", "ANTIBIOTICOS_CANAL_EN_LINEA"],
    CANAL_HABILITADO
  );
  return v === CANAL_SUSPENDIDO ? CANAL_SUSPENDIDO : CANAL_HABILITADO;
}

/** ¿Se permite enviar antibióticos a domicilio? Default false: la receta se valida al recoger. */
export function antibioticosEnvioDomicilio() {
  const v = strEnv(
    ["REACT_APP_ANTIBIOTICOS_ENVIO_DOMICILIO", "ANTIBIOTICOS_ENVIO_DOMICILIO"],
    "false"
  );
  return v === "true" || v === "1" || v === "si" || v === "sí";
}

export const TIPO = Object.freeze({
  CONTROLADO: "controlado",
  ANTIBIOTICO: "antibiotico",
  RECETA: "receta",
  LIBRE: "libre",
});

function normEntrega(entrega) {
  const e = String(entrega ?? "").toLowerCase().trim();
  if (["envio", "envío", "domicilio", "delivery", "foraneo", "cdmx"].includes(e)) return "envio";
  return "recoger";
}

/**
 * Clasifica un producto y devuelve lo que la tienda debe hacer con él.
 * @param {object} prod  fila de productos (categoria, requiere_receta, controlado, grupo_controlado)
 * @param {object} [opts] { canal, envioAntibioticos } para pruebas; por defecto lee los switches.
 */
export function politicaProducto(prod, opts = {}) {
  const canal = opts.canal ?? antibioticosCanalEnLinea();
  const envioAb = opts.envioAntibioticos ?? antibioticosEnvioDomicilio();

  if (esMedicamentoControlado(prod)) {
    return {
      tipo: TIPO.CONTROLADO,
      requiereReceta: true,
      ventaEnLinea: false,
      envioDomicilio: false,
      etiquetaCorta: "Rx",
      etiqueta: "Controlado · solo en farmacia",
      avisoFicha:
        "Medicamento controlado. Se surte únicamente en farmacia con receta médica vigente, que la farmacia conserva.",
    };
  }

  if (esCategoriaAntibiotico(prod?.categoria)) {
    const enLinea = canal === CANAL_HABILITADO;
    return {
      tipo: TIPO.ANTIBIOTICO,
      requiereReceta: true,
      ventaEnLinea: enLinea,
      envioDomicilio: enLinea && envioAb,
      etiquetaCorta: "Rx",
      etiqueta: "Requiere receta",
      avisoFicha: !enLinea
        ? "Antibiótico. Por ahora se surte solo en farmacia, con receta médica vigente."
        : envioAb
          ? "Antibiótico. Requiere receta médica vigente; la farmacia la revisa y la registra al entregar."
          : "Antibiótico. Requiere receta médica vigente; la farmacia la revisa y la registra al recoger. Disponible solo para recoger en farmacia.",
    };
  }

  if (prod?.requiere_receta) {
    return {
      tipo: TIPO.RECETA,
      requiereReceta: true,
      ventaEnLinea: true,
      envioDomicilio: true,
      etiquetaCorta: "Rx",
      etiqueta: "Requiere receta",
      avisoFicha: "Requiere receta médica. Se solicita al entregar.",
    };
  }

  return {
    tipo: TIPO.LIBRE,
    requiereReceta: false,
    ventaEnLinea: true,
    envioDomicilio: true,
    etiquetaCorta: "",
    etiqueta: "",
    avisoFicha: "",
  };
}

/**
 * Valida un carrito contra la política para una entrega dada.
 * @returns {{ ok: boolean, bloqueados: Array<{prod, motivo}> , requiereReceta: boolean }}
 */
export function validarCarritoPolitica(items, entrega, opts = {}) {
  const tipoEntrega = normEntrega(entrega);
  const bloqueados = [];
  let requiereReceta = false;
  for (const it of items || []) {
    const prod = it?.prod ?? it;
    const pol = politicaProducto(prod, opts);
    if (pol.requiereReceta) requiereReceta = true;
    if (!pol.ventaEnLinea) {
      bloqueados.push({ prod, motivo: `${prod?.nombre || "Este producto"} se surte solo en farmacia.` });
    } else if (tipoEntrega === "envio" && !pol.envioDomicilio) {
      bloqueados.push({ prod, motivo: `${prod?.nombre || "Este producto"} está disponible solo para recoger en farmacia.` });
    }
  }
  return { ok: bloqueados.length === 0, bloqueados, requiereReceta };
}

/** Textos legales y de ayuda generados desde la política (no editarlos en Tienda.jsx). */
export function textosPolitica(opts = {}) {
  const canal = opts.canal ?? antibioticosCanalEnLinea();
  const envioAb = opts.envioAntibioticos ?? antibioticosEnvioDomicilio();
  const abEnLinea = canal === CANAL_HABILITADO;

  const antibioticos = !abEnLinea
    ? "Los antibióticos se surten solo en farmacia, con receta médica vigente."
    : envioAb
      ? "Los antibióticos requieren receta médica vigente, que revisamos y registramos al entregar."
      : "Los antibióticos requieren receta médica vigente y están disponibles solo para recoger en farmacia, donde revisamos y registramos la receta.";

  return {
    faqReceta:
      `Agrega el medicamento al carrito. Si requiere receta, la solicitamos al entregar. ${antibioticos} ` +
      "Los medicamentos controlados se surten solo en farmacia con receta original vigente.",
    terminosReceta:
      "Los medicamentos que requieren receta médica se entregan únicamente al presentar la receta vigente. " +
      `${antibioticos} ` +
      "Los medicamentos controlados no se venden en línea. FarmaCapital puede cancelar pedidos que no cumplan los requisitos sanitarios aplicables.",
    catalogoRx: abEnLinea
      ? "Mostrando medicamentos que requieren receta (Rx y antibióticos). Ten tu receta a la mano al recoger."
      : "Mostrando medicamentos que requieren receta. Los antibióticos se surten solo en farmacia.",
    carritoAviso:
      "Algunos productos no se venden en línea o solo pueden recogerse en farmacia (controlados y, según la política vigente, antibióticos). Si alguno se marca, quítalo o elige recoger en farmacia.",
  };
}
