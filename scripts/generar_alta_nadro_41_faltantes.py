#!/usr/bin/env python3
"""Alta catálogo: 41 EAN del ticket Nadro 1658128647824-01 que Recibir
marcó «sin registrar». Stock 0. Sin lote ni MMAA.
Precio = ceil(costo / (1 - margen)), igual que Recibir (marca 25% / genérico 60%).
"""
from __future__ import annotations

import math
from pathlib import Path

OUT = Path(__file__).resolve().parents[1] / "sql" / "patch_alta_catalogo_nadro_41_20260831.sql"


def precio(costo: float, tipo: str) -> int:
    margen = 25 if tipo == "marca" else 60
    return math.ceil(costo / (1 - margen / 100))


def sku_de(ean: str) -> str:
    return "FC-" + ean[-8:]


# ean, nombre POS, costo ticket, tipo, categoria, receta
ROWS = [
    ("7501008499412", "Flanax 660 mg 8 tabletas", 230.00, "marca", "Medicamentos", False),
    ("7501008499092", "Flanax Nocto 220/25 mg 20 comprimidos", 130.50, "marca", "Medicamentos", False),
    ("7501008498866", "Flanax 550 mg 6 tabletas", 105.00, "marca", "Medicamentos", False),
    ("7501070600709", "Syncol 500/25/15 mg 12 comprimidos", 97.12, "marca", "Medicamentos", False),
    ("354312225133", "Vitacilina ungüento 28 g", 37.57, "marca", "Medicamentos", False),
    ("354312225140", "Vitacilina ungüento 16 g", 25.19, "marca", "Medicamentos", False),
    ("7502321440013", "Buscapina Duo 10/500 mg 10 tabletas", 122.36, "marca", "Medicamentos", False),
    ("7501165011649", "Buscapina 10 mg 24 grageas", 172.04, "marca", "Medicamentos", False),
    ("7501349026377", "Gentamicina 160 mg solución inyectable 2 ml AMSA", 12.71, "generico", "Medicamentos", True),
    ("7502216798878", "Pioglitazona 30 mg 7 tabletas LGEN", 17.76, "generico", "Medicamentos", True),
    ("7501019068911", "Panty protector Saba largo 28", 27.28, "marca", "Cuidado personal", False),
    ("7501058715913", "Picot Plus 9 sobres efervescentes", 46.12, "marca", "Medicamentos", False),
    ("7501019039355", "Parches Saba térmicos 3 pz", 57.41, "marca", "Cuidado personal", False),
    ("7501349029613", "Combedi DX Complejo B / Dexametasona 6 amp AMSA", 55.76, "generico", "Medicamentos", True),
    ("4005800631702", "Eucerin pH5 pomada labial", 85.20, "marca", "Cuidado personal", False),
    ("650240053634", "Alli Triple 50/.25/50/50 mg 6 tabletas", 79.87, "marca", "Medicamentos", False),
    ("7501019032424", "Tampones Saba compactos super", 31.39, "marca", "Cuidado personal", False),
    ("7502268541491", "Electrolife Zero uva 625 ml", 19.36, "marca", "Bebidas", False),
    ("75073107", "Rexona Woman Clinical Classic stick 46 g", 55.68, "marca", "Cuidado personal", False),
    ("75073114", "Rexona Men Clinical Clean stick 46 g", 55.68, "marca", "Cuidado personal", False),
    ("7501349013223", "Deflazacort 30 mg 10 tabletas LGEN", 110.89, "generico", "Medicamentos", True),
    ("4005900948670", "Labello Caring Beauty Red 4.8 g", 79.58, "marca", "Cuidado personal", False),
    ("7501054503637", "Labello Med Protection 4.8 g", 54.87, "marca", "Cuidado personal", False),
    ("7501019050473", "Toalla húmeda Tena adulto EG", 55.00, "marca", "Cuidado personal", False),
    ("7502256729917", "Oxímetro Inhala Care pulso dedo FS10E", 303.80, "marca", "Botiquín", False),
    ("3337875784054", "CeraVe gel limpiador contra imperfecciones 236 ml", 273.91, "marca", "Cuidado personal", False),
    ("7501300450227", "Bactrim 200/40 mg suspensión 100 ml", 188.44, "marca", "Medicamentos", True),
    ("7501349028234", "Omeprazol 40 mg solución inyectable ampolleta LGEN", 29.06, "generico", "Medicamentos", True),
    ("7501300450210", "Bactrim F 800/160 mg 15 tabletas", 331.87, "marca", "Medicamentos", True),
    ("7501349022768", "Cefalotina 1 g solución inyectable FA 5 ml LGEN", 56.28, "generico", "Medicamentos", True),
    ("7501125195105", "Cefuroxima 750 mg FA + ampolleta 5 ml", 42.56, "generico", "Medicamentos", True),
    ("7502009740442", "Klarix Claritromicina 250 mg 10 tabletas", 44.88, "generico", "Medicamentos", True),
    ("7502227879597", "Oxitetraciclina 500 mg 16 cápsulas", 70.00, "generico", "Medicamentos", True),
    ("7502227870259", "Roxidolin Doxiciclina 100 mg 10 cápsulas", 21.15, "generico", "Medicamentos", True),
    ("7501493888302", "Doxiciclina 100 mg 10 cápsulas Ken LGEN", 23.86, "generico", "Medicamentos", True),
    ("7506442700643", "Irbesartán + HCTZ 150/12.5 mg 28 tabletas Camber", 91.86, "generico", "Medicamentos", True),
    ("7501349022492", "Irbesartán 150 mg 28 tabletas LGEN", 92.36, "generico", "Medicamentos", True),
    ("7502216804708", "Irbesartán 150 mg frasco 28 tabletas LGEN", 97.42, "generico", "Medicamentos", True),
    ("7506442700629", "Irbesartán 300 mg 28 tabletas LGEN", 59.66, "generico", "Medicamentos", True),
    ("7502216792760", "Omeprazol 20 mg 30 cápsulas LGEN", 16.13, "generico", "Medicamentos", True),
    ("7502216792555", "Omeprazol 20 mg 14 cápsulas LGEN", 9.50, "generico", "Medicamentos", True),
]


