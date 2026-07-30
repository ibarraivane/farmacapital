import React from "react";
import ReactDOM from "react-dom/client";
import "./index.css";
import App from "./App";
import { initEventStore } from "./core/eventStore/initEventStore";

initEventStore();

if (typeof window !== "undefined" && process.env.REACT_APP_FARMACAPITAL_BUILD_ID) {
  window.__FARMACAPITAL_BUILD_ID__ = process.env.REACT_APP_FARMACAPITAL_BUILD_ID;
}

const CHUNK_RETRY_KEY = "farmacapital_chunk_retries";

/** Errores típicos al cargar código partido (deploy nuevo + HTML/JS viejos en caché). */
function isChunkLoadFailure(reason) {
  if (reason == null) return false;

  const scan = (r, depth) => {
    if (depth > 4 || r == null) return false;
    const name = r.name || "";
    const msg = typeof r === "string" ? r : String(r.message || r);
    if (
      name === "ChunkLoadError" ||
      /loading chunk [\d]+ failed/i.test(msg) ||
      /chunk load error/i.test(msg) ||
      /failed to fetch dynamically imported module/i.test(msg) ||
      /error when loading ['"]chunk/i.test(msg) ||
      /importing a module script failed/i.test(msg)
    ) {
      return true;
    }
    return scan(r.cause, depth + 1);
  };

  return scan(reason, 0);
}

async function clearSwAndCaches() {
  try {
    if ("caches" in window) {
      const keys = await caches.keys();
      await Promise.all(keys.map((k) => caches.delete(k)));
    }
  } catch (_) { /* noop */ }

  try {
    if ("serviceWorker" in navigator) {
      const regs = await navigator.serviceWorker.getRegistrations();
      await Promise.all(regs.map((r) => r.unregister()));
    }
  } catch (_) { /* noop */ }
}

function scheduleChunkRecovery() {
  let retries = 0;
  try {
    retries = parseInt(sessionStorage.getItem(CHUNK_RETRY_KEY) || "0", 10) || 0;
  } catch (_) { /* noop */ }

  if (retries >= 4) {
    try {
      sessionStorage.removeItem(CHUNK_RETRY_KEY);
    } catch (_) { /* noop */ }
    return;
  }

  try {
    sessionStorage.setItem(CHUNK_RETRY_KEY, String(retries + 1));
  } catch (_) { /* noop */ }

  void (async () => {
    await clearSwAndCaches();
    try {
      const u = new URL(window.location.href);
      u.searchParams.set("_farmacapital_v", String(Date.now()));
      window.location.replace(u.toString());
    } catch (_) {
      window.location.reload();
    }
  })();
}

window.addEventListener("unhandledrejection", (event) => {
  if (!isChunkLoadFailure(event.reason)) return;
  event.preventDefault();
  scheduleChunkRecovery();
});

window.addEventListener(
  "error",
  (event) => {
    const t = event.target;
    if (t && t.tagName === "SCRIPT" && t.src) {
      if (/chunk|static\/js/i.test(t.src)) {
        event.preventDefault();
        scheduleChunkRecovery();
      }
    }
  },
  true
);

ReactDOM.createRoot(document.getElementById("root")).render(<App />);
