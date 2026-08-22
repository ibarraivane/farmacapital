#!/usr/bin/env node
"use strict";

const fs = require("fs");
const path = require("path");
const { pathToFileURL } = require("url");

const root = path.resolve(__dirname, "..");
const errors = [];

function read(rel) {
  return fs.readFileSync(path.join(root, rel), "utf8");
}

function fail(msg) {
  errors.push(msg);
}

const rec = read("src/RecepcionModule.jsx");
if (/id=["']rc-scan["'][\s\S]{0,400}disabled=\{/.test(rec)) {
  fail("RecepcionModule: el recuadro de pistola no debe usar disabled (Safari/iPad tira NotFoundError). Usa readOnly.");
}
if (/lazy\s*\(\s*\(\)\s*=>\s*import\(\s*["']\.\/RecepcionModule["']/.test(read("src/InventarioHub.jsx"))) {
  fail("InventarioHub: Recibir no debe ir lazy; la tablet se queda con un chunk viejo tras el deploy.");
}

async function assertScanLogic() {
  const scanUrl = pathToFileURL(path.join(root, "src/lib/recepcionScan.js")).href;
  const cadUrl = pathToFileURL(path.join(root, "src/lib/caducidad.js")).href;
  const {
    itemMatchScan,
    eanPistolaListo,
    pedidoEsperaEntrada,
    recepcionEsTicket,
    matchScanEnTicket,
  } = await import(scanUrl);
  const { parseCaducidadMMAA } = await import(cadUrl);

  const tegaderm = {
    sku: "FC-89592876",
    codigo_escaneado: "4001895928765",
    confirmado: false,
  };
  if (!itemMatchScan(tegaderm, "4001895928765")) {
    fail("Tegaderm 4001895928765 debe abrir el renglón gris.");
  }
  if (!itemMatchScan(tegaderm, "FC-89592876")) {
    fail("SKU FC-89592876 debe abrir el renglón.");
  }
  if (itemMatchScan(tegaderm, "7501289511421")) {
    fail("Un EAN ajeno no debe abrir Tegaderm.");
  }
  if (!eanPistolaListo("4001895928765")) {
    fail("EAN-13 completo debe disparar sin Enter.");
  }
  if (eanPistolaListo("400189")) {
    fail("EAN a medias no debe disparar.");
  }
  if (!pedidoEsperaEntrada({ renglones: 11, sin_confirmar: 11, estado: "borrador" })) {
    fail("Ticket con cajas pendientes debe ser pedido vivo.");
  }
  if (parseCaducidadMMAA("0000") != null) {
    fail("0000 no es caducidad: parseCaducidadMMAA debe devolver null.");
  }
  const ticket = {
    items: [
      { origen: "pdf", confirmado: true, codigo_escaneado: "4001895928765", sku: "FC-89592876" },
      { origen: "pdf", confirmado: false, codigo_escaneado: "7501289511421", sku: "FC-9511421" },
    ],
  };
  if (!recepcionEsTicket(ticket)) fail("Un PDF debe tratarse como ticket.");
  if (recepcionEsTicket({ items: [{ origen: "pistola" }] })) {
    fail("Solo pistola no es ticket de proveedor.");
  }
  if (matchScanEnTicket(ticket.items, "7501342802749").gris || matchScanEnTicket(ticket.items, "7501342802749").yaConfirmado) {
    fail("Sildenafil (Levic) no debe coincidir en un ticket Farmalive.");
  }
  if (!matchScanEnTicket(ticket.items, "4001895928765").yaConfirmado) {
    fail("Tegaderm ya confirmado debe detectarse.");
  }
}

assertScanLogic()
  .then(() => {
    if (errors.length) {
      for (const e of errors) console.error(`[check-recibir-tablet] ${e}`);
      process.exit(1);
    }
    console.log("[check-recibir-tablet] OK");
  })
  .catch((err) => {
    console.error("[check-recibir-tablet]", err);
    process.exit(1);
  });
