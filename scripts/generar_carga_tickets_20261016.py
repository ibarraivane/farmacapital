#!/usr/bin/env python3
"""Tickets 16-oct-2026 (fotos térmicas) → altas + cola Recibir.

4 pedidos:
  La Hacienda Pets 143865 · El Surtidor 146002
  Equilibrio 448303 · Bodega F-42 86064

Nombres de mostrador desde ficha cuando hay página con el EAN.
El código del ticket no se usa como nombre.
Sin caducidad inventada (MMAA de la caja). Equilibrio sí trae lote de fábrica.
Kannes Delta: el ticket no trae código de barras.
"""
from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_carga_tickets_20260915 import (  # noqa: E402
    ceil_pvp,
    foto_url,
    sku_de,
    write_carga_sql,
)
from generar_recepcion_borrador import report, write_ticket_csv  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "sql"
GEN_DIR = ROOT / "sql" / "generated"

# Instante del ticket 143865 (16:47:01 CDMX = 22:47:01 UTC). Sin EAN no hay
# últimos 8 dígitos; el SKU queda fijo para que el SQL sea idempotente.
SKU_KANNES = "FC-1792190821000"


def p(
    ean: str | None,
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
        "ean": ean,
        "sku": sku or (sku_de(ean) if ean else SKU_KANNES),
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
    # ── La Hacienda Pets ──
    "KANNES": p(
        None,
        sku=SKU_KANNES,
        nombre="Kannes Delta shampoo",
        categoria="Mascotas",
        subcategoria="Antiparasitario",
        forma="Shampoo",
        marca="Kannes",
        laboratorio="Pet's Pharma",
        presentacion="250 ml",
        principio="Deltametrina",
        concentracion="0.058%",
        foto_file="kannes-delta-shampoo-250ml.png",
    ),
    # ── Surtidor ──
    "7501677620056": p(
        "7501677620056",
        sku="FC-77620056",
        nombre="Agua destilada La Flor",
        categoria="Botiquín",
        subcategoria="Agua destilada",
        forma="Solución",
        marca="La Flor",
        presentacion="1 L",
        ya=True,
    ),
    "7501034605115": p(
        "7501034605115",
        nombre="Jardianz empagliflozina 25 mg",
        categoria="Medicamentos",
        subcategoria="Diabetes",
        forma="Tabletas",
        marca="Jardianz",
        laboratorio="Boehringer Ingelheim",
        presentacion="Caja con 30 tabletas",
        principio="Empagliflozina",
        concentracion="25 mg",
        receta=True,
        foto_file="jardianz-25mg-c30-7501034605115.jpg",
    ),
    # ── Equilibrio ──
    "7501384541163": p(
        "7501384541163",
        sku="EQ-ALP0608",
        nombre="Carbamazepina Alpharma 200 mg",
        tipo="generico",
        categoria="Medicamentos",
        subcategoria="Anticonvulsivo",
        forma="Tabletas",
        marca="Alpharma",
        laboratorio="Alpharma",
        presentacion="Caja con 20 tabletas",
        principio="Carbamazepina",
        concentracion="200 mg",
        receta=True,
        ya=True,
    ),
    # ── Bodega F-42 ──
    "7501032938215": p(
        "7501032938215",
        nombre="Glade aerosol Campos de lavanda",
        categoria="Hogar",
        subcategoria="Aromatizante",
        forma="Aerosol",
        marca="Glade",
        laboratorio="SC Johnson",
        presentacion="400 ml",
        foto_file="glade-campos-lavanda-400ml-7501032938215.jpg",
    ),
    "7501032907075": p(
        "7501032907075",
        nombre="Glade aerosol Fresh Lemon",
        categoria="Hogar",
        subcategoria="Aromatizante",
        forma="Aerosol",
        marca="Glade",
        laboratorio="SC Johnson",
        presentacion="400 ml",
        foto_file="glade-fresh-lemon-400ml-7501032907075.jpg",
    ),
    "7501014501406": p(
        "7501014501406",
        nombre="BIC Flex 5 Titanium",
        subcategoria="Afeitado",
        forma="Rastrillo",
        marca="BIC",
        presentacion="Blíster con 2 rastrillos",
    ),
    "070330736580": p(
        "070330736580",
        nombre="BIC Flex 3",
        subcategoria="Afeitado",
        forma="Rastrillo",
        marca="BIC",
        presentacion="Blíster con 2 rastrillos",
    ),
    "7503005405168": p(
        "7503005405168",
        sku="FC-05405168",
        nombre="Estropajo Saluk Fashion F-Clean clásica",
        categoria="Higiene",
        subcategoria="Limpieza",
        forma="Estropajo",
        marca="Saluk Fashion",
        laboratorio="Lidernova",
        presentacion="1 pieza",
        ya=True,
        foto_file="estropajo-fclean-clasica-7503005405168.jpg",
    ),
    "7500435250689": p(
        "7500435250689",
        nombre="Secret spray Cherry Blossom",
        subcategoria="Desodorante",
        forma="Spray",
        marca="Secret",
        laboratorio="Procter & Gamble",
        presentacion="150 ml",
    ),
    "7500435259187": p(
        "7500435259187",
        nombre="Secret spray Berry",
        subcategoria="Desodorante",
        forma="Spray",
        marca="Secret",
        laboratorio="Procter & Gamble",
        presentacion="150 ml",
    ),
    "7500435180665": p(
        "7500435180665",
        nombre="Secret aerosol Orange Blossom",
        subcategoria="Desodorante",
        forma="Aerosol",
        marca="Secret",
        laboratorio="Procter & Gamble",
        presentacion="93 g",
    ),
    "037836051562": p(
        "037836051562",
        nombre="Grisi jabón líquido algas rojas",
        subcategoria="Baño",
        forma="Jabón líquido",
        marca="Grisi",
        presentacion="450 ml",
    ),
    "037836051227": p(
        "037836051227",
        nombre="Grisi jabón líquido concha nácar",
        subcategoria="Baño",
        forma="Jabón líquido",
        marca="Grisi",
        presentacion="450 ml",
        foto_file="grisi-concha-nacar-liq-450ml.jpg",
    ),
    "7506306251847": p(
        "7506306251847",
        nombre="Axe Black Remixed",
        subcategoria="Desodorante",
        forma="Aerosol",
        marca="Axe",
        laboratorio="Unilever",
        presentacion="210 ml",
        foto_file="axe-black-remixed-210ml-7506306251847.jpg",
    ),
    "7506306250604": p(
        "7506306250604",
        nombre="Axe Dark Temptation",
        subcategoria="Desodorante",
        forma="Aerosol",
        marca="Axe",
        laboratorio="Unilever",
        presentacion="210 ml",
    ),
    "850040940046": p(
        "850040940046",
        nombre="Ricitos de Oro shampoo y gel lavanda y lechuga",
        subcategoria="Cabello",
        forma="Shampoo",
        marca="Ricitos de Oro",
        laboratorio="Grisi",
        presentacion="500 ml",
    ),
    "7501165009486": p(
        "7501165009486",
        sku="FC-65009486",
        nombre="Lactacyd Pro-Bio shampoo íntimo",
        subcategoria="Higiene íntima",
        forma="Shampoo",
        marca="Lactacyd",
        laboratorio="Sanofi",
        presentacion="200 ml",
        ya=True,
    ),
    "7502245720208": p(
        "7502245720208",
        nombre="Silkhair quitaesmalte manzana",
        subcategoria="Uñas",
        forma="Líquido",
        marca="Silkhair",
        presentacion="100 ml",
    ),
    "7502245720574": p(
        "7502245720574",
        nombre="Silkhair quitaesmalte uva",
        subcategoria="Uñas",
        forma="Líquido",
        marca="Silkhair",
        presentacion="100 ml",
    ),
    "7502245720567": p(
        "7502245720567",
        nombre="Silkhair quitaesmalte coco",
        subcategoria="Uñas",
        forma="Líquido",
        marca="Silkhair",
        presentacion="100 ml",
    ),
    "7501001169091": p(
        "7501001169091",
        nombre="Pantene Pro-V rizos definidos",
        subcategoria="Cabello",
        forma="Shampoo",
        marca="Pantene",
        laboratorio="Procter & Gamble",
        presentacion="200 ml",
    ),
    "7500435142564": p(
        "7500435142564",
        nombre="Head & Shoulders hidratación aceite de coco",
        subcategoria="Cabello",
        forma="Shampoo",
        marca="Head & Shoulders",
        laboratorio="Procter & Gamble",
        presentacion="180 ml",
        foto_file="hs-hidratacion-coco-180ml-7500435142564.jpg",
    ),
    "7500435258425": p(
        "7500435258425",
        nombre="Head & Shoulders anticaída romero",
        subcategoria="Cabello",
        forma="Shampoo",
        marca="Head & Shoulders",
        laboratorio="Procter & Gamble",
        presentacion="90 ml",
    ),
    "7500435257084": p(
        "7500435257084",
        nombre="Head & Shoulders anti comezón menta",
        subcategoria="Cabello",
        forma="Shampoo",
        marca="Head & Shoulders",
        laboratorio="Procter & Gamble",
        presentacion="90 ml",
    ),
    "7501943490994": p(
        "7501943490994",
        nombre="Kotex Slim con alas",
        subcategoria="Protección femenina",
        forma="Toalla sanitaria",
        marca="Kotex",
        presentacion="10 toallas",
        foto_file="kotex-ultradelgada-alas-10-7501943490994.jpg",
    ),
    "7501019030611": p(
        "7501019030611",
        nombre="Saba confort manzanilla delgada",
        subcategoria="Protección femenina",
        forma="Toalla sanitaria",
        marca="Saba",
        presentacion="10 toallas",
        foto_file="saba-confort-manzanilla-10-7501019030611.jpg",
    ),
    "7501103306691": p(
        "7501103306691",
        nombre="T.Taio esponja Bathtime suave animal",
        subcategoria="Baño",
        forma="Esponja",
        marca="T.Taio",
        presentacion="1 pieza",
    ),
    "793969378180": p(
        "793969378180",
        nombre="Esponja redonda",
        categoria="Higiene",
        subcategoria="Baño",
        forma="Esponja",
        presentacion="Blíster 1 pieza",
    ),
    "7501027551047": p(
        "7501027551047",
        nombre="Evenflo escobillón Basic",
        categoria="Bebé",
        subcategoria="Biberón",
        forma="Cepillo",
        marca="Evenflo",
        presentacion="1 pieza",
    ),
    "7500435140591": p(
        "7500435140591",
        nombre="Gillette gel aloe",
        subcategoria="Desodorante",
        forma="Gel",
        marca="Gillette",
        laboratorio="Procter & Gamble",
        presentacion="82 g",
    ),
    "7506309862057": p(
        "7506309862057",
        nombre="Gillette Sport Triumph gel",
        subcategoria="Desodorante",
        forma="Gel",
        marca="Gillette",
        laboratorio="Procter & Gamble",
        presentacion="82 g",
    ),
    "7500435129947": p(
        "7500435129947",
        nombre="Gillette Cool Wave",
        subcategoria="Desodorante",
        forma="Barra",
        marca="Gillette",
        laboratorio="Procter & Gamble",
        presentacion="45 g",
    ),
    "7702018913664": p(
        "7702018913664",
        nombre="Gillette Clear Cool Wave gel",
        subcategoria="Desodorante",
        forma="Gel",
        marca="Gillette",
        laboratorio="Procter & Gamble",
        presentacion="82 g",
        foto_file="gillette-clear-cool-wave-gel-82g-7702018913664.jpg",
    ),
    "7506195160466": p(
        "7506195160466",
        nombre="Pantene Pro-V cuidado clásico 2 en 1",
        subcategoria="Cabello",
        forma="Shampoo",
        marca="Pantene",
        laboratorio="Procter & Gamble",
        presentacion="100 ml",
    ),
    "7506195148686": p(
        "7506195148686",
        nombre="Head & Shoulders limpieza renovadora",
        subcategoria="Cabello",
        forma="Shampoo",
        marca="Head & Shoulders",
        laboratorio="Procter & Gamble",
        presentacion="90 ml",
        foto_file="hs-limpieza-renovadora-90ml-7506195148686.jpg",
    ),
}


