# Auditoría — corrección barcodes OCR

Catálogo: `sql/preview_catalogo_campos_y_precios.csv`

| Métrica | Valor |
|---------|-------|
| Correcciones SQL | **127** |
| Pendientes (revisar manual) | **27** |

## Reglas aplicadas
- EAN-13 válido (checksum GS1)
- Sin colisión con otro producto
- Overrides manuales: Vitacilina 28 `750222503430721` → `7502250343072`
- Solo actualiza `codigo_barras` (no precio, stock, lotes)

## Correcciones

| SKU | Antes | Después | Producto |
|-----|-------|---------|----------|
| `FC-00740024` | `65024000740024` | `6502400074024` | Silka Medic Gel |
| `FC-30133021` | `75011230133021` | `7501123013302` | Iri (Inmunoglobulina) |
| `FC-12225027` | `7501354312225027` | `7501354312250` | Derman Crema |
| `FC-85103015` | `619585103015` | `6195851030154` | Toallitas Humedas Bebin Super |
| `FC-54525051` | `75010954525051` | `7501095452505` | Tempra Forte C/24 |
| `FC-71829601` | `75015015371829601` | `7501501537161` | Tribedoce |
| `FC-40010712` | `650240010712` | `6502400107128` | Tukol-D jarabe |
| `FC-51078461` | `75064751078461` | `7506475107846` | Nan 1 Pro 1 |
| `FC-51078531` | `75064751078531` | `7506475107853` | Nan Nestle Bolsa Nestle Bolsa |
| `FC-40036354` | `650240036354` | `6502400363548` | Genoprazol Tab |
| `FC-51448511` | `75011251448511` | `7501125144851` | Electrolit Uva |
| `FC-95201021` | `75012895201021` | `7501289520102` | Pomada Hipoglos Pac |
| `FC-01508201` | `750525301508201` | `7505253015021` | Antiflu-Des |
| `FC-06134531` | `75010506134531` | `7501050613453` | Afrin DTC rojo spray |
| `FC-47624171` | `75022347624171` | `7502234762417` | Nailex Desenterrador Unas Desenterrador Unas |
| `FC-50002301` | `75011650002301` | `7501165000230` | Neo-Melubrina metamizol tabletas C/10 |
| `FC-34092301` | `7501210734092301` | `7501210734301` | Syncol Max tabletas |
| `FC-50724298` | `75012501050724298` | `7501250105079` | Tempra jarabe |
| `FC-54521161` | `75010954521161` | `7501095452116` | Tempra 500 mg |
| `FC-58203691` | `75022358203691` | `7502235820369` | Hilo dental expanding |
| `FC-40006647` | `650240006647` | `6502400066470` | Ultra Bengue Gel |
| `FC-40032264` | `650240032264` | `6502400322644` | Suerox 8 Iones Eresa-Kiwi 630 ML |
| `FC-40032271` | `650240032271` | `6502400322712` | Suerox 8 Iones Uva 630 ML |
| `FC-50959781` | `75010650959781` | `7501065095978` | Centrum Performance |
| `FC-40032295` | `650240032295` | `6502400322958` | Suerox 8 Iones Mora Azul 630 ML |
| `FC-40066306` | `650240066306` | `6502400663068` | Suerox 8 Iones Fresa 630 ML |
| `FC-40074455` | `650240074455` | `6502400744552` | Suerox 8 Iones Uva Mora Azul 630 ML |
| `FC-03405381` | `750022503405381` | `7500225034031` | Vitacilina Ungüento |
| `FC-06247327` | `75010506247327` | `7501050624732` | Afrin No Drip extra humectante spray |
| `FC-12225164` | `354312225164` | `3543122251648` | Vitacilina Bebé Pomada |
| `FC-47640531` | `75022347640531` | `7502234764053` | Nailex El Recuperador |
| `FC-60403681` | `75022760403681` | `7502276040368` | Desenfriol |
| `FC-03430721` | `750222503430721` | `7502250343072` | Vitacilina 28 Crema |
| `FC-40010538` | `650240010538` | `6502400105384` | Next Tab |
| `FC-40015366` | `650240015366` | `6502400153668` | Nasalub Sol |
| `FC-40017100` | `650240017100` | `6502400171006` | Xl-3 Vr |
| `FC-40032325` | `650240032325` | `6502400323252` | Suerox 8 Iones Lima Limón 630 ML |
| `FC-40035395` | `650240035395` | `6502400353952` | Suerox 8 Iones Coco 630 ML |
| `FC-51747971` | `75011251747971` | `7501125174797` | Electrolit Mora Azul |
| `FC-80596011` | `36647980596011` | `3664798059601` | Aderogyl Amp |
| `FC-83683367` | `75010583683367` | `7501058363367` | Condón Sico Rojo Feel |
| `FC-92730451` | `7507201092730451` | `7507201092351` | Riopan Sobres |
| `FC-83146207` | `780083146207` | `7800831462076` | Fazolin F (nafazolina) |
| `FC-75354321` | `75010075354321` | `7501007535432` | Tylenol |
| `FC-75125811` | `75010275125811` | `7501027512581` | Evenflo Colors |
| `FC-75163051` | `75010275163051` | `7501027516305` | Evenflo Ensueno Azul |
| `FC-23001331` | `75010723001331` | `7501072300133` | Sr. Ting pomada (ácido bórico) |
| `FC-79071241` | `75010379071241` | `7501037907124` | Bisolvon Infantil |
| `FC-23273451` | `75060223273451` | `7506022327345` | Jeringa insulina 0.5 ml |
| `FC-84335531` | `75010084335531` | `7501008433553` | Aspirina Forte C/24 Caf Iaspirina |
| `FC-29003221` | `75065529003221` | `7506552900322` | Quirmex |
| `FC-84999001` | `75010084999001` | `7501008499900` | Alka-Seltzer |
| `FC-84431050` | `759684431050` | `7596844310502` | Acetona Jaloma chico |
| `FC-84437151` | `759684437151` | `7596844371510` | Acetona Jaloma mediano |
| `FC-85097661` | `75010885097661` | `7501088509766` | Chinoin Junior jarabe infantil |
| `FC-82176351` | `75012982176351` | `7501298217635` | Neurobión inyectable prellenado |
| `FC-84095411` | `75010084095411` | `7501008409541` | Saridon |
| `FC-84973401` | `75010084973401` | `7501008497340` | Flanax |
| `FC-36041273` | `037836041273` | `0378360412734` | Crema Hinds Clasica Rosa |
| `FC-40013850` | `650240013850` | `6502400138504` | Crema Teatrical Lanolina |
| `FC-45079011` | `75010545079011` | `7501054507901` | Labello |
| `FC-85592111` | `75010885592111` | `7501088559211` | Scabisan |
| `FC-86167151` | `75010586167151` | `7501058616715` | Nestum Probioticos Avena 270 Probioticos |
| `FC-88923551` | `75022088923551` | `7502208892355` | Cilocid Iv |
| `FC-87154871` | `75010587154871` | `7501058715487` | Graneodin F (flurbiprofeno) |
| `FC-87932321` | `75010587932321` | `7501058793232` | Microdacyn lubricante cereza 50 ml |
| `FC-51067711` | `75064751067711` | `7506475106771` | Nido leche en polvo (grande) |
| `FC-50003151` | `75011650003151` | `7501165000315` | Neo-Melubrina jarabe |
| `FC-86708021` | `75010486708021` | `7501048670802` | Protec termómetro digital |
| `FC-89794961` | `75013289794961` | `7501328979496` | Histiacil NF Infantil (Jarabe) |
| `FC-88947797` | `75022088947797` | `7502208894779` | Tribedoce Tabletas |
| `FC-56131681` | `75064256131681` | `7506425613168` | Evenflo |
| `FC-66534951` | `75095466534951` | `7509546653495` | Colgate Total |
| `FC-73629981` | `75010173629981` | `7501017362998` | Kleenex Panuelos Pack C/8 1 |
| `FC-83351381` | `75010483351381` | `7501048335138` | Agua oxigenada |
| `FC-83351691` | `75010483351691` | `7501048335169` | Degasa Agua Oxigenada |
| `FC-83510531` | `75010483510531` | `7501048351053` | Protec Antibacterial 22.40 Antibacterial |
| `FC-92821171` | `75010592821171` | `7501059282117` | Nido Nido Nestle Bolsa Nestle |
| `FC-98100381` | `75010898100381` | `7501089810038` | Shampoo Herklin |
| `FC-45307181` | `75010545307181` | `7501054530718` | Arnica Bde Parche |
| `FC-36040450` | `037836040450` | `0378360404500` | Crema Grisi concha nácar para manos |
| `FC-AA905BF7` | `780083141226` | `7800831412262` | Perludil |
| `FC-34062421` | `75030034062421` | `7503003406242` | Tela adhesiva |
| `FC-20500171` | `810120500171` | `8101205001716` | Crema para peinar Pert aceite oliva aguacate |
| `FC-34063651` | `75030034063651` | `7503003406365` | Quirmex |
| `FC-5D9DFA3D` | `785120755497` | `7851207554970` | Norquinol |
| `FC-974EE5FD` | `780083141875` | `7800831418752` | Gimalxina |
| `FC-51444145` | `75004351444145` | `7500435144414` | Old Spice |
| `FC-E4BE37BE` | `785120754858` | `7851207548580` | Atorvastatina |
| `FC-34067301` | `75030034067301` | `7503003406730` | Quirmex |
| `FC-20500201` | `810120500201` | `8101205002010` | Shampoo Pert  Ac-Oliva |
| `FC-36033735` | `037836033735` | `0378360337358` | Shampoo Ricitos de Oro Oro Agua De Coco |
| `FC-40030338` | `650240030338` | `6502400303384` | Jabon Intimo Lomecan V Aclar |
| `FC-20501765` | `810120501765` | `8101205017656` | Crema Grisi aloe vera para manos |
| `FC-40030963` | `650240030963` | `6502400309638` | Crema Teatrical Cel-Ma Nutrit |
| `FC-88915491` | `75022088915491` | `7502208891549` | Tarmin 2 Mg /12 |
| `FC-36032776` | `037836032776` | `0378360327762` | Shampoo Ricitos de Oro Oro Biopure |
| `FC-40025839` | `650240025839` | `6502400258394` | Jabon Intimo Lomecan V |
| `FC-36041402` | `037836041402` | `0378360414028` | Crema Hinds hidratación extra almendras |
| `FC-20501673` | `810120501673` | `8101205016734` | Crema Hinds líquida agave azul |
| `FC-85800198` | `619585800198` | `6195858001980` | Toallitas Bebin Super |
| `FC-49824911` | `75022149824911` | `7502214982491` | Prudence condones C/3 |
| `FC-89100101` | `75018689100101` | `7501868910010` | Algodón 200 g |
| `FC-84900280` | `759684900280` | `7596849002808` | Jaloma Agua de Rosas |
| `FC-01015141` | `75064601015141` | `7506460101514` | Lubricante Sico Softlube Origin |
| `FC-49824391` | `75022149824391` | `7502214982439` | Prudence 'Ull Retardante C/3 |
| `FC-49853867` | `75022149853867` | `7502214985386` | Softlub Extra condones C/3 |
| `FC-23272151` | `75060223272151` | `7506022327215` | Jeringa insulina 0.3 ml |
| `FC-49824771` | `75022149824771` | `7502214982477` | Prudence Fresa |
| `FC-40013898` | `650240013898` | `6502400138986` | Crema Teatrical Lanol/Ros |
| `FC-08820243` | `75012508820243` | `7501250882024` | Dermodine infantil |
| `FC-34067471` | `75030034067471` | `7503003406747` | Quirmex |
| `FC-34064021` | `75030034064021` | `7503003406402` | Quirmex Tarro 1 2 12.00 Cotonetes Tarro 1 |
| `FC-34067781` | `75030034067781` | `7503003406778` | Quirmex |
| `FC-34067851` | `75030034067851` | `7503003406785` | Quirmex |
| `FC-60009851` | `75095460009851` | `7509546000985` | Colgate Triple Acc |
| `FC-60689091` | `75095460689091` | `7509546068909` | Colgate Trip Xtra |
| `FC-66888171` | `75095466888171` | `7509546688817` | Colgate Max Clean |
| `FC-66873531` | `75095466873531` | `7509546687353` | Crema dental anticaries |
| `FC-38891190` | `067238891190` | `0672388911904` | Jabon Dove Original |
| `FC-40004643` | `650240004643` | `6502400046434` | Jabon Asepxia Exfoliante |
| `FC-40036965` | `650240036965` | `6502400369656` | Jabon Asepxia Bicarbon |
| `FC-21042481` | `75010221042481` | `7501022104248` | Manzanilla Ml Hnos 31.40 Hnos |
| `FC-24004581` | `75064524004581` | `7506452400458` | Ajolotius Pastillas Elderberry Past |
| `FC-45045281` | `75010545045281` | `7501054504528` | Labello Hydro-C |
| `FC-49800151` | `75022149800151` | `7502214980015` | Prudence Clasico C/3 |
| `FC-56034041` | `75064256034041` | `7506425603404` | Toallitas húmedas antibacterial |

