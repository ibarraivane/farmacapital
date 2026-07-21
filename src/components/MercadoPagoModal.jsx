import React, { useState, useEffect } from "react";
import { crearIntenciónDePago, esperarConfirmacionPago, cancelarPago, isMPConfigured } from "../utils/mercadoPago";

/**
 * FARMACAPITAL — Modal de pago con Mercado Pago Point Smart 2
 */
export default function MercadoPagoModal({ open, total, folio, hint, onSuccess, onCancel }) {
  const [estado,    setEstado]    = useState("idle"); // idle|iniciando|esperando|exito|error|cancelado
  const [mensaje,   setMensaje]   = useState("");
  const [intentId,  setIntentId]  = useState(null);
  const [progreso,  setProgreso]  = useState(0);
  const pollingRef = React.useRef(null);

  useEffect(() => {
    if (!open) {
      pollingRef.current?.cancelar?.();
      pollingRef.current = null;
      setEstado("idle"); setMensaje(""); setIntentId(null); setProgreso(0);
    }
    return () => {
      pollingRef.current?.cancelar?.();
      pollingRef.current = null;
    };
  }, [open]);
  useEffect(() => {
    if (!open) return undefined;
    const prev = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return () => {
      document.body.style.overflow = prev || "auto";
    };
  }, [open]);

  const iniciarPago = async () => {
    setEstado("iniciando");
    setMensaje("Enviando al terminal...");
    try {
      const intent = await crearIntenciónDePago({
        amount:            total,
        description:       `Venta FarmaCapital ${folio}`,
        externalReference: folio,
      });
      setIntentId(intent.id);
      setEstado("esperando");
      setMensaje("Esperando pago en terminal Point Smart 2...");
      setProgreso(10);

      const polling = esperarConfirmacionPago(intent.id, (status) => {
        setMensaje(`Estado: ${status}`);
        setProgreso(p => Math.min(p+5, 90));
      });
      pollingRef.current = polling;
      const result = await polling;

      setProgreso(100);
      setEstado("exito");
      setMensaje("¡Pago aprobado!");
      setTimeout(() => onSuccess?.(result.data), 1500);

    } catch(e) {
      setEstado("error");
      const msg = e?.message || "Error desconocido";
      if (/queued order/i.test(msg)) {
        setMensaje("El terminal tenía un cobro pendiente. Cierra este modal e intenta de nuevo en unos segundos.");
      } else if (/STANDALONE|modo PDV|terminal_mode_switched|terminal_not_in_pdv/i.test(msg)) {
        setMensaje(msg);
      } else if (/Timeout/i.test(msg)) {
        setMensaje(
          "El cobro se envió a Mercado Pago pero el Point no respondió. Verifica que el terminal esté en modo PDV (integrado), con WiFi, y reiniciado. Si la pantalla sigue en «Ingresar monto», hay que activar integración API en Mercado Pago."
        );
      } else {
        setMensaje(msg);
      }
    }
  };

  const cancelar = async () => {
    pollingRef.current?.cancelar?.();
    pollingRef.current = null;
    if (intentId) {
      await cancelarPago(intentId).catch(() => {});
    }
    setEstado("cancelado");
    onCancel?.();
  };

  if(!open) return null;

  const colores = {
    idle:       "#0D1B2A",
    iniciando:  "#f59e0b",
    esperando:  "#1E3ABA",
    exito:      "#16a34a",
    error:      "#ef4444",
    cancelado:  "#94a3b8",
  };

  const iconos = {
    idle:"💳", iniciando:"⏳", esperando:"📱",
    exito:"✅", error:"❌", cancelado:"✕"
  };

  return (
    <div style={{position:"fixed",inset:0,background:"rgba(15,23,42,.6)",backdropFilter:"blur(4px)",zIndex:9000,display:"flex",alignItems:"center",justifyContent:"center",padding:20}}>
      <div style={{background:"#fff",borderRadius:16,width:"min(400px,95vw)",padding:28,boxShadow:"0 24px 80px rgba(15,45,110,.2)"}}>

        {/* Header */}
        <div style={{textAlign:"center",marginBottom:24}}>
          <div style={{fontSize:48,marginBottom:8}}>{iconos[estado]}</div>
          <div style={{fontWeight:800,fontSize:18,color:"#0f172a"}}>Pago con tarjeta — Point Smart 2</div>
          <div style={{color:"#475569",fontSize:13,marginTop:4}}>Folio: {folio}</div>
          {hint && (
            <div style={{color:"#64748b",fontSize:11,marginTop:10,lineHeight:1.45,maxWidth:340,marginLeft:"auto",marginRight:"auto"}}>{hint}</div>
          )}
        </div>

        {/* Monto */}
        <div style={{background:"#f8fafc",borderRadius:12,padding:16,textAlign:"center",marginBottom:20,border:"1px solid #e2e8f0"}}>
          <div style={{color:"#94a3b8",fontSize:11,fontWeight:700,marginBottom:4}}>TOTAL A COBRAR</div>
          <div style={{color:"#0D1B2A",fontWeight:900,fontSize:32}}>${parseFloat(total||0).toFixed(2)}</div>
        </div>

        {/* Estado */}
        {estado!=="idle"&&(
          <div style={{marginBottom:16}}>
            <div style={{background:colores[estado]+"15",border:`1px solid ${colores[estado]}30`,borderRadius:10,padding:"10px 14px",textAlign:"center",marginBottom:8}}>
              <div style={{color:colores[estado],fontWeight:700,fontSize:13}}>{mensaje}</div>
            </div>
            {estado==="esperando"&&(
              <div style={{height:6,background:"#f1f5f9",borderRadius:3,overflow:"hidden"}}>
                <div style={{height:"100%",width:`${progreso}%`,background:"#1E3ABA",borderRadius:3,transition:"width .5s"}}/>
              </div>
            )}
          </div>
        )}

        {/* No configurado */}
        {!isMPConfigured()&&(
          <div style={{background:"#fef3c7",border:"1px solid #f59e0b30",borderRadius:8,padding:"10px 14px",marginBottom:16,fontSize:11,color:"#92400e"}}>
            ⚠️ Mercado Pago no configurado en modo seguro.<br/>
            Configura <strong>REACT_APP_MP_PUBLIC_KEY</strong>, <strong>REACT_APP_MP_DEVICE_ID</strong> y <strong>REACT_APP_MP_PROXY_URL</strong>.<br/>
            No expongas <strong>REACT_APP_MP_ACCESS_TOKEN</strong> en frontend de producción.
          </div>
        )}

        {/* Botones */}
        <div style={{display:"flex",gap:10,flexDirection:"column"}}>
          {estado==="idle"&&(
            <button onClick={iniciarPago} disabled={!isMPConfigured()} style={{
              padding:"13px",borderRadius:10,border:"none",
              background:isMPConfigured()?"linear-gradient(135deg,#009ee3,#00b1ea)":"#e2e8f0",
              color:"#fff",fontWeight:800,fontSize:15,cursor:isMPConfigured()?"pointer":"not-allowed",
            }}>
              💳 Cobrar con Point Smart 2
            </button>
          )}
          {(estado==="idle"||estado==="esperando"||estado==="error")&&(
            <button onClick={cancelar} style={{
              padding:"10px",borderRadius:10,border:"1px solid #e2e8f0",
              background:"transparent",color:"#475569",fontWeight:700,fontSize:13,cursor:"pointer",
            }}>
              {estado==="esperando"?"⏹ Cancelar pago":"✕ Cerrar"}
            </button>
          )}
        </div>

        {/* Instrucciones */}
        {estado==="esperando"&&(
          <div style={{marginTop:14,fontSize:10,color:"#94a3b8",textAlign:"center",lineHeight:1.6}}>
            El cliente debe presentar su tarjeta o celular en el terminal.<br/>
            Esperando respuesta del Point Smart 2...
          </div>
        )}
      </div>
    </div>
  );
}
