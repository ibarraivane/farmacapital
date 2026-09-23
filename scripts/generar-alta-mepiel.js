#!/usr/bin/env node
/**
 * Alta bajo pedido de la lista ME Piel 2026.
 *
 *   node scripts/generar-alta-mepiel.js
 *
 * Costo = precio cliente c/IVA (lo que cobra ME Piel).
 * productos.precio queda en 0 (botón Ordenar) hasta que el dueño publique.
 * Fotos: Dermaexpress por EAN, y docs/catalogos/mepiel_fotos_extra_2026.csv si existe.
 */
"use strict";

const fs = require("fs");
const path = require("path");
const { spawnSync } = require("child_process");

const {
  FUENTE_MEPIEL,
  enriquecerFilaMepiel,
  filasMepielDesdeRaws,
  sqlNum,
  sqlTexto,
} = require("../src/lib/catalogoBajoPedido");

const ROOT = path.join(__dirname, "..");
const DOCS = path.join(ROOT, "docs/catalogos");
const SQL_DIR = path.join(ROOT, "sql/alta_mepiel_2026");
const UPLOADS = "/home/ubuntu/.cursor/projects/workspace/uploads";

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
      cur += ch;
      if (inQ && raw[i + 1] === '"') { cur += raw[i + 1]; i += 1; }
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

function cargarDerma() {
  const file = path.join(DOCS, "catalogo_dermaexpress.csv");
  const map = new Map();
  if (!fs.existsSync(file)) return map;
  for (const row of parseCsv(file)) {
    const ean = String(row.sku || "").replace(/\D/g, "");
    if (ean.length >= 8) map.set(ean, row);
  }
  return map;
}

function cargarFotosExtra() {
  const file = path.join(DOCS, "mepiel_fotos_extra_2026.csv");
  const map = new Map();
  if (!fs.existsSync(file)) return map;
  for (const row of parseCsv(file)) {
    const ean = String(row.ean || "").replace(/\D/g, "");
    if (ean.length >= 8 && row.imagen_url) map.set(ean, row);
  }
  return map;
}

function asignarSkus(filas) {
  const used = new Set();
  for (const f of filas) {
    let sku = f.sku;
    if (used.has(sku)) sku = `FC-ND-${f.ean.slice(-8)}`;
    if (used.has(sku)) sku = `FC-MP-${f.ean.slice(-8)}`;
    f.sku = sku;
    used.add(sku);
  }
}

function sqlTuple(f) {
  return `(${sqlTexto(f.sku)}, ${sqlTexto(f.ean)}, ${sqlTexto(f.nombre)}, ${sqlTexto(f.marca)},
    ${sqlTexto(f.presentacion)}, ${sqlTexto(f.concentracion)}, ${sqlTexto(f.forma_farmaceutica)},
    ${sqlTexto(f.categoria)}, ${sqlTexto(f.subcategoria)}, ${sqlTexto(f.linea)},
    ${sqlNum(f.costo)}, ${sqlNum(f.techo)}, ${sqlTexto(f.imagen_url)}, ${sqlTexto(f.oferta)})`;
}

function chunk(arr, n) {
  const out = [];
  for (let i = 0; i < arr.length; i += n) out.push(arr.slice(i, i + n));
  return out;
}

