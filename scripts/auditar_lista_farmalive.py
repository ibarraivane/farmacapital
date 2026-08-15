#!/usr/bin/env python3
"""
Audita la lista de productos del ticket FarmaLive #9861 (FL-080826) vs catálogo
y genera SQL idempotente para cargar los faltantes con nombres limpios.

  python3 scripts/auditar_lista_farmalive.py
"""

from __future__ import annotations

import csv
import math
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "scripts"))

from parse_nombre_producto import parse_nombre_producto  # noqa: E402

CATALOGO = ROOT / "sql" / "preview_catalogo_campos_y_precios.csv"
OUT_MD = ROOT / "sql" / "generated" / "auditoria_lista_usuario_farmalive.md"
OUT_SQL = ROOT / "sql" / "patch_cargar_faltantes_1b_farmalive_corregido.sql"

MARGEN_VENTA = 0.35
TICKET = "FL-080826"

# Productos del ticket FarmaLive — barcode verificado (OCR + catálogo público MX)
PRODUCTOS = [
    {"q": "xl-3", "bc": "650240017100", "nombre": "XL-3 VR", "pres": "C/24", "costo": 88.20, "qty": 2},
    {"q": "xl-3 tab", "bc": "6502400170941", "nombre": "XL-3 Xtra", "pres": "C/12", "costo": 36.26, "qty": 4},
    {"q": "xl-3 tab c/10", "bc": "6502400525451", "nombre": "XL-3 Tab", "pres": "C/10", "costo": 30.38, "qty": 4},
    {"q": "vitacilina bebe", "bc": "354312225164", "nombre": "Vitacilina Bebé", "pres": "Pomada", "costo": 53.70, "qty": 1},
    {"q": "vitacilina 28", "bc": "7502250343072", "nombre": "Vitacilina 28", "pres": "Crema", "costo": 38.12, "qty": 1},
    {"q": "vitacilina ung", "bc": "750022503405381", "nombre": "Vitacilina Ungüento", "pres": "", "costo": 23.06, "qty": 1},
    {"q": "afrin spray", "bc": "75010506134531", "nombre": "Afrin Spray", "pres": "20 ML", "costo": 75.46, "qty": 1},
    {"q": "derma crema", "bc": "3543122250276", "nombre": "Derman Crema 50 g", "pres": "50 G", "costo": 44.69, "qty": 1},
    {"q": "tribedoce", "bc": "75022088947797", "nombre": "Tribedoce", "pres": "C/30", "costo": 17.64, "qty": 5},
    {"q": "nasalub sol", "bc": "650240015366", "nombre": "Nasalub Sol", "pres": "30 ML", "costo": 83.32, "qty": 1},
    {"q": "next tac c/10", "bc": "650240010538", "nombre": "Next Tab", "pres": "C/10", "costo": 23.52, "qty": 4},
    {"q": "silka medic gel", "bc": "650240007408", "nombre": "Silka Medic Gel", "pres": "Tubo 15 g", "costo": 80.56, "qty": 1},
    {"q": "contact ultra", "bc": "75029650608272", "nombre": "Contac Ultra", "pres": "", "costo": 32.34, "qty": 2},
    {"q": "deeflamox plus", "bc": "7503854221482", "nombre": "Deeflamox Plus", "pres": "", "costo": 42.41, "qty": 1},
    {"q": "tribedoce 5000", "bc": "75015015371829601", "nombre": "Tribedoce 50000", "pres": "Amp C/5", "costo": 73.11, "qty": 2},
    {"q": "riopan sobres", "bc": "7507201092730451", "nombre": "Riopan Sobres", "pres": "", "costo": 268.72, "qty": 1},
    {"q": "aderogyl amp", "bc": "36647980596011", "nombre": "Aderogyl", "pres": "Amp C/4", "costo": 96.92, "qty": 2},
    {"q": "tempra forte", "bc": "75010954525051", "nombre": "Tempra Forte", "pres": "50 MG C/24", "costo": 113.93, "qty": 1},
    {"q": "tukol-d inf", "bc": "6502400315021", "nombre": "Tukol-D", "pres": "Jbe Inf", "costo": 126.91, "qty": 1},
    {"q": "tukol-d adto", "bc": "650240010712", "nombre": "Tukol-D", "pres": "Jbe 125 ML", "costo": 117.42, "qty": 1, "alias": "tukol-d inf"},
    {"q": "rocainol ung", "bc": "7501312250181", "nombre": "Rocainol", "pres": "Ung 45 G", "costo": 53.12, "qty": 2},
    {"q": "genoprasol tab", "bc": "650240036354", "nombre": "Genoprazol", "pres": "Tab", "costo": 24.50, "qty": 1},
    {"q": "cond sico invisible", "bc": "7501685171118", "nombre": "Condón Sico", "pres": "C/3", "costo": 71.25, "qty": 1},
    {"q": "cond sico negro feel", "bc": "7501058367129", "nombre": "Condón Sico Negro Feel", "pres": "C/3", "costo": 54.71, "qty": 1},
    {"q": "condon sico rojo feel", "bc": "75010583683367", "nombre": "Condón Sico Rojo Feel", "pres": "C/3", "costo": 54.71, "qty": 1},
    {"q": "tabcin eferb", "bc": "7501008485316", "nombre": "Tabcin Eferv", "pres": "C/12", "costo": 37.73, "qty": 2},
    {"q": "fazolin f gotas", "bc": "780083146207", "nombre": "Fazolin F", "pres": "Gotas 15 ML", "costo": 26.85, "qty": 2},
    {"q": "syncolmax", "bc": "7501210734092301", "nombre": "Syncol Max", "pres": "Tab", "costo": 88.69, "qty": 1},
    {"q": "graneodin b frambuesa", "bc": "7501095409004", "nombre": "Graneodin B Frambuesa", "pres": "C/24", "costo": 42.64, "qty": 2},
    {"q": "alka-seltzer boost 10", "bc": "7501008497593", "nombre": "Alka-Seltzer Boost C/10", "pres": "C/10", "costo": 42.0, "qty": 2},
    {"q": "bepanthen", "bc": "7501008427330", "nombre": "Bepanthen", "pres": "100 G", "costo": 131.81, "qty": 1},
    {"q": "antifludes", "bc": "750525301508201", "nombre": "Antiflu-Des", "pres": "", "costo": 149.35, "qty": 1},
    {"q": "theraflu td", "bc": "7503050071598", "nombre": "Theraflu TD", "pres": "", "costo": 170.32, "qty": 2},
    {"q": "splash tears", "bc": "7509854054221", "nombre": "Splash Tears", "pres": "Sol oftálmica", "costo": 140.53, "qty": 1},
    {"q": "alka-seltzer boost tab", "bc": "75010084999001", "nombre": "Alka-Seltzer Boost", "pres": "C/50", "costo": 170.52, "qty": 1},
    {"q": "tempra jbe", "bc": "75012501050724298", "nombre": "Tempra Jbe", "pres": "120 ML", "costo": 166.19, "qty": 1},
    {"q": "iodex cristal", "bc": "7501064560163", "nombre": "Iodex Cristal", "pres": "60 G", "costo": 70.07, "qty": 1},
    # Lista Farmalive sin línea OCR — EAN verificado en empaque
    {"q": "estomaquil", "bc": "7501369200016", "nombre": "Estomaquil Polvo C/20", "pres": "C/20", "costo": 98.79, "qty": 0, "en_ticket": False},
    {"q": "pharmaton complete", "bc": "3664798062229", "nombre": "Pharmaton Complete", "pres": "C/30", "costo": 118.0, "qty": 0, "en_ticket": False},
    {"q": "pisacaina", "bc": "7501125112881", "nombre": "Pisacaina 2% Sol 50 ml", "pres": "50 ml", "costo": 85.0, "qty": 0, "en_ticket": False},
    {"q": "redoxon 2pack", "bc": "7501008421321", "nombre": "Redoxon 1g 2-pack", "pres": "2x10 tab", "costo": 130.0, "qty": 0, "en_ticket": False},
    {"q": "eucaliptine", "bc": "7501159525015", "nombre": "Eucaliptine Jarabe", "pres": "140 ml", "costo": 107.0, "qty": 0, "en_ticket": False},
    {"q": "tabcin noche", "bc": "7501008499702", "nombre": "Tabcin Noche", "pres": "C/12 caps", "costo": 71.21, "qty": 0, "en_ticket": False},
    {"q": "motrin infantil", "bc": "7501007535494", "nombre": "Motrin Infantil Susp 120 ml", "pres": "120 ml frutas", "costo": 186.40, "qty": 1, "en_ticket": True},
    {"q": "sedalmerck max", "bc": "7501298215099", "nombre": "Sedalmerck Max", "pres": "C/24 tab", "costo": 122.06, "qty": 2, "en_ticket": True},
]

