using Azure.Core;
using EG.Application.Interfaces.Almacen;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Almacen;
using EG.Domain.DTOs.Responses.Almacen;
using EG.Domain.DTOs.Responses.General;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCore.Controllers.Almacen;

[ApiController]
[Route("api/[controller]")]
public class FamiliaController : ControllerBase
{
    private readonly IFamiliaService _familiaService;

    public FamiliaController(IFamiliaService familiaService)
    {
        _familiaService = familiaService;
    }

    [HttpGet]
    public async Task<ActionResult<PagedResult<FamiliaResponse>>> GetAll()
    {
        var result = await _familiaService.GetAllAsync();
        return Ok(result);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<PagedResult<FamiliaResponse>>> GetById(int id)
    {
        var result = await _familiaService.GetByIdAsync(id);
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
    public async Task<ActionResult<PagedResult<FamiliaResponse>>> Create([FromBody] FamiliaDto dto, [FromQuery] int usuarioActual)
    {
        try
        {
            var result = await _familiaService.CreateAsync(dto, usuarioActual);
            return CreatedAtAction(nameof(GetById), new { id = result.PkidFamilia }, new PagedResult<FamiliaResponse>
            {
                Success = true,
                Message = "Familia creada correctamente",
                Code = "SUCCESS",
                Data = result,
                Items = new List<FamiliaResponse> { result },
                TotalCount = 1
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

    [HttpPut("{id}")]
    public async Task<ActionResult<PagedResult<FamiliaResponse>>> Update(int id, [FromBody] FamiliaDto dto, [FromQuery] int usuarioActual)
    {
        try
        {
            var result = await _familiaService.UpdateAsync(id, dto, usuarioActual);
            return Ok(new PagedResult<FamiliaResponse>
            {
                Success = true,
                Message = "Familia actualizada correctamente",
                Code = "SUCCESS",
                Data = result,
                Items = new List<FamiliaResponse> { result },
                TotalCount = 1
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

    [HttpDelete("{id}")]
    public async Task<ActionResult<PagedResult<bool>>> Delete(int id, [FromQuery] int usuarioActual)
    {
        try
        {
            var result = await _familiaService.DeleteAsync(id, usuarioActual);
            return Ok(new PagedResult<bool>
            {
                Success = result,
                Message = result ? "Familia eliminada correctamente" : "Error al eliminar la familia",
                Code = result ? "SUCCESS" : "ERROR",
                Data = result,
                Items = new List<bool> { result },
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

    [HttpPost("GetAllPaginado")]
    public async Task<ActionResult<PagedResult<FamiliaResponse>>> GetAllPaginado([FromBody] PagedRequest pageRequest)
    {
        try
        {
            //_serviceView.ClearConfiguration();
            //ConfigureService();

            var result = await _familiaService.GetAllPaginadoAsync(pageRequest);
            return new PagedResult<FamiliaResponse>
            {
                Success = true,
                Items = result.Items,
                TotalCount = result.TotalCount
            };
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