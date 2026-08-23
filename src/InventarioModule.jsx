import { useState, useEffect, useCallback, useMemo, useRef } from "react";
import { useMediaQuery } from "./hooks/useMediaQuery";
import { C_LIGHT } from "./constants";
import { supabase } from "./supabase";
import { logAudit, normalizeForSearch } from "./utils";
import {
  inventarioProductMatchesBusqueda,
  inventarioSearchRelevanceRank,
  spellSuggestFromProducts,
} from "./utils/fuzzySearch";
import { findProductExactScan } from "./utils/barcodeProductLookup";
import { SkeletonTable, Paginador, SearchDropdown, HorizontalScrollSync } from "./ui";
import { showToast } from "./ui";
import OnboardingTour from "./components/OnboardingTour";
import { idEmpleadoUsuarios } from "./utils/usuarioId";
import ImageUploader from "./components/ImageUploader";
import { sugerirPrecioUnidad, aplicarReglaPrecioUnidad, margenBrutoPct } from "./utils/precioUnidad";
import { parseDinero, productoEsVendible } from "./utils/productoVendible";
import {
  PRODUCTOS_POR_PAGINA,
  agruparLotesPorProducto,
  diasParaCaducar,
  fetchLotesInventario,
  minCaducidadLotes,
} from "./lib/inventarioHubData";
import { DIAS_CADUCIDAD_ALERTA, DIAS_CADUCIDAD_CRITICO, esPorCaducar } from "./lib/caducidad";

const leerSesion = () => {
  try {
    return JSON.parse(sessionStorage.getItem("farmacapital_admin_user") || "{}");
  } catch {
    return {};
  }
};

const BRAND = { primary:"#0D1B2A", secondary:"#1E3ABA", gradient:"linear-gradient(135deg,#0D1B2A,#1E3ABA)" };
const CATEGORIAS = [
  "Analgésico","Antiinflamatorio","Antibiótico","Gastro","Diabetes",
  "Hipertensión","Alergia","Vitaminas","Suplemento","Herbolario","Hidratación","Cardiovascular",
  "Hormonales","Respiratorio","Dispositivo médico","Botiquín","Higiene","Bebidas","Básicos","Abarrotes","Minisuper","Cuidado personal","Otro",
];
const EMPTY = {
  nombre:"", sku:"", codigo_barras:"", categoria:"Otro", precio:"", costo:"", venta_unidad:false, unidades_por_caja:"", precio_unidad:"", stock_unidades:"",
  stock:"", stock_minimo:"", tipo:"generico", proveedor:"", lote:"",
  fecha_caducidad:"", descuento_pct:"0", activo:true, imagen_url:"", imagen_mobile_url:"",
  principio_activo:"", denominacion_generica:"", denominacion_distintiva:"",
  concentracion:"", presentacion:"", forma_farmaceutica:"",
  marca:"", ubicacion_texto:"",
};

/** PostgREST puede devolver una fila como array o como objeto según versión/cliente */
function productoIdDesdeCreateRpc(data) {
  if (data == null) return null;
  const row = Array.isArray(data) ? data[0] : data;
  const raw = row?.producto_id;
  if (raw == null || raw === "") return null;
  const n = typeof raw === "number" ? raw : parseInt(String(raw), 10);
  return Number.isFinite(n) ? n : null;
}

// F4: campos lote/fecha_caducidad ya NO viven en productos; son del lote.

/** Lote activo con caducidad más próxima (PEPS). */
const loteCaducidadMasProxima = (lotes) => {
  if (!lotes?.length) return null;
  const activos = lotes.filter((l) => l.activo !== false && (l.cantidad_actual || 0) > 0);
  const pool = activos.length ? activos : lotes.filter((l) => l.activo !== false);
  if (!pool.length) return null;
  return pool
    .slice()
    .sort((a, b) => {
      if (!a.fecha_caducidad) return 1;
      if (!b.fecha_caducidad) return -1;
      return a.fecha_caducidad.localeCompare(b.fecha_caducidad);
    })[0];
};

const lotesActivosProducto = (product) => {
  if (product?.lotes_activos?.length) return product.lotes_activos;
  return (product?.lotes || []).filter((l) => l.activo !== false && (l.cantidad_actual || 0) > 0);
};

/** Lote editable para caducidad (activo con stock, o cualquier lote activo en BD). */
const resolverLoteCaducidadProducto = (product) => {
  const activos = lotesActivosProducto(product);
  const ref = loteCaducidadMasProxima(activos);
  if (ref) return ref;
  const sueltos = (product?.lotes || []).filter((l) => l.activo !== false);
  return loteCaducidadMasProxima(sueltos.length ? sueltos : null) || sueltos[0] || null;
};

async function fetchLotesPorProducto(sessionToken, { omitCosto = false } = {}) {
  if (!sessionToken) return {};
  const { data: list } = await fetchLotesInventario(sessionToken);
  const grouped = agruparLotesPorProducto(list);
  if (!omitCosto) return grouped;
  const slim = {};
  for (const [pid, lotes] of Object.entries(grouped)) {
    slim[pid] = lotes.map((l) => ({
      id: l.id,
      numero_lote: l.numero_lote,
      fecha_caducidad: l.fecha_caducidad,
      cantidad_actual: l.cantidad_actual,
      activo: l.activo,
    }));
  }
  return slim;
}

function enrichProductoConLotes(p, lotes) {
  const lotesList = lotes || [];
  return {
    ...p,
    lotes: lotesList,
    min_caducidad_lotes: minCaducidadLotes(lotesList),
    lotes_activos: lotesList.filter((l) => l.activo !== false && (l.cantidad_actual || 0) > 0),
  };
}

async function refetchProductoLotes(productoId) {
  const { data, error } = await supabase
    .from("productos")
    .select("id, stock, lotes(id, numero_lote, fecha_caducidad, cantidad_actual, costo_unitario, activo)")
    .eq("id", productoId)
    .single();
  if (error || !data) return null;
  return {
    ...data,
    lotes_activos: (data.lotes || []).filter((l) => l.activo !== false && (l.cantidad_actual || 0) > 0),
  };
}

async function rpcGuardarCaducidadProducto(sessionToken, productoId, fecha, loteId = null) {
  return supabase.rpc("admin_guardar_caducidad_producto", {
    p_session_token: sessionToken,
    p_producto_id: productoId,
    p_fecha_caducidad: fecha,
    p_lote_id: loteId,
  });
}

const mkInputStyle = (C) => ({ width:"100%", padding:"8px 10px", borderRadius:7, border:`1px solid ${C.border}`, background:C.bg, color:C.text, fontSize:12, outline:"none", boxSizing:"border-box" });
const mkLabelStyle = (C) => ({ color:C.textMid, fontSize:11, fontWeight:600, marginBottom:3, display:"block" });
const mkBtnPrimary = (C) => ({ padding:"9px 18px", borderRadius:8, border:"none", cursor:"pointer", background:BRAND.gradient, color:"#fff", fontWeight:700, fontSize:12 });
const mkBtnOutline = (C) => ({ padding:"8px 16px", borderRadius:8, cursor:"pointer", fontWeight:700, fontSize:12, border:`1px solid ${C.blue}`, background:"transparent", color:C.blue });
const mkBtnGreen = (C) => ({ padding:"9px 18px", borderRadius:8, border:"none", cursor:"pointer", background:C.green, color:"#fff", fontWeight:700, fontSize:12 });
const mkBtnSecondary = (C) => ({ padding:"9px 18px", borderRadius:8, cursor:"pointer", fontWeight:700, fontSize:12, border:`1px solid ${C.border}`, background:"transparent", color:C.textMid });

const margen = (pv, co) => {
  const p = parseFloat(pv), c = parseFloat(co);
  if (!c || c === 0) return "—";
  return ((p - c) / c * 100).toFixed(1) + "%";
};

/** Mes/año para control de caducidad en tabla (ej. 11/2027). */
function formatCaducidadMesAnio(fecha) {
  if (!fecha) return null;
  const s = String(fecha).slice(0, 10);
  const m = /^(\d{4})-(\d{2})/.exec(s);
  if (!m) return s;
  return `${m[2]}/${m[1]}`;
}

/**
 * Referencia del Excel mayorista (columna A del libro), guardada en `notas` como "Lista SKU origen".
 * No es el SKU FarmaCapital (`productos.sku`): es solo la ref. del distribuidor para pedidos / cruce con lista.
 */
function refListaMayoristaDesdeNotas(notas) {
  const m = String(notas ?? "").match(/Lista SKU origen:\s*([^·]+)/);
  return m ? m[1].trim() : "";
}

/** Jerarquía · línea general guardadas en import — útil para categorizar recompra (equiv. Excel G/I). */
function rubroComprasDesdeNotas(notas) {
  const s = String(notas ?? "");
  const mj = s.match(/Jerarquía:\s*([^·]+)/);
  let j = mj ? mj[1].trim() : "";
  const ml = s.match(/Línea:\s*(.+)$/);
  let ln = ml ? ml[1].trim() : "";
  if (j === "—") j = "";
  if (ln === "—") ln = "";
  const parts = [j, ln].filter(Boolean);
  return parts.length ? parts.join(" · ") : "";
}

/** Texto que parece solo concentración/dosis (mal colocado a veces en principio_activo en CSV viejos). */
function esSoloConcentracionTexto(s) {
  const t = String(s ?? "").trim();
  if (!t) return false;
  return /^(\d+(?:[.,]\d+)?\s*(?:mg|g|gr|gm|mcg|µg|ug|ml|mcl|%|iu|ui|meq)\b|\d+(?:[.,]\d+)?\s*-\s*\d+(?:[.,]\d+)?\s*(?:mg|g)?)$/i.test(t);
}

/**
 * Presentación empotrada al final del nombre en listas mayoristas (ej. "... Ad 30Comp", "... 20 Tab").
 * Solo usamos inferencia si la columna Presentación viene vacía en BD/import.
 */
function inferPresentacionDesdeNombre(nombre) {
  const s = String(nombre ?? "").trim();
  if (!s) return { nombreCorto: "", presentacion: "" };
  const patterns = [
    /\s+Ad\s+\d+\s*[Cc](?:omp|aps?)\b/i,
    /\s+\d+\s*[Cc](?:omp|aps?|aja)\b/i,
    /\s+\d+\s*[Tt]ab(?:letas)?\b/i,
    /\s+\d+\s*[Cc]aps?\b/i,
    /\s+\d+\s*(?:COMP|TAB)\b/,
  ];
  for (const re of patterns) {
    const m = s.match(new RegExp(`^(.+?)(${re.source})$`, "i"));
    if (m && m[1].trim().length >= 2) {
      return { nombreCorto: m[1].trim(), presentacion: m[2].trim() };
    }
  }
  return { nombreCorto: s, presentacion: "" };
}

function codigoBarrasLimpio(v) {
  return String(v ?? "").replace(/\D/g, "").trim();
}

function productoSinCodigoBarras(p) {
  return !codigoBarrasLimpio(p?.codigo_barras);
}

function productoSinPrecioVenta(p) {
  return !productoEsVendible(p);
}

/** Parte nombre/presentación y mueve dosis suelta de principio → concentración al importar CSV. */
function normalizarCamposFarmaceuticosImport(row) {
  const out = { ...row };
  let pa = String(out.principio_activo ?? "").trim();
  let conc = String(out.concentracion ?? "").trim();

  if (pa && esSoloConcentracionTexto(pa)) {
    if (!conc) out.concentracion = pa;
    out.principio_activo = null;
    pa = "";
  }

  const presStored = String(out.presentacion ?? "").trim();
  const nombre = String(out.nombre ?? "").trim();
  if (!presStored && nombre) {
    const inf = inferPresentacionDesdeNombre(nombre);
    if (inf.presentacion) {
      out.presentacion = inf.presentacion;
      out.nombre = inf.nombreCorto;
    }
  }
  return out;
}

function lineaPrincipioQuimicoTabla(p) {
  const dg = String(p.denominacion_generica ?? "").trim();
  const pa = String(p.principio_activo ?? "").trim();
  if (dg) return dg;
  if (pa && !esSoloConcentracionTexto(pa)) return pa;
  return "";
}

/** Dosis para segunda línea bajo principio (concentración o PA mal cargado como dosis). */
function lineaDosisTabla(p) {
  const c = String(p.concentracion ?? "").trim();
  const pa = String(p.principio_activo ?? "").trim();
  if (c) return c;
  if (pa && esSoloConcentracionTexto(pa)) return pa;
  return "";
}

function nombreYPresentacionTabla(p) {
  const presStored = String(p.presentacion ?? "").trim();
  const inf = inferPresentacionDesdeNombre(p.nombre);
  if (presStored) {
    return { nombre: p.nombre, presentacion: presStored };
  }
  if (inf.presentacion) {
    return { nombre: inf.nombreCorto, presentacion: inf.presentacion };
  }
  return { nombre: p.nombre, presentacion: "" };
}

const tdEllipsisStyle = {
  display: "block",
  overflow: "hidden",
  textOverflow: "ellipsis",
  whiteSpace: "nowrap",
};

/** Offset bajo tabs sticky de InventarioHub */
const INV_TOOLBAR_STICKY_TOP = { mobile: 92, desktop: 112 };

const INV_INLINE_FIELD_PATCH = {
  sku: "sku",
  codigo_barras: "codigo_barras",
  nombre: "nombre",
  marca: "marca",
  presentacion: "presentacion",
  principio: "principio_activo",
  ubicacion: "ubicacion_texto",
  categoria: "categoria",
  tipo: "tipo",
  proveedor: "proveedor",
  min: "stock_minimo",
  precio: "precio",
  costo: "costo",
  desc: "descuento_pct",
};

function InventarioEditableCell({
  C,
  productId,
  field,
  value,
  display,
  tdStyle,
  inputStyle,
  inlineEdit,
  inlineSaving,
  onStart,
  onDraft,
  onCommit,
  onCancel,
  type = "text",
  options,
  mono = false,
  selectionMode = false,
  readOnly = false,
}) {
  const isEditing = inlineEdit?.productId === productId && inlineEdit?.field === field;
  const rowBg = tdStyle?.background;

  if (isEditing) {
    const controlProps = {
      autoFocus: true,
      value: inlineEdit.draft,
      disabled: inlineSaving,
      onChange: (e) => onDraft(e.target.value),
      onKeyDown: (e) => {
        if (e.key === "Enter") {
          e.preventDefault();
          onCommit(e.currentTarget.value);
        }
        if (e.key === "Escape") {
          e.preventDefault();
          onCancel();
        }
      },
      onBlur: (e) => {
        if (!inlineSaving) onCommit(e.currentTarget.value);
      },
      style: {
        ...inputStyle,
        width: "100%",
        padding: "4px 6px",
        fontSize: 11,
        fontFamily: mono ? "ui-monospace,Menlo,monospace" : undefined,
        boxSizing: "border-box",
      },
    };
    return (
      <td style={tdStyle}>
        {type === "select" ? (
          <select {...controlProps}>
            {(options || []).map((o) => (
              <option key={o} value={o}>
                {o}
              </option>
            ))}
          </select>
        ) : (
          <input type={type} {...controlProps} />
        )}
      </td>
    );
  }

  return (
    <td
      style={{ ...tdStyle, cursor: (selectionMode || readOnly) ? "default" : "pointer" }}
      title={readOnly ? undefined : selectionMode ? "Hay productos seleccionados — usa el menú azul arriba de la tabla" : "Clic para editar"}
      onMouseDown={(e) => {
        if (selectionMode || readOnly) return;
        const editingOther = inlineEdit && (inlineEdit.productId !== productId || inlineEdit.field !== field);
        // Si otra celda está en edición, no bloquees el blur: si no, el precio no se guarda.
        if (!editingOther) e.preventDefault();
      }}
      onClick={(e) => {
        e.stopPropagation();
        if (selectionMode || readOnly) return;
        onStart(productId, field, value);
      }}
      onMouseEnter={(e) => {
        e.currentTarget.style.background = "rgba(30, 58, 138, 0.07)";
      }}
      onMouseLeave={(e) => {
        e.currentTarget.style.background = rowBg || "";
      }}
    >
      {display}
    </td>
  );
}

const INV_CHECKBOX_COL_WIDTH = 38;
const INV_STICKY_COL_IDS = ["foto", "acciones", "skuFarmaCapital", "nombre"];

const INV_COL_WIDTHS_DEFAULT = {
  acciones: 104,
  codigoBarras: 128,
  nombre: 272,
  marca: 130,
  presentacion: 160,
  principio: 200,
  ubicacion: 180,
  categoria: 120,
  proveedor: 140,
};

const INV_COLUMN_DEFS = {
  foto: { label: "Foto", hint: "" },
  acciones: { label: "Acciones", hint: "Editar, lotes, activar/desactivar" },
  skuFarmaCapital: {
    label: "SKU",
    hint: "SKU FarmaCapital — identificador único (POS, ticket, código interno).",
  },
  codigoBarras: {
    label: "Cód. barras",
    hint: "EAN/UPC escaneable en POS y resurtido. Clic en la celda para editar.",
  },
  nombre: { label: "Nombre", hint: "" },
  marca: { label: "Marca", hint: "" },
  presentacion: { label: "Presentación", hint: "" },
  principio: { label: "Principio activo", hint: "" },
  ubicacion: { label: "Ubicación", hint: "" },
  categoria: { label: "Categoría", hint: "" },
  tipo: { label: "Tipo", hint: "" },
  proveedor: { label: "Proveedor", hint: "" },
  stock: { label: "Stock", hint: "" },
  min: { label: "Mín", hint: "" },
  precio: { label: "Precio", hint: "" },
  costo: { label: "Costo", hint: "" },
  margen: { label: "Margen%", hint: "" },
  cad: { label: "Cad.", hint: "Mes/año del lote más próximo — clic para editar" },
  agot: { label: "Agot. (días)", hint: "" },
  desc: { label: "Desc%", hint: "" },
  estado: { label: "Estado", hint: "" },
};

const INV_ICON_BTN = {
  borderRadius: 4,
  padding: "1px 4px",
  cursor: "pointer",
  fontSize: 11,
  lineHeight: 1.1,
  fontWeight: 700,
  display: "inline-flex",
  alignItems: "center",
  justifyContent: "center",
  minWidth: 20,
  minHeight: 20,
  flexShrink: 0,
};

const INV_COMPACT_CELL_PAD = "4px 6px";

const INV_COLUMN_ORDER_DEFAULT = [
  "foto",
  "acciones",
  "skuFarmaCapital",
  "codigoBarras",
  "nombre",
  "marca",
  "presentacion",
  "principio",
  "ubicacion",
  "categoria",
  "tipo",
  "proveedor",
  "stock",
  "min",
  "precio",
  "costo",
  "margen",
  "cad",
  "agot",
  "desc",
  "estado",
];

function invColumnPixelWidth(colId, colWidths) {
  const map = {
    foto: 44,
    acciones: Math.max(88, Number(colWidths?.acciones) || INV_COL_WIDTHS_DEFAULT.acciones),
    skuFarmaCapital: 118,
    codigoBarras: Math.max(100, Number(colWidths?.codigoBarras) || INV_COL_WIDTHS_DEFAULT.codigoBarras),
    nombre: Math.max(200, Number(colWidths?.nombre) || INV_COL_WIDTHS_DEFAULT.nombre),
    marca: Math.max(90, Number(colWidths?.marca) || INV_COL_WIDTHS_DEFAULT.marca),
    presentacion: Math.max(110, Number(colWidths?.presentacion) || INV_COL_WIDTHS_DEFAULT.presentacion),
    principio: Math.max(130, Number(colWidths?.principio) || INV_COL_WIDTHS_DEFAULT.principio),
    ubicacion: Math.max(120, Number(colWidths?.ubicacion) || INV_COL_WIDTHS_DEFAULT.ubicacion),
    categoria: Math.max(100, Number(colWidths?.categoria) || INV_COL_WIDTHS_DEFAULT.categoria),
    proveedor: Math.max(100, Number(colWidths?.proveedor) || INV_COL_WIDTHS_DEFAULT.proveedor),
  };
  return map[colId] ?? 96;
}

function inventarioStickyStyle(colId, colOrder, colWidths, { header, bg, hasCheckbox = true }) {
  if (!INV_STICKY_COL_IDS.includes(colId)) return {};
  const myIndex = colOrder.indexOf(colId);
  if (myIndex < 0) return {};
  let left = hasCheckbox ? INV_CHECKBOX_COL_WIDTH : 0;
  for (const id of colOrder) {
    if (id === colId) break;
    if (INV_STICKY_COL_IDS.includes(id)) left += invColumnPixelWidth(id, colWidths);
  }
  const w = invColumnPixelWidth(colId, colWidths);
  const stickyRank = INV_STICKY_COL_IDS.indexOf(colId);
  const hasStickyAfter = colOrder.slice(myIndex + 1).some((id) => INV_STICKY_COL_IDS.includes(id));
  return {
    position: "sticky",
    left,
    width: w,
    minWidth: w,
    maxWidth: w,
    boxSizing: "border-box",
    zIndex: header ? 5 + stickyRank : 2 + stickyRank,
    background: bg,
    borderRight: !hasStickyAfter ? "1px solid #e2e8f0" : undefined,
  };
}

function loadInvColumnOrder() {
  try {
    const saved = JSON.parse(localStorage.getItem("farmacapital_inv_col_order") || "null");
    if (Array.isArray(saved) && saved.length) {
      const seen = new Set();
      const cleaned = [];
      for (const id of saved) {
        if (!INV_COLUMN_ORDER_DEFAULT.includes(id) || seen.has(id)) continue;
        seen.add(id);
        cleaned.push(id);
      }
      const missing = INV_COLUMN_ORDER_DEFAULT.filter((id) => !seen.has(id));
      return [...cleaned, ...missing];
    }
  } catch {
    /* noop */
  }
  return [...INV_COLUMN_ORDER_DEFAULT];
}

function reorderInvColumnOrder(order, fromId, toId) {
  if (fromId === toId) return order;
  const next = order.filter((id) => id !== fromId);
  const toIdx = next.indexOf(toId);
  if (toIdx < 0) return order;
  next.splice(toIdx, 0, fromId);
  return next;
}

