#!/usr/bin/env node
/** Chequeo rápido del gate (no usa Jest/CRA).: node scripts/backup-schema-secrets.test.js */
"use strict";

const assert = require("node:assert/strict");
const { findLiteralSecrets } = require("./backup-schema-secrets");

assert.deepEqual(
  findLiteralSecrets(`
CREATE FUNCTION admin_reset_password(p_nueva_password text) RETURNS void AS $$
BEGIN NULL; END; $$ LANGUAGE plpgsql;
`),
  [],
  "no debe marcar nombres con password"
);

assert.ok(
  findLiteralSecrets(
    `SELECT 'postgresql://postgres.abc:s3cretPass@aws.example.com:5432/postgres'`
  ).some((x) => x.name === "postgres_url_with_password"),
  "debe detectar URL con password"
);

assert.ok(
  findLiteralSecrets(
    `COMMENT ON FUNCTION f IS 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0In0.signaturehereXX'`
  ).some((x) => x.name === "jwt_like"),
  "debe detectar JWT"
);

assert.ok(
  findLiteralSecrets(`SELECT 'Bearer abcdefghijklmnopqrstuvwxyz012345'`).length > 0,
  "debe detectar Bearer"
);

console.log("✓ backup-schema-secrets checks OK");
