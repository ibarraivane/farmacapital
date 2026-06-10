import { useState, useEffect, useRef } from "react";

// ═══════════════════════════════════════════════════════════════
// ECOSISTEMA FARMACAPITAL — Sistema de Gestión Multi-negocio
// Farmacia FarmaCapital · Minisuper Yolanda · Consultorio
// Identidad: Cápsula bicolor · Azul #0052cc → #0099e6 · Verde #00c46a
// ═══════════════════════════════════════════════════════════════

const C = {
  bg:"#07111a", card:"#0c1824", border:"#162436", borderHi:"#1f3347",
  blue:"#0099e6",   blueDark:"#0052cc",  blueDim:"#0099e618",
  green:"#00c46a",  greenDark:"#009952", greenDim:"#00c46a18",
  amber:"#ffaa00",  amberDim:"#ffaa0018",
  red:"#ff3d5a",    redDim:"#ff3d5a18",
  purple:"#9d6fff", purpleDim:"#9d6fff18",
  teal:"#00bcd4",   tealDim:"#00bcd418",
  text:"#e4eef8",   textMid:"#6a8eaa",   textDim:"#2d4560",
};

// Paleta de marca FarmaCapital
const BRAND = {
  primary:   "#0052cc",
  secondary: "#0099e6",
  accent:    "#00c46a",
  gradient:  "linear-gradient(135deg, #0052cc, #0099e6)",
  gradientG: "linear-gradient(135deg, #0052cc, #00c46a)",
};

const NEG = {
  farmacia:  { label:"FarmaCapital",    icon:"💊", color:C.blue,  owner:"Luis Ventura QFB" },
  minisuper: { label:"Minisuper Yolanda",  icon:"🛒", color:C.green, owner:"Yolanda Ventura"  },
};

// ── LOGO FARMACAPITAL (cápsula bicolor) ─────────────────────────────
function LogoFarmaCapital({ size = 36, showText = true, light = false }) {
  const textColor = light ? "#ffffff" : BRAND.primary;
  const subColor  = light ? "rgba(255,255,255,.7)" : BRAND.secondary;
  return (
    <div style={{ display:"flex", alignItems:"center", gap:10 }}>
      {/* Ícono cápsula */}
      <div style={{
        width: size, height: size, borderRadius: Math.round(size * 0.25),
        background: BRAND.gradient,
        display:"flex", alignItems:"center", justifyContent:"center",
        flexShrink: 0,
      }}>
        <div style={{
          width: size * 0.38, height: size * 0.65,
          borderRadius: size * 0.19,
          overflow:"hidden", display:"flex", flexDirection:"column",
        }}>
          <div style={{ flex:1, background:"rgba(255,255,255,1)" }}/>
          <div style={{ flex:1, background:"rgba(255,255,255,0.35)" }}/>
        </div>
      </div>
      {showText && (
        <div style={{ display:"flex", flexDirection:"column", lineHeight:1 }}>
          <div style={{
            color: textColor, fontWeight:800, fontSize: size * 0.44,
            fontFamily:"'Plus Jakarta Sans',sans-serif", letterSpacing:"-0.5px",
          }}>
            FAR<span style={{ color: subColor }}>MAX</span>
          </div>
          <div style={{
            color: subColor, fontSize: size * 0.22,
            letterSpacing:"2px", textTransform:"uppercase",
            marginTop: 2, fontWeight:600,
          }}>Farmacia · Salud</div>
        </div>
      )}
    </div>
  );
}

// ── DATOS ──────────────────────────────────────────────────────
const INV_F = [
  {id:1, sku:"PAR-500",name:"Paracetamol 500mg",    cat:"Analgésico",     stock:8, min:20,price:12,cost:5.5, lote:"L24-01",cad:"2025-06-30",ctrl:false,receta:false,tipo:"generico",prov:"Nadro"},
  {id:2, sku:"IBU-400",name:"Ibuprofeno 400mg",      cat:"Antiinflamatorio",stock:45,min:30,price:18,cost:8,   lote:"L24-02",cad:"2026-03-15",ctrl:false,receta:false,tipo:"generico",prov:"Marzam"},
  {id:3, sku:"OME-20", name:"Omeprazol 20mg",         cat:"Gastro",         stock:3, min:15,price:22,cost:10,  lote:"L24-03",cad:"2025-09-01",ctrl:false,receta:false,tipo:"generico",prov:"Casa Saba"},
  {id:4, sku:"AMO-500",name:"Amoxicilina 500mg",      cat:"Antibiótico",    stock:32,min:20,price:35,cost:14,  lote:"L24-04",cad:"2026-01-20",ctrl:true, receta:true, tipo:"generico",prov:"Nadro"},
  {id:5, sku:"MET-850",name:"Metformina 850mg",        cat:"Diabetes",       stock:60,min:25,price:28,cost:11,  lote:"L24-05",cad:"2026-08-10",ctrl:false,receta:true, tipo:"generico",prov:"Fármacos Nac."},
  {id:6, sku:"LOS-50", name:"Losartán 50mg",           cat:"Hipertensión",   stock:40,min:20,price:32,cost:13,  lote:"L24-06",cad:"2026-06-01",ctrl:false,receta:true, tipo:"generico",prov:"Marzam"},
  {id:7, sku:"LOR-10", name:"Loratadina 10mg",         cat:"Alergia",        stock:12,min:20,price:15,cost:6,   lote:"L24-07",cad:"2025-12-31",ctrl:false,receta:false,tipo:"generico",prov:"Marzam"},
  {id:8, sku:"VIT-C",  name:"Vitamina C 1000mg",       cat:"Vitaminas",      stock:7, min:20,price:45,cost:18,  lote:"L24-08",cad:"2026-05-15",ctrl:false,receta:false,tipo:"generico",prov:"Nadro"},
  {id:9, sku:"PED-500",name:"Pedialyte 500ml",          cat:"Hidratación",    stock:24,min:15,price:55,cost:32,  lote:"L24-09",cad:"2026-07-01",ctrl:false,receta:false,tipo:"marca",   prov:"Casa Saba"},
  {id:10,sku:"AZI-500",name:"Azitromicina 500mg",       cat:"Antibiótico",    stock:18,min:15,price:48,cost:20,  lote:"L24-10",cad:"2026-02-28",ctrl:true, receta:true, tipo:"generico",prov:"Nadro"},
  {id:11,sku:"ASP-100",name:"Aspirina 100mg",            cat:"Cardiovascular", stock:55,min:30,price:10,cost:4,   lote:"L24-11",cad:"2026-09-15",ctrl:false,receta:false,tipo:"generico",prov:"Casa Saba"},
  {id:12,sku:"SAL-INH",name:"Salbutamol Inhalador",      cat:"Respiratorio",   stock:9, min:10,price:85,cost:45,  lote:"L24-12",cad:"2026-04-30",ctrl:false,receta:true, tipo:"marca",   prov:"Marzam"},
];

const INV_M = [
  {id:101,sku:"AGU-1L", name:"Agua Purificada 1L",   cat:"Bebidas",    stock:48,min:24,price:12,cost:7},
  {id:102,sku:"GAT-600",name:"Gatorade 600ml",         cat:"Electrolitos",stock:30,min:20,price:22,cost:14},
  {id:103,sku:"COK-600",name:"Coca-Cola 600ml",         cat:"Refrescos",  stock:36,min:24,price:20,cost:12},
  {id:104,sku:"SAB-200",name:"Sabritas 200g",            cat:"Botanas",    stock:15,min:10,price:28,cost:18},
  {id:105,sku:"BIM-680",name:"Bimbo Blanco 680g",        cat:"Panadería",  stock:8, min:5, price:45,cost:32},
  {id:106,sku:"LEC-1L", name:"Leche Lala 1L",            cat:"Lácteos",    stock:20,min:12,price:32,cost:22},
  {id:107,sku:"JAB-LIQ",name:"Jabón Líquido 500ml",      cat:"Limpieza",   stock:12,min:8, price:38,cost:24},
  {id:108,sku:"ALC-96", name:"Alcohol 96° 1L",           cat:"Higiene",    stock:18,min:10,price:55,cost:35},
  {id:109,sku:"HUE-12", name:"Huevo 12 pzas",            cat:"Básicos",    stock:10,min:8, price:48,cost:38},
  {id:110,sku:"ARR-1K", name:"Arroz 1kg",                cat:"Básicos",    stock:25,min:15,price:25,cost:18},
];

const CLIENTES_D = [
  {id:1,nombre:"Roberto Mendoza", tel:"5551112233",puntos:245,visitas:12,ultimo:"2026-03-15",gasto:3240,nivel:"Gold",  cronica:"Diabetes"},
  {id:2,nombre:"Carmen Solis",    tel:"5554445566",puntos:180,visitas:8, ultimo:"2026-03-10",gasto:1890,nivel:"Silver",cronica:"Hipertensión"},
  {id:3,nombre:"Pedro Juárez",    tel:"5557778899",puntos:45, visitas:3, ultimo:"2026-03-01",gasto:580, nivel:"Bronze",cronica:null},
  {id:4,nombre:"Ana Martínez",    tel:"5552223344",puntos:320,visitas:18,ultimo:"2026-03-18",gasto:4100,nivel:"Gold",  cronica:"Diabetes"},
];

const BITACORA_D = [
  {id:1,fecha:"2026-04-12",med:"Amoxicilina 500mg", lote:"L24-04",qty:1,receta:"RX-001",medico:"Dra. García", paciente:"Juan P.",    tel:"5551234567",emp:"María G."},
  {id:2,fecha:"2026-04-11",med:"Azitromicina 500mg",lote:"L24-10",qty:1,receta:"RX-002",medico:"Dr. Ramírez", paciente:"Ana L.",     tel:"5559876543",emp:"Juan R."},
  {id:3,fecha:"2026-04-10",med:"Metformina 850mg",  lote:"L24-05",qty:2,receta:"RX-003",medico:"Dra. García", paciente:"Roberto M.", tel:"5551112233",emp:"María G."},
];

const AGENDA_D = [
  {id:1,hora:"09:00",pac:"Roberto Mendoza",motivo:"Control diabetes",    estado:"confirmada"},
  {id:2,hora:"09:30",pac:"—",              motivo:"",                    estado:"libre"},
  {id:3,hora:"10:00",pac:"Carmen Solis",   motivo:"Control hipertensión",estado:"confirmada"},
  {id:4,hora:"10:30",pac:"Nueva consulta", motivo:"Dolor de cabeza",     estado:"pendiente"},
  {id:5,hora:"11:00",pac:"María Torres",   motivo:"Revisión general",    estado:"completada"},
  {id:6,hora:"11:30",pac:"—",              motivo:"",                    estado:"libre"},
];

const EXP_D = [
  {id:1,nombre:"Roberto Mendoza",edad:58,tel:"5551112233",dx:"Diabetes Tipo 2",  meds:["Metformina 850mg"],      ultima:"2026-03-10",proxima:"2026-04-10",notas:"HbA1c 7.2%. Control estable.",     alergias:"Ninguna"},
  {id:2,nombre:"Carmen Solis",    edad:42,tel:"5554445566",dx:"Hipertensión",     meds:["Losartán 50mg"],          ultima:"2026-03-05",proxima:"2026-04-05",notas:"Presión 130/85. Bien controlada.", alergias:"Penicilina"},
  {id:3,nombre:"María Torres",    edad:35,tel:"5556667788",dx:"Revisión general", meds:[],                         ultima:"2026-04-12",proxima:null,         notas:"Sin antecedentes relevantes.",     alergias:"Ninguna"},
];

const CORTES_D = [
  {turno:"Matutino",  emp:"María García",ap:"08:00",ci:"16:00",ef_dec:2450,ef_sis:2450,tar:1820,serv:340, total:4610,dif:0},
  {turno:"Vespertino",emp:"Juan Ramírez", ap:"16:00",ci:"22:00",ef_dec:1890,ef_sis:1920,tar:980, serv:120, total:3020,dif:-30},
];

