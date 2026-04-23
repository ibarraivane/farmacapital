import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App";

/** Tras un deploy, el navegador puede tener HTML viejo que pide chunks JS ya borrados (error "Loading chunk N failed"). */
function isChunkLoadFailure(reason) {
  if (reason == null) return false;
  const name = reason.name || "";
  const msg = typeof reason === "string" ? reason : String(reason.message || reason);
  return (
    name === "ChunkLoadError" ||
    /loading chunk [\d]+ failed/i.test(msg) ||
    /chunk load error/i.test(msg)
  );
}

window.addEventListener("unhandledrejection", (event) => {
  if (!isChunkLoadFailure(event.reason)) return;
  event.preventDefault();
  const key = "farmax_chunk_reload_once";
  try {
    if (!sessionStorage.getItem(key)) {
      sessionStorage.setItem(key, "1");
      window.location.reload();
    }
  } catch (_) {
    window.location.reload();
  }
});

ReactDOM.createRoot(document.getElementById("root")).render(<App />);