function csvCell(v) {
  const s = v == null ? "" : String(v);
  if (/[",\n]/.test(s)) return `"${s.replace(/"/g, '""')}"`;
  return s;
}

function main() {
  const xlsx = findFile([
    path.join(UPLOADS, "ME_Piel_Lista_de_precios_2026_1b54.xlsx"),
    path.join(DOCS, "ME_Piel_Lista_de_precios_2026.xlsx"),
  ]);
  if (!xlsx) throw new Error("No está el xlsx de ME Piel");

  const rawPath = path.join("/tmp", "mepiel_raw_2026.json");
  const parsed = spawnSync("python3", [
    path.join(ROOT, "scripts/parse_mepiel_xlsx.py"),
    xlsx,
    rawPath,
  ], { encoding: "utf8" });
  if (parsed.status !== 0) {
    console.error(parsed.stdout || "", parsed.stderr || "");
    throw new Error("No se pudo leer el xlsx");
  }
  process.stdout.write(parsed.stdout || "");

  const raw = JSON.parse(fs.readFileSync(rawPath, "utf8"));
  const derma = cargarDerma();
  const extras = cargarFotosExtra();
  const base = filasMepielDesdeRaws(raw.productos);
  const filas = base.map((fila) => {
    const d = derma.get(fila.ean);
    const extra = extras.get(fila.ean);
    return enriquecerFilaMepiel(fila, {
      derma: d ? {
        nombre: d.nombre,
        marca: d.marca,
        imagen_url: d.imagen_url,
      } : null,
      extra: extra ? {
        nombre: extra.nombre,
        marca: extra.marca,
        imagen_url: extra.imagen_url,
        origen: extra.origen || "extra",
      } : null,
    });
  });
  asignarSkus(filas);
  filas.sort((a, b) => a.marca.localeCompare(b.marca, "es") || a.nombre.localeCompare(b.nombre, "es"));

  const conteos = {
    filas_lista: raw.productos.length,
    unicos: filas.length,
    sin_codigo: (raw.sin_codigo || []).length,
    con_foto: filas.filter((f) => f.imagen_url).length,
    foto_dermaexpress: filas.filter((f) => f.imagen_origen === "dermaexpress").length,
    foto_extra: filas.filter((f) => f.imagen_origen && f.imagen_origen !== "dermaexpress").length,
    sin_foto: filas.filter((f) => !f.imagen_url).length,
    costo_mediano: mediana(filas.map((f) => f.costo)),
  };

  const cols = [
    "sku", "ean", "nombre", "marca", "presentacion", "concentracion", "forma_farmaceutica",
    "categoria", "subcategoria", "linea", "costo", "techo", "oferta", "imagen_url", "imagen_origen",
    "nombre_lista",
  ];
  fs.writeFileSync(
    path.join(DOCS, "mepiel_lista_2026.csv"),
    [cols.join(",")].concat(filas.map((f) => cols.map((c) => csvCell(f[c])).join(","))).join("\n") + "\n",
  );
  fs.writeFileSync(
    path.join(DOCS, "mepiel_sin_foto_2026.csv"),
    ["ean,sku,marca,nombre,nombre_lista"].concat(
      filas.filter((f) => !f.imagen_url).map((f) =>
        [f.ean, f.sku, f.marca, f.nombre, f.nombre_lista].map(csvCell).join(",")),
    ).join("\n") + "\n",
  );

  fs.mkdirSync(SQL_DIR, { recursive: true });
  for (const old of fs.readdirSync(SQL_DIR)) {
    if (old.endsWith(".sql")) fs.unlinkSync(path.join(SQL_DIR, old));
  }

  fs.writeFileSync(path.join(SQL_DIR, "00_staging.sql"), `-- ME Piel lista 2026 — staging.
-- Costo = precio cliente c/IVA. productos.precio no se publica (Ordenar).
-- Antes: sql/patch_bajo_pedido_20260916.sql y sql/patch_fuentes_bajo_pedido_20260917.sql
-- Orden: 00, 01…, 99.

begin;

update public.fuentes_precio
   set notas = 'Mayoreo dermo. Lista 2026: precio cliente c/IVA. El PVP de la lista es techo, no costo.'
 where id = 'mepiel';

create table if not exists public._fc_mepiel_stg (
  sku text not null,
  ean text,
  nombre text not null,
  marca text,
  presentacion text,
  concentracion text,
  forma text,
  categoria text not null,
  subcategoria text,
  linea text,
  costo numeric(12,2),
  techo numeric(12,2),
  imagen_url text,
  oferta text
);

truncate public._fc_mepiel_stg;
commit;

select 'staging mepiel lista' as ok;
`);

  const groups = chunk(filas, 100);
  groups.forEach((group, i) => {
    const n = String(i + 1).padStart(2, "0");
    fs.writeFileSync(path.join(SQL_DIR, `${n}_filas.sql`), `-- ${n} — ${group.length} filas ME Piel
begin;
insert into public._fc_mepiel_stg values
${group.map(sqlTuple).join(",\n")};
commit;
`);
  });

  const last = String(groups.length + 1).padStart(2, "0");
  escribirAplicarMepiel(SQL_DIR, last);

  fs.writeFileSync(path.join(DOCS, "mepiel_manifiesto_2026.json"), JSON.stringify({
    generado: new Date().toISOString().slice(0, 10),
    conteos,
    sin_codigo: raw.sin_codigo || [],
  }, null, 2));

  console.log(JSON.stringify(conteos, null, 2));
  console.log(`SQL → ${SQL_DIR} (${groups.length + 1} filas + aplicar en 7 archivos)`);
}

function escribirAplicarMepiel(dir, last) {
  const falta = `do $$
begin
  if to_regclass('public._fc_mepiel_stg') is null then
    raise exception 'Falta la tabla temporal de ME Piel. No vuelvas a correr el 00.';
  end if;
end $$;`;

  fs.writeFileSync(path.join(dir, `${last}_aplicar.sql`), `-- Ya no corras este archivo: el editor lo cortaba por tiempo.
-- Sigue en orden con:
--   ${last}a_insertar_0.sql … ${last}a_insertar_3.sql
--   ${last}b_actualizar.sql, ${last}c_referencias.sql, ${last}d_cerrar.sql
do $$
begin
  raise exception 'No corras ${last}_aplicar.sql. Empieza por ${last}a_insertar_0.sql';
end $$;
`);

  for (let lote = 0; lote < 4; lote++) {
    fs.writeFileSync(path.join(dir, `${last}a_insertar_${lote}.sql`), `-- ${last}a lote ${lote} de 4 — da de alta los productos que aún no están.
-- No vuelvas a correr 00 ni 01…${String(Number(last) - 1).padStart(2, "0")}.
-- Solo compara código de barras y SKU. No llama fc_buscar_producto_escaneo.
begin;

${falta}

create index if not exists _fc_mepiel_stg_ean_idx on public._fc_mepiel_stg (ean);

with base as (
  select distinct on (ean) s.*
  from public._fc_mepiel_stg s
  where nullif(btrim(s.ean), '') is not null
  order by s.ean, s.costo nulls last
),
ranked as (
  select b.*,
         row_number() over (partition by b.sku order by b.ean) as rn
  from base b
)
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, subcategoria, imagen_url, bajo_pedido,
  concentracion, forma_farmaceutica
)
select
  r.nombre,
  case
    when r.rn = 1 and ps.id is null then r.sku
    when pm.id is null then 'FC-MP-' || r.ean
    else 'FC-MP-' || r.ean || '-' || r.rn::text
  end,
  r.ean,
  r.categoria,
  'marca',
  'Bajo pedido · mepiel'
    || coalesce(' · ' || nullif(r.linea, ''), '')
    || coalesce(' · oferta ' || nullif(r.oferta, ''), ''),
  r.costo,
  0,
  0, 1, true, false,
  r.marca, r.presentacion, r.subcategoria, nullif(r.imagen_url, ''), true,
  nullif(r.concentracion, ''), nullif(r.forma, '')
from ranked r
left join public.productos pe on pe.codigo_barras = r.ean
left join public.productos ps on ps.sku = r.sku
left join public.productos pm on pm.sku = ('FC-MP-' || r.ean)
where pe.id is null
  and ((mod(hashtext(r.ean), 4) + 4) % 4) = ${lote}
on conflict (sku) do nothing;

commit;

select 'lote ${lote}' as paso;
`);
  }

  fs.writeFileSync(path.join(dir, `${last}b_actualizar.sql`), `-- ${last}b — a los que ya existían les guarda el costo de ME Piel si es más barato.
-- No toca anaquel (stock > 0) ni un precio ya publicado.
begin;

${falta}

update public.productos p
   set bajo_pedido = true,
       activo = true,
       costo = case
         when p.costo is null or p.costo <= 0 then t.costo
         when t.costo < p.costo then t.costo
         else p.costo
       end,
       marca = coalesce(nullif(trim(p.marca), ''), t.marca),
       presentacion = coalesce(nullif(trim(p.presentacion), ''), nullif(t.presentacion, '')),
       concentracion = coalesce(nullif(trim(p.concentracion), ''), nullif(t.concentracion, '')),
       forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), nullif(t.forma, '')),
       imagen_url = coalesce(nullif(trim(p.imagen_url), ''), nullif(t.imagen_url, '')),
       subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria)
  from (
    select distinct on (ean) *
    from public._fc_mepiel_stg
    where nullif(btrim(ean), '') is not null
    order by ean, costo nulls last
  ) t
 where p.codigo_barras = t.ean
   and coalesce(p.stock, 0) = 0
   and coalesce(p.precio, 0) <= 0.01;

commit;

select 'actualizar' as paso;
`);

  fs.writeFileSync(path.join(dir, `${last}c_referencias.sql`), `-- ${last}c — anota el precio cliente con IVA como referencia de compra ME Piel.
begin;

${falta}

delete from public.producto_precios_referencia r
 using (
   select distinct ean
   from public._fc_mepiel_stg
   where nullif(btrim(ean), '') is not null
 ) t
 join public.productos p on p.codigo_barras = t.ean
 where r.producto_id = p.id
   and r.fuente = '${FUENTE_MEPIEL}'
   and r.origen = 'import_csv'
   and r.fecha = current_date;

insert into public.producto_precios_referencia
  (producto_id, fuente, tipo, precio, sku_externo, origen, notas)
select distinct on (p.id)
  p.id, '${FUENTE_MEPIEL}', 'compra', t.costo, t.ean, 'import_csv',
  'Lista ME Piel 2026 · precio cliente c/IVA'
    || coalesce(' · PVP c/IVA ' || t.techo::text, '')
    || coalesce(' · oferta ' || nullif(t.oferta, ''), '')
  from (
    select distinct on (ean) *
    from public._fc_mepiel_stg
    where nullif(btrim(ean), '') is not null
      and costo is not null
      and costo > 0
    order by ean, costo nulls last
  ) t
  join public.productos p on p.codigo_barras = t.ean
 order by p.id, t.costo;

commit;

select 'referencias' as paso, count(*) as de_hoy
from public.producto_precios_referencia
where fuente = '${FUENTE_MEPIEL}' and fecha = current_date;
`);

  fs.writeFileSync(path.join(dir, `${last}d_cerrar.sql`), `-- ${last}d — cierra la carga y borra la tabla temporal.
begin;
drop table if exists public._fc_mepiel_stg;
commit;

select
  count(*) filter (where coalesce(bajo_pedido, false)) as bajo_pedido,
  count(*) filter (
    where coalesce(bajo_pedido, false)
      and descripcion ilike '%mepiel%'
  ) as alta_mepiel_nueva
from public.productos;
`);
}

function mediana(nums) {
  const xs = nums.filter((n) => Number.isFinite(n)).sort((a, b) => a - b);
  if (!xs.length) return null;
  const mid = Math.floor(xs.length / 2);
  return xs.length % 2 ? xs[mid] : Math.round(((xs[mid - 1] + xs[mid]) / 2) * 100) / 100;
}

main();
