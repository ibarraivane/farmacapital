#!/usr/bin/env python3
"""Ticket Equilibrio POS · folio 450233 (02-nov-2026) → catálogo + cola Recibir.

Cliente 307513 LUIS ANGEL PALILLERO VENTURA · sucursal Iztapalapa 2 · pedido online.
15 renglones / 42 pzas / Subtotal P.U. $1,059.92 + IVA $65.18 = Total $1,125.10.
Costo = P.U. neto del papel (antes de IVA). Lote de fábrica sí. Caducidad NO (MMAA caja).
Fichas BuscaMed / Costofarma / Quirmex / Levic — no el código truncado del ticket.
Hisopos QIR016: dos lotes → dos renglones (no consolidar).
SON098 del ticket = Fenimeth → SKU catálogo EQ-SON096 (EAN 7502001164697).
"""
from __future__ import annotations

import csv
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_carga_tickets_20260915 import (  # noqa: E402
    ceil_pvp,
    foto_url,
    write_carga_sql,
)
from generar_recepcion_borrador import report  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]
OUT_CSV = ROOT / "sql" / "generated" / "ticket_equilibrio_450233.csv"
OUT_MD = ROOT / "sql" / "LEERME_equilibrio_450233.md"

FOLIO = "450233"
PROVEEDOR = "Equilibrio"
FECHA = "2026-11-02"
SUBTOTAL_PU = 1059.92
TOTAL = 1125.10  # con IVA (ticket)
IVA = 65.18


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


