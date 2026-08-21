import { parseTicketCsv } from "./recepcionTicketCsv";

describe("parseTicketCsv", () => {
  test("Cityfarma 6315912", () => {
    const csv = `linea,folio,fecha,proveedor,ean,descripcion_ticket,cantidad,precio_unitario,subtotal,lote,caducidad,sku_farmacapital,accion
1,6315912,2026-08-21,Cityfarma Iztapalapa,7501050613453,AFRIN ADUL SPRAY,2,75.38,150.76,2601928,,FC-06134531,recibir
2,6315912,2026-08-21,Cityfarma Iztapalapa,7501050623766,AFRIN NO DRIP SOL 15,2,115.52,231.04,2601390,,FC-05062376,alta`;
    const { renglones, folio, proveedor } = parseTicketCsv(csv);
    expect(folio).toBe("6315912");
    expect(proveedor).toBe("Cityfarma Iztapalapa");
    expect(renglones).toHaveLength(2);
    expect(renglones[0].codigo).toBe("7501050613453");
    expect(renglones[0].cantidad).toBe(2);
    expect(renglones[0].numero_lote).toBe("2601928");
    expect(renglones[0].costo).toBe(75.38);
    expect(renglones[1].sku).toBe("FC-05062376");
  });

  test("Levic 9012078353", () => {
    const csv = `linea,folio,fecha,proveedor,ean,descripcion_ticket,cantidad,precio_unitario,subtotal,lote,caducidad,sku_farmacapital,accion
1,9012078353,2026-08-20,Levic,7501342802749,SILDENAFIL 1 TAB 50 MG,4,4.90,19.60,ECM297C,2028-03-30,EQ-BEA267,alta
6,9012078353,2026-08-20,Levic,7501109769063,AGECAPS MINOXIDIL HOMBRE 5% SOL 60 ML,1,150.00,150.00,26C063,2028-02-29,EQ-QUI139,alta`;
    const { renglones, folio, proveedor } = parseTicketCsv(csv);
    expect(folio).toBe("9012078353");
    expect(proveedor).toBe("Levic");
    expect(renglones).toHaveLength(2);
    expect(renglones[0].codigo).toBe("7501342802749");
    expect(renglones[0].cantidad).toBe(4);
    expect(renglones[0].numero_lote).toBe("ECM297C");
    expect(renglones[0].costo).toBe(4.9);
    expect(renglones[1].sku).toBe("EQ-QUI139");
  });
});