const VSEM = [
  {dia:"L",f:4200,m:1800},{dia:"M",f:3800,m:2100},{dia:"X",f:5100,m:1600},
  {dia:"J",f:2900,m:2400},{dia:"V",f:6200,m:3100},{dia:"S",f:4800,m:2800},{dia:"D",f:2200,m:1900},
];

// ── UTILS ─────────────────────────────────────────────────────
const dC   = f => Math.floor((new Date(f)-new Date())/86400000);
const cC   = d => d<0?C.red:d<15?C.red:d<30?C.amber:C.green;
const $    = n => `$${Number(n).toLocaleString("es-MX")}`;
const abc  = i => { const v=i.stock*i.price; return v>800?"A":v>300?"B":"C"; };
const aCol = a => ({A:C.green,B:C.amber,C:C.red}[a]);
const nCol = n => ({Gold:C.amber,Silver:C.textMid,Bronze:"#cd7f32"}[n]||C.textMid);

// ── UI BASE ───────────────────────────────────────────────────
const Box = ({children,style,onClick,ac})=>(
  <div onClick={onClick} style={{background:C.card,borderRadius:14,border:`1px solid ${ac?ac+"40":C.border}`,transition:"border-color .2s",cursor:onClick?"pointer":"default",...style}}
    onMouseEnter={e=>onClick&&(e.currentTarget.style.borderColor=ac||C.borderHi)}
    onMouseLeave={e=>onClick&&(e.currentTarget.style.borderColor=ac?ac+"40":C.border)}>
    {children}
  </div>
);

const Tag=({col,children,sm})=>(
  <span style={{background:col+"20",color:col,border:`1px solid ${col}40`,borderRadius:20,padding:sm?"2px 7px":"3px 10px",fontSize:sm?9:11,fontWeight:700,letterSpacing:.5,textTransform:"uppercase",whiteSpace:"nowrap",display:"inline-block"}}>{children}</span>
);

const Btn=({children,onClick,col,sm,ol,dis,full})=>(
  <button onClick={onClick} disabled={dis} style={{padding:sm?"5px 12px":"9px 18px",borderRadius:8,border:`1px solid ${ol?(col||BRAND.primary):"transparent"}`,background:ol?"transparent":dis?C.border:(col||BRAND.primary),color:ol?(col||BRAND.primary):dis?C.textMid:"#fff",fontWeight:700,fontSize:sm?11:13,cursor:dis?"not-allowed":"pointer",fontFamily:"'Plus Jakarta Sans',sans-serif",opacity:dis?.5:1,width:full?"100%":undefined,transition:"opacity .15s"}}>{children}</button>
);

const Inp=({value,onChange,placeholder,style,type,onKeyDown})=>(
  <input value={value} onChange={onChange} placeholder={placeholder} type={type||"text"} onKeyDown={onKeyDown} style={{background:C.bg,border:`1px solid ${C.border}`,borderRadius:8,color:C.text,padding:"9px 13px",fontSize:13,outline:"none",fontFamily:"'Plus Jakarta Sans',sans-serif",...style}}
    onFocus={e=>(e.target.style.borderColor=C.borderHi)} onBlur={e=>(e.target.style.borderColor=C.border)}/>
);

const KPI=({label,value,sub,col,icon,trend})=>(
  <Box style={{padding:"18px 20px",flex:1,minWidth:140}}>
    <div style={{display:"flex",justifyContent:"space-between",alignItems:"flex-start"}}>
      <div style={{flex:1,minWidth:0}}>
        <div style={{color:C.textDim,fontSize:9,letterSpacing:1.5,textTransform:"uppercase",marginBottom:8}}>{label}</div>
        <div style={{color:col||C.text,fontSize:22,fontWeight:800,fontFamily:"'Plus Jakarta Sans',sans-serif",lineHeight:1}}>{value}</div>
        {sub&&<div style={{color:C.textMid,fontSize:11,marginTop:4}}>{sub}</div>}
        {trend!==undefined&&<div style={{color:trend>=0?C.green:C.red,fontSize:11,marginTop:4,fontWeight:700}}>{trend>=0?"▲":"▼"} {Math.abs(trend)}% vs ayer</div>}
      </div>
      <div style={{fontSize:24,opacity:.5,marginLeft:8}}>{icon}</div>
    </div>
  </Box>
);

const Modal=({open,onClose,title,children,ac})=>!open?null:(
  <div style={{position:"fixed",inset:0,background:"#000b",zIndex:300,display:"flex",alignItems:"center",justifyContent:"center",padding:20}} onClick={e=>e.target===e.currentTarget&&onClose()}>
    <Box ac={ac} style={{padding:28,width:"100%",maxWidth:480,maxHeight:"90vh",overflowY:"auto"}}>
      <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:20}}>
        <div style={{color:C.text,fontWeight:800,fontSize:16,fontFamily:"'Plus Jakarta Sans',sans-serif"}}>{title}</div>
        <button onClick={onClose} style={{background:"none",border:"none",color:C.textMid,cursor:"pointer",fontSize:20}}>×</button>
      </div>
      {children}
    </Box>
  </div>
);

const H2=({children,sub,action})=>(
  <div style={{display:"flex",justifyContent:"space-between",alignItems:"flex-start",marginBottom:24}}>
    <div>
      <h2 style={{color:C.text,fontSize:20,fontWeight:800,fontFamily:"'Plus Jakarta Sans',sans-serif",margin:0}}>{children}</h2>
      {sub&&<div style={{color:C.textMid,fontSize:12,marginTop:4}}>{sub}</div>}
    </div>
    {action}
  </div>
);

// ── SIDEBAR ───────────────────────────────────────────────────
const NAV=[
  {id:"dash",icon:"◈",label:"Dashboard"},
  {id:"pos", icon:"⊡",label:"Punto de Venta"},
  {id:"inv", icon:"▤",label:"Inventario"},
  {id:"cof", icon:"⚕",label:"COFEPRIS"},
  {id:"caja",icon:"⊞",label:"Corte de Caja"},
  {id:"cons",icon:"♥",label:"Consultorio"},
  {id:"cli", icon:"◉",label:"Clientes & Puntos"},
  {id:"rrhh",icon:"◑",label:"RR.HH."},
  {id:"rep", icon:"◧",label:"Reportes"},
  {id:"bot", icon:"✦",label:"Asistente IA"},
];

function Sidebar({active,setActive,negocio,setNegocio}){
  const ac=NEG[negocio].color;
  const bajo=INV_F.filter(i=>i.stock<i.min).length;
  const cad=INV_F.filter(i=>dC(i.cad)<30).length;
  return(
    <div style={{width:224,minHeight:"100dvh",background:C.card,borderRight:`1px solid ${C.border}`,display:"flex",flexDirection:"column",position:"fixed",left:0,top:0,zIndex:100}}>
      {/* Logo FarmaCapital */}
      <div style={{padding:"22px 16px 16px",borderBottom:`1px solid ${C.border}`}}>
        <LogoFarmaCapital size={34} showText={true}/>
        <div style={{display:"flex",gap:4,marginTop:14}}>
          {Object.entries(NEG).map(([k,n])=>(
            <button key={k} onClick={()=>setNegocio(k)} style={{flex:1,padding:"5px 2px",borderRadius:6,border:`1px solid ${negocio===k?n.color:C.border}`,background:negocio===k?n.color+"22":"transparent",color:negocio===k?n.color:C.textDim,fontSize:9,fontWeight:700,cursor:"pointer",textTransform:"uppercase",letterSpacing:.5,transition:"all .15s"}}>
              {n.icon} {k==="farmacia"?"FarmaCapital":"Mini"}
            </button>
          ))}
        </div>
      </div>
      <div style={{flex:1,padding:"10px 8px",overflowY:"auto"}}>
        {NAV.map(n=>(
          <button key={n.id} onClick={()=>setActive(n.id)} style={{width:"100%",display:"flex",alignItems:"center",gap:10,padding:"8px 10px",borderRadius:8,border:"none",cursor:"pointer",marginBottom:2,textAlign:"left",fontSize:12,fontWeight:600,fontFamily:"'Plus Jakarta Sans',sans-serif",background:active===n.id?BRAND.primary+"18":"transparent",color:active===n.id?BRAND.secondary:C.textMid,borderLeft:`3px solid ${active===n.id?BRAND.primary:"transparent"}`,transition:"all .15s"}}>
            <span style={{fontSize:13,width:16,textAlign:"center"}}>{n.icon}</span>{n.label}
          </button>
        ))}
      </div>
      <div style={{padding:"0 8px 16px"}}>
        <Box style={{padding:"12px 14px"}}>
          <div style={{color:C.textDim,fontSize:9,letterSpacing:1.5,textTransform:"uppercase",marginBottom:8}}>Alertas FarmaCapital</div>
          {bajo>0&&<div style={{color:C.red,fontSize:12,fontWeight:700,marginBottom:4}}>⚠ {bajo} bajo stock</div>}
          {cad>0&&<div style={{color:C.amber,fontSize:12,fontWeight:700,marginBottom:4}}>⏱ {cad} por caducar</div>}
          <div style={{color:C.green,fontSize:12,fontWeight:700}}>💰 2 ofertas mayoreo</div>
        </Box>
      </div>
    </div>
  );
}

