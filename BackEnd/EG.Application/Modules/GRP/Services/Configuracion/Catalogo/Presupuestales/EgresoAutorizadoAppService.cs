using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales;
using EG.Business.Interfaces;

namespace EG.Application.Services.Configuracion.Catalogo.Presupuestales;

public sealed class EgresoAutorizadoAppService(IEgresoAutorizadoOperations service) : IEgresoAutorizadoAppService
{
    public Task<PagedResult<EgresoAutorizadoResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<PagedResult<EgresoAutorizadoResponse>> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<PagedResult<EgresoAutorizadoResponse>> CreateAsync(EgresoAutorizadoResponse response, int usuarioActual) => service.CreateAsync(response, usuarioActual);
    public Task<PagedResult<EgresoAutorizadoResponse>> UpdateAsync(int id, EgresoAutorizadoResponse response, int usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public Task<PagedResult<bool>> DeleteAsync(int id) => service.DeleteAsync(id);
    public Task<PagedResult<EgresoAutorizadoResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
    public Task<PagedResult<EgresoAutorizadoResponse>> AutorizarProyectadoAsync( int pkidEgresoProyectado, int usuarioActual, int? fkidPolizaConta, string? descripcion) => service.AutorizarProyectadoAsync(pkidEgresoProyectado, usuarioActual, fkidPolizaConta, descripcion);
    public Task<PagedResult<bool>> RegresarAProyectadoAsync(int pkidEgresoAutorizado, int usuarioActual) => service.RegresarAProyectadoAsync(pkidEgresoAutorizado, usuarioActual);
}
