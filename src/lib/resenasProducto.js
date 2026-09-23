/**
 * Reexporta la regla de reseñas. La implementación vive en
 * resenasProductoCore.cjs para que el correo (Node) y la tienda usen la misma.
 *
 * El build de la tienda (webpack) no sigue `module.exports = require(...)`:
 * las importaciones con nombre salían vacías y el deploy fallaba.
 */
import core from "./resenasProductoCore.cjs";

export const CATEGORIAS_CON_RESENA = core.CATEGORIAS_CON_RESENA;
export const motivoSinResena = core.motivoSinResena;
export const productoAceptaResena = core.productoAceptaResena;
export const promedioResenas = core.promedioResenas;
export const textoPromedio = core.textoPromedio;
export const resumenVisible = core.resumenVisible;
