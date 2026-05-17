using Mapster;
using EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.Configuracion.Catalogo.Presupuestales
{
    public class FuenteFinanciamientoAppServices : IFuenteFinanciamientoAppServices
    {
        private readonly GenericService<FuenteFinanciamiento, FuenteFinanciamientoDto, FuenteFinanciamientoResponse> _service;

        public FuenteFinanciamientoAppServices(
            GenericService<FuenteFinanciamiento, FuenteFinanciamientoDto, FuenteFinanciamientoResponse> service)
        {
            _service = service;
            ConfigureValidations();
        }

        private void ConfigureValidations()
        {
            _service.AddValidationRule("UniqueFuenteFinanciamiento", async (dto) =>
            {
                var itemDto = dto as FuenteFinanciamientoDto;
                if (itemDto == null) return true;
                return !await _service.GetQueryWithIncludes()
                    .AnyAsync(f => f.Clave.ToLower() == itemDto.Clave.ToLower() && f.Activo);
            });

            _service.AddValidationRuleWithId("UniqueFuenteFinanciamientoUpdate", async (dto, id) =>
            {
                var itemDto = dto as FuenteFinanciamientoDto;
                if (itemDto == null || !id.HasValue) return true;
                return !await _service.GetQueryWithIncludes()
                    .AnyAsync(f => f.Clave.ToLower() == itemDto.Clave.ToLower() && f.PkidFuenteFinanciamiento != id.Value && f.Activo);
            });
        }

        public async Task<IEnumerable<FuenteFinanciamientoResponse>> GetAllAsync()
        {
            return await _service.GetAllAsync();
        }

        public async Task<FuenteFinanciamientoResponse> GetByIdAsync(int id)
        {
            return await _service.GetByIdAsync(id, idPropertyName: "PkidFuenteFinanciamiento");
        }

        public async Task<PagedResult<FuenteFinanciamientoResponse>> GetAllPaginadoAsync(PagedRequest pageRequest, Func<FuenteFinanciamientoResponse, bool>? predicate = null)
        {
            try
            {
                //Hay que quitar el año, no lleva
                //if (TryGetIntFilter(pageRequest, "FkidAnioSis", out var anioId))
                //{
                //    return await GetAllPaginadoByAnioAsync(pageRequest, anioId, predicate);
                //}

                var result = await _service.GetAllPaginadoAsync(pageRequest);
                var items = result.Items.AsEnumerable();

                if (predicate != null)
                    items = items.Where(predicate);

                return new PagedResult<FuenteFinanciamientoResponse>
                {
                    Success = true,
                    Message = "Fuentes de Financiamiento obtenidas correctamente",
                    Code = "SUCCESS",
                    Items = items.ToList(),
                    TotalCount = result.TotalCount
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<FuenteFinanciamientoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    Items = new List<FuenteFinanciamientoResponse>(),
                    TotalCount = 0
                };
            }
        }

        public async Task<FuenteFinanciamientoResponse> CreateAsync(FuenteFinanciamientoResponse response, int usuarioCreacion)
        {
            if (response == null)
                throw new ArgumentNullException(nameof(response), "Los datos de la Fuente de Financiamiento son requeridos");

            var dto = response.Adapt<FuenteFinanciamientoDto>();
            dto.Activo = true;
            dto.FechaCreacion = DateTime.Now;
            dto.UsuarioCreacion = usuarioCreacion;
            dto.FechaModificacion = null;
            dto.UsuarioModificacion = null;

            if (!await _service.CanAddAsync(dto))
                throw new InvalidOperationException("Ya existe una Fuente de Financiamiento activa con esa clave");

            await _service.AddAsync(dto);
            return await _service.GetByIdAsync(dto.PkidFuenteFinanciamiento, idPropertyName: "PkidFuenteFinanciamiento");
        }

        public async Task<FuenteFinanciamientoResponse> UpdateAsync(int id, FuenteFinanciamientoResponse response, int usuarioModificacion)
        {
            if (response == null)
                throw new ArgumentNullException(nameof(response), "Los datos de la Fuente de Financiamiento son requeridos");

            if (id <= 0)
                throw new ArgumentException("ID de Fuente de Financiamiento inválido", nameof(id));

            var dto = response.Adapt<FuenteFinanciamientoDto>();
            dto.PkidFuenteFinanciamiento = id;
            dto.FechaModificacion = DateTime.Now;
            dto.UsuarioModificacion = usuarioModificacion;

            if (!await _service.CanUpdateAsync(id, dto))
                throw new InvalidOperationException("Ya existe otra Fuente de Financiamiento activa con esa clave");

            await _service.UpdateAsync(id, dto);
            return await _service.GetByIdAsync(id, idPropertyName: "PkidFuenteFinanciamiento");
        }

        public async Task<bool> DeleteAsync(int id, int usuarioActual)
        {
            if (id <= 0)
                throw new ArgumentException("ID de Fuente de Financiamiento inválido", nameof(id));

            var entity = await _service.GetByIdAsync(id, idPropertyName: "PkidFuenteFinanciamiento");
            if (entity == null)
                return false;

            var dto = entity.Adapt<FuenteFinanciamientoDto>();
            dto.Activo = false;
            dto.FechaModificacion = DateTime.Now;
            dto.UsuarioModificacion = usuarioActual;

            await _service.UpdateAsync(id, dto);
            return true;
        }

        public async Task<bool> ExistsAsync(int id)
        {
            try
            {
                var entity = await _service.GetByIdAsync(id, idPropertyName: "PkidFuenteFinanciamiento");
                return entity != null;
            }
            catch
            {
                return false;
            }
        }

    }
}
