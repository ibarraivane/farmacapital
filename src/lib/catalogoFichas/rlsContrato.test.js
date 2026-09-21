/**
 * Contrato de RLS (el SQL se aplica en Supabase, no aquí).
 * Si alguien cambia el patch, estos nombres tienen que seguir existiendo.
 */
const fs = require("node:fs");
const path = require("node:path");

const sql = fs.readFileSync(
  path.join(__dirname, "../../../sql/patch_catalogo_fichas_20260921.sql"),
  "utf8"
);

test("anon no lee tablas crudas ni jobs", () => {
  expect(sql).toMatch(/revoke all on public\.monografias from anon/);
  expect(sql).toMatch(/revoke all on public\.producto_fichas from anon/);
  expect(sql).toMatch(/revoke all on public\.enriquecimiento_jobs from anon/);
  expect(sql).toMatch(/tienda_ficha_producto/);
  expect(sql).not.toMatch(/grant select on public\.enriquecimiento_jobs to anon/);
  expect(sql).toMatch(/pf\.estado = 'publicado'/);
  const fnStart = sql.indexOf("create or replace function public.tienda_ficha_producto");
  const fnEnd = sql.indexOf("$$;", fnStart);
  const rpcBody = sql.slice(fnStart, fnEnd);
  expect(rpcBody).not.toMatch(/revisado_por/);
  expect(rpcBody).not.toMatch(/fuentes/);
});

test("al publicar se guarda imagen aprobada con origen, fuente y licencia", () => {
  const start = sql.indexOf("create or replace function public.admin_guardar_ficha_revision");
  const body = sql.slice(start, sql.indexOf("$$;", start));
  expect(body).toMatch(/insert into public\.producto_imagenes/);
  expect(body).toMatch(/fuente_url/);
  expect(body).toMatch(/licencia/);
  expect(body).toMatch(/aprobada/);
});
