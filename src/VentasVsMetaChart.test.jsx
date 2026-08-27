import { render, screen } from "@testing-library/react";
import VentasVsMetaChart from "./VentasVsMetaChart";

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
    expect(screen.getByText(/de \$80\.0k/)).toBeInTheDocument();
    expect(screen.getByRole("tab", { name: "Día" })).toHaveAttribute("aria-selected", "true");
    expect(document.querySelectorAll(".fc-ventas-meta-tick").length).toBeGreaterThan(0);
  });
});
