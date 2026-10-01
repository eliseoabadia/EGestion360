const fs=require('fs'),path=require('path');
const {chromium}=require('C:/Users/Eliseo/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
(async()=>{
 const out=path.resolve('tmp/maya_fitgap/layers_qa');fs.mkdirSync(out,{recursive:true});
 const browser=await chromium.launch({channel:'msedge',headless:true});
 const page=await browser.newPage({viewport:{width:1600,height:1100},deviceScaleFactor:1});
 const errors=[];page.on('pageerror',e=>errors.push(e.message));
 await page.goto('file:///'+path.resolve('output/pdf/universidad-maya/Diagramas_Capas_EXUX/Arquitectura_EXUX.html').replace(/\\/g,'/'));
 await page.screenshot({path:path.join(out,'html-contexto.png'),fullPage:true});
 await page.locator('g[data-action="view:capas"]').first().click();
 if(!await page.locator('#title').textContent().then(t=>t.includes('capas')))throw Error('Context click failed');
 await page.getByRole('button',{name:'Siguiente: mapa de módulos',exact:true}).click();
 await page.screenshot({path:path.join(out,'html-modulos.png'),fullPage:true});
 await page.locator('g[data-action="module:4"]').click();
 await page.screenshot({path:path.join(out,'html-almacen.png'),fullPage:true});
 await page.locator('#tableFilter').fill('PartidaStock');
 if(await page.locator('#tableGrid .table-choice').count()!==1)throw Error('Filter failed');
 await page.locator('#tableGrid .table-choice').click();
 if(await page.locator('#title').textContent()!=='ALMA.PartidaStock')throw Error('Drilldown failed');
 await page.screenshot({path:path.join(out,'html-tabla.png'),fullPage:true});
 const before=await page.locator('#canvas').evaluate(e=>e.getBoundingClientRect().width);
 await page.locator('#plus').click();await page.waitForFunction(w=>document.querySelector('#canvas').getBoundingClientRect().width>w+50,before);const after=await page.locator('#canvas').evaluate(e=>e.getBoundingClientRect().width);
 await page.locator('#fit').click();
 const checks=await page.evaluate(()=>{
  const counts=[];
  for(let m=1;m<=15;m++){navigate('module:'+m,false);const c=document.querySelectorAll('#tableGrid .table-choice').length;const expected=Object.values(DATA.details).filter(t=>t.mod===m).length;if(c!==expected)throw Error('Count mismatch '+m);counts.push(c)}
  for(const v of DATA.views){navigate('view:'+v.id,false);if(!document.querySelector('#canvas svg'))throw Error('Missing SVG '+v.id)}
  for(const t of Object.keys(DATA.details)){navigate('table:'+t,false);if(document.querySelectorAll('.data-table tbody tr').length!==DATA.details[t].fields.length)throw Error('Fields mismatch '+t)}
  navigate('view:contexto',false);
  return {modules:counts.length,views:DATA.views.length,tables:Object.keys(DATA.details).length,counts};
 });
 await page.setViewportSize({width:390,height:844});await page.evaluate(()=>navigate('module:4',false));
 await page.screenshot({path:path.join(out,'html-mobile.png'),fullPage:true});
 const overflow=await page.evaluate(()=>document.documentElement.scrollWidth>window.innerWidth+1);
 await browser.close();const report={...checks,errors,mobileBodyOverflow:overflow,zoomBefore:before,zoomAfter:after};fs.writeFileSync(path.join(out,'browser_report.json'),JSON.stringify(report,null,2));console.log(JSON.stringify(report));if(errors.length||overflow)process.exitCode=1;
})().catch(e=>{console.error(e);process.exit(1)});
