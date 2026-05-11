using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Adquisicion;

namespace EG.Application.Interfaces.Adquisicion
{
    public interface IProcedimientoContratacionAppService
    {
        Task<PagedResult<ProcedimientoContratacionResponse>> GetAllAsync();
        Task<PagedResult<ProcedimientoContratacionResponse>> GetByIdAsync(int id);
        Task<PagedResult<ProcedimientoContratacionResponse>> CreateAsync(ProcedimientoContratacionResponse response, int usuarioActual);
        Task<PagedResult<ProcedimientoContratacionResponse>> UpdateAsync(int id, ProcedimientoContratacionResponse response, int usuarioActual);
        Task<PagedResult<bool>> DeleteAsync(int id);
        Task<PagedResult<ProcedimientoContratacionResponse>> GetAllPaginadoAsync(PagedRequest request);
    }
}
