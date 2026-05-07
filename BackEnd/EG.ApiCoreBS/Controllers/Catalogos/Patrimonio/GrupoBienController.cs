using AutoMapper;
using EG.ApiCoreBS.Services;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCoreBS.Controllers.Patrimonio
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class GrupoBienController : ControllerBase
    {
        private readonly GenericService<GrupoBien, GrupoBienDto, GrupoBienResponse> _service;
        private readonly GenericService<VwGrupoBien, GrupoBienDto, GrupoBienResponse> _serviceView;
        private readonly EGestionContext _context;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public GrupoBienController(
            GenericService<GrupoBien, GrupoBienDto, GrupoBienResponse> service,
            GenericService<VwGrupoBien, GrupoBienDto, GrupoBienResponse> serviceView,
            EGestionContext context,
            IMapper mapper,
            IUserContextService userContext)
        {
            _service = service;
            _serviceView = serviceView;
            _context = context;
            _mapper = mapper;
            _userContext = userContext;
            ConfigureService();
            ConfigureValidations();
        }

        private void ConfigureService()
        {
            _service.AddInclude(e => e.FkidFamiliaAlmaNavigation);
        }

        private void ConfigureValidations()
        {
            _service.AddValidationRule("UniqueDescripcion", async (dto) =>
            {
                return !_service.GetQueryWithIncludes()
                    .Any(x => x.Descripcion.ToLower() == dto.Descripcion.ToLower() && x.Activo);
            });

            _service.AddValidationRuleWithId("UniqueDescripcionUpdate", async (dto, id) =>
            {
                return !_service.GetQueryWithIncludes()
                    .Any(x => x.Descripcion.ToLower() == dto.Descripcion.ToLower() && x.PkidGrupoBien != id.Value && x.Activo);
            });
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<GrupoBienResponse>>> GetAll()
        {
            var result = await _serviceView.GetAllAsync();
            return Ok(new PagedResult<GrupoBienResponse>
            {
                Success = true,
                Message = "Grupos de bien obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<GrupoBienResponse>>> GetById(int id)
        {
            var result = await _serviceView.GetByIdAsync(id);
            if (result == null)
                return NotFound(new PagedResult<GrupoBienResponse> { Success = false, Message = "Grupo de bien no encontrado", Code = "NOT_FOUND" });

            return Ok(new PagedResult<GrupoBienResponse>
            {
                Success = true,
                Message = "Grupo de bien obtenido correctamente",
                Code = "SUCCESS",
                Data = result,
                Items = new List<GrupoBienResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<GrupoBienResponse>>> Create([FromBody] GrupoBienResponse response)
        {
            try
            {
                var dto = _mapper.Map<GrupoBienDto>(response);
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.UtcNow;

                await _service.CanAddAsync(dto);
                await _service.AddAsync(dto);

                var createdView = await _serviceView.GetQueryWithIncludes()
                    .FirstOrDefaultAsync(x => x.GrupoBienDescripcion == dto.Descripcion && x.Activo);

                return CreatedAtAction(nameof(GetById), new { id = createdView?.PkidGrupoBien }, 
                    new PagedResult<GrupoBienResponse>
                    {
                        Success = true,
                        Message = "Grupo de bien creado correctamente",
                        Code = "SUCCESS",
                        Items = createdView != null ? new List<GrupoBienResponse> { _mapper.Map<GrupoBienResponse>(createdView) } : new List<GrupoBienResponse>(),
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<GrupoBienResponse> { Success = false, Message = ex.Message, Code = "ERROR" });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<GrupoBienResponse>>> Update(int id, [FromBody] GrupoBienResponse response)
        {
            try
            {
                var existingView = await _serviceView.GetByIdAsync(id);
                if (existingView == null)
                    return NotFound(new PagedResult<GrupoBienResponse> { Success = false, Message = "Grupo de bien no encontrado", Code = "NOT_FOUND" });

                var dto = _mapper.Map<GrupoBienDto>(response);
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.UtcNow;

                await _service.CanUpdateAsync(id, dto);
                await _service.UpdateAsync(id, dto);

                var updatedView = await _serviceView.GetByIdAsync(id);
                return Ok(new PagedResult<GrupoBienResponse>
                {
                    Success = true,
                    Message = "Grupo de bien actualizado correctamente",
                    Code = "SUCCESS",
                    Items = updatedView != null ? new List<GrupoBienResponse> { _mapper.Map<GrupoBienResponse>(updatedView) } : new List<GrupoBienResponse>(),
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<GrupoBienResponse> { Success = false, Message = ex.Message, Code = "ERROR" });
            }
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
        {
            try
            {
                var existingView = await _serviceView.GetByIdAsync(id);
                if (existingView == null)
                    return NotFound(new PagedResult<bool> { Success = false, Message = "Grupo de bien no encontrado", Code = "NOT_FOUND" });

                await _service.DeleteAsync(id);
                return Ok(new PagedResult<bool> { Success = true, Message = "Grupo de bien eliminado correctamente", Code = "SUCCESS", Items = new List<bool> { true }, TotalCount = 1 });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<bool> { Success = false, Message = ex.Message, Code = "ERROR" });
            }
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<GrupoBienResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var query = _serviceView.GetQueryWithIncludes();

            if (!string.IsNullOrWhiteSpace(request.Filtro))
            {
                query = query.Where(e =>
                    e.GrupoBienDescripcion.Contains(request.Filtro) ||
                    e.FamiliaDescripcion.Contains(request.Filtro) ||
                    (e.GrupoBienClave.HasValue && e.GrupoBienClave.Value.ToString().Contains(request.Filtro)));
            }

            if (!string.IsNullOrEmpty(request.SortLabel))
            {
                var isAscending = string.IsNullOrEmpty(request.SortDirection) || request.SortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);
                query = request.SortLabel switch
                {
                    "PkidGrupoBien" => isAscending ? query.OrderBy(e => e.PkidGrupoBien) : query.OrderByDescending(e => e.PkidGrupoBien),
                    "GrupoBienDescripcion" => isAscending ? query.OrderBy(e => e.GrupoBienDescripcion) : query.OrderByDescending(e => e.GrupoBienDescripcion),
                    "FamiliaDescripcion" => isAscending ? query.OrderBy(e => e.FamiliaDescripcion) : query.OrderByDescending(e => e.FamiliaDescripcion),
                    _ => query.OrderBy(e => e.GrupoBienDescripcion)
                };
            }

            var totalItems = await query.CountAsync();
            var items = await query
                .Skip((request.Page - 1) * request.PageSize)
                .Take(request.PageSize)
                .ToListAsync();

            return Ok(new PagedResult<GrupoBienResponse>
            {
                Items = _mapper.Map<List<GrupoBienResponse>>(items),
                TotalCount = totalItems,
                Success = true,
                Message = "OK",
                Code = "SUCCESS"
            });
        }

        [HttpGet("GetGrupoBien")]
        public async Task<ActionResult<PagedResult<GrupoBienResponse>>> GetGrupoBien()
        {
            var items = await _context.GrupoBiens
                .Where(g => (g.Clave ?? 0) > 2000 && g.Activo)
                .OrderBy(g => g.ClaveCucop)
                .Select(g => new GrupoBienResponse
                {
                    PkidGrupoBien = g.PkidGrupoBien,
                    GrupoBienDescripcion = g.Descripcion,
                    GrupoBienClave = g.Clave,
                    ClaveAn = g.ClaveAn,
                    CabmAct = g.CabmAct,
                    ClaveCucop = g.ClaveCucop,
                    Activo = g.Activo
                })
                .ToListAsync();

            return Ok(new PagedResult<GrupoBienResponse>
            {
                Success = true,
                Message = "OK",
                Code = "SUCCESS",
                Items = items,
                TotalCount = items.Count
            });
        }

        [HttpGet("GetLookup")]
        public async Task<ActionResult<List<LookupItem>>> GetLookup()
        {
            var items = await _context.GrupoBiens
                .Where(g => (g.Clave ?? 0) > 2000 && g.Activo)
                .OrderBy(g => g.ClaveAn)
                .Select(g => new LookupItem
                {
                    Id = g.PkidGrupoBien,
                    Text = (g.ClaveAn ?? "") + " / " + (g.CabmAct ?? "") + " / " + (g.Descripcion ?? "")
                })
                .ToListAsync();
            return Ok(items);
        }
    }
}
