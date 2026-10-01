# Índice de código de EGestion360

Actualizado: 2026-09-17T15:31:36-06:00. Incluye el árbol de trabajo y sus cambios locales.

**2,293 archivos de código y soporte · 14 proyectos .NET · 11,280 entradas de símbolos, miembros y rutas.**

Se localizaron 467 declaraciones `@page` en 186 archivos Razor y 568 declaraciones públicas `DbSet`.

## Consultar

- [Proyectos y criterios de extracción](PROJECT_MAP.md).
- [Archivos](files.txt), [símbolos con línea](symbols.tsv) y [rutas declaradas](routes.tsv).
- [Referencias y paquetes de proyectos](projects.json).
- [Entidades expuestas por los contextos](persistencia.csv).
- [Huellas SHA-256 de los archivos](huellas.json) para identificar cambios posteriores.
- [Documentos de Universidad Maya](../../../output/pdf/universidad-maya/INDICE.md).

## Arquitectura observada

- Interfaz Blazor WebAssembly y MudBlazor: [FrontEnd/EG.Web/Program.cs](../../../FrontEnd/EG.Web/Program.cs).
- API ASP.NET Core, autenticación JWT y registro de servicios: [BackEnd/EG.ApiCoreBS/Program.cs](../../../BackEnd/EG.ApiCoreBS/Program.cs).
- Persistencia con Entity Framework y SQL Server: [BackEnd/EG.Infraestructure/DbContextExtensions.cs](../../../BackEnd/EG.Infraestructure/DbContextExtensions.cs).
- Contexto principal: [BackEnd/EG.Infraestructure/Models/EGestionContext.cs](../../../BackEnd/EG.Infraestructure/Models/EGestionContext.cs).
- Procedimientos almacenados: [BackEnd/EG.Infraestructure/Models/EGestionContextProcedures.cs](../../../BackEnd/EG.Infraestructure/Models/EGestionContextProcedures.cs).
- Convenciones modulares: [Docs/Estructura_Modular_EGestion360.md](../../../Docs/Estructura_Modular_EGestion360.md).

La solución organiza API, Application, Business, Domain, Infraestructure, Common y Logger; también contiene contratos compartidos, pruebas y el generador EG.Builder. El inventario incluye proyectos auxiliares fuera de la solución.

## Módulos y áreas

Agrupación por ubicación de archivos; los modelos compartidos o históricos pueden quedar en la carpeta de su capa. La presencia de código no confirma cobertura funcional ni funcionamiento.

### .github (1 archivos)

Consultar sus rutas en `files.txt`.

### Analisis_Codigo_Base.md (1 archivos)

Consultar sus rutas en `files.txt`.

### BackEnd (970 archivos)

**Servicios (11)**

- [DocumentRagCleanupHostedService](../../../BackEnd/EG.ApiCoreBS/Services/DocumentRag/DocumentRagCleanupHostedService.cs) — `BackEnd/EG.ApiCoreBS/Services/DocumentRag/DocumentRagCleanupHostedService.cs`
- [OpenAiCompatibleRagEmbeddingService](../../../BackEnd/EG.ApiCoreBS/Services/DocumentRag/OpenAiCompatibleRagEmbeddingService.cs) — `BackEnd/EG.ApiCoreBS/Services/DocumentRag/OpenAiCompatibleRagEmbeddingService.cs`
- [UserContextService](../../../BackEnd/EG.ApiCoreBS/Services/UserContextService.cs) — `BackEnd/EG.ApiCoreBS/Services/UserContextService.cs`
- [AuthService](../../../BackEnd/EG.Business/Services/AuthService.cs) — `BackEnd/EG.Business/Services/AuthService.cs`
- [BitacoraService](../../../BackEnd/EG.Business/Services/BitacoraService.cs) — `BackEnd/EG.Business/Services/BitacoraService.cs`
- [EmployeeService](../../../BackEnd/EG.Business/Services/EmployeeService.cs) — `BackEnd/EG.Business/Services/EmployeeService.cs`
- [EmpresaService](../../../BackEnd/EG.Business/Services/EmpresaService.cs) — `BackEnd/EG.Business/Services/EmpresaService.cs`
- [GenericService](../../../BackEnd/EG.Business/Services/GenericService.cs) — `BackEnd/EG.Business/Services/GenericService.cs`
- [NavigateService](../../../BackEnd/EG.Business/Services/NavigateService.cs) — `BackEnd/EG.Business/Services/NavigateService.cs`
- [UserProfileService](../../../BackEnd/EG.Business/Services/UserProfileService.cs) — `BackEnd/EG.Business/Services/UserProfileService.cs`
- [UserIpService](../../../BackEnd/EG.Common/Util/UserIpService.cs) — `BackEnd/EG.Common/Util/UserIpService.cs`

### Directory.Build.props (1 archivos)

Consultar sus rutas en `files.txt`.

### Docs (10 archivos)

Consultar sus rutas en `files.txt`.

### EG.Builder (21 archivos)

**Controladores (1)**

- [BuilderController](../../../EG.Builder/Controllers/BuilderController.cs) — `EG.Builder/Controllers/BuilderController.cs`

**Servicios (1)**

- [TemplateService](../../../EG.Builder/Templates/TemplateService.cs) — `EG.Builder/Templates/TemplateService.cs`

### EGestion360.slnx (1 archivos)

Consultar sus rutas en `files.txt`.

### FrontEnd (133 archivos)

**Servicios (17)**

- [AnioPresupuestalStateService](../../../FrontEnd/EG.Web/Services/AnioPresupuestalStateService.cs) — `FrontEnd/EG.Web/Services/AnioPresupuestalStateService.cs`
- [AuthService](../../../FrontEnd/EG.Web/Services/AuthService.cs) — `FrontEnd/EG.Web/Services/AuthService.cs`
- [BaseService](../../../FrontEnd/EG.Web/Services/BaseService.cs) — `FrontEnd/EG.Web/Services/BaseService.cs`
- [AccessConfigurationService](../../../FrontEnd/EG.Web/Services/Configuration/AccessConfigurationService.cs) — `FrontEnd/EG.Web/Services/Configuration/AccessConfigurationService.cs`
- [EmpresaLogoService](../../../FrontEnd/EG.Web/Services/Configuration/EmpresaLogoService.cs) — `FrontEnd/EG.Web/Services/Configuration/EmpresaLogoService.cs`
- [NavigateService](../../../FrontEnd/EG.Web/Services/Configuration/NavigateService.cs) — `FrontEnd/EG.Web/Services/Configuration/NavigateService.cs`
- [ProfileService](../../../FrontEnd/EG.Web/Services/Configuration/ProfileService.cs) — `FrontEnd/EG.Web/Services/Configuration/ProfileService.cs`
- [DashboardService](../../../FrontEnd/EG.Web/Services/DashboardService.cs) — `FrontEnd/EG.Web/Services/DashboardService.cs`
- [GenericCrudService](../../../FrontEnd/EG.Web/Services/GenericCrudService.cs) — `FrontEnd/EG.Web/Services/GenericCrudService.cs`
- [LoginService](../../../FrontEnd/EG.Web/Services/LoginService.cs) — `FrontEnd/EG.Web/Services/LoginService.cs`
- [MenuStateService](../../../FrontEnd/EG.Web/Services/MenuStateService.cs) — `FrontEnd/EG.Web/Services/MenuStateService.cs`
- [NotificacionService](../../../FrontEnd/EG.Web/Services/NotificacionService.cs) — `FrontEnd/EG.Web/Services/NotificacionService.cs`
- [PbrDashboardService](../../../FrontEnd/EG.Web/Services/PbrDashboardService.cs) — `FrontEnd/EG.Web/Services/PbrDashboardService.cs`
- [RequestService](../../../FrontEnd/EG.Web/Services/RequestService.cs) — `FrontEnd/EG.Web/Services/RequestService.cs`
- [SucursalStateService](../../../FrontEnd/EG.Web/Services/SucursalStateService.cs) — `FrontEnd/EG.Web/Services/SucursalStateService.cs`
- [ThemeStateService](../../../FrontEnd/EG.Web/Services/ThemeStateService.cs) — `FrontEnd/EG.Web/Services/ThemeStateService.cs`
- [TipoBienDefaultsService](../../../FrontEnd/EG.Web/Services/TipoBienDefaultsService.cs) — `FrontEnd/EG.Web/Services/TipoBienDefaultsService.cs`

### Herramientas (4 archivos)

Consultar sus rutas en `files.txt`.

### Modules/GRP (773 archivos)

**Controladores (94)**

