using Microsoft.AspNetCore.Components;
using MudBlazor;

namespace EG.Web.Pages.Shared;

public partial class DeleteDialog<TItem>
{
    [Parameter] public int Id { get; set; }
    [Parameter] public string? ItemName { get; set; }
    [Parameter] public Func<int, Task<bool>>? DeleteFunc { get; set; }
    [Parameter] public string ConfirmationMessage { get; set; } = "La baja se aplicará según el estado y las dependencias del registro.";

    [Parameter] public TItem? ItemPayload { get; set; }
    
    private BaseCrudDialog<TItem>? dialog;
    
    private bool isDeleted = false;


    private async Task Eliminar(bool _)
    {
        if (DeleteFunc == null)
        {
            return;
        }

        var result = await DeleteFunc(Id);
        if (result)
        {
            isDeleted = true;
            dialog?.SignalClose(true);
        }
    }
}
