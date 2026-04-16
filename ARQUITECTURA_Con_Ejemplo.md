SmartDoc: Generador de CRUD Completo para Arquitectura Blazor + MudBlazor + GenericService
🎯 Objetivo
Este documento guía a una IA para generar automáticamente todo el código necesario (frontend y backend) de un CRUD completo, siguiendo la arquitectura y patrones definidos por el usuario. La IA deberá pedir información faltante y producir código sin errores ni warnings.

📐 Filosofía del Sistema
Frontend: Blazor con MudBlazor.

Tabla genérica: GenericTable<T> con paginación, búsqueda y ordenamiento.

Página base: BaseCrudPage<TResponse, TItem> (hereda la lógica de CRUD).

Diálogo: BaseCrudDialog<TItem> + BaseEntityForm<TEntity> para formularios.

Backend: ASP.NET Core Web API.

Servicio genérico: GenericService<TEntity, TDto, TResponse> (EG.Business).

Repositorio: IRepository<T> (EG.Domain.Interfaces).

Mapeo: AutoMapper (perfiles separados por módulo).

Vistas con FK: Si una entidad tiene llaves foráneas, se usa una vista (ej. VwEmpresa) en el controlador para las consultas, mientras que el DTO se usa para escritura.

Validaciones: Se configuran dentro del controlador usando métodos AddValidationRule y AddValidationRuleWithId.

🗂️ Estructura de Carpetas Esperada
Frontend (Blazor)
text
Pages/
  └── [Modulo]/
      └── [SubModulo]/
          ├── [Entidad]s.razor        (página principal)
          └── [Entidad]Dialog.razor    (diálogo de creación/edición)
Backend
text
EG.ApiCore/
  └── Controllers/
      └── [Modulo]/
          └── [Entidad]Controller.cs

EG.Business/
  └── Mapping/
      └── [Modulo]/
          └── [Entidad]MappingProfile.cs

EG.Domain/
  └── DTOs/
      ├── Requests/
      │   └── [Modulo]/
      │       └── [Entidad]Dto.cs
      └── Responses/
          └── [Modulo]/
              └── [Entidad]Response.cs

EG.Infraestructure/
  └── Models/
      ├── [Entidad].cs          (entidad EF)
      └── Vw[Entidad].cs        (vista con FK)
Registro de Servicios (Frontend)
EG.Web/Extensions/ApiServiceExtensions.cs → agregar RegisterCrud<[Entidad]Response>(services, "api/[Entidad]");

📥 Datos Requeridos por la IA
Antes de generar código, la IA debe preguntar lo siguiente:

Nombre de la entidad (ej. Empresa, Departamento).

Módulo y submódulo (para la ruta y permisos). Ej: módulo configuracion, submódulo empresas.

Definición de la clase Entidad (el modelo EF Core, sin navegaciones virtuales, pero con propiedades de navegación si se usan en includes).

Definición de la vista VwEntidad (si existe; si no, se usará la entidad directamente, pero se recomienda una vista cuando hay FKs).

Nombre de la propiedad principal para ordenar (ej. Nombre, EmpresaNombre).

Reglas de validación específicas (unicidad, formato, rangos, etc.).

¿Tiene FK con otras tablas? Listar las tablas relacionadas y si se deben cargar en combos (ej. Estado, Moneda).

Campos de auditoría: ¿Tiene UsuarioCreacion, FechaCreacion, UsuarioModificacion, FechaModificacion?

¿Requiere lógica adicional (ej. guardar relación muchos-a-muchos)?

🧩 Pasos de Generación (Orden Estricto)
La IA debe ejecutar estos pasos en orden, produciendo el código completo al final.

1. Crear DTOs
Request DTO ([Entidad]Dto.cs)
Copiar la entidad base, eliminar propiedades virtuales.

Cambiar namespace a EG.Domain.DTOs.Requests.[Modulo].

La clase se llamará [Entidad]Dto.

Si la entidad tiene Activo, el DTO también lo tiene (se usará para escritura).

Incluir solo los campos que se puedan escribir (no incluir campos solo lectura de la vista).

Response DTO ([Entidad]Response.cs)
Copiar la vista Vw[Entidad], eliminar propiedades virtuales.

