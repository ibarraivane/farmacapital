"""
Metadatos de catálogo investigados en internet (EAN, PA, presentación).
Complementa datos_catalogo_faltantes.py y el export SQL/Excel.

Fuentes: farmacias MX (Klyns, San Jorge, Sanorim, Sufarmed, iFarma, Fahorro, etc.)
"""

from __future__ import annotations

import csv
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

# Marca comercial → principio activo genérico (corrige PA = nombre de marca)
BRAND_TO_GENERIC_PA: dict[str, str] = {
    "GIMALXINA": "AMOXICILINA",
    "BENEVENTOL": "CEFIXIMA",
    "ZITRIASOL": "ITRACONAZOL",
    "NORQUINOL": "NORFLOXACINO",
    "BACTIVER": "SULFAMETOXAZOL + TRIMETOPRIMA",
    "PENTIBROXIL": "AMOXICILINA + AMBROXOL",
    "DESROTAN": "FEXOFENADINA",
    "AMDORYL": "LANSOPRAZOL",
    "REGLUSAN": "GLIBENCLAMIDA",
    "DIURMESSEL": "FUROSEMIDA",
    "OVISEN": "FLUOXETINA",
    "DIZIVER": "HIDROCLOROTIAZIDA",
    "PENIPOT": "BENCILPENICILINA",
    "ERISPAN": "BETAMETASONA",
    "AMIFARIN": "DICLOXACILINA",
    "VANDIL": "AMOXICILINA",
    "PERLUDIL": "ALGESTONA + ESTRADIOL",
    "CLOXAN": "AMBROXOL",
    "GELUBRIN": "IBUPROFENO",
    "FASICLOR": "CEFACLOR",
    "CEFAGEN": "CEFUROXIMA",
    "KLARIX": "CLARITROMICINA",
    "CHARLYN": "CIPROFLOXACINO",
    "CEPOBROM": "CEFADROXIL",
    "DICLOFEN": "DICLOFENACO",
    "EPICIN": "ERITROMICINA",
    "KNORICIN": "NITROFURANTOINA",
    "CLAMOXIN": "AMOXICILINA + ACIDO CLAVULANICO",
    "VALCLAN": "AMOXICILINA + ACIDO CLAVULANICO",
    "GIMALXINA": "AMOXICILINA",
    "REUMATOL": "MENTOL + ALCANFOR + METILSALICILATO",
    "BIOERTER": "CETIRIZINA",
    "PROTECT": "Budesonida + Formoterol",
}

