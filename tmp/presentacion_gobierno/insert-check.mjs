import {FileBlob,PresentationFile} from '@oai/artifact-tool';
const p=await PresentationFile.importPptx(await FileBlob.load('C:/Desarrollo/Propuestas/Gobierno/CiaNet_Almacen_y_Patrimonio_Gobierno.pptx'));
const r=await p.slides.insert({after:p.slides.items[9]});console.log('RETURN',r,'COUNT',p.slides.items.length);console.log('KEYS',Object.keys(r??{}));
