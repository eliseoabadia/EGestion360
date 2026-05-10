# Analisis Codigo Base

## Regla principal para paginas nuevas

Para cualquier pagina CRUD nueva, tomar primero como base el flujo completo de `Usuario`:

- Front principal: `FrontEnd/EG.Web/Pages/Configuration/Sistema/Usuario/Usuarios.razor`
- Dialog: `FrontEnd/EG.Web/Pages/Configuration/Sistema/Usuario/UsuarioDialog.razor`
- Controller: `BackEnd/EG.ApiCoreBS/Controllers/General/UsuarioController.cs`
- AppService: `BackEnd/EG.Application/Services/General/UsuarioAppService.cs`
- Interface: `BackEnd/EG.Application/Interfaces/General/IUsuarioAppService.cs`
- Mapper: `BackEnd/EG.Business/Mapping/General/UsuarioMappingProfile.cs`
- DTO: `BackEnd/EG.Domain/DTOs/Requests/General/UsuarioDto.cs`
- Response: `BackEnd/EG.Domain/DTOs/Responses/General/UsuarioResponse.cs`

El placeholder oficial de esta guia es `[Entitie]`. Ejemplo: `Usuario` se convierte en `[Entitie]`, `UsuarioResponse` en `[Entitie]Response`, `UsuarioDialog` en `[Entitie]Dialog`.

## Arquitectura obligatoria

El modelo que viaja al front siempre es `[Entitie]Response`.

- Si existe vista, `[Entitie]Response` debe representar la vista, por ejemplo `Vw[Entitie]`.
- Si no existe vista, `[Entitie]Response` debe representar la entidad.
- El front no debe duplicar modelos en `EG.Web`; debe usar los modelos compartidos desde `EG.Domain`.
- Para crear o actualizar, el controller recibe `[Entitie]Response`, lo mapea a `[Entitie]Dto` y manda el DTO al AppService.
- `EG.Infraestructure/Models` es referencia de solo lectura: no modificar modelos EF generados.

Capas:

- `EG.Web`: paginas Razor, dialogos, tabla generica y combos.
- `EG.ApiCoreBS`: controllers HTTP.
- `EG.Application`: interfaces y AppServices con reglas de aplicacion.
- `EG.Business`: `GenericService` y perfiles de AutoMapper.
- `EG.Domain`: DTOs de request y responses compartidos.
- `EG.Infraestructure`: entidades EF, vistas y resultados de SP.

## Front principal: [Entitie]s.razor

La pagina principal debe heredar de `BaseCrudPage<TResponse, TItem>` usando el mismo tipo para ambos genericos:

```razor
@inherits BaseCrudPage<UsuarioResponse, UsuarioResponse>
@inherits BaseCrudPage<[Entitie]Response, [Entitie]Response>
```

Estructura esperada:

