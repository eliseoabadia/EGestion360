using Mapster;
using EG.Business.Interfaces;
using EG.Domain.Interfaces;
using EG.Dommain.DTOs.Responses;
using EG.Infraestructure.Models;

namespace EG.Business.Services
{
    public class UserProfileService(IRepository<PerfilUsuario> repositorySP) : IUserProfileService
    {
        private readonly IRepository<PerfilUsuario> _repository = repositorySP;

        public async Task<IEnumerable<PerfilUsuario>> GetAllUsuariosAsync()
        {
            var Usuarios = await _repository.GetAllAsync();
            return Usuarios.Adapt<IEnumerable<PerfilUsuario>>();
        }

        public async Task<PerfilUsuario?> GetUsuarioByIdAsync(int UsuarioId)
        {
            var Usuario = await _repository.GetByIdAsync(UsuarioId);
            return Usuario != null ? Usuario.Adapt<PerfilUsuario>() : null;
        }

        public async Task AddUsuarioAsync(PerfilUsuario dto)
        {
            var _usuario = dto.Adapt<PerfilUsuario>();
            await _repository.AddAsync(_usuario);
        }

        public async Task UpdateUsuarioAsync(int UsuarioId, PerfilUsuario dto)
        {
            var existingUsuario = await _repository.GetByIdAsync(UsuarioId);
            if (existingUsuario == null)
                throw new KeyNotFoundException($"Usuario {UsuarioId} No encontrada.");

            EntityUpdateMapper.Apply(dto, existingUsuario);
            await _repository.UpdateAsync(existingUsuario);
        }

        public async Task UpdateUserUsuarioAsync(int UsuarioId, PerfilUsuarioResponse dto)
        {
            var existingUsuario = await _repository.GetByIdAsync(UsuarioId);
            if (existingUsuario == null)
            {
                existingUsuario = new PerfilUsuario();
                EntityUpdateMapper.Apply(dto, existingUsuario);
                await _repository.AddAsync(existingUsuario);
            }
            else
            {
                EntityUpdateMapper.Apply(dto, existingUsuario);
                await _repository.UpdateAsync(existingUsuario);
            }
        }

        public async Task DeleteUsuarioAsync(int UsuarioId)
        {
            var Usuario = await _repository.GetByIdAsync(UsuarioId);
            if (Usuario == null)
                throw new KeyNotFoundException($"Usuario {UsuarioId} No encontrada.");

            await _repository.DeleteAsync(UsuarioId);
        }
    }
}
