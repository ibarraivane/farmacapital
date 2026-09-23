"use strict";

/**
 * Reexporta la regla de reseñas. La implementación vive en
 * resenasProductoCore.cjs para que el correo (Node) y la tienda usen la misma.
 */
module.exports = require("./resenasProductoCore.cjs");
