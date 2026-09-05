import { readFileSync } from "fs";
import { join } from "path";
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

  test("Exprezo 1279718 generado", () => {
    const csv = readFileSync(join(__dirname, "../../sql/generated/ticket_exprezo_1279718.csv"), "utf8");
    const { renglones, folio, proveedor, total } = parseTicketCsv(csv);
    expect(folio).toBe("1279718");
    expect(proveedor).toBe("Exprezo");
    expect(total).toBe(1981.55);
    expect(renglones).toHaveLength(17);
    expect(renglones.some((r) => r.codigo === "7501008497340" && r.cantidad === 3)).toBe(true);
    expect(renglones.every((r) => !r.numero_lote)).toBe(true);
  });

  test("Levic 9012148211 generado", () => {
    const csv = readFileSync(join(__dirname, "../../sql/generated/ticket_levic_9012148211.csv"), "utf8");
    const { renglones, folio, proveedor, total } = parseTicketCsv(csv);
    expect(folio).toBe("9012148211");
    expect(proveedor).toBe("Levic");
    expect(total).toBe(627.85);
    expect(renglones).toHaveLength(11);
    expect(renglones.reduce((a, r) => a + r.cantidad, 0)).toBe(22);
    expect(renglones.some((r) => r.codigo === "7501349021808" && r.sku === "EQ-AMS349")).toBe(true);
    expect(renglones.some((r) => r.codigo === "7896009498091" && r.cantidad === 1 && r.costo === 56.88)).toBe(true);
    expect(renglones.every((r) => r.codigo && r.codigo.length >= 8)).toBe(true);
    expect(renglones.every((r) => !r.numero_lote)).toBe(true);
  });

  test("Nadro 1658128647824-01 generado", () => {
    const csv = readFileSync(join(__dirname, "../../sql/generated/ticket_nadro_1658128647824.csv"), "utf8");
    const { renglones, folio, proveedor, total } = parseTicketCsv(csv);
    expect(folio).toBe("1658128647824-01");
    expect(proveedor).toBe("Nadro");
    expect(total).toBe(5617.17);
    expect(renglones).toHaveLength(50);
    expect(renglones.reduce((a, r) => a + r.cantidad, 0)).toBe(89);
    expect(renglones.every((r) => r.codigo && r.codigo.length >= 8)).toBe(true);
    expect(renglones.every((r) => !r.numero_lote)).toBe(true);

    // Supabase SQL Editor corta do $$ — el patch debe ser solo SQL plano.
    const sql = readFileSync(
      join(__dirname, "../../sql/patch_recepcion_nadro_1658128647824_corroborar.sql"),
      "utf8",
    );
    expect(sql).toMatch(/SIN bloques dollar-quote/);
    expect(sql).not.toMatch(/\ndo\s*\$\$/);
    expect(sql).not.toMatch(/\nend\s*\$\$/);
    expect(sql).toMatch(/folio = '1658128647824-01'/);
    expect((sql.match(/^\s*\(\d+,/gm) || []).length).toBe(50);
  });

  test("Nadro 20260901 generado", () => {
    const csv = readFileSync(join(__dirname, "../../sql/generated/ticket_nadro_20260901.csv"), "utf8");
    const { renglones, folio, proveedor, total } = parseTicketCsv(csv);
    expect(folio).toBe("20260901");
    expect(proveedor).toBe("Nadro");
    expect(total).toBe(848.05);
    expect(renglones).toHaveLength(13);
    expect(renglones.reduce((a, r) => a + r.cantidad, 0)).toBe(15);
    expect(renglones.every((r) => r.codigo && r.codigo.length >= 8)).toBe(true);
    expect(renglones.every((r) => !r.numero_lote)).toBe(true);
    expect(renglones.some((r) => r.codigo === "7506494600038" && r.cantidad === 1)).toBe(true);
    expect(renglones.some((r) => r.codigo === "037836051227")).toBe(true);
    expect(renglones.some((r) => r.codigo === "3337875917810" && r.costo === 372.2)).toBe(true);
  });
});
