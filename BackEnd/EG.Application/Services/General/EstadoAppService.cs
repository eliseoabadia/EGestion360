using AutoMapper;
using EG.Application.Interfaces.General;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.General;
using EG.Infraestructure.Models;

namespace EG.Application.Services.General
{
    public class EstadoAppService : IEstadoAppService
    {
        private readonly GenericService<Estado, EstadoDto, EstadoResponse> _service;
        private readonly IMapper _mapper;

        public EstadoAppService(
            GenericService<Estado, EstadoDto, EstadoResponse> service,
            IMapper mapper)
        {
            _service = service;
            _mapper = mapper;
        }

        public async Task<PagedResult<EstadoResponse>> GetAllAsync()
        {
            var result = await _service.GetAllAsync();
            return new PagedResult<EstadoResponse>
            {
                Success = true,
                Message = "Estados obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            };
        }

        public async Task<EstadoResponse> GetByIdAsync(int id)
        {
            return await _service.GetByIdAsync(id, idPropertyName: "PkidEstado");
        }

        public async Task<EstadoResponse> CreateAsync(EstadoDto dto, int usuarioActual)
        {
            dto.UsuarioCreacion = usuarioActual;
            dto.FechaCreacion = DateTime.Now;
            await _service.AddAsync(dto);
            return await _service.GetByIdAsync(dto.PkidEstado, idPropertyName: "PkidEstado");
        }

        public async Task<EstadoResponse> UpdateAsync(int id, EstadoDto dto, int usuarioActual)
        {
            dto.PkidEstado = id;
            dto.UsuarioModificacion = usuarioActual;
            dto.FechaModificacion = DateTime.Now;
            await _service.UpdateAsync(id, dto);
            return await _service.GetByIdAsync(id, idPropertyName: "PkidEstado");
        }

        public async Task<bool> DeleteAsync(int id)
        {
            await _service.DeleteAsync(id);
            return true;
        }
    }
}