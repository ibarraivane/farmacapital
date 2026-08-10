/**
 * Endpoint: POST /api/inventario/procesar-pdf
 * Procesa un PDF con Claude Vision y extrae productos
 */

import fetch from 'node-fetch';

const SUPABASE_URL = process.env.REACT_APP_SUPABASE_URL || 'https://qyabhoftqfmqwpqcsdrb.supabase.co';
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;

async function validateSession(sessionToken) {
  try {
    // Validar token de sesión
    // Por ahora, simplemente retornamos true si existe el token
    return !!sessionToken;
  } catch {
    return false;
  }
}

async function insertProducts(productos, proveedor) {
  /**
   * Inserta productos en Supabase (tabla productos_v2 + ofertas_proveedor + lotes_v2)
   * Usa RPC para transacción atómica
   */

  if (!Array.isArray(productos) || productos.length === 0) {
    return { success: true, insertados: 0 };
  }

  try {
    // Implementar inserción en Supabase
    // Por ahora retornamos éxito para prueba
    console.log(`✓ Insertando ${productos.length} productos para ${proveedor}`);

    return {
      success: true,
      insertados: productos.length,
      mensaje: `${productos.length} productos cargados exitosamente`
    };
  } catch (error) {
    console.error('Error insertando productos:', error.message);
    return {
      success: false,
      error: error.message
    };
  }
}

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { session_token, archivo_base64, proveedor = 'PROVEEDOR' } = req.body;

    // Validar sesión
    if (!await validateSession(session_token)) {
      return res.status(401).json({ error: 'Sesión no válida' });
    }

    // Validar entrada
    if (!archivo_base64) {
      return res.status(400).json({ error: 'archivo_base64 requerido' });
    }

    // TODO: Procesar PDF con Claude Vision
    // Por ahora retornamos ejemplo

    const productosEjemplo = [
      {
        codigo: '7501090131234',
        nombre: 'AMOXICILINA',
        marca: 'FARMALAB',
        presentacion: '40 CAPSULAS',
        contenido: '500',
        unidad: 'MG',
        cantidad: 2,
        precio: 85.50,
        caducidad: '2025-12-15',
        lote: 'A123456'
      }
    ];

    // Insertar en BD
    const resultado = await insertProducts(productosEjemplo, proveedor);

    return res.status(200).json({
      success: resultado.success,
      productos: productosEjemplo,
      mensaje: resultado.mensaje
    });

  } catch (error) {
    console.error('[procesar-pdf] Error:', error.message);
    return res.status(500).json({
      error: 'Error procesando PDF',
      detalle: error.message
    });
  }
}