# SKU → metadatos verificados en farmacias MX (barcode + PA)
SKU_CATALOG_WEB: dict[str, dict] = {
    "FC-5C8C9C11": {
        "codigo_barras": "7503027446279",
        "principio_activo": "Ibuprofeno",
        "marca": "Gelubrin",
        "concentracion": "600 MG",
        "forma_farmaceutica": "CAPSULAS",
    },
    "FC-1DA570E3": {
        "codigo_barras": "7501573900337",
        "principio_activo": "Ambroxol",
        "marca": "Cloxan",
        "concentracion": "30 MG",
        "forma_farmaceutica": "COMPRIMIDOS",
    },
    "FC-974EE5FD": {
        "codigo_barras": "780083141875",
        "principio_activo": "Amoxicilina",
        "marca": "Gimalxina",
        "concentracion": "250MG/5/75 ML",
        "forma_farmaceutica": "SUSPENSION",
    },
    "FC-6519183A": {
        "codigo_barras": "7502009740206",
        "principio_activo": "Amoxicilina + Acido clavulanico",
        "marca": "Clamoxin",
        "concentracion": "125/31.25MG/5/60 ML",
        "forma_farmaceutica": "SUSPENSION",
    },
    "FC-516C2E89": {
        "codigo_barras": "7502009740503",
        "principio_activo": "Amoxicilina + Acido clavulanico",
        "marca": "Clamoxin",
        "concentracion": "400/57MG/5/50 ML",
        "forma_farmaceutica": "SUSPENSION",
    },
    "FC-9B93AC4C": {
        "codigo_barras": "7502009745737",
        "principio_activo": "Cefixima",
        "marca": "Beneventol",
        "concentracion": "100MG/5 ML/50 ML",
        "forma_farmaceutica": "SUSPENSION",
    },
    "FC-9A4E4C31": {
        "codigo_barras": "7501349021860",
        "principio_activo": "Clindamicina",
        "marca": "AMSA",
        "concentracion": "600MG/4 ML",
        "forma_farmaceutica": "FRASCO AMPULA",
    },
    "FC-11294615": {
        "codigo_barras": "7501349021488",
        "principio_activo": "Amikacina",
        "concentracion": "500MG/2 ML",
        "forma_farmaceutica": "AMPOLLETA",
    },
    "FC-7F90064A": {
        "codigo_barras": "7501349021051",
        "principio_activo": "Ampicilina",
        "concentracion": "500MG/2 ML",
        "forma_farmaceutica": "FRASCO AMPULA",
    },
    "FC-D210172A": {
        "codigo_barras": "7501349022874",
        "principio_activo": "Ampicilina",
        "concentracion": "1 G/5 ML",
        "forma_farmaceutica": "FRASCO AMPULA",
    },
    "FC-F82A6E4B": {
        "codigo_barras": "7501349022881",
        "principio_activo": "Ampicilina",
        "concentracion": "1 G",
        "forma_farmaceutica": "TABLETAS",
    },
    "FC-BDB2E087": {
        "codigo_barras": "7501349022454",
        "principio_activo": "Irbesartan",
        "concentracion": "150 MG",
        "forma_farmaceutica": "TABLETAS",
    },
    "FC-A23F290E": {
        "codigo_barras": "7502209858107",
        "principio_activo": "Itraconazol",
        "marca": "Zitriasol",
        "concentracion": "100 MG",
        "forma_farmaceutica": "CAPSULAS",
    },
    "FC-357D4A17": {
        "codigo_barras": "7501349022799",
        "principio_activo": "Ceftazidima",
        "concentracion": "1 G/3 ML",
        "forma_farmaceutica": "FRASCO AMPULA",
    },
    "FC-5BC5F234": {
        "codigo_barras": "7501349012943",
        "principio_activo": "Fluconazol",
        "concentracion": "150 MG",
        "forma_farmaceutica": "CAPSULAS",
    },
    "FC-5D9DFA3D": {
        "codigo_barras": "785120755497",
        "principio_activo": "Norfloxacino",
        "marca": "Norquinol",
        "concentracion": "400 MG",
        "forma_farmaceutica": "TABLETAS",
    },
    "FC-447B30F9": {
        "codigo_barras": "7501349023987",
        "principio_activo": "Budesonida",
        "concentracion": "0.250MG/2 ML",
        "forma_farmaceutica": "AMPOLLETA",
    },
    "FC-50AC2C82": {
        "codigo_barras": "7502009740916",
        "principio_activo": "Betametasona",
        "marca": "Erispan",
        "concentracion": "8MG/2 ML",
        "forma_farmaceutica": "FRASCO AMPULA",
    },
    "FC-930E0B1B": {
        "codigo_barras": "7503001007069",
        "principio_activo": "Amoxicilina",
        "marca": "Vandil",
        "concentracion": "250MG/5/75 ML",
        "forma_farmaceutica": "SUSPENSION",
    },
    "FC-9F67BB73": {
        "codigo_barras": "7503001007090",
        "principio_activo": "Dicloxacilina",
        "marca": "Amifarin",
        "concentracion": "250MG/5/60 ML",
        "forma_farmaceutica": "SUSPENSION",
    },
    "FC-E4BE37BE": {
        "codigo_barras": "785120754858",
        "principio_activo": "Atorvastatina",
        "concentracion": "40 MG",
        "forma_farmaceutica": "TABLETAS",
    },
    "FC-DEAF33B0": {
        "codigo_barras": "7503000422511",
        "principio_activo": "Sulfametoxazol + Trimetoprima",
        "marca": "Bactiver",
        "concentracion": "40/200MG/5ML",
        "forma_farmaceutica": "SUSPENSION",
    },
    "FC-F4E9C71F": {
        "codigo_barras": "7501349021839",
        "principio_activo": "Amoxicilina",
        "concentracion": "500MG/5/75 ML",
        "forma_farmaceutica": "SUSPENSION",
    },
    "FC-AA905BF7": {
        "codigo_barras": "780083141226",
        "principio_activo": "Algestona + Estradiol",
        "marca": "Perludil",
        "concentracion": "150/10 MG",
        "forma_farmaceutica": "FRASCO AMPULA",
    },
    "FC-B4477A00": {
        "codigo_barras": "7503000422757",
        "principio_activo": "Amoxicilina + Ambroxol",
        "marca": "Pentibroxil",
        "concentracion": "500/30 MG",
        "forma_farmaceutica": "CAPSULAS",
    },
    "FC-B3B8F9BB": {
        "codigo_barras": "7502227875568",
        "principio_activo": "Fexofenadina",
        "marca": "Desrotan",
        "concentracion": "180 MG",
        "forma_farmaceutica": "TABLETAS",
    },
    "FC-9A37D44A": {
        "codigo_barras": "7503003738961",
        "principio_activo": "Lansoprazol",
        "marca": "Amdoryl",
        "concentracion": "30 MG",
        "forma_farmaceutica": "CAPSULAS",
    },
    "FC-57925EF3": {
        "codigo_barras": "7501075714739",
        "principio_activo": "Glibenclamida",
        "marca": "Reglusan",
        "concentracion": "5 MG",
        "forma_farmaceutica": "TABLETAS",
    },
    "FC-E535DE28": {
        "codigo_barras": "7501573900375",
        "principio_activo": "Furosemida",
        "marca": "Diurmessel",
        "concentracion": "40 MG",
        "forma_farmaceutica": "TABLETAS",
    },
    "FC-F7DB080D": {
        "codigo_barras": "7501573909408",
        "principio_activo": "Fluoxetina",
        "marca": "Ovisen",
        "concentracion": "20 MG",
        "forma_farmaceutica": "TABLETAS",
    },
    "FC-28A424E5": {
        "codigo_barras": "7502009746383",
        "principio_activo": "Hidroclorotiazida",
        "marca": "Diziver",
        "concentracion": "25 MG",
        "forma_farmaceutica": "TABLETAS",
    },
    "FC-F183C6E9": {
        "codigo_barras": "7501349011175",
        "principio_activo": "Bencilpenicilina",
        "marca": "Penipot",
        "concentracion": "800,000 UI",
        "forma_farmaceutica": "FRASCO AMPULA",
    },
    "FC-D06E54FE": {
        "codigo_barras": "7503000422795",
        "principio_activo": "Amoxicilina + Acido clavulanico",
        "marca": "Valclan",
        "concentracion": "500/125 MG",
        "forma_farmaceutica": "TABLETAS",
    },
    "FC-2E5B7248": {
        "codigo_barras": "7503003406600",
        "principio_activo": "Mentol + Alcanfor + Metilsalicilato",
        "marca": "Reumatol",
        "forma_farmaceutica": "GEL",
    },
    "FC-6898B64F": {
        "codigo_barras": "7503008344747",
        "principio_activo": "Cetirizina",
        "marca": "Bioerter",
        "concentracion": "250 MG/100 ML",
        "forma_farmaceutica": "SUSPENSION",
    },
    "FC-6B2ADEE9": {
        "codigo_barras": "7501109900008",
        "principio_activo": "Budesonida + Formoterol",
        "marca": "Protect",
        "forma_farmaceutica": "SPRAY",
    },
    "FC-7D1D9857": {
        "codigo_barras": "7501008491074",
        "principio_activo": "Acido acetilsalicilico",
        "concentracion": "100 MG",
        "forma_farmaceutica": "TABLETAS",
    },
    "FC-DFF99C3F": {
        "codigo_barras": "3311000003920",
        "principio_activo": "Arnica montana",
        "marca": "Mercurio",
        "forma_farmaceutica": "GLOBULOS",
    },
    "FC-89F00320": {
        "codigo_barras": "3311000003920",
        "principio_activo": "Arnica montana",
        "marca": "Mercurio",
        "forma_farmaceutica": "GLOBULOS",
    },
    "FC-25E452B6": {
        "codigo_barras": "3311000003920",
        "principio_activo": "Arnica montana",
        "marca": "Mercurio",
        "forma_farmaceutica": "POMADA",
    },
    "FC-127F5753": {
        "codigo_barras": "3311000003920",
        "principio_activo": "Arnica montana",
        "marca": "Mercurio",
        "forma_farmaceutica": "GOTAS",
    },
}