Cambiar namespace a EG.Domain.DTOs.Responses.[Modulo].

La clase se llamará [Entidad]Response.

Incluir todos los campos que se mostrarán en la tabla y en el diálogo.

2. Crear Mapping Profile
Ubicación: EG.Business.Mapping.[Modulo].[Entidad]MappingProfile.cs

csharp
using AutoMapper;
using EG.Domain.DTOs.Requests.[Modulo];
using EG.Domain.DTOs.Responses.[Modulo];
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.[Modulo]
{
    public class [Entidad]MappingProfile : Profile
    {
        public [Entidad]MappingProfile()
        {
            // Entity ↔ DTO
            CreateMap<[Entidad], [Entidad]Dto>().ReverseMap();
            
            // Vista → Response
            CreateMap<Vw[Entidad], [Entidad]Response>();
            
            // Response → DTO (ignorando propiedades extra)
            CreateMap<[Entidad]Response, [Entidad]Dto>()
                .ForMember(dest => dest.[PropiedadId], opt => opt.Ignore()) // ignorar PK si no está en DTO
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}
3. Crear Controlador
Ubicación: EG.ApiCore.Controllers.[Modulo].[Entidad]Controller.cs

Usar como machote el siguiente código (adaptar según la entidad). Incluir:

Inyección de GenericService<Entidad, EntidadDto, EntidadResponse> y GenericService<VwEntidad, EntidadDto, EntidadResponse>.

Configuración de ConfigureService() para añadir Include de navegaciones y AddRelationFilter para búsquedas en propiedades relacionadas.

Configuración de validaciones en ConfigureValidations().

Métodos: GetAll, GetById, Create, Update, Delete, GetAllPaginado, Buscar.

Machote base (tomado de DepartamentoController):

csharp
using AutoMapper;
using EG.ApiCore.Services;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.[Modulo];
using EG.Domain.DTOs.Responses.[Modulo];
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCore.Controllers.[Modulo]
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class [Entidad]Controller : ControllerBase
    {
        private readonly GenericService<[Entidad], [Entidad]Dto, [Entidad]Response> _service;
        private readonly GenericService<Vw[Entidad], [Entidad]Dto, [Entidad]Response> _serviceView;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public [Entidad]Controller(
            GenericService<[Entidad], [Entidad]Dto, [Entidad]Response> service,
            GenericService<Vw[Entidad], [Entidad]Dto, [Entidad]Response> serviceView,
            IMapper mapper,
            IUserContextService userContext)
        {
            _service = service;
            _serviceView = serviceView;
            _mapper = mapper;
            _userContext = userContext;
            ConfigureService();
            ConfigureValidations();
        }

        private void ConfigureService()
        {
            // Agregar includes para propiedades de navegación
            // _service.AddInclude(e => e.FkPropiedadNavigation);
            // Configurar búsqueda en relaciones
            // _service.AddRelationFilter("PropiedadNavegacion", new List<string> { "CampoBusqueda" });
        }

        private void ConfigureValidations()
        {
            // Reglas de validación (ej: nombre único)
            // _service.AddValidationRule("UniqueName", async (dto) => { ... });
            // _service.AddValidationRuleWithId("UniqueNameUpdate", async (dto, id) => { ... });
        }

        // Métodos CRUD: GetAll, GetById, Add, Update, Delete, GetAllPaginado, Buscar
        // (copiar exactamente la implementación de DepartamentoController)
    }
}
Nota: Los métodos CRUD deben ser idénticos en estructura a los del DepartamentoController, solo cambiar el tipo de entidad y los mensajes.

4. Registrar Servicio en Frontend
En EG.Web/Extensions/ApiServiceExtensions.cs, dentro del método AddApiServices, agregar:

csharp
RegisterCrud<[Entidad]Response>(services, "api/[Entidad]");
5. Generar Vistas Razor
a) Página principal [Entidad]s.razor
Ubicación: Pages/[Modulo]/[SubModulo]/[Entidad]s.razor.

Hereda de BaseCrudPage<[Entidad]Response, [Entidad]Response>.

