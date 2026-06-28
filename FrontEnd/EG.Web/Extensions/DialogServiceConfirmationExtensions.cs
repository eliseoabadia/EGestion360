using EG.Web.Pages.Shared;
using MudBlazor;

namespace EG.Web.Extensions
{
    public static class DialogServiceConfirmationExtensions
    {
        public static async Task<bool> ConfirmWorkflowAsync(
            this IDialogService dialogService,
            string title,
            string message,
            string confirmText = "Confirmar",
            Color confirmColor = Color.Primary,
            int? id = null)
        {
            var parameters = new DialogParameters
            {
                [nameof(ConfirmIniciarConteoDialog.Title)] = title,
                [nameof(ConfirmIniciarConteoDialog.Message)] = message,
                [nameof(ConfirmIniciarConteoDialog.ConfirmText)] = confirmText,
                [nameof(ConfirmIniciarConteoDialog.ConfirmColor)] = confirmColor,
                [nameof(ConfirmIniciarConteoDialog.Id)] = id
            };

            var dialog = await dialogService.ShowAsync<ConfirmIniciarConteoDialog>(
                string.Empty,
                parameters,
                new DialogOptions
                {
                    MaxWidth = MaxWidth.Small,
                    FullWidth = true,
                    CloseOnEscapeKey = true
                });

            var result = await dialog.Result;
            return result is { Canceled: false, Data: true };
        }
    }
}
