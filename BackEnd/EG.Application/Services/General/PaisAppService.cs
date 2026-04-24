using EG.Application.Interfaces.General;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.General;
using EG.Infraestructure.Models;

namespace EG.Application.Services.General
{
    public class PaisAppService : IPaisAppService
    {
        private readonly GenericService<Paise, PaiseDto> _service;

        public PaisAppService(GenericService<Paise, PaiseDto> service)
        {
            _service = service;
        }

        public async Task<PagedResult<PaiseDto>> GetAllAsync()
        {
            var result = await _service.GetAllAsync();
            return new PagedResult<PaiseDto>
            {
                Success = true,
                Message = "Países obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            };
        }

        public async Task<PaiseDto> GetByIdAsync(int id)
        {
            return await _service.GetByIdAsync(id, idPropertyName: "PkidPais");
        }

        public async Task<PaiseDto> CreateAsync(PaiseDto dto)
        {
            await _service.AddAsync(dto);
            return await _service.GetByIdAsync(dto.PkidPais, idPropertyName: "PkidPais");
        }

        public async Task<PaiseDto> UpdateAsync(int id, PaiseDto dto)
        {
            dto.PkidPais = id;
            await _service.UpdateAsync(id, dto);
            return await _service.GetByIdAsync(id, idPropertyName: "PkidPais");
        }

        public async Task<bool> DeleteAsync(int id)
        {
            await _service.DeleteAsync(id);
            return true;
        }
    }
}