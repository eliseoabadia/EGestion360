using EG.Domain.DTOs.Responses.Adquisicion;

namespace EG.Application.Interfaces.Adquisicion
{
    public interface IRequisicionAppService : IAdquisicionCrudAppService<RequisicionResponse>
    {
        Task<EG.Common.GenericModel.PagedResult<bool>> DeleteAsync(int id, int usuarioActual);
    }
}