def sql_str(s: str) -> str:
    return "'" + s.replace("'", "''") + "'"


def main() -> None:
    skus = [sku_de(e) for e, *_ in ROWS]
    assert len(skus) == len(set(skus)), "SKU repetido"
    assert len(ROWS) == 41, len(ROWS)

    values = []
    for i, (ean, nombre, costo, tipo, cat, receta) in enumerate(ROWS):
        costo_sql = f"{costo:.2f}::numeric" if i == 0 else f"{costo:.2f}"
        values.append(
            "        ({ean}, {sku}, {nombre}, {costo}, {precio}, {tipo}, {cat}, {receta})".format(
                ean=sql_str(ean),
                sku=sql_str(sku_de(ean)),
                nombre=sql_str(nombre),
                costo=costo_sql,
                precio=precio(costo, tipo),
                tipo=sql_str(tipo),
                cat=sql_str(cat),
                receta="true" if receta else "false",
            )
        )

    body = f"""-- 41 productos del ticket Nadro 1658128647824-01 que Recibir marcó
-- «sin registrar en catálogo». Stock 0. Sin lote ni caducidad (MMAA de la caja).
-- Precio provisional: marca 25% / genérico 60% sobre venta (igual que Recibir).
-- Enlaza renglones pendientes. Idempotente. Pegar en Supabase → SQL Editor → Run.

begin;

do $$
declare
  r record;
  v_pid bigint;
  v_sku text;
  v_creados int := 0;
  v_existian int := 0;
  v_enlazados int := 0;
begin
  for r in
    select * from (values
{chr(10).join(v + ("," if i < len(values) - 1 else "") for i, v in enumerate(values))}
    ) as t(ean, sku, nombre, costo, precio, tipo, categoria, receta)
  loop
    v_pid := public.fc_buscar_producto_escaneo(r.ean);
    if v_pid is not null then
      v_existian := v_existian + 1;
    else
      v_sku := r.sku;
      if exists (
        select 1 from public.productos p
        where p.sku = v_sku
          and coalesce(p.codigo_barras, '') <> r.ean
      ) then
        v_sku := 'FC-ND-' || right(r.ean, 8);
      end if;

      insert into public.productos (
        nombre, sku, codigo_barras, categoria, tipo, descripcion,
        costo, precio, stock, stock_minimo, activo, requiere_receta, proveedor
      ) values (
        r.nombre, v_sku, r.ean, r.categoria, r.tipo,
        'Alta Nadro 1658128647824-01 · 2026-08-31 · listo para pistola',
        r.costo, r.precio, 0, 1, true, r.receta, 'Nadro'
      )
      returning id into v_pid;
      v_creados := v_creados + 1;
    end if;
  end loop;

  update public.recepcion_items i
  set
    producto_id = public.fc_buscar_producto_escaneo(i.codigo_escaneado),
    pendiente_alta = false
  where i.pendiente_alta
    and i.producto_id is null
    and public.fc_buscar_producto_escaneo(i.codigo_escaneado) is not null;

  get diagnostics v_enlazados = row_count;

  raise notice 'Nadro 41: creados=% ya_estaban=% renglones_enlazados=%',
    v_creados, v_existian, v_enlazados;
end
$$;

commit;

select
  p.sku,
  p.codigo_barras as ean,
  left(p.nombre, 52) as nombre,
  p.costo,
  p.precio,
  p.stock,
  p.tipo
from public.productos p
where p.codigo_barras in (
{chr(10).join("  " + sql_str(e) + ("," if i < len(ROWS) - 1 else "") for i, (e, *_rest) in enumerate(ROWS))}
)
order by p.nombre;
"""
    OUT.write_text(body, encoding="utf-8")
    print(f"sql  {OUT}")
    print(f"lineas {len(ROWS)}")


if __name__ == "__main__":
    main()
