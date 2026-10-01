import fs from 'node:fs/promises';
import {FileBlob,PresentationFile} from '@oai/artifact-tool';
const p=await PresentationFile.importPptx(await FileBlob.load('C:/Desarrollo/Propuestas/Gobierno/CiaNet_Almacen_y_Patrimonio_Gobierno.pptx'));
const snap=await p.inspect({kind:'slide,textbox,image',maxChars:100000});
await fs.writeFile('C:/Desarrollo/Desarrollo/FullStack/EGestion360/tmp/presentacion_gobierno/source-inspect.ndjson',snap.ndjson);
console.log(snap.ndjson.slice(0,8000));
console.log(p.help('slide.shapes',{include:['index','notes'],maxChars:2500}).text??'');