```razor
@page "/[modulo]/[submodulo]/[entities]"
@using EG.Domain.DTOs.Responses.General
@using EG.Dommain.DTOs.Responses
@using EG.Web.Pages.Shared
@using EG.Web.Shared
@inherits BaseCrudPage<[Entitie]Response, [Entitie]Response>

<AccessVerification IsInitialized="@IsInitialized"
                    HasAccess="@HasAccess"
                    NavigateToHome="NavigateToHome">
    <MudContainer Class="px-2 d-flex flex-column" MaxWidth="MaxWidth.False" Style="height: 100vh;">
        <PageHeader Title="Gestion de [Entitie]"
                    Subtitle="Administra y manten el registro"
                    Icon="@Icons.Material.Filled.List"
                    CanCreate="@CanCreate"
                    OnCreate="CreateItem"
                    OnRefresh="() => table?.ReloadData()" />

        <GenericTable TItem="[Entitie]Response"
                      @ref="table"
                      Title="Lista de [Entitie]"
                      SearchPlaceholder="Buscar..."
                      ShowExportButton="@CanExport"
                      ServerDataFunc="LoadServerData"
                      ExportFunc="ExportToExcel"
                      SearchString="@SearchString"
                      SearchStringChanged="(s) => SearchString = s"
                      OnSearch="OnSearch">
            <Header>
                <MudTh>Acciones</MudTh>
                <MudTh>
                    <MudTableSortLabel SortLabel="PkId[Entitie]" T="[Entitie]Response">ID</MudTableSortLabel>
                </MudTh>
                <MudTh>
                    <MudTableSortLabel SortLabel="[CampoPrincipal]" T="[Entitie]Response">[Campo principal]</MudTableSortLabel>
                </MudTh>
            </Header>

            <Row Context="item">
                <MudTd>
                    <MudTooltip Text="Editar">
                        <MudIconButton Icon="@Icons.Material.Filled.Edit"
                                       Visible="@CanUpdate"
                                       Color="Color.Primary"
                                       Size="Size.Small"
                                       OnClick="@(() => EditItem(item.PkId[Entitie]))" />
                    </MudTooltip>
                    <MudTooltip Text="Eliminar">
                        <MudIconButton Icon="@Icons.Material.Filled.Delete"
                                       Visible="@CanDelete"
                                       Color="Color.Error"
                                       Size="Size.Small"
                                       OnClick="@(() => DeleteItem(item.PkId[Entitie]))" />
                    </MudTooltip>
                </MudTd>
                <MudTd>@item.PkId[Entitie]</MudTd>
                <MudTd>@item.[CampoPrincipal]</MudTd>
            </Row>
        </GenericTable>
    </MudContainer>
</AccessVerification>

@code {
    private GenericTable<[Entitie]Response> table = null!;

    protected override string ModuleName => "[Modulo]";
    protected override string SubModuleName => "[SubModulo]";

    protected override Type CreateDialogType => typeof([Entitie]Dialog);
    protected override Type EditDialogType => typeof([Entitie]Dialog);
    protected override Type DeleteDialogType => typeof(DeleteDialog<[Entitie]Response>);

    protected override string GetDefaultSortLabel() => "[CampoPrincipal]";

    protected override IEnumerable<object> MapToExcelData(IEnumerable<[Entitie]Response> items)
    {
        return items.Select(item => new
        {
            ID = item.PkId[Entitie],
            Nombre = item.[CampoPrincipal]
        });
    }

    protected override async Task ReloadData()
    {
        if (table != null)
        {
            await table.ReloadData();
            StateHasChanged();
        }
    }
}
```

Notas obligatorias:

- La tabla siempre debe ser `GenericTable<TItem>`.
- `ServerDataFunc="LoadServerData"` debe quedarse para que la tabla use paginacion real desde backend.
- Los `SortLabel` deben coincidir con propiedades reales de `[Entitie]Response`.
- `CreateDialogType` y `EditDialogType` apuntan a `[Entitie]Dialog`.
- Las acciones extra, como `Asignar Sucursal` en `Usuario`, solo se agregan si la entidad lo requiere.

## Dialog: [Entitie]Dialog.razor

El dialog debe basarse en `UsuarioDialog`, generalizando `UsuarioResponse` a `[Entitie]Response`:

