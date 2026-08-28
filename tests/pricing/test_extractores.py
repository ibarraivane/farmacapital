#!/usr/bin/env python3
"""Tests de parsers MayoreoTotal / Scorpion / Abarrotero — fixtures locales, sin red."""

from __future__ import annotations

import json
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))

from lib.pricing.adapters.abarrotero import parsear_producto_wc  # noqa: E402
from lib.pricing.adapters.mayoreototal import parsear_products_json  # noqa: E402
from lib.pricing.adapters.scorpion import parsear_listado  # noqa: E402

FX = Path(__file__).resolve().parent / "fixtures"


class TestMayoreoTotal(unittest.TestCase):
    def test_esquema_y_unitario_calculado(self):
        payload = json.loads((FX / "mayoreototal_products.json").read_text(encoding="utf-8"))
        filas = parsear_products_json(payload, fecha="2026-08-18")
        self.assertEqual(len(filas), 3)
        cols = {
            "fuente", "tipo_fuente", "fecha_captura", "url", "categoria",
            "producto_raw", "marca", "presentacion", "unidad_base",
            "cantidad_empaque", "precio_empaque", "precio_unitario",
            "min_piezas", "precio_escalon", "moneda", "minimo_compra_pedido", "notas",
        }
        self.assertTrue(cols.issubset(filas[0].keys()))
        self.assertEqual(filas[0]["fuente"], "MayoreoTotal")
        self.assertEqual(filas[0]["tipo_fuente"], "mayorista")

        jabon = next(f for f in filas if "Asepxia" in f["producto_raw"])
        # caja $720 / 36 barras = $20, no el precio de caja
        self.assertEqual(jabon["precio_empaque"], 720.0)
        self.assertAlmostEqual(jabon["precio_unitario"], 20.0)
        self.assertEqual(jabon["unidad_base"], "g")

        locion = next(f for f in filas if "236" in f["producto_raw"])
        self.assertIn("Pure Seduction", locion["producto_raw"])
        self.assertAlmostEqual(locion["precio_unitario"], 419.0)
        self.assertEqual(locion["unidad_base"], "ml")


class TestScorpion(unittest.TestCase):
    def test_escalon_y_caja(self):
        html = (FX / "scorpion_listado.html").read_text(encoding="utf-8")
        filas = parsear_listado(html, fecha="2026-08-18", categoria="proteccion-femenina")
        self.assertEqual(len(filas), 2)
        saba = next(f for f in filas if "Saba" in f["producto_raw"])
        self.assertEqual(saba["min_piezas"], 3)
        self.assertAlmostEqual(saba["precio_escalon"], 19.90)
        self.assertAlmostEqual(saba["precio_empaque"], 278.60)
        # 14 packs × 8 toallas = 112 piezas individuales
        self.assertEqual(saba["cantidad_empaque"], 112)
        self.assertAlmostEqual(saba["precio_unitario"], 278.60 / 112, places=3)

        suave = next(f for f in filas if "Suavelastic" in f["producto_raw"])
        self.assertEqual(suave["cantidad_empaque"], 160)  # 4×40
        self.assertAlmostEqual(suave["precio_unitario"], 882.40 / 160, places=3)


class TestAbarrotero(unittest.TestCase):
    def test_tachado_y_caja(self):
        productos = json.loads((FX / "abarrotero_products.json").read_text(encoding="utf-8"))
        vick = parsear_producto_wc(productos[0], fecha="2026-08-18")
        self.assertEqual(vick["fuente"], "Abarrotero")
        self.assertIn("tachado=18000", vick["notas"])
        self.assertAlmostEqual(vick["precio_empaque"], 17236)
        # caja 48 × barra 100g → unitario por pieza (barra)
        self.assertEqual(vick["cantidad_empaque"], 48)
        self.assertAlmostEqual(vick["precio_unitario"], 17236 / 48, places=3)

        treda = parsear_producto_wc(productos[1], fecha="2026-08-18")
        self.assertIn("tachado=2043", treda["notas"])
        self.assertAlmostEqual(treda["precio_actual"] if False else treda["precio_empaque"], 1857)


if __name__ == "__main__":
    unittest.main()