# Prefijos en nombre → PA descriptivo (higiene / abarrotes)
_NAME_PA_RULES: list[tuple[str, str]] = [
    (r"\bSHAMPOO\b", "Surfactantes / formula capilar"),
    (r"\bDESODORANTE\b", "Antitranspirante / desodorante"),
    (r"\bJABON\b|\bJBN\b", "Jabon / tensioactivos"),
    (r"\bCREMA\s+DENT\b|\bPASTA\s+DENT\b|\bCOLGATE\b", "Fluoruro de sodio"),
    (r"\bCREMA\s+CORP\b|\bCREMA\s+HINDS\b|\bNIVEA\b", "Emolientes / humectantes"),
    (r"\bTALCO\b", "Talco / zinc undecilenato"),
    (r"\bALCOHOL\b", "Alcohol etilico"),
    (r"\bVENDA\b|\bGASA\b|\bTELA\b", "Material de curacion"),
    (r"\bENSURE\b|\bPEDIASURE\b|\bGLUCERNA\b", "Suplemento nutricional"),
    (r"\bELECTROLIT\b|\bSUEROX\b|\bPEDIALYTE\b", "Electrolitos / suero oral"),
    (r"\bCONDON\b|\bPRUDENCE\b|\bSICO\b", "Latex"),
    (r"\bCEPILLO\b|\bBIBERON\b|\bEVENFLO\b", "Material sintetico"),
    (r"\bTOALLITAS\b|\bTOALLAS\b", "Solucion limpiadora"),
    (r"\bPAÑAL\b|\bDIAPRO\b", "Celulosa absorbente"),
    (r"\bVICKS\b|\bVAPORUB\b", "Alcanfor + Mentol + Eucalipto"),
    (r"\bCENTRUM\b", "Multivitaminico + minerales"),
    (r"\bQUIRMEX\b", "Vaselina + lanolina"),
    (r"\bMERCURIO\b", "Producto homeopatico / natural"),
    (r"\bMERTIOLATE\b", "Timerosal"),
    (r"\bBICARBONATO\b", "Bicarbonato de sodio"),
    (r"\bPERILLA\b", "Material plastico"),
    (r"\bGOTERO\b", "Vidrio / plastico"),
    (r"\bJERINGA\b", "Plastico medical grade"),
    (r"\bAFRODIT\b", "Emolientes"),
    (r"\bBLUMEN\b", "Surfactantes"),
    (r"\bPALMOLIVE\b|\bESCUDO\b|\bDOVE\b", "Surfactantes / formula corporal"),
    (r"\bSILICA\b|\bSILKA\b", "Silice / dimeticone"),
    (r"\bNIDO\b", "Formula lactea"),
    (r"\bCERA\b", "Cera / resina"),
    (r"\bIODEX\b", "Mentol + eucalipto"),
    (r"\bREDOXON\b|\bPHARMATON\b", "Vitamina C / multivitaminico"),
    (r"\bTUMS\b", "Carbonato de calcio"),
    (r"\bLACTOPRAM\b", "Lactobacillus"),
    (r"\bTROJAN\b|\bCONDONES\b", "Latex"),
    (r"\bREXONA\b|\bOBBO\b|\bOBBO\b", "Antitranspirante"),
    (r"\bLABELLO\b|\bCHAPSTICK\b", "Emolientes labiales"),
    (r"\bKLEENEX\b|\bPANUELOS\b", "Celulosa"),
    (r"\bTREDA\b", "Loperamida"),
    (r"\bNEOMELUBRINA\b|\bNEOMELU\b", "Dipirona + Metoclopramida"),
    (r"\bPRUEBA\s+EMBARAZO\b|\bMEDITEST\b", "Gonadotropina corionica (test)"),
    (r"\bAGUA\s+DEST\b|\bAGUA\s+MIC\b", "Agua purificada"),
    (r"\bTEATRICAL\b", "Emolientes / lanolina"),
    (r"\bTING\b", "Acido bórico / talco"),
    (r"\bPROTEC\b|\bPADS\b", "Material absorbente"),
    (r"\bDEGASA\b|\bAGUA\s+OXIGENADA\b", "Agua oxigenada"),
    (r"\bNATURELLA\b|\bSABA\b|\bKOTEX\b", "Celulosa absorbente"),
    (r"\bARMSTRONG\b|\bHERKLIN\b", "Surfactantes"),
    (r"\bHIALURONATO\b", "Hialuronato de sodio"),
    (r"\bDIOSMINA\b", "Diosmina + Hesperidina"),
    (r"\bCARBAMAZEPINA\b", "Carbamazepina"),
    (r"\bAZITROMICINA\b", "Azitromicina"),
    (r"\bENALAPRIL\b", "Enalapril"),
    (r"\bGENTAMICINA\b", "Gentamicina"),
    (r"\bBISOPROLOL\b", "Bisoprolol"),
    (r"\bCEFALEXINA\b", "Cefalexina"),
    (r"\bCLARITROMICINA\b", "Claritromicina"),
    (r"\bACEMETACINA\b", "Acemetacina"),
]