// ── DASHBOARD ─────────────────────────────────────────────────
function Dashboard({negocio}){
  const inv=negocio==="farmacia"?INV_F:INV_M;
  const ac=NEG[negocio].color;
  const bajo=inv.filter(i=>i.stock<i.min).length;
  const maxV=Math.max(...VSEM.map(d=>Math.max(d.f,d.m)));
  return(
    <div>
      <div style={{display:"flex",justifyContent:"space-between",alignItems:"flex-start",marginBottom:28}}>
        <div>
          <h1 style={{color:C.text,fontSize:22,fontWeight:800,fontFamily:"'Plus Jakarta Sans',sans-serif",margin:0}}>{NEG[negocio].icon} {NEG[negocio].label}</h1>
          <div style={{color:C.textMid,fontSize:12,marginTop:4}}>{NEG[negocio].owner} · Dom 12 Abr 2026</div>
        </div>
        <Tag col={ac}>{negocio==="farmacia"?"⚕ COFEPRIS Activo":"✓ Operando"}</Tag>
      </div>
      <div style={{display:"flex",gap:12,marginBottom:20,flexWrap:"wrap"}}>
        <KPI label="Ventas hoy" value={negocio==="farmacia"?"$6,200":"$3,100"} col={ac} icon="💵" trend={12}/>
        <KPI label="Esta semana" value={$(VSEM.reduce((a,d)=>a+(negocio==="farmacia"?d.f:d.m),0))} col={C.teal} icon="📈"/>
        <KPI label="Bajo stock" value={bajo} col={bajo>0?C.red:C.green} icon="⚠️"/>
        {negocio==="farmacia"&&<KPI label="Por caducar" value={INV_F.filter(i=>dC(i.cad)<30).length} col={C.amber} icon="⏱" sub="30 días"/>}
        <KPI label="Puntos FarmaCapital" value="4,820" col={C.purple} icon="⭐" sub="38 clientes"/>
      </div>
      <div style={{display:"grid",gridTemplateColumns:"1fr 1fr",gap:16,marginBottom:16}}>
        <Box style={{padding:20}}>
          <div style={{color:C.text,fontWeight:700,fontSize:13,marginBottom:4}}>Ventas semana</div>
          <div style={{color:C.textMid,fontSize:10,marginBottom:14}}>
            <span style={{color:ac}}>■</span> {NEG[negocio].label}
            {negocio==="farmacia"&&<> &nbsp;<span style={{color:C.green}}>■</span> Minisuper</>}
          </div>
          <div style={{display:"flex",alignItems:"flex-end",gap:5,height:100}}>
            {VSEM.map((d,i)=>(
              <div key={i} style={{flex:1,display:"flex",flexDirection:"column",alignItems:"center",gap:3,height:"100%"}}>
                <div style={{flex:1,width:"100%",display:"flex",flexDirection:"column",justifyContent:"flex-end",gap:1}}>
                  {negocio==="farmacia"&&<div style={{width:"100%",background:C.green+"44",borderRadius:"2px 2px 0 0",height:`${(d.m/maxV)*80}%`,minHeight:1}}/>}
                  <div style={{width:"100%",background:ac,borderRadius:negocio==="farmacia"?"0":"4px 4px 0 0",height:`${((negocio==="farmacia"?d.f:d.m)/maxV)*80}%`,minHeight:2}}/>
                </div>
                <div style={{color:C.textDim,fontSize:9}}>{d.dia}</div>
              </div>
            ))}
          </div>
        </Box>
        {negocio==="farmacia"?(
          <Box style={{padding:20}}>
            <div style={{color:C.text,fontWeight:700,fontSize:13,marginBottom:14}}>⚕ Estado COFEPRIS</div>
            {[["Bitácora SICAD",true,"Al día"],["Stock regulatorio",false,"3 faltantes"],["Recetas hoy",true,"3 registradas"],["Responsable QFB",true,"Luis Ventura"],["Licencia",true,"Vigente"]].map(([l,ok,t])=>(
              <div key={l} style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:8}}>
                <span style={{color:C.textMid,fontSize:12}}>{l}</span>
                <Tag col={ok?C.green:C.red} sm>{ok?"✓":"⚠"} {t}</Tag>
              </div>
            ))}
          </Box>
        ):(
          <Box style={{padding:20}}>
            <div style={{color:C.text,fontWeight:700,fontSize:13,marginBottom:14}}>📊 Top productos</div>
            {INV_M.slice(0,6).map(p=>(
              <div key={p.id} style={{display:"flex",justifyContent:"space-between",marginBottom:8}}>
                <span style={{color:C.textMid,fontSize:12}}>{p.name}</span>
                <span style={{color:C.green,fontWeight:700,fontSize:12}}>{$(p.price)}</span>
              </div>
            ))}
          </Box>
        )}
      </div>
      <div style={{display:"grid",gridTemplateColumns:"1fr 1fr",gap:16}}>
        <Box style={{padding:20}}>
          <div style={{color:C.text,fontWeight:700,fontSize:13,marginBottom:12}}>⚠ Reordenar urgente</div>
          {inv.filter(i=>i.stock<i.min).map(item=>(
            <div key={item.id} style={{background:C.redDim,border:`1px solid ${C.red}30`,borderRadius:8,padding:"10px 12px",marginBottom:8}}>
              <div style={{display:"flex",justifyContent:"space-between"}}>
                <span style={{color:C.text,fontSize:12,fontWeight:700}}>{item.name}</span>
                <Tag col={C.red} sm>{item.stock}/{item.min}</Tag>
              </div>
              {item.prov&&<div style={{color:C.textMid,fontSize:10,marginTop:3}}>Prov: {item.prov}</div>}
            </div>
          ))}
          {!inv.filter(i=>i.stock<i.min).length&&<div style={{color:C.green,fontSize:13,fontWeight:700}}>✓ Todo en orden</div>}
        </Box>
        <Box style={{padding:20}}>
          <div style={{color:C.text,fontWeight:700,fontSize:13,marginBottom:12}}>{negocio==="farmacia"?"💰 Ofertas mayoreo":"📦 Inventario"}</div>
          {negocio==="farmacia"?[
            {name:"Paracetamol 500mg",prov:"Nadro",    oferta:4.8,ahorro:13},
            {name:"Vitamina C 1000mg",prov:"Casa Saba",oferta:14.5,ahorro:19},
          ].map(o=>(
            <div key={o.name} style={{background:C.amberDim,border:`1px solid ${C.amber}30`,borderRadius:8,padding:"10px 12px",marginBottom:8}}>
              <div style={{display:"flex",justifyContent:"space-between"}}><span style={{color:C.text,fontSize:12,fontWeight:700}}>{o.name}</span><Tag col={C.amber} sm>-{o.ahorro}%</Tag></div>
              <div style={{color:C.textMid,fontSize:11,marginTop:3}}>{o.prov} · {$(o.oferta)}/ud</div>
            </div>
          )):<div style={{color:C.green,fontSize:13,fontWeight:700}}>✓ Sin alertas</div>}
        </Box>
      </div>
      {negocio==="farmacia"&&(
        <Box style={{padding:20,marginTop:16}}>
          <div style={{color:C.text,fontWeight:700,fontSize:13,marginBottom:12}}>⏱ Caducidades próximas (90 días)</div>
          <div style={{display:"grid",gridTemplateColumns:"repeat(auto-fill,minmax(190px,1fr))",gap:10}}>
            {INV_F.map(i=>({...i,d:dC(i.cad)})).filter(i=>i.d<90).sort((a,b)=>a.d-b.d).map(item=>(
              <div key={item.id} style={{background:cC(item.d)+"10",border:`1px solid ${cC(item.d)}30`,borderRadius:10,padding:"12px 14px"}}>
                <Tag col={cC(item.d)} sm>{item.d<0?"CADUCADO":item.d<15?"CRÍTICO":"PRÓXIMO"}</Tag>
                <div style={{color:C.text,fontSize:12,fontWeight:700,marginTop:6}}>{item.name}</div>
                <div style={{color:C.textMid,fontSize:10,marginTop:2}}>Lote: {item.lote}</div>
                <div style={{color:cC(item.d),fontSize:11,fontWeight:700,marginTop:4}}>{item.d<0?"⛔ Retirar":`${item.d}d · ${item.cad}`}</div>
              </div>
            ))}
          </div>
        </Box>
      )}
    </div>
  );
}

