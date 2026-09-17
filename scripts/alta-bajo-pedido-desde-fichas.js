#!/usr/bin/env node
/**
 * Arma el SQL de alta bajo pedido a partir de fichas de proveedor.
 * No inventa EAN, nombre, marca ni foto.
 *
 *   node scripts/alta-bajo-pedido-desde-fichas.js docs/fichas_proxima_vitrina.json
 *
 * El JSON es un arreglo de objetos. Campos:
 *   ean, nombre, marca, presentacion, categoria, precio, imagen_url
 * Opcionales: subcategoria, forma, fuente
 *
 * categoria canónica: Cuidado personal | Vitaminas | Suplemento | Dispositivo médico
 * Dermatología: categoria=Cuidado personal + subcategoria=Dermatología
 * Nutrición deportiva: categoria=Suplemento + subcategoria=Nutrición deportiva
 */
"use strict";

const fs = require("fs");
const path = require("path");

const CATEGORIAS = new Set([
  "Analgésico",
  "Antiinflamatorio",
  "Antibiótico",
  "Gastro",
  "Diabetes",
  "Hipertensión",
  "Alergia",
  "Vitaminas",
  "Suplemento",
  "Herbolario",
  "Hidratación",
  "Cardiovascular",
  "Hormonales",
  "Respiratorio",
  "Dispositivo médico",
  "Botiquín",
  "Higiene",
  "Bebidas",
  "Básicos",
  "Abarrotes",
  "Minisuper",
  "Cuidado personal",
  "Otro",
]);

const MARCAS_CASA = new Set([
  "frabel",
  "frabel 2",
  "frabel2",
  "lgen",
  "nadro",
  "marzam",
  "levic",
  "genericos",
  "generico",
  "genérico",
]);

function norm(s) {
  return String(s || "")
    .trim()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase();
}

