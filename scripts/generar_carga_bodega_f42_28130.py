#!/usr/bin/env python3
"""Bodega F-42 Caja 4/28130 · 24-oct-2026 → altas + cola Recibir.

Ticket térmico Ejidos del Moral. Total tarjeta $5,282.50
(subtotal $4,553.92 + impuestos $728.58; los P.U. del ticket ya incluyen IVA
y la suma de subtotales de renglón = total).

Nombres de mostrador (no el código abreviado del ticket).
Sin caducidad inventada (MMAA de la caja). Sin fotos: TODO packshot.
"""
from __future__ import annotations

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_recepcion_borrador import report, write_ticket_csv  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "sql"
GEN_DIR = ROOT / "sql" / "generated"

FOLIO = "28130"
FECHA = "2026-10-24"
PROVEEDOR = "Bodega F-42"
TOTAL = 5282.50
TMP = "_fc_bf42_28130"


def ceil_pvp(costo: float, tipo: str) -> int:
    factor = 1.25 if tipo == "marca" else 1.6
    return int(math.ceil(costo * factor))


def sku_de(ean: str) -> str:
    digits = "".join(c for c in ean if c.isdigit())
    return "FC-" + digits[-8:]


def sql_str(s: str | None) -> str:
    if s is None:
        return "null"
    return "'" + str(s).replace("'", "''") + "'"


