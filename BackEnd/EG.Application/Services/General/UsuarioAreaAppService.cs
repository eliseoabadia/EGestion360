using AutoMapper;
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
        private readonly IMapper _mapper;

        public UsuarioAreaAppService(IRepository<VwUsuarioPersonaArea> repository, IMapper mapper)
        {
            _repository = repository;
            _mapper = mapper;
        }

        public async Task<PagedResult<UsuarioAreaResponse>> GetAllAsync(int usuarioId)
        {
            try
            {
                var entities = await _repository.GetAllWithIncludesAsync(x => x.PkIdUsuario == usuarioId);
                var result = _mapper.Map<List<UsuarioAreaResponse>>(entities.Where(e => e.PkidArea.HasValue));
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
