/**
 * Dashboard de Validación de Precios
 * Muestra productos con warnings (precio alto/bajo)
 * Permite actualizar precios directamente
 */

import React, { useState, useEffect } from 'react';
import { supabase } from '../../supabase';

const ProductosValidacionDashboard = () => {
  const [productos, setProductos] = useState([]);
  const [warnings, setWarnings] = useState([]);
  const [filtro, setFiltro] = useState('TODOS');
  const [cargando, setCargando] = useState(true);

  useEffect(() => {
    cargarReporte();
  }, []);

  const cargarReporte = async () => {
    try {
      // En desarrollo: leer del archivo generado
      const response = await fetch('/scripts/reports/analisis_productos.json');
      if (response.ok) {
        const data = await response.json();
        setProductos(data.productos);
        setWarnings(data.warnings);
      }
    } catch (e) {
      console.error('Error cargando reporte:', e);
    } finally {
      setCargando(false);
    }
  };

  const actualizarPrecio = async (productoId, nuevoPrecio) => {
    try {
      const { error } = await supabase
        .from('productos')
        .update({ precio: nuevoPrecio })
        .eq('id', productoId);

      if (error) throw error;

      alert('✓ Precio actualizado');
      cargarReporte();
    } catch (error) {
      alert(`✗ Error: ${error.message}`);
    }
  };

  const productosConWarning = productos.filter(p => p.tiene_warning);

  return (
    <div style={estilos.container}>
      <h2>📊 Validación de Precios</h2>

      {/* Filtros */}
      <div style={estilos.filtros}>
        <button
          onClick={() => setFiltro('TODOS')}
          style={{
            ...estilos.btn,
            background: filtro === 'TODOS' ? '#3498db' : '#95a5a6'
          }}
        >
          Todos ({productos.length})
        </button>
        <button
          onClick={() => setFiltro('WARNINGS')}
          style={{
            ...estilos.btn,
            background: filtro === 'WARNINGS' ? '#e74c3c' : '#95a5a6'
          }}
        >
          ⚠️ Warnings ({productosConWarning.length})
        </button>
        <button
          onClick={() => setFiltro('PRECIO_ALTO')}
          style={{
            ...estilos.btn,
            background: filtro === 'PRECIO_ALTO' ? '#c0392b' : '#95a5a6'
          }}
        >
          🔴 Precio Alto ({warnings.filter(w => w.warning === 'PRECIO_ALTO').length})
        </button>
      </div>

      {/* Tabla */}
      <div style={estilos.tabla}>
        <thead>
          <tr>
            <th>Nombre</th>
            <th>Costo</th>
            <th>Precio Actual</th>
            <th>Precio Sugerido</th>
            <th>Margen</th>
            <th>Diferencia</th>
            <th>Acción</th>
          </tr>
        </thead>
        <tbody>
          {(filtro === 'TODOS' ? productos : productosConWarning).map(prod => (
            <tr
              key={prod.id}
              style={{
                background:
                  prod.tipo_warning === 'PRECIO_ALTO' ? '#ffe0e0' :
                  prod.tipo_warning === 'PRECIO_BAJO' ? '#fff4e6' :
                  'white',
                borderLeft: prod.tipo_warning ? `4px solid ${
                  prod.tipo_warning === 'PRECIO_ALTO' ? '#c0392b' : '#f39c12'
                }` : 'none'
              }}
            >
              <td style={estilos.tdNombre}>
                {prod.nombre}
                <br />
                <small>{prod.marca}</small>
              </td>
              <td>${prod.costo?.toFixed(2)}</td>
              <td>${prod.precio_actual?.toFixed(2)}</td>
              <td style={{ fontWeight: 'bold', color: '#27ae60' }}>
                ${prod.precio_sugerido?.toFixed(2)}
              </td>
              <td>{prod.margen_aplicado}</td>
              <td style={{
                color: prod.tipo_warning === 'PRECIO_ALTO' ? '#c0392b' : '#f39c12',
                fontWeight: 'bold'
              }}>
                {prod.tipo_warning ? `${prod.diferencia_porcentaje > 0 ? '+' : ''}${prod.diferencia_porcentaje}%` : '✓'}
              </td>
              <td>
                <button
                  onClick={() => {
                    const nuevo = prompt('Nuevo precio:', prod.precio_sugerido);
                    if (nuevo) actualizarPrecio(prod.id, parseFloat(nuevo));
                  }}
                  style={estilos.btnActualizar}
                >
                  Actualizar
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </div>

      {/* Resumen */}
      <div style={estilos.resumen}>
        <div style={estilos.card}>
          <h3>💰 Resumen</h3>
          <p>Total de productos: {productos.length}</p>
          <p style={{ color: '#e74c3c' }}>Warnings: {productosConWarning.length}</p>
          <p style={{ color: '#c0392b' }}>
            Precio alto: {warnings.filter(w => w.warning === 'PRECIO_ALTO').length}
          </p>
        </div>
      </div>
    </div>
  );
};

const estilos = {
  container: {
    padding: '20px',
    maxWidth: '1400px',
    margin: '0 auto',
    fontFamily: 'system-ui, -apple-system, sans-serif'
  },
  filtros: {
    display: 'flex',
    gap: '10px',
    marginBottom: '20px'
  },
  btn: {
    padding: '10px 15px',
    border: 'none',
    borderRadius: '6px',
    color: 'white',
    cursor: 'pointer',
    fontSize: '14px',
    fontWeight: 'bold'
  },
  tabla: {
    width: '100%',
    borderCollapse: 'collapse',
    background: 'white',
    borderRadius: '8px',
    overflow: 'hidden',
    boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
    display: 'table'
  },
  tdNombre: {
    paddingTop: '12px',
    paddingBottom: '12px',
    textAlign: 'left'
  },
  btnActualizar: {
    padding: '6px 12px',
    background: '#3498db',
    color: 'white',
    border: 'none',
    borderRadius: '4px',
    cursor: 'pointer',
    fontSize: '12px'
  },
  resumen: {
    display: 'grid',
    gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))',
    gap: '20px',
    marginTop: '20px'
  },
  card: {
    background: 'white',
    padding: '15px',
    borderRadius: '8px',
    boxShadow: '0 2px 8px rgba(0,0,0,0.1)'
  }
};

export default ProductosValidacionDashboard;
