#!/usr/bin/env node
/**
 * Alta bajo pedido de Suplementos Mayoreo.
 * El precio del CSV es costo de mayoreo. El precio público queda en 0.
 *
 *   node scripts/generar-alta-suplementos-mayoreo.js
 *
 * No pisa sql/alta_bajo_pedido_partes/ (Dermaexpress / Birdman / Ewafra).
 */
"use strict";

const fs = require("fs");
const path = require("path");
const {
  filaSuplementosMayoreo,
  motivoExclusionSuplementoMayoreo,
  sqlNum,
  sqlTexto,
} = require("../src/lib/catalogoBajoPedido");

const ROOT = path.join(__dirname, "..");
const DOCS = path.join(ROOT, "docs/catalogos");
const CSV = path.join(DOCS, "catalogo_suplementosmayoreo.csv");
const PARTS = path.join(ROOT, "sql/alta_suplementos_mayoreo_partes");

function parseCsv(filePath) {
  const raw = fs.readFileSync(filePath, "utf8").replace(/^\uFEFF/, "");
  const lines = [];
  let cur = "";
  let inQ = false;
  for (let i = 0; i < raw.length; i += 1) {
    const ch = raw[i];
    if (ch === '"') {
      cur += ch;
      if (inQ && raw[i + 1] === '"') { cur += '"'; i += 1; }
      else inQ = !inQ;
    } else if ((ch === "\n" || ch === "\r") && !inQ) {
      if (ch === "\r" && raw[i + 1] === "\n") i += 1;
      if (cur.trim()) lines.push(cur);
      cur = "";
    } else cur += ch;
  }
  if (cur.trim()) lines.push(cur);

  const split = (line) => {
    const out = [];
    let cell = "";
    let q = false;
    for (let i = 0; i < line.length; i += 1) {
      const ch = line[i];
      if (ch === '"') {
        if (q && line[i + 1] === '"') { cell += '"'; i += 1; }
        else q = !q;
      } else if (ch === "," && !q) { out.push(cell); cell = ""; }
      else cell += ch;
    }
    out.push(cell);
    return out;
  };

  const headers = split(lines[0]).map((h) => h.trim());
  return lines.slice(1).map((line) => {
    const cols = split(line);
    const row = {};
    headers.forEach((h, i) => { row[h] = cols[i] == null ? "" : cols[i]; });
    return row;
  });
}

