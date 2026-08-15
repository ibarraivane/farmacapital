#!/usr/bin/env python3
"""
Genera SQL para renombrar productos con nombres truncados / OCR ilegibles.
Solo actualiza `nombre` (no pisa precio, costo ni stock).

Uso:
  python3 scripts/generar_patch_nombres_legibles.py
  python3 scripts/generar_patch_nombres_legibles.py --apply
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG_CSV = ROOT / "sql/preview_catalogo_campos_y_precios.csv"
CATALOG_JSON = ROOT / "sql/generated/analisis_nombres_inventario.json"
OUT_SQL = ROOT / "sql/patch_nombres_legibles_v2.sql"
OUT_CSV = ROOT / "sql/generated/renombres_nombres_legibles.csv"

try:
    import requests
except ImportError:
    requests = None

# Renombres autoritativos por SKU (prioridad sobre heurística)
SKU_RENAMES: dict[str, str] = {
    # Críticos — 1–3 letras
    "FC-F8691496": "Bactiver F (Sulfametoxazol/Trimetoprima)",
    "FC-77FE5C83": "Sonblefam S (Crema)",
    "FC-0E0A9E42": "Clamoxin S (Amoxicilina/Clavulánico susp.)",
    "FC-2001A890": "Ampigrin AD (Ampicilina + Dicloxacilina)",
    "FC-DE106642": "Infamid (Metamizol + Dexametasona + Vit. B)",
    "FC-1FFBB505": "Dac (Paracetamol + Diclofenaco)",
    "FC-DB4A39AE": "Eferox (Cefalexina)",
    "FC-30133021": "Iri (Inmunoglobulina)",
    "FC-89794961": "Histiacil NF Infantil (Jarabe)",
    "FC-1CF27DC9": "Dison Dex",
    "FC-2E79C2D8": "Hierro Dex",
    "FC-BE76D409": "Amcef IM 1 g (Inyectable)",
    "FC-C636D8EA": "Ceftriaxona IM 1 g (Inyectable)",
    "FC-07F04F88": "Amcef IM 500 mg (Inyectable)",
    "FC-22B18244": "Cefotaxima IM (Inyectable)",
    "FC-51067711": "Nido leche en polvo (grande)",
    "FC-59225411": "Nido leche en polvo (bolsa)",
    # Línea Clamoxin
    "FC-F22C72BE": "Clamoxin 12H (Amoxicilina/Clavulánico)",
    "FC-516C2E89": "Clamoxin 12H Jr (Amoxicilina/Clavulánico susp.)",
    "FC-DDFBABDF": "Clamoxin 12H Ped (Amoxicilina/Clavulánico susp.)",
    "FC-6519183A": "Clamoxin (Amoxicilina/Clavulánico 500/125 mg)",
    "FC-F48FF7EF": "Clamoxin (Amoxicilina/Clavulánico susp. 250/62.5)",
    "FC-5F30F9D4": "Clamoxin (Amoxicilina/Clavulánico 500/125 mg)",
    # Pantene / higiene truncados
    "FC-01303454": "Pantene Control caída anticaída",
    # OTC FarmaLive — nombres comerciales (v2)
    "FC-06134531": "Afrin Adulto spray 20 mL",
    "FC-40017100": "XL-3 VR C/24",
    "FC-00525451": "XL-3 C/10",
    "FC-00170941": "XL-3 Xtra C/12",
}

# Correcciones puntuales adicionales (nombre exacto → nuevo)
NAME_FIXES: dict[str, str] = {
    "Opella Neomelubrina Jbe I 121.00 Neomelubrina Jbe I": "Neo-Melubrina jarabe",
    "NeoMelubrina Opella Metamizol sodico tabletas": "Neo-Melubrina metamizol tabletas C/10",
    "Neurobion Sot.O- Dc Ete Jga Sot.O- Prell Health9.20": "Neurobión inyectable prellenado",
    "Chinoin Jr. Jbe Ine 60 Mant Jr. Jbe Mant": "Chinoin Junior jarabe infantil",
    "Prudence Mora Cond Mexico 34.10 Mora Cond Mexico": "Prudence mora condones C/3",
    "Prudence Iva Dki Mexico S Cond Iva Mexico": "Prudence condones C/3",
    "Prudence Chicle C/E Idkt Cond Chicle": "Prudence chicle condones C/3",
    "Prudence Ull Sensitive Cond 'Ull Sensitive": "Prudence Ultra Sensitive condones C/3",
    "Mercurio Oxido De Zinc 1620824 83521": "Mercurio óxido de zinc C/50",
    "Afrin Spray No Drip Extra Humectante Spray Drip Extra": "Afrin No Drip extra humectante spray",
    "Lásico Pomada I.Abeili.C 56.50 56.50": "Lásico pomada",
    "Protec Sigital Termometro 42.10 Sigital Termometro": "Protec termómetro digital",
    "Microdacyn Lubricante Ico Cereza 50 Ml 1 Ico Cereza 50": "Microdacyn lubricante cereza 50 ml",
    "Ajolotius Menta Eucal S/Azucar Past Menta Eucal": "Ajolotius menta eucalipto sin azúcar pastillas",
    "Toallas Saba Inv isible Alas": "Toallas Saba Invisible con alas C/10",
    "Histiacil NF Adulto": "Histiacil NF adulto jarabe",
    "Tukol-D Jbe": "Tukol-D jarabe",
    "Tukol-D Jbe Inf": "Tukol-D jarabe infantil",
    "Tempra Jbe": "Tempra jarabe",
    "Tempra Forte C/24": "Tempra Forte C/24",
    "Xl- C/10": "XL-3 C/10",
    "XL-3 Xtra": "XL-3 Xtra C/12",
    "Syncol Max Tab": "Syncol Max tabletas",
    "Sr I Ting": "Sr. Ting pomada (ácido bórico)",
    "Fazolin F": "Fazolin F (nafazolina)",
    "Graneodin F": "Graneodin F (flurbiprofeno)",
    "Graneodin B": "Graneodin B (benzocaína)",
    "Fc 01711/2030": "FC producto botiquín",
    "Inf": "Infamid (Metamizol + Dexametasona + Vit. B)",
    "Dac": "Dac (Paracetamol + Diclofenaco)",
    "Efe": "Eferox (Cefalexina)",
    "Cina": "Cina (Ciprofloxacino)",
    "Iri": "Iri (Inmunoglobulina)",
    "Ad": "Ampigrin AD (Ampicilina + Dicloxacilina)",
    "Acetona Jaloma ch": "Acetona Jaloma chico",
    "Acetona Jaloma med": "Acetona Jaloma mediano",
    "Agrifen Ab Pis": "Agrifen AB polvo efervescente",
    "Dermodine Ine M 1 37.60 Ine": "Dermodine infantil",
    "Dibar Gr Algodon Algodon": "Dibar algodón grande",
    "Senosiain Supos Adto C/10": "Senosiain supositorios adulto C/10",
    "Senosiain Supos Ine C/10": "Senosiain supositorios infantil C/10",
    "Softlub Extra Cond Extra": "Softlub Extra condones C/3",
    "Quita Esmalte Nuvel Humec Con Lanolina": "Nuvel quita esmalte humectante lanolina",
    "Ponds Desmaq Bio-Hydra Dual": "Ponds desmaquillante Bio-Hydra dual",
    "Nuvel Desmaq Bifasico Oil": "Nuvel desmaquillante bifásico oil",
    "Claris Toallas Desmaq Aloe": "Claris toallas desmaquillantes aloe C/40",
    "Crema Grisi Conchnac P/Manos": "Crema Grisi concha nácar para manos",
    "Crema Grisi Aloe Vera P/Manos": "Crema Grisi aloe vera para manos",
    "Crema Lubriderm P/Normal": "Crema Lubriderm piel normal",
    "Crema Para Peinar Pert Ac Oliv Agu": "Crema para peinar Pert aceite oliva aguacate",
    "Crema Hinds Hidr-Extr Almendras": "Crema Hinds hidratación extra almendras",
    "Crema Hinds Liq Agave Azul": "Crema Hinds líquida agave azul",
    "Blumen Coconut liq": "Blumen coconut líquido",
    "Blumen Jbn liq Cherry Bloss": "Blumen jabón líquido cherry blossom",
    "Palmolive Jbn Liq Cerezo y Rosa": "Palmolive jabón líquido cerezo y rosa",
    "Palmolive liq neutro": "Palmolive líquido neutro",
    "Escudo Jbn Liq Blanco Neut": "Escudo jabón líquido blanco neutro",
    "Desodorante Ego Force 24H R-On": "Desodorante Ego Force 24H roll-on",
    "Shampoo Caprice Biotina Fza": "Shampoo Caprice biotina fuerza",
    "Shampoo Caprice Nat Mzna": "Shampoo Caprice natural manzana",
    "Shampoo Mennen Lavan-Extrac Aven": "Shampoo Mennen lavanda extracto avena",
    "Shampoo Mennen Miel-Mza": "Shampoo Mennen miel manzana",
    "Shampoo Pantene Ctrl caida": "Shampoo Pantene control caída",
    "Shampoo Pantene Bambu Ctrl Caida": "Shampoo Pantene bambú control caída",
    "Shampoo Savile Ker-Sab Fza Repar": "Shampoo Savile keratina sábila fuerza reparadora",
    "Shampoo Savile Bio-Sab Creci Res": "Shampoo Savile bio sábila crecimiento resistente",
    "Vitacilina Cre Humectante Humectante": "Vitacilina crema humectante",
    "Mousse Herbal Essences Extra ctrl": "Mousse Herbal Essences extra control",
    "Pantene Ctrcaida A/Pv": "Pantene control caída anticaída",
    "Afrin Dtc (Rojo) 20": "Afrin Adulto spray 20 mL",
    "Afrin DTC rojo spray": "Afrin Adulto spray 20 mL",
    "Afrin Adulto rojo spray": "Afrin Adulto spray 20 mL",
    "Xl-3 Vr": "XL-3 VR C/24",
    "Aderogyl Amp": "Aderogyl ampolletas C/4",
    "Ajolotius Jengibre Tab Nati Jengibre": "Ajolotius jengibre pastillas",
    "Ajolotius Menta Fucal Menta Fucal": "Ajolotius menta eucalipto pastillas",
    "Alevarin Capsulas": "Alevarin cápsulas C/45",
    "Animalin Formula liquida": "Animalin fórmula líquida 30 mL",
    "Aspirina Eferv": "Aspirina efervescente C/12",
    "Cafiaspirina Tar C/100": "Cafiaspirina tartrato C/100",
    "Cinta Micropor Cintapore Blanca 2.5 cm x 5m": "Cinta micropore blanca 2.5 cm x 5 m",
    "Cinta Micropor Cintapore Blanca 2.5 cm x 9.1 m": "Cinta micropore blanca 2.5 cm x 9.1 m",
    "Crema Nivea Manos  Ant-Arrugas": "Crema Nivea manos antiarrugas",
    "Crema Para Peinar Sedal Recons Inst": "Crema para peinar Sedal reconstructor instantáneo",
    "Dove Aero Tono Uniforme Calendula y VitaminaE": "Dove aerosol tono uniforme caléndula y vitamina E",
    "Drosquim Ad 1 Ibe 300/160": "Drosquim adulto jarabe 300/160",
    "Gelcavit-9M Capsulas": "Gelcavit-9M cápsulas C/30",
    "Genoprazol Tab": "Genoprazol tabletas C/7",
    "Hucius Capsulas": "Hucius cápsulas",
    "Next Tab": "Next tabletas C/10",
    "Tabcin Eferv": "Tabcin efervescente",
    "Talco Para Bebe Mennen Azul ch": "Talco para bebé Mennen azul chico",
    "Talco Para Bebe Mennen Azul": "Talco para bebé Mennen azul",
    "Talco Para Bebe Mennen Rosa": "Talco para bebé Mennen rosa",
    "Talco Nuvel Pura Para Bebe": "Talco Nuvel Pura para bebé",
    "Tusilen Ad 1 Ibe 240/30/50Mg/100": "Tusilen adulto jarabe",
    "Valgab 3 Ibe /6Ml": "Valgab 3 jarabe 6 mL",
    "Valnait Capsulas Valeriana": "Valnait cápsulas valeriana",
    "Vick Drops Tengibre Pastillas Drops Tengibre": "Vick Drops jengibre pastillas C/20",
    "XL-3 C/10": "XL-3 C/10",
    "XL-3 Xtra C/12": "XL-3 Xtra C/12",
    "Charlyn": "Charlyn (Ciprofloxacino)",
    "Syncol": "Syncol (Paracetamol)",
    "Theraflu TD": "Theraflu TD",
    "Labello Hydro-C": "Labello Hydro-C",
}


def sql_quote(s: str) -> str:
    return "'" + str(s).replace("'", "''") + "'"


def expand_abbrev(n: str) -> str:
    s = n
    reps = [
        (r"\bAdto\b", "Adulto"),
        (r"\bIne\b", "Infantil"),
        (r"\bJbe\b", "Jarabe"),
        (r"\bJbn\b", "Jabón líquido"),
        (r"\bLiq\b", "Líquido"),
        (r"\bliq\b", "líquido"),
        (r"\bGr\b", "Grande"),
        (r"\bCh\b", "Chico"),
        (r"\bPis\b", "Polvo efervescente"),
        (r"\bS/Azucar\b", "Sin azúcar"),
        (r"\bS/AZUCAR\b", "Sin azúcar"),
        (r"\bDesmaq\b", "Desmaquillante"),
        (r"\bHumec\b", "Humectante"),
        (r"\bCtrl\b", "Control"),
        (r"\bCtrcaida\b", "Control caída"),
        (r"\bA/Pv\b", "Anticaída"),
        (r"\bAnt-Arrugas\b", "Antiarrugas"),
        (r"\bHidr-Extr\b", "Hidratación extra"),
        (r"\bRecons\b", "Reconstructor"),
        (r"\bDefin\b", "Definidos"),
        (r"\bExtr\b", "Extra"),
        (r"\bFza\b", "Fuerza"),
        (r"\bMzna\b", "Manzana"),
        (r"\bMza\b", "Manzana"),
        (r"\bInv isible\b", "Invisible"),
        (r"\bCond\b", "Condón"),
        (r"\bPrell\b", "Prellenado"),
        (r"\bR-ON\b", "Roll-on"),
        (r"\bR-On\b", "Roll-on"),
        (r"\bKer-Sab\b", "Keratina sábila"),
        (r"\bBio-Sab\b", "Bio sábila"),
        (r"\bLavan-Extrac\b", "Lavanda extracto"),
        (r"\bMiel-Mza\b", "Miel manzana"),
        (r"\bAc Oliv Agu\b", "Aceite oliva aguacate"),
        (r"\bAc-Oliva\b", "Aceite oliva"),
        (r"\bP/Manos\b", "Para manos"),
        (r"\bAb Pis\b", "AB Polvo"),
        (r"\bNat\b", "Natural"),
        (r"\bBifasico\b", "Bifásico"),
        (r"\bSot\.O-\s*", ""),
        (r"\bDc\b", ""),
        (r"\bEte\b", ""),
        (r"\bJga\b", "Jeringa"),
        (r"\bHealth[\d.]+\b", ""),
        (r"\bI\.Abeili\.C\b", ""),
        (r"\bIco\b", ""),
        (r"\bSigital\b", "Digital"),
        (r"\bIdkt\b", ""),
        (r"\bAmp\b", "Ampolletas"),
        (r"\bTab\b", "Tabletas"),
        (r"\bCapsulas\b", "Cápsulas"),
        (r"\bFormula liquida\b", "Fórmula líquida"),
        (r"\bEferv\b", "Efervescente"),
        (r"\bTar\b", "Tartrato"),
        (r"\bMicropor\b", "Micropore"),
        (r"\bCintapore\b", ""),
        (r"\bAero\b", "Aerosol"),
        (r"\bRecons Inst\b", "Reconstructor instantáneo"),
        (r"\bAnt-Arrugas\b", "Antiarrugas"),
        (r"\bNati\b", ""),
        (r"\bIbe\b", "Jarabe"),
        (r"\bAd 1\b", "Adulto"),
        (r"\bFucal\b", "Eucalipto"),
        (r"\bMenta Fucal Menta Fucal\b", "Menta eucalipto"),
        (r"\bDrops Tengibre Pastillas Drops Tengibre\b", "Drops jengibre pastillas"),
        (r"\bVitaminaE\b", "Vitamina E"),
        (r"\bCalendula\b", "Caléndula"),
        (r"\bPara Bebe\b", "Para bebé"),
        (r"\bAzul ch\b", "Azul chico"),
        (r"\bValeriana\b", "valeriana"),
        (r"\bDtc\b", ""),
        (r"\bDTC\b", ""),
        (r"\s+\d+\.\d+\s+\d+\.\d+", ""),
        (r"\s+\d{5,}\S*", ""),
    ]
    for pat, rep in reps:
        s = re.sub(pat, rep, s, flags=re.I)
    words = s.split()
    dedup: list[str] = []
    for w in words:
        if w and (not dedup or w.lower() != dedup[-1].lower()):
            dedup.append(w)
    s = " ".join(dedup)
    return re.sub(r"\s{2,}", " ", s).strip()


def needs_rename(nombre: str) -> bool:
    n = nombre.strip()
    if len(n) <= 3:
        return True
    if len(n) >= 45:
        return True
    if re.search(r"\d{5,}", n):
        return True
    markers = [
        "Jbe", "Jbn", "Ine", "Adto", "Desmaq", "Humec", "Hidr-Extr", "Ctrcaida",
        "A/Pv", "Ker-Sab", "Bio-Sab", "Lavan-Extrac", "Inv isible", "Cond Mexico",
        "Neomelubrina Jbe", "Sot.O-", "Prell Health", "S/Azucar", "P/Manos",
        "Spray Drip Extra", "I.Abeili", "Sigital Termometro",
        "DTC", "Dtc", "Xl-3 Vr", "Xl- C/", " Vr", "Cre Humectante Humectante",
        "Amp", " Tab", "Capsulas", "Eferv", " Tar", "Micropor", "Cintapore",
        "Aero ", "Recons Inst", "Ant-Arrugas", "Formula liquida", "Ibe", "Ad 1",
        "Nati ", "Fucal Menta", "Drops Tengibre", "VitaminaE", "Para Bebe",
        "Azul ch", "Valeriana",
    ]
    return any(m.lower() in n.lower() for m in markers)


def suggest_name(row: dict) -> str | None:
    sku = row["sku"]
    if sku in SKU_RENAMES:
        val = SKU_RENAMES[sku]
        return val if val else None

    old = (row.get("nombre") or "").strip()
    if old in NAME_FIXES:
        return NAME_FIXES[old]

    marca = (row.get("marca") or "").strip()
    if old == "I.M" and marca:
        conc = (row.get("concentracion") or "")[:20]
        return f"{marca} IM {conc}".strip()
    if old == "Dex" and marca:
        return f"{marca} Dex"
    if old == "S" and marca:
        return f"{marca} S"
    if old == "F" and marca:
        return f"{marca} F"

    if not needs_rename(old):
        return None

    new = expand_abbrev(old)
    if new != old and len(new) >= 4:
        return new[:100]
    return None


def load_catalog() -> list[dict]:
    if CATALOG_CSV.exists():
        import csv

        rows = []
        for row in csv.DictReader(CATALOG_CSV.open(encoding="utf-8")):
            if (row.get("activo") or "").lower() not in ("true", "1", "t"):
                continue
            rows.append(
                {
                    "id": row.get("id") or row.get("producto_id"),
                    "sku": row.get("sku", "").strip(),
                    "nombre": (row.get("nombre") or "").strip(),
                    "marca": (row.get("marca") or "").strip() or None,
                    "concentracion": (row.get("concentracion") or "").strip() or None,
                    "presentacion": (row.get("presentacion") or "").strip() or None,
                    "principio_activo": (row.get("principio_activo") or "").strip() or None,
                }
            )
        if rows:
            return rows
    if CATALOG_JSON.exists():
        return json.loads(CATALOG_JSON.read_text(encoding="utf-8"))
    if requests is None:
        sys.exit("Falta requests y catálogo JSON")
    env = {}
    for line in (ROOT / ".env").read_text(encoding="utf-8").splitlines():
        if "=" in line and not line.strip().startswith("#"):
            k, v = line.split("=", 1)
            env[k.strip()] = v.strip().strip('"').strip("'")
    url = env["REACT_APP_SUPABASE_URL"].rstrip("/")
    key = env["REACT_APP_SUPABASE_ANON_KEY"]
    headers = {"apikey": key, "Authorization": f"Bearer {key}"}
    return requests.get(
        f"{url}/rest/v1/productos",
        headers={**headers, "Range": "0-4999"},
        params={"select": "id,sku,nombre,marca,concentracion,presentacion,principio_activo", "activo": "eq.true"},
        timeout=60,
    ).json()


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--apply", action="store_true")
    args = ap.parse_args()

    rows = load_catalog()
    renames: list[dict] = []
    for row in rows:
        new = suggest_name(row)
        old = (row.get("nombre") or "").strip()
        if not new or new.strip() == old:
            continue
        renames.append({"sku": row["sku"], "id": row["id"], "old": old, "new": new.strip()})

    print(f"Renombres propuestos: {len(renames)}")

    OUT_CSV.parent.mkdir(parents=True, exist_ok=True)
    import csv

    with OUT_CSV.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=["sku", "id", "old", "new"])
        w.writeheader()
        w.writerows(renames)

    lines = [
        "-- Renombrar productos con nombres truncados / OCR ilegibles (delta vs catálogo live)",
        f"-- {len(renames)} updates · solo campo nombre · {datetime.now():%Y-%m-%d}",
        "-- Ejecutar DESPUÉS de patch_nombres_legibles_20260814.sql (v1 ya aplicado)",
        "-- NO modifica precio, costo, stock ni presentación",
        "",
        "BEGIN;",
        "",
    ]
    for r in renames:
        lines.append(
            f"UPDATE public.productos SET nombre = {sql_quote(r['new'])} "
            f"WHERE sku = {sql_quote(r['sku'])} AND activo = true;"
        )
    # Concentración OCR basura en Histiacil NF Infantil
    lines.append(
        "UPDATE public.productos SET concentracion = '150 ML', presentacion = '1 JARABE' "
        "WHERE sku = 'FC-89794961' AND activo = true "
        "AND concentracion ILIKE '%OPELLA%';"
    )
    lines.extend(["", "COMMIT;", ""])
    OUT_SQL.write_text("\n".join(lines), encoding="utf-8")
    print(f"SQL → {OUT_SQL}")
    print(f"CSV → {OUT_CSV}")

    if args.apply:
        env = {}
        for line in (ROOT / ".env").read_text(encoding="utf-8").splitlines():
            if "=" in line and not line.strip().startswith("#"):
                k, v = line.split("=", 1)
                env[k.strip()] = v.strip().strip('"').strip("'")
        url = env["REACT_APP_SUPABASE_URL"].rstrip("/")
        key = env.get("SUPABASE_SERVICE_ROLE_KEY") or env.get("REACT_APP_SUPABASE_ANON_KEY")
        if not env.get("SUPABASE_SERVICE_ROLE_KEY"):
            print("AVISO: sin SUPABASE_SERVICE_ROLE_KEY — PATCH directo puede fallar por RLS.")
            print("       Ejecuta el SQL en Supabase SQL Editor:", OUT_SQL)
        headers = {
            "apikey": key,
            "Authorization": f"Bearer {key}",
            "Content-Type": "application/json",
            "Prefer": "return=minimal",
        }
        ok = 0
        for r in renames:
            resp = requests.patch(
                f"{url}/rest/v1/productos",
                headers=headers,
                params={"sku": f"eq.{r['sku']}"},
                json={"nombre": r["new"]},
                timeout=30,
            )
            if resp.status_code not in (200, 204):
                print(f"FAIL {r['sku']}: {resp.status_code} {resp.text[:120]}")
            else:
                ok += 1
        print(f"Apply OK: {ok}/{len(renames)}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
