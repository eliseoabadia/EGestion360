using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.General;

namespace EG.Application.Interfaces.General
{
    public interface IEmpresaAppService
    {
        // Consultas
        Task<PagedResult<EmpresaResponse>> GetAllAsync();
        Task<EmpresaResponse> GetByIdAsync(int id);
        Task<PagedResult<EmpresaResponse>> GetAllPaginadoAsync(PagedRequest request);

        // Comandos
        Task<EmpresaResponse> CreateAsync(EmpresaDto dto, int usuarioActual);
        Task<EmpresaResponse> UpdateAsync(int id, EmpresaDto dto, int usuarioActual);
        Task DeleteAsync(int id);
    }
}