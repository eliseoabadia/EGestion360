using AutoMapper;
using EG.ApiCore.Services;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCore.Controllers.ConteoCiclico;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ConteoController : ControllerBase
{
    private readonly GenericService<Conteo, ConteoDto, ConteoResponse> _service;
    private readonly GenericService<VwConteo, ConteoDto, ConteoResponse> _serviceView;
    private readonly GenericService<VwConteoDetalleEscaneo, ConteoDto, ConteoDetalleEscaneoResponse> _serviceEscaneo;
    private readonly IMapper _mapper;
    private readonly IUserContextService _userContext;

    public ConteoController(
        GenericService<Conteo, ConteoDto, ConteoResponse> service,
        GenericService<VwConteo, ConteoDto, ConteoResponse> serviceView,
        GenericService<VwConteoDetalleEscaneo, ConteoDto, ConteoDetalleEscaneoResponse> serviceEscaneo,
        IMapper mapper,
        IUserContextService userContext)
    {
        _service = service;
        _serviceView = serviceView;
        _serviceEscaneo = serviceEscaneo;
        _mapper = mapper;
        _userContext = userContext;
        ConfigureService();
    }

    private void ConfigureService()
    {
        // VwConteo es una vista, las relaciones ya están resueltas
        // Filtro por periodo si se pasa como parámetro
    }

    [HttpGet]
    public async Task<ActionResult<PagedResult<ConteoResponse>>> GetAll()
    {
        var result = await _serviceView.GetAllAsync();
        return Ok(new PagedResult<ConteoResponse>
        {
            Success = true,
            Message = "Conteos obtenidos correctamente",
            Code = "SUCCESS",
            Items = result.ToList(),
            TotalCount = result.Count()
        });
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<PagedResult<ConteoResponse>>> GetById(int id)
    {
        try
        {
            var result = await _serviceView.GetByIdAsync(id, idPropertyName: "PkidConteo");
            if (result == null)
            {
                return NotFound(new PagedResult<ConteoResponse>
                {
                    Success = false,
                    Message = "Conteo no encontrado",
                    Code = "NOT_FOUND"
                });
            }

            return Ok(new PagedResult<ConteoResponse>
            {
                Success = true,
                Message = "Conteo encontrado",
                Code = "SUCCESS",
                Data = result,
                Items = new List<ConteoResponse> { result },
                TotalCount = 1
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new PagedResult<ConteoResponse>
            {
                Success = false,
                Message = ex.Message,
                Code = "ERROR"
            });
        }
    }

    [HttpPost("GetAllPaginado")]
    public async Task<ActionResult<PagedResult<ConteoResponse>>> GetAllPaginado([FromBody] PagedRequest pageRequest)
    {
        try
        {
            var result = await _serviceView.GetAllPaginadoAsync(pageRequest);
            return Ok(new PagedResult<ConteoResponse>
            {
                Success = true,
                Message = "Conteos obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new PagedResult<ConteoResponse>
            {
                Success = false,
                Message = ex.Message,
                Code = "ERROR"
            });
        }
    }

    /// <summary>
    /// Obtiene los escaneos (lecturas) paginados, opcionalmente filtrados por conteo
    /// </summary>
    [HttpPost("GetEscaneosPaginado")]
    public async Task<ActionResult<PagedResult<ConteoDetalleEscaneoResponse>>> GetEscaneosPaginado([FromBody] PagedRequest pageRequest)
    {
        try
        {
            var result = await _serviceEscaneo.GetAllPaginadoAsync(pageRequest);
            return Ok(new PagedResult<ConteoDetalleEscaneoResponse>
            {
                Success = true,
                Message = "Escaneos obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new PagedResult<ConteoDetalleEscaneoResponse>
            {
                Success = false,
                Message = ex.Message,
                Code = "ERROR"
            });
        }
    }

    /// <summary>
    /// Obtiene los escaneos de un conteo específico
    /// </summary>
    [HttpGet("{id}/Escaneos")]
    public async Task<ActionResult<PagedResult<ConteoDetalleEscaneoResponse>>> GetEscaneosByConteo(int id)
    {
        try
        {
            var all = await _serviceEscaneo.GetAllAsync();
            var filtered = all.Where(e => e.FkidConteoAlma == id).ToList();

            return Ok(new PagedResult<ConteoDetalleEscaneoResponse>
            {
                Success = true,
                Message = "Escaneos del conteo obtenidos correctamente",
                Code = "SUCCESS",
                Items = filtered,
                TotalCount = filtered.Count
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new PagedResult<ConteoDetalleEscaneoResponse>
            {
                Success = false,
                Message = ex.Message,
                Code = "ERROR"
            });
        }
    }

    [HttpPost]
    public async Task<ActionResult<PagedResult<ConteoResponse>>> Create([FromBody] ConteoResponse response)
    {
        try
        {
            var dto = _mapper.Map<ConteoDto>(response);
            dto.UsuarioCreacion = _userContext.GetCurrentUserId();
            dto.FechaCreacion = DateTime.Now;
            dto.Activo = true;

            await _service.AddAsync(dto);

            return CreatedAtAction(nameof(GetById), new { id = dto.PkidConteo }, new PagedResult<ConteoResponse>
            {
                Success = true,
                Message = "Conteo creado correctamente",
                Code = "SUCCESS",
                TotalCount = 1
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new PagedResult<ConteoResponse>
            {
                Success = false,
                Message = $"Error al crear: {ex.Message}",
                Code = "ERROR"
            });
        }
    }

    [HttpPut("{id}")]
    public async Task<ActionResult<PagedResult<ConteoResponse>>> Update(int id, [FromBody] ConteoResponse response)
    {
        try
        {
            var dto = _mapper.Map<ConteoDto>(response);
            dto.PkidConteo = id;
            dto.UsuarioModificacion = _userContext.GetCurrentUserId();
            dto.FechaModificacion = DateTime.Now;

            await _service.UpdateAsync(id, dto);

            return Ok(new PagedResult<ConteoResponse>
            {
                Success = true,
                Message = "Conteo actualizado correctamente",
                Code = "SUCCESS",
                TotalCount = 1
            });
        }
        catch (KeyNotFoundException)
        {
            return NotFound(new PagedResult<ConteoResponse>
            {
                Success = false,
                Message = $"Conteo con ID {id} no encontrado",
                Code = "NOT_FOUND"
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new PagedResult<ConteoResponse>
            {
                Success = false,
                Message = $"Error al actualizar: {ex.Message}",
                Code = "ERROR"
            });
        }
    }

    [HttpDelete("{id}")]
    public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
    {
        try
        {
            await _service.DeleteAsync(id);
            return Ok(new PagedResult<bool>
            {
                Success = true,
                Message = "Conteo eliminado correctamente",
                Code = "SUCCESS",
                Data = true,
                Items = new List<bool> { true },
                TotalCount = 1
            });
        }
        catch (KeyNotFoundException)
        {
            return NotFound(new PagedResult<bool>
            {
                Success = false,
                Message = $"Conteo con ID {id} no encontrado",
                Code = "NOT_FOUND"
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new PagedResult<bool>
            {
                Success = false,
                Message = $"Error al eliminar: {ex.Message}",
                Code = "ERROR"
            });
        }
    }
}
