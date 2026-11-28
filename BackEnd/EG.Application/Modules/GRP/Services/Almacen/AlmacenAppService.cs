using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Almacen;
using EG.Application.Interfaces.Almacen;
using EG.Business.Interfaces;

namespace EG.Application.Services.Almacen;

public sealed class AlmacenAppService(IAlmacenOperations service) : IAlmacenAppService
{
    public Task<PagedResult<AlmacenResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<PagedResult<AlmacenResponse>> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<PagedResult<AlmacenResponse>> CreateAsync(AlmacenResponse response, int usuarioActual) => service.CreateAsync(response, usuarioActual);
    public Task<PagedResult<AlmacenResponse>> UpdateAsync(int id, AlmacenResponse response, int usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public Task<PagedResult<bool>> DeleteAsync(int id) => service.DeleteAsync(id);
    public Task<PagedResult<AlmacenResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
    public Task<PagedResult<AlmacenResponse>> CreateSalidaAjusteAsync(int origenId, AlmacenResponse response, int usuarioActual) => service.CreateSalidaAjusteAsync(origenId, response, usuarioActual);
}