function sqlStr(s) {
  return "'" + String(s ?? "").replace(/'/g, "''") + "'";
}

function sqlNull(s) {
  const t = String(s || "").trim();
  return t ? sqlStr(t) : "null";
}

function skuDe(ean) {
  return "FC-" + String(ean).slice(-8);
}

function esNombreTicket(nombre) {
  const n = String(nombre || "").trim();
  if (!n) return true;
  if (/\b(BLOQ|ANTHE|UVAIR|UVMUNE|JBN|TCO|CRA CORP|POM LAB|SH ACOND)\b/i.test(n)) return true;
  const letters = n.replace(/[^A-Za-zÁÉÍÓÚáéíóúÑñ]/g, "");
  if (letters.length >= 8) {
    const upper = letters.replace(/[^A-ZÁÉÍÓÚÑ]/g, "").length;
    if (upper / letters.length >= 0.85 && /\s/.test(n)) return true;
  }
  return false;
}

function validarFicha(raw, i) {
  const errores = [];
  const ean = String(raw.ean || "").replace(/\D/g, "");
  if (ean.length < 8 || ean.length > 14) {
    errores.push("ean de 8 a 14 dígitos (el SKU interno de Promexsa/Birdman no sirve)");
  }
  const nombre = String(raw.nombre || "").trim();
  if (!nombre) errores.push("nombre de mostrador vacío");
  if (nombre && esNombreTicket(nombre)) {
    errores.push("nombre parece código de ticket; abre la ficha del proveedor");
  }
  const marca = String(raw.marca || "").trim();
  if (!marca) errores.push("marca vacía");
  if (marca && MARCAS_CASA.has(norm(marca))) {
    errores.push(`marca de casa del mayorista (${marca}); usa la marca real`);
  }
  const presentacion = String(raw.presentacion || "").trim();
  if (!presentacion) errores.push("presentacion vacía");
  const categoria = String(raw.categoria || "").trim();
  if (!CATEGORIAS.has(categoria)) {
    errores.push(`categoria no canónica: ${categoria || "(vacía)"}`);
  }
  const precio = Number(raw.precio);
  if (!Number.isFinite(precio) || precio <= 0) {
    errores.push("precio ancla > 0 (lista/público del mayorista, sin MP)");
  }
  const imagen = String(raw.imagen_url || "").trim();
  if (!/^https:\/\//i.test(imagen)) {
    errores.push("imagen_url https obligatoria");
  }
  if (errores.length) {
    const err = new Error(`Ficha #${i + 1} (${ean || nombre || "?"}): ${errores.join("; ")}`);
    err.detalles = errores;
    throw err;
  }
  return {
    ean,
    sku: skuDe(ean),
    nombre,
    marca,
    presentacion,
    categoria,
    subcategoria: String(raw.subcategoria || "").trim() || null,
    forma: String(raw.forma || raw.forma_farmaceutica || "").trim() || null,
    precio: Math.round(precio * 100) / 100,
    imagen_url: imagen,
    fuente: String(raw.fuente || "").trim() || "ficha proveedor",
  };
}

function validarFichas(list) {
  if (!Array.isArray(list) || !list.length) {
    throw new Error("El JSON tiene que ser un arreglo con al menos una ficha");
  }
  const out = list.map(validarFicha);
  const eans = new Set();
  for (const f of out) {
    if (eans.has(f.ean)) throw new Error(`EAN repetido: ${f.ean}`);
    eans.add(f.ean);
  }
  return out;
}

function armarSql(fichas, { titulo = "lote vitrina bajo pedido" } = {}) {
  const rows = fichas
    .map(
      (f) =>
        `  (${sqlStr(f.ean)}, ${sqlStr(f.sku)}, ${sqlStr(f.nombre)}, ${sqlStr(f.marca)}, ${sqlStr(f.presentacion)}, ${sqlStr(f.categoria)}, ${sqlNull(f.subcategoria)}, ${sqlNull(f.forma)}, ${f.precio}::numeric, ${sqlStr(f.imagen_url)}, ${sqlStr(f.fuente)})`
    )
    .join(",\n");
  const eanList = fichas.map((f) => `  ${sqlStr(f.ean)}`).join(",\n");
  return `-- ============================================================================
-- FARMA CAPITAL — ${titulo}
-- Generado por scripts/alta-bajo-pedido-desde-fichas.js
-- ${fichas.length} SKU(s). Stock 0. Sin lote ni caducidad.
-- Si el EAN ya existe CON stock: no se marca bajo_pedido.
-- ============================================================================

begin;

do $$
begin
  if not exists (
    select 1
      from information_schema.columns
     where table_schema = 'public'
       and table_name = 'productos'
       and column_name = 'bajo_pedido'
  ) then
    raise exception 'Primero corre sql/patch_bajo_pedido_20260916.sql (falta productos.bajo_pedido)';
  end if;
end
$$;

create temp table _fc_vitrina_bp (
  ean text primary key,
  sku text not null,
  nombre text not null,
  marca text not null,
  presentacion text not null,
  categoria text not null,
  subcategoria text,
  forma text,
  precio numeric(12,2) not null,
  imagen_url text not null,
  descripcion text not null
) on commit drop;

insert into _fc_vitrina_bp values
${rows};

insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, subcategoria, imagen_url,
  bajo_pedido
)
select
  t.nombre,
  case
    when exists (
      select 1 from public.productos p
      where p.sku = t.sku
        and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  'marca',
  t.descripcion,
  null,
  t.precio,
  0,
  1,
  true,
  false,
  t.marca,
  t.presentacion,
  t.forma,
  t.subcategoria,
  t.imagen_url,
  true
from _fc_vitrina_bp t
where public.fc_buscar_producto_escaneo(t.ean) is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = t.ean
  );

update public.productos p
   set bajo_pedido = true,
       activo = true,
       marca = coalesce(nullif(trim(p.marca), ''), t.marca),
       presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
       imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen_url),
       precio = case when coalesce(p.precio, 0) <= 0.01 then t.precio else p.precio end
  from _fc_vitrina_bp t
 where (p.codigo_barras = t.ean or p.id = public.fc_buscar_producto_escaneo(t.ean))
   and coalesce(p.stock, 0) = 0;

insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select p.id, t.imagen_url, 1, true, 'distribuidor'
  from _fc_vitrina_bp t
  join public.productos p
    on p.codigo_barras = t.ean
    or p.id = public.fc_buscar_producto_escaneo(t.ean)
 where coalesce(p.bajo_pedido, false) = true
   and not exists (
     select 1 from public.producto_imagenes i
      where i.producto_id = p.id
        and i.url = t.imagen_url
   );

commit;

select
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.marca,
  p.categoria,
  p.subcategoria,
  p.precio,
  p.stock,
  p.bajo_pedido,
  left(p.imagen_url, 80) as imagen
from public.productos p
where p.codigo_barras in (
${eanList}
)
order by p.categoria, p.subcategoria nulls first, p.nombre;
`;
}

function main(argv = process.argv.slice(2)) {
  const input = argv[0];
  if (!input || input === "-h" || input === "--help") {
    process.stderr.write(
      "Uso: node scripts/alta-bajo-pedido-desde-fichas.js docs/fichas_proxima_vitrina.json [salida.sql]\n"
    );
    process.exit(input ? 0 : 1);
  }
  const abs = path.resolve(process.cwd(), input);
  const raw = JSON.parse(fs.readFileSync(abs, "utf8"));
  const fichas = validarFichas(raw);
  const sql = armarSql(fichas, { titulo: path.basename(abs, path.extname(abs)) });
  const dest = argv[1];
  if (dest) {
    const out = path.resolve(process.cwd(), dest);
    fs.writeFileSync(out, sql);
    process.stderr.write(`${fichas.length} ficha(s) → ${out}\n`);
  } else {
    process.stdout.write(sql);
  }
}

if (require.main === module) {
  try {
    main();
  } catch (err) {
    process.stderr.write(`${err.message}\n`);
    process.exit(1);
  }
}

module.exports = { validarFicha, validarFichas, armarSql, skuDe, esNombreTicket };
