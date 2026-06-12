using EG.Application.Interfaces.ConteoCiclico;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;

namespace EG.Application.Services.ConteoCiclico
{
    public class PeriodoConteoAppService : IPeriodoConteoAppService
    {
        private readonly GenericService<PeriodoConteo, PeriodoConteoDto, PeriodoConteoResponse> _service;
        private readonly GenericService<VwPeriodoConteo, PeriodoConteoDto, PeriodoConteoResponse> _serviceView;

        public PeriodoConteoAppService(
            GenericService<PeriodoConteo, PeriodoConteoDto, PeriodoConteoResponse> service,
            GenericService<VwPeriodoConteo, PeriodoConteoDto, PeriodoConteoResponse> serviceView)
        {
            _service = service;
            _serviceView = serviceView;
        }

        public async Task<PagedResult<PeriodoConteoResponse>> GetAllAsync()
        {
            var result = await _serviceView.GetAllAsync();
            return new PagedResult<PeriodoConteoResponse>
            {
                Success = true,
                Message = "Períodos obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            };
        }

        public async Task<PeriodoConteoResponse> GetByIdAsync(int id)
        {
            return await _serviceView.GetByIdAsync(id, idPropertyName: "PkidPeriodoConteo");
        }

        public async Task<PeriodoConteoResponse> CreateAsync(PeriodoConteoDto dto, int usuarioActual)
        {
            dto.UsuarioCreacion = usuarioActual;
            dto.FechaCreacion = DateTime.Now;
            await _service.AddAsync(dto);
            return await _serviceView.GetByIdAsync(dto.PkidPeriodoConteo, idPropertyName: "PkidPeriodoConteo");
        }

        public async Task<PeriodoConteoResponse> UpdateAsync(int id, PeriodoConteoDto dto, int usuarioActual)
        {
            dto.PkidPeriodoConteo = id;
            dto.UsuarioModificacion = usuarioActual;
            dto.FechaModificacion = DateTime.Now;
            await _service.UpdateAsync(id, dto);
            return await _serviceView.GetByIdAsync(id, idPropertyName: "PkidPeriodoConteo");
        }

        public async Task<bool> DeleteAsync(int id)
        {
            await _service.DeleteAsync(id);
            return true;
        }

        public async Task<PagedResult<PeriodoConteoResponse>> GetAllPaginadoAsync(PagedRequest pageRequest)
        {
            var result = await _serviceView.GetAllPaginadoAsync(pageRequest);
            return new PagedResult<PeriodoConteoResponse>
            {
                Success = true,
                Message = "Períodos obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            };
        }
    }
}