# (ean, snap_ticket, qty, pu, sub, nombre, marca, presentacion, forma, subcat, ya)
# costo = round(pu, 2); PVP = +25% marca (cuidado personal)
RAW = [
    ("7506078972292", "DESOD OBAO PIEL DEL SPY 150ML", 1, 43.410, 43.41,
     "Obao Piel Delicada spray 150 ml", "Obao", "Spray 150 ml", "Spray", "Desodorante", False),
    ("7509552909814", "DESOD OBAO RSA TEN 48H SPY 150ML", 1, 43.410, 43.41,
     "Obao Rosa Tentación 48h spray 150 ml", "Obao", "Spray 150 ml", "Spray", "Desodorante", False),
    ("7506306226722", "DESOD AXE MEN YOUNG SPY 150ML", 2, 45.830, 91.66,
     "Axe Men Young spray 150 ml", "Axe", "Spray 150 ml", "Spray", "Desodorante", True),
    ("7509552844795", "DESOD OBAO R-NAT COCO SPY 150ML", 1, 42.410, 42.41,
     "Obao Ritual Natural Coco spray 150 ml", "Obao", "Spray 150 ml", "Spray", "Desodorante", False),
    ("7506306226739", "DESOD AXE MEN CONVICT SPY 150ML", 1, 45.830, 45.83,
     "Axe Men Conviction spray 150 ml", "Axe", "Spray 150 ml", "Spray", "Desodorante", True),
    ("7506306213081", "DESOD AXE MUSIC FRES 48H SPY150ML", 2, 45.830, 91.66,
     "Axe Music Fresh 48h spray 150 ml", "Axe", "Spray 150 ml", "Spray", "Desodorante", False),
    ("75062804", "DESOD REXONA ANTIB+ACLA R-ON 50ML", 1, 33.740, 33.74,
     "Rexona Antibacterial + Aclarante roll-on 50 ml", "Rexona", "Roll-on 50 ml", "Roll-on", "Desodorante", False),
    ("7506306245686", "DESOD AXE MEN EPIC-F 48H SPY 150ML", 2, 45.830, 91.66,
     "Axe Men Epic Fresh 48h spray 150 ml", "Axe", "Spray 150 ml", "Spray", "Desodorante", True),
    ("7501868920163", "DIBAR GEL 500ML ANTIBAC", 2, 35.240, 70.48,
     "Dibar gel antibacterial 500 ml", "Dibar", "Frasco 500 ml", "Gel", "Antibacterial", False),
    ("75085513", "DESOD REXONA 41G BARRA MEN INVIS BALM MLCTN &PEONIA", 2, 55.680, 111.36,
     "Rexona Men Invisible Balm Milk & Peonia barra 41 g", "Rexona", "Barra 41 g", "Barra", "Desodorante", False),
    ("7506306244795", "DESOD AXE INTENSE 48H SPY 150ML", 1, 45.830, 45.83,
     "Axe Intense 48h spray 150 ml", "Axe", "Spray 150 ml", "Spray", "Desodorante", True),
    ("75081669", "DEO ROLL ON REXONA POW 50ML", 1, 30.130, 30.13,
     "Rexona Powder Dry roll-on 50 ml", "Rexona", "Roll-on 50 ml", "Roll-on", "Desodorante", False),
    ("7506376000284", "AGUA MIC VITACILINA ROS-SAB 500MLN", 1, 81.470, 81.47,
     "Vitacilina agua micelar rosa-sábila 500 ml", "Vitacilina", "Frasco 500 ml", "Líquido", "Limpieza facial", True),
    ("7506078928565", "DESMAQ L'OREAL 200ML BIFASICO", 1, 118.130, 118.13,
     "L'Oréal desmaquillante bifásico 200 ml", "L'Oréal", "Frasco 200 ml", "Líquido", "Desmaquillante", False),
    ("75075996", "DESOD REXON HAPPY MOR 48H R-ON 50ML", 1, 34.790, 34.79,
     "Rexona Happy Morning 48h roll-on 50 ml", "Rexona", "Roll-on 50 ml", "Roll-on", "Desodorante", False),
    ("78924345", "DESOD REXONA WOM BAMBOO R-ON 50ML", 1, 30.130, 30.13,
     "Rexona Women Bamboo roll-on 50 ml", "Rexona", "Roll-on 50 ml", "Roll-on", "Desodorante", False),
    ("7502254073821", "DESINFEC ANTIB GLESOL FRESH 443ML", 2, 68.195, 136.39,
     "Glesol Fresh desinfectante antibacterial 443 ml", "Glesol", "Frasco 443 ml", "Líquido", "Desinfectante", False),
    ("759684154140", "JALOMA 120ML GEL ANTIBACTERIAL", 3, 18.183, 54.55,
     "Jaloma gel antibacterial 120 ml", "Jaloma", "Frasco 120 ml", "Gel", "Antibacterial", False),
    ("037836051555", "JBN LIQ GRISI P MANO NEUTRO 480 ML", 1, 45.980, 45.98,
     "Grisi jabón líquido para manos neutro 480 ml", "Grisi", "Frasco 480 ml", "Líquido", "Higiene de manos", False),
    ("7501022151198", "JBN LIQ GRISI P-MANO FRESIA 480ML", 1, 45.980, 45.98,
     "Grisi jabón líquido para manos fresia 480 ml", "Grisi", "Frasco 480 ml", "Líquido", "Higiene de manos", False),
    ("7501082731064", "DESOD NUVEL SOFTY WOM SPY 170 ML", 2, 32.725, 65.45,
     "Nuvel Soft Woman spray 170 ml", "Nuvel", "Spray 170 ml", "Spray", "Desodorante", False),
    ("7501082731071", "DESOD NUVEL TROPIC WOM SPY 170 ML", 2, 32.725, 65.45,
     "Nuvel Tropic Woman spray 170 ml", "Nuvel", "Spray 170 ml", "Spray", "Desodorante", False),
    ("7500435107389", "DESOD OLD SPICE BEAR GLOV SPY 150ML", 2, 59.450, 118.90,
     "Old Spice Bearglove spray 150 ml", "Old Spice", "Spray 150 ml", "Spray", "Desodorante", False),
    ("7500435257008", "DESOD OLD SPICE 150ML SPY PARADISE", 2, 59.475, 118.95,
     "Old Spice Paradise spray 150 ml", "Old Spice", "Spray 150 ml", "Spray", "Desodorante", False),
    ("7506309839141", "DESOD OLD SPICE WOLF ANTI SPY 150ML", 2, 56.235, 112.47,
     "Old Spice Wolfthorn Anti spray 150 ml", "Old Spice", "Spray 150 ml", "Spray", "Desodorante", False),
    ("7506339349146", "DESOD OLD SPICE WOLFTHORN SPY 150ML", 2, 59.845, 119.69,
     "Old Spice Wolfthorn spray 150 ml", "Old Spice", "Spray 150 ml", "Spray", "Desodorante", False),
    ("7501082731057", "DESOD NUVEL FUSION MEN SPY 160ML", 1, 32.720, 32.72,
     "Nuvel Fusion Men spray 160 ml", "Nuvel", "Spray 160 ml", "Spray", "Desodorante", False),
    ("75085537", "DESOD REXONA 41G BARRA MEN INVIS BALM MINT FRESH", 2, 55.680, 111.36,
     "Rexona Men Invisible Balm Mint Fresh barra 41 g", "Rexona", "Barra 41 g", "Barra", "Desodorante", False),
    ("75085520", "DESOD REXONA 41G BARRA MEN INVIS BALM OCEAN FRESH", 2, 55.680, 111.36,
     "Rexona Men Invisible Balm Ocean Fresh barra 41 g", "Rexona", "Barra 41 g", "Barra", "Desodorante", False),
    ("7501082731040", "DEO NUVEL SPY 170ML MEN DEVOTION", 1, 32.720, 32.72,
     "Nuvel Devotion Men spray 170 ml", "Nuvel", "Spray 170 ml", "Spray", "Desodorante", False),
    ("7501082736021", "DEO NUVEL ACLA WOM SPY150ML", 2, 35.450, 70.90,
     "Nuvel Aclarante Woman spray 150 ml", "Nuvel", "Spray 150 ml", "Spray", "Desodorante", False),
    ("7791293036052", "DESOD REXONA WOM FLORESB SPY150ML", 2, 54.680, 109.36,
     "Rexona Women Flores Blancas spray 150 ml", "Rexona", "Spray 150 ml", "Spray", "Desodorante", False),
    ("7501054504535", "CRA NIVEA B MILK EXTSCA 400 ML", 2, 84.495, 168.99,
     "Nivea Body Milk Extra Seca 400 ml", "Nivea", "Frasco 400 ml", "Crema", "Cuidado corporal", True),
    ("4005900581341", "CRM NIVEA MILK NUTRITIVA PIEL EXTRA SECA 625ML", 2, 113.640, 227.28,
     "Nivea Milk Nutritiva piel extra seca 625 ml", "Nivea", "Frasco 625 ml", "Crema", "Cuidado corporal", False),
    ("7506306202832", "DESOD AXE COLLISION SPY150ML", 1, 45.830, 45.83,
     "Axe Collision spray 150 ml", "Axe", "Spray 150 ml", "Spray", "Desodorante", False),
    ("4005808802836", "CRA NIVEA B SOFMILK SEC400ML", 2, 84.495, 168.99,
     "Nivea Soft Milk seca 400 ml", "Nivea", "Frasco 400 ml", "Crema", "Cuidado corporal", False),
    ("7501082790504", "DESMAQ BIFASICO OIL NUVEL 125ML", 3, 27.747, 83.24,
     "Nuvel desmaquillante bifásico oil 125 ml", "Nuvel", "Frasco 125 ml", "Líquido", "Desmaquillante", True),
    ("810120501673", "CRA HINDS LIQ AGAVE AZUL 400ML", 1, 42.250, 42.25,
     "Hinds Agave Azul crema líquida 400 ml", "Hinds", "Frasco 400 ml", "Crema", "Cuidado corporal", False),
    ("037836041273", "HINDS ROSA 400ML CREMA CORPORAL", 1, 49.970, 49.97,
     "Hinds Rosa crema corporal 400 ml", "Hinds", "Frasco 400 ml", "Crema", "Cuidado corporal", False),
    ("037836041259", "CRA HINDS LIQ RSA RCA 90ML", 2, 18.740, 37.48,
     "Hinds Rosa crema líquida 90 ml", "Hinds", "Frasco 90 ml", "Crema", "Cuidado corporal", True),
    ("7791293036045", "DESOD REXONA WOM POM/TOR SPY150ML", 1, 54.550, 54.55,
     "Rexona Women Pomelo / Toronja spray 150 ml", "Rexona", "Spray 150 ml", "Spray", "Desodorante", False),
    ("7501082790474", "DESMAQ NUVEL OIL-FREE P/MIX 235ML", 1, 43.650, 43.65,
     "Nuvel desmaquillante oil-free piel mixta 235 ml", "Nuvel", "Frasco 235 ml", "Líquido", "Desmaquillante", False),
    ("759684154232", "JALOMA 60ML GEL ANTIBACTERIAL", 3, 13.010, 39.03,
     "Jaloma gel antibacterial 60 ml", "Jaloma", "Frasco 60 ml", "Gel", "Antibacterial", False),
    ("7501022140543", "KIT RICITOS DE ORO LAVANDA C/4PZ", 1, 106.640, 106.64,
     "Ricitos de Oro Lavanda kit C/4", "Ricitos de Oro", "Kit 4 piezas", None, "Cuidado infantil", False),
    ("037836041426", "CRA HINDS HIDR-EXT C/AVENA 400 ML", 1, 49.970, 49.97,
     "Hinds Hidratación Extrema con avena 400 ml", "Hinds", "Frasco 400 ml", "Crema", "Cuidado corporal", False),
    ("7791293032412", "DESOD REXONA WOM SEXY-BOU SPY 150ML", 1, 54.680, 54.68,
     "Rexona Women Sexy Bouquet spray 150 ml", "Rexona", "Spray 150 ml", "Spray", "Desodorante", False),
    ("037836041341", "CRA HINDS LIQ P/RCA 90ML", 2, 18.740, 37.48,
     "Hinds Natural crema líquida piel reseca 90 ml", "Hinds", "Frasco 90 ml", "Crema", "Cuidado corporal", True),
    ("037836041365", "CRA HINDS LIQ NAT RCA 400ML", 1, 49.970, 49.97,
     "Hinds Natural crema líquida piel reseca 400 ml", "Hinds", "Frasco 400 ml", "Crema", "Cuidado corporal", False),
    ("7506306216907", "TCO DESOD EFFICIENT PIES 200G DUO", 1, 120.000, 120.00,
     "Rexona Efficient pies talco dúo 200 g", "Rexona", "Dúo 200 g", "Talco", "Cuidado de pies", False),
    ("7501022188507", "SH RICITOS DE ORO DE LAV Y LECH 400ML C/ CR A CORP 100ML", 1, 77.520, 77.52,
     "Ricitos de Oro Lavanda y Leche shampoo 400 ml + crema 100 ml", "Ricitos de Oro", "Shampoo 400 ml + crema 100 ml", "Shampoo", "Cuidado infantil", False),
    ("7501082790450", "GEL NUVEL LIMPIADOR FAC 235ML", 1, 42.360, 42.36,
     "Nuvel gel limpiador facial 235 ml", "Nuvel", "Frasco 235 ml", "Gel", "Limpieza facial", False),
    ("7791293025810", "DESOD AXE MEN FUSION SPY 150ML", 1, 45.830, 45.83,
     "Axe Men Fusion spray 150 ml", "Axe", "Spray 150 ml", "Spray", "Desodorante", False),
    ("7501082790498", "DESMAQ NUVEL BIFAS ROST/OJO 235ML", 1, 43.650, 43.65,
     "Nuvel desmaquillante bifásico rostro/ojos 235 ml", "Nuvel", "Frasco 235 ml", "Líquido", "Desmaquillante", False),
    ("7791293025797", "DESOD AXE MEN DARK TEMP SPY150ML", 1, 45.830, 45.83,
     "Axe Men Dark Temptation spray 150 ml", "Axe", "Spray 150 ml", "Spray", "Desodorante", True),
    ("7509546052632", "CEP DENT COLGATE TA+C D T ACC 75ML OCT26", 3, 23.897, 71.69,
     "Colgate Total Advanced Clean 75 ml", "Colgate", "Tubo 75 ml", "Crema dental", "Higiene bucal", False),
    ("037836040368", "AGUA COL RICITOS ORO SPY 100 ML", 2, 39.070, 78.14,
     "Ricitos de Oro agua de colonia spray 100 ml", "Ricitos de Oro", "Spray 100 ml", "Spray", "Cuidado infantil", False),
    ("7501082722123", "CRA NUVEL P/MANOS HIDRATADA 65ML", 1, 13.490, 13.49,
     "Nuvel crema para manos hidratada 65 ml", "Nuvel", "Tubo 65 ml", "Crema", "Cuidado de manos", False),
    ("7798140258490", "SH TIO NACHO ULT-HIDRA COCO 415ML", 1, 85.840, 85.84,
     "Tío Nacho Ultra Hidratación Coco shampoo 415 ml", "Tío Nacho", "Frasco 415 ml", "Shampoo", "Cuidado capilar", False),
    ("7506295388487", "C D ORAL-B 3DW BRILLIAN FRES 53ML", 3, 24.610, 73.83,
     "Oral-B 3D White Brilliance Fresh pasta 53 ml", "Oral-B", "Tubo 53 ml", "Crema dental", "Higiene bucal", False),
    ("7791293032429", "DESOD REXONA WOM HAPPY-MO SPY 150ML", 1, 54.680, 54.68,
     "Rexona Women Happy Morning spray 150 ml", "Rexona", "Spray 150 ml", "Spray", "Desodorante", False),
    ("7896009498091", "SENSODYNE PROTEC COMPLET + ACC LIM EFEC 90G HALEON", 1, 72.620, 72.62,
     "Sensodyne Protección Completa limpieza efectiva 90 g", "Sensodyne", "Tubo 90 g", "Crema dental", "Higiene bucal", True),
    ("7896009419324", "CD SENSODYNE ORIGINAL 90G", 1, 72.620, 72.62,
     "Sensodyne Original pasta dental 90 g", "Sensodyne", "Tubo 90 g", "Crema dental", "Higiene bucal", True),
    ("7509546687353", "C D COLGATE MFP CALCI-PROT 90ML", 1, 33.340, 33.34,
     "Colgate Máxima Protección Anticaries Calci-Protect 90 ml", "Colgate", "Tubo 90 ml", "Crema dental", "Higiene bucal", True),
    ("7509546054032", "C D COLGATE LUMINOUS WHITE22", 3, 17.540, 52.62,
     "Colgate Luminous White pasta dental", "Colgate", "Tubo", "Crema dental", "Higiene bucal", False),
    ("7506306257597", "REXONA 100GR TCO PIES EFFICIENT ORIG", 2, 40.240, 80.48,
     "Rexona Efficient Original talco para pies 100 g", "Rexona", "Talco 100 g", "Talco", "Cuidado de pies", True),
    ("7501027280657", "SH KIDS 2EN1 SMOOTHIE MANJA265ML", 1, 77.230, 77.23,
     "Kids 2 en 1 Smoothie Manzana shampoo 265 ml", "Kids", "Frasco 265 ml", "Shampoo", "Cuidado infantil", False),
    ("7506078941755", "SH KIDS 3EN1 EXPLOSION FRAMBU 265ML", 1, 77.000, 77.00,
     "L'Oréal Kids 3 en 1 Explosión Frambuesa shampoo 265 ml", "L'Oréal Kids", "Frasco 265 ml", "Shampoo", "Cuidado infantil", False),
    ("7506306257580", "PVO DESOD REXONA EFICC PIES 50 G", 2, 29.685, 59.37,
     "Rexona Efficient polvo desodorante pies 50 g", "Rexona", "Polvo 50 g", "Polvo", "Cuidado de pies", False),
    ("7501082722116", "CRA NUVEL P/MANOS SUAVES 65ML", 1, 13.490, 13.49,
     "Nuvel crema para manos suaves 65 ml", "Nuvel", "Tubo 65 ml", "Crema", "Cuidado de manos", False),
    ("7501846506198", "CERA ELASTIK 100GM XIOMARA", 2, 78.140, 156.28,
     "Xiomara Elastik cera 100 g", "Xiomara", "Tarro 100 g", "Cera", "Cuidado capilar", False),
    ("7509552874952", "SH ELVIVE HIDRA HIALU PURE 370ML", 1, 71.440, 71.44,
     "Elvive Hidra Hialurónico Pure shampoo 370 ml", "Elvive", "Frasco 370 ml", "Shampoo", "Cuidado capilar", False),
    ("7501054558682", "CRA CORP NIVEAMILK 400ML+CRA100ML", 1, 85.870, 85.87,
     "Nivea Milk crema corporal 400 ml + 100 ml", "Nivea", "400 ml + 100 ml", "Crema", "Cuidado corporal", True),
    ("7509552525427", "DESOD OBAO 65G ROLL ON FRESC SUAVE-PIEL DEL IC 3PACK", 1, 58.950, 58.95,
     "Obao Frescura Suave / Piel Delicada roll-on 65 g 3-pack", "Obao", "3 roll-on 65 g", "Roll-on", "Desodorante", False),
]