const descargarPlantilla = () => {
  const headers = [
    "SKU", "Codigo_Barras", "Nombre", "Categoria", "Tipo", "Stock", "Stock_Minimo",
    "Precio_Venta", "Costo", "Proveedor", "Lote", "Fecha_Caducidad",
    "Descuento_Porcentaje",
    "Marca_Comercial", "Principio_Activo", "Concentracion", "Presentacion",
    "Contenido_Caja", "Linea_Comercial", "Grupo_Farmacologico", "Jerarquia",
    "SKU_Casa_Saba", "Stock_Maximo", "Notas"
  ];
  const ejemplo = [
    ["FAR001","7501234567890","Paracetamol 500mg","Analgésico","generico","50","10","12.00","6.00","Casa Saba","L2024-01","2026-12-31","0",
     "ACETAFEN","Paracetamol","500MG","TABLETA","10 TABLETAS","ANALGESICOS","ANALGESICO/ANTIPIRETICO","MEDICAMENTOS","162","30",""],
    ["FAR002","7509876543210","Omeprazol 20mg","Gastro","generico","30","5","20.00","10.00","Marzam","L2024-02","2026-06-30","0",
     "OMEZOL","Omeprazol","20MG","CAPSULA","14 CAPSULAS","ESTOMACALES (GASTRO)","PROTECTOR GASTRICO","MEDICAMENTOS","523","15",""],
  ];
  const csv = [headers, ...ejemplo].map(r=>r.map(v=>`"${v}"`).join(",")).join("\n");
  const blob = new Blob(["\uFEFF"+csv],{type:"text/csv;charset=utf-8;"});
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href=url; a.download="plantilla_inventario_farmacapital.csv";
  a.click(); URL.revokeObjectURL(url);
};

/** RFC4180 simplificado: respeta comas dentro de `"..."`. */
function splitCsvLine(line) {
  const result = [];
  let cur = "";
  let inQuotes = false;
  for (let i = 0; i < line.length; i++) {
    const c = line[i];
    if (inQuotes) {
      if (c === '"') {
        if (line[i + 1] === '"') {
          cur += '"';
          i++;
        } else {
          inQuotes = false;
        }
      } else {
        cur += c;
      }
    } else if (c === '"') {
      inQuotes = true;
    } else if (c === ",") {
      result.push(cur.trim());
      cur = "";
    } else {
      cur += c;
    }
  }
  result.push(cur.trim());
  return result;
}

/**
 * Cabecera CSV → clave estable sin tildes ni puntuación extra (ej. Excel "Presentación" → presentacion).
 * Sin esto, headerSet.has("presentacion") falla si el archivo trae "presentación".
 */
function normCsvHeader(h) {
  let s = String(h ?? "")
    .replace(/"/g, "")
    .trim()
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "");
  s = s.replace(/\./g, " ");
  s = s.replace(/[^a-z0-9]+/g, " ");
  s = s.trim().replace(/\s+/g, "_");
  return s;
}

/** Cabeceras CSV que no deben pasarse como JSON plano a create_producto_secure (van en metaPatch). */
const CSV_META_HEADER_KEYS = new Set([
  "marca",
  "marca_comercial",
  "presentacion",
  "presentacion_completada",
  "principio_activo",
  "principio_activo_completado",
  "ubicacion",
  "ubicacion_texto",
  "notas",
  "jerarquia",
  "grupo_articulos",
  "rubro",
  "linea_general",
  "linea",
  "ref_lista_mayorista",
  "lista_sku_origen",
  "sku_lista",
  "ref_lista",
  "sku_casa_saba",
  "linea_comercial",
  "concentracion",
]);

const CSV_FIELD_ALIASES = {
  marca: ["marca", "marca_comercial"],
  presentacion: ["presentacion", "presentacion_completada"],
  principio_activo: ["principio_activo", "principio_activo_completado"],
  ubicacion_texto: ["ubicacion", "ubicacion_texto"],
  concentracion: ["concentracion"],
};

function csvPick(row, ...aliases) {
  for (const a of aliases) {
    const key = normCsvHeader(a);
    const raw = row[key];
    if (raw == null) continue;
    const s = String(raw).trim();
    if (s !== "") return s;
  }
  return "";
}

const CSV_REF_LISTA_ALIASES = [
  "ref_lista_mayorista",
  "lista_sku_origen",
  "sku_lista",
  "ref_lista",
  "sku_casa_saba",
];

/** Construye parche JSON para admin_editar_producto según columnas presentes en el CSV. */
function csvMetaPatchFromHeaders(row, headerSet) {
  const patch = {};
  if (!headerSet || headerSet.size === 0) return patch;

  for (const [field, aliases] of Object.entries(CSV_FIELD_ALIASES)) {
    const present = aliases.some((a) => headerSet.has(normCsvHeader(a)));
    if (!present) continue;
    const val = csvPick(row, ...aliases);
    patch[field] = val === "" ? null : val;
  }

  const refAliasesNorm = CSV_REF_LISTA_ALIASES.map((a) => normCsvHeader(a));
  const hasRefCol = refAliasesNorm.some((k) => headerSet.has(k));
  const refVal = csvPick(row, ...CSV_REF_LISTA_ALIASES);

  const rubKeysNorm = ["jerarquia", "grupo_articulos", "rubro", "linea_general", "linea", "linea_comercial"];
  const hasRubCols = rubKeysNorm.some((k) => headerSet.has(k));

  const notasPieces = [];
  if (hasRefCol && refVal) notasPieces.push(`Lista SKU origen: ${refVal}`);

  if (headerSet.has("notas")) {
    const raw = csvPick(row, "notas");
    if (raw) notasPieces.push(raw);
  } else if (hasRubCols) {
    const jer = csvPick(row, "rubro", "grupo_articulos", "jerarquia");
    const lin = csvPick(row, "linea_general", "linea_comercial", "linea");
    if (jer) notasPieces.push(`Jerarquía: ${jer}`);
    if (lin) notasPieces.push(`Línea: ${lin}`);
  }

  const wantNotasPatch =
    headerSet.has("notas") ||
    hasRefCol ||
    hasRubCols;

  if (wantNotasPatch) {
    patch.notas = notasPieces.length ? notasPieces.join(" · ") : null;
  }

  return patch;
}

function rowSinMetaCsv(row) {
  const o = { ...row };
  for (const k of CSV_META_HEADER_KEYS) {
    delete o[k];
  }
  return o;
}

const parsearCSV = (texto) => {
  const lineas = texto.trim().split("\n").map(l=>l.trim()).filter(Boolean);
  if(lineas.length<2) return {ok:false,msg:"El archivo está vacío",rows:[]};
  
  const normalizar = (s) => s
    .replace(/"/g, "").trim().toLowerCase().replace(/ /g, "_")
    .replace(/[áàä]/g, "a").replace(/[éèë]/g, "e")
    .replace(/[íìï]/g, "i").replace(/[óòö]/g, "o")
    .replace(/[úùü]/g, "u").replace(/ñ/g, "n")
    .replace(/%/g, "_porcentaje");
  
  const headers = lineas[0].split(",").map(normalizar);
  
  const parseLine = (line) => {
    const result = [];
    let current = '';
    let inQuotes = false;
    for (let i = 0; i < line.length; i++) {
      const ch = line[i];
      if (ch === '"') inQuotes = !inQuotes;
      else if (ch === ',' && !inQuotes) { result.push(current.trim()); current = ''; }
      else current += ch;
    }
    result.push(current.trim());
    return result.map(v => v.replace(/^"|"$/g, ""));
  };
  
  const rows = [];
  const errores = [];
  for(let i=1; i<lineas.length; i++){
    const vals = parseLine(lineas[i]);
    const row = {};
    headers.forEach((h,j)=>{ row[h] = (vals[j]||"").trim(); });
    if(!row.nombre) { errores.push(`Fila ${i+1}: Nombre requerido`); continue; }

    const raw = {
      sku:           row.sku || null,
      codigo_barras: row.codigo_barras || row.codigo_de_barras || null,
      nombre:        row.nombre,
      categoria:     row.categoria || "Otro",
      tipo:          row.tipo || "generico",
      stock:         parseInt(row.stock) || 0,
      stock_minimo:  parseInt(row.stock_minimo) || 0,
      precio:        parseFloat(row.precio_venta || row.precio) || 0,
      costo:         parseFloat(row.costo) || 0,
      proveedor:     row.proveedor || null,
      lote:          row.lote || null,
      fecha_caducidad: row.fecha_caducidad || null,
      descuento_pct: parseFloat(row.descuento_porcentaje || row.descuento_pct) || 0,
      activo: true,
      // Extras
      marca_comercial:     row.marca_comercial || null,
      principio_activo:    row.principio_activo || null,
      concentracion:       row.concentracion || null,
      presentacion:        row.presentacion || null,
      contenido_caja:      row.contenido_caja || null,
      linea_comercial:     row.linea_comercial || null,
      grupo_farmacologico: row.grupo_farmacologico || null,
      jerarquia:           row.jerarquia || null,
      sku_casa_saba:       row.sku_casa_saba || null,
      stock_maximo:        parseInt(row.stock_maximo) || null,
      notas:               row.notas || null,
    };
    rows.push(normalizarCamposFarmaceuticosImport(raw));
  }
  return {ok:rows.length>0, msg:errores.length?`${errores.length} errores`:null, rows};
};

const exportarCSV = (productos) => {
  const headers = [
    "SKU", "Codigo_Barras", "Nombre", "Categoria", "Tipo", "Stock", "Stock_Minimo",
    "Precio_Venta", "Costo", "Proveedor", "Lote", "Fecha_Caducidad",
    "Descuento_Porcentaje",
    "Marca_Comercial", "Principio_Activo", "Concentracion", "Presentacion",
    "Contenido_Caja", "Linea_Comercial", "Grupo_Farmacologico", "Jerarquia",
    "SKU_Casa_Saba", "Margen_Porcentaje", "Stock_Maximo", "Notas"
  ];
  const rows = productos.map(p => [
    p.sku||"", p.codigo_barras||"", p.nombre||"", p.categoria||"", p.tipo||"generico",
    p.stock??0, p.stock_minimo??0,
    parseFloat(p.precio||0).toFixed(2), parseFloat(p.costo||0).toFixed(2),
    p.proveedor||"", p.lote||p.min_lote||"", p.fecha_caducidad||p.min_caducidad_lotes||"",
    p.descuento_pct||0,
    p.marca_comercial||"", p.principio_activo||"", p.concentracion||"",
    p.presentacion||"", p.contenido_caja||"", p.linea_comercial||"",
    p.grupo_farmacologico||"", p.jerarquia||"", p.sku_casa_saba||"",
    margen(p.precio, p.costo), p.stock_maximo||"", p.notas||""
  ]);
  const csv = [headers, ...rows].map(r => r.map(v => `"${v}"`).join(",")).join("\n");
  const blob = new Blob(["\uFEFF"+csv], { type:"text/csv;charset=utf-8;" });
  const url  = URL.createObjectURL(blob);
  const a    = document.createElement("a");
  a.href = url; 
  a.download = `inventario_farmacapital_${new Date().toISOString().slice(0,10)}.csv`;
  a.click(); URL.revokeObjectURL(url);
};

function ProductoModal({ initial, onClose, onSaved, onEditarCaducidad, onRecibirMercancia, onCaducidadSaved }) {
  const C = C_LIGHT;
  const inputStyle = mkInputStyle(C);
  const labelStyle = mkLabelStyle(C);
  const btnSecondary = mkBtnSecondary(C);
  const btnPrimary = mkBtnPrimary(C);
  const btnOutline = mkBtnOutline(C);
  const btnGreen = mkBtnGreen(C);
  const loteCadRef = useMemo(() => {
    if (!initial?.id) return null;
    return resolverLoteCaducidadProducto(initial);
  }, [initial]);
  const [form, setForm]     = useState(() => {
    const base = {
      ...(initial || EMPTY),
      imagen_url: (initial || EMPTY).imagen_url || "",
      imagen_mobile_url: (initial || EMPTY).imagen_mobile_url || "",
      _focusBarcode: Boolean(initial?._focusBarcode),
    };
    for (const k of ["nombre", "sku", "codigo_barras", "proveedor", "lote"]) {
      if (base[k] == null) base[k] = "";
    }
    return base;
  });
  const [errors, setErrors] = useState({});
  const [saving, setSaving] = useState(false);
  const [caducidadLote, setCaducidadLote] = useState(() => loteCadRef?.fecha_caducidad || "");
  const [cadSaving, setCadSaving] = useState(false);
  const barcodeRef = useRef(null);
  useEffect(() => {
    setCaducidadLote(loteCadRef?.fecha_caducidad || "");
  }, [loteCadRef?.id, loteCadRef?.fecha_caducidad]);
  useEffect(() => {
    if (form._focusBarcode) {
      barcodeRef.current?.focus();
    }
  }, [form._focusBarcode, form.id]);

  const guardarCaducidadLote = async (fecha, { quitar = false } = {}) => {
    const prev = loteCadRef?.fecha_caducidad || null;
    const next = quitar ? null : (fecha || null);
    if (!quitar && !next) {
      if (!prev) return;
      if (!window.confirm("¿Quitar la fecha de caducidad de este lote?")) {
        setCaducidadLote(prev);
        return;
      }
      return guardarCaducidadLote(null, { quitar: true });
    }
    if (!quitar && prev === next) return;
    if (quitar && !prev) {
      setCaducidadLote("");
      return;
    }
    const tok = sessionStorage.getItem("farmacapital_session_token");
    if (!tok) {
      showToast("Sesión expirada.", "error");
      setCaducidadLote(loteCadRef?.fecha_caducidad || "");
      return;
    }
    if (quitar && prev === null) return;
    setCadSaving(true);
    try {
      const loteId = loteCadRef?.id ?? resolverLoteCaducidadProducto(initial)?.id ?? null;
      const { data: resp, error } = await rpcGuardarCaducidadProducto(tok, initial.id, next, loteId);
      if (error) {
        showToast(error.message, "error");
        setCaducidadLote(loteCadRef?.fecha_caducidad || "");
        return;
      }
      if (!resp?.success) {
        showToast("No se pudo guardar la caducidad.", "error");
        setCaducidadLote(loteCadRef?.fecha_caducidad || "");
        return;
      }
      const msg = resp.accion === "quitar"
        ? "Fecha de caducidad eliminada"
        : resp.accion === "crear_referencia"
          ? "Caducidad guardada (lote de referencia, sin stock)"
          : resp.accion === "crear"
            ? `Lote creado (${resp.cantidad ?? form.stock} pza.) con caducidad`
            : "Caducidad actualizada";
      showToast(msg, "success");
      if (quitar) setCaducidadLote("");
      await onCaducidadSaved?.();
    } finally {
      setCadSaving(false);
    }
  };

  const quitarCaducidadLote = async () => {
    if (!caducidadLote && !loteCadRef?.fecha_caducidad) return;
    if (!window.confirm("¿Quitar la fecha de caducidad de este lote?")) return;
    await guardarCaducidadLote(null, { quitar: true });
  };

  const set = (k, v) => setForm(f => ({ ...f, [k]: v }));
  const validate = () => {
    const e = {};
    if (!(form.nombre ?? "").trim())                           e.nombre       = "Requerido";
    if (!form.precio||parseFloat(form.precio)<=0) e.precio = "Debe ser mayor a $0";
    if (!form.costo||parseFloat(form.costo)<0)         e.costo        = "Debe ser 0 o mayor";
    if (form.stock === "" || form.stock === null)       e.stock        = "Requerido";
    const cb = codigoBarrasLimpio(form.codigo_barras);
    if (cb && (cb.length < 8 || cb.length > 14)) {
      e.codigo_barras = "Usa 8–14 dígitos (EAN/UPC)";
    }
    return e;
  };
  const handleSave = async () => {
    const e = validate();
    if (Object.keys(e).length) { setErrors(e); return; }
    setSaving(true);
    try {
      const stockInt = parseInt(form.stock) || 0;
      const costoNum = parseFloat(form.costo) || 0;

      // Campos del producto (sin stock/costo que viajan al lote en el alta)
      const productoFields = aplicarReglaPrecioUnidad({
        nombre: (form.nombre ?? "").trim(),
        sku: (form.sku ?? "").trim() || null,
        codigo_barras: codigoBarrasLimpio(form.codigo_barras) || null,
        categoria: form.categoria,
        precio: parseFloat(form.precio),
        costo: costoNum,
        stock_minimo: form.stock_minimo !== "" ? parseInt(form.stock_minimo) : 0,
        tipo: form.tipo,
        proveedor: (form.proveedor ?? "").trim() || null,
        descuento_pct: parseFloat(form.descuento_pct) || 0,
        principio_activo: (form.principio_activo ?? "").trim() || null,
        denominacion_generica: (form.denominacion_generica ?? "").trim() || null,
        denominacion_distintiva: (form.denominacion_distintiva ?? "").trim() || null,
        concentracion: (form.concentracion ?? "").trim() || null,
        presentacion: (form.presentacion ?? "").trim() || null,
        forma_farmaceutica: (form.forma_farmaceutica ?? "").trim() || null,
        marca: (form.marca ?? "").trim() || null,
        ubicacion_texto: (form.ubicacion_texto ?? "").trim() || null,
        activo: form.activo,
        venta_unidad: form.venta_unidad || false,
        unidades_por_caja: form.venta_unidad ? parseInt(form.unidades_por_caja) || 0 : 0,
        precio_unidad: form.venta_unidad ? Math.ceil(parseFloat(form.precio_unidad) || 0) : 0,
        stock_unidades: form.venta_unidad ? parseInt(form.stock_unidades) || 0 : 0,
      });

      const sesion = leerSesion();
      await idEmpleadoUsuarios(sesion);

      const tok = sessionStorage.getItem("farmacapital_session_token");
      if (!tok) {
        showToast("Sesión expirada. Inicia sesión de nuevo.", "error");
        return;
      }

      let err;
      const urlNow = (form.imagen_url || "").trim();
      if (form.id) {
        const patch = {
          ...productoFields,
          costo: costoNum,
          imagen_url: urlNow || null,
          imagen_mobile_url: urlNow || null,
          manual_price_override: true,
        };
        const { error: editErr } = await supabase.rpc("admin_editar_producto", {
          p_session_token: tok,
          p_producto_id: form.id,
          p_patch: patch,
        });
        err = editErr;
        if (!err) {
          const { error: adjErr } = await supabase.rpc("adjust_stock_secure", {
            p_session_token: tok,
            p_producto_id: form.id,
            p_nuevo_stock: stockInt,
            p_motivo: "Edición manual desde Inventario",
          });
          if (adjErr) err = adjErr;
        }
      } else {
        const pdata = {
          ...productoFields,
          costo: costoNum,
          ...(urlNow ? { imagen_url: urlNow, imagen_mobile_url: urlNow } : {}),
        };
        const { data: created, error: rpcErr } = await supabase.rpc("create_producto_secure", {
          p_session_token: tok,
          p_producto_data: pdata,
          p_cantidad_inicial: stockInt,
          p_numero_lote: (form.lote ?? "").trim() || null,
          p_fecha_caducidad: form.fecha_caducidad || null,
          p_costo_unitario: costoNum || null,
        });
        err = rpcErr;
      }
      if (err) {
        showToast("Error al guardar: " + (err.message || String(err)), "error");
        return;
      }
      if (form.id) {
        logAudit(sesion, "EDITAR_PRODUCTO", "productos", form.id, {
          nombre: form.nombre, precio: form.precio, costo: form.costo, stock: form.stock
        });
      } else {
        logAudit(sesion, "CREAR_PRODUCTO", "productos", "nuevo", {
          nombre: form.nombre, precio: form.precio
        });
      }
      onSaved();
    } catch (unexpected) {
      console.error("ProductoModal guardar:", unexpected);
      showToast("Error al guardar: " + (unexpected?.message || String(unexpected)), "error");
    } finally {
      setSaving(false);
    }
  };
  const field = (label, key, type="text", required=false) => (
    <div style={{ marginBottom:12 }}>
      <label style={labelStyle}>{label}{required&&<span style={{color:C.red}}> *</span>}</label>
      <input type={type} value={form[key]} onChange={e=>set(key,e.target.value)}
        style={{...inputStyle, borderColor:errors[key]?C.red:C.border}}/>
      {errors[key]&&<span style={{color:C.red,fontSize:10}}>{errors[key]}</span>}
    </div>
  );

  const upcVenta = parseInt(form.unidades_por_caja, 10) || 0;
  const costoPieza = upcVenta > 0 && form.costo !== "" ? (parseFloat(form.costo) || 0) / upcVenta : 0;
  const precioPieza = Math.ceil(parseFloat(form.precio_unidad) || 0);
  const minPrecioPieza = upcVenta > 0
    ? sugerirPrecioUnidad(form.precio, form.costo, upcVenta, form.categoria, form.tipo)
    : 0;
  const margenPiezaPct = precioPieza > 0 && costoPieza > 0 ? margenBrutoPct(precioPieza, costoPieza) : null;
  const margenCajaPct = form.precio && form.costo ? margenBrutoPct(form.precio, form.costo) : null;
  const margenPiezaColor = precioPieza > 0 && precioPieza < minPrecioPieza
    ? C.amber
    : margenPiezaPct != null && margenCajaPct != null && margenPiezaPct >= margenCajaPct
      ? C.green
      : C.textMid;

  return (
    <div style={{position:"fixed",inset:0,background:"#00000099",zIndex:1000,display:"flex",alignItems:"center",justifyContent:"center"}}>
      <div style={{background:C.card,border:`1px solid ${C.borderHi}`,borderRadius:14,width:"min(680px,95vw)",maxHeight:"90vh",overflowY:"auto",padding:28,boxShadow:"0 24px 60px #00000088"}}>
        <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:20}}>
          <h2 style={{margin:0,color:C.text,fontSize:16,fontWeight:800}}>{form.id?"✏️ Editar producto":"➕ Nuevo producto"}</h2>
          <button onClick={onClose} style={{background:"none",border:"none",color:C.textMid,fontSize:20,cursor:"pointer"}}>✕</button>
        </div>
        <div style={{marginBottom:16,padding:14,background:C.bg,borderRadius:10,border:`1px solid ${C.border}`}}>
          <label style={{color:C.textMid,fontSize:11,fontWeight:700,display:"block",marginBottom:8}}>📷 FOTO DEL PRODUCTO</label>
          <ImageUploader
            bucket="productos"
            currentUrl={form.imagen_url}
            onUploaded={(url)=>setForm((f)=>({...f,imagen_url:url,imagen_mobile_url:url}))}
            onRemoved={()=>{
              setForm((f)=>({...f,imagen_url:"",imagen_mobile_url:""}));
              if(form.id){
                const t=sessionStorage.getItem("farmacapital_session_token");
                if(t){
                  supabase.rpc("admin_editar_producto",{p_session_token:t,p_producto_id:form.id,p_patch:{imagen_url:"",imagen_mobile_url:""}})
                    .then(({error})=>{ if(error)showToast(error.message,"error"); else showToast("Imagen quitada en servidor","info"); });
                }
              }
            }}
            aspectRatio="1:1"
            filenamePrefix={(form.sku||form.nombre||"prod").toString()}
            size="medium"
          />
          <div style={{fontSize:11,color:C.textDim,marginTop:8,lineHeight:1.4}}>
            💡 También podés pegar URL abajo si preferís. Bucket <code style={{background:C.card,padding:"1px 4px",borderRadius:4}}>productos</code> · <code style={{background:C.card,padding:"1px 4px",borderRadius:4}}>sql/storage_buckets.sql</code>
          </div>
        </div>
        <div style={{display:"grid",gridTemplateColumns:"1fr 1fr",gap:"0 18px"}}>
          <div>
            {field("Nombre","nombre","text",true)}
            {field("SKU FarmaCapital","sku")}
            <div style={{ marginBottom: 12 }}>
              <label style={labelStyle}>Código de barras</label>
              <input
                ref={barcodeRef}
                value={form.codigo_barras || ""}
                onChange={(e) => set("codigo_barras", e.target.value.replace(/[^\d]/g, ""))}
                onKeyDown={(e) => {
                  if (e.key === "Enter") {
                    e.preventDefault();
                    handleSave();
                  }
                }}
                placeholder="Escanea o escribe EAN (750…)"
                inputMode="numeric"
                autoComplete="off"
                style={{
                  ...inputStyle,
                  ...(errors.codigo_barras ? { borderColor: C.red } : {}),
                  fontFamily: "ui-monospace,Menlo,monospace",
                }}
              />
              {errors.codigo_barras ? (
                <div style={{ color: C.red, fontSize: 11, marginTop: 4 }}>{errors.codigo_barras}</div>
              ) : null}
              {productoSinCodigoBarras(form) ? (
                <div style={{ fontSize: 11, color: C.amber, marginTop: 6, fontWeight: 600 }}>
                  Sin código de barras — no se puede escanear en POS hasta capturarlo.
                </div>
              ) : (
                <div style={{ fontSize: 11, color: C.textDim, marginTop: 6, lineHeight: 1.45 }}>
                  Escanea el EAN/UPC de la caja con la pistola (POS, resurtido y recepción usan este número).
                </div>
              )}
            </div>
            <div style={{marginBottom:12}}>
              <label style={labelStyle}>Categoría</label>
              <select value={form.categoria} onChange={e=>set("categoria",e.target.value)} style={{...inputStyle}}>
                {CATEGORIAS.map(c=><option key={c} value={c}>{c}</option>)}
              </select>
            </div>
            <div style={{marginBottom:12}}>
              <label style={labelStyle}>Tipo</label>
              <select value={form.tipo} onChange={e=>set("tipo",e.target.value)} style={{...inputStyle}}>
                <option value="generico">Genérico</option>
                <option value="marca">Marca</option>
              </select>
            </div>
            {field("Proveedor","proveedor")}
            {field("Principio activo","principio_activo")}
            {field("Marca comercial","marca")}
            {field("Denominación genérica","denominacion_generica")}
            {field("Denominación distintiva / marca clínica","denominacion_distintiva")}
            {!form.id && field("Lote inicial","lote")}
            {!form.id && field("Fecha de caducidad (lote inicial)","fecha_caducidad","date")}
            {form.id && (() => {
              const activos = initial?.lotes_activos
                ?? (initial?.lotes || []).filter((l) => l.activo !== false && (l.cantidad_actual || 0) > 0);
              const diasProx = diasParaCaducar(caducidadLote || loteCadRef?.fecha_caducidad);
              const multiLotes = activos.length > 1;
              return (
                <div style={{ marginBottom: 12, padding: "12px 14px", background: C.blueDim, borderRadius: 8, fontSize: 11, color: C.blue, lineHeight: 1.5 }}>
                  <label style={{ ...labelStyle, color: C.blue, marginBottom: 6 }}>
                    Fecha de caducidad
                    {loteCadRef?.numero_lote ? (
                      <span style={{ fontWeight: 400, color: C.textMid }}> · Lote {loteCadRef.numero_lote}</span>
                    ) : null}
                  </label>
                  {loteCadRef ? (
                    <>
                      <input
                        type="date"
                        value={caducidadLote}
                        disabled={cadSaving}
                        onChange={(e) => setCaducidadLote(e.target.value)}
                        onBlur={(e) => guardarCaducidadLote(e.target.value || null)}
                        style={{
                          ...inputStyle,
                          marginBottom: 8,
                          color: diasProx !== null && diasProx <= DIAS_CADUCIDAD_ALERTA ? C.red : C.text,
                          fontWeight: caducidadLote ? 600 : 400,
                        }}
                      />
                      {caducidadLote ? (
                        <div style={{ color: C.textMid, marginBottom: 8 }}>
                          {diasProx !== null && diasProx < 0
                            ? "Vencido"
                            : `Caducidad: ${formatCaducidadMesAnio(caducidadLote) || caducidadLote}`}
                        </div>
                      ) : (
                        <div style={{ color: C.textMid, marginBottom: 8 }}>Sin fecha de caducidad</div>
                      )}
                      {(caducidadLote || loteCadRef?.fecha_caducidad) ? (
                        <button
                          type="button"
                          disabled={cadSaving}
                          style={{ ...btnOutline, padding: "5px 10px", fontSize: 11, marginBottom: 8, borderColor: C.red, color: C.red }}
                          onClick={quitarCaducidadLote}
                        >
                          Quitar fecha
                        </button>
                      ) : null}
                      {multiLotes && onEditarCaducidad ? (
                        <button
                          type="button"
                          style={{ ...btnOutline, padding: "5px 10px", fontSize: 11, marginBottom: 8 }}
                          onClick={() => onEditarCaducidad(initial)}
                        >
                          Ver {activos.length} lotes
                        </button>
                      ) : null}
                    </>
                  ) : (
                    <>
                      <div style={{ color: C.textMid, marginBottom: 8 }}>
                        {(parseInt(form.stock, 10) || 0) > 0
                          ? <>Hay {form.stock} pza. en stock pero sin lote PEPS. Al elegir fecha se crea el lote <strong>sin cambiar cantidad ni precio</strong>.</>
                          : <>Sin stock ni lote. Al elegir fecha se crea un lote de referencia <strong>(0 pza.)</strong> — usá <strong>Recibir mercancía</strong> cuando entren unidades.</>}
                      </div>
                      <input
                        type="date"
                        value={caducidadLote}
                        disabled={cadSaving}
                        onChange={(e) => setCaducidadLote(e.target.value)}
                        onBlur={(e) => guardarCaducidadLote(e.target.value || null)}
                        style={{
                          ...inputStyle,
                          marginBottom: 8,
                          fontWeight: caducidadLote ? 600 : 400,
                        }}
                      />
                    </>
                  )}
                  <div style={{ display: "flex", flexWrap: "wrap", gap: 8 }}>
                    {loteCadRef && onEditarCaducidad && !multiLotes ? (
                      <button
                        type="button"
                        style={{ ...btnOutline, padding: "6px 12px", fontSize: 11 }}
                        onClick={() => onEditarCaducidad(initial)}
                      >
                        📅 Más lotes
                      </button>
                    ) : null}
                    {onRecibirMercancia && (
                      <button
                        type="button"
                        style={{ ...btnGreen, padding: "6px 12px", fontSize: 11 }}
                        onClick={() => onRecibirMercancia(initial)}
                      >
                        📦 Recibir mercancía
                      </button>
                    )}
                  </div>
                </div>
              );
            })()}
          </div>
          <div>
            {field("Precio de venta","precio","number",true)}
            {field("Costo","costo","number",true)}
            <div style={{marginBottom:12,padding:"8px 10px",background:C.blueDim,borderRadius:8,fontSize:11,color:C.blue,lineHeight:1.45}}>
              Margen sugerido: <strong>genérico / OTC +60%</strong> sobre costo · <strong>patente +30%</strong>.
              {form.costo ? (
                <> Ej.: costo ${parseFloat(form.costo).toFixed(2)} → ${Math.ceil(parseFloat(form.costo)*1.6*100)/100} (60%) o ${Math.ceil(parseFloat(form.costo)*1.3*100)/100} (30%).</>
              ) : null}
            </div>
            {field("Stock actual","stock","number",true)}
            {field("Stock mínimo","stock_minimo","number")}
            {field("Descuento %","descuento_pct","number")}
            {field("Concentración","concentracion")}
            {field("Presentación","presentacion")}
            {field("Forma farmacéutica","forma_farmaceutica")}
            {field("Ubicación física (anaquel/cajón/zona)","ubicacion_texto")}
            <div style={{marginBottom:12,display:"flex",alignItems:"center",gap:10}}>
              <input type="checkbox" id="activo_chk" checked={form.activo}
                onChange={e=>set("activo",e.target.checked)} style={{width:16,height:16,cursor:"pointer"}}/>
              <label htmlFor="activo_chk" style={{...labelStyle,margin:0,cursor:"pointer"}}>Producto activo</label>
            </div>
          </div>
        </div>

        <div style={{marginTop:16,padding:16,borderRadius:10,border:`1px solid ${C.border}`,background:C.cardDark}}>
          <label style={{...labelStyle,fontSize:12,fontWeight:700}}>O URL de imagen (opcional)</label>
          <input type="url" value={form.imagen_url||""} onChange={e=>setForm(f=>({...f,imagen_url:e.target.value,imagen_mobile_url:e.target.value}))}
            placeholder="https://..." style={{...inputStyle,fontSize:12}}/>
        </div>

        {/* ── Venta por unidad suelta ── */}
        <div style={{marginTop:16,padding:16,borderRadius:10,border:`1px solid ${C.border}`,background:C.cardDark}}>
          <div style={{display:"flex",alignItems:"center",gap:10,marginBottom:form.venta_unidad?14:0}}>
            <input type="checkbox" id="venta_unidad_chk" checked={form.venta_unidad||false}
              onChange={e=>{
                const on=e.target.checked;
                set("venta_unidad", on);
                if (on) {
                  set("precio_unidad", sugerirPrecioUnidad(form.precio, form.costo, form.unidades_por_caja || 1, form.categoria, form.tipo));
                }
              }} style={{width:16,height:16,cursor:"pointer"}}/>
            <label htmlFor="venta_unidad_chk" style={{...labelStyle,margin:0,cursor:"pointer",fontSize:13,fontWeight:700}}>
              💊 Permite venta por unidad suelta (caja abierta)
            </label>
          </div>
          {form.venta_unidad&&(
            <div style={{display:"grid",gridTemplateColumns:"1fr 1fr 1fr",gap:12,marginTop:12}}>
              <div>
                <label style={labelStyle}>Unidades por caja</label>
                <input type="number" min="1" value={form.unidades_por_caja}
                  onChange={e=>{ const u=parseInt(e.target.value,10)||1; set("unidades_por_caja",e.target.value); set("precio_unidad", sugerirPrecioUnidad(form.precio, form.costo, u, form.categoria, form.tipo)); }}
                  style={inputStyle} placeholder="20"/>
              </div>
              <div>
                <label style={labelStyle}>
                  Precio por unidad ($)
                  {margenPiezaPct != null ? (
                    <span style={{ color: margenPiezaColor, fontSize: 10, fontWeight: 700, marginLeft: 6 }}>
                      · margen {margenPiezaPct}%
                    </span>
                  ) : null}
                </label>
                <input type="number" min="0" step="0.01" value={form.precio_unidad}
                  onChange={e=>set("precio_unidad",Math.ceil(parseFloat(e.target.value)||0))}
                  style={inputStyle} placeholder="3"/>
                <div style={{ color: C.textDim, fontSize: 9, marginTop: 2, lineHeight: 1.45 }}>
                  {costoPieza > 0 ? <>Costo/pieza ${costoPieza.toFixed(2)}</> : "Indicá costo y unidades/caja"}
                  {precioPieza > 0 && minPrecioPieza > 0 && precioPieza < minPrecioPieza
                    ? <> · sugerido ${minPrecioPieza} (se guarda el que indiques)</>
                    : margenCajaPct != null
                      ? <> · margen caja {margenCajaPct}%</>
                      : null}
                </div>
              </div>
              <div>
                <label style={labelStyle}>Stock unidades sueltas</label>
                <input type="number" min="0" value={form.stock_unidades}
                  onChange={e=>set("stock_unidades",e.target.value)}
                  style={inputStyle} placeholder="0"/>
              </div>
              <div style={{gridColumn:"1/-1",background:C.blueDim,borderRadius:8,padding:"8px 12px",fontSize:11,color:C.blue}}>
                💡 SKU unidad: <strong>{(form.sku||"PROD")+"-UNIT"}</strong> ·
                Sugerido: <strong>${upcVenta ? minPrecioPieza : "-"}</strong>/unidad (puedes poner menos)
                {margenPiezaPct != null && margenCajaPct != null ? (
                  <> · margen pieza <strong style={{ color: margenPiezaColor }}>{margenPiezaPct}%</strong> vs caja {margenCajaPct}%</>
                ) : null}
              </div>
            </div>
          )}
        </div>

        <div style={{display:"flex",justifyContent:"flex-end",gap:10,marginTop:8}}>
          <button style={btnSecondary} onClick={onClose}>Cancelar</button>
          <button style={btnPrimary} onClick={handleSave} disabled={saving}>{saving?"Guardando…":"💾 Guardar"}</button>
        </div>
      </div>
    </div>
  );
}

