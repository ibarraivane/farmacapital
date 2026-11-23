#!/usr/bin/env python3
"""City Mark ticket 20261123 (fotos) → altas + cola Recibir.

Ticket PUBLICO EN GENERAL · Cajera 1 · 36 renglones · 50 pzas · $1,710.16
P.U. ya incluyen IVA (suma qty×P.U. = total). Sin folio en papel → YYYYMMDD.
Nombres de mostrador (no código de ticket). Caducidad null (MMAA de la caja).
SIN producto_imagenes en el mismo txn. SIN bloques dollar-quote.
"""
from __future__ import annotations

import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT_SQL = ROOT / "sql" / "patch_recibir_citymark_20261123_SOLO_pegar_esto.sql"
OUT_MD = ROOT / "sql" / "LEERME_citymark_20261123_SOLO_pegar_esto.md"
FOTO = "https://www.farmacapital.mx/catalogo-propia"


def ceil_pvp(costo: float, tipo: str) -> int:
    return int(math.ceil(costo * (1.25 if tipo == "marca" else 1.6)))


def sku_de(ean: str) -> str:
    return "FC-" + ean[-8:]


def sql_str(v) -> str:
    if v is None:
        return "null"
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, (int, float)) and not isinstance(v, bool):
        return str(v)
    return "'" + str(v).replace("'", "''") + "'"


def foto(name: str | None) -> str | None:
    if not name:
        return None
    return f"{FOTO}/{name}"


def P(
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
        "ean": ean,
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
        "foto": foto(foto_file),
    }


