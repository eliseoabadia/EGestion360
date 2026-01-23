namespace EG.Builder.Templates;
public static class ViewTemplate
{
    public static string View =
@"@page ""/ROUTEPAGEMENU""
@using System.ComponentModel.DataAnnotations
@using EG.WebApp.Models.Configuration
@using EG.WebApp.Services.Configuration
@using Microsoft.AspNetCore.Components.Forms

@inject IJSRuntime _jsRuntime
@inject ProfileService profileService

<MudContainer Class=""px-2 d-flex flex-column"" MaxWidth=""MaxWidth.False"" Style=""height: 100vh; padding-top: 20px;"">

    <!-- Usando Card para el header -->
    <MudCard Elevation=""1"" Class=""mb-4"">
        <MudCardContent>
            <MudGrid Spacing=""2"" AlignItems=""AlignItems.Center"" Justify=""Justify.SpaceBetween"">
                <MudItem>
                    <MudStack Spacing=""2"">
                        <MudText Typo=""Typo.h4""
                                 Color=""Color.Primary""
                                 Style=""font-weight: 600; display: flex; align-items: center; gap: 12px;"">
                            <MudIcon Icon=""@Icons.Material.Filled.PeopleAlt""
                                     Color=""Color.Primary""
                                     Size=""Size.Large"" />
                            Gestión de TABLENAMEs
                        </MudText>
                        <MudText Typo=""Typo.body2""
                                 Color=""Color.Tertiary""
                                 Class=""ml-6"">
                            Administra y mantén el registro de TABLENAMEs del sistema
                        </MudText>
                    </MudStack>
                </MudItem>

                <MudItem>
                    <MudButtonGroup Variant=""Variant.Filled"" Color=""Color.Primary"">
                        <MudTooltip Text=""Nuevo TABLENAME"">
                            <MudButton StartIcon=""@Icons.Material.Filled.Add""
                                       OnClick=""CrearTABLENAME""
                                       Size=""Size.Small"" />
                        </MudTooltip>
                        <MudTooltip Text=""Refrescar..."">
                            <MudButton StartIcon=""@Icons.Material.Filled.Refresh""
                                       OnClick=""OnSearchInput""
                                       Size=""Size.Small"" />
                        </MudTooltip>
                    </MudButtonGroup>
                </MudItem>
            </MudGrid>
        </MudCardContent>
    </MudCard>

    <MudPaper Elevation=""2"" Class=""pa-4 rounded-lg"">

        <MudTable ServerData=""LoadServerData""
                  RowsPerPage=""@pageSize""
                  Page=""@currentPage""
                  RowCount=""@totalCount""
                  @ref=""mudTableRef""
                  Dense=""@dense""
                  Hover=""@hover""
                  Loading=""@loading""
                  ReadOnly=""@ronly""
                  SortLabel=""Sort By""
                  InitialSortDirection=""SortDirection.Descending""
                  @bind-SelectedItem=""selectedItem1""
                  IsEditRowSwitchingBlocked=""@blockSwitch""
                  ApplyButtonPosition=""@applyButtonPosition""
                  EditButtonPosition=""@editButtonPosition""
                  EditTrigger=""@editTrigger"">
            <ToolBarContent>
                <MudText Typo=""Typo.h6"">Lista de TABLENAMEs</MudText>
                <MudSpacer />
                <MudTextField @bind-Value=""searchString""
                              Placeholder=""Buscar por nombre, email o teléfono...""
                              Adornment=""Adornment.Start""
                              AdornmentIcon=""@Icons.Material.Filled.Search""
                              IconSize=""Size.Medium""
                              Immediate=""true""
                              @ref=""txtSerch""
                              OnKeyUp=""HandleKeyUp""
                              Class=""mt-0"">
                </MudTextField>
            </ToolBarContent>
            <HeaderContent>
                <MudTh>Acciones</MudTh>
                SEARCHHEADERTABLE
            </HeaderContent>
            <RowTemplate>
                <MudTd>
                    <MudTooltip Text=""Editar TABLENAME"">
                        <MudIconButton Icon=""@Icons.Material.Filled.Edit""
                                       Color=""Color.Primary""
                                       Size=""Size.Small""
                                       OnClick=""@(() => EditarTABLENAME(context.PKIDENEITY))"" />
                    </MudTooltip>

