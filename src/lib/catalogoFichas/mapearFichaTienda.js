import { descripcionPublicaTienda } from "../../utils/tiendaFarmaciaCatalogo";

function texto(v) {
  return v == null ? "" : String(v).trim();
}

function lista(v) {
  if (!Array.isArray(v)) return [];
  return v.map((x) => texto(x)).filter(Boolean);
}

function publicado(row) {
  return row && String(row.estado || "").toLowerCase() === "publicado";
}

/**
 * Arma el modelo de UI. Solo usa contenido `publicado`.
 * Sin ficha publicada: ficha técnica + WhatsApp, sin acordeones clínicos.
 */
export function mapearFichaTienda({ producto, ficha, monografia } = {}) {
  const prod = producto || {};
  const fichaOk = publicado(ficha) ? ficha : null;
  const monoOk = publicado(monografia) ? monografia : null;
  const contenidoFicha = fichaOk?.contenido && typeof fichaOk.contenido === "object" ? fichaOk.contenido : {};
  const contenidoMono = monoOk?.contenido && typeof monoOk.contenido === "object" ? monoOk.contenido : {};
  const fabricante = contenidoFicha.fabricante && typeof contenidoFicha.fabricante === "object"
    ? contenidoFicha.fabricante
    : null;

  const resumen = texto(contenidoFicha.resumen)
    || texto(contenidoMono.resumen)
    || descripcionPublicaTienda(prod)
    || "";

  const chips = lista(contenidoFicha.chips);
  const tipo = fichaOk?.tipo_ficha || (monoOk ? "medicamento" : null);
  const tieneClinica = Boolean(
    tipo === "medicamento"
    && monoOk
    && (texto(contenidoMono.para_que_sirve) || lista(contenidoMono.como_se_usa).length)
  );
  const tieneFabricante = Boolean(
    fabricante
    && (texto(fabricante.descripcion)
      || texto(fabricante.inci_completo)
      || lista(fabricante.modo_de_uso).length
      || lista(fabricante.ingredientes_destacados).length)
  );

  const fichaTecnica = [
    { k: "Sustancia activa", v: texto(prod.principio_activo) },
    { k: "Concentración", v: texto(prod.concentracion) },
    { k: "Forma farmacéutica", v: texto(prod.forma_farmaceutica) },
    { k: "Presentación", v: texto(prod.presentacion) },
    { k: "Laboratorio", v: texto(prod.marca) },
    { k: "Registro sanitario", v: texto(fichaOk?.registro_sanitario) },
    { k: "Tipo de venta", v: prod.requiere_receta ? "Con receta médica" : (prod.requiere_receta === false ? "Sin receta" : "") },
    { k: "Código de barras", v: texto(prod.codigo_barras) },
  ].filter((row) => row.v);

  return {
    publicada: Boolean(fichaOk || monoOk),
    tipo,
    resumen,
    chips,
    clinica: tieneClinica ? {
      para_que_sirve: texto(contenidoMono.para_que_sirve),
      como_se_usa: lista(contenidoMono.como_se_usa),
      no_usar_si: lista(contenidoMono.no_usar_si),
      consulta_si: lista(contenidoMono.consulta_si),
      interacciones: texto(contenidoMono.interacciones),
      efectos: lista(contenidoMono.efectos),
      alarma: texto(contenidoMono.alarma),
      conservacion: lista(contenidoMono.conservacion),
    } : null,
    fabricante: tieneFabricante ? {
      descripcion: texto(fabricante.descripcion),
      para_quien: fabricante.para_quien && typeof fabricante.para_quien === "object" ? fabricante.para_quien : null,
      modo_de_uso: lista(fabricante.modo_de_uso),
      ingredientes_destacados: lista(fabricante.ingredientes_destacados),
      inci_completo: texto(fabricante.inci_completo),
      precauciones: lista(fabricante.precauciones),
      tabla_nutrimental: fabricante.tabla_nutrimental || null,
    } : null,
    instructivo_url: texto(fichaOk?.instructivo_url) || "",
    fichaTecnica,
    leyendaLegal: tipo === "medicamento"
      ? "Tomada del instructivo autorizado del producto."
      : "Información del fabricante.",
    mostrarSoloTecnica: !tieneClinica && !tieneFabricante,
  };
}

export function seccionesClinicasVisibles(clinica) {
  if (!clinica) return [];
  const out = [];
  if (texto(clinica.para_que_sirve)) out.push({ id: "para", titulo: "¿Para qué sirve?", abierta: true });
  if (clinica.como_se_usa?.length) out.push({ id: "uso", titulo: "¿Cómo se toma?", abierta: false });
  if (clinica.no_usar_si?.length || clinica.consulta_si?.length) {
    out.push({ id: "antes", titulo: "Antes de tomarlo", abierta: false });
  }
  if (texto(clinica.interacciones)) out.push({ id: "inter", titulo: "Interacciones", abierta: false });
  if (clinica.efectos?.length || texto(clinica.alarma)) {
    out.push({ id: "efectos", titulo: "Posibles efectos secundarios", abierta: false });
  }
  if (clinica.conservacion?.length) out.push({ id: "cons", titulo: "Cómo guardarlo", abierta: false });
  return out;
}
