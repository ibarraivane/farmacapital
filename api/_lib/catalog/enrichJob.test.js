'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const {
  payloadSeguroParaAgente,
  validarResultadoEnriquecimiento,
  foldClave,
  procesarUnJob,
} = require('./enrichJob');

test('payload del job no incluye costo ni proveedor', () => {
  const p = payloadSeguroParaAgente({
    id: 1,
    nombre: 'Omeprazol',
    costo: 9,
    proveedor: 'Nadro',
    precio: 40,
    codigo_barras: '750',
  });
  assert.equal(p.nombre, 'Omeprazol');
  assert.equal(JSON.stringify(p).includes('costo'), false);
  assert.equal(JSON.stringify(p).includes('proveedor'), false);
});

test('foldClave normaliza acentos y +', () => {
  assert.equal(foldClave('Amoxicilina / Ácido clavulánico'), 'amoxicilina + acido clavulanico');
});

test('JSON sin fuente por sección queda en error', () => {
  const r = validarResultadoEnriquecimiento({
    tipo_ficha: 'medicamento',
    monografia: {
      clave: 'omeprazol',
      via: 'oral',
      contenido: { resumen: 'x', para_que_sirve: 'y' },
    },
    fuentes: [],
    faltantes: [],
  });
  assert.equal(r.ok, false);
});

test('procesarUnJob liga monografía publicada y valida JSON', async () => {
  const calls = [];
  const origFetch = global.fetch;
  global.fetch = async (url, opts) => {
    calls.push({ url: String(url), method: opts && opts.method });
    if (String(url).includes('/productos')) {
      return {
        ok: true,
        json: async () => [{
          id: 7,
          nombre: 'Omeprazol 20 mg',
          marca: 'Ultra',
          codigo_barras: '7501',
          principio_activo: 'Omeprazol',
          forma_farmaceutica: 'Cápsula',
          requiere_receta: false,
        }],
      };
    }
    if (String(url).includes('/monografias')) {
      return { ok: true, json: async () => [{ id: 3, clave: 'omeprazol', via: 'oral', contenido: {} }] };
    }
    return { ok: true, json: async () => [] };
  };
  try {
    const out = await procesarUnJob({
      job: { producto_id: 7 },
      supabaseUrl: 'https://example.supabase.co',
      serviceKey: 'svc',
      apiKey: 'k',
      imageSearch: async () => [{ url: 'https://off.example/a.jpg', origen: 'openfacts', licencia: 'CC BY-SA' }],
      research: async ({ payload }) => {
        assert.equal(payload.nombre, 'Omeprazol 20 mg');
        assert.equal(JSON.stringify(payload).includes('costo'), false);
        return {
          tokens: 12,
          parsed: {
            tipo_ficha: 'medicamento',
            monografia: null,
            producto: { resumen: 'Cápsulas 20 mg', chips: ['Sin receta'] },
            fuentes: [{
              url: 'https://lab.example/ipp',
              tipo: 'instructivo',
              titulo: 'IPP',
              consultado: '2026-09-21',
              campos: ['resumen'],
            }],
            faltantes: [],
            imagenes: [],
          },
        };
      },
    });
    assert.equal(out.resultado.producto.resumen, 'Cápsulas 20 mg');
    assert.equal(out.resultado.monografia, null);
    assert.ok(out.resultado.imagenes.length >= 1);
  } finally {
    global.fetch = origFetch;
  }
});
