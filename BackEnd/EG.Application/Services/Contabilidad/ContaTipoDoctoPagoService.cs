using Mapster;
using EG.Application.Interfaces.Contabilidad;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Infraestructure.Models;

namespace EG.ApiCoreBS.Services.Contabilidad
{
    public class ContaTipoDoctoPagoService : IContaTipoDoctoPagoService
    {
        private readonly GenericService<TipoDoctoPago, ContaTipoDoctoPagoDto, ContaTipoDoctoPagoResponse> _service;

        public ContaTipoDoctoPagoService(
            GenericService<TipoDoctoPago, ContaTipoDoctoPagoDto, ContaTipoDoctoPagoResponse> service)
        {
            _service = service;
            ConfigureValidations();
        }

        private void ConfigureValidations()
        {
            _service.AddValidationRule("UniqueDescripcion", async (dto) =>
            {
                return !_service.GetQueryWithIncludes()
                    .Any(x => x.Descripcion.ToLower() == dto.Descripcion.ToLower() && x.Activo);
            });

            _service.AddValidationRuleWithId("UniqueDescripcionUpdate", async (dto, id) =>
            {
                return !_service.GetQueryWithIncludes()
                    .Any(x => x.Descripcion.ToLower() == dto.Descripcion.ToLower() && x.PkidTipoDoctoPago != id.Value && x.Activo);
            });
        }

        public async Task<IEnumerable<ContaTipoDoctoPagoResponse>> GetAllAsync()
        {
            return await _service.GetAllAsync();
        }

        public async Task<ContaTipoDoctoPagoResponse?> GetByIdAsync(int id)
        {
            return await _service.GetByIdAsync(id);
        }

        public async Task<ContaTipoDoctoPagoResponse> CreateAsync(ContaTipoDoctoPagoResponse response, int usuarioId)
        {
            var dto = response.Adapt<ContaTipoDoctoPagoDto>();
            dto.UsuarioCreacion = usuarioId.ToString();
            dto.FechaCreacion = DateTime.UtcNow;

            await _service.CanAddAsync(dto);
            await _service.AddAsync(dto);

            var created = _service.GetQueryWithIncludes()
                .FirstOrDefault(x => x.Descripcion == dto.Descripcion && x.Activo);

            return created.Adapt<ContaTipoDoctoPagoResponse>();
        }

        public async Task<ContaTipoDoctoPagoResponse?> UpdateAsync(int id, ContaTipoDoctoPagoResponse response, int usuarioId)
        {
            var existing = await _service.GetByIdAsync(id);
            if (existing == null) return null;

            var dto = response.Adapt<ContaTipoDoctoPagoDto>();
            dto.UsuarioCreacion = existing.UsuarioCreacion;
            dto.FechaCreacion = existing.FechaCreacion;
            dto.UsuarioModificacion = usuarioId.ToString();
            dto.FechaModificacion = DateTime.UtcNow;

            await _service.CanUpdateAsync(id, dto);
            await _service.UpdateAsync(id, dto);

            return await _service.GetByIdAsync(id);
        }

        public async Task DeleteAsync(int id)
        {
            var existing = await _service.GetByIdAsync(id);
            if (existing == null) throw new KeyNotFoundException($"Registro con ID {id} no encontrado");

            await _service.DeleteAsync(id);
        }

        public async Task<PagedResult<ContaTipoDoctoPagoResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            return await _service.GetAllPaginadoAsync(request);
        }
    }
}
