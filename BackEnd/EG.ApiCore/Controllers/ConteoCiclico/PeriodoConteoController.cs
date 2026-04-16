using AutoMapper;
using EG.ApiCore.Services;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Data.Common;

namespace EG.ApiCore.Controllers.ConteoCiclico;

[ApiController]
[Route("api/[controller]")]
public class PeriodoConteoController : ControllerBase
{
    private readonly GenericService<PeriodoConteo, PeriodoConteoDto, PeriodoConteoResponse> _service;
    private readonly GenericService<VwPeriodoConteo, PeriodoConteoDto, PeriodoConteoResponse> _serviceView;
    private readonly IMapper _mapper;
    private readonly IUserContextService _userContext;
    private readonly EGestionContext _context;
    private readonly EGestionContextProcedures _procedures;

    public PeriodoConteoController(
        GenericService<PeriodoConteo, PeriodoConteoDto, PeriodoConteoResponse> service,
        GenericService<VwPeriodoConteo, PeriodoConteoDto, PeriodoConteoResponse> serviceView,
        IMapper mapper,
        IUserContextService userContext,
        EGestionContext context,
        EGestionContextProcedures procedures)
    {
        _service = service;
        _serviceView = serviceView;
        _mapper = mapper;
        _userContext = userContext;
        _context = context;
        _procedures = procedures;
        ConfigureService();
    }

    private void ConfigureService()
    {
        // VwPeriodoConteo es una vista, no tiene propiedades de navegación
        // Las relaciones ya están resueltas en la vista
    }

    [HttpGet]
    public async Task<ActionResult<PagedResult<PeriodoConteoResponse>>> GetAll()
    {
        var result = await _serviceView.GetAllAsync();
        return Ok(new PagedResult<PeriodoConteoResponse>
        {
            Success = true,
            Message = "Períodos de conteo obtenidos correctamente",
            Code = "SUCCESS",
            Items = result.ToList(),
            TotalCount = result.Count()
        });
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<PagedResult<PeriodoConteoResponse>>> GetById(int id)
    {
        try
        {
            var result = await _serviceView.GetByIdAsync(id, idPropertyName: "PkidPeriodoConteo");
            if (result == null)
            {
                return NotFound(new PagedResult<PeriodoConteoResponse>
                {
                    Success = false,
                    Message = "Período de conteo no encontrado",
                    Code = "NOT_FOUND"
                });
            }

            return Ok(new PagedResult<PeriodoConteoResponse>
            {
                Success = true,
                Message = "Período de conteo encontrado",
                Code = "SUCCESS",
                Data = result,
                Items = new List<PeriodoConteoResponse> { result },
                TotalCount = 1
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new PagedResult<PeriodoConteoResponse>
            {
                Success = false,
                Message = ex.Message,
                Code = "ERROR"
            });
        }
    }

    [HttpPost("GetAllPaginado")]
    public async Task<ActionResult<PagedResult<PeriodoConteoResponse>>> GetAllPaginado([FromBody] PagedRequest pageRequest)
    {
        try
        {
            var result = await _serviceView.GetAllPaginadoAsync(pageRequest);
            return Ok(new PagedResult<PeriodoConteoResponse>
            {
                Success = true,
                Message = "Períodos de conteo obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new PagedResult<PeriodoConteoResponse>
            {
                Success = false,
                Message = ex.Message,
                Code = "ERROR"
            });
        }
    }

    [HttpPost]
    public async Task<ActionResult<PagedResult<PeriodoConteoResponse>>> Create([FromBody] PeriodoConteoResponse response)
    {
        try
        {
            var dto = _mapper.Map<PeriodoConteoDto>(response);
            dto.UsuarioCreacion = _userContext.GetCurrentUserId();
            dto.FechaCreacion = DateTime.Now;

            await _service.AddAsync(dto);

            return CreatedAtAction(nameof(GetById), new { id = dto.PkidPeriodoConteo }, new PagedResult<PeriodoConteoResponse>
            {
                Success = true,
                Message = "Período de conteo creado correctamente",
                Code = "SUCCESS",
                TotalCount = 1
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new PagedResult<PeriodoConteoResponse>
            {
                Success = false,
                Message = $"Error al crear: {ex.Message}",
                Code = "ERROR"
            });
        }
    }

    [HttpPut("{id}")]
    public async Task<ActionResult<PagedResult<PeriodoConteoResponse>>> Update(int id, [FromBody] PeriodoConteoResponse response)
    {
        try
        {
            var dto = _mapper.Map<PeriodoConteoDto>(response);
            dto.PkidPeriodoConteo = id;
            dto.UsuarioModificacion = _userContext.GetCurrentUserId();
            dto.FechaModificacion = DateTime.Now;

            await _service.UpdateAsync(id, dto);

            return Ok(new PagedResult<PeriodoConteoResponse>
            {
                Success = true,
                Message = "Período de conteo actualizado correctamente",
                Code = "SUCCESS",
                TotalCount = 1
            });
        }
        catch (KeyNotFoundException)
        {
            return NotFound(new PagedResult<PeriodoConteoResponse>
            {
                Success = false,
                Message = $"Período de conteo con ID {id} no encontrado",
                Code = "NOT_FOUND"
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new PagedResult<PeriodoConteoResponse>
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
                Message = "Período de conteo eliminado correctamente",
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
                Message = $"Período de conteo con ID {id} no encontrado",
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

    [HttpPost("IniciarConteo/{id}")]
    public async Task<ActionResult<PagedResult<PeriodoConteoResponse>>> IniciarConteo(int id)
    {
        try
        {
            var periodo = await _context.TipoBiens
                .FirstOrDefaultAsync(p => p.PkidTipoBien == id);

            if (periodo == null)
            {
                return NotFound(new PagedResult<PeriodoConteoResponse>
                {
                    Success = false,
                    Message = $"Período de conteo con ID {id} no encontrado",
                    Code = "NOT_FOUND"
                });
            }

            var periodoEntity = await _context.PeriodoConteos.FindAsync(id);
            if (periodoEntity == null)
            {
                return NotFound(new PagedResult<PeriodoConteoResponse>
                {
                    Success = false,
                    Message = $"Período de conteo con ID {id} no encontrado",
                    Code = "NOT_FOUND"
                });
            }

            try
            {
                await _procedures.SP_CargaInicialConteoAsync(p_Partida: null, p_Periodo: id);
            }
            catch (Exception spEx)
            {
                Console.WriteLine($"Error al ejecutar SP_CargaInicialConteo: {spEx.Message}");
            }

            periodoEntity.RequiereAprobacionSupervisor = false;
            periodoEntity.Activo = true;
            periodoEntity.UsuarioModificacion = _userContext.GetCurrentUserId();
            periodoEntity.FechaModificacion = DateTime.Now;

            await _context.SaveChangesAsync();

            return Ok(new PagedResult<PeriodoConteoResponse>
            {
                Success = true,
                Message = "Conteo iniciado correctamente. Los artículos han sido cargados para conteo.",
                Code = "SUCCESS",
                TotalCount = 1
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new PagedResult<PeriodoConteoResponse>
            {
                Success = false,
                Message = $"Error al iniciar conteo: {ex.Message}",
                Code = "ERROR"
            });
        }
    }
}
