#!/usr/bin/env python3
"""Ticket Equilibrio POS · folio 450593 (04-nov-2026) → catálogo + cola Recibir.

Cliente 307513 LUIS ANGEL PALILLERO VENTURA · sucursal Iztapalapa 2 · pedido online.
2 renglones / 8 pzas / Subtotal P.U. $224.40 + IVA $12.48 = Total $236.88.
Costo = P.U. neto del papel (antes de IVA). Lote de fábrica sí. Caducidad NO (MMAA caja).
Fichas BuscaMed / Dilopsan / Levic — no el código truncado del ticket.
"""
from __future__ import annotations

import csv
import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_carga_tickets_20260915 import (  # noqa: E402
    foto_url,
    write_carga_sql,
)
from generar_recepcion_borrador import report  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]
OUT_CSV = ROOT / "sql" / "generated" / "ticket_equilibrio_450593.csv"
OUT_MD = ROOT / "sql" / "LEERME_equilibrio_450593.md"
OUT_SOLO = ROOT / "sql" / "patch_equilibrio_450593_SOLO_pegar_esto.sql"
OUT_SOLO_MD = ROOT / "sql" / "LEERME_equilibrio_450593_SOLO_pegar_esto.md"

FOLIO = "450593"
PROVEEDOR = "Equilibrio"
FECHA = "2026-11-04"
SUBTOTAL_PU = 224.40
TOTAL = 236.88
IVA = 12.48


def ceil_pvp(costo: float, tipo: str) -> int:
    factor = 1.25 if tipo == "marca" else 1.6
    return int(math.ceil(costo * factor))


def row(
    *,
    ean: str,
    codigo: str,
    snap: str,
    nombre: str,
    qty: int,
    pu: float,
    lote: str,
    tipo: str = "generico",
    categoria: str = "Medicamentos",
    subcategoria: str | None = None,
    forma: str | None = None,
    marca: str | None = None,
    laboratorio: str | None = None,
    presentacion: str | None = None,
    principio: str | None = None,
    concentracion: str | None = None,
    receta: bool = True,
    ya: bool = False,
    sku: str | None = None,
    foto_file: str | None = None,
) -> dict:
    precio = ceil_pvp(pu, tipo)
    return {
        "ean": ean,
        "sku": sku or f"EQ-{codigo}",
        "nombre": nombre,
        "snap": snap,
        "qty": qty,
        "pu": pu,
        "sub": round(pu * qty, 2),
        "precio": precio,
        "tipo": tipo,
        "categoria": categoria,
        "subcategoria": subcategoria,
        "forma": forma,
        "marca": marca,
        "laboratorio": laboratorio,
        "presentacion": presentacion,
        "principio": principio,
        "concentracion": concentracion,
        "receta": receta,
        "ya": ya,
        "foto": foto_url(foto_file) if foto_file else None,
        "foto_file": f"catalogo-propia/{foto_file}" if foto_file else None,
        "lote": lote,
        "match": "ya" if ya else "alta",
    }


ROWS = [
    row(
        ean="7506022315281",
        codigo="JAY142",
        snap="JAY142 PRUEBA DE EMBARAZO MEDITEST 1 CJA 1 PZA",
        nombre="Meditest",
        qty=5,
        pu=15.60,
        lote="2605979401",
        tipo="marca",
        categoria="Salud sexual",
        subcategoria=None,
        forma="Prueba",
        marca="Meditest",
        laboratorio="Jayor",
        presentacion="Caja con 1 prueba tipo pluma",
        principio="Gonadotropina coriónica (test)",
        concentracion=None,
        receta=False,
        ya=True,
        sku="FC-66055303",
        foto_file="meditest-prueba-embarazo-pluma-7506022315281.jpg",
    ),
    row(
        ean="0780083140731",
        codigo="COL100",
        snap="COL100 VENGESIC 20 GRAG 200/100/0.5 MG",
        nombre="Vengesic",
        qty=3,
        pu=48.80,
        lote="26142061",
        tipo="generico",
        categoria="Medicamentos",
        subcategoria="Muscular",
        forma="Grageas",
        marca="Vengesic",
        laboratorio="Collins",
        presentacion="Caja con 20 grageas",
        principio="Metocarbamol / fenilbutazona / dexametasona / hidróxido de aluminio",
        concentracion="200/100/0.5 mg",
        receta=True,
        ya=False,
        sku="FC-83140731",
        foto_file="vengesic-collins-20-grageas-0780083140731.jpg",
    ),
]


