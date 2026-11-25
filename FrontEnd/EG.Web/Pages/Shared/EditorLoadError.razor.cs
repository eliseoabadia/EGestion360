using Microsoft.AspNetCore.Components;

namespace EG.Web.Pages.Shared;

public partial class EditorLoadError
{
    [Parameter, EditorRequired] public string Message { get; set; } = string.Empty;
    [Parameter] public EventCallback OnRetry { get; set; }
}
