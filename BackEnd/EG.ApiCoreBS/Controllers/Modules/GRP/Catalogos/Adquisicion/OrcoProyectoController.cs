using EG.Application.Interfaces.General;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Adquisicion;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Catalogos.Adquisicion
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class OrcoProyectoController : ControllerBase
    {
        private readonly ICatalogLookupAppService _lookups;

        public OrcoProyectoController(ICatalogLookupAppService lookups)
        {
            _lookups = lookups;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<OrcoProyectoResponse>>> GetAll()
        {
            return Ok(await _lookups.GetProyectosAsync());
        }

        [HttpGet("{id:int}")]
        public async Task<ActionResult<PagedResult<OrcoProyectoResponse>>> GetById(int id)
        {
            var result = await _lookups.GetProyectoByIdAsync(id);
            return result.Success ? Ok(result) : NotFound(result);
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<OrcoProyectoResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            return Ok(await _lookups.GetProyectosAsync(request));
        }

    }
}