- [BitacoraController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Administracion/Seguridad/BitacoraController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Administracion/Seguridad/BitacoraController.cs`
- [AlmacenController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Almacen/AlmacenController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Almacen/AlmacenController.cs`
- [DetalleSolicitudSalidaController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Almacen/DetalleSolicitudSalidaController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Almacen/DetalleSolicitudSalidaController.cs`
- [EstatusSolController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Almacen/EstatusSolController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Almacen/EstatusSolController.cs`
- [EstatusSolicitudSalidaController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Almacen/EstatusSolicitudSalidaController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Almacen/EstatusSolicitudSalidaController.cs`
- [MotivoEsController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Almacen/MotivoEsController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Almacen/MotivoEsController.cs`
- [SolicitudSalidaController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Almacen/SolicitudSalidaController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Almacen/SolicitudSalidaController.cs`
- [UnidadesController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Almacen/UnidadesController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Almacen/UnidadesController.cs`
- [ArticuloController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Adquisicion/ArticuloController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Adquisicion/ArticuloController.cs`
- [CotizacionController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Adquisicion/CotizacionController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Adquisicion/CotizacionController.cs`
- [CotizacionDetalleController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Adquisicion/CotizacionDetalleController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Adquisicion/CotizacionDetalleController.cs`
- [EstatusRequisicionController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Adquisicion/EstatusRequisicionController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Adquisicion/EstatusRequisicionController.cs`
- [FraccionController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Adquisicion/FraccionController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Adquisicion/FraccionController.cs`
- [ModalidadController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Adquisicion/ModalidadController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Adquisicion/ModalidadController.cs`
- [OrcoProyectoController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Adquisicion/OrcoProyectoController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Adquisicion/OrcoProyectoController.cs`
- [OrdenCompraController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Adquisicion/OrdenCompraController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Adquisicion/OrdenCompraController.cs`
- [OrdenCompraDetalleController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Adquisicion/OrdenCompraDetalleController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Adquisicion/OrdenCompraDetalleController.cs`
- [OrdenCompraPartidaController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Adquisicion/OrdenCompraPartidaController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Adquisicion/OrdenCompraPartidaController.cs`
- [PaaaController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Adquisicion/PaaaController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Adquisicion/PaaaController.cs`
- [ProcedimientoContratacionController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Adquisicion/ProcedimientoContratacionController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Adquisicion/ProcedimientoContratacionController.cs`
- [ProveedorController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Adquisicion/ProveedorController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Adquisicion/ProveedorController.cs`
- [RequisicionController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Adquisicion/RequisicionController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Adquisicion/RequisicionController.cs`
- [RequisicionDetalleController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Adquisicion/RequisicionDetalleController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Adquisicion/RequisicionDetalleController.cs`
- [RequisicionPartidaController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Adquisicion/RequisicionPartidaController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Adquisicion/RequisicionPartidaController.cs`
- [SolicitudSuficienciaController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Adquisicion/SolicitudSuficienciaController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Adquisicion/SolicitudSuficienciaController.cs`
- [SolicitudSuficienciaDetalleController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Adquisicion/SolicitudSuficienciaDetalleController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Adquisicion/SolicitudSuficienciaDetalleController.cs`
- [TipoContratoController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Adquisicion/TipoContratoController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Adquisicion/TipoContratoController.cs`
- [TipoDocumentoController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Adquisicion/TipoDocumentoController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Adquisicion/TipoDocumentoController.cs`
- [TipoGarantiaController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Adquisicion/TipoGarantiaController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Adquisicion/TipoGarantiaController.cs`
- [FnController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/ClavePrograma/FnController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/ClavePrograma/FnController.cs`
- [GfController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/ClavePrograma/GfController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/ClavePrograma/GfController.cs`
- [SfController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/ClavePrograma/SfController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/ClavePrograma/SfController.cs`
- [ContaTipoDoctoPagoController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Contabilidad/ContaTipoDoctoPagoController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Contabilidad/ContaTipoDoctoPagoController.cs`
- [MatrizConversionController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Contabilidad/MatrizConversionController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Contabilidad/MatrizConversionController.cs`
- [MatrizIngresoController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Contabilidad/MatrizIngresoController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Contabilidad/MatrizIngresoController.cs`
- [TipoPolizaController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Contabilidad/TipoPolizaController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Contabilidad/TipoPolizaController.cs`
- [FamiliaController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Patrimonio/FamiliaController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Patrimonio/FamiliaController.cs`
- [GrupoBienController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Patrimonio/GrupoBienController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Patrimonio/GrupoBienController.cs`
- [MarcaController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Patrimonio/MarcaController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Patrimonio/MarcaController.cs`
- [NivelController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Patrimonio/NivelController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Patrimonio/NivelController.cs`
- [PartidaController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Patrimonio/PartidaController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Patrimonio/PartidaController.cs`
- [PersonaController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Patrimonio/PersonaController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Patrimonio/PersonaController.cs`
- [TipoAdquisicionController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Patrimonio/TipoAdquisicionController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Patrimonio/TipoAdquisicionController.cs`
- [TipoBienController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Patrimonio/TipoBienController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Patrimonio/TipoBienController.cs`
- [TipoPatrimonioController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Patrimonio/TipoPatrimonioController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Patrimonio/TipoPatrimonioController.cs`
- [ActividadInstitucionalController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Presupuestales/ActividadInstitucionalController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Presupuestales/ActividadInstitucionalController.cs`
- [AniosController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Presupuestales/AniosController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Presupuestales/AniosController.cs`
- [EgresoAutorizadoController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Presupuestales/EgresoAutorizadoController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Presupuestales/EgresoAutorizadoController.cs`
- [EgresoProyectadoController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Presupuestales/EgresoProyectadoController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Presupuestales/EgresoProyectadoController.cs`
- [FuenteFinanciamientoController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Presupuestales/FuenteFinanciamientoController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Presupuestales/FuenteFinanciamientoController.cs`
- [IngresoAutorizadoController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Presupuestales/IngresoAutorizadoController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Presupuestales/IngresoAutorizadoController.cs`
- [PgController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Presupuestales/PgController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Presupuestales/PgController.cs`
- [ProgramaController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Presupuestales/ProgramaController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Presupuestales/ProgramaController.cs`
- [ProgramaPresupuestalController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Presupuestales/ProgramaPresupuestalController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Presupuestales/ProgramaPresupuestalController.cs`
- [ProyectoController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Presupuestales/ProyectoController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Presupuestales/ProyectoController.cs`
- [RamoController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Presupuestales/RamoController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Presupuestales/RamoController.cs`
- [SectorController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Presupuestales/SectorController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Presupuestales/SectorController.cs`
- [TipoRecursoController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Presupuestales/TipoRecursoController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Presupuestales/TipoRecursoController.cs`
- [UnidadResponsableController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Presupuestales/UnidadResponsableController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Presupuestales/UnidadResponsableController.cs`
- [UrController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Presupuestales/UrController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Presupuestales/UrController.cs`
- [TipoCambioController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Tesoreria/TipoCambioController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Tesoreria/TipoCambioController.cs`
- [TipoDoctoClcController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Tesoreria/TipoDoctoClcController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Tesoreria/TipoDoctoClcController.cs`
- [TipoInversionController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Tesoreria/TipoInversionController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Tesoreria/TipoInversionController.cs`
- [TipoMonedaController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Tesoreria/TipoMonedaController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Tesoreria/TipoMonedaController.cs`
- [TipoPagoController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Tesoreria/TipoPagoController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Tesoreria/TipoPagoController.cs`
- [TipoPagoSFController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Tesoreria/TipoPagoSFController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Tesoreria/TipoPagoSFController.cs`
- [TipoSolicitudCLCController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Tesoreria/TipoSolicitudCLCController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Catalogos/Tesoreria/TipoSolicitudCLCController.cs`
- [CierreMensualController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Contabilidad/CierreMensualController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Contabilidad/CierreMensualController.cs`
- [ConceptoController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Contabilidad/ConceptoController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Contabilidad/ConceptoController.cs`
- [CuentaContableController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Contabilidad/CuentaContableController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Contabilidad/CuentaContableController.cs`
- [PolizaController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Contabilidad/PolizaController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Contabilidad/PolizaController.cs`
- [PolizaDetalleController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Contabilidad/PolizaDetalleController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Contabilidad/PolizaDetalleController.cs`
- [TipoDetallePolizaController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Contabilidad/TipoDetallePolizaController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Contabilidad/TipoDetallePolizaController.cs`
- [ConteoController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/ConteoCiclico/ConteoController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/ConteoCiclico/ConteoController.cs`
- [ConteoDetalleController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/ConteoCiclico/ConteoDetalleController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/ConteoCiclico/ConteoDetalleController.cs`
- [ConteoDetalleEscaneoController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/ConteoCiclico/ConteoDetalleEscaneoController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/ConteoCiclico/ConteoDetalleEscaneoController.cs`
- [PeriodoConteoController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/ConteoCiclico/PeriodoConteoController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/ConteoCiclico/PeriodoConteoController.cs`
- [BajaController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Patrimonio/BajaController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Patrimonio/BajaController.cs`
- [BienController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Patrimonio/BienController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Patrimonio/BienController.cs`
- [BienDisponibleBajaController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Patrimonio/BienDisponibleBajaController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Patrimonio/BienDisponibleBajaController.cs`
- [CalendarioInventarioController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Patrimonio/CalendarioInventarioController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Patrimonio/CalendarioInventarioController.cs`
- [CedulaDiferenciasController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Patrimonio/CedulaDiferenciasController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Patrimonio/CedulaDiferenciasController.cs`
- [ClasificacionBienesMueblesController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Patrimonio/ClasificacionBienesMueblesController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Patrimonio/ClasificacionBienesMueblesController.cs`
- [EstatusBajaController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Patrimonio/EstatusBajaController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Patrimonio/EstatusBajaController.cs`
- [EstatusInventarioController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Patrimonio/EstatusInventarioController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Patrimonio/EstatusInventarioController.cs`
- [InventarioController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Patrimonio/InventarioController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Patrimonio/InventarioController.cs`
- [InventarioDetalleController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Patrimonio/InventarioDetalleController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Patrimonio/InventarioDetalleController.cs`
- [ResguardoController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Patrimonio/ResguardoController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Patrimonio/ResguardoController.cs`
- [ResguardoDetalleController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Patrimonio/ResguardoDetalleController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Patrimonio/ResguardoDetalleController.cs`
- [ResguardoMovimientoController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Patrimonio/ResguardoMovimientoController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Patrimonio/ResguardoMovimientoController.cs`
- [TipoBajaController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Patrimonio/TipoBajaController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Patrimonio/TipoBajaController.cs`
- [EstudioMercadoController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Planeacion/EstudioMercadoController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Planeacion/EstudioMercadoController.cs`
- [EstudioMercadoDetalleController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Planeacion/EstudioMercadoDetalleController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Planeacion/EstudioMercadoDetalleController.cs`
- [ProvisionPagoImporteController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Presupuesto/Tesoreria/ProvisionPagoImporteController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/Presupuesto/Tesoreria/ProvisionPagoImporteController.cs`

**Pantallas con ruta (113)**

- [Bitacora](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Administracion/Seguridad/Bitacora.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Administracion/Seguridad/Bitacora.razor`
- [Estado_Contrato](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Adquisiciones/Contratos/Estado_Contrato.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Adquisiciones/Contratos/Estado_Contrato.razor`
- [Registro_Compromiso](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Adquisiciones/Contratos/Registro_Compromiso.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Adquisiciones/Contratos/Registro_Compromiso.razor`
- [Saldos_Contratos](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Adquisiciones/Contratos/Saldos_Contratos.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Adquisiciones/Contratos/Saldos_Contratos.razor`
- [Cotizaciones](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Adquisiciones/Cotizaciones.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Adquisiciones/Cotizaciones.razor`
- [OrdenCompra](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Adquisiciones/OrdenCompra.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Adquisiciones/OrdenCompra.razor`
- [Paaas](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Adquisiciones/Paaas.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Adquisiciones/Paaas.razor`
- [RequisicionDetalles](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Adquisiciones/RequisicionDetalles.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Adquisiciones/RequisicionDetalles.razor`
- [RequisicionPartidas](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Adquisiciones/RequisicionPartidas.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Adquisiciones/RequisicionPartidas.razor`
- [Requisiciones](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Adquisiciones/Requisiciones.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Adquisiciones/Requisiciones.razor`
- [SolicitudSuficienciaDetalles](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Adquisiciones/SolicitudSuficienciaDetalles.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Adquisiciones/SolicitudSuficienciaDetalles.razor`
- [SolicitudSuficiencias](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Adquisiciones/SolicitudSuficiencias.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Adquisiciones/SolicitudSuficiencias.razor`
- [Conteo_ciclico](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Almacen/Conteo_ciclico.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Almacen/Conteo_ciclico.razor`
- [Conteo_ciclico_anual](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Almacen/Conteo_ciclico_anual.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Almacen/Conteo_ciclico_anual.razor`
- [Entradas_Ajuste](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Almacen/Entradas_Ajuste.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Almacen/Entradas_Ajuste.razor`
- [Existencias_Registradas](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Almacen/Existencias_Registradas.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Almacen/Existencias_Registradas.razor`
- [MisConteos](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Almacen/MisPeriodos/MisConteos.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Almacen/MisPeriodos/MisConteos.razor`
- [Recepcion_Pedidos](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Almacen/Recepcion_Pedidos.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Almacen/Recepcion_Pedidos.razor`
- [Reporte_diferencias_Conteo](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Almacen/Reporte_diferencias_Conteo.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Almacen/Reporte_diferencias_Conteo.razor`
- [Reporte_diferencias_Conteo_anual](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Almacen/Reporte_diferencias_Conteo_anual.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Almacen/Reporte_diferencias_Conteo_anual.razor`
- [Salidas_Ajuste](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Almacen/Salidas_Ajuste.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Almacen/Salidas_Ajuste.razor`
- [Solicitudes_Salida](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Almacen/Solicitudes_Salida.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Almacen/Solicitudes_Salida.razor`
- [Suministros_Salida](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Almacen/Suministros_Salida.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Almacen/Suministros_Salida.razor`
- [Articulos](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Adquisicion/Articulos.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Adquisicion/Articulos.razor`
- [EstatusRequisiciones](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Adquisicion/EstatusRequisiciones.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Adquisicion/EstatusRequisiciones.razor`
- [Fracciones](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Adquisicion/Fracciones.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Adquisicion/Fracciones.razor`
- [Modalidades](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Adquisicion/Modalidades.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Adquisicion/Modalidades.razor`
- [ProcedimientosContratacion](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Adquisicion/ProcedimientosContratacion.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Adquisicion/ProcedimientosContratacion.razor`
- [Proveedores](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Adquisicion/Proveedores.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Adquisicion/Proveedores.razor`
- [TipoContratos](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Adquisicion/TipoContratos.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Adquisicion/TipoContratos.razor`
- [TipoDocumentos](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Adquisicion/TipoDocumentos.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Adquisicion/TipoDocumentos.razor`
- [TipoGarantias](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Adquisicion/TipoGarantias.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Adquisicion/TipoGarantias.razor`
- [EstatusSolicitud](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Almacen/EstatusSolicitud.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Almacen/EstatusSolicitud.razor`
- [MotivoEntradasSalidas](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Almacen/MotivoEntradasSalidas.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Almacen/MotivoEntradasSalidas.razor`
- [PeriodoConteo](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Almacen/PeriodoConteo.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Almacen/PeriodoConteo.razor`
- [Unidades](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Almacen/Unidades.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Almacen/Unidades.razor`
- [Funcion](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/ClavePrograma/Funcion.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/ClavePrograma/Funcion.razor`
- [GrupoFuncional](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/ClavePrograma/GrupoFuncional.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/ClavePrograma/GrupoFuncional.razor`
- [SubFuncion](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/ClavePrograma/SubFuncion.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/ClavePrograma/SubFuncion.razor`
- [CuentasContables](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Contabilidad/CuentasContables.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Contabilidad/CuentasContables.razor`
- [FormasPago](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Contabilidad/FormasPago.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Contabilidad/FormasPago.razor`
- [MatricesIngresos](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Contabilidad/MatricesIngresos.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Contabilidad/MatricesIngresos.razor`
- [MatrizConversion](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Contabilidad/MatrizConversion.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Contabilidad/MatrizConversion.razor`
- [PartidasPresupuestales](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Contabilidad/PartidasPresupuestales.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Contabilidad/PartidasPresupuestales.razor`
- [TiposDetallesPolizas](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Contabilidad/TiposDetallesPolizas.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Contabilidad/TiposDetallesPolizas.razor`
- [TiposPolizas](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Contabilidad/TiposPolizas.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Contabilidad/TiposPolizas.razor`
- [Familias](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Patrimonio/Familias.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Patrimonio/Familias.razor`
- [GruposBien](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Patrimonio/GruposBien.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Patrimonio/GruposBien.razor`
- [Marcas](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Patrimonio/Marcas.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Patrimonio/Marcas.razor`
- [Personas](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Patrimonio/Personas.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Patrimonio/Personas.razor`
- [TipoBien](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Patrimonio/TipoBien.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Patrimonio/TipoBien.razor`
- [TiposAdquisicion](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Patrimonio/TiposAdquisicion.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Patrimonio/TiposAdquisicion.razor`
- [TiposPatrimonio](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Patrimonio/TiposPatrimonio.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Patrimonio/TiposPatrimonio.razor`
- [ActividadInstitucionales](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Presupuestales/ActividadInstitucionales.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Presupuestales/ActividadInstitucionales.razor`
- [Anios](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Presupuestales/Anios.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Presupuestales/Anios.razor`
- [FuenteFinanciamientos](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Presupuestales/FuenteFinanciamientos.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Presupuestales/FuenteFinanciamientos.razor`
- [Pgs](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Presupuestales/Pgs.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Presupuestales/Pgs.razor`
- [ProgramaPresupuestals](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Presupuestales/ProgramaPresupuestals.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Presupuestales/ProgramaPresupuestals.razor`
- [ProgramasPresupuestales](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Presupuestales/ProgramasPresupuestales.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Presupuestales/ProgramasPresupuestales.razor`
- [Proyectos](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Presupuestales/Proyectos.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Presupuestales/Proyectos.razor`
- [Ramos](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Presupuestales/Ramos.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Presupuestales/Ramos.razor`
- [Sectores](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Presupuestales/Sectores.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Presupuestales/Sectores.razor`
- [TipoRecursos](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Presupuestales/TipoRecursos.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Presupuestales/TipoRecursos.razor`
- [UnidadResponsables](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Presupuestales/UnidadResponsables.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Presupuestales/UnidadResponsables.razor`
- [TipoCambio](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Tesoreria/TipoCambio.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Tesoreria/TipoCambio.razor`
- [TipoDoctoClc](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Tesoreria/TipoDoctoClc.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Tesoreria/TipoDoctoClc.razor`
- [TipoInversion](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Tesoreria/TipoInversion.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Tesoreria/TipoInversion.razor`
- [TipoMoneda](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Tesoreria/TipoMoneda.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Tesoreria/TipoMoneda.razor`
- [TipoPago](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Tesoreria/TipoPago.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Tesoreria/TipoPago.razor`
- [TipoPagoSF](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Tesoreria/TipoPagoSF.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Tesoreria/TipoPagoSF.razor`
- [TipoSolicitudCLC](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Tesoreria/TipoSolicitudCLC.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Configuration/Catalogos/Tesoreria/TipoSolicitudCLC.razor`
- [Cierre_Mensual](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Contabilidad/Cierre_Mensual.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Contabilidad/Cierre_Mensual.razor`
- [ContabilidadReportes](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Contabilidad/ContabilidadReportes.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Contabilidad/ContabilidadReportes.razor`
- [Polizas](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Contabilidad/Polizas.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Contabilidad/Polizas.razor`
- [Bajas](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Patrimonio/Bajas.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Patrimonio/Bajas.razor`
- [Bienes](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Patrimonio/Bienes.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Patrimonio/Bienes.razor`
- [Calendario_Inventarios](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Patrimonio/Calendario_Inventarios.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Patrimonio/Calendario_Inventarios.razor`
- [Cedula_Diferencia](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Patrimonio/Cedula_Diferencia.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Patrimonio/Cedula_Diferencia.razor`
- [Clasificacion_Bienes_Muebles](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Patrimonio/Clasificacion_Bienes_Muebles.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Patrimonio/Clasificacion_Bienes_Muebles.razor`
- [Firma_Resguardos](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Patrimonio/Firma_Resguardos.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Patrimonio/Firma_Resguardos.razor`
- [Inventarios](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Patrimonio/Inventarios.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Patrimonio/Inventarios.razor`
- [ResguardoHistorico](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Patrimonio/ResguardoHistorico.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Patrimonio/ResguardoHistorico.razor`
- [Resguardos](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Patrimonio/Resguardos.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Patrimonio/Resguardos.razor`
- [Investigacion_Mercado](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Egreso/Investigacion_Mercado.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Egreso/Investigacion_Mercado.razor`
- [AnteproyectoEgresos](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Egreso/Planeacion/AnteproyectoEgresos.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Egreso/Planeacion/AnteproyectoEgresos.razor`
- [PresupuestoAutorizado](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Egreso/PresupuestoAutorizado.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Egreso/PresupuestoAutorizado.razor`
- [AutorizacionSuficiencia](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Egreso/PresupuestoComprometido/AutorizacionSuficiencia.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Egreso/PresupuestoComprometido/AutorizacionSuficiencia.razor`
- [RegistroComprometido](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Egreso/PresupuestoComprometido/RegistroComprometido.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Egreso/PresupuestoComprometido/RegistroComprometido.razor`
- [SolicitudSuficiencia](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Egreso/PresupuestoComprometido/SolicitudSuficiencia.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Egreso/PresupuestoComprometido/SolicitudSuficiencia.razor`
- [PresupuestoDisponible](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Egreso/PresupuestoDisponible.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Egreso/PresupuestoDisponible.razor`
- [AdecuacionesCompensadas](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Egreso/PresupuestoModificado/AdecuacionesCompensadas.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Egreso/PresupuestoModificado/AdecuacionesCompensadas.razor`
- [Ampliaciones](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Egreso/PresupuestoModificado/Ampliaciones.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Egreso/PresupuestoModificado/Ampliaciones.razor`
- [Reducciones](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Egreso/PresupuestoModificado/Reducciones.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Egreso/PresupuestoModificado/Reducciones.razor`
- [DepositosCLC](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Tesoreria/CuentasXCobrar/DepositosCLC.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Tesoreria/CuentasXCobrar/DepositosCLC.razor`
- [IngresoAutorizado](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Tesoreria/CuentasXCobrar/IngresoAutorizado.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Tesoreria/CuentasXCobrar/IngresoAutorizado.razor`
- [IngresosClc](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Tesoreria/CuentasXCobrar/IngresosDevengados/IngresosClc.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Tesoreria/CuentasXCobrar/IngresosDevengados/IngresosClc.razor`
- [IngresosPropios](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Tesoreria/CuentasXCobrar/IngresosPropios.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Tesoreria/CuentasXCobrar/IngresosPropios.razor`
- [IngresosRecaudar](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Tesoreria/CuentasXCobrar/IngresosRecaudar.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Tesoreria/CuentasXCobrar/IngresosRecaudar.razor`
- [AdecuacionesCompensadasIngresos](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Tesoreria/CuentasXCobrar/ModificadoIngreso/AdecuacionesCompensadasIngresos.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Tesoreria/CuentasXCobrar/ModificadoIngreso/AdecuacionesCompensadasIngresos.razor`
- [AumentosPresupuestoIngreso](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Tesoreria/CuentasXCobrar/ModificadoIngreso/AumentosPresupuestoIngreso.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Tesoreria/CuentasXCobrar/ModificadoIngreso/AumentosPresupuestoIngreso.razor`
- [ReduccionPresupuestoIngreso](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Tesoreria/CuentasXCobrar/ModificadoIngreso/ReduccionPresupuestoIngreso.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Tesoreria/CuentasXCobrar/ModificadoIngreso/ReduccionPresupuestoIngreso.razor`
- [ChequeTransferencia](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Tesoreria/CuentasXPagar/ChequeTransferencia.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Tesoreria/CuentasXPagar/ChequeTransferencia.razor`
- [ProvisionPago](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Tesoreria/CuentasXPagar/ProvisionPago.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Tesoreria/CuentasXPagar/ProvisionPago.razor`
- [RecepcionFacturaComprobantePago](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Tesoreria/CuentasXPagar/RecepcionFacturaComprobantePago.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Tesoreria/CuentasXPagar/RecepcionFacturaComprobantePago.razor`
- [Banco](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Tesoreria/Inversiones/Banco.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Tesoreria/Inversiones/Banco.razor`
- [CuentaBancaria](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Tesoreria/Inversiones/CuentaBancaria.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Tesoreria/Inversiones/CuentaBancaria.razor`
- [InstrumentosInversion](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Tesoreria/Inversiones/InstrumentosInversion.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Tesoreria/Inversiones/InstrumentosInversion.razor`
- [IntermediariosFinanciero](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Tesoreria/Inversiones/IntermediariosFinanciero.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Tesoreria/Inversiones/IntermediariosFinanciero.razor`
- [ListadoInversiones](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Tesoreria/Inversiones/ListadoInversiones.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Tesoreria/Inversiones/ListadoInversiones.razor`
- [TipoPlazos](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Tesoreria/Inversiones/TipoPlazos.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Tesoreria/Inversiones/TipoPlazos.razor`
- [TipoRetiro](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Tesoreria/Inversiones/TipoRetiro.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Tesoreria/Inversiones/TipoRetiro.razor`
- [ProvisionPago](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Tesoreria/ProvisionPago.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Tesoreria/ProvisionPago.razor`
- [SaldosCuentas](../../../FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Tesoreria/SaldosCuentas.razor) — `FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Tesoreria/SaldosCuentas.razor`

**Servicios (87)**

- [AdquisicionCrudAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/AdquisicionCrudAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/AdquisicionCrudAppService.cs`
- [ArticuloAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/ArticuloAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/ArticuloAppService.cs`
- [CotizacionAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/CotizacionAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/CotizacionAppService.cs`
- [CotizacionDetalleAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/CotizacionDetalleAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/CotizacionDetalleAppService.cs`
- [EstatusRequisicionAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/EstatusRequisicionAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/EstatusRequisicionAppService.cs`
- [EstudioMercadoDetalleService](../../../BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/EstudioMercadoDetalleService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/EstudioMercadoDetalleService.cs`
- [EstudioMercadoService](../../../BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/EstudioMercadoService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/EstudioMercadoService.cs`
- [FraccionAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/FraccionAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/FraccionAppService.cs`
- [ModalidadAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/ModalidadAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/ModalidadAppService.cs`
- [OrdenCompraAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/OrdenCompraAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/OrdenCompraAppService.cs`
- [OrdenCompraDetalleAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/OrdenCompraDetalleAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/OrdenCompraDetalleAppService.cs`
- [OrdenCompraPartidaAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/OrdenCompraPartidaAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/OrdenCompraPartidaAppService.cs`
- [PaaaAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/PaaaAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/PaaaAppService.cs`
- [ProcedimientoContratacionAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/ProcedimientoContratacionAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/ProcedimientoContratacionAppService.cs`
- [ProveedorAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/ProveedorAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/ProveedorAppService.cs`
- [RequisicionAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/RequisicionAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/RequisicionAppService.cs`
- [RequisicionDetalleAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/RequisicionDetalleAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/RequisicionDetalleAppService.cs`
- [RequisicionPartidaAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/RequisicionPartidaAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/RequisicionPartidaAppService.cs`
- [SolicitudSuficienciaAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/SolicitudSuficienciaAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/SolicitudSuficienciaAppService.cs`
- [SolicitudSuficienciaDetalleAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/SolicitudSuficienciaDetalleAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/SolicitudSuficienciaDetalleAppService.cs`
- [StoredProcedureCrudAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/StoredProcedureCrudAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/StoredProcedureCrudAppService.cs`
- [TipoContratoAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/TipoContratoAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/TipoContratoAppService.cs`
- [TipoDocumentoAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/TipoDocumentoAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/TipoDocumentoAppService.cs`
- [TipoGarantiaAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/TipoGarantiaAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Adquisicion/TipoGarantiaAppService.cs`
- [AlmacenAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Almacen/AlmacenAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Almacen/AlmacenAppService.cs`
- [DetalleSolicitudSalidaAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Almacen/DetalleSolicitudSalidaAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Almacen/DetalleSolicitudSalidaAppService.cs`
- [EstatusSolicitudSalidaAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Almacen/EstatusSolicitudSalidaAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Almacen/EstatusSolicitudSalidaAppService.cs`
- [SolicitudSalidaAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Almacen/SolicitudSalidaAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Almacen/SolicitudSalidaAppService.cs`
- [EstatusSolService](../../../BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Almacen/EstatusSolService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Almacen/EstatusSolService.cs`
- [MotivoEsService](../../../BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Almacen/MotivoEsService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Almacen/MotivoEsService.cs`
- [UnidadesService](../../../BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Almacen/UnidadesService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Almacen/UnidadesService.cs`
- [FnAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/ClavePrograma/FnAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/ClavePrograma/FnAppService.cs`
- [FnService](../../../BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/ClavePrograma/FnService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/ClavePrograma/FnService.cs`
- [GfAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/ClavePrograma/GfAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/ClavePrograma/GfAppService.cs`
- [GfService](../../../BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/ClavePrograma/GfService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/ClavePrograma/GfService.cs`
- [SfAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/ClavePrograma/SfAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/ClavePrograma/SfAppService.cs`
- [SfService](../../../BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/ClavePrograma/SfService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/ClavePrograma/SfService.cs`
- [GenericCatalogService](../../../BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/GenericCatalogService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/GenericCatalogService.cs`
- [FamiliaService](../../../BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Patrimonio/FamiliaService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Patrimonio/FamiliaService.cs`
- [GrupoBienService](../../../BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Patrimonio/GrupoBienService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Patrimonio/GrupoBienService.cs`
- [MarcaService](../../../BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Patrimonio/MarcaService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Patrimonio/MarcaService.cs`
- [NivelService](../../../BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Patrimonio/NivelService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Patrimonio/NivelService.cs`
- [PartidaService](../../../BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Patrimonio/PartidaService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Patrimonio/PartidaService.cs`
- [PersonaService](../../../BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Patrimonio/PersonaService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Patrimonio/PersonaService.cs`
- [TipoAdquisicionService](../../../BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Patrimonio/TipoAdquisicionService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Patrimonio/TipoAdquisicionService.cs`
- [TipoBienService](../../../BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Patrimonio/TipoBienService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Patrimonio/TipoBienService.cs`
- [TipoPatrimonioService](../../../BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Patrimonio/TipoPatrimonioService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Patrimonio/TipoPatrimonioService.cs`
- [EgresoAutorizadoAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Presupuestales/EgresoAutorizadoAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Presupuestales/EgresoAutorizadoAppService.cs`
- [EgresoProyectadoAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Presupuestales/EgresoProyectadoAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Presupuestales/EgresoProyectadoAppService.cs`
- [IngresoAutorizadoAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Presupuestales/IngresoAutorizadoAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Presupuestales/IngresoAutorizadoAppService.cs`
- [ProvisionPagoImporteAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Tesoreria/ProvisionPagoImporteAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Tesoreria/ProvisionPagoImporteAppService.cs`
- [TipoCambioService](../../../BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Tesoreria/TipoCambioService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Tesoreria/TipoCambioService.cs`
- [TipoDoctoClcService](../../../BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Tesoreria/TipoDoctoClcService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Tesoreria/TipoDoctoClcService.cs`
- [TipoInversionService](../../../BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Tesoreria/TipoInversionService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Tesoreria/TipoInversionService.cs`
- [TipoMonedaService](../../../BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Tesoreria/TipoMonedaService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Tesoreria/TipoMonedaService.cs`
- [TipoPagoService](../../../BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Tesoreria/TipoPagoService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Tesoreria/TipoPagoService.cs`
- [TipoPagoSFService](../../../BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Tesoreria/TipoPagoSFService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Tesoreria/TipoPagoSFService.cs`
- [TipoSolicitudCLCService](../../../BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Tesoreria/TipoSolicitudCLCService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Configuracion/Catalogo/Tesoreria/TipoSolicitudCLCService.cs`
- [CierreMensualService](../../../BackEnd/EG.Application/Modules/GRP/Services/Contabilidad/CierreMensualService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Contabilidad/CierreMensualService.cs`
- [ConceptoService](../../../BackEnd/EG.Application/Modules/GRP/Services/Contabilidad/ConceptoService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Contabilidad/ConceptoService.cs`
- [ContaTipoDoctoPagoService](../../../BackEnd/EG.Application/Modules/GRP/Services/Contabilidad/ContaTipoDoctoPagoService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Contabilidad/ContaTipoDoctoPagoService.cs`
- [CuentaContableService](../../../BackEnd/EG.Application/Modules/GRP/Services/Contabilidad/CuentaContableService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Contabilidad/CuentaContableService.cs`
- [MatrizConversionService](../../../BackEnd/EG.Application/Modules/GRP/Services/Contabilidad/MatrizConversionService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Contabilidad/MatrizConversionService.cs`
- [MatrizIngresoService](../../../BackEnd/EG.Application/Modules/GRP/Services/Contabilidad/MatrizIngresoService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Contabilidad/MatrizIngresoService.cs`
- [PolizaDetalleService](../../../BackEnd/EG.Application/Modules/GRP/Services/Contabilidad/PolizaDetalleService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Contabilidad/PolizaDetalleService.cs`
- [PolizaService](../../../BackEnd/EG.Application/Modules/GRP/Services/Contabilidad/PolizaService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Contabilidad/PolizaService.cs`
- [TipoDetallePolizaService](../../../BackEnd/EG.Application/Modules/GRP/Services/Contabilidad/TipoDetallePolizaService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Contabilidad/TipoDetallePolizaService.cs`
- [TipoPolizaService](../../../BackEnd/EG.Application/Modules/GRP/Services/Contabilidad/TipoPolizaService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Contabilidad/TipoPolizaService.cs`
- [ConteoAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/ConteoCiclico/ConteoAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/ConteoCiclico/ConteoAppService.cs`
- [ConteoDetalleAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/ConteoCiclico/ConteoDetalleAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/ConteoCiclico/ConteoDetalleAppService.cs`
- [ConteoDetalleEscaneoAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/ConteoCiclico/ConteoDetalleEscaneoAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/ConteoCiclico/ConteoDetalleEscaneoAppService.cs`
- [PeriodoConteoAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/ConteoCiclico/PeriodoConteoAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/ConteoCiclico/PeriodoConteoAppService.cs`
- [BajaAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Patrimonio/BajaAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Patrimonio/BajaAppService.cs`
- [BienAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Patrimonio/BienAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Patrimonio/BienAppService.cs`
- [BienDisponibleBajaAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Patrimonio/BienDisponibleBajaAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Patrimonio/BienDisponibleBajaAppService.cs`
- [CalendarioInventarioAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Patrimonio/CalendarioInventarioAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Patrimonio/CalendarioInventarioAppService.cs`
- [CedulaDiferenciasAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Patrimonio/CedulaDiferenciasAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Patrimonio/CedulaDiferenciasAppService.cs`
- [ClasificacionBienesMueblesAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Patrimonio/ClasificacionBienesMueblesAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Patrimonio/ClasificacionBienesMueblesAppService.cs`
- [EstatusBajaAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Patrimonio/EstatusBajaAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Patrimonio/EstatusBajaAppService.cs`
- [EstatusInventarioAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Patrimonio/EstatusInventarioAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Patrimonio/EstatusInventarioAppService.cs`
- [InventarioAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Patrimonio/InventarioAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Patrimonio/InventarioAppService.cs`
- [InventarioDetalleAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Patrimonio/InventarioDetalleAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Patrimonio/InventarioDetalleAppService.cs`
- [ResguardoAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Patrimonio/ResguardoAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Patrimonio/ResguardoAppService.cs`
- [ResguardoDetalleAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Patrimonio/ResguardoDetalleAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Patrimonio/ResguardoDetalleAppService.cs`
- [TipoBajaAppService](../../../BackEnd/EG.Application/Modules/GRP/Services/Patrimonio/TipoBajaAppService.cs) — `BackEnd/EG.Application/Modules/GRP/Services/Patrimonio/TipoBajaAppService.cs`
- [PolizaAiImportService](../../../FrontEnd/EG.Web/Services/Modules/GRP/Contabilidad/PolizaAiImportService.cs) — `FrontEnd/EG.Web/Services/Modules/GRP/Contabilidad/PolizaAiImportService.cs`
- [EgresoProyectadoAiImportService](../../../FrontEnd/EG.Web/Services/Modules/GRP/Presupuestales/EgresoProyectadoAiImportService.cs) — `FrontEnd/EG.Web/Services/Modules/GRP/Presupuestales/EgresoProyectadoAiImportService.cs`

### Modules/Nomina (102 archivos)

**Controladores (3)**

- [NominaOperacionController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/Nomina/Operaciones/NominaOperacionController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/Nomina/Operaciones/NominaOperacionController.cs`
- [NominaProcesosController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/Nomina/Procesos/NominaProcesosController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/Nomina/Procesos/NominaProcesosController.cs`
- [NominaRhEmpleadoController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/Nomina/RH/NominaRhEmpleadoController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/Nomina/RH/NominaRhEmpleadoController.cs`

**Pantallas con ruta (50)**

- [NomCatalogosSimples](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomCatalogosSimples.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomCatalogosSimples.razor`
- [NomClasePuestos](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomClasePuestos.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomClasePuestos.razor`
- [NomConceptoFactors](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomConceptoFactors.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomConceptoFactors.razor`
- [NomConceptoFijos](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomConceptoFijos.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomConceptoFijos.razor`
- [NomConceptoPorcentajes](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomConceptoPorcentajes.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomConceptoPorcentajes.razor`
- [NomConceptoProporcionals](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomConceptoProporcionals.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomConceptoProporcionals.razor`
- [NomConceptoTabulars](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomConceptoTabulars.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomConceptoTabulars.razor`
- [NomConceptoVariables](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomConceptoVariables.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomConceptoVariables.razor`
- [NomConceptos](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomConceptos.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomConceptos.razor`
- [NomContratoTerceross](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomContratoTerceross.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomContratoTerceross.razor`
- [NomContratosLaborales](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomContratosLaborales.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomContratosLaborales.razor`
- [NomCreditos](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomCreditos.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomCreditos.razor`
- [NomDescuentoCreditos](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomDescuentoCreditos.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomDescuentoCreditos.razor`
- [NomDescuentoInfonavits](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomDescuentoInfonavits.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomDescuentoInfonavits.razor`
- [NomDiaSemanas](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomDiaSemanas.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomDiaSemanas.razor`
- [NomEmpresasNomina](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomEmpresasNomina.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomEmpresasNomina.razor`
- [NomEscolaridades](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomEscolaridades.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomEscolaridades.razor`
- [NomEstadosCiviles](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomEstadosCiviles.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomEstadosCiviles.razor`
- [NomEstatusPagos](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomEstatusPagos.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomEstatusPagos.razor`
- [NomFactorInts](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomFactorInts.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomFactorInts.razor`
- [NomImporteNiveles](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomImporteNiveles.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomImporteNiveles.razor`
- [NomInfonavits](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomInfonavits.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomInfonavits.razor`
- [NomMedodoPagos](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomMedodoPagos.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomMedodoPagos.razor`
- [NomNiveles](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomNiveles.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomNiveles.razor`
- [NomNombramientos](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomNombramientos.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomNombramientos.razor`
- [NomParentescos](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomParentescos.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomParentescos.razor`
- [NomPeriodoActivos](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomPeriodoActivos.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomPeriodoActivos.razor`
- [NomPlazasAutorizadas](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomPlazasAutorizadas.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomPlazasAutorizadas.razor`
- [NomPuestos](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomPuestos.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomPuestos.razor`
- [NomSalarioMinimos](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomSalarioMinimos.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomSalarioMinimos.razor`
- [NomSueldoEspecials](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomSueldoEspecials.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomSueldoEspecials.razor`
- [NomSueldoLiqFins](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomSueldoLiqFins.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomSueldoLiqFins.razor`
- [NomSueldoMensuals](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomSueldoMensuals.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomSueldoMensuals.razor`
- [NomSueldoQuincenals](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomSueldoQuincenals.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomSueldoQuincenals.razor`
- [NomSueldoSemanals](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomSueldoSemanals.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomSueldoSemanals.razor`
- [NomTablaFiscals](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomTablaFiscals.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomTablaFiscals.razor`
- [NomTipoContrataciones](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomTipoContrataciones.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomTipoContrataciones.razor`
- [NomTipoIncapacidads](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomTipoIncapacidads.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomTipoIncapacidads.razor`
- [NomTipoIncidencias](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomTipoIncidencias.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomTipoIncidencias.razor`
- [NomTipoJustificaciones](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomTipoJustificaciones.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomTipoJustificaciones.razor`
- [NomTipoPagos](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomTipoPagos.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomTipoPagos.razor`
- [NomTipoPensions](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomTipoPensions.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomTipoPensions.razor`
- [NomUniversos](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomUniversos.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Configuration/Catalogos/NomUniversos.razor`
- [Incidencias](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Nomina/Incidencias/Incidencias.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Nomina/Incidencias/Incidencias.razor`
- [JustificacionIncidencias](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Nomina/Incidencias/JustificacionIncidencias.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Nomina/Incidencias/JustificacionIncidencias.razor`
- [ReporteIncidencias](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Nomina/Incidencias/ReporteIncidencias.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Nomina/Incidencias/ReporteIncidencias.razor`
- [ConceptosVariables](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Nomina/PagosExtraordinarios/ConceptosVariables.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Nomina/PagosExtraordinarios/ConceptosVariables.razor`
- [NominaOperaciones](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/NominaOperaciones.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/NominaOperaciones.razor`
- [NominaProcesos](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/Procesos/NominaProcesos.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/Procesos/NominaProcesos.razor`
- [Empleados](../../../FrontEnd/EG.Web/Pages/Modules/Nomina/RH/Empleados.razor) — `FrontEnd/EG.Web/Pages/Modules/Nomina/RH/Empleados.razor`

**Servicios (4)**

- [NominaCrudAppService](../../../BackEnd/EG.Application/Modules/Nomina/Services/Catalogos/NominaCrudAppService.cs) — `BackEnd/EG.Application/Modules/Nomina/Services/Catalogos/NominaCrudAppService.cs`
- [NominaOperacionAppService](../../../BackEnd/EG.Application/Modules/Nomina/Services/Operaciones/NominaOperacionAppService.cs) — `BackEnd/EG.Application/Modules/Nomina/Services/Operaciones/NominaOperacionAppService.cs`
- [NominaProcesoAppService](../../../BackEnd/EG.Application/Modules/Nomina/Services/Procesos/NominaProcesoAppService.cs) — `BackEnd/EG.Application/Modules/Nomina/Services/Procesos/NominaProcesoAppService.cs`
- [NominaRhEmpleadoAppService](../../../BackEnd/EG.Application/Modules/Nomina/Services/RH/NominaRhEmpleadoAppService.cs) — `BackEnd/EG.Application/Modules/Nomina/Services/RH/NominaRhEmpleadoAppService.cs`

### Modules/PBR (23 archivos)

**Controladores (1)**

- [PbrDashboardController](../../../BackEnd/EG.ApiCoreBS/Controllers/Modules/PBR/PbrDashboardController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Modules/PBR/PbrDashboardController.cs`

**Pantallas con ruta (6)**

- [Anteproyectos](../../../FrontEnd/EG.Web/Pages/Modules/PBR/Anteproyectos.razor) — `FrontEnd/EG.Web/Pages/Modules/PBR/Anteproyectos.razor`
- [Index](../../../FrontEnd/EG.Web/Pages/Modules/PBR/Index.razor) — `FrontEnd/EG.Web/Pages/Modules/PBR/Index.razor`
- [MapaProcesos](../../../FrontEnd/EG.Web/Pages/Modules/PBR/MapaProcesos.razor) — `FrontEnd/EG.Web/Pages/Modules/PBR/MapaProcesos.razor`
- [MatrizIndicadores](../../../FrontEnd/EG.Web/Pages/Modules/PBR/MatrizIndicadores.razor) — `FrontEnd/EG.Web/Pages/Modules/PBR/MatrizIndicadores.razor`
- [MiTablero](../../../FrontEnd/EG.Web/Pages/Modules/PBR/MiTablero.razor) — `FrontEnd/EG.Web/Pages/Modules/PBR/MiTablero.razor`
- [Presupuestos](../../../FrontEnd/EG.Web/Pages/Modules/PBR/Presupuestos.razor) — `FrontEnd/EG.Web/Pages/Modules/PBR/Presupuestos.razor`

**Servicios (1)**

- [PbrDashboardAppService](../../../BackEnd/EG.Application/Modules/PBR/Services/PbrDashboardAppService.cs) — `BackEnd/EG.Application/Modules/PBR/Services/PbrDashboardAppService.cs`

### NuGet.Config (1 archivos)

Consultar sus rutas en `files.txt`.

### Platform (6 archivos)

**Controladores (1)**

- [BaseApiController](../../../BackEnd/EG.ApiCoreBS/Controllers/Platform/BaseApiController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Platform/BaseApiController.cs`

**Pantallas con ruta (4)**

- [Ayuda](../../../FrontEnd/EG.Web/Pages/Platform/Ayuda.razor) — `FrontEnd/EG.Web/Pages/Platform/Ayuda.razor`
- [Home](../../../FrontEnd/EG.Web/Pages/Platform/Home.razor) — `FrontEnd/EG.Web/Pages/Platform/Home.razor`
- [MenuPendiente](../../../FrontEnd/EG.Web/Pages/Platform/MenuPendiente.razor) — `FrontEnd/EG.Web/Pages/Platform/MenuPendiente.razor`
- [ModuleDashboard](../../../FrontEnd/EG.Web/Pages/Platform/ModuleDashboard.razor) — `FrontEnd/EG.Web/Pages/Platform/ModuleDashboard.razor`

### Platform/Account (7 archivos)

**Controladores (2)**

- [AuthController](../../../BackEnd/EG.ApiCoreBS/Controllers/Platform/Account/AuthController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Platform/Account/AuthController.cs`
- [NavigateController](../../../BackEnd/EG.ApiCoreBS/Controllers/Platform/Account/NavigateController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Platform/Account/NavigateController.cs`

**Pantallas con ruta (2)**

- [Login](../../../FrontEnd/EG.Web/Pages/Platform/Account/Login.razor) — `FrontEnd/EG.Web/Pages/Platform/Account/Login.razor`
- [Register](../../../FrontEnd/EG.Web/Pages/Platform/Account/Register.razor) — `FrontEnd/EG.Web/Pages/Platform/Account/Register.razor`

### Platform/DTOs (46 archivos)

Consultar sus rutas en `files.txt`.

### Platform/DocumentRag (6 archivos)

**Controladores (1)**

- [DocumentRagController](../../../BackEnd/EG.ApiCoreBS/Controllers/Platform/DocumentRag/DocumentRagController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Platform/DocumentRag/DocumentRagController.cs`

**Pantallas con ruta (1)**

- [DocumentRag](../../../FrontEnd/EG.Web/Pages/Platform/DocumentRag/DocumentRag.razor) — `FrontEnd/EG.Web/Pages/Platform/DocumentRag/DocumentRag.razor`

**Servicios (1)**

- [DocumentRagService](../../../FrontEnd/EG.Web/Services/Platform/DocumentRag/DocumentRagService.cs) — `FrontEnd/EG.Web/Services/Platform/DocumentRag/DocumentRagService.cs`

### Platform/FirmaDocumental (5 archivos)

**Controladores (1)**

- [FirmaDocumentalController](../../../BackEnd/EG.ApiCoreBS/Controllers/Platform/FirmaDocumental/FirmaDocumentalController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Platform/FirmaDocumental/FirmaDocumentalController.cs`

**Pantallas con ruta (1)**

- [FirmaDocumentalControl](../../../FrontEnd/EG.Web/Pages/Platform/FirmaDocumental/FirmaDocumentalControl.razor) — `FrontEnd/EG.Web/Pages/Platform/FirmaDocumental/FirmaDocumentalControl.razor`

**Servicios (1)**

- [FirmaDocumentalService](../../../FrontEnd/EG.Web/Services/Platform/FirmaDocumental/FirmaDocumentalService.cs) — `FrontEnd/EG.Web/Services/Platform/FirmaDocumental/FirmaDocumentalService.cs`

### Platform/General (19 archivos)

**Controladores (19)**

- [AccessConfigurationController](../../../BackEnd/EG.ApiCoreBS/Controllers/Platform/General/AccessConfigurationController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Platform/General/AccessConfigurationController.cs`
- [AreaController](../../../BackEnd/EG.ApiCoreBS/Controllers/Platform/General/AreaController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Platform/General/AreaController.cs`
- [AspNetRolesController](../../../BackEnd/EG.ApiCoreBS/Controllers/Platform/General/AspNetRolesController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Platform/General/AspNetRolesController.cs`
- [DashboardController](../../../BackEnd/EG.ApiCoreBS/Controllers/Platform/General/DashboardController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Platform/General/DashboardController.cs`
- [DepartamentoController](../../../BackEnd/EG.ApiCoreBS/Controllers/Platform/General/DepartamentoController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Platform/General/DepartamentoController.cs`
- [EmailController](../../../BackEnd/EG.ApiCoreBS/Controllers/Platform/General/EmailController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Platform/General/EmailController.cs`
- [EmpresaController](../../../BackEnd/EG.ApiCoreBS/Controllers/Platform/General/EmpresaController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Platform/General/EmpresaController.cs`
- [EstadoController](../../../BackEnd/EG.ApiCoreBS/Controllers/Platform/General/EstadoController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Platform/General/EstadoController.cs`
- [MenuController](../../../BackEnd/EG.ApiCoreBS/Controllers/Platform/General/MenuController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Platform/General/MenuController.cs`
- [MenuRoleController](../../../BackEnd/EG.ApiCoreBS/Controllers/Platform/General/MenuRoleController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Platform/General/MenuRoleController.cs`
- [NotificacionController](../../../BackEnd/EG.ApiCoreBS/Controllers/Platform/General/NotificacionController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Platform/General/NotificacionController.cs`
- [PaiseController](../../../BackEnd/EG.ApiCoreBS/Controllers/Platform/General/PaiseController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Platform/General/PaiseController.cs`
- [PeriodoPagoController](../../../BackEnd/EG.ApiCoreBS/Controllers/Platform/General/PeriodoPagoController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Platform/General/PeriodoPagoController.cs`
- [SucursalController](../../../BackEnd/EG.ApiCoreBS/Controllers/Platform/General/SucursalController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Platform/General/SucursalController.cs`
- [UserProfileController](../../../BackEnd/EG.ApiCoreBS/Controllers/Platform/General/UserProfileController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Platform/General/UserProfileController.cs`
- [UsuarioAreaController](../../../BackEnd/EG.ApiCoreBS/Controllers/Platform/General/UsuarioAreaController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Platform/General/UsuarioAreaController.cs`
- [UsuarioController](../../../BackEnd/EG.ApiCoreBS/Controllers/Platform/General/UsuarioController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Platform/General/UsuarioController.cs`
- [UsuarioDepartamentoController](../../../BackEnd/EG.ApiCoreBS/Controllers/Platform/General/UsuarioDepartamentoController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Platform/General/UsuarioDepartamentoController.cs`
- [UsuarioSucursalController](../../../BackEnd/EG.ApiCoreBS/Controllers/Platform/General/UsuarioSucursalController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Platform/General/UsuarioSucursalController.cs`

### Platform/Interfaces (26 archivos)

Consultar sus rutas en `files.txt`.

### Platform/Reporting (4 archivos)

**Controladores (1)**

- [ReportingExportController](../../../BackEnd/EG.ApiCoreBS/Controllers/Platform/Reporting/ReportingExportController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Platform/Reporting/ReportingExportController.cs`

**Pantallas con ruta (2)**

- [ReportDesigner](../../../FrontEnd/EG.Web/Pages/Platform/Reporting/ReportDesigner.razor) — `FrontEnd/EG.Web/Pages/Platform/Reporting/ReportDesigner.razor`
- [ReportViewer](../../../FrontEnd/EG.Web/Pages/Platform/Reporting/ReportViewer.razor) — `FrontEnd/EG.Web/Pages/Platform/Reporting/ReportViewer.razor`

### Platform/Services (30 archivos)

**Servicios (23)**

- [AccessConfigurationAppService](../../../BackEnd/EG.Application/Platform/Services/AccessConfiguration/AccessConfigurationAppService.cs) — `BackEnd/EG.Application/Platform/Services/AccessConfiguration/AccessConfigurationAppService.cs`
- [AuthAppService](../../../BackEnd/EG.Application/Platform/Services/Account/AuthAppService.cs) — `BackEnd/EG.Application/Platform/Services/Account/AuthAppService.cs`
- [NavigateAppService](../../../BackEnd/EG.Application/Platform/Services/Account/NavigateAppService.cs) — `BackEnd/EG.Application/Platform/Services/Account/NavigateAppService.cs`
- [DocumentRagAppService](../../../BackEnd/EG.Application/Platform/Services/DocumentRag/DocumentRagAppService.cs) — `BackEnd/EG.Application/Platform/Services/DocumentRag/DocumentRagAppService.cs`
- [FirmaDocumentalAppService](../../../BackEnd/EG.Application/Platform/Services/FirmaDocumental/FirmaDocumentalAppService.cs) — `BackEnd/EG.Application/Platform/Services/FirmaDocumental/FirmaDocumentalAppService.cs`
- [AreaAppService](../../../BackEnd/EG.Application/Platform/Services/General/AreaAppService.cs) — `BackEnd/EG.Application/Platform/Services/General/AreaAppService.cs`
- [AspNetRolesAppService](../../../BackEnd/EG.Application/Platform/Services/General/AspNetRolesAppService.cs) — `BackEnd/EG.Application/Platform/Services/General/AspNetRolesAppService.cs`
- [DashboardAppService](../../../BackEnd/EG.Application/Platform/Services/General/DashboardAppService.cs) — `BackEnd/EG.Application/Platform/Services/General/DashboardAppService.cs`
- [DepartamentoAppService](../../../BackEnd/EG.Application/Platform/Services/General/DepartamentoAppService.cs) — `BackEnd/EG.Application/Platform/Services/General/DepartamentoAppService.cs`
- [EmailService](../../../BackEnd/EG.Application/Platform/Services/General/EmailService.cs) — `BackEnd/EG.Application/Platform/Services/General/EmailService.cs`
- [EmpresaAppService](../../../BackEnd/EG.Application/Platform/Services/General/EmpresaAppService.cs) — `BackEnd/EG.Application/Platform/Services/General/EmpresaAppService.cs`
- [EnvioWorkflowService](../../../BackEnd/EG.Application/Platform/Services/General/EnvioWorkflowService.cs) — `BackEnd/EG.Application/Platform/Services/General/EnvioWorkflowService.cs`
- [EstadoAppService](../../../BackEnd/EG.Application/Platform/Services/General/EstadoAppService.cs) — `BackEnd/EG.Application/Platform/Services/General/EstadoAppService.cs`
- [NotificacionAppService](../../../BackEnd/EG.Application/Platform/Services/General/NotificacionAppService.cs) — `BackEnd/EG.Application/Platform/Services/General/NotificacionAppService.cs`
- [PaisAppService](../../../BackEnd/EG.Application/Platform/Services/General/PaisAppService.cs) — `BackEnd/EG.Application/Platform/Services/General/PaisAppService.cs`
- [SucursalAppService](../../../BackEnd/EG.Application/Platform/Services/General/SucursalAppService.cs) — `BackEnd/EG.Application/Platform/Services/General/SucursalAppService.cs`
- [UserProfileAppService](../../../BackEnd/EG.Application/Platform/Services/General/UserProfileAppService.cs) — `BackEnd/EG.Application/Platform/Services/General/UserProfileAppService.cs`
- [UsuarioAppService](../../../BackEnd/EG.Application/Platform/Services/General/UsuarioAppService.cs) — `BackEnd/EG.Application/Platform/Services/General/UsuarioAppService.cs`
- [UsuarioAreaAppService](../../../BackEnd/EG.Application/Platform/Services/General/UsuarioAreaAppService.cs) — `BackEnd/EG.Application/Platform/Services/General/UsuarioAreaAppService.cs`
- [UsuarioDepartamentoAppService](../../../BackEnd/EG.Application/Platform/Services/General/UsuarioDepartamentoAppService.cs) — `BackEnd/EG.Application/Platform/Services/General/UsuarioDepartamentoAppService.cs`
- [UsuarioSucursalAppService](../../../BackEnd/EG.Application/Platform/Services/General/UsuarioSucursalAppService.cs) — `BackEnd/EG.Application/Platform/Services/General/UsuarioSucursalAppService.cs`
- [SoporteDocumentalAppService](../../../BackEnd/EG.Application/Platform/Services/SoporteDocumental/SoporteDocumentalAppService.cs) — `BackEnd/EG.Application/Platform/Services/SoporteDocumental/SoporteDocumentalAppService.cs`
- [TokenService](../../../BackEnd/EG.Application/Platform/Services/TokenService.cs) — `BackEnd/EG.Application/Platform/Services/TokenService.cs`

### Platform/Settings (3 archivos)

Consultar sus rutas en `files.txt`.

### Platform/Sistema (18 archivos)

**Pantallas con ruta (7)**

- [ConfigurarAccesos](../../../FrontEnd/EG.Web/Pages/Platform/Sistema/AccessConfiguration/ConfigurarAccesos.razor) — `FrontEnd/EG.Web/Pages/Platform/Sistema/AccessConfiguration/ConfigurarAccesos.razor`
- [Departamentos](../../../FrontEnd/EG.Web/Pages/Platform/Sistema/Departamento/Departamentos.razor) — `FrontEnd/EG.Web/Pages/Platform/Sistema/Departamento/Departamentos.razor`
- [Empresas](../../../FrontEnd/EG.Web/Pages/Platform/Sistema/Empresa/Empresas.razor) — `FrontEnd/EG.Web/Pages/Platform/Sistema/Empresa/Empresas.razor`
- [Perfil](../../../FrontEnd/EG.Web/Pages/Platform/Sistema/General/Perfil.razor) — `FrontEnd/EG.Web/Pages/Platform/Sistema/General/Perfil.razor`
- [Menus](../../../FrontEnd/EG.Web/Pages/Platform/Sistema/Menu/Menus.razor) — `FrontEnd/EG.Web/Pages/Platform/Sistema/Menu/Menus.razor`
- [Sucursales](../../../FrontEnd/EG.Web/Pages/Platform/Sistema/Sucursal/Sucursales.razor) — `FrontEnd/EG.Web/Pages/Platform/Sistema/Sucursal/Sucursales.razor`
- [Usuarios](../../../FrontEnd/EG.Web/Pages/Platform/Sistema/Usuario/Usuarios.razor) — `FrontEnd/EG.Web/Pages/Platform/Sistema/Usuario/Usuarios.razor`

### Platform/SoporteDocumental (4 archivos)

**Controladores (1)**

- [SoporteDocumentalController](../../../BackEnd/EG.ApiCoreBS/Controllers/Platform/SoporteDocumental/SoporteDocumentalController.cs) — `BackEnd/EG.ApiCoreBS/Controllers/Platform/SoporteDocumental/SoporteDocumentalController.cs`

**Servicios (1)**

- [DocumentSupportService](../../../FrontEnd/EG.Web/Services/Platform/SoporteDocumental/DocumentSupportService.cs) — `FrontEnd/EG.Web/Services/Platform/SoporteDocumental/DocumentSupportService.cs`

### Scripts (38 archivos)

Consultar sus rutas en `files.txt`.

### Shared (5 archivos)

Consultar sus rutas en `files.txt`.

### Tests (11 archivos)

Consultar sus rutas en `files.txt`.

### Tools (22 archivos)

Consultar sus rutas en `files.txt`.

### opencode.json (1 archivos)

Consultar sus rutas en `files.txt`.

### referencias-documentales-2026-09-17.md (1 archivos)

Consultar sus rutas en `files.txt`.

## SQL y pruebas

### Scripts SQL

- [Scripts/00.GestionEmpresarial.sql](../../../Scripts/00.GestionEmpresarial.sql)
- [Scripts/01_GestionEmpresarial_Script_Final_BD.sql](../../../Scripts/01_GestionEmpresarial_Script_Final_BD.sql)
- [Scripts/02_GestionEmpresarial_Catalogos_Necesarios.sql](../../../Scripts/02_GestionEmpresarial_Catalogos_Necesarios.sql)
- [Scripts/03_Correcciones_Contabilidad_Gubernamental.sql](../../../Scripts/03_Correcciones_Contabilidad_Gubernamental.sql)
- [Scripts/04_Controles_Juridicos_Adquisiciones.sql](../../../Scripts/04_Controles_Juridicos_Adquisiciones.sql)
- [Scripts/05_Respaldos_Produccion.sql](../../../Scripts/05_Respaldos_Produccion.sql)
- [Scripts/06_Rendimiento_Concurrencia.sql](../../../Scripts/06_Rendimiento_Concurrencia.sql)
- [Scripts/07_Migrar_BD_PRESUPUESTO_ALMA_Bien.sql](../../../Scripts/07_Migrar_BD_PRESUPUESTO_ALMA_Bien.sql)
- [Scripts/20260724_CorregirConteoCiclico.sql](../../../Scripts/20260724_CorregirConteoCiclico.sql)
- [Scripts/20260724_EnvioWorkflow.sql](../../../Scripts/20260724_EnvioWorkflow.sql)
- [Scripts/20260724_PlanificacionAvanzadaConteoCiclico.sql](../../../Scripts/20260724_PlanificacionAvanzadaConteoCiclico.sql)
- [Scripts/20260724_RegresoChequeASolicitudSuficiencia.sql](../../../Scripts/20260724_RegresoChequeASolicitudSuficiencia.sql)
- [Scripts/20260724_RepararPolizaEgresoAutorizado.sql](../../../Scripts/20260724_RepararPolizaEgresoAutorizado.sql)
- [Scripts/20260728_Bajas_Empresa_Anio_Poliza.sql](../../../Scripts/20260728_Bajas_Empresa_Anio_Poliza.sql)
- [Scripts/20260728_Clasificacion_Bienes_Muebles_Flujo.sql](../../../Scripts/20260728_Clasificacion_Bienes_Muebles_Flujo.sql)
- [Scripts/20260728_Contratos_Compromiso_Saldos.sql](../../../Scripts/20260728_Contratos_Compromiso_Saldos.sql)
- [Scripts/20260728_EgresoAutorizado_Empresa_Flujo.sql](../../../Scripts/20260728_EgresoAutorizado_Empresa_Flujo.sql)
- [Scripts/20260728_Fix_Suficiencia_Matrices.sql](../../../Scripts/20260728_Fix_Suficiencia_Matrices.sql)
- [Scripts/20260728_FlujoRequisicionHastaCheque.sql](../../../Scripts/20260728_FlujoRequisicionHastaCheque.sql)
- [Scripts/20260728_Integridad_PAAAS_Bienes.sql](../../../Scripts/20260728_Integridad_PAAAS_Bienes.sql)
- [Scripts/20260728_IntegridadOrdenCompraContratos.sql](../../../Scripts/20260728_IntegridadOrdenCompraContratos.sql)
- [Scripts/20260729_Almacen_SolicitudSalida_Empresa_Anio_Poliza.sql](../../../Scripts/20260729_Almacen_SolicitudSalida_Empresa_Anio_Poliza.sql)
- [Scripts/20260729_Patrimonio_Inventarios_Resguardos_Contexto.sql](../../../Scripts/20260729_Patrimonio_Inventarios_Resguardos_Contexto.sql)
- [Scripts/20260729_PresupuestoModificado_Egresos_Contexto_Flujo.sql](../../../Scripts/20260729_PresupuestoModificado_Egresos_Contexto_Flujo.sql)
- [Scripts/20260730_Corregir_MatrizConversion_Duplicados.sql](../../../Scripts/20260730_Corregir_MatrizConversion_Duplicados.sql)
- [Scripts/20260810_CompletarFlujoManualCompra.sql](../../../Scripts/20260810_CompletarFlujoManualCompra.sql)
- [Scripts/20260810_FixVwSolicitudSuficienciaArea.sql](../../../Scripts/20260810_FixVwSolicitudSuficienciaArea.sql)
- [Scripts/20260810_LimpiarFlujoPruebaIntegral.sql](../../../Scripts/20260810_LimpiarFlujoPruebaIntegral.sql)
- [Scripts/20260811_Almacen_AutorizarSolicitudesYSuministros.sql](../../../Scripts/20260811_Almacen_AutorizarSolicitudesYSuministros.sql)
- [Scripts/20260811_EgresoAutorizado_AgregarEmpresaInsert.sql](../../../Scripts/20260811_EgresoAutorizado_AgregarEmpresaInsert.sql)
- [Scripts/20260811_ReversaCheque_ContratoAutorizado.sql](../../../Scripts/20260811_ReversaCheque_ContratoAutorizado.sql)
- [Scripts/Tests/20260728_BajaPatrimonial_Poliza_Rollback.sql](../../../Scripts/Tests/20260728_BajaPatrimonial_Poliza_Rollback.sql)
- [Scripts/Tests/20260728_FlujoRequisicionHastaCheque_Rollback.sql](../../../Scripts/Tests/20260728_FlujoRequisicionHastaCheque_Rollback.sql)
- [Tests/Sql/RegresoChequeASolicitudSuficiencia.integration.sql](../../../Tests/Sql/RegresoChequeASolicitudSuficiencia.integration.sql)

### Pruebas C#

- [Tests/EG.UnidTest/ApiCoreBS/SecurityAuthorizationTests.cs](../../../Tests/EG.UnidTest/ApiCoreBS/SecurityAuthorizationTests.cs)
- [Tests/EG.UnidTest/ApiCoreBS/UserContextServiceTests.cs](../../../Tests/EG.UnidTest/ApiCoreBS/UserContextServiceTests.cs)
- [Tests/EG.UnidTest/Application/ConteoCiclicoValidatorTests.cs](../../../Tests/EG.UnidTest/Application/ConteoCiclicoValidatorTests.cs)
- [Tests/EG.UnidTest/Business/GenericServicePagingTests.cs](../../../Tests/EG.UnidTest/Business/GenericServicePagingTests.cs)
- [Tests/EG.UnidTest/Domain/EnvioWorkflowEstadosTests.cs](../../../Tests/EG.UnidTest/Domain/EnvioWorkflowEstadosTests.cs)
- [Tests/EG.UnidTest/Support/FixedUserContext.cs](../../../Tests/EG.UnidTest/Support/FixedUserContext.cs)
- [Tests/EG.UnidTest/Support/InMemoryRepository.cs](../../../Tests/EG.UnidTest/Support/InMemoryRepository.cs)
- [Tests/EG.UnidTest/Support/TestAsyncEnumerable.cs](../../../Tests/EG.UnidTest/Support/TestAsyncEnumerable.cs)

## Alcance y actualización

Índice estático, sin compilación ni ejecución. La extracción por expresiones regulares no resuelve herencia, rutas dinámicas ni vínculos semánticos entre capas. Los DbSet no son un inventario verificado de tablas de una base de datos conectada. No se exportan valores de configuración.

Desde la raíz, regenerar primero el inventario y después este mapa:

```powershell
& .\Tools\ProjectIndex\Generate-ProjectIndex.ps1 -BaselineDate (Get-Date -Format 'yyyy-MM-dd')
python .\Tools\ProjectIndex\Generate-CodeMap.py
```
