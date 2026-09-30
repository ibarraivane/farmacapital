'use strict';

const { test } = require('node:test');
const assert = require('node:assert/strict');
const { LINEAS, FOLIO } = require('./aplicarCargaNadro6090551411');

test('ticket Nadro 6090551411 tiene 4 renglones y folio fijo', () => {
  assert.equal(FOLIO, '6090551411');
  assert.equal(LINEAS.length, 4);
  assert.equal(LINEAS.filter((l) => l.alta_nueva).length, 3);
  assert.deepEqual(
    LINEAS.map((l) => l.ean),
    ['7501026462245', '4042809591446', '650240032431', '650240032455']
  );
  const sub = LINEAS.reduce((s, l) => s + l.qty * l.costo, 0);
  assert.ok(Math.abs(sub - 379.47) < 0.02, `subtotal ${sub}`);
});