NO_EN_TICKET: set[str] = set()


def precio_venta(costo: float) -> float:
    if costo <= 0:
        return 0.0
    return math.ceil(costo * (1 + MARGEN_VENTA) * 100) / 100


def sku_for_bc(bc: str) -> str:
    return f"FC-{bc[-8:]}"


def sql_quote(s: str) -> str:
    return "'" + s.replace("'", "''") + "'"


def load_catalog_by_bc() -> dict[str, dict]:
    out: dict[str, dict] = {}
    if not CATALOGO.exists():
        return out
    with CATALOGO.open(encoding="utf-8") as f:
        for row in csv.DictReader(f):
            bc = (row.get("codigo_barras") or "").strip()
            if bc:
                out[bc] = row
    return out


def nombre_display(p: dict) -> str:
    pres = (p.get("pres") or "").strip()
    base = p["nombre"]
    return f"{base} {pres}".strip() if pres else base


def sql_block(p: dict, line: int) -> str:
    bc = p["bc"]
    sku = sku_for_bc(bc)
    parsed = parse_nombre_producto(nombre_display(p))
    nombre = nombre_display(p)
    costo = p["costo"]
    precio = precio_venta(costo)
    qty = max(1, int(p.get("qty") or 1))
    desc = f"{nombre} — Ticket {TICKET}"
    tipo = "MEDICAMENTO" if parsed.categoria in ("Medicamento", "Medicamentos") else "GENERICO"
    cat = parsed.categoria or "GENERAL"

    return f"""
-- {TICKET} · {p['q']} · {bc}
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = {sql_quote(bc)} limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = {sql_quote(bc)};
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', {sql_quote(nombre[:200])},
      'sku', {sql_quote(sku)},
      'codigo_barras', {sql_quote(bc)},
      'categoria', {sql_quote(cat)},
      'tipo', {sql_quote(tipo)},
      'descripcion', {sql_quote(desc)},
      'costo', {costo:.2f},
      'precio', {precio:.2f},
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      {qty},
      {sql_quote(f'TK-{TICKET}-{line}')},
      NULL::date,
      {costo:.2f},
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ({sql_quote(bc)}, v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;"""


