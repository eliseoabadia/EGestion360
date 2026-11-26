const {chromium}=require('C:/Desarrollo/Desarrollo/FullStack/GE.UNI360/tmp/validacion-nf013-nf018-playwright/node_modules/playwright');
const fs=require('node:fs');
(async()=>{
const browser=await chromium.launch({channel:'msedge',headless:true});
const context=await browser.newContext({viewport:{width:1440,height:1080}});
const page=await context.newPage(); const errors=[]; let saves=0;
page.on('pageerror',e=>errors.push(e.message));page.on('response',r=>{if(r.status()>=400)console.log('RESOURCE '+r.status()+' '+r.url())}); page.on('console',m=>{if(m.type()==='error')errors.push(m.text())});
const order={pkidOrdenCompra:101,fkidEmpresaSis:1,fkidEstatusOrdenCompraOrco:2,numeroOrdenCompra:'OC-DEMO-101',proveedorNombre:'Proveedor de prueba',fechaOrdenCompra:'2026-11-20T00:00:00',fechaEntrega:'2026-11-26T00:00:00',estatusDescripcion:'Autorizada',total:2500,activo:true};
const details=[{pkidOrdenCompraDetalle:1,fkidOrdenCompraOrco:101,fkidTipoBienAlma:11,fkidUnidadesAlma:1,tipoBienCodigoClave:'PAP-001',tipoBienDescripcion:'Papel para oficina',unidadMedida:'Paquete',cantidadSolicitada:10,cantidadRecibida:8,cantidadPendiente:2,precioUnitario:120,activo:true},{pkidOrdenCompraDetalle:2,fkidOrdenCompraOrco:101,fkidTipoBienAlma:12,fkidUnidadesAlma:1,tipoBienCodigoClave:'MAT-002',tipoBienDescripcion:'Material de oficina',unidadMedida:'Pieza',cantidadSolicitada:20,cantidadRecibida:15,cantidadPendiente:5,precioUnitario:50,activo:true}];
const result=(items)=>({success:true,items,totalCount:items.length,message:'Consulta de prueba',code:'SUCCESS'});
await page.route('**/api/**',async route=>{
 const req=route.request(), path=new URL(req.url()).pathname.toLowerCase(); let body=result([]); console.log(req.method()+" "+path);
 if(req.method()==='OPTIONS') return route.fulfill({status:204,headers:{'access-control-allow-origin':'*','access-control-allow-methods':'*','access-control-allow-headers':'*'}});
 if(path.includes('/navigate/version'))body={success:true,version:'Revisión visual'};
 else if(path.includes('/navigate/claims'))body=[];
 else if(/^\/api\/navigate\/\d+$/.test(path))body=[{pkidMenu:1,nombre:'Almacén',legacyName:'Almacen',ruta:'/',activo:true,fkidMenuSis:0},{pkidMenu:2,nombre:'Recepción de pedidos',ruta:'/Almacen/Recepcion_Pedidos',activo:true,fkidMenuSis:1}];
 else if(path.includes('ordencompradetalle'))body=result(details);
 else if(path.includes('ordencompra'))body=result([order]);
 else if(path.includes('/almacen')&&req.method()==='POST'&&!path.includes('paginado')){saves++;const input=req.postDataJSON();const d=details.find(x=>x.pkidOrdenCompraDetalle===(input.fkidDetalleOrdenCompraOrco??input.FkidDetalleOrdenCompraOrco));if(d){d.cantidadRecibida+=(input.cantidad??input.Cantidad);d.cantidadPendiente-=(input.cantidad??input.Cantidad);}body={success:true,items:[],message:'Entrada de prueba confirmada',code:'SUCCESS'};}
 else if(path.includes('/anios'))body=result([{pkidAnio:1,clave:2026,descripcion:'Ejercicio de prueba',activo:true}]);
 await route.fulfill({status:200,contentType:'application/json',headers:{'access-control-allow-origin':'*'},body:JSON.stringify(body)});
});
await page.addInitScript(()=>{const enc=x=>btoa(JSON.stringify(x)).replaceAll('=','').replaceAll('+','-').replaceAll('/','_');localStorage.setItem('authToken',`${enc({alg:'none'})}.${enc({sub:'42',role:'SuperAdmin',exp:4102444800,empresaId:'1',Nombre:'Usuario de prueba'})}.fixture`);localStorage.setItem('dbPermissionClaims','[]');localStorage.setItem('userId','42');localStorage.setItem('userName','Usuario de prueba');localStorage.setItem('sucursal_seleccionada',JSON.stringify({Id:1,Nombre:'Sucursal de prueba',EmpresaId:1,EmpresaNombre:'Empresa de prueba'}));localStorage.setItem('anio_presupuestal_seleccionado',JSON.stringify({Id:1,Clave:2026,Descripcion:'Ejercicio de prueba'}));});
const manifest=JSON.parse(fs.readFileSync('FrontEnd/EG.Web/bin/Debug/net10.0/EG.Web.staticwebassets.runtime.json','utf8'));
const endpoints=JSON.parse(fs.readFileSync('FrontEnd/EG.Web/bin/Debug/net10.0/EG.Web.staticwebassets.endpoints.json','utf8')).Endpoints;
await page.route('http://localhost:5247/**',async route=>{let path=decodeURIComponent(new URL(route.request().url()).pathname).replace(/^\//,'');if(path.startsWith('api/'))return route.fallback();let node=manifest.Root;for(const part of path.split('/'))node=node?.Children?.[part];if(!node?.Asset&&!path.includes('.'))node=manifest.Root.Children['index.html'];if(!node?.Asset)return route.fallback();let asset=node.Asset;let file=require('node:path').join(manifest.ContentRoots[asset.ContentRootIndex],asset.SubPath);let ep=endpoints.find(e=>e.Route===path&&!e.ResponseHeaders?.some(h=>h.Name==='Content-Encoding'));let type=ep?.ResponseHeaders?.find(h=>h.Name==='Content-Type')?.Value; if(!type)type=path.endsWith('.wasm')?'application/wasm':path.endsWith('.js')?'text/javascript':path.endsWith('.json')?'application/json':path.endsWith('.css')?'text/css':'text/html';await route.fulfill({status:200,contentType:type,body:fs.readFileSync(file)});});
await page.goto('http://localhost:5247/Almacen/Recepcion_Pedidos');
try { await page.getByRole('heading',{name:'Recepción rápida',exact:true}).waitFor({timeout:30000}); } catch(e) { await page.screenshot({path:'tmp/recepcion-design/load-error.png',fullPage:true}); console.log(JSON.stringify({body:(await page.locator('body').innerText()).slice(-4500),errors})); throw e; }
await page.getByRole('button',{name:'Confirmar recepción',exact:true}).waitFor();
await page.waitForTimeout(1000);
await page.waitForTimeout(1500);
const confirm=page.getByRole('button',{name:'Confirmar recepción',exact:true});
const initialEnabled=await confirm.isEnabled();
await page.screenshot({path:'tmp/recepcion-design/desktop-dark.png',fullPage:true});
if(!initialEnabled)throw Error('Confirm button not ready: '+(await page.locator('.recepcion-page').innerText()).slice(-3000));
const qty=page.getByLabel('Cantidad a recibir',{exact:false});
await qty.fill('999');await confirm.click();await page.waitForTimeout(250);if(saves!==0)throw Error('Over receipt sent');
await qty.fill('1');await qty.press('Tab');await page.waitForTimeout(200);await confirm.dblclick();await page.waitForTimeout(1200);if(saves!==1)throw Error('Expected exactly one save, got '+saves+' '+(await page.locator('.quick-receipt').innerText()));
await page.setViewportSize({width:390,height:844});await page.waitForTimeout(700);const contentWidth=await page.locator('.recepcion-page').evaluate(e=>e.getBoundingClientRect().width);if(contentWidth<300)throw Error('Sidebar hides mobile content');await page.screenshot({path:'tmp/recepcion-design/mobile-dark.png',fullPage:true});await confirm.scrollIntoViewIfNeeded();await page.screenshot({path:'tmp/recepcion-design/mobile-capture.png',fullPage:true});await page.getByRole('button',{name:'Abrir o cerrar menú principal'}).click();await page.getByRole('button',{name:'Cerrar menú principal',exact:true}).click({position:{x:380,y:200}});await page.setViewportSize({width:1440,height:1080});await page.evaluate(()=>localStorage.setItem('tema_seleccionado',JSON.stringify({Option:'Claro'})));await page.reload();await page.getByRole('heading',{name:'Recepción rápida',exact:true}).waitFor();await page.waitForTimeout(800);await page.screenshot({path:'tmp/recepcion-design/desktop-light.png',fullPage:true});
const overflow=await page.evaluate(()=>document.documentElement.scrollWidth>window.innerWidth);
fs.writeFileSync('tmp/recepcion-design/result.json',JSON.stringify({initialEnabled,saves,overflow,errors},null,2));
console.log(JSON.stringify({initialEnabled,saves,overflow,errors})); await browser.close();
})().catch(e=>{console.error(e);process.exit(1)});