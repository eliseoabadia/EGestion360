const {chromium}=require('C:/Desarrollo/Desarrollo/FullStack/GE.UNI360/tmp/validacion-nf013-nf018-playwright/node_modules/playwright');
const fs=require('node:fs'),path=require('node:path');
const date='2026-11-26T00:00:00';
const origin=process.env.EG_REVIEW_ORIGIN??'http://localhost:5247';
const common={fkidEmpresaSis:1,fkidAnioSis:1,activo:true,fechaCreacion:date};
const data={
 cotizacion:[{...common,pkidCotizacion:201,fkidRequisicionOrco:1001,proveedorNombre:'Proveedor de prueba',requisicionDescripcion:'Material de oficina',fechaSolicitud:date,totalDetalles:1,totalCotizado:250,puedeEnviar:true}],
 cotizaciondetalle:[{...common,pkidCotizacionDetalle:1,fkidCotizacionOrco:201,tipoBienCodigoClave:'PAP-001',tipoBienDescripcion:'Papel cotizado',cantidad:2,precioUnitario:125,total:250}],
 ordencompra:[{...common,pkidOrdenCompra:101,numeroOrdenCompra:'OC-PRUEBA-101',proveedorNombre:'Proveedor de prueba',fechaOrdenCompra:date,total:250,totalDetalles:1,totalPartidas:1,fkidEstatusOrdenCompraOrco:1,estatusDescripcion:'Captura'}],
 ordencompradetalle:[{...common,pkidOrdenCompraDetalle:1,fkidOrdenCompraOrco:101,tipoBienCodigoClave:'PAP-001',tipoBienDescripcion:'Papel de la orden',cantidadSolicitada:2,precioUnitario:125,totalDetalle:250}],
 ordencomprapartida:[{...common,pkidOrdenCompraPartida:1,fkidOrdenCompraOrco:101,partidaClave:'21101',partidaDescripcion:'Material de oficina',importe:250}],
 solicitudesuficiencia:[],
 solicitudsuficiencia:[{...common,pkidSolicitudSuficiencia:401,fkidRequisicionOrco:1001,requisicionDescripcion:'Suficiencia de prueba',fechaSolicitud:'2026-11-26',fechaRequisicion:date,estatus:1,estatusDescripcion:'Borrador'}],
 solicitudsuficienciadetalle:[{...common,pkidSolicitudSuficienciaDetalle:1,fkidSolicitudSuficienciaPres:401,partidaClave:'21101',partidaClaveNombre:'21101 Oficina',tipoBienDescripcion:'Papel para suficiencia',tipoBienClave:'PAP-001',cantidad:2,total:250}],
 paaa:[{...common,pkidPaaas:301,descripcion:'Programa de prueba',fecha:date,areaNombre:'Almacén',responsableCompleto:'Usuario de prueba'}],
 resguardo:[{...common,pkidResguardo:501,folio:'RES-PRUEBA-501',personaNombre:'Responsable de prueba',areaNombre:'Almacén',fechaResguardo:date,totalBienes:1}],
 resguardodetalle:[{...common,pkidResguardoDetalle:1,fkidResguardoAlma:501,bienDescripcion:'Equipo resguardado',numeroInventario:'INV-001',serie:'SER-001'}],
 inventario:[{...common,pkidInventario:601,folio:'INV-PRUEBA-601',areaNombre:'Almacén',fechaInventario:date,totalBienes:1,totalLocalizados:1,totalDiferencias:0,responsable:'Responsable de prueba'}],
 inventariodetalle:[{...common,pkidInventarioDetalle:1,fkidInventarioAlma:601,bienDescripcion:'Equipo inventariado',numeroInventario:'INV-001',serie:'SER-001',localizado:true}],
 solicitudsalida:[{...common,pkidSolicitudSalida:701,folio:'SAL-PRUEBA-701',solicitante:'Usuario de prueba',areaSolicitaNombre:'Compras',areaEntregaNombre:'Almacén',fechaSolicitud:date,totalDetalles:1,totalSolicitado:2,totalPendiente:2,autorizado:true,estatusDescripcion:'Autorizada'},{...common,pkidSolicitudSalida:702,folio:'SAL-PRUEBA-702',solicitante:'Segundo solicitante',fechaSolicitud:date,totalDetalles:1,totalSolicitado:1,totalPendiente:1,autorizado:true,estatusDescripcion:'Autorizada'}]
};
const partidas=[{pkidPaaaspartida:1,fkidPaaas:301,fkidPaaasOrco:301,clavePartida:'21101',descripcion:'Oficina de prueba',monto:150},{pkidPaaaspartida:2,fkidPaaas:301,fkidPaaasOrco:301,clavePartida:'21201',descripcion:'Impresión de prueba',monto:100}];
Object.assign(data,{
 autorizacionsuficiencia:[{...common,pkidAutorizacionSuficiencia:801,fkidSolicitudSuficienciaPres:401,fkidRequisicionOrco:1001,requisicionDescripcion:'Autorización de prueba',fechaSolicitud:'2026-11-26',fechaAutorizacion:'2026-11-26',estatus:1,estatusDescripcion:'Captura'}],
 autorizacionsuficienciadetalle:[{...common,pkidAutorizacionSuficienciaDetalle:1,fkidAutorizacionSuficienciaPres:801,partidaClaveNombre:'21101 Partida autorizada',tipoBienDescripcion:'Bien autorizado de prueba',cantidad:2,total:250}],
 estadocontrato:[{...common,pkidContrato:901,numeroContrato:'COM-PRUEBA-901',proveedorNombre:'Proveedor de prueba',fechaContrato:'2026-11-26',montoTotal:250,estatus:1,estatusDescripcion:'Captura'}],
 registrocompromiso:[{...common,pkidContrato:902,numero:'CON-PRUEBA-902',descripcion:'Contrato administrativo de prueba',proveedorNombre:'Proveedor de prueba',fechaContrato:date,montoMaximo:250,montoMinimo:200,fkidEstatusContratoOrco:1,estatusDescripcion:'Captura',puedeModificar:true}],
 baja:[{...common,pkidBaja:1001,folio:'BAJ-PRUEBA-1001',bienClave:'INV-001',bienDescripcion:'Bien para baja de prueba',fechaSolicitud:date,valorActual:250,estatusDescripcion:'Captura',esFinal:false}]
});
const cases=[
 {name:'cotizacion',route:'/Adquisiciones/Cotizacion',open:'Abrir cotización',ready:'Papel cotizado',action:'Capturar bienes'},
 {name:'orden',route:'/Adquisiciones/Orden_Compra',open:'Abrir orden',ready:'Papel de la orden',action:'Agregar bien'},
 {name:'suficiencia',route:'/Adquisiciones/Solicitud_Suficiencia',open:'Abrir solicitud',ready:'Papel para suficiencia',action:'Editar solicitud'},
 {name:'programa',route:'/Adquisiciones/Programa_Anual',open:'Abrir programa',ready:'Bien del programa 1',action:'Agregar bien',second:'Impresión de prueba',after:'Bien del programa 2'},
 {name:'solicitud-salida',route:'/Almacen/Solicitudes_Salida',ready:'Bien de salida 701',action:'Agregar bien',second:'SAL-PRUEBA-702',after:'Bien de salida 702'},
 {name:'suministro',route:'/Almacen/Suministros_Salida',ready:'Bien de salida 701',action:'Registrar entrega',second:'SAL-PRUEBA-702',after:'Bien de salida 702'},
 {name:'resguardo',route:'/Patrimonio/Resguardos',open:'Abrir resguardo',ready:'Equipo resguardado',action:'Agregar bien'},
 {name:'inventario',route:'/Patrimonio/Inventarios',open:'Abrir inventario',ready:'Equipo inventariado',action:'Agregar bien'},
 {name:'autorizacion',route:'/Presupuesto/Egreso/Presupuesto_Comprometido/Autorizacion_Suficiencia',open:'Abrir autorización',ready:'Bien autorizado de prueba',action:'Registrar compromiso'},
 {name:'compromiso',route:'/Adquisiciones/Contratos/Registro_Compromiso',ready:'COM-PRUEBA-901',action:'Autorizar contrato'},
 {name:'contrato',route:'/Adquisiciones/Contratos/Registro_Administrativo',ready:'CON-PRUEBA-902',action:'Autorizar contrato'},
 {name:'baja',route:'/Patrimonio/Bajas',ready:'BAJ-PRUEBA-1001',action:'Aplicar baja'}
];
(async()=>{
const browser=await chromium.launch({channel:'msedge',headless:true});const context=await browser.newContext({viewport:{width:1600,height:1080}});const page=await context.newPage();const errors=[],requests=[],checks=[];let delayStock=false,failStock=false;
page.on('pageerror',e=>errors.push(e.message));
await page.route('**/api/**',async route=>{
 const req=route.request(),url=new URL(req.url()),p=url.pathname.toLowerCase(),parts=p.split('/');const controller=parts[2];const result=items=>({success:true,items,totalCount:items.length,code:'SUCCESS'});let body=result([]);requests.push({path:p,method:req.method(),body:req.postData()});
 if(req.method()==='OPTIONS')return route.fulfill({status:204,headers:{'access-control-allow-origin':'*','access-control-allow-methods':'*','access-control-allow-headers':'*'}});
 if(req.method()!=='GET'&&!p.includes('paginado')&&!p.endsWith('/resumen')){errors.push('Unexpected mutation '+p);return route.fulfill({status:400,body:'Mutation blocked in visual review'});}
 if(p.includes('/navigate/version'))body={success:true,version:'Revisión de pantallas'};
 else if(p.includes('/navigate/claims'))body=[];
 else if(/^\/api\/navigate\/\d+$/.test(p))body=[{pkidMenu:1,nombre:'Operación de prueba',ruta:'/Adquisiciones/Cotizacion',activo:true,fkidMenuSis:0}];
 else if(controller==='paaa'&&p.endsWith('/partidas'))body=result(partidas);
 else if(controller==='paaa'&&p.endsWith('/detalles')){const id=Number(parts[4]);body=result([{pkidPaaasdetalle:id,fkidPaaaspartida:id,tipoBienDescripcion:'Bien del programa '+id,tipoBienCodigoClave:'PROG-'+id,cantidad:2,precioUnitario:50}]);}
 else if(controller==='detallesolicitudsalida'){const input=req.postDataJSON();const id=Number((input.additionalFilters??input.AdditionalFilters).FkidSolicitudSalidaAlma);if(failStock)return route.fulfill({status:500,contentType:'application/json',headers:{'access-control-allow-origin':'*'},body:JSON.stringify({success:false,message:'Fallo simulado'})});if(delayStock&&id===701)await new Promise(r=>setTimeout(r,700));body=result([{...common,pkidDetalleSolicitudSalida:id,fkidSolicitudSalidaAlma:id,tipoBienDescripcion:'Bien de salida '+id,cantidadSolicitada:2,cantidadAutorizada:2,cantidadEntregada:0,cantidadPendiente:2}]);}
 else if(data[controller])body=/\/\d+$/.test(p)?{success:true,data:data[controller][0]}:result(data[controller]);
 else if(controller?.includes('anio'))body=result([{pkidAnio:1,clave:2026,descripcion:'Prueba',activo:true}]);
 else if(controller==='usuario'&&/\/\d+$/.test(p))body={success:true,data:{pkidUsuario:42,monedaSimbolo:'$'}};
 await route.fulfill({status:200,contentType:'application/json',headers:{'access-control-allow-origin':'*'},body:JSON.stringify(body)});
});
await page.addInitScript(()=>{const enc=x=>btoa(JSON.stringify(x)).replaceAll('=','').replaceAll('+','-').replaceAll('/','_');localStorage.setItem('authToken',`${enc({alg:'none'})}.${enc({sub:'42',role:'SuperAdmin',exp:4102444800,empresaId:'1',Nombre:'Usuario de prueba'})}.fixture`);localStorage.setItem('dbPermissionClaims','[]');localStorage.setItem('userId','42');localStorage.setItem('userName','Usuario de prueba');localStorage.setItem('sucursal_seleccionada',JSON.stringify({Id:1,Nombre:'Sucursal de prueba',EmpresaId:1,EmpresaNombre:'Empresa de prueba'}));localStorage.setItem('anio_presupuestal_seleccionado',JSON.stringify({Id:1,Clave:2026,Descripcion:'Prueba'}));});
const manifest=JSON.parse(fs.readFileSync('FrontEnd/EG.Web/bin/DesignReview/EG.Web.staticwebassets.runtime.json','utf8'));const endpoints=JSON.parse(fs.readFileSync('FrontEnd/EG.Web/bin/DesignReview/EG.Web.staticwebassets.endpoints.json','utf8')).Endpoints;
await page.route('http://localhost:5247/**',async route=>{let p=decodeURIComponent(new URL(route.request().url()).pathname).replace(/^\//,'');if(p.startsWith('api/'))return route.fallback();let node=manifest.Root;for(const part of p.split('/'))node=node?.Children?.[part];if(!node?.Asset&&!p.includes('.'))node=manifest.Root.Children['index.html'];if(!node?.Asset)return route.fallback();const a=node.Asset;const ep=endpoints.find(e=>e.Route===p&&!e.ResponseHeaders?.some(h=>h.Name==='Content-Encoding'));const type=ep?.ResponseHeaders?.find(h=>h.Name==='Content-Type')?.Value??(p.endsWith('.wasm')?'application/wasm':p.endsWith('.js')?'text/javascript':p.endsWith('.json')?'application/json':p.endsWith('.css')?'text/css':'text/html');await route.fulfill({status:200,contentType:type,body:fs.readFileSync(path.join(manifest.ContentRoots[a.ContentRootIndex],a.SubPath))});});
let current='startup';
try{
for(const theme of ['Oscuro','Claro']){
 await page.goto(origin+'/');await page.evaluate(theme=>localStorage.setItem('tema_seleccionado',JSON.stringify({Option:theme})),theme);
 for(const c of cases.filter(c=>!process.env.EG_REVIEW_SCREENS||process.env.EG_REVIEW_SCREENS.split(',').includes(c.name))){
  current=c.name+'-'+theme;await page.setViewportSize({width:1600,height:1080});const from=requests.length;
  await page.goto(origin+c.route);
  if(c.open)await page.getByRole('button',{name:c.open,exact:true}).first().click({timeout:30000});
  await page.getByText(c.ready,{exact:true}).first().waitFor({timeout:30000});
  await page.getByRole('button',{name:c.action,exact:true}).first().waitFor();
  if(c.name==='baja')await page.getByText('$250.00',{exact:true}).first().waitFor();
  if(c.second){await page.getByText(c.second,{exact:true}).first().click();await page.getByText(c.after,{exact:true}).first().waitFor();if(await page.getByText(c.ready,{exact:true}).count())throw Error('Old detail visible '+current);}
  const help=page.locator('.operation-action-help summary');await help.first().click();
  await page.screenshot({path:'tmp/operations-design/'+current+'-desktop.png',fullPage:true});
  await page.setViewportSize({width:768,height:1024});await page.waitForTimeout(100);
  if(await page.evaluate(()=>document.documentElement.scrollWidth>window.innerWidth))throw Error('Tablet overflow '+current);
  await page.setViewportSize({width:390,height:844});await page.getByRole('button',{name:c.action,exact:true}).first().scrollIntoViewIfNeeded();await page.waitForTimeout(100);
  if(await page.evaluate(()=>document.documentElement.scrollWidth>window.innerWidth))throw Error('Mobile overflow '+current);
  const actionBounds=await page.getByRole('button',{name:c.action,exact:true}).first().boundingBox();if(!actionBounds||actionBounds.x<0||actionBounds.x+actionBounds.width>390)throw Error('Clipped mobile action '+current);
  await page.screenshot({path:'tmp/operations-design/'+current+'-mobile.png',fullPage:true});
  checks.push({screen:c.name,theme,desktop:true,tablet:true,mobile:true,requests:requests.slice(from).filter(r=>/detalle|partida/.test(r.path))});
  console.log('PASS '+current);
 }
}
current='view-only-permissions';
await page.addInitScript(()=>{if(localStorage.getItem('reviewReadOnly')==='true'){const enc=x=>btoa(JSON.stringify(x)).replaceAll('=','').replaceAll('+','-').replaceAll('/','_');localStorage.setItem('authToken',`${enc({alg:'none'})}.${enc({sub:'42',role:'Reader',exp:4102444800,empresaId:'1',Group:'Adquisiciones',SubGroup:'Cotizacion',Values:'view'})}.fixture`);localStorage.setItem('dbPermissionClaims','[]');}});
await page.evaluate(()=>localStorage.setItem('reviewReadOnly','true'));await page.goto(origin+'/Adquisiciones/Cotizacion');await page.getByRole('button',{name:'Abrir cotización',exact:true}).first().click();await page.getByText('Papel cotizado',{exact:true}).waitFor();
for(const name of ['Capturar bienes','Recibir precios','Enviar al proveedor'])if(await page.getByRole('button',{name,exact:true}).count())throw Error('Read-only sees action '+name);
if(await page.getByRole('link',{name:'Ver requisición',exact:true}).count())throw Error('Unauthorized shortcut visible');
checks.push({screen:'cotizacion-read-only',mutationsHidden:true,shortcutHidden:true});
current='empty-state';await page.evaluate(()=>localStorage.removeItem('reviewReadOnly'));data.cotizacion=[];await page.goto(origin+'/Adquisiciones/Cotizacion');await page.getByText('Sin cotizaciones',{exact:true}).waitFor();await page.getByRole('button',{name:'Nueva cotización',exact:true}).waitFor();checks.push({screen:'cotizacion-empty',createActionVisible:true});
current='delayed-stock-selection';delayStock=true;const slow=page.waitForRequest(r=>r.url().toLowerCase().includes('/detallesolicitudsalida/')&&r.postData()?.includes('701'));await page.goto(origin+'/Almacen/Solicitudes_Salida');await slow;await page.getByText('SAL-PRUEBA-702',{exact:true}).first().click();await page.getByText('Bien de salida 702',{exact:true}).waitFor();await page.waitForTimeout(900);if(await page.getByText('Bien de salida 701',{exact:true}).count())throw Error('Delayed response replaced active stock selection');checks.push({screen:'stock-delayed',staleResponseIgnored:true});
current='stock-retry';delayStock=false;failStock=true;await page.goto(origin+'/Almacen/Solicitudes_Salida');await page.getByRole('button',{name:'Intentar nuevamente',exact:true}).waitFor();failStock=false;await page.getByRole('button',{name:'Intentar nuevamente',exact:true}).click();await page.getByText('Bien de salida 701',{exact:true}).waitFor();checks.push({screen:'stock-retry',recovered:true});
if(errors.length)throw Error(errors.join('\n'));
fs.writeFileSync('tmp/operations-design/'+(process.env.EG_REVIEW_SCREENS?'result-focused.json':'result.json'),JSON.stringify({checks,errors},null,2));
}catch(e){await page.screenshot({path:'tmp/operations-design/failure.png',fullPage:true});console.log('FAILED '+current+'\n'+(await page.locator('body').innerText()).slice(-5500));fs.writeFileSync('tmp/operations-design/failure.json',JSON.stringify({current,requests:requests.slice(-20),errors},null,2));throw e;}finally{await browser.close();}
})().catch(e=>{console.error(e);process.exitCode=1});
