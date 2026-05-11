using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.General;

namespace EG.Application.Interfaces.General
{
    public interface IUsuarioAreaAppService
    {
        Task<PagedResult<UsuarioAreaResponse>> GetAllAsync(int usuarioId);
    }
}
