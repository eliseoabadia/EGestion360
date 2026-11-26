const {chromium}=require('C:/Desarrollo/Desarrollo/FullStack/GE.UNI360/tmp/validacion-nf013-nf018-playwright/node_modules/playwright');
const fs=require('node:fs');
const path=require('node:path');
(async()=>{
 const browser=await chromium.launch({channel:'msedge',headless:true});
 const context=await browser.newContext({viewport:{width:1440,height:1080}});
 const page=await context.newPage(), errors=[], detailRequests=[];
 page.on('pageerror',e=>errors.push(e.message));
 const result=items=>({success:true,items,totalCount:items.length,code:'SUCCESS'});
 const requisicion={pkidRequisicion:1001,fkidEmpresaSis:1,descripcion:'Adquisición de material de oficina',fechaRequisicion:'2026-11-26T00:00:00',importe:250,areaNombre:'Almacén',solicitanteCompleto:'Usuario de prueba',fkidProgramaPres:1,fkidEgresoAutorizadoPres:1,partidasActivas:2,partidasConPosicionPresupuestal:2,montoPartidas:250,detallesActivos:2,activo:true};
 const partidas=[{pkidRequisicionPartida:1,fkidEmpresaSis:1,fkidRequisicionOrco:1001,fkidPartidaConta:21101,partidaClave:'21101',partidaDescripcion:'Materiales y útiles de oficina',monto:150,activo:true},{pkidRequisicionPartida:2,fkidEmpresaSis:1,fkidRequisicionOrco:1001,fkidPartidaConta:21201,partidaClave:'21201',partidaDescripcion:'Material de impresión',monto:100,activo:true}];
 await page.route('**/api/**',async route=>{
  const req=route.request(), url=new URL(req.url()), p=url.pathname.toLowerCase();let body=result([]);
  if(req.method()==='OPTIONS')return route.fulfill({status:204,headers:{'access-control-allow-origin':'*','access-control-allow-methods':'*','access-control-allow-headers':'*'}});
  if(p.includes('/navigate/version'))body={success:true,version:'Revisión visual'};
  else if(p.includes('/navigate/claims'))body=[];
  else if(/^\/api\/navigate\/\d+$/.test(p))body=[{pkidMenu:1,nombre:'Adquisiciones',legacyName:'Adquisiciones',ruta:'/',activo:true,fkidMenuSis:0},{pkidMenu:2,nombre:'Requisición',ruta:'/Adquisiciones/Requisicion',activo:true,fkidMenuSis:1}];
  else if(p.includes('/requisicionpartida/'))body=result(partidas);
  else if(p.includes('/requisiciondetalle/')){const data=req.postDataJSON();const filters=data.additionalFilters??data.AdditionalFilters;detailRequests.push(filters);if(filters.FkidRequisicionOrco!==1001)throw Error('Missing requisition scope');const second=Number(filters.FkidPartidaConta)===21201;body=result([{pkidRequisicionDetalle:second?2:1,fkidEmpresaSis:1,fkidRequisicionOrco:1001,fkidTipoBienAlma:second?12:11,tipoBienDescripcion:second?'Tóner de prueba':'Papel de prueba',tipoBienCodigoClave:second?'TON-002':'PAP-001',cantidad:2,unidadMedida:'Pieza',activo:true}]);}
  else if(p.endsWith('/requisicion/1001'))body={success:true,data:requisicion,code:'SUCCESS'};
  else if(p.includes('/anio'))body=result([{pkidAnio:1,clave:2026,descripcion:'Ejercicio de prueba',activo:true}]);
  else if(req.method()!=='GET'&&!p.includes('paginado')&&!p.endsWith('/resumen'))throw Error('Unexpected mutation '+p);
  await route.fulfill({status:200,contentType:'application/json',headers:{'access-control-allow-origin':'*'},body:JSON.stringify(body)});
 });
 await page.addInitScript(()=>{const enc=x=>btoa(JSON.stringify(x)).replaceAll('=','').replaceAll('+','-').replaceAll('/','_');localStorage.setItem('authToken',`${enc({alg:'none'})}.${enc({sub:'42',role:'SuperAdmin',exp:4102444800,empresaId:'1',Nombre:'Usuario de prueba'})}.fixture`);localStorage.setItem('dbPermissionClaims','[]');localStorage.setItem('userId','42');localStorage.setItem('userName','Usuario de prueba');localStorage.setItem('sucursal_seleccionada',JSON.stringify({Id:1,Nombre:'Sucursal de prueba',EmpresaId:1,EmpresaNombre:'Empresa de prueba'}));localStorage.setItem('anio_presupuestal_seleccionado',JSON.stringify({Id:1,Clave:2026,Descripcion:'Ejercicio de prueba'}));});
 const manifest=JSON.parse(fs.readFileSync('FrontEnd/EG.Web/bin/DesignReview/EG.Web.staticwebassets.runtime.json','utf8'));
 const endpoints=JSON.parse(fs.readFileSync('FrontEnd/EG.Web/bin/DesignReview/EG.Web.staticwebassets.endpoints.json','utf8')).Endpoints;
 await page.route('http://localhost:5247/**',async route=>{let p=decodeURIComponent(new URL(route.request().url()).pathname).replace(/^\//,'');if(p.startsWith('api/'))return route.fallback();let node=manifest.Root;for(const part of p.split('/'))node=node?.Children?.[part];if(!node?.Asset&&!p.includes('.'))node=manifest.Root.Children['index.html'];if(!node?.Asset)return route.fallback();const a=node.Asset;const ep=endpoints.find(e=>e.Route===p&&!e.ResponseHeaders?.some(h=>h.Name==='Content-Encoding'));const type=ep?.ResponseHeaders?.find(h=>h.Name==='Content-Type')?.Value??(p.endsWith('.wasm')?'application/wasm':p.endsWith('.js')?'text/javascript':p.endsWith('.json')?'application/json':p.endsWith('.css')?'text/css':'text/html');await route.fulfill({status:200,contentType:type,body:fs.readFileSync(path.join(manifest.ContentRoots[a.ContentRootIndex],a.SubPath))});});
 await page.goto('http://localhost:5242/Adquisiciones/Requisicion/1001');
 try {
  await page.getByText('Papel de prueba',{exact:true}).waitFor({timeout:45000});
  if(Number(detailRequests[0]?.FkidPartidaConta)!==21101)throw Error('First partida not loaded automatically');
  await page.getByRole('button',{name:'Agregar bien',exact:true}).waitFor();
  await page.getByText('Material de impresión',{exact:true}).click();
  await page.getByText('Tóner de prueba',{exact:true}).waitFor();
  if(await page.getByText('Papel de prueba',{exact:true}).count())throw Error('Previous partida leaked');
  await page.getByRole('button',{name:'Guía rápida',exact:true}).click();
  await page.getByText('Cómo continuar',{exact:true}).waitFor();
  const handle=page.locator('.sidebar-resize-handle');const box=await handle.boundingBox();
  await page.mouse.move(box.x+box.width/2,box.y+100);
  if(await page.locator('.layout-root').evaluate(e=>e.classList.contains('sidebar-resizing')))throw Error('Hover starts dragging');
  for(const event of ['blur','lostpointercapture','pointercancel','Escape','pointerup']){
   const b=await handle.boundingBox();await page.mouse.move(b.x+b.width/2,b.y+120);await page.mouse.down();await page.mouse.move(b.x+32,b.y+120);await page.waitForTimeout(80);
   if(!await page.locator('.layout-root').evaluate(e=>e.classList.contains('sidebar-resizing')))throw Error('Resize did not begin');
   if(event==='blur')await page.evaluate(()=>window.dispatchEvent(new Event('blur')));
   else if(event==='lostpointercapture')await handle.dispatchEvent('lostpointercapture');
   else if(event==='pointercancel')await page.evaluate(()=>window.dispatchEvent(new PointerEvent('pointercancel',{pointerId:1})));
   else if(event==='Escape')await page.keyboard.press('Escape');
   else await page.mouse.up();
   await page.mouse.up();
   if(await page.locator('.layout-root').evaluate(e=>e.classList.contains('sidebar-resizing')))throw Error('Cursor stuck after '+event);
  }
  await handle.dblclick();await page.screenshot({path:'tmp/requisicion-design/desktop-dark.png',fullPage:true});
  await page.setViewportSize({width:390,height:844});await page.waitForTimeout(400);
  await page.screenshot({path:'tmp/requisicion-design/mobile-dark.png',fullPage:true});
  await page.getByRole('button',{name:'Agregar bien',exact:true}).scrollIntoViewIfNeeded();
  await page.screenshot({path:'tmp/requisicion-design/mobile-actions.png',fullPage:true});
  if(await page.evaluate(()=>document.documentElement.scrollWidth>window.innerWidth))throw Error('Mobile overflow');
  await page.setViewportSize({width:1440,height:1080});await page.evaluate(()=>localStorage.setItem('tema_seleccionado',JSON.stringify({Option:'Claro'})));await page.reload();await page.getByText('Papel de prueba',{exact:true}).waitFor();await page.screenshot({path:'tmp/requisicion-design/desktop-light.png',fullPage:true});
  await page.goto('http://localhost:5242/Almacen/Recepcion_Pedidos');
  await page.getByText('No hay órdenes autorizadas para recibir',{exact:true}).waitFor();
  await page.getByRole('link',{name:'Abrir órdenes de compra',exact:true}).waitFor();
  await page.screenshot({path:'tmp/requisicion-design/receipt-empty-help.png',fullPage:true});
  if(errors.length)throw Error(errors.join('\n'));
  fs.writeFileSync('tmp/requisicion-design/result.json',JSON.stringify({autoSelected:true,rowSelection:true,pointerRelease:['blur','lostpointercapture','pointercancel','Escape','pointerup'],mobileOverflow:false,detailRequests,errors},null,2));
  console.log('PASS automatic selection, row selection, contextual help, pointer release, mobile and light theme');
 }catch(e){await page.screenshot({path:'tmp/requisicion-design/failure.png',fullPage:true});console.log((await page.locator('body').innerText()).slice(-5000));console.log(errors);throw e;}finally{await browser.close();}
})().catch(e=>{console.error(e);process.exitCode=1});
