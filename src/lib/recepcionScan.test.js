import { itemMatchScan, pedidoEsperaEntrada, eanPistolaListo, recepcionEsTicket, matchScanEnTicket } from "./recepcionScan";
import { parseCaducidadMMAA } from "./caducidad";

describe("itemMatchScan — casos reales de piso", () => {
  const tegaderm = {
    sku: "FC-89592876",
    codigo_escaneado: "4001895928765",
    nombre: "Tegaderm 3M 10 x 12 cm C/50",
    confirmado: false,
  };

  test("EAN de la caja abre el renglón (Tegaderm)", () => {
    expect(itemMatchScan(tegaderm, "4001895928765")).toBe(true);
  });

  test("SKU interno también abre", () => {
    expect(itemMatchScan(tegaderm, "FC-89592876")).toBe(true);
  });

  test("no abre otro producto", () => {
    expect(itemMatchScan(tegaderm, "7501289511421")).toBe(false);
  });
});

describe("eanPistolaListo", () => {
  test("EAN-13 listo sin Enter", () => {
    expect(eanPistolaListo("4001895928765")).toBe(true);
  });
  test("a medias, no dispara", () => {
    expect(eanPistolaListo("400189")).toBe(false);
  });
});

describe("pedidoEsperaEntrada", () => {
  test("ticket vivo con cajas sin confirmar", () => {
    expect(pedidoEsperaEntrada({ renglones: 11, sin_confirmar: 11, estado: "borrador" })).toBe(true);
  });
  test("ticket vacío no es pedido vivo", () => {
    expect(pedidoEsperaEntrada({ renglones: 0, estado: "borrador" })).toBe(false);
  });
});

describe("caducidad — no inventar", () => {
  test("0000 no es fecha", () => {
    expect(parseCaducidadMMAA("0000")).toBeNull();
  });
});

describe("ticket: pistola no inventa renglones", () => {
  const items = [
    { origen: "pdf", confirmado: true, codigo_escaneado: "4001895928765", sku: "FC-89592876" },
    { origen: "pdf", confirmado: false, codigo_escaneado: "7501289511421", sku: "FC-9511421" },
  ];
  test("PDF es ticket", () => {
    expect(recepcionEsTicket({ items })).toBe(true);
  });
  test("EAN de Levic no entra en Farmalive", () => {
    expect(matchScanEnTicket(items, "7501342802749")).toEqual({ gris: null, yaConfirmado: null });
  });
});
