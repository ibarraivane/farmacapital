/**
 * SERVICIO: Leer recetas con Claude Vision (vía API backend)
 */

/**
 * Procesa imagen de receta y extrae medicamentos
 * @param {string} base64Image - Imagen en base64
 * @returns {Promise<Object>} Resultado con medicamentos extraídos
 */
export async function procesarImagenReceta(base64Image) {
  try {
    const tok = sessionStorage.getItem("farmacapital_session_token");
    if (!tok) {
      throw new Error("Sesión expirada");
    }

    // Llamar a API backend
    const response = await fetch("/api/ai/receta", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        session_token: tok,
        imagen_base64: base64Image
      })
    });

    const data = await response.json();

    if (!response.ok) {
      throw new Error(data?.error || "Error procesando receta");
    }

    return {
      success: true,
      medicamentos: data.medicamentos || [],
      diagnostico: data.diagnostico,
      medico: data.medico,
      fecha: data.fecha
    };
  } catch (error) {
    return {
      success: false,
      error: error.message || "Error procesando imagen"
    };
  }
}

/**
 * Convierte archivo a base64
 */
export function fileToBase64(file) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => {
      const base64 = reader.result.split(',')[1];
      resolve(base64);
    };
    reader.onerror = reject;
    reader.readAsDataURL(file);
  });
}
