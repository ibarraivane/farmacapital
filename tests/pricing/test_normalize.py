#!/usr/bin/env python3
"""Tests de normalización — sin red."""

from __future__ import annotations

import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))

from lib.pricing.normalize import (  # noqa: E402
    corregir_marca,
    expandir_abreviaturas,
    extraer_tamano,
    inferir_tipo,
    precio_por_unidad_base,
    tamanos_equivalentes,
)


class TestAbreviaturas(unittest.TestCase):
    def test_jbn_asepxia_bicarbon(self):
        n = expandir_abreviaturas("Jbn Asepxia Bicarbon Sod 100G")
        self.assertIn("jabon", n)
        self.assertIn("bicarbonato de sodio", n)
        self.assertIn("asepxia", n)

    def test_jbn_asexia_exfol(self):
        n = expandir_abreviaturas("Jbn Asexia Exfol 100G")
        self.assertIn("jabon", n)
        self.assertIn("exfoliante", n)

    def test_sh_shampoo(self):
        self.assertIn("shampoo", expandir_abreviaturas("Sh Pantene 400ML"))


class TestTamano(unittest.TestCase):
    def test_litro_igual_1000_ml(self):
        a = extraer_tamano("Fabuloso 1 L")
        b = extraer_tamano("Fabuloso 1000 ML")
        self.assertIsNotNone(a)
        self.assertIsNotNone(b)
        self.assertTrue(tamanos_equivalentes(a, b))
        self.assertEqual(a.unidad, "ml")
        self.assertEqual(a.cantidad, 1000)

    def test_gramos(self):
        t = extraer_tamano("Jabon Asepxia 100G")
        self.assertEqual(t.unidad, "g")
        self.assertEqual(t.cantidad, 100)

    def test_pack_4_40(self):
        t = extraer_tamano("Suavelastic Pañal Max Jumbo 4/40 Pz")
        self.assertEqual(t.unidad, "pza")
        self.assertEqual(t.cantidad, 40)
        self.assertEqual(t.empaque_unidades, 4)
        self.assertEqual(t.piezas_totales(), 160)

    def test_caja_con(self):
        t = extraer_tamano("Vick Vaporub 100g. Caja con 48 piezas.")
        self.assertEqual(t.unidad, "g")
        self.assertEqual(t.cantidad, 100)
        self.assertEqual(t.empaque_unidades, 48)

    def test_tolerancia_2_pct(self):
        a = extraer_tamano("400 ml")
        b = extraer_tamano("408 ml")
        self.assertTrue(tamanos_equivalentes(a, b, 0.02))
        c = extraer_tamano("500 ml")
        self.assertFalse(tamanos_equivalentes(a, c, 0.02))


class TestMarcaYTipo(unittest.TestCase):
    def test_typo_asexia(self):
        marca, score = corregir_marca("asexia", ["Asepxia", "Pantene", "Saba"])
        self.assertEqual(marca, "asepxia")
        self.assertGreaterEqual(score, 82)

    def test_tipo_jabon(self):
        self.assertEqual(inferir_tipo("Jbn Asepxia Exfol 100G"), "jabon")

    def test_precio_por_100g_no_caja(self):
        t = extraer_tamano("Jabon 100 g caja con 36")
        # caja $720 → $20 por barra → $20 / 100 g
        self.assertAlmostEqual(precio_por_unidad_base(20.0, t), 20.0)
        # si alguien pasara el precio de caja por error, 720/100*100 = 720 (distinto)
        self.assertNotAlmostEqual(precio_por_unidad_base(720.0, t), 20.0)


if __name__ == "__main__":
    unittest.main()
