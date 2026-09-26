#!/usr/bin/env node
/**
 * Genera SQL de alta bajo pedido + manifiesto de fotos
 * a partir de Dermaexpress, Birdman, Ewafra/DIS y Promexsa (techo).
 *
 *   node scripts/generar-alta-bajo-pedido.js
 */
"use strict";

const fs = require("fs");
const path = require("path");
const { spawnSync } = require("child_process");

const {
  filaBirdman,
  filaDermaexpress,
  filaEwafra,
  matchPromexsa,
  sqlNum,
  sqlTexto,
  marcaDesdeDescripcionDis,
} = require("../src/lib/catalogoBajoPedido");

const ROOT = path.join(__dirname, "..");
const UP = "/home/ubuntu/.cursor/projects/workspace/uploads";
const DOCS = path.join(ROOT, "docs/catalogos");
const SQL_DIR = path.join(ROOT, "sql");

function findFile(candidates) {
  for (const p of candidates) {
    if (p && fs.existsSync(p)) return p;
  }
  return null;
}

function parseCsv(filePath) {
  const raw = fs.readFileSync(filePath, "utf8").replace(/^\uFEFF/, "");
  const lines = [];
  let cur = "";
  let inQ = false;
  for (let i = 0; i < raw.length; i += 1) {
    const ch = raw[i];
    if (ch === '"') {
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

function slugFoto(fila) {
  const base = (fila.ean || fila.sku_externo || fila.sku || "x")
    .toString()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-|-$/g, "")
    .slice(0, 48);
  return `bp-${fila.fuente}-${base}`;
}

function sqlTuple(f) {
  const ean = f.ean && f.ean.length >= 8 ? sqlTexto(f.ean) : "null";
  return `(${sqlTexto(f.sku)}, ${ean}, ${sqlTexto(f.nombre)}, ${sqlTexto(f.marca)},
    ${sqlTexto(f.presentacion)}, ${sqlTexto(f.categoria)}, ${sqlTexto(f.subcategoria)},
    ${sqlTexto(f.tipo)}, ${sqlNum(f.costo)}, ${sqlNum(f.precio, "0")},
    ${sqlTexto(f.imagen_url)}, ${sqlTexto(f.fuente)}, ${sqlTexto(f.sku_externo)},
    ${sqlNum(f.techo)}, ${f.disponible === false ? "false" : "true"})`;
}

function chunk(arr, n) {
  const out = [];
  for (let i = 0; i < arr.length; i += n) out.push(arr.slice(i, i + n));
  return out;
}

function main() {
  fs.mkdirSync(DOCS, { recursive: true });

  const pdf = findFile([
    path.join(UP, "lista_dis_agosto_2026_d078.pdf"),
    path.join(DOCS, "lista_dis_agosto_2026.pdf"),
  ]);
  const disCsv = path.join(DOCS, "ewafra_dis_agosto_2026.csv");
  if (pdf) {
    const r = spawnSync("python3", [path.join(ROOT, "scripts/parse_ewafra_dis_pdf.py"), pdf, disCsv], {
      encoding: "utf8",
    });
    if (r.status !== 0) {
      console.error(r.stdout || "", r.stderr || "");
      throw new Error("Fallo el parseo del PDF DIS");
    }
    process.stdout.write(r.stdout || "");
  }

  const dermaPath = findFile([
    path.join(UP, "catalogo_farmacapital_0923.csv"),
    path.join(DOCS, "catalogo_dermaexpress.csv"),
  ]);
  const birdPath = findFile([
    path.join(UP, "catalogo_birdman_farmacapital_4e5f.csv"),
    path.join(DOCS, "catalogo_birdman.csv"),
  ]);
  const pmxPath = findFile([
    path.join(UP, "farmacapital_catalogo_promexsa_c028.csv"),
    path.join(DOCS, "catalogo_promexsa.csv"),
  ]);
  if (!dermaPath || !birdPath || !pmxPath || !fs.existsSync(disCsv)) {
    throw new Error(`Faltan catálogos: derma=${dermaPath} bird=${birdPath} pmx=${pmxPath} dis=${fs.existsSync(disCsv)}`);
  }

  const derma = parseCsv(dermaPath).map(filaDermaexpress).filter((f) => f && f.nombre && f.sku);
  const birdRows = parseCsv(birdPath);
  const eanSidecar = path.join(DOCS, "birdman_ean_imagen.csv");
  if (fs.existsSync(eanSidecar)) {
    const porSku = new Map();
    for (const extra of parseCsv(eanSidecar)) {
      const clave = String(extra.sku_birdman || "").trim().toUpperCase();
      if (clave) porSku.set(clave, extra);
    }
    for (const row of birdRows) {
      const extra = porSku.get(String(row.sku || "").trim().toUpperCase());
      if (!extra) continue;
      if (!String(row.ean || row.codigo_barras || "").trim() && extra.ean) row.ean = extra.ean;
      if (!String(row.imagen_url || "").trim() && extra.imagen_url) row.imagen_url = extra.imagen_url;
    }
  }
  const bird = birdRows.map(filaBirdman).filter((f) => f && f.nombre && f.sku);
  const pmx = parseCsv(pmxPath);
  const disRaw = parseCsv(disCsv);

  const ewafra = [];
  let disMatch = 0;
  for (const row of disRaw) {
    row.marca = marcaDesdeDescripcionDis(row.descripcion);
    row.costo = Number(row.costo_lista6);
    const hit = matchPromexsa(
      { descripcion: row.descripcion, nombre: row.descripcion, marca: row.marca },
      pmx,
      { minimo: 0.55 },
    );
    const matched = hit ? { ...hit.row, score: hit.score } : null;
    if (matched) disMatch += 1;
    const fila = filaEwafra(row, matched);
    if (fila && fila.nombre && fila.sku) ewafra.push(fila);
  }

  const skus = new Set();
  const productos = [];
  for (const f of [...derma, ...bird, ...ewafra]) {
    if (skus.has(f.sku)) {
      f.sku = `FC-${String(Number(f.sku.slice(3)) + 1).padStart(8, "0")}`;
    }
    if (skus.has(f.sku)) continue;
    skus.add(f.sku);
    f.slug_foto = slugFoto(f);
    if (f.imagen_url) {
      f.imagen_propia = `https://www.farmacapital.mx/catalogo-propia/${f.slug_foto}.jpg`;
    }
    productos.push(f);
  }

  const manifest = {
    generado: new Date().toISOString().slice(0, 10),
    conteos: {
      dermaexpress: derma.length,
      birdman: bird.length,
      ewafra: ewafra.length,
      ewafra_match_promexsa: disMatch,
      total: productos.length,
      con_precio: productos.filter((p) => p.precio > 0.01).length,
      cotizar: productos.filter((p) => p.precio <= 0.01).length,
      con_imagen: productos.filter((p) => p.imagen_url).length,
      sin_imagen: productos.filter((p) => !p.imagen_url).length,
    },
    productos: productos.map((p) => ({
      sku: p.sku,
      ean: p.ean,
      nombre: p.nombre,
      marca: p.marca,
      fuente: p.fuente,
      costo: p.costo,
      precio: p.precio,
      imagen_url: p.imagen_url,
      slug_foto: p.slug_foto,
      foto_pendiente: !p.imagen_url,
    })),
  };
  fs.writeFileSync(path.join(DOCS, "manifiesto_bajo_pedido_20260917.json"), JSON.stringify(manifest, null, 2));
  fs.writeFileSync(
    path.join(DOCS, "fotos_bajo_pedido.csv"),
    ["slug,fuente,url_origen,sku,ean,nombre"].concat(
      productos.filter((p) => p.imagen_url).map((p) =>
        [p.slug_foto, p.fuente, p.imagen_url, p.sku, p.ean, `"${String(p.nombre).replace(/"/g, '""')}"`].join(",")),
    ).join("\n"),
  );

  const partsDir = path.join(SQL_DIR, "alta_bajo_pedido_partes");
  fs.mkdirSync(partsDir, { recursive: true });
  for (const old of fs.readdirSync(partsDir)) {
    if (old.endsWith(".sql")) fs.unlinkSync(path.join(partsDir, old));
  }

  const header00 = `-- 00/N — crea staging (NO es temp: cada parte se pega en una query del SQL Editor).
-- Orden: 00, luego 01.., luego 99. Primero: patch_fuentes_bajo_pedido_20260917.sql

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

create table if not exists public._fc_cat_bp_stg (
  sku text not null,
  ean text,
  nombre text not null,
  marca text,
  presentacion text,
  categoria text not null,
  subcategoria text,
  tipo text not null,
  costo numeric(12,2),
  precio numeric(12,2) not null,
  imagen_url text,
  fuente text not null,
  sku_externo text,
  techo numeric(12,2),
  disponible boolean not null default true
);

truncate public._fc_cat_bp_stg;
commit;

select 'staging lista' as ok;
`;
  fs.writeFileSync(path.join(partsDir, "00_staging.sql"), header00);

  const groups = chunk(productos, 120);
  groups.forEach((group, i) => {
    const n = String(i + 1).padStart(2, "0");
    const body = `-- ${n}/${String(groups.length).padStart(2, "0")} — ${group.length} filas a _fc_cat_bp_stg
begin;
insert into public._fc_cat_bp_stg values
${group.map(sqlTuple).join(",\n")};
commit;
`;
    fs.writeFileSync(path.join(partsDir, `${n}_filas.sql`), body);
  });

  const lastN = String(groups.length + 1).padStart(2, "0");
  const merge = `-- ${lastN} — pasa staging a productos + referencias. Idempotente.
begin;

insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, subcategoria, imagen_url, bajo_pedido
)
select
  t.nombre,
  case
    when exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') is distinct from coalesce(t.ean, '')
    ) then 'FC-ND-' || right(coalesce(t.ean, t.sku), 8)
    else t.sku
  end,
  nullif(t.ean, ''),
  t.categoria,
  t.tipo,
  'Bajo pedido · ' || t.fuente || coalesce(' · ' || t.sku_externo, ''),
  t.costo,
  0,
  0, 1, true, false,
  t.marca, t.presentacion, t.subcategoria, t.imagen_url, true
from public._fc_cat_bp_stg t
where (t.ean is null or public.fc_buscar_producto_escaneo(t.ean) is null)
  and not exists (
    select 1 from public.productos p
    where (t.ean is not null and p.codigo_barras = t.ean)
       or p.sku = t.sku
  );

update public.productos p
   set bajo_pedido = true,
       activo = true,
       costo = coalesce(t.costo, p.costo),
       precio = 0,
       marca = coalesce(nullif(trim(p.marca), ''), t.marca),
       presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
       imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen_url),
       codigo_barras = case
         when coalesce(nullif(trim(p.codigo_barras), ''), '') <> '' then p.codigo_barras
         when nullif(t.ean, '') is null then p.codigo_barras
         when exists (
           select 1 from public.productos o
           where o.codigo_barras = t.ean and o.id <> p.id
         ) then p.codigo_barras
         else t.ean
       end
  from public._fc_cat_bp_stg t
 where coalesce(p.stock, 0) = 0
   and (
     (t.ean is not null and (p.codigo_barras = t.ean or p.id = public.fc_buscar_producto_escaneo(t.ean)))
     or p.sku = t.sku
   );

insert into public.producto_precios_referencia
  (producto_id, fuente, tipo, precio, sku_externo, origen, notas)
select p.id, t.fuente, 'compra', t.costo, t.sku_externo, 'import_csv',
       'mayoreo ' || t.fuente
  from public._fc_cat_bp_stg t
  join public.productos p
    on p.sku = t.sku
    or (t.ean is not null and (p.codigo_barras = t.ean or p.id = public.fc_buscar_producto_escaneo(t.ean)))
 where t.costo is not null and t.costo > 0
   and not exists (
     select 1 from public.producto_precios_referencia r
      where r.producto_id = p.id and r.fuente = t.fuente
        and r.fecha = current_date
   );

insert into public.producto_precios_referencia
  (producto_id, fuente, tipo, precio, sku_externo, origen, notas)
select p.id, 'promexsa', 'compra', t.techo, t.sku_externo, 'import_csv',
       'techo web Promexsa — no es mayoreo'
  from public._fc_cat_bp_stg t
  join public.productos p
    on p.sku = t.sku
    or (t.ean is not null and p.codigo_barras = t.ean)
 where t.fuente = 'ewafra' and t.techo is not null and t.techo > 0
   and not exists (
     select 1 from public.producto_precios_referencia r
      where r.producto_id = p.id and r.fuente = 'promexsa'
        and r.fecha = current_date
   );

drop table if exists public._fc_cat_bp_stg;
commit;

select
  count(*) filter (where coalesce(bajo_pedido, false)) as bajo_pedido,
  count(*) filter (where coalesce(bajo_pedido, false) and coalesce(precio, 0) > 0.01) as con_precio,
  count(*) filter (where coalesce(bajo_pedido, false) and coalesce(precio, 0) <= 0.01) as ordenar
from public.productos;
`;
  fs.writeFileSync(path.join(partsDir, "99_aplicar.sql"), merge);

  const stub = `-- NO PEGAR ESTE ARCHIVO en el SQL Editor (pesa ~900 KB y el editor lo corta).
-- En farmacapital.mx/conseguir siguen ~111 encargos viejos si solo corriste este archivo.
--
-- Corre EN ORDEN los trozos de sql/alta_bajo_pedido_partes/:
--   00_staging.sql
--   01_filas.sql … NN_filas.sql
--   99_aplicar.sql
-- Al final 99 debe devolver bajo_pedido ≈ 3300 (no 111).
--
-- Regenerar: node scripts/generar-alta-bajo-pedido.js
`;
  fs.writeFileSync(path.join(SQL_DIR, "patch_alta_catalogo_bajo_pedido_20260917.sql"), stub);

  const nParts = fs.readdirSync(partsDir).filter((f) => f.endsWith(".sql")).length;
  console.log(JSON.stringify(manifest.conteos, null, 2));
  console.log(`Partes → ${partsDir} (${nParts} archivos)`);
}

main();
