#!/usr/bin/env python3
"""Tickets 06-oct-2026 (fotos) → cola Recibir.

3 pedidos:
  IFC F8 127425 · Grupo Zorro T01696085 · Equilibrio 447156

Nombres de mostrador desde ficha (no el código del ticket).
Sin caducidad inventada (MMAA de la caja). Equilibrio sí trae lote de fábrica.
"""
from __future__ import annotations

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_carga_tickets_20260915 import (  # noqa: E402
    ceil_pvp,
    foto_url,
    report,
    sku_de,
    sql_str,
    write_carga_sql,
)
from generar_recepcion_borrador import write_ticket_csv  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "sql"
GEN_DIR = ROOT / "sql" / "generated"


def p(
    ean: str,
    *,
    nombre: str,
    tipo: str = "generico",
    categoria: str = "Medicamentos",
    subcategoria: str | None = None,
    forma: str | None = None,
    marca: str | None = None,
    laboratorio: str | None = None,
    presentacion: str | None = None,
    principio: str | None = None,
    concentracion: str | None = None,
    receta: bool = False,
    ya: bool = False,
    sku: str | None = None,
    foto_file: str | None = None,
) -> dict:
    return {
        "sku": sku or sku_de(ean),
        "nombre": nombre,
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
    }


PRODUCTOS: dict[str, dict] = {
    # ── IFC ──
    "7506484500034": p(
        "7506484500034",
        sku="FC-84500034",
        nombre="Cintapore micropore piel",
        tipo="marca",
        categoria="Botiquín",
        subcategoria="Material de curación",
        forma="Cinta",
        marca="Cintapore",
        laboratorio="Codifarma",
        presentacion="Caja con 12 rollos 2.5 cm × 9.1 m",
        ya=False,
        foto_file="cintapore-piel-2.5x5.jpg",
    ),
    # ── Zorro ──
    "7502274881475": p(
        "7502274881475",
        sku="FC-274881475",
        nombre="Schick Xtreme 3",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Afeitado",
        forma="Rastrillo",
        marca="Schick",
        laboratorio="Edgewell",
        presentacion="Bolsa con 12 rastrillos",
        ya=False,
    ),
    # ── Equilibrio ──
    "7501537164638": p(
        "7501537164638",
        sku="EQ-BRU029",
        nombre="Butifeno ketotifeno solución",
        tipo="generico",
        forma="Solución",
        marca="Butifeno",
        laboratorio="Bruluart",
        presentacion="Frasco 120 mL",
        principio="Ketotifeno",
        concentracion="20 mg/5 mL",
        receta=False,
        ya=False,
    ),
    "7501573904403": p(
        "7501573904403",
        sku="EQ-BIO138",
        nombre="Lozamir-C clotrimazol crema 1%",
        tipo="generico",
        categoria="Dermocosmético",
        forma="Crema",
        marca="Lozamir-C",
        laboratorio="Biomep",
        presentacion="Tubo 30 g",
        principio="Clotrimazol",
        concentracion="1%",
        ya=True,
    ),
    "7502001166110": p(
        "7502001166110",
        sku="EQ-SON247",
        nombre="Femitab clindamicina/ketoconazol",
        tipo="generico",
        forma="Óvulo",
        marca="Femitab",
        laboratorio="Son's",
        presentacion="Caja con 7 óvulos",
        principio="Clindamicina / ketoconazol",
        concentracion="100/400 mg",
        receta=True,
        ya=False,
    ),
    "7501478316226": p(
        "7501478316226",
        sku="EQ-VIT061",
        nombre="Bocetix levocetirizina 5 mg",
        tipo="generico",
        forma="Tableta",
        marca="Bocetix",
        laboratorio="Vitae",
        presentacion="Caja con 10 tabletas",
        principio="Levocetirizina",
        concentracion="5 mg",
        ya=False,
    ),
    "7503004908714": p(
        "7503004908714",
        sku="EQ-ALP0520",
        nombre="Miconazol crema 2%",
        tipo="generico",
        categoria="Dermocosmético",
        forma="Crema",
        marca="Alpharma",
        laboratorio="Alpharma",
        presentacion="Tubo 20 g",
        principio="Miconazol",
        concentracion="2%",
        ya=True,
    ),
    "7501836006042": p(
        "7501836006042",
        sku="EQ-LIF160",
        nombre="Virindrez Adulto oximetazolina 0.050%",
        tipo="generico",
        forma="Atomizador",
        marca="Virindrez",
        laboratorio="Liferpal",
        presentacion="Frasco atomizador 20 mL",
        principio="Oximetazolina",
        concentracion="0.050%",
        ya=True,
    ),
    "7503001007120": p(
        "7503001007120",
        sku="FC-50587FA6",
        nombre="Mexapin amoxicilina suspensión 125 mg/5 mL",
        tipo="generico",
        forma="Suspensión",
        marca="Mexapin",
        laboratorio="Wandel",
        presentacion="Frasco 60 mL",
        principio="Amoxicilina",
        concentracion="125 mg/5 mL",
        receta=True,
        ya=True,
    ),
    "7501573902584": p(
        "7501573902584",
        sku="EQ-BIO067",
        nombre="Sarox omeprazol 20 mg",
        tipo="generico",
        forma="Cápsula",
        marca="Sarox",
        laboratorio="Biomep",
        presentacion="Caja con 14 cápsulas",
        principio="Omeprazol",
        concentracion="20 mg",
        ya=True,
    ),
    "7502009740213": p(
        "7502009740213",
        sku="FC-F48FF7EF",
        nombre="Clamoxin amoxicilina/clavulánico suspensión 250/62.5",
        tipo="generico",
        forma="Suspensión",
        marca="Clamoxin",
        laboratorio="Maver",
        presentacion="Frasco 60 mL",
        principio="Amoxicilina / ácido clavulánico",
        concentracion="250/62.5 mg/5 mL",
        receta=True,
        ya=True,
    ),
    "7501075727180": p(
        "7501075727180",
        sku="EQ-NOV175",
        nombre="Lia drospirenona/etinilestradiol",
        tipo="marca",
        forma="Comprimido",
        marca="Lia",
        laboratorio="Novag",
        presentacion="Caja con 28 comprimidos",
        principio="Drospirenona / etinilestradiol",
        concentracion="3/0.03 mg",
        receta=True,
        ya=False,
    ),
    "7502009744570": p(
        "7502009744570",
        sku="EQ-MAV201",
        nombre="Sinfonil oxcarbazepina 300 mg",
        tipo="generico",
        forma="Tableta",
        marca="Sinfonil",
        laboratorio="Maver",
        presentacion="Caja con 20 tabletas",
        principio="Oxcarbazepina",
        concentracion="300 mg",
        receta=True,
        ya=False,
    ),
    "7502213040871": p(
        "7502213040871",
        sku="EQ-HIS045",
        nombre="Cifhir bencidamina gel 5%",
        tipo="generico",
        categoria="Dermocosmético",
        forma="Gel",
        marca="Cifhir",
        laboratorio="Hispanoamericana",
        presentacion="Tubo 60 g",
        principio="Bencidamina",
        concentracion="5%",
        ya=True,
    ),
    "7502009744587": p(
        "7502009744587",
        sku="EQ-MAV202",
        nombre="Sinfonil oxcarbazepina 600 mg",
        tipo="generico",
        forma="Tableta",
        marca="Sinfonil",
        laboratorio="Maver",
        presentacion="Caja con 20 tabletas",
        principio="Oxcarbazepina",
        concentracion="600 mg",
        receta=True,
        ya=False,
    ),
    "7501075722604": p(
        "7501075722604",
        sku="EQ-NOV154",
        nombre="Belazix levocetirizina 5 mg",
        tipo="marca",
        forma="Tableta",
        marca="Belazix",
        laboratorio="Novag",
        presentacion="Caja con 20 tabletas",
        principio="Levocetirizina",
        concentracion="5 mg",
        ya=True,
    ),
    "7501573902928": p(
        "7501573902928",
        sku="EQ-BIO081",
        nombre="Ketoconazol crema 2%",
        tipo="generico",
        categoria="Dermocosmético",
        forma="Crema",
        marca="Biomep",
        laboratorio="Biomep",
        presentacion="Tubo 30 g",
        principio="Ketoconazol",
        concentracion="2%",
        ya=False,
    ),
    "7502227427408": p(
        "7502227427408",
        sku="EQ-GEP050",
        nombre="Esgaro levocetirizina 5 mg",
        tipo="generico",
        forma="Cápsula",
        marca="Esgaro",
        laboratorio="Gelpharma",
        presentacion="Caja con 10 cápsulas",
        principio="Levocetirizina",
        concentracion="5 mg",
        ya=False,
    ),
    "7502001165311": p(
        "7502001165311",
        sku="FC-830BF3FB",
        nombre="Diviltac 150/10 mg/mL",
        tipo="generico",
        forma="Frasco ámpula",
        marca="Diviltac",
        laboratorio="Son's",
        presentacion="Frasco ámpula 1 mL",
        principio=None,
        concentracion="150/10 mg/mL",
        receta=True,
        ya=True,
    ),
    "7501349014190": p(
        "7501349014190",
        sku="EQ-AMS147",
        nombre="Ácido alendrónico 10 mg",
        tipo="generico",
        forma="Tableta",
        marca="AMSA",
        laboratorio="AMSA",
        presentacion="Caja con 30 tabletas",
        principio="Ácido alendrónico",
        concentracion="10 mg",
        receta=True,
        ya=True,
    ),
    "7503001007113": p(
        "7503001007113",
        sku="FC-D5AC44CA",
        nombre="Amifarin dicloxacilina 500 mg",
        tipo="generico",
        forma="Cápsula",
        marca="Amifarin",
        laboratorio="Wandel",
        presentacion="Caja con 20 cápsulas",
        principio="Dicloxacilina",
        concentracion="500 mg",
        receta=True,
        ya=True,
    ),
    "7501349020153": p(
        "7501349020153",
        sku="EQ-AMS326",
        nombre="Levotiroxina sódica 100 mcg",
        tipo="generico",
        forma="Tableta",
        marca="AMSA",
        laboratorio="AMSA",
        presentacion="Caja con 100 tabletas",
        principio="Levotiroxina sódica",
        concentracion="100 mcg",
        receta=True,
        ya=False,
    ),
    "7502001165748": p(
        "7502001165748",
        sku="EQ-SON244",
        nombre="Exbenzol mebendazol 100 mg",
        tipo="generico",
        forma="Tableta",
        marca="Exbenzol",
        laboratorio="Son's",
        presentacion="Caja con 6 tabletas",
        principio="Mebendazol",
        concentracion="100 mg",
        ya=False,
    ),
}