                    <MudTooltip Text=""Eliminar TABLENAME"">
                        <MudIconButton Icon=""@Icons.Material.Filled.Delete""
                                       Color=""Color.Error""
                                       Size=""Size.Small""
                                       OnClick=""@(() => EliminarItem(context.PKIDENEITY))"" />
                    </MudTooltip>
                </MudTd>

                SEARCHDETAILTABLE
            </RowTemplate>
            <NoRecordsContent>
                <MudText>No se encontraron registros</MudText>
            </NoRecordsContent>
            <LoadingContent>
                <MudText>Cargando...</MudText>
            </LoadingContent>
            <PagerContent>
                <MudTablePager RowsPerPageString=""Filas por página""
                               FirstPageIcon=""@Icons.Material.Filled.FirstPage""
                               LastPageIcon=""@Icons.Material.Filled.LastPage""
                               NextPageIcon=""@Icons.Material.Filled.NavigateNext""
                               PreviousPageIcon=""@Icons.Material.Filled.NavigateBefore""
                               PageSizeOptions=""new int[] { 5, 10, 20, 50 }""
                               ShowFirstLastPage=""true""
                               ShowPageSizeSelector=""true""
                               ShowPaginationText=""true""
                               PaginationTextFormat=""Página {0} de {1}"" />
            </PagerContent>

        </MudTable>
    </MudPaper>

</MudContainer>

@code {
    private IList<TABLENAMEResponse> Elements = new List<TABLENAMEResponse>();
    private int totalCount = 0;

    [Inject] private ISnackbar Snackbar { get; set; } = null!;
    [Inject] private NavigationManager NavigationManager { get; set; } = null!;
    [Inject] private IDialogService DialogService { get; set; } = null!;

    private bool _isInitialized = false;

    private bool dense = true;
    private bool hover = true;
    private bool ronly = true;
    private bool blockSwitch = false;

    private TABLENAMEResponse selectedItem1 = new TABLENAMEResponse();
    private MudTable<TABLENAMEResponse> mudTableRef = new MudTable<TABLENAMEResponse>();

    private MudTextField<string> txtSerch = new MudTextField<string>();

    private string searchString = string.Empty;
    private bool loading = true;
    private int currentPage = 0;
    private int pageSize = 10;
    private int[] pageSizeOptions = new[] { 10, 25, 50, 100 };
    private CancellationTokenSource searchCts = new CancellationTokenSource();

    private HashSet<TABLENAMEResponse> selectedItems1 = new HashSet<TABLENAMEResponse>();
    private TableApplyButtonPosition applyButtonPosition = TableApplyButtonPosition.End;
    private TableEditButtonPosition editButtonPosition = TableEditButtonPosition.End;
    private TableEditTrigger editTrigger = TableEditTrigger.RowClick;

    private SortDirection sortDirection;
    private string sortLabel = string.Empty;



    protected override async Task OnAfterRenderAsync(bool firstRender)
    {
        if (firstRender && !_isInitialized)
        {
            await Task.Run(() =>
           {
               _isInitialized = true;
               loading = false;
           });
        }
    }

    private async Task<TableData<TABLENAMEResponse>> LoadServerData(TableState state, CancellationToken cancellationToken)
    {
        loading = true;

        try
        {
            currentPage = state.Page + 1; // MudBlazor uses 0-based index
            pageSize = state.PageSize;
            sortLabel = state.SortLabel == null ? ""NombreCompleto"" : state.SortLabel;
            sortDirection = state.SortDirection;

            (Elements, totalCount) = await profileService.GetAllTABLENAMEsPaginadoAsync(
                currentPage,
                pageSize,
                searchString,
                sortLabel,
                sortDirection
            );

            return new TableData<TABLENAMEResponse>
            {
                Items = Elements,
                TotalItems = totalCount
            };
        }
        catch (Exception ex)
        {
            Snackbar.Add($""Error al cargar TABLENAMEs: {ex.Message}"", Severity.Error);
            return new TableData<TABLENAMEResponse>
            {
                Items = new List<TABLENAMEResponse>(),
                TotalItems = 0
            };
        }
        finally
        {
            loading = false;
        }
    }

    private async void OnSearchInput()
    {
        // Cancelar búsqueda anterior si existe
        searchCts?.Cancel();
        searchCts = new CancellationTokenSource();

        try
        {
            // Esperar 500ms para evitar múltiples llamadas mientras el TABLENAME escribe
            await Task.Delay(500, searchCts.Token);

            if (!searchCts.Token.IsCancellationRequested && mudTableRef != null)
            {
                // Reiniciar a la primera página y recargar datos
                await mudTableRef.ReloadServerData();
            }
        }
        catch (TaskCanceledException)
        {
            // La búsqueda fue cancelada por una nueva entrada, esto es normal
            Console.WriteLine(""Búsqueda cancelada"");
        }
    }

    private async void HandleKeyUp(KeyboardEventArgs args)
    {
        if (args.Key == ""Enter"")
        {
            await mudTableRef.ReloadServerData();
        }
    }

    private async Task CrearTABLENAME()
    {
        try
        {
            var parameters = new DialogParameters();
            var options = new DialogOptions
            {
                CloseButton = true,
                MaxWidth = MaxWidth.Medium,
                FullWidth = false,
                Position = DialogPosition.Center,
                NoHeader = false,
            };

            var dialog = await DialogService.ShowAsync<Crear>(""Crear TABLENAME"", parameters, options);
            var result = await dialog.Result;

            if (!result!.Canceled)
            {
                currentPage = 1;
                await mudTableRef.ReloadServerData();
            }
        }
        catch (Exception ex)
        {
            Snackbar.Add(""Ocurrió un error: "" + ex.Message, Severity.Error);
        }
    }

    private async Task EditarTABLENAME(int id)
    {
        try
        {
            var parameters = new DialogParameters { [""itemId""] = id };
            var options = new DialogOptions
            {
                CloseButton = true,
                MaxWidth = MaxWidth.Medium,
                FullWidth = true,
            };

            var dialog = await DialogService.ShowAsync<Editar>(""Editar TABLENAME"", parameters, options);
            var result = await dialog.Result;

            if (!result!.Canceled)
            {
                await mudTableRef.ReloadServerData();
            }
        }
        catch (Exception ex)
        {
            Snackbar.Add(""Error al editar TABLENAME: "" + ex.Message, Severity.Error);
        }
    }

    private async Task EliminarItem(int id)
    {
        try
        {
            var parameters = new DialogParameters { [""itemId""] = id };
            var options = new DialogOptions
            {
                CloseButton = true,
                MaxWidth = MaxWidth.Small,
                FullWidth = true,
            };

            var dialog = await DialogService.ShowAsync<Eliminar>(""Eliminar TABLENAME"", parameters, options);
            var result = await dialog.Result;

            if (!result!.Canceled)
            {
                if (Elements.Count == 1 && currentPage > 1)
                {
                    currentPage--;
                }
                await mudTableRef.ReloadServerData();
            }
        }
        catch (Exception ex)
        {
            Snackbar.Add(""Error al eliminar TABLENAME: "" + ex.Message, Severity.Error);
        }
    }
}



";
}


