/**
 * INVENTARIO SERVICE - Llama directamente a Supabase
 * Sin Express, usando RPC y Supabase client
 */

import { supabase } from '../../supabase';

// ============================================================
// FLUJO 1: CREAR NUEVO PRODUCTO
// ============================================================
export async function crearNuevoProducto(datos) {
  const {
    codigo_barras,
    nombre,
    marca,
    presentacion,
    contenido,
    unidad = 'UNIT',
    precio,
    cantidad,
    caducidad,
    lote,
    categoria = 'GENERAL',
    proveedor = 'EQUILIBRIO FARMACEÚTICO'
  } = datos;

  try {
    const sku = `FC-${Date.now().toString().slice(-6)}`;

    // Usar función RPC de Supabase para crear producto + lote
    const { data, error } = await supabase.rpc('create_producto_with_lote', {
      p_producto: {
        sku,
        nombre,
        marca,
        codigo_barras,
        categoria,
        presentacion,
        contenido,
        precio: parseFloat(precio),
        costo: parseFloat(precio),
        proveedor,
        requiere_receta: false,
        activo: true,
        visible_tienda: true,
        tipo: 'MEDICAMENTO',
        descripcion: `${nombre} ${presentacion}`,
        unidad
      },
      p_cantidad: parseInt(cantidad),
      p_numero_lote: lote,
      p_fecha_caducidad: caducidad,
      p_costo_unitario: parseFloat(precio)
    });

    if (error) throw error;

    return {
      success: true,
      producto: data?.[0],
      mensaje: `Producto ${nombre} creado exitosamente`
    };
  } catch (error) {
    return {
      success: false,
      error: error.message
    };
  }
}

// ============================================================
// FLUJO 2: BUSCAR PRODUCTO EXISTENTE
// ============================================================
export async function buscarProducto(codigo_barras) {
  try {
    const { data, error } = await supabase
      .from('productos')
      .select('*')
      .eq('codigo_barras', codigo_barras)
      .single();

    if (error) {
      return {
        existe: false,
        error: 'Producto no encontrado'
      };
    }

    return {
      existe: true,
      producto: data
    };
  } catch (error) {
    return {
      existe: false,
      error: error.message
    };
  }
}

// ============================================================
// FLUJO 2: ACTUALIZAR STOCK
// ============================================================
export async function actualizarStock(datos) {
  const { codigo_barras, cantidad_adicional, caducidad, lote } = datos;

  try {
    // Buscar producto
    const { data: producto, error: searchError } = await supabase
      .from('productos')
      .select('*')
      .eq('codigo_barras', codigo_barras)
      .single();

    if (searchError || !producto) {
      throw new Error('Producto no encontrado');
    }

    // Crear nuevo lote
    const { error: loteError } = await supabase
      .from('lotes')
      .insert([{
        producto_id: producto.id,
        numero_lote: lote,
        cantidad_inicial: parseInt(cantidad_adicional),
        cantidad_actual: parseInt(cantidad_adicional),
        fecha_caducidad: caducidad,
        costo_unitario: producto.costo,
        activo: true
      }]);

    if (loteError) throw loteError;

    // Registrar movimiento
    const { error: movError } = await supabase
      .from('movimientos_inventario')
      .insert([{
        producto_id: producto.id,
        tipo: 'entrada',
        cantidad: parseInt(cantidad_adicional),
        motivo: 'Reabastecimiento - escaneo',
        usuario_id: null
      }]);

    if (movError) throw movError;

    // El trigger automático actualizará el stock en tabla productos
    const nuevo_stock = producto.stock + parseInt(cantidad_adicional);

    return {
      success: true,
      producto,
      nuevo_stock,
      mensaje: `Stock actualizado: ${nuevo_stock} unidades`
    };
  } catch (error) {
    return {
      success: false,
      error: error.message
    };
  }
}

// ============================================================
// FLUJO 3: PROCESAR PDF CON CLAUDE VISION (vía API backend)
// ============================================================
export async function procesarPDF(base64Data, proveedor = 'EQUILIBRIO FARMACEÚTICO') {
  try {
    const tok = sessionStorage.getItem("farmacapital_session_token");
    if (!tok) {
      throw new Error("Sesión expirada");
    }

    // Llamar a API backend para procesar PDF
    const response = await fetch("/api/inventarioProcesarPdf", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        session_token: tok,
        archivo_base64: base64Data,
        proveedor: proveedor
      })
    });

    const respuesta = await response.json();

    if (!response.ok) {
      throw new Error(respuesta?.error || "Error procesando PDF");
    }

    const datos_pdf = {
      productos: respuesta.productos || []
    };

    // Los productos ya fueron creados por la API backend
    const productos_creados = respuesta.productos || [];

    return {
      success: true,
      total_procesados: productos_creados.length,
      productos: productos_creados,
      mensaje: `${productos_creados.length} productos cargados desde PDF`
    };
  } catch (error) {
    return {
      success: false,
      error: error.message
    };
  }
}

// ============================================================
// HELPER: Leer archivo como base64
// ============================================================
export function fileToBase64(file) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => {
      const base64 = reader.result.split(',')[1];
      resolve(base64);
    };
    reader.onerror = reject;
    reader.readAsDataURL(file);
  });
}