Define ModuleName y SubModuleName (usados para permisos).

Usa GenericTable<T> con columnas definidas según las propiedades de [Entidad]Response.

Implementa MapToExcelData para exportación.

Implementa GetItemNameForDelete.

Machote (basado en Empresas.razor):

razor
@page "/[modulo]/[submodulo]"
@using EG.Web.Models.[Modulo]
@using EG.Web.Pages.Shared
@using EG.Web.Shared
@inherits BaseCrudPage<[Entidad]Response, [Entidad]Response>

<AccessVerification ...>
    <MudContainer ...>
        <PageHeader ... />
        <GenericTable TItem="[Entidad]Response" ...>
            <Header>...</Header>
            <Row Context="item">...</Row>
        </GenericTable>
    </MudContainer>
</AccessVerification>

@code {
    private GenericTable<[Entidad]Response> table = null!;
    protected override string ModuleName => "[modulo]";
    protected override string SubModuleName => "[submodulo]";
    protected override Type CreateDialogType => typeof([Entidad]Dialog);
    protected override Type EditDialogType => typeof([Entidad]Dialog);
    protected override Type DeleteDialogType => typeof(DeleteDialog<[Entidad]Response>);
    protected override string GetDefaultSortLabel() => "[PropiedadOrden]";
    protected override IEnumerable<object> MapToExcelData(IEnumerable<[Entidad]Response> items) { ... }
    protected override async Task<string> GetItemNameForDelete(int id) { ... }
    protected override async Task ReloadData() { ... }
}
b) Diálogo [Entidad]Dialog.razor
Usa BaseCrudDialog<TItem> y BaseEntityForm<TEntity>.

Carga combos para cada FK (usando IGenericCrudService<TRelacion>).

Implementa validaciones de campos (longitud, formato, etc.).

Maneja fechas (convertir DateOnly? a DateTime?).

Envía los datos al servicio IGenericCrudService<[Entidad]Response>.

Machote (basado en EmpresaDialog.razor).

6. Compilación y Verificación
La IA debe verificar que:

Todos los using sean correctos.

No haya propiedades virtuales en DTOs/Responses.

Los nombres de propiedades coincidan entre entidad, DTO, response y vista.

Los métodos del controlador usen el idPropertyName correcto en GetByIdAsync.

Las validaciones estén bien implementadas.

📝 Formato de Salida
La IA debe entregar el resultado en un solo bloque de Markdown con cada archivo claramente delimitado y con su ruta relativa.

Ejemplo:

markdown
## 1. DTOs

### `EG.Domain.DTOs.Requests.General.EmpresaDto.cs`
```csharp
// código
EG.Domain.DTOs.Responses.General.EmpresaResponse.cs
csharp
// código
2. Mapping Profile
... etc.

text

Además, debe incluir una sección de **instrucciones finales** para el usuario (cómo compilar, qué ajustar manualmente).

---

## ❓ Preguntas que la IA debe hacer al usuario (si falta info)

- ¿Cuál es el nombre exacto de la entidad y la vista?
- ¿Qué propiedades tiene la entidad? (proporcionar el código de la clase)
- ¿Qué propiedades tiene la vista? (si no existe, se usará la entidad directamente)
- ¿Cuál es el módulo y submódulo para la ruta? (ej. `configuracion/empresas`)
- ¿Cuál es la propiedad por la que se ordena por defecto?
- ¿Qué validaciones de negocio se requieren? (unicidad, rangos, etc.)
- ¿Qué relaciones FK se necesitan cargar en combos? (listar entidades relacionadas)
- ¿La entidad tiene campos de auditoría? (UsuarioCreacion, FechaCreacion, etc.)
- ¿Hay lógica adicional al guardar (ej. guardar en tablas puente)?

---

En la Aplicación al Logeo se pide que indiques la empresa en donde estás trabajando, así que hay que cuando aplique agregar el combo y elegir ls empresa seleccionar por defacult la del login

## 🧪 Ejemplo de Uso

Si el usuario responde con los datos de `Empresa` (como se hizo anteriormente), la IA aplicará este SmartDoc y generará el código completo sin necesidad de más intervención.

---

**Fin del SmartDoc**