# Fichas de mostrador (no el código del ticket).
ROWS = [
    row(
        ean="7502009749698",
        codigo="MAV414",
        snap="MAV414 BROMHE/OXELAD 1 JBE 60/120MG/100/120",
        nombre="Bromhexina/oxeladina",
        qty=2,
        pu=70.81,
        lote="265229",
        tipo="marca",
        subcategoria="Respiratorio",
        forma="Jarabe",
        marca="Maver",
        laboratorio="Maver",
        presentacion="Frasco 225 ml",
        principio="Bromhexina / oxeladina",
        concentracion="60 mg/100 ml / 120 mg/100 ml",
        receta=True,
        ya=False,
        sku="FC-09749698",
        foto_file="verxolin-bromhexina-oxeladina-maver-7502009749698.jpg",
    ),
    row(
        ean="7503003406402",
        codigo="QIR016",
        snap="QIR016 HISOPOS 1 ENVASE 100 PZAS",
        nombre="Cotonetes Quirmex",
        qty=7,
        pu=9.29,
        lote="H1402226",
        tipo="marca",
        categoria="Higiene",
        subcategoria="Curación",
        forma="Cotonetes",
        marca="Quirmex",
        laboratorio="Quirmex",
        presentacion="Envase 100 pzas",
        principio=None,
        concentracion=None,
        receta=False,
        ya=True,
        sku="FC-34064021",
    ),
    row(
        ean="7503003406402",
        codigo="QIR016",
        snap="QIR016 HISOPOS 1 ENVASE 100 PZAS",
        nombre="Cotonetes Quirmex",
        qty=3,
        pu=9.29,
        lote="H1402026",
        tipo="marca",
        categoria="Higiene",
        subcategoria="Curación",
        forma="Cotonetes",
        marca="Quirmex",
        laboratorio="Quirmex",
        presentacion="Envase 100 pzas",
        principio=None,
        concentracion=None,
        receta=False,
        ya=True,
        sku="FC-34064021",
    ),
    row(
        ean="7502223112445",
        codigo="QUM052",
        snap="QUM052 QUIMIKAN 1 SOL C/ APLI 10 ML 200MG/ 1 ML",
        nombre="Quimikan benzocaína 200 mg/mL",
        qty=3,
        pu=71.10,
        lote="26FS34",
        forma="Solución bucal",
        marca="Quimikan",
        laboratorio="Quimpharma",
        presentacion="Frasco 10 mL con aplicador",
        principio="Benzocaína",
        concentracion="200 mg/mL",
        receta=False,
        ya=True,
        sku="EQ-QUM052",
    ),
    row(
        ean="7503003406051",
        codigo="QIR023",
        snap="QIR023 GASA ESTERILIZADA 10 SOB 10CMX10CM",
        nombre="Gasa estéril Quirmex 10×10",
        qty=10,
        pu=9.89,
        lote="GS2922826",
        tipo="marca",
        categoria="Higiene",
        subcategoria="Curación",
        forma="Gasa",
        marca="Quirmex",
        laboratorio="Quirmex",
        presentacion="Caja con 10 sobres 10×10 cm",
        principio=None,
        concentracion=None,
        receta=False,
        ya=False,
        sku="FC-03406051",
        foto_file="quirmex-gasa-esteril-10x10-c10-7503003406051.jpg",
    ),
    row(
        ean="0780083144302",
        codigo="COL145",
        snap="COL145 COLLIFRIN ADULTO 1 SOL 50MG/20 ML",
        nombre="Collifrin Adulto oximetazolina 0.05%",
        qty=5,
        pu=33.73,
        lote="26140881",
        subcategoria="Respiratorio",
        forma="Solución nasal",
        marca="Collifrin",
        laboratorio="Collins",
        presentacion="Frasco 20 mL",
        principio="Oximetazolina",
        concentracion="0.05%",
        receta=False,
        ya=True,
        sku="FC-83144302",
    ),
    row(
        ean="7502009747052",
        codigo="MAV344",
        snap="MAV344 CORIVER 10 TAB 750 MG",
        nombre="Coriver paracetamol 750 mg",
        qty=2,
        pu=8.04,
        lote="263137",
        tipo="marca",
        categoria="Analgésico",
        forma="Tableta",
        marca="Coriver",
        laboratorio="Maver",
        presentacion="Caja con 10 tabletas",
        principio="Paracetamol",
        concentracion="750 mg",
        receta=False,
        ya=True,
        sku="FC-09747052",
    ),
    row(
        ean="7502001164697",
        codigo="SON098",
        snap="SON098 FENIMETH V 12 OVS 500MG/100,000 UI",
        nombre="Fenimeth V óvulos 500 mg / 100000 UI",
        qty=3,
        pu=37.59,
        lote="26071744",
        subcategoria="Ginecología",
        forma="Óvulo",
        marca="Fenimeth",
        laboratorio="Son's",
        presentacion="Caja con 12 óvulos",
        principio="Metronidazol / nistatina",
        concentracion="500 mg / 100000 UI",
        receta=True,
        ya=True,
        sku="EQ-SON096",
    ),
    row(
        ean="7503014377883",
        codigo="PBY019",
        snap="PBY019 MAX SENS UVA 1 CARTERA 3+1",
        nombre="Max Sens Uva",
        qty=1,
        pu=28.12,
        lote="MUV070626",
        tipo="marca",
        categoria="Salud sexual",
        forma="Preservativo",
        marca="Max Sens",
        laboratorio="Playboy",
        presentacion="Cartera 3+1",
        principio=None,
        concentracion=None,
        receta=False,
        ya=False,
        sku="FC-14377883",
        foto_file="max-sens-uva-3plus1-7503014377883.jpg",
    ),
    row(
        ean="7503014377890",
        codigo="PBY021",
        snap="PBY021 MAX SENS CHOCOMENTA 1 CARTERA 3+1",
        nombre="Max Sens Chocomenta",
        qty=1,
        pu=28.11,
        lote="MCH010226",
        tipo="marca",
        categoria="Salud sexual",
        forma="Preservativo",
        marca="Max Sens",
        laboratorio="Playboy",
        presentacion="Cartera 3+1",
        principio=None,
        concentracion=None,
        receta=False,
        ya=False,
        sku="FC-14377890",
        foto_file="max-sens-chocomenta-3plus1-7503014377890.jpg",
    ),
    row(
        ean="7503014377197",
        codigo="PBY007",
        snap="PBY007 MAX SENS TROPICANA MIX 1 BLISTER 3+1",
        nombre="Max Sens Tropicana Mix",
        qty=1,
        pu=28.13,
        lote="TRP110726",
        tipo="marca",
        categoria="Salud sexual",
        forma="Preservativo",
        marca="Max Sens",
        laboratorio="Playboy",
        presentacion="Blíster 3+1",
        principio=None,
        concentracion=None,
        receta=False,
        ya=True,
        sku="EQ-PBY007",
        foto_file="max-sens-tropicana-mix-3plus1-7503014377197.jpg",
    ),
    row(
        ean="75034498",
        codigo="PBY003",
        snap="PBY003 PLAYBOY TEXTURIZADO 1 BLISTER C/3 PZAS",
        nombre="Playboy Texturizado",
        qty=1,
        pu=37.53,
        lote="1330626",
        tipo="marca",
        categoria="Salud sexual",
        forma="Preservativo",
        marca="Playboy",
        laboratorio="Playboy",
        presentacion="Blíster con 3 pzas",
        principio=None,
        concentracion=None,
        receta=False,
        ya=False,
        sku="FC-75034498",
        foto_file="playboy-texturizado-c3-75034498.jpg",
    ),
    row(
        ean="75034481",
        codigo="PBY002",
        snap="PBY002 PLAYBOY EXTRA SENSIBLE 1 BLISTER 3 PZAS",
        nombre="Playboy Extra Sensible",
        qty=1,
        pu=37.51,
        lote="2050426",
        tipo="marca",
        categoria="Salud sexual",
        forma="Preservativo",
        marca="Playboy",
        laboratorio="Playboy",
        presentacion="Blíster con 3 pzas",
        principio=None,
        concentracion=None,
        receta=False,
        ya=False,
        sku="FC-75034481",
        foto_file="playboy-extra-sensible-c3-75034481.jpg",
    ),
    row(
        ean="7503014377876",
        codigo="PBY018",
        snap="PBY018 MAX SENS FRESA 1 BLISTER 3+1",
        nombre="Max Sens Fresa",
        qty=1,
        pu=28.15,
        lote="MFR090726",
        tipo="marca",
        categoria="Salud sexual",
        forma="Preservativo",
        marca="Max Sens",
        laboratorio="Playboy",
        presentacion="Blíster 3+1",
        principio=None,
        concentracion=None,
        receta=False,
        ya=False,
        sku="FC-14377876",
        foto_file="max-sens-fresa-3plus1-7503014377876.jpg",
    ),
    row(
        ean="7503014377180",
        codigo="PBY008",
        snap="PBY008 MAX SENS PASSION MIX 1 BLISTER 3+1",
        nombre="Max Sens Passion Mix",
        qty=1,
        pu=28.15,
        lote="PAS210626",
        tipo="marca",
        categoria="Salud sexual",
        forma="Preservativo",
        marca="Max Sens",
        laboratorio="Playboy",
        presentacion="Blíster 3+1",
        principio=None,
        concentracion=None,
        receta=False,
        ya=True,
        sku="EQ-PBY008",
        foto_file="max-sens-passion-mix-3plus1-7503014377180.jpg",
    ),
]


