// ═══════════════════════════════════════════════════════════
// FARMAX — ESC/POS Direct Printing via QZ Tray
// Requisito: QZ Tray instalado en la computadora del mostrador
// Descarga: https://qz.io/download/
// ═══════════════════════════════════════════════════════════

// ── Verificar si QZ Tray está disponible ─────────────────
export function isQZAvailable() {
  return typeof window.qz !== "undefined";
}

// ── Conectar a QZ Tray ───────────────────────────────────
export async function conectarQZ() {
  if(!isQZAvailable()) {
    throw new Error("QZ Tray no está instalado. Descárgalo en https://qz.io");
  }
  if(window.qz.websocket.isActive()) return true;
  await window.qz.websocket.connect();
  return true;
}

// ── Desconectar QZ Tray ───────────────────────────────────
export async function desconectarQZ() {
  if(isQZAvailable() && window.qz.websocket.isActive()) {
    await window.qz.websocket.disconnect();
  }
}

// ── Obtener lista de impresoras ───────────────────────────
export async function listarImpresoras() {
  await conectarQZ();
  return window.qz.printers.find();
}

// ── Buscar Epson TM-T20III ────────────────────────────────
export async function buscarEpson() {
  const impresoras = await listarImpresoras();
  const epson = impresoras.find(p =>
    p.toLowerCase().includes("epson") ||
    p.toLowerCase().includes("tm-t20") ||
    p.toLowerCase().includes("thermal") ||
    p.toLowerCase().includes("receipt")
  );
  return epson || impresoras[0] || null;
}

// ── Comandos ESC/POS básicos ──────────────────────────────
const ESC = "\x1B";
const GS  = "\x1D";
const LF  = "\x0A";
const CR  = "\x0D";

const CMD = {
  INIT:           ESC+"@",           // Inicializar impresora
  BOLD_ON:        ESC+"E\x01",       // Negrita on
  BOLD_OFF:       ESC+"E\x00",       // Negrita off
  ALIGN_LEFT:     ESC+"a\x00",       // Alinear izquierda
  ALIGN_CENTER:   ESC+"a\x01",       // Alinear centro
  ALIGN_RIGHT:    ESC+"a\x02",       // Alinear derecha
  FONT_NORMAL:    ESC+"!\x00",       // Fuente normal
  FONT_LARGE:     ESC+"!\x30",       // Fuente grande
  CUT_PAPER:      GS+"V\x41\x00",   // Cortar papel
  FEED_LINES:     (n) => ESC+"d"+String.fromCharCode(n), // Avanzar n líneas
  LINE:           "--------------------------------\n",
  LINE_DOUBLE:    "================================\n",
};