# Reglas: todas las palabras clave deben aparecer en PA+concentración+presentación
GENERIC_EAN_SIGNATURES: list[dict] = [
    {"sig": ["AMOXICILINA", "875", "125"], "codigo_barras": "7502009740763", "marca": "Clamoxin"},
    {"sig": ["AMOXICILINA", "500", "125"], "codigo_barras": "7502009740992", "marca": "Clamoxin"},
    {"sig": ["AMOXICILINA", "250", "62"], "codigo_barras": "7502009740213", "marca": "Clamoxin"},
    {"sig": ["AMOXICILINA", "125", "31"], "codigo_barras": "7502009740206", "marca": "Clamoxin"},
    {"sig": ["AMOXICILINA", "400", "57"], "codigo_barras": "7502009740503", "marca": "Clamoxin"},
    {"sig": ["AMOXICILINA", "600", "42"], "codigo_barras": "7502009740497", "marca": "Clamoxin"},
    {"sig": ["CEFACLOR", "375"], "codigo_barras": "7502009741050", "marca": "Fasiclor"},
    {"sig": ["CEFACLOR", "250", "5"], "codigo_barras": "7502009741050", "marca": "Fasiclor"},
    {"sig": ["CEFACLOR", "500"], "codigo_barras": "7502009741456", "marca": "Fasiclor"},
    {"sig": ["CEFUROXIMA", "250", "10"], "codigo_barras": "7502009745119", "marca": "Cefagen", "principio_activo": "Cefuroxima"},
    {"sig": ["LEVOFLOXACINO", "500", "7"], "codigo_barras": "7501349021419", "marca": "AMSA"},
    {"sig": ["IRBESARTAN", "150"], "codigo_barras": "7501349022454", "marca": "AMSA"},
    {"sig": ["CEFIXIMA", "400", "3"], "codigo_barras": "7502009745928", "marca": "Beneventol"},
    {"sig": ["CEFIXIMA", "400", "6"], "codigo_barras": "7502009746253", "marca": "Beneventol"},
    {"sig": ["CEFIXIMA", "100"], "codigo_barras": "7502009745737", "marca": "Beneventol"},
    {"sig": ["AMOXICILINA", "500", "75"], "codigo_barras": "7501349021839", "marca": "AMSA"},
    {"sig": ["AMOXICILINA", "250", "75"], "codigo_barras": "780083141875", "marca": "Gimalxina"},
    {"sig": ["CLINDAMICINA", "600"], "codigo_barras": "7501349021860", "marca": "AMSA"},
]

