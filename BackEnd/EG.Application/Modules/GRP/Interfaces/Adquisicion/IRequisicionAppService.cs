using EG.Domain.DTOs.Responses.Adquisicion;

namespace EG.Application.Interfaces.Adquisicion
{
    public interface IRequisicionAppService : IAdquisicionCrudAppService<RequisicionResponse>
    {
        Task<EG.Common.GenericModel.PagedResult<EG.Domain.DTOs.Responses.General.UsuarioAreaResponse>> GetRequestersAsync();
        Task<EG.Common.GenericModel.PagedResult<bool>> DeleteAsync(int id, int usuarioActual);
    }
}
