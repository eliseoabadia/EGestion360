from __future__ import annotations

from pathlib import Path
from zipfile import ZipFile
from lxml import etree

BASE = Path(__file__).resolve().parent
DOCX = BASE / "original.docx"
OUT = BASE / "content.txt"
IMAGES = BASE / "images"

NS = {
    "w": "http://schemas.openxmlformats.org/wordprocessingml/2006/main",
    "r": "http://schemas.openxmlformats.org/officeDocument/2006/relationships",
    "a": "http://schemas.openxmlformats.org/drawingml/2006/main",
    "pr": "http://schemas.openxmlformats.org/package/2006/relationships",
}


def text_of(node) -> str:
    parts: list[str] = []
    for el in node.iter():
        if el.tag == f"{{{NS['w']}}}t" and el.text:
            parts.append(el.text)
        elif el.tag == f"{{{NS['w']}}}tab":
            parts.append("\t")
        elif el.tag in {f"{{{NS['w']}}}br", f"{{{NS['w']}}}cr"}:
            parts.append("\n")
    return "".join(parts).strip()


def main() -> None:
    IMAGES.mkdir(parents=True, exist_ok=True)
    lines: list[str] = []
    with ZipFile(DOCX) as zf:
        for name in zf.namelist():
            if name.startswith("word/media/") and not name.endswith("/"):
                (IMAGES / Path(name).name).write_bytes(zf.read(name))

        doc_root = etree.fromstring(zf.read("word/document.xml"))
        rel_root = etree.fromstring(zf.read("word/_rels/document.xml.rels"))
        rels = {
            rel.get("Id"): rel.get("Target")
            for rel in rel_root.findall("pr:Relationship", NS)
        }

        body = doc_root.find("w:body", NS)
        assert body is not None
        p_no = 0
        table_no = 0
        for child in body:
            local = etree.QName(child).localname
            if local == "p":
                p_no += 1
                style_el = child.find("w:pPr/w:pStyle", NS)
                style = style_el.get(f"{{{NS['w']}}}val") if style_el is not None else "Normal"
                text = text_of(child)
                images: list[str] = []
                for blip in child.findall(".//a:blip", NS):
                    rid = blip.get(f"{{{NS['r']}}}embed")
                    target = rels.get(rid, rid or "unknown")
                    images.append(Path(target).name if target else "unknown")
                if text or images:
                    lines.append(f"P{p_no:03d} [{style}] {text}")
                    for image in images:
                        lines.append(f"    [IMAGE: {image}]")
            elif local == "tbl":
                table_no += 1
                lines.append(f"TABLE {table_no}")
                for row_no, row in enumerate(child.findall("w:tr", NS), start=1):
                    cells = [text_of(cell).replace("\n", " / ") for cell in row.findall("w:tc", NS)]
                    lines.append(f"  R{row_no:02d}: " + " | ".join(cells))

    OUT.write_text("\n".join(lines), encoding="utf-8")
    print(f"wrote {OUT}")
    print(f"images: {len(list(IMAGES.iterdir()))}")


if __name__ == "__main__":
    main()