_SQL_CACHE: dict[str, dict] | None = None
_LOTE2_CACHE: dict[str, dict] | None = None


def _load_sql_catalog() -> dict[str, dict]:
    global _SQL_CACHE
    if _SQL_CACHE is not None:
        return _SQL_CACHE
    path = ROOT / "sql" / "actualizar_catalogo_campos_y_precios.sql"
    out: dict[str, dict] = {}
    if not path.exists():
        _SQL_CACHE = out
        return out
    text = path.read_text(encoding="utf-8")
    pat = re.compile(r"update public\.productos set (.+?) where sku = '([^']+)'", re.I | re.S)
    for m in pat.finditer(text):
        sku = m.group(2)
        body = m.group(1)
        d: dict[str, str] = {}
        for field in (
            "nombre",
            "marca",
            "presentacion",
            "principio_activo",
            "concentracion",
            "forma_farmaceutica",
            "tipo",
        ):
            mm = re.search(rf"{field} = '([^']*)'", body)
            if mm and mm.group(1).strip():
                d[field] = mm.group(1).strip()
        out[sku] = d
    _SQL_CACHE = out
    return out


def _load_lote2() -> dict[str, dict]:
    global _LOTE2_CACHE
    if _LOTE2_CACHE is not None:
        return _LOTE2_CACHE
    path = ROOT / "pricing" / "importados" / "lote2_50_medicamentos_claude.csv"
    out: dict[str, dict] = {}
    if path.exists():
        for row in csv.DictReader(path.open(encoding="utf-8")):
            sku = (row.get("sku") or "").strip()
            if sku:
                out[sku] = row
    _LOTE2_CACHE = out
    return out


