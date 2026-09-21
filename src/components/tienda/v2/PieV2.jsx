import { logoFullSrc, logoFullSrcSet } from "../../../brand";
import { FARMACIA_FISCAL } from "../../../constants/farmaciaFiscal";

function datoReal(...vals) {
  const t = vals.map((v) => String(v || "").trim()).filter(Boolean).join(" · ");
  return t || "";
}

export default function PieV2({ setPage, farmacia = FARMACIA_FISCAL }) {
  const go = (id, opts) => setPage?.(id, opts);
  const responsable = datoReal(farmacia.responsable_sanitario, farmacia.responsable_cedula);
  const avisoFun = datoReal(farmacia.aviso_funcionamiento);
  const legal = [
    datoReal(farmacia.razon_social, farmacia.rfc ? `RFC ${farmacia.rfc}` : ""),
    farmacia.direccion_comercial,
    responsable ? `Responsable sanitario: ${responsable}` : "",
    avisoFun ? `Aviso de funcionamiento: ${avisoFun}` : "",
    datoReal(farmacia.telefono_display, farmacia.email),
  ].filter(Boolean);

  const links = [
    { label: "Cotizar especializado", page: "conseguir" },
    { label: "Envíos", page: "envios" },
    { label: "Aviso de privacidad", page: "privacidad" },
    { label: "Términos", page: "terminos" },
    { label: "Factura tu compra", page: "faq" },
    { label: "Cookies", page: "privacidad" },
  ];

  return (
    <footer className="foot">
      <div style={{ display: "flex", flexDirection: "column", gap: 14 }}>
        <img
          className="foot-logo"
          src={logoFullSrc({ light: true })}
          srcSet={logoFullSrcSet({ light: true })}
          alt="FarmaCapital"
          height={26}
        />
        {legal.length ? (
          <div className="legal">
            {legal.map((line) => (
              <span key={line}>{line}<br /></span>
            ))}
          </div>
        ) : null}
      </div>
      <div className="foot-links">
        {links.map((l) => (
          <button key={l.label} type="button" className="link-foot" onClick={() => go(l.page)}>
            {l.label}
          </button>
        ))}
      </div>
    </footer>
  );
}
