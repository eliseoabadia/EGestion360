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
    public class ProgramaPresupuestalAppServices : IProgramaPresupuestalAppServices
    {
        private readonly GenericService<Pp, ProgramaPresupuestalDto, ProgramaPresupuestalResponse> _service;

        public ProgramaPresupuestalAppServices(
            GenericService<Pp, ProgramaPresupuestalDto, ProgramaPresupuestalResponse> service)
        {
            _service = service;
            ConfigureValidations();
        }

        private void ConfigureValidations()
        {
            _service.AddValidationRule("UniqueProgramaPresupuestal", async (dto) =>
            {
                var itemDto = dto as ProgramaPresupuestalDto;
                if (itemDto == null) return true;
                return !await _service.GetQueryWithIncludes()
                    .AnyAsync(p => p.Clave.ToLower() == itemDto.Clave.ToLower() && p.Activo);
            });

            _service.AddValidationRuleWithId("UniqueProgramaPresupuestalUpdate", async (dto, id) =>
            {
                var itemDto = dto as ProgramaPresupuestalDto;
                if (itemDto == null || !id.HasValue) return true;
                return !await _service.GetQueryWithIncludes()
                    .AnyAsync(p => p.Clave.ToLower() == itemDto.Clave.ToLower() && p.PkidPp != id.Value && p.Activo);
            });
        }

        public async Task<IEnumerable<ProgramaPresupuestalResponse>> GetAllAsync()
        {
            return await _service.GetAllAsync();
        }

        public async Task<ProgramaPresupuestalResponse> GetByIdAsync(int id)
        {
            return await _service.GetByIdAsync(id, idPropertyName: "PkidPp");
        }

        public async Task<PagedResult<ProgramaPresupuestalResponse>> GetAllPaginadoAsync(PagedRequest pageRequest, Func<ProgramaPresupuestalResponse, bool>? predicate = null)
        {
            try
            {
                var result = await _service.GetAllPaginadoAsync(pageRequest);
                var items = result.Items.AsEnumerable();

                if (predicate != null)
                    items = items.Where(predicate);

                return new PagedResult<ProgramaPresupuestalResponse>
                {
                    Success = true,
                    Message = "Programas Presupuestales obtenidos correctamente",
                    Code = "SUCCESS",
                    Items = items.ToList(),
                    TotalCount = result.TotalCount
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<ProgramaPresupuestalResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    Items = new List<ProgramaPresupuestalResponse>(),
                    TotalCount = 0
                };
            }
        }

        public async Task<ProgramaPresupuestalResponse> CreateAsync(ProgramaPresupuestalResponse response, int usuarioCreacion)
        {
            if (response == null)
                throw new ArgumentNullException(nameof(response), "Los datos del Programa Presupuestal son requeridos");

            var dto = response.Adapt<ProgramaPresupuestalDto>();
            dto.Activo = true;
            dto.FechaCreacion = DateTime.Now;
            dto.UsuarioCreacion = usuarioCreacion;
            dto.FechaModificacion = null;
            dto.UsuarioModificacion = null;

            if (!await _service.CanAddAsync(dto))
                throw new InvalidOperationException("Ya existe un Programa Presupuestal activo con esa clave");

            await _service.AddAsync(dto);
            return await _service.GetByIdAsync(dto.PkidPp, idPropertyName: "PkidPp");
        }

        public async Task<ProgramaPresupuestalResponse> UpdateAsync(int id, ProgramaPresupuestalResponse response, int usuarioModificacion)
        {
            if (response == null)
                throw new ArgumentNullException(nameof(response), "Los datos del Programa Presupuestal son requeridos");

            if (id <= 0)
                throw new ArgumentException("ID de Programa Presupuestal inválido", nameof(id));

            var dto = response.Adapt<ProgramaPresupuestalDto>();
            dto.PkidPp = id;
            dto.FechaModificacion = DateTime.Now;
            dto.UsuarioModificacion = usuarioModificacion;

            if (!await _service.CanUpdateAsync(id, dto))
                throw new InvalidOperationException("Ya existe otro Programa Presupuestal activo con esa clave");

            await _service.UpdateAsync(id, dto);
            return await _service.GetByIdAsync(id, idPropertyName: "PkidPp");
        }

        public async Task<bool> DeleteAsync(int id, int usuarioActual)
        {
            if (id <= 0)
                throw new ArgumentException("ID de Programa Presupuestal inválido", nameof(id));

            var entity = await _service.GetByIdAsync(id, idPropertyName: "PkidPp");
            if (entity == null)
                return false;

            var dto = entity.Adapt<ProgramaPresupuestalDto>();
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
                var entity = await _service.GetByIdAsync(id, idPropertyName: "PkidPp");
                return entity != null;
            }
            catch
            {
                return false;
            }
        }
    }
}
