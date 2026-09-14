import { Box, Btn, Tag } from "../../ui";
import { C_LIGHT, BRAND } from "../../constants";
import { lineasRecetaParaMostrador } from "../../utils/recetaDisponibilidad";

const C = C_LIGHT;

/**
 * Cola de recetas del consultorio en mostrador: imprimir carta en Brother y surtir.
 */
export default function RecetaColaMostrador({
  recetas = [],
  onImprimir,
  onSurtir,
  imprimiendoId,
  compact = false,
  onVerTodas,
}) {
  if (!recetas.length) return null;

  const pendientesPrint = recetas.filter((r) => r.estado !== "impresa").length;

  if (compact) {
    return (
      <Box
        style={{
          padding: "12px 14px",
          marginBottom: 14,
          border: `1px solid ${C.green}45`,
          background: C.greenDim,
        }}
      >
        <div style={{ display: "flex", justifyContent: "space-between", gap: 10, flexWrap: "wrap", alignItems: "center" }}>
          <div>
            <div style={{ color: C.text, fontWeight: 800, fontSize: 13 }}>
              {recetas.length === 1
                ? "1 receta del consultorio"
                : `${recetas.length} recetas del consultorio`}
              {pendientesPrint ? ` · ${pendientesPrint} por imprimir en Brother` : " · ya impresas, surtir"}
            </div>
            <div style={{ color: C.textMid, fontSize: 11, marginTop: 3, lineHeight: 1.4 }}>
              La doctora ya mandó la receta. Imprime carta en la Brother y surte en el carrito.
            </div>
          </div>
          <Btn sm col={BRAND.primary} onClick={onVerTodas}>
            Ver recetas
          </Btn>
        </div>
      </Box>
    );
  }

  return (
    <Box
      style={{
        padding: 16,
        marginBottom: 16,
        border: `1px solid ${C.green}40`,
        background: C.greenDim,
      }}
    >
      <div style={{ color: C.text, fontWeight: 800, fontSize: 14, marginBottom: 4 }}>
        Recetas del consultorio
      </div>
      <div style={{ color: C.textMid, fontSize: 12, marginBottom: 12, lineHeight: 1.45 }}>
        Llegan del 2.º piso cuando la doctora toca <strong>Enviar a mostrador</strong>.
        Primero imprime en la <strong>Brother</strong> (hoja carta, no el ticket Epson). Luego surte: se cargan al carrito las piezas que sí vendemos.
      </div>
      {recetas.map((rxRow) => {
        const lineas = lineasRecetaParaMostrador(rxRow.medicamentos);
        const impresa = rxRow.estado === "impresa";
        return (
          <div
            key={rxRow.id}
            style={{
              padding: "12px 0",
              borderTop: `1px solid ${C.border}`,
            }}
          >
            <div style={{ display: "flex", justifyContent: "space-between", gap: 10, flexWrap: "wrap", alignItems: "flex-start" }}>
              <div style={{ minWidth: 0, flex: "1 1 220px" }}>
                <div style={{ fontWeight: 800, color: C.text, display: "flex", gap: 8, flexWrap: "wrap", alignItems: "center" }}>
                  {rxRow.folio} · {rxRow.paciente_nombre || "Paciente"}
                  <Tag col={impresa ? C.blue : C.amber} sm>
                    {impresa ? "Impresa · surtir" : "Por imprimir en Brother"}
                  </Tag>
                </div>
                <div style={{ fontSize: 12, color: C.textMid, marginTop: 3 }}>
                  {rxRow.medico_nombre || "Médico"}
                  {rxRow.paciente_telefono ? ` · ${rxRow.paciente_telefono}` : ""}
                </div>
                <div style={{ marginTop: 8, display: "flex", flexDirection: "column", gap: 6 }}>
                  {lineas.map((ln) => (
                    <div key={ln.key} style={{ fontSize: 12, color: C.text, lineHeight: 1.4 }}>
                      <strong>
                        {ln.nombre}
                        {ln.cantidad > 1 ? ` ×${ln.cantidad}` : ""}
                      </strong>
                      {ln.libre ? (
                        <span style={{ color: C.textMid, fontWeight: 600 }}> · no lo vendemos (línea libre)</span>
                      ) : null}
                      {ln.posologia ? (
                        <div style={{ color: C.textMid, fontSize: 11 }}>{ln.posologia}</div>
                      ) : null}
                    </div>
                  ))}
                  {!lineas.length ? (
                    <div style={{ fontSize: 11, color: C.textDim, fontStyle: "italic" }}>Sin renglones</div>
                  ) : null}
                </div>
              </div>
              <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
                <Btn
                  sm
                  ol
                  col={BRAND.primary}
                  dis={imprimiendoId === rxRow.id}
                  onClick={() => onImprimir?.(rxRow)}
                >
                  {impresa ? "Reimprimir Brother" : "Imprimir en Brother"}
                </Btn>
                <Btn sm col={C.green} onClick={() => onSurtir?.(rxRow)}>
                  Surtir en mostrador
                </Btn>
              </div>
            </div>
          </div>
        );
      })}
    </Box>
  );
}
