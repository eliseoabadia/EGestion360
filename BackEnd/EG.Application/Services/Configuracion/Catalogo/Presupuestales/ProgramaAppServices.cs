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
        private readonly GenericService<Programa, ProgramaDto, ProgramaResponse> _service;

        public ProgramaAppServices(
            GenericService<Programa, ProgramaDto, ProgramaResponse> service)
        {
            _service = service;
            ConfigureService();
        }

        private void ConfigureService()
        {
            _service.AddInclude(p => p.UsuarioCreacionNavigation);
            _service.AddInclude(p => p.UsuarioModificacionNavigation);

            _service.AddRelationFilter("UsuarioCreacionNavigation", new List<string> { "Nombre", "Email" });
            _service.AddRelationFilter("UsuarioModificacionNavigation", new List<string> { "Nombre", "Email" });
        }

        public async Task<IEnumerable<ProgramaResponse>> GetAllAsync()
        {
            return await _service.GetAllAsync();
        }

        public async Task<ProgramaResponse> GetByIdAsync(int id)
        {
            return await _service.GetByIdAsync(id, idPropertyName: "PkidPrograma");
        }

        public async Task<PagedResult<ProgramaResponse>> GetAllPaginadoAsync(PagedRequest pageRequest, Func<ProgramaResponse, bool>? predicate = null)
        {
            try
            {
                _service.ClearConfiguration();
                ConfigureService();

                var result = await _service.GetAllPaginadoAsync(pageRequest);
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

            var dto = response.Adapt<ProgramaDto>();
            dto.Activo = true;
            dto.FechaCreacion = DateTime.Now;
            dto.UsuarioCreacion = usuarioCreacion;
            dto.FechaModificacion = null;
            dto.UsuarioModificacion = null;

            if (!await _service.CanAddAsync(dto))
                throw new InvalidOperationException("No se puede crear el programa. Verifique la clave única u otras reglas.");

            await _service.AddAsync(dto);
            return await _service.GetByIdAsync(dto.PkidPrograma, idPropertyName: "PkidPrograma");
        }

        public async Task<ProgramaResponse> UpdateAsync(int id, ProgramaResponse response, int usuarioModificacion)
        {
            if (response == null)
                throw new ArgumentNullException(nameof(response), "Los datos del programa son requeridos");

            if (id <= 0)
                throw new ArgumentException("ID de programa inválido", nameof(id));

            var dto = response.Adapt<ProgramaDto>();
            dto.PkidPrograma = id;
            dto.FechaModificacion = DateTime.Now;
            dto.UsuarioModificacion = usuarioModificacion;

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

            var dto = programa.Adapt<ProgramaDto>();
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