# Fichas de mostrador. Clave = EAN.
CAT: dict[str, dict] = {
    "037836007279": P(
        "037836007279",
        nombre="Conseguau Aloe Vera shampoo para perro",
        categoria="Mascotas",
        forma="Shampoo",
        marca="Conseguau",
        laboratorio="Grisi",
        presentacion="400 ml",
        ya=True,
    ),
    "7501054555728": P(
        "7501054555728",
        nombre="Nivea Milk Nutritiva pack 1 L + 100 ml",
        categoria="Cuidado de la piel",
        forma="Crema corporal",
        marca="Nivea",
        laboratorio="Beiersdorf",
        presentacion="Pack 1 L + 100 ml",
        ya=False,
    ),
    "7501103300200": P(
        "7501103300200",
        nombre="T.Taio Bath Time esponja redonda estampada",
        categoria="Cuidado personal",
        forma="Esponja",
        marca="T.Taio",
        presentacion="1 pieza",
        ya=False,
    ),
    "037836050930": P(
        "037836050930",
        nombre="Ricitos de Oro jabón líquido y shampoo lavanda lechuga",
        categoria="Cuidado bebé",
        forma="Pack",
        marca="Ricitos de Oro",
        laboratorio="Grisi",
        presentacion="400 ml + dosificador",
        ya=False,
    ),
    "7501019031137": P(
        "7501019031137",
        nombre="Saba Amore Regular con alas",
        categoria="Higiene femenina",
        forma="Toallas sanitarias",
        marca="Saba",
        laboratorio="Essity",
        presentacion="Caja con 8 piezas",
        ya=False,
    ),
    "7501019006388": P(
        "7501019006388",
        nombre="Saba Invisible con alas",
        categoria="Higiene femenina",
        forma="Toallas sanitarias",
        marca="Saba",
        laboratorio="Essity",
        presentacion="Caja con 14 piezas",
        ya=False,
    ),
    "850040940619": P(
        "850040940619",
        nombre="Ricitos de Oro shampoo lavanda pack",
        categoria="Cuidado bebé",
        forma="Shampoo",
        marca="Ricitos de Oro",
        laboratorio="Grisi",
        presentacion="500 ml + 100 ml",
        ya=False,
    ),
    "7501054549796": P(
        "7501054549796",
        nombre="Nivea Milk Nutritiva extra seca",
        categoria="Cuidado de la piel",
        forma="Crema corporal",
        marca="Nivea",
        laboratorio="Beiersdorf",
        presentacion="100 ml",
        ya=False,
    ),
    "037836021060": P(
        "037836021060",
        nombre="Ricitos de Oro gel manzanilla",
        categoria="Cuidado bebé",
        forma="Gel",
        marca="Ricitos de Oro",
        laboratorio="Grisi",
        presentacion="125 ml",
        ya=False,
    ),
    "037836033797": P(
        "037836033797",
        nombre="Ricitos de Oro Bio Pure",
        categoria="Cuidado bebé",
        forma="Loción",
        marca="Ricitos de Oro",
        laboratorio="Grisi",
        presentacion="100 ml",
        ya=False,
    ),
    "037836040368": P(
        "037836040368",
        nombre="Ricitos de Oro agua de colonia spray",
        categoria="Cuidado bebé",
        forma="Spray",
        marca="Ricitos de Oro",
        laboratorio="Grisi",
        presentacion="100 ml",
        ya=False,
    ),
    "037836040535": P(
        "037836040535",
        nombre="Ricitos de Oro crema corporal lavanda",
        categoria="Cuidado bebé",
        forma="Crema corporal",
        marca="Ricitos de Oro",
        laboratorio="Grisi",
        presentacion="100 ml",
        ya=False,
    ),
    "037836041259": P(
        "037836041259",
        nombre="Hinds crema líquida rosa",
        categoria="Cuidado de la piel",
        forma="Crema líquida",
        marca="Hinds",
        laboratorio="Grisi",
        presentacion="90 ml",
        ya=False,
    ),
    "037836041297": P(
        "037836041297",
        nombre="Hinds Inspiration crema líquida",
        categoria="Cuidado de la piel",
        forma="Crema líquida",
        marca="Hinds",
        laboratorio="Grisi",
        presentacion="90 ml",
        ya=False,
    ),
    "037836041389": P(
        "037836041389",
        nombre="Hinds Hidratación Extra crema líquida pesca",
        categoria="Cuidado de la piel",
        forma="Crema líquida",
        marca="Hinds",
        laboratorio="Grisi",
        presentacion="90 ml",
        ya=False,
    ),
    "7501007528939": P(
        "7501007528939",
        nombre="Lubriderm Reparación Intensiva",
        categoria="Cuidado de la piel",
        forma="Crema corporal",
        marca="Lubriderm",
        laboratorio="Johnson & Johnson",
        presentacion="120 ml",
        ya=True,
    ),
    "7702035469151": P(
        "7702035469151",
        nombre="Lubriderm UV",
        categoria="Cuidado de la piel",
        forma="Crema corporal",
        marca="Lubriderm",
        laboratorio="Johnson & Johnson",
        presentacion="120 ml",
        concentracion="FPS 15",
        ya=True,
    ),
    "7702031244486": P(
        "7702031244486",
        nombre="Lubriderm piel normal",
        categoria="Cuidado de la piel",
        forma="Crema corporal",
        marca="Lubriderm",
        laboratorio="Johnson & Johnson",
        presentacion="120 ml",
        ya=True,
        foto_file="lubriderm-piel-normal-120ml.jpg",
    ),
    "037836084829": P(
        "037836084829",
        nombre="Ricitos de Oro shampoo manzanilla miel + crema corporal",
        categoria="Cuidado bebé",
        forma="Pack",
        marca="Ricitos de Oro",
        laboratorio="Grisi",
        presentacion="400 ml + 100 ml",
        ya=False,
    ),
    "7501022130063": P(
        "7501022130063",
        nombre="Ricitos de Oro shampoo miel",
        categoria="Cuidado bebé",
        forma="Shampoo",
        marca="Ricitos de Oro",
        laboratorio="Grisi",
        presentacion="100 ml",
        ya=False,
    ),
    "5050456009190": P(
        "5050456009190",
        nombre="Playboy Goddess Come desodorante spray",
        categoria="Desodorantes",
        forma="Spray",
        marca="Playboy",
        presentacion="150 ml",
        ya=False,
    ),
    "5050456009176": P(
        "5050456009176",
        nombre="Playboy Play It Sexy desodorante spray",
        categoria="Desodorantes",
        forma="Spray",
        marca="Playboy",
        presentacion="150 ml",
        ya=False,
    ),
    "5050456009206": P(
        "5050456009206",
        nombre="Playboy Wham Glam desodorante spray",
        categoria="Desodorantes",
        forma="Spray",
        marca="Playboy",
        presentacion="150 ml",
        ya=False,
    ),
    "7501019006371": P(
        "7501019006371",
        nombre="Saba Invisible con alas",
        categoria="Higiene femenina",
        forma="Toallas sanitarias",
        marca="Saba",
        laboratorio="Essity",
        presentacion="Caja con 10 piezas",
        ya=False,
    ),
    "7501019035876": P(
        "7501019035876",
        nombre="Saba Amore Nocturna Super Absorción con alas",
        categoria="Higiene femenina",
        forma="Toallas sanitarias",
        marca="Saba",
        laboratorio="Essity",
        presentacion="Caja con 8 piezas",
        ya=False,
    ),
    "7501017360604": P(
        "7501017360604",
        nombre="Kotex Anti Flujo Abundante sin alas",
        categoria="Higiene femenina",
        forma="Toallas sanitarias",
        marca="Kotex",
        laboratorio="Kimberly-Clark",
        presentacion="Paquete con 10 piezas",
        ya=False,
    ),
    "7501017360789": P(
        "7501017360789",
        nombre="Kotex Anatómica Delgada con alas",
        categoria="Higiene femenina",
        forma="Toallas sanitarias",
        marca="Kotex",
        laboratorio="Kimberly-Clark",
        presentacion="Paquete con 10 piezas",
        ya=False,
    ),
    "7501943410893": P(
        "7501943410893",
        nombre="Kotex Protect rosa",
        categoria="Higiene femenina",
        forma="Toallas sanitarias",
        marca="Kotex",
        laboratorio="Kimberly-Clark",
        presentacion="Paquete con 7 piezas",
        ya=False,
    ),
    "7501019031144": P(
        "7501019031144",
        nombre="Saba Amore Regular sin alas",
        categoria="Higiene femenina",
        forma="Toallas sanitarias",
        marca="Saba",
        laboratorio="Essity",
        presentacion="Caja con 8 piezas",
        ya=False,
    ),
    "7501048335305": P(
        "7501048335305",
        nombre="Protec agua oxigenada",
        tipo="generico",
        categoria="Botiquin",
        forma="Solución",
        marca="Protec",
        presentacion="480 ml",
        principio="Peróxido de hidrógeno",
        ya=True,
    ),
    "7502004531366": P(
        "7502004531366",
        nombre="Selecta agua oxigenada",
        tipo="generico",
        categoria="Botiquin",
        forma="Solución",
        marca="Selecta",
        presentacion="250 ml",
        principio="Peróxido de hidrógeno",
        ya=False,
    ),
    "7502004530758": P(
        "7502004530758",
        nombre="Selecta agua oxigenada",
        tipo="generico",
        categoria="Botiquin",
        forma="Solución",
        marca="Selecta",
        presentacion="110 ml",
        principio="Peróxido de hidrógeno",
        ya=False,
    ),
    "5050456009183": P(
        "5050456009183",
        nombre="Playboy Keep It Real desodorante spray",
        categoria="Desodorantes",
        forma="Spray",
        marca="Playboy",
        presentacion="150 ml",
        ya=False,
    ),
    "4068359345674": P(
        "4068359345674",
        nombre="Koleston Rubio Mediano 70",
        categoria="Cuidado del cabello",
        forma="Tinte",
        marca="Koleston",
        laboratorio="Wella",
        presentacion="Kit 1 pieza",
        concentracion="70",
        ya=False,
    ),
    "4068359345797": P(
        "4068359345797",
        nombre="Koleston Rubio Mate 72",
        categoria="Cuidado del cabello",
        forma="Tinte",
        marca="Koleston",
        laboratorio="Wella",
        presentacion="Kit 1 pieza",
        concentracion="72",
        ya=False,
    ),
    "7501056340131": P(
        "7501056340131",
        nombre="Sedal Rizos Obedientes crema para peinar",
        categoria="Cuidado del cabello",
        forma="Crema para peinar",
        marca="Sedal",
        laboratorio="Unilever",
        presentacion="300 ml",
        ya=True,
    ),
}