// ── Generar datos ESC/POS del ticket ─────────────────────
export function generarESCPOS(ticketData) {
  const { venta={}, productos=[], cliente=null, metodoPago="Efectivo", config={} } = ticketData;
  const fecha = new Date(venta.created_at||Date.now());
  const fechaStr = fecha.toLocaleDateString("es-MX",{day:"2-digit",month:"2-digit",year:"numeric"});
  const horaStr  = fecha.toLocaleTimeString("es-MX",{hour:"2-digit",minute:"2-digit"});
  const folio    = venta.folio || `VTA-${String(venta.id||"0").padStart(8,"0")}`;
  const total    = parseFloat(venta.total||0);
  const fmt      = n => `$${parseFloat(n||0).toFixed(2)}`;

  const padRight = (str, len) => String(str).substring(0,len).padEnd(len);
  const padLeft  = (str, len) => String(str).substring(0,len).padStart(len);

  let data = [];

  // INIT
  data.push(CMD.INIT);

  // HEADER
  data.push(CMD.ALIGN_CENTER);
  data.push(CMD.FONT_LARGE);
  data.push(CMD.BOLD_ON);
  data.push("  FARMAX  \n");
  data.push(CMD.FONT_NORMAL);
  data.push(CMD.BOLD_OFF);
  data.push("Tu salud primero\n");
  data.push(config.direccion_farmacia||"Chinampac de Juarez, CDMX");
  data.push(LF);
  if(config.rfc) { data.push(`RFC: ${config.rfc}\n`); }
  if(config.telefono_farmacia) { data.push(`Tel: ${config.telefono_farmacia}\n`); }

  // SEPARADOR
  data.push(CMD.ALIGN_LEFT);
  data.push(CMD.LINE);

  // INFO VENTA
  data.push(`Folio : ${folio}\n`);
  data.push(`Fecha : ${fechaStr}  ${horaStr}\n`);
  if(cliente) data.push(`Cliente: ${cliente.nombre||"—"}\n`);

  // PRODUCTOS
  data.push(CMD.LINE);
  data.push(CMD.BOLD_ON);
  data.push(`${padRight("PRODUCTO",18)}${padLeft("CANT",4)}${padLeft("TOTAL",10)}\n`);
  data.push(CMD.BOLD_OFF);
  data.push(CMD.LINE);

  productos.forEach(p => {
    const nombre = (p.nombre||"Producto").substring(0,18);
    const qty    = p.qty||p.cantidad||1;
    const precio = parseFloat(p.precio||p.precio_unitario||0);
    const ptotal = precio*qty;
    data.push(`${padRight(nombre,18)}${padLeft(qty,4)}${padLeft(fmt(ptotal),10)}\n`);
    // Segunda línea si nombre es largo
    if(p.nombre && p.nombre.length>18) {
      data.push(`  ${p.nombre.substring(18,36)}\n`);
    }
    if(p.lote) data.push(`  Lote: ${p.lote}\n`);
  });

  // TOTALES
  data.push(CMD.LINE);
  data.push(`${padRight("Subtotal:",22)}${padLeft(fmt(total),10)}\n`);
  data.push(`${padRight("IVA incluido:",22)}${padLeft(fmt(total*0.16),10)}\n`);
  data.push(CMD.LINE_DOUBLE);
  data.push(CMD.BOLD_ON);
  data.push(CMD.FONT_LARGE);
  data.push(`TOTAL: ${fmt(total)}\n`);
  data.push(CMD.FONT_NORMAL);
  data.push(CMD.BOLD_OFF);
  data.push(CMD.LINE);

  // PAGO Y PUNTOS
  data.push(`Pago  : ${metodoPago}\n`);
  const pts = Math.floor(total/10);
  if(pts>0) {
    data.push(CMD.ALIGN_CENTER);
    data.push(CMD.BOLD_ON);
    data.push(`*** +${pts} PUNTOS FARMAX ***\n`);
    data.push(CMD.BOLD_OFF);
  }

  // FOOTER
  data.push(CMD.LINE);
  data.push(CMD.ALIGN_CENTER);
  data.push("Gracias por su compra\n");
  data.push("!Vuelva pronto!\n");
  data.push("farmax-seven.vercel.app\n");

  // CORTE
  data.push(CMD.FEED_LINES(3));
  data.push(CMD.CUT_PAPER);

  return data;
}

// ── Imprimir ticket directo (sin diálogo) ─────────────────
export async function imprimirESCPOS(ticketData, nombreImpresora=null) {
  try {
    await conectarQZ();
    const impresora = nombreImpresora || await buscarEpson();
    if(!impresora) throw new Error("No se encontró impresora térmica");

    const config = window.qz.configs.create(impresora, {
      size: { width:80, height:null }, // 80mm
      units: "mm",
    });

    const data = generarESCPOS(ticketData);
    await window.qz.print(config, [{ type:"raw", format:"plain", data:data.join("") }]);
    console.log("[Farmax ESC/POS] Ticket impreso en:", impresora);
    return { success:true, impresora };
  } catch(e) {
    console.error("[Farmax ESC/POS] Error:", e);
    throw e;
  }
}