function RecibirModal({ productos, onClose, onReceived, initialProductId = null }) {
  const C = C_LIGHT;
  const inputStyle = mkInputStyle(C);
  const labelStyle = mkLabelStyle(C);
  const btnSecondary = mkBtnSecondary(C);
  const btnGreen = mkBtnGreen(C);
  const [busq,     setBusq]    = useState("");
  const [selId,    setSelId]   = useState(initialProductId ? String(initialProductId) : "");
  const [cantidad, setCantidad]= useState("");
  const [lote,     setLote]    = useState("");
  const [caducidad,setCaduc]   = useState("");
  const [costo,    setCosto]   = useState("");
  const [proveedor,setProv]    = useState("");
  const [saving,   setSaving]  = useState(false);
  const [error,    setError]   = useState("");
  const busqRef = useRef(null);
  const cantidadRef = useRef(null);
  const caducidadRef = useRef(null);

  useEffect(() => {
    if (initialProductId) {
      setSelId(String(initialProductId));
      cantidadRef.current?.focus();
    } else {
      busqRef.current?.focus();
    }
  }, [initialProductId]);

  const prodsFilt = useMemo(
    () =>
      productos
        .filter((p) => p.activo && inventarioProductMatchesBusqueda(p, busq))
        .sort((a, b) => inventarioSearchRelevanceRank(a, busq) - inventarioSearchRelevanceRank(b, busq)),
    [productos, busq]
  );
  const selProd = productos.find((p) => p.id === parseInt(selId, 10));

  const resetScanForm = () => {
    setSelId("");
    setBusq("");
    setCantidad("");
    setLote("");
    setCaduc("");
    setError("");
    setTimeout(() => busqRef.current?.focus(), 40);
  };

  const selectProduct = (p) => {
    if (!p) return;
    setSelId(String(p.id));
    setBusq(p.nombre);
    setError("");
    if (p.costo != null && p.costo !== "" && !costo) setCosto(String(p.costo));
    setTimeout(() => cantidadRef.current?.focus(), 40);
  };

  const trySelectFromScan = (raw) => {
    const trimmed = raw.trim();
    if (!trimmed) return false;
    const exact = findProductExactScan(productos, trimmed);
    if (exact) {
      selectProduct(exact);
      return true;
    }
    if (prodsFilt.length === 1) {
      selectProduct(prodsFilt[0]);
      return true;
    }
    return false;
  };

  const handleRecibir = async () => {
    if (!selId) { setError("Escanea o selecciona un producto"); return; }
    if (!cantidad || parseInt(cantidad, 10) <= 0) { setError("Cantidad inválida"); return; }
    setSaving(true);
    setError("");
    const tok = sessionStorage.getItem("farmacapital_session_token");
    if (!tok) { setSaving(false); setError("Sesión expirada."); return; }
    const { error: err } = await supabase.rpc("receive_merchandise_secure", {
      p_session_token: tok,
      p_producto_id: selProd.id,
      p_cantidad: parseInt(cantidad, 10),
      p_numero_lote: lote.trim() || null,
      p_fecha_caducidad: caducidad || null,
      p_costo_unitario: costo ? parseFloat(costo) : null,
      p_proveedor: proveedor.trim() || null,
    });
    setSaving(false);
    if (err) { setError("Error: " + err.message); return; }
    showToast(`✅ +${cantidad} · ${selProd.nombre}`, "success");
    resetScanForm();
    onReceived?.();
  };

  return (
    <div style={{position:"fixed",inset:0,background:"#00000099",zIndex:1000,display:"flex",alignItems:"center",justifyContent:"center"}}>
      <div style={{background:C.card,border:`1px solid ${C.borderHi}`,borderRadius:14,width:"min(520px,95vw)",maxHeight:"90vh",overflowY:"auto",padding:28,boxShadow:"0 24px 60px #00000088"}}>
        <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:12}}>
          <div>
            <h2 style={{margin:0,color:C.text,fontSize:16,fontWeight:800}}>📦 Resurtir / Recibir</h2>
            <div style={{color:C.textMid,fontSize:11,marginTop:4}}>Escanea código de barras → cantidad → caducidad → Enter</div>
          </div>
          <button type="button" onClick={onClose} aria-label="Cerrar" style={{background:"none",border:"none",color:C.textMid,fontSize:20,cursor:"pointer"}}>✕</button>
        </div>
        <div style={{background:"#eff6ff",border:"1px solid #bfdbfe",borderRadius:8,padding:"8px 12px",marginBottom:14,fontSize:11,color:"#1e40af",lineHeight:1.5}}>
          La pistola USB escribe aquí como teclado. Si el producto no existe, regístralo en <strong>Nuevo producto</strong> con su código de barras.
        </div>
        <div style={{marginBottom:12}}>
          <label style={labelStyle}>Escanear o buscar producto <span style={{color:C.red}}>*</span></label>
          <input
            ref={busqRef}
            value={busq}
            onChange={(e) => { setBusq(e.target.value); setSelId(""); setError(""); }}
            onKeyDown={(e) => {
              if (e.key !== "Enter") return;
              e.preventDefault();
              if (trySelectFromScan(busq)) return;
              if (prodsFilt.length > 1) {
                setError("Varios resultados — elige uno de la lista o escanea el código exacto de la caja.");
                return;
              }
              setError("Producto no encontrado. Agrégalo al catálogo con su código de barras.");
            }}
            placeholder="🔫 Código de barras, SKU o nombre…"
            style={{...inputStyle, fontSize:16}}
          />
        </div>
        {busq && !selProd && prodsFilt.length > 0 && (
          <div style={{background:C.bg,border:`1px solid ${C.border}`,borderRadius:8,marginBottom:12,maxHeight:160,overflowY:"auto"}}>
            {prodsFilt.slice(0, 8).map((p) => (
              <div
                key={p.id}
                role="button"
                tabIndex={0}
                onClick={() => selectProduct(p)}
                onKeyDown={(e) => { if (e.key === "Enter") selectProduct(p); }}
                style={{padding:"8px 12px",cursor:"pointer",color:C.text,fontSize:12,borderBottom:`1px solid ${C.border}`}}
                onMouseEnter={(e) => { e.currentTarget.style.background = C.blueDim; }}
                onMouseLeave={(e) => { e.currentTarget.style.background = "transparent"; }}
              >
                <strong>{p.nombre}</strong>
                {p.codigo_barras ? (
                  <span style={{color:C.textMid,marginLeft:8,fontFamily:"monospace",fontSize:10}}>{p.codigo_barras}</span>
                ) : null}
                <span style={{color:C.textMid,marginLeft:8}}>Stock: <strong style={{color:C.amber}}>{p.stock}</strong></span>
              </div>
            ))}
          </div>
        )}
        {selProd && (
          <div style={{background:C.blueDim,border:`1px solid ${C.blue}30`,borderRadius:8,padding:"10px 14px",marginBottom:16}}>
            <div style={{color:C.blue,fontWeight:700,fontSize:13}}>{selProd.nombre}</div>
            <div style={{color:C.textMid,fontSize:11,marginTop:4}}>
              {selProd.codigo_barras ? <>Cód. barras: <strong style={{fontFamily:"monospace"}}>{selProd.codigo_barras}</strong> · </> : null}
              Stock actual: <strong style={{color:C.amber}}>{selProd.stock}</strong>
              {selProd.stock_minimo ? ` · Mínimo: ${selProd.stock_minimo}` : ""}
              {selProd.min_caducidad_lotes ? ` · Próx. caduca: ${selProd.min_caducidad_lotes}` : ""}
            </div>
          </div>
        )}
        <div style={{display:"grid",gridTemplateColumns:"1fr 1fr",gap:"0 16px"}}>
          <div>
            <div style={{marginBottom:12}}>
              <label style={labelStyle}>Cantidad a recibir <span style={{color:C.red}}>*</span></label>
              <input
                ref={cantidadRef}
                type="number"
                value={cantidad}
                onChange={(e) => setCantidad(e.target.value)}
                onKeyDown={(e) => {
                  if (e.key === "Enter") {
                    e.preventDefault();
                    caducidadRef.current?.focus();
                  }
                }}
                min="1"
                placeholder="0"
                style={{...inputStyle, fontSize:16}}
              />
            </div>
            <div style={{marginBottom:12}}>
              <label style={labelStyle}>Nuevo lote</label>
              <input value={lote} onChange={(e) => setLote(e.target.value)} placeholder="Ej. L-20250101 (opcional)" style={inputStyle}/>
            </div>
            <div style={{marginBottom:12}}>
              <label style={labelStyle}>Fecha de caducidad</label>
              <input
                ref={caducidadRef}
                type="date"
                value={caducidad}
                onChange={(e) => setCaduc(e.target.value)}
                onKeyDown={(e) => {
                  if (e.key === "Enter" && selId && cantidad) {
                    e.preventDefault();
                    handleRecibir();
                  }
                }}
                style={inputStyle}
              />
            </div>
          </div>
          <div>
            <div style={{marginBottom:12}}>
              <label style={labelStyle}>Nuevo costo unitario</label>
              <input
                type="number"
                value={costo}
                onChange={(e) => setCosto(e.target.value)}
                placeholder={selProd ? `Actual: $${selProd.costo}` : "$0.00"}
                style={inputStyle}
              />
            </div>
            <div style={{marginBottom:12}}>
              <label style={labelStyle}>Proveedor</label>
              <input value={proveedor} onChange={(e) => setProv(e.target.value)} placeholder="Nadro, Marzam…" style={inputStyle}/>
            </div>
            {selProd && cantidad && parseInt(cantidad, 10) > 0 && (
              <div style={{background:C.greenDim,border:`1px solid ${C.green}30`,borderRadius:8,padding:"10px 14px",marginTop:4}}>
                <div style={{color:C.textMid,fontSize:10,fontWeight:700}}>NUEVO STOCK</div>
                <div style={{color:C.green,fontWeight:800,fontSize:22}}>{(selProd.stock || 0) + parseInt(cantidad, 10)}</div>
                <div style={{color:C.textMid,fontSize:10}}>({selProd.stock} + {cantidad})</div>
              </div>
            )}
          </div>
        </div>
        {error && <div style={{color:C.red,fontSize:12,marginBottom:8}}>{error}</div>}
        <div style={{display:"flex",justifyContent:"flex-end",gap:10,marginTop:12}}>
          <button type="button" style={btnSecondary} onClick={onClose}>Cerrar</button>
          <button type="button" style={btnGreen} onClick={handleRecibir} disabled={saving || !selId || !cantidad}>
            {saving ? "Guardando…" : "📦 Registrar entrada"}
          </button>
        </div>
      </div>
    </div>
  );
}

