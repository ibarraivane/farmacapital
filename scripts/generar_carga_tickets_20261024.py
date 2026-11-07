#!/usr/bin/env python3
"""Tickets 24-oct-2026 (fotos) → altas + cola Recibir.

2 pedidos:
  Farmalive 15586 · Club Iztapalapa 1 · $2,078.48
  Farma Mayoreo 241026 · folio provisional (foto sin encabezado) · $737.34

Nombres de mostrador desde ficha (no el código del ticket).
Sin caducidad inventada (MMAA de la caja). Materfol sí trae lote de fábrica.
Farmalive: costo = P.U. neto después del descuento del renglón (2%).
Farma Mayoreo: P.U. ya trae IVA (suma renglones = TOTAL).
"""
from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_carga_tickets_20260915 import (  # noqa: E402
    ceil_pvp,
    foto_url,
    report,
    sku_de,
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
    tipo: str = "marca",
    categoria: str = "Cuidado personal",
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
    # ── Farmalive 15586 ──
    "7501058626479": p(
        "7501058626479",
        nombre="NAN 2 Optimal Pro",
        tipo="marca",
        categoria="Bebés",
        subcategoria="Fórmula infantil",
        forma="Polvo",
        marca="NAN",
        laboratorio="Nestlé",
        presentacion="Paquete 2 × 1.2 kg",
        ya=False,
    ),
    "7506425648634": p(
        "7506425648634",
        nombre="Pañal Suavelastic Recién Nacido Etapa 1",
        tipo="marca",
        categoria="Bebés",
        subcategoria="Pañales",
        marca="Suavelastic",
        laboratorio="Kimberly-Clark",
        presentacion="Bolsa con 20 pañales",
        ya=False,
    ),
    "7506425608867": p(
        "7506425608867",
        nombre="Toallas húmedas Huggies Pure & Natural",
        tipo="marca",
        categoria="Bebés",
        subcategoria="Toallitas",
        marca="Huggies",
        laboratorio="Kimberly-Clark",
        presentacion="2-pack con 80 toallitas",
        ya=False,
    ),
    "7501125174797": p(
        "7501125174797",
        sku="FC-51747971",
        nombre="Electrolit Mora Azul",
        tipo="marca",
        categoria="Bebidas",
        subcategoria="Electrolitos",
        forma="Bebida",
        marca="Electrolit",
        laboratorio="Pisa",
        presentacion="Botella 625 mL",
        ya=True,
    ),
    "75001865": p(
        "75001865",
        sku="FC-75001865",
        nombre="Brillantina Palmolive",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Cabello",
        forma="Brillantina",
        marca="Palmolive",
        laboratorio="Colgate-Palmolive",
        presentacion="Envase 115 mL",
        ya=True,
    ),
    "7500435127363": p(
        "7500435127363",
        nombre="Oral-B Kids Mickey",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Higiene bucal",
        forma="Crema dental",
        marca="Oral-B",
        laboratorio="P&G",
        presentacion="Tubo 37 mL",
        ya=False,
    ),
    "7500435137737": p(
        "7500435137737",
        nombre="Oral-B Kids Princess",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Higiene bucal",
        forma="Crema dental",
        marca="Oral-B",
        laboratorio="P&G",
        presentacion="Tubo 37 mL",
        ya=False,
    ),
    "7500435145152": p(
        "7500435145152",
        nombre="Oral-B Kids Spiderman",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Higiene bucal",
        forma="Crema dental",
        marca="Oral-B",
        laboratorio="P&G",
        presentacion="Tubo 37 mL",
        ya=False,
    ),
    # ── Farma Mayoreo 241026 ──
    "7506425607808": p(
        "7506425607808",
        nombre="Toallas húmedas Huggies Supreme",
        tipo="marca",
        categoria="Bebés",
        subcategoria="Toallitas",
        marca="Huggies",
        laboratorio="Kimberly-Clark",
        presentacion="Paquete con 80 toallitas",
        ya=False,
    ),
    "7502304290383": p(
        "7502304290383",
        nombre="GUM gel dental Stranger Things",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Higiene bucal",
        forma="Gel dental",
        marca="GUM",
        laboratorio="Sunstar",
        presentacion="Tubo 75 mL",
        ya=False,
    ),
    "7506425648030": p(
        "7506425648030",
        nombre="Pañal KleenBebé Absorsec Ultra Etapa 3 Mediano",
        tipo="marca",
        categoria="Bebés",
        subcategoria="Pañales",
        marca="KleenBebé",
        laboratorio="Kimberly-Clark",
        presentacion="Bolsa con 16 pañales",
        ya=False,
    ),
    "7506339394733": p(
        "7506339394733",
        sku="FC-39394733",
        nombre="Fixodent Plus adhesivo dental",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Higiene bucal",
        forma="Adhesivo",
        marca="Fixodent",
        laboratorio="P&G",
        presentacion="Tubo 35 mL",
        ya=True,
        foto_file="fixodent-plus-35g.jpg",
    ),
    "7501943441408": p(
        "7501943441408",
        nombre="Pañal KleenBebé Absorsec Ultra Etapa 5 Jumbo",
        tipo="marca",
        categoria="Bebés",
        subcategoria="Pañales",
        marca="KleenBebé",
        laboratorio="Kimberly-Clark",
        presentacion="Bolsa con 14 pañales",
        ya=False,
    ),
    "7898185415114": p(
        "7898185415114",
        nombre="GUM kit viaje Bob Esponja",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Higiene bucal",
        forma="Kit",
        marca="GUM",
        laboratorio="Sunstar",
        presentacion="Cepillo + gel dental",
        ya=False,
    ),
    "070942004428": p(
        "070942004428",
        sku="FC-42004428",
        nombre="Cepillo dental GUM Barbie",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Higiene bucal",
        forma="Cepillo",
        marca="GUM",
        laboratorio="Sunstar",
        presentacion="1 cepillo",
        ya=False,
    ),
    "759684152047": p(
        "759684152047",
        nombre="Jaloma chupón cartera balón",
        tipo="marca",
        categoria="Bebés",
        subcategoria="Accesorios",
        marca="Jaloma",
        laboratorio="Jaloma",
        presentacion="Caja con 12 piezas",
        ya=False,
    ),
    "7501017375189": p(
        "7501017375189",
        nombre="Pañal KleenBebé Absorsec Ultra Etapa 4 Grande",
        tipo="marca",
        categoria="Bebés",
        subcategoria="Pañales",
        marca="KleenBebé",
        laboratorio="Kimberly-Clark",
        presentacion="Bolsa con 14 pañales",
        ya=False,
    ),
    "7501943471900": p(
        "7501943471900",
        sku="FC-43471900",
        nombre="Toallas húmedas KleenBebé Absorsec",
        tipo="marca",
        categoria="Bebés",
        subcategoria="Toallitas",
        marca="KleenBebé",
        laboratorio="Kimberly-Clark",
        presentacion="Paquete con 120 toallitas",
        ya=True,
    ),
    "7501590222214": p(
        "7501590222214",
        sku="EQ-CMD015",
        nombre="Materfol ácido fólico 400 mcg",
        tipo="generico",
        categoria="Medicamentos",
        subcategoria="Vitaminas",
        forma="Tableta",
        marca="Materfol",
        laboratorio="CMD",
        presentacion="Frasco con 90 tabletas",
        principio="Ácido fólico",
        concentracion="400 mcg",
        ya=True,
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
        "key": "farmalive_15586",
        "folio": "15586",
        "proveedor": "Farmalive",
        "proveedor_ilike": "farmalive",
        "fecha": "2026-10-24",
        "total": 2078.48,
        "notas": (
            "Ticket Farmalive 15586 · Club Iztapalapa 1 · 24-oct-2026 13:14 · "
            "cliente FARMACAPITAL · descuento 2% por renglón · "
            "cola Recibir; stock al confirmar pistola + MMAA"
        ),
        "tmp": "_fc_fl_15586",
        "header": (
            "Farmalive · ticket 15586 · 2026-10-24 13:14 · Club Iztapalapa 1\n"
            "-- 8 renglones / 13 unidades. Subtotal $2,120.90 − desc. $42.42 → neto $2,078.48.\n"
            "-- Costo = P.U. neto del renglón (2%). Sin lote ni MMAA.\n"
            "-- Brillantina Palmolive: ticket trunca a 8 dígitos 75001865 (EAN-8 de catálogo).\n"
            "-- Oral-B Kids Mickey: papel Importe $50.37 vs 2×$25.19=$50.38 (1¢)."
        ),
        "rows": [
            row(
                "7501058626479",
                "LECHE NAN 2 OPTIMAL PRO 1.2 KG 2PACK | MARCAS NESTLE",
                2,
                847.70,
            ),
            row(
                "7506425648634",
                "PAÑAL SUAVELASTIC REC NACIDO E1 C/20 | KIMBERLY CLARK",
                1,
                47.73,
            ),
            row(
                "7506425608867",
                "TOA HUM HUGGIES PURE NAT 2PACK C/80 | KIMBERLY CLARK",
                1,
                77.03,
            ),
            row(
                "7501125174797",
                "ELECTROLIT MORA AZUL 625 ML | LAB PISA",
                3,
                19.60,
            ),
            row(
                "75001865",
                "BRILLANTINA PALMOLIVE LIQ 115 ML | COLGATE PALMOLIVE",
                2,
                49.39,
            ),
            row(
                "7500435127363",
                "CREMA DENT ORAL-B KIDS MICKEY 37 ML | PG PERF",
                2,
                25.19,
            ),
            row(
                "7500435137737",
                "CREMA DENT ORAL-B KIDS PRINCESS 37 ML | PG PERF",
                1,
                25.19,
            ),
            row(
                "7500435145152",
                "CRE DENT ORAL-B KIDS SPIDERMAN 37 ML | PG PERF",
                1,
                25.19,
            ),
        ],
    },
    {
        "key": "farmamayoreo_241026",
        "folio": "241026",
        "proveedor": "Farma Mayoreo",
        "proveedor_ilike": "farma mayoreo",
        "fecha": "2026-10-24",
        "total": 737.34,
        "notas": (
            "Ticket Farma Mayoreo folio provisional 241026 (foto sin encabezado; "
            "fecha ddmmyy) · 24-oct-2026 · tarjeta BBVA $737.34 · "
            "cola Recibir; stock al confirmar pistola + MMAA · "
            "Materfol lote fábrica 2610990"
        ),
        "tmp": "_fc_fm_241026",
        "header": (
            "Farma Mayoreo · folio provisional 241026 · 2026-10-24\n"
            "-- Foto térmica sin encabezado (sin ID VENTA). Folio = ddmmyy.\n"
            "-- Cajero Alfredo Luciano Salazar · caja 3 · tarjeta BBVA (mismo POS que 303033).\n"
            "-- 11 renglones / 16 pzas. SUBTOTAL $638.81 + IVA $98.53 = TOTAL $737.34.\n"
            "-- P.U. ya trae IVA (suma renglones = TOTAL).\n"
            "-- GUM Barbie: ticket 70942004428 → EAN canónico 070942004428.\n"
            "-- Materfol: lote 2610990 del papel; caducidad NO (MMAA de la caja).\n"
            "-- Fixodent Plus ya en catálogo con foto."
        ),
        "rows": [
            row(
                "7506425607808",
                "TOALLAS HUMEDAS HUGGIES SUPREME 80 PIEZAS",
                2,
                38.50,
            ),
            row(
                "7502304290383",
                "GEL DENT GUM STRANGER THINGS 75 ML",
                1,
                40.02,
            ),
            row(
                "7506425648030",
                "PAÑAL KLEEN BEBE ABSORSEC ULTRA ET-3 T-M 16 PIEZAS",
                1,
                50.98,
            ),
            row(
                "7506339394733",
                "ADHESIVO FIXODENT PLUS CON TUBO 35ML",
                2,
                91.97,
            ),
            row(
                "7501943441408",
                "PAÑAL KLEEN BEBE ABSORSEC ULTRA ET-5 T-J 14 PIEZAS",
                1,
                62.98,
            ),
            row(
                "7898185415114",
                "KIT VIAJE GUM CEP DENTAL+GEL BOB ESPONJA",
                1,
                64.85,
            ),
            row(
                "070942004428",
                "CEPILLO DENTAL GUM BARBIE",
                2,
                28.29,
            ),
            row(
                "759684152047",
                "JALOMA CHUPON CARTERA BALON C/12 PZ",
                2,
                33.77,
            ),
            row(
                "7501017375189",
                "PAÑAL KLEEN BEBE ABSORSEC ULTRA ET-4 T-G 14 PIEZAS",
                1,
                64.97,
            ),
            row(
                "7501943471900",
                "TOALLAS HUMEDAS KLEEN BEBE ABSORSEC 120 PIEZAS",
                2,
                22.75,
            ),
            row(
                "7501590222214",
                "MATERFOL ACIDO FOLICO 400 MCG FRASCO CON 90 TABLETAS",
                1,
                22.98,
                "2610990",
            ),
        ],
    },
]


