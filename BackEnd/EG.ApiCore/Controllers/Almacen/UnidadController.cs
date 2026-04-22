using AutoMapper;
using EG.ApiCore.Services;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Almacen;
using EG.Domain.DTOs.Responses.Almacen;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCore.Controllers.Almacen;

[ApiController]
[Route("api/[controller]")]
public class UnidadController : ControllerBase
{
    private readonly GenericService<Unidade, UnidadDto, UnidadResponse> _service;
    private readonly GenericService<Unidade, UnidadDto, UnidadResponse> _serviceView;
    private readonly IMapper _mapper;
    private readonly IUserContextService _userContext;

    public UnidadController(
        GenericService<Unidade, UnidadDto, UnidadResponse> service,
        GenericService<Unidade, UnidadDto, UnidadResponse> serviceView,
        IMapper mapper,
        IUserContextService userContext)
    {
        _service = service;
        _serviceView = serviceView;
        _mapper = mapper;
        _userContext = userContext;
    }

    [HttpGet]
    public async Task<ActionResult<PagedResult<UnidadResponse>>> GetAll()
    {
        var result = await _serviceView.GetAllAsync();
        return Ok(new PagedResult<UnidadResponse>
        {
            Success = true,
            Message = "Unidades obtenidas correctamente",
            Code = "SUCCESS",
            Items = result.ToList(),
            TotalCount = result.Count()
        });
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<PagedResult<UnidadResponse>>> GetById(int id)
    {
        var result = await _serviceView.GetByIdAsync(id, idPropertyName: "PkidUnidades");
        if (result == null)
        {
            return NotFound(new PagedResult<UnidadResponse>
            {
                Success = false,
                Message = "Unidad no encontrada",
                Code = "NOT_FOUND"
            });
        }

        return Ok(new PagedResult<UnidadResponse>
        {
            Success = true,
            Message = "Unidad encontrada",
            Code = "SUCCESS",
            Data = result,
            Items = new List<UnidadResponse> { result },
            TotalCount = 1
        });
    }

    [HttpPost]
    public async Task<ActionResult<PagedResult<UnidadResponse>>> Create([FromBody] UnidadResponse response)
    {
        try
        {
            var dto = _mapper.Map<UnidadDto>(response);
            dto.UsuarioCreacion = _userContext.GetCurrentUserId();
            dto.FechaCreacion = DateTime.Now;

            await _service.AddAsync(dto);

            return CreatedAtAction(nameof(GetById), new { id = dto.PkidUnidades }, new PagedResult<UnidadResponse>
            {
                Success = true,
                Message = "Unidad creada correctamente",
                Code = "SUCCESS",
                Data = dto.PkidUnidades > 0 ? _mapper.Map<UnidadResponse>(dto) : null,
                TotalCount = 1
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new PagedResult<UnidadResponse>
            {
                Success = false,
                Message = $"Error al crear: {ex.Message}",
                Code = "ERROR"
            });
        }
    }

    [HttpPut("{id}")]
    public async Task<ActionResult<PagedResult<UnidadResponse>>> Update(int id, [FromBody] UnidadResponse response)
    {
        try
        {
            var dto = _mapper.Map<UnidadDto>(response);
            dto.PkidUnidades = id;
            dto.UsuarioModificacion = _userContext.GetCurrentUserId();
            dto.FechaModificacion = DateTime.Now;

            await _service.UpdateAsync(id, dto);

            return Ok(new PagedResult<UnidadResponse>
            {
                Success = true,
                Message = "Unidad actualizada correctamente",
                Code = "SUCCESS",
                TotalCount = 1
            });
        }
        catch (KeyNotFoundException)
        {
            return NotFound(new PagedResult<UnidadResponse>
            {
                Success = false,
                Message = $"Unidad con ID {id} no encontrada",
                Code = "NOT_FOUND"
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new PagedResult<UnidadResponse>
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
                Message = "Unidad eliminada correctamente",
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
                Message = $"Unidad con ID {id} no encontrada",
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

    [HttpPost("GetAllPaginado")]
    public async Task<ActionResult<PagedResult<UnidadResponse>>> GetAllPaginado([FromBody] PagedRequest pageRequest)
    {
        try
        {
            var result = await _serviceView.GetAllPaginadoAsync(pageRequest);
            return Ok(new PagedResult<UnidadResponse>
            {
                Success = true,
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new PagedResult<UnidadResponse>
            {
                Success = false,
                Message = ex.Message,
                Code = "ERROR"
            });
        }
    }
}