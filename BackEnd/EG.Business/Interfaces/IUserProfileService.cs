using EG.Dommain.DTOs.Responses;
using EG.Infraestructure.Models;

namespace EG.Business.Interfaces
{
    public interface IUserProfileService
    {
        Task<IEnumerable<PerfilUsuario>> GetAllUsuariosAsync();
        Task<PerfilUsuario?> GetUsuarioByIdAsync(int UsuarioId);
        Task AddUsuarioAsync(PerfilUsuario dto);
        Task UpdateUsuarioAsync(int UsuarioId, PerfilUsuario dto);
        Task UpdateUserUsuarioAsync(int UsuarioId, PerfilUsuarioResponse dto);
        Task DeleteUsuarioAsync(int UsuarioId);
    }
}
