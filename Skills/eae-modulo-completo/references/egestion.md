# Mapa de EGestion observado el 12 de septiembre de 2026

Verifica que estas rutas sigan existiendo en el repositorio actual. Son puntos de entrada, no una plantilla para copiar sin revisar.

| Responsabilidad | Ubicacion relativa al repositorio |
|---|---|
| Endpoints | BackEnd/EG.ApiCoreBS/Controllers/Modules |
| Servicios de negocio y contratos de servicio | BackEnd/EG.Application |
| DTOs compartidos | Shared/EG.Contracts |
| Contratos y configuracion restantes | BackEnd/EG.Domain |
| Mapeos | BackEnd/EG.Business |
| EF y modelos | BackEnd/EG.Infraestructure |
| Pantallas | FrontEnd/EG.Web/Pages/Modules |
| Cliente HTTP y registro | FrontEnd/EG.Web/Services y Extensions |
| Tabla compartida | FrontEnd/EG.Web/Pages/Shared/GenericTable.razor |
| Pruebas | Tests/EG.UnidTest |

Lee `Shared/EG.Contracts/README.md` si cambias DTOs. Conserva los namespaces historicos que ese documento mantiene; el nombre del namespace no determina por si solo el proyecto al que pertenece un archivo.

Para catalogos mira `BackEnd/EG.Application/Modules/Nomina/Services/Catalogos/NominaCatalogServices.cs`, `BackEnd/EG.ApiCoreBS/Controllers/Modules/Nomina/Catalogos/NominaCatalogControllerBase.cs` y `FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NominaCatalogUi.cs`. Compara con el modulo destino antes de reutilizar: un ejemplo vecino no garantiza que todos sus permisos sean suficientes.

`Tools/ProjectIndex/Generate-ProjectIndex.ps1` puede generar un indice si hace falta una vision amplia. Lee sus parametros antes de ejecutarlo; no regeneres todo el indice por una edicion pequena.

La solucion observada usa .NET, SQL Server, Blazor WebAssembly y MudBlazor. Lee los `.csproj` actuales para versiones. No actualices dependencias como parte automatica de crear un modulo.
