using AutoMapper;
using EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.Configuracion.Catalogo.Presupuestales
{
    public class PgAppServices : IPgAppServices
    {
        private readonly GenericService<Pg, PgDto, PgResponse> _service;
        private readonly IMapper _mapper;

        public PgAppServices(
            GenericService<Pg, PgDto, PgResponse> service,
            IMapper mapper)
        {
            _service = service;
            _mapper = mapper;
            ConfigureValidations();
        }

        private void ConfigureValidations()
        {
            _service.AddValidationRule("UniquePg", async (dto) =>
            {
                var itemDto = dto as PgDto;
                if (itemDto == null) return true;
                return !await _service.GetQueryWithIncludes()
                    .AnyAsync(p => p.Clave == itemDto.Clave && p.Activo);
            });

            _service.AddValidationRuleWithId("UniquePgUpdate", async (dto, id) =>
            {
                var itemDto = dto as PgDto;
                if (itemDto == null || !id.HasValue) return true;
                return !await _service.GetQueryWithIncludes()
                    .AnyAsync(p => p.Clave == itemDto.Clave && p.PkidPg != id.Value && p.Activo);
            });
        }

        public async Task<IEnumerable<PgResponse>> GetAllAsync()
        {
            return await _service.GetAllAsync();
        }

        public async Task<PgResponse> GetByIdAsync(int id)
        {
            return await _service.GetByIdAsync(id, idPropertyName: "PkidPg");
        }

        public async Task<PagedResult<PgResponse>> GetAllPaginadoAsync(PagedRequest pageRequest, Func<PgResponse, bool>? predicate = null)
        {
            try
            {
                var result = await _service.GetAllPaginadoAsync(pageRequest);
                var items = result.Items.AsEnumerable();

                if (predicate != null)
                    items = items.Where(predicate);

                return new PagedResult<PgResponse>
                {
                    Success = true,
                    Message = "PGs obtenidos correctamente",
                    Code = "SUCCESS",
                    Items = items.ToList(),
                    TotalCount = result.TotalCount
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<PgResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    Items = new List<PgResponse>(),
                    TotalCount = 0
                };
            }
        }

        public async Task<PgResponse> CreateAsync(PgResponse response, int usuarioCreacion)
        {
            if (response == null)
                throw new ArgumentNullException(nameof(response), "Los datos del PG son requeridos");

            var dto = _mapper.Map<PgDto>(response);
            dto.Activo = true;
            dto.FechaCreacion = DateTime.Now;
            dto.UsuarioCreacion = usuarioCreacion;
            dto.FechaModificacion = null;
            dto.UsuarioModificacion = null;

            if (!await _service.CanAddAsync(dto))
                throw new InvalidOperationException("Ya existe un PG activo con esa clave");

            await _service.AddAsync(dto);
            return await _service.GetByIdAsync(dto.PkidPg, idPropertyName: "PkidPg");
        }

        public async Task<PgResponse> UpdateAsync(int id, PgResponse response, int usuarioModificacion)
        {
            if (response == null)
                throw new ArgumentNullException(nameof(response), "Los datos del PG son requeridos");

            if (id <= 0)
                throw new ArgumentException("ID de PG inválido", nameof(id));

            var dto = _mapper.Map<PgDto>(response);
            dto.PkidPg = id;
            dto.FechaModificacion = DateTime.Now;
            dto.UsuarioModificacion = usuarioModificacion;

            if (!await _service.CanUpdateAsync(id, dto))
                throw new InvalidOperationException("Ya existe otro PG activo con esa clave");

            await _service.UpdateAsync(id, dto);
            return await _service.GetByIdAsync(id, idPropertyName: "PkidPg");
        }

        public async Task<bool> DeleteAsync(int id, int usuarioActual)
        {
            if (id <= 0)
                throw new ArgumentException("ID de PG inválido", nameof(id));

            var entity = await _service.GetByIdAsync(id, idPropertyName: "PkidPg");
            if (entity == null)
                return false;

            var dto = _mapper.Map<PgDto>(entity);
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
                var entity = await _service.GetByIdAsync(id, idPropertyName: "PkidPg");
                return entity != null;
            }
            catch
            {
                return false;
            }
        }
    }
}
