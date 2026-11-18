#!/usr/bin/env python3
"""Tickets 28-sep-2026 (fotos térmicas) → altas + cola Recibir.

3 pedidos:
  Farma Mayoreo 306978 · IFC F8 126031 · Equilibrio 446088

Costo = P.U. neto del ticket (después de descuento / con IVA si el
térmico ya lo trae en el renglón).
Equilibrio: lote de fábrica sí; caducidad NO (MMAA de la caja).
Farma Mayoreo / IFC: igual — no inventar 0000.
Nombres de ficha, no el recorte del ticket.
"""
from __future__ import annotations

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_carga_tickets_20260915 import (  # noqa: E402
    report,
    sku_de,
    sql_str,
)

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "sql"
GEN_DIR = ROOT / "sql" / "generated"
FOTO_BASE = "https://www.farmacapital.mx/catalogo-propia"


def ceil_pvp(costo: float, tipo: str) -> int:
    factor = 1.25 if tipo == "marca" else 1.6
    return int(math.ceil(costo * factor))


def foto_file(name: str | None) -> str | None:
    if not name:
        return None
    path = ROOT / "public" / "catalogo-propia" / name
    if not path.exists() or path.stat().st_size < 4000:
        return None
    return f"catalogo-propia/{name}"


def foto_ok(name: str | None) -> str | None:
    rel = foto_file(name)
    return f"{FOTO_BASE}/{name}" if rel else None


def p(
    *,
    sku: str,
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
    foto_name: str | None = None,
) -> dict:
    return {
        "sku": sku,
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
        "foto": foto_ok(foto_name),
        "foto_file": foto_file(foto_name),
    }


