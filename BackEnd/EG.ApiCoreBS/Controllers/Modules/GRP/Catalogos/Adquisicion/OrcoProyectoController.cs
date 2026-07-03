using EG.Common.GenericModel;
using EG.Application.Services.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCoreBS.Controllers.Catalogos.Adquisicion
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class OrcoProyectoController : ControllerBase
    {
        private readonly EGestionContext _context;

        public OrcoProyectoController(EGestionContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<OrcoProyectoResponse>>> GetAll()
        {
            var items = await ProjectQuery()
                .OrderBy(x => x.Descripcion)
                .ToListAsync();

            return Ok(Success(items, items.Count));
        }

        [HttpGet("{id:int}")]
        public async Task<ActionResult<PagedResult<OrcoProyectoResponse>>> GetById(int id)
        {
            var item = await ProjectQuery()
                .FirstOrDefaultAsync(x => x.PkidProyecto == id);

            if (item == null)
            {
                return NotFound(new PagedResult<OrcoProyectoResponse>
                {
                    Success = false,
                    Message = "Proyecto ORCO no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }

            return Ok(new PagedResult<OrcoProyectoResponse>
            {
                Success = true,
                Message = "Proyecto ORCO encontrado",
                Code = "SUCCESS",
                Data = item,
                Items = [item],
                TotalCount = 1
            });
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<OrcoProyectoResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var page = request.Page <= 0 ? 1 : request.Page;
            var pageSize = request.PageSize <= 0 ? 10 : request.PageSize;
            var query = ProjectQuery();

            if (!string.IsNullOrWhiteSpace(request.Filtro))
            {
                var filter = request.Filtro.Trim();
                query = query.Where(x =>
                    x.Descripcion.Contains(filter) ||
                    x.PkidProyecto.ToString().Contains(filter));
            }

            var isAscending = string.IsNullOrWhiteSpace(request.SortDirection) ||
                              request.SortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);

            query = request.SortLabel switch
            {
                "PkidProyecto" => isAscending
                    ? query.OrderBy(x => x.PkidProyecto)
                    : query.OrderByDescending(x => x.PkidProyecto),
                _ => isAscending
                    ? query.OrderBy(x => x.Descripcion)
                    : query.OrderByDescending(x => x.Descripcion)
            };

            var totalCount = await query.CountAsync();
            var items = await query
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return Ok(Success(items, totalCount));
        }

        private IQueryable<OrcoProyectoResponse> ProjectQuery()
        {
            return OrcoProyectoCatalog.ActiveProjectsQuery(_context);
        }

        private static PagedResult<OrcoProyectoResponse> Success(
            IList<OrcoProyectoResponse> items,
            int totalCount)
        {
            return new PagedResult<OrcoProyectoResponse>
            {
                Success = true,
                Message = "Proyectos ORCO obtenidos correctamente",
                Code = "SUCCESS",
                Items = items,
                TotalCount = totalCount
            };
        }
    }
}
