import { logoFullSrc, logoFullSrcSet } from "../../../brand";
import { FARMACIA_FISCAL } from "../../../constants/farmaciaFiscal";
import { pageIdToTiendaPath } from "../../../shared/tiendaRoutes";
import EnlaceTienda from "./EnlaceTienda";

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
        <a
          className="fc-textbtn"
          href={farmacia.maps_url || FARMACIA_FISCAL.maps_url || pageIdToTiendaPath("faq")}
          target={farmacia.maps_url || FARMACIA_FISCAL.maps_url ? "_blank" : undefined}
          rel={farmacia.maps_url || FARMACIA_FISCAL.maps_url ? "noopener noreferrer" : undefined}
          onClick={(e) => {
            if (farmacia.maps_url || FARMACIA_FISCAL.maps_url) {
              e.preventDefault();
              irSucursal();
              return;
            }
            e.preventDefault();
            setPage?.("faq");
          }}
        >
          Ver ubicación de la sucursal
        </a>
      </div>

      <nav className="fc-footer-links" aria-label="Enlaces de la tienda">
        {ENLACES_PIE.map((l) => (
          <EnlaceTienda key={l.id} href={pageIdToTiendaPath(l.id)} onNavigate={() => setPage?.(l.id)}>{l.label}</EnlaceTienda>
        ))}
      </nav>

      {legal ? <span className="fc-legal">{legal}</span> : null}
    </footer>
  );
}
