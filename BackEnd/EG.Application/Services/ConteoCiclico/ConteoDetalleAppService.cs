using AutoMapper;
using EG.Application.Interfaces.ConteoCiclico;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;

namespace EG.Application.Services.ConteoCiclico
{
    public class ConteoDetalleAppService : IConteoDetalleAppService
    {
        private readonly GenericService<ConteoDetalle, ConteoDetalleDto, ConteoDetalleResponse> _service;
        private readonly GenericService<VwBien, BienResponse, BienResponse> _bienService;
        private readonly IMapper _mapper;

        public ConteoDetalleAppService(
            GenericService<ConteoDetalle, ConteoDetalleDto, ConteoDetalleResponse> service,
            GenericService<VwBien, BienResponse, BienResponse> bienService,
            IMapper mapper)
        {
            _service = service;
            _bienService = bienService;
            _mapper = mapper;
        }

        public async Task<PagedResult<ConteoDetalleResponse>> GetAllAsync()
        {
            var result = await _service.GetAllAsync();
            return new PagedResult<ConteoDetalleResponse>
            {
                Success = true,
                Message = "Detalles obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            };
        }

        public async Task<ConteoDetalleResponse> GetByIdAsync(int id)
        {
            return await _service.GetByIdAsync(id, idPropertyName: "PkidDetalleConteo");
        }

        public async Task<ConteoDetalleResponse> CreateAsync(ConteoDetalleDto dto, int usuarioActual)
        {
            dto.UsuarioCreacion = usuarioActual;
            dto.FechaCreacion = DateTime.Now;
            await _service.AddAsync(dto);
            return await _service.GetByIdAsync(dto.PkidDetalleConteo, idPropertyName: "PkidDetalleConteo");
        }

        public async Task<ConteoDetalleResponse> UpdateAsync(int id, ConteoDetalleDto dto, int usuarioActual)
        {
            dto.PkidDetalleConteo = id;
            dto.UsuarioModificacion = usuarioActual;
            dto.FechaModificacion = DateTime.Now;
            await _service.UpdateAsync(id, dto);
            return await _service.GetByIdAsync(id, idPropertyName: "PkidDetalleConteo");
        }

        public async Task<bool> DeleteAsync(int id)
        {
            await _service.DeleteAsync(id);
            return true;
        }
    }
}