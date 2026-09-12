import {
  IMPRESORA_RECETA,
  IMPRESORA_TICKET,
  LEYENDA_IMPRESORA_RECETA,
  esImpresoraTermica,
  esImpresoraLaserReceta,
  elegirImpresoraTermica,
  elegirImpresoraReceta,
} from "./impresoras";

describe("impresoras del local", () => {
  test("receta es Brother carta simplex; ticket es Epson 80 mm", () => {
    expect(IMPRESORA_RECETA.modelo).toBe("DCP-L2660DW");
    expect(IMPRESORA_RECETA.papel).toBe("letter");
    expect(IMPRESORA_RECETA.duplex).toBe(false);
    expect(IMPRESORA_TICKET.papel).toBe("80mm");
    expect(LEYENDA_IMPRESORA_RECETA).toMatch(/Brother DCP-L2660DW/);
    expect(LEYENDA_IMPRESORA_RECETA).toMatch(/no uses la epson/i);
  });

  test("distingue térmica y láser por el nombre de Windows", () => {
    expect(esImpresoraTermica("Epson TM-T20III")).toBe(true);
    expect(esImpresoraTermica("Brother DCP-L2660DW")).toBe(false);
    expect(esImpresoraLaserReceta("Brother DCP-L2660DW Printer")).toBe(true);
    expect(esImpresoraLaserReceta("DCP-L2660DW")).toBe(true);
    expect(esImpresoraLaserReceta("Epson TM-T20III")).toBe(false);
  });

  test("no manda tickets a la Brother ni recetas a la Epson", () => {
    const mix = ["Brother DCP-L2660DW", "Epson TM-T20III", "Microsoft Print to PDF"];
    expect(elegirImpresoraTermica(mix)).toBe("Epson TM-T20III");
    expect(elegirImpresoraReceta(mix)).toBe("Brother DCP-L2660DW");
    expect(elegirImpresoraTermica(["Brother DCP-L2660DW"])).toBe(null);
    expect(elegirImpresoraReceta(["Epson TM-T20III"])).toBe(null);
  });
});
