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
if (!/costoSugeridoRecepcion/.test(rec)) {
  fail("RecepcionModule: el costo del renglón tiene que salir solo (costoSugeridoRecepcion).");
}
const sqlPrecio = read("sql/patch_recibir_precio_auto_20260908.sql");
if (!/'costo_estimado', i\.costo_estimado/.test(sqlPrecio)) {
  fail("fc_recepcion_json tiene que mandar costo_estimado para que Recibir lo ponga solo.");
}
if (!/fc_costo_unitario_renglon/.test(sqlPrecio) || !/45\.890/.test(sqlPrecio)) {
  fail("El SQL de precio tiene que partir el importe del renglón (Neutrogena 45.89, no 91.78).");
}
if (/update public\.recepcion_items i[\s\S]{0,240}join public\.productos p on p\.id = i\.producto_id/.test(sqlPrecio)) {
  fail("UPDATE recepcion_items no puede JOIN productos con i en el FROM (Postgres 42P01).");
}
const sqlVivo = read("sql/patch_recibir_guardar_caducidad_vivo_20260908.sql");
if (!/pendiente_caducidad/.test(sqlVivo) || !/recepcion_confirmar_item/.test(sqlVivo)) {
  fail("Hay que poder grabar MMAA en un ticket vivo, no solo en borrador.");
}
if (/update public\.recepciones[\s\S]{0,400}estado = 'borrador'[\s\S]{0,500}confirmada/.test(sqlVivo)) {
  fail("El SQL de caducidad viva no puede reabrir tickets confirmada/descuadre.");
}
const sqlCerrar = read("sql/patch_recibir_cerrar_reabiertos_20260908.sql");
if (!/backfill ticket inicial/.test(sqlCerrar) || !/1658128647824-01/.test(sqlCerrar)) {
  fail("El SQL correctivo tiene que cerrar el historial y el Nadro ya recibido.");
}
if (!/pedidoEsperaEntrada/.test(rec)) {
  fail("RecepcionModule: la lista de Recibir debe filtrar con pedidoEsperaEntrada.");
}
const handler = read("api/_lib/recepcionAbiertasHandler.js");
if (/falta > 0 \|\| t\.estado === 'borrador'/.test(handler)) {
  fail("esPedidoVivo no debe listar todo borrador; solo cajas pendientes.");
}
if (/id=["']rc-scan["'][\s\S]{0,400}disabled=\{/.test(rec)) {
  fail("RecepcionModule: el recuadro de pistola no debe usar disabled (Safari/iPad tira NotFoundError). Usa readOnly.");
}
if (/lazy\s*\(\s*\(\)\s*=>\s*import\(\s*["']\.\/RecepcionModule["']/.test(read("src/InventarioHub.jsx"))) {
  fail("InventarioHub: Recibir no debe ir lazy; la tablet se queda con un chunk viejo tras el deploy.");
}
if (!/codigo_barras,descripcion/.test(rec)) {
  fail("RecepcionModule: el catálogo de Recibir debe traer descripcion (EANs de exhibidor/pieza).");
}
if (/flex:\s*["']1 1 140px["']/.test(rec)) {
  fail("Recibir: las tarjetas de proveedor no deben crecer (flex 1 1) — Nadro/Exprezo se estiran solos.");
}
if (!/auto-fill/.test(rec)) {
  fail("Recibir: la lista de tickets vivos debe ser grid auto-fill para que todas midan igual.");
}
if (/Dalos de alta en[\s\S]{0,80}Inventario → Catálogo →/.test(rec)) {
  fail("Recibir: el recuadro rojo no debe mandar a Inventario → Catálogo. El alta se arma desde Recibir.");
}
if (!/No vayas a Inventario → Catálogo/.test(rec)) {
  fail("RecepcionModule: el recuadro de sin registrar debe decir que no vayan a Catálogo.");
}
const sqlFl127790 = read("sql/patch_alta_farmalive_127790_y_match_ean_20260916.sql");
if (/Enlaza grises de cualquier ticket vivo/.test(sqlFl127790)) {
  fail("Farmalive 127790: no enlazar pendiente_alta en todos los tickets (reabre lo ya recibido).");
}
if (!/r\.folio = '127790'/.test(sqlFl127790)) {
  fail("Farmalive 127790: el enlazar tiene que ir acotado al folio.");
}
const sqlFl6 = read("sql/patch_recibir_farmalive_127790_faltantes_y_reabiertos_20260916.sql");
if (!/7501008499245/.test(sqlFl6) || !/7501008849949/.test(sqlFl6)) {
  fail("El SQL de los 6 faltantes tiene que dar de alta Aspirina GO y el 3-pack.");
}
if (!/estado = 'pendiente_alta'/.test(sqlFl6) || !/confirmada/.test(sqlFl6)) {
  fail("El SQL correctivo tiene que cerrar tickets reabiertos (pendiente_alta → confirmada).");
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
    extractGs1Gtin,
    esSerialTerminalPoint,
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
  if (pedidoEsperaEntrada({ renglones: 184, sin_confirmar: 0, estado: "borrador" })) {
    fail("Historial ya recibido (todo verde) no debe volver a Recibir.");
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
  const gs1 = "01040018959287651728031110LOTE";
  if (extractGs1Gtin(gs1) !== "4001895928765") {
    fail("GS1 AI 01 debe extraer el GTIN/EAN de la caja.");
  }
  if (!itemMatchScan(tegaderm, gs1)) {
    fail("DataMatrix GS1 de Tegaderm debe abrir el renglón gris.");
  }
  if (!eanPistolaListo(gs1)) {
    fail("Beep GS1 largo debe disparar sin Enter.");
  }
  if (!esSerialTerminalPoint("NCCC05728001")) {
    fail("Serial Point NCCC… debe reconocerse para no dejarlo pegado.");
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