def row(key: str, snap: str, qty: int, pu: float, lote: str | None = None) -> dict:
    prod = PRODUCTOS[key]
    sub = round(qty * pu, 2)
    return {
        "ean": prod["ean"],
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
        "key": "hacienda_143865",
        "tmp": "_fc_hda_143865",
        "folio": "143865",
        "proveedor": "La Hacienda Pets",
        "proveedor_ilike": "hacienda",
        "fecha": "2026-10-16",
        "total": 290.00,
        "notas": (
            "Ticket Bodega G-71 La Hacienda Pets 143865 · 16-oct-2026 16:47 · "
            "efectivo $290.00 · sello PAGADO · cola Recibir. "
            "El papel no trae código: toca el renglón gris y pon MMAA de la botella. "
            "Cuando leas el código de la etiqueta, anótalo en la ficha."
        ),
        "header": (
            "La Hacienda Pets · Bodega G-71 · ticket 143865 · 2026-10-16 16:47\n"
            "-- 1 renglón / 2 piezas. Efectivo $290.00. Cambio $0.\n"
            "-- Ficha Pet's Pharma: shampoo insecticida deltametrina 0.058%, 250 ml.\n"
            "-- Sin EAN en el ticket. SKU FC-1792190821000 (instante del ticket).\n"
            "-- Sin lote ni caducidad. No inventar 0000."
        ),
        "rows": [
            row("KANNES", "FAR SHAMPOO KANNES DELTA 250ML", 2, 145.00),
        ],
    },
    {
        "key": "surtidor_146002",
        "tmp": "_fc_sur_146002",
        "folio": "146002",
        "proveedor": "El Surtidor",
        "proveedor_ilike": "surtidor",
        "fecha": "2026-10-16",
        "total": 1276.88,
        "notas": (
            "Ticket El Surtidor venta 146002 · caja 1 · 16-oct-2026 16:49 · "
            "bodega F48 Central de Abasto · sello PAGADO · "
            "costo = total neto del renglón (ya con descuento) · "
            "cola Recibir; stock al confirmar pistola + MMAA"
        ),
        "header": (
            "El Surtidor de su Farmacia · venta 146002 · 2026-10-16 16:49 · MAESTRO F48\n"
            "-- Agua destilada: 15 × $19.00 = $285.01 en el papel (1 centavo de redondeo).\n"
            "-- Jardianz: lista $2,717.46 − descuento $1,725.59 = neto $991.87 (63.5%).\n"
            "-- Costo = total del renglón ÷ piezas, no el precio de lista.\n"
            "-- Total ticket $1,276.88. Sin lote ni caducidad. No inventar 0000."
        ),
        "rows": [
            row("7501677620056", "AGUA DESTILADA LA FLOR 1 LT", 15, 19.00),
            row("7501034605115", "JARDIANZ TAB 25MG C/30 EMPAGLIFOZINA", 1, 991.87),
        ],
    },
    {
        "key": "equilibrio_448303",
        "tmp": "_fc_eq_448303",
        "folio": "448303",
        "proveedor": "Equilibrio",
        "proveedor_ilike": "equilibrio",
        "fecha": "2026-10-16",
        "total": 181.10,
        "notas": (
            "Ticket Equilibrio 448303 · pedido online · sucursal Iztapalapa 2 · "
            "16-oct-2026 17:08 · cliente Luis Angel Palillero Ventura · "
            "lote de fábrica 7230526 · caducidad del papel 31/05/2029 no se guarda "
            "(MMAA de la caja) · cola Recibir"
        ),
        "header": (
            "Equilibrio Farmacéutico · ticket 448303 · 2026-10-16 17:08 · Iztapalapa 2\n"
            "-- Pedido online. Clave ALPO608 = ALP0608 Alpharma EAN 7501384541163.\n"
            "-- 10 cajas × P.U. neto $18.11 = $181.10. Ahorro de lista $718.90.\n"
            "-- Lote de fábrica 7230526 sí. Caducidad NO: el papel dice 31/05/2029; "
            "MMAA se captura de la caja. 0000 inválido."
        ),
        "rows": [
            row(
                "7501384541163",
                "ALPO608 CARBAMAZEPINA 20 TAB 200 MG",
                10,
                18.11,
                "7230526",
            ),
        ],
    },
    {
        "key": "bodega_f42_86064",
        "tmp": "_fc_bf42_86064",
        "folio": "86064",
        "proveedor": "Bodega F-42",
        "proveedor_ilike": "f-42",
        "fecha": "2026-10-16",
        "total": 1812.74,
        "notas": (
            "Ticket Bodega F-42 Caja 3/86064 · 16-oct-2026 17:24 · "
            "tarjeta de crédito $1,812.74 · costo = P.U. del renglón a 2 decimales · "
            "cola Recibir; stock al confirmar pistola + MMAA"
        ),
        "header": (
            "Bodega F-42 Ejidos del Moral · Caja 3/86064 · 2026-10-16 17:24\n"
            "-- 32 renglones. Total en letra: mil ochocientos doce pesos 74/100.\n"
            "-- Costo = P.U. impreso redondeado a 2 decimales (el papel trae 3).\n"
            "-- La suma de importes de renglón es el total pagado. No se vuelve a sumar IVA.\n"
            "-- Sin lote ni caducidad. No inventar 0000.\n"
            "-- Esponja redonda 793969378180: el ticket no dice marca."
        ),
        "rows": [
            row("7501032938215", "GLADE 400ML SPY AROM CAMPOS LAVAND", 1, 62.16),
            row("7501032907075", "GLADE 400ML SPY AROM FRESH LEMON", 1, 54.84),
            row("7501014501406", "BIC FLEX5 TITANIUM BL C/2 OFERTA 15%", 1, 79.05),
            row("070330736580", "BIC FLEX 3 BL C/2 OFERTA 15%", 2, 51.85),
            row("7503005405168", "ESTROPAJO F-CLEAN CLASICA SAL C/1", 3, 12.31),
            row("7500435250689", "DEO SECRET 150ML SPY CHERRY BLOSSOM", 1, 57.51),
            row("7500435259187", "DESOD SECRET 150ML SPY BERRY", 1, 57.52),
            row("7500435180665", "DEO SECRET AERO ANT ORANGE", 1, 56.24),
            row("037836051562", "JBN LIQ GRISI CORP ALGA ROJA 450ML", 1, 53.74),
            row("037836051227", "JBN LIQ GRISI CONCHA NACAR 450ML", 1, 53.74),
            row("7506306251847", "DESOD AXE BLACK REMIX SPY 210 ML", 1, 68.73),
            row("7506306250604", "DESOD AXE MEN DARK TEM SPY 210ML", 2, 68.73),
            row("850040940046", "SH Y GEL RICITOS DE ORO LAV Y LECH 500ML C 12", 1, 70.66),
            row("7501165009486", "LACTACYD PRO-BIO FEMINA 200ML SH", 1, 72.37),
            row("7502245720208", "SILKHAIR QUITA ESMALTE MANZANA 100ML", 1, 17.20),
            row("7502245720574", "SILKHAIR QUITA ESMALTE UVA 100ML", 1, 17.20),
            row("7502245720567", "SILKHAIR QUITA ESMALTE COCO 100 ML", 1, 17.20),
            row("7501001169091", "SH PANTENE PRO-V RIZOS DEFI 200ML", 2, 37.80),
            row("7500435142564", "SH H&S HIDRATACION AC COCO 180ML", 2, 36.55),
            row("7500435258425", "SH H&S 90ML ROMERO ANTI CAIDA C24", 2, 17.05),
            row("7500435257084", "SH H&S 90ML ANTI COMEZON", 2, 17.05),
            row("7501943490994", "TAS SANIT KOTEX ULTRADELG ALAS 10", 1, 15.90),
            row("7501019030611", "TAS SANIT SABA CONF MZLLA DELG 10", 1, 18.47),
            row("7501103306691", "ESPONJA T.TAIO BATHTIME SVE ANIMAL", 1, 15.16),
            row("793969378180", "ESPONJA REDONDA BLISTER", 1, 12.74),
            row("7501027551047", "ESCOBILLON BASIC EVENFLO", 2, 33.70),
            row("7500435140591", "DESOD GTTE HYDR-GEL ALOE STICK 82G", 1, 69.58),
            row("7506309862057", "DESOD GTTE SPORT TRIUMPH GEL 82G", 1, 70.40),
            row("7500435129947", "DESOD GTTE COOLWAVE STICK 45G", 2, 50.65),
            row("7702018913664", "DESOD GTTE 3XAP CL COOL-W GEL 82G", 2, 65.23),
            row("7506195160466", "SH. PANTENE CUIDADO CLASICO 2EN1 100ML", 3, 15.93),
            row("7506195148686", "SH H&S LIMP RENOV 90ML", 2, 15.19),
        ],
    },
]