def main() -> None:
    GEN_DIR.mkdir(parents=True, exist_ok=True)
    paths: list[Path] = []
    for t in TICKETS:
        for r in t["rows"]:
            r["sub"] = round(r["qty"] * r["pu"], 2)
            r["precio"] = ceil_pvp(r["pu"], r["tipo"])

        suma = round(sum(r["sub"] for r in t["rows"]), 2)
        pzas = sum(r["qty"] for r in t["rows"])
        # Farmalive Mickey: 2×25.19 = 50.38 vs papel 50.37 → +$0.02 vs total papel
        if abs(suma - t["total"]) > 0.05:
            raise SystemExit(
                f"{t['folio']}: suma renglones {suma} ≠ total ticket {t['total']}"
            )
        if abs(suma - t["total"]) > 0.001:
            print(f"  nota {t['folio']}: suma SQL ${suma:.2f} vs papel ${t['total']:.2f}")
            if t["key"].startswith("farmalive"):
                t["total"] = suma

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

    todos = OUT_DIR / "patch_carga_tickets_20261024_TODOS.sql"
    parts = [
        "-- ═══════════════════════════════════════════════════════════════",
        "-- TICKETS 24-OCT-2026 · PEGAR EN SUPABASE (uno por uno o todo)",
        "-- Ver LEERME_tickets_20261024.md",
        "-- ═══════════════════════════════════════════════════════════════",
        "",
    ]
    for path in paths:
        parts.append(f"\n-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        parts.append(f"-- INICIO: {path.name}")
        parts.append(f"-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        parts.append(path.read_text(encoding="utf-8").rstrip() + "\n")
    todos.write_text("\n".join(parts), encoding="utf-8")

    fl_pzas = sum(r["qty"] for r in TICKETS[0]["rows"])
    fm_pzas = sum(r["qty"] for r in TICKETS[1]["rows"])
    fl_total = TICKETS[0]["total"]
    fm_total = TICKETS[1]["total"]

    leerme = OUT_DIR / "LEERME_tickets_20261024.md"
    leerme.write_text(
        f"""# Tickets Recibir · 24-oct-2026

Fotos Farmalive + Farma Mayoreo. Pegar **cada** SQL en Supabase → SQL Editor → Run.

| Pedido | Archivo | Piezas | Total |
|--------|---------|--------|-------|
| Farmalive 15586 | `patch_carga_farmalive_15586.sql` | {fl_pzas} | ${fl_total:,.2f} |
| Farma Mayoreo 241026 | `patch_carga_farmamayoreo_241026.sql` | {fm_pzas} | ${fm_total:,.2f} |

## Todo-en-uno

`patch_carga_tickets_20261024_TODOS.sql`

## Notas

1. **Farma Mayoreo folio 241026:** la foto no trae el encabezado con el ID VENTA. Usé fecha `ddmmyy`. Cajero Alfredo Luciano Salazar · caja 3 (mismo POS que ticket 303033). Si el papel dice otro folio, avisar y lo renombramos.
2. **Farmalive:** costo = P.U. neto (2%). Brillantina EAN-8 `75001865` (ticket truncado igual). Suma SQL $2,078.50 (papel $2,078.48; 1¢ en Mickey).
3. **Farma Mayoreo:** P.U. con IVA; suma renglones = TOTAL. GUM Barbie ticket `70942004428` → canónico `070942004428`.
4. **Materfol:** lote de fábrica `2610990` del papel; caducidad = MMAA de la caja (no usar 29/06/2028 del ticket como FEFO sin escanear).
5. **Stock:** 0 hasta pistola + MMAA. No poner `0000`.
6. **Fotos pendientes (altas nuevas):** NAN 2-pack, Suavelastic E1, Huggies Pure/Supreme, Oral-B Kids ×3, Absorsec Ultra E3/E4/E5, GUM Stranger/Barbie/Bob, Jaloma chupón. Fixodent ya tiene packshot.
7. Regenerar: `python3 scripts/generar_carga_tickets_20261024.py`

## Después del SQL

1. Recargar Recibir en la tablet.
2. Debe haber **2 botones** de tickets vivos (no se pisan con los anteriores).
3. Escanear → MMAA → Guardar renglón.
""",
        encoding="utf-8",
    )
    print(f"\nTODOS → {todos.name} ({todos.stat().st_size} bytes)")
    print(f"LEERME → {leerme.name}")


if __name__ == "__main__":
    main()
