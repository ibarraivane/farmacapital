'use strict';

const { describe, it, beforeEach } = require('node:test');
const assert = require('node:assert/strict');
const {
  digitsCp,
  coloniasFromZippopotam,
  lookupColoniasByCp,
  __resetColoniasCache,
} = require('./sepomexColonias');

describe('sepomexColonias', () => {
  beforeEach(() => {
    __resetColoniasCache();
  });

  it('digitsCp deja 5 números', () => {
    assert.equal(digitsCp('06700'), '06700');
    assert.equal(digitsCp('CP 06700'), '06700');
    assert.equal(digitsCp('12'), '12');
  });

  it('arma colonias desde Zippopotam', () => {
    const list = coloniasFromZippopotam({
      places: [
        { 'place name': 'Roma Norte' },
        { 'place name': 'Roma Norte' },
        { place_name: 'Juárez' },
      ],
    });
    assert.deepEqual(list, ['Juárez', 'Roma Norte']);
  });

  it('06700 → Roma Norte (mock)', async () => {
    const result = await lookupColoniasByCp('06700', {
      fetchFn: async () => ({
        ok: true,
        status: 200,
        json: async () => ({
          'post code': '06700',
          places: [{ 'place name': 'Roma Norte', state: 'Mexico City' }],
        }),
      }),
    });
    assert.equal(result.ok, true);
    assert.deepEqual(result.colonias, ['Roma Norte']);
  });

  it('03100 puede traer más de una colonia', async () => {
    const result = await lookupColoniasByCp('03100', {
      fetchFn: async () => ({
        ok: true,
        status: 200,
        json: async () => ({
          places: [
            { 'place name': 'Del Valle Centro' },
            { 'place name': 'Insurgentes San Borja' },
          ],
        }),
      }),
    });
    assert.equal(result.colonias.length, 2);
    assert.ok(result.colonias.includes('Del Valle Centro'));
  });

  it('CP incompleto no pega a la red', async () => {
    let called = false;
    const result = await lookupColoniasByCp('031', {
      fetchFn: async () => {
        called = true;
        return { ok: true, status: 200, json: async () => ({}) };
      },
    });
    assert.equal(called, false);
    assert.equal(result.ok, false);
    assert.equal(result.error, 'cp_invalid');
  });

  it('404 de Zippopotam es lista vacía, no error', async () => {
    const result = await lookupColoniasByCp('00000', {
      fetchFn: async () => ({ ok: false, status: 404, json: async () => ({}) }),
    });
    assert.equal(result.ok, true);
    assert.deepEqual(result.colonias, []);
  });
});
