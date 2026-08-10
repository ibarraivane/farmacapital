import React, { useState, useEffect, useRef } from 'react';
import './inventario.css';
import { crearNuevoProducto, buscarProducto, actualizarStock as actualizarStockProducto, procesarPDF, fileToBase64 } from './inventarioService';

export default function InventarioModule() {
  const [activeTab, setActiveTab] = useState('escaneo');
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState('');
  const scanInputRef = useRef(null);

  // FLUJO 1: NUEVO PRODUCTO MANUAL
  const [nuevoProducto, setNuevoProducto] = useState({
    codigo_barras: '',
    nombre: '',
    marca: '',
    presentacion: '',
    contenido: '',
    unidad: 'UNIT',
    precio: '',
    cantidad: '1',
    caducidad: '',
    lote: ''
  });

  // FLUJO 2: PRODUCTO EXISTENTE
  const [productoExistente, setProductoExistente] = useState(null);
  const [buscandoProducto, setBuscandoProducto] = useState(false);
  const [actualizarStock, setActualizarStock] = useState({
    cantidad_adicional: '1',
    caducidad: '',
    lote: ''
  });

  // FLUJO 3: PDF
  const [pdfData, setPdfData] = useState(null);
  const [previewPDF, setPreviewPDF] = useState([]);
  const [pdfProcesando, setPdfProcesando] = useState(false);

  // ==================== FLUJO 1: NUEVO PRODUCTO ====================
  const handleNuevoProductoChange = (e) => {
    const { name, value } = e.target;
    setNuevoProducto(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleCrearNuevoProducto = async () => {
    try {
      setLoading(true);
      const result = await crearNuevoProducto(nuevoProducto);

      if (result.success) {
        setMessage(`✓ ${result.mensaje}`);
        setNuevoProducto({
          codigo_barras: '',
          nombre: '',
          marca: '',
          presentacion: '',
          contenido: '',
          unidad: 'UNIT',
          precio: '',
          cantidad: '1',
          caducidad: '',
          lote: ''
        });
        setTimeout(() => scanInputRef.current?.focus(), 100);
      } else {
        setMessage(`✗ Error: ${result.error}`);
      }
    } catch (error) {
      setMessage(`✗ Error: ${error.message}`);
    } finally {
      setLoading(false);
    }
  };

  // ==================== FLUJO 2: PRODUCTO EXISTENTE ====================
  const handleBuscarProducto = async (codigo) => {
    if (!codigo) return;

    try {
      setBuscandoProducto(true);
      const result = await buscarProducto(codigo);

      if (result.existe) {
        setProductoExistente(result.producto);
        setMessage('✓ Producto encontrado');
      } else {
        setProductoExistente(null);
        setMessage('✗ Producto no encontrado - cambiar a Escaneo Manual');
      }
    } catch (error) {
      setMessage(`✗ Error: ${error.message}`);
    } finally {
      setBuscandoProducto(false);
    }
  };

  const handleActualizarProductoStock = async () => {
    try {
      setLoading(true);
      const result = await actualizarStockProducto({
        codigo_barras: productoExistente.codigo_barras,
        ...actualizarStock
      });

      if (result.success) {
        setMessage(`✓ Stock actualizado: ${result.nuevo_stock} unidades`);
        setProductoExistente(null);
        setActualizarStock({
          cantidad_adicional: '1',
          caducidad: '',
          lote: ''
        });
      } else {
        setMessage(`✗ Error: ${result.error}`);
      }
    } catch (error) {
      setMessage(`✗ Error: ${error.message}`);
    } finally {
      setLoading(false);
    }
  };

  // ==================== FLUJO 3: PDF ====================
  const handlePDFUpload = async (e) => {
    const file = e.target.files[0];
    if (!file) return;

    try {
      setPdfProcesando(true);
      const base64 = await fileToBase64(file);

      const result = await procesarPDF(base64, 'EQUILIBRIO FARMACEÚTICO');

      if (result.success) {
        setPreviewPDF(result.productos);
        setMessage(`✓ ${result.mensaje}`);
        setPdfData(file.name);
      } else {
        setMessage(`✗ Error: ${result.error}`);
      }
    } catch (error) {
      setMessage(`✗ Error: ${error.message}`);
    } finally {
      setPdfProcesando(false);
    }
  };

  // ==================== RENDER ====================
  return (
    <div className="inventario-container">
      <div className="inventario-header">
        <h1>📦 Inventario - Ingreso de Productos</h1>
        <p>Escanea, busca o carga PDFs para agregar productos</p>
      </div>

      <div className="inventario-tabs">
        {['escaneo', 'existente', 'pdf'].map(tab => (
          <button
            key={tab}
            className={`tab ${activeTab === tab ? 'active' : ''}`}
            onClick={() => {
              setActiveTab(tab);
              setMessage('');
              setProductoExistente(null);
            }}
          >
            {tab === 'escaneo' && '🔍 Escaneo Manual'}
            {tab === 'existente' && '✓ Producto Existente'}
            {tab === 'pdf' && '📄 Cargar PDF'}
          </button>
        ))}
      </div>

      {/* FLUJO 1: ESCANEO MANUAL */}
      {activeTab === 'escaneo' && (
        <div className="inventario-form">
          <div className="form-group">
            <label>Escanear código de barras</label>
            <input
              ref={scanInputRef}
              type="text"
              name="codigo_barras"
              placeholder="Escanea o escribe el código..."
              value={nuevoProducto.codigo_barras}
              onChange={handleNuevoProductoChange}
              autoFocus
            />
          </div>

          <div className="form-group">
            <label>Nombre del producto</label>
            <input
              type="text"
              name="nombre"
              placeholder="ej: AMOXICILINA 500MG"
              value={nuevoProducto.nombre}
              onChange={handleNuevoProductoChange}
            />
          </div>

          <div className="form-group">
            <label>Marca</label>
            <input
              type="text"
              name="marca"
              placeholder="ej: FARMALAB"
              value={nuevoProducto.marca}
              onChange={handleNuevoProductoChange}
            />
          </div>

          <div className="form-row">
            <div className="form-group">
              <label>Presentación</label>
              <input
                type="text"
                name="presentacion"
                placeholder="ej: 40 CAPS"
                value={nuevoProducto.presentacion}
                onChange={handleNuevoProductoChange}
              />
            </div>
            <div className="form-group">
              <label>Contenido</label>
              <input
                type="text"
                name="contenido"
                placeholder="ej: 500MG"
                value={nuevoProducto.contenido}
                onChange={handleNuevoProductoChange}
              />
            </div>
          </div>

          <div className="form-row">
            <div className="form-group">
              <label>Precio</label>
              <input
                type="number"
                name="precio"
                placeholder="$0.00"
                step="0.01"
                value={nuevoProducto.precio}
                onChange={handleNuevoProductoChange}
              />
            </div>
            <div className="form-group">
              <label>Cantidad</label>
              <input
                type="number"
                name="cantidad"
                placeholder="0"
                value={nuevoProducto.cantidad}
                onChange={handleNuevoProductoChange}
              />
            </div>
          </div>

          <div className="form-row">
            <div className="form-group">
              <label>Caducidad</label>
              <input
                type="date"
                name="caducidad"
                value={nuevoProducto.caducidad}
                onChange={handleNuevoProductoChange}
              />
            </div>
            <div className="form-group">
              <label>Lote</label>
              <input
                type="text"
                name="lote"
                placeholder="ej: LOTE-2028-001"
                value={nuevoProducto.lote}
                onChange={handleNuevoProductoChange}
              />
            </div>
          </div>

          <div className="form-buttons">
            <button
              className="btn-primary"
              onClick={handleCrearNuevoProducto}
              disabled={loading}
            >
              {loading ? 'Guardando...' : 'Guardar Producto'}
            </button>
            <button
              className="btn-secondary"
              onClick={() => {
                setNuevoProducto({
                  codigo_barras: '',
                  nombre: '',
                  marca: '',
                  presentacion: '',
                  contenido: '',
                  unidad: 'UNIT',
                  precio: '',
                  cantidad: '1',
                  caducidad: '',
                  lote: ''
                });
                setMessage('');
              }}
            >
              Limpiar
            </button>
          </div>
        </div>
      )}

      {/* FLUJO 2: PRODUCTO EXISTENTE */}
      {activeTab === 'existente' && (
        <div className="inventario-form">
          <div className="form-group">
            <label>Escanear código de barras</label>
            <input
              type="text"
              placeholder="Escanea el código..."
              autoFocus
              onKeyPress={(e) => {
                if (e.key === 'Enter') {
                  handleBuscarProducto(e.target.value);
                  e.target.value = '';
                }
              }}
            />
          </div>

          {productoExistente && (
            <>
              <div className="producto-card">
                <div className="producto-nombre">{productoExistente.nombre}</div>
                <div className="producto-meta">
                  Marca: {productoExistente.marca} • SKU: {productoExistente.sku}
                </div>
                <div className="producto-meta">
                  Stock actual: {productoExistente.stock} unidades • Precio: ${productoExistente.precio.toFixed(2)}
                </div>
              </div>

              <div className="form-row">
                <div className="form-group">
                  <label>Cantidad adicional</label>
                  <input
                    type="number"
                    placeholder="ej: 5"
                    value={actualizarStock.cantidad_adicional}
                    onChange={(e) => setActualizarStock(prev => ({
                      ...prev,
                      cantidad_adicional: e.target.value
                    }))}
                  />
                </div>
                <div className="form-group">
                  <label>Caducidad</label>
                  <input
                    type="date"
                    value={actualizarStock.caducidad}
                    onChange={(e) => setActualizarStock(prev => ({
                      ...prev,
                      caducidad: e.target.value
                    }))}
                  />
                </div>
              </div>

              <div className="form-group">
                <label>Lote</label>
                <input
                  type="text"
                  placeholder="ej: LOTE-2028-001"
                  value={actualizarStock.lote}
                  onChange={(e) => setActualizarStock(prev => ({
                    ...prev,
                    lote: e.target.value
                  }))}
                />
              </div>

              <div className="form-buttons">
                <button
                  className="btn-primary"
                  onClick={handleActualizarProductoStock}
                  disabled={loading}
                >
                  {loading ? 'Actualizando...' : 'Confirmar + Actualizar Stock'}
                </button>
                <button
                  className="btn-secondary"
                  onClick={() => {
                    setProductoExistente(null);
                    setActualizarStock({
                      cantidad_adicional: '1',
                      caducidad: '',
                      lote: ''
                    });
                  }}
                >
                  Cancelar
                </button>
              </div>
            </>
          )}
        </div>
      )}

      {/* FLUJO 3: PDF */}
      {activeTab === 'pdf' && (
        <div className="inventario-form">
          <div className="form-group">
            <label>Cargar PDF del proveedor</label>
            <div className="pdf-upload">
              <input
                type="file"
                accept=".pdf"
                onChange={handlePDFUpload}
                disabled={pdfProcesando}
                id="pdf-input"
              />
              <label htmlFor="pdf-input" className="upload-label">
                <div className="upload-icon">📄</div>
                <div className="upload-text">
                  {pdfProcesando ? 'Procesando...' : 'Arrastra un PDF aquí o haz clic'}
                </div>
              </label>
            </div>
          </div>

          {previewPDF.length > 0 && (
            <div className="pdf-preview">
              <div className="preview-header">
                Preview: {previewPDF.length} productos detectados
              </div>
              <div className="preview-items">
                {previewPDF.slice(0, 10).map((prod, idx) => (
                  <div key={idx} className="preview-item">
                    <div className="preview-nombre">{prod.nombre}</div>
                    <div className="preview-meta">
                      {prod.cantidad} × ${prod.precio?.toFixed(2) || '0.00'}
                    </div>
                  </div>
                ))}
                {previewPDF.length > 10 && (
                  <div className="preview-more">
                    +{previewPDF.length - 10} productos más
                  </div>
                )}
              </div>
            </div>
          )}
        </div>
      )}

      {/* MENSAJE DE ESTADO */}
      {message && (
        <div className={`message ${message.includes('✓') ? 'success' : 'error'}`}>
          {message}
        </div>
      )}
    </div>
  );
}
