from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED
from lxml import etree
from PIL import Image
import re, shutil, json

root=Path(__file__).resolve().parents[2]
source=Path('C:/Desarrollo/Propuestas/Universidad Maya/Output')
out=root/'output/documentos/universidad-maya'
backup=root/'tmp/maya_fitgap/antes_exus'
backup.mkdir(exist_ok=True)
logo=Path('C:/Users/Eliseo/Downloads/PHOTO-2026-09-17-18-05-35.jpg')
iw,ih=Image.open(logo).size
ns={'w':'http://schemas.openxmlformats.org/wordprocessingml/2006/main','wp':'http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing','a':'http://schemas.openxmlformats.org/drawingml/2006/main','pic':'http://schemas.openxmlformats.org/drawingml/2006/picture','r':'http://schemas.openxmlformats.org/officeDocument/2006/relationships'}
report=[]
for src in sorted(source.glob('0*.docx')):
    assert not (backup/src.name).exists(), 'Backup exists; do not overwrite original'
    shutil.copy2(src,backup/src.name)
    with ZipFile(src) as z: entries={n:z.read(n) for n in z.namelist()}
    doc=etree.fromstring(entries['word/document.xml'])
    rels=etree.fromstring(entries['word/_rels/document.xml.rels'])
    drawings=doc.xpath('//wp:inline',namespaces=ns)
    assert len(drawings)==1
    inline=drawings[0]
    rid=inline.xpath('.//a:blip/@r:embed',namespaces=ns)[0]
    target=next(e.get('Target') for e in rels if e.get('Id')==rid)
    entries['word/'+target]=logo.read_bytes()
    extent=inline.find('wp:extent',ns)
    oldcy=int(extent.get('cy')); newcy=round(int(extent.get('cx'))*ih/iw)
    extent.set('cy',str(newcy))
    inline.find('.//a:xfrm/a:ext',ns).set('cy',str(newcy))
    for e in inline.xpath('.//wp:docPr|.//pic:cNvPr',namespaces=ns):
        e.set('name','Logo EXUS');e.set('descr','EXUS')
    # Keep the space occupied by the original branding block.
    paragraph=inline.getparent().getparent().getparent()
    assert paragraph.tag.endswith('}p')
    pp=paragraph.find('w:pPr',ns)
    if pp is None: pp=etree.Element('{'+ns['w']+'}pPr');paragraph.insert(0,pp)
    spacing=pp.find('w:spacing',ns)
    if spacing is None:spacing=etree.SubElement(pp,'{'+ns['w']+'}spacing')
    prior=int(spacing.get('{'+ns['w']+'}after','120'))
    spacing.set('{'+ns['w']+'}after',str(prior+round((oldcy-newcy)/635)))
    entries['word/document.xml']=etree.tostring(doc,xml_declaration=True,encoding='UTF-8',standalone=True)
    replacements=0
    for name,data in list(entries.items()):
        if name.endswith('.xml'):
            text=data.decode('utf-8')
            text,n=re.subn('cianet','EXUS',text,flags=re.I)
            replacements+=n
            entries[name]=text.encode('utf-8')
    assert replacements>=2
    with ZipFile(out/src.name,'w',ZIP_DEFLATED) as z:
        for name,data in entries.items():z.writestr(name,data)
    assert not any(re.search(b'cianet',v,re.I) for k,v in entries.items() if k.endswith('.xml'))
    report.append({'file':src.name,'text_replacements':replacements,'logo_dimensions':[iw,ih]})
print(json.dumps(report))