def row(
    ean: str | None,
    snap: str,
    qty: int,
    pu: float,
    meta: dict,
    lote: str | None = None,
) -> dict:
    sub = round(qty * pu, 2)
    return {
        "ean": ean or "",
        "sku": meta["sku"],
        "snap": snap,
        "nombre": meta["nombre"],
        "qty": qty,
        "pu": pu,
        "sub": sub,
        "lote": lote,
        **{
            k: meta[k]
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
        "precio": ceil_pvp(pu, meta["tipo"]),
        "match": "ya" if meta["ya"] else ("sin_ean" if not ean else "alta"),
    }


# ── catálogo por EAN / clave ───────────────────────────────────────
FM = {
    "7503007859624": p(
        sku=sku_de("7503007859624"),
        nombre="Blumen jabón líquido Coconut Paradise 525 ml",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Higiene",
        forma="Jabón líquido",
        marca="Blumen",
        presentacion="Botella 525 ml",
        foto_name="blumen-jabon-liquido-coco-525ml-7503007859624.jpg",
    ),
    "7503007859648": p(
        sku=sku_de("7503007859648"),
        nombre="Blumen jabón líquido Cherry Blossom 525 ml",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Higiene",
        forma="Jabón líquido",
        marca="Blumen",
        presentacion="Botella 525 ml",
        ya=True,
        foto_name="blumen-jabon-liquido-cherry-525ml.jpg",
    ),
    "7503007859617": p(
        sku=sku_de("7503007859617"),
        nombre="Blumen jabón líquido Kiwi 525 ml",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Higiene",
        forma="Jabón líquido",
        marca="Blumen",
        presentacion="Botella 525 ml",
        foto_name="blumen-jabon-liquido-kiwi-525ml-7503007859617.jpg",
    ),
    "7506267905131": p(
        sku="FC-67905131",
        nombre="Blumen jabón líquido Cherry Blossom 221 ml",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Higiene",
        forma="Jabón líquido",
        marca="Blumen",
        presentacion="Botella 221 ml",
        ya=True,
    ),
    "7503008344617": p(
        sku=sku_de("7503008344617"),
        nombre="Vitamina E Progela 850 mg C/30",
        tipo="marca",
        categoria="Vitaminas",
        subcategoria="Suplemento",
        forma="Cápsula",
        marca="Progela",
        laboratorio="Progela",
        presentacion="Caja con 30 cápsulas",
        principio="Vitamina E / aceite de germen de trigo",
        concentracion="850 mg",
        foto_name="progela-vitamina-e-850mg-c30-7503008344617.jpg",
    ),
    # Ticket: «ACETONA MADRID 4» / «MADRID ACEITE DE» — no inventar ml ni tipo.
    "7506313000377": p(
        sku=sku_de("7506313000377"),
        nombre="Acetona Madrid",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Uñas",
        forma="Acetona",
        marca="Madrid",
        laboratorio="AMSA",
    ),
    "7506313000810": p(
        sku=sku_de("7506313000810"),
        nombre="Aceite Madrid",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Piel",
        forma="Aceite",
        marca="Madrid",
        laboratorio="AMSA",
    ),
    "7506313000230": p(
        sku=sku_de("7506313000230"),
        nombre="Aceite Madrid",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Piel",
        forma="Aceite",
        marca="Madrid",
        laboratorio="AMSA",
    ),
    "7506313000155": p(
        sku=sku_de("7506313000155"),
        nombre="Aceite Madrid",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Piel",
        forma="Aceite",
        marca="Madrid",
        laboratorio="AMSA",
    ),
    "7506267905186": p(
        sku="FC-67905186",
        nombre="Blumen jabón líquido Coconut 221 ml",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Higiene",
        forma="Jabón líquido",
        marca="Blumen",
        presentacion="Botella 221 ml",
        ya=True,
        foto_name="blumen-coconut-221ml.jpg",
    ),
    "7506267905148": p(
        sku=sku_de("7506267905148"),
        nombre="Blumen jabón líquido Kiwi Starfruit 221 ml",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Higiene",
        forma="Jabón líquido",
        marca="Blumen",
        presentacion="Botella 221 ml",
        foto_name="blumen-jabon-liquido-kiwi-221ml-7506267905148.jpg",
    ),
    "7506313000972": p(
        sku=sku_de("7506313000972"),
        nombre="Aceite Madrid",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Piel",
        forma="Aceite",
        marca="Madrid",
        laboratorio="AMSA",
    ),
}

IFC_MANZANA = p(
    sku="FC-MER-MANZANA",
    nombre="Mercurio Pomada Manzana 50 g",
    tipo="marca",
    categoria="Cuidado personal",
    subcategoria="Piel",
    forma="Pomada",
    marca="Mercurio",
    presentacion="50 g",
    ya=True,
    foto_name="mercurio-pomada-manzana-50g.jpg",
)

EQ = {
    "WER053": (
        None,
        p(
            sku="EQ-WER053",
            nombre="Rosel Pediatric solución 30 ml",
            marca="Rosel",
            laboratorio="Wermar",
            forma="Solución",
            presentacion="Frasco 30 ml",
            principio="Amantadina / clorfenamina / paracetamol",
            concentracion="2.5/0.100/15 g / 30 ml",
            # TODO EAN: ligar código de la caja al escanear.
        ),
    ),
    "MAV236": (
        "7502009745478",
        p(
            sku="EQ-MAV236",
            nombre="Ideliver Pro duloxetina 60 mg C/14",
            marca="Ideliver Pro",
            laboratorio="Maver",
            forma="Tableta",
            presentacion="Caja con 14 tabletas",
            principio="Duloxetina",
            concentracion="60 mg",
            receta=True,
            ya=True,
        ),
    ),
    "MAV212": (
        "7502009744877",
        p(
            sku="FC-A909ABC0",
            nombre="Odivitor atorvastatina 20 mg C/10",
            marca="Odivitor",
            laboratorio="Maver",
            forma="Tableta",
            presentacion="Caja con 10 tabletas",
            principio="Atorvastatina",
            concentracion="20 mg",
            receta=True,
            ya=True,
        ),
    ),
    "MAV237": (
        "7502009745485",
        p(
            sku="EQ-MAV237",
            nombre="Ideliver Pro duloxetina 30 mg C/7",
            marca="Ideliver Pro",
            laboratorio="Maver",
            forma="Tableta",
            presentacion="Caja con 7 tabletas",
            principio="Duloxetina",
            concentracion="30 mg",
            receta=True,
        ),
    ),
    "AVT201": (
        "7502209858206",
        p(
            sku="EQ-AVT201",
            nombre="Alphalock tamsulosina 0.4 mg C/20",
            marca="Alphalock",
            laboratorio="Avitus",
            forma="Cápsula",
            presentacion="Caja con 20 cápsulas",
            principio="Tamsulosina",
            concentracion="0.4 mg",
            receta=True,
        ),
    ),
    "DEN073": (
        None,
        p(
            sku="EQ-DEN073",
            nombre="Delaphil 20 mg C/4",
            marca="Delaphil",
            forma="Tableta",
            presentacion="Caja con 4 tabletas",
            concentracion="20 mg",
            receta=True,
        ),
    ),
    "BEA463": (
        None,
        p(
            sku="EQ-BEA463",
            nombre="Tamsulosina 0.4 mg C/30",
            marca="beadvance",
            laboratorio="beadvance",
            forma="Cápsula",
            presentacion="Caja con 30 cápsulas",
            principio="Tamsulosina",
            concentracion="0.4 mg",
            receta=True,
        ),
    ),
    "AMS458": (
        None,
        p(
            sku="EQ-AMS458",
            nombre="Ácido alendrónico 70 mg C/4",
            marca="AMSA",
            laboratorio="AMSA",
            forma="Tableta",
            presentacion="Caja con 4 tabletas",
            principio="Ácido alendrónico",
            concentracion="70 mg",
            receta=True,
        ),
    ),
    "AMS232": (
        "7501349025943",
        p(
            sku="EQ-AMS232",
            nombre="Pregabalina 75 mg C/28",
            marca="AMSA",
            laboratorio="AMSA",
            forma="Cápsula",
            presentacion="Caja con 28 cápsulas",
            principio="Pregabalina",
            concentracion="75 mg",
            receta=True,
            ya=True,
        ),
    ),
    "QUM019": (
        "7502223112193",
        p(
            sku="FMX-502386",
            nombre="Guaxoquim jarabe adulto 140 ml",
            tipo="marca",
            marca="Guaxoquim",
            laboratorio="Quimphar",
            forma="Jarabe",
            presentacion="Frasco 140 ml",
            concentracion="100/50 mg/5 ml",
            ya=True,
        ),
    ),
    "ALP0241": (
        None,
        p(
            sku="EQ-ALP0241",
            nombre="Vivradoxil doxiciclina 100 mg C/10",
            marca="Alpharma",
            laboratorio="Alpharma",
            forma="Tableta",
            presentacion="Caja con 10 tabletas",
            principio="Doxiciclina",
            concentracion="100 mg",
            receta=True,
        ),
    ),
    # Ticket OCR «BI0064» → clave Levic BIO064
    "BIO064": (
        "7501573902706",
        p(
            sku="FC-4F737E93",
            nombre="Cloxan ambroxol solución 120 ml",
            tipo="marca",
            marca="Cloxan",
            laboratorio="Bioresearch",
            forma="Solución",
            presentacion="Frasco 120 ml",
            principio="Ambroxol",
            concentracion="300 mg/120 ml",
            ya=True,
        ),
    ),
    "QUI127": (
        "7501644707490",
        p(
            sku="EQ-QUI127",
            nombre="Levonorgestrel / etinilestradiol 0.15/0.03 mg C/28",
            marca="Quifa",
            laboratorio="Quifa",
            forma="Tableta",
            presentacion="Caja con 28 tabletas",
            principio="Levonorgestrel / etinilestradiol",
            concentracion="0.15/0.03 mg",
            receta=True,
            ya=True,
        ),
    ),
    "JAY239": (
        None,
        p(
            sku="EQ-JAY239",
            nombre="Zensif ceftriaxona I.M. 1 g",
            marca="Zensif",
            laboratorio="Jayor",
            forma="Inyectable",
            presentacion="Frasco ámpula 1 g / 3.5 ml",
            principio="Ceftriaxona",
            concentracion="1 g",
            receta=True,
        ),
    ),
    "BIO016": (
        "7501573900337",
        p(
            sku="FC-1DA570E3",
            nombre="Cloxan ambroxol 30 mg C/20",
            tipo="marca",
            marca="Cloxan",
            laboratorio="Bioresearch",
            forma="Comprimidos",
            presentacion="Caja con 20 comprimidos",
            principio="Ambroxol",
            concentracion="30 mg",
            ya=True,
        ),
    ),
    "LOE058": (
        "7502211784005",
        p(
            sku="EQ-LOE058",
            nombre="Feniffler-T fenitoína 100 mg C/50",
            marca="Feniffler-T",
            laboratorio="Loeffler",
            forma="Tableta",
            presentacion="Frasco 50 tabletas",
            principio="Fenitoína",
            concentracion="100 mg",
            receta=True,
            ya=True,
        ),
    ),
    "SOE017": (
        "7501384505271",
        p(
            sku="FMX-307626",
            nombre="Bromuro de pinaverio Alpharma 100 mg C/14",
            marca="Alpharma",
            laboratorio="Alpharma",
            forma="Tableta",
            presentacion="Caja con 14 tabletas",
            principio="Bromuro de pinaverio",
            concentracion="100 mg",
            receta=True,
            ya=True,
        ),
    ),
    "VIT073": (
        "7501478317421",
        p(
            sku="EQ-VIT073",
            nombre="Bocetix levocetirizina solución 150 ml",
            marca="Bocetix",
            laboratorio="Vitae",
            forma="Solución",
            presentacion="Frasco 150 ml",
            principio="Levocetirizina",
            concentracion="50 mg / 150 ml",
            ya=True,
            foto_name="bocetix-levocetirizina-150ml.jpg",
        ),
    ),
    "STR007": (
        "7501547522220",
        p(
            sku="EQ-STR007",
            nombre="Trociletas cereza 1.45 mg C/10",
            tipo="marca",
            marca="Trociletas",
            laboratorio="Streger",
            forma="Tableta",
            presentacion="Caja con 10 tabletas",
            principio="Cloruro de cetilpiridinio",
            concentracion="1.45 mg",
        ),
    ),
    "GEP050": (
        None,
        p(
            sku="EQ-GEP050",
            nombre="Esgaro 5 mg C/10",
            marca="Esgaro",
            forma="Cápsula",
            presentacion="Caja con 10 cápsulas",
            concentracion="5 mg",
            receta=True,
        ),
    ),
    "STR008": (
        "7501547522145",
        p(
            sku="EQ-STR008",
            nombre="Trociletas-B limón 2.5/10 mg C/12",
            tipo="marca",
            marca="Trociletas",
            laboratorio="Streger",
            forma="Tableta",
            presentacion="Caja con 12 tabletas",
            principio="Cloruro de cetilpiridinio / benzocaína",
            concentracion="2.5/10 mg",
            ya=True,
        ),
    ),
    "STR029": (
        None,
        p(
            sku="EQ-STR029",
            nombre="Trociletas cereza 1.45 mg C/12",
            tipo="marca",
            marca="Trociletas",
            laboratorio="Streger",
            forma="Tableta",
            presentacion="Caja con 12 tabletas",
            principio="Cloruro de cetilpiridinio",
            concentracion="1.45 mg",
        ),
    ),
}


def eq_row(codigo: str, snap: str, qty: int, pu: float, lote: str | None) -> dict:
    ean, meta = EQ[codigo]
    return row(ean, snap, qty, pu, meta, lote)


TICKETS = [
    {
        "key": "farmamayoreo_306978",
        "folio": "306978",
        "proveedor": "Farma Mayoreo",
        "proveedor_ilike": "farma mayoreo",
        "fecha": "2026-09-28",
        "total": 539.74,
        "notas": (
            "Ticket Farma Mayoreo 306978 · 28-sep-2026 16:00 · CEDA · tarjeta · "
            "cola Recibir; stock al confirmar pistola · lote de fábrica en papel; "
            "MMAA de la caja · Aceite/Acetona Madrid: tipo/ml al escanear (ticket corta)"
        ),
        "tmp": "_fc_fm_306978",
        "header": (
            "Farma Mayoreo · ID VENTA 306978 · 2026-09-28 16:00 · caja 1 · Rosalba Medel\n"
            "-- RFC FMA180119D55 · FARMAMAYOREO CENTRAL (Canal de Apatlaco, CEDA).\n"
            "-- Pago tarjeta. SUBTOTAL $465.34 + IVA $74.40 = TOTAL $539.74.\n"
            "-- Los P.U. ya traen IVA (suma renglones = total). 12 renglones / 27 pzas.\n"
            "-- Blumen 525: coco 9624 · cherry 9648 · kiwi 9617. 221 ml: cherry/coco/kiwi.\n"
            "-- Aceite/Acetona Madrid: ticket «MADRID ACEITE DE» / «ACETONA MADRID 4» —\n"
            "-- no se inventa tipo ni ml (mismo criterio que almendras 305016).\n"
            "-- Lote de fábrica sí. Caducidad NO: MMAA de la caja. 0000 inválido."
        ),
        "rows": [
            row("7503007859624", "BLUMEN JABON LIQ", 1, 35.98, FM["7503007859624"]),
            row("7503007859648", "BLUMEN JABON LIQ", 2, 35.98, FM["7503007859648"]),
            row("7503007859617", "BLUMEN JABON LIQ", 2, 35.98, FM["7503007859617"]),
            row("7506267905131", "JABON BLUMEN JL", 2, 17.69, FM["7506267905131"]),
            row("7503008344617", "VITAMINA PROGELA", 2, 44.97, FM["7503008344617"], "0040U"),
            row("7506313000377", "ACETONA MADRID 4", 2, 10.00, FM["7506313000377"], "03-05-19"),
            row("7506313000810", "MADRID ACEITE DE", 3, 11.98, FM["7506313000810"], "03-05-19"),
            row("7506313000230", "MADRID ACEITE DE", 3, 11.98, FM["7506313000230"], "2712-017"),
            row("7506313000155", "MADRID ACEITE DE", 3, 11.98, FM["7506313000155"], "2712-017"),
            row("7506267905186", "JBN BLUMEN JL CP", 2, 17.69, FM["7506267905186"]),
            row("7506267905148", "JABON BLUMEN JL", 2, 17.69, FM["7506267905148"]),
            row("7506313000972", "MADRID ACEITE DE", 3, 11.98, FM["7506313000972"]),
        ],
    },
    {
        "key": "ifc_126031",
        "folio": "126031",
        "proveedor": "IFC F8 Tienda",
        "proveedor_ilike": "ifc",
        "fecha": "2026-09-28",
        "total": 47.50,
        "notas": (
            "Farma Centre / IFC F8 Tienda · folio 126031 · MENUDEO · "
            "28-sep-2026 16:17 · cliente LUIS · sin EAN GS1 (código IFC 82943) · "
            "cola Recibir; stock al confirmar pistola · Pomada Manzana FC-MER-MANZANA"
        ),
        "tmp": "_fc_ifc_126031",
        "header": (
            "IFC F8 Tienda · folio 126031 · 2026-09-28 16:17 · CJ 01 · cliente LUIS\n"
            "-- MENUDEO. Total $47.50 · 1 producto / 5 pzas. P.PUBLICO = costo.\n"
            "-- Misma ficha que 122576: Mercurio Pomada Manzana 50 g (FC-MER-MANZANA).\n"
            "-- Sin EAN GS1 (código IFC 82943). Ligar EAN de la caja al escanear.\n"
            "-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000."
        ),
        "rows": [
            row("", "MERCURIO POMADA MANZANA C/25 2530123 82943", 5, 9.50, IFC_MANZANA),
        ],
    },
    {
        "key": "equilibrio_446088",
        "folio": "446088",
        "proveedor": "Equilibrio",
        "proveedor_ilike": "equilibrio",
        "fecha": "2026-09-28",
        "total": 3149.38,
        "notas": (
            "Ticket Equilibrio 446088 · Iztapalapa 2 · pedido online · "
            "cliente 307513 Palillero · 28-sep-2026 · lote de fábrica en papel · "
            "cola Recibir; stock al confirmar pistola + MMAA · "
            "sin EAN: WER053 DEN073 BEA463 AMS458 ALP0241 JAY239 GEP050 STR029"
        ),
        "tmp": "_fc_eq_446088",
        "header": (
            "Equilibrio · ticket 446088 · 2026-09-28 14:55 · sucursal Iztapalapa 2\n"
            "-- Pedido online. Total $3,149.38 · 22 renglones / 106 pzas. IVA $0.\n"
            "-- Costo = P.U. neto (después de D/D6). Claves EQF → EAN Levic/ficha.\n"
            "-- Ticket OCR BI0064 = BIO064 Cloxan sol. 7501573902706.\n"
            "-- Sin EAN público aún: WER053 DEN073 BEA463 AMS458 ALP0241 JAY239\n"
            "-- GEP050 STR029 → alta por SKU EQ-*; ligar EAN de caja al escanear.\n"
            "-- Lote de fábrica sí. Caducidad NO: MMAA de la caja. 0000 inválido."
        ),
        "rows": [
            eq_row("WER053", "WER053 ROSEL PED 1 SOL 2.5/10/15G 30ML", 3, 28.48, "260603"),
            eq_row("MAV236", "MAV236 IDELIVER PRO 14 TAB 60 MG", 4, 59.82, "264227"),
            eq_row("MAV212", "MAV212 ODIVITOR 10 TAB 20 MG", 5, 13.77, "261644"),
            eq_row("MAV237", "MAV237 IDELIVER PRO 7 TAB 30 MG", 5, 30.16, "256611"),
            eq_row("AVT201", "AVT201 ALPHALOCK 20 CAPS 0.4 MG", 5, 35.41, "SC26069"),
            eq_row("DEN073", "DEN073 DELAPHIL 4 TAB 20 MG", 5, 23.65, "26F009"),
            eq_row("BEA463", "BEA463 TAMSULOSINA 30 CAPS 0.4 MG", 3, 46.19, "SC26101"),
            eq_row("AMS458", "AMS458 ACIDO ALENDRONICO 4 TAB 70 MG", 4, 29.26, "U26A137"),
            eq_row("AMS232", "AMS232 PREGABALINA 28 CAPS 75 MG", 3, 38.02, "U26J066"),
            eq_row("QUM019", "QUM019 GUAXOQUIM AD 1 JBE 100/50MG/5/140 ML", 3, 39.17, "26BN38"),
            eq_row("ALP0241", "ALP0241 VIVRADOXIL 10 TAB 100 MG", 2, 29.13, "2604467"),
            eq_row("BIO064", "BI0064 CLOXAN 1 SOL 300MG/120ML", 3, 12.12, "LE262B"),
            eq_row("QUI127", "QUI127 LEVONORGES ETINILEST 28 TAB 0.15/0.03MG", 2, 24.54, "26F010"),
            eq_row("JAY239", "JAY239 ZENSIF I.M. 1 FA 1G/3.5 ML", 10, 9.47, "3125180"),
            eq_row("BIO016", "BIO016 CLOXAN 20 COMP 30 MG", 4, 9.53, "SB2642"),
            eq_row("LOE058", "LOE058 FENIFFLER-T 50 TAB 100 MG", 2, 20.56, "R2511437"),
            eq_row("SOE017", "SOE017 BROMURO DE PINAVERIO 14 TAB 100 MG", 5, 18.78, "172066"),
            eq_row("VIT073", "VIT073 BOCETIX 1 SOL 50 MG 150 ML", 3, 73.28, "T2604224"),
            eq_row("STR007", "STR007 TROCILETAS CEREZA 10 TAB 1.45 MG", 10, 27.61, "SN01IN"),
            eq_row("GEP050", "GEP050 ESGARO 10 CAPS 5 MG", 5, 54.57, "260910"),
            eq_row("STR008", "STR008 TROCILETAS-B LIMON 12 TAB 2.5/10 MG", 10, 32.11, "SN02SD"),
            eq_row("STR029", "STR029 TROCILETAS CEREZA 12 TAB 1.45 MG", 10, 32.11, "IU02SR"),
        ],
    },
]


def write_carga_sql(ticket: dict) -> Path:
    """SQL combinado altas + cola Recibir. Soporta EAN vacío (match por SKU)."""
    rows = ticket["rows"]
    tmp = ticket["tmp"]
    folio = ticket["folio"]
    vals = []
    for i, r in enumerate(rows, start=1):
        ean = r["ean"] or None
        vals.append(
            "  ({linea}, {ean}, {sku}, {nombre}, {snap}, {qty}, {costo}, {precio}, "
            "{tipo}, {cat}, {subcat}, {forma}, {marca}, {lab}, {pres}, {pa}, {conc}, "
            "{receta}, {ya}, {foto}, {foto_file}, {lote})".format(
                linea=i,
                ean=sql_str(ean),
                sku=sql_str(r["sku"]),
                nombre=sql_str(r["nombre"]),
                snap=sql_str(r["snap"]),
                qty=int(r["qty"]),
                costo=f"{r['pu']:.2f}",
                precio=int(r["precio"]),
                tipo=sql_str(r["tipo"]),
                cat=sql_str(r["categoria"]),
                subcat=sql_str(r["subcategoria"]),
                forma=sql_str(r["forma"]),
                marca=sql_str(r["marca"]),
                lab=sql_str(r["laboratorio"]),
                pres=sql_str(r["presentacion"]),
                pa=sql_str(r["principio"]),
                conc=sql_str(r["concentracion"]),
                receta="true" if r["receta"] else "false",
                ya="true" if r["ya"] else "false",
                foto=sql_str(r["foto"]),
                foto_file=sql_str(r["foto_file"]),
                lote=sql_str(r.get("lote")),
            )
        )

    n_alta = sum(1 for r in rows if not r["ya"])
    n_ya = sum(1 for r in rows if r["ya"])
    sin_ean = [r["sku"] for r in rows if not r["ean"]]
    body = f"""-- {ticket['header']}
-- {n_alta} alta(s) stock 0. {n_ya} ya estaban: solo costo / ficha vacía, no PVP.
-- Sin EAN (match por SKU): {", ".join(sin_ean) or "ninguno"}.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table {tmp} (
  linea integer primary key,
  ean text,
  sku text not null,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,2) not null,
  precio numeric(12,2) not null,
  tipo text not null,
  categoria text not null,
  subcategoria text,
  forma text,
  marca text,
  laboratorio text,
  presentacion text,
  principio_activo text,
  concentracion text,
  receta boolean not null,
  ya boolean not null,
  imagen text,
  foto_file text,
  lote text
) on commit drop;

insert into {tmp} (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
{",\n".join(vals)};

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when nullif(btrim(t.ean), '') is not null and exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  nullif(btrim(t.ean), ''),
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta {ticket["proveedor"]} {folio} · {ticket["fecha"]} · listo para pistola',
  t.costo,
  t.precio,
  0,
  1,
  true,
  t.receta,
  t.marca,
  t.presentacion,
  t.forma,
  t.principio_activo,
  t.concentracion,
  t.laboratorio,
  t.imagen,
  t.imagen
from (
  select distinct on (coalesce(nullif(btrim(ean), ''), sku)) *
  from {tmp}
  order by coalesce(nullif(btrim(ean), ''), sku), linea
) t
where (
    nullif(btrim(t.ean), '') is null
    or public.fc_buscar_producto_escaneo(t.ean) is null
  )
  and public.fc_buscar_producto_escaneo(t.sku) is null;

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from (
  select distinct on (coalesce(nullif(btrim(ean), ''), sku)) *
  from {tmp}
  order by coalesce(nullif(btrim(ean), ''), sku), linea
) t
where p.id = coalesce(
  case when nullif(btrim(t.ean), '') is not null
    then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

update public.productos p
set
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  codigo_barras = coalesce(
    nullif(trim(p.codigo_barras), ''),
    nullif(btrim(t.ean), '')
  )
from (
  select distinct on (coalesce(nullif(btrim(ean), ''), sku)) *
  from {tmp}
  order by coalesce(nullif(btrim(ean), ''), sku), linea
) t
where p.id = coalesce(
  case when nullif(btrim(t.ean), '') is not null
    then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  {sql_str(ticket["proveedor"])},
  {sql_str(folio)},
  {sql_str(ticket["fecha"])},
  {ticket["total"]:.2f},
  'borrador',
  {sql_str(ticket["notas"])}
where not exists (
  select 1 from public.recepciones
  where folio = {sql_str(folio)}
    and coalesce(proveedor, '') ilike {sql_str("%" + ticket["proveedor_ilike"] + "%")}
);

update public.recepciones
set
  total_ticket = {ticket["total"]:.2f},
  fecha = {sql_str(ticket["fecha"])},
  proveedor = {sql_str(ticket["proveedor"])},
  notas = {sql_str(ticket["notas"])},
  updated_at = now()
where folio = {sql_str(folio)}
  and coalesce(proveedor, '') ilike {sql_str("%" + ticket["proveedor_ilike"] + "%")}
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = {sql_str(folio)}
  and coalesce(r.proveedor, '') ilike {sql_str("%" + ticket["proveedor_ilike"] + "%")}
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  v.pid,
  nullif(btrim(t.ean), ''),
  t.nombre,
  t.qty,
  null,
  t.lote,
  t.costo,
  (v.pid is null),
  'pdf',
  false,
  (
    v.pid is not null and exists (
      select 1 from public.lotes l
      where l.producto_id = v.pid
        and coalesce(l.activo, true)
        and coalesce(l.cantidad_actual, 0) > 0
        and l.numero_lote is distinct from t.lote
    )
  ),
  null
from {tmp} t
join public.recepciones r
  on r.folio = {sql_str(folio)}
 and coalesce(r.proveedor, '') ilike {sql_str("%" + ticket["proveedor_ilike"] + "%")}
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(t.ean) end,
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  p.id,
  t.imagen,
  t.foto_file,
  coalesce((
    select max(i.posicion) from public.producto_imagenes i
    where i.producto_id = p.id
  ), 0) + 1,
  not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.es_principal
  ),
  'propia'
from (
  select distinct on (coalesce(nullif(btrim(ean), ''), sku)) *
  from {tmp}
  order by coalesce(nullif(btrim(ean), ''), sku), linea
) t
join public.productos p on p.id = coalesce(
  case when nullif(btrim(t.ean), '') is not null
    then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
)
where t.imagen is not null
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url = t.imagen
  );

commit;

select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 52) as nombre,
  i.cantidad,
  i.costo_estimado,
  i.numero_lote,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = {sql_str(folio)}
  and coalesce(r.proveedor, '') ilike {sql_str("%" + ticket["proveedor_ilike"] + "%")}
order by i.id;
"""
    path = OUT_DIR / f"patch_carga_{ticket['key']}.sql"
    path.write_text(body, encoding="utf-8")
    return path


def write_leerme() -> Path:
    lines = [
        "# Tickets Recibir · 28-sep-2026",
        "",
        "Fotos térmicas (Palillero / Luis). Pegar **cada** SQL en Supabase → SQL Editor → Run.",
        "",
        "| Pedido | Archivo | Piezas | Total |",
        "|--------|---------|--------|-------|",
        "| Farma Mayoreo 306978 | `patch_carga_farmamayoreo_306978.sql` | 27 | $539.74 |",
        "| IFC F8 126031 | `patch_carga_ifc_126031.sql` | 5 | $47.50 |",
        "| Equilibrio 446088 | `patch_carga_equilibrio_446088.sql` | 106 | $3,149.38 |",
        "",
        "## Altas nuevas (stock 0)",
        "",
        "### Farma Mayoreo",
        "- Blumen jabón líquido Coconut Paradise 525 ml (`7503007859624`)",
        "- Blumen jabón líquido Kiwi 525 ml (`7503007859617`)",
        "- Vitamina E Progela 850 mg C/30 (`7503008344617`)",
        "- Acetona Madrid (`7506313000377`) · ml al escanear",
        "- Aceite Madrid ×4 EAN (`7506313000810`, `0230`, `0155`, `0972`) · tipo/ml al escanear",
        "- Blumen jabón líquido Kiwi Starfruit 221 ml (`7506267905148`)",
        "",
        "### Equilibrio",
        "- Ideliver Pro 30 mg C/7 (`7502009745485`)",
        "- Alphalock tamsulosina 0.4 mg C/20 (`7502209858206`)",
        "- Trociletas cereza C/10 (`7501547522220`)",
        "- Sin EAN aún (SKU EQ-*): Rosel Ped, Delaphil 20, Tamsulosina beadvance C/30,",
        "  Ácido alendrónico 70, Vivradoxil, Zensif IM, Esgaro, Trociletas cereza C/12",
        "",
        "## Notas",
        "",
        "- Farma Mayoreo: P.U. ya con IVA; suma renglones = total.",
        "- Equilibrio: costo = P.U. neto post-descuento; lote de fábrica sí; MMAA de la caja.",
        "- IFC: misma Pomada Manzana `FC-MER-MANZANA` que el ticket 122576.",
        "- Ticket Equilibrio «BI0064» = clave **BIO064** Cloxan solución.",
        "- Madrid Aceite/Acetona: no se inventa el tipo (mismo criterio que almendras 305016).",
        "- Regenerar: `python3 scripts/generar_carga_tickets_20260928.py`",
        "",
    ]
    path = OUT_DIR / "LEERME_tickets_20260928.md"
    path.write_text("\n".join(lines), encoding="utf-8")
    return path


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    GEN_DIR.mkdir(parents=True, exist_ok=True)
    for t in TICKETS:
        rows = t["rows"]
        suma = sum(r["sub"] for r in rows)
        piezas = sum(r["qty"] for r in rows)
        assert abs(suma - t["total"]) < 0.05, (t["key"], suma, t["total"])
        for r in rows:
            assert abs(r["pu"] * r["qty"] - r["sub"]) < 0.05, r
            assert "BLOQ" not in r["nombre"] and "JBN" not in r["nombre"], r["nombre"]
            assert not (r["nombre"].isupper() and len(r["nombre"]) > 12), r["nombre"]

        import csv as csvmod

        csv_path = GEN_DIR / f"ticket_{t['key']}.csv"
        with csv_path.open("w", newline="", encoding="utf-8") as fh:
            w = csvmod.writer(fh)
            w.writerow([
                "linea", "folio", "fecha", "proveedor", "ean",
                "descripcion_ticket", "nombre_mostrador", "cantidad",
                "precio_unitario", "subtotal", "lote", "caducidad",
                "sku_farmacapital", "total_ticket", "match",
            ])
            for i, r in enumerate(rows, start=1):
                w.writerow([
                    i, t["folio"], t["fecha"], t["proveedor"], r["ean"],
                    r["snap"], r["nombre"], r["qty"],
                    f"{r['pu']:.2f}", f"{r['sub']:.2f}",
                    r.get("lote") or "", "",
                    r["sku"], f"{t['total']:.2f}", r["match"],
                ])

        sql_path = write_carga_sql(t)
        print(report(rows, t["total"]))
        print(f"  piezas={piezas} csv={csv_path.name} sql={sql_path.name}")
        print(f"  altas={sum(1 for r in rows if not r['ya'])} ya={sum(1 for r in rows if r['ya'])}")
        for r in rows:
            foto = "foto" if r["foto"] else "SIN FOTO"
            ean = r["ean"] or "(sin EAN)"
            print(f"    {ean}  {r['qty']}×{r['pu']:.2f}  {'ya' if r['ya'] else 'ALTA'}  {foto}  {r['nombre']}")

    leerme = write_leerme()
    print(f"leerme={leerme}")


if __name__ == "__main__":
    main()
