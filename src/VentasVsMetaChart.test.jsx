import { render, screen } from "@testing-library/react";
import VentasVsMetaChart from "./VentasVsMetaChart";
import { METAS_COLONIA_DEF } from "./utils/turnosMetas";

const CFG = {
  meta_matutino_lv: "1500",
  meta_vespertino_lv: "1500",
  meta_sabado_matutino: "1800",
  meta_sabado_vespertino: "1800",
  meta_domingo: "2200",
  meta_ventas_semana: "20800",
  meta_ventas_mes: "80000",
};

const porDia = {
  "2026-08-21": 3100,
  "2026-08-22": 800,
  "2026-08-23": 12,
};

describe("VentasVsMetaChart", () => {
  test("muestra las tres metas y la raya de cada barra", () => {
    render(
      <VentasVsMetaChart
        porDia={porDia}
        cfg={CFG}
        hoyYmd="2026-08-23"
      />,
    );
    expect(screen.getByLabelText("Metas de hoy, semana y mes")).toBeInTheDocument();
    expect(screen.getByText("Hoy")).toBeInTheDocument();
    expect(screen.getByText("Esta semana")).toBeInTheDocument();
    expect(screen.getByText("Este mes")).toBeInTheDocument();
    expect(screen.getAllByText(/de \$2\.2k/).length).toBeGreaterThan(0);
    expect(screen.getByText(/de \$20\.8k/)).toBeInTheDocument();
    // Mes en curso prorrateado (23/31 de 80k)
    expect(screen.getByText(/de \$59\.4k/)).toBeInTheDocument();
    expect(screen.getByRole("tab", { name: "Día" })).toHaveAttribute("aria-selected", "true");
    expect(document.querySelector("figure.fc-ventas-meta-scroll")).toBeInTheDocument();
    expect(document.querySelectorAll(".fc-ventas-meta-tick").length).toBeGreaterThan(0);
    expect(document.querySelectorAll(".fc-ventas-meta-col").length).toBeGreaterThan(3);
    expect(document.querySelectorAll(".fc-ventas-meta-track").length).toBeGreaterThan(3);
    expect(document.querySelector(".fc-ventas-meta-pair")).toBeNull();
  });

  test("dibuja la barra de ganancia bruta al lado de la venta", () => {
    render(
      <VentasVsMetaChart
        porDia={porDia}
        gananciaPorDia={{ "2026-08-23": 4 }}
        cfg={CFG}
        hoyYmd="2026-08-23"
      />,
    );
    expect(screen.getByText("Ganancia")).toBeInTheDocument();
    expect(document.querySelectorAll(".fc-ventas-meta-pair").length).toBeGreaterThan(3);
    expect(document.querySelectorAll(".fc-ventas-meta-fill.is-ganancia").length).toBeGreaterThan(3);
    expect(screen.getAllByText(/Ganancia \$4/).length).toBeGreaterThan(0);
  });

  test("el 4 de octubre explica por qué la semana se ve más alta que el mes", () => {
    render(
      <VentasVsMetaChart
        porDia={{ "2026-09-30": 5000, "2026-10-04": 1100 }}
        cfg={METAS_COLONIA_DEF}
        hoyYmd="2026-10-04"
      />,
    );
    expect(screen.getByText(/no la meta/)).toBeInTheDocument();
    expect(screen.getAllByText(/\$110\.0k/).length).toBeGreaterThan(0);
    expect(screen.getByText(/ritmo de \$14\.2k/)).toBeInTheDocument();
  });
});