```razor
@using EG.Domain.DTOs.Responses.General
@using EG.Domain.DTOs.Responses.Patrimonio
@using EG.Dommain.DTOs.Responses
@using EG.Common.GenericModel
@using MudBlazor

@* Combo Empresa *@
@inject IGenericCrudService<EmpresaResponse> empresaService
@inject IGenericCrudService<[Entitie]Response> _service
@* Combo Persona *@
@inject IGenericCrudService<PersonaResponse> personaService
@inject ISnackbar Snackbar

<BaseCrudDialog TItem="[Entitie]Response"
                Title="@dialogTitle"
                MaxWidth="MaxWidth.Large"
                ActionText="@actionText"
                ProcessingText="@processingText"
                LoadingMessage="Cargando datos..."
                OnConfirm="GuardarCambiosAsync">

    <BaseEntityForm TEntity="[Entitie]Response"
                    @ref="form"
                    ShowHeader="true"
                    HeaderTitle="@dialogTitle">
        <MudGrid GutterSize="2">
            <!-- Campos del formulario -->
        </MudGrid>
    </BaseEntityForm>
</BaseCrudDialog>

@code {
    [Parameter] public int? Id { get; set; }
    [CascadingParameter] private IMudDialogInstance MudDialog { get; set; } = null!;

    private BaseEntityForm<[Entitie]Response> form = null!;
    private [Entitie]Response item = new();

    private string dialogTitle => Id.HasValue ? "Editar [Entitie]" : "Nuevo [Entitie]";
    private string actionText => Id.HasValue ? "Actualizar" : "Crear";
    private string processingText => Id.HasValue ? "Actualizando..." : "Creando...";

    protected override async Task OnInitializedAsync()
    {
        await Task.WhenAll(CargarCombosAsync());

        if (Id.HasValue)
            await CargarItemAsync();
    }

    private async Task CargarCombosAsync()
    {
        // Cargar aqui solo combos pequenos.
        // Los catalogos grandes deben usar PagedAutocomplete con LoadPage.
        await Task.CompletedTask;
    }

    private async Task CargarItemAsync()
    {
        var response = await _service.GetByIdAsync(Id!.Value);
        if (response?.Success == true && response.Data != null)
            item = response.Data;
        else
            Snackbar.Add(response?.Message ?? "Error al cargar", Severity.Warning);
    }

    private async Task GuardarCambiosAsync(bool _)
    {
        if (!await form.ValidateAsync())
        {
            Snackbar.Add("Por favor, completa los campos requeridos.", Severity.Warning);
            return;
        }

        ApiResponse<[Entitie]Response> response = Id.HasValue
            ? await _service.UpdateAsync(item, item.PkId[Entitie])
            : await _service.CreateAsync(item);

        if (response?.Success == true)
        {
            Snackbar.Add(response.Message ?? "Operacion realizada correctamente", Severity.Success);
            MudDialog.Close(DialogResult.Ok(true));
        }
        else
        {
            Snackbar.Add(response?.Message ?? "Error en la operacion", Severity.Error);
        }
    }
}
```

## Combos optimizados

Los combos se dividen en dos tipos.

Para catalogos pequenos o casi estaticos, cargar una sola vez:

```csharp
private IList<EmpresaResponse> listadoEmpresas = new List<EmpresaResponse>();

private async Task CargarEmpresasAsync()
{
    var response = await empresaService.GetAllAsync();
    if (response?.Success == true && response.Items != null)
        listadoEmpresas = response.Items.ToList();
}
```

Para catalogos grandes, relaciones con muchas filas o busquedas frecuentes, usar `PagedAutocomplete`. Este es el patron super optimizado y debe preferirse para entidades como `Persona`, `Proyecto`, `Programa`, `Partida`, etc.

```razor
<PagedAutocomplete Value="@_selectedPersona"
                   ValueChanged="OnPersonaChanged"
                   Label="Persona"
                   Clearable="true"
                   Required="true"
                   RequiredError="Debe seleccionar una persona"
                   LoadPage="LoadPersonasPageAsync" />
```

```csharp
private LookupItem? _selectedPersona;

private void OnPersonaChanged(LookupItem? lookup)
{
    _selectedPersona = lookup;
    item.IdPersona = lookup?.Id;
}

private async Task<ComboLookupResult> LoadPersonasPageAsync(
    int page,
    int pageSize,
    string filter,
    CancellationToken ct)
{
    var response = await personaService.GetAllPaginadoAsync(
        page,
        pageSize,
        filter,
        "Nombre",
        SortDirection.Ascending);

    return new ComboLookupResult
    {
        Items = response?.Items?.Select(persona => new LookupItem
        {
            Id = persona.PkidPersona,
            Text = $"{persona.Nombre} {persona.Paterno} {persona.Materno}".Trim()
        }) ?? Enumerable.Empty<LookupItem>(),
        TotalCount = response?.TotalCount ?? 0
    };
}
```

Al editar, reconstruir el valor seleccionado desde el response:

```csharp
if (item.IdPersona.HasValue)
{
    _selectedPersona = new LookupItem
    {
        Id = item.IdPersona.Value,
        Text = item.NombreCompletoPersona
    };
}
```

Reglas para combos:

