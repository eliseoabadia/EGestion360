using AutoMapper;
using EG.Application.Interfaces.ConteoCiclico;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;

namespace EG.Application.Services.ConteoCiclico
{
    public class TipoBienService : ITipoBienService
    {
        private readonly GenericService<TipoBien, TipoBienDto, TipoBienResponse> _service;
        private readonly GenericService<VwTipoBienConteo, TipoBienDto, TipoBienResponse> _viewService;
        private readonly IMapper _mapper;

        public TipoBienService(
            GenericService<TipoBien, TipoBienDto, TipoBienResponse> service,
            GenericService<VwTipoBienConteo, TipoBienDto, TipoBienResponse> viewService,
            IMapper mapper)
        {
            _service = service;
            _viewService = viewService;
            _mapper = mapper;
            ConfigureService();
        }

        private void ConfigureService()
        {
            _service.AddInclude(t => t.FkidUnidadesAlmaNavigation);
            _service.AddInclude(t => t.FkidUnidadesEquivalenteNavigation);
            _service.AddInclude(t => t.FkidGrupoBienAlmaNavigation);
            _service.AddInclude(t => t.FkidNivelAlmaNavigation);
            _service.AddInclude(t => t.FkidPartidaContaNavigation);
            _service.AddInclude(t => t.FkidCuentaContableContaNavigation);

            _service.AddRelationFilter("Codigo", new List<string> { "CodigoClave" });
            _service.AddRelationFilter("Descripcion", new List<string> { "Descripcion" });
            _service.AddRelationFilter("Cabms", new List<string> { "Cabms" });
            _service.AddRelationFilter("Cucop", new List<string> { "CucopPlus" });
        }

        public async Task<PagedResult<TipoBienResponse>> GetAllPagedAsync(int page, int pageSize, string search = null, string sortColumn = null, string sortOrder = "asc")
        {
            try
            {
                var pagedRequest = new PagedRequest
                {
                    Page = page,
                    PageSize = pageSize,
                    Filtro = search ?? string.Empty,
                    SortLabel = sortColumn ?? "CodigoClave",
                    SortDirection = sortOrder.ToLower() == "desc" ? "Descending" : "Ascending"
                };

                var result = await _service.GetAllPaginadoAsync(pagedRequest);

                return new PagedResult<TipoBienResponse>
                {
                    Success = true,
                    Message = "Lista obtenida",
                    Code = "SUCCESS",
                    Items = result.Items,
                    TotalCount = result.TotalCount
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<TipoBienResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<TipoBienResponse> GetByIdAsync(int id)
        {
            try
            {
                return await _service.GetByIdAsync(id);
            }
            catch
            {
                return null;
            }
        }

        public async Task<TipoBienResponse> CreateAsync(TipoBienDto dto, int usuarioId)
        {
            if (dto == null)
                throw new ArgumentNullException(nameof(dto), "Los datos del tipo bien son requeridos");

            dto.FechaCreacion = DateTime.Now;
            dto.UsuarioCreacion = usuarioId;
            dto.Activo = true;

            await _service.AddAsync(dto);
            return await GetByIdAsync(dto.PkidTipoBien);
        }

        public async Task<TipoBienResponse> UpdateAsync(int id, TipoBienDto dto, int usuarioId)
        {
            if (dto == null)
                throw new ArgumentNullException(nameof(dto), "Los datos del tipo bien son requeridos");
            if (id <= 0)
                throw new ArgumentException("ID inválido", nameof(id));

            var existing = await _service.GetByIdAsync(id);
            if (existing == null)
                throw new InvalidOperationException("Tipo bien no encontrado");

            dto.PkidTipoBien = id;
            dto.FechaModificacion = DateTime.Now;
            dto.UsuarioModificacion = usuarioId;

            await _service.UpdateAsync(id, dto);
            return await GetByIdAsync(id);
        }

        public async Task<bool> DeleteAsync(int id, int usuarioId)
        {
            if (id <= 0)
                throw new ArgumentException("ID inválido", nameof(id));

            var existing = await _service.GetByIdAsync(id);
            if (existing == null)
                throw new InvalidOperationException("Tipo bien no encontrado");

            var dto = _mapper.Map<TipoBienDto>(existing);
            dto.Activo = false;
            dto.FechaModificacion = DateTime.Now;
            dto.UsuarioModificacion = usuarioId;

            await _service.UpdateAsync(id, dto);
            return true;
        }

        public async Task<PagedResult<TipoBienResponse>> GetFromViewPagedAsync(int page, int pageSize, string search = null, string sortColumn = null, string sortOrder = "asc")
        {
            try
            {
                var pagedRequest = new PagedRequest
                {
                    Page = page,
                    PageSize = pageSize,
                    Filtro = search ?? string.Empty,
                    SortLabel = sortColumn ?? "CodigoArticulo",
                    SortDirection = sortOrder.ToLower() == "desc" ? "Descending" : "Ascending"
                };

                var result = await _viewService.GetAllPaginadoAsync(pagedRequest);

                return new PagedResult<TipoBienResponse>
                {
                    Success = true,
                    Message = "Lista de vista obtenida",
                    Code = "SUCCESS",
                    Items = result.Items,
                    TotalCount = result.TotalCount
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<TipoBienResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }
    }
}