public static class ViewCrearTemplate
{
    public static string View =
@"@using System.ComponentModel.DataAnnotations
@using EG.WebApp.Models.Configuration
@using EG.WebApp.Services.Configuration
@using Microsoft.AspNetCore.Components.Forms
@using MudBlazor


@inject IJSRuntime _jsRuntime

//@inject EmpresaService empresaService
@inject TABLENAMEService itemService
@inject NavigationManager NavigationManager
@inject ISnackbar Snackbar



<MudDialog MaxWidth=""MaxWidth.Medium"" FullWidth=""true"" CloseOnEscapeKey=""false"">
    <DialogContent>
        <!-- Indicador de carga -->
        <MudOverlay Visible=""@loading"" Fixed=""true"" ZIndex=""10"">
            <div class=""d-flex flex-column align-center justify-center"" style=""height:100%"">
                <MudProgressCircular Color=""Color.Primary"" Size=""Size.Large"" Indeterminate=""true"" />
                <MudText Class=""mt-4"">Cargando...</MudText>
            </div>
        </MudOverlay>
        <MudPaper Class=""pa-6 my-6"" Elevation=""6"">
            <MudGrid GutterSize=""2"">
                <!-- Información del TABLENAME -->
                <MudForm @ref=""form"">

                    <MudCard Elevation=""2"" Class=""pa-2"">
                        <MudDivider Class=""mb-4"" />
                        <MudForm>
                            <MudGrid GutterSize=""2"">
                                FROMEDITDETAILENTITY
                            </MudGrid>

