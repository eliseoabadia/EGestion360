import fs from 'node:fs/promises';
import {pathToFileURL} from 'node:url';
import {FileBlob,PresentationFile} from '@oai/artifact-tool';
const root='C:/Desarrollo/Desarrollo/FullStack/EGestion360';
const dir=root+'/tmp/presentacion_gobierno/revision_logo';
const skill='C:/Users/Eliseo/.codex/plugins/cache/openai-primary-runtime/presentations/26.909.12148/skills/presentations';
const {finalizePresentation}=await import(pathToFileURL(skill+'/container_tools/artifact_tool_utils.mjs').href);
const p=await PresentationFile.importPptx(await FileBlob.load('C:/Desarrollo/Propuestas/Gobierno/CiaNet_Almacen_y_Patrimonio_Gobierno.pptx'));
const snapshot=await p.inspect({kind:'slide,textbox,image',maxChars:150000});
const records=snapshot.ndjson.split('\n').filter(Boolean).map(JSON.parse);
const originalSlides=[...p.slides.items];
const logo=new Uint8Array(await fs.readFile(dir+'/Logo_CiaNet_original.jpg'));
const green='#4B772B', navy='#162C4F';
function txt(s,t,x,y,w,h,size=28,color=navy,bold=false){const a=s.shapes.add({geometry:'textbox',position:{left:x,top:y,width:w,height:h},fill:'none',line:{fill:'none',width:0}});a.text=t;a.text.style={typeface:'Arial',fontSize:size,color,bold,autoFit:'none'};return a;}
function brand(s,large=false){const w=large?370:235; s.images.add({blob:logo,contentType:'image/jpeg',alt:'CIANET Consultoría en Informática, logo proporcionado por el usuario',fit:'contain',position:{left:72,top:large?34:22,width:w,height:w*509/1600}});}
function change(oldText,newText){const matches=records.filter(r=>r.kind==='textbox'&&r.text===oldText);if(matches.length!==1)throw new Error('No se encuentra texto único: '+oldText);const a=p.resolve(matches[0].id);a.text=newText;return a;}
for(const r of records.filter(r=>r.kind==='textbox')){
 const a=p.resolve(r.id);
 if(r.text==='CiaNet')a.text='';
 const [x,y]=r.bbox;
 // Acentos de contenido conservando las cajas y tamaños del documento original.
 if(![1,5,12].includes(r.slide)&&((x===72&&y>=235&&y<630&&r.text.length<110)||(r.slide===4&&/^0[1-4]$/.test(r.text)))) a.text.style={color:green};
}
for(let i=0;i<originalSlides.length;i++){
 const s=originalSlides[i];
 if(![0,4,11].includes(i))s.background.fill='#FAFAFA';
 brand(s,[0,11].includes(i));
}
change('Control de suministros y bienes\npara instituciones gubernamentales','Disponibilidad de materiales y control\nde bienes para el servicio público').text.style={fontSize:28};
change('Cada movimiento necesita una explicación verificable','Recursos disponibles y bienes bajo control');
change('Conocer qué existe antes de comprar o entregar.','Consultar existencias antes de comprar o entregar.');
change('Conservar información útil cuando cambian los responsables.','Mantener el historial al cambiar de responsable.');
change('Sustentar recepciones, movimientos y bajas.','Reunir evidencia de recepciones, movimientos y bajas.');
change('Un sistema alineado a la institución','Diseño para la operación gubernamental');
change('La estructura administrativa forma parte del control','La institución define quién opera y con qué alcance');
change('Catálogos, formatos y procedimientos definidos en el alcance.','Catálogos, formatos y adecuaciones acordados en el proyecto.');
change('Almacén: control de la operación diaria','Almacén: disponibilidad y entregas trazables');
change('Relaciona lo recibido con la orden de compra y su detalle.','Relaciona la entrada con el pedido para revisar lo recibido.');
change('Facilita decisiones de suministro con información registrada.','Ayuda a evitar compras innecesarias al consultar lo disponible.');
change('Organiza la atención de materiales a las áreas.','Permite seguir la atención de materiales solicitados por las áreas.');
change('Registra correcciones de entrada y salida.','Conserva el registro de las correcciones de entrada y salida.');
change('Conteos que ayudan a detectar diferencias','Conteos para revisar lo que realmente existe');
change('Verificar físicamente fortalece\nla confiabilidad del inventario','Las diferencias se detectan\npara investigarlas y atenderlas');
change('Programación de conteos y clasificación ABC\nRegistro de conteo y escaneo\nConsulta de diferencias para su revisión\nCierre del periodo de conteo','Programación por clasificación ABC\nRegistro de conteos y escaneos\nRevisión de diferencias detectadas\nCierre del periodo de conteo');
change('Un registro consultable facilita localizar el bien y explicar su situación.','Información útil para localizar, reasignar y revisar los bienes.');
change('La información acompaña los cambios de custodia.','El historial facilita revisar los cambios de custodia.');
change('Evidencia para revisión y seguimiento','Soporte para rendición de cuentas');
change('Documentos asociados a registros de recepción y bajas.','Evidencia vinculada a registros de recepción y bajas.');
change('Menos recaptura como objetivo de una operación integrada','Una misma referencia facilita el seguimiento entre áreas').text.style={fontSize:35};
change('Mejor visibilidad de materiales y solicitudes pendientes.','Disponibilidad para atender solicitudes con menos incertidumbre.').text.style={fontSize:27};
change('Seguimiento de ubicación, custodia y situación del bien.','Responsables y ubicaciones identificados para dar seguimiento.').text.style={fontSize:27};
change('Información centralizada para decidir y supervisar.','Mejor información para revisar necesidades y priorizar recursos.').text.style={fontSize:27};
change('Registros y evidencia organizados para su revisión.','Evidencia localizable para revisar movimientos y diferencias.').text.style={fontSize:27};
change('Implementación con alcance acordado','Implementación con un piloto verificable');
change('Procesos, responsables, formatos y prioridades.','Procesos, reglas, responsables y prioridades.');
change('Catálogos, permisos y depuración de datos iniciales.','Catálogos, permisos y datos iniciales depurados.');
change('Prueba de recepción, entrega, resguardo e inventario.','Un almacén o área, con casos y resultados acordados.');
change('Capacitación, criterios de aceptación y seguimiento.','Capacitación, aceptación y seguimiento de resultados.');
change('Una demostración con\nel proceso de su institución','Una demostración basada\nen sus propios procesos').text.style={fontSize:52};
change('Alcance funcional y propuesta de implementación\na partir de sus necesidades.','Siguiente paso: acordar un piloto, sus responsables\ny los criterios para evaluar el resultado.');