def main() -> None:
    piezas = sum(r["qty"] for r in ROWS)
    sub = round(sum(r["sub"] for r in ROWS), 2)
    assert piezas == 42, piezas
    assert abs(sub - SUBTOTAL_PU) < 0.02, (sub, SUBTOTAL_PU)
    for r in ROWS:
        assert abs(r["pu"] * r["qty"] - r["sub"]) < 0.03, r
        assert not r["nombre"].isupper(), r["nombre"]
        assert len(r["ean"]) >= 8, r["ean"]
        assert r["lote"], r
        if not r["ya"]:
            assert r["foto_file"], r["nombre"]

    altas = [r for r in ROWS if not r["ya"]]
    # altas únicas por EAN
    altas_ean = {r["ean"]: r for r in altas}
    ticket = {
        "key": "equilibrio_450233",
        "header": (
            f"Equilibrio · ticket {FOLIO} · {FECHA} · cliente 307513 Palillero · "
            f"pedido online Iztapalapa 2 · Total ${TOTAL:,.2f} "
            f"(subtotal P.U. ${SUBTOTAL_PU:,.2f} + IVA ${IVA:.2f}) · "
            f"{len(ROWS)} renglones / {piezas} pzas. "
            "Claves EQF → EAN ficha/BuscaMed/Costofarma. Lote de fábrica sí. "
            "Caducidad NO: MMAA de la caja. 0000 inválido."
        ),
        "tmp": "_fc_eq_450233",
        "folio": FOLIO,
        "proveedor": PROVEEDOR,
        "proveedor_ilike": "equilibrio",
        "fecha": FECHA,
        "total": TOTAL,
        "notas": (
            f"Ticket Equilibrio folio {FOLIO} · cliente 307513 Luis Angel · "
            f"02-nov-2026 · {piezas} pzas · ${TOTAL:,.2f} · lote de fábrica en renglón; "
            "MMAA de la caja · cola Recibir"
        ),
        "rows": ROWS,
    }

    sql_path = write_carga_sql(ticket)

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
    ya_txt = " · ".join(sorted({
        f"{r['sku']}" for r in ROWS if r["ya"]
    }))

    OUT_MD.write_text(
        f"""# Equilibrio {FOLIO} — Recibir

Cliente **307513** Luis Ángel Palillero Ventura · pedido online · sucursal Iztapalapa 2 · 02-nov-2026.

## Qué correr

1. Pegar **todo** `sql/patch_carga_equilibrio_450233.sql` en Supabase → SQL Editor → Run.
2. En Recibir debe aparecer el botón vivo **Equilibrio · {FOLIO}**.
3. Escanear cada caja → MMAA de la caja (no inventar `0000`) → confirmar.
4. Hisopos: hay **dos lotes** (H1402226 ×7 y H1402026 ×3). Escanea y confirma cada renglón.

## Totales

- {len(ROWS)} renglones / **{piezas} pzas** / **${TOTAL:,.2f}** (subtotal P.U. ${SUBTOTAL_PU:,.2f} + IVA ${IVA:.2f})
- Folio **{FOLIO}** del ticket térmico.
- **{len(altas_ean)} altas** stock 0: {altas_txt}
- Ya en catálogo: {ya_txt}

## Notas de mapeo

| Clave ticket | EAN | SKU | Nota |
|---|---|---|---|
| MAV414 | 7502009749698 | FC-09749698 | Bromhexina/oxeladina Maver frasco 225 ml |
| QIR016 | 7503003406402 | FC-34064021 | Dos lotes → dos renglones |
| QUM052 | 7502223112445 | EQ-QUM052 | Quimikan |
| QIR023 | 7503003406051 | FC-03406051 | Gasa Quirmex 10×10 C/10 |
| COL145 | 0780083144302 | FC-83144302 | Collifrin Adulto |
| MAV344 | 7502009747052 | FC-09747052 | Coriver 750 mg C/10 |
| SON098 | 7502001164697 | EQ-SON096 | Fenimeth (SKU catálogo, no EQ-SON098) |
| PBY019/021/018 | …7883/7890/7876 | FC-14377883/90/76 | Max Sens Uva / Chocomenta / Fresa |
| PBY007/008 | …7197/7180 | EQ-PBY007/008 | Tropicana / Passion ya en catálogo |
| PBY003/002 | 75034498 / 75034481 | FC-75034498/81 | Códigos Costofarma/FarmaMedical (8 dígitos) |

## Pendiente

- Al escanear Playboy Texturizado / Extra Sensible: si el beep no pega con 8 dígitos, mandar foto del código de barras de la caja.
- Collifrin Adulto: si falta packshot adulto en catálogo, no se pisó el infantil.

## Regenerar

`python3 scripts/generar_carga_equilibrio_450233.py`
""",
        encoding="utf-8",
    )

    print(report(ROWS, SUBTOTAL_PU))
    print(f"ticket_total=${TOTAL:.2f} (con IVA)")
    print(f"SQL → {sql_path}")
    print(f"CSV → {OUT_CSV}")
    print(f"MD  → {OUT_MD}")
    print(f"piezas={piezas} sub={sub} altas={len(altas_ean)}")
    for r in ROWS:
        print(
            f"  {r['ean']}  {r['qty']}×{r['pu']:.2f}  "
            f"{'ya' if r['ya'] else 'ALTA'}  {r['nombre']}  lote={r['lote']}"
        )


if __name__ == "__main__":
    main()