- No cargar catalogos grandes con `GetAllAsync`.
- Usar `Task.WhenAll(...)` para combos independientes.
- Guardar solo el ID FK en el response antes de crear o actualizar.
- Para edicion, preseleccionar el `LookupItem` usando campos que ya vienen en `[Entitie]Response`.
- El backend debe soportar `GetAllPaginado` para que el combo busque por servidor.

## Registro del servicio CRUD en front

En `FrontEnd/EG.Web/Extensions/ServiceRegistrationExtensions.cs`, clase `ApiServiceExtensions`, agregar el registro:

```csharp
public static class ApiServiceExtensions
{
    public static IServiceCollection AddApiServices(this IServiceCollection services)
    {
        RegisterCrud<[Entitie]Response>(services, "api/[Entitie]");
        return services;
    }
}
```

Este registro permite inyectar:

```razor
@inject IGenericCrudService<[Entitie]Response> _service
```

## Controller backend

Usar como base `UsuarioController`.

Ruta esperada:

```text
BackEnd/EG.ApiCoreBS/Controllers/[Modulo]/[Entitie]Controller.cs
```

Estructura:

```csharp
using AutoMapper;
using EG.ApiCoreBS.Services;
using EG.Application.Interfaces.General;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Dommain.DTOs.Responses;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.General
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class [Entitie]Controller : ControllerBase
    {
        private readonly I[Entitie]AppService _appService;
        private readonly IUserContextService _userContext;
        private readonly IMapper _mapper;

        public [Entitie]Controller(
            I[Entitie]AppService appService,
            IUserContextService userContext,
            IMapper mapper)
        {
            _appService = appService;
            _userContext = userContext;
            _mapper = mapper;
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<[Entitie]Response>>> GetById(int id)
        {
            var item = await _appService.GetByIdAsync(id);

            if (item == null)
            {
                return NotFound(new PagedResult<[Entitie]Response>
                {
                    Success = false,
                    Message = "[Entitie] no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }

            return Ok(new PagedResult<[Entitie]Response>
            {
                Success = true,
                Message = "[Entitie] encontrado",
                Code = "SUCCESS",
                Data = item,
                Items = new List<[Entitie]Response> { item },
                TotalCount = 1
            });
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<[Entitie]Response>>> GetAllPaginado([FromBody] PagedRequest pageRequest)
        {
            var result = await _appService.GetAllPaginadoAsync(pageRequest);

            return Ok(new PagedResult<[Entitie]Response>
            {
                Success = true,
                Message = "[Entitie] obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<[Entitie]Response>>> Create([FromBody] [Entitie]Response request)
        {
            var dto = _mapper.Map<[Entitie]Dto>(request);
            var userCreacion = _userContext.GetCurrentUserId();

            dto.UsuarioCreacion = userCreacion;
            dto.FechaCreacion = DateTime.Now;

            var result = await _appService.CreateAsync(dto, userCreacion);

            return CreatedAtAction(nameof(GetById), new { id = result.PkId[Entitie] },
                new PagedResult<[Entitie]Response>
                {
                    Success = true,
                    Message = "[Entitie] creado correctamente",
                    Code = "SUCCESS",
                    Data = result,
                    Items = new List<[Entitie]Response> { result },
                    TotalCount = 1
                });
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<[Entitie]Response>>> Update(int id, [FromBody] [Entitie]Response request)
        {
            var dto = _mapper.Map<[Entitie]Dto>(request);
            var userModificacion = _userContext.GetCurrentUserId();

            dto.PkId[Entitie] = id;
            dto.UsuarioModificacion = userModificacion;
            dto.FechaModificacion = DateTime.Now;

            var result = await _appService.UpdateAsync(id, dto, userModificacion);

            return Ok(new PagedResult<[Entitie]Response>
            {
                Success = true,
                Message = "[Entitie] actualizado correctamente",
                Code = "SUCCESS",
                Data = result,
                Items = new List<[Entitie]Response> { result },
                TotalCount = 1
            });
        }
    }
}
```

Metodos obligatorios del controller:

- `GetAll`
- `GetById`
- `GetAllPaginado`
- `Create`
- `Update`
- `Delete`
- Endpoints extra solo si la entidad lo necesita, por ejemplo `GetByEmpresaId`.

