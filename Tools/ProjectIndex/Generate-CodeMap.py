"""Complementa Generate-ProjectIndex.ps1 con navegación y persistencia estáticas."""
from pathlib import Path
from collections import defaultdict
from urllib.parse import quote
import csv
import hashlib
import json
import re

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'artifacts/implementacion_2026/indice_codigo'
files = (OUT / 'files.txt').read_text(encoding='utf-8-sig').splitlines()
meta = json.loads((OUT / 'metadata.json').read_text(encoding='utf-8-sig'))

def rows(name):
    with (OUT / name).open(encoding='utf-8-sig', newline='') as stream:
        return list(csv.DictReader(stream, delimiter='\t'))

routes = rows('routes.tsv')
symbols = rows('symbols.tsv')

def link(path, label=None):
    return f'[{label or path}]({quote("../../../" + path)})'

def group(path):
    parts = path.split('/')
    if 'Modules' in parts:
        i = parts.index('Modules')
        return '/'.join(parts[i:i+2])
    if 'Platform' in parts:
        i = parts.index('Platform')
        return '/'.join(parts[i:i+2]) if i+2 < len(parts) else 'Platform'
    return parts[0]

groups = defaultdict(list)
for path in files:
    groups[group(path)].append(path)

persist = []
manifest = []
for path in files:
    full = ROOT / path
    raw = full.read_bytes()
    manifest.append({'archivo': path, 'sha256': hashlib.sha256(raw).hexdigest()})
    if path.endswith('.cs') and 'Infraestructure' in path:
        for n, line in enumerate(raw.decode('utf-8-sig', errors='replace').splitlines(), 1):
            match = re.search(r'public\s+(?:virtual\s+)?DbSet<([^>]+)>\s+(\w+)', line)
            if match:
                persist.append({'entidad': match[1], 'coleccion': match[2], 'archivo': path, 'linea': n})

with (OUT / 'persistencia.csv').open('w', encoding='utf-8-sig', newline='') as stream:
    writer = csv.DictWriter(stream, fieldnames=['entidad', 'coleccion', 'archivo', 'linea'])
    writer.writeheader()
    writer.writerows(persist)
(OUT / 'huellas.json').write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding='utf-8')

text = ['# Índice de código de EGestion360', '',
        f'Actualizado: {meta["GeneratedAt"]}. Incluye el árbol de trabajo y sus cambios locales.', '',
        f'**{len(files):,} archivos de código y soporte · {meta["Projects"]} proyectos .NET · '
        f'{len(symbols):,} entradas de símbolos, miembros y rutas.**', '',
        f'Se localizaron {sum(r["Kind"] == "page" for r in routes)} declaraciones `@page` '
        f'en {len({r["File"] for r in routes if r["Kind"] == "page"})} archivos Razor y '
        f'{len(persist)} declaraciones públicas `DbSet`.', '',
        '## Consultar', '',
        '- [Proyectos y criterios de extracción](PROJECT_MAP.md).',
        '- [Archivos](files.txt), [símbolos con línea](symbols.tsv) y [rutas declaradas](routes.tsv).',
        '- [Referencias y paquetes de proyectos](projects.json).',
        '- [Entidades expuestas por los contextos](persistencia.csv).',
        '- [Huellas SHA-256 de los archivos](huellas.json) para identificar cambios posteriores.',
        '- [Documentos de Universidad Maya](../../../output/pdf/universidad-maya/INDICE.md).', '',
        '## Arquitectura observada', '',
        '- Interfaz Blazor WebAssembly y MudBlazor: ' + link('FrontEnd/EG.Web/Program.cs') + '.',
        '- API ASP.NET Core, autenticación JWT y registro de servicios: ' + link('BackEnd/EG.ApiCoreBS/Program.cs') + '.',
        '- Persistencia con Entity Framework y SQL Server: ' + link('BackEnd/EG.Infraestructure/DbContextExtensions.cs') + '.',
        '- Contexto principal: ' + link('BackEnd/EG.Infraestructure/Models/EGestionContext.cs') + '.',
        '- Procedimientos almacenados: ' + link('BackEnd/EG.Infraestructure/Models/EGestionContextProcedures.cs') + '.',
        '- Convenciones modulares: ' + link('Docs/Estructura_Modular_EGestion360.md') + '.', '',
        'La solución organiza API, Application, Business, Domain, Infraestructure, Common y Logger; '
        'también contiene contratos compartidos, pruebas y el generador EG.Builder. '
        'El inventario incluye proyectos auxiliares fuera de la solución.', '',
        '## Módulos y áreas', '',
        'Agrupación por ubicación de archivos; los modelos compartidos o históricos pueden quedar '
        'en la carpeta de su capa. La presencia de código no confirma cobertura funcional ni funcionamiento.', '']

for name, paths in sorted(groups.items()):
    text += [f'### {name} ({len(paths)} archivos)', '']
    controllers = [p for p in paths if p.endswith('Controller.cs')]
    pages = sorted({r['File'] for r in routes if r['Kind'] == 'page' and r['File'] in paths})
    services = [p for p in paths if p.endswith('Service.cs') and '/Interfaces/' not in p and '/Contracts/' not in p]
    for title, subset in [('Controladores', controllers), ('Pantallas con ruta', pages), ('Servicios', services)]:
        if subset:
            text += [f'**{title} ({len(subset)})**', '']
            text += ['- ' + link(p, str(Path(p).with_suffix('').name)) + f' — `{p}`' for p in subset]
            text.append('')
    if not controllers and not pages and not services:
        text += ['Consultar sus rutas en `files.txt`.', '']

text += ['## SQL y pruebas', '']
for title, subset in [('Scripts SQL', [p for p in files if p.endswith('.sql')]),
                      ('Pruebas C#', [p for p in files if p.startswith('Tests/') and p.endswith('.cs')])]:
    text += [f'### {title}', '']
    text += ['- ' + link(p) for p in subset]
    text.append('')
text += ['## Alcance y actualización', '',
         'Índice estático, sin compilación ni ejecución. La extracción por expresiones regulares no '
         'resuelve herencia, rutas dinámicas ni vínculos semánticos entre capas. Los DbSet no son un '
         'inventario verificado de tablas de una base de datos conectada. No se exportan valores de configuración.', '',
         'Desde la raíz, regenerar primero el inventario y después este mapa:', '',
         '```powershell',
         r"& .\Tools\ProjectIndex\Generate-ProjectIndex.ps1 -BaselineDate (Get-Date -Format 'yyyy-MM-dd')",
         r'python .\Tools\ProjectIndex\Generate-CodeMap.py', '```', '']
(OUT / 'INDICE.md').write_text('\n'.join(text), encoding='utf-8')

assert len(files) == meta['Files']
assert len(routes) == meta['Routes']
assert len(symbols) == meta['SymbolsAndRoutes']
for item in routes + symbols:
    path = ROOT / item['File']
    assert path.is_file(), path
    assert 1 <= int(item['Line']) <= len(path.read_text(encoding='utf-8-sig', errors='replace').splitlines()), item
print(json.dumps({'archivos': len(files), 'proyectos': meta['Projects'],
                  'pantallas_con_ruta': len({r['File'] for r in routes if r['Kind'] == 'page'}),
                  'dbsets': len(persist), 'grupos': len(groups), 'referencias_verificadas': len(routes)+len(symbols)}))
