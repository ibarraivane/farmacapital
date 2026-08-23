import { servicioTicketInner } from "./servicioTicket";

describe("ticket de recarga", () => {
  test("lleva folio, teléfono, recargo y total; no menciona Mercado Pago", () => {
    const html = servicioTicketInner({
      folio: "SRV-20260824-000012",
      proveedor: "Telcel",
      categoria: "recarga",
      referencia: "5512345678",
      montoServicio: 100,
      comision: 5,
      total: 105,
      metodoPago: "efectivo",
      created_at: "2026-08-24T10:00:00.000Z",
    }, {});
    expect(html).toContain("RECARGA TELCEL");
    expect(html).toContain("SRV-20260824-000012");
    expect(html).toContain("5512345678");
    expect(html).toContain("$100.00");
    expect(html).toContain("$5.00");
    expect(html).toContain("$105.00");
    expect(html).toContain("Efectivo");
    expect(html.toLowerCase()).not.toContain("mercado pago");
    expect(html.toLowerCase()).not.toContain("compensaci");
  });

  test("escapa la referencia para no romper el HTML", () => {
    const html = servicioTicketInner({
      folio: "SRV-1",
      proveedor: "CFE",
      categoria: "luz",
      referencia: "<script>x</script>",
      montoServicio: 200,
      comision: 8,
      total_cobrado: 208,
    }, {});
    expect(html).toContain("PAGO CFE");
    expect(html).not.toContain("<script>");
    expect(html).toContain("&lt;script&gt;");
  });
});
