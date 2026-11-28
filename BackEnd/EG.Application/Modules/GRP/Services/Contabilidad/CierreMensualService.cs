using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Application.Interfaces.Contabilidad;
using EG.Business.Interfaces;

namespace EG.ApiCoreBS.Services.Contabilidad;

public sealed class CierreMensualService(ICierreMensualOperations service) : ICierreMensualService
{
    public Task<PagedResult<CierreMensualResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<PagedResult<CierreMensualResponse>> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<PagedResult<CierreMensualResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
    public Task<PagedResult<CierreMensualResponse>> GetEstadoAsync() => service.GetEstadoAsync();
    public Task<PagedResult<CierreMensualResponse>> AplicarCierreMensualAsync(int usuarioActual) => service.AplicarCierreMensualAsync(usuarioActual);
}