# Ticket lines: (ean, snap, qty, pu)
LINES: list[tuple[str, str, int, float]] = [
    ("037836007279", "SH PERRO CONSE GUAU ALOE VERA 400ML", 2, 45.665),
    ("7501054555728", "CRM NIVEA 1LT PACK + CRM NIVEA 100ML", 1, 262.980),
    ("7501103300200", "TTAIO ESPONJA REDONDA ESTAMPADA", 2, 16.740),
    ("037836050930", "RICITOS DE ORO 400ML JBN LIQ Y SH LAV LECHUGA + DOSIFICADOR", 1, 85.900),
    ("7501019031137", "TAS SANIT SABA AMORE REG ALAS C/8", 2, 12.845),
    ("7501019006388", "TAS SANIT SABA INV ALAS C/14 E638", 1, 35.990),
    ("850040940619", "SH RICITOS DE ORO 500ML LAVANDA + 100ML SH LAVANDA", 1, 98.500),
    ("7501054549796", "CRA CORP NIV MILK N EX/SECA 100ML", 2, 26.960),
    ("037836021060", "GEL RICITOS DE ORO MZLLA 125 ML", 1, 37.290),
    ("037836033797", "RICITOS DE ORO 100ML BIO PURE", 1, 18.900),
    ("037836040368", "AGUA COL RICITOS ORO SPY 100 ML", 1, 39.070),
    ("037836040535", "RICITOS DE ORO 100ML CRA CORP LAVANDA C3 6 AB", 2, 18.895),
    ("037836041259", "CRA HINDS LIQ RSA RCA 90ML", 2, 18.740),
    ("037836041297", "CRA HINDS INSP LIQ RCA 90ML MAY27", 2, 16.300),
    ("037836041389", "CRA HINDS HID-EXT LIQ PSCA 90ML", 2, 18.740),
    ("7501007528939", "CRA LUBRIDERM THINT PSEC120ML", 1, 31.590),
    ("7702035469151", "CRA LUBRIDERM UV FPS15 120ML DIC27", 1, 34.410),
    ("7702031244486", "CRA LUBRIDERM P/NORMAL 120ML", 1, 31.590),
    ("037836084829", "RICITOS DE ORO 400ML SH MNZLLA MIEL + 100ML CRA CORP", 1, 85.900),
    ("7501022130063", "SH GRISI RICITOS ORO MIEL 100 ML", 1, 29.800),
    ("5050456009190", "DESOD PLAYBOY GODDES COM SPY 150ML", 1, 53.420),
    ("5050456009176", "DESOD PLAYBOY PLAY SEXY SPY 150ML", 1, 51.610),
    ("5050456009206", "DESOD PLAY BOY WHAM GLAM SPY 150ML", 1, 53.500),
    ("7501019006371", "TAS SANIT SABA INV ALAS C/10", 1, 21.350),
    ("7501019035876", "TAS SANIT SABA AMORE NOCSUP-ABC/A 8", 3, 14.180),
    ("7501017360604", "TAS SAN KOTEX ANT FLUJO ABUNDANTE S/A 10PZ", 2, 21.210),
    ("7501017360789", "TAS SANIT KOTEX ANAT DELG ALAS 10", 1, 18.110),
    ("7501943410893", "TAS SANIT KOTEXP1 ROSA C7", 1, 9.920),
    ("7501019031144", "TAS SANIT SABA AMORE REG S/ALAS 8", 1, 10.820),
    ("7501048335305", "PROTEC AGUA OXIGENADA 480 ML", 2, 13.600),
    ("7502004531366", "SELECTA AGUA OXIGENADA 250ML", 2, 8.420),
    ("7502004530758", "SELECTA AGUA OXIGENADA 110ML", 2, 5.245),
    ("5050456009183", "DESOD PLAY BOY KEEP IREAL SPY 150ML", 1, 53.500),
    ("4068359345674", "KOLESTON TIN RUBIO MEDIANO 70", 1, 53.340),
    ("4068359345797", "TIN KOLESTON RUBIO MATE 72", 1, 53.340),
    ("7501056340131", "CRA SEDAL RIZOS OBEDIE 300ML", 1, 50.070),
]


