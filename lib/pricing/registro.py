"""Registro de adapters disponibles."""

from __future__ import annotations

from lib.pricing.adapter import ProveedorAdapter
from lib.pricing.adapters.abarrotero import AbarroteroAdapter
from lib.pricing.adapters.csv_manual import adapters_farma
from lib.pricing.adapters.exprezo import ExprezoAdapter
from lib.pricing.adapters.mayoreototal import MayoreoTotalAdapter
from lib.pricing.adapters.scorpion import ScorpionAdapter
from lib.pricing.adapters.vtex import ChedrauiAdapter, WalmartAdapter


def todos_adapters() -> dict[str, ProveedorAdapter]:
    lista: list[ProveedorAdapter] = [
        MayoreoTotalAdapter(),
        ScorpionAdapter(),
        AbarroteroAdapter(),
        ExprezoAdapter(),
        ChedrauiAdapter(),
        WalmartAdapter(),
        *adapters_farma(),
    ]
    return {a.nombre.lower(): a for a in lista}


PRIORIDAD_SCRAPE = ["mayoreototal", "scorpion", "abarrotero", "exprezo"]
BENCHMARK = ["chedraui", "walmart"]
