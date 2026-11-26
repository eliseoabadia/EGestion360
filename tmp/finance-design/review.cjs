const {chromium}=require('C:/Desarrollo/Desarrollo/FullStack/GE.UNI360/tmp/validacion-nf013-nf018-playwright/node_modules/playwright');
const fs=require('node:fs'),path=require('node:path'),cp=require('node:child_process');
const origin=process.env.EG_REVIEW_ORIGIN??'http://localhost:5248';
const plan=JSON.parse(fs.readFileSync('tmp/finance-design/guidance-plan.json','utf8'));
const inventory=JSON.parse(fs.readFileSync('tmp/finance-design/inventory.json','utf8'));
const models=new Map();
const files=cp.execFileSync('rg',['--files','Shared/EG.Contracts','BackEnd/EG.Common','-g','*.cs'],{encoding:'utf8'}).trim().split(/\r?\n/);
for(const file of files){const text=fs.readFileSync(file,'utf8');const classes=[...text.matchAll(/public\s+(?:sealed\s+|partial\s+)?class\s+(\w+)/g)];for(let i=0;i<classes.length;i++){const body=text.slice(classes[i].index,classes[i+1]?.index??text.length);const props=[...body.matchAll(/public\s+([\w<>\[\]?.,]+)\s+(\w+)\s*\{\s*get;\s*set;/g)].map(m=>({type:m[1],name:m[2]}));if(props.length)models.set(classes[i][1],props);}}
const endpoints=new Map();const registration=fs.readFileSync('FrontEnd/EG.Web/Extensions/ServiceRegistrationExtensions.cs','utf8');for(const m of registration.matchAll(/RegisterCrud<(\w+)>\(services,\s*"api\/([^"/]+)"/g))endpoints.set(m[2].toLowerCase(),m[1]);
function infer(controller){return [...models.keys()].find(name=>name.toLowerCase()===controller+'response')??[...models.keys()].find(name=>name.toLowerCase().endsWith(controller+'response'));}
function make(type,id=1){const result={};for(const p of models.get(type)??[]){const name=p.name[0].toLowerCase()+p.name.slice(1),t=p.type.replace('?','');if(t==='string'){result[name]=/simbolo|symbol/i.test(name)?'$':/monedaNombre/i.test(name)?'Peso mexicano':/monedaClave/i.test(name)?'MXN':type+' de prueba';}else if(['int','short','long','byte'].includes(t))result[name]=/^pkid|^id$/i.test(name)?id:/^fk/i.test(name)?1:/^anio$|año|anioClave/i.test(name)?2026:1;else if(['decimal','double','float'].includes(t))result[name]=/diferencia/i.test(name)?0:250;else if(t==='bool')result[name]=/^activo$|^activa$|^puede|^permitir|estaBalanceado|balanceado/i.test(name);else if(t==='DateOnly')result[name]='2026-11-26';else if(t==='DateTime'||t==='DateTimeOffset')result[name]='2026-11-26T00:00:00';}
 Object.assign(result,{activo:true});if(type==='AniosResponse')Object.assign(result,{pkidAnio:1,clave:2026,descripcion:'Ejercicio de prueba'});if(type==='PolizaResponse')Object.assign(result,{pkidPoliza:id,clavePoliza:'POL-PRUEBA-'+id,totalDebe:250,totalHaber:250,diferencia:0,estaBalanceado:true,autorizado:false,puedeEnviarFirma:true});if(type==='UsuarioResponse')Object.assign(result,{id:42,pkidUsuario:42,monedaSimbolo:'$',monedaNombre:'Peso mexicano'});return result;}
const datasets=new Map();function dataset(controller){if(!datasets.has(controller))datasets.set(controller,[make(endpoints.get(controller)??'')]);return datasets.get(controller);}
const core=[
 {name:'polizas',route:'/Contabilidad/Polizas',open:'Abrir póliza',action:'Agregar movimiento'},
 {name:'facturas',route:'/Presupuesto/Tesoreria/CuentasXPagar/Factura_Pago',open:'Abrir factura',action:'Agregar partida'},
 {name:'clc',route:'/Presupuesto/Tesoreria/CuentasXPagar/Provision_Pago',open:'Abrir CLC',action:'Asociar factura'},
 {name:'cheques',route:'/Presupuesto/Tesoreria/CuentasXPagar/Cheque_Transferencia',open:'Abrir pago',action:'Agregar partida'},
 {name:'estudios',route:'/Presupuesto/Egreso/Investigacion_Mercado',open:'Abrir estudio',action:'Capturar bienes'},
 {name:'comprometido',route:'/Presupuesto/Egreso/Presupuesto_Comprometido/Registro_Comprometido',open:'Abrir compromiso',action:'Registrar factura'},
 {name:'revision-suficiencia',route:'/Presupuesto/Egreso/Presupuesto_Comprometido/Solicitud_Suficiencia',open:'Abrir solicitud',action:'Autorizar solicitud'},
 {name:'inversiones',route:'/Presupuesto/Tesoreria/Inversiones/Listado_Inversiones',open:'Abrir inversión',action:'Registrar retiro'}
];
const cases=[...core,...plan.map((p,i)=>({name:path.basename(p.file.replaceAll('\\','/'),'.razor'),route:p.routes[0],guidance:p.title,file:p.file,tables:inventory.find(x=>x.file===p.file)?.tables??[]}))];
cases.push({name:'catalogo-contable',route:'/configuracion/contabilidad/tipo-polizas',guidance:'Consulta y captura del catálogo'});
for (const [family,folder,title] of [
 ['egreso','FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Egreso/PresupuestoModificado','Captura y autorización del egreso'],
 ['ingreso','FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Tesoreria/CuentasXCobrar/ModificadoIngreso','Captura y autorización del ingreso']]) {
 for(const file of fs.readdirSync(folder).filter(f=>f.endsWith('.razor')&&!f.includes('Shell'))){
  const route=fs.readFileSync(path.join(folder,file),'utf8').match(/@page "([^"]+)"/)?.[1];
  if(route)cases.push({name:family+'-'+file.replace('.razor',''),route,guidance:title,shell:family});
 }
}
let activeCase=null,prefillMode=false,failSecondPage=false,slowInvestment=false;
const requests=[],errors=[],consoleErrors=[],checks=[];
function result(items,totalCount=items.length){return {success:true,items,totalCount,code:'SUCCESS'};}
function pageResult(items,request){const raw=request.postDataJSON?.()??{};const page=Number(raw.page??raw.Page??1),size=Number(raw.pageSize??raw.PageSize??250);return result(items.slice((page-1)*size,page*size));}
async function main(){
const browser=await chromium.launch({channel:'msedge',headless:true}),context=await browser.newContext({viewport:{width:1600,height:1080}}),page=await context.newPage();page.setDefaultTimeout(15000);
page.on('pageerror',e=>errors.push(e.message));
page.on('console',e=>{if(e.type()==='error')consoleErrors.push(e.text());});
await page.route('**/api/**',async route=>{
 const request=route.request(),url=new URL(request.url()),p=url.pathname.toLowerCase(),segments=p.split('/'),controller=segments[2];
 const input=request.method()==='POST'?request.postDataJSON():null;requests.push({path:p,method:request.method(),input});
 if(request.method()==='OPTIONS')return route.fulfill({status:204,headers:{'access-control-allow-origin':'*','access-control-allow-methods':'*','access-control-allow-headers':'*'}});
 if(request.method()!=='GET'&&!p.includes('paginado')&&!p.includes('resumen')&&!p.endsWith('/buscar')&&!p.endsWith('/estado')){errors.push('Unexpected write blocked: '+p);return route.fulfill({status:400,body:'No writes in visual review'});}
 let body=result([]);
 if(p.includes('/navigate/version'))body={success:true,version:'Revisión de módulos'};
 else if(p.includes('/navigate/claims'))body=[];
 else if(/^\/api\/navigate\/\d+$/.test(p))body=[{pkidMenu:1,nombre:'Módulos de prueba',ruta:'/Contabilidad/Polizas',activo:true,fkidMenuSis:0}];
 else if(controller==='anios')body=result([make('AniosResponse')]);
 else if(controller==='usuario')body={success:true,data:make('UsuarioResponse',42)};
 else if(controller==='empresa')body={success:true,data:{pkidEmpresa:1,nombre:'Empresa de prueba',abreviatura:'PRUEBA'}};
 else if(controller==='cierremensual'&&p.includes('estado'))body={success:true,data:{periodoNombre:'Noviembre 2026',puedeRealizarCierre:true,totalPolizas:1,polizasBalanceadas:1,movimientos:2,totalDebe:250,totalHaber:250,diferencia:0}};
 else if(endpoints.has(controller)||infer(controller)){
  const type=endpoints.get(controller)??infer(controller);if(!endpoints.has(controller))endpoints.set(controller,type);let items=dataset(controller);
  if(activeCase?.shell==='egreso'&&controller==='egreadecuacion')items=[1,2].map(id=>({...make(type,id),fkidPolizaConta:id}));
  if(activeCase?.shell==='egreso'&&controller==='egreadecuaciondetalle')items=[1,2].map(id=>({...make(type,id),fkidEgreAdecuacionPres:id,total:250}));
  if(activeCase?.shell==='egreso'&&controller==='polizadetalle')items=[1,2].map(id=>({...make(type,id),fkidPolizaConta:id}));
  if(activeCase?.name==='inversiones'&&controller==='interes')items=Array.from({length:251},(_,i)=>({...make(type,i+1),monto:1}));
  if(activeCase?.name==='inversiones'&&controller==='retiro')items=[{...make(type),monto:1}];
  if(prefillMode&&controller==='facturadetalle'){
   if(failSecondPage&&Number(input?.page)===2)return route.fulfill({status:500,contentType:'application/json',headers:{'access-control-allow-origin':'*'},body:JSON.stringify({success:false,message:'Fallo de prueba'})});
   items=Array.from({length:251},(_,i)=>({...make(type,i+1),montoAplicado:1}));
  }
  const filter=input?.additionalFilters??input?.AdditionalFilters;
  if(filter)for(const [key,value]of Object.entries(filter)){if(key.endsWith('__in')){const prop=key.slice(0,-4);items=items.filter(x=>value.includes(x[prop[0].toLowerCase()+prop.slice(1)]));}}
  if(/\/\d+$/.test(p)&&!p.includes('paginado'))body={success:true,data:items.find(x=>Object.entries(x).some(([k,v])=>(k.startsWith('pkid')||k==='id')&&v===Number(segments.at(-1))))??items[0]};
  else if(p.includes('paginado')){const pageNumber=Number(input?.page??1),size=Math.min(Number(input?.pageSize??250),250);body=result(items.slice((pageNumber-1)*size,pageNumber*size),items.length);}
  else body=result(items);
 }
 await route.fulfill({status:200,contentType:'application/json',headers:{'access-control-allow-origin':'*'},body:JSON.stringify(body)});
});
await page.addInitScript(()=>{const enc=x=>btoa(JSON.stringify(x)).replaceAll('=','').replaceAll('+','-').replaceAll('/','_');localStorage.setItem('authToken',`${enc({alg:'none'})}.${enc({sub:'42',role:'SuperAdmin',exp:4102444800,empresaId:'1',Nombre:'Usuario de prueba'})}.fixture`);localStorage.setItem('dbPermissionClaims','[]');localStorage.setItem('userId','42');localStorage.setItem('userName','Usuario de prueba');localStorage.setItem('sucursal_seleccionada',JSON.stringify({Id:1,Nombre:'Sucursal de prueba',EmpresaId:1,EmpresaNombre:'Empresa de prueba'}));localStorage.setItem('anio_presupuestal_seleccionado',JSON.stringify({Id:1,Clave:2026,Descripcion:'Ejercicio de prueba'}));});
const manifest=JSON.parse(fs.readFileSync('FrontEnd/EG.Web/bin/FinanceReview/EG.Web.staticwebassets.runtime.json','utf8'));
const assets=JSON.parse(fs.readFileSync('FrontEnd/EG.Web/bin/FinanceReview/EG.Web.staticwebassets.endpoints.json','utf8')).Endpoints;
if(origin.endsWith(':5248'))await page.route(origin+'/**',async route=>{let p=decodeURIComponent(new URL(route.request().url()).pathname).replace(/^\//,'');if(p.startsWith('api/'))return route.fallback();let node=manifest.Root;for(const part of p.split('/'))node=node?.Children?.[part];if(!node?.Asset&&!p.includes('.'))node=manifest.Root.Children['index.html'];if(!node?.Asset)return route.fallback();const asset=node.Asset,endpoint=assets.find(e=>e.Route===p&&!e.ResponseHeaders?.some(h=>h.Name==='Content-Encoding'));const type=endpoint?.ResponseHeaders?.find(h=>h.Name==='Content-Type')?.Value??(p.endsWith('.wasm')?'application/wasm':p.endsWith('.js')?'text/javascript':p.endsWith('.json')?'application/json':p.endsWith('.css')?'text/css':'text/html');await route.fulfill({status:200,contentType:type,body:fs.readFileSync(path.join(manifest.ContentRoots[asset.ContentRootIndex],asset.SubPath))});});
let current='startup';
try{
const filter=process.env.EG_REVIEW_SCREENS?.split(',');
for(const theme of (process.env.EG_REVIEW_SMOKE?['Oscuro']:['Oscuro','Claro'])){
 await page.goto(origin+'/');await page.evaluate(theme=>localStorage.setItem('tema_seleccionado',JSON.stringify({Option:theme})),theme);
 for(const c of cases.filter(c=>!filter||filter.includes(c.name))){activeCase=c;current=c.name+'-'+theme;await page.setViewportSize({width:1600,height:1080});const before=requests.length;
  await page.goto(origin+c.route);
  if(c.open)await page.getByRole('button',{name:c.open,exact:true}).first().click();
  await page.locator('.operation-action-panel').first().waitFor();
  if(c.action)await page.getByRole('button',{name:c.action,exact:true}).first().waitFor();
  if(c.name==='inversiones'){await page.getByRole('button',{name:'Registrar retiro',exact:true}).waitFor({state:'visible'});await page.waitForFunction(()=>!document.body.innerText.includes('Cargando movimientos y estado contable'));await page.getByRole('heading',{name:'Intereses calculados',exact:true}).waitFor();if(!requests.slice(before).some(r=>r.path.includes('/interes/')&&Number(r.input?.page)===2))throw Error('Incomplete investment interest read');}
  if(c.guidance)await page.getByRole('heading',{name:c.guidance,exact:true}).first().waitFor();
  await page.locator('.operation-action-help summary').first().click();
  let detailTarget=null;
  if(process.env.EG_REVIEW_DETAILS==='1'){
   const detail={Bienes:['Abrir bien','Resguardo activo'],Firma_Resguardos:['Revisar resguardo','Bienes a firmar'],Presupuestos:['Abrir presupuesto','Partidas del presupuesto'],MatrizIndicadores:['Abrir nivel','Indicadores'],Empleados:['Abrir expediente',null]}[c.name];
   if(detail){await page.getByRole('button',{name:detail[0],exact:true}).first().click();detailTarget=detail[1]?page.getByRole('heading',{name:detail[1],exact:true}):page.locator('.rh-detail-shell');await detailTarget.waitFor();if(c.name==='Presupuestos')await page.getByRole('button',{name:'Agregar partida',exact:true}).waitFor();if(c.name==='MatrizIndicadores')await page.getByRole('button',{name:'Agregar indicador',exact:true}).waitFor();current+='-detail';}
   if(c.name==='Empleados'){
    const sections=[['Contratos','Contrato'],['Expedientes','Documento'],['Dependientes','Nombre'],['Incidencias','Fecha'],['Pensiones','Beneficiario']];
    for(const [tab,column]of sections){await page.getByRole('tab',{name:tab,exact:true}).click();await page.getByRole('columnheader',{name:column,exact:true}).waitFor();await page.screenshot({path:'tmp/finance-design/employee-'+tab+'-'+theme+'.png',fullPage:true});}
    checks.push({screen:'employee-detail-tabs',theme,sections:sections.map(s=>s[0])});
   }
  }
  if(c.shell){
   await page.getByRole('button',{name:'Abrir modificación',exact:true}).first().waitFor();
   if(c.shell==='egreso'){
    for(const [controller,key]of [['egreadecuaciondetalle','FkidEgreAdecuacionPres__in'],['polizadetalle','FkidPolizaConta__in']]){
     const batched=requests.slice(before).filter(r=>r.path.includes('/'+controller+'/')&&r.input?.additionalFilters?.[key]);
     if(batched.length!==1||batched[0].input.additionalFilters[key].length!==2)throw Error('Expected one batch for two records: '+controller);
    }
   }
   await page.getByRole('button',{name:'Abrir modificación',exact:true}).first().click();
   await page.getByRole('button',{name:c.shell==='egreso'?'Solicitar autorizacion':'Solicitar',exact:true}).waitFor();
  }
  await page.screenshot({path:'tmp/finance-design/'+current+'-desktop.png',fullPage:true});
  for(const width of [768,390]){await page.setViewportSize({width,height:844});await page.waitForTimeout(100);if(await page.evaluate(()=>document.documentElement.scrollWidth>window.innerWidth))throw Error('Horizontal overflow at '+width);}
  const target=detailTarget??(c.shell?page.getByRole('button',{name:c.shell==='egreso'?'Solicitar autorizacion':'Solicitar',exact:true}):c.action?page.getByRole('button',{name:c.action,exact:true}).first():page.locator('.operation-action-panel').first());await target.scrollIntoViewIfNeeded();await page.screenshot({path:'tmp/finance-design/'+current+'-mobile.png',fullPage:true});
  if(await page.locator('#blazor-error-ui').evaluateAll(nodes=>nodes.some(node=>getComputedStyle(node).display!=='none')))throw Error('Blazor displayed an unhandled error');
  if(await page.getByText('No fue posible mostrar esta pagina',{exact:true}).isVisible())throw Error('An error boundary replaced the screen');
  checks.push({screen:c.name,route:c.route,theme,desktop:true,tablet:true,mobile:true,requests:requests.slice(before)});console.log('PASS '+current);
 }
}
if(process.env.EG_REVIEW_PREFILL==='1'){
 activeCase={name:'factura-prefill'};prefillMode=true;failSecondPage=true;datasets.set('factura',[{...make('FacturaResponse'),estatus:3}]);current='failed-second-page';
 await page.goto(origin+'/Presupuesto/Tesoreria/CuentasXPagar/Factura_Pago');await page.getByRole('button',{name:'Abrir factura',exact:true}).first().click();await page.getByRole('button',{name:'Enviar a autorización',exact:true}).click();await page.getByText('No se pudo consultar el detalle completo. Actualiza e intenta nuevamente.',{exact:true}).waitFor();if(await page.getByRole('dialog').count())throw Error('Opened a partial prefill');
 failSecondPage=false;current='complete-prefill';const before=requests.length;await page.getByRole('button',{name:'Enviar a autorización',exact:true}).dblclick();await page.getByRole('dialog').waitFor();const total=page.getByLabel('Importe total',{exact:true});if(Number((await total.inputValue()).replaceAll(',',''))!==251)throw Error('Prefill total excludes detail pages');if(requests.slice(before).filter(r=>r.path.includes('/facturadetalle/')&&r.input?.page===1).length!==1)throw Error('Duplicate prefill request');await page.getByRole('button',{name:'Cancelar',exact:true}).last().click();checks.push({screen:'factura-prefill',secondPageFailurePreventsPartialForm:true,total:251,singleRequest:true});
}
if(errors.length)throw Error(errors.join('\n'));
fs.writeFileSync('tmp/finance-design/'+(filter?'result-focused.json':'result.json'),JSON.stringify({origin,checks,errors},null,2));
}catch(e){await page.screenshot({path:'tmp/finance-design/failure.png',fullPage:true});fs.writeFileSync('tmp/finance-design/failure.json',JSON.stringify({current,requests:requests.slice(-25),errors,consoleErrors,body:(await page.locator('body').innerText()).slice(-6000)},null,2));console.log('FAIL '+current+' '+e.message);throw e;}finally{await browser.close();}
}
main().catch(e=>{console.error(e);process.exitCode=1});