function BulkImagesModal({ open, onClose, productos, onComplete }) {
  const C = C_LIGHT;
  const [files, setFiles] = useState([]);
  const [results, setResults] = useState([]);
  const [uploading, setUploading] = useState(false);
  const [progress, setProgress] = useState({ current: 0, total: 0 });

  if (!open) return null;

  const normToken = (s) =>
    String(s || "")
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "")
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-+|-+$/g, "")
      .trim();

  const handleFiles = (e) => {
    const selected = Array.from(e.target.files || []);
    setFiles(selected);
    setResults([]);
  };

  const procesarTodas = async () => {
    if (!files.length) return;
    const tok = sessionStorage.getItem("farmacapital_session_token");
    if (!tok) {
      showToast("Sesión expirada.", "error");
      return;
    }
    setUploading(true);
    setProgress({ current: 0, total: files.length });
    const res = [];
    const bySku = new Map();
    const byNombre = new Map();
    for (const p of productos || []) {
      const skuKey = normToken(p?.sku);
      if (skuKey && !bySku.has(skuKey)) bySku.set(skuKey, p);
      const nombreKey = normToken(p?.nombre);
      if (!nombreKey) continue;
      const arr = byNombre.get(nombreKey) || [];
      arr.push(p);
      byNombre.set(nombreKey, arr);
    }

    for (let i = 0; i < files.length; i++) {
      const file = files[i];
      setProgress({ current: i + 1, total: files.length });

      const nombreArchivo = file.name.replace(/\.[^/.]+$/, "");
      const token = normToken(nombreArchivo);
      let producto = bySku.get(token) || null;
      let ambiguous = false;
      let matchBy = producto ? "sku" : "";

      if (!producto) {
        const exactByName = byNombre.get(token) || [];
        if (exactByName.length === 1) {
          producto = exactByName[0];
          matchBy = "nombre";
        } else if (exactByName.length > 1) {
          ambiguous = true;
        }
      }

      if (!producto && !ambiguous) {
        const candidates = (productos || []).filter((p) => {
          const skuKey = normToken(p?.sku);
          const nombreKey = normToken(p?.nombre);
          return (skuKey && token.includes(skuKey)) || (nombreKey && token.includes(nombreKey));
        });
        if (candidates.length === 1) {
          producto = candidates[0];
          matchBy = "aprox";
        } else if (candidates.length > 1) {
          ambiguous = true;
        }
      }

      if (!producto) {
        res.push({
          archivo: file.name,
          status: "no_match",
          mensaje: ambiguous
            ? "Coincidencia ambigua (varios productos). Renombra con SKU exacto."
            : "Sin coincidencia por SKU o nombre",
        });
        setResults([...res]);
        continue;
      }

      try {
        const ext = (file.name.split(".").pop() || "jpg").toLowerCase();
        const safeSku = String(producto.sku).toLowerCase().replace(/[^a-z0-9-]/g, "-");
        const fileName = `${safeSku}-${Date.now()}-${i}.${ext}`;

        const { error: upErr } = await supabase.storage
          .from("productos")
          .upload(fileName, file, { upsert: false, cacheControl: "3600" });

        if (upErr) throw upErr;

        const { data: pub } = supabase.storage.from("productos").getPublicUrl(fileName);
        const publicUrl = pub.publicUrl;

        const { error: updErr } = await supabase.rpc("admin_editar_producto", {
          p_session_token: tok,
          p_producto_id: producto.id,
          p_patch: { imagen_url: publicUrl, imagen_mobile_url: publicUrl },
        });

        if (updErr) throw updErr;

        res.push({
          archivo: file.name,
          status: "ok",
          producto: producto.nombre,
          sku: producto.sku,
          matchBy,
        });
      } catch (e) {
        res.push({
          archivo: file.name,
          status: "error",
          mensaje: e.message || String(e),
        });
      }
      setResults([...res]);
    }

    setUploading(false);
    onComplete?.();
  };

  const exitosas = results.filter((r) => r.status === "ok").length;
  const sinMatch = results.filter((r) => r.status === "no_match").length;
  const errores = results.filter((r) => r.status === "error").length;

  return (
    <div
      style={{
        position: "fixed",
        inset: 0,
        background: "rgba(15,23,42,.5)",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        zIndex: 1100,
        padding: 20,
      }}
    >
      <div
        style={{
          background: C.card,
          borderRadius: 14,
          width: "min(700px, 95vw)",
          maxHeight: "90vh",
          overflowY: "auto",
          padding: 28,
          boxSizing: "border-box",
        }}
      >
        <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 20 }}>
          <h3 style={{ margin: 0, color: C.text, fontSize: 18, fontWeight: 800 }}>🖼️ Carga masiva de fotos</h3>
          <button
            type="button"
            onClick={onClose}
            disabled={uploading}
            style={{ background: "none", border: "none", fontSize: 22, cursor: "pointer", color: C.textMid }}
          >
            ✕
          </button>
        </div>

        <div
          style={{
            background: C.blueDim,
            border: `1px solid ${C.blue}30`,
            borderRadius: 10,
            padding: "12px 16px",
            marginBottom: 16,
            fontSize: 12,
            color: C.blue,
            lineHeight: 1.6,
          }}
        >
          📋 <strong>Cómo funciona:</strong>
          <br />
          1. Mejor práctica: nombra cada archivo con el SKU (ej: <code>par-500.jpg</code>, <code>ome-20.png</code>)
          <br />
          2. Selecciona todas las imágenes a la vez
          <br />
          3. También intenta por nombre del producto si no encuentra SKU (sin mayúsculas/acentos)
          <br />
          4. Si hay varias coincidencias, te pedirá renombrar con SKU exacto
          <br />
          5. Se usa Storage <code>productos</code> y RPC <code>admin_editar_producto</code>
        </div>

        <input
          type="file"
          multiple
          accept="image/jpeg,image/png,image/webp"
          onChange={handleFiles}
          disabled={uploading}
          style={{
            width: "100%",
            padding: 16,
            border: `2px dashed ${C.border}`,
            borderRadius: 10,
            background: C.bg,
            cursor: "pointer",
            marginBottom: 16,
            boxSizing: "border-box",
          }}
        />

        {files.length > 0 && !uploading && results.length === 0 && (
          <div style={{ marginBottom: 16 }}>
            <div style={{ color: C.text, fontWeight: 700, marginBottom: 8 }}>📁 {files.length} archivo(s) seleccionado(s)</div>
            <button
              type="button"
              onClick={procesarTodas}
              style={{
                width: "100%",
                padding: 14,
                borderRadius: 10,
                border: "none",
                background: BRAND.primary,
                color: "#fff",
                fontWeight: 700,
                fontSize: 14,
                cursor: "pointer",
              }}
            >
              🚀 Procesar todas las fotos
            </button>
          </div>
        )}

        {uploading && (
          <div style={{ marginBottom: 16 }}>
            <div style={{ color: C.text, marginBottom: 8 }}>
              Procesando {progress.current} de {progress.total}...
            </div>
            <div style={{ background: C.border, borderRadius: 6, height: 12, overflow: "hidden" }}>
              <div
                style={{
                  width: `${progress.total ? (progress.current / progress.total) * 100 : 0}%`,
                  height: "100%",
                  background: BRAND.primary,
                  transition: "width 0.3s",
                }}
              />
            </div>
          </div>
        )}

        {results.length > 0 && (
          <div>
            <div
              style={{
                display: "grid",
                gridTemplateColumns: "repeat(3, 1fr)",
                gap: 8,
                marginBottom: 16,
              }}
            >
              <div style={{ background: C.greenDim, padding: "10px 12px", borderRadius: 8, textAlign: "center" }}>
                <div style={{ color: C.green, fontSize: 22, fontWeight: 800 }}>{exitosas}</div>
                <div style={{ color: C.green, fontSize: 11 }}>✅ Subidas OK</div>
              </div>
              <div style={{ background: C.amberDim, padding: "10px 12px", borderRadius: 8, textAlign: "center" }}>
                <div style={{ color: C.amber, fontSize: 22, fontWeight: 800 }}>{sinMatch}</div>
                <div style={{ color: C.amber, fontSize: 11 }}>⚠️ Sin SKU</div>
              </div>
              <div style={{ background: C.redDim, padding: "10px 12px", borderRadius: 8, textAlign: "center" }}>
                <div style={{ color: C.red, fontSize: 22, fontWeight: 800 }}>{errores}</div>
                <div style={{ color: C.red, fontSize: 11 }}>❌ Errores</div>
              </div>
            </div>

            <div style={{ maxHeight: 300, overflowY: "auto", border: `1px solid ${C.border}`, borderRadius: 8 }}>
              {results.map((r, i) => (
                <div
                  key={`${r.archivo}-${i}`}
                  style={{
                    padding: "8px 12px",
                    borderBottom: i < results.length - 1 ? `1px solid ${C.border}` : "none",
                    display: "flex",
                    alignItems: "center",
                    gap: 10,
                    fontSize: 12,
                  }}
                >
                  <span style={{ fontSize: 16 }}>{r.status === "ok" ? "✅" : r.status === "no_match" ? "⚠️" : "❌"}</span>
                  <div style={{ flex: 1 }}>
                    <div style={{ color: C.text, fontWeight: 600 }}>{r.archivo}</div>
                    {r.producto && (
                      <div style={{ color: C.green, fontSize: 11 }}>
                        → {r.producto} ({r.sku})
                      </div>
                    )}
                    {r.mensaje && (
                      <div style={{ color: r.status === "no_match" ? C.amber : C.red, fontSize: 11 }}>{r.mensaje}</div>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {!uploading && (
          <button
            type="button"
            onClick={onClose}
            style={{
              marginTop: 16,
              width: "100%",
              padding: 12,
              borderRadius: 8,
              border: `1px solid ${C.border}`,
              background: "transparent",
              color: C.textMid,
              fontWeight: 600,
              cursor: "pointer",
            }}
          >
            Cerrar
          </button>
        )}
      </div>
    </div>
  );
}

/** Modal: aplicar los mismos campos a varios productos vía admin_editar_producto */
function BulkEditProductosModal({ count, onClose, onApplied }) {
  const C = C_LIGHT;
  const inputStyle = mkInputStyle(C);
  const labelStyle = mkLabelStyle(C);
  const btnPrimary = mkBtnPrimary(C);
  const btnSecondary = mkBtnSecondary(C);
  const [categoria, setCategoria] = useState("");
  const [tipo, setTipo] = useState("");
  const [descuento, setDescuento] = useState("");
  const [stockMin, setStockMin] = useState("");
  const [activo, setActivo] = useState("");
  const [busy, setBusy] = useState(false);

  const aplicar = async () => {
    const patch = {};
    if (categoria) patch.categoria = categoria;
    if (tipo) patch.tipo = tipo;
    if (descuento.trim() !== "") {
      const d = parseFloat(descuento);
      if (Number.isNaN(d) || d < 0 || d > 100) {
        showToast("Descuento debe ser un % entre 0 y 100.", "error");
        return;
      }
      patch.descuento_pct = d;
    }
    if (stockMin.trim() !== "") {
      const s = parseInt(stockMin, 10);
      if (Number.isNaN(s) || s < 0) {
        showToast("Stock mínimo inválido.", "error");
        return;
      }
      patch.stock_minimo = s;
    }
    if (activo === "si") patch.activo = true;
    if (activo === "no") patch.activo = false;

    if (Object.keys(patch).length === 0) {
      showToast("Elegí al menos un campo para actualizar.", "warning");
      return;
    }
    setBusy(true);
    try {
      await onApplied(patch);
    } finally {
      setBusy(false);
    }
  };

  return (
    <div
      style={{
        position: "fixed",
        inset: 0,
        background: "rgba(15,23,42,.45)",
        backdropFilter: "blur(4px)",
        zIndex: 1000,
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        padding: 20,
      }}
      onClick={(e) => e.target === e.currentTarget && !busy && onClose()}
    >
      <div
        style={{
          background: C.card,
          borderRadius: 14,
          width: "min(480px, 95vw)",
          maxHeight: "90vh",
          overflowY: "auto",
          padding: 24,
          boxShadow: "0 20px 60px rgba(15,45,110,.15)",
        }}
      >
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 16 }}>
          <h3 style={{ margin: 0, color: C.text, fontSize: 16, fontWeight: 800 }}>✏️ Edición en lote</h3>
          <button type="button" disabled={busy} onClick={onClose} style={{ background: "none", border: "none", color: C.textMid, fontSize: 20, cursor: busy ? "default" : "pointer" }}>
            ✕
          </button>
        </div>
        <p style={{ margin: "0 0 16px", color: C.textMid, fontSize: 12, lineHeight: 1.5 }}>
          Se aplicará a <strong style={{ color: C.text }}>{count}</strong> producto(s). Solo completa los campos que quieras cambiar; el resto se mantiene igual en cada producto.
        </p>
        <div style={{ display: "grid", gap: 12 }}>
          <div>
            <label style={labelStyle}>Categoría</label>
            <select value={categoria} onChange={(e) => setCategoria(e.target.value)} style={inputStyle}>
              <option value="">— Sin cambiar —</option>
              {CATEGORIAS.map((c) => (
                <option key={c} value={c}>
                  {c}
                </option>
              ))}
            </select>
          </div>
          <div>
            <label style={labelStyle}>Tipo</label>
            <select value={tipo} onChange={(e) => setTipo(e.target.value)} style={inputStyle}>
              <option value="">— Sin cambiar —</option>
              <option value="generico">Genérico</option>
              <option value="marca">Marca</option>
            </select>
          </div>
          <div>
            <label style={labelStyle}>Descuento % (sobre precio de lista)</label>
            <input value={descuento} onChange={(e) => setDescuento(e.target.value)} placeholder="Ej. 15 (vacío = no cambiar)" style={inputStyle} inputMode="decimal" />
          </div>
          <div>
            <label style={labelStyle}>Stock mínimo</label>
            <input value={stockMin} onChange={(e) => setStockMin(e.target.value)} placeholder="Vacío = no cambiar" style={inputStyle} inputMode="numeric" />
          </div>
          <div>
            <label style={labelStyle}>Estado en catálogo</label>
            <select value={activo} onChange={(e) => setActivo(e.target.value)} style={inputStyle}>
              <option value="">— Sin cambiar —</option>
              <option value="si">Activar</option>
              <option value="no">Desactivar (ocultar)</option>
            </select>
          </div>
        </div>
        <div style={{ display: "flex", gap: 10, marginTop: 20, flexWrap: "wrap" }}>
          <button type="button" disabled={busy} onClick={onClose} style={{ ...btnSecondary, flex: 1, minWidth: 120 }}>
            Cancelar
          </button>
          <button type="button" disabled={busy} onClick={aplicar} style={{ ...btnPrimary, flex: 1, minWidth: 120, opacity: busy ? 0.7 : 1 }}>
            {busy ? "Aplicando…" : `Aplicar a ${count}`}
          </button>
        </div>
      </div>
    </div>
  );
}

function renderInventarioColumnCell(colId, ctx) {
  const {
    C,
    BRAND: BR,
    CATEGORIAS: cats,
    p,
    stickyRowBg,
    inlineCellProps,
    invColWidthStyle,
    inventarioStickyStyleFor,
    abrirEdicionProducto,
    setModalLotes,
    liquidar,
    desactivar,
    reactivar,
    eliminarUno,
    btnSecondary,
    bajo,
    inact,
    mgn,
    mgnCol,
    marcaDisp,
    nombreTabla,
    presDisp,
    presInferida,
    provDisp,
    principioLine,
    dosisLine,
    cbDisp,
    sinCb,
    proxCad,
    dias,
    nearCad,
  } = ctx;

  const sticky = (extra = {}) => inventarioStickyStyleFor(colId, { header: false, bg: stickyRowBg, ...extra });
  const w = (id) => invColWidthStyle(id);
  const {
    inlineEdit,
    inlineSaving,
    selectionMode,
    inputStyle,
    onStart,
    onDraft,
    onCommit,
    onCancel,
    onQuitarCad,
  } = inlineCellProps;

  switch (colId) {
    case "foto":
      return (
        <td
          key={colId}
          style={{
            padding: INV_COMPACT_CELL_PAD,
            borderBottom: `1px solid ${C.border}`,
            verticalAlign: "middle",
            cursor: "pointer",
            ...sticky(),
          }}
          title="Clic para editar foto y más campos"
          onClick={() => abrirEdicionProducto(p)}
        >
          <div
            style={{
              width: 28,
              height: 28,
              borderRadius: 4,
              background: p.imagen_url ? `url(${p.imagen_url}) center/cover` : C.bg,
              border: `1px solid ${C.border}`,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              fontSize: 12,
            }}
          >
            {!p.imagen_url ? "📷" : null}
          </div>
        </td>
      );
    case "acciones":
      return (
        <td
          key={colId}
          style={{
            padding: INV_COMPACT_CELL_PAD,
            borderBottom: `1px solid ${C.border}`,
            whiteSpace: "nowrap",
            verticalAlign: "middle",
            background: stickyRowBg,
            ...sticky(),
            ...w("acciones"),
          }}
        >
          <div style={{ display: "flex", alignItems: "center", gap: 1, flexWrap: "nowrap" }}>
          <button
            type="button"
            onClick={() => abrirEdicionProducto(p)}
            style={{
              ...INV_ICON_BTN,
              background: C.blueDim,
              border: `1px solid ${C.blue}30`,
              color: C.blue,
            }}
            title="Editar"
          >
            ✏️
          </button>
          <button
            type="button"
            onClick={() => setModalLotes(p)}
            style={{
              ...INV_ICON_BTN,
              background: "#f1f5f9",
              border: `1px solid ${C.border}`,
              color: C.textMid,
              fontSize: 10,
            }}
            title="Lotes"
          >
            📦{(p.lotes_activos || []).length}
          </button>
          {p.min_caducidad_lotes && esPorCaducar(diasParaCaducar(p.min_caducidad_lotes)) && (
            <button
              type="button"
              onClick={() => liquidar(p)}
              style={{ ...INV_ICON_BTN, ...btnSecondary, color: C.red, borderColor: C.red, background: C.redDim }}
              title="Liquidar"
            >
              🏷️
            </button>
          )}
          {p.activo ? (
            <>
              <button
                type="button"
                onClick={() => desactivar(p.id)}
                title="Desactivar (ocultar)"
                style={{ ...INV_ICON_BTN, background: C.redDim, border: `1px solid ${C.red}30`, color: C.red }}
              >
                🔴
              </button>
              <button
                type="button"
                onClick={() => eliminarUno(p)}
                title="Eliminar del catálogo"
                style={{ ...INV_ICON_BTN, background: C.redDim, border: `1px solid ${C.red}50`, color: C.red }}
              >
                🗑️
              </button>
            </>
          ) : (
            <button
              type="button"
              onClick={() => reactivar(p.id)}
              style={{ ...INV_ICON_BTN, background: C.greenDim, border: `1px solid ${C.green}30`, color: C.green }}
              title="Reactivar"
            >
              ✅
            </button>
          )}
          </div>
        </td>
      );
    case "skuFarmaCapital":
      return (
        <InventarioEditableCell
          key={colId}
          {...inlineCellProps}
          productId={p.id}
          field="sku"
          value={p.sku || ""}
          mono
          display={<span style={tdEllipsisStyle}>{p.sku || "—"}</span>}
          tdStyle={{
            padding: "6px 8px 6px 6px",
            color: C.textMid,
            borderBottom: `1px solid ${C.border}`,
            fontFamily: "ui-monospace,Menlo,monospace",
            fontSize: 11,
            textAlign: "left",
            verticalAlign: "middle",
            background: stickyRowBg,
            ...sticky(),
            ...w("skuFarmaCapital"),
          }}
        />
      );
    case "codigoBarras":
      return (
        <InventarioEditableCell
          key={colId}
          {...inlineCellProps}
          productId={p.id}
          field="codigo_barras"
          value={p.codigo_barras || ""}
          mono
          display={
            sinCb ? (
              <span style={{ color: C.blue, fontWeight: 700, fontSize: 10 }}>+ Agregar código</span>
            ) : (
              <span style={{ fontFamily: "ui-monospace,Menlo,monospace", fontSize: 11, color: C.textMid, ...tdEllipsisStyle }} title={cbDisp}>
                {cbDisp}
              </span>
            )
          }
          tdStyle={{ padding: "8px 12px", borderBottom: `1px solid ${C.border}`, verticalAlign: "middle", background: stickyRowBg, ...w("codigoBarras") }}
          readOnly={false}
        />
      );
    case "nombre":
      return (
        <InventarioEditableCell
          key={colId}
          {...inlineCellProps}
          productId={p.id}
          field="nombre"
          value={p.nombre || ""}
          display={
            <span
              style={{ ...tdEllipsisStyle, whiteSpace: "normal", display: "-webkit-box", WebkitLineClamp: 2, WebkitBoxOrient: "vertical", overflow: "hidden", fontWeight: 600, color: inact ? C.textDim : C.text }}
              title={nombreTabla}
            >
              {nombreTabla}
            </span>
          }
          tdStyle={{ padding: "8px 12px", borderBottom: `1px solid ${C.border}`, verticalAlign: "middle", background: stickyRowBg, ...sticky(), ...w("nombre") }}
        />
      );
    case "marca":
      return (
        <InventarioEditableCell
          key={colId}
          {...inlineCellProps}
          productId={p.id}
          field="marca"
          value={p.marca || ""}
          display={<span style={tdEllipsisStyle}>{marcaDisp || "—"}</span>}
          tdStyle={{ padding: "8px 12px", color: C.textMid, borderBottom: `1px solid ${C.border}`, background: stickyRowBg, ...w("marca") }}
        />
      );
    case "presentacion":
      return (
        <InventarioEditableCell
          key={colId}
          {...inlineCellProps}
          productId={p.id}
          field="presentacion"
          value={p.presentacion || presInferida || ""}
          display={<span style={tdEllipsisStyle}>{presDisp}</span>}
          tdStyle={{ padding: "8px 12px", color: C.textMid, borderBottom: `1px solid ${C.border}`, background: stickyRowBg, ...w("presentacion") }}
        />
      );
    case "principio":
      return (
        <InventarioEditableCell
          key={colId}
          {...inlineCellProps}
          productId={p.id}
          field="principio"
          value={p.principio_activo || lineaPrincipioQuimicoTabla(p) || ""}
          display={
            <>
              <span style={{ ...tdEllipsisStyle, display: "block" }}>{principioLine || "—"}</span>
              {dosisLine ? <span style={{ display: "block", fontSize: 10, color: C.textDim, marginTop: 2 }}>{dosisLine}</span> : null}
            </>
          }
          tdStyle={{ padding: "8px 12px", color: C.textMid, borderBottom: `1px solid ${C.border}`, background: stickyRowBg, ...w("principio") }}
        />
      );
    case "ubicacion":
      return (
        <InventarioEditableCell
          key={colId}
          {...inlineCellProps}
          productId={p.id}
          field="ubicacion"
          value={p.ubicacion_texto || ""}
          display={<span style={{ fontSize: 11, fontWeight: 700, color: p.ubicacion_texto ? C.blue : C.textDim }}>{p.ubicacion_texto || "Sin ubicación"}</span>}
          tdStyle={{ padding: "8px 12px", color: C.text, borderBottom: `1px solid ${C.border}`, background: stickyRowBg, ...w("ubicacion") }}
        />
      );
    case "categoria":
      return (
        <InventarioEditableCell
          key={colId}
          {...inlineCellProps}
          productId={p.id}
          field="categoria"
          value={p.categoria || "Otro"}
          type="select"
          options={cats}
          display={p.categoria}
          tdStyle={{ padding: "8px 12px", color: C.textMid, borderBottom: `1px solid ${C.border}`, background: stickyRowBg, ...w("categoria") }}
        />
      );
    case "tipo":
      return (
        <InventarioEditableCell
          key={colId}
          {...inlineCellProps}
          productId={p.id}
          field="tipo"
          value={p.tipo || "generico"}
          type="select"
          options={["generico", "marca"]}
          display={
            <span style={{ padding: "2px 8px", borderRadius: 20, fontSize: 10, fontWeight: 700, background: p.tipo === "marca" ? "#9d6fff18" : C.blueDim, color: p.tipo === "marca" ? "#9d6fff" : C.blue }}>
              {p.tipo}
            </span>
          }
          tdStyle={{ padding: "8px 12px", borderBottom: `1px solid ${C.border}`, background: stickyRowBg }}
        />
      );
    case "proveedor":
      return (
        <InventarioEditableCell
          key={colId}
          {...inlineCellProps}
          productId={p.id}
          field="proveedor"
          value={p.proveedor || ""}
          display={<span style={tdEllipsisStyle}>{provDisp || "—"}</span>}
          tdStyle={{ padding: "8px 12px", color: C.textMid, borderBottom: `1px solid ${C.border}`, background: stickyRowBg, ...w("proveedor") }}
        />
      );
    case "stock":
      return (
        <InventarioEditableCell
          key={colId}
          {...inlineCellProps}
          productId={p.id}
          field="stock"
          value={String(p.stock ?? 0)}
          type="number"
          display={<span style={{ fontWeight: 700, color: bajo ? C.amber : C.green }}>{p.stock}</span>}
          tdStyle={{ padding: "8px 12px", borderBottom: `1px solid ${C.border}`, background: stickyRowBg }}
        />
      );
    case "min":
      return (
        <InventarioEditableCell
          key={colId}
          {...inlineCellProps}
          productId={p.id}
          field="min"
          value={String(p.stock_minimo ?? 0)}
          type="number"
          display={p.stock_minimo ?? 0}
          tdStyle={{ padding: "8px 12px", color: C.textMid, borderBottom: `1px solid ${C.border}`, background: stickyRowBg }}
        />
      );
    case "precio":
      return (
        <InventarioEditableCell
          key={colId}
          {...inlineCellProps}
          productId={p.id}
          field="precio"
          value={String(parseFloat(p.precio || 0))}
          type="number"
          display={
            productoSinPrecioVenta(p) ? (
              <span style={{ color: C.red, fontWeight: 700, fontSize: 10 }}>No vendible</span>
            ) : p.venta_unidad && parseFloat(p.precio_unidad) > 0 ? (
              <span>
                ${parseFloat(p.precio || 0).toFixed(2)}
                <span style={{ color: C.textMid, fontSize: 10, marginLeft: 6 }}>pza ${parseFloat(p.precio_unidad).toFixed(0)}</span>
              </span>
            ) : (
              `$${parseFloat(p.precio || 0).toFixed(2)}`
            )
          }
          tdStyle={{ padding: "8px 12px", color: C.text, borderBottom: `1px solid ${C.border}`, background: stickyRowBg }}
        />
      );
    case "costo":
      return (
        <InventarioEditableCell
          key={colId}
          {...inlineCellProps}
          productId={p.id}
          field="costo"
          value={String(parseFloat(p.costo || 0))}
          type="number"
          display={`$${parseFloat(p.costo || 0).toFixed(2)}`}
          tdStyle={{ padding: "8px 12px", color: C.textMid, borderBottom: `1px solid ${C.border}`, background: stickyRowBg }}
        />
      );
    case "margen":
      return <td key={colId} style={{ padding: "8px 12px", fontWeight: 700, borderBottom: `1px solid ${C.border}`, color: mgnCol, background: stickyRowBg }}>{mgn}</td>;
    case "cad": {
      const loteRef = resolverLoteCaducidadProducto(p);
      const puedeCad = true;
      const isEditingCad = inlineEdit?.productId === p.id && inlineEdit?.field === "cad";
      const tdCad = {
        padding: "8px 12px",
        borderBottom: `1px solid ${C.border}`,
        whiteSpace: "nowrap",
        background: stickyRowBg,
        ...w("cad"),
      };
      if (isEditingCad) {
        const cadMeta = inlineEdit.meta || {};
        const puedeQuitar = Boolean(inlineEdit.draft || loteRef?.fecha_caducidad);
        return (
          <td style={tdCad}>
            <div style={{ display: "flex", gap: 4, alignItems: "center", flexWrap: "nowrap" }}>
              <input
                type="date"
                autoFocus
                disabled={inlineSaving}
                value={inlineEdit.draft}
                onChange={(e) => onDraft(e.target.value)}
                onKeyDown={(e) => {
                  if (e.key === "Enter") {
                    e.preventDefault();
                    onCommit();
                  }
                  if (e.key === "Escape") {
                    e.preventDefault();
                    onCancel();
                  }
                }}
                onBlur={() => {
                  if (!inlineSaving) onCommit();
                }}
                style={{
                  ...inputStyle,
                  flex: 1,
                  minWidth: 0,
                  padding: "4px 6px",
                  fontSize: 11,
                  boxSizing: "border-box",
                }}
              />
              {puedeQuitar ? (
                <button
                  type="button"
                  title="Quitar fecha de caducidad"
                  disabled={inlineSaving}
                  onMouseDown={(e) => e.preventDefault()}
                  onClick={() => onQuitarCad?.(p.id, cadMeta)}
                  style={{
                    padding: "2px 7px",
                    borderRadius: 6,
                    border: `1px solid ${C.red}`,
                    background: "#fff",
                    color: C.red,
                    fontWeight: 700,
                    fontSize: 12,
                    lineHeight: 1.2,
                    cursor: inlineSaving ? "not-allowed" : "pointer",
                    flexShrink: 0,
                  }}
                >
                  ×
                </button>
              ) : null}
            </div>
          </td>
        );
      }
      const multiLotes = (p.lotes_activos || []).length > 1;
      return (
        <td
          key={colId}
          style={{
            ...tdCad,
            cursor: selectionMode || !puedeCad ? "default" : "pointer",
          }}
          title={
            !loteRef
              ? (p.stock ?? 0) > 0
                ? `Stock ${p.stock} sin lote PEPS — clic para asignar caducidad (crea lote sin sumar unidades)`
                : "Sin lote — clic para asignar caducidad (lote de referencia 0 pza.)"
              : `${loteRef.fecha_caducidad || "Sin fecha"} · Lote ${loteRef.numero_lote || "—"}${
                  multiLotes ? " (más próximo; otros en 📦 Lotes)" : ""
                } · Clic para editar`
          }
          onClick={(e) => {
            e.stopPropagation();
            if (selectionMode || !puedeCad) return;
            onStart(p.id, "cad", loteRef?.fecha_caducidad || "", { loteId: loteRef?.id ?? null });
          }}
          onMouseEnter={(e) => {
            if (!selectionMode && puedeCad) e.currentTarget.style.background = "#eff6ff";
          }}
          onMouseLeave={(e) => {
            e.currentTarget.style.background = stickyRowBg;
          }}
        >
          {proxCad ? (
            <span style={{ color: nearCad ? C.red : dias !== null && dias <= 60 ? C.amber : C.textMid, fontWeight: nearCad ? 700 : 500, fontSize: 11 }}>
              {dias !== null && dias < 0 ? "Vencido" : formatCaducidadMesAnio(proxCad)}
            </span>
          ) : loteRef ? (
              <span style={{ color: C.amber, fontWeight: 600, fontSize: 11 }}>Sin fecha</span>
            ) : (p.stock ?? 0) > 0 ? (
              <span style={{ color: C.blue, fontWeight: 600, fontSize: 11 }}>+ Cad.</span>
            ) : (
              "—"
            )}
        </td>
      );
    }
    case "agot":
      return (
        <td key={colId} style={{ padding: "8px 12px", borderBottom: `1px solid ${C.border}`, background: stickyRowBg }}>
          {(() => {
            if (!p.stock || !p.stock_minimo) return "—";
            const ventaDiaria = Math.max(p.stock_minimo * 0.15, 0.5);
            const diasAgot = Math.floor(p.stock / ventaDiaria);
            const col = diasAgot < 7 ? C.red : diasAgot < 15 ? C.amber : C.green;
            return <span style={{ color: col, fontWeight: 700, fontSize: 11 }}>~{diasAgot}d</span>;
          })()}
        </td>
      );
    case "desc":
      return (
        <InventarioEditableCell
          key={colId}
          {...inlineCellProps}
          productId={p.id}
          field="desc"
          value={String(p.descuento_pct ?? 0)}
          type="number"
          display={p.descuento_pct > 0 ? <span style={{ color: C.amber, fontWeight: 700 }}>{p.descuento_pct}%</span> : "—"}
          tdStyle={{ padding: "8px 12px", borderBottom: `1px solid ${C.border}`, background: stickyRowBg }}
        />
      );
    case "estado":
      return (
        <td key={colId} style={{ padding: "8px 12px", borderBottom: `1px solid ${C.border}`, background: stickyRowBg }}>
          <span style={{ padding: "2px 8px", borderRadius: 20, fontSize: 10, fontWeight: 700, background: p.activo ? C.greenDim : C.redDim, color: p.activo ? C.green : C.red }}>
            {p.activo ? "Activo" : "Inactivo"}
          </span>
        </td>
      );
    default:
      return null;
  }
}

const INV_COLS_OCULTAS_CONSULTA = ["costo", "margen", "acciones", "precio", "desc"];

export default function InventarioModule({ modoConsulta = false, onIrARecibir }) {
  const C = C_LIGHT;
  const inputStyle = mkInputStyle(C);
  const labelStyle = mkLabelStyle(C);
  const btnPrimary = mkBtnPrimary(C);
  const btnOutline = mkBtnOutline(C);
  const btnGreen = mkBtnGreen(C);
  const btnSecondary = mkBtnSecondary(C);
  const isMobileInv = useMediaQuery("(max-width: 768px)");
  const [productos,       setProductos]       = useState([]);
  const [loading,         setLoading]         = useState(true);
  const [busqueda,        setBusqueda]        = useState("");
  const [verInactivos,    setVerInactivos]    = useState(false);
  const [filtroCategoria, setFiltroCategoria] = useState("todas");
  const [filtroAlerta,    setFiltroAlerta]    = useState("todos");
  const [modal,           setModal]           = useState(null);
  const [modalRecibir,    setModalRecibir]    = useState(false);
  const [recibirPresetId, setRecibirPresetId] = useState(null);
  const [modalImportar,   setModalImportar]   = useState(false);
  const [importando,      setImportando]      = useState(false);
  /** Progreso durante confirmarImport (RPC en lotes). */
  const [importProgress,  setImportProgress]  = useState(null);
  /** Si true: solo `create`; filas con SKU ya en catálogo se omiten (no actualiza). */
  const [importCsvSoloNuevos, setImportCsvSoloNuevos] = useState(false);
  const [importResult,    setImportResult]    = useState(null);
  const [paginaInv, setPaginaInv] = useState(1);
  const [modalLotes, setModalLotes] = useState(null);
  const [loteCadSaving, setLoteCadSaving] = useState(null);
  const [modalBulkImages, setModalBulkImages] = useState(false);
  const [selectedIds, setSelectedIds] = useState([]);
  const [modalBulkEdit, setModalBulkEdit] = useState(false);
  const [showColumnSizer, setShowColumnSizer] = useState(false);
  const [colOrder, setColOrder] = useState(loadInvColumnOrder);
  const colOrderVisible = useMemo(
    () => (modoConsulta ? colOrder.filter((id) => !INV_COLS_OCULTAS_CONSULTA.includes(id)) : colOrder),
    [colOrder, modoConsulta]
  );
  const [colDragId, setColDragId] = useState(null);
  const [colWidths, setColWidths] = useState(() => {
    try {
      const raw = JSON.parse(localStorage.getItem("farmacapital_inv_col_widths") || "{}");
      const merged = { ...INV_COL_WIDTHS_DEFAULT, ...raw };
      // El default viejo (118+) dejaba un hueco entre el basurero y el SKU.
      if (!raw.acciones || Number(raw.acciones) >= 118) merged.acciones = INV_COL_WIDTHS_DEFAULT.acciones;
      return merged;
    } catch {
      return { ...INV_COL_WIDTHS_DEFAULT };
    }
  });

  useEffect(() => {
    try {
      localStorage.setItem("farmacapital_inv_col_widths", JSON.stringify(colWidths));
    } catch {
      /* noop */
    }
  }, [colWidths]);

  useEffect(() => {
    try {
      localStorage.setItem("farmacapital_inv_col_order", JSON.stringify(colOrder));
    } catch {
      /* noop */
    }
  }, [colOrder]);

  const inventarioStickyStyleFor = useCallback(
    (colId, opts) => inventarioStickyStyle(colId, colOrderVisible, colWidths, {
      ...opts,
      hasCheckbox: !modoConsulta,
    }),
    [colOrderVisible, colWidths, modoConsulta]
  );

  const invColWidthStyle = useCallback(
    (id) => {
      const w = invColumnPixelWidth(id, colWidths);
      return { width: w, minWidth: w, maxWidth: w, boxSizing: "border-box" };
    },
    [colWidths]
  );
  const headerSelectAllRef = useRef(null);
  const selectedSet = useMemo(() => new Set(selectedIds), [selectedIds]);

  const clearSelection = useCallback(() => setSelectedIds([]), []);
  const toggleSelectId = useCallback((id) => {
    setInlineEdit(null);
    setSelectedIds((prev) => (prev.includes(id) ? prev.filter((x) => x !== id) : [...prev, id]));
  }, []);

  // N8: Resetear página al cambiar filtros
  useEffect(()=>{ setPaginaInv(1); },[filtroCategoria,filtroAlerta,busqueda,verInactivos]);
  useEffect(()=>{ clearSelection(); },[filtroCategoria,filtroAlerta,busqueda,verInactivos,clearSelection]);
  const INV_POR_PAG = 50;

  const procesarArchivo = (file) => {
    const reader = new FileReader();
    reader.onload = e => {
      const texto = e.target.result;
      const result = parsearCSV(texto);
      if(!result.ok && result.rows.length===0){
        setImportResult({error: result.msg||"No se pudieron leer productos del archivo. Verifica el formato."});
      } else {
        setImportResult(result);
      }
    };
    reader.onerror = () => setImportResult({error:"Error al leer el archivo."});
    reader.readAsText(file, "UTF-8");
  };

  /** Varias RPC en paralelo; secuencial era ~550× RTT y parecía “colgado”. */
  const IMPORT_RPC_CONCURRENCY = 8;
  const IMPORT_SKU_LOOKUP_CHUNK = 120;

  const confirmarImport = async () => {
    if (!importResult?.rows?.length) return;
    const rows = importResult.rows;
    const total = rows.length;
    setImportando(true);
    setImportProgress({ cur: 0, total });
    const tok = sessionStorage.getItem("farmacapital_session_token");
    if (!tok) {
      setImportando(false);
      setImportProgress(null);
      showToast("Sesión expirada.", "error");
      return;
    }

    /** SKU / código de barras → id para filas que ya existen. */
    const skuList = [...new Set(rows.map((r) => (r.sku || "").trim()).filter(Boolean))];
    const cbList = [...new Set(rows.map((r) => (r.codigo_barras || "").trim()).filter(Boolean))];
    const skuToId = new Map();
    const cbToId = new Map();
    try {
      for (let s = 0; s < skuList.length; s += IMPORT_SKU_LOOKUP_CHUNK) {
        const chunk = skuList.slice(s, s + IMPORT_SKU_LOOKUP_CHUNK);
        const { data, error: qErr } = await supabase
          .from("productos")
          .select("id, sku")
          .in("sku", chunk);
        if (qErr) {
          console.error("Import: lookup SKU", qErr);
          showToast(`No se pudo consultar productos existentes: ${qErr.message}`, "error");
          setImportando(false);
          setImportProgress(null);
          return;
        }
        for (const p of data || []) {
          if (p.sku) skuToId.set(String(p.sku).trim(), p.id);
        }
      }
      for (let s = 0; s < cbList.length; s += IMPORT_SKU_LOOKUP_CHUNK) {
        const chunk = cbList.slice(s, s + IMPORT_SKU_LOOKUP_CHUNK);
        const { data, error: qErr } = await supabase
          .from("productos")
          .select("id, codigo_barras")
          .in("codigo_barras", chunk);
        if (qErr) {
          console.error("Import: lookup código de barras", qErr);
          showToast(`No se pudo consultar códigos de barras: ${qErr.message}`, "error");
          setImportando(false);
          setImportProgress(null);
          return;
        }
        for (const p of data || []) {
          if (p.codigo_barras) cbToId.set(String(p.codigo_barras).trim(), p.id);
        }
      }
    } catch (e) {
      console.error(e);
      showToast("Error al preparar importación.", "error");
      setImportando(false);
      setImportProgress(null);
      return;
    }

    let created = 0;
    let updated = 0;
    let skipped = 0;
    let err = 0;
    try {
      const runRow = async (row) => {
        const {
          stock,
          lote,
          fecha_caducidad,
          costo,
          codigo_barras,
          marca_comercial,
          principio_activo,
          concentracion,
          presentacion,
          contenido_caja,
          linea_comercial,
          grupo_farmacologico,
          jerarquia,
          sku_casa_saba,
          stock_maximo,
          notas,
          ...resto
        } = row;
        const skuKey = (resto.sku || "").trim();
        const cbKey = (codigo_barras || "").trim();
        const existingId = skuKey ? skuToId.get(skuKey) : (cbKey ? cbToId.get(cbKey) : null);
        const cbNorm = cbKey || null;
        const extrasPatch = {
          marca_comercial: marca_comercial || null,
          marca: marca_comercial || null,
          principio_activo: principio_activo || null,
          concentracion: concentracion || null,
          presentacion: presentacion || null,
          contenido_caja: contenido_caja || null,
          linea_comercial: linea_comercial || null,
          grupo_farmacologico: grupo_farmacologico || null,
          jerarquia: jerarquia || null,
          sku_casa_saba: sku_casa_saba || null,
          stock_maximo: Number.isFinite(Number(stock_maximo)) ? Number(stock_maximo) : null,
          notas: notas || null,
        };

        if (existingId && importCsvSoloNuevos) {
          return "skip";
        }

        if (existingId) {
          const patch = {
            nombre: resto.nombre,
            sku: skuKey || null,
            codigo_barras: cbNorm,
            categoria: resto.categoria,
            tipo: resto.tipo,
            precio: resto.precio,
            costo: costo != null && costo !== "" ? Number(costo) : null,
            stock_minimo: resto.stock_minimo,
            proveedor: resto.proveedor || null,
            descuento_pct: resto.descuento_pct,
            activo: resto.activo !== false,
            ...extrasPatch,
          };
          const { error: edErr } = await supabase.rpc("admin_editar_producto", {
            p_session_token: tok,
            p_producto_id: existingId,
            p_patch: patch,
          });
          if (edErr) {
            console.error("Import actualizar:", edErr);
            return "err";
          }
          const stockNum = parseInt(stock, 10) || 0;
          if (stockNum > 0) {
            const { error: recvErr } = await supabase.rpc("receive_merchandise_secure", {
              p_session_token: tok,
              p_producto_id: existingId,
              p_cantidad: stockNum,
              p_numero_lote: lote || null,
              p_fecha_caducidad: fecha_caducidad || null,
              p_costo_unitario: costo != null && costo !== "" ? Number(costo) : null,
              p_proveedor: resto.proveedor || null,
            });
            if (recvErr) {
              console.error("Import recepción:", recvErr);
              return "err";
            }
          }
          return "upd";
        }

        const { data: respCreacion, error: rpcErr } = await supabase.rpc("create_producto_secure", {
          p_session_token: tok,
          p_producto_data: { ...resto, codigo_barras: cbNorm, costo: costo ?? null, ...extrasPatch },
          p_cantidad_inicial: stock || 0,
          p_numero_lote: lote || null,
          p_fecha_caducidad: fecha_caducidad || null,
          p_costo_unitario: costo ?? null,
        });
        if (rpcErr) {
          console.error("Import alta:", rpcErr);
          return "err";
        }
        const newId = productoIdDesdeCreateRpc(respCreacion);
        if (newId != null) {
          const { error: metaErr } = await supabase.rpc("admin_editar_producto", {
            p_session_token: tok,
            p_producto_id: newId,
            p_patch: extrasPatch,
          });
          if (metaErr) {
            console.error("Import alta (campos extendidos):", metaErr);
            return "err";
          }
        }
        return "new";
      };

      for (let i = 0; i < rows.length; i += IMPORT_RPC_CONCURRENCY) {
        const slice = rows.slice(i, i + IMPORT_RPC_CONCURRENCY);
        const outcomes = await Promise.all(slice.map((row) => runRow(row)));
        for (const o of outcomes) {
          if (o === "new") created++;
          else if (o === "upd") updated++;
          else if (o === "skip") skipped++;
          else err++;
        }
        const cur = Math.min(i + slice.length, total);
        setImportProgress({ cur, total });
      }
    } finally {
      setImportando(false);
      setImportProgress(null);
      setModalImportar(false);
      setImportResult(null);
      await fetchProductos();
      if (err > 0) {
        const tail = importCsvSoloNuevos ? ` · ${skipped} omitidos` : "";
        showToast(
          `Listo: ${created} nuevos${importCsvSoloNuevos ? "" : `, ${updated} actualizados`}.${tail} · ${err} error(es). Revisa la consola.`,
          "warning"
        );
      } else if (importCsvSoloNuevos) {
        showToast(
          `✅ ${created} producto(s) nuevo(s). ${skipped} fila(s) con SKU FarmaCapital ya en catálogo (omitidas).`,
          created > 0 ? "success" : "info"
        );
      } else if (updated > 0 && created === 0) {
        showToast(`✅ ${updated} productos actualizados desde CSV (ya existían por SKU FarmaCapital)`, "success");
      } else if (created > 0 && updated === 0) {
        showToast(`✅ ${created} productos dados de alta`, "success");
      } else {
        showToast(`✅ ${created} nuevos · ${updated} actualizados`, "success");
      }
    }
  };

  const liquidar = async (prod) => {
    const pct = window.prompt(`¿Qué % de descuento aplicar para liquidar "${prod.nombre}"?\nPrecio actual: $${prod.precio}`, "30");
    if (!pct || isNaN(pct) || parseFloat(pct)<=0 || parseFloat(pct)>=100) return;
    const tok = sessionStorage.getItem("farmacapital_session_token");
    const { error } = await supabase.rpc("admin_editar_producto", {
      p_session_token: tok,
      p_producto_id: prod.id,
      p_patch: { descuento_pct: parseFloat(pct) },
    });
    if (error) { showToast("Error al liquidar: "+error.message, "error"); return; }
    const precioBase = parseFloat(prod.precio) || 0;
    const conDto = Math.max(0, precioBase * (1 - parseFloat(pct) / 100));
    showToast(`✅ ${prod.nombre} liquidado con ${pct}% desc. · Precio ref. ~$${conDto.toFixed(2)}`, "success");
    fetchProductos();
  };

  const fetchProductos = useCallback(async () => {
    setLoading(true);
    const tok = sessionStorage.getItem("farmacapital_session_token");
    const stripCosto = (p) => {
      if (!p || typeof p !== "object") return p;
      const next = { ...p };
      delete next.costo;
      if (Array.isArray(next.lotes)) {
        next.lotes = next.lotes.map((l) => {
          if (!l || typeof l !== "object") return l;
          const sl = { ...l };
          delete sl.costo_unitario;
          delete sl.costo;
          return sl;
        });
      }
      return next;
    };

    const traerConsultaVendedor = async () => {
      if (tok) {
        const { data, error } = await supabase.rpc("empleado_listar_productos_con_lotes_pos", {
          p_session_token: tok,
        });
        if (!error && data != null) {
          const list = Array.isArray(data) ? data : [];
          return { data: list.map(stripCosto), error: null, conLotes: true };
        }
        if (error) console.warn("[Inventario] RPC consulta vendedor:", error.message);
      }
      const filas = [];
      for (let desde = 0; ; desde += PRODUCTOS_POR_PAGINA) {
        const { data, error } = await supabase
          .from("productos")
          .select("id,nombre,sku,codigo_barras,categoria,stock,stock_minimo,activo,marca,presentacion,principio_activo,forma_farmaceutica,precio")
          .eq("activo", true)
          .order("nombre")
          .order("id")
          .range(desde, desde + PRODUCTOS_POR_PAGINA - 1);
        if (error) return { data: null, error, conLotes: false };
        filas.push(...(data || []).map(stripCosto));
        if ((data || []).length < PRODUCTOS_POR_PAGINA) break;
      }
      return { data: filas, error: null, conLotes: false };
    };

    const traerTodos = async () => {
      const filas = [];
      for (let desde = 0; ; desde += PRODUCTOS_POR_PAGINA) {
        let q = supabase
          .from("productos")
          .select("*")
          .order("nombre")
          .order("id")
          .range(desde, desde + PRODUCTOS_POR_PAGINA - 1);
        if (!verInactivos) q = q.eq("activo", true);
        const { data, error } = await q;
        if (error) return { data: null, error };
        filas.push(...(data || []));
        if ((data || []).length < PRODUCTOS_POR_PAGINA) break;
      }
      return { data: filas, error: null };
    };

    if (modoConsulta) {
      const { data, error, conLotes } = await traerConsultaVendedor();
      if (error) {
        showToast("No se pudo cargar el inventario: " + error.message, "error");
        setProductos([]);
        setLoading(false);
        return null;
      }
      let lotesByProducto = {};
      if (!conLotes) lotesByProducto = await fetchLotesPorProducto(tok, { omitCosto: true });
      const enriched = (data || []).map((p) => enrichProductoConLotes(p, p.lotes || lotesByProducto[p.id]));
      setProductos(enriched);
      setLoading(false);
      return enriched;
    }

    const [{ data, error }, lotesByProducto] = await Promise.all([
      traerTodos(),
      fetchLotesPorProducto(tok, { omitCosto: false }),
    ]);
    if (error) {
      showToast("No se pudo cargar el inventario: " + error.message, "error");
      setProductos([]);
      setLoading(false);
      return null;
    }
    const enriched = (data || []).map((p) => enrichProductoConLotes(p, lotesByProducto[p.id]));
    setProductos(enriched);
    setLoading(false);
    return enriched;
  }, [verInactivos, modoConsulta]);

  useEffect(() => { fetchProductos(); }, [fetchProductos]);

  const poolSinBusqueda = useMemo(() => productos.filter(p => {
    const cat = filtroCategoria === "todas" || p.categoria === filtroCategoria;
    const dias = diasParaCaducar(p.min_caducidad_lotes);
    const alerta =
      filtroAlerta === "todos"            ? true :
      filtroAlerta === "bajo_stock"       ? (p.stock <= (p.stock_minimo??0)) :
      filtroAlerta === "por_caducar"      ? esPorCaducar(dias) :
      filtroAlerta === "sin_codigo_barras" ? productoSinCodigoBarras(p) :
      filtroAlerta === "sin_precio" ? productoSinPrecioVenta(p) :
      true;
    return cat && alerta;
  }), [productos, filtroCategoria, filtroAlerta]);

  const filtradosTodosInv = useMemo(() => {
    const q = busqueda.trim();
    let list = poolSinBusqueda.filter((p) => inventarioProductMatchesBusqueda(p, busqueda));
    if (q.length >= 2) {
      list = [...list].sort(
        (a, b) =>
          inventarioSearchRelevanceRank(a, busqueda) - inventarioSearchRelevanceRank(b, busqueda) ||
          String(a.nombre || "").localeCompare(String(b.nombre || ""), "es", { sensitivity: "base" })
      );
    }
    return list;
  }, [poolSinBusqueda, busqueda]);

  const spellHintsInv = useMemo(
    () => (busqueda.trim().length >= 3 && filtradosTodosInv.length === 0
      ? spellSuggestFromProducts(poolSinBusqueda, busqueda)
      : []),
    [poolSinBusqueda, busqueda, filtradosTodosInv.length]
  );
  const filtrados = filtradosTodosInv.slice((paginaInv-1)*INV_POR_PAG, paginaInv*INV_POR_PAG);

  useEffect(() => {
    const el = headerSelectAllRef.current;
    if (!el) return;
    if (filtrados.length === 0) {
      el.indeterminate = false;
      return;
    }
    const all = filtrados.every((p) => selectedSet.has(p.id));
    const some = filtrados.some((p) => selectedSet.has(p.id));
    el.indeterminate = some && !all;
  }, [filtrados, selectedSet]);

  const toggleSelectAllOnPage = () => {
    setSelectedIds((prev) => {
      const next = new Set(prev);
      const pageIds = filtrados.map((p) => p.id);
      const allIn = pageIds.length > 0 && pageIds.every((id) => next.has(id));
      if (allIn) pageIds.forEach((id) => next.delete(id));
      else pageIds.forEach((id) => next.add(id));
      return [...next];
    });
  };

  const selectAllFiltered = () => {
    setSelectedIds(filtradosTodosInv.map((p) => p.id));
  };

  const activos    = productos.filter(p => p.activo).length;
  const bajoStock  = productos.filter(p => p.activo && p.stock<=(p.stock_minimo??0)).length;
  const porCaducar = productos.filter(p => esPorCaducar(diasParaCaducar(p.min_caducidad_lotes))).length;
  const sinCodigoBarras = productos.filter(p => p.activo && productoSinCodigoBarras(p)).length;
  const sinPrecioVenta = productos.filter(p => p.activo && productoSinPrecioVenta(p)).length;
  const inactivos  = productos.filter(p => !p.activo).length;

  const abrirEdicionProducto = useCallback((p, { focusBarcode = false } = {}) => {
    setModal({ ...p, _focusBarcode: focusBarcode });
  }, []);

  const abrirLotesDesdeEdicion = useCallback((p) => {
    if (!p?.id) return;
    setModal(null);
    const fresh = productos.find((x) => x.id === p.id) || p;
    setModalLotes(fresh);
  }, [productos]);

  const abrirRecibirDesdeEdicion = useCallback((p) => {
    if (!p?.id) return;
    setModal(null);
    setRecibirPresetId(p.id);
    setModalRecibir(true);
  }, []);

  const refrescarProductoEnEdicion = useCallback(async () => {
    const enriched = await fetchProductos();
    if (!modal?.id || !enriched) return enriched;
    const fresh = enriched.find((x) => x.id === modal.id);
    if (fresh) setModal((m) => (m?.id === fresh.id ? { ...fresh, _focusBarcode: m._focusBarcode } : m));
    return enriched;
  }, [fetchProductos, modal?.id]);

  const [inlineEdit, setInlineEdit] = useState(null);
  const inlineEditRef = useRef(null);
  const [inlineSaving, setInlineSaving] = useState(false);

  const cancelInlineEdit = useCallback(() => {
    inlineEditRef.current = null;
    setInlineEdit(null);
  }, []);

  const guardarCampoInline = useCallback(async (product, field, rawDraft, meta = null) => {
    const tok = sessionStorage.getItem("farmacapital_session_token");
    if (!tok) {
      showToast("Sesión expirada.", "error");
      return false;
    }
    const draft = String(rawDraft ?? "").trim();

    if (modoConsulta && field !== "cad" && field !== "codigo_barras") {
      showToast("En este perfil solo puedes corregir código de barras y caducidad.", "error");
      return false;
    }

    if (field === "cad") {
      const quitar = Boolean(meta?.quitar);
      const fecha = quitar ? null : (draft || null);
      const loteId = meta?.loteId ?? resolverLoteCaducidadProducto(product)?.id ?? null;
      const lote = loteId ? (product.lotes || []).find((l) => l.id === loteId) : null;
      const prev = lote?.fecha_caducidad || null;
      if (!fecha) {
        if (!prev) return true;
        if (!quitar && !window.confirm("¿Quitar la fecha de caducidad de este lote?")) return false;
        const { data: resp, error } = await rpcGuardarCaducidadProducto(tok, product.id, null, loteId);
        if (error) {
          showToast(error.message, "error");
          return false;
        }
        if (!resp?.success) {
          showToast("No se pudo quitar la caducidad.", "error");
          return false;
        }
        await fetchProductos();
        showToast("Fecha de caducidad eliminada", "success");
        return true;
      }
      if (prev === fecha) return true;
      const { data: resp, error } = await rpcGuardarCaducidadProducto(tok, product.id, fecha, loteId);
      if (error) {
        showToast(error.message, "error");
        return false;
      }
      if (!resp?.success) {
        showToast("No se pudo guardar la caducidad.", "error");
        return false;
      }
      await fetchProductos();
      showToast(
        resp.accion === "crear_referencia"
          ? "Caducidad guardada (lote de referencia, sin stock)"
          : resp.accion === "crear"
            ? `Lote creado (${resp.cantidad ?? product.stock} pza.) con caducidad`
            : "Caducidad actualizada",
        "success"
      );
      return true;
    }

    if (field === "stock") {
      const n = parseInt(draft, 10);
      if (Number.isNaN(n) || n < 0) {
        showToast("Stock inválido.", "error");
        return false;
      }
      if (n === (product.stock ?? 0)) return true;
      const { error } = await supabase.rpc("adjust_stock_secure", {
        p_session_token: tok,
        p_producto_id: product.id,
        p_nuevo_stock: n,
        p_motivo: "Edición inline inventario",
      });
      if (error) {
        showToast(error.message, "error");
        return false;
      }
      await fetchProductos();
      showToast("Stock actualizado", "success");
      return true;
    }

    const patchKey = INV_INLINE_FIELD_PATCH[field];
    if (!patchKey) return false;

    let patchValue;
    if (field === "codigo_barras") {
      patchValue = codigoBarrasLimpio(draft) || null;
      if (!patchValue || patchValue.length < 8 || patchValue.length > 14) {
        showToast("Usa 8–14 dígitos (EAN/UPC).", "error");
        return false;
      }
      if (modoConsulta) {
        const { data, error } = await supabase.rpc("empleado_guardar_codigo_barras", {
          p_session_token: tok,
          p_producto_id: product.id,
          p_codigo_barras: patchValue,
        });
        if (error) {
          showToast(error.message, "error");
          return false;
        }
        if (!data?.success) {
          showToast(data?.error || "No se pudo guardar el código.", "error");
          return false;
        }
        await fetchProductos();
        showToast("Código de barras guardado", "success");
        return true;
      }
    } else if (field === "precio" || field === "costo") {
      const n = parseDinero(draft);
      if (Number.isNaN(n) || n < 0) {
        showToast("Precio/costo inválido.", "error");
        return false;
      }
      patchValue = n;
    } else if (field === "min") {
      const n = parseInt(draft, 10);
      if (Number.isNaN(n) || n < 0) {
        showToast("Stock mínimo inválido.", "error");
        return false;
      }
      patchValue = n;
    } else if (field === "desc") {
      const n = parseFloat(draft);
      if (Number.isNaN(n) || n < 0 || n >= 100) {
        showToast("Descuento % inválido (0–99).", "error");
        return false;
      }
      patchValue = n;
    } else if (field === "nombre") {
      if (!draft) {
        showToast("El nombre no puede quedar vacío.", "error");
        return false;
      }
      patchValue = draft;
    } else {
      patchValue = draft || null;
    }

    const currentRaw = product[patchKey];
    const currentNorm =
      currentRaw == null || currentRaw === ""
        ? ""
        : typeof patchValue === "number"
          ? Number(currentRaw)
          : String(currentRaw);
    if (currentNorm === patchValue || (patchValue == null && !currentNorm)) return true;

    const { data, error } = await supabase.rpc("admin_editar_producto", {
      p_session_token: tok,
      p_producto_id: product.id,
      p_patch: { [patchKey]: patchValue },
    });
    if (error) {
      showToast(error.message, "error");
      return false;
    }
    const saved = typeof data === "string" ? JSON.parse(data) : data;
    const row = saved?.producto;
    if (row && row.id != null) {
      setProductos((prev) => prev.map((p) => (
        p.id === product.id
          ? { ...p, precio: row.precio ?? p.precio, costo: row.costo ?? p.costo, precio_unidad: row.precio_unidad ?? p.precio_unidad }
          : p
      )));
      if (field === "precio" && row.precio != null && Number(row.precio) !== Number(patchValue)) {
        showToast(`Quedó en $${Number(row.precio).toFixed(2)} (regla de pieza).`, "warning");
      }
    }
    await fetchProductos();
    showToast("Guardado", "success");
    return true;
  }, [fetchProductos, modoConsulta]);

  const commitInlineEdit = useCallback(async (draftOverride) => {
    const edit = inlineEditRef.current || inlineEdit;
    if (!edit || inlineSaving) return;
    const product = productos.find((x) => x.id === edit.productId);
    if (!product) {
      cancelInlineEdit();
      return;
    }
    setInlineSaving(true);
    try {
      const draft = draftOverride != null ? draftOverride : edit.draft;
      const ok = await guardarCampoInline(product, edit.field, draft, edit.meta);
      if (ok) {
        cancelInlineEdit();
      } else if (edit.field === "cad") {
        const loteId = edit.meta?.loteId ?? resolverLoteCaducidadProducto(product)?.id ?? null;
        const lote = loteId ? (product.lotes || []).find((l) => l.id === loteId) : null;
        setInlineEdit((prev) => {
          const next = prev ? { ...prev, draft: lote?.fecha_caducidad || "" } : prev;
          inlineEditRef.current = next;
          return next;
        });
      }
    } finally {
      setInlineSaving(false);
    }
  }, [inlineEdit, inlineSaving, productos, guardarCampoInline, cancelInlineEdit]);

  const quitarCaducidadInline = useCallback(async (productId, meta = null) => {
    if (inlineSaving) return;
    const product = productos.find((x) => x.id === productId);
    if (!product) return;
    if (!window.confirm("¿Quitar la fecha de caducidad de este lote?")) return;
    setInlineSaving(true);
    try {
      const ok = await guardarCampoInline(product, "cad", "", { ...(meta || {}), quitar: true });
      if (ok) cancelInlineEdit();
    } finally {
      setInlineSaving(false);
    }
  }, [inlineSaving, productos, guardarCampoInline, cancelInlineEdit]);

  const startInlineEdit = useCallback((productId, field, rawValue, meta = null) => {
    const next = {
      productId,
      field,
      draft: rawValue == null || rawValue === "" ? "" : String(rawValue),
      meta,
    };
    inlineEditRef.current = next;
    setInlineEdit(next);
  }, []);

  const selectionMode = selectedIds.length > 0;

  const inlineCellProps = {
    C,
    inputStyle,
    inlineEdit,
    inlineSaving,
    selectionMode,
    readOnly: modoConsulta,
    onStart: startInlineEdit,
    onDraft: (v) => setInlineEdit((prev) => {
      const next = prev ? { ...prev, draft: v } : prev;
      inlineEditRef.current = next;
      return next;
    }),
    onCommit: commitInlineEdit,
    onCancel: cancelInlineEdit,
    onQuitarCad: quitarCaducidadInline,
  };

  const eliminarProducto = async (id, { confirmMsg } = {}) => {
    const tok = sessionStorage.getItem("farmacapital_session_token");
    if (!tok) {
      showToast("Sesión expirada.", "error");
      return { ok: false };
    }
    if (
      confirmMsg != null &&
      !window.confirm(
        confirmMsg ||
          "¿Eliminar este producto? Si tiene historial de ventas o compras solo se ocultará (desactivará)."
      )
    ) {
      return { ok: false, cancelled: true };
    }
    const { data: resp, error } = await supabase.rpc("admin_eliminar_producto", {
      p_session_token: tok,
      p_producto_id: id,
    });
    if (error) {
      showToast(`Error al eliminar: ${error.message}`, "error");
      return { ok: false, error: error.message };
    }
    if (!resp?.success) {
      showToast("No se pudo eliminar el producto.", "error");
      return { ok: false };
    }
    return { ok: true, softDeleted: !!resp.soft_deleted, motivo: resp.motivo || null };
  };

  const desactivar = async (id) => {
    if (!window.confirm("¿Desactivar este producto? (se oculta del catálogo activo)")) return;
    const tok = sessionStorage.getItem("farmacapital_session_token");
    if (!tok) {
      showToast("Sesión expirada.", "error");
      return;
    }
    const { data: resp, error } = await supabase.rpc("admin_toggle_producto", {
      p_session_token: tok, p_producto_id: id, p_activo: false,
    });
    if (error) {
      showToast(`Error: ${error.message}`, "error");
      return;
    }
    if (!resp?.success) {
      showToast("No se pudo desactivar el producto.", "error");
      return;
    }
    showToast("Producto desactivado. Activa «Ver inactivos» para verlo.", "success");
    fetchProductos();
  };
  const eliminarUno = async (p) => {
    const result = await eliminarProducto(p.id, {
      confirmMsg: `¿Eliminar «${p.nombre || "producto"}»? Si tiene ventas o compras registradas solo se ocultará.`,
    });
    if (!result.ok) return;
    if (result.softDeleted) {
      showToast("Producto ocultado (tiene historial). Activa «Ver inactivos» para verlo.", "success");
    } else {
      showToast("✅ Producto eliminado", "success");
    }
    fetchProductos();
  };
  const reactivar = async (id) => {
    const tok = sessionStorage.getItem("farmacapital_session_token");
    const { error } = await supabase.rpc("admin_toggle_producto", {
      p_session_token: tok, p_producto_id: id, p_activo: true,
    });
    if (error) showToast("Error: "+error.message, "error");
    fetchProductos();
  };

  const aplicarEdicionLote = async (patch) => {
    const tok = sessionStorage.getItem("farmacapital_session_token");
    if (!tok) {
      showToast("Sesión expirada.", "error");
      return;
    }
    const ids = [...selectedIds];
    let ok = 0;
    let err = 0;
    for (const id of ids) {
      const { error } = await supabase.rpc("admin_editar_producto", {
        p_session_token: tok,
        p_producto_id: id,
        p_patch: patch,
      });
      if (error) err++;
      else ok++;
    }
    setModalBulkEdit(false);
    clearSelection();
    fetchProductos();
    if (err) {
      showToast(`Actualizados ${ok} de ${ids.length}. ${err} error(es).`, err === ids.length ? "error" : "warning");
    } else {
      showToast(`✅ ${ok} producto(s) actualizado(s)`, "success");
    }
  };

  const bulkDesactivar = async () => {
    const tok = sessionStorage.getItem("farmacapital_session_token");
    if (!tok) {
      showToast("Sesión expirada.", "error");
      return;
    }
    const ids = [...selectedIds];
    const targets = productos.filter((p) => ids.includes(p.id) && p.activo);
    if (!targets.length) {
      showToast("Ninguno de los seleccionados está activo.", "info");
      return;
    }
    if (!window.confirm(`¿Desactivar ${targets.length} producto(s)?`)) return;
    let ok = 0;
    let err = 0;
    for (const p of targets) {
      const { error } = await supabase.rpc("admin_toggle_producto", {
        p_session_token: tok,
        p_producto_id: p.id,
        p_activo: false,
      });
      if (error) err++;
      else ok++;
    }
    clearSelection();
    fetchProductos();
    if (err) {
      showToast(`Desactivados ${ok}. ${err} error(es).`, "warning");
    } else {
      showToast(`✅ ${ok} producto(s) desactivado(s)`, "success");
    }
  };

  const bulkReactivar = async () => {
    const tok = sessionStorage.getItem("farmacapital_session_token");
    if (!tok) {
      showToast("Sesión expirada.", "error");
      return;
    }
    const ids = [...selectedIds];
    const targets = productos.filter((p) => ids.includes(p.id) && !p.activo);
    if (!targets.length) {
      showToast("Ninguno de los seleccionados está inactivo.", "info");
      return;
    }
    if (!window.confirm(`¿Reactivar ${targets.length} producto(s)?`)) return;
    let ok = 0;
    let err = 0;
    for (const p of targets) {
      const { error } = await supabase.rpc("admin_toggle_producto", {
        p_session_token: tok,
        p_producto_id: p.id,
        p_activo: true,
      });
      if (error) err++;
      else ok++;
    }
    clearSelection();
    fetchProductos();
    if (err) {
      showToast(`Reactivados ${ok}. ${err} error(es).`, "warning");
    } else {
      showToast(`✅ ${ok} producto(s) reactivado(s)`, "success");
    }
  };

  const bulkEliminar = async () => {
    const ids = [...selectedIds];
    if (!ids.length) return;
    if (
      !window.confirm(
        `¿Eliminar ${ids.length} producto(s)? Los que tienen ventas o compras registradas solo se ocultarán (desactivarán).`
      )
    ) {
      return;
    }
    let ok = 0;
    let soft = 0;
    let err = 0;
    let lastError = "";
    for (const id of ids) {
      const result = await eliminarProducto(id);
      if (result.cancelled) return;
      if (result.ok) {
        ok++;
        if (result.softDeleted) soft++;
      } else {
        err++;
        if (result.error) lastError = result.error;
      }
    }
    clearSelection();
    fetchProductos();
    if (err) {
      showToast(
        `Procesados ${ok} de ${ids.length}. ${err} error(es).${lastError ? ` ${lastError}` : ""}`,
        err === ids.length ? "error" : "warning"
      );
    } else if (soft > 0 && soft === ok) {
      showToast(
        `✅ ${ok} producto(s) ocultado(s) (tenían historial). Activa «Ver inactivos» si necesitas verlos.`,
        "success"
      );
    } else if (soft > 0) {
      showToast(`✅ ${ok - soft} eliminado(s), ${soft} ocultado(s) por historial`, "success");
    } else {
      showToast(`✅ ${ok} producto(s) eliminado(s)`, "success");
    }
  };

  const abrirLotesSeleccion = () => {
    if (selectedIds.length !== 1) {
      showToast("Seleccioná un solo producto para ver sus lotes.", "warning");
      return;
    }
    const p = productos.find((x) => x.id === selectedIds[0]);
    if (p) setModalLotes(p);
  };

  const actualizarCaducidadLote = useCallback(async (loteId, fecha, productoId) => {
    const tok = sessionStorage.getItem("farmacapital_session_token");
    if (!tok) {
      showToast("Sesión expirada.", "error");
      return;
    }
    const quitar = !fecha;
    setLoteCadSaving(loteId);
    try {
      const { data: resp, error } = await supabase.rpc("admin_editar_lote", {
        p_session_token: tok,
        p_lote_id: loteId,
        p_fecha_caducidad: fecha || null,
        p_numero_lote: null,
        p_quitar_caducidad: quitar,
      });
      if (error) {
        showToast(error.message, "error");
        return;
      }
      if (!resp?.success) {
        showToast("No se pudo guardar la caducidad.", "error");
        return;
      }
      const refreshed = await fetchProductos();
      const p = refreshed?.find((x) => x.id === productoId);
      if (p) setModalLotes(p);
      showToast(quitar ? "Fecha de caducidad eliminada" : "Caducidad actualizada", "success");
    } finally {
      setLoteCadSaving(null);
    }
  }, [fetchProductos]);

  const abrirEdicionSeleccion = () => {
    if (selectedIds.length === 1) {
      const p = productos.find((x) => x.id === selectedIds[0]);
      if (p) abrirEdicionProducto(p);
      return;
    }
    setModalBulkEdit(true);
  };

  return (
    <div style={{padding:24,background:C.bg,minHeight:"100dvh",fontFamily:"var(--fc-body)"}}>

      <div
        style={{
          position: "sticky",
          top: isMobileInv ? INV_TOOLBAR_STICKY_TOP.mobile : INV_TOOLBAR_STICKY_TOP.desktop,
          zIndex: 24,
          background: C.bg,
          margin: "0 -24px",
          padding: "0 24px 12px",
          borderBottom: `1px solid ${C.border}`,
          boxShadow: "0 6px 20px rgba(15,23,42,.06)",
        }}
      >
      {selectionMode && !modoConsulta && (
        <div
          style={{
            display: "flex",
            flexWrap: "wrap",
            gap: 8,
            alignItems: "center",
            marginBottom: 12,
            padding: "12px 14px",
            background: C.card,
            border: `1px solid rgba(0, 82, 204, 0.35)`,
            borderRadius: 10,
            boxShadow: "0 4px 14px rgba(15, 45, 110, 0.06)",
          }}
        >
          <span style={{ fontWeight: 800, color: C.text, marginRight: 4 }}>
            {selectedIds.length} seleccionado{selectedIds.length !== 1 ? "s" : ""}
          </span>
          <span style={{ fontSize: 11, color: C.textMid, marginRight: 8 }}>
            Editá desde aquí · quita la selección (✕) para editar celdas sueltas
          </span>
          <button
            type="button"
            style={{ ...btnPrimary, padding: "8px 14px", fontSize: 12 }}
            onClick={abrirEdicionSeleccion}
          >
            {selectedIds.length === 1 ? "✏️ Editar producto" : "✏️ Editar en lote"}
          </button>
          {selectedIds.length === 1 && (
            <button type="button" style={{ ...btnOutline, padding: "8px 12px", fontSize: 12 }} onClick={abrirLotesSeleccion}>
              📦 Lotes
            </button>
          )}
          <button
            type="button"
            style={{ ...btnOutline, padding: "8px 12px", fontSize: 12, color: C.amber, borderColor: C.amber }}
            onClick={() => {
              const pct = window.prompt(`% de descuento a aplicar a ${selectedIds.length} producto(s) (0–99)`, "15");
              if (pct == null || pct === "") return;
              const n = parseFloat(pct);
              if (Number.isNaN(n) || n <= 0 || n >= 100) {
                showToast("Porcentaje inválido.", "error");
                return;
              }
              aplicarEdicionLote({ descuento_pct: n });
            }}
          >
            🏷️ Descuento %
          </button>
          <button type="button" style={{ ...btnOutline, padding: "8px 12px", fontSize: 12, color: C.red, borderColor: C.red }} onClick={bulkDesactivar}>
            🔴 Desactivar
          </button>
          <button type="button" style={{ ...btnOutline, padding: "8px 12px", fontSize: 12, color: C.green, borderColor: C.green }} onClick={bulkReactivar}>
            ✅ Reactivar
          </button>
          <button
            type="button"
            style={{ ...btnSecondary, padding: "8px 12px", fontSize: 12, color: C.red, borderColor: C.red, background: C.redDim }}
            onClick={bulkEliminar}
          >
            🗑️ Eliminar
          </button>
          <button type="button" style={{ ...btnSecondary, padding: "8px 10px", fontSize: 11, marginLeft: "auto" }} onClick={clearSelection} title="Quitar selección">
            ✕ Quitar selección
          </button>
        </div>
      )}
      <div style={{
        display:"flex",
        flexDirection:isMobileInv?"column":"row",
        justifyContent:"space-between",
        alignItems:isMobileInv?"stretch":"center",
        marginBottom:16,
        flexWrap:isMobileInv?"nowrap":"wrap",
        gap:12,
        paddingTop: 4,
      }}>
        <div style={{ minWidth: 0 }}>
          <h1 style={{margin:0,color:C.text,fontSize:20,fontWeight:800}}>▤ Inventario</h1>
          <p style={{margin:"4px 0 0",color:C.textMid,fontSize:12}}>
            {modoConsulta
              ? "Toca el código de barras o la caducidad para corregirlos. El precio se consulta en el POS."
              : "Clic en cualquier celda para editar · ↔ Columnas para ordenar y ajustar anchos"}
          </p>
        </div>
        <div style={isMobileInv ? {
          display:"grid",
          gridTemplateColumns:"1fr 1fr",
          gap:8,
          width:"100%",
        } :         {display:"flex", gap:8, flexWrap:"wrap" }}>
          {modoConsulta && onIrARecibir && (
            <button type="button" style={{...btnPrimary, ...(isMobileInv ? { gridColumn:"1 / -1", padding:"11px 16px", fontSize:13 } : {})}} onClick={onIrARecibir}>
              📦 Recibir cajas
            </button>
          )}
          {!modoConsulta && (
            <>
          <button data-tour="inv-agregar" style={{...btnPrimary, ...(isMobileInv ? { gridColumn:"1 / -1", padding:"11px 16px", fontSize:13 } : {})}} onClick={()=>setModal(EMPTY)}>
            ➕ Nuevo producto
          </button>
          <button style={btnOutline} onClick={() => (onIrARecibir ? onIrARecibir() : setModalRecibir(true))}>
            {isMobileInv ? "📦 Recibir" : "📦 Recibir (escáner)"}
          </button>
          <button style={btnOutline} onClick={()=>{ setImportResult(null); setImportCsvSoloNuevos(false); setModalImportar(true); }}>
            {isMobileInv ? "📥 Importar" : "📥 Importar CSV"}
          </button>
          <button style={btnOutline} onClick={()=>setModalBulkImages(true)}>
            {isMobileInv ? "🖼️ Masivo" : "🖼️ Cargar fotos masivo"}
          </button>
          <button style={btnOutline} onClick={descargarPlantilla}>📋 Plantilla</button>
          <button style={btnOutline} onClick={()=>exportarCSV(filtradosTodosInv)}>
            ⬇ Exportar CSV
          </button>
            </>
          )}
        </div>
      </div>

      <div style={{display:"flex",gap:12,marginBottom:14,flexWrap:"wrap"}}>
        {[
          {label:"Activos",     val:activos,    col:C.blue,  click:()=>{ setFiltroAlerta("todos"); setFiltroCategoria("todas"); setBusqueda(""); setVerInactivos(false); }, on: filtroAlerta==="todos" && filtroCategoria==="todas" && !busqueda && !verInactivos},
          {label:"Bajo stock",  val:bajoStock,  col:C.amber, click:()=>setFiltroAlerta(filtroAlerta==="bajo_stock"?"todos":"bajo_stock"), on: filtroAlerta==="bajo_stock"},
          {label:"Por caducar", val:porCaducar, col:C.red,   click:()=>setFiltroAlerta(filtroAlerta==="por_caducar"?"todos":"por_caducar"), on: filtroAlerta==="por_caducar"},
          {label:"Sin cód. barras", val:sinCodigoBarras, col:C.blue, click:()=>setFiltroAlerta(filtroAlerta==="sin_codigo_barras"?"todos":"sin_codigo_barras"), on: filtroAlerta==="sin_codigo_barras"},
          ...(!modoConsulta ? [
            {label:"Sin precio", val:sinPrecioVenta, col:C.red, click:()=>setFiltroAlerta(filtroAlerta==="sin_precio"?"todos":"sin_precio"), on: filtroAlerta==="sin_precio"},
            {label:"Inactivos",   val:inactivos,  col:C.textMid, click:()=>{ setVerInactivos(true); setFiltroAlerta("todos"); }, on: !!verInactivos},
          ] : []),
        ].map(s=>(
          <button key={s.label} type="button" onClick={s.click} style={{
            background:s.on ? `${s.col}14` : C.card,
            border:`1.5px solid ${s.on ? s.col : C.border}`,borderRadius:10,
            padding:"10px 18px",minWidth:110,cursor:"pointer",textAlign:"left"}}
            onMouseEnter={e=>{e.currentTarget.style.border=`1.5px solid ${s.col}`;}}
            onMouseLeave={e=>{e.currentTarget.style.border=`1.5px solid ${s.on ? s.col : C.border}`;}}>
            <div style={{color:s.col,fontWeight:800,fontSize:22}}>{s.val}</div>
            <div style={{color:C.textMid,fontSize:11}}>{s.label}</div>
          </button>
        ))}
      </div>

      <div style={{
        display:"flex", flexWrap:"wrap", gap:10, marginBottom:12, fontSize:11, color:C.textMid,
      }}>
        <span style={{padding:"4px 10px",borderRadius:8,background:C.amberDim,color:C.amber,fontWeight:600}}>
          🟡 Fondo ámbar = stock bajo (≤ mínimo)
        </span>
        <span style={{padding:"4px 10px",borderRadius:8,background:C.redDim,color:C.red,fontWeight:600}}>
          🔴 Fondo rojo = caduca en ≤{DIAS_CADUCIDAD_ALERTA} días
        </span>
        <span style={{padding:"4px 10px",borderRadius:8,background:C.bg,border:`1px solid ${C.border}`}}>
          Sin color = normal · Tenue = inactivo
        </span>
        {!modoConsulta && (
        <span style={{padding:"4px 10px",borderRadius:8,background:"#eff6ff",color:C.blue}}>
          📊 Referencias de mercado: Inventario → «Referencias de precio»
        </span>
        )}
      </div>

      <div data-tour="inv-buscar" style={{display:"flex",flexDirection:"column",gap:10,marginBottom:0}}>
        <SearchDropdown value={busqueda} onChange={setBusqueda} onSelect={p=>setBusqueda(p.nombre)} placeholder="🔍 Nombre, SKU FarmaCapital, marca, principio, presentación…" items={productos} labelKey="nombre" subKey="sku" searchMode="inventario" badgeKey="stock" badgeCol="#1E3ABA" style={{width:"100%",maxWidth:"100%"}} emptyMsg="Sin productos"/>
        <div style={{display:"flex",gap:10,flexWrap:"wrap",alignItems:"center"}}>
        <select value={filtroCategoria} onChange={e=>setFiltroCategoria(e.target.value)} style={{...inputStyle,maxWidth:180}}>
          <option value="todas">Todas las categorías</option>
          {CATEGORIAS.map(c=><option key={c} value={c}>{c}</option>)}
        </select>
        <select value={filtroAlerta} onChange={e=>setFiltroAlerta(e.target.value)} style={{...inputStyle,maxWidth:180}}>
          <option value="todos">Todas las alertas</option>
          <option value="bajo_stock">⚠ Bajo stock</option>
          <option value="por_caducar">⏰ Por caducar ({DIAS_CADUCIDAD_ALERTA}d)</option>
          <option value="sin_codigo_barras">🏷️ Sin código de barras</option>
          {!modoConsulta && <option value="sin_precio">Sin precio de venta</option>}
        </select>
        {!modoConsulta && (
        <label style={{display:"flex",alignItems:"center",gap:7,cursor:"pointer",color:C.textMid,fontSize:12,fontWeight:600}}>
          <div onClick={()=>setVerInactivos(v=>!v)} style={{width:36,height:20,borderRadius:10,cursor:"pointer",
            background:verInactivos?C.blue:C.border,position:"relative",transition:"background .2s"}}>
            <div style={{position:"absolute",top:3,left:verInactivos?18:3,width:14,height:14,borderRadius:"50%",background:C.card,transition:"left .2s"}}/>
          </div>
          Ver inactivos
        </label>
        )}
        {(filtroCategoria!=="todas"||filtroAlerta!=="todos"||busqueda)&&(
          <button onClick={()=>{setFiltroCategoria("todas");setFiltroAlerta("todos");setBusqueda("");}}
            style={{...btnSecondary,padding:"7px 12px",fontSize:11}}>✕ Limpiar filtros</button>
        )}
        {filtrados.length > 0 && !modoConsulta && (
          <>
            <button type="button" onClick={toggleSelectAllOnPage} style={{ ...btnSecondary, padding: "7px 10px", fontSize: 11 }}>
              ☑ Esta página
            </button>
            {filtradosTodosInv.length > filtrados.length && (
              <button type="button" onClick={selectAllFiltered} style={{ ...btnOutline, padding: "7px 10px", fontSize: 11 }}>
                ☑ Todos los filtrados ({filtradosTodosInv.length})
              </button>
            )}
            {selectedIds.length > 0 && (
              <button type="button" onClick={clearSelection} style={{ ...btnSecondary, padding: "7px 10px", fontSize: 11 }}>
                Quitar selección ({selectedIds.length})
              </button>
            )}
          </>
        )}
        <span style={{color:C.textMid,fontSize:11,marginLeft:"auto"}}>
          {filtrados.length} en página · {filtradosTodosInv.length} filtrado{filtradosTodosInv.length !== 1 ? "s" : ""}
        </span>
        </div>
        {!modoConsulta && (
        <div style={{display:"flex",gap:8,alignItems:"center",marginTop:8,flexWrap:"wrap"}}>
          <button
            type="button"
            onClick={() => setShowColumnSizer((v) => !v)}
            style={{ ...btnSecondary, padding:"6px 10px", fontSize:11 }}
          >
            ↔ Columnas
          </button>
          <button
            type="button"
            onClick={() => setColWidths({ ...INV_COL_WIDTHS_DEFAULT })}
            style={{ ...btnSecondary, padding:"6px 10px", fontSize:11 }}
          >
            Restablecer anchos
          </button>
          <button
            type="button"
            onClick={() => setColOrder([...INV_COLUMN_ORDER_DEFAULT])}
            style={{ ...btnSecondary, padding:"6px 10px", fontSize:11 }}
          >
            Restablecer orden
          </button>
        </div>
        )}
        {showColumnSizer && !modoConsulta && (
          <div style={{
            marginTop: 8,
            background: C.card,
            border: `1px solid ${C.border}`,
            borderRadius: 10,
            padding: "10px 12px",
          }}>
            <div style={{ fontSize: 11, color: C.textMid, marginBottom: 10 }}>
              Arrastra las filas para ordenar columnas. Los cambios se guardan en este navegador.
            </div>
            <div style={{ display: "flex", flexDirection: "column", gap: 6, marginBottom: 14 }}>
              {colOrder.map((colId) => {
                const def = INV_COLUMN_DEFS[colId];
                if (!def) return null;
                const dragging = colDragId === colId;
                return (
                  <div
                    key={colId}
                    draggable
                    onDragStart={() => setColDragId(colId)}
                    onDragEnd={() => setColDragId(null)}
                    onDragOver={(e) => e.preventDefault()}
                    onDrop={(e) => {
                      e.preventDefault();
                      if (colDragId && colDragId !== colId) {
                        setColOrder((prev) => reorderInvColumnOrder(prev, colDragId, colId));
                      }
                      setColDragId(null);
                    }}
                    style={{
                      display: "flex",
                      alignItems: "center",
                      gap: 10,
                      padding: "8px 10px",
                      borderRadius: 8,
                      border: `1px solid ${dragging ? BRAND.secondary : C.border}`,
                      background: dragging ? "rgba(30, 58, 138, 0.06)" : C.bg,
                      cursor: "grab",
                      userSelect: "none",
                    }}
                  >
                    <span style={{ color: C.textDim, fontSize: 14, lineHeight: 1 }} aria-hidden>⠿</span>
                    <span style={{ fontSize: 12, fontWeight: 700, color: C.text, flex: 1 }}>{def.label}</span>
                    <span style={{ fontSize: 10, color: C.textDim }}>{INV_STICKY_COL_IDS.includes(colId) ? "Fija al scroll" : ""}</span>
                  </div>
                );
              })}
            </div>
            <div style={{
              display: "grid",
              gridTemplateColumns: "repeat(auto-fit, minmax(170px, 1fr))",
              gap: 10,
            }}>
            {[
              ["acciones", "Acciones", 88, 140],
              ["codigoBarras", "Cód. barras", 100, 180],
              ["nombre", "Nombre", 200, 420],
              ["marca", "Marca", 90, 240],
              ["presentacion", "Presentación", 110, 260],
              ["principio", "Principio activo", 130, 320],
              ["ubicacion", "Ubicación", 120, 280],
              ["categoria", "Categoría", 100, 220],
              ["proveedor", "Proveedor", 100, 240],
            ].map(([key, label, min, max]) => (
              <label key={key} style={{display:"block",fontSize:11,color:C.textMid}}>
                <div style={{display:"flex",justifyContent:"space-between",marginBottom:4}}>
                  <span>{label}</span>
                  <strong style={{color:C.text}}>{colWidths[key]}px</strong>
                </div>
                <input
                  type="range"
                  min={min}
                  max={max}
                  step="2"
                  value={colWidths[key]}
                  onChange={(e)=>setColWidths((p)=>({...p,[key]: Number(e.target.value)}))}
                  style={{width:"100%"}}
                />
              </label>
            ))}
            </div>
          </div>
        )}
      </div>

      </div>

      {spellHintsInv.length > 0 && (
        <div style={{
          marginBottom:14,padding:"10px 12px",borderRadius:10,
          background:"rgba(15,45,110,.08)",border:"1px solid rgba(15,45,110,.25)",
          fontSize:12,color:C.text,lineHeight:1.5,
        }}>
          <span style={{fontWeight:800,color:BRAND.primary}}>¿Quisiste decir? </span>
          {spellHintsInv.map((h, i) => (
            <span key={h.label}>
              {i > 0 && " · "}
              <button type="button" onClick={() => setBusqueda(h.label)} style={{
                background:"none",border:"none",padding:0,cursor:"pointer",
                color:BRAND.primary,fontWeight:700,textDecoration:"underline",fontSize:"inherit",
              }}>{h.label}</button>
            </span>
          ))}
        </div>
      )}

      {loading ? (
        <SkeletonTable rows={8} cols={12}/>
      ) : (
        <>
        <HorizontalScrollSync data-tour="inv-tabla">
          <table style={{width:"max-content",minWidth:1640,tableLayout:"fixed",borderCollapse:"separate",borderSpacing:0,fontSize:12}}>
            <thead>
              <tr>
                {!modoConsulta && (
                <th style={{
                  padding: "8px 4px",
                  textAlign: "center",
                  color: C.textMid,
                  fontWeight: 700,
                  borderBottom: `1px solid ${C.border}`,
                  verticalAlign: "middle",
                  position: "sticky",
                  left: 0,
                  width: INV_CHECKBOX_COL_WIDTH,
                  minWidth: INV_CHECKBOX_COL_WIDTH,
                  boxSizing: "border-box",
                  zIndex: 40,
                  background: C.card,
                }}>
                  <input
                    ref={headerSelectAllRef}
                    type="checkbox"
                    checked={filtrados.length > 0 && filtrados.every((p) => selectedSet.has(p.id))}
                    onChange={toggleSelectAllOnPage}
                    aria-label="Seleccionar todos en esta página"
                    style={{ width: 14, height: 14, cursor: "pointer", accentColor: BRAND.primary }}
                  />
                </th>
                )}
                {colOrderVisible.map((colId) => {
                  const col = INV_COLUMN_DEFS[colId];
                  if (!col) return null;
                  const compactHead = colId === "foto" || colId === "acciones";
                  return (
                  <th
                    key={colId}
                    title={col.hint || undefined}
                    style={{
                      padding: compactHead ? "8px 6px" : "10px 12px",
                      textAlign: "left",
                      color: C.textMid,
                      fontWeight: 700,
                      background: C.card,
                      borderBottom: `1px solid ${C.border}`,
                      whiteSpace: "nowrap",
                      cursor: col.hint ? "help" : undefined,
                      verticalAlign: "middle",
                      ...inventarioStickyStyleFor(colId, { header: true, bg: C.card }),
                      ...invColWidthStyle(colId),
                    }}
                  >
                    {col.label}
                  </th>
                  );
                })}
              </tr>
            </thead>
            <tbody>
              {filtrados.length===0&&(
                <tr><td colSpan={colOrderVisible.length + (modoConsulta ? 0 : 1)} style={{textAlign:"center",padding:32,color:C.textMid}}>
                  Sin productos{busqueda?` para "${busqueda}"`:""}{modoConsulta ? "." : ". Agrega el primero con ➕"}
                </td></tr>
              )}
              {filtrados.map((p,_rowIdx)=>{
                const bajo    = p.activo && p.stock<=(p.stock_minimo??0);
                const inact   = !p.activo;
                const proxCad = p.min_caducidad_lotes || resolverLoteCaducidadProducto(p)?.fecha_caducidad;
                const dias    = diasParaCaducar(proxCad);
                const nearCad = esPorCaducar(dias);
                const mgn     = margen(p.precio, p.costo);
                const mgnNum  = parseFloat(mgn);
                const mgnCol  = isNaN(mgnNum)?C.textMid:mgnNum>=50?C.green:mgnNum>=25?C.amber:C.red;
                const marcaDisp = (p.marca || "").trim();
                const { nombre: nombreTabla, presentacion: presInferida } = nombreYPresentacionTabla(p);
                const presDisp = presInferida || "—";
                const provDisp = (p.proveedor || "").trim();
                const principioLine = lineaPrincipioQuimicoTabla(p);
                const dosisLine = lineaDosisTabla(p);
                const cbDisp = codigoBarrasLimpio(p.codigo_barras);
                const sinCb = !cbDisp;
                const stickyRowBg = bajo ? C.amberDim : nearCad ? C.redDim : C.bg;
                const rowCtx = {
                  C,
                  BRAND,
                  CATEGORIAS,
                  p,
                  stickyRowBg,
                  inlineCellProps,
                  invColWidthStyle,
                  inventarioStickyStyleFor,
                  abrirEdicionProducto,
                  setModalLotes,
                  liquidar,
                  desactivar,
                  reactivar,
                  eliminarUno,
                  btnSecondary,
                  bajo,
                  inact,
                  mgn,
                  mgnCol,
                  marcaDisp,
                  nombreTabla,
                  presDisp,
                  presInferida,
                  provDisp,
                  principioLine,
                  dosisLine,
                  cbDisp,
                  sinCb,
                  proxCad,
                  dias,
                  nearCad,
                };
                return (
                  <tr key={p.id} className="farmacapital-table-row" style={{opacity:inact?0.45:1,background:bajo?C.amberDim:nearCad?C.redDim:"transparent"}}>
                    {!modoConsulta && (
                    <td style={{
                      padding: "4px 4px",
                      borderBottom: `1px solid ${C.border}`,
                      textAlign: "center",
                      verticalAlign: "middle",
                      position: "sticky",
                      left: 0,
                      width: INV_CHECKBOX_COL_WIDTH,
                      minWidth: INV_CHECKBOX_COL_WIDTH,
                      boxSizing: "border-box",
                      zIndex: 20,
                      background: stickyRowBg,
                    }}>
                      <input
                        type="checkbox"
                        checked={selectedSet.has(p.id)}
                        onChange={() => toggleSelectId(p.id)}
                        aria-label={`Seleccionar ${p.nombre}`}
                        style={{ width: 14, height: 14, cursor: "pointer", accentColor: BRAND.primary }}
                      />
                    </td>
                    )}
                    {colOrderVisible.map((colId) => renderInventarioColumnCell(colId, rowCtx))}
                  </tr>
                );
              })}
            </tbody>
          </table>
        </HorizontalScrollSync>
        <Paginador
          total={filtradosTodosInv.length}
          porPagina={INV_POR_PAG}
          pagina={paginaInv}
          setPagina={setPaginaInv}
        />
        </>
      )}

      {modal!==null && !modoConsulta && (
        <ProductoModal
          key={modal.id ?? "nuevo"}
          initial={modal}
          onClose={() => setModal(null)}
          onSaved={() => { setModal(null); fetchProductos(); }}
          onEditarCaducidad={modal.id ? abrirLotesDesdeEdicion : undefined}
          onRecibirMercancia={modal.id ? abrirRecibirDesdeEdicion : undefined}
          onCaducidadSaved={modal.id ? refrescarProductoEnEdicion : undefined}
        />
      )}
      {modalBulkImages && (
        <BulkImagesModal
          open={modalBulkImages}
          onClose={()=>setModalBulkImages(false)}
          productos={productos}
          onComplete={fetchProductos}
        />
      )}
      {modalBulkEdit && selectedIds.length > 0 && (
        <BulkEditProductosModal
          count={selectedIds.length}
          onClose={() => setModalBulkEdit(false)}
          onApplied={aplicarEdicionLote}
        />
      )}
      {modalLotes&&(
        <div style={{position:"fixed",inset:0,background:"rgba(15,23,42,.45)",backdropFilter:"blur(4px)",zIndex:1000,display:"flex",alignItems:"center",justifyContent:"center",padding:20}}
          onClick={e=>e.target===e.currentTarget&&setModalLotes(null)}>
          <div style={{background:C.card,borderRadius:14,width:"min(720px,95vw)",maxHeight:"85vh",overflowY:"auto",padding:24,boxShadow:"0 20px 60px rgba(15,45,110,.15)"}}>
            <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:16}}>
              <div>
                <h3 style={{margin:0,color:C.text,fontSize:15,fontWeight:800}}>📦 Lotes de {modalLotes.nombre}</h3>
                <div style={{color:C.textMid,fontSize:11,marginTop:2}}>
                  Stock total: <strong style={{color:C.blue}}>{modalLotes.stock}</strong>
                  {` · ${(modalLotes.lotes_activos||[]).length} lote(s) activo(s)`}
                </div>
              </div>
              <button onClick={()=>setModalLotes(null)} style={{background:"none",border:"none",color:C.textMid,fontSize:20,cursor:"pointer"}}>✕</button>
            </div>
            {((modalLotes.lotes||[]).filter((l) => l.activo !== false)).length===0 ? (
              <div style={{textAlign:"center",padding:40,color:C.textMid,fontSize:13}}>
                Este producto no tiene lotes. Asigná caducidad en la ficha del producto o usá <strong>📦 Recibir mercancía</strong>.
              </div>
            ) : (
              <>
              <p style={{ margin: "0 0 10px", fontSize: 11, color: C.textMid }}>
                Editá la fecha de caducidad de cada lote. Los cambios se guardan al salir del campo.
              </p>
              <table style={{width:"100%",borderCollapse:"collapse",fontSize:12}}>
                <thead>
                  <tr style={{background:C.cardDark}}>
                    {["Lote","Caducidad","Días","Cantidad","Costo unit."].map(h=>(
                      <th key={h} style={{padding:"8px 12px",textAlign:"left",color:C.textMid,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{h}</th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {(modalLotes.lotes||[])
                    .filter((l) => l.activo !== false)
                    .slice()
                    .sort((a,b)=>{
                      if(!a.fecha_caducidad) return 1;
                      if(!b.fecha_caducidad) return -1;
                      return a.fecha_caducidad.localeCompare(b.fecha_caducidad);
                    })
                    .map((l,i)=>{
                      const dias = diasParaCaducar(l.fecha_caducidad);
                      const col  = dias===null?C.textMid:dias<0?C.red:dias<=DIAS_CADUCIDAD_CRITICO?C.red:dias<=DIAS_CADUCIDAD_ALERTA?C.amber:C.green;
                      const saving = loteCadSaving === l.id;
                      return (
                        <tr key={l.id} style={{background:i%2===0?"transparent":"#f8fafc"}}>
                          <td style={{padding:"8px 12px",color:C.text,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{l.numero_lote||"—"}</td>
                          <td style={{padding:"8px 12px",borderBottom:`1px solid ${C.border}`}}>
                            <input
                              key={`${l.id}-${l.fecha_caducidad || "none"}`}
                              type="date"
                              defaultValue={l.fecha_caducidad || ""}
                              disabled={saving}
                              onBlur={(e) => {
                                const next = e.target.value || null;
                                if ((l.fecha_caducidad || null) === next) return;
                                if (!next && l.fecha_caducidad) {
                                  if (!window.confirm("¿Quitar la fecha de caducidad de este lote?")) {
                                    e.target.value = l.fecha_caducidad || "";
                                    return;
                                  }
                                }
                                actualizarCaducidadLote(l.id, next, modalLotes.id);
                              }}
                              style={{
                                ...inputStyle,
                                padding: "4px 8px",
                                fontSize: 11,
                                color: col,
                                fontWeight: 600,
                                minWidth: 130,
                              }}
                            />
                          </td>
                          <td style={{padding:"8px 12px",borderBottom:`1px solid ${C.border}`}}>
                            {dias===null?"—":<span style={{padding:"2px 8px",borderRadius:20,fontSize:10,fontWeight:700,background:col+"20",color:col}}>{dias<0?"Vencido":dias===0?"Hoy":`${dias}d`}</span>}
                          </td>
                          <td style={{padding:"8px 12px",color:C.blue,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{l.cantidad_actual}</td>
                          <td style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>${parseFloat(l.costo_unitario||0).toFixed(2)}</td>
                        </tr>
                      );
                    })}
                </tbody>
              </table>
              </>
            )}
          </div>
        </div>
      )}
      {modalRecibir&&(
        <RecibirModal
          productos={productos}
          initialProductId={recibirPresetId}
          onClose={() => { setModalRecibir(false); setRecibirPresetId(null); }}
          onReceived={() => { fetchProductos(); setRecibirPresetId(null); }}
        />
      )}

      {/* Modal Importar CSV */}
      {modalImportar&&(
        <div style={{position:"fixed",inset:0,background:"rgba(15,23,42,.45)",backdropFilter:"blur(4px)",zIndex:1000,display:"flex",alignItems:"center",justifyContent:"center",padding:20}}
          onClick={(e)=>{
            if (importando) return;
            if (e.target===e.currentTarget) { setModalImportar(false); setImportResult(null); setImportProgress(null); setImportCsvSoloNuevos(false); }
          }}>
          <div style={{background:C.card,borderRadius:14,width:"min(580px,95vw)",maxHeight:"90vh",overflowY:"auto",padding:28,boxShadow:"0 20px 60px rgba(15,45,110,.15)"}}>
            <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:20}}>
              <h2 style={{margin:0,color:C.text,fontSize:16,fontWeight:800}}>📥 Importar productos desde CSV</h2>
              <button onClick={()=>{setModalImportar(false);setImportResult(null);setImportProgress(null);setImportCsvSoloNuevos(false);}} style={{background:"none",border:"none",color:C.textMid,fontSize:22,cursor:"pointer"}}>✕</button>
            </div>
            <div style={{background:"#eff6ff",border:"1px solid #bfdbfe",borderRadius:10,padding:14,marginBottom:16}}>
              <div style={{color:"#1d4ed8",fontWeight:700,fontSize:13,marginBottom:8}}>📋 Instrucciones</div>
              <ol style={{color:"#1d4ed8",fontSize:12,paddingLeft:18,lineHeight:1.8,margin:0}}>
                <li>Descarga la plantilla con el botón de abajo</li>
                <li>Ábrela en Excel o Google Sheets</li>
                <li>Agrega tus productos (una fila por producto). Incluye <strong>Codigo_Barras</strong> (EAN de la caja) cuando lo tengas.</li>
                <li>Guarda como CSV (separado por comas)</li>
                <li>Sube el archivo aquí</li>
                <li style={{marginTop:6}}><strong>SKU FarmaCapital</strong> o <strong>Codigo_Barras</strong> identifican productos existentes para actualizar o recibir stock.</li>
                <li>En productos ya registrados, la columna <strong>Stock</strong> es la <strong>cantidad a recibir</strong> (nuevo lote PEPS), no el total deseado.</li>
              </ol>
            </div>
            <button onClick={descargarPlantilla} style={{width:"100%",padding:"10px",borderRadius:8,border:"1px solid #0D1B2A",background:"#eff6ff",color:"#0D1B2A",fontWeight:700,fontSize:13,cursor:"pointer",marginBottom:16,display:"flex",alignItems:"center",justifyContent:"center",gap:8}}>
              📋 Descargar plantilla Excel/CSV
            </button>
            <div style={{border:"2px dashed #e2e8f0",borderRadius:10,padding:24,textAlign:"center",marginBottom:16,cursor:"pointer",background:C.cardDark}}
              onClick={()=>document.getElementById("csv_input").click()}
              onDragOver={e=>{e.preventDefault();e.currentTarget.style.borderColor="#0D1B2A";}}
              onDragLeave={e=>{e.currentTarget.style.borderColor="#e2e8f0";}}
              onDrop={e=>{e.preventDefault();e.currentTarget.style.borderColor="#e2e8f0";const f=e.dataTransfer.files[0];if(f)procesarArchivo(f);}}>
              <div style={{fontSize:36,marginBottom:8}}>📄</div>
              <div style={{color:C.text,fontWeight:700,fontSize:14,marginBottom:4}}>Arrastra tu archivo CSV aquí</div>
              <div style={{color:C.textMid,fontSize:12}}>o haz clic para seleccionar · .csv o .txt</div>
              <input id="csv_input" type="file" accept=".csv,.txt" style={{display:"none"}}
                onChange={e=>{const f=e.target.files[0];if(f)procesarArchivo(f);e.target.value="";}}/>
            </div>
            {importResult&&(
              <div>
                {importResult.error?(
                  <div style={{background:"#fee2e2",border:"1px solid #fca5a5",borderRadius:8,padding:12,marginBottom:12,color:"#dc2626",fontSize:13}}>❌ {importResult.error}</div>
                ):(
                  <div>
                    <div style={{background:"#dcfce7",border:"1px solid #86efac",borderRadius:8,padding:12,marginBottom:12}}>
                      <div style={{color:"#16a34a",fontWeight:700,fontSize:13}}>✅ {importResult.rows.length} productos listos para importar</div>
                      {importResult.msg&&<div style={{color:"#16a34a",fontSize:11,marginTop:4}}>⚠️ {importResult.msg}</div>}
                    </div>
                    <div style={{maxHeight:200,overflowY:"visible",border:`1px solid ${C.border}`,borderRadius:8,marginBottom:16}}>
                      <table style={{width:"100%",borderCollapse:"collapse",fontSize:11}}>
                        <thead><tr style={{background:C.cardDark}}>
                          {["Nombre","SKU","Cód. barras","Stock","Precio","Caducidad"].map(h=><th key={h} style={{padding:"6px 10px",textAlign:"left",color:C.textMid,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{h}</th>)}
                        </tr></thead>
                        <tbody>
                          {importResult.rows.slice(0,20).map((r,i)=>(
                            <tr key={i} style={{background:i%2===0?"transparent":"#f8fafc"}}>
                              <td style={{padding:"5px 10px",color:C.text,fontWeight:600,borderBottom:`1px solid ${C.border}`}}>{r.nombre}</td>
                              <td style={{padding:"5px 10px",color:C.textMid,borderBottom:`1px solid ${C.border}`,fontFamily:"monospace"}}>{r.sku||"—"}</td>
                              <td style={{padding:"5px 10px",color:C.textMid,borderBottom:`1px solid ${C.border}`,fontFamily:"monospace",fontSize:10}}>{r.codigo_barras||"—"}</td>
                              <td style={{padding:"5px 10px",color:"#1E3ABA",fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{r.stock}</td>
                              <td style={{padding:"5px 10px",color:"#16a34a",fontWeight:700,borderBottom:`1px solid ${C.border}`}}>${r.precio}</td>
                              <td style={{padding:"5px 10px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{r.fecha_caducidad||"—"}</td>
                            </tr>
                          ))}
                          {importResult.rows.length>20&&<tr><td colSpan={6} style={{padding:"6px 10px",color:C.textDim,fontSize:10,textAlign:"center"}}>...y {importResult.rows.length-20} más</td></tr>}
                        </tbody>
                      </table>
                    </div>
                    <label style={{display:"flex",alignItems:"flex-start",gap:10,marginBottom:14,cursor:"pointer",fontSize:12,color:C.text,lineHeight:1.45}}>
                      <input type="checkbox" checked={importCsvSoloNuevos} onChange={(e)=>setImportCsvSoloNuevos(e.target.checked)} style={{marginTop:3}} />
                      <span>
                        <strong>Solo productos nuevos</strong> — solo dan de alta filas cuyo <strong>SKU FarmaCapital</strong> <em>aún no</em> está en el catálogo. Las que ya existen se omiten (no cambian precio ni stock).
                        <span style={{display:"block",color:C.textMid,fontSize:11,marginTop:4}}>
                          Desmarcado: fusionar lista — crea nuevos y actualiza precio/stock de los que ya tenían ese SKU FarmaCapital.
                        </span>
                      </span>
                    </label>
                    <button onClick={confirmarImport} disabled={importando}
                      style={{width:"100%",padding:"12px",borderRadius:8,border:"none",background:"linear-gradient(135deg,#0D1B2A,#1E3ABA)",color:"#fff",fontWeight:700,fontSize:14,cursor:"pointer",opacity: importando ? 0.85 : 1}}>
                      {importando && importProgress
                        ? `Importando… ${importProgress.cur}/${importProgress.total}`
                        : importando
                          ? `Importando… (${importResult.rows.length} productos)`
                          : "✅ Confirmar importación"}
                    </button>
                  </div>
                )}
              </div>
            )}
          </div>
        </div>
      )}
      <OnboardingTour tourId="inv" />
    </div>
  );
}
