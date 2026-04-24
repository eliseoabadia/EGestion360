using AutoMapper;
using EG.Application.Interfaces.Almacen;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Almacen;
using EG.Domain.DTOs.Responses.Almacen;
using EG.Infraestructure.Models;

namespace EG.Application.Services.Almacen
{
    public class UnidadAppService : IUnidadAppService
    {
        private readonly GenericService<Unidade, UnidadDto, UnidadResponse> _service;
        private readonly GenericService<Unidade, UnidadDto, UnidadResponse> _serviceView;
        private readonly IMapper _mapper;

        public UnidadAppService(
            GenericService<Unidade, UnidadDto, UnidadResponse> service,
            GenericService<Unidade, UnidadDto, UnidadResponse> serviceView,
            IMapper mapper)
        {
            _service = service;
            _serviceView = serviceView;
            _mapper = mapper;
        }

        public async Task<PagedResult<UnidadResponse>> GetAllAsync()
        {
            var result = await _serviceView.GetAllAsync();
            return new PagedResult<UnidadResponse>
            {
                Success = true,
                Message = "Unidades obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            };
        }

        public async Task<UnidadResponse> GetByIdAsync(int id)
        {
            return await _serviceView.GetByIdAsync(id, idPropertyName: "PkidUnidades");
        }

        public async Task<UnidadResponse> CreateAsync(UnidadDto dto, int usuarioActual)
        {
            dto.UsuarioCreacion = usuarioActual;
            dto.FechaCreacion = DateTime.Now;
            await _service.AddAsync(dto);
            return await _serviceView.GetByIdAsync(dto.PkidUnidades, idPropertyName: "PkidUnidades");
        }

        public async Task<UnidadResponse> UpdateAsync(int id, UnidadDto dto, int usuarioActual)
        {
            dto.PkidUnidades = id;
            dto.UsuarioModificacion = usuarioActual;
            dto.FechaModificacion = DateTime.Now;
            await _service.UpdateAsync(id, dto);
            return await _serviceView.GetByIdAsync(id, idPropertyName: "PkidUnidades");
        }

        public async Task<bool> DeleteAsync(int id)
        {
            await _service.DeleteAsync(id);
            return true;
        }

        public async Task<PagedResult<UnidadResponse>> GetAllPaginadoAsync(PagedRequest pageRequest)
        {
            var result = await _serviceView.GetAllPaginadoAsync(pageRequest);
            return new PagedResult<UnidadResponse>
            {
                Success = true,
                Message = "Unidades obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            };
        }
    }
}