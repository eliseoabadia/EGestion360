using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Nomina;
using EG.Domain.DTOs.Responses.Nomina;

namespace EG.Application.Interfaces.Nomina
{
    public interface INominaProcesoAppService
    {
        Task<PagedResult<NominaProcesoResponse>> CalcularNominaAsync(NominaProcesoRequest request, int usuarioActual);
        Task<PagedResult<NominaProcesoResponse>> CerrarPeriodoAsync(NominaProcesoRequest request, int usuarioActual);
        Task<PagedResult<NominaProcesoResponse>> CalcularAguinaldoAsync(NominaProcesoRequest request, int usuarioActual);
        Task<PagedResult<NominaProcesoResponse>> CalcularPrimaVacacionalIndividualAsync(NominaProcesoRequest request, int usuarioActual);
        Task<PagedResult<NominaProcesoResponse>> CrearComprometidoNominaAsync(NominaProcesoRequest request, int usuarioActual);
        Task<PagedResult<NominaProcesoResponse>> CrearDevengadoNominaAsync(NominaProcesoRequest request, int usuarioActual);
        Task<PagedResult<NominaProcesoResponse>> CrearEjercidoNominaAsync(NominaProcesoRequest request, int usuarioActual);
    }
}
