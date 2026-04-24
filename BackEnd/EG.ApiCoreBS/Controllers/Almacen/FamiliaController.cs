using AutoMapper;
using EG.ApiCoreBS.Services;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Almacen;
using EG.Domain.DTOs.Responses.Almacen;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Almacen;

[ApiController]
[Route("api/[controller]")]
public class FamiliaController : ControllerBase
{
    private readonly GenericService<Familium, FamiliaDto, FamiliaResponse> _service;
    private readonly GenericService<Familium, FamiliaDto, FamiliaResponse> _serviceView;
    private readonly IMapper _mapper;
    private readonly IUserContextService _userContext;

    public FamiliaController(
        GenericService<Familium, FamiliaDto, FamiliaResponse> service,
        GenericService<Familium, FamiliaDto, FamiliaResponse> serviceView,
        IMapper mapper,
        IUserContextService userContext)
    {
        _service = service;
        _serviceView = serviceView;
        _mapper = mapper;
        _userContext = userContext;
    }

    [HttpGet]
    public async Task<ActionResult<PagedResult<FamiliaResponse>>> GetAll()
    {
        var result = await _serviceView.GetAllAsync();
        return Ok(new PagedResult<FamiliaResponse>
        {
            Success = true,
            Message = "Familias obtenidas correctamente",
            Code = "SUCCESS",
            Items = result.ToList(),
            TotalCount = result.Count()
        });
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<PagedResult<FamiliaResponse>>> GetById(int id)
    {
        var result = await _serviceView.GetByIdAsync(id, idPropertyName: "PkidFamilia");
        if (result == null)
        {
            return NotFound(new PagedResult<FamiliaResponse>
            {
                Success = false,
                Message = "Familia no encontrada",
                Code = "NOT_FOUND"
            });
        }

        return Ok(new PagedResult<FamiliaResponse>
        {
            Success = true,
            Message = "Familia encontrada",
            Code = "SUCCESS",
            Data = result,
            Items = new List<FamiliaResponse> { result },
            TotalCount = 1
        });
    }

    [HttpPost]
    public async Task<ActionResult<PagedResult<FamiliaResponse>>> Create([FromBody] FamiliaResponse response)
    {
        try
        {
            var dto = _mapper.Map<FamiliaDto>(response);
            dto.UsuarioCreacion = _userContext.GetCurrentUserId();
            dto.FechaCreacion = DateTime.Now;

            await _service.AddAsync(dto);

            return CreatedAtAction(nameof(GetById), new { id = dto.PkidFamilia }, new PagedResult<FamiliaResponse>
            {
                Success = true,
                Message = "Familia creada correctamente",
                Code = "SUCCESS",
                Data = dto.PkidFamilia > 0 ? _mapper.Map<FamiliaResponse>(dto) : null,
                TotalCount = 1
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new PagedResult<FamiliaResponse>
            {
                Success = false,
                Message = $"Error al crear: {ex.Message}",
                Code = "ERROR"
            });
        }
    }

    [HttpPut("{id}")]
    public async Task<ActionResult<PagedResult<FamiliaResponse>>> Update(int id, [FromBody] FamiliaResponse response)
    {
        try
        {
            var dto = _mapper.Map<FamiliaDto>(response);
            dto.PkidFamilia = id;
            dto.UsuarioModificacion = _userContext.GetCurrentUserId();
            dto.FechaModificacion = DateTime.Now;

            await _service.UpdateAsync(id, dto);

            return Ok(new PagedResult<FamiliaResponse>
            {
                Success = true,
                Message = "Familia actualizada correctamente",
                Code = "SUCCESS",
                TotalCount = 1
            });
        }
        catch (KeyNotFoundException)
        {
            return NotFound(new PagedResult<FamiliaResponse>
            {
                Success = false,
                Message = $"Familia con ID {id} no encontrada",
                Code = "NOT_FOUND"
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new PagedResult<FamiliaResponse>
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
                Message = "Familia eliminada correctamente",
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
                Message = $"Familia con ID {id} no encontrada",
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
    public async Task<ActionResult<PagedResult<FamiliaResponse>>> GetAllPaginado([FromBody] PagedRequest pageRequest)
    {
        try
        {
            var result = await _serviceView.GetAllPaginadoAsync(pageRequest);
            return Ok(new PagedResult<FamiliaResponse>
            {
                Success = true,
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new PagedResult<FamiliaResponse>
            {
                Success = false,
                Message = ex.Message,
                Code = "ERROR"
            });
        }
    }
}
