# EGestion360: indice de codigo actualizado

Corte de planeacion: 2026-09-30. Generado: 2026-09-30T20:24:07-06:00.
Repositorio: `C:\Desarrollo\Desarrollo\FullStack\EGestion360`.
Commit base: `afb239a49c508cc903835166e9ce05306f23df76`. Incluye archivos de trabajo con cambios locales: True.

## Inventario

- Archivos de codigo y soporte: 2336.
- Simbolos, miembros y rutas: 11423.
- Declaraciones de rutas/verbos y paginas: 1651; paginas Razor: 468.
- Proyectos .NET: 15.

## Archivos del indice

- `files.txt`: rutas de archivos; `symbols.tsv`: nombres y lineas; `routes.tsv`: atributos HTTP y paginas Razor.
- `projects.csv` y `projects.json`: SDK, frameworks, referencias y paquetes directos de cada proyecto.
- `metadata.json`: fecha, commit, conteos y criterios reproducibles.

## Proyectos .NET

| Proyecto | SDK | Framework | Referencias internas |
|---|---|---|---|
| `BackEnd/EG.ApiCoreBS/EG.ApiCoreBS.csproj` | Microsoft.NET.Sdk.Web | net10.0 | ..\EG.Application\EG.Application.csproj; ..\EG.Common\EG.Common.csproj; ..\EG.Logger\EG.Logger.csproj |
| `BackEnd/EG.Application/EG.Application.csproj` | Microsoft.NET.Sdk | net10.0 | ..\EG.Business\EG.Business.csproj; ..\EG.Common\EG.Common.csproj; ..\EG.Domain\EG.Domain.csproj; ..\EG.Infraestructure\EG.Infraestructure.csproj; ..\EG.Logger\EG.Logger.csproj |
| `BackEnd/EG.Business/EG.Business.csproj` | Microsoft.NET.Sdk | net10.0 | ..\EG.Common\EG.Common.csproj; ..\EG.Domain\EG.Domain.csproj; ..\EG.Infraestructure\EG.Infraestructure.csproj |
| `BackEnd/EG.Common/EG.Common.csproj` | Microsoft.NET.Sdk | net10.0 |  |
| `BackEnd/EG.Domain/EG.Domain.csproj` | Microsoft.NET.Sdk | net10.0 | ..\..\Shared\EG.Contracts\EG.Contracts.csproj |
| `BackEnd/EG.Infraestructure/EG.Infraestructure.csproj` | Microsoft.NET.Sdk | net10.0 | ..\EG.Common\EG.Common.csproj; ..\EG.Domain\EG.Domain.csproj |
| `BackEnd/EG.Logger/EG.Logger.csproj` | Microsoft.NET.Sdk | net10.0 | ..\EG.Common\EG.Common.csproj |
| `EG.Builder/EG.Builder.csproj` | Microsoft.NET.Sdk.Web | net10.0 | ..\BackEnd\EG.Infraestructure\EG.Infraestructure.csproj |
| `FrontEnd/EG.Web/EG.Web.csproj` | Microsoft.NET.Sdk.BlazorWebAssembly | net10.0 | ..\..\BackEnd\EG.Common\EG.Common.csproj; ..\..\Shared\EG.Contracts\EG.Contracts.csproj |
| `Shared/EG.Contracts/EG.Contracts.csproj` | Microsoft.NET.Sdk | net10.0 |  |
| `Tests/EG.UnidTest/EG.UnidTest.csproj` | Microsoft.NET.Sdk | net10.0 | ..\..\BackEnd\EG.ApiCoreBS\EG.ApiCoreBS.csproj; ..\..\BackEnd\EG.Business\EG.Business.csproj; ..\..\BackEnd\EG.Common\EG.Common.csproj; ..\..\BackEnd\EG.Domain\EG.Domain.csproj |
| `Tools/CertificadoDeploy/EGestion360.CertificateRepair/EGestion360.CertificateRepair.csproj` | Microsoft.NET.Sdk | net8.0-windows |  |
| `Tools/DeployLocalInstaller/Installer.csproj` | Microsoft.NET.Sdk | net10.0 |  |
| `Tools/LicensingGenerator/GE360.Licensing.Generator.csproj` | Microsoft.NET.Sdk | net10.0 | ..\..\Shared\EG.Contracts\EG.Contracts.csproj |
| `Tools/StressTest/EgestionStressRunner/EgestionStressRunner.csproj` | Microsoft.NET.Sdk | net10.0 |  |

## Distribucion por extension

- `.cs`: 1769.
- `.razor`: 380.
- `.css`: 36.
- `.sql`: 35.
- `.md`: 29.
- `.json`: 18.
- `.csproj`: 15.
- `.ps1`: 13.
- `.js`: 10.
- `.txt`: 9.
- `.yaml`: 6.
- `.cshtml`: 5.
- `.config`: 4.
- `.cmd`: 2.
- `.html`: 1.
- `.py`: 1.
- `.sln`: 1.
- `.slnx`: 1.
- `.props`: 1.

## Distribucion por carpeta principal

- `BackEnd`: 1400.
- `FrontEnd`: 512.
- `Shared`: 287.
- `Scripts`: 39.
- `Tools`: 27.
- `EG.Builder`: 21.
- `Skills`: 15.
- `Docs`: 12.
- `Tests`: 12.
- `Herramientas`: 4.
- `opencode.json`: 1.
- `referencias-documentales-2026-09-17.md`: 1.
- `EGestion360.slnx`: 1.
- `Directory.Build.props`: 1.
- `Analisis_Codigo_Base.md`: 1.
- `NuGet.Config`: 1.
- `.github`: 1.

## Limites y exclusiones

Es un indice lexicografico basado en expresiones regulares por linea; no demuestra compilacion, cobertura funcional, calidad ni disponibilidad de una funcionalidad. Puede omitir declaraciones multilínea, constructores, funciones locales, sintaxis inusual y rutas dinamicas; tambien puede incluir falsos positivos en comentarios multilínea. Las rutas de controlador y accion se listan por separado, sin resolver prefijos ni construir endpoints efectivos.

Se excluyen artefactos, compilaciones, dependencias y temporales: .git, .vs, .artifacts, artifacts, .codex, .codex-tmp, .agents, bin, obj, publish, output, tmp, temp, node_modules, packages, TestResults, coverage, dist, build, _framework, _content, vendor. Se omiten archivos de secretos/certificados/llaves, archivos .g.cs, minificados y mapas de origen. Los appsettings se inventarian solo por nombre; su contenido no se exporta.

Los conteos cubren el arbol de trabajo actual, incluidos archivos no versionados que cumplen las reglas. No se aplican filtros de .gitignore para evitar omitir codigo de trabajo; las exclusiones anteriores delimitan el universo. No son comparables directamente con el indice de julio, que tenia menos exclusiones y extensiones.

## Regenerar y consultar

```powershell
& .\Tools\ProjectIndex\Generate-ProjectIndex.ps1
rg -n -i 'Presupuesto|Contabilidad' artifacts/implementacion_2026/indice_codigo/files.txt
rg -n -i 'Nombre|ruta' artifacts/implementacion_2026/indice_codigo/symbols.tsv
```
