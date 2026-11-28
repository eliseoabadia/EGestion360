using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.ConteoCiclico;

namespace EG.Business.Interfaces;

public interface IConteoDetalleEscaneoOperations
{
    Task<PagedResult<ConteoDetalleEscaneoResponse>> GetAllAsync();
    Task<PagedResult<ConteoDetalleEscaneoResponse>> GetByIdAsync(int id);
    Task<PagedResult<ConteoDetalleEscaneoResponse>> GetAllPaginadoAsync(PagedRequest pageRequest);
    Task<PagedResult<ConteoDetalleEscaneoResponse>> GetByConteoAsync(int conteoId);
    Task<PagedResult<ConteoDetalleEscaneoResponse>> CreateAsync(ConteoDetalleEscaneoResponse request, int usuarioActual);
}
