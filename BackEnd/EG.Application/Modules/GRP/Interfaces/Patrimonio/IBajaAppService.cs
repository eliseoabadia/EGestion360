using EG.Application.Interfaces.Adquisicion;
using EG.Domain.DTOs.Responses.Patrimonio;

namespace EG.Application.Interfaces.Patrimonio
{
    public interface IBajaAppService : IAdquisicionCrudAppService<BajaResponse>
    {
        Task<EG.Common.GenericModel.PagedResult<BajaResponse>> AplicarAsync(int id, int fkidAnioSis, int usuarioActual);
    }
}
