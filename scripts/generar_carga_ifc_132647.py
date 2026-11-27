#!/usr/bin/env python3
"""IFC F8 Tienda · folio 132647 (07-nov-2026) → cola Recibir.

Ticket térmico IFC F8 · CJ 01 Fol 132647 · 07/11/2026 14:27 · Cliente LUIS.
MENUDEO · 2 productos / 11 pzas · Total $215.50.
P.PUBLICO = costo. Sin lote ni MMAA (caja).
EANs canónicos (no el código IFC 84529 / 84129 del papel).
"""
from __future__ import annotations

import csv
import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_carga_tickets_20260915 import write_carga_sql  # noqa: E402
from generar_recepcion_borrador import report  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]
OUT_CSV = ROOT / "sql" / "generated" / "ticket_ifc_132647.csv"
OUT_MD = ROOT / "sql" / "LEERME_ifc_132647.md"
OUT_SOLO = ROOT / "sql" / "patch_ifc_132647_SOLO_pegar_esto.sql"
OUT_SOLO_MD = ROOT / "sql" / "LEERME_ifc_132647_SOLO_pegar_esto.md"

FOLIO = "132647"
PROVEEDOR = "IFC F8 Tienda"
FECHA = "2026-11-07"
TOTAL = 215.50


def ceil_pvp(costo: float, tipo: str = "marca") -> int:
    factor = 1.25 if tipo == "marca" else 1.6
    return int(math.ceil(costo * factor))


ROWS = [
    {
        "ean": "3311000001292",
        "sku": "FC-00001292",
        "nombre": "Aceite de ricino Mercurio",
        "snap": "MERCURIO ACEITE RICINO C/25 1120627 84529",
        "qty": 8,
        "pu": 9.50,
        "sub": 76.00,
        "precio": ceil_pvp(9.50),
        "tipo": "marca",
        "categoria": "Cuidado personal",
        "subcategoria": None,
        "forma": "Aceite",
        "marca": "Mercurio",
        "laboratorio": "Mercurio",
        "presentacion": "Frasco (pieza de C/25)",
        "principio": "Aceite de ricino",
        "concentracion": None,
        "receta": False,
        "ya": True,
        "foto": None,
        "foto_file": None,
        "lote": None,
        "match": "ya",
    },
    {
        "ean": "7501048640829",
        "sku": "FC-46640629",
        "nombre": "Venda de yeso Protec 20 cm",
        "snap": "PROTEC VENDA YESO 20CM C/12 14036300025 84129",
        "qty": 3,
        "pu": 46.50,
        "sub": 139.50,
        "precio": ceil_pvp(46.50),
        "tipo": "marca",
        "categoria": "Botiquín",
        "subcategoria": "Material de curación",
        "forma": "Venda",
        "marca": "Protec",
        "laboratorio": "Degasa",
        "presentacion": "1 pieza 20 cm × 2.75 m (caja C/12)",
        "principio": None,
        "concentracion": None,
        "receta": False,
        "ya": True,
        "foto": None,
        "foto_file": None,
        "lote": None,
        "match": "ya",
    },
]


def strip_producto_imagenes(body: str) -> str:
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
-- IFC F8 Tienda folio {FOLIO} · 07-nov-2026 · ${TOTAL:,.2f} · 2 renglones / 11 pzas
-- Merge a GitHub NO crea la tarjeta. Este Run sí.
-- Sin bloques dollar-quote. Sin galería extra. Idempotente en borrador.
-- Al final: VERIFICACION con folio {FOLIO} en borrador.
-- Luego: tablet Recibir → recargar → tarjeta IFC F8 · {FOLIO}.
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
  and coalesce(r.proveedor, '') ilike '%ifc%'
group by r.id, r.proveedor, r.folio, r.estado, r.total_ticket;
"""
    OUT_SOLO.write_text(header + body + verificacion, encoding="utf-8")


def main() -> None:
    piezas = sum(r["qty"] for r in ROWS)
    sub = round(sum(r["sub"] for r in ROWS), 2)
    assert piezas == 11, piezas
    assert abs(sub - TOTAL) < 0.02, (sub, TOTAL)
    for r in ROWS:
        assert abs(r["pu"] * r["qty"] - r["sub"]) < 0.03, r
        assert not r["nombre"].isupper(), r["nombre"]
        assert len(r["ean"]) >= 8, r["ean"]

    ticket = {
        "key": "ifc_132647",
        "header": (
            f"IFC F8 Tienda · ticket {FOLIO} · {FECHA} 14:27 · cliente LUIS · "
            f"MENUDEO · Total ${TOTAL:,.2f} · {len(ROWS)} renglones / {piezas} pzas. "
            "P.PUBLICO = costo. EANs canónicos (no código IFC del papel). "
            "Sin lote. Caducidad NO: MMAA de la caja."
        ),
        "tmp": "_fc_ifc_132647",
        "folio": FOLIO,
        "proveedor": PROVEEDOR,
        "proveedor_ilike": "ifc",
        "fecha": FECHA,
        "total": TOTAL,
        "notas": (
            f"Ticket IFC F8 folio {FOLIO} · CJ 01 · cliente LUIS · "
            f"07-nov-2026 14:27 · {piezas} pzas · ${TOTAL:,.2f} · "
            "MENUDEO · MMAA de la caja · cola Recibir"
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
                f"{r['pu']:.2f}", f"{r['sub']:.2f}", "",
                r["sku"], f"{TOTAL:.2f}", r["match"],
            ])

    OUT_MD.write_text(
        f"""# IFC F8 {FOLIO} — Recibir

Cliente **LUIS** · MENUDEO · CJ 01 · 07-nov-2026 14:27.

## Qué correr

1. Pegar **todo** `sql/patch_ifc_132647_SOLO_pegar_esto.sql` en Supabase → SQL Editor → Run.
2. En Recibir debe aparecer el botón vivo **IFC F8 Tienda · {FOLIO}**.
3. Escanear cada pieza → MMAA de la caja (no inventar `0000`) → confirmar.

## Totales

- {len(ROWS)} renglones / **{piezas} pzas** / **${TOTAL:,.2f}**
- Folio **{FOLIO}** del ticket térmico.
- Ambos ya en catálogo (solo actualiza costo).

## Notas de mapeo

| Ticket | EAN | SKU | Nota |
|---|---|---|---|
| MERCURIO ACEITE RICINO … 84529 | 3311000001292 | FC-00001292 | ya · $9.50 |
| PROTEC VENDA YESO 20CM … 84129 | 7501048640829 | FC-46640629 | ya · pieza 20 cm × 2.75 m |

## Regenerar

`python3 scripts/generar_carga_ifc_132647.py`
""",
        encoding="utf-8",
    )

    OUT_SOLO_MD.write_text(
        f"""# IFC F8 {FOLIO} — pegar en Supabase

## Pegar ahora

1. Selecciona TODO el SQL SOLO → copiar → Supabase SQL Editor → **Run**
2. VERIFICACION: folio `{FOLIO}`, estado `borrador`, 11 piezas
3. Tablet: Recibir → recargar → tarjeta **IFC F8 · {FOLIO}**

MMAA de la caja. Si Run marca rojo, manda el texto.
""",
        encoding="utf-8",
    )

    print(report(ROWS, TOTAL))
    print(f"SQL  → {sql_path}")
    print(f"SOLO → {OUT_SOLO}")
    print(f"CSV  → {OUT_CSV}")
    print(f"piezas={piezas} sub={sub}")
    for r in ROWS:
        print(f"  {r['ean']}  {r['qty']}×{r['pu']:.2f}  ya  {r['nombre']}")


if __name__ == "__main__":
    main()