function csvCell(s) {
  const t = String(s ?? "");
  if (/[",\n]/.test(t)) return `"${t.replace(/"/g, '""')}"`;
  return t;
}

function sqlTuple(f) {
  const ean = f.ean && f.ean.length >= 8 ? sqlTexto(f.ean) : "null";
  return `(${sqlTexto(f.sku)}, ${ean}, ${sqlTexto(f.nombre)}, ${sqlTexto(f.marca)},
    ${sqlTexto(f.presentacion)}, ${sqlTexto(f.concentracion)}, ${sqlTexto(f.forma_farmaceutica)},
    ${sqlTexto(f.categoria)}, ${sqlTexto(f.subcategoria)},
    ${sqlTexto(f.tipo)}, ${sqlNum(f.costo)}, ${sqlNum(f.precio, "0")},
    ${sqlTexto(f.imagen_url)}, ${sqlTexto(f.fuente)}, ${sqlTexto(f.sku_externo)})`;
}

function chunk(arr, n) {
  const out = [];
  for (let i = 0; i < arr.length; i += n) out.push(arr.slice(i, i + n));
  return out;
}

function main() {
  if (!fs.existsSync(CSV)) {
    throw new Error(`Falta ${CSV}`);
  }
  const rows = parseCsv(CSV);
  const motivos = { merch: 0, hormonal: 0, inyectable: 0, sin_costo: 0, sin_nombre: 0, sin_stock: 0 };
  const productos = [];
  const skus = new Set();

  for (const row of rows) {
    const texto = `${row.marca || ""} ${row.nombre || ""} ${row.nombre_completo || ""}`;
    const motivo = motivoExclusionSuplementoMayoreo(texto);
    if (motivo) {
      motivos[motivo] += 1;
      continue;
    }
    const stock = Number(row.stock);
    if (Number.isFinite(stock) && stock <= 0) {
      motivos.sin_stock += 1;
      continue;
    }
    const fila = filaSuplementosMayoreo(row);
    if (!fila) {
      const costo = Number(row.precio);
      if (!Number.isFinite(costo) || costo <= 0) motivos.sin_costo += 1;
      else motivos.sin_nombre += 1;
      continue;
    }
    if (!fila.sku) {
      motivos.sin_nombre += 1;
      continue;
    }
    let guardSku = 0;
    while (skus.has(fila.sku) && guardSku < 25) {
      fila.sku = `FC-${String((Number(fila.sku.slice(3)) + 1) % 100000000).padStart(8, "0")}`;
      guardSku += 1;
    }
    if (skus.has(fila.sku)) continue;
    skus.add(fila.sku);
    productos.push(fila);
  }

  fs.mkdirSync(PARTS, { recursive: true });
  for (const old of fs.readdirSync(PARTS)) {
    if (old.endsWith(".sql")) fs.unlinkSync(path.join(PARTS, old));
  }

  const header00 = `-- Suplementos Mayoreo — staging. Pegar en el SQL Editor EN ORDEN.
-- Antes: sql/patch_bajo_pedido_20260916.sql y sql/patch_fuente_suplementosmayoreo_20260922.sql
-- El precio del CSV es costo. productos.precio queda 0 (botón Ordenar).

begin;

do $$
begin
  if not exists (
    select 1 from information_schema.columns
     where table_schema = 'public' and table_name = 'productos' and column_name = 'bajo_pedido'
  ) then
    raise exception 'Primero corre sql/patch_bajo_pedido_20260916.sql';
  end if;
end
$$;

create table if not exists public._fc_cat_sm_stg (
  sku text not null,
  ean text,
  nombre text not null,
  marca text,
  presentacion text,
  concentracion text,
  forma_farmaceutica text,
  categoria text not null,
  subcategoria text,
  tipo text not null,
  costo numeric(12,2),
  precio numeric(12,2) not null,
  imagen_url text,
  fuente text not null,
  sku_externo text
);

truncate public._fc_cat_sm_stg;
commit;

select 'staging suplementos mayoreo lista' as ok;
`;
  fs.writeFileSync(path.join(PARTS, "00_staging.sql"), header00);

  const groups = chunk(productos, 100);
  groups.forEach((group, i) => {
    const n = String(i + 1).padStart(2, "0");
    const body = `-- ${n}/${String(groups.length).padStart(2, "0")} — ${group.length} filas a _fc_cat_sm_stg
begin;
insert into public._fc_cat_sm_stg (
  sku, ean, nombre, marca, presentacion, concentracion, forma_farmaceutica,
  categoria, subcategoria, tipo, costo, precio, imagen_url, fuente, sku_externo
) values
${group.map(sqlTuple).join(",\n")};
commit;
`;
    fs.writeFileSync(path.join(PARTS, `${n}_filas.sql`), body);
  });

  const merge = `-- Pasa staging a productos + referencia de costo. Idempotente.
-- No toca anaquel con stock. Precio público = 0.
-- No borra _fc_cat_sm_stg: si esto falla, las filas siguen ahí.
begin;

do $$
declare
  n int;
begin
  if to_regclass('public._fc_cat_sm_stg') is null then
    raise exception 'No existe _fc_cat_sm_stg. Primero pega los archivos de cargar, en orden.';
  end if;
  select count(*) into n from public._fc_cat_sm_stg;
  if n < ${Math.max(1, productos.length - 5)} then
    raise exception 'La tabla temporal tiene % filas y deben ser ${productos.length}. Faltan archivos de cargar.', n;
  end if;
end
$$;

insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, concentracion, forma_farmaceutica, subcategoria,
  imagen_url, bajo_pedido
)
select
  t.nombre,
  case
    when exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') is distinct from coalesce(t.ean, '')
    ) then 'FC-ND-' || right(coalesce(nullif(t.ean, ''), t.sku), 8)
    else t.sku
  end,
  nullif(t.ean, ''),
  t.categoria,
  t.tipo,
  'Bajo pedido · suplementosmayoreo' || coalesce(' · ' || nullif(trim(t.sku_externo), ''), ''),
  t.costo,
  0,
  0, 1, true, false,
  t.marca, t.presentacion, t.concentracion, t.forma_farmaceutica, t.subcategoria,
  t.imagen_url, true
from public._fc_cat_sm_stg t
where not exists (
  select 1 from public.productos p
  where p.sku = t.sku
     or (t.ean is not null and p.codigo_barras = t.ean)
);

update public.productos p
   set bajo_pedido = true,
       activo = true,
       costo = coalesce(t.costo, p.costo),
       precio = 0,
       marca = coalesce(nullif(trim(p.marca), ''), t.marca),
       presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
       concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
       forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma_farmaceutica),
       imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen_url),
       descripcion = coalesce(
         nullif(trim(p.descripcion), ''),
         'Bajo pedido · suplementosmayoreo' || coalesce(' · ' || nullif(trim(t.sku_externo), ''), '')
       )
  from public._fc_cat_sm_stg t
 where coalesce(p.stock, 0) = 0
   and (
     p.sku = t.sku
     or (t.ean is not null and p.codigo_barras = t.ean)
   );

insert into public.producto_precios_referencia
  (producto_id, fuente, tipo, precio, sku_externo, origen, notas)
select p.id, 'suplementosmayoreo', 'compra', t.costo, t.sku_externo, 'import_csv',
       'mayoreo suplementosmayoreo.com'
  from public._fc_cat_sm_stg t
  join public.productos p
    on p.sku = t.sku
    or (t.ean is not null and p.codigo_barras = t.ean)
 where t.costo is not null and t.costo > 0
   and not exists (
     select 1 from public.producto_precios_referencia r
      where r.producto_id = p.id and r.fuente = 'suplementosmayoreo'
        and r.fecha = current_date
   );

commit;

select
  count(*) filter (where coalesce(bajo_pedido, false) and descripcion like 'Bajo pedido · suplementosmayoreo%') as filas_sm,
  count(*) filter (where coalesce(bajo_pedido, false) and coalesce(precio, 0) <= 0.01) as ordenar
from public.productos;
`;
  fs.writeFileSync(path.join(PARTS, "99_aplicar.sql"), merge);

  const pegar = path.join(ROOT, "sql/alta_suplementos_mayoreo_pegar");
  fs.mkdirSync(pegar, { recursive: true });
  for (const old of fs.readdirSync(pegar)) {
    if (old.endsWith(".sql")) fs.unlinkSync(path.join(pegar, old));
  }
  const leer = (name) => fs.readFileSync(path.join(PARTS, name), "utf8").trim();
  const MAX = 48 * 1024;
  const piezas = [];
  let actual = [leer("00_staging.sql")];
  let bytes = Buffer.byteLength(actual[0], "utf8");
  for (let i = 1; i <= groups.length; i += 1) {
    const body = leer(`${String(i).padStart(2, "0")}_filas.sql`);
    const n = Buffer.byteLength(body, "utf8") + 2;
    if (actual.length && bytes + n > MAX) {
      piezas.push(actual.join("\n\n"));
      actual = [];
      bytes = 0;
    }
    actual.push(body);
    bytes += n;
  }
  if (actual.length) piezas.push(actual.join("\n\n"));
  const totalPasos = piezas.length + 1;
  piezas.forEach((texto, i) => {
    const nota = i === 0
      ? "Crea la tabla temporal y carga el primer bloque. Si lo vuelves a correr, vacía lo ya cargado."
      : "Suma filas. No vacía la tabla. Solo después del archivo anterior.";
    const nombre = `${String(i + 1).padStart(2, "0")}_cargar.sql`;
    fs.writeFileSync(
      path.join(pegar, nombre),
      `-- Paso ${i + 1} de ${totalPasos}. ${nota}\n\n${texto}\n`,
    );
  });
  fs.writeFileSync(
    path.join(pegar, `${String(totalPasos).padStart(2, "0")}_aplicar.sql`),
    `-- Paso ${totalPasos} de ${totalPasos}. Pasa las filas al inventario.\n-- Exige las ${productos.length} filas. No borra la tabla temporal.\n\n${merge}\n`,
  );
  const stagingHeader = [
    "sku", "ean", "nombre", "marca", "presentacion", "concentracion", "forma_farmaceutica",
    "categoria", "subcategoria", "tipo", "costo", "precio", "imagen_url", "fuente", "sku_externo",
  ];
  fs.writeFileSync(
    path.join(pegar, "staging.csv"),
    [
      stagingHeader.join(","),
      ...productos.map((p) => stagingHeader.map((k) => csvCell(p[k] ?? "")).join(",")),
    ].join("\n") + "\n",
  );

  const altaCsv = [
    "sku,ean,codigo,nombre,marca,presentacion,concentracion,forma,categoria,subcategoria,costo,imagen_url,foto_pendiente",
    ...productos.map((p) => [
      p.sku, p.ean, p.sku_externo, p.nombre, p.marca, p.presentacion, p.concentracion,
      p.forma_farmaceutica, p.categoria, p.subcategoria, p.costo, p.imagen_url,
      p.imagen_url ? "0" : "1",
    ].map(csvCell).join(",")),
  ].join("\n");
  fs.writeFileSync(path.join(DOCS, "alta_suplementos_mayoreo_20260922.csv"), `${altaCsv}\n`);

  const fotos = productos.filter((p) => p.imagen_url);
  fs.writeFileSync(
    path.join(DOCS, "fotos_suplementos_mayoreo.csv"),
    ["slug,fuente,url_origen,sku,ean,nombre"].concat(fotos.map((p) => {
      const slug = `sm-${(p.ean || p.sku_externo || p.sku).toString().toLowerCase().replace(/[^a-z0-9]+/g, "-").slice(0, 48)}`;
      return [slug, p.fuente, p.imagen_url, p.sku, p.ean, csvCell(p.nombre)].join(",");
    })).join("\n") + "\n",
  );

  const porRubro = {};
  for (const p of productos) {
    const k = `${p.categoria} / ${p.subcategoria}`;
    porRubro[k] = (porRubro[k] || 0) + 1;
  }
  const conteos = {
    filas_csv: rows.length,
    alta: productos.length,
    con_imagen: fotos.length,
    sin_imagen: productos.length - fotos.length,
    con_ean: productos.filter((p) => p.ean).length,
    excluidos: motivos,
    rubros: porRubro,
  };
  fs.writeFileSync(path.join(DOCS, "conteos_suplementos_mayoreo_20260922.json"), `${JSON.stringify(conteos, null, 2)}\n`);
  console.log(JSON.stringify(conteos, null, 2));
  console.log(`Partes → ${PARTS} (${fs.readdirSync(PARTS).filter((f) => f.endsWith(".sql")).length} sql)`);
}

main();
