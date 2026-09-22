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
      <img
        src={logoFullSrc({ light: true })}
        srcSet={logoFullSrcSet({ light: true })}
        alt="FarmaCapital"
      />
      {legal ? <span className="fc-legal">{legal}</span> : null}
      <button type="button" className="fc-textbtn" onClick={irSucursal}>
        Atención y sucursal
      </button>
    </footer>
  );
}