def strip_producto_imagenes(body: str) -> str:
    """Sin galería en el mismo txn: si falla producto_imagenes, no entra la recepción."""
    lines = []
    skip = False
    for line in body.splitlines(keepends=True):
        if line.startswith("insert into public.producto_imagenes"):
            skip = True
            continue
        if skip:
            if line.strip() == "" or line.startswith("--"):
                skip = False
                if line.startswith("--"):
                    lines.append(line)
            continue
        lines.append(line)
    return "".join(lines)


def write_solo(carga_path: Path) -> None:
    header = f"""-- =============================================================================
-- PEGAR TODO ESTE ARCHIVO en Supabase → SQL Editor → Run
-- Equilibrio folio {FOLIO} · 04-nov-2026 · ${TOTAL:,.2f} · 2 renglones / 8 pzas
-- Merge a GitHub NO crea la tarjeta. Este Run sí.
-- Sin bloques dollar-quote. Sin galería extra. Idempotente en borrador.
-- Al final: VERIFICACION con folio {FOLIO} en borrador.
-- Luego: tablet Recibir → recargar → tarjeta Equilibrio {FOLIO}.
-- =============================================================================

"""
    body = strip_producto_imagenes(carga_path.read_text(encoding="utf-8"))
    carga_path.write_text(body, encoding="utf-8")
    verificacion = f"""
-- VERIFICACION
select
  r.proveedor,
  r.folio,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  coalesce(sum(i.cantidad), 0) as piezas,
  count(*) filter (where not coalesce(i.confirmado, false)) as sin_confirmar
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '{FOLIO}'
  and coalesce(r.proveedor, '') ilike '%equilibrio%'
group by r.id, r.proveedor, r.folio, r.estado, r.total_ticket;
"""
    OUT_SOLO.write_text(header + body + verificacion, encoding="utf-8")


