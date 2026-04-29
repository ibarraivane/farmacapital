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
import { SkeletonTable, Paginador, SearchDropdown, HorizontalScrollSync } from "./ui";
import { showToast } from "./ui";
import OnboardingTour from "./components/OnboardingTour";
import { idEmpleadoUsuarios } from "./utils/usuarioId";
import ImageUploader from "./components/ImageUploader";

const leerSesion = () => {
  try {
    return JSON.parse(sessionStorage.getItem("farmax_admin_user") || "{}");
  } catch {
    return {};
  }
};

const BRAND = { primary:"#0052cc", secondary:"#0099e6", gradient:"linear-gradient(135deg,#0052cc,#0099e6)" };
const CATEGORIAS = [
  "Analgésico","Antiinflamatorio","Antibiótico","Gastro","Diabetes",
  "Hipertensión","Alergia","Vitaminas","Hidratación","Cardiovascular",
  "Respiratorio","Botiquín","Higiene","Bebidas","Básicos","Abarrotes","Minisuper","Cuidado personal","Otro",
];
const EMPTY = {
  nombre:"", sku:"", codigo_barras:"", categoria:"Otro", precio:"", costo:"", venta_unidad:false, unidades_por_caja:"", precio_unidad:"", stock_unidades:"",
  stock:"", stock_minimo:"", tipo:"generico", proveedor:"", lote:"",
  fecha_caducidad:"", descuento_pct:"0", activo:true, imagen_url:"", imagen_mobile_url:"",
  principio_activo:"", denominacion_generica:"", denominacion_distintiva:"",
  concentracion:"", presentacion:"", forma_farmaceutica:"",
  ubicacion_texto:"",
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
// Para productos ya existentes derivamos min_caducidad desde lotes activos.
const minCaducidadLotes = (lotes) => {
  const activos = (lotes || []).filter(l => l.activo !== false && (l.cantidad_actual || 0) > 0 && l.fecha_caducidad);
  return activos.reduce((m, l) => (!m || l.fecha_caducidad < m) ? l.fecha_caducidad : m, null);
};

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

const diasParaCaducar = (fecha) => {
  if (!fecha) return null;
  const diff = (new Date(fecha) - new Date()) / (1000 * 60 * 60 * 24);
  return Math.ceil(diff);
};

/**
 * Referencia del Excel mayorista (columna A del libro), guardada en `notas` como "Lista SKU origen".
 * No es el SKU Farmax (`productos.sku`): es solo la ref. del distribuidor para pedidos / cruce con lista.
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

const tdEllipsisStyle = {
  display: "block",
  overflow: "hidden",
  textOverflow: "ellipsis",
  whiteSpace: "nowrap",
};

/** Columnas fijas al hacer scroll horizontal: ☑ · foto · SKU · ref lista · nombre */
const INV_STICKY_COL_WIDTH = [52, 62, 120, 128, 272];
const INV_STICKY_LEFT = INV_STICKY_COL_WIDTH.reduce((acc, w, i) => {
  if (i === 0) acc.push(0);
  else acc.push(acc[i - 1] + INV_STICKY_COL_WIDTH[i - 1]);
  return acc;
}, []);

function inventarioStickyCell(colIdx, { header, bg }) {
  const edgeShadow =
    colIdx === 4 ? "6px 0 18px -10px rgba(15, 23, 42, 0.22)" : undefined;
  return {
    position: "sticky",
    left: INV_STICKY_LEFT[colIdx],
    width: INV_STICKY_COL_WIDTH[colIdx],
    minWidth: INV_STICKY_COL_WIDTH[colIdx],
    maxWidth: colIdx === 4 ? INV_STICKY_COL_WIDTH[colIdx] : undefined,
    boxSizing: "border-box",
    zIndex: header ? 35 + colIdx : 15 + colIdx,
    background: bg,
    boxShadow: edgeShadow,
  };
}

/** Cabeceras tabla inventario + tooltip para distinguir SKU Farmax vs ref. lista mayorista. */
const INV_COLUMN_HEADERS = [
  { id: "foto", label: "Foto", hint: "" },
  {
    id: "skuFarmax",
    label: "SKU Farmax",
    hint: "Identificador único en Farmax — campo productos.sku (POS, ticket, código interno).",
  },
  {
    id: "refLista",
    label: "Ref. lista mayorista",
    hint: "Número/código del Excel del distribuidor (pedidos). No repetir como segundo «SKU»: es solo referencia de lista.",
  },
  { id: "nombre", label: "Nombre", hint: "" },
  { id: "marca", label: "Marca", hint: "" },
  { id: "presentacion", label: "Presentación", hint: "" },
  { id: "principio", label: "Principio activo", hint: "" },
  { id: "ubicacion", label: "Ubicación", hint: "" },
  { id: "categoria", label: "Categoría", hint: "" },
  { id: "tipo", label: "Tipo", hint: "" },
  { id: "rubro", label: "Rubro", hint: "" },
  { id: "proveedor", label: "Proveedor", hint: "" },
  { id: "stock", label: "Stock", hint: "" },
  { id: "min", label: "Mín", hint: "" },
  { id: "precio", label: "Precio", hint: "" },
  { id: "costo", label: "Costo", hint: "" },
  { id: "margen", label: "Margen%", hint: "" },
  { id: "cad", label: "Cad. (días)", hint: "" },
  { id: "agot", label: "Agot. (días)", hint: "" },
  { id: "desc", label: "Desc%", hint: "" },
  { id: "estado", label: "Estado", hint: "" },
  { id: "acciones", label: "Acciones", hint: "" },
];

const descargarPlantilla = () => {
  const headers = [
    "SKU", "Nombre", "Categoria", "Tipo", "Stock", "Stock_Minimo",
    "Precio_Venta", "Costo", "Proveedor", "Lote", "Fecha_Caducidad",
    "Descuento_Porcentaje",
    "Marca_Comercial", "Principio_Activo", "Concentracion", "Presentacion",
    "Contenido_Caja", "Linea_Comercial", "Grupo_Farmacologico", "Jerarquia",
    "SKU_Casa_Saba", "Stock_Maximo", "Notas"
  ];
  const ejemplo = [
    ["FAR001","Paracetamol 500mg","Analgésico","generico","50","10","12.00","6.00","Casa Saba","L2024-01","2026-12-31","0",
     "ACETAFEN","Paracetamol","500MG","TABLETA","10 TABLETAS","ANALGESICOS","ANALGESICO/ANTIPIRETICO","MEDICAMENTOS","162","30",""],
    ["FAR002","Omeprazol 20mg","Gastro","generico","30","5","20.00","10.00","Marzam","L2024-02","2026-06-30","0",
     "OMEZOL","Omeprazol","20MG","CAPSULA","14 CAPSULAS","ESTOMACALES (GASTRO)","PROTECTOR GASTRICO","MEDICAMENTOS","523","15",""],
  ];
  const csv = [headers, ...ejemplo].map(r=>r.map(v=>`"${v}"`).join(",")).join("\n");
  const blob = new Blob(["\uFEFF"+csv],{type:"text/csv;charset=utf-8;"});
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href=url; a.download="plantilla_inventario_farmax.csv";
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

    rows.push({
      sku:           row.sku || null,
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
    });
  }
  return {ok:rows.length>0, msg:errores.length?`${errores.length} errores`:null, rows};
};

