import React from "react";
import { render, screen } from "@testing-library/react";
import FichaProductoEnriquecida from "./FichaProductoEnriquecida";

const producto = {
  nombre: "Omeprazol 20 mg",
  descripcion: "Respaldo corto",
  principio_activo: "Omeprazol",
  concentracion: "20 mg",
  forma_farmaceutica: "Cápsula",
  presentacion: "30 cápsulas",
  marca: "Ultra",
  requiere_receta: false,
  codigo_barras: "750123",
};

test("sin ficha publicada solo muestra técnica y WhatsApp", () => {
  render(
    <FichaProductoEnriquecida
      producto={producto}
      ficha={{ estado: "borrador", contenido: { resumen: "NO", chips: ["oculto"] } }}
      whatsappHref="https://wa.me/525562530631"
    />
  );
  expect(screen.getByText("Ficha técnica")).toBeInTheDocument();
  expect(screen.getByText("Omeprazol")).toBeInTheDocument();
  expect(screen.queryByText("NO")).not.toBeInTheDocument();
  expect(screen.queryByText("¿Para qué sirve?")).not.toBeInTheDocument();
  expect(screen.getByText("Preguntar por WhatsApp")).toBeInTheDocument();
  expect(screen.queryByText("Código de barras")).not.toBeInTheDocument();
  expect(screen.queryByText("750123")).not.toBeInTheDocument();
});

test("Aspirina Eferv no enseña el EAN al cliente", () => {
  render(
    <FichaProductoEnriquecida
      producto={{
        nombre: "Aspirina Eferv",
        descripcion: "Aspirina Eferv",
        principio_activo: "Acidoacetilsalicilico",
        forma_farmaceutica: "TABLETAS",
        presentacion: "C/12",
        marca: "Aspirina",
        requiere_receta: false,
        codigo_barras: "7501008496701",
      }}
    />
  );
  expect(screen.getByText("Caja con 12")).toBeInTheDocument();
  expect(screen.getByText("Tabletas")).toBeInTheDocument();
  expect(screen.queryByText("Código de barras")).not.toBeInTheDocument();
  expect(screen.queryByText("7501008496701")).not.toBeInTheDocument();
});

test("con monografía publicada muestra acordeones", () => {
  render(
    <FichaProductoEnriquecida
      producto={producto}
      ficha={{
        estado: "publicado",
        tipo_ficha: "medicamento",
        contenido: { resumen: "Baja la acidez", chips: ["En ayunas"] },
      }}
      monografia={{
        estado: "publicado",
        contenido: {
          para_que_sirve: "Reflujo y úlcera",
          como_se_usa: ["En ayunas"],
          no_usar_si: ["Alergia"],
          consulta_si: [],
          interacciones: "Consulta la lista.",
          efectos: ["Dolor de cabeza"],
          alarma: "Busca atención.",
          conservacion: ["Lugar seco"],
        },
      }}
    />
  );
  expect(screen.getByText("Baja la acidez")).toBeInTheDocument();
  expect(screen.getAllByText("En ayunas").length).toBeGreaterThan(0);
  expect(screen.getByText("¿Para qué sirve?")).toBeInTheDocument();
  expect(screen.getByText("Tomada del instructivo autorizado del producto.")).toBeInTheDocument();
  expect(screen.getByText("Reflujo y úlcera")).toBeInTheDocument();
});
