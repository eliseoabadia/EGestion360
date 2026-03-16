using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Dommain.DTOs.Responses;

namespace EG.Application.Interfaces.General
{
    public interface IUsuarioAppService
    {
        Task<PagedResult<UsuarioResponse>> GetAllAsync();
        Task<UsuarioResponse> GetByIdAsync(int id);
        Task<PagedResult<UsuarioResponse>> GetAllPaginadoAsync(PagedRequest pageRequest, Func<UsuarioResponse, bool> predicate = null);
        Task<PagedResult<UsuarioResponse>> GetByEmpresaIdAsync(int empresaId);
        Task<UsuarioResponse> CreateAsync(UsuarioDto dto, int usuarioActual);
        Task<UsuarioResponse> UpdateAsync(int id, UsuarioDto dto, int usuarioActual);
        Task<bool> DeleteAsync(int id, int usuarioActual);
    }
}