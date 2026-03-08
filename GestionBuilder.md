Tomar como base la siguiente estrcutura:
EG.Web/
├── Pages/
│   ├── Account/
│   │   └── Login.razor
│   ├── Configuration/
│   │   ├── Empresa/
│   │   │   └── EmpresaDialog.razor
│   │   ├── Menu/
│   │   │   ├── CrearMenu.razor
│   │   │   └── (otros CRUD de menú)
│   │   ├── Usuario/
│   │   │   ├── Usuarios.razor
│   │   │   ├── Crear.razor
│   │   │   └── Editar.razor
│   │   └── Departamento/
│   │       └── Departamentos.razor
│   └── ConteoCiclico/
│       ├── PeriodoConteo.razor
│       ├── PeriodoConteoDashboard.razor
│       └── PeriodoConteoDialog.razor
├── Services/
│   ├── BaseService.cs
│   ├── GenericCrudService.cs
│   ├── ILoginService.cs
│   ├── IGenericServiceFactory.cs (fábrica genérica)
│   ├── AuthenticationProviderJWT.cs
│   ├── INavigateService.cs
│   ├── MenuStateService.cs
│   └── Configuration/
│       ├── EmpresaService.cs
│       ├── DepartamentoService.cs
│       ├── UsuarioService.cs
│       ├── SucursalService.cs
│       └── (otros servicios específicos)
├── Contracs/   (nota: en el repo la carpeta aparece como Contracs)
│   └── Configuration/
│       ├── IEmpresaService.cs
│       ├── IDepartamentoService.cs
│       ├── IUsuarioService.cs
│       └── ISucursalService.cs
├── Models/
│   └── Configuration/
│       ├── EmpresaResponse.cs
│       ├── PerfilUsuarioResponse.cs
│       ├── MenuItemsResponse.cs
│       └── MenuItem.cs (cliente)
├── Pages/Shared/
│   ├── BaseCrudPage.razor.cs
│   └── GenericTable.razor
├── Layout/
│   ├── MainLayout.razor
│   ├── DynamicMenu.razor
│   └── NavMenuItems.razor

En base a mi modelo, requiero que me ayudes a pasar el conteo ciclico y utilizar
@inherits BaseCrudPage<EmpresaResponse, EmpresaResponse> como ejemplo