def main() -> None:
    by_bc = load_catalog_by_bc()
    OUT_MD.parent.mkdir(parents=True, exist_ok=True)

    seen_q: set[str] = set()
    rows_audit: list[str] = []
    sql_blocks: list[str] = []
    line = 0

    registrados = 0
    faltantes = 0
    no_ticket = 0

    for p in PRODUCTOS:
        q = p["q"]
        if q in seen_q:
            continue
        seen_q.add(q)

        if (p.get("en_ticket") is False or q in NO_EN_TICKET) and not p.get("bc"):
            no_ticket += 1
            rows_audit.append(f"| {q} | — | ❓ No en ticket OCR | — | Sin barcode verificado |")
            continue

        bc = p.get("bc")
        if not bc:
            faltantes += 1
            rows_audit.append(f"| {q} | — | ⚠️ Sin barcode | — | Revisar OCR manual |")
            continue

        cat = by_bc.get(bc)
        nombre_cat = (
            cat.get("nombre")
            or cat.get("nombre_comercial")
            or cat.get("nombre_ticket")
            or ""
        )[:45] if cat else ""
        sku_cat = cat.get("sku", "") if cat else ""

        if cat:
            registrados += 1
            ok = (
                q.lower() in (nombre_cat or "").lower()
                or p["nombre"].lower().split()[0] in (nombre_cat or "").lower()
                or (nombre_cat or "").lower().split()[0] in q.lower()
            )
            estado = "✅ Registrado" if ok else "⚠️ Registrado (revisar nombre)"
            rows_audit.append(
                f"| {q} | `{bc}` | {estado} | {sku_cat} | {nombre_cat or '(sin nombre)'} |"
            )
        else:
            faltantes += 1
            line += 1
            rows_audit.append(
                f"| {q} | `{bc}` | ❌ Falta cargar | — | {nombre_display(p)} · ${p['costo']:.2f} |"
            )
            sql_blocks.append(sql_block(p, line))

    md = f"""# Auditoría — lista usuario vs catálogo (FarmaLive {TICKET})

Ticket OCR: `.tmp_ocr_vision/FarmaLive.txt` (#9861, 08/08/2026)

> **Fuente catálogo:** `{CATALOGO.relative_to(ROOT)}`  
> Regenera antes de auditar: `python3 scripts/exportar_catalogo_supabase.py`

| Producto | Barcode | Estado | SKU | Detalle |
|----------|---------|--------|-----|---------|
"""
    md += "\n".join(rows_audit)
    md += f"""

## Resumen
- **Registrados en catálogo:** {registrados}
- **Faltan cargar:** {faltantes}
- **No encontrados en ticket OCR:** {no_ticket}

## Causa raíz
El parser FarmaLive solo reconocía barcodes `750…`/`354…`. Los productos **Genomma Lab** (`65024…`) y varios OCR truncados **nunca entraron** al SQL de carga; otros quedaron con nombres mezclados (ej. Vitacilina 28 dentro del lubricante).

## SQL generado
Ejecutar en Supabase **después** de `sql/patch_cargar_faltantes_0_fix_rpcs.sql`:

`{OUT_SQL.relative_to(ROOT)}` ({len(sql_blocks)} productos)
"""
    OUT_MD.write_text(md, encoding="utf-8")

    header = f"""-- ============================================================================
-- CARGAR faltantes corregidos — FarmaLive {TICKET}
-- {len(sql_blocks)} productos con barcode y nombre limpio (Genomma 65024…, etc.)
-- PASO 0 previo: sql/patch_cargar_faltantes_0_fix_rpcs.sql
-- ============================================================================

begin;

create temp table if not exists _fc_carga_map (
  codigo_barras text primary key,
  producto_id bigint
) on commit preserve rows;

insert into _fc_carga_map (codigo_barras, producto_id)
select codigo_barras, id from public.productos
where codigo_barras is not null and btrim(codigo_barras) <> ''
on conflict (codigo_barras) do nothing;

"""
    footer = """
commit;

select count(*) as productos_fc from public.productos where sku like 'FC-%';
"""
    OUT_SQL.write_text(header + "\n".join(sql_blocks) + footer, encoding="utf-8")

    print(f"Auditoría: {OUT_MD}")
    print(f"SQL:       {OUT_SQL} ({len(sql_blocks)} bloques)")
    print(f"Registrados: {registrados} | Faltantes: {faltantes} | No en ticket: {no_ticket}")


if __name__ == "__main__":
    main()
