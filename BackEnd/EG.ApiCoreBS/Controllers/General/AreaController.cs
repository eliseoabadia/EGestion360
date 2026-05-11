using AutoMapper;
using EG.ApiCoreBS.Services;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.General;
using EG.Infraestructure;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCoreBS.Controllers.General
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class AreaController : ControllerBase
    {
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;
        private readonly EGestionContext _context;

        public AreaController(
            IMapper mapper,
            IUserContextService userContext,
            EGestionContext context)
        {
            _mapper = mapper;
            _userContext = userContext;
            _context = context;
        }

        [HttpGet("por-persona/{personaId}")]
        public async Task<ActionResult<PagedResult<AreaResponse>>> GetAreasByPersona(int personaId)
        {
            try
            {
                var areas = await _context.PersonaAreas
                    .Where(pa => pa.FkidPersonaNom == personaId && pa.Activo)
                    .Include(pa => pa.FkidAreaSisNavigation)
                    .Select(pa => new AreaResponse
                    {
                        PkidArea = pa.FkidAreaSis,
                        Clave = pa.FkidAreaSisNavigation != null ? pa.FkidAreaSisNavigation.Clave : string.Empty,
                        Descripcion = pa.FkidAreaSisNavigation != null ? pa.FkidAreaSisNavigation.Nombre : string.Empty,
                        Activo = pa.FkidAreaSisNavigation != null && pa.FkidAreaSisNavigation.Activo,
                        FechaCreacion = pa.FkidAreaSisNavigation != null ? pa.FkidAreaSisNavigation.FechaCreacion : null,
                        UsuarioCreacion = pa.FkidAreaSisNavigation != null ? pa.FkidAreaSisNavigation.UsuarioCreacion : 0
                    })
                    .Distinct()
                    .ToListAsync();

                return Ok(new PagedResult<AreaResponse>
                {
                    Items = areas,
                    TotalCount = areas.Count,
                    Success = true,
                    Message = "Áreas obtenidas correctamente",
                    Code = "SUCCESS"
                });
            }
            catch (Exception ex)
            {
                return Ok(new PagedResult<AreaResponse>
                {
                    Success = false,
                    Message = $"Error interno: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }
    }
}