// ── POS ───────────────────────────────────────────────────────
function POS({negocio}){
  const inv=negocio==="farmacia"?INV_F:INV_M;
  const ac=NEG[negocio].color;
  const [cart,setCart]=useState([]);
  const [srch,setSrch]=useState("");
  const [pay,setPay]=useState("Efectivo");
  const [tel,setTel]=useState("");
  const [cli,setCli]=useState(null);
  const [ticket,setTicket]=useState(null);
  const [rxM,setRxM]=useState(null);
  const [rx,setRx]=useState({receta:"",medico:"",paciente:""});
  const [ptsC,setPtsC]=useState(0);

  const buscar=t=>{setTel(t);setCli(CLIENTES_D.find(c=>c.tel===t)||null);};
  const fil=inv.filter(i=>i.name.toLowerCase().includes(srch.toLowerCase())||i.sku.toLowerCase().includes(srch.toLowerCase()));
  const add=item=>{
    if(negocio==="farmacia"&&item.receta){setRxM(item);return;}
    setCart(p=>{const ex=p.find(c=>c.sku===item.sku);return ex?p.map(c=>c.sku===item.sku?{...c,qty:c.qty+1}:c):[...p,{...item,qty:1,rxI:null}];});
  };
  const confRx=()=>{
    if(!rx.receta||!rx.medico||!rx.paciente)return;
    setCart(p=>[...p,{...rxM,qty:1,rxI:{...rx}}]);
    setRxM(null);setRx({receta:"",medico:"",paciente:""});
  };
  const rm=sku=>setCart(p=>p.filter(c=>c.sku!==sku));
  const upd=(sku,d)=>setCart(p=>p.map(c=>c.sku===sku?{...c,qty:Math.max(1,c.qty+d)}:c));
  const sub=cart.reduce((a,c)=>a+c.price*c.qty,0);
  const dPts=ptsC*0.5;
  const total=Math.max(0,sub-dPts);
  const ptsG=Math.floor(sub/10);
  const cobrar=()=>{
    if(!cart.length)return;
    setTicket({id:Date.now(),items:[...cart],sub,dPts,total,pay,cli,ptsG,ptsC,negocio});
    setCart([]);setTel("");setCli(null);setPtsC(0);
  };

  return(
    <div>
      <H2 sub={`${NEG[negocio].icon} ${NEG[negocio].label}`}>Punto de Venta</H2>
      <Modal open={!!rxM} onClose={()=>setRxM(null)} title="⚕ Medicamento con Receta — COFEPRIS" ac={C.amber}>
        <div style={{color:C.textMid,fontSize:13,marginBottom:14}}><strong style={{color:C.text}}>{rxM?.name}</strong> — registro obligatorio SICAD</div>
        {[["Número de receta","receta","RX-2024-XXX"],["Médico prescriptor","medico","Dr. Nombre / Cédula"],["Nombre del paciente","paciente","Nombre completo"]].map(([l,k,ph])=>(
          <div key={k} style={{marginBottom:12}}>
            <div style={{color:C.textMid,fontSize:11,marginBottom:4}}>{l} *</div>
            <Inp value={rx[k]} onChange={e=>setRx(p=>({...p,[k]:e.target.value}))} placeholder={ph} style={{width:"100%",boxSizing:"border-box"}}/>
          </div>
        ))}
        <div style={{background:C.amberDim,border:`1px solid ${C.amber}30`,borderRadius:8,padding:"10px 12px",marginBottom:14}}>
          <div style={{color:C.amber,fontSize:11}}>⚕ Se agrega a bitácora COFEPRIS y reporte SICAD automáticamente.</div>
        </div>
        <div style={{display:"flex",gap:8}}>
          <Btn onClick={()=>setRxM(null)} ol col={C.textMid}>Cancelar</Btn>
          <Btn onClick={confRx} col={C.amber} dis={!rx.receta||!rx.medico||!rx.paciente}>✓ Registrar y agregar</Btn>
        </div>
      </Modal>
      <div style={{display:"grid",gridTemplateColumns:"1fr 340px",gap:16,alignItems:"start"}}>
        <div>
          <Inp value={srch} onChange={e=>setSrch(e.target.value)} placeholder="🔍 Buscar o escanear código de barras..." style={{width:"100%",boxSizing:"border-box",marginBottom:12}}/>
          <div style={{display:"flex",gap:5,flexWrap:"wrap",marginBottom:12}}>
            {[...new Set(inv.map(i=>i.cat))].map(cat=>(
              <button key={cat} onClick={()=>setSrch(srch===cat?"":cat)} style={{padding:"3px 9px",borderRadius:20,border:`1px solid ${C.border}`,background:srch===cat?BRAND.primary+"20":"transparent",color:srch===cat?BRAND.secondary:C.textMid,fontSize:10,cursor:"pointer",fontWeight:700}}>{cat}</button>
            ))}
          </div>
          <div style={{display:"grid",gridTemplateColumns:"repeat(auto-fill,minmax(150px,1fr))",gap:8}}>
            {fil.map(item=>{
              const bajo=item.stock<item.min;const d=item.cad?dC(item.cad):999;const sin=item.stock===0;
              return(
                <Box key={item.id} onClick={sin?undefined:()=>add(item)} style={{padding:13,opacity:sin?.5:1,cursor:sin?"not-allowed":"pointer"}}>
                  <div style={{color:C.textDim,fontSize:9,letterSpacing:1,marginBottom:3}}>{item.sku}</div>
                  <div style={{color:C.text,fontSize:12,fontWeight:700,lineHeight:1.3,marginBottom:6}}>{item.name}</div>
                  <div style={{display:"flex",gap:4,flexWrap:"wrap",marginBottom:6}}>
                    {item.receta&&<Tag col={C.amber} sm>Rx</Tag>}
                    {item.ctrl&&<Tag col={C.red} sm>Ctrl</Tag>}
                    {item.tipo==="generico"&&<Tag col={C.teal} sm>Genérico</Tag>}
                  </div>
                  <div style={{display:"flex",justifyContent:"space-between",alignItems:"center"}}>
                    <span style={{color:ac,fontWeight:800,fontSize:16}}>{$(item.price)}</span>
                    <Tag col={sin?C.red:bajo?C.amber:C.green} sm>{sin?"Agotado":`${item.stock}`}</Tag>
                  </div>
                  {item.cad&&d<30&&<div style={{color:cC(d),fontSize:10,marginTop:5,fontWeight:700}}>⏱ {d}d</div>}
                </Box>
              );
            })}
          </div>
        </div>
        <div>
          <Box style={{padding:18}}>
            <div style={{color:C.text,fontWeight:800,fontSize:15,marginBottom:14,fontFamily:"'Plus Jakarta Sans',sans-serif"}}>🛒 Carrito</div>
            <div style={{marginBottom:12}}>
              <Inp value={tel} onChange={e=>buscar(e.target.value)} placeholder="📱 Teléfono — puntos FarmaCapital" style={{width:"100%",boxSizing:"border-box",fontSize:12}}/>
              {cli&&(
                <div style={{background:C.purpleDim,border:`1px solid ${C.purple}30`,borderRadius:8,padding:"8px 10px",marginTop:6}}>
                  <div style={{color:C.purple,fontWeight:700,fontSize:12}}>⭐ {cli.nombre}</div>
                  <div style={{color:C.textMid,fontSize:11}}>{cli.puntos} puntos FarmaCapital · {cli.nivel}</div>
                  {cli.cronica&&<div style={{color:C.amber,fontSize:10,marginTop:2}}>💊 {cli.cronica}</div>}
                </div>
              )}
            </div>
            {!cart.length?(
              <div style={{color:C.textDim,textAlign:"center",padding:"28px 0",fontSize:13}}>Agrega productos</div>
            ):(
              <>
                {cart.map(c=>(
                  <div key={c.sku} style={{marginBottom:10,paddingBottom:10,borderBottom:`1px solid ${C.border}`}}>
                    <div style={{display:"flex",justifyContent:"space-between",gap:6}}>
                      <div style={{flex:1,minWidth:0}}>
                        <div style={{color:C.text,fontSize:12,fontWeight:700}}>{c.name}</div>
                        {c.rxI&&<div style={{color:C.amber,fontSize:10,marginTop:2}}>⚕ {c.rxI.receta}</div>}
                      </div>
                      <button onClick={()=>rm(c.sku)} style={{background:"none",border:"none",color:C.red,cursor:"pointer",fontSize:16,padding:0}}>×</button>
                    </div>
                    <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginTop:6}}>
                      <div style={{display:"flex",alignItems:"center",gap:6}}>
                        <button onClick={()=>upd(c.sku,-1)} style={{background:C.border,border:"none",color:C.text,width:22,height:22,borderRadius:4,cursor:"pointer",fontSize:14}}>−</button>
                        <span style={{color:C.text,fontSize:13,fontWeight:700,minWidth:20,textAlign:"center"}}>{c.qty}</span>
                        <button onClick={()=>upd(c.sku,1)} style={{background:C.border,border:"none",color:C.text,width:22,height:22,borderRadius:4,cursor:"pointer",fontSize:14}}>+</button>
                      </div>
                      <span style={{color:ac,fontWeight:800,fontSize:14}}>{$(c.price*c.qty)}</span>
                    </div>
                  </div>
                ))}
                {cli&&cli.puntos>0&&(
                  <div style={{background:C.purpleDim,border:`1px solid ${C.purple}30`,borderRadius:8,padding:"10px 12px",marginBottom:12}}>
                    <div style={{color:C.purple,fontSize:12,fontWeight:700,marginBottom:6}}>⭐ Canjear puntos FarmaCapital</div>
                    <div style={{display:"flex",gap:6,alignItems:"center"}}>
                      <Inp value={ptsC} onChange={e=>setPtsC(Math.min(Number(e.target.value),cli.puntos))} type="number" style={{width:70,fontSize:12,padding:"6px 10px"}}/>
                      <span style={{color:C.textMid,fontSize:12}}>= {$(ptsC*0.5)} desc.</span>
                    </div>
                    <div style={{color:C.textDim,fontSize:10,marginTop:4}}>⚠ No aplica en productos con descuento previo</div>
                  </div>
                )}
                <div style={{borderTop:`1px solid ${C.border}`,paddingTop:10,marginBottom:12}}>
                  {dPts>0&&<><div style={{display:"flex",justifyContent:"space-between",marginBottom:4}}><span style={{color:C.textMid,fontSize:12}}>Subtotal</span><span style={{color:C.text,fontSize:12}}>{$(sub)}</span></div><div style={{display:"flex",justifyContent:"space-between",marginBottom:6}}><span style={{color:C.purple,fontSize:12}}>Desc. puntos</span><span style={{color:C.purple,fontSize:12}}>−{$(dPts)}</span></div></>}
                  <div style={{display:"flex",justifyContent:"space-between",alignItems:"center"}}>
                    <span style={{color:C.textMid,fontSize:14}}>Total</span>
                    <span style={{color:ac,fontWeight:900,fontSize:22,fontFamily:"'Plus Jakarta Sans',sans-serif"}}>{$(total)}</span>
                  </div>
                  {cli&&<div style={{color:C.purple,fontSize:11,fontWeight:700,marginTop:4}}>+{ptsG} puntos FarmaCapital al pagar</div>}
                </div>
                <div style={{display:"flex",gap:5,marginBottom:12}}>
                  {["Efectivo","Tarjeta","OXXO"].map(p=>(
                    <button key={p} onClick={()=>setPay(p)} style={{flex:1,padding:"6px 2px",borderRadius:6,border:`1px solid ${pay===p?ac:C.border}`,background:pay===p?ac+"20":"transparent",color:pay===p?ac:C.textMid,cursor:"pointer",fontSize:9,fontWeight:700}}>{p}</button>
                  ))}
                </div>
                <Btn onClick={cobrar} col={ac} full>Cobrar {$(total)} 🖨️</Btn>
              </>
            )}
          </Box>
          {ticket&&(
            <Box ac={C.green} style={{padding:18,marginTop:12}}>
              <div style={{color:C.green,fontWeight:800,fontSize:13,marginBottom:8}}>✅ Ticket #{String(ticket.id).slice(-4)}</div>
              <div style={{color:C.textMid,fontSize:11,marginBottom:8}}>{new Date().toLocaleString("es-MX")}</div>
              {ticket.items.map(i=>(
                <div key={i.sku} style={{display:"flex",justifyContent:"space-between",fontSize:11,color:C.textMid,marginBottom:4}}>
                  <span>{i.name} ×{i.qty}</span><span>{$(i.price*i.qty)}</span>
                </div>
              ))}
              <div style={{borderTop:`1px solid ${C.border}`,marginTop:8,paddingTop:8}}>
                {ticket.dPts>0&&<div style={{display:"flex",justifyContent:"space-between",fontSize:11,color:C.purple,marginBottom:4}}><span>Desc. puntos</span><span>−{$(ticket.dPts)}</span></div>}
                <div style={{display:"flex",justifyContent:"space-between",marginBottom:6}}><span style={{color:C.textMid,fontSize:13}}>TOTAL</span><span style={{color:C.green,fontWeight:900,fontSize:16}}>{$(ticket.total)}</span></div>
                <div style={{color:C.textMid,fontSize:11}}>Pago: {ticket.pay}</div>
                {ticket.cli&&<div style={{color:C.purple,fontSize:11,fontWeight:700,marginTop:4}}>⭐ +{ticket.ptsG} puntos FarmaCapital → {ticket.cli.nombre}</div>}
              </div>
              <div style={{marginTop:10,paddingTop:10,borderTop:`1px solid ${C.border}`,textAlign:"center"}}>
                <div style={{color:C.textDim,fontSize:10}}>FarmaCapital · Chinampac de Juárez · CDMX</div>
                <div style={{color:C.textDim,fontSize:10}}>Luis Ventura QFB · COFEPRIS</div>
              </div>
            </Box>
          )}
        </div>
      </div>
    </div>
  );
}