Reglas del controller:

- `GetAllPaginado` debe existir exactamente como endpoint `HttpPost("GetAllPaginado")`.
- `Create` y `Update` reciben `[Entitie]Response`, no `[Entitie]Dto`.
- El controller mapea `Response -> Dto`.
- El usuario actual siempre sale de `_userContext.GetCurrentUserId()`.
- Fechas y usuarios de auditoria se asignan antes de llamar al AppService.

## EG.Application

Crear la interfaz:

```text
BackEnd/EG.Application/Interfaces/General/I[Entitie]AppService.cs
```

```csharp
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Dommain.DTOs.Responses;

namespace EG.Application.Interfaces.General
{
    public interface I[Entitie]AppService
    {
        Task<PagedResult<[Entitie]Response>> GetAllAsync();
        Task<[Entitie]Response> GetByIdAsync(int id);
        Task<PagedResult<[Entitie]Response>> GetAllPaginadoAsync(PagedRequest pageRequest);
        Task<[Entitie]Response> CreateAsync([Entitie]Dto dto, int usuarioActual);
        Task<[Entitie]Response> UpdateAsync(int id, [Entitie]Dto dto, int usuarioActual);
        Task<bool> DeleteAsync(int id, int usuarioActual);
    }
}
```

Crear el AppService:

```text
BackEnd/EG.Application/Services/General/[Entitie]AppService.cs
```

```csharp
using AutoMapper;
using EG.Application.Interfaces.General;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Dommain.DTOs.Responses;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;

namespace EG.Application.Services.General
{
    public class [Entitie]AppService : I[Entitie]AppService
    {
        private readonly GenericService<[Entitie], [Entitie]Dto, [Entitie]Response> _service;
        private readonly GenericService<Vw[Entitie], [Entitie]Dto, [Entitie]Response> _serviceView;
        private readonly IRepositorySP<sp[Entitie]Result> _repositorySP;
        private readonly IMapper _mapper;

        public [Entitie]AppService(
            GenericService<[Entitie], [Entitie]Dto, [Entitie]Response> service,
            GenericService<Vw[Entitie], [Entitie]Dto, [Entitie]Response> serviceView,
            IRepositorySP<sp[Entitie]Result> repositorySP,
            IMapper mapper)
        {
            _service = service;
            _serviceView = serviceView;
            _repositorySP = repositorySP;
            _mapper = mapper;
            ConfigureService();
            ConfigureValidations();
        }
    }
}
```

Si no existe vista, eliminar `_serviceView` y leer desde `_service`.

Si no existe stored procedure, eliminar `_repositorySP`.

Reglas del AppService:

- Lecturas (`GetAll`, `GetById`, `GetAllPaginado`) usan `_serviceView` cuando existe vista.
- Escrituras (`Create`, `Update`, `Delete`) usan `_service` contra la entidad real.
- `GetByIdAsync` debe indicar el nombre real de la PK cuando sea necesario:

```csharp
var item = await _serviceView.GetByIdAsync(id, idPropertyName: "PkId[Entitie]");
```

- Antes de paginar se puede limpiar y reconstruir configuracion si el servicio acumula filtros:

```csharp
_serviceView.ClearConfiguration();
ConfigureService();
var result = await _serviceView.GetAllPaginadoAsync(pageRequest);
```

- `ConfigureService()` debe concentrar includes y filtros de busqueda:

```csharp
private void ConfigureService()
{
    _service.AddInclude(x => x.FkidEmpresaNavigation);

    _service.AddRelationFilter("Empresa", new List<string> { "Nombre", "Rfc" });

    _serviceView.AddRelationFilter("[Entitie]", new List<string>
    {
        "[CampoPrincipal]",
        "[OtroCampoBusqueda]"
    });
}
```

- `ConfigureValidations()` debe concentrar unicidad, obligatorios y reglas de negocio:

