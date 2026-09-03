'use strict';

const FECHA = '2026-08-14';
const CONF = { alta: 85, media: 75, dudoso: 60 };
const BATCHES = [{"fuente":"fahorro","tipo":"venta","archivo":"import_fahorro_listo.csv","rows":[{"sku":"FC-02012468","precio":"125.0"},{"sku":"FC-06134531","precio":"113.0"},{"sku":"FC-08895196","precio":"43.0"},{"sku":"FC-09419324","precio":"79.0"},{"sku":"FC-11294615","precio":"55.0"},{"sku":"FC-2005DD57","precio":"253.0"},{"sku":"FC-22105207","precio":"30.0"},{"sku":"FC-22150801","precio":"32.5"},{"sku":"FC-25104411","precio":"25.0"},{"sku":"FC-25149221","precio":"25.0"},{"sku":"FC-31887928","precio":"97.0"},{"sku":"FC-33954740","precio":"34.5"},{"sku":"FC-357D4A17","precio":"261.0"},{"sku":"FC-3B001F9B","precio":"282.0"},{"sku":"FC-3CAA7C5C","precio":"77.0"},{"sku":"FC-405A75E3","precio":"432.0"},{"sku":"FC-41339950","precio":"236.0"},{"sku":"FC-51448511","precio":"25.0"},{"sku":"FC-53506FA4","precio":"102.0"},{"sku":"FC-5BC5F234","precio":"67.0"},{"sku":"FC-60F627D5","precio":"45.5"},{"sku":"FC-65095718","precio":"199.0"},{"sku":"FC-6519183A","precio":"143.0"},{"sku":"FC-74A5ABEE","precio":"239.0"},{"sku":"FC-75354321","precio":"118.0"},{"sku":"FC-7D1D9857","precio":"32.5"},{"sku":"FC-7F90064A","precio":"85.0"},{"sku":"FC-82F88FED","precio":"58.0"},{"sku":"FC-84973401","precio":"227.0"},{"sku":"FC-885F2723","precio":"80.0"},{"sku":"FC-9A4E4C31","precio":"135.0"},{"sku":"FC-A2B284E0","precio":"423.0"},{"sku":"FC-ACA2A2F6","precio":"133.0"},{"sku":"FC-BDB2E087","precio":"400.0"},{"sku":"FC-C101D5B1","precio":"366.0"},{"sku":"FC-C721E8D7","precio":"158.0"},{"sku":"FC-C9F4ACCC","precio":"151.0"},{"sku":"FC-D06E54FE","precio":"143.0"},{"sku":"FC-D9391288","precio":"212.0"},{"sku":"FC-DEAF33B0","precio":"87.0"},{"sku":"FC-E4BE37BE","precio":"217.0"},{"sku":"FC-E4EFC4C2","precio":"266.0"},{"sku":"FC-E6B50AC3","precio":"457.0"},{"sku":"FC-EADF1484","precio":"364.0"},{"sku":"FC-F4E9C71F","precio":"102.0"},{"sku":"FC-FD845E68","precio":"334.0"}]},{"fuente":"exprezo","tipo":"compra","archivo":"import_exprezo_listo.csv","rows":[{"sku":"FC-01157296","precio":"12.95"},{"sku":"FC-01405335","precio":"21.25"},{"sku":"FC-06257597","precio":"71.49"},{"sku":"FC-07528939","precio":"38.99"},{"sku":"FC-08443026","precio":"267.68"},{"sku":"FC-08485316","precio":"70.6"},{"sku":"FC-14982514","precio":"33.5"},{"sku":"FC-19006371","precio":"16.84"},{"sku":"FC-19006623","precio":"20.11"},{"sku":"FC-22150221","precio":"21.94"},{"sku":"FC-25104411","precio":"19.17"},{"sku":"FC-25149221","precio":"19.17"},{"sku":"FC-31244486","precio":"38.99"},{"sku":"FC-35469151","precio":"42.49"},{"sku":"FC-36033735","precio":"69.73"},{"sku":"FC-40013898","precio":"34.66"},{"sku":"FC-46073040","precio":"15.53"},{"sku":"FC-51448511","precio":"19.17"},{"sku":"FC-56330309","precio":"79.19"},{"sku":"FC-60009851","precio":"24.94"},{"sku":"FC-60403681","precio":"72.37"},{"sku":"FC-60689091","precio":"16.96"},{"sku":"FC-66534951","precio":"20.58"},{"sku":"FC-68901131","precio":"36.9"},{"sku":"FC-70612368","precio":"142.24"},{"sku":"FC-73629981","precio":"31.73"},{"sku":"FC-83510531","precio":"13.0"},{"sku":"FC-92506601","precio":"18.84"},{"sku":"FC-95451096","precio":"156.0"},{"sku":"FC-DE106642","precio":"18.21"}]},{"fuente":"similares","tipo":"venta","archivo":"import_similares_lote1_listo.csv","rows":[{"sku":"FC-08496701","precio":"36.38","confianza_match":"alta","notas":"ACIDO ACETILSALICILICO 500MG 12 TABLETAS EFERVESCENTES ASPIRINA -- coincidencia exacta de marca, mg y cantidad."},{"sku":"FC-48F732CF","precio":"46.5","confianza_match":"dudoso","notas":"Similares solo tiene ERITROMICINA 500MG en TABLETAS (20), tu presentacion original es CAPSULAS (EPICIN 20 CAPS 500 MG). Misma mg y cantidad pero forma farmaceutica distinta."},{"sku":"FC-516C2E89","precio":"48.0","confianza_match":"alta","notas":"AMOXICILINA/ACIDO CLAVULANICO 400/57 SUSPENSION 50-60 ML -- coincide concentracion exacta (recuperada del inventario original: CLAMOXIN 12H JR 1 SUSP 400/57MG/5/50ML)."},{"sku":"FC-54521161","precio":"6.0","confianza_match":"media","notas":"Tempra 500mg C/10 no esta como marca en Similares; se usa el generico PARACETAMOL 500 MG 10 TABLETAS (PICK UP), misma concentracion y cantidad exacta."},{"sku":"FC-5D9DFA3D","precio":"59.25","confianza_match":"media","notas":"Norquinol = marca de Norfloxacino. Match generico: NORFLOXACINO 400 MG 20 TABLETAS, misma concentracion y cantidad."},{"sku":"FC-8FB65B79","precio":"124.5","confianza_match":"dudoso","notas":"CLARITROMICINA 250MG/5ML SUSPENSION -- el catalogo no especifica volumen del frasco (dice '1 pieza'), no se puede confirmar si son los 60ml de tu presentacion."},{"sku":"FC-A0D320D1","precio":"29.25","confianza_match":"alta","notas":"AMOXICILINA 500 MG 12 CAPSULAS -- coincidencia exacta."},{"sku":"FC-CF18C740","precio":"90.0","confianza_match":"alta","notas":"CLINDAMICINA 300 MG 16 CAPSULAS -- coincidencia exacta."},{"sku":"FC-DDFBABDF","precio":"24.75","confianza_match":"alta","notas":"AMOXICILINA/ACIDO CLAVULANICO 200/28.5MG SUSPENSION 40 O 50 ML -- coincide concentracion exacta (recuperada del inventario original: CLAMOXIN 12H PED 1 SUSP 200/28.5MG/40ML)."}],"withNotas":true}];

