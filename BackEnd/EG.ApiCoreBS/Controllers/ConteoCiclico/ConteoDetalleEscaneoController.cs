using AutoMapper;
using EG.ApiCoreBS.Services;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.ConteoCiclico;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ConteoDetalleEscaneoController : ControllerBase
{
    private readonly GenericService<VwConteoDetalleEscaneo, ConteoDto, ConteoDetalleEscaneoResponse> _serviceView;
    private readonly IMapper _mapper;
    private readonly IUserContextService _userContext;

    public ConteoDetalleEscaneoController(
        GenericService<VwConteoDetalleEscaneo, ConteoDto, ConteoDetalleEscaneoResponse> serviceView,
        IMapper mapper,
        IUserContextService userContext)
    {
        _serviceView = serviceView;
        _mapper = mapper;
        _userContext = userContext;
    }

    [HttpGet]
    public async Task<ActionResult<PagedResult<ConteoDetalleEscaneoResponse>>> GetAll()
    {
        var result = await _serviceView.GetAllAsync();
        return Ok(new PagedResult<ConteoDetalleEscaneoResponse>
        {
            Success = true,
            Message = "Escaneos obtenidos correctamente",
            Code = "SUCCESS",
            Items = result.ToList(),
            TotalCount = result.Count()
        });
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<PagedResult<ConteoDetalleEscaneoResponse>>> GetById(int id)
    {
        try
        {
            var result = await _serviceView.GetByIdAsync(id, idPropertyName: "PkidDetalleEscaneo");
            if (result == null)
                return NotFound(new PagedResult<ConteoDetalleEscaneoResponse>
                {
                    Success = false,
                    Message = "Escaneo no encontrado",
                    Code = "NOT_FOUND"
                });

            return Ok(new PagedResult<ConteoDetalleEscaneoResponse>
            {
                Success = true,
                Message = "Escaneo encontrado",
                Code = "SUCCESS",
                Data = result,
                Items = new List<ConteoDetalleEscaneoResponse> { result },
                TotalCount = 1
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

    [HttpPost("GetAllPaginado")]
    public async Task<ActionResult<PagedResult<ConteoDetalleEscaneoResponse>>> GetAllPaginado([FromBody] PagedRequest pageRequest)
    {
        try
        {
            var result = await _serviceView.GetAllPaginadoAsync(pageRequest);
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
    /// Obtiene escaneos filtrados por conteo
    /// </summary>
    [HttpGet("ByConteo/{conteoId}")]
    public async Task<ActionResult<PagedResult<ConteoDetalleEscaneoResponse>>> GetByConteo(int conteoId)
    {
        try
        {
            var all = await _serviceView.GetAllAsync();
            var filtered = all.Where(e => e.FkidConteoAlma == conteoId).ToList();

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
    public async Task<ActionResult<PagedResult<ConteoDetalleEscaneoResponse>>> Create([FromBody] ConteoDetalleEscaneoResponse request)
    {
        try
        {
            var escaneo = new ConteoDetalleEscaneo
            {
                FkidConteoAlma = request.FkidConteoAlma,
                FkidPersonaNom = request.FkidPersonaNom,
                FkidBienAlma = request.FkidBienAlma,
                FkidTipoBienAlma = request.FkidTipoBienAlma,
                CodigoBarras = request.CodigoBarras ?? "",
                FechaEscaneo = DateTime.Now,
                Activo = true,
                UsuarioCreacion = _userContext.GetCurrentUserId(),
                FechaCreacion = DateTime.Now
            };

            var dbContext = HttpContext.RequestServices.GetRequiredService<EGestionContext>();
            dbContext.ConteoDetalleEscaneos.Add(escaneo);
            await dbContext.SaveChangesAsync();

            return Ok(new PagedResult<ConteoDetalleEscaneoResponse>
            {
                Success = true,
                Message = "Escaneo creado correctamente",
                Code = "SUCCESS",
                TotalCount = 1
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
}
