using Mapster;
using Microsoft.EntityFrameworkCore;
using EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;

namespace EG.Application.Services.Configuracion.Catalogo.Presupuestales
{
    public class UnidadResponsableAppServices : IUnidadResponsableAppServices
    {
        private readonly GenericService<Area, UnidadResponsableDto, UnidadResponsableResponse> _service;
        private readonly GenericService<VwArea, UnidadResponsableDto, UnidadResponsableResponse> _serviceView;

        public UnidadResponsableAppServices(
            GenericService<Area, UnidadResponsableDto, UnidadResponsableResponse> service,
            GenericService<VwArea, UnidadResponsableDto, UnidadResponsableResponse> serviceView)
        {
            _service = service;
            _serviceView = serviceView;
            ConfigureValidations();
        }

        public async Task<IEnumerable<UnidadResponsableResponse>> GetAllAsync()
        {
            var mapped = (await _serviceView.GetAllAsync()).ToList();
            var dict = mapped.ToDictionary(m => m.PkidUnidadResponsable);

            foreach (var item in mapped)
            {
                if (item.FkidAreaSis.HasValue && dict.ContainsKey(item.FkidAreaSis.Value))
                {
                    dict[item.FkidAreaSis.Value].Children.Add(item);
                }
            }

            return mapped.Where(m => !m.FkidAreaSis.HasValue).ToList();
        }

        public async Task<UnidadResponsableResponse> GetByIdAsync(int id)
        {
            return await _serviceView.GetByIdAsync(id, idPropertyName: "PkidArea");
        }

        public async Task<PagedResult<UnidadResponsableResponse>> GetAllPaginadoAsync(PagedRequest pageRequest)
        {
            pageRequest.SortLabel = pageRequest.SortLabel switch
            {
                "PkidUnidadResponsable" => "PkidArea",
                "Descripcion" => "Nombre",
                _ => pageRequest.SortLabel
            };

            var result = await _serviceView.GetAllPaginadoAsync(pageRequest);
            result.Message = result.Success ? "OK" : result.Message;
            result.Code = result.Success ? "SUCCESS" : result.Code;
            return result;
        }

        public async Task<UnidadResponsableResponse> CreateAsync(UnidadResponsableResponse response, int usuarioCreacion)
        {
            ArgumentNullException.ThrowIfNull(response, nameof(response));

            var dto = response.Adapt<UnidadResponsableDto>();
            dto.UsuarioCreacion = usuarioCreacion;
            dto.FechaCreacion = DateTime.Now;
            dto.Activo = true;

            if (!await _service.CanAddAsync(dto))
            {
                throw new InvalidOperationException("Ya existe una Unidad Responsable activa con esa clave");
            }

            await _service.AddAsync(dto);
            return await GetByIdAsync(dto.PkidUnidadResponsable) ?? dto.Adapt<UnidadResponsableResponse>();
        }

        public async Task<UnidadResponsableResponse> UpdateAsync(int id, UnidadResponsableResponse response, int usuarioModificacion)
        {
            ArgumentNullException.ThrowIfNull(response, nameof(response));

            var existing = await _service.GetByIdAsync(id, idPropertyName: "PkidArea");
            if (existing == null)
            {
                throw new KeyNotFoundException($"Unidad Responsable con ID {id} no encontrada");
            }

            var dto = response.Adapt<UnidadResponsableDto>();
            dto.PkidUnidadResponsable = id;
            dto.UsuarioModificacion = usuarioModificacion;
            dto.FechaModificacion = DateTime.Now;

            if (!await _service.CanUpdateAsync(id, dto))
            {
                throw new InvalidOperationException("Ya existe otra Unidad Responsable activa con esa clave");
            }

            await _service.UpdateAsync(id, dto);
            return await GetByIdAsync(id) ?? dto.Adapt<UnidadResponsableResponse>();
        }

        public async Task<bool> DeleteAsync(int id, int usuarioActual)
        {
            var existing = await _service.GetByIdAsync(id, idPropertyName: "PkidArea");
            if (existing == null)
            {
                return false;
            }

            await _service.DeleteAsync(id);
            return true;
        }

        private void ConfigureValidations()
        {
            _service.AddValidationRule("UniqueClave", dto =>
                Task.FromResult(!_service.GetQueryWithIncludes()
                    .Any(entity => entity.Clave.ToLower() == dto.Clave.ToLower() && entity.Activo)));

            _service.AddValidationRuleWithId("UniqueClaveUpdate", (dto, id) =>
                Task.FromResult(!_service.GetQueryWithIncludes()
                    .Any(entity => entity.Clave.ToLower() == dto.Clave.ToLower() &&
                        entity.PkidArea != id!.Value &&
                        entity.Activo)));
        }
    }
}