def _fix_pa(pa: str, marca: str = "", nombre: str = "") -> str:
    pa = (pa or "").strip()
    if pa.upper() in BRAND_TO_GENERIC_PA:
        return BRAND_TO_GENERIC_PA[pa.upper()]
    first = (nombre or marca or pa or "").split()[0].upper()
    if first in BRAND_TO_GENERIC_PA:
        return BRAND_TO_GENERIC_PA[first]
    if pa and pa.upper() == (marca or "").upper() and pa.upper() in BRAND_TO_GENERIC_PA:
        return BRAND_TO_GENERIC_PA[pa.upper()]
    return pa


def infer_pa_from_nombre(nombre: str) -> str:
    u = (nombre or "").upper()
    for pat, pa in _NAME_PA_RULES:
        if re.search(pat, u):
            return pa
    # Mercurio subproductos
    if "MERCURIO" in u:
        if "ARNICA" in u:
            return "Arnica montana"
        if "YODO" in u:
            return "Yodo homeopatico"
        if "GLICERINA" in u:
            return "Glicerina"
        if "BISMUTO" in u:
            return "Bismuto subnitrato"
        if "BORAX" in u:
            return "Borax"
        if "SULFATIAZOL" in u:
            return "Sulfatiazol"
        if "ABEJA" in u:
            return "Veneno de abeja (homeopatia)"
        if "ALCANFOR" in u or "ALCANFORADA" in u:
            return "Alcanfor"
        if "ROMERO" in u or "COCO" in u or "OLIVO" in u:
            return "Aceite esencial"
        if "ESPIRITUS" in u:
            return "Alcohol / espiritu medicinal"
        return "Producto homeopatico"
    return ""


def _norm_sig_text(*parts: str) -> str:
    return re.sub(r"\s+", " ", " ".join(parts)).upper()


def lookup_generic_ean(meta: dict) -> dict:
    """Asigna barcode por firma PA + concentración + presentación."""
    blob = _norm_sig_text(
        meta.get("principio_activo", ""),
        meta.get("concentracion", ""),
        meta.get("presentacion", ""),
        meta.get("forma_farmaceutica", ""),
        meta.get("marca", ""),
    )
    for rule in GENERIC_EAN_SIGNATURES:
        keys = rule.get("sig") or []
        if keys and all(k.upper() in blob for k in keys):
            out = {k: v for k, v in rule.items() if k != "sig" and v}
            return out
    return {}


def lookup_sku_catalog(sku: str, nombre: str = "", marca: str = "") -> dict:
    """Metadatos consolidados por SKU (web + SQL + lote2 + inferencia)."""
    meta: dict = {}

    for src in (_load_sql_catalog().get(sku, {}), _load_lote2().get(sku, {}), SKU_CATALOG_WEB.get(sku, {})):
        for k, v in src.items():
            if v and str(v).strip() and k not in meta:
                meta[k] = str(v).strip()

    if "codigo_barras" in meta:
        meta["codigo_barras"] = re.sub(r"\D", "", meta["codigo_barras"])

    if not meta.get("codigo_barras"):
        generic = lookup_generic_ean(meta)
        for k, v in generic.items():
            if v and k not in meta:
                meta[k] = str(v).strip()

    pa = _fix_pa(meta.get("principio_activo", ""), meta.get("marca", marca), nombre)
    if not pa:
        pa = infer_pa_from_nombre(nombre or meta.get("nombre", ""))
    if pa:
        meta["principio_activo"] = pa

    # Segunda pasada: barcode tras corregir PA (p. ej. Cefagen → Cefuroxima)
    if not meta.get("codigo_barras"):
        generic = lookup_generic_ean(meta)
        for k, v in generic.items():
            if v and k not in meta:
                meta[k] = str(v).strip()

    return meta