def build_rows() -> list[dict]:
    out = []
    for ean, snap, qty, pu in LINES:
        f = CAT[ean]
        costo = round(pu, 2)
        out.append(
            {
                **f,
                "snap": snap[:60],
                "qty": qty,
                "pu": costo,
                "precio": ceil_pvp(costo, f["tipo"]),
                "sub": round(qty * pu, 2),
            }
        )
    return out


def render(rows: list[dict]) -> str:
    tmp = "_fc_cm_20261123"
    folio = "20261123"
    proveedor = "City Mark"
    ilike = sql_str("%city mark%")
    vals = []
    for i, r in enumerate(rows, start=1):
        vals.append(
            "  ({linea}, {ean}, {sku}, {nombre}, {snap}, {qty}, {costo}, {precio}, "
            "{tipo}, {cat}, {sub}, {forma}, {marca}, {lab}, {pres}, {pa}, {conc}, "
            "{receta}, {ya}, {img}, {lote})".format(
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
                sub=sql_str(r["subcategoria"]),
                forma=sql_str(r["forma"]),
                marca=sql_str(r["marca"]),
                lab=sql_str(r["laboratorio"]),
                pres=sql_str(r["presentacion"]),
                pa=sql_str(r["principio"]),
                conc=sql_str(r["concentracion"]),
                receta=sql_str(r["receta"]),
                ya=sql_str(r["ya"]),
                img=sql_str(r["foto"]),
                lote="null",
            )
        )
    n_alta = sum(1 for r in rows if not r["ya"])
    n_ya = sum(1 for r in rows if r["ya"])
    total = 1710.16
    notas = (
        "City Mark · folio 20261123 · ticket PUBLICO EN GENERAL · Cajera 1 · "
        "36 renglones · 50 pzas · P.U. con IVA (suma = total $1,710.16) · "
        "tarjeta crédito · cola Recibir; stock al confirmar pistola"
    )
    return f"""-- =============================================================================
-- PEGAR TODO ESTE ARCHIVO en Supabase → SQL Editor → Run
-- City Mark 20261123 · $1,710.16 · 36 renglones · 50 pzas
-- Merge a GitHub NO crea la cola. Sin dollar-quote. Sin producto_imagenes.
-- Caducidad null: MMAA de la caja. No inventar 0000.
-- =============================================================================

rollback;

-- ========== City Mark 20261123 ==========
-- City Mark · folio 20261123 · 2026-11-23 · total $1,710.16 · 36 renglones
-- {n_alta} alta(s) stock 0. {n_ya} ya estaban: solo costo / ficha vacia, no PVP.
-- Nombres de ficha, no del ticket. SIN dollar-quote. Idempotente en borrador.
-- Caducidad null: MMAA de la caja. No inventar 0000.

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
  lote text
) on commit drop;

insert into {tmp} (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, lote
) values
{chr(10).join(v + (',' if i < len(vals) else '') for i, v in enumerate(vals, start=1))};

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when not exists (
      select 1 from public.productos p where p.sku = t.sku
    ) then t.sku
    when t.ean is not null and not exists (
      select 1 from public.productos p
      where p.sku = ('FC-ND-' || right(t.ean, 8))
    ) then 'FC-ND-' || right(t.ean, 8)
    when t.ean is not null then
      'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.ean, 8)
    else 'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.sku, 8)
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta City Mark 20261123 · 2026-11-23 · listo para pistola',
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
  select distinct on (coalesce(ean, sku)) *
  from {tmp}
  order by coalesce(ean, sku), linea
) t
where (t.ean is null or not exists (
    select 1 from public.productos p
    where nullif(btrim(p.codigo_barras), '') = t.ean
  ))
  and not exists (
    select 1 from public.productos p
    where p.sku = t.sku
      and (
        t.ean is null
        or nullif(btrim(p.codigo_barras), '') is null
        or nullif(btrim(p.codigo_barras), '') = t.ean
      )
  )
  and not exists (
    select 1 from public.productos p
    where p.sku = (
      case
        when not exists (
          select 1 from public.productos x where x.sku = t.sku
        ) then t.sku
        when t.ean is not null and not exists (
          select 1 from public.productos x
          where x.sku = ('FC-ND-' || right(t.ean, 8))
        ) then 'FC-ND-' || right(t.ean, 8)
        when t.ean is not null then
          'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.ean, 8)
        else 'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.sku, 8)
      end
    )
  );

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from (
  select distinct on (coalesce(ean, sku)) *
  from {tmp}
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku),
  (
    select p2.id from public.productos p2
    where t.ean is not null
      and nullif(btrim(p2.codigo_barras), '') = t.ean
    order by p2.id
    limit 1
  ),
  (
    select p2.id from public.productos p2
    where p2.sku = t.sku
    order by p2.id
    limit 1
  )
)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

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
  codigo_barras = coalesce(nullif(p.codigo_barras, ''), t.ean)
from (
  select distinct on (coalesce(ean, sku)) *
  from {tmp}
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku),
  (
    select p2.id from public.productos p2
    where t.ean is not null
      and nullif(btrim(p2.codigo_barras), '') = t.ean
    order by p2.id
    limit 1
  ),
  (
    select p2.id from public.productos p2
    where p2.sku = t.sku
    order by p2.id
    limit 1
  )
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  {sql_str(proveedor)},
  {sql_str(folio)},
  '2026-11-23',
  {total:.2f},
  'borrador',
  {sql_str(notas)}
where not exists (
  select 1 from public.recepciones
  where folio = {sql_str(folio)}
    and coalesce(proveedor, '') ilike {ilike}
);

update public.recepciones
set
  total_ticket = {total:.2f},
  fecha = '2026-11-23',
  proveedor = {sql_str(proveedor)},
  notas = {sql_str(notas)},
  updated_at = now()
where folio = {sql_str(folio)}
  and coalesce(proveedor, '') ilike {ilike}
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = {sql_str(folio)}
  and coalesce(r.proveedor, '') ilike {ilike}
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  v.pid,
  coalesce(nullif(btrim(t.ean), ''), t.sku),
  t.snap,
  t.qty,
  null,
  t.lote,
  t.costo,
  (v.pid is null),
  'pdf',
  false,
  false,
  null
from {tmp} t
join public.recepciones r
  on r.folio = {sql_str(folio)}
 and coalesce(r.proveedor, '') ilike {ilike}
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.ean), ''))
      else null end,
    public.fc_buscar_producto_escaneo(t.sku),
    (
      select p2.id from public.productos p2
      where nullif(btrim(t.ean), '') is not null
        and nullif(btrim(p2.codigo_barras), '') = nullif(btrim(t.ean), '')
      order by p2.id
      limit 1
    ),
    (
      select p2.id from public.productos p2
      where p2.sku = t.sku
      order by p2.id
      limit 1
    )
  ) as pid
) v on true
order by t.linea;

select
  r.folio,
  r.proveedor,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  sum(i.cantidad) as piezas,
  count(*) filter (where i.confirmado is not true) as sin_confirmar,
  bool_or(i.pendiente_alta) as tiene_pendiente_alta
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = {sql_str(folio)}
  and coalesce(r.proveedor, '') ilike {ilike}
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.sku,
  t.nombre,
  t.qty,
  t.costo,
  t.lote,
  case
    when coalesce(
      case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
      public.fc_buscar_producto_escaneo(t.sku),
      (
        select p2.id from public.productos p2
        where t.ean is not null
          and nullif(btrim(p2.codigo_barras), '') = t.ean
        order by p2.id
        limit 1
      ),
      (
        select p2.id from public.productos p2
        where p2.sku = t.sku
        order by p2.id
        limit 1
      )
    ) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from {tmp} t
order by t.linea;

commit;
"""