async function fetchSkuIndex(url, key) {
  const headers = { apikey: key, Authorization: 'Bearer ' + key };
  const map = {};
  let offset = 0;
  while (true) {
    const r = await fetch(
      url + '/rest/v1/productos?select=id,sku&activo=eq.true&order=id.asc',
      { headers: { ...headers, Range: offset + '-' + (offset + 499) } }
    );
    if (!r.ok) throw new Error('productos ' + r.status);
    const batch = await r.json();
    for (const p of batch) { if (p.sku) map[p.sku] = p.id; }
    if (batch.length < 500) break;
    offset += 500;
  }
  return map;
}

async function applyBatch(url, key, skuIdx, batch) {
  const headers = {
    apikey: key,
    Authorization: 'Bearer ' + key,
    'Content-Type': 'application/json',
    Prefer: 'return=representation',
  };
  const matched = [];
  for (const row of batch.rows) {
    const sku = row.sku;
    const precio = parseFloat(String(row.precio || '').replace(/[$,]/g, ''));
    if (!sku || !Number.isFinite(precio)) continue;
    const pid = skuIdx[sku];
    if (!pid) continue;
    const confRaw = row.confianza_match || row.confianza || 'alta';
    const confianza = CONF[String(confRaw).toLowerCase()] || (Number(confRaw) || 85);
    matched.push({ producto_id: pid, precio, confianza, notas: row.notas || null });
  }
  if (!matched.length) return { fuente: batch.fuente, inserted: 0 };

  const impRes = await fetch(url + '/rest/v1/importaciones_referencia', {
    method: 'POST', headers,
    body: JSON.stringify({
      fuente: batch.fuente, tipo: batch.tipo, fecha_lista: FECHA,
      archivo: batch.archivo, filas_ok: matched.length, filas_error: 0,
      notas: 'bootstrap-referencias',
    }),
  });
  if (!impRes.ok) throw new Error('import ' + batch.fuente + ': ' + impRes.status + ' ' + (await impRes.text()).slice(0, 200));
  const importId = (await impRes.json())[0].id;

  const payload = matched.map((m) => ({
    producto_id: m.producto_id, fuente: batch.fuente, tipo: batch.tipo,
    precio: m.precio, fecha: FECHA, origen: 'import_csv', import_id: importId,
    confianza: m.confianza,
    ...(batch.withNotas && m.notas ? { notas: m.notas } : {}),
  }));

  for (let i = 0; i < payload.length; i += 100) {
    const chunk = payload.slice(i, i + 100);
    const r = await fetch(url + '/rest/v1/producto_precios_referencia', {
      method: 'POST', headers, body: JSON.stringify(chunk),
    });
    if (!r.ok) throw new Error('insert ' + batch.fuente + ': ' + r.status + ' ' + (await r.text()).slice(0, 200));
  }
  return { fuente: batch.fuente, inserted: matched.length };
}

async function runBootstrapReferencias(supabaseUrl, serviceKey, { force = false } = {}) {
  const countRes = await fetch(supabaseUrl + '/rest/v1/producto_precios_referencia?select=id&limit=1', {
    headers: { apikey: serviceKey, Authorization: 'Bearer ' + serviceKey, Prefer: 'count=exact' },
  });
  const existing = countRes.headers.get('content-range');
  const already = existing && !existing.endsWith('/0');
  if (already && !force) {
    return { ok: true, skipped: true, message: 'Ya hay referencias cargadas', content_range: existing };
  }
  const skuIdx = await fetchSkuIndex(supabaseUrl, serviceKey);
  const results = [];
  for (const b of BATCHES) results.push(await applyBatch(supabaseUrl, serviceKey, skuIdx, b));
  const total = results.reduce((s, r) => s + r.inserted, 0);
  return { ok: true, total, results, fecha: FECHA };
}

module.exports = { runBootstrapReferencias };
