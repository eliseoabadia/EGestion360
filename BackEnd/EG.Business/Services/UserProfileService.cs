using AutoMapper;
using EG.Business.Interfaces;
using EG.Domain.Entities;
using EG.Domain.Interfaces;
using EG.Dommain.DTOs.Responses;

namespace EG.Business.Services
{
    public class UserProfileService(IRepository<PerfilUsuario> repositorySP,
                    IMapper mapper) : IUserProfileService
    {
        private readonly IRepository<PerfilUsuario> _repository = repositorySP;
        private readonly IMapper _mapper = mapper;

        public async Task<IEnumerable<PerfilUsuario>> GetAllUsuariosAsync()
        {
            var Usuarios = await _repository.GetAllAsync();
            return _mapper.Map<IEnumerable<PerfilUsuario>>(Usuarios);
        }

        public async Task<PerfilUsuario?> GetUsuarioByIdAsync(int UsuarioId)
        {
            var Usuario = await _repository.GetByIdAsync(UsuarioId);
            return Usuario != null ? _mapper.Map<PerfilUsuario>(Usuario) : null;
        }

        public async Task AddUsuarioAsync(PerfilUsuario dto)
        {
            var _usuario = _mapper.Map<PerfilUsuario>(dto);
            await _repository.AddAsync(_usuario);
        }

        public async Task UpdateUsuarioAsync(int UsuarioId, PerfilUsuario dto)
        {
            var existingUsuario = await _repository.GetByIdAsync(UsuarioId);
            if (existingUsuario == null)
                throw new KeyNotFoundException($"Usuario {UsuarioId} No encontrada.");

            _mapper.Map(dto, existingUsuario);
            await _repository.UpdateAsync(existingUsuario);
        }

        public async Task UpdateUserUsuarioAsync(int UsuarioId, PerfilUsuarioResponse dto)
        {
            var existingUsuario = await _repository.GetByIdAsync(UsuarioId);
            if (existingUsuario == null)
            {
                existingUsuario = new PerfilUsuario();
                _mapper.Map(dto, existingUsuario);
                await _repository.AddAsync(existingUsuario);
            }
            else
            {
                _mapper.Map(dto, existingUsuario);
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