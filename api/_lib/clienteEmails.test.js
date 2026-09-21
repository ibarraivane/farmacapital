'use strict';

const { describe, it } = require('node:test');
const assert = require('node:assert/strict');
const { emailsValidos, emailsAvisoCliente } = require('./clienteEmails');

describe('clienteEmails', () => {
  it('junta Gmail y Hotmail sin duplicar', () => {
    assert.deepEqual(
      emailsAvisoCliente({
        email: 'alejandro@gmail.com',
        emailAlt: 'a_escalante_barreto@hotmail.com',
      }),
      ['alejandro@gmail.com', 'a_escalante_barreto@hotmail.com']
    );
  });

  it('si guest y ficha son el mismo, solo manda una vez', () => {
    assert.deepEqual(
      emailsAvisoCliente({
        guestEmail: 'A_Escalante_Barreto@hotmail.com',
        email: 'a_escalante_barreto@hotmail.com',
      }),
      ['A_Escalante_Barreto@hotmail.com']
    );
  });

  it('ignora vacíos y texto sin @', () => {
    assert.deepEqual(emailsValidos('', 'sin-correo', null, 'ok@fc.mx'), ['ok@fc.mx']);
  });
});
