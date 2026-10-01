from pathlib import Path
import pypdfium2 as pdfium
from pypdf import PdfReader
import json,re
root=Path(__file__).resolve().parent
report={}
for src in sorted(root.glob('0*.pdf')):
    out=root/('qa_'+src.stem[:2]);out.mkdir(exist_ok=True)
    pdf=pdfium.PdfDocument(str(src));reader=PdfReader(str(src))
    texts=[]
    for i in range(len(pdf)):
        page=pdf[i]
        bitmap=page.render(scale=1.5)
        im=bitmap.to_pil().copy().convert('RGB')
        im.save(out/f'page-{i+1}.png')
        im.save(out/f'page-{i+1}.jpg',quality=66,optimize=True)
        texts.append(reader.pages[i].extract_text())
        bitmap.close();page.close()
    alltext='\n'.join(texts)
    ids=re.findall(r'\b(?:CAT|COM|PRE|PAG|BAN|CAJ|VIA|PAT|FIS|CUM|CTL|TEC|NFR)\d\d\b',alltext)
    assert len(set(ids))==101,(src,len(set(ids)))
    assert all(ids.count(k)==1 for k in set(ids)),[k for k in set(ids) if ids.count(k)!=1]
    report[src.name]={'pages':len(pdf),'requirement_ids':len(set(ids)),'chars_per_page':[len(t) for t in texts]}
    (out/'pages.txt').write_text('\n\n'.join(f'PAGE {i+1}\n{t}' for i,t in enumerate(texts)),encoding='utf-8')
(root/'qa_report.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(report,ensure_ascii=False))
