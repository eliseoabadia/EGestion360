using AutoMapper;
using EG.ApiCore.Services;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCore.Controllers.ConteoCiclico;

[ApiController]
[Route("api/[controller]")]
public class ConteoDetalleController : ControllerBase
{
    private readonly GenericService<ConteoDetalle, ConteoDetalleDto, ConteoDetalleResponse> _service;
    private readonly GenericService<VwBien, BienResponse, BienResponse> _bienService;
    private readonly EGestionContext _context;
    private readonly IMapper _mapper;
    private readonly IUserContextService _userContext;

    public ConteoDetalleController(
        GenericService<ConteoDetalle, ConteoDetalleDto, ConteoDetalleResponse> service,
        GenericService<VwBien, BienResponse, BienResponse> bienService,
        EGestionContext context,
        IMapper mapper,
        IUserContextService userContext)
    {
        _service = service;
        _bienService = bienService;
        _context = context;
        _mapper = mapper;
        _userContext = userContext;
        ConfigureService();
    }

    private void ConfigureService()
    {
        // VwBien es una vista, no tiene propiedades de navegación
    }

    [HttpGet("buscar-bienes")]
    public async Task<ActionResult<PagedResult<BienResponse>>> BuscarBienes(
        [FromQuery] string? filtro,
        [FromQuery] string? tipoBienCodigo,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20)
    {
        try
        {
            var request = new PagedRequest
            {
                Page = page,
                PageSize = pageSize,
                Filtro = filtro ?? string.Empty,
                SortLabel = "Clave",
                SortDirection = "Ascending"
            };

            var result = await _bienService.GetAllPaginadoAsync(request);
            var bienes = result.Items.ToList();

            // Filtrar por TipoBien si se especifica
            if (!string.IsNullOrWhiteSpace(tipoBienCodigo))
            {
                bienes = bienes.Where(b => 
                    b.TipoBienCodigoClave?.Equals(tipoBienCodigo, StringComparison.OrdinalIgnoreCase) == true
                ).ToList();
            }

            // Filtrar por texto de búsqueda
            if (!string.IsNullOrWhiteSpace(filtro))
            {
                filtro = filtro.ToLower();
                bienes = bienes.Where(b =>
                    (b.Clave?.ToLower().Contains(filtro) ?? false) ||
                    (b.ClaveAnt?.ToLower().Contains(filtro) ?? false) ||
                    (b.Descripcion?.ToLower().Contains(filtro) ?? false) ||
                    (b.Serie?.ToLower().Contains(filtro) ?? false) ||
                    (b.Modelo?.ToLower().Contains(filtro) ?? false)
                ).ToList();
            }

            return Ok(new PagedResult<BienResponse>
            {
                Success = true,
                Message = "Bienes obtenidos correctamente",
                Code = "SUCCESS",
                Items = bienes,
                TotalCount = bienes.Count
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new PagedResult<BienResponse>
            {
                Success = false,
                Message = ex.Message,
                Code = "ERROR"
            });
        }
    }

    [HttpGet("buscar-por-codigo/{codigo}")]
    public async Task<ActionResult<PagedResult<BienResponse>>> BuscarPorCodigo(
        string codigo,
        [FromQuery] string? tipoBienCodigo = null)
    {
        try
        {
            var filtro = codigo.ToLower();
            var request = new PagedRequest
            {
                Page = 1,
                PageSize = 50,
                Filtro = string.Empty,
                SortLabel = "Clave",
                SortDirection = "Ascending"
            };

            var result = await _bienService.GetAllPaginadoAsync(request);
            var bienes = result.Items.Where(b =>
                (b.Clave?.ToLower() == filtro ||
                b.ClaveAnt?.ToLower() == filtro ||
                b.Serie?.ToLower() == filtro) &&
                (string.IsNullOrWhiteSpace(tipoBienCodigo) ||
                 b.TipoBienCodigoClave?.Equals(tipoBienCodigo, StringComparison.OrdinalIgnoreCase) == true)
            ).ToList();

            return Ok(new PagedResult<BienResponse>
            {
                Success = true,
                Message = bienes.Any() ? "Bien encontrado" : "No se encontraron bienes",
                Code = "SUCCESS",
                Items = bienes,
                TotalCount = bienes.Count
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new PagedResult<BienResponse>
            {
                Success = false,
                Message = ex.Message,
                Code = "ERROR"
            });
        }
    }

    [HttpPost("agregar-bien")]
    public async Task<ActionResult<PagedResult<ConteoDetalleResponse>>> AgregarBien([FromBody] AgregarBienConteoDto dto)
    {
        try
        {
            var conteoDetalle = new ConteoDetalle
            {
                FkidConteoAlma = dto.FkidConteoAlma,
                FkidNumeroConteoAlma = dto.FkidNumeroConteoAlma,
                FkidPersonaNom = dto.FkidPersonaNom,
                Cantidad = dto.Cantidad,
                Fecha = DateTime.Now,
                Activo = true,
                UsuarioCreacion = _userContext.GetCurrentUserId(),
                FechaCreacion = DateTime.Now
            };

            _context.ConteoDetalles.Add(conteoDetalle);
            await _context.SaveChangesAsync();

            return Ok(new PagedResult<ConteoDetalleResponse>
            {
                Success = true,
                Message = "Bien agregado al conteo correctamente",
                Code = "SUCCESS",
                TotalCount = 1
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new PagedResult<ConteoDetalleResponse>
            {
                Success = false,
                Message = $"Error al agregar bien: {ex.Message}",
                Code = "ERROR"
            });
        }
    }

    [HttpGet("por-conteo/{conteoId}")]
    public async Task<ActionResult<PagedResult<ConteoDetalleResponse>>> GetPorConteo(int conteoId)
    {
        try
        {
            var detalles = await _context.ConteoDetalles
                .Where(d => d.FkidConteoAlma == conteoId)
                .Include(d => d.FkidPersonaNomNavigation)
                .ToListAsync();

            var response = detalles.Select(d => new ConteoDetalleResponse
            {
                PkidDetalleConteo = d.PkidDetalleConteo,
                FkidConteoAlma = d.FkidConteoAlma,
                FkidNumeroConteoAlma = d.FkidNumeroConteoAlma,
                FkidPersonaNom = d.FkidPersonaNom,
                PersonaNombre = d.FkidPersonaNomNavigation != null 
                    ? $"{d.FkidPersonaNomNavigation.Nombre} {d.FkidPersonaNomNavigation.Paterno} {d.FkidPersonaNomNavigation.Materno}".Trim()
                    : null,
                Cantidad = d.Cantidad,
                Fecha = d.Fecha,
                Activo = d.Activo,
                FechaCreacion = d.FechaCreacion,
                UsuarioCreacion = d.UsuarioCreacion,
                FechaModificacion = d.FechaModificacion,
                UsuarioModificacion = d.UsuarioModificacion
            });

            return Ok(new PagedResult<ConteoDetalleResponse>
            {
                Success = true,
                Message = "Detalles obtenidos correctamente",
                Code = "SUCCESS",
                Items = response.ToList(),
                TotalCount = response.Count()
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new PagedResult<ConteoDetalleResponse>
            {
                Success = false,
                Message = ex.Message,
                Code = "ERROR"
            });
        }
    }

    [HttpPut("{id}/cantidad")]
    public async Task<ActionResult<PagedResult<ConteoDetalleResponse>>> ActualizarCantidad(int id, [FromBody] decimal cantidad)
    {
        try
        {
            var detalle = await _context.ConteoDetalles.FindAsync(id);
            if (detalle == null)
            {
                return NotFound(new PagedResult<ConteoDetalleResponse>
                {
                    Success = false,
                    Message = "Detalle no encontrado",
                    Code = "NOT_FOUND"
                });
            }

            detalle.Cantidad = cantidad;
            detalle.FechaModificacion = DateTime.Now;
            detalle.UsuarioModificacion = _userContext.GetCurrentUserId();

            await _context.SaveChangesAsync();

            return Ok(new PagedResult<ConteoDetalleResponse>
            {
                Success = true,
                Message = "Cantidad actualizada correctamente",
                Code = "SUCCESS",
                TotalCount = 1
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new PagedResult<ConteoDetalleResponse>
            {
                Success = false,
                Message = ex.Message,
                Code = "ERROR"
            });
        }
    }

    [HttpDelete("{id}")]
    public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
    {
        try
        {
            var detalle = await _context.ConteoDetalles.FindAsync(id);
            if (detalle == null)
            {
                return NotFound(new PagedResult<bool>
                {
                    Success = false,
                    Message = "Detalle no encontrado",
                    Code = "NOT_FOUND"
                });
            }

            _context.ConteoDetalles.Remove(detalle);
            await _context.SaveChangesAsync();

            return Ok(new PagedResult<bool>
            {
                Success = true,
                Message = "Detalle eliminado correctamente",
                Code = "SUCCESS",
                Data = true,
                Items = new List<bool> { true },
                TotalCount = 1
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new PagedResult<bool>
            {
                Success = false,
                Message = ex.Message,
                Code = "ERROR"
            });
        }
    }
}
