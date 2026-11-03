#!/usr/bin/env python3
"""Tickets 06-oct-2026 (fotos térmicas tarde) → cola Recibir.

2 pedidos:
  Farma Mayoreo 308422 · Bodega F-42 Caja 2/83450

Nombres de mostrador desde ficha (Go-UPC / Farmatodo / marca), no el
recorte del térmico. Sin caducidad inventada (MMAA de la caja).
Farma Mayoreo: P.U. ya traen IVA (suma renglones = TOTAL).
Bodega F-42: P.U. impresos (3 decimales) → costo a 2 decimales; total tarjeta.
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
    # ── Farma Mayoreo ──
    "7501082731323": p(
        "7501082731323",
        nombre="Nuvel Beauty antitranspirante roll-on",
        subcategoria="Desodorante",
        forma="Roll-on",
        marca="Nuvel",
        presentacion="55 ml",
        ya=False,
        foto_file="nuvel-beauty-rollon-55ml-7501082731323.jpg",
    ),
    "7501082731286": p(
        "7501082731286",
        nombre="Nuvel Addiction antitranspirante roll-on",
        subcategoria="Desodorante",
        forma="Roll-on",
        marca="Nuvel",
        presentacion="55 ml",
        ya=False,
        foto_file="nuvel-addiction-rollon-55ml-7501082731286.jpg",
    ),
    "7500462933746": p(
        "7500462933746",
        nombre="Inha-Rub ungüento",
        tipo="generico",
        categoria="Medicamentos",
        subcategoria="Resfriado",
        forma="Ungüento",
        marca="ADN Pharma",
        laboratorio="ADN Pharma",
        presentacion="Tarro 40 g",
        principio="Alcanfor / mentol / eucalipto",
        ya=False,
        foto_file="adn-inha-rub-40g-7500462933746.jpg",
    ),
    "7501054549819": p(
        "7501054549819",
        nombre="Nivea Soft Milk",
        subcategoria="Crema corporal",
        forma="Crema",
        marca="Nivea",
        laboratorio="Beiersdorf",
        presentacion="100 ml",
        ya=True,
    ),
    "7501044205725": p(
        "7501044205725",
        nombre="Olorex talco para pies mentol",
        subcategoria="Talco",
        forma="Talco",
        marca="Olorex",
        presentacion="80 g",
        ya=False,
        foto_file="olorex-talco-mentol-80g-7501044205725.jpg",
    ),
    "7501044205718": p(
        "7501044205718",
        nombre="Olorex talco para pies clásico",
        subcategoria="Talco",
        forma="Talco",
        marca="Olorex",
        presentacion="80 g",
        ya=False,
        foto_file="olorex-talco-clasico-80g-7501044205718.jpg",
    ),
    "7501058714312": p(
        "7501058714312",
        nombre="Tempra solución pediátrica uva",
        tipo="marca",
        categoria="Medicamentos",
        subcategoria="Analgésico",
        forma="Solución",
        marca="Tempra",
        laboratorio="RB Health",
        presentacion="Frasco 30 ml",
        principio="Paracetamol",
        concentracion="100 mg/ml",
        ya=True,
        foto_file="tempra-solucion-pediatrica-uva-30ml-7501058714312.jpg",
    ),
    "7896009499180": p(
        "7896009499180",
        nombre="Sensodyne Limpieza Profunda",
        subcategoria="Higiene bucal",
        forma="Crema dental",
        marca="Sensodyne",
        laboratorio="Haleon",
        presentacion="Tubo 50 g",
        ya=False,
        foto_file="sensodyne-limpieza-profunda-50g-7896009499180.jpg",
    ),
    "7896009498091": p(
        "7896009498091",
        nombre="Sensodyne Protección Completa",
        subcategoria="Higiene bucal",
        forma="Crema dental",
        marca="Sensodyne",
        laboratorio="Haleon",
        presentacion="Tubo 90 g",
        ya=True,
    ),
    "5000174305449": p(
        "5000174305449",
        nombre="Fixodent Original adhesivo dental",
        subcategoria="Higiene bucal",
        forma="Crema adhesiva",
        marca="Fixodent",
        laboratorio="P&G",
        presentacion="Tubo 40 ml",
        ya=True,
        foto_file="fixodent-original-40ml-5000174305449.jpg",
    ),
    "7506346604726": p(
        "7506346604726",
        nombre="Vaso coprocultivo estéril Kohn",
        categoria="Botiquín",
        subcategoria="Material de curación",
        forma="Vaso",
        marca="Kohn",
        presentacion="100 ml",
        ya=False,
        foto_file="kohn-vaso-copro-100ml-7506346604726.jpg",
    ),
    "7501054549796": p(
        "7501054549796",
        nombre="Nivea Milk Nutritiva",
        subcategoria="Crema corporal",
        forma="Crema",
        marca="Nivea",
        laboratorio="Beiersdorf",
        presentacion="100 ml",
        ya=True,
    ),
    "7501058793232": p(
        "7501058793232",
        nombre="Sico lubricante cereza",
        subcategoria="Salud sexual",
        forma="Lubricante",
        marca="Sico",
        laboratorio="RB Health",
        presentacion="50 ml",
        ya=True,
    ),
    "7501058793249": p(
        "7501058793249",
        nombre="Sico lubricante sensación calor",
        subcategoria="Salud sexual",
        forma="Lubricante",
        marca="Sico",
        laboratorio="RB Health",
        presentacion="50 ml",
        ya=True,
    ),
    "7500435169035": p(
        "7500435169035",
        nombre="Herbal Essences mousse rizo",
        subcategoria="Cabello",
        forma="Mousse",
        marca="Herbal Essences",
        laboratorio="P&G",
        presentacion="210 ml",
        ya=True,
    ),
    "7506306210103": p(
        "7506306210103",
        nombre="eGo Force desodorante aerosol",
        subcategoria="Desodorante",
        forma="Aerosol",
        marca="eGo",
        laboratorio="Unilever",
        presentacion="150 ml",
        ya=False,
        foto_file="ego-force-aerosol-150ml-7506306210103.jpg",
    ),
    "7506306221765": p(
        "7506306221765",
        nombre="eGo Ultra Fresh desodorante aerosol",
        subcategoria="Desodorante",
        forma="Aerosol",
        marca="eGo",
        laboratorio="Unilever",
        presentacion="150 ml",
        ya=False,
        foto_file="ego-ultra-fresh-aerosol-150ml-7506306221765.jpg",
    ),
    "7506306210080": p(
        "7506306210080",
        nombre="eGo Sport desodorante aerosol",
        subcategoria="Desodorante",
        forma="Aerosol",
        marca="eGo",
        laboratorio="Unilever",
        presentacion="150 ml",
        ya=False,
        foto_file="ego-sport-aerosol-150ml-7506306210080.jpg",
    ),
    # ── Bodega F-42 ──
    "7501943494220": p(
        "7501943494220",
        nombre="Kotex Unika nocturna con alas",
        subcategoria="Higiene femenina",
        forma="Toalla",
        marca="Kotex",
        laboratorio="Kimberly-Clark",
        presentacion="Paquete con 10 piezas",
        ya=False,
        foto_file="kotex-unika-nocturna-c10-7501943494220.jpg",
    ),
    "7501022182796": p(
        "7501022182796",
        nombre="Grisi jabón barra neutro",
        subcategoria="Higiene",
        forma="Jabón",
        marca="Grisi",
        presentacion="Pack 3 barras 150 g",
        ya=False,
        foto_file="grisi-jabon-neutro-pack3-7501022182796.jpg",
    ),
    "7501048352005": p(
        "7501048352005",
        nombre="Protec toallitas con alcohol",
        categoria="Botiquín",
        subcategoria="Material de curación",
        forma="Toallitas",
        marca="Protec",
        presentacion="Bote con 100 piezas",
        ya=False,
        foto_file="protec-toallitas-alcohol-100-7501048352005.jpg",
    ),
    "7501007528939": p(
        "7501007528939",
        nombre="Lubriderm Reparación Intensiva",
        subcategoria="Crema corporal",
        forma="Crema",
        marca="Lubriderm",
        laboratorio="J&J",
        presentacion="120 ml",
        ya=True,
    ),
    "7702035469151": p(
        "7702035469151",
        nombre="Lubriderm UV FPS 15",
        subcategoria="Crema corporal",
        forma="Crema",
        marca="Lubriderm",
        laboratorio="J&J",
        presentacion="120 ml",
        concentracion="FPS 15",
        ya=True,
    ),
    "3614225108778": p(
        "3614225108778",
        nombre="Koleston Castaño Aterciopelado 477",
        subcategoria="Cabello",
        forma="Tinte",
        marca="Koleston",
        laboratorio="Wella",
        presentacion="Kit crema",
        ya=False,
        foto_file="koleston-castano-aterciopelado-477-3614225108778.jpg",
    ),
    "7506339390278": p(
        "7506339390278",
        nombre="Old Spice Leña spray corporal",
        subcategoria="Desodorante",
        forma="Aerosol",
        marca="Old Spice",
        laboratorio="P&G",
        presentacion="150 ml",
        ya=False,
        foto_file="old-spice-lena-spray-150ml-7506339390278.jpg",
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
        "key": "farmamayoreo_308422",
        "folio": "308422",
        "proveedor": "Farma Mayoreo",
        "proveedor_ilike": "farma mayoreo",
        "fecha": "2026-10-06",
        "total": 2385.97,
        "notas": (
            "Ticket Farma Mayoreo 308422 · 06-oct-2026 · CEDA · "
            "tarjeta $2,385.97 · cola Recibir; stock al confirmar pistola · "
            "lote de fábrica en el papel; MMAA de la caja"
        ),
        "tmp": "_fc_fm308422",
        "header": (
            "Farma Mayoreo · ID VENTA 308422 · 2026-10-06 16:34 · caja 0 · Rosalba M.\n"
            "-- RFC FMA180119D55 · sucursal FARMAMAYOREO CENTRAL (Canal de Apatlaco, CEDA).\n"
            "-- Pago tarjeta. SUBTOTAL $2,099.84 + IVA $286.13 = TOTAL $2,385.97.\n"
            "-- Los P.U. ya traen IVA (suma de renglones = total). 18 renglones / 58 pzas.\n"
            "-- Fichas Go-UPC / Farmatodo / marca, no el recorte del térmico.\n"
            "-- Lote de fábrica sí (si no se repite el Lt. del renglón de arriba).\n"
            "-- Caducidad NO: Recibir pide MMAA de la caja. 0000 es inválido.\n"
            "-- Nivea Soft EAN canónico 7501054549819 (ticket térmico confunde 3/5).\n"
            "-- Fixodent Original EAN 5000174305449.\n"
            "-- Tempra SOL PED → solución pediátrica uva 30 ml (Farmatodo)."
        ),
        "rows": [
            row("7501082731323", "DESODORANTE ROLL", 4, 11.96, "019123"),
            row("7501082731286", "DESODORANTE ROLL", 2, 11.96, "613203"),
            row("7500462933746", "ADN INHA RUB UNG", 3, 23.98, "2601VP34"),
            row("7501054549819", "NIVEA CREMA SOFT", 3, 27.81, None),
            row("7501044205725", "TALCO OLOREX CON", 2, 19.98, "TB14E26"),
            row("7501044205718", "TALCO OLOREX ORI", 2, 19.98, "MG3026"),
            row("7501058714312", "TEMPRA SOL PED 3", 2, 155.98, "ABJ8273"),
            row("7896009499180", "C D SENSODYNE LI", 2, 39.98, "KD9L"),
            row("7896009498091", "SENSODYNE PROTEC", 1, 66.98, "VT6A"),
            row("5000174305449", "FIXODENT ORIGINA", 2, 89.98, "5072028890"),
            row("7506346604726", "VASO COPRO ESTER", 13, 4.50, "1460726"),
            row("7501054549796", "NIVEA CREMA MILK", 3, 25.97, None),
            row("7501058793232", "SICO LUBRICANTE", 3, 97.98, "A3G9728"),
            row("7501058793249", "SICO LUBRICANTE", 3, 96.98, "A3H4789"),
            row("7500435169035", "HERBAL ESSENCES", 10, 58.98, "6164C24591102233"),
            row("7506306210103", "DES EGO FORCE 24", 1, 42.99, "262107"),
            row("7506306221765", "DES EGO ULTRA FR", 1, 42.99, "CODWZH"),
            row("7506306210080", "DES EGO AEROSOL", 1, 42.99, "26219"),
        ],
    },
    {
        "key": "bodega_f42_83450",
        "folio": "83450",
        "proveedor": "Bodega F-42 Ejidos del Moral",
        "proveedor_ilike": "bodega f-42",
        "fecha": "2026-10-06",
        "total": 641.67,
        "notas": (
            "Ticket Bodega F-42 Caja 2/83450 · 06-oct-2026 · foto térmica · "
            "tarjeta $641.67 · cola Recibir; stock al confirmar pistola"
        ),
        "tmp": "_fc_bf42_83450",
        "header": (
            "Bodega F-42 Ejidos del Moral · Caja 2/83450 · 2026-10-06 16:59\n"
            "-- Ticket térmico. Subtotal $556.49 + impuestos $85.18 = $641.67.\n"
            "-- Costo = P.U. impreso (suma renglones ≈ total con impuestos).\n"
            "-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000.\n"
            "-- 7 renglones / 14 pzas. Fichas Go-UPC / Farmatodo, no el ticket."
        ),
        "rows": [
            row("7501943494220", "TAS SANIT KOTEX UNIKA NOC C/10", 1, 24.14),
            row("7501022182796", "GRISI 150GR JBN BARRA NEUTRO PACK3", 2, 34.86),
            row("7501048352005", "TAS PROTEC C/ALCOHOL 100 PZS", 2, 69.06),
            row("7501007528939", "CRA LUBRIDERM THINT PSEC120ML", 2, 31.58),
            row("7702035469151", "CRA LUBRIDERM UV FPS15 120ML", 2, 34.41),
            row("3614225108778", "TIN KOLESTON CRA GLOSS CAST ATERCIO 477", 1, 54.07),
            row("7506339390278", "DESOD OLD SPICE LENA SPY 150ML", 4, 55.91),
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

        # Bodega: Old Spice 4×55.912 → usamos 55.91; UV 2×34.405 → 34.41
        # Suma SQL $641.68 vs ticket $641.67 (1 centavo; OK ≤0.02).
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

    todos = OUT_DIR / "patch_carga_tickets_20261006_mayoreo_bodega_TODOS.sql"
    parts = [
        "-- ═══════════════════════════════════════════════════════════════",
        "-- TICKETS 06-OCT-2026 (tarde) · Farma Mayoreo + Bodega F-42",
        "-- Ver LEERME_tickets_20261006_mayoreo_bodega.md",
        "-- ═══════════════════════════════════════════════════════════════",
        "",
    ]
    for path in paths:
        parts.append(f"\n-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        parts.append(f"-- INICIO: {path.name}")
        parts.append(f"-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        parts.append(path.read_text(encoding="utf-8").rstrip() + "\n")
    todos.write_text("\n".join(parts), encoding="utf-8")

    leerme = OUT_DIR / "LEERME_tickets_20261006_mayoreo_bodega.md"
    leerme.write_text(
        """# Tickets Recibir · 06-oct-2026 (tarde)