// ── INVENTARIO ────────────────────────────────────────────────
function Inventario({negocio}){
  const inv=negocio==="farmacia"?INV_F:INV_M;
  const ac=NEG[negocio].color;
  const [fE,setFE]=useState("todos");const [fA,setFA]=useState("todos");
  const [fC,setFC]=useState(false);const [busq,setBusq]=useState("");const [tabla,setTabla]=useState(false);
  const fil=inv.filter(i=>!busq||i.name.toLowerCase().includes(busq.toLowerCase())||i.sku.toLowerCase().includes(busq.toLowerCase())).filter(i=>fE==="todos"||(fE==="bajo"&&i.stock<i.min)||(fE==="ok"&&i.stock>=i.min)||(fE==="cad"&&i.cad&&dC(i.cad)<30)).filter(i=>fA==="todos"||abc(i)===fA).filter(i=>!fC||i.ctrl);
  return(
    <div>
      <H2 sub={`${inv.length} SKUs · ${NEG[negocio].label}`} action={<div style={{display:"flex",gap:8}}><Btn onClick={()=>setTabla(!tabla)} ol col={ac} sm>{tabla?"Cards":"Tabla"}</Btn><Btn col={ac} sm>+ Agregar</Btn></div>}>Inventario</H2>
      <div style={{display:"flex",gap:12,marginBottom:20,flexWrap:"wrap"}}>
        <KPI label="Total SKUs" value={inv.length} icon="📦" col={ac}/>
        <KPI label="Bajo stock" value={inv.filter(i=>i.stock<i.min).length} icon="⚠️" col={inv.filter(i=>i.stock<i.min).length>0?C.red:C.green}/>
        <KPI label="Valor inv." value={$(inv.reduce((a,i)=>a+i.stock*i.cost,0))} icon="💰" col={C.teal}/>
        {negocio==="farmacia"&&<KPI label="Por caducar" value={inv.filter(i=>i.cad&&dC(i.cad)<30).length} icon="⏱" col={C.amber}/>}
        {negocio==="farmacia"&&<KPI label="Controlados" value={inv.filter(i=>i.ctrl).length} icon="⚕" col={C.purple}/>}
      </div>
      <div style={{display:"flex",gap:8,flexWrap:"wrap",marginBottom:16,alignItems:"center"}}>
        <Inp value={busq} onChange={e=>setBusq(e.target.value)} placeholder="🔍 Buscar..." style={{width:200}}/>
        {[["todos","Todos"],["bajo","⚠ Bajo"],["ok","✓ OK"],...(negocio==="farmacia"?[["cad","⏱ Cad."]]:[])].map(([v,l])=>(
          <Btn key={v} ol={fE!==v} col={ac} sm onClick={()=>setFE(v)}>{l}</Btn>
        ))}
        {["todos","A","B","C"].map(c=>(<Btn key={c} ol={fA!==c} col={C.purple} sm onClick={()=>setFA(c)}>{c==="todos"?"ABC":`Clase ${c}`}</Btn>))}
        {negocio==="farmacia"&&<Btn ol={!fC} col={C.red} sm onClick={()=>setFC(!fC)}>⚕ Ctrl</Btn>}
      </div>
      {tabla?(
        <Box style={{overflow:"hidden"}}>
          <div style={{overflowX:"auto"}}>
            <table style={{width:"100%",borderCollapse:"collapse"}}>
              <thead><tr style={{borderBottom:`1px solid ${C.border}`}}>
                {["SKU","Producto","Cat","Stock","Mín",...(negocio==="farmacia"?["Lote","Caducidad"]:[]),"Precio","Costo","Margen","ABC","Estado"].map(h=>(
                  <th key={h} style={{padding:"9px 12px",color:C.textDim,fontSize:9,textAlign:"left",letterSpacing:1.5,textTransform:"uppercase",whiteSpace:"nowrap"}}>{h}</th>
                ))}
              </tr></thead>
              <tbody>
                {fil.map((item,i)=>{
                  const bajo=item.stock<item.min;const d=item.cad?dC(item.cad):999;
                  const A=abc(item);const mg=Math.round(((item.price-item.cost)/item.price)*100);
                  return(
                    <tr key={item.id} style={{borderBottom:`1px solid ${C.border}`,background:i%2===0?"transparent":C.bg+"60"}}>
                      <td style={{padding:"8px 12px",color:C.textMid,fontSize:11}}>{item.sku}</td>
                      <td style={{padding:"8px 12px",color:C.text,fontSize:12,fontWeight:600}}>{item.name}{item.ctrl&&<span style={{marginLeft:4}}><Tag col={C.red} sm>Ctrl</Tag></span>}</td>
                      <td style={{padding:"8px 12px",color:C.textMid,fontSize:11}}>{item.cat}</td>
                      <td style={{padding:"8px 12px"}}><span style={{color:bajo?C.red:ac,fontWeight:800}}>{item.stock}</span></td>
                      <td style={{padding:"8px 12px",color:C.textDim,fontSize:11}}>{item.min}</td>
                      {negocio==="farmacia"&&<><td style={{padding:"8px 12px",color:C.textMid,fontSize:11}}>{item.lote}</td><td style={{padding:"8px 12px"}}><span style={{color:cC(d),fontSize:11,fontWeight:700}}>{item.cad}{d<30&&` (${d}d)`}</span></td></>}
                      <td style={{padding:"8px 12px",color:ac,fontWeight:700}}>{$(item.price)}</td>
                      <td style={{padding:"8px 12px",color:C.textMid,fontSize:11}}>{$(item.cost)}</td>
                      <td style={{padding:"8px 12px"}}><Tag col={mg>40?C.green:mg>25?C.amber:C.red} sm>{mg}%</Tag></td>
                      <td style={{padding:"8px 12px"}}><Tag col={aCol(A)} sm>{A}</Tag></td>
                      <td style={{padding:"8px 12px"}}><Tag col={bajo?C.red:C.green} sm>{bajo?"Reordenar":"OK"}</Tag></td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </Box>
      ):(
        <div style={{display:"grid",gridTemplateColumns:"repeat(auto-fill,minmax(210px,1fr))",gap:10}}>
          {fil.map(item=>{
            const bajo=item.stock<item.min;const d=item.cad?dC(item.cad):999;
            const A=abc(item);const mg=Math.round(((item.price-item.cost)/item.price)*100);
            return(
              <Box key={item.id} style={{padding:14}}>
                <div style={{display:"flex",justifyContent:"space-between",marginBottom:6}}><div style={{color:C.textDim,fontSize:9,letterSpacing:1}}>{item.sku}</div><Tag col={aCol(A)} sm>ABC-{A}</Tag></div>
                <div style={{color:C.text,fontSize:13,fontWeight:700,marginBottom:8,lineHeight:1.3}}>{item.name}</div>
                <div style={{display:"flex",gap:4,flexWrap:"wrap",marginBottom:8}}>{item.ctrl&&<Tag col={C.red} sm>Ctrl</Tag>}{item.receta&&<Tag col={C.amber} sm>Rx</Tag>}{item.tipo&&<Tag col={C.teal} sm>{item.tipo}</Tag>}</div>
                <div style={{display:"grid",gridTemplateColumns:"1fr 1fr",gap:6,marginBottom:8}}>
                  <div style={{background:C.bg,borderRadius:6,padding:"7px 9px"}}><div style={{color:C.textDim,fontSize:9,marginBottom:1}}>STOCK</div><div style={{color:bajo?C.red:ac,fontWeight:800,fontSize:16}}>{item.stock}</div><div style={{color:C.textDim,fontSize:9}}>mín:{item.min}</div></div>
                  <div style={{background:C.bg,borderRadius:6,padding:"7px 9px"}}><div style={{color:C.textDim,fontSize:9,marginBottom:1}}>PRECIO</div><div style={{color:ac,fontWeight:800,fontSize:15}}>{$(item.price)}</div><div style={{color:C.textDim,fontSize:9}}>mg:{mg}%</div></div>
                </div>
                {item.cad&&<div style={{color:cC(d),fontSize:11,fontWeight:700,marginBottom:4}}>⏱ {d<0?"CADUCADO":`${item.cad} (${d}d)`}</div>}
                {item.prov&&<div style={{color:C.textMid,fontSize:10,marginBottom:8}}>Prov: {item.prov}</div>}
                <div style={{display:"flex",gap:5}}><Btn sm ol col={ac}>Editar</Btn>{bajo&&<Btn sm col={C.amber}>Reordenar</Btn>}</div>
              </Box>
            );
          })}
        </div>
      )}
    </div>
  );
}

// ── COFEPRIS ──────────────────────────────────────────────────
function COFEPRIS(){
  const [tab,setTab]=useState("bitacora");const [modal,setModal]=useState(false);
  const [nv,setNv]=useState({med:"",lote:"",qty:1,receta:"",medico:"",paciente:"",tel:""});
  return(
    <div>
      <H2 sub="Responsable sanitario: Luis Ventura QFB · FarmaCapital" action={<Btn sm col={C.amber} onClick={()=>setModal(true)}>+ Nuevo registro</Btn>}>⚕ Panel COFEPRIS</H2>
      <div style={{display:"flex",gap:12,marginBottom:20,flexWrap:"wrap"}}>
        <KPI label="Registros hoy" value={BITACORA_D.filter(b=>b.fecha==="2026-04-12").length} icon="📋" col={C.blue}/>
        <KPI label="Antibióticos"  value={INV_F.filter(i=>i.cat==="Antibiótico").length}       icon="⚕"  col={C.amber}/>
        <KPI label="Controlados"   value={INV_F.filter(i=>i.ctrl).length}                      icon="🔒" col={C.purple}/>
        <KPI label="SICAD"         value="Activo"                                              icon="✅"  col={C.green}/>
      </div>
      <Modal open={modal} onClose={()=>setModal(false)} title="➕ Nuevo registro COFEPRIS — FarmaCapital" ac={C.amber}>
        {[["Medicamento","med","Nombre"],["Lote","lote","L24-XX"],["Receta","receta","RX-XXX"],["Médico","medico","Dr. Nombre"],["Paciente","paciente","Nombre completo"],["Teléfono","tel","55XXXXXXXX"]].map(([l,k,ph])=>(
          <div key={k} style={{marginBottom:12}}><div style={{color:C.textMid,fontSize:11,marginBottom:4}}>{l}</div><Inp value={nv[k]} onChange={e=>setNv(p=>({...p,[k]:e.target.value}))} placeholder={ph} style={{width:"100%",boxSizing:"border-box"}}/></div>
        ))}
        <div style={{background:C.amberDim,border:`1px solid ${C.amber}30`,borderRadius:8,padding:"10px 12px",marginBottom:14}}><div style={{color:C.amber,fontSize:11}}>Se enviará al sistema SICAD de COFEPRIS automáticamente.</div></div>
        <Btn col={C.amber} onClick={()=>setModal(false)}>✓ Guardar en bitácora</Btn>
      </Modal>
      <div style={{display:"flex",gap:8,marginBottom:20}}>
        {[["bitacora","📋 Bitácora"],["controlados","⚕ Controlados"],["alertas","🚨 Alertas"]].map(([v,l])=>(
          <Btn key={v} sm ol={tab!==v} col={BRAND.primary} onClick={()=>setTab(v)}>{l}</Btn>
        ))}
      </div>
      {tab==="bitacora"&&(
        <Box style={{overflow:"hidden"}}>
          <div style={{padding:"14px 18px",borderBottom:`1px solid ${C.border}`,display:"flex",justifyContent:"space-between",alignItems:"center"}}>
            <div style={{color:C.text,fontWeight:700,fontSize:13}}>Bitácora SICAD — Antibióticos y controlados · FarmaCapital</div>
            <Btn sm ol col={BRAND.primary}>Exportar PDF</Btn>
          </div>
          <div style={{overflowX:"auto"}}>
            <table style={{width:"100%",borderCollapse:"collapse"}}>
              <thead><tr style={{borderBottom:`1px solid ${C.border}`}}>
                {["Fecha","Medicamento","Lote","Cant.","Receta","Médico","Paciente","Tel.","Empleado"].map(h=>(
                  <th key={h} style={{padding:"9px 12px",color:C.textDim,fontSize:9,textAlign:"left",letterSpacing:1.5,textTransform:"uppercase",whiteSpace:"nowrap"}}>{h}</th>
                ))}
              </tr></thead>
              <tbody>
                {BITACORA_D.map((r,i)=>(
                  <tr key={r.id} style={{borderBottom:`1px solid ${C.border}`,background:i%2===0?"transparent":C.bg+"60"}}>
                    <td style={{padding:"8px 12px",color:C.textMid,fontSize:11}}>{r.fecha}</td>
                    <td style={{padding:"8px 12px",color:C.text,fontSize:12,fontWeight:600}}>{r.med}</td>
                    <td style={{padding:"8px 12px",color:C.textMid,fontSize:11}}>{r.lote}</td>
                    <td style={{padding:"8px 12px",color:BRAND.secondary,fontWeight:700}}>{r.qty}</td>
                    <td style={{padding:"8px 12px"}}><Tag col={C.amber} sm>{r.receta}</Tag></td>
                    <td style={{padding:"8px 12px",color:C.textMid,fontSize:11}}>{r.medico}</td>
                    <td style={{padding:"8px 12px",color:C.text,fontSize:11}}>{r.paciente}</td>
                    <td style={{padding:"8px 12px",color:C.textMid,fontSize:11}}>{r.tel}</td>
                    <td style={{padding:"8px 12px",color:C.textMid,fontSize:11}}>{r.emp}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </Box>
      )}
      {tab==="controlados"&&(
        <div style={{display:"grid",gridTemplateColumns:"repeat(auto-fill,minmax(250px,1fr))",gap:12}}>
          {INV_F.filter(i=>i.ctrl).map(item=>(
            <Box key={item.id} ac={C.purple} style={{padding:16}}>
              <div style={{display:"flex",justifyContent:"space-between",marginBottom:8}}><Tag col={C.purple} sm>Controlado</Tag>{item.receta&&<Tag col={C.amber} sm>Requiere Rx</Tag>}</div>
              <div style={{color:C.text,fontWeight:700,fontSize:14,marginBottom:4}}>{item.name}</div>
              <div style={{color:C.textMid,fontSize:12,marginBottom:10}}>{item.cat} · {item.sku}</div>
              <div style={{display:"grid",gridTemplateColumns:"1fr 1fr",gap:8}}>
                <div style={{background:C.bg,borderRadius:6,padding:"8px 10px"}}><div style={{color:C.textDim,fontSize:9}}>STOCK</div><div style={{color:item.stock<item.min?C.red:C.green,fontWeight:800,fontSize:18}}>{item.stock}</div></div>
                <div style={{background:C.bg,borderRadius:6,padding:"8px 10px"}}><div style={{color:C.textDim,fontSize:9}}>LOTE</div><div style={{color:C.text,fontWeight:700,fontSize:12}}>{item.lote}</div></div>
              </div>
            </Box>
          ))}
        </div>
      )}
      {tab==="alertas"&&(
        <div style={{display:"grid",gap:12}}>
          {[{t:"error",title:"Omeprazol 20mg — Stock crítico",desc:"3 uds. Mínimo 15. Reordenar urgente con Casa Saba."},
            {t:"error",title:"Paracetamol 500mg — Bajo stock",desc:"8 uds. Mínimo 20. Pedir a Nadro."},
            {t:"warning",title:"Loratadina 10mg — Caducidad próxima",desc:"Lote L24-07 caduca 31 Dic 2025. Rotar FIFO."},
            {t:"ok",title:"Bitácora SICAD al día",desc:"Todos los antibióticos dispensados están registrados correctamente."},
            {t:"ok",title:"Licencia sanitaria FarmaCapital vigente",desc:"Sin observaciones. Responsable: Luis Ventura QFB."},
          ].map((a,i)=>{
            const col=a.t==="error"?C.red:a.t==="warning"?C.amber:C.green;
            return(<Box key={i} ac={col} style={{padding:"16px 20px"}}><div style={{display:"flex",gap:12,alignItems:"flex-start"}}><div style={{fontSize:20}}>{a.t==="error"?"🚨":a.t==="warning"?"⚠️":"✅"}</div><div><div style={{color:C.text,fontWeight:700,fontSize:13}}>{a.title}</div><div style={{color:C.textMid,fontSize:12,marginTop:4}}>{a.desc}</div></div></div></Box>);
          })}
        </div>
      )}
    </div>
  );
}

// ── CORTE DE CAJA ─────────────────────────────────────────────
function CorteCaja({negocio}){
  const ac=NEG[negocio].color;const [ef,setEf]=useState("");
  const totDia=CORTES_D.reduce((a,c)=>a+c.total,0);
  const totEf=CORTES_D.reduce((a,c)=>a+c.ef_dec,0);
  const totTar=CORTES_D.reduce((a,c)=>a+c.tar,0);
  const totServ=CORTES_D.reduce((a,c)=>a+c.serv,0);
  const difs=CORTES_D.filter(c=>c.dif!==0).length;
  return(
    <div>
      <H2 sub={`Dom 12 Abr 2026 · ${NEG[negocio].label}`}>⊞ Corte de Caja</H2>
      <div style={{display:"flex",gap:12,marginBottom:20,flexWrap:"wrap"}}>
        <KPI label="Total día"   value={$(totDia)}  icon="💵" col={ac}/>
        <KPI label="Efectivo"    value={$(totEf)}   icon="💴" col={C.green}/>
        <KPI label="Tarjeta"     value={$(totTar)}  icon="💳" col={BRAND.secondary}/>
        <KPI label="Servicios"   value={$(totServ)} icon="🔌" col={C.teal}/>
        <KPI label="Diferencias" value={difs}       icon="⚠️" col={difs>0?C.red:C.green} sub={difs>0?"Revisar":"Cuadrado"}/>
      </div>
      <div style={{display:"grid",gap:14,marginBottom:20}}>
        {CORTES_D.map((c,i)=>(
          <Box key={i} ac={c.dif!==0?C.red:C.green} style={{padding:20}}>
            <div style={{display:"flex",justifyContent:"space-between",alignItems:"flex-start",marginBottom:16}}>
              <div><div style={{color:C.text,fontWeight:800,fontSize:15}}>Turno {c.turno}</div><div style={{color:C.textMid,fontSize:12,marginTop:2}}>{c.emp} · {c.ap}–{c.ci}</div></div>
              <Tag col={c.dif!==0?C.red:C.green}>{c.dif!==0?`⚠ Dif. ${$(Math.abs(c.dif))}`:"✓ Cuadrado"}</Tag>
            </div>
            <div style={{display:"grid",gridTemplateColumns:"repeat(4,1fr)",gap:10,marginBottom:14}}>
              {[["Ef. declarado",c.ef_dec,C.green],["Sistema",c.ef_sis,C.textMid],["Tarjeta",c.tar,BRAND.secondary],["Servicios",c.serv,C.teal]].map(([l,v,col])=>(
                <div key={l} style={{background:C.bg,borderRadius:8,padding:"10px 12px"}}><div style={{color:C.textDim,fontSize:9,letterSpacing:1,textTransform:"uppercase",marginBottom:4}}>{l}</div><div style={{color:col,fontWeight:800,fontSize:16}}>{$(v)}</div></div>
              ))}
            </div>
            <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",borderTop:`1px solid ${C.border}`,paddingTop:12}}>
              <div style={{color:C.textMid,fontSize:13}}>Total turno</div>
              <div style={{color:ac,fontWeight:900,fontSize:20,fontFamily:"'Plus Jakarta Sans',sans-serif"}}>{$(c.total)}</div>
            </div>
            {c.dif!==0&&<div style={{background:C.redDim,border:`1px solid ${C.red}30`,borderRadius:8,padding:"10px 12px",marginTop:12}}><div style={{color:C.red,fontWeight:700,fontSize:12}}>⚠ Diferencia {$(Math.abs(c.dif))} — Revisar con {c.emp}</div></div>}
          </Box>
        ))}
      </div>
      <Box ac={ac} style={{padding:20}}>
        <div style={{color:C.text,fontWeight:700,fontSize:14,marginBottom:14}}>Iniciar corte de turno</div>
        <div style={{display:"grid",gridTemplateColumns:"1fr 1fr",gap:12,marginBottom:12}}>
          <div><div style={{color:C.textMid,fontSize:11,marginBottom:4}}>Efectivo contado en caja</div><Inp value={ef} onChange={e=>setEf(e.target.value)} placeholder="$0.00" type="number" style={{width:"100%",boxSizing:"border-box"}}/></div>
          <div><div style={{color:C.textMid,fontSize:11,marginBottom:4}}>Empleado que cierra</div><select style={{background:C.bg,border:`1px solid ${C.border}`,borderRadius:8,color:C.text,padding:"9px 13px",fontSize:13,width:"100%",outline:"none"}}><option>María García</option><option>Juan Ramírez</option></select></div>
        </div>
        <div style={{display:"flex",gap:8}}>
          <Btn col={ac}>Corte ciego</Btn>
          <Btn ol col={ac}>Corte automático</Btn>
          <Btn ol col={BRAND.primary}>Exportar PDF</Btn>
        </div>
      </Box>
    </div>
  );
}

// ── CONSULTORIO ───────────────────────────────────────────────
function ConsDoctora({usuario}){
  const [tab,setTab]=useState("agenda");const [sel,setSel]=useState(null);
  const eCol={confirmada:C.green,pendiente:C.amber,libre:C.textDim,completada:BRAND.secondary};
  return(
    <div>
      <H2 sub="Doctora · Consultorio FarmaCapital · Chinampac de Juárez" action={<Btn sm col={BRAND.primary}>+ Nueva cita</Btn>}>♥ Consultorio</H2>
      <div style={{display:"flex",gap:12,marginBottom:20,flexWrap:"wrap"}}>
        <KPI label="Citas hoy"   value={AGENDA_D.filter(a=>a.estado!=="libre").length} icon="📅" col={BRAND.primary}/>
        <KPI label="Completadas" value={AGENDA_D.filter(a=>a.estado==="completada").length} icon="✅" col={C.green}/>
        <KPI label="Pendientes"  value={AGENDA_D.filter(a=>a.estado==="pendiente").length} icon="⏳" col={C.amber}/>
        <KPI label="Expedientes" value={EXP_D.length} icon="📋" col={C.purple}/>
        <KPI label="Ingreso hoy" value="$1,200" icon="💵" col={C.teal} sub="4 × $300"/>
      </div>
      <div style={{display:"flex",gap:8,marginBottom:20}}>
        {[["agenda","📅 Agenda"],["expedientes","📋 Expedientes"],["recetas","💊 Recetas"]].map(([v,l])=>(
          <Btn key={v} sm ol={tab!==v} col={BRAND.primary} onClick={()=>setTab(v)}>{l}</Btn>
        ))}
      </div>
      {tab==="agenda"&&(
        <div style={{display:"grid",gridTemplateColumns:"1fr 1fr",gap:12}}>
          {AGENDA_D.map(cita=>(
            <Box key={cita.id} ac={eCol[cita.estado]} style={{padding:16}}>
              <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:8}}>
                <div style={{color:eCol[cita.estado],fontWeight:800,fontSize:16}}>{cita.hora}</div>
                <Tag col={eCol[cita.estado]}>{cita.estado}</Tag>
              </div>
              <div style={{color:C.text,fontWeight:700,fontSize:14}}>{cita.pac}</div>
              {cita.motivo&&<div style={{color:C.textMid,fontSize:12,marginTop:4}}>{cita.motivo}</div>}
              {cita.estado!=="libre"&&cita.estado!=="completada"&&(<div style={{display:"flex",gap:6,marginTop:10}}><Btn sm col={C.green}>Iniciar</Btn><Btn sm ol col={C.red}>Cancelar</Btn></div>)}
            </Box>
          ))}
        </div>
      )}
      {tab==="expedientes"&&(
        <div style={{display:"grid",gap:12}}>
          {EXP_D.map(exp=>(
            <Box key={exp.id} style={{padding:18}} onClick={()=>setSel(sel===exp?null:exp)}>
              <div style={{display:"flex",justifyContent:"space-between",alignItems:"flex-start"}}>
                <div><div style={{color:C.text,fontWeight:800,fontSize:15}}>{exp.nombre}</div><div style={{color:C.textMid,fontSize:12,marginTop:2}}>{exp.edad} años · {exp.tel}</div></div>
                <Tag col={BRAND.secondary}>{exp.dx}</Tag>
              </div>
              {sel===exp&&(
                <div style={{marginTop:14,paddingTop:14,borderTop:`1px solid ${C.border}`}}>
                  <div style={{display:"grid",gridTemplateColumns:"1fr 1fr",gap:10,marginBottom:12}}>
                    {[["Última consulta",exp.ultima],["Próxima cita",exp.proxima||"Sin agendar"],["Alergias",exp.alergias],["Medicamentos",exp.meds.join(", ")||"Ninguno"]].map(([l,v])=>(
                      <div key={l} style={{background:C.bg,borderRadius:8,padding:"9px 11px"}}><div style={{color:C.textDim,fontSize:9,letterSpacing:1,textTransform:"uppercase",marginBottom:3}}>{l}</div><div style={{color:C.text,fontSize:12,fontWeight:600}}>{v}</div></div>
                    ))}
                  </div>
                  <div style={{background:C.bg,borderRadius:8,padding:"9px 11px",marginBottom:12}}><div style={{color:C.textDim,fontSize:9,letterSpacing:1,textTransform:"uppercase",marginBottom:3}}>Notas</div><div style={{color:C.textMid,fontSize:12}}>{exp.notas}</div></div>
                  <div style={{display:"flex",gap:8}}><Btn sm col={BRAND.primary}>Editar</Btn><Btn sm ol col={BRAND.primary}>Receta</Btn><Btn sm ol col={C.green}>Agendar</Btn></div>
                </div>
              )}
            </Box>
          ))}
        </div>
      )}
      {tab==="recetas"&&(<Box style={{padding:24}}><div style={{color:C.textMid,fontSize:14,textAlign:"center",padding:"20px 0"}}>📋 Las recetas se generan digitalmente y la doctora las firma a mano.<br/><br/><Btn col={BRAND.primary}>+ Crear receta digital</Btn></div></Box>)}
    </div>
  );
}

// ── CLIENTES & PUNTOS ─────────────────────────────────────────
function ClientesPuntos(){
  const [tab,setTab]=useState("clientes");const [busq,setBusq]=useState("");
  const fil=CLIENTES_D.filter(c=>c.nombre.toLowerCase().includes(busq.toLowerCase())||c.tel.includes(busq));
  const totPts=CLIENTES_D.reduce((a,c)=>a+c.puntos,0);
  return(
    <div>
      <H2 sub="Programa de lealtad válido en FarmaCapital, Minisuper y Consultorio" action={<Btn sm col={C.purple}>+ Nuevo cliente</Btn>}>⭐ Clientes & Puntos FarmaCapital</H2>
      <div style={{display:"flex",gap:12,marginBottom:20,flexWrap:"wrap"}}>
        <KPI label="Clientes"       value={CLIENTES_D.length}   icon="👥" col={C.purple}/>
        <KPI label="Ptos. activos"  value={totPts.toLocaleString()} icon="⭐" col={C.amber} sub={`= ${$(totPts*0.5)} valor`}/>
        <KPI label="Gold"           value={CLIENTES_D.filter(c=>c.nivel==="Gold").length} icon="🥇" col={C.amber}/>
        <KPI label="Crónicos"       value={CLIENTES_D.filter(c=>c.cronica).length} icon="💊" col={BRAND.secondary} sub="WhatsApp auto"/>
      </div>
      <Box style={{padding:"14px 18px",marginBottom:20}}>
        <div style={{color:C.text,fontWeight:700,fontSize:13,marginBottom:12}}>⭐ Reglas Puntos FarmaCapital</div>
        <div style={{display:"grid",gridTemplateColumns:"1fr 1fr",gap:16}}>
          <div>
            <div style={{color:C.textMid,fontSize:10,fontWeight:700,marginBottom:8,textTransform:"uppercase",letterSpacing:1}}>Acumulas</div>
            {[["$10 en FarmaCapital (precio normal)","1 pto"],["$10 en minisuper","1 pto"],["Consulta médica","5 ptos"],["Registro nuevo","10 ptos"],["Compra en línea","1.5× ptos"],["Cumpleaños","2× ese mes"],["❌ Prod. con descuento","0 ptos"]].map(([a,b])=>(
              <div key={a} style={{display:"flex",justifyContent:"space-between",marginBottom:4}}><span style={{color:C.textMid,fontSize:11}}>{a}</span><span style={{color:a.startsWith("❌")?C.red:C.amber,fontWeight:700,fontSize:11}}>{b}</span></div>
            ))}
          </div>
          <div>
            <div style={{color:C.textMid,fontSize:10,fontWeight:700,marginBottom:8,textTransform:"uppercase",letterSpacing:1}}>Canjeas</div>
            {[["20 ptos","$10 desc. FarmaCapital"],["50 ptos","Envío gratis online"],["100 ptos","$50 descuento"],["160 ptos","Consulta gratis"],["200 ptos","Producto gratis"]].map(([p,b])=>(
              <div key={p} style={{display:"flex",justifyContent:"space-between",marginBottom:4}}><Tag col={C.purple} sm>{p}</Tag><span style={{color:C.textMid,fontSize:11}}>{b}</span></div>
            ))}
            <div style={{color:C.textDim,fontSize:10,marginTop:6}}>1 pto = $0.50 · Vencen a 12 meses</div>
          </div>
        </div>
      </Box>
      <div style={{display:"flex",gap:8,marginBottom:16}}>
        {[["clientes","👥 Clientes"],["whatsapp","📲 WhatsApp auto"]].map(([v,l])=>(<Btn key={v} sm ol={tab!==v} col={C.purple} onClick={()=>setTab(v)}>{l}</Btn>))}
        <div style={{marginLeft:"auto"}}><Inp value={busq} onChange={e=>setBusq(e.target.value)} placeholder="🔍 Buscar..." style={{width:180}}/></div>
      </div>
      {tab==="clientes"&&(
        <div style={{display:"grid",gridTemplateColumns:"repeat(auto-fill,minmax(270px,1fr))",gap:12}}>
          {fil.map(c=>(
            <Box key={c.id} style={{padding:16}}>
              <div style={{display:"flex",justifyContent:"space-between",alignItems:"flex-start",marginBottom:10}}>
                <div style={{display:"flex",alignItems:"center",gap:10}}>
                  <div style={{width:40,height:40,borderRadius:"50%",background:BRAND.gradient,display:"flex",alignItems:"center",justifyContent:"center",color:"#fff",fontWeight:800,fontSize:16}}>{c.nombre[0]}</div>
                  <div><div style={{color:C.text,fontWeight:700,fontSize:13}}>{c.nombre}</div><div style={{color:C.textMid,fontSize:11}}>{c.tel}</div></div>
                </div>
                <Tag col={nCol(c.nivel)}>{c.nivel}</Tag>
              </div>
              {c.cronica&&<div style={{background:C.blueDim,border:`1px solid ${BRAND.secondary}30`,borderRadius:6,padding:"5px 8px",marginBottom:10}}><span style={{color:BRAND.secondary,fontSize:10,fontWeight:700}}>💊 {c.cronica}</span></div>}
              <div style={{display:"grid",gridTemplateColumns:"1fr 1fr 1fr",gap:6,marginBottom:8}}>
                {[["Puntos",c.puntos,C.amber],["Visitas",c.visitas,BRAND.secondary],["Gastado",$(c.gasto),C.green]].map(([l,v,col])=>(
                  <div key={l} style={{background:C.bg,borderRadius:6,padding:"6px 8px",textAlign:"center"}}><div style={{color:C.textDim,fontSize:9}}>{l}</div><div style={{color:col,fontWeight:800,fontSize:13}}>{v}</div></div>
                ))}
              </div>
              <div style={{color:C.textDim,fontSize:10}}>Última compra: {c.ultimo}</div>
            </Box>
          ))}
        </div>
      )}
      {tab==="whatsapp"&&(
        <div style={{display:"grid",gap:10}}>
          {CLIENTES_D.filter(c=>c.cronica).map(c=>(
            <Box key={c.id} style={{padding:16}}>
              <div style={{display:"flex",justifyContent:"space-between",alignItems:"center"}}>
                <div><div style={{color:C.text,fontWeight:700,fontSize:13}}>{c.nombre}</div><div style={{color:C.textMid,fontSize:12,marginTop:2}}>Tratamiento: {c.cronica} · {c.tel}</div><div style={{color:C.textDim,fontSize:11,marginTop:2}}>Última compra: {c.ultimo}</div></div>
                <div style={{display:"flex",gap:8}}><Btn sm col={C.green}>📲 Enviar</Btn><Btn sm ol col={BRAND.primary}>Historial</Btn></div>
              </div>
            </Box>
          ))}
          <Box style={{padding:16}}>
            <div style={{color:C.text,fontWeight:700,fontSize:13,marginBottom:10}}>🔔 Plantilla automática FarmaCapital</div>
            <div style={{background:C.bg,borderRadius:8,padding:"12px 14px",color:C.textMid,fontSize:12,lineHeight:1.7}}>
              Hola [Nombre] 👋 Te recordamos de parte de <strong style={{color:C.text}}>FarmaCapital</strong> que tu [Medicamento] podría estar terminándose. Pásate o pídelo en línea en farmacapital.com.mx 💊 Tienes [X] puntos FarmaCapital. ¡Te esperamos! 🌟
            </div>
          </Box>
        </div>
      )}
    </div>
  );
}

// ── RRHH ──────────────────────────────────────────────────────
function RRHH({negocio}){
  const ac=NEG[negocio].color;const [tab,setTab]=useState("empleados");
  const dias=["Lun","Mar","Mié","Jue","Vie","Sáb","Dom"];
  const emps=[
    {id:"m",nombre:"María García",rol:"Cajera",  turno:"Matutino",  sueldo:7200,imss:1224,hor:["08-16","08-16","08-16","08-16","08-16","",""]},
    {id:"j",nombre:"Juan Ramírez",rol:"Auxiliar",turno:"Vespertino",sueldo:6800,imss:1156,hor:["14-22","14-22","14-22","14-22","14-22","",""]},
  ];
  return(
    <div>
      <H2 sub={NEG[negocio].label} action={<Btn sm col={ac}>+ Agregar</Btn>}>◑ Recursos Humanos</H2>
      <div style={{display:"flex",gap:12,marginBottom:20,flexWrap:"wrap"}}>
        <KPI label="Empleados"   value={emps.length} icon="👤" col={ac}/>
        <KPI label="Nómina/mes"  value={$(emps.reduce((a,e)=>a+e.sueldo,0))} icon="💵" col={C.green}/>
        <KPI label="Costo total" value={$(Math.round(emps.reduce((a,e)=>a+e.sueldo+e.imss,0)*1.15))} icon="📊" col={C.amber} sub="IMSS+prestaciones"/>
      </div>
      <div style={{display:"flex",gap:8,marginBottom:20}}>
        {[["empleados","👤 Empleados"],["horarios","📅 Horarios"],["nomina","💰 Nómina"]].map(([v,l])=>(<Btn key={v} sm ol={tab!==v} col={ac} onClick={()=>setTab(v)}>{l}</Btn>))}
        <div style={{marginLeft:"auto"}}><Btn sm col={ac}>+ Agregar</Btn></div>
      </div>
      {tab==="empleados"&&(
        <div style={{display:"grid",gridTemplateColumns:"1fr 1fr",gap:14}}>
          {emps.map(e=>(
            <Box key={e.id} style={{padding:20}}>
              <div style={{display:"flex",alignItems:"center",gap:12,marginBottom:14}}>
                <div style={{width:48,height:48,borderRadius:"50%",background:BRAND.gradient,display:"flex",alignItems:"center",justifyContent:"center",color:"#fff",fontWeight:800,fontSize:20}}>{e.nombre[0]}</div>
                <div style={{flex:1}}><div style={{color:C.text,fontWeight:800,fontSize:15}}>{e.nombre}</div><div style={{color:C.textMid,fontSize:12}}>{e.rol} · {e.turno}</div></div>
                <Tag col={C.green}>● Activo</Tag>
              </div>
              <div style={{display:"grid",gridTemplateColumns:"1fr 1fr",gap:8}}>
                {[["Sueldo base",$(e.sueldo)],["Horas/sem","40 hrs"],["IMSS est.",$(e.imss)],["Costo total",$(Math.round((e.sueldo+e.imss)*1.15))]].map(([l,v])=>(
                  <div key={l} style={{background:C.bg,borderRadius:8,padding:"9px 11px"}}><div style={{color:C.textDim,fontSize:9,letterSpacing:1,textTransform:"uppercase",marginBottom:3}}>{l}</div><div style={{color:C.text,fontWeight:700,fontSize:13}}>{v}</div></div>
                ))}
              </div>
            </Box>
          ))}
        </div>
      )}
      {tab==="horarios"&&(
        <Box style={{overflow:"hidden"}}>
          <div style={{overflowX:"auto"}}>
            <table style={{width:"100%",borderCollapse:"collapse"}}>
              <thead><tr style={{borderBottom:`1px solid ${C.border}`}}>
                <th style={{padding:"11px 16px",color:C.textDim,fontSize:9,textAlign:"left",letterSpacing:1.5,textTransform:"uppercase"}}>Empleado</th>
                {dias.map(d=><th key={d} style={{padding:"11px 10px",color:C.textDim,fontSize:9,textAlign:"center",letterSpacing:1.5,textTransform:"uppercase"}}>{d}</th>)}
              </tr></thead>
              <tbody>
                {emps.map(e=>(
                  <tr key={e.id} style={{borderBottom:`1px solid ${C.border}`}}>
                    <td style={{padding:"11px 16px",color:C.text,fontWeight:700,fontSize:13}}>{e.nombre}</td>
                    {dias.map((d,i)=>{const t=e.hor[i]||"";return(<td key={d} style={{padding:"8px",textAlign:"center"}}>{t?<div style={{background:BRAND.primary+"20",border:`1px solid ${BRAND.primary}40`,borderRadius:6,padding:"4px 5px",fontSize:10,color:BRAND.secondary,fontWeight:700}}>{t}</div>:<div style={{color:C.textDim,fontSize:14}}>—</div>}</td>);})}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </Box>
      )}
      {tab==="nomina"&&(
        <Box style={{overflow:"hidden"}}>
          <div style={{overflowX:"auto"}}>
            <table style={{width:"100%",borderCollapse:"collapse"}}>
              <thead><tr style={{borderBottom:`1px solid ${C.border}`}}>
                {["Empleado","Puesto","Sueldo","IMSS ~17%","Vacaciones","Aguinaldo","Total/mes"].map(h=>(<th key={h} style={{padding:"9px 14px",color:C.textDim,fontSize:9,textAlign:"left",letterSpacing:1.5,textTransform:"uppercase",whiteSpace:"nowrap"}}>{h}</th>))}
              </tr></thead>
              <tbody>
                {emps.map((e,i)=>(
                  <tr key={e.id} style={{borderBottom:`1px solid ${C.border}`,background:i%2===0?"transparent":C.bg+"60"}}>
                    <td style={{padding:"9px 14px",color:C.text,fontWeight:700,fontSize:13}}>{e.nombre}</td>
                    <td style={{padding:"9px 14px",color:C.textMid,fontSize:12}}>{e.rol}</td>
                    <td style={{padding:"9px 14px",color:C.green,fontWeight:700}}>{$(e.sueldo)}</td>
                    <td style={{padding:"9px 14px",color:C.textMid,fontSize:12}}>{$(e.imss)}</td>
                    <td style={{padding:"9px 14px",color:C.textMid,fontSize:12}}>{$(Math.round(e.sueldo/12))}</td>
                    <td style={{padding:"9px 14px",color:C.textMid,fontSize:12}}>{$(Math.round(e.sueldo*15/12))}</td>
                    <td style={{padding:"9px 14px",color:ac,fontWeight:800}}>{$(Math.round((e.sueldo+e.imss)*1.15))}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </Box>
      )}
    </div>
  );
}

// ── REPORTES ──────────────────────────────────────────────────
function Reportes({negocio}){
  const ac=NEG[negocio].color;
  const totalSem=VSEM.reduce((a,d)=>a+(negocio==="farmacia"?d.f:d.m),0);
  const maxV=Math.max(...VSEM.map(d=>negocio==="farmacia"?d.f:d.m));
  return(
    <div>
      <H2 sub={NEG[negocio].label} action={<div style={{display:"flex",gap:8}}><Btn sm col={ac}>📄 PDF</Btn><Btn sm ol col={ac}>📊 Excel</Btn></div>}>◧ Reportes</H2>
      <div style={{display:"flex",gap:12,marginBottom:20,flexWrap:"wrap"}}>
        <KPI label="Venta semana"    value={$(totalSem)}   icon="📈" col={ac}/>
        <KPI label="Ticket promedio" value="$82"           icon="🎫" col={C.teal}/>
        <KPI label="Margen promedio" value="42%"           icon="💰" col={C.green}/>
        <KPI label="Transacciones"   value="87"            icon="🔄" col={BRAND.secondary}/>
      </div>
      <div style={{display:"grid",gridTemplateColumns:"1fr 1fr",gap:16,marginBottom:16}}>
        <Box style={{padding:20}}>
          <div style={{color:C.text,fontWeight:700,fontSize:13,marginBottom:14}}>Ventas diarias</div>
          <div style={{display:"flex",alignItems:"flex-end",gap:6,height:120}}>
            {VSEM.map((d,i)=>{const v=negocio==="farmacia"?d.f:d.m;return(
              <div key={i} style={{flex:1,display:"flex",flexDirection:"column",alignItems:"center",gap:4,height:"100%"}}>
                <div style={{flex:1,width:"100%",display:"flex",flexDirection:"column",justifyContent:"flex-end"}}>
                  <div style={{width:"100%",background:i===4?ac:ac+"55",borderRadius:"4px 4px 0 0",height:`${(v/maxV)*100}%`,minHeight:2}}/>
                </div>
                <div style={{color:C.textDim,fontSize:9}}>{d.dia}</div>
              </div>
            );})}
          </div>
        </Box>
        <Box style={{padding:20}}>
          <div style={{color:C.text,fontWeight:700,fontSize:13,marginBottom:14}}>Top categorías</div>
          {(negocio==="farmacia"?[["Analgésico",32],["Antibiótico",24],["Gastro",18],["Diabetes",14],["Otros",12]]:[["Bebidas",35],["Básicos",25],["Refrescos",20],["Botanas",12],["Otros",8]]).map(([cat,pct])=>(
            <div key={cat} style={{marginBottom:10}}>
              <div style={{display:"flex",justifyContent:"space-between",marginBottom:4}}><span style={{color:C.textMid,fontSize:12}}>{cat}</span><span style={{color:C.text,fontSize:12,fontWeight:700}}>{pct}%</span></div>
              <div style={{background:C.border,borderRadius:4,height:6}}><div style={{width:`${pct}%`,background:ac,height:6,borderRadius:4}}/></div>
            </div>
          ))}
        </Box>
      </div>
      <Box style={{padding:20}}>
        <div style={{color:C.text,fontWeight:700,fontSize:13,marginBottom:14}}>Consolidado Ecosistema FarmaCapital</div>
        <div style={{display:"grid",gridTemplateColumns:"1fr 1fr 1fr",gap:12}}>
          {[["FarmaCapital",$(VSEM.reduce((a,d)=>a+d.f,0)),BRAND.secondary],["Minisuper Yolanda",$(VSEM.reduce((a,d)=>a+d.m,0)),C.green],["Consultorio","$8,400",C.teal]].map(([n,v,col])=>(
            <div key={n} style={{background:C.bg,borderRadius:10,padding:"14px 16px",textAlign:"center"}}>
              <div style={{color:C.textMid,fontSize:11,marginBottom:6}}>{n}</div>
              <div style={{color:col,fontWeight:900,fontSize:20,fontFamily:"'Plus Jakarta Sans',sans-serif"}}>{v}</div>
              <div style={{color:C.textDim,fontSize:10,marginTop:4}}>esta semana</div>
            </div>
          ))}
        </div>
      </Box>
    </div>
  );
}

// ── CHATBOT IA ────────────────────────────────────────────────
function ChatbotIA({negocio}){
  const inv=negocio==="farmacia"?INV_F:INV_M;
  const ac=NEG[negocio].color;
  const [msgs,setMsgs]=useState([{role:"assistant",content:`¡Hola! Soy el asistente IA de ${NEG[negocio].label}. Analizo tu inventario, ventas, caducidades y precios de mercado en tiempo real. ¿En qué te ayudo?`}]);
  const [input,setInput]=useState("");const [load,setLoad]=useState(false);
  const endRef=useRef(null);
  useEffect(()=>endRef.current?.scrollIntoView({behavior:"smooth"}),[msgs]);
  const sys=`Eres el asistente inteligente de ${NEG[negocio].label}, parte del Ecosistema FarmaCapital en Chinampac de Juárez, Iztapalapa, CDMX.
Administrador general: Ivan. Dueño farmacia: Luis Ventura QFB. Dueña minisuper: Yolanda Ventura.
La farmacia se llama FARMACAPITAL (antes Ventura, cambio de nombre reciente).

INVENTARIO: ${JSON.stringify(inv)}
CLIENTES: ${JSON.stringify(CLIENTES_D)}
VENTAS SEMANA: ${JSON.stringify(VSEM)}
BITÁCORA COFEPRIS: ${JSON.stringify(BITACORA_D)}
CORTES: ${JSON.stringify(CORTES_D)}

Responde SIEMPRE en español. Sé conciso y orientado a acción. Usa emojis. Analiza stock, caducidades, ofertas mayoreo, precios vs Similares/Del Ahorro, tendencias de ventas, alertas operativas, puntos FarmaCapital.`;
  const send=async()=>{
    if(!input.trim()||load)return;
    const msg=input.trim();setInput("");
    setMsgs(p=>[...p,{role:"user",content:msg}]);setLoad(true);
    try{
      const hist=msgs.map(m=>({role:m.role,content:m.content}));
      const res=await fetch("https://api.anthropic.com/v1/messages",{method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify({model:"claude-sonnet-4-20250514",max_tokens:1000,system:sys,messages:[...hist,{role:"user",content:msg}]})});
      const data=await res.json();
      setMsgs(p=>[...p,{role:"assistant",content:data.content?.[0]?.text||"Error al responder."}]);
    }catch{setMsgs(p=>[...p,{role:"assistant",content:"Error de conexión. El chatbot requiere internet activo."}]);}
    finally{setLoad(false);}
  };
  const sugs=negocio==="farmacia"?["¿Qué debo reordenar urgente?","¿Hay productos por caducar?","¿Cómo van las ventas?","¿Qué ofertas mayoreo convienen?"]:["¿Qué productos se agotan?","¿Cómo van las ventas hoy?","¿Qué tengo bajo stock?","¿Cuál es mi mejor categoría?"];
  return(
    <div style={{display:"flex",flexDirection:"column",height:"calc(100vh - 100px)"}}>
      <H2 sub="Analiza inventario, ventas y mercado · Requiere internet">✦ Asistente IA FarmaCapital</H2>
      <div style={{display:"flex",gap:6,flexWrap:"wrap",marginBottom:14}}>
        {sugs.map(s=>(<button key={s} onClick={()=>setInput(s)} style={{padding:"5px 10px",borderRadius:20,border:`1px solid ${C.border}`,background:"transparent",color:C.textMid,cursor:"pointer",fontSize:11,fontWeight:600,transition:"all .2s"}} onMouseEnter={e=>{e.currentTarget.style.borderColor=BRAND.secondary;e.currentTarget.style.color=BRAND.secondary;}} onMouseLeave={e=>{e.currentTarget.style.borderColor=C.border;e.currentTarget.style.color=C.textMid;}}>{s}</button>))}
      </div>
      <div style={{flex:1,background:C.card,borderRadius:14,border:`1px solid ${C.border}`,padding:18,overflowY:"auto",marginBottom:12}}>
        {msgs.map((m,i)=>(
          <div key={i} style={{display:"flex",justifyContent:m.role==="user"?"flex-end":"flex-start",marginBottom:14}}>
            <div style={{maxWidth:"80%",padding:"12px 16px",borderRadius:m.role==="user"?"18px 18px 4px 18px":"18px 18px 18px 4px",background:m.role==="user"?BRAND.gradient:C.bg,color:C.text,fontSize:13,lineHeight:1.6,border:m.role==="assistant"?`1px solid ${C.border}`:"none",whiteSpace:"pre-wrap"}}>
              {m.role==="assistant"&&<div style={{color:BRAND.secondary,fontSize:10,fontWeight:700,marginBottom:4}}>✦ Asistente FarmaCapital IA</div>}
              {m.content}
            </div>
          </div>
        ))}
        {load&&(<div style={{display:"flex",justifyContent:"flex-start",marginBottom:14}}><div style={{background:C.bg,border:`1px solid ${C.border}`,borderRadius:"18px 18px 18px 4px",padding:"12px 20px",display:"flex",gap:5}}>{[0,1,2].map(i=><div key={i} style={{width:6,height:6,borderRadius:"50%",background:BRAND.secondary,animation:`bounce 1s infinite ${i*.2}s`}}/>)}</div></div>)}
        <div ref={endRef}/>
      </div>
      <div style={{display:"flex",gap:10}}>
        <Inp value={input} onChange={e=>setInput(e.target.value)} onKeyDown={e=>e.key==="Enter"&&send()} placeholder="Pregúntame sobre inventario, ventas, caducidades, precios del mercado..." style={{flex:1}}/>
        <Btn onClick={send} col={BRAND.primary} dis={load}>Enviar</Btn>
      </div>
    </div>
  );
}

// ── APP ───────────────────────────────────────────────────────
export default function App(){
  const [page,setPage]=useState("dash");
  const [neg,setNeg]=useState("farmacia");
  const pages={dash:Dashboard,pos:POS,inv:Inventario,cof:COFEPRIS,caja:CorteCaja,cons:Consultorio,cli:ClientesPuntos,rrhh:RRHH,rep:Reportes,bot:ChatbotIA};
  const Page=pages[page]||Dashboard;
  return(
    <>
      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap');
        *{box-sizing:border-box;margin:0;padding:0;}
        body{background:${C.bg};font-family:'Plus Jakarta Sans',sans-serif;color:${C.text};}
        ::-webkit-scrollbar{width:4px;height:4px;}
        ::-webkit-scrollbar-track{background:${C.bg};}
        ::-webkit-scrollbar-thumb{background:${C.border};border-radius:4px;}
        @keyframes bounce{0%,80%,100%{transform:translateY(0);}40%{transform:translateY(-6px);}}
        select option{background:${C.card};}
        button{font-family:'Plus Jakarta Sans',sans-serif;}
      `}</style>
      <Sidebar active={page} setActive={setPage} negocio={neg} setNegocio={setNeg}/>
      <main style={{marginLeft:224,padding:"28px 28px",minHeight:"100dvh",background:C.bg}}>
        <Page negocio={neg}/>
      </main>
    </>
  );
}