def main() -> None:
    piezas = sum(r["qty"] for r in ROWS)
    sub = round(sum(r["sub"] for r in ROWS), 2)
    assert piezas == 8, piezas
    assert abs(sub - SUBTOTAL_PU) < 0.02, (sub, SUBTOTAL_PU)
    for r in ROWS:
        assert abs(r["pu"] * r["qty"] - r["sub"]) < 0.03, r
        assert not r["nombre"].isupper(), r["nombre"]
        assert len(r["ean"]) >= 8, r["ean"]
        assert r["lote"], r
        if not r["ya"]:
            assert r["foto_file"], r["nombre"]

    altas = [r for r in ROWS if not r["ya"]]
    altas_ean = {r["ean"]: r for r in altas}
    ticket = {
        "key": "equilibrio_450593",
        "header": (
            f"Equilibrio · ticket {FOLIO} · {FECHA} · cliente 307513 Palillero · "
            f"pedido online Iztapalapa 2 · Total ${TOTAL:,.2f} "
            f"(subtotal P.U. ${SUBTOTAL_PU:,.2f} + IVA ${IVA:.2f}) · "
            f"{len(ROWS)} renglones / {piezas} pzas. "
            "Claves EQF → EAN ficha/BuscaMed/Dilopsan. Lote de fábrica sí. "
            "Caducidad NO: MMAA de la caja. 0000 inválido."
        ),
        "tmp": "_fc_eq_450593",
        "folio": FOLIO,
        "proveedor": PROVEEDOR,
        "proveedor_ilike": "equilibrio",
        "fecha": FECHA,
        "total": TOTAL,
        "notas": (
            f"Ticket Equilibrio folio {FOLIO} · cliente 307513 Luis Angel · "
            f"04-nov-2026 · {piezas} pzas · ${TOTAL:,.2f} · lote de fábrica en renglón; "
            "MMAA de la caja · cola Recibir"
        ),
        "rows": ROWS,
    }

    sql_path = write_carga_sql(ticket)
    write_solo(sql_path)

    OUT_CSV.parent.mkdir(parents=True, exist_ok=True)
    with OUT_CSV.open("w", newline="", encoding="utf-8") as fh:
        w = csv.writer(fh)
        w.writerow([
            "linea", "folio", "fecha", "proveedor", "ean",
            "descripcion_ticket", "nombre_mostrador", "cantidad",
            "precio_unitario", "subtotal", "lote", "sku_farmacapital",
            "total_ticket", "match",
        ])
        for i, r in enumerate(ROWS, start=1):
            w.writerow([
                i, FOLIO, FECHA, PROVEEDOR, r["ean"],
                r["snap"], r["nombre"], r["qty"],
                f"{r['pu']:.2f}", f"{r['sub']:.2f}", r["lote"], r["sku"],
                f"{TOTAL:.2f}", r["match"],
            ])

    altas_txt = " · ".join(
        f"{r['sku']} {r['nombre']}" for r in altas_ean.values()
    )
    ya_txt = " · ".join(sorted({f"{r['sku']}" for r in ROWS if r["ya"]}))

    OUT_MD.write_text(
        f"""# Equilibrio {FOLIO} — Recibir

Cliente **307513** Luis Ángel Palillero Ventura · pedido online · sucursal Iztapalapa 2 · 04-nov-2026.

## Qué correr

1. Pegar **todo** `sql/patch_equilibrio_450593_SOLO_pegar_esto.sql` en Supabase → SQL Editor → Run.
2. En Recibir debe aparecer el botón vivo **Equilibrio · {FOLIO}**.
3. Escanear cada caja → MMAA de la caja (no inventar `0000`) → confirmar.

## Totales

- {len(ROWS)} renglones / **{piezas} pzas** / **${TOTAL:,.2f}** (subtotal P.U. ${SUBTOTAL_PU:,.2f} + IVA ${IVA:.2f})
- Folio **{FOLIO}** del ticket térmico.
- **{len(altas_ean)} alta** stock 0: {altas_txt}
- Ya en catálogo: {ya_txt}

## Notas de mapeo

| Clave ticket | EAN | SKU | Nota |
|---|---|---|---|
| JAY142 | 7506022315281 | FC-66055303 | Meditest ya en catálogo · Jayor |
| COL100 | 0780083140731 | FC-83140731 | Vengesic Collins · alta · LGEN +60% |

## Regenerar

`python3 scripts/generar_carga_equilibrio_450593.py`
""",
        encoding="utf-8",
    )

    OUT_SOLO_MD.write_text(
        f"""# Equilibrio {FOLIO} — pegar en Supabase

## Pegar ahora

1. Raw: https://raw.githubusercontent.com/ibarraivane/farmacapital/main/sql/patch_equilibrio_450593_SOLO_pegar_esto.sql
2. Selecciona TODO → copiar → Supabase SQL Editor → **Run**
3. VERIFICACION: folio `{FOLIO}`, estado `borrador`, 8 piezas
4. Tablet: Recibir → recargar → tarjeta **Equilibrio · {FOLIO}**

MMAA de la caja. Si Run marca rojo, manda el texto.
""",
        encoding="utf-8",
    )

    print(report(ROWS, SUBTOTAL_PU))
    print(f"ticket_total=${TOTAL:.2f} (con IVA)")
    print(f"SQL  → {sql_path}")
    print(f"SOLO → {OUT_SOLO}")
    print(f"CSV  → {OUT_CSV}")
    print(f"MD   → {OUT_MD}")
    print(f"piezas={piezas} sub={sub} altas={len(altas_ean)}")
    for r in ROWS:
        print(
            f"  {r['ean']}  {r['qty']}×{r['pu']:.2f}→${r['precio']}  "
            f"{'ya' if r['ya'] else 'ALTA'}  {r['nombre']}  lote={r['lote']}"
        )


if __name__ == "__main__":
    main()