                            <!-- Botones -->
                            <div class=""d-flex justify-end mt-6"">
                                <MudButton Variant=""Variant.Text"" Color=""Color.Secondary"" Class=""mr-2"" OnClick=""Cancelar"">
                                    Cancelar
                                </MudButton> 
                                <MudButton Variant=""Variant.Filled"" Color=""Color.Primary"" StartIcon=""@Icons.Material.Filled.Save"" OnClick=""GuardarCambiosAsync"">
                                    Guardar cambios
                                </MudButton>
                            </div>
                        </MudForm>
                    </MudCard>
                </MudForm>
            </MudGrid>
        </MudPaper>
    </DialogContent>
</MudDialog>


@code {

    [Parameter] public int itemId { get; set; }

    [CascadingParameter] private IMudDialogInstance MudDialog { get; set; } = null!;

    private MudForm form = new MudForm();

    private bool loading = false;

    //public List<EmpresaResponse> listadoEmpresas { get; set; } = new();

    public TABLENAMEResponse itemEntity { get; set; } = new();


    protected override async Task OnInitializedAsync()
    {
        loading = true;
        try
        {
            //await LoadData();

            StateHasChanged();
        }
        catch (Exception ex)
        {
            Snackbar.Add($""Error al cargar datos: {ex.Message}"", Severity.Error);
        }
        finally
        {
            loading = false;
        }
    }

    /*private async Task LoadData()
    {
        listadoEmpresas = await empresaService.GetEmpresa();
    }*/

    private async Task GuardarCambiosAsync()
    {
        bool result;
        string msg;
        loading = true;
        try
        {
            // // Simular operación de guardado
            await form.Validate();

            if (!form.IsValid)
            {
                Snackbar.Add(""Por favor, completa todos los campos requeridos."", Severity.Warning);
                return;
            }

            try
            {
                (result, msg) = await itemService.CreateTABLENAME(itemEntity);

                Snackbar.Add(msg, result ? Severity.Success : Severity.Error);

                MudDialog.Close(DialogResult.Ok(result));
            }
            catch (Exception ex)
            {
                Snackbar.Add($""Error al guardar: {ex.Message}"", Severity.Error);
            }

        }
        catch (Exception ex)
        {
            Snackbar.Add($""Error al guardar: {ex.Message}"", Severity.Error);
        }
        finally
        {
            loading = false;
        }
    }

    private void Cancelar()
    {
        MudDialog.Cancel();
    }
}
";
}


public static class ViewEdithTemplate
{
    public static string View =
@"@using System.ComponentModel.DataAnnotations
@using EG.WebApp.Models.Configuration
@using EG.WebApp.Services.Configuration
@using Microsoft.AspNetCore.Components.Forms
@using MudBlazor


@inject IJSRuntime _jsRuntime

//@inject EmpresaService empresaService
@inject TABLENAMEService itemService
@inject NavigationManager NavigationManager
@inject ISnackbar Snackbar


<MudDialog>
    <DialogContent>
        <!-- Indicador de carga -->
        <MudOverlay Visible=""@loading"" Fixed=""true"" ZIndex=""10"">
            <div class=""d-flex flex-column align-center justify-center"" style=""height:100%"">
                <MudProgressCircular Color=""Color.Primary"" Size=""Size.Large"" Indeterminate=""true"" />
                <MudText Class=""mt-4"">Cargando...</MudText>
            </div>
        </MudOverlay>
        <MudPaper Class=""pa-6 my-6"" Elevation=""6"">
            <MudGrid GutterSize=""2"">


                <!-- Información del TABLENAME -->
         
                    <MudForm @ref=""form"">

                        <MudCard Elevation=""2"" Class=""pa-2"">
                           
                            <MudDivider Class=""mb-4"" />

                            <MudForm>
                                <MudGrid GutterSize=""2"">
                                    FROMEDITDETAILENTITY
                                </MudGrid>

                                <!-- Botones -->
                                <div class=""d-flex justify-end mt-6"">
                                    @*  <MudButton Variant=""Variant.Text"" Color=""Color.Secondary"" Class=""mr-2"" OnClick=""Cancelar"">
                                    Cancelar
                                </MudButton> *@
                                    <MudButton Variant=""Variant.Filled"" Color=""Color.Primary"" StartIcon=""@Icons.Material.Filled.Save"" OnClick=""GuardarCambiosAsync"">
                                        Guardar cambios
                                    </MudButton>
                                </div>
                            </MudForm>
                        </MudCard>
                    </MudForm>
              
