const fs = require("fs");
const path = require("path");
import {
  excluirFilaDis,
  filaBirdman,
  filaDermaexpress,
  filaEwafra,
  filaSuplementosMayoreo,
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

test("Dermaexpress: sin precio público aunque haya costo", () => {
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
  expect(ok.precio).toBe(0);
  expect(ok.costo).toBe(619);

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
  expect(fit.precio).toBe(0);
  expect(fit.costo).toBe(399);
});

test("Suplementos Mayoreo: costo de mayoreo, precio público en 0", () => {
  const whey = filaSuplementosMayoreo({
    codigo: "9660",
    nombre: "ISOFLEX 5 LBS CHOCOLATE *OFERTA*",
    nombre_completo: "ALMX ISOFLEX 5 LBS CHOCOLATE *OFERTA*",
    marca: "ALLMAX",
    precio: "1673",
    stock: "332",
    imagen_url: "https://firebasestorage.googleapis.com/v0/b/suplementos-mayoreo.appspot.com/o/products%2Fimg%2Fjpeg%2F665553121154.jpg?alt=media",
  });
  expect(whey.precio).toBe(0);
  expect(whey.costo).toBe(1673);
  expect(whey.marca).toBe("Allmax");
  expect(whey.nombre).toMatch(/Isoflex/i);
  expect(whey.nombre).not.toMatch(/oferta/i);
  expect(whey.nombre).not.toMatch(/5 lb/i);
  expect(whey.presentacion).toBe("5 lb");
  expect(whey.categoria).toBe("Suplemento");
  expect(whey.subcategoria).toBe("Proteína");
  expect(whey.sku).toBe("FC-53121154");
  expect(whey.ean).toBe("665553121154");
  expect(whey.fuente).toBe("suplementosmayoreo");
  expect(whey.imagen_url).toContain("firebasestorage.googleapis.com");

  const creatina = filaSuplementosMayoreo({
    codigo: "23641",
    nombre: "CREATINA MONOHIDRATADA 450 GRS",
    nombre_completo: "BIRDMAN CREATINA MONOHIDRATADA 450 GRS",
    marca: "BIRDMAN",
    precio: "453",
    stock: "10",
    imagen_url: "",
  });
  expect(creatina.sku).toMatch(/^FC-\d{8}$/);
  expect(creatina.ean).toBe("");
  expect(creatina.presentacion).toBe("450 g");
  expect(creatina.subcategoria).toBe("Deportiva");
  expect(creatina.precio).toBe(0);

  const sinMarca = filaSuplementosMayoreo({
    codigo: "1",
    nombre: "",
    nombre_completo: "APPLIED NUTRITION CREATINE MONOHYDRATE POWDER 250 GR *NUEVO*",
    marca: "",
    precio: "280",
    stock: "4",
    imagen_url: "",
  });
  expect(sinMarca.marca).toBe("Applied Nutrition");
  expect(sinMarca.nombre).toMatch(/Creatine/i);
  expect(sinMarca.presentacion).toBe("250 g");

  const cafe = filaSuplementosMayoreo({
    codigo: "2",
    nombre: "CAFFEINE 200 MG 100 CT *OFERTA*",
    nombre_completo: "ALMX CAFFEINE 200 MG 100 CT *OFERTA*",
    marca: "ALLMAX",
    precio: "185",
    stock: "3",
    imagen_url: "",
  });
  expect(cafe.nombre).toMatch(/200 mg/i);
  expect(cafe.presentacion).toBe("100 piezas");
  expect(cafe.concentracion).toBe("200 mg");
  expect(cafe.subcategoria).toBe("Deportiva");

  expect(filaSuplementosMayoreo({
    codigo: "3",
    nombre: "EVOGEN CLASSIC GREY (L)",
    nombre_completo: "T-SHIRT EVOGEN CLASSIC GREY (L)",
    marca: "PLAYERAS",
    precio: "180",
    stock: "2",
  })).toBeNull();

  expect(filaSuplementosMayoreo({
    codigo: "4",
    nombre: "",
    nombre_completo: "BIOMEDIC STANOZOLOL 20MG 100TABS",
    marca: "",
    precio: "455",
    stock: "1",
  })).toBeNull();

  expect(filaSuplementosMayoreo({
    codigo: "4b",
    nombre: "",
    nombre_completo: "BIOMEDIC METHANDROSTENOLONE 20MG 100 TABS",
    marca: "",
    precio: "455",
    stock: "1",
  })).toBeNull();

  expect(filaSuplementosMayoreo({
    codigo: "4c",
    nombre: "IONIC+ DIANA 50 CAPS",
    nombre_completo: "IONIC+ DIANA 50 CAPS",
    marca: "",
    precio: "359",
    stock: "1",
  })).toBeNull();

  const anabol = filaSuplementosMayoreo({
    codigo: "6",
    nombre: "ANABOL HARDCORE",
    nombre_completo: "NT ANABOL HARDCORE",
    marca: "NUTREX",
    precio: "317",
    stock: "4",
  });
  expect(anabol.nombre).toMatch(/Anabol Hardcore/i);
  expect(anabol.precio).toBe(0);

  const fitmingo = filaSuplementosMayoreo({
    codigo: "7",
    nombre: "FITMINGO 1,020GRS BLUEBERRY",
    nombre_completo: "BIRDMAN FITMINGO 1,020GRS BLUEBERRY",
    marca: "BIRDMAN",
    precio: "861",
    stock: "3",
  });
  expect(fitmingo.presentacion).toBe("1020 g");
  expect(fitmingo.nombre).toMatch(/Blueberry/i);

  expect(filaSuplementosMayoreo({
    codigo: "5",
    nombre: "OMEGA 3 180 CT",
    nombre_completo: "ALMX OMEGA 3 180 CT",
    marca: "ALLMAX",
    precio: "293",
    stock: "8",
  }).categoria).toBe("Vitaminas");
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
  expect(fila.precio).toBe(0);
  expect(fila.costo).toBe(97.5);
});
