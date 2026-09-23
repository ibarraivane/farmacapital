import { logoFullSrc, logoFullSrcSet } from "../../../brand";
import { FARMACIA_FISCAL } from "../../../constants/farmaciaFiscal";

function datoReal(...vals) {
  return vals.map((v) => String(v || "").trim()).filter(Boolean).join(" · ");
}

export function lineaLegalPie(farmacia = FARMACIA_FISCAL) {
  const responsable = datoReal(farmacia.responsable_sanitario, farmacia.responsable_cedula);
  const avisoFun = datoReal(farmacia.aviso_funcionamiento);
  return [
    datoReal(farmacia.razon_social, farmacia.rfc ? `RFC ${farmacia.rfc}` : ""),
    farmacia.direccion_comercial,
    farmacia.telefono_display,
    responsable ? `Responsable sanitario: ${responsable}` : "",
    avisoFun ? `Aviso de funcionamiento: ${avisoFun}` : "",
  ].filter(Boolean).join(" · ");
}

/** La ley pide que el aviso de privacidad y los términos estén siempre a la mano. */
export const ENLACES_PIE = [
  { id: "conseguir", label: "Te lo conseguimos" },
  { id: "cita", label: "Agendar consulta" },
  { id: "cuenta", label: "Mi cuenta" },
  { id: "faq", label: "Preguntas frecuentes" },
  { id: "privacidad", label: "Aviso de privacidad" },
  { id: "terminos", label: "Términos y condiciones" },
  { id: "envios", label: "Política de envíos" },
];

export default function PieV2({ setPage, farmacia = FARMACIA_FISCAL }) {
  const legal = lineaLegalPie(farmacia);

  const irSucursal = () => {
    const url = farmacia.maps_url || FARMACIA_FISCAL.maps_url;
    if (url && typeof window.open === "function") {
      window.open(url, "_blank", "noopener,noreferrer");
      return;
    }
    setPage?.("faq");
  };

  return (
    <footer className="fc-footer">
      <div className="fc-footer-marca">
        <img
          src={logoFullSrc({ light: true })}
          srcSet={logoFullSrcSet({ light: true })}
          alt="FarmaCapital"
        />
        <button type="button" className="fc-textbtn" onClick={irSucursal}>
          Ver ubicación de la sucursal
        </button>
      </div>

      <nav className="fc-footer-links" aria-label="Enlaces de la tienda">
        {ENLACES_PIE.map((l) => (
          <button key={l.id} type="button" onClick={() => setPage?.(l.id)}>{l.label}</button>
        ))}
      </nav>

      {legal ? <span className="fc-legal">{legal}</span> : null}
    </footer>
  );
}
