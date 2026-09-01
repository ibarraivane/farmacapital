'use strict';

const { describe, it } = require('node:test');
const assert = require('node:assert/strict');
const {
  normalizeSuggestion,
  streetFromGoogleComponents,
  coloniaFromGoogleComponents,
  suggestAddresses,
} = require('./addressSuggest');

describe('addressSuggest', () => {
  it('arma calle desde components de Google', () => {
    const components = [
      { long_name: '1750', types: ['street_number'] },
      { long_name: 'José Ignacio Bartolache', types: ['route'] },
      { long_name: 'Del Valle Sur', types: ['sublocality_level_1', 'sublocality'] },
      { long_name: '03104', types: ['postal_code'] },
    ];
    assert.equal(streetFromGoogleComponents(components), 'José Ignacio Bartolache 1750');
    assert.equal(coloniaFromGoogleComponents(components), 'Del Valle Sur');
  });

  it('normaliza sugerencia y quita alcaldía de colonia', () => {
    const s = normalizeSuggestion({
      id: '1',
      label: 'Bartolache 1750, Benito Juárez, 03104',
      calle: 'Bartolache 1750',
      colonia: 'Col. Benito Juárez',
      cp: '03104-1',
      lat: 19.37,
      lng: -99.17,
      source: 'photon',
    });
    assert.equal(s.colonia, '');
    assert.equal(s.cp, '03104');
    assert.equal(s.lat, 19.37);
  });

  it('Photon: mapea features a calle/colonia/cp/coords', async () => {
    const result = await suggestAddresses('Bartolache 1750 Del Valle', {
      fetchFn: async () => ({
        json: async () => ({
          features: [
            {
              geometry: { coordinates: [-99.1699, 19.3846] },
              properties: {
                osm_id: 99,
                countrycode: 'MX',
                street: 'José Ignacio Bartolache',
                housenumber: '1750',
                suburb: 'Del Valle Sur',
                district: 'Benito Juárez',
                postcode: '03104',
                city: 'Ciudad de México',
              },
            },
          ],
        }),
      }),
    });
    assert.equal(result.ok, true);
    assert.equal(result.provider, 'photon');
    assert.equal(result.suggestions.length, 1);
    assert.match(result.suggestions[0].calle, /Bartolache 1750/);
    assert.equal(result.suggestions[0].colonia, 'Del Valle Sur');
    assert.equal(result.suggestions[0].cp, '03104');
    assert.equal(result.suggestions[0].lat, 19.3846);
    assert.equal(result.suggestions[0].lng, -99.1699);
  });

  it('query corta no llama proveedores', async () => {
    const result = await suggestAddresses('ab', {
      fetchFn: async () => {
        throw new Error('no debe llamar');
      },
    });
    assert.equal(result.ok, true);
    assert.equal(result.suggestions.length, 0);
  });
});
