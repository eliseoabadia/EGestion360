using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.ConteoCiclico;

namespace EG.Application.Interfaces.ConteoCiclico
{
    public interface IConteoDetalleEscaneoAppService
    {
        Task<PagedResult<ConteoDetalleEscaneoResponse>> GetAllAsync();
        Task<PagedResult<ConteoDetalleEscaneoResponse>> GetByIdAsync(int id);
        Task<PagedResult<ConteoDetalleEscaneoResponse>> GetAllPaginadoAsync(PagedRequest pageRequest);
        Task<PagedResult<ConteoDetalleEscaneoResponse>> GetByConteoAsync(int conteoId);
        Task<PagedResult<ConteoDetalleEscaneoResponse>> CreateAsync(ConteoDetalleEscaneoResponse request, int usuarioActual);
    }
}
