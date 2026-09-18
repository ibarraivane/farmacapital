const fs = require("fs");
const path = require("path");
import {
  excluirFilaDis,
  filaBirdman,
  filaDermaexpress,
  filaEwafra,
  hashSku8,
  marcaDesdeDescripcionDis,
  matchPromexsa,
  nombreMostradorDis,
  precioBajoPedido,
  skuCatalogoBajoPedido,
} from "./catalogoBajoPedido";

test("el CSV DIS parseado trae el grueso de la lista agosto", () => {
  const p = path.join(__dirname, "../../docs/catalogos/ewafra_dis_agosto_2026.csv");
  const n = fs.readFileSync(p, "utf8").trim().split("\n").length - 1;
  expect(n).toBeGreaterThan(1100);
});

test("precio = recargo sobre costo, techo solo recorta", () => {
  expect(precioBajoPedido(100, "marca")).toBe(125);
  expect(precioBajoPedido(100, "marca", 110)).toBe(110);
  expect(precioBajoPedido(0, "marca", 500)).toBe(0);
  expect(precioBajoPedido(null, "marca")).toBe(0);
  expect(precioBajoPedido(97.5, "marca", 158.77)).toBe(122);
});

test("SKU EAN vs hash estable sin código de barras", () => {
  expect(skuCatalogoBajoPedido("3337875902823")).toBe("FC-75902823");
  const a = skuCatalogoBajoPedido("", { proveedor: "ewafra", codigoProveedor: "A15896" });
  const b = skuCatalogoBajoPedido("", { proveedor: "ewafra", codigoProveedor: "A15896" });
  expect(a).toMatch(/^FC-\d{8}$/);
  expect(a).toBe(b);
  expect(a).not.toBe(skuCatalogoBajoPedido("", { proveedor: "ewafra", codigoProveedor: "00557" }));
  expect(hashSku8("ewafra:a15896")).toHaveLength(8);
});

test("nombres DIS de almacén → mostrador + marca", () => {
  expect(nombreMostradorDis("ABATELENGUAS D/MAD. 15 CM C/20 C/25 AMBIDERM")).toMatch(/Abatelenguas de madera/i);
  expect(nombreMostradorDis("ABATELENGUAS D/MAD. 15 CM C/20 C/25 AMBIDERM")).toMatch(/caja 20/i);
  expect(marcaDesdeDescripcionDis("GASA ESTERIL 10 X 10 C/100 SOB. DIBAR")).toBe("Dibar");
  expect(marcaDesdeDescripcionDis("AGUJA 21 X 32 VERDE C/100 CVE 301731 BD")).toBe("BD");
});

test("DIS excluye laboratorio, anticipo y sin costo", () => {
  expect(excluirFilaDis({ descripcion: "ANTICIPO PEDIDO", costo: 100 })).toBe("excluido");
  expect(excluirFilaDis({ descripcion: "ACEITE DE INMERSION TIPO A", costo: 50 })).toBe("excluido");
  expect(excluirFilaDis({ descripcion: "ADRENALINA 1MG/ML", costo: 80 })).toBe("excluido");
  expect(excluirFilaDis({ descripcion: "GASA ESTERIL DIBAR", costo: 0 })).toBe("sin_costo");
  expect(excluirFilaDis({ descripcion: "GASA ESTERIL 10 X 10 DIBAR", costo: 97.5 })).toBeNull();
});

test("Dermaexpress: Encargar si hay costo y está disponible; si no, Cotizar", () => {
  const ok = filaDermaexpress({
    sku: "3282771000787",
    nombre: "Ducray Kelual DS 100 ml",
    marca: "Ducray",
    costo_proveedor: 619,
    pvp_referencia: 0,
    disponible_proveedor: 1,
    imagen_url: "https://cdn.shopify.com/s/files/x.jpg",
  });
  expect(ok.sku).toBe("FC-71000787");
  expect(ok.categoria).toBe("Cuidado personal");
  expect(ok.subcategoria).toBe("Dermatología");
  expect(ok.precio).toBe(precioBajoPedido(619, "marca", 0));
  expect(ok.precio).toBeGreaterThan(0);

  const agotado = filaDermaexpress({
    sku: "3337875902823",
    nombre: "Vichy Dercos refill",
    marca: "Vichy",
    costo_proveedor: 799,
    pvp_referencia: 1029,
    disponible_proveedor: 0,
    imagen_url: "https://cdn.shopify.com/x.jpg",
  });
  expect(agotado.precio).toBe(0);
  expect(agotado.costo).toBe(799);

  const fahorro = filaDermaexpress({
    sku: "1234567890123",
    nombre: "X",
    marca: "X",
    costo_proveedor: 10,
    disponible_proveedor: 1,
    imagen_url: "https://production-media.fahorro.com/x.png",
  });
  expect(fahorro.imagen_url).toBe("");
});

test("Birdman merch fuera; proteína entra", () => {
  expect(filaBirdman({
    sku: "PlayeraNegraHombreGrande",
    nombre: "Playera Distribuidor Autorizado Hombre - L",
    linea: "Accesorios",
    costo_base_25: 224,
    disponible_proveedor: 1,
  })).toBeNull();

  const fit = filaBirdman({
    sku: "FPCHC1140",
    nombre: "Falcon Protein chocolate 1.14 kg",
    marca: "Birdman",
    linea: "Proteinas",
    costo_base_25: 399,
    pvp_sugerido_marca: 699,
    disponible_proveedor: 1,
    imagen_url: "https://cdn.shopify.com/birdman.png",
  });
  expect(fit.categoria).toBe("Suplemento");
  expect(fit.subcategoria).toBe("Proteína");
  expect(fit.sku).toMatch(/^FC-\d{8}$/);
  expect(fit.precio).toBeGreaterThan(0);
});

test("Ewafra toma nombre/foto Promexsa si el match es fuerte", () => {
  const promexsa = [{
    sku: "DIS-GAS-010",
    nombre: "Gasa estéril 10x10 100 sobres Dibar",
    marca: "Dibar",
    precio_techo_mercado: 154,
    url_imagen: "https://acdn-us.mitiendanube.com/gasa.webp",
  }];
  const hit = matchPromexsa(
    { descripcion: "GASA ESTERIL 10 X 10 C/100 SOB. DIBAR", marca: "Dibar" },
    promexsa,
    { minimo: 0.55 },
  );
  expect(hit?.row.sku).toBe("DIS-GAS-010");

  const fila = filaEwafra({
    codigo: "G10",
    descripcion: "GASA ESTERIL 10 X 10 C/100 SOB. DIBAR",
    costo: 97.5,
    unidad: "C/100",
  }, { ...hit.row, score: hit.score });
  expect(fila.nombre).toMatch(/Gasa/i);
  expect(fila.imagen_url).toContain("mitiendanube");
  expect(fila.precio).toBe(precioBajoPedido(97.5, "marca", 154));
  expect(fila.precio).toBeLessThan(154);
});
