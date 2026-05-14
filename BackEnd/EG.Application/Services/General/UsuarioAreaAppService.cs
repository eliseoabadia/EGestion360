using Mapster;
using EG.Application.Interfaces.General;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.General;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;

namespace EG.Application.Services.General
{
    public class UsuarioAreaAppService : IUsuarioAreaAppService
    {
        private readonly IRepository<VwUsuarioPersonaArea> _repository;

        public UsuarioAreaAppService(IRepository<VwUsuarioPersonaArea> repository)
        {
            _repository = repository;
        }

        public async Task<PagedResult<UsuarioAreaResponse>> GetAllAsync(int usuarioId)
        {
            try
            {
                var entities = await _repository.GetAllWithIncludesAsync(x => x.PkIdUsuario == usuarioId);
                var result = entities.Where(e => e.PkidArea.HasValue).Adapt<List<UsuarioAreaResponse>>();
                return new PagedResult<UsuarioAreaResponse>
                {
                    Success = true,
                    Message = "Áreas del usuario obtenidas correctamente",
                    Code = "SUCCESS",
                    Items = result,
                    TotalCount = result.Count
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<UsuarioAreaResponse>
                {
                    Success = false,
                    Message = $"Error al obtener áreas: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }
    }
}
