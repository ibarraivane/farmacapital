'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const sharp = require('sharp');
const { runMiniaturasJob, rutaMiniatura, codificarRuta } = require('./miniaturasJob');

const SUPA = 'https://sb.test';

async function jpeg(width, height) {
  return sharp({ create: { width, height, channels: 3, background: '#3366cc' } }).jpeg().toBuffer();
}

function fakeStorage(archivos) {
  const subidas = new Map();
  const fetchImpl = async (url, init = {}) => {
    const ruta = decodeURIComponent(url.replace(`${SUPA}/storage/v1/object/productos/`, ''));
    if ((init.method || 'GET') === 'GET') {
      if (!archivos.has(ruta)) return { ok: false, status: 404, text: async () => '' };
      const buf = archivos.get(ruta);
      return { ok: true, status: 200, arrayBuffer: async () => buf };
    }
    subidas.set(ruta, { body: init.body, headers: init.headers });
    return { ok: true, status: 200, text: async () => '' };
  };
  return { fetchImpl, subidas };
}

test('rutaMiniatura y codificarRuta', () => {
  assert.equal(rutaMiniatura('rappi/7501/1.webp'), '_miniaturas/480/rappi/7501/1.webp.webp');
  assert.equal(codificarRuta('fc créma/a b.png'), 'fc%20cr%C3%A9ma/a%20b.png');
});

test('genera WebP de 480 px, no agranda, no toca la original y reporta errores', async () => {
  const archivos = new Map([
    ['7/desktop.jpg', await jpeg(1200, 900)],
    ['chica.jpg', await jpeg(200, 300)],
    ['rota.jpg', Buffer.from('no es imagen')],
  ]);
  const { fetchImpl, subidas } = fakeStorage(archivos);
  const rpcImpl = async (_k, _u, fn, payload) => {
    assert.equal(fn, 'fn_miniaturas_pendientes');
    assert.equal(payload.p_limite, 10);
    return [{ name: '7/desktop.jpg' }, { name: 'chica.jpg' }, { name: 'rota.jpg' }, { name: 'falta.jpg' }];
  };

  const r = await runMiniaturasJob({ supabaseUrl: SUPA, serviceKey: 'svc', limite: 10, fetchImpl, rpcImpl, sharpLib: sharp });

  assert.equal(r.hechas, 2);
  assert.equal(r.con_error, 2);
  assert.equal(r.quedan_mas, false);
  assert.deepEqual([...subidas.keys()].sort(), [
    '_miniaturas/480/7/desktop.jpg.webp',
    '_miniaturas/480/chica.jpg.webp',
  ]);

  const grande = await sharp(subidas.get('_miniaturas/480/7/desktop.jpg.webp').body).metadata();
  assert.equal(grande.format, 'webp');
  assert.equal(grande.width, 480);
  assert.equal(grande.height, 360);

  const chica = await sharp(subidas.get('_miniaturas/480/chica.jpg.webp').body).metadata();
  assert.equal(chica.width, 200);

  const h = subidas.get('_miniaturas/480/7/desktop.jpg.webp').headers;
  assert.equal(h['Content-Type'], 'image/webp');
  assert.equal(h['x-upsert'], 'true');

  // Ninguna escritura fuera de _miniaturas/
  for (const k of subidas.keys()) assert.ok(k.startsWith('_miniaturas/480/'));
});

test('lote lleno avisa que quedan más', async () => {
  const archivos = new Map([['a.jpg', await jpeg(600, 600)]]);
  const { fetchImpl } = fakeStorage(archivos);
  const rpcImpl = async () => [{ name: 'a.jpg' }];
  const r = await runMiniaturasJob({ supabaseUrl: SUPA, serviceKey: 'svc', limite: 1, fetchImpl, rpcImpl, sharpLib: sharp });
  assert.equal(r.hechas, 1);
  assert.equal(r.quedan_mas, true);
});
