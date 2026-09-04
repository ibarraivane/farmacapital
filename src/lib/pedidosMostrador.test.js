import { describe, expect, it } from "vitest";
import {
  puedeGuardarSolicitud,
  normalizarTextoSolicitud,
  siguientesEstados,
  etiquetaTipo,
  etiquetaPago,
} from "./pedidosMostrador.js";

describe("pedidosMostrador", () => {
  it("normaliza espacios y recorta", () => {
    expect(normalizarTextoSolicitud("  bumetadina   1mg  ")).toBe("bumetadina 1mg");
  });

  it("exige texto y cantidad válidos para guardar", () => {
    expect(puedeGuardarSolicitud({ texto: "a", cantidad: 1 })).toBe(false);
    expect(puedeGuardarSolicitud({ texto: "Clonazepam", cantidad: 1 })).toBe(true);
    expect(puedeGuardarSolicitud({ texto: "Clonazepam", cantidad: 0 })).toBe(false);
  });

  it("sugiere siguientes estados desde pendiente", () => {
    expect(siguientesEstados("pendiente")).toContain("pedir");
    expect(siguientesEstados("pedido")).toContain("llego");
  });

  it("etiqueta tipo y pago", () => {
    expect(etiquetaTipo("agotado")).toMatch(/Agotado/);
    expect(etiquetaTipo("no_catalogo")).toMatch(/catálogo/i);
    expect(etiquetaPago("nada")).toMatch(/Sin anticipo/i);
    expect(etiquetaPago("deposito", 50)).toMatch(/50/);
    expect(etiquetaPago("completo", 200)).toMatch(/todo/i);
  });
});
