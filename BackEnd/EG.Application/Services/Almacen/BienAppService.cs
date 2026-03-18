using AutoMapper;
using EG.Application.Interfaces.Almacen;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Almacen;
using EG.Domain.DTOs.Responses.Almacen;
using EG.Infraestructure.Models;

namespace EG.Application.Services.Almacen
{
    public class BienAppService : IBienAppService
    {
        private readonly GenericService<Bien, BienDto, BienResponse> _service;
        private readonly GenericService<VwBien, BienDto, BienResponse> _serviceView;
        private readonly IMapper _mapper;

        public BienAppService(
            GenericService<Bien, BienDto, BienResponse> service,
            GenericService<VwBien, BienDto, BienResponse> serviceView,
            IMapper mapper)
        {
            _service = service;
            _serviceView = serviceView;
            _mapper = mapper;
            ConfigureService();
        }

        private void ConfigureService()
        {
            // Incluir todas las navegaciones necesarias para operaciones de escritura
            _service.AddInclude(b => b.FkidGrupoBienAlmaNavigation);
            _service.AddInclude(b => b.FkidTipoBienAlmaNavigation);
            _service.AddInclude(b => b.FkidAreaSisNavigation);
            _service.AddInclude(b => b.FkidProveedorSisNavigation);
            _service.AddInclude(b => b.FkidEstadoBienAlmaNavigation);
            _service.AddInclude(b => b.FkidTipoPatrimonioAlmaNavigation);
            _service.AddInclude(b => b.FkidMarcaAlmaNavigation);
            _service.AddInclude(b => b.FkidMaterialAlmaNavigation);
            _service.AddInclude(b => b.FkidTipoAdqAlmaNavigation);
            _service.AddInclude(b => b.FkidPartidaContaNavigation);

            // Filtros para búsquedas por nombre de relaciones
            _service.AddRelationFilter("GrupoBien", new List<string> { "Descripcion" });
            _service.AddRelationFilter("TipoBien", new List<string> { "CodigoClave", "Descripcion" });
            _service.AddRelationFilter("Area", new List<string> { "Nombre", "Clave" });
            _service.AddRelationFilter("Proveedor", new List<string> { "Nombre", "Rfc", "Clave" });
            _service.AddRelationFilter("EstadoBien", new List<string> { "DescripcionGeneral", "DescripcionEspecifica", "DescripcionCorta" });
            _service.AddRelationFilter("TipoPatrimonio", new List<string> { "Descripcion" });
            _service.AddRelationFilter("Marca", new List<string> { "Descripcion" });
            _service.AddRelationFilter("Material", new List<string> { "Descripcion" });
            _service.AddRelationFilter("TipoAdquisicion", new List<string> { "Clave", "Descripcion", "DescripcionMovto" });
            _service.AddRelationFilter("Partida", new List<string> { "Clave", "Descripcion" });
        }

        public async Task<PagedResult<BienResponse>> GetAllAsync()
        {
            var result = await _serviceView.GetAllAsync();
            return new PagedResult<BienResponse>
            {
                Success = true,
                Items = result.ToList(),
                TotalCount = result.Count()
            };
        }

        public async Task<BienResponse> GetByIdAsync(int id)
        {
            if (id <= 0)
                throw new ArgumentException("ID debe ser mayor a 0");

            var result = await _serviceView.GetByIdAsync(id, idPropertyName: "PkidBien");

            if (result == null)
                throw new KeyNotFoundException($"Bien {id} no encontrado");

            return result;
        }

        public async Task<PagedResult<BienResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            // Limpiar configuración previa y volver a aplicar (si la vista necesita configuración)
            _serviceView.ClearConfiguration();
            // Si la vista no necesita includes, no se llama a ConfigureService() aquí.
            // Pero si se requieren filtros de relación en la vista, habría que configurarla.
            // Por ahora dejamos sin configuración adicional.

            var result = await _serviceView.GetAllPaginadoAsync(request);
            return new PagedResult<BienResponse>
            {
                Success = true,
                Items = result.Items,
                TotalCount = result.TotalCount
            };
        }

        public async Task<BienResponse> CreateAsync(BienDto dto, int usuarioActual)
        {
            if (dto == null)
                throw new ArgumentNullException(nameof(dto));

            // Asignar valores de auditoría
            dto.FechaCreacion = DateTime.Now;
            dto.UsuarioCreacion = usuarioActual;
            dto.Activo = true;

            // Validar reglas de negocio (ejemplo: clave única)
            if (!await _service.CanAddAsync(dto))
                throw new InvalidOperationException("No se puede crear el bien. Verifique las validaciones.");

            await _service.AddAsync(dto);
            return await GetByIdAsync(dto.PkidBien);
        }

        public async Task<BienResponse> UpdateAsync(int id, BienDto dto, int usuarioActual)
        {
            if (id <= 0)
                throw new ArgumentException("ID debe ser mayor a 0");
            if (dto == null)
                throw new ArgumentNullException(nameof(dto));

            dto.PkidBien = id;
            dto.FechaModificacion = DateTime.Now;
            dto.UsuarioModificacion = usuarioActual;

            if (!await _service.CanUpdateAsync(id, dto))
                throw new InvalidOperationException("No se puede actualizar el bien. Verifique las validaciones.");

            await _service.UpdateAsync(id, dto);
            return await GetByIdAsync(id);
        }

        public async Task DeleteAsync(int id)
        {
            if (id <= 0)
                throw new ArgumentException("ID debe ser mayor a 0");

            await _service.DeleteAsync(id);
        }
    }
}