def row(ean: str, snap: str, qty: int, pu: float, lote: str | None = None) -> dict:
    prod = PRODUCTOS[ean]
    sub = round(qty * pu, 2)
    return {
        "ean": ean,
        "sku": prod["sku"],
        "snap": snap,
        "nombre": prod["nombre"],
        "qty": qty,
        "pu": pu,
        "sub": sub,
        "lote": lote,
        **{
            k: prod[k]
            for k in (
                "tipo",
                "categoria",
                "subcategoria",
                "forma",
                "marca",
                "laboratorio",
                "presentacion",
                "principio",
                "concentracion",
                "receta",
                "ya",
                "foto",
                "foto_file",
            )
        },
        "precio": ceil_pvp(pu, prod["tipo"]),
        "match": "ya" if prod["ya"] else "alta",
    }


TICKETS = [
    {
        "key": "ifc_127425",
        "folio": "127425",
        "proveedor": "IFC",
        "proveedor_ilike": "ifc",
        "fecha": "2026-10-06",
        "total": 238.00,
        "notas": (
            "Ticket IFC F8 127425 · 06-oct-2026 17:08 · foto térmica · "
            "Cintapore micropore piel grande C/12 · cola Recibir; stock al confirmar pistola"
        ),
        "tmp": "_fc_ifc_127425",
        "header": (
            "IFC F8 · ticket 127425 · 2026-10-06 17:08 · cliente IVAN\n"
            "-- Mayoreo. 1 paquete · total $238.00.\n"
            "-- CINTAPORE MICROPORE PIEL GRANDE C/12 → EAN caja 7506484500034 "
            "(Codifarma 2.5 cm × 9.1 m × 12; código IFC 84129).\n"
            "-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000."
        ),
        "rows": [
            row(
                "7506484500034",
                "CINTAPORE MICROPORE PIEL GRANDE C/12 | 260402-4 84129",
                1,
                238.00,
            ),
        ],
    },
    {
        "key": "zorro_T01696085",
        "folio": "T01696085",
        "proveedor": "Grupo Zorro",
        "proveedor_ilike": "zorro",
        "fecha": "2026-10-06",
        "total": 161.67,
        "notas": (
            "Ticket Grupo Zorro ZE9 T01696085 · 06-oct-2026 17:20 · "
            "Schick Xtreme 3 bolsa 12 pzas · cola Recibir; stock al confirmar pistola"
        ),
        "tmp": "_fc_zorro_T01696085",
        "header": (
            "Grupo Zorro E-9 · ticket T01696085 · 2026-10-06 17:20:22\n"
            "-- Menudeo. 1 pza · total $161.67 (IVA incluido en ticket).\n"
            "-- RASTRILLOS SCHICK XTREME 3 12-12 PZ → EAN bolsa 7502274881475 "
            "(no confundir con pieza suelta 7591066701015).\n"
            "-- Sin lote ni caducidad. No inventar 0000."
        ),
        "rows": [
            row(
                "7502274881475",
                "RASTRILLOS SCHICK XTREME 3 12-12 PZ",
                1,
                161.67,
            ),
        ],
    },
    {
        "key": "equilibrio_447156",
        "folio": "447156",
        "proveedor": "Equilibrio",
        "proveedor_ilike": "equilibrio",
        "fecha": "2026-10-06",
        "total": 2643.87,
        "notas": (
            "Ticket Equilibrio 447156 · 06-oct-2026 · pedido online Iztapalapa 2 · "
            "75 pzas · $2,643.87 · cola Recibir; stock al confirmar pistola"
        ),
        "tmp": "_fc_eq_447156",
        "header": (
            "Equilibrio · ticket 447156 · 2026-10-06 · sucursal Iztapalapa 2\n"
            "-- Pedido online. Total $2,643.87 · 21 renglones / 75 pzas.\n"
            "-- Claves EQF → EAN ficha/Levic/mayoreo. Lote de fábrica sí.\n"
            "-- Caducidad NO: MMAA de la caja. 0000 inválido."
        ),
        "rows": [
            row("7501537164638", "BRU029 BUTIFENO 1 SOL 20MG/5/120 ML", 2, 19.80, "2511999"),
            row("7501573904403", "BIO138 LOZAMIR-C 1 CMA 1/30 G", 3, 14.31, "CE2604"),
            row("7502001166110", "SON247 FEMITAB 7 OVS 100/400 MG", 2, 63.63, "25123575"),
            row("7501478316226", "VIT061 BOCETIX 10 TAB 5 MG", 5, 43.63, "T2607355"),
            row("7503004908714", "ALP0520 MICONAZOL 1 CMA DE 20 G", 5, 10.67, "2601222"),
            row("7501836006042", "LIF160 VIRINDREZ ADULTO 1 ATOM 50 MG/20 ML", 5, 23.37, "26F031"),
            row("7503001007120", "WAN006 MEXAPIN 1 SUSP 125MG/5/60 ML", 6, 13.32, "56113"),
            row("7501573902584", "BIO067 SAROX 14 CAPS 20 MG", 5, 8.18, "5F2637"),
            row("7502009740213", "MAV012 CLAMOXIN 1 SUSP 250/62.5MG/5/60 ML", 3, 35.05, "260031"),
            row("7501075727180", "NOV175 LIA 28 COMP 3/.03 MG", 1, 156.43, "16737"),
            row("7502009744570", "MAV201 SINFONIL 20 TAB 300 MG", 2, 75.97, "262434"),
            row("7502213040871", "HIS045 CIFHIR 1 GEL 60G/5 %", 1, 44.77, "5M326"),
            row("7502009744587", "MAV202 SINFONIL 20 TAB 600 MG", 2, 138.11, "262430"),
            row("7501075722604", "NOV154 BELAZIX C/20 TAB 5MG", 4, 63.67, "880086"),
            row("7501573902928", "BIO081 KETOCONAZOL 1 CMA 2%/30 G", 5, 15.68, "CG2610"),
            row("7502227427408", "GEP050 ESGARO 10 CAPS 5 MG", 5, 53.48, "260910"),
            row("7502001165311", "SON189 DIVILTAC 1 FA 150/10MG/1 ML", 2, 37.48, "H26040037"),
            row("7501349014190", "AMS147 ACIDO ALENDRONICO 30 TAB 10 MG", 8, 25.65, "U26A275"),
            row("7503001007113", "WAN024 AMIFARIN 20 CAPS 500 MG", 5, 44.31, "C6227"),
            row("7501349020153", "AMS326 LEVOTIROXINA SODICA 100 TAB 100 MCG", 1, 43.21, "U25G450"),
            row("7502001165748", "SON244 EXBENZOL 6 TAB 100 MG", 3, 15.00, "26040942"),
        ],
    },
]


