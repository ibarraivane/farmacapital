/**
 * Reexporta la regla de reseñas. La implementación vive en
 * resenasProductoCore.js para que el correo (Node) y la tienda usen la misma.
 *
 * Tiene que ser .js. Webpack trata un .cjs como archivo estático (la URL),
 * y entonces resumenVisible no es una función y la tienda no arranca.
 */
import core from "./resenasProductoCore";

export const CATEGORIAS_CON_RESENA = core.CATEGORIAS_CON_RESENA;
export const motivoSinResena = core.motivoSinResena;
export const productoAceptaResena = core.productoAceptaResena;
export const promedioResenas = core.promedioResenas;
export const textoPromedio = core.textoPromedio;
export const resumenVisible = core.resumenVisible;
