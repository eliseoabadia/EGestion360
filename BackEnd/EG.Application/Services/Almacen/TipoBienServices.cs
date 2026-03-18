using AutoMapper;
using EG.Application.Interfaces.Almacen;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Almacen;
using EG.Domain.DTOs.Responses.Almacen;
using EG.Infraestructure.Models;

namespace EG.Application.Services.Almacen
{
    public class TipoBienAppService : ITipoBienAppService
    {
        private readonly GenericService<TipoBien, TipoBienDto, TipoBienResponse> _service;
        private readonly GenericService<VwTipoBienConteo, TipoBienDto, TipoBienResponse> _serviceView;
        private readonly IMapper _mapper;

        public TipoBienAppService(
            GenericService<TipoBien, TipoBienDto, TipoBienResponse> service,
            GenericService<VwTipoBienConteo, TipoBienDto, TipoBienResponse> serviceView,
            IMapper mapper)
        {
            _service = service;
            _serviceView = serviceView;
            _mapper = mapper;
            ConfigureService();
        }

        private void ConfigureService()
        {
            // Incluir navegaciones necesarias para operaciones de escritura
            _service.AddInclude(t => t.FkidGrupoBienAlmaNavigation);
            _service.AddInclude(t => t.FkidNivelAlmaNavigation);
            _service.AddInclude(t => t.FkidPartidaContaNavigation);
            _service.AddInclude(t => t.FkidCuentaContableContaNavigation);
            _service.AddInclude(t => t.FkidUnidadesAlmaNavigation);
            _service.AddInclude(t => t.FkidUnidadesEquivalenteNavigation);

            // Filtros para búsquedas por nombre de relaciones
            _service.AddRelationFilter("GrupoBien", new List<string> { "Descripcion" });
            _service.AddRelationFilter("Nivel", new List<string> { "Descripcion" });
            _service.AddRelationFilter("Partida", new List<string> { "Clave", "Descripcion" });
            _service.AddRelationFilter("CuentaContable", new List<string> { "CuentaCompleta", "Descripcion" });
            _service.AddRelationFilter("UnidadMedida", new List<string> { "Descripcion" });
        }

        public async Task<PagedResult<TipoBienResponse>> GetAllAsync()
        {
            var result = await _serviceView.GetAllAsync();
            return new PagedResult<TipoBienResponse>
            {
                Success = true,
                Items = result.ToList(),
                TotalCount = result.Count()
            };
        }

        public async Task<TipoBienResponse> GetByIdAsync(int id)
        {
            if (id <= 0)
                throw new ArgumentException("ID debe ser mayor a 0");

            var result = await _serviceView.GetByIdAsync(id, idPropertyName: "PkidTipoBien");

            if (result == null)
                throw new KeyNotFoundException($"Tipo de bien {id} no encontrado");

            return result;
        }

        public async Task<PagedResult<TipoBienResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            // Limpiar configuración previa y volver a aplicar
            _serviceView.ClearConfiguration();
            // No se requieren includes en la vista, pero se puede configurar algo similar si la vista tuviera relaciones
            // Por ahora, solo usamos la configuración base

            var result = await _serviceView.GetAllPaginadoAsync(request);
            return new PagedResult<TipoBienResponse>
            {
                Success = true,
                Items = result.Items,
                TotalCount = result.TotalCount
            };
        }

        public async Task<TipoBienResponse> CreateAsync(TipoBienDto dto, int usuarioActual)
        {
            if (dto == null)
                throw new ArgumentNullException(nameof(dto));

            // Asignar valores de auditoría
            dto.FechaCreacion = DateTime.Now;
            dto.UsuarioCreacion = usuarioActual;
            dto.Activo = true;

            // Validar reglas de negocio (ejemplo: código único)
            if (!await _service.CanAddAsync(dto))
                throw new InvalidOperationException("No se puede crear el tipo de bien. Verifique las validaciones.");

            await _service.AddAsync(dto);
            return await GetByIdAsync(dto.PkidTipoBien);
        }

        public async Task<TipoBienResponse> UpdateAsync(int id, TipoBienDto dto, int usuarioActual)
        {
            if (id <= 0)
                throw new ArgumentException("ID debe ser mayor a 0");
            if (dto == null)
                throw new ArgumentNullException(nameof(dto));

            dto.PkidTipoBien = id;
            dto.FechaModificacion = DateTime.Now;
            dto.UsuarioModificacion = usuarioActual;

            if (!await _service.CanUpdateAsync(id, dto))
                throw new InvalidOperationException("No se puede actualizar el tipo de bien. Verifique las validaciones.");

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