using System.Globalization;
using EG.Domain.DTOs.Responses.Nomina;
using Microsoft.AspNetCore.Components;

namespace EG.Web.Pages.Modules.Nomina.Nomina.Incidencias;

public partial class ReporteIncidenciasDetalleDialog
{
    [Parameter] public VwRhIncidenciaResponse? Item { get; set; }

    private static string FormatDate(DateOnly? date) => date?.ToString("dd/MM/yyyy", CultureInfo.InvariantCulture) ?? "-";
}
