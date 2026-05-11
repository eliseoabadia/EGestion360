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
    public class ProgramaAppServices : IProgramaAppServices
    {
        private readonly GenericService<Programa, ProgramaDto, ProgramaResponse> _service;
        private readonly IMapper _mapper;

        public ProgramaAppServices(
            GenericService<Programa, ProgramaDto, ProgramaResponse> service,
            IMapper mapper)
        {
            _service = service;
            _mapper = mapper;
            ConfigureService();
            // Si se requieren validaciones adicionales, llamar a ConfigureValidations()
        }

        private void ConfigureService()
        {
            // Includes de navegación (si se necesitan para filtros o proyecciones)
            _service.AddInclude(p => p.UsuarioCreacionNavigation);
            _service.AddInclude(p => p.UsuarioModificacionNavigation);

            // Filtros de relación (para búsquedas en propiedades de navegación)
            _service.AddRelationFilter("UsuarioCreacionNavigation", new List<string> { "Nombre", "Email" });
            _service.AddRelationFilter("UsuarioModificacionNavigation", new List<string> { "Nombre", "Email" });
        }

        // Ejemplo de validaciones personalizadas (opcional)
        private void ConfigureValidations()
        {
            // Validar que Clave sea única
            _service.AddValidationRule("UniqueClave", async (dto) =>
            {
                var programaDto = dto as ProgramaDto;
                if (programaDto == null || string.IsNullOrWhiteSpace(programaDto.Clave))
                    return false;

                var exists = await _service.GetQueryWithIncludes()
                    .AnyAsync(p => p.Clave.ToLower() == programaDto.Clave.ToLower() && p.Activo);
                return !exists;
            });

            // Validar actualización: Clave única excluyendo el mismo registro
            _service.AddValidationRuleWithId("UniqueClaveUpdate", async (dto, id) =>
            {
                var programaDto = dto as ProgramaDto;
                if (programaDto == null || !id.HasValue || string.IsNullOrWhiteSpace(programaDto.Clave))
                    return true;

                var exists = await _service.GetQueryWithIncludes()
                    .AnyAsync(p => p.Clave.ToLower() == programaDto.Clave.ToLower() &&
                                   p.PkidPrograma != id.Value &&
                                   p.Activo);
                return !exists;
            });
        }

        public async Task<IEnumerable<ProgramaResponse>> GetAllAsync()
        {
            var programas = await _service.GetAllAsync();
            return _mapper.Map<IEnumerable<ProgramaResponse>>(programas);
        }

        public async Task<ProgramaResponse> GetByIdAsync(int id)
        {
            var programa = await _service.GetByIdAsync(id, idPropertyName: "PkidPrograma");
            return programa;
        }

    public async Task<PagedResult<ProgramaResponse>> GetAllPaginadoAsync(PagedRequest pageRequest, Func<ProgramaResponse, bool> predicate = null)
    {
        try
        {
            // Limpiar configuraciones previas y volver a aplicar (si es necesario)
            _service.ClearConfiguration();
            ConfigureService();

            var result = await _service.GetAllPaginadoAsync(pageRequest);
            var items = result.Items.AsEnumerable();
            
            // Aplicar filtro si se proporciona
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
            // Log error (usar tu sistema de logging)
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

        public async Task<ProgramaResponse> CreateAsync(ProgramaDto dto, int usuarioCreacion)
        {
            if (dto == null)
                throw new ArgumentNullException(nameof(dto), "Los datos del programa son requeridos");

            // Asignar valores de auditoría
            dto.Activo = true;
            dto.FechaCreacion = DateTime.Now;
            dto.UsuarioCreacion = usuarioCreacion;
            dto.FechaModificacion = null;
            dto.UsuarioModificacion = null;

            // Validar reglas de negocio (si las hay)
            if (!await _service.CanAddAsync(dto))
                throw new InvalidOperationException("No se puede crear el programa. Verifique la clave única u otras reglas.");

            await _service.AddAsync(dto);
            return await _service.GetByIdAsync(dto.PkidPrograma, idPropertyName: "PkidPrograma");
        }

        public async Task<ProgramaResponse> UpdateAsync(int id, ProgramaDto dto, int usuarioModificacion)
        {
            if (dto == null)
                throw new ArgumentNullException(nameof(dto), "Los datos del programa son requeridos");

            if (id <= 0)
                throw new ArgumentException("ID de programa inválido", nameof(id));

            // Asignar valores de auditoría
            dto.PkidPrograma = id;
            dto.FechaModificacion = DateTime.Now;
            dto.UsuarioModificacion = usuarioModificacion;

            // Validar reglas de negocio (actualización)
            if (!await _service.CanUpdateAsync(id, dto))
                throw new InvalidOperationException("No se puede actualizar el programa. Verifique la clave única u otras reglas.");

            await _service.UpdateAsync(id, dto);
            return await _service.GetByIdAsync(id, idPropertyName: "PkidPrograma");
        }

        public async Task<bool> DeleteAsync(int id, int usuarioActual)
        {
            if (id <= 0)
                throw new ArgumentException("ID de programa inválido", nameof(id));

            var programa = await _service.GetByIdAsync(id, idPropertyName: "PkidPrograma");
            if (programa == null)
                return false;

            // Soft delete (borrado lógico)
            var dto = _mapper.Map<ProgramaDto>(programa);
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
            var programa = await _service.GetByIdAsync(id, idPropertyName: "PkidPrograma");
            return programa != null;
        }
        catch
        {
            return false;
        }
    }
    }
}