def main() -> None:
    GEN_DIR.mkdir(parents=True, exist_ok=True)
    paths: list[Path] = []
    for t in TICKETS:
        suma = round(sum(r["sub"] for r in t["rows"]), 2)
        pzas = sum(r["qty"] for r in t["rows"])
        if abs(suma - t["total"]) > 0.02:
            raise SystemExit(
                f"{t['folio']}: suma renglones {suma} ≠ total ticket {t['total']}"
            )
        csv_path = GEN_DIR / f"ticket_{t['key']}.csv"
        write_ticket_csv(
            csv_path,
            folio=t["folio"],
            fecha=t["fecha"],
            proveedor=t["proveedor"],
            total=t["total"],
            rows=[
                {
                    "ean": r["ean"],
                    "nombre": r["snap"],
                    "qty": r["qty"],
                    "pu": r["pu"],
                    "sub": r["sub"],
                    "sku": r["sku"],
                    "match": r["match"],
                }
                for r in t["rows"]
            ],
        )
        sql_path = write_carga_sql(t)
        paths.append(sql_path)
        print(f"{t['folio']}: {report(t['rows'], t['total'])}")
        print(f"  → {csv_path.relative_to(ROOT)}")
        print(f"  → {sql_path.name} · {pzas} pzas · ${t['total']:.2f}")

    todos = OUT_DIR / "patch_carga_tickets_20261006_TODOS.sql"
    parts = [
        "-- ═══════════════════════════════════════════════════════════════",
        "-- TICKETS 06-OCT-2026 · PEGAR EN SUPABASE (uno por uno o todo)",
        "-- Ver LEERME_tickets_20261006.md",
        "-- ═══════════════════════════════════════════════════════════════",
        "",
    ]
    for path in paths:
        parts.append(f"\n-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        parts.append(f"-- INICIO: {path.name}")
        parts.append(f"-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        parts.append(path.read_text(encoding="utf-8").rstrip() + "\n")
    todos.write_text("\n".join(parts), encoding="utf-8")

    leerme = OUT_DIR / "LEERME_tickets_20261006.md"
    leerme.write_text(
        """# Tickets Recibir · 06-oct-2026

Fotos IFC + Zorro + Equilibrio. Pegar **cada** SQL en Supabase → SQL Editor → Run.

| Pedido | Archivo | Piezas | Total |
|--------|---------|--------|-------|
| IFC 127425 | `patch_carga_ifc_127425.sql` | 1 | $238.00 |
| Grupo Zorro T01696085 | `patch_carga_zorro_T01696085.sql` | 1 | $161.67 |
| Equilibrio 447156 | `patch_carga_equilibrio_447156.sql` | 75 | $2,643.87 |

## Todo-en-uno

`patch_carga_tickets_20261006_TODOS.sql`

## Notas

- Equilibrio trae **lote de fábrica**; caducidad = MMAA de la caja al escanear.
- Schick bolsa 12 pzas EAN `7502274881475` (no la pieza suelta `7591066701015`).
- Cintapore caja C/12 EAN `7506484500034` (código IFC 84129).
- Regenerar: `python3 scripts/generar_carga_tickets_20261006.py`
""",
        encoding="utf-8",
    )
    print(f"\nTODOS → {todos.name} ({todos.stat().st_size} bytes)")
    print(f"LEERME → {leerme.name}")


if __name__ == "__main__":
    main()
