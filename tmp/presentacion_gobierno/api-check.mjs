import {FileBlob,PresentationFile} from '@oai/artifact-tool';
const p=await PresentationFile.importPptx(await FileBlob.load('C:/Desarrollo/Propuestas/Gobierno/CiaNet_Almacen_y_Patrimonio_Gobierno.pptx'));
const snap=await p.inspect({kind:'textbox',maxChars:100000});
for(const r of snap.ndjson.split('\n').filter(Boolean).map(JSON.parse).filter(r=>r.kind==='textbox').slice(0,4)){const o=p.resolve(r.id);console.log(JSON.stringify({text:r.text,style:o.text.style,position:o.position}));}
console.log(JSON.stringify(p.help('*',{search:'slides insert move delete shapes delete',include:['index','notes'],maxChars:4000})));
