using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Adquisicion;

namespace EG.Application.Interfaces.Adquisicion
{
    public interface IEstatusRequisicionAppService
    {
        Task<PagedResult<EstatusRequisicionResponse>> GetAllAsync();
        Task<PagedResult<EstatusRequisicionResponse>> GetByIdAsync(int id);
        Task<PagedResult<EstatusRequisicionResponse>> CreateAsync(EstatusRequisicionResponse response, int usuarioActual);
        Task<PagedResult<EstatusRequisicionResponse>> UpdateAsync(int id, EstatusRequisicionResponse response, int usuarioActual);
        Task<PagedResult<bool>> DeleteAsync(int id);
        Task<PagedResult<EstatusRequisicionResponse>> GetAllPaginadoAsync(PagedRequest request);
    }
}
