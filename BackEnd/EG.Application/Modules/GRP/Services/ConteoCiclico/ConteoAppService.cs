using EG.Application.Interfaces.ConteoCiclico;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;

namespace EG.Application.Services.ConteoCiclico
{
    public class ConteoAppService : IConteoAppService
    {
        private readonly GenericService<Conteo, ConteoDto, ConteoResponse> _service;
        private readonly GenericService<VwConteo, ConteoDto, ConteoResponse> _serviceView;

        public ConteoAppService(
            GenericService<Conteo, ConteoDto, ConteoResponse> service,
            GenericService<VwConteo, ConteoDto, ConteoResponse> serviceView)
        {
            _service = service;
            _serviceView = serviceView;
        }

        public async Task<PagedResult<ConteoResponse>> GetAllAsync()
        {
            var result = await _serviceView.GetAllAsync();
            return new PagedResult<ConteoResponse>
            {
                Success = true,
                Message = "Conteos obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            };
        }

        public async Task<ConteoResponse> GetByIdAsync(int id)
        {
            return await _serviceView.GetByIdAsync(id, idPropertyName: "PkidConteo");
        }

        public async Task<ConteoResponse> CreateAsync(ConteoDto dto, int usuarioActual)
        {
            dto.UsuarioCreacion = usuarioActual;
            dto.FechaCreacion = DateTime.Now;
            await _service.AddAsync(dto);
            return await _serviceView.GetByIdAsync(dto.PkidConteo, idPropertyName: "PkidConteo")
                ?? MapFromDto(dto);
        }

        public async Task<ConteoResponse> UpdateAsync(int id, ConteoDto dto, int usuarioActual)
        {
            var existing = await _service.GetByIdAsync(id);
            if (existing == null)
            {
                throw new KeyNotFoundException($"Conteo con ID {id} no encontrado.");
            }

            dto.PkidConteo = id;
            dto.UsuarioCreacion = existing.UsuarioCreacion;
            dto.FechaCreacion = existing.FechaCreacion;
            dto.UsuarioModificacion = usuarioActual;
            dto.FechaModificacion = DateTime.Now;
            await _service.UpdateAsync(id, dto);
            return await _serviceView.GetByIdAsync(id, idPropertyName: "PkidConteo")
                ?? MapFromDto(dto);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            await _service.DeleteAsync(id);
            return true;
        }

        public async Task<PagedResult<ConteoResponse>> GetAllPaginadoAsync(PagedRequest pageRequest)
        {
            var result = await _serviceView.GetAllPaginadoAsync(pageRequest);
            return new PagedResult<ConteoResponse>
            {
                Success = true,
                Message = "Conteos obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            };
        }

        private static ConteoResponse MapFromDto(ConteoDto dto) => new()
        {
            PkidConteo = dto.PkidConteo,
            IdTipoBien = dto.FkidTipoBienAlma,
            IdPeriodoConteo = dto.FkidPeriodoConteoAlma,
            CantidadInventario = dto.CantidadInventario,
            Descripcion = dto.Descripcion,
            FechaInicio = dto.FechaInicio,
            FechaFin = dto.FechaFin,
            Activo = dto.Activo,
            FechaCreacion = dto.FechaCreacion,
            UsuarioCreacion = dto.UsuarioCreacion,
            FechaModificacion = dto.FechaModificacion,
            UsuarioModificacion = dto.UsuarioModificacion
        };
    }
}