const exportarCSV = (productos) => {
  const headers = [
    "SKU", "Nombre", "Categoria", "Tipo", "Stock", "Stock_Minimo",
    "Precio_Venta", "Costo", "Proveedor", "Lote", "Fecha_Caducidad",
    "Descuento_Porcentaje",
    "Marca_Comercial", "Principio_Activo", "Concentracion", "Presentacion",
    "Contenido_Caja", "Linea_Comercial", "Grupo_Farmacologico", "Jerarquia",
    "SKU_Casa_Saba", "Margen_Porcentaje", "Stock_Maximo", "Notas"
  ];
  const rows = productos.map(p => [
    p.sku||"", p.nombre||"", p.categoria||"", p.tipo||"generico",
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
  a.download = `inventario_farmax_${new Date().toISOString().slice(0,10)}.csv`;
  a.click(); URL.revokeObjectURL(url);
};

function ProductoModal({initial, onClose, onSaved }) {
  const C = C_LIGHT;
  const inputStyle = mkInputStyle(C);
  const labelStyle = mkLabelStyle(C);
  const btnSecondary = mkBtnSecondary(C);
  const btnPrimary = mkBtnPrimary(C);
  const btnOutline = mkBtnOutline(C);
  const btnGreen = mkBtnGreen(C);
  const [form, setForm]     = useState(() => {
    const base = {
      ...(initial || EMPTY),
      imagen_url: (initial || EMPTY).imagen_url || "",
      imagen_mobile_url: (initial || EMPTY).imagen_mobile_url || "",
    };
    for (const k of ["nombre", "sku", "codigo_barras", "proveedor", "lote"]) {
      if (base[k] == null) base[k] = "";
    }
    return base;
  });
  const [errors, setErrors] = useState({});
  const [saving, setSaving] = useState(false);
  const set = (k, v) => setForm(f => ({ ...f, [k]: v }));
  const validate = () => {
    const e = {};
    if (!(form.nombre ?? "").trim())                           e.nombre       = "Requerido";
    if (!form.precio||parseFloat(form.precio)<=0) e.precio = "Debe ser mayor a $0";
    if (!form.costo||parseFloat(form.costo)<0)         e.costo        = "Debe ser 0 o mayor";
    if (form.stock === "" || form.stock === null)       e.stock        = "Requerido";
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
      const productoFields = {
        nombre: (form.nombre ?? "").trim(),
        sku: (form.sku ?? "").trim() || null,
        codigo_barras: form.codigo_barras?.trim() || null,
        categoria: form.categoria,
        precio: parseFloat(form.precio),
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
        ubicacion_texto: (form.ubicacion_texto ?? "").trim() || null,
        activo: form.activo,
        venta_unidad: form.venta_unidad || false,
        unidades_por_caja: form.venta_unidad ? parseInt(form.unidades_por_caja) || 0 : 0,
        precio_unidad: form.venta_unidad ? Math.ceil(parseFloat(form.precio_unidad) || 0) : 0,
        stock_unidades: form.venta_unidad ? parseInt(form.stock_unidades) || 0 : 0,
      };

      const sesion = leerSesion();
      await idEmpleadoUsuarios(sesion);

      const tok = sessionStorage.getItem("farmax_session_token");
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
                const t=sessionStorage.getItem("farmax_session_token");
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
            {field("SKU Farmax","sku")}
            {field("Código de barras","codigo_barras")}
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
            {field("Denominación genérica","denominacion_generica")}
            {field("Denominación distintiva / marca clínica","denominacion_distintiva")}
            {!form.id && field("Lote inicial","lote")}
            {!form.id && field("Fecha de caducidad (lote inicial)","fecha_caducidad","date")}
            {form.id && (
              <div style={{marginBottom:12,padding:"10px 12px",background:C.blueDim,borderRadius:8,fontSize:11,color:C.blue,lineHeight:1.5}}>
                💡 Lote y caducidad ahora viven en la tabla <strong>lotes</strong>.
                Para agregar un nuevo lote a este producto usa <strong>📦 Recibir mercancía</strong>.
              </div>
            )}
          </div>
          <div>
            {field("Precio de venta","precio","number",true)}
            {field("Costo","costo","number",true)}
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
              onChange={e=>set("venta_unidad",e.target.checked)} style={{width:16,height:16,cursor:"pointer"}}/>
            <label htmlFor="venta_unidad_chk" style={{...labelStyle,margin:0,cursor:"pointer",fontSize:13,fontWeight:700}}>
              💊 Permite venta por unidad suelta (caja abierta)
            </label>
          </div>
          {form.venta_unidad&&(
            <div style={{display:"grid",gridTemplateColumns:"1fr 1fr 1fr",gap:12,marginTop:12}}>
              <div>
                <label style={labelStyle}>Unidades por caja</label>
                <input type="number" min="1" value={form.unidades_por_caja}
                  onChange={e=>{ set("unidades_por_caja",e.target.value); const pv=parseFloat(form.precio)||0; const u=parseInt(e.target.value)||1; set("precio_unidad", Math.ceil(pv/u)); }}
                  style={inputStyle} placeholder="20"/>
              </div>
              <div>
                <label style={labelStyle}>Precio por unidad ($) <span style={{color:C.textDim,fontSize:9}}>AUTO↑</span></label>
                <input type="number" min="0" step="0.01" value={form.precio_unidad}
                  onChange={e=>set("precio_unidad",Math.ceil(parseFloat(e.target.value)||0))}
                  style={inputStyle} placeholder="3"/>
                <div style={{color:C.textDim,fontSize:9,marginTop:2}}>Se redondea hacia arriba (Math.ceil)</div>
              </div>
              <div>
                <label style={labelStyle}>Stock unidades sueltas</label>
                <input type="number" min="0" value={form.stock_unidades}
                  onChange={e=>set("stock_unidades",e.target.value)}
                  style={inputStyle} placeholder="0"/>
              </div>
              <div style={{gridColumn:"1/-1",background:C.blueDim,borderRadius:8,padding:"8px 12px",fontSize:11,color:C.blue}}>
                💡 SKU unidad: <strong>{(form.sku||"PROD")+"-UNIT"}</strong> · 
                Precio sugerido: <strong>${form.precio&&form.unidades_por_caja?Math.ceil(parseFloat(form.precio)/parseInt(form.unidades_por_caja)):"-"}</strong>/unidad
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

function RecibirModal({ productos, onClose, onSaved }) {
  const C = C_LIGHT;
  const inputStyle = mkInputStyle(C);
  const labelStyle = mkLabelStyle(C);
  const btnSecondary = mkBtnSecondary(C);
  const btnGreen = mkBtnGreen(C);
  const [busq,     setBusq]    = useState("");
  const [selId,    setSelId]   = useState("");
  const [cantidad, setCantidad]= useState("");
  const [lote,     setLote]    = useState("");
  const [caducidad,setCaduc]   = useState("");
  const [costo,    setCosto]   = useState("");
  const [proveedor,setProv]    = useState("");
  const [saving,   setSaving]  = useState(false);
  const [error,    setError]   = useState("");

  const prodsFilt = productos.filter(p => p.activo && inventarioProductMatchesBusqueda(p, busq));
  const selProd   = productos.find(p => p.id === parseInt(selId));

  const handleRecibir = async () => {
    if (!selId) { setError("Selecciona un producto"); return; }
    if (!cantidad || parseInt(cantidad) <= 0) { setError("Cantidad inválida"); return; }
    setSaving(true); setError("");
    const tok = sessionStorage.getItem("farmax_session_token");
    if (!tok) { setSaving(false); setError("Sesión expirada."); return; }
    const { error: err } = await supabase.rpc("receive_merchandise_secure", {
      p_session_token: tok,
      p_producto_id: selProd.id,
      p_cantidad: parseInt(cantidad),
      p_numero_lote: lote.trim() || null,
      p_fecha_caducidad: caducidad || null,
      p_costo_unitario: costo ? parseFloat(costo) : null,
      p_proveedor: proveedor.trim() || null,
    });
    setSaving(false);
    if (err) { setError("Error: " + err.message); return; }
    onSaved();
  };

  return (
    <div style={{position:"fixed",inset:0,background:"#00000099",zIndex:1000,display:"flex",alignItems:"center",justifyContent:"center"}}>
      <div style={{background:C.card,border:`1px solid ${C.borderHi}`,borderRadius:14,width:"min(520px,95vw)",maxHeight:"90vh",overflowY:"auto",padding:28,boxShadow:"0 24px 60px #00000088"}}>
        <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:20}}>
          <h2 style={{margin:0,color:C.text,fontSize:16,fontWeight:800}}>📦 Recibir mercancía</h2>
          <button onClick={onClose} style={{background:"none",border:"none",color:C.textMid,fontSize:20,cursor:"pointer"}}>✕</button>
        </div>
        <div style={{marginBottom:12}}>
          <label style={labelStyle}>Buscar producto <span style={{color:C.red}}>*</span></label>
          <input value={busq} onChange={e=>{setBusq(e.target.value);setSelId("");}}
            placeholder="Escribe nombre del producto…" style={inputStyle}/>
        </div>
        {busq && !selProd && (
          <div style={{background:C.bg,border:`1px solid ${C.border}`,borderRadius:8,marginBottom:12,maxHeight:160,overflowY:"auto"}}>
            {prodsFilt.length===0
              ? <div style={{padding:12,color:C.textMid,fontSize:12}}>Sin resultados</div>
              : prodsFilt.slice(0,8).map(p=>(
                  <div key={p.id} onClick={()=>{setSelId(String(p.id));setBusq(p.nombre);}}
                    style={{padding:"8px 12px",cursor:"pointer",color:C.text,fontSize:12,borderBottom:`1px solid ${C.border}`}}
                    onMouseEnter={e=>e.currentTarget.style.background=C.blueDim}
                    onMouseLeave={e=>e.currentTarget.style.background="transparent"}>
                    <strong>{p.nombre}</strong>
                    <span style={{color:C.textMid,marginLeft:8}}>Stock: <strong style={{color:C.amber}}>{p.stock}</strong></span>
                  </div>
                ))
            }
          </div>
        )}
        {selProd && (
          <div style={{background:C.blueDim,border:`1px solid ${C.blue}30`,borderRadius:8,padding:"10px 14px",marginBottom:16}}>
            <div style={{color:C.blue,fontWeight:700,fontSize:13}}>{selProd.nombre}</div>
            <div style={{color:C.textMid,fontSize:11,marginTop:4}}>
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
              <input type="number" value={cantidad} onChange={e=>setCantidad(e.target.value)} min="1" placeholder="0" style={inputStyle}/>
            </div>
            <div style={{marginBottom:12}}>
              <label style={labelStyle}>Nuevo lote</label>
              <input value={lote} onChange={e=>setLote(e.target.value)} placeholder="Ej. L-20250101" style={inputStyle}/>
            </div>
            <div style={{marginBottom:12}}>
              <label style={labelStyle}>Nueva fecha de caducidad</label>
              <input type="date" value={caducidad} onChange={e=>setCaduc(e.target.value)} style={inputStyle}/>
            </div>
          </div>
          <div>
            <div style={{marginBottom:12}}>
              <label style={labelStyle}>Nuevo costo unitario</label>
              <input type="number" value={costo} onChange={e=>setCosto(e.target.value)}
                placeholder={selProd?`Actual: $${selProd.costo}`:"$0.00"} style={inputStyle}/>
            </div>
            <div style={{marginBottom:12}}>
              <label style={labelStyle}>Proveedor</label>
              <input value={proveedor} onChange={e=>setProv(e.target.value)} placeholder="Nadro, Marzam…" style={inputStyle}/>
            </div>
            {selProd && cantidad && parseInt(cantidad)>0 && (
              <div style={{background:C.greenDim,border:`1px solid ${C.green}30`,borderRadius:8,padding:"10px 14px",marginTop:4}}>
                <div style={{color:C.textMid,fontSize:10,fontWeight:700}}>NUEVO STOCK</div>
                <div style={{color:C.green,fontWeight:800,fontSize:22}}>{(selProd.stock||0)+parseInt(cantidad)}</div>
                <div style={{color:C.textMid,fontSize:10}}>({selProd.stock} + {cantidad})</div>
              </div>
            )}
          </div>
        </div>
        {error && <div style={{color:C.red,fontSize:12,marginBottom:8}}>{error}</div>}
        <div style={{display:"flex",justifyContent:"flex-end",gap:10,marginTop:12}}>
          <button style={btnSecondary} onClick={onClose}>Cancelar</button>
          <button style={btnGreen} onClick={handleRecibir} disabled={saving||!selId||!cantidad}>
            {saving?"Guardando…":"📦 Recibir mercancía"}
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
    const tok = sessionStorage.getItem("farmax_session_token");
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
          boxShadow: "0 20px 60px rgba(0,82,204,.15)",
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

export default function InventarioModule() {
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
  const [modalImportar,   setModalImportar]   = useState(false);
  const [importando,      setImportando]      = useState(false);
  /** Progreso durante confirmarImport (RPC en lotes). */
  const [importProgress,  setImportProgress]  = useState(null);
  /** Si true: solo `create`; filas con SKU ya en catálogo se omiten (no actualiza). */
  const [importCsvSoloNuevos, setImportCsvSoloNuevos] = useState(false);
  const [importResult,    setImportResult]    = useState(null);
  const [paginaInv, setPaginaInv] = useState(1);
  const [modalLotes, setModalLotes] = useState(null);
  const [modalBulkImages, setModalBulkImages] = useState(false);
  const [selectedIds, setSelectedIds] = useState([]);
  const [modalBulkEdit, setModalBulkEdit] = useState(false);
  const headerSelectAllRef = useRef(null);
  const selectedSet = useMemo(() => new Set(selectedIds), [selectedIds]);

  const clearSelection = useCallback(() => setSelectedIds([]), []);
  const toggleSelectId = useCallback((id) => {
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
    const tok = sessionStorage.getItem("farmax_session_token");
    if (!tok) {
      setImportando(false);
      setImportProgress(null);
      showToast("Sesión expirada.", "error");
      return;
    }

    /** SKU → id para filas que ya existen (reimportar export no debe duplicar). */
    const skuList = [...new Set(rows.map((r) => (r.sku || "").trim()).filter(Boolean))];
    const skuToId = new Map();
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
        const existingId = skuKey ? skuToId.get(skuKey) : null;
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
          const { error: adjErr } = await supabase.rpc("adjust_stock_secure", {
            p_session_token: tok,
            p_producto_id: existingId,
            p_nuevo_stock: stockNum,
            p_motivo: "Import CSV — sincronizar stock",
          });
          if (adjErr) {
            console.error("Import ajuste stock:", adjErr);
            return "err";
          }
          return "upd";
        }

        const { data: respCreacion, error: rpcErr } = await supabase.rpc("create_producto_secure", {
          p_session_token: tok,
          p_producto_data: { ...resto, costo: costo ?? null, ...extrasPatch },
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
          `✅ ${created} producto(s) nuevo(s). ${skipped} fila(s) con SKU Farmax ya en catálogo (omitidas).`,
          created > 0 ? "success" : "info"
        );
      } else if (updated > 0 && created === 0) {
        showToast(`✅ ${updated} productos actualizados desde CSV (ya existían por SKU Farmax)`, "success");
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
    const tok = sessionStorage.getItem("farmax_session_token");
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
    let q = supabase.from("productos")
      .select("*, lotes(id,numero_lote,fecha_caducidad,cantidad_actual,costo_unitario,activo)")
      .order("nombre");
    if (!verInactivos) q = q.eq("activo", true);
    const { data, error } = await q;
    if (!error) {
      const enriched = (data || []).map(p => ({
        ...p,
        min_caducidad_lotes: minCaducidadLotes(p.lotes),
        lotes_activos: (p.lotes || []).filter(l => l.activo !== false && (l.cantidad_actual || 0) > 0),
      }));
      setProductos(enriched);
    }
    setLoading(false);
  }, [verInactivos]);

  useEffect(() => { fetchProductos(); }, [fetchProductos]);

  const poolSinBusqueda = useMemo(() => productos.filter(p => {
    const cat = filtroCategoria === "todas" || p.categoria === filtroCategoria;
    const dias = diasParaCaducar(p.min_caducidad_lotes);
    const alerta =
      filtroAlerta === "todos"       ? true :
      filtroAlerta === "bajo_stock"  ? (p.stock <= (p.stock_minimo??0)) :
      filtroAlerta === "por_caducar" ? (dias !== null && dias <= 30 && dias >= 0) : true;
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
  const porCaducar = productos.filter(p => { const d=diasParaCaducar(p.min_caducidad_lotes); return d!==null&&d<=30&&d>=0; }).length;
  const inactivos  = productos.filter(p => !p.activo).length;

  const desactivar = async (id) => {
    if (!window.confirm("¿Desactivar este producto?")) return;
    const tok = sessionStorage.getItem("farmax_session_token");
    const { error } = await supabase.rpc("admin_toggle_producto", {
      p_session_token: tok, p_producto_id: id, p_activo: false,
    });
    if (error) showToast("Error: "+error.message, "error");
    fetchProductos();
  };
  const reactivar = async (id) => {
    const tok = sessionStorage.getItem("farmax_session_token");
    const { error } = await supabase.rpc("admin_toggle_producto", {
      p_session_token: tok, p_producto_id: id, p_activo: true,
    });
    if (error) showToast("Error: "+error.message, "error");
    fetchProductos();
  };

  const aplicarEdicionLote = async (patch) => {
    const tok = sessionStorage.getItem("farmax_session_token");
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
    const tok = sessionStorage.getItem("farmax_session_token");
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
    const tok = sessionStorage.getItem("farmax_session_token");
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
    const tok = sessionStorage.getItem("farmax_session_token");
    if (!tok) {
      showToast("Sesión expirada.", "error");
      return;
    }
    const ids = [...selectedIds];
    if (!ids.length) return;
    if (
      !window.confirm(
        `¿Eliminar ${ids.length} producto(s)? Los que ya tuvieron ventas en el historial solo se desactivarán (no se borran del sistema).`
      )
    ) {
      return;
    }
    let ok = 0;
    let err = 0;
    for (const id of ids) {
      const { data: resp, error } = await supabase.rpc("admin_eliminar_producto", {
        p_session_token: tok,
        p_producto_id: id,
      });
      if (error || !resp?.success) err++;
      else ok++;
    }
    clearSelection();
    fetchProductos();
    if (err) {
      showToast(`Procesados ${ok} de ${ids.length}. ${err} error(es).`, err === ids.length ? "error" : "warning");
    } else {
      showToast(`✅ ${ok} producto(s) eliminado(s) o desactivado(s) según historial`, "success");
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

  return (
    <div style={{padding:24,background:C.bg,minHeight:"100vh",fontFamily:"'Plus Jakarta Sans',sans-serif"}}>

      <div style={{
        display:"flex",
        flexDirection:isMobileInv?"column":"row",
        justifyContent:"space-between",
        alignItems:isMobileInv?"stretch":"center",
        marginBottom:20,
        flexWrap:isMobileInv?"nowrap":"wrap",
        gap:12,
      }}>
        <div style={{ minWidth: 0 }}>
          <h1 style={{margin:0,color:C.text,fontSize:20,fontWeight:800}}>▤ Inventario</h1>
          <p style={{margin:"4px 0 0",color:C.textMid,fontSize:12}}>Gestión de productos · Farmax</p>
        </div>
        <div style={isMobileInv ? {
          display:"grid",
          gridTemplateColumns:"1fr 1fr",
          gap:8,
          width:"100%",
        } : { display:"flex", gap:8, flexWrap:"wrap" }}>
          <button data-tour="inv-agregar" style={{...btnPrimary, ...(isMobileInv ? { gridColumn:"1 / -1", padding:"11px 16px", fontSize:13 } : {})}} onClick={()=>setModal(EMPTY)}>
            ➕ Nuevo producto
          </button>
          <button style={btnOutline} onClick={()=>setModalRecibir(true)}>
            {isMobileInv ? "📦 Recibir" : "📦 Recibir mercancía"}
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
        </div>
      </div>

      <div style={{display:"flex",gap:12,marginBottom:20,flexWrap:"wrap"}}>
        {[
          {label:"Activos",     val:activos,    col:C.blue},
          {label:"Bajo stock",  val:bajoStock,  col:C.amber, click:()=>setFiltroAlerta("bajo_stock")},
          {label:"Por caducar", val:porCaducar, col:C.red,   click:()=>setFiltroAlerta("por_caducar")},
          {label:"Inactivos",   val:inactivos,  col:C.textMid},
        ].map(s=>(
          <div key={s.label} onClick={s.click} style={{
            background:C.card,border:`1px solid ${C.border}`,borderRadius:10,
            padding:"10px 18px",minWidth:110,cursor:s.click?"pointer":"default"}}
            onMouseEnter={e=>{if(s.click)e.currentTarget.style.border=`1px solid ${s.col}`;}}
            onMouseLeave={e=>{if(s.click)e.currentTarget.style.border=`1px solid ${C.border}`;}}>
            <div style={{color:s.col,fontWeight:800,fontSize:22}}>{s.val}</div>
            <div style={{color:C.textMid,fontSize:11}}>{s.label}</div>
          </div>
        ))}
      </div>

      <div data-tour="inv-buscar" style={{display:"flex",flexDirection:"column",gap:10,marginBottom:16}}>
        <SearchDropdown value={busqueda} onChange={setBusqueda} onSelect={p=>setBusqueda(p.nombre)} placeholder="🔍 Nombre, SKU Farmax, marca, principio, presentación…" items={productos} labelKey="nombre" subKey="sku" extraSearchKeys={["codigo_barras","categoria","principio_activo","denominacion_generica","denominacion_distintiva","marca","concentracion","presentacion","forma_farmaceutica","ubicacion_texto"]} badgeKey="stock" badgeCol="#0099e6" style={{width:"100%",maxWidth:"100%"}} emptyMsg="Sin productos"/>
        <div style={{display:"flex",gap:10,flexWrap:"wrap",alignItems:"center"}}>
        <select value={filtroCategoria} onChange={e=>setFiltroCategoria(e.target.value)} style={{...inputStyle,maxWidth:180}}>
          <option value="todas">Todas las categorías</option>
          {CATEGORIAS.map(c=><option key={c} value={c}>{c}</option>)}
        </select>
        <select value={filtroAlerta} onChange={e=>setFiltroAlerta(e.target.value)} style={{...inputStyle,maxWidth:180}}>
          <option value="todos">Todas las alertas</option>
          <option value="bajo_stock">⚠ Bajo stock</option>
          <option value="por_caducar">⏰ Por caducar (30d)</option>
        </select>
        <label style={{display:"flex",alignItems:"center",gap:7,cursor:"pointer",color:C.textMid,fontSize:12,fontWeight:600}}>
          <div onClick={()=>setVerInactivos(v=>!v)} style={{width:36,height:20,borderRadius:10,cursor:"pointer",
            background:verInactivos?C.blue:C.border,position:"relative",transition:"background .2s"}}>
            <div style={{position:"absolute",top:3,left:verInactivos?18:3,width:14,height:14,borderRadius:"50%",background:C.card,transition:"left .2s"}}/>
          </div>
          Ver inactivos
        </label>
        {(filtroCategoria!=="todas"||filtroAlerta!=="todos"||busqueda)&&(
          <button onClick={()=>{setFiltroCategoria("todas");setFiltroAlerta("todos");setBusqueda("");}}
            style={{...btnSecondary,padding:"7px 12px",fontSize:11}}>✕ Limpiar filtros</button>
        )}
        {filtrados.length > 0 && (
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
      </div>
      {spellHintsInv.length > 0 && (
        <div style={{
          marginBottom:14,padding:"10px 12px",borderRadius:10,
          background:"rgba(0,82,204,.08)",border:"1px solid rgba(0,82,204,.25)",
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

      {selectedIds.length > 0 && (
        <div
          style={{
            display: "flex",
            flexWrap: "wrap",
            gap: 8,
            alignItems: "center",
            marginBottom: 16,
            padding: "12px 14px",
            background: C.card,
            border: `1px solid rgba(0, 82, 204, 0.35)`,
            borderRadius: 10,
            position: "sticky",
            top: 0,
            zIndex: 6,
            boxShadow: "0 4px 20px rgba(15,23,42,.06)",
          }}
        >
          <span style={{ fontWeight: 800, color: C.text, marginRight: 4 }}>{selectedIds.length} seleccionados</span>
          <button type="button" style={{ ...btnOutline, padding: "8px 12px", fontSize: 12 }} onClick={() => setModalBulkEdit(true)}>
            ✏️ Editar en lote
          </button>
          <button type="button" style={{ ...btnOutline, padding: "8px 12px", fontSize: 12 }} onClick={abrirLotesSeleccion}>
            📦 Lotes
          </button>
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
          <button type="button" style={{ ...btnSecondary, padding: "8px 10px", fontSize: 11 }} onClick={clearSelection} title="Quitar selección">
            ✕
          </button>
        </div>
      )}

      {loading ? (
        <SkeletonTable rows={8} cols={12}/>
      ) : (
        <>
        <HorizontalScrollSync data-tour="inv-tabla">
          <table style={{width:"100%",minWidth:1780,borderCollapse:"collapse",fontSize:12}}>
            <thead>
              <tr style={{background:C.card}}>
                <th style={{
                  padding: "10px 8px",
                  textAlign: "center",
                  color: C.textMid,
                  fontWeight: 700,
                  borderBottom: `1px solid ${C.border}`,
                  verticalAlign: "middle",
                  ...inventarioStickyCell(0, { header: true, bg: C.card }),
                }}>
                  <input
                    ref={headerSelectAllRef}
                    type="checkbox"
                    checked={filtrados.length > 0 && filtrados.every((p) => selectedSet.has(p.id))}
                    onChange={toggleSelectAllOnPage}
                    aria-label="Seleccionar todos en esta página"
                    style={{ width: 16, height: 16, cursor: "pointer", accentColor: BRAND.primary }}
                  />
                </th>
                {INV_COLUMN_HEADERS.map((col, colIdx) => (
                  <th
                    key={col.id}
                    title={col.hint || undefined}
                    style={{
                      padding: "10px 12px",
                      textAlign: "left",
                      color: C.textMid,
                      fontWeight: 700,
                      borderBottom: `1px solid ${C.border}`,
                      whiteSpace: "nowrap",
                      cursor: col.hint ? "help" : undefined,
                      verticalAlign: "middle",
                      ...(colIdx <= 3 ? inventarioStickyCell(colIdx + 1, { header: true, bg: C.card }) : {}),
                    }}
                  >
                    {col.label}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {filtrados.length===0&&(
                <tr><td colSpan={23} style={{textAlign:"center",padding:32,color:C.textMid}}>
                  Sin productos{busqueda?` para "${busqueda}"`:""}. Agrega el primero con ➕
                </td></tr>
              )}
              {filtrados.map((p,_rowIdx)=>{
                const bajo    = p.activo && p.stock<=(p.stock_minimo??0);
                const inact   = !p.activo;
                const dias    = diasParaCaducar(p.min_caducidad_lotes);
                const nearCad = dias!==null && dias<=30 && dias>=0;
                const mgn     = margen(p.precio, p.costo);
                const mgnNum  = parseFloat(mgn);
                const mgnCol  = isNaN(mgnNum)?C.textMid:mgnNum>=30?C.green:mgnNum>=15?C.amber:C.red;
                const refListaProv = refListaMayoristaDesdeNotas(p.notas);
                const rubroCompras = rubroComprasDesdeNotas(p.notas);
                const marcaDisp = (p.marca || "").trim();
                const presDisp = (p.presentacion || "").trim();
                const provDisp = (p.proveedor || "").trim();
                const principioDisp = [p.principio_activo, p.denominacion_generica, p.concentracion].filter(Boolean).join(" · ");
                const stickyRowBg = bajo ? C.amberDim : nearCad ? C.redDim : C.bg;
                return (
                  <tr key={p.id} className="farmax-table-row" style={{opacity:inact?0.45:1,background:bajo?C.amberDim:nearCad?C.redDim:"transparent"}}>
                    <td style={{
                      padding: "6px 8px",
                      borderBottom: `1px solid ${C.border}`,
                      textAlign: "center",
                      verticalAlign: "middle",
                      ...inventarioStickyCell(0, { header: false, bg: stickyRowBg }),
                    }}>
                      <input
                        type="checkbox"
                        checked={selectedSet.has(p.id)}
                        onChange={() => toggleSelectId(p.id)}
                        aria-label={`Seleccionar ${p.nombre}`}
                        style={{ width: 16, height: 16, cursor: "pointer", accentColor: BRAND.primary }}
                      />
                    </td>
                    <td style={{
                      padding: "6px 10px",
                      borderBottom: `1px solid ${C.border}`,
                      verticalAlign: "middle",
                      ...inventarioStickyCell(1, { header: false, bg: stickyRowBg }),
                    }}>
                      <div style={{
                        width:40,height:40,borderRadius:6,
                        background:p.imagen_url?`url(${p.imagen_url}) center/cover`:C.bg,
                        border:`1px solid ${C.border}`,
                        display:"flex",alignItems:"center",justifyContent:"center",fontSize:16,
                      }}>{!p.imagen_url?"📷":null}</div>
                    </td>
                    <td style={{
                      padding: "8px 12px",
                      color: C.textMid,
                      borderBottom: `1px solid ${C.border}`,
                      fontFamily: "ui-monospace,Menlo,monospace",
                      fontSize: 11,
                      verticalAlign: "middle",
                      ...inventarioStickyCell(2, { header: false, bg: stickyRowBg }),
                    }}>{p.sku||"—"}</td>
                    <td style={{
                      padding: "8px 12px",
                      color: C.textMid,
                      borderBottom: `1px solid ${C.border}`,
                      fontFamily: "ui-monospace,Menlo,monospace",
                      fontSize: 11,
                      verticalAlign: "middle",
                      ...inventarioStickyCell(3, { header: false, bg: stickyRowBg }),
                    }} title={refListaProv || undefined}>
                      <span style={tdEllipsisStyle}>{refListaProv || "—"}</span>
                    </td>
                    <td style={{
                      padding: "8px 12px",
                      color: inact ? C.textDim : C.text,
                      fontWeight: 600,
                      borderBottom: `1px solid ${C.border}`,
                      verticalAlign: "middle",
                      ...inventarioStickyCell(4, { header: false, bg: stickyRowBg }),
                    }} title={p.nombre}>
                      <span style={{...tdEllipsisStyle,whiteSpace:"normal",display:"-webkit-box",WebkitLineClamp:2,WebkitBoxOrient:"vertical",overflow:"hidden"}}>{p.nombre}</span>
                    </td>
                    <td style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`,maxWidth:130}} title={marcaDisp || undefined}>
                      <span style={tdEllipsisStyle}>{marcaDisp || "—"}</span>
                    </td>
                    <td style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`,maxWidth:160}} title={presDisp || undefined}>
                      <span style={tdEllipsisStyle}>{presDisp || "—"}</span>
                    </td>
                    <td style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`,maxWidth:200}} title={principioDisp || undefined}>
                      <span style={tdEllipsisStyle}>{principioDisp || "—"}</span>
                    </td>
                    <td style={{padding:"8px 12px",color:C.text,borderBottom:`1px solid ${C.border}`,maxWidth:180}}>
                      <span style={{fontSize:11,fontWeight:700,color:p.ubicacion_texto ? C.blue : C.textDim}}>
                        {p.ubicacion_texto || "Sin ubicación"}
                      </span>
                    </td>
                    <td style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{p.categoria}</td>
                    <td style={{padding:"8px 12px",borderBottom:`1px solid ${C.border}`}}>
                      <span style={{padding:"2px 8px",borderRadius:20,fontSize:10,fontWeight:700,
                        background:p.tipo==="marca"?"#9d6fff18":C.blueDim,color:p.tipo==="marca"?"#9d6fff":C.blue}}>{p.tipo}</span>
                    </td>
                    <td style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`,maxWidth:180}} title={rubroCompras || undefined}>
                      <span style={tdEllipsisStyle}>{rubroCompras || "—"}</span>
                    </td>
                    <td style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`,maxWidth:140}} title={provDisp || undefined}>
                      <span style={tdEllipsisStyle}>{provDisp || "—"}</span>
                    </td>
                    <td style={{padding:"8px 12px",fontWeight:700,borderBottom:`1px solid ${C.border}`,color:bajo?C.amber:C.green}}>{p.stock}</td>
                    <td style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{p.stock_minimo??0}</td>
                    <td style={{padding:"8px 12px",color:C.text,borderBottom:`1px solid ${C.border}`}}>${parseFloat(p.precio||0).toFixed(2)}</td>
                    <td style={{padding:"8px 12px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>${parseFloat(p.costo||0).toFixed(2)}</td>
                    <td style={{padding:"8px 12px",fontWeight:700,borderBottom:`1px solid ${C.border}`,color:mgnCol}}>{mgn}</td>
                    <td style={{padding:"8px 12px",borderBottom:`1px solid ${C.border}`,whiteSpace:"nowrap"}}>
                      {dias===null?"—":(
                        <span style={{color:nearCad?C.red:dias<=60?C.amber:C.textMid,fontWeight:nearCad?700:400}}>
                          {dias<0?"Vencido":dias===0?"Hoy":dias+" d"}
                        </span>
                      )}
                    </td>
                    <td style={{padding:"8px 12px",borderBottom:`1px solid ${C.border}`}}>
                      {(()=>{
                        if(!p.stock||!p.stock_minimo) return "—";
                        const ventaDiaria = Math.max(p.stock_minimo*0.15,0.5);
                        const diasAgot = Math.floor(p.stock/ventaDiaria);
                        const col = diasAgot<7?C.red:diasAgot<15?C.amber:C.green;
                        return <span style={{color:col,fontWeight:700,fontSize:11}}>~{diasAgot}d</span>;
                      })()}
                    </td>
                    <td style={{padding:"8px 12px",borderBottom:`1px solid ${C.border}`}}>
                      {p.descuento_pct>0?<span style={{color:C.amber,fontWeight:700}}>{p.descuento_pct}%</span>:"—"}
                    </td>
                    <td style={{padding:"8px 12px",borderBottom:`1px solid ${C.border}`}}>
                      <span style={{padding:"2px 8px",borderRadius:20,fontSize:10,fontWeight:700,
                        background:p.activo?C.greenDim:C.redDim,color:p.activo?C.green:C.red}}>
                        {p.activo?"Activo":"Inactivo"}</span>
                    </td>
                    <td style={{padding:"8px 12px",borderBottom:`1px solid ${C.border}`,whiteSpace:"nowrap"}}>
                      <button onClick={()=>setModal(p)} style={{background:C.blueDim,border:`1px solid ${C.blue}30`,
                        color:C.blue,borderRadius:6,padding:"4px 10px",cursor:"pointer",fontSize:11,fontWeight:700,marginRight:6}}>
                        ✏️ Editar</button>
                      <button onClick={()=>setModalLotes(p)} style={{background:"#f1f5f9",border:`1px solid ${C.border}`,
                        color:C.textMid,borderRadius:6,padding:"4px 10px",cursor:"pointer",fontSize:11,fontWeight:700,marginRight:6}}>
                        📦 Lotes ({(p.lotes_activos||[]).length})</button>
                      {p.min_caducidad_lotes && diasParaCaducar(p.min_caducidad_lotes)<=30 && diasParaCaducar(p.min_caducidad_lotes)>=0 && (
                        <button onClick={()=>liquidar(p)}
                          style={{...btnSecondary,padding:"5px 10px",fontSize:10,color:C.red,borderColor:C.red,background:C.redDim,marginLeft:4}}>
                          🏷️ Liquidar
                        </button>
                      )}
                      {p.activo?(
                        <button onClick={()=>desactivar(p.id)} style={{background:C.redDim,border:`1px solid ${C.red}30`,
                          color:C.red,borderRadius:6,padding:"4px 10px",cursor:"pointer",fontSize:11,fontWeight:700}}>
                          🔴 Desactivar</button>
                      ):(
                        <button onClick={()=>reactivar(p.id)} style={{background:C.greenDim,border:`1px solid ${C.green}30`,
                          color:C.green,borderRadius:6,padding:"4px 10px",cursor:"pointer",fontSize:11,fontWeight:700}}>
                          ✅ Reactivar</button>
                      )}
                    </td>
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

      {modal!==null&&(
        <ProductoModal key={modal.id ?? "nuevo"} initial={modal} onClose={()=>setModal(null)}
          onSaved={()=>{setModal(null);fetchProductos();}}/>
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
          <div style={{background:C.card,borderRadius:14,width:"min(720px,95vw)",maxHeight:"85vh",overflowY:"auto",padding:24,boxShadow:"0 20px 60px rgba(0,82,204,.15)"}}>
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
            {(modalLotes.lotes_activos||[]).length===0 ? (
              <div style={{textAlign:"center",padding:40,color:C.textMid,fontSize:13}}>
                Este producto no tiene lotes activos. Usa <strong>📦 Recibir mercancía</strong> para agregar uno.
              </div>
            ) : (
              <table style={{width:"100%",borderCollapse:"collapse",fontSize:12}}>
                <thead>
                  <tr style={{background:C.cardDark}}>
                    {["Lote","Caducidad","Días","Cantidad","Costo unit."].map(h=>(
                      <th key={h} style={{padding:"8px 12px",textAlign:"left",color:C.textMid,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{h}</th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {(modalLotes.lotes_activos||[])
                    .slice()
                    .sort((a,b)=>{
                      if(!a.fecha_caducidad) return 1;
                      if(!b.fecha_caducidad) return -1;
                      return a.fecha_caducidad.localeCompare(b.fecha_caducidad);
                    })
                    .map((l,i)=>{
                      const dias = diasParaCaducar(l.fecha_caducidad);
                      const col  = dias===null?C.textMid:dias<0?C.red:dias<=15?C.red:dias<=30?C.amber:C.green;
                      return (
                        <tr key={l.id} style={{background:i%2===0?"transparent":"#f8fafc"}}>
                          <td style={{padding:"8px 12px",color:C.text,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{l.numero_lote||"—"}</td>
                          <td style={{padding:"8px 12px",color:col,fontWeight:600,borderBottom:`1px solid ${C.border}`}}>{l.fecha_caducidad||"—"}</td>
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
            )}
          </div>
        </div>
      )}
      {modalRecibir&&(
        <RecibirModal productos={productos} onClose={()=>setModalRecibir(false)}
          onSaved={()=>{setModalRecibir(false);fetchProductos();}}/>
      )}

      {/* Modal Importar CSV */}
      {modalImportar&&(
        <div style={{position:"fixed",inset:0,background:"rgba(15,23,42,.45)",backdropFilter:"blur(4px)",zIndex:1000,display:"flex",alignItems:"center",justifyContent:"center",padding:20}}
          onClick={(e)=>{
            if (importando) return;
            if (e.target===e.currentTarget) { setModalImportar(false); setImportResult(null); setImportProgress(null); setImportCsvSoloNuevos(false); }
          }}>
          <div style={{background:C.card,borderRadius:14,width:"min(580px,95vw)",maxHeight:"90vh",overflowY:"auto",padding:28,boxShadow:"0 20px 60px rgba(0,82,204,.15)"}}>
            <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:20}}>
              <h2 style={{margin:0,color:C.text,fontSize:16,fontWeight:800}}>📥 Importar productos desde CSV</h2>
              <button onClick={()=>{setModalImportar(false);setImportResult(null);setImportProgress(null);setImportCsvSoloNuevos(false);}} style={{background:"none",border:"none",color:C.textMid,fontSize:22,cursor:"pointer"}}>✕</button>
            </div>
            <div style={{background:"#eff6ff",border:"1px solid #bfdbfe",borderRadius:10,padding:14,marginBottom:16}}>
              <div style={{color:"#1d4ed8",fontWeight:700,fontSize:13,marginBottom:8}}>📋 Instrucciones</div>
              <ol style={{color:"#1d4ed8",fontSize:12,paddingLeft:18,lineHeight:1.8,margin:0}}>
                <li>Descarga la plantilla con el botón de abajo</li>
                <li>Ábrela en Excel o Google Sheets</li>
                <li>Agrega tus productos (una fila por producto)</li>
                <li>Guarda como CSV (separado por comas)</li>
                <li>Sube el archivo aquí</li>
                <li style={{marginTop:6}}><strong>SKU Farmax</strong> (columna «SKU» del CSV): debe coincidir con <code>productos.sku</code> para fusionar o omitir duplicados en “solo nuevos”.</li>
              </ol>
            </div>
            <button onClick={descargarPlantilla} style={{width:"100%",padding:"10px",borderRadius:8,border:"1px solid #0052cc",background:"#eff6ff",color:"#0052cc",fontWeight:700,fontSize:13,cursor:"pointer",marginBottom:16,display:"flex",alignItems:"center",justifyContent:"center",gap:8}}>
              📋 Descargar plantilla Excel/CSV
            </button>
            <div style={{border:"2px dashed #e2e8f0",borderRadius:10,padding:24,textAlign:"center",marginBottom:16,cursor:"pointer",background:C.cardDark}}
              onClick={()=>document.getElementById("csv_input").click()}
              onDragOver={e=>{e.preventDefault();e.currentTarget.style.borderColor="#0052cc";}}
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
                    <div style={{maxHeight:200,overflowY:"auto",border:`1px solid ${C.border}`,borderRadius:8,marginBottom:16}}>
                      <table style={{width:"100%",borderCollapse:"collapse",fontSize:11}}>
                        <thead><tr style={{background:C.cardDark}}>
                          {["Nombre","SKU Farmax","Categoría","Stock","Precio","Caducidad"].map(h=><th key={h} style={{padding:"6px 10px",textAlign:"left",color:C.textMid,fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{h}</th>)}
                        </tr></thead>
                        <tbody>
                          {importResult.rows.slice(0,20).map((r,i)=>(
                            <tr key={i} style={{background:i%2===0?"transparent":"#f8fafc"}}>
                              <td style={{padding:"5px 10px",color:C.text,fontWeight:600,borderBottom:`1px solid ${C.border}`}}>{r.nombre}</td>
                              <td style={{padding:"5px 10px",color:C.textMid,borderBottom:`1px solid ${C.border}`,fontFamily:"monospace"}}>{r.sku||"—"}</td>
                              <td style={{padding:"5px 10px",color:C.textMid,borderBottom:`1px solid ${C.border}`}}>{r.categoria}</td>
                              <td style={{padding:"5px 10px",color:"#0099e6",fontWeight:700,borderBottom:`1px solid ${C.border}`}}>{r.stock}</td>
                              <td style={{padding:"5px 10px",color:"#00c46a",fontWeight:700,borderBottom:`1px solid ${C.border}`}}>${r.precio}</td>
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
                        <strong>Solo productos nuevos</strong> — solo dan de alta filas cuyo <strong>SKU Farmax</strong> <em>aún no</em> está en el catálogo. Las que ya existen se omiten (no cambian precio ni stock).
                        <span style={{display:"block",color:C.textMid,fontSize:11,marginTop:4}}>
                          Desmarcado: fusionar lista — crea nuevos y actualiza precio/stock de los que ya tenían ese SKU Farmax.
                        </span>
                      </span>
                    </label>
                    <button onClick={confirmarImport} disabled={importando}
                      style={{width:"100%",padding:"12px",borderRadius:8,border:"none",background:"linear-gradient(135deg,#0052cc,#0099e6)",color:"#fff",fontWeight:700,fontSize:14,cursor:"pointer",opacity: importando ? 0.85 : 1}}>
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
