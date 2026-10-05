import EnlaceTienda from "./EnlaceTienda";
import { pageIdToTiendaPath } from "../../../shared/tiendaRoutes";

export default function NoEncontradaV2({ setPage }) {
  return (
    <div className="fc-body fc-empty">
      <h1>Página no encontrada</h1>
      <p>Esa dirección no existe en FarmaCapital. Prueba el inicio, el catálogo o pídenos que te lo consigamos.</p>
      <p style={{ display: "flex", flexWrap: "wrap", gap: 16, justifyContent: "center" }}>
        <EnlaceTienda className="fc-primary" href={pageIdToTiendaPath("home")} onNavigate={() => setPage?.("home")}>
          Ir al inicio
        </EnlaceTienda>
        <EnlaceTienda className="fc-secondary" href={pageIdToTiendaPath("catalogo")} onNavigate={() => setPage?.("catalogo")}>
          Ver catálogo
        </EnlaceTienda>
        <EnlaceTienda className="fc-textbtn" href={pageIdToTiendaPath("conseguir")} onNavigate={() => setPage?.("conseguir")}>
          Te lo conseguimos
        </EnlaceTienda>
      </p>
    </div>
  );
}
