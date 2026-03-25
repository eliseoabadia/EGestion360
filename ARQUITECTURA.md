# EGestion360 - Documentación de Arquitectura

## Tabla de Contenidos
- [Visión General](#visión-general)
- [Backend](#backend)
  - [Controllers](#controllers)
  - [GenericService](#genericservice)
  - [Mapping Profiles](#mapping-profiles)
- [Frontend](#frontend)
  - [GenericTable](#generictable)
  - [Págs.razor](#págsrazor)
  - [Dialogs](#dialogs)
- [Flujo de Datos](#flujo-de-datos)
- [Convenciones](#convenciones)

---

## Visión General

```
┌─────────────────────────────────────────────────────────────────┐
│                         FRONTEND (Blazor)                        │
├─────────────────────────────────────────────────────────────────┤
│  Pages (.razor)      │  Dialogs (.razor)     │  Components      │
│  ├── Usuarios.razor │  ├── UsuarioDialog     │  ├── GenericTable│
│  ├── Familia.razor  │  ├── FamiliaDialog     │  ├── BaseCrud...│
│  ├── TipoBien.razor │  ├── TipoBienDialog    │  └── ...        │
│  └── Bien.razor    │  └── BienDialog        │                  │
├─────────────────────────────────────────────────────────────────┤
│  Services                    │  Contracts (Interfaces)          │
│  ├── GenericCrudService     │  ├── IGenericCrudService         │
│  ├── UsuarioService         │  ├── IUsuarioService             │
│  └── ...                    │  └── ...                         │
├─────────────────────────────────────────────────────────────────┤
│  Models                      │  Responses                       │
│  ├── UsuarioRequest         │  ├── UsuarioResponse             │
│  └── ...                    │  └── ...                         │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼ HTTP/REST
┌─────────────────────────────────────────────────────────────────┐
│                         BACKEND (.NET API)                       │
├─────────────────────────────────────────────────────────────────┤
│  Controllers                                                  │
│  ├── General/UsuarioController.cs                              │
│  ├── Almacen/FamiliaController.cs                             │
│  ├── Almacen/TipoBienController.cs                            │
│  └── ...                                                      │
├─────────────────────────────────────────────────────────────────┤
│  GenericService<T, TDto, TResponse>                            │
│  └── Métodos genéricos: GetAll, GetById, Add, Update, Delete │
├─────────────────────────────────────────────────────────────────┤
│  Application Services (AppServices)                           │
│  ├── UsuarioAppService                                         │
│  └── ...                                                      │
├─────────────────────────────────────────────────────────────────┤
│  Mapping Profiles (AutoMapper)                                 │
│  ├── General/UsuarioMappingProfile.cs                          │
│  ├── Almacen/AlmacenMappingProfile.cs                         │
│  └── ...                                                      │
├─────────────────────────────────────────────────────────────────┤
│  Domain                                                       │
│  ├── DTOs/Requests/{Module}/{Entity}Dto.cs                   │
│  └── DTOs/Responses/{Module}/{Entity}Response.cs            │
├─────────────────────────────────────────────────────────────────┤
│  Infrastructure                                                │
│  ├── Models/{Entity}.cs (EF Core Entities)                   │
│  └── Views/{VwEntity}.cs                                      │
└─────────────────────────────────────────────────────────────────┘
```

---

## Backend

### Controllers

Los controllers exponen endpoints REST y delegan la lógica de negocio al `GenericService`.

#### Estructura Base

```csharp
[ApiController]
[Route("api/[controller]")]
[Authorize]
public class EntityController : ControllerBase
{
    private readonly GenericService<Entity, EntityDto, EntityResponse> _service;
    private readonly GenericService<VwEntity, EntityDto, EntityResponse> _serviceView;
    private readonly IMapper _mapper;
    private readonly IUserContextService _userContext;

    public EntityController(
        GenericService<Entity, EntityDto, EntityResponse> service,
        GenericService<VwEntity, EntityDto, EntityResponse> serviceView,
        IMapper mapper,
        IUserContextService userContext)
    {
        _service = service;
        _serviceView = serviceView;
        _mapper = mapper;
        _userContext = userContext;
    }
}
```

#### Métodos HTTP

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/api/{entity}` | Obtener todos |
| GET | `/api/{entity}/{id}` | Obtener por ID |
| POST | `/api/{entity}/GetAllPaginado` | Lista paginada |
| POST | `/api/{entity}` | Crear nuevo |
| PUT | `/api/{entity}/{id}` | Actualizar existente |
| DELETE | `/api/{entity}/{id}` | Eliminar |

#### Ejemplo: Create

```csharp
[HttpPost]
public async Task<ActionResult<PagedResult<EntityResponse>>> Create(
    [FromBody] EntityResponse response)
{
    try
    {
        var dto = _mapper.Map<EntityDto>(response);
        dto.UsuarioCreacion = _userContext.GetCurrentUserId();
        dto.FechaCreacion = DateTime.Now;

        await _service.AddAsync(dto);

        return CreatedAtAction(nameof(GetById), new { id = dto.Id },
            new PagedResult<EntityResponse>
            {
                Success = true,
                Message = "Registro creado correctamente",
                Code = "SUCCESS",
                TotalCount = 1
            });
    }
    catch (Exception ex)
    {
        return BadRequest(new PagedResult<EntityResponse>
        {
            Success = false,
            Message = $"Error al crear: {ex.Message}",
            Code = "ERROR",
            TotalCount = 0
        });
    }
}
```

#### Ejemplo: Update

```csharp
[HttpPut("{id}")]
public async Task<ActionResult<PagedResult<EntityResponse>>> Update(
    int id, [FromBody] EntityResponse response)
{
    try
    {
        var dto = _mapper.Map<EntityDto>(response);
        dto.Id = id;
        dto.UsuarioModificacion = _userContext.GetCurrentUserId();
        dto.FechaModificacion = DateTime.Now;

        await _service.UpdateAsync(id, dto);

        return Ok(new PagedResult<EntityResponse>
        {
            Success = true,
            Message = "Registro actualizado correctamente",
            Code = "SUCCESS",
            TotalCount = 1
        });
    }
    catch (KeyNotFoundException)
    {
        return NotFound(new PagedResult<EntityResponse>
        {
            Success = false,
            Message = $"Registro con ID {id} no encontrado",
            Code = "NOTFOUND",
            TotalCount = 0
        });
    }
    catch (Exception ex)
    {
        return BadRequest(new PagedResult<EntityResponse>
        {
            Success = false,
            Message = $"Error al actualizar: {ex.Message}",
            Code = "ERROR",
            TotalCount = 0
        });
    }
}
```

---

### GenericService

El `GenericService` proporciona operaciones CRUD genéricas para cualquier entidad.

#### Definición

```csharp
public class GenericService<TEntity, TDto, TResponse>
    where TEntity : class
    where TDto : class
    where TResponse : class
{
    private readonly IRepository<TEntity> _repository;
    private readonly IMapper _mapper;
    
    // Métodos disponibles:
    // - GetAllAsync()
    // - GetByIdAsync(int id, string idPropertyName = "Id")
    // - GetAllPaginadoAsync(PagedRequest request)
    // - AddAsync(TDto dto)
    // - UpdateAsync(int id, TDto dto)
    // - DeleteAsync(int id)
    // - CanAddAsync(TDto dto)
    // - CanUpdateAsync(int id, TDto dto)
}
```

#### Configuración de Includes

```csharp
private void ConfigureService()
{
    _service.AddInclude(e => e.NavigationProperty);
    _service.AddRelationFilter("RelationName", new List<string> { "Field1", "Field2" });
}
```

#### Campos de Auditoría

Todas las entidades con campos de auditoría deben incluir:

```csharp
public DateTime? FechaCreacion { get; set; }
public int UsuarioCreacion { get; set; }
public DateTime? FechaModificacion { get; set; }
public int? UsuarioModificacion { get; set; }
```

---

### Mapping Profiles

Los perfiles de mapeo definen las conversiones entre entidades, DTOs y Responses.

#### Estructura

```csharp
public class EntityMappingProfile : Profile
{
    public EntityMappingProfile()
    {
        // Entity -> Response
        CreateMap<Entity, EntityResponse>()
            .ForMember(dest => dest.Property, opt => opt.MapFrom(src => src.SourceProperty));

        // Dto -> Entity
        CreateMap<EntityDto, Entity>()
            .ForMember(dest => dest.Navigation, opt => opt.Ignore());

        // Response -> Dto (para Updates)
        CreateMap<EntityResponse, EntityDto>()
            .ForMember(dest => dest.Property, opt => opt.MapFrom(src => src.SourceProperty));
    }
}
```

#### Ejemplo: AlmacenMappingProfile

```csharp
public class AlmacenMappingProfile : Profile
{
    public AlmacenMappingProfile()
    {
        // Familia mappings
        CreateMap<Familium, FamiliaResponse>()
            .ForMember(dest => dest.PkidFamilia, 
                opt => opt.MapFrom(src => src.PkidFamilia)).ReverseMap();

        CreateMap<FamiliaDto, FamiliaResponse>()
            .ForMember(dest => dest.PkidFamilia, 
                opt => opt.MapFrom(src => src.PkidFamilia)).ReverseMap();

        // TipoBien mappings
        CreateMap<TipoBien, TipoBienDto>().ReverseMap();
        CreateMap<VwTipoBienConteo, TipoBienResponse>();

        // Bien mappings
        CreateMap<Bien, BienDto>().ReverseMap();
        CreateMap<VwBien, BienResponse>();
    }
}
```

---

## Frontend

### GenericTable

`GenericTable` es un componente reutilizable que muestra datos en una tabla con paginación, ordenamiento y búsqueda.

#### Uso Básico

```razor
<GenericTable TItem="EntityResponse"
              @ref="table"
              Title="Lista de Entidades"
              SearchPlaceholder="Buscar por nombre..."
              ShowExportButton="@CanExport"
              ServerDataFunc="LoadServerData"
              ExportFunc="ExportToExcel"
              SearchString="@SearchString"
              SearchStringChanged="(s) => SearchString = s"
              OnSearch="OnSearch">

    <Header>
        <MudTh>Acciones</MudTh>
        <MudTh><MudTableSortLabel SortLabel="Id" T="EntityResponse">ID</MudTableSortLabel></MudTh>
        <MudTh><MudTableSortLabel SortLabel="Nombre" T="EntityResponse">Nombre</MudTh>
    </Header>

    <Row Context="entity">
        <MudTd>
            <MudIconButton Icon="@Icons.Material.Filled.Edit" 
                           OnClick="@(() => EditItem(entity.Id ?? 0))" />
        </MudTd>
        <MudTd>@entity.Id</MudTd>
        <MudTd>@entity.Nombre</MudTd>
    </Row>
</GenericTable>
```

#### Props

| Prop | Tipo | Descripción |
|------|------|-------------|
| `TItem` | `T` | Tipo del modelo de datos |
| `Title` | `string` | Título de la tabla |
| `SearchPlaceholder` | `string` | Placeholder del buscador |
| `ShowExportButton` | `bool` | Mostrar botón de exportar |
| `ServerDataFunc` | `Func` | Función para cargar datos del servidor |
| `isLoading` | `bool` | Estado de carga (deshabilita paginación) |

---

### Págs.razor

Las páginas heredan de `BaseCrudPage<TModel, TResponse>` y definen el comportamiento CRUD.

#### Estructura Base

```razor
@page "/modulo/entidad"
@inherits BaseCrudPage<EntityResponse, EntityResponse>

<MudContainer>
    <PageHeader Title="Gestión de Entidades"
                CanCreate="@CanCreate"
                OnCreate="CreateItem" />

    <GenericTable TItem="EntityResponse"
                  @ref="table"
                  ServerDataFunc="LoadServerData"
                  ...>
        <!-- Headers y Rows -->
    </GenericTable>
</MudContainer>

@code {
    private GenericTable<EntityResponse> table = null!;

    protected override string ModuleName => "modulo";
    protected override string SubModuleName => "entidad";

    protected override Type CreateDialogType => typeof(EntityDialog);
    protected override Type EditDialogType => typeof(EntityDialog);
    protected override Type DeleteDialogType => typeof(DeleteDialog<EntityResponse>);

    protected override string GetDefaultSortLabel() => "Nombre";
}
```

#### Métodos Principales

| Método | Descripción |
|--------|-------------|
| `CreateItem()` | Abre diálogo para crear |
| `EditItem(int id)` | Abre diálogo para editar |
| `DeleteItem(int id)` | Abre diálogo para eliminar |
| `LoadServerData()` | Carga datos del servidor |
| `OnSearch(string search)` | Ejecuta búsqueda |
| `ReloadData()` | Recarga la tabla |

---

### Dialogs

Los diálogos heredan de `BaseCrudDialog<TItem>` y manejan la creación/edición.

#### Estructura Base

```razor
<BaseCrudDialog TItem="EntityResponse"
                Title="@dialogTitle"
                MaxWidth="MaxWidth.Small"
                ActionText="@actionText"
                ProcessingText="@processingText"
                LoadingMessage="Cargando..."
                OnConfirm="GuardarCambiosAsync">

    <BaseEntityForm TEntity="EntityResponse"
                    @ref="form"
                    ShowHeader="true"
                    HeaderTitle="@dialogTitle">

        <MudGrid>
            <MudItem xs="12">
                <MudTextField @bind-Value="entity.Nombre"
                              Label="Nombre"
                              Required="true" />
            </MudItem>
        </MudGrid>
    </BaseEntityForm>
</BaseCrudDialog>

@code {
    [Parameter] public int? Id { get; set; }
    [CascadingParameter] private IMudDialogInstance MudDialog { get; set; }

    private BaseEntityForm<EntityResponse> form = null!;
    private EntityResponse entity = new();

    private string dialogTitle => Id.HasValue ? "Editar" : "Nuevo";
    private string actionText => Id.HasValue ? "Actualizar" : "Crear";

    protected override async Task OnInitializedAsync()
    {
        if (Id.HasValue)
            await CargarEntity();
    }

    private async Task GuardarCambiosAsync(bool _)
    {
        if (!await form.ValidateAsync())
            return;

        ApiResponse<EntityResponse> response;
        if (Id.HasValue)
            response = await _service.UpdateAsync(entity, entity.Id ?? 0);
        else
            response = await _service.CreateAsync(entity);

        if (response?.Success == true)
            MudDialog.Close(DialogResult.Ok(true));
    }
}
```

---

## Flujo de Datos

### Create/Update

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│   Dialog    │────▶│ GenericCrud  │────▶│ Controller  │
│  (Razor)    │     │  Service     │     │   (API)     │
└─────────────┘     └──────────────┘     └─────────────┘
       │                                         │
       │ Request (EntityRequest)                 │
       │                                         ▼
       │                                   ┌─────────────┐
       │                                   │  Mapper     │
       │                                   │ (Response→  │
       │                                   │   Dto)      │
       │                                         │
       │                                         ▼
       │                                   ┌─────────────┐
       │                                   │GenericService│
       │                                   └─────────────┘
       │                                         │
       │                                         ▼
       │                                   ┌─────────────┐
       │                                   │  Repository │
       │                                   └─────────────┘
```

### Lectura

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│   Page      │◀────│ GenericCrud  │◀────│ Controller  │
│  (Razor)    │     │  Service     │     │   (API)     │
└─────────────┘     └──────────────┘     └─────────────┘
                                              │
                                              ▼
                                        ┌─────────────┐
                                        │GenericService│
                                        │  (Views)    │
                                        └─────────────┘
                                              │
                                              ▼
                                        ┌─────────────┐
                                        │  Mapper     │
                                        │ (Entity→    │
                                        │  Response)  │
                                        └─────────────┘
```

---

## Convenciones

### Backend

| Elemento | Convención | Ejemplo |
|----------|------------|---------|
| Controller | `{Entity}Controller.cs` | `UsuarioController.cs` |
| DTO | `{Entity}Dto.cs` | `UsuarioDto.cs` |
| Response | `{Entity}Response.cs` | `UsuarioResponse.cs` |
| Entity | `{Entity}.cs` | `Usuario.cs` |
| View | `Vw{Entity}.cs` | `VwUsuarioEmpresa.cs` |
| Mapping Profile | `{Module}MappingProfile.cs` | `AlmacenMappingProfile.cs` |
| Primary Key | `Pkid{Entity}` | `PkidUsuario` |

### Frontend

| Elemento | Convención | Ejemplo |
|----------|------------|---------|
| Page | `{Entity}.razor` | `Usuarios.razor` |
| Dialog | `{Entity}Dialog.razor` | `UsuarioDialog.razor` |
| Request Model | `{Entity}Request.cs` | `UsuarioRequest.cs` |
| Response Model | `{Entity}Response.cs` | `UsuarioResponse.cs` |
| Service | `{Entity}Service.cs` | `UsuarioService.cs` |
| Interface | `I{Entity}Service.cs` | `IUsuarioService.cs` |

### Tipos Nullable

- IDs deben ser `int?` con valor default `0` al enviarse
- Strings deben ser `string.Empty` al inicializarse
- Booleanos deben usar `== true` / `== false` para comparaciones

```razor
@* Incorrecto *@
OnClick="@(() => EditItem(entity.Id))"
@(entity.Activo ? "Activo" : "Inactivo")

@* Correcto *@
OnClick="@(() => EditItem(entity.Id ?? 0))"
@(entity.Activo == true ? "Activo" : "Inactivo")
```

---

## Ejemplo Completo: Familia

### Backend

**Entity:** `EG.Infraestructure/Models/Familium.cs`
```csharp
public partial class Familium
{
    public int PkidFamilia { get; set; }
    public string Clave { get; set; }
    public string Descripcion { get; set; }
    public bool Activo { get; set; }
    public DateTime? FechaCreacion { get; set; }
    public int UsuarioCreacion { get; set; }
    public DateTime? FechaModificacion { get; set; }
    public int? UsuarioModificacion { get; set; }
}
```

**Dto:** `EG.Domain/DTOs/Requests/Almacen/FamiliaDto.cs`
```csharp
public class FamiliaDto
{
    public int PkidFamilia { get; set; }
    public string Clave { get; set; }
    public string Descripcion { get; set; }
    public bool Activo { get; set; }
    public DateTime? FechaCreacion { get; set; }
    public int UsuarioCreacion { get; set; }
    public DateTime? FechaModificacion { get; set; }
    public int? UsuarioModificacion { get; set; }
}
```

**Response:** `EG.Domain/DTOs/Responses/Almacen/FamiliaResponse.cs`
```csharp
public class FamiliaResponse
{
    public int? PkidFamilia { get; set; }
    public string Clave { get; set; }
    public string Descripcion { get; set; }
    public bool? Activo { get; set; }
}
```

**Controller:** `EG.ApiCore/Controllers/Almacen/FamiliaController.cs`
```csharp
[ApiController]
[Route("api/[controller]")]
public class FamiliaController : ControllerBase
{
    private readonly GenericService<Familium, FamiliaDto, FamiliaResponse> _service;
    private readonly IMapper _mapper;
    private readonly IUserContextService _userContext;

    [HttpPost]
    public async Task<ActionResult<PagedResult<FamiliaResponse>>> Create(
        [FromBody] FamiliaResponse response)
    {
        var dto = _mapper.Map<FamiliaDto>(response);
        dto.UsuarioCreacion = _userContext.GetCurrentUserId();
        dto.FechaCreacion = DateTime.Now;
        await _service.AddAsync(dto);
        
        return CreatedAtAction(nameof(GetById), 
            new { id = dto.PkidFamilia },
            new PagedResult<FamiliaResponse>
            {
                Success = true,
                Message = "Familia creada correctamente",
                Code = "SUCCESS",
                TotalCount = 1
            });
    }
}
```

### Frontend

**Page:** `Pages/Almacen/Familia.razor`
```razor
@page "/almacen/familia"
@inherits BaseCrudPage<FamiliaResponse, FamiliaResponse>

<MudContainer>
    <GenericTable TItem="FamiliaResponse"
                  @ref="table"
                  ServerDataFunc="LoadServerData">
        <Header>
            <MudTh>Acciones</MudTh>
            <MudTh><MudTableSortLabel SortLabel="PkidFamilia" T="FamiliaResponse">ID</MudTableSortLabel></MudTh>
            <MudTh>Clave</MudTh>
            <MudTh>Descripción</MudTh>
        </Header>
        <Row Context="familia">
            <MudTd>
                <MudIconButton Icon="@Icons.Material.Filled.Edit"
                               OnClick="@(() => EditItem(familia.PkidFamilia ?? 0))" />
            </MudTd>
            <MudTd>@familia.PkidFamilia</MudTd>
            <MudTd>@familia.Clave</MudTd>
            <MudTd>@familia.Descripcion</MudTd>
        </Row>
    </GenericTable>
</MudContainer>

@code {
    private GenericTable<FamiliaResponse> table = null!;
    protected override string ModuleName => "almacen";
    protected override string SubModuleName => "familia";
    protected override Type CreateDialogType => typeof(FamiliaDialog);
    protected override Type EditDialogType => typeof(FamiliaDialog);
}
```

**Dialog:** `Pages/Almacen/FamiliaDialog.razor`
```razor
<BaseCrudDialog TItem="FamiliaResponse"
                Title="@dialogTitle"
                OnConfirm="GuardarCambiosAsync">

    <MudGrid>
        <MudItem xs="12">
            <MudTextField @bind-Value="familia.Clave"
                          Label="Clave"
                          Required="true" />
        </MudItem>
        <MudItem xs="12">
            <MudTextField @bind-Value="familia.Descripcion"
                          Label="Descripción"
                          Required="true" />
        </MudItem>
    </MudGrid>
</BaseCrudDialog>

@code {
    [Parameter] public int? Id { get; set; }
    [CascadingParameter] private IMudDialogInstance MudDialog { get; set; }

    private FamiliaResponse familia = new() { Activo = true };
    private string dialogTitle => Id.HasValue ? "Editar Familia" : "Nueva Familia";

    private async Task GuardarCambiosAsync(bool _)
    {
        ApiResponse<FamiliaResponse> response;
        if (Id.HasValue)
            response = await _service.UpdateAsync(familia, familia.PkidFamilia ?? 0);
        else
            response = await _service.CreateAsync(familia);

        if (response?.Success == true)
            MudDialog.Close(DialogResult.Ok(true));
    }
}
```

---

*Documentación generada para EGestion360 - Sistema de Gestión de Inventario*
