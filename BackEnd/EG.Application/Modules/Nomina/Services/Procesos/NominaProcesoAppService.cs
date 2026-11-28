using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Nomina;
using EG.Domain.DTOs.Responses.Nomina;
using EG.Application.Interfaces.Nomina;
using EG.Business.Interfaces;

namespace EG.Application.Services.Nomina;

public sealed class NominaProcesoAppService(INominaProcesoOperations service) : INominaProcesoAppService
{
    public Task<PagedResult<NominaProcesoResponse>> CalcularNominaAsync(NominaProcesoRequest request, int usuarioActual) => service.CalcularNominaAsync(request, usuarioActual);
    public Task<PagedResult<NominaProcesoResponse>> CerrarPeriodoAsync(NominaProcesoRequest request, int usuarioActual) => service.CerrarPeriodoAsync(request, usuarioActual);
    public Task<PagedResult<NominaProcesoResponse>> CalcularAguinaldoAsync(NominaProcesoRequest request, int usuarioActual) => service.CalcularAguinaldoAsync(request, usuarioActual);
    public Task<PagedResult<NominaProcesoResponse>> CalcularPrimaVacacionalIndividualAsync(NominaProcesoRequest request, int usuarioActual) => service.CalcularPrimaVacacionalIndividualAsync(request, usuarioActual);
    public Task<PagedResult<NominaProcesoResponse>> CrearComprometidoNominaAsync(NominaProcesoRequest request, int usuarioActual) => service.CrearComprometidoNominaAsync(request, usuarioActual);
    public Task<PagedResult<NominaProcesoResponse>> CrearDevengadoNominaAsync(NominaProcesoRequest request, int usuarioActual) => service.CrearDevengadoNominaAsync(request, usuarioActual);
    public Task<PagedResult<NominaProcesoResponse>> CrearEjercidoNominaAsync(NominaProcesoRequest request, int usuarioActual) => service.CrearEjercidoNominaAsync(request, usuarioActual);
}
