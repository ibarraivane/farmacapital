const fs = require("fs");
const path = require("path");
import {
  costoClienteMepiel,
  costoMayoreoPreferido,
  enriquecerFilaMepiel,
  excluirFilaDis,
  filaBirdman,
  filaDermaexpress,
  filaEwafra,
  filaMepiel,
  filasMepielDesdeRaws,
  hashSku8,
  marcaDesdeDescripcionDis,
  marcaMepielPorFila,
  matchPromexsa,
  nombreDesdeListaMepiel,
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

test("ME Piel cobra el precio cliente con IVA y no publica vitrina", () => {
  expect(marcaMepielPorFila(50)).toBe("Eucerin");
  expect(marcaMepielPorFila(150)).toBe("Bioderma");
  expect(costoClienteMepiel({ cliente_con: 474.3008, cliente_sin: 408.88 })).toBe(474.3);

  const fila = filaMepiel({
    fila: 130,
    ean: "4005900996169",
    descripcion: "EUCERIN SUN KIDS GEL CREMA DRY TOUCH SPF50 200ML",
    uni: "PZA",
    cliente_sin: 408.88,
    cliente_con: 474.3008,
    publico_con: 692.1952,
    linea: "SOLARES",
  });
  expect(fila.sku).toBe("FC-00996169");
  expect(fila.costo).toBe(474.3);
  expect(fila.precio).toBe(0);
  expect(fila.techo).toBe(692.2);
  expect(fila.categoria).toBe("Cuidado personal");
  expect(fila.subcategoria).toBe("Dermatología");
  expect(fila.marca).toBe("Eucerin");
  expect(fila.oferta).toBe("10+1");
  expect(nombreDesdeListaMepiel(fila.nombre_lista)).toMatch(/SPF50/);
  expect(nombreDesdeListaMepiel(fila.nombre_lista)).toMatch(/200 ml/);
});

test("ME Piel deduplica lanzamiento y se queda el nombre de mostrador", () => {
  const filas = filasMepielDesdeRaws([
    {
      fila: 373, ean: "8436574364866", descripcion: "ENDOCARE RADIANCE C FERULIC SERUM GEL",
      uni: "MAYO", cliente_con: 924, publico_con: 1200, marca: "Cantabria Labs",
    },
    {
      fila: 377, ean: "8436574364866", descripcion: "ENDOCARE RADIANCE C FERULIC SERUM GEL 30ML",
      uni: "PZA", cliente_con: 923.998, publico_con: 1200, marca: "Cantabria Labs",
    },
  ]);
  expect(filas).toHaveLength(1);
  expect(filas[0].uni).toBe("PZA");
  expect(filas[0].costo).toBe(924);

  const ficha = enriquecerFilaMepiel(filas[0], {
    derma: {
      nombre: "Endocare Radiance C Ferulic Serum Gel 30 ml",
      marca: "Endocare",
      imagen_url: "https://cdn.shopify.com/s/files/endocare.jpg",
    },
  });
  expect(ficha.nombre).toMatch(/Radiance C Ferulic/i);
  expect(ficha.marca).toBe("Endocare");
  expect(ficha.presentacion).toMatch(/30 ml/i);
  expect(ficha.imagen_origen).toBe("dermaexpress");
  expect(ficha.precio).toBe(0);

  const sucio = enriquecerFilaMepiel(filas[0], {
    derma: { imagen_url: "https://production-media.fahorro.com/x.png", nombre: "X largo" },
  });
  expect(sucio.imagen_url).toBe("");
  expect(costoMayoreoPreferido(489, 474.3)).toBe(474.3);
  expect(costoMayoreoPreferido(0, 474.3)).toBe(474.3);
});