```csharp
private void ConfigureValidations()
{
    _service.AddValidationRule("UniqueName", async dto =>
    {
        var itemDto = dto as [Entitie]Dto;
        if (itemDto == null)
            return false;

        return !await _service.GetQueryWithIncludes()
            .AnyAsync(x => x.[CampoPrincipal] == itemDto.[CampoPrincipal] && x.Activo);
    });

    _service.AddValidationRuleWithId("UniqueNameUpdate", async (dto, id) =>
    {
        var itemDto = dto as [Entitie]Dto;
        if (itemDto == null || !id.HasValue)
            return false;

        return !await _service.GetQueryWithIncludes()
            .AnyAsync(x => x.[CampoPrincipal] == itemDto.[CampoPrincipal]
                        && x.PkId[Entitie] != id.Value
                        && x.Activo);
    });
}
```

## Registro de AppService en backend

En `BackEnd/EG.ApiCoreBS/Extensions/ServiceCollectionExtensions.cs` agregar:

```csharp
services.AddScoped<I[Entitie]AppService, [Entitie]AppService>();
```

Si hay SP:

```csharp
services.AddScoped<IRepositorySP<sp[Entitie]Result>, RepositorySP<sp[Entitie]Result>>();
```

`GenericService<,,>` ya se registra de forma generica, pero confirmar que exista:

```csharp
services.AddScoped(typeof(GenericService<,,>));
```

## EG.Business mapping

Crear o actualizar:

```text
BackEnd/EG.Business/Mapping/[Modulo]/[Entitie]MappingProfile.cs
```

Patron:

```csharp
using AutoMapper;
using EG.Domain.DTOs.Requests.General;
using EG.Dommain.DTOs.Responses;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.General
{
    public class [Entitie]MappingProfile : Profile
    {
        public [Entitie]MappingProfile()
        {
            CreateMap<[Entitie], [Entitie]Response>();

            CreateMap<Vw[Entitie], [Entitie]Response>();

            CreateMap<[Entitie]Response, [Entitie]Dto>()
                .ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));

            CreateMap<[Entitie]Dto, [Entitie]>()
                .ForMember(dest => dest.FechaCreacion, opt => opt.Ignore())
                .ForMember(dest => dest.UsuarioCreacion, opt => opt.Ignore())
                .ForMember(dest => dest.FechaModificacion, opt => opt.Ignore())
                .ForMember(dest => dest.UsuarioModificacion, opt => opt.Ignore())
                .ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}
```

Reglas de mapping:

- Si `[Entitie]Response` viene de una vista, mapear `Vw[Entitie] -> [Entitie]Response`.
- Si no hay vista, mapear `[Entitie] -> [Entitie]Response`.
- Mapear `[Entitie]Response -> [Entitie]Dto` porque el controller recibe Response desde el front.
- Resolver diferencias de nombres de FK, por ejemplo `IdEmpresa` en response hacia `FkidEmpresaSis` en DTO.
- Ignorar navegaciones y campos de auditoria en `Dto -> Entidad` si se asignan desde controller/AppService.

## EG.Domain DTO y Response

DTO de escritura:

```text
BackEnd/EG.Domain/DTOs/Requests/[Modulo]/[Entitie]Dto.cs
```

```csharp
namespace EG.Domain.DTOs.Requests.General;

public class [Entitie]Dto
{
    public int PkId[Entitie] { get; set; }

    // Campos copiados desde EG.Infraestructure/Models/[Entitie].cs
    // Solo propiedades simples, sin virtual, sin navegaciones.

    public bool Activo { get; set; }
    public DateTime? FechaCreacion { get; set; }
    public int UsuarioCreacion { get; set; }
    public DateTime? FechaModificacion { get; set; }
    public int? UsuarioModificacion { get; set; }
}
```

Response que viaja al front:

```text
BackEnd/EG.Domain/DTOs/Responses/[Modulo]/[Entitie]Response.cs
```

```csharp
namespace EG.Dommain.DTOs.Responses;

public partial class [Entitie]Response
{
    public int PkId[Entitie] { get; set; }

    // Si existe vista, copiar campos de Vw[Entitie].
    // Si no existe vista, copiar campos de [Entitie].
    // Incluir campos que se muestran en tabla, dialogo y combos.

    public DateTime? FechaCreacion { get; set; }
    public int UsuarioCreacion { get; set; }
    public DateTime? FechaModificacion { get; set; }
    public int? UsuarioModificacion { get; set; }
}
```