            </MudGrid>

        </MudPaper>
    </DialogContent>
</MudDialog>


@code {
    
    [Parameter] public int itemId { get; set; }

    [CascadingParameter] private IMudDialogInstance MudDialog { get; set; } = null!;

    private MudForm form;

    private bool loading = false;

    //public List<EmpresaResponse> listadoEmpresas { get; set; } = new();

    public TABLENAMEResponse itemEntity { get; set; } = new();

    private bool isLoading = false;

    // Propiedad intermedia para el binding
    //private void OnSelectedGeneroChanged(bool selectedOption)
    //{
    //    itemEntity.Sexo = selectedOption;
    //}

    protected override async Task OnInitializedAsync()
    {
        loading = true;
        try
        {
            //await LoadData();

            StateHasChanged();
        }
        catch (Exception ex)
        {
            Snackbar.Add($""Error al cargar datos: {ex.Message}"", Severity.Error);
        }
        finally
        {
            loading = false;
        }
    }

    private async Task LoadData()
    {
        itemEntity = await itemService.GetTABLENAMEByIdAsync(itemId);

        //listadoEmpresas = await empresaService.GetEmpresa();
    }

    private async Task GuardarCambiosAsync()
    {
        bool result;
        string msg;
        loading = true;
        try
        {
            await form.Validate();

            if (!form.IsValid)
            {
                Snackbar.Add(""Por favor, completa todos los campos requeridos."", Severity.Warning);
                return;
            }

            try
            {
                (result, msg) = await itemService.SetTABLENAMEById(itemId, itemEntity);

                Snackbar.Add(msg, result ? Severity.Success : Severity.Error);

                MudDialog.Close(DialogResult.Ok(result));
            }
            catch (Exception ex)
            {
                Snackbar.Add($""Error al guardar: {ex.Message}"", Severity.Error);
            }

        }
        catch (Exception ex)
        {
            Snackbar.Add($""Error al guardar: {ex.Message}"", Severity.Error);
        }
        finally
        {
            loading = false;
        }
    }

    private void Cancelar()
    {
        MudDialog.Cancel();
    }

}
";
}

public static class ViewDeleteTemplate
{
    public static string View =
@"@using System.ComponentModel.DataAnnotations
@using EG.WebApp.Models.Configuration
@using EG.WebApp.Services.Configuration
@using Microsoft.AspNetCore.Components.Forms
@using MudBlazor

@inject IJSRuntime _jsRuntime
@inject ProfileService profileService

<MudDialog>
    <DialogContent>
        <MudText Typo=""Typo.h6"" GutterBottom=""true"">¿Estás seguro?</MudText>
        <MudText Typo=""Typo.body2"">
            Estás a punto de eliminar este registro. Esta acción no se puede deshacer. ¿Deseas continuar?
        </MudText>
    </DialogContent>
    <DialogActions>
        <MudButton OnClick=""Cancelar"" Color=""Color.Primary"" Variant=""Variant.Text"">Cancelar</MudButton>
        <MudButton OnClick=""EliminarTABLENAME"" Color=""Color.Error"" Variant=""Variant.Filled"">Eliminar</MudButton>
    </DialogActions>
</MudDialog>

@code {
    [Parameter] public int itemId { get; set; }

    private bool loading = false;

    [Inject] private ISnackbar Snackbar { get; set; } = null!;
    [Inject] private NavigationManager NavigationManager { get; set; } = null!;
    [CascadingParameter] private IMudDialogInstance MudDialog { get; set; } = null!;

    private async Task EliminarTABLENAME()
    {
        bool result;
        string msg;
        loading = true;

        try
        {
            (result, msg) = await profileService.DeleteTABLENAMEById(itemId);

            Snackbar.Add(msg, result ? Severity.Success : Severity.Error);

            MudDialog.Close(DialogResult.Ok(result));
        }
        catch (Exception ex)
        {
            Snackbar.Add($""Error al eliminar el TABLENAME: {ex.Message}"", Severity.Error);
        }
    }

    private void Cancelar()
    {
        MudDialog.Close(DialogResult.Cancel());
    }
}

";
}