for(const text of ['Contexto del bien','Bienes y resguardos']) p.resolve(records.find(r=>r.kind==='textbox'&&r.text===text).id).text.style={color:green};
for(const text of ['Clave, descripción, marca, modelo\ny número de serie.','La orden de compra da contexto\na las entradas de almacén.']) p.resolve(records.find(r=>r.kind==='textbox'&&r.text===text).id).text.style={color:'#18374A'};
for(const r of records.filter(r=>r.kind==='textbox'&&r.bbox?.[0]===1160))p.resolve(r.id).text.style={color:[1,5,12].includes(r.slide)?'#B8CDD7':'#526675'};

const {slide:k}=await p.slides.insert({after:originalSlides[9]});k.background.fill='#FAFAFA';brand(k);
txt(k,'Indicadores para evaluar el piloto',72,115,1136,110,46,navy,true);
txt(k,'Medición propuesta antes y después de la implementación',72,231,1100,62,30,green,true);
const metrics=[['Exactitud de existencias','Registros sin diferencia / registros contados'],['Asignación de bienes','Bienes con resguardo vigente / bienes a resguardar'],['Atención de solicitudes','Tiempo entre solicitud y entrega'],['Evidencia completa','Expedientes completos / expedientes revisados']];
metrics.forEach((a,i)=>{txt(k,a[0],72,325+i*64,360,54,25,navy,true);txt(k,a[1],485,325+i*64,700,54,25);});
txt(k,'Metas y fuentes de datos a definir con la institución.',72,607,1080,40,23,green);
k.speakerNotes.textFrame.setText('Indicadores sugeridos para acordar una línea base y evaluar el piloto. No son resultados obtenidos ni indicadores automáticos confirmados del producto. Definir universo, periodo, responsables, fuente de datos, criterio de expediente completo y metas durante el diagnóstico.');
const ibm='https://www.ibm.com/products/maximo/public-sector';
const infor='https://dam.infor.com/api/public/content/a082f11fa209493e84866f3fc4c5fada?v=8f87e121';
originalSlides[0].speakerNotes.textFrame.setText('EGestion360 Almacén y Patrimonio. Logo original de CIANET proporcionado por el usuario, reproducido sin alteración. Imagen de almacén ilustrativa, no corresponde a una instalación real.');
originalSlides[1].speakerNotes.textFrame.setText('El valor propuesto es apoyar la disponibilidad de materiales, el control de custodia y la continuidad de la información. Beneficios cualitativos sujetos a calidad de datos, reglas y adopción del proceso. Referencia conceptual de comunicación comercial: IBM Maximo para el sector público, '+ibm+' (consulta: 17/09/2026). No se atribuyen a EGestion360 funciones, certificaciones o resultados de IBM.');
originalSlides[8].speakerNotes.textFrame.setText('El código relaciona recepción con órdenes de compra y bienes con resguardos. Fuentes de producto: FrontEnd/EG.Web/Pages/Modules/GRP/Almacen/Recepcion_Pedidos.razor, BackEnd/EG.Infraestructure/Models/Bien.cs y Resguardo.cs. Referencia conceptual: Infor Asset and work management, '+infor+' (consulta: 17/09/2026). Las interfaces con otros sistemas, conciliaciones y adecuaciones se acuerdan en alcance. No se ofrecen GIS, operación sin conexión ni mantenimiento predictivo como capacidades verificadas de EGestion360.');
originalSlides[10].speakerNotes.textFrame.setText('Propuesta de implantación por fases con un piloto. Los entregables, adecuaciones, migración, interfaces, plazos y costos se acuerdan tras el diagnóstico. Aceptación sugerida: operación de casos completos, identificación de responsables y revisión de los indicadores definidos.');
// Renumeración tras insertar el piloto, respetando el pie del original.
const now=(await p.inspect({kind:'textbox',maxChars:150000})).ndjson.split('\n').filter(Boolean).map(JSON.parse);
for(const r of now.filter(r=>r.kind==='textbox'&&r.bbox?.[0]===1160&&r.bbox?.[1]===645))p.resolve(r.id).text=String(r.slide).padStart(2,'0');
txt(k,'11',1160,645,48,30,18,'#526675');
await (await PresentationFile.exportPptx(p)).save(dir+'/candidate.pptx');
await finalizePresentation({workspaceDir:root,candidatePath:dir+'/candidate.pptx',finalPath:root+'/output/presentaciones/CiaNet_Almacen_y_Patrimonio_Gobierno_Actualizada.pptx',pythonExecutable:'C:/Users/Eliseo/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe',integrityValidatorPath:skill+'/container_tools/inspect_presentation_package_integrity.py',layoutValidatorPath:skill+'/container_tools/inspect_presentation_layout_geometry.py',layoutArgs:['--expected-slide-size-emu','12192000,6858000','--validate-bullet-geometry','--validate-heading-fit'],fontPolicy:{basis:'design',families:['Arial']},verifyArtifactToolImport:true,receiptPath:dir+'/validation-final.json'});
for(let i=0;i<p.slides.items.length;i++){const b=await p.export({slide:p.slides.items[i],format:'jpeg',scale:1,quality:75});await fs.writeFile(dir+`/slide-${i+1}.jpg`,new Uint8Array(await b.arrayBuffer()));}
console.log('Presentación editada: '+p.slides.items.length+' diapositivas.');


