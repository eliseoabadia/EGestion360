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
    public class ProgramaAppServices : IProgramaAppServices
    {
        private readonly GenericService<Programa, ProgramaDto, ProgramaResponse> _writeService;
        private readonly GenericService<VwPrograma, ProgramaDto, ProgramaResponse> _viewService;

        public ProgramaAppServices(
            GenericService<Programa, ProgramaDto, ProgramaResponse> writeService,
            GenericService<VwPrograma, ProgramaDto, ProgramaResponse> viewService)
        {
            _writeService = writeService;
            _viewService = viewService;
            ConfigureService();
        }

        private void ConfigureService()
        {
            _writeService.ClearConfiguration();
            _writeService.AddInclude(p => p.UsuarioCreacionNavigation);
            _writeService.AddInclude(p => p.UsuarioModificacionNavigation);

            _writeService.AddRelationFilter("UsuarioCreacionNavigation", new List<string> { "Nombre", "Email" });
            _writeService.AddRelationFilter("UsuarioModificacionNavigation", new List<string> { "Nombre", "Email" });
            _writeService.AddValidationRule("UniquePrograma", dto =>
                Task.FromResult(!_writeService.GetQueryWithIncludes().Any(e => e.Clave == dto.Clave && e.Activo)));
            _writeService.AddValidationRuleWithId("UniqueProgramaUpdate", (dto, id) =>
                Task.FromResult(!_writeService.GetQueryWithIncludes().Any(e => e.Clave == dto.Clave && e.PkidPrograma != id && e.Activo)));
        }

        public async Task<IEnumerable<ProgramaResponse>> GetAllAsync()
        {
            return await _viewService.GetAllAsync();
        }

        public async Task<ProgramaResponse> GetByIdAsync(int id)
        {
            return await _viewService.GetByIdAsync(id, idPropertyName: "PkidPrograma");
        }

        public async Task<PagedResult<ProgramaResponse>> GetAllPaginadoAsync(PagedRequest pageRequest, Func<ProgramaResponse, bool>? predicate = null)
        {
            try
            {
                var result = await _viewService.GetAllPaginadoAsync(pageRequest);
                var items = result.Items.AsEnumerable();

                if (predicate != null)
                {
                    items = items.Where(predicate);
                }

                return new PagedResult<ProgramaResponse>
                {
                    Success = true,
                    Message = "Programas obtenidos correctamente",
                    Code = "SUCCESS",
                    Items = items.ToList(),
                    TotalCount = result.TotalCount
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<ProgramaResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    Items = new List<ProgramaResponse>(),
                    TotalCount = 0
                };
            }
        }

        public async Task<ProgramaResponse> CreateAsync(ProgramaResponse response, int usuarioCreacion)
        {
            if (response == null)
                throw new ArgumentNullException(nameof(response), "Los datos del programa son requeridos");

            ValidateRequiredFields(response);

            var dto = response.Adapt<ProgramaDto>();
            dto.Activo = true;
            dto.FechaCreacion = DateTime.Now;
            dto.UsuarioCreacion = usuarioCreacion;
            dto.FechaModificacion = null;
            dto.UsuarioModificacion = null;

            if (!await _writeService.CanAddAsync(dto))
                throw new InvalidOperationException("Ya existe un programa activo con esa clave.");

            await _writeService.AddAsync(dto);
            return await GetByIdAsync(dto.PkidPrograma)
                ?? await _writeService.GetByIdAsync(dto.PkidPrograma, idPropertyName: "PkidPrograma");
        }

        public async Task<ProgramaResponse> UpdateAsync(int id, ProgramaResponse response, int usuarioModificacion)
        {
            if (response == null)
                throw new ArgumentNullException(nameof(response), "Los datos del programa son requeridos");

            if (id <= 0)
                throw new ArgumentException("ID de programa inválido", nameof(id));

            ValidateRequiredFields(response);

            var existing = await _writeService.GetByIdAsync(id, idPropertyName: "PkidPrograma");
            if (existing == null)
                throw new InvalidOperationException($"Programa con ID {id} no encontrado");

            var dto = response.Adapt<ProgramaDto>();
            dto.PkidPrograma = id;
            dto.FechaCreacion = existing.FechaCreacion;
            dto.UsuarioCreacion = existing.UsuarioCreacion;
            dto.FechaModificacion = DateTime.Now;
            dto.UsuarioModificacion = usuarioModificacion;

            if (!await _writeService.CanUpdateAsync(id, dto))
                throw new InvalidOperationException("Ya existe otro programa activo con esa clave.");

            await _writeService.UpdateAsync(id, dto);
            return await GetByIdAsync(id)
                ?? await _writeService.GetByIdAsync(id, idPropertyName: "PkidPrograma");
        }

        public async Task<bool> DeleteAsync(int id, int usuarioActual)
        {
            if (id <= 0)
                throw new ArgumentException("ID de programa inválido", nameof(id));

            var programa = await _writeService.GetByIdAsync(id, idPropertyName: "PkidPrograma");
            if (programa == null)
                return false;

            var dto = programa.Adapt<ProgramaDto>();
            dto.Activo = false;
            dto.FechaModificacion = DateTime.Now;
            dto.UsuarioModificacion = usuarioActual;

            await _writeService.UpdateAsync(id, dto);
            return true;
        }

        public async Task<bool> ExistsAsync(int id)
        {
            try
            {
                var programa = await _writeService.GetByIdAsync(id, idPropertyName: "PkidPrograma");
                return programa != null;
            }
            catch
            {
                return false;
            }
        }

        private static void ValidateRequiredFields(ProgramaResponse response)
        {
            if (string.IsNullOrWhiteSpace(response.Clave))
                throw new ArgumentException("La clave es requerida", nameof(response.Clave));
            if (string.IsNullOrWhiteSpace(response.Descripcion))
                throw new ArgumentException("La descripción es requerida", nameof(response.Descripcion));
            if (response.FkidUrPres <= 0)
                throw new ArgumentException("La unidad responsable es requerida", nameof(response.FkidUrPres));
            if (response.FkidGfPres <= 0)
                throw new ArgumentException("El grupo funcional es requerido", nameof(response.FkidGfPres));
            if (response.FkidFnPres <= 0)
                throw new ArgumentException("La función es requerida", nameof(response.FkidFnPres));
            if (response.FkidSfPres <= 0)
                throw new ArgumentException("La subfunción es requerida", nameof(response.FkidSfPres));
            if (response.FkidActividadInstitucionalSis <= 0)
                throw new ArgumentException("La actividad institucional es requerida", nameof(response.FkidActividadInstitucionalSis));
        }
    }
}
