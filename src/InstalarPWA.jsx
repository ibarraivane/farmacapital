import { useState, useEffect } from "react";
import { useTheme } from "./themeContext";

const BRAND = { primary:"#0052cc", gradient:"linear-gradient(135deg,#0052cc,#0099e6)" };

const URL_ADMIN = "https://farmax-seven.vercel.app/admin";

export default function InstalarPWA() {
  const C = useTheme();
  const [yaInstalada, setYaInstalada] = useState(false);
  const [deferredPrompt, setDeferredPrompt] = useState(null);
  const [instalando, setInstalando] = useState(false);
  const [instalada, setInstalada] = useState(false);

  useEffect(()=>{
    // Detectar si ya está instalada como PWA
    if(window.matchMedia("(display-mode: standalone)").matches || window.navigator.standalone){
      setYaInstalada(true);
    }
    // Capturar el evento de instalación (Android/Chrome)
    const handler = e => { e.preventDefault(); setDeferredPrompt(e); };
    window.addEventListener("beforeinstallprompt", handler);
    return ()=>window.removeEventListener("beforeinstallprompt", handler);
  },[]);

  const instalarAhora = async () => {
    if(!deferredPrompt) return;
    setInstalando(true);
    deferredPrompt.prompt();
    const { outcome } = await deferredPrompt.userChoice;
    if(outcome==="accepted") setInstalada(true);
    setDeferredPrompt(null);
    setInstalando(false);
  };

  const pasos = {
    android: [
      { n:1, icon:"🌐", txt:"Abre Chrome en tu Android" },
      { n:2, icon:"🔗", txt:`Ve a: ${URL_ADMIN}` },
      { n:3, icon:"⋮",  txt:'Toca el menú (3 puntos arriba a la derecha)' },
      { n:4, icon:"➕", txt:'"Agregar a pantalla de inicio"' },
      { n:5, icon:"✅", txt:"Confirma → aparece ícono Farmax" },
    ],
    iphone: [
      { n:1, icon:"🌐", txt:"Abre Safari en tu iPhone/iPad" },
      { n:2, icon:"🔗", txt:`Ve a: ${URL_ADMIN}` },
      { n:3, icon:"📤", txt:"Toca el botón compartir (cuadro con flecha)" },
      { n:4, icon:"➕", txt:'"Añadir a pantalla de inicio"' },
      { n:5, icon:"✅", txt:"Confirma → aparece ícono Farmax" },
    ],
    windows: [
      { n:1, icon:"🌐", txt:"Abre Chrome o Edge en tu PC/tablet Windows" },
      { n:2, icon:"🔗", txt:`Ve a: ${URL_ADMIN}` },
      { n:3, icon:"💻", txt:"Busca el ícono de instalar en la barra de URL (⊕)" },
      { n:4, icon:"➕", txt:'Haz clic en "Instalar"' },
      { n:5, icon:"✅", txt:"Farmax se abre como app independiente" },
    ],
  };

  const [tab, setTab] = useState("android");

  return (
    <div style={{maxWidth:700,margin:"0 auto"}}>
      <h1 style={{color:C.text,fontSize:20,fontWeight:800,marginBottom:8}}>📱 Instalar Farmax como app</h1>
      <p style={{color:C.textMid,fontSize:13,marginBottom:24,lineHeight:1.6}}>
        Instala Farmax en cada dispositivo de la farmacia para usarlo como una app nativa.
        Funciona aunque no haya internet (modo offline) y siempre estará disponible con un solo toque.
      </p>

      {/* Estado actual */}
      {yaInstalada?(
        <div style={{background:C.greenDim,border:`1px solid ${C.green}30`,borderRadius:12,padding:16,marginBottom:24,display:"flex",alignItems:"center",gap:12}}>
          <span style={{fontSize:28}}>✅</span>
          <div>
            <div style={{color:"#16a34a",fontWeight:700,fontSize:14}}>¡Farmax ya está instalado en este dispositivo!</div>
            <div style={{color:"#16a34a",fontSize:12,marginTop:2}}>Estás usando la versión PWA. El ícono ya aparece en tu pantalla de inicio.</div>
          </div>
        </div>
      ):deferredPrompt?(
        <div style={{background:"#eff6ff",border:`1px solid #bfdbfe`,borderRadius:12,padding:16,marginBottom:24,display:"flex",alignItems:"center",justifyContent:"space-between",flexWrap:"wrap",gap:12}}>
          <div style={{display:"flex",alignItems:"center",gap:12}}>
            <span style={{fontSize:28}}>🔔</span>
            <div>
              <div style={{color:BRAND.primary,fontWeight:700,fontSize:14}}>¡Puedes instalar Farmax ahora!</div>
              <div style={{color:C.textMid,fontSize:12,marginTop:2}}>Tu navegador está listo para instalar la app.</div>
            </div>
          </div>
          <button onClick={instalarAhora} disabled={instalando||instalada}
            style={{padding:"10px 20px",borderRadius:8,border:"none",background:BRAND.gradient,color:"#fff",fontWeight:700,fontSize:13,cursor:"pointer"}}>
            {instalada?"✅ Instalada":instalando?"Instalando…":"⬇️ Instalar ahora"}
          </button>
        </div>
      ):(
        <div style={{background:"#fef3c7",border:"1px solid #f59e0b30",borderRadius:12,padding:16,marginBottom:24}}>
          <div style={{color:"#92400e",fontWeight:700,fontSize:13}}>📋 Sigue las instrucciones de abajo para instalar en cada dispositivo</div>
        </div>
      )}

      {/* Beneficios */}
      <div style={{display:"grid",gridTemplateColumns:"repeat(auto-fill,minmax(180px,1fr))",gap:12,marginBottom:24}}>
        {[
          {icon:"⚡",titulo:"Acceso rápido",desc:"Un toque y abre al instante, sin buscar el link"},
          {icon:"📶",titulo:"Funciona offline",desc:"Ver datos aunque no haya internet"},
          {icon:"🔔",titulo:"Notificaciones",desc:"Aviso de pedidos y citas nuevas"},
          {icon:"🖥️",titulo:"Pantalla completa",desc:"Sin barra del navegador, más espacio"},
        ].map(b=>(
          <div key={b.titulo} style={{background:"#fff",border:`1px solid ${C.border}`,borderRadius:12,padding:16}}>
            <div style={{fontSize:28,marginBottom:8}}>{b.icon}</div>
            <div style={{color:C.text,fontWeight:700,fontSize:13,marginBottom:4}}>{b.titulo}</div>
            <div style={{color:C.textMid,fontSize:11,lineHeight:1.5}}>{b.desc}</div>
          </div>
        ))}
      </div>

      {/* Instrucciones por dispositivo */}
      <div style={{background:"#fff",border:`1px solid ${C.border}`,borderRadius:14,overflow:"hidden",marginBottom:24}}>
        <div style={{display:"flex",borderBottom:`1px solid ${C.border}`}}>
          {[["android","🤖 Android"],["iphone","🍎 iPhone/iPad"],["windows","💻 Windows"]].map(([id,label])=>(
            <button key={id} onClick={()=>setTab(id)} style={{
              flex:1,padding:"12px 8px",border:"none",cursor:"pointer",fontWeight:700,fontSize:12,
              background:tab===id?"#eff6ff":"transparent",
              color:tab===id?BRAND.primary:C.textMid,
              borderBottom:tab===id?`2px solid ${BRAND.primary}`:"2px solid transparent",
            }}>{label}</button>
          ))}
        </div>
        <div style={{padding:20}}>
          {pasos[tab].map(p=>(
            <div key={p.n} style={{display:"flex",alignItems:"flex-start",gap:14,marginBottom:16}}>
              <div style={{width:32,height:32,borderRadius:"50%",background:BRAND.gradient,display:"flex",alignItems:"center",justifyContent:"center",color:"#fff",fontWeight:800,fontSize:14,flexShrink:0}}>
                {p.n}
              </div>
              <div style={{display:"flex",alignItems:"center",gap:10,flex:1}}>
                <span style={{fontSize:20}}>{p.icon}</span>
                <span style={{color:C.text,fontSize:13,lineHeight:1.5}}>{p.txt}</span>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* QR Code */}
      <div style={{background:"#fff",border:`1px solid ${C.border}`,borderRadius:14,padding:24,textAlign:"center",marginBottom:24}}>
        <div style={{color:C.text,fontWeight:700,fontSize:14,marginBottom:8}}>📷 Escanea este código QR</div>
        <div style={{color:C.textMid,fontSize:12,marginBottom:16}}>Abre la cámara del celular y apunta al código para abrir el Admin directamente</div>
        <img
          src={`https://api.qrserver.com/v1/create-qr-code/?size=180x180&data=${encodeURIComponent(URL_ADMIN)}&bgcolor=ffffff&color=0052cc&margin=10`}
          alt="QR Farmax Admin"
          style={{width:180,height:180,borderRadius:12,border:`1px solid ${C.border}`}}
        />
        <div style={{marginTop:12,color:C.textDim,fontSize:11,fontFamily:"monospace"}}>{URL_ADMIN}</div>
      </div>

      {/* Dispositivos recomendados */}
      <div style={{background:"#fff",border:`1px solid ${C.border}`,borderRadius:14,padding:20}}>
        <div style={{color:C.text,fontWeight:700,fontSize:14,marginBottom:16}}>🏥 Dispositivos recomendados para Farmax</div>
        <div style={{display:"flex",flexDirection:"column",gap:10}}>
          {[
            {icon:"🖥️",quien:"Tu computadora (Mac)",rol:"Administrador",recom:"Navegador Chrome/Safari — no necesita instalación PWA",pwa:false},
            {icon:"📱",quien:"Tablet del mostrador",rol:"Vendedor",recom:"Instalar PWA en Chrome/Android — acceso rápido al POS",pwa:true},
            {icon:"💊",quien:"PC o tablet de la doctora",rol:"Dra. Lourdes",recom:"Instalar PWA — acceso al Consultorio siempre disponible",pwa:true},
            {icon:"📱",quien:"Tu celular",rol:"Admin móvil",recom:"Opcional — para revisar Dashboard y pedidos desde cualquier lugar",pwa:false},
          ].map(d=>(
            <div key={d.quien} style={{display:"flex",alignItems:"center",gap:14,padding:"12px 14px",borderRadius:10,background:d.pwa?"#eff6ff":C.bg,border:`1px solid ${d.pwa?"#bfdbfe":C.border}`}}>
              <span style={{fontSize:28,flexShrink:0}}>{d.icon}</span>
              <div style={{flex:1}}>
                <div style={{display:"flex",alignItems:"center",gap:8,marginBottom:2}}>
                  <span style={{color:C.text,fontWeight:700,fontSize:13}}>{d.quien}</span>
                  <span style={{padding:"2px 8px",borderRadius:20,fontSize:9,fontWeight:700,background:d.pwa?"#bfdbfe":"#e2e8f0",color:d.pwa?BRAND.primary:C.textMid}}>{d.rol}</span>
                  {d.pwa&&<span style={{padding:"2px 8px",borderRadius:20,fontSize:9,fontWeight:700,background:"#dcfce7",color:"#16a34a"}}>⬇️ Instalar PWA</span>}
                </div>
                <div style={{color:C.textMid,fontSize:11}}>{d.recom}</div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