def main() -> None:
    rows = build_rows()
    missing = [ean for ean, *_ in LINES if ean not in CAT]
    if missing:
        raise SystemExit(f"Faltan fichas: {missing}")
    s = round(sum(r["sub"] for r in rows), 2)
    if abs(s - 1710.16) > 0.02:
        raise SystemExit(f"suma {s} != 1710.16")
    piezas = sum(r["qty"] for r in rows)
    if piezas != 50:
        raise SystemExit(f"piezas {piezas} != 50")
    print(f"20261123: {len(rows)} rows · sum {s} · piezas {piezas}")

    sql = render(rows)
    if "$$" in sql:
        raise SystemExit("ERROR: el SQL contiene $$ (dollar-quote)")
    OUT_SQL.write_text(sql, encoding="utf-8")
    OUT_MD.write_text(
        f"""# City Mark 20261123 — pegar en Supabase

Ticket PUBLICO EN GENERAL · Cajera 1 · **$1,710.16** · 50 pzas · 36 renglones.
P.U. con IVA (suma = total). Sin folio en papel → `20261123`.

## Pegar ahora

1. Raw: https://raw.githubusercontent.com/ibarraivane/farmacapital/main/sql/patch_recibir_citymark_20261123_SOLO_pegar_esto.sql
2. Selecciona TODO → copiar → Supabase SQL Editor → **Run**
3. VERIFICACION: folio `20261123`, estado `borrador`, 36 renglones, 50 piezas
4. Tablet: Recibir → recargar → tarjeta **City Mark · 20261123**

Sin lote en el papel. MMAA de la caja. Si Run marca rojo, manda el texto.

## Mapeo rápido

| # | Ticket | EAN | SKU |
|---|---|---|---|
"""
        + "\n".join(
            f"| {i} | {r['snap'][:40]} | `{r['ean']}` | `{r['sku']}` |"
            for i, r in enumerate(rows, start=1)
        )
        + "\n",
        encoding="utf-8",
    )
    print(f"→ {OUT_SQL.relative_to(ROOT)} ({OUT_SQL.stat().st_size} bytes)")
    print(f"→ {OUT_MD.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
