using Mapster;
using EG.Application.Interfaces.Contabilidad;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Infraestructure.Models;

namespace EG.ApiCoreBS.Services.Contabilidad
{
    public class TipoDetallePolizaService : ITipoDetallePolizaService
    {
        private readonly GenericService<TipoDetallePoliza, TipoDetallePolizaDto, TipoDetallePolizaResponse> _service;

        public TipoDetallePolizaService(
            GenericService<TipoDetallePoliza, TipoDetallePolizaDto, TipoDetallePolizaResponse> service)
        {
            _service = service;
        }

        public async Task<IEnumerable<TipoDetallePolizaResponse>> GetAllAsync()
        {
            return await _service.GetAllAsync();
        }

        public async Task<TipoDetallePolizaResponse?> GetByIdAsync(int id)
        {
            return await _service.GetByIdAsync(id);
        }

        public async Task<TipoDetallePolizaResponse> CreateAsync(TipoDetallePolizaResponse response, int usuarioId)
        {
            var dto = response.Adapt<TipoDetallePolizaDto>();
            dto.UsuarioCreacion = usuarioId;
            dto.FechaCreacion = DateTime.Now;
            dto.Activo = true;

            if (!await _service.CanAddAsync(dto))
                throw new InvalidOperationException("Ya existe un tipo de detalle de póliza con esa descripción");

            await _service.AddAsync(dto);
            return await _service.GetByIdAsync(dto.PkidTipoDetallePoliza);
        }

        public async Task<TipoDetallePolizaResponse?> UpdateAsync(int id, TipoDetallePolizaResponse response, int usuarioId)
        {
            var dto = response.Adapt<TipoDetallePolizaDto>();
            dto.PkidTipoDetallePoliza = id;
            dto.UsuarioModificacion = usuarioId;
            dto.FechaModificacion = DateTime.Now;

            if (!await _service.CanUpdateAsync(id, dto))
                throw new InvalidOperationException("Ya existe otro tipo de detalle de póliza con esa descripción");

            await _service.UpdateAsync(id, dto);
            return await _service.GetByIdAsync(id);
        }

        public async Task DeleteAsync(int id)
        {
            var existing = await _service.GetByIdAsync(id);
            if (existing == null) throw new KeyNotFoundException($"Tipo de detalle de póliza con ID {id} no encontrado");

            await _service.DeleteAsync(id);
        }

        public async Task<PagedResult<TipoDetallePolizaResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            return await _service.GetAllPaginadoAsync(request);
        }
    }
}