Fotos Farma Mayoreo + Bodega F-42. Pegar **cada** SQL en Supabase → SQL Editor → Run.

| Pedido | Archivo | Piezas | Total |
|--------|---------|--------|-------|
| Farma Mayoreo 308422 | `patch_carga_farmamayoreo_308422.sql` | 58 | $2,385.97 |
| Bodega F-42 83450 | `patch_carga_bodega_f42_83450.sql` | 14 | $641.67 |

## Todo-en-uno

`patch_carga_tickets_20261006_mayoreo_bodega_TODOS.sql`

## Altas nuevas (stock 0)

- Nuvel Beauty / Addiction roll-on 55 ml
- Inha-Rub ADN Pharma 40 g
- Olorex talco mentol / clásico 80 g
- Sensodyne Limpieza Profunda 50 g
- Vaso coprocultivo Kohn 100 ml
- eGo Force / Ultra Fresh / Sport aerosol 150 ml
- Kotex Unika nocturna C/10
- Grisi jabón neutro pack 3
- Protec toallitas alcohol C/100
- Koleston 477 Castaño Aterciopelado
- Old Spice Leña spray 150 ml

## Notas

- Farma Mayoreo: P.U. con IVA; suma = TOTAL $2,385.97. Lote de fábrica sí; caducidad = MMAA al escanear.
- Bodega: total tarjeta $641.67 (1 ¢ de redondeo en SQL vs papel).
- Regenerar: `python3 scripts/generar_carga_tickets_20261006_mayoreo_bodega.py`
""",
        encoding="utf-8",
    )
    print(f"\nTODOS → {todos.name} ({todos.stat().st_size} bytes)")
    print(f"LEERME → {leerme.name}")


if __name__ == "__main__":
    main()
