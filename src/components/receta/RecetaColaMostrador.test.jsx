import { render, screen, fireEvent } from "@testing-library/react";
import RecetaColaMostrador from "./RecetaColaMostrador";

const receta = {
  id: 9,
  folio: "FC-RX-2026-000042",
  paciente_nombre: "Ana Pérez",
  medico_nombre: "Dra. Lucio",
  estado: "en_caja",
  medicamentos: [
    { producto_id: 1, medicamento: "Amoxicilina 500", cantidad: 1, dosis: "1 cáps", frecuencia: "c/8 h" },
    { producto_id: null, medicamento: "Crema externa", dosis: "aplicar" },
  ],
};

describe("RecetaColaMostrador", () => {
  test("muestra folio, posología y acciones Brother / surtir", () => {
    const onImprimir = jest.fn();
    const onSurtir = jest.fn();
    render(<RecetaColaMostrador recetas={[receta]} onImprimir={onImprimir} onSurtir={onSurtir} />);
    expect(screen.getByText(/FC-RX-2026-000042/)).toBeInTheDocument();
    expect(screen.getByText(/Amoxicilina 500/)).toBeInTheDocument();
    expect(screen.getByText(/no lo vendemos/i)).toBeInTheDocument();
    fireEvent.click(screen.getByRole("button", { name: /Imprimir en Brother/i }));
    fireEvent.click(screen.getByRole("button", { name: /Surtir en mostrador/i }));
    expect(onImprimir).toHaveBeenCalledWith(receta);
    expect(onSurtir).toHaveBeenCalledWith(receta);
  });

  test("compacto avisa y manda a ver recetas", () => {
    const onVerTodas = jest.fn();
    render(<RecetaColaMostrador compact recetas={[receta]} onVerTodas={onVerTodas} />);
    fireEvent.click(screen.getByRole("button", { name: /Ver recetas/i }));
    expect(onVerTodas).toHaveBeenCalled();
  });
});
