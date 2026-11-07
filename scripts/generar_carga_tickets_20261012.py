#!/usr/bin/env python3
"""Tickets 12-oct-2026 (fotos térmicas) → cola Recibir.

5 pedidos:
  Cityfarma S330922 · Cityfarma S330971 · IFC F8 128440
  Equilibrio 447795 · Farmalive 1537

Nombres de mostrador desde ficha (no el código del ticket).
Sin caducidad inventada (MMAA de la caja). Equilibrio sí trae lote de fábrica.
Farmalive: costo = P.U. neto después del descuento del renglón.
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

# Fotos Mayfar (Mercurio) — URL ficha; copia a catalogo-propia tras deploy.
FOTO_JARABE = (
    "https://acdn-us.mitiendanube.com/stores/004/824/171/products/"
    "mer128-8c5715a7144487dbd317373352570961-640-0.webp"
)
FOTO_MANZANA = (
    "https://acdn-us.mitiendanube.com/stores/004/824/171/products/"
    "mer010-3391c4a7525545e5be17194451807817-640-0.webp"
)


def p(
    ean: str | None,
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
    foto_abs: str | None = None,
) -> dict:
    ean_n = ean or ""
    return {
        "ean": ean_n,
        "sku": sku or (sku_de(ean_n) if len(ean_n) >= 8 else "FC-TMP"),
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
        "foto": foto_abs or (foto_url(foto_file) if foto_file else None),
        "foto_file": (
            f"catalogo-propia/{foto_file}" if foto_file else None
        ),
    }


PRODUCTOS: dict[str, dict] = {
    # ── Cityfarma S330922 ──
    "7501298234809": p(
        "7501298234809",
        nombre="Eutirox 25 mcg",
        tipo="marca",
        forma="Tableta",
        marca="Eutirox",
        laboratorio="Merck",
        presentacion="Caja con 50 tabletas",
        principio="Levotiroxina sódica",
        concentracion="25 mcg",
        receta=True,
        ya=False,
    ),
    "7501298234908": p(
        "7501298234908",
        nombre="Eutirox 50 mcg",
        tipo="marca",
        forma="Tableta",
        marca="Eutirox",
        laboratorio="Merck",
        presentacion="Caja con 50 tabletas",
        principio="Levotiroxina sódica",
        concentracion="50 mcg",
        receta=True,
        ya=False,
    ),
    # ── Cityfarma S330971 ──
    "7501298221397": p(
        "7501298221397",
        nombre="Neurobión",
        tipo="marca",
        categoria="Vitaminas",
        forma="Tableta",
        marca="Neurobión",
        laboratorio="Procter & Gamble Health",
        presentacion="Caja con 30 tabletas",
        principio="Tiamina / piridoxina / cianocobalamina",
        concentracion="100 mg / 5 mg / 50 mcg",
        ya=False,
    ),
    "7501298223810": p(
        "7501298223810",
        nombre="Neurobión DC inyectable",
        tipo="marca",
        categoria="Vitaminas",
        forma="Inyectable",
        marca="Neurobión DC",
        laboratorio="Procter & Gamble Health",
        presentacion="Caja con 1 jeringa prellenada doble cámara",
        principio="Tiamina / piridoxina / cianocobalamina",
        concentracion="100 mg / 100 mg / 1 mg",
        receta=True,
        ya=False,
    ),
    # ── IFC (sin EAN GS1 público en pomadas; jarabe usa código distribuidor) ──
    "IFC-JARABE-GRANADA": p(
        "3311000001612",
        sku="FC-DFF99C3F",
        nombre="Mercurio jarabe de granada",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Bucal",
        forma="Jarabe",
        marca="Mercurio",
        laboratorio="Mercurio",
        presentacion="Frasco 50 mL",
        ya=True,
        foto_abs=FOTO_JARABE,
    ),
    "IFC-POMADA-MANZANA": p(
        None,
        sku="FC-MER-MANZANA",
        nombre="Mercurio pomada de manzana",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Pomada",
        forma="Pomada",
        marca="Mercurio",
        laboratorio="Mercurio",
        presentacion="Tarro 50 g",
        ya=True,
        foto_abs=FOTO_MANZANA,
    ),
    "IFC-PAN-PUERCO": p(
        "7506313000278",
        sku="FC-MAD-PANPUERCO",
        nombre="Madrid pomada pan de puerco",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Pomada",
        forma="Pomada",
        marca="Madrid",
        laboratorio="Madrid",
        presentacion="Tarro 50 g",
        ya=False,
    ),
    # ── Equilibrio 447795 ──
    "7502001164413": p(
        "7502001164413",
        sku="EQ-SON220",
        nombre="Clotrimazol 500 mg óvulo",
        tipo="generico",
        forma="Óvulo",
        marca="Son's",
        laboratorio="Son's",
        presentacion="Caja con 1 óvulo",
        principio="Clotrimazol",
        concentracion="500 mg",
        receta=True,
        ya=True,
    ),
    "7503000422863": p(
        "7503000422863",
        sku="EQ-MAV006",
        nombre="Cefalver cefalexina 500 mg",
        tipo="generico",
        forma="Cápsula",
        marca="Cefalver",
        laboratorio="Maver",
        presentacion="Caja con 12 cápsulas",
        principio="Cefalexina",
        concentracion="500 mg",
        receta=True,
        ya=False,
    ),
    # Ticket SON098 = Fenimeth (Levic). Catálogo EQ-SON096 lleva EAN correcto.
    "7502001164697": p(
        "7502001164697",
        sku="EQ-SON096",
        nombre="Fenimeth V metronidazol/nistatina",
        tipo="generico",
        forma="Óvulo",
        marca="Fenimeth V",
        laboratorio="Son's",
        presentacion="Caja con 12 óvulos",
        principio="Metronidazol / nistatina",
        concentracion="500 mg / 100,000 UI",
        receta=True,
        ya=True,
    ),
    # ── Farmalive 1537 ──
    "7501100088217": p(
        "7501100088217",
        nombre="Tylenol gotas infantiles",
        tipo="marca",
        forma="Gotas",
        marca="Tylenol",
        laboratorio="Johnson & Johnson",
        presentacion="Frasco 15 mL",
        principio="Paracetamol",
        ya=False,
    ),
    "7501088505829": p(
        "7501088505829",
        nombre="Troferit Flow jarabe",
        tipo="marca",
        forma="Jarabe",
        marca="Troferit Flow",
        laboratorio="Chinoin",
        presentacion="Frasco 120 mL",
        ya=False,
    ),
    "7501019036590": p(
        "7501019036590",
        nombre="Saba Buenas Noches Extra",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Higiene femenina",
        forma="Toalla",
        marca="Saba",
        laboratorio="Essity",
        presentacion="Paquete con 12 toallas",
        ya=False,
    ),
    "7501019006104": p(
        "7501019006104",
        nombre="Saba Íntima Regular sin alas",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Higiene femenina",
        forma="Toalla",
        marca="Saba",
        laboratorio="Essity",
        presentacion="Paquete con 10 toallas",
        ya=False,
    ),
    "7501008491157": p(
        "7501008491157",
        nombre="Tabcin Pods Noche 2-pack",
        tipo="marca",
        forma="Cápsula",
        marca="Tabcin",
        laboratorio="Bayer OTC",
        presentacion="2 empaques con 12 cápsulas cada uno",
        ya=False,
    ),
    "7501008491140": p(
        "7501008491140",
        nombre="Tabcin Pods Active 2-pack",
        tipo="marca",
        forma="Cápsula",
        marca="Tabcin",
        laboratorio="Bayer OTC",
        presentacion="2 empaques con 12 cápsulas cada uno",
        ya=False,
    ),
    "7501836009661": p(
        "7501836009661",
        sku="FC-36009661",
        nombre="Dualgos paracetamol/ibuprofeno",
        tipo="generico",
        forma="Tableta",
        marca="Dualgos",
        laboratorio="Liferpal",
        presentacion="Caja con 20 tabletas",
        principio="Paracetamol / ibuprofeno",
        concentracion="325/200 mg",
        ya=True,
    ),
    "7501088505836": p(
        "7501088505836",
        nombre="Troferit Flow",
        tipo="marca",
        forma="Tableta",
        marca="Troferit Flow",
        laboratorio="Chinoin",
        presentacion="Caja con 15 tabletas",
        ya=False,
    ),
    "7501008485316": p(
        "7501008485316",
        sku="FC-08485316",
        nombre="Tabcin efervescente",
        tipo="marca",
        forma="Tableta efervescente",
        marca="Tabcin",
        laboratorio="Bayer OTC",
        presentacion="Caja con 12 tabletas",
        ya=True,
    ),
    "7501008485408": p(
        "7501008485408",
        sku="FC-08485408",
        nombre="Tabcin 500",
        tipo="marca",
        forma="Tableta",
        marca="Tabcin",
        laboratorio="Bayer OTC",
        presentacion="Caja con 12 tabletas",
        concentracion="500 mg",
        ya=True,
    ),
    "7501019030048": p(
        "7501019030048",
        nombre="Tena Maxi Protec chico/mediano",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Incontinencia",
        forma="Pañal",
        marca="Tena",
        laboratorio="Essity",
        presentacion="Paquete con 10 piezas",
        ya=False,
    ),
    "7501100088170": p(
        "7501100088170",
        nombre="Tylenol suspensión infantil",
        tipo="marca",
        forma="Suspensión",
        marca="Tylenol",
        laboratorio="Johnson & Johnson",
        presentacion="Frasco 120 mL",
        principio="Paracetamol",
        ya=False,
    ),
    "7501065008473": p(
        "7501065008473",
        sku="FC-5008473",
        nombre="Theraflu TD limón resfriado severo",
        tipo="marca",
        forma="Sobre",
        marca="Theraflu",
        laboratorio="Haleon",
        presentacion="Caja con 10 sobres",
        ya=True,
    ),
    "033200011309": p(
        "033200011309",
        nombre="Arm & Hammer bicarbonato de sodio",
        tipo="marca",
        categoria="Cuidado personal",
        forma="Polvo",
        marca="Arm & Hammer",
        laboratorio="Church & Dwight",
        presentacion="Caja 227 g",
        ya=False,
    ),
    "7501008495339": p(
        "7501008495339",
        nombre="Tabcin 500 exhibidor",
        tipo="marca",
        forma="Tableta",
        marca="Tabcin",
        laboratorio="Bayer OTC",
        presentacion="Exhibidor con 60 tabletas",
        concentracion="500 mg",
        ya=False,
    ),
    "7501008485378": p(
        "7501008485378",
        nombre="Tabcin efervescente exhibidor",
        tipo="marca",
        forma="Tableta efervescente",
        marca="Tabcin",
        laboratorio="Bayer OTC",
        presentacion="Exhibidor con 60 tabletas",
        ya=False,
    ),
    "7501017362998": p(
        "7501017362998",
        sku="FC-73629981",
        nombre="Kleenex pañuelos pack",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Higiene",
        forma="Pañuelo",
        marca="Kleenex",
        laboratorio="Kimberly-Clark",
        presentacion="Pack con 8 paquetes",
        ya=True,
    ),
    "7501088509766": p(
        "7501088509766",
        sku="FC-85097661",
        nombre="Antiflu-Des Jr jarabe infantil",
        tipo="marca",
        forma="Jarabe",
        marca="Antiflu-Des",
        laboratorio="Chinoin",
        presentacion="Frasco 60 mL",
        ya=True,
    ),
    "7502214983375": p(
        "7502214983375",
        nombre="Levonorgestrel 1.5 mg Prudence",
        tipo="marca",
        forma="Tableta",
        marca="Prudence",
        laboratorio="DKT México",
        presentacion="Caja con 1 tableta",
        principio="Levonorgestrel",
        concentracion="1.5 mg",
        ya=False,
    ),
}


def row(key: str, snap: str, qty: int, pu: float, lote: str | None = None) -> dict:
    prod = PRODUCTOS[key]
    ean = prod["ean"] or ""
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
        "key": "cityfarma_s330922",
        "folio": "S330922",
        "proveedor": "Cityfarma Iztapalapa",
        "proveedor_ilike": "cityfarma",
        "fecha": "2026-10-12",
        "total": 789.82,
        "notas": (
            "Ticket Cityfarma S330922 · 12-oct-2026 17:16 · foto térmica · "
            "pagado tarjeta $789.82 · cola Recibir; stock al confirmar pistola + MMAA"
        ),
        "tmp": "_fc_cf_s330922",
        "header": (
            "Cityfarma Iztapalapa · orden S330922 · 2026-10-12 17:16\n"
            "-- Ticket térmico. IVA 0%. Pagado tarjeta = $789.82.\n"
            "-- Eutirox 25 mcg / 50 mcg C/50 (ticket dice «50 MG» = 50 mcg).\n"
            "-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000."
        ),
        "rows": [
            row("7501298234809", "EUTIROX 25MCG T50 AG", 3, 127.00),
            row("7501298234908", "EUTIROX 50 MG C 50 T", 2, 204.41),
        ],
    },
    {
        "key": "cityfarma_s330971",
        "folio": "S330971",
        "proveedor": "Cityfarma Iztapalapa",
        "proveedor_ilike": "cityfarma",
        "fecha": "2026-10-12",
        "total": 942.64,
        "notas": (
            "Ticket Cityfarma S330971 · 12-oct-2026 17:14 · foto térmica · "
            "Pendiente de pago $942.64 · cola Recibir; stock al confirmar pistola + MMAA"
        ),
        "tmp": "_fc_cf_s330971",
        "header": (
            "Cityfarma Iztapalapa · orden S330971 · 2026-10-12 17:14\n"
            "-- Ticket térmico. IVA 0%. Pendiente de pago = $942.64.\n"
            "-- Neurobión C/30 tabs + Neurobión DC inyección C/1.\n"
            "-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000."
        ),
        "rows": [
            row("7501298221397", "NEUROBION C30 TABS V", 2, 272.73),
            row("7501298223810", "NEUROBION DC INY C1", 2, 198.59),
        ],
    },
    {
        "key": "ifc_128440",
        "folio": "128440",
        "proveedor": "IFC F8 Tienda",
        "proveedor_ilike": "ifc",
        "fecha": "2026-10-12",
        "total": 187.50,
        "notas": (
            "Ticket IFC F8 128440 · 12-oct-2026 17:27 · MENUDEO · cliente LUIS · "
            "cola Recibir; stock al confirmar pistola · pomadas sin EAN GS1: ligar caja"
        ),
        "tmp": "_fc_ifc_128440",
        "header": (
            "IFC F8 Tienda · ticket 128440 · 2026-10-12 17:27 · cliente LUIS\n"
            "-- Menudeo. 20 pzas / 3 productos · total $187.50.\n"
            "-- Jarabe granada: código distribuidor 3311000001612 (Mayfar/DISA).\n"
            "-- Pomada Manzana: sin EAN GS1; match por SKU FC-MER-MANZANA.\n"
            "-- Pan puerco Madrid: EAN DISA 7506313000278.\n"
            "-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000."
        ),
        "rows": [
            row(
                "IFC-JARABE-GRANADA",
                "MERCURIO JARABE DE GRANADA C/25 1750827 84611",
                10,
                7.00,
            ),
            row(
                "IFC-POMADA-MANZANA",
                "MERCURIO POMADA MANZANA C/25 2530427 84404",
                5,
                10.50,
            ),
            row(
                "IFC-PAN-PUERCO",
                "MADRID POMADA PAN PUERCO C/25 2712017 D22",
                5,
                13.00,
            ),
        ],
    },
    {
        "key": "equilibrio_447795",
        "folio": "447795",
        "proveedor": "Equilibrio",
        "proveedor_ilike": "equilibrio",
        "fecha": "2026-10-12",
        "total": 263.04,
        "notas": (
            "Ticket Equilibrio 447795 · pedido online WER-220084 · 12-oct-2026 · "
            "Iztapalapa 2 · 8 pzas · $263.04 · cola Recibir; stock al confirmar pistola"
        ),
        "tmp": "_fc_eq_447795",
        "header": (
            "Equilibrio · ticket 447795 · 2026-10-12 17:09 · sucursal Iztapalapa 2\n"
            "-- Pedido online WER-220084. Total $263.04 · 3 renglones / 8 pzas.\n"
            "-- Claves EQF → EAN ficha/Levic/Sufarmed. Lote de fábrica sí.\n"
            "-- Caducidad NO: MMAA de la caja. 0000 inválido.\n"
            "-- SON098 FENIMETH → EAN 7502001164697 (EQ-SON096 en catálogo)."
        ),
        "rows": [
            row(
                "7502001164413",
                "SON220 CLOTRIMAZOL 1 OV 500 MG",
                3,
                29.74,
                "26061474",
            ),
            row(
                "7503000422863",
                "MAV006 CEFALVER 12 CAPS 500 MG",
                3,
                32.88,
                "263343",
            ),
            row(
                "7502001164697",
                "SON098 FENIMETH V 12 OVS 500MG/100,000 UI",
                2,
                37.59,
                "26030746",
            ),
        ],
    },
    {
        "key": "farmalive_1537",
        "folio": "1537",
        "proveedor": "Farmalive",
        "proveedor_ilike": "farmalive",
        "fecha": "2026-10-12",
        "total": 2694.76,
        "notas": (
            "Ticket Farmalive 1537 · Club Iztapalapa 1 · 12-oct-2026 16:59 · "
            "20 artículos / 36 unidades · descuentos por renglón · "
            "cola Recibir; stock al confirmar pistola + MMAA"
        ),
        "tmp": "_fc_fl_1537",
        "header": (
            "Farmalive · ticket 1537 · 2026-10-12 16:59 · Club Iztapalapa 1\n"
            "-- 20 renglones / 36 unidades. Papel: subtotal $2,842.01 − desc. $147.25 "
            "= $2,694.76 · tarjeta $2,697.78 (cambio $3).\n"
            "-- Costo = P.U. neto del renglón a 2 decimales (importe impreso).\n"
            "-- Tabcin Pods = 2PACK (EAN 7501008491157 / 7501008491140), no la caja suelta.\n"
            "-- Levonorgestrel: 5 pzas + 1 promo $0.01 (igual que FarmaLive 12790)."
        ),
        "rows": [
            # pu = importe_neto / qty para que qty*pu = importe del ticket
            row("7501100088217", "TYLENOL GOTAS 15 ML | JOHNSON JOHNSON", 1, 86.93),
            row("7501088505829", "IV TROFERIT FLOW JARABE 120 ML | CHINOIN", 1, 188.70),
            row("7501019036590", "TOA SANIT SABA BUENAS NOCHES EXTRA C/12 | ESSITY", 1, 43.04),
            row("7501019006104", "TOA SANIT SABA INTIMA REG S/ALAS C/10 | SCA", 2, 13.585),
            row("7501008491157", "TABCIN PODS NOCHE CAPS C/12 2PACK | BAYER OTC", 2, 115.20),
            row("7501008491140", "TABCIN PODS ACTIVE CAPS C/12 2PACK | BAYER OTC", 2, 115.20),
            row("7501836009661", "DUALGOS TAB C/20 | LIFERPAL", 4, 29.2025),
            row("7501088505836", "IV TROFERIT FLOW TAB C/15 | CHINOIN", 1, 209.72),
            row("7501008485316", "TABCIN EFERV TAB C/12 | BAYER OTC", 2, 36.96),
            row("7501008485408", "TABCIN 500 TAB C/12 | BAYER OTC", 2, 45.12),
            row("7501019030048", "PAÑAL TENA MAXI PROTEC CH/MED C/10 | ESSITY", 1, 152.00),
            row("7501100088170", "TYLENOL SUSP INF 120 ML | JOHNSON JOHNSON", 1, 148.47),
            row("7501065008473", "THERAFLU VERDE SOB C/10 | HALEON", 2, 153.545),
            row("033200011309", "BICARBONATO DE SODIO ARM & HAMMER 227 GR | CHURCH & DWIGHT", 2, 19.45),
            row("7501008495339", "TABCIN 500 TAB EXH C/60 | BAYER OTC", 1, 197.76),
            row("7501008485378", "TABCIN EFERV EXH TAB C/60 | BAYER OTC", 1, 151.68),
            row("7501017362998", "PAÑUELOS KLEENEX PACK C/8 | KIMBERLY CLARK", 2, 32.83),
            row("7501088509766", "ANTIFLU-DES JR. JBE INF 60 ML | CHINOIN", 2, 118.945),
            row("7502214983375", "IV LEVONORGESTREL 1.5 MG TAB C/1 (PRUDENCE) | DKT MEXICO", 5, 19.60),
            row("7502214983375", "IV LEVONORGESTREL 1.5 MG TAB C/1 (PRUDENCE) promo | DKT", 1, 0.01),
        ],
    },
]


def main() -> None:
    GEN_DIR.mkdir(parents=True, exist_ok=True)
    paths: list[Path] = []
    for t in TICKETS:
        for r in t["rows"]:
            # Importe de línea = redondeo del ticket (no qty×pu truncado a 2 en pu)
            r["sub"] = round(r["qty"] * r["pu"], 2)
            # costo unitario a 2 decimales para SQL (igual que tickets previos)
            r["pu"] = round(r["sub"] / r["qty"], 2) if r["qty"] else r["pu"]
            r["sub"] = round(r["qty"] * r["pu"], 2)
            r["precio"] = ceil_pvp(r["pu"], r["tipo"])

        if t["key"] == "farmalive_1537":
            # Forzar importes impresos del ticket (evita ±1¢ por redondeo)
            printed = [
                86.93, 188.70, 43.04, 27.17, 230.40, 230.40, 116.81, 209.72,
                73.92, 90.24, 152.00, 148.47, 307.09, 38.90, 197.76, 151.68,
                65.66, 237.89, 98.00, 0.01,
            ]
            for r, imp in zip(t["rows"], printed):
                r["sub"] = imp
                r["pu"] = round(imp / r["qty"], 2)
                r["precio"] = ceil_pvp(r["pu"], r["tipo"])
            t["total"] = round(sum(r["sub"] for r in t["rows"]), 2)

        suma = round(sum(r["sub"] for r in t["rows"]), 2)
        pzas = sum(r["qty"] for r in t["rows"])
        if abs(suma - t["total"]) > 0.05:
            raise SystemExit(
                f"{t['folio']}: suma renglones {suma} ≠ total ticket {t['total']}"
            )
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
        # write_carga_sql writes to OUT_DIR/patch_carga_{key}.sql via ticket key?
        paths.append(sql_path)
        print(f"{t['folio']}: {report(t['rows'], t['total'])}")
        print(f"  → {csv_path.relative_to(ROOT)}")
        print(f"  → {sql_path.name} · {pzas} pzas · ${t['total']:.2f}")

    todos = OUT_DIR / "patch_carga_tickets_20261012_TODOS.sql"
    parts = [
        "-- ═══════════════════════════════════════════════════════════════",
        "-- TICKETS 12-OCT-2026 · PEGAR EN SUPABASE (uno por uno o todo)",
        "-- Ver LEERME_tickets_20261012.md",
        "-- ═══════════════════════════════════════════════════════════════",
        "",
    ]
    for path in paths:
        parts.append(f"\n-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        parts.append(f"-- INICIO: {path.name}")
        parts.append(f"-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        parts.append(path.read_text(encoding="utf-8").rstrip() + "\n")
    todos.write_text("\n".join(parts), encoding="utf-8")

    # Piezas / totales para LEERME
    resumen = []
    for t, path in zip(TICKETS, paths):
        pzas = sum(r["qty"] for r in t["rows"])
        resumen.append((t["proveedor"].split()[0] if t["key"].startswith("city") else t["proveedor"], t["folio"], path.name, pzas, t["total"]))

    lines_md = [
        "# Tickets Recibir · 12-oct-2026",
        "",
        "Fotos Cityfarma ×2 + IFC + Equilibrio + Farmalive. Pegar **cada** SQL en Supabase → SQL Editor → Run.",
        "",
        "| Pedido | Archivo | Piezas | Total |",
        "|--------|---------|--------|-------|",
        f"| Cityfarma S330922 | `patch_carga_cityfarma_s330922.sql` | 5 | $789.82 |",
        f"| Cityfarma S330971 | `patch_carga_cityfarma_s330971.sql` | 4 | $942.64 |",
        f"| IFC F8 128440 | `patch_carga_ifc_128440.sql` | 20 | $187.50 |",
        f"| Equilibrio 447795 | `patch_carga_equilibrio_447795.sql` | 8 | $263.04 |",
        f"| Farmalive 1537 | `patch_carga_farmalive_1537.sql` | 36 | ${TICKETS[-1]['total']:,.2f} |",
        "",
        "## Todo-en-uno",
        "",
        "`patch_carga_tickets_20261012_TODOS.sql`",
        "",
        "## Notas",
        "",
        "- Cityfarma S330922 pagado; S330971 **pendiente de pago** $942.64.",
        "- Eutirox ticket «50 MG» = **50 mcg** (EAN `7501298234908`).",
        "- Equilibrio trae **lote de fábrica**; caducidad = MMAA de la caja al escanear.",
        "- Fenimeth (SON098) → EAN `7502001164697` / SKU `EQ-SON096` (ficha correcta).",
        "- Cefalver 12 cáps 500 mg → EAN Sufarmed `7503000422863`.",
        "- IFC: Pomada Manzana sin EAN GS1 (SKU `FC-MER-MANZANA`). Jarabe granada `3311000001612`.",
        "- Madrid pan puerco EAN `7506313000278` (DISA). **Foto pendiente**.",
        "- Farmalive: costo = neto del renglón. Tabcin Pods = **2PACK**. Levonorgestrel 5+1 promo $0.01.",
        "- Farmalive papel $2,694.76 / SQL suma renglones (±¢ por redondeo); tarjeta $2,697.78.",
        "- Regenerar: `python3 scripts/generar_carga_tickets_20261012.py`",
        "",
    ]
    leerme = OUT_DIR / "LEERME_tickets_20261012.md"
    leerme.write_text("\n".join(lines_md), encoding="utf-8")
    print(f"\nTODOS → {todos.name} ({todos.stat().st_size} bytes)")
    print(f"LEERME → {leerme.name}")


if __name__ == "__main__":
    main()