Reglas:

- El DTO debe copiar la entidad EF real, solo propiedades simples.
- El DTO debe incluir campos de control/auditoria si la tabla los tiene.
- El Response debe copiar la vista si existe.
- El Response debe tener todo lo que necesita el front: tabla, dialogo, exportacion, texto de combos y valores seleccionados.
- No incluir propiedades `virtual` ni navegaciones.
- Respetar namespaces existentes del modulo. El proyecto tiene namespaces legacy como `EG.Dommain.DTOs.Responses`; usarlos solo donde el modulo ya los usa.

## Flujo completo de guardado

1. El usuario captura en `[Entitie]Dialog`.
2. El dialog llama a `IGenericCrudService<[Entitie]Response>.CreateAsync(item)` o `UpdateAsync(item, id)`.
3. El front llega a `api/[Entitie]`.
4. El controller recibe `[Entitie]Response`.
5. El controller mapea:

```csharp
var dto = _mapper.Map<[Entitie]Dto>(request);
```

6. El controller asigna auditoria:

```csharp
var userCreacion = _userContext.GetCurrentUserId();
dto.UsuarioCreacion = userCreacion;
dto.FechaCreacion = DateTime.Now;
```

7. El controller manda al AppService:

```csharp
var result = await _appService.CreateAsync(dto, userCreacion);
```

8. El AppService valida y guarda con `_service`.
9. El AppService devuelve `[Entitie]Response`, preferentemente leido desde `_serviceView`.
10. El controller regresa `PagedResult<[Entitie]Response>`.

## Checklist para generar una pagina nueva

1. Identificar entidad EF: `[Entitie]`.
2. Confirmar si existe vista `Vw[Entitie]`.
3. Confirmar PK real, por ejemplo `PkId[Entitie]`.
4. Crear `[Entitie]Dto` en `EG.Domain/DTOs/Requests`.
5. Crear `[Entitie]Response` en `EG.Domain/DTOs/Responses`.
6. Crear mapper `[Entitie]MappingProfile`.
7. Crear `I[Entitie]AppService`.
8. Crear `[Entitie]AppService`.
9. Registrar AppService en backend.
10. Crear `[Entitie]Controller`.
11. Registrar `RegisterCrud<[Entitie]Response>(services, "api/[Entitie]")` en front.
12. Crear `[Entitie]s.razor` con `BaseCrudPage<[Entitie]Response, [Entitie]Response>`.
13. Crear `[Entitie]Dialog.razor` con `BaseCrudDialog TItem="[Entitie]Response"`.
14. Usar `GenericTable` para la tabla.
15. Usar `PagedAutocomplete` para combos grandes.
16. Verificar build.

## Preguntas minimas si falta informacion

- Nombre exacto de la entidad EF.
- Nombre exacto de la vista, si aplica.
- Modulo, submodulo y ruta de la pagina.
- PK real y campo de orden default.
- Campos que deben mostrarse en tabla.
- Campos que deben ir en dialogo.
- FKs que requieren combos.
- Cuales combos son pequenos y cuales deben usar `PagedAutocomplete`.
- Validaciones de negocio.
- Si hay soft delete con `Activo`.
- Si hay stored procedure relacionado.

## Verificacion final obligatoria

Antes de entregar una pagina nueva:

- Ejecutar build del backend y front cuando aplique.
- Confirmar que los `using` correspondan al namespace real.
- Confirmar que `GetAllPaginado` existe en el controller.
- Confirmar que `RegisterCrud<[Entitie]Response>(services, "api/[Entitie]")` existe en front.
- Confirmar que los `SortLabel` existen en `[Entitie]Response`.
- Confirmar que los combos grandes no usan `GetAllAsync`.
- Confirmar que `Create` y `Update` reciben `[Entitie]Response`.
- Confirmar que el mapper cubre `Response -> Dto` y vista/entidad -> Response.
- Confirmar que auditoria se asigna con `_userContext.GetCurrentUserId()`.
