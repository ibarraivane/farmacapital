'use strict';

const { describe, it } = require('node:test');
const assert = require('node:assert/strict');
const { planCambioFotos, urlFotoPermitida, claveFoto } = require('./fotosProductoPlan');

const CONTAC = 'https://cdn.ejemplo/contac-roja.jpg';
const LENTE_A = 'https://cdn.ejemplo/bausch-a.jpg';
const LENTE_B = 'https://cdn.ejemplo/bausch-b.jpg?v=1';

describe('planCambioFotos', () => {
  it('quitar una foto que no es el producto y deja la principal', () => {
    const plan = planCambioFotos({
      filas: [
        { id: 1, url: LENTE_A, posicion: 1, es_principal: true },
        { id: 2, url: LENTE_B, posicion: 2, es_principal: false },
      ],
      imagenUrl: CONTAC,
      action: 'quitar',
      url: LENTE_A,
    });
    assert.equal(plan.ok, true);
    assert.equal(plan.imagenUrl, CONTAC);
    assert.equal(plan.filas.length, 1);
    assert.equal(plan.filas[0].url, LENTE_B);
  });

  it('quitar las dos fotos ajenas deja la galería vacía y conserva la principal', () => {
    let plan = planCambioFotos({
      filas: [
        { id: 1, url: LENTE_A, posicion: 1, es_principal: false },
        { id: 2, url: LENTE_B, posicion: 2, es_principal: false },
      ],
      imagenUrl: CONTAC,
      action: 'quitar',
      url: LENTE_B,
    });
    plan = planCambioFotos({
      filas: plan.filas,
      imagenUrl: plan.imagenUrl,
      action: 'quitar',
      url: LENTE_A,
    });
    assert.deepEqual(plan.filas, []);
    assert.equal(plan.imagenUrl, CONTAC);
  });

  it('agregar varias no esconde la foto principal cuando la galería estaba vacía', () => {
    const plan = planCambioFotos({
      filas: [],
      imagenUrl: CONTAC,
      action: 'agregar',
      url: 'https://cdn.ejemplo/contac-dorso.jpg',
      principal: false,
    });
    assert.equal(plan.ok, true);
    assert.equal(plan.imagenUrl, CONTAC);
    assert.equal(plan.filas.length, 2);
    assert.equal(plan.filas.find((f) => f.es_principal).url, CONTAC);
    assert.equal(plan.filas.filter((f) => f.es_principal).length, 1);
  });

  it('al sumar fotos deja la principal del formulario aunque ya hubiera otras', () => {
    const plan = planCambioFotos({
      filas: [{ id: 1, url: LENTE_A, posicion: 1, es_principal: true }],
      imagenUrl: CONTAC,
      action: 'agregar',
      url: 'https://cdn.ejemplo/contac-dorso.jpg',
      principal: false,
    });
    assert.equal(plan.ok, true);
    assert.equal(plan.imagenUrl, CONTAC);
    assert.equal(plan.filas.find((f) => f.es_principal).url, CONTAC);
    assert.equal(plan.filas.length, 3);
    assert.equal(plan.filas.filter((f) => f.es_principal).length, 1);
  });

  it('marcar principal mete esa foto primero en la ficha y guarda la anterior', () => {
    const plan = planCambioFotos({
      filas: [{ id: 8, url: LENTE_A, posicion: 1, es_principal: true }],
      imagenUrl: CONTAC,
      action: 'principal',
      url: CONTAC,
    });
    assert.equal(plan.imagenUrl, CONTAC);
    assert.equal(plan.filas.find((f) => f.es_principal).url, CONTAC);
    assert.ok(plan.filas.some((f) => f.url === LENTE_A && !f.es_principal));
  });

  it('rechaza el placeholder de Del Ahorro y acciones raras', () => {
    assert.equal(urlFotoPermitida('https://www.fahorro.com/media/a.jpg'), '');
    assert.equal(urlFotoPermitida('javascript:alert(1)'), '');
    const plan = planCambioFotos({
      filas: [],
      imagenUrl: '',
      action: 'agregar',
      url: 'https://production-media.fahorro.com/media/x.jpg',
    });
    assert.equal(plan.ok, false);
  });

  it('ignora el cache buster al reconocer la misma foto', () => {
    assert.equal(claveFoto(`${CONTAC}?v=9`), claveFoto(CONTAC));
    const plan = planCambioFotos({
      filas: [{ id: 3, url: `${LENTE_A}?v=2`, posicion: 1, es_principal: false }],
      imagenUrl: CONTAC,
      action: 'quitar',
      url: LENTE_A,
    });
    assert.equal(plan.filas.length, 0);
  });
});