def relax_kannes_ean(path: Path) -> None:
    """El ticket no trae EAN: la columna temporal acepta null y no se inventa código."""
    text = path.read_text(encoding="utf-8")
    text = text.replace("ean text not null,", "ean text,", 1)
    path.write_text(text, encoding="utf-8")


def main() -> None:
    GEN_DIR.mkdir(parents=True, exist_ok=True)
    paths: list[Path] = []
    resumen: list[tuple[str, str, int, float]] = []
    for t in TICKETS:
        for r in t["rows"]:
            r["sub"] = round(r["qty"] * r["pu"], 2)
            r["precio"] = ceil_pvp(r["pu"], r["tipo"])
        suma = round(sum(r["sub"] for r in t["rows"]), 2)
        pzas = sum(r["qty"] for r in t["rows"])
        # Surtidor: el papel cierra $1,276.88 y 15×19.00+991.87 = $1,276.87.
        # F-42: el P.U. de 3 decimales, guardado a 2, mueve centavos.
        if abs(suma - t["total"]) > 0.15:
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
        if t["key"] == "hacienda_143865":
            relax_kannes_ean(sql_path)
        paths.append(sql_path)
        resumen.append((t["proveedor"], sql_path.name, pzas, t["total"]))
        print(f"{t['folio']}: {report(t['rows'], t['total'])}  suma_sql={suma:.2f}")
        print(f"  → {csv_path.relative_to(ROOT)}")
        print(f"  → {sql_path.name}")

    todos = OUT_DIR / "patch_carga_tickets_20261016_TODOS.sql"
    parts = [
        "-- ═══════════════════════════════════════════════════════════════",
        "-- TICKETS 16-OCT-2026 · PEGAR EN SUPABASE (uno por uno o todo)",
        "-- Ver LEERME_tickets_20261016.md",
        "-- ═══════════════════════════════════════════════════════════════",
        "",
    ]
    for path in paths:
        parts.append("\n-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        parts.append(f"-- INICIO: {path.name}")
        parts.append("-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        parts.append(path.read_text(encoding="utf-8").rstrip() + "\n")
    todos.write_text("\n".join(parts), encoding="utf-8")

    filas = "\n".join(
        f"| {prov} | `{name}` | {pzas} | ${total:,.2f} |"
        for prov, name, pzas, total in resumen
    )
    (OUT_DIR / "LEERME_tickets_20261016.md").write_text(
        f"""# Tickets Recibir · 16-oct-2026

Fotos La Hacienda Pets + El Surtidor + Equilibrio + Bodega F-42. Pegar **cada** SQL en Supabase → SQL Editor → Run.

| Pedido | Archivo | Piezas | Total |
|--------|---------|--------|-------|
{filas}

## Todo-en-uno

`patch_carga_tickets_20261016_TODOS.sql`

## Notas

- Equilibrio 448303 trae **lote 7230526**. El papel dice caducidad 31/05/2029; no se guarda. MMAA de la caja. Clave ALPO608 = Alpharma `7501384541163`.
- Surtidor: costo = total neto del renglón. Jardianz queda en $991.87, no en la lista de $2,717.46. El agua cierra $285.01 en el papel y $285.00 en el SQL (15 × $19.00).
- La Hacienda Pets no trae código. En Recibir se toca el renglón gris. El EAN de la botella se anota después en la ficha.
- Bodega F-42: costo = P.U. a 2 decimales. El total pagado con tarjeta es $1,812.74. La suma de renglones a 2 decimales queda en $1,812.73 (el papel trae milésimas).
- Ricitos de Oro: el renglón dice «C 12» y la cantidad impresa es 1 pieza de 500 ml.
- Precio de alta = recargo sobre ese costo (marca +25%, genérico +60%). Si el producto ya tenía precio, no se pisa.
- Foto pendiente (el alta queda sin imagen hasta conseguir packshot): BIC Flex 5, BIC Flex 3, Secret Cherry Blossom, Secret Berry, Secret Orange Blossom, Grisi algas rojas, Axe Dark Temptation, Ricitos de Oro lavanda y lechuga, Lactacyd Pro-Bio, Silkhair manzana / uva / coco, Pantene rizos definidos 200 ml, Head & Shoulders romero, Head & Shoulders anti comezón, T.Taio Bathtime, esponja redonda, Evenflo Basic, Gillette gel aloe, Gillette Sport Triumph, Gillette Cool Wave 45 g, Pantene cuidado clásico 2 en 1 100 ml, agua destilada La Flor.
- Regenerar: `python3 scripts/generar_carga_tickets_20261016.py`
""",
        encoding="utf-8",
    )
    print(f"  → {todos.name}")


if __name__ == "__main__":
    main()
