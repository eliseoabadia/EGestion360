using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.General;

namespace EG.Application.Interfaces.General
{
    public interface IDepartamentoAppService
    {
        Task<PagedResult<DepartamentoResponse>> GetAllAsync();
        Task<DepartamentoResponse> GetByIdAsync(int id);
        Task<PagedResult<DepartamentoResponse>> GetAllPaginadoAsync(PagedRequest request);
        Task<PagedResult<DepartamentoResponse>> GetAllByEmpresaAsync(int empresaId);
        Task<DepartamentoResponse> CreateAsync(DepartamentoDto dto, int usuarioActual);
        Task<DepartamentoResponse> UpdateAsync(int id, DepartamentoDto dto, int usuarioActual);
        Task DeleteAsync(int id);
    }
}