## Pendientes

| SKU | Barcode | Nota |
|-----|---------|------|
| `FC-00525451` | `6502400525451` | XL-3 C/10 |
| `FC-00170941` | `6502400170941` | XL-3 Xtra C/12 |
| `FC-01246730` | `75916565` | Vicks Vaporub pomada 12 g |
| `FC-00315021` | `6502400315021` | Tukol-D jarabe infantil |
| `FC-7D1D9857` | `7501008491074` | Acetilsalicilico |
| `FC-01303454` | `7501001303454` | Pantene Control caída anticaída |
| `FC-50071598` | `7503050071598` | Theraflu TD |
| `FC-54054221` | `7509854054221` | Splash Tears Sol oftálmica |
| `FC-00322571` | `6502400322571` | Suerox 8 Iones Manzana 630 ML |
| `FC-00323011` | `6502400323011` | Suerox 8 Iones Naranja Mandarina 630 ML |
| `FC-00661391` | `6502400661391` | Suerox 8 Iones Frutos Rojos 630 ML |
| `FC-00721471` | `6502400721471` | Suerox Vitamins Naranja Mango 630 ML |
| `FC-00721541` | `6502400721541` | Suerox Vitamins Manzana V-Limón 630 ML |
| `FC-00744481` | `6502400744481` | Suerox 8 Iones Coco Piña 630 ML |
| `FC-50608272` | `75029650608272` | Contac Ultra |
| `FC-54221482` | `7503854221482` | Deeflamox Plus |
| `FC-85171118` | `7501685171118` | Condón Sico |
| `FC-75064938` | `75064938` | Desodorante Ego Force 24H roll-on |
| `FC-42270027` | `42270027` | Crema Nivea Facial 7 en 1 |
| `FC-68990023` | `7501868990023` | Alcohol Etilico Rojo 96° |
| `FC-75069223` | `75069223` | Rexona Sport Stick |
| `FC-75076009` | `75076009` | Rexona 48H Happy (Mujer) |
| `FC-75001865` | `75001865` | Brillantina Palmolive |
| `FC-75062927` | `75062927` | Desodorante Rexona Pom-Dry 48 H |
| `FC-42417644` | `42417644` | Crema Nivea Cuidado Int P/Mano |
| `FC-75062897` | `75062897` | Desodorante Rexona Bamboo 48H |
| `FC-08491074` | `7501008491074` | Aspirina |

SQL: `sql/patch_corregir_barcodes_ocr.sql`
