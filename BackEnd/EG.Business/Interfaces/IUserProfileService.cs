using EG.Domain.Entities;
using EG.Dommain.DTOs.Responses;
using System;
using System.Collections.Generic;
using System.Text;

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
