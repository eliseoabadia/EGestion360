using AutoMapper;
using EG.ApiCoreBS.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.General;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.General;

[Route("api/[controller]")]
[ApiController]
[Authorize]
public class UsuarioAreaController : ControllerBase
{
    private readonly IRepository<VwUsuarioPersonaArea> _repository;
    private readonly IMapper _mapper;
    private readonly IUserContextService _userContext;

    public UsuarioAreaController(
        IRepository<VwUsuarioPersonaArea> repository,
        IMapper mapper,
        IUserContextService userContext)
    {
        _repository = repository;
        _mapper = mapper;
        _userContext = userContext;
    }

    [HttpGet]
    public async Task<ActionResult<PagedResult<UsuarioAreaResponse>>> GetAll()
    {
        try
        {
            var usuarioId = _userContext.GetCurrentUserId();
            var entities = await _repository.GetAllWithIncludesAsync(x => x.PkIdUsuario == usuarioId);
            var result = _mapper.Map<List<UsuarioAreaResponse>>(entities.Where(e => e.PkidArea.HasValue));
            return Ok(new PagedResult<UsuarioAreaResponse>
            {
                Success = true,
                Message = "Áreas del usuario obtenidas correctamente",
                Code = "SUCCESS",
                Items = result,
                TotalCount = result.Count
            });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new PagedResult<UsuarioAreaResponse>
            {
                Success = false,
                Message = $"Error al obtener áreas: {ex.Message}",
                Code = "ERROR",
                TotalCount = 0
            });
        }
    }
}