def build_rows() -> list[dict]:
    rows = []
    for ean, snap, qty, pu, sub, nombre, marca, presentacion, forma, subcat, ya in RAW:
        costo = round(float(pu), 2)
        tipo = "marca"
        rows.append({
            "ean": ean,
            "sku": sku_de(ean),
            "snap": snap,
            "nombre": nombre,
            "qty": int(qty),
            "pu": costo,
            "sub": round(float(sub), 2),
            "tipo": tipo,
            "categoria": "Cuidado personal",
            "subcategoria": subcat,
            "forma": forma,
            "marca": marca,
            "laboratorio": None,
            "presentacion": presentacion,
            "principio": None,
            "concentracion": None,
            "receta": False,
            "ya": ya,
            "foto": None,
            "foto_file": None,
            "lote": None,
            "precio": ceil_pvp(costo, tipo),
            "match": "ya" if ya else "alta",
        })
    return rows


def write_carga_sql(rows: list[dict]) -> Path:
    vals = []
    for i, r in enumerate(rows, start=1):
        vals.append(
            "  ({linea}, {ean}, {sku}, {nombre}, {snap}, {qty}, {costo}, {precio}, "
            "{tipo}, {cat}, {subcat}, {forma}, {marca}, {lab}, {pres}, {pa}, {conc}, "
            "{receta}, {ya}, {foto}, {foto_file}, {lote})".format(
                linea=i,
                ean=sql_str(r["ean"]),
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
    body = f"""-- Bodega F-42 Ejidos del Moral · Caja 4/{FOLIO} · {FECHA} 12:39
-- Ticket térmico. Subtotal $4,553.92 + impuestos $728.58 = ${TOTAL:,.2f}.
-- Costo = P.U. impreso (ya con IVA; suma de renglones = total tarjeta).
-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000.
-- {n_alta} alta(s) stock 0. {n_ya} ya estaban (snapshot ago-2026): solo costo / ficha vacía, no PVP.
-- Nombres de mostrador, no del ticket. Fotos: TODO packshot (sin placeholder competencia).
-- Códigos cortos Rexona (8 dígitos) tal cual en ticket Walmart; pistola puede traer EAN completo.
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table {TMP} (
  linea integer primary key,
  ean text not null,
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

insert into {TMP} (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
{",\n".join(vals)};

-- Una fila por EAN (mismo producto no debe insertar 2 veces el SKU).
insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    -- SKU libre
    when not exists (
      select 1 from public.productos p where p.sku = t.sku
    ) then t.sku
    -- Colisión (activo o no): FC-ND- + últimos 8
    when not exists (
      select 1 from public.productos p
      where p.sku = 'FC-ND-' || right(t.ean, 8)
    ) then 'FC-ND-' || right(t.ean, 8)
    -- Último recurso por folio/línea (no chocar unique)
    else 'FC-B' || '{FOLIO}' || '-' || lpad(t.linea::text, 3, '0')
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta {PROVEEDOR} {FOLIO} · {FECHA} · listo para pistola',
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
  select distinct on (ean) *
  from {TMP}
  order by ean, linea
) t
-- Solo por EAN: no exigir SKU libre (si el SKU está ocupado, arriba lo remapeamos).
-- Incluye inactivos con el mismo código (fc_buscar solo mira activos).
where public.fc_buscar_producto_escaneo(t.ean) is null
  and not exists (
    select 1 from public.productos p
    where coalesce(p.codigo_barras, '') = t.ean
       or public.fc_match_codigo_barras(t.ean, p.codigo_barras)
  );

-- Ya existían: costo. PVP solo si estaba en 0.
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from (
  select distinct on (ean) *
  from {TMP}
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

-- Ficha vacía / foto si falta. No pisa una foto que ya esté.
update public.productos p
set
  nombre = case
    when length(trim(coalesce(p.nombre, ''))) < 8 then t.nombre
    else p.nombre
  end,
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  codigo_barras = coalesce(nullif(trim(p.codigo_barras), ''), t.ean)
from (
  select distinct on (ean) *
  from {TMP}
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  {sql_str(PROVEEDOR)},
  {sql_str(FOLIO)},
  {sql_str(FECHA)},
  {TOTAL:.2f},
  'borrador',
  {sql_str(
      f"Ticket Bodega F-42 Caja 4/{FOLIO} · 24-oct-2026 · foto térmica · "
      f"tarjeta ${TOTAL:,.2f} · cola Recibir; stock al confirmar pistola"
  )}
where not exists (
  select 1 from public.recepciones
  where folio = {sql_str(FOLIO)}
    and coalesce(proveedor, '') ilike '%bodega%'
);

update public.recepciones
set
  total_ticket = {TOTAL:.2f},
  fecha = {sql_str(FECHA)},
  proveedor = {sql_str(PROVEEDOR)},
  notas = {sql_str(
      f"Ticket Bodega F-42 Caja 4/{FOLIO} · 24-oct-2026 · foto térmica · "
      f"tarjeta ${TOTAL:,.2f} · cola Recibir; stock al confirmar pistola"
  )},
  updated_at = now()
where folio = {sql_str(FOLIO)}
  and coalesce(proveedor, '') ilike '%bodega%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = {sql_str(FOLIO)}
  and coalesce(r.proveedor, '') ilike '%bodega%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  v.pid,
  t.ean,
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
    )
  ),
  null
from {TMP} t
join public.recepciones r
  on r.folio = {sql_str(FOLIO)}
 and coalesce(r.proveedor, '') ilike '%bodega%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
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
    where i.producto_id = p.id and coalesce(i.es_principal, false)
  ),
  'propia'
from {TMP} t
join public.productos p on p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
)
where t.imagen is not null
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and (i.url = t.imagen or i.storage_path = t.foto_file)
  );

-- Diagnóstico
select
  r.folio,
  r.proveedor,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  sum(i.cantidad) as piezas,
  bool_or(i.pendiente_alta) as tiene_pendiente_alta
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = {sql_str(FOLIO)}
  and coalesce(r.proveedor, '') ilike '%bodega%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from {TMP} t
order by t.linea;

commit;
"""
    path = OUT_DIR / f"patch_carga_bodega_f42_{FOLIO}.sql"
    path.write_text(body, encoding="utf-8")
    return path


def write_leerme(rows: list[dict]) -> Path:
    n_alta = sum(1 for r in rows if not r["ya"])
    piezas = sum(r["qty"] for r in rows)
    path = OUT_DIR / f"LEERME_bodega_f42_{FOLIO}_20261024.md"
    path.write_text(
        f"""# Bodega F-42 · Caja 4/{FOLIO} · 24-oct-2026

Ticket térmico Ejidos del Moral. Pegar **todo** `sql/patch_carga_bodega_f42_{FOLIO}.sql` en Supabase → SQL Editor → Run.

| Campo | Valor |
|-------|-------|
| Proveedor | Bodega F-42 |
| Folio | **{FOLIO}** (Caja 4) |
| Fecha | {FECHA} 12:39 |
| Renglones | {len(rows)} |
| Piezas | {piezas} |
| Subtotal / IVA / Total | $4,553.92 / $728.58 / **${TOTAL:,.2f}** (tarjeta) |
| Altas nuevas (estimado) | ~{n_alta} (el SQL inserta solo si `fc_buscar` no encuentra) |

## Notas

1. **Stock 0** hasta pistola + MMAA de la caja. No poner `0000`.
2. **Colgate Total Advanced** (EAN `7509546052632`): el ticket trae `OCT26` en la descripción — eso no se guarda como caducidad; se pide MMAA al escanear.
3. **Códigos cortos Rexona** (`75062804`, `75085513`, `75081669`, `75075996`, `78924345`, `75085537`, `75085520`): así vienen en el ticket Walmart. Si la pistola lee EAN-13 distinto, avisar para ligar.
4. **Fotos:** ninguna alta de este ticket trae packshot todavía. **TODO** buscar en mayoreo/retailer (sin placeholder Fahorro/Similares) y subir a `public/catalogo-propia/`.
5. Regenerar: `python3 scripts/generar_carga_bodega_f42_28130.py`

## Después del SQL

1. Recargar Recibir en la tablet.
2. Debe aparecer el botón **Bodega F-42 · {FOLIO}** junto a los otros pedidos vivos.
3. Escanear → MMAA → Guardar renglón.
""",
        encoding="utf-8",
    )
    return path


def main() -> None:
    assert len(RAW) == 73, f"esperaba 73 renglones, hay {len(RAW)}"
    rows = build_rows()
    suma = sum(r["sub"] for r in rows)
    assert abs(suma - TOTAL) < 0.05, f"suma renglones ${suma:.2f} ≠ total ${TOTAL:.2f}"

    GEN_DIR.mkdir(parents=True, exist_ok=True)
    csv_path = GEN_DIR / f"ticket_bodega_f42_{FOLIO}.csv"
    write_ticket_csv(
        csv_path,
        folio=FOLIO,
        fecha=FECHA,
        proveedor=PROVEEDOR,
        total=TOTAL,
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
            for r in rows
        ],
    )
    sql_path = write_carga_sql(rows)
    md_path = write_leerme(rows)
    print(f"{FOLIO}: {report(rows, TOTAL)}")
    print(f"  → {csv_path.relative_to(ROOT)}")
    print(f"  → {sql_path.relative_to(ROOT)}")
    print(f"  → {md_path.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
