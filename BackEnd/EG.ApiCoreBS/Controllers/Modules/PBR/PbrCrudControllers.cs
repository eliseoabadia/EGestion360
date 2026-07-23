using EG.Application.Interfaces.Adquisicion;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.PBR;
using EG.Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.PBR
{
    [ApiController]
    [Authorize(Policy = "PBR|PBR|view")]
    public abstract class PbrCrudController<TResponse> : ControllerBase
        where TResponse : class
    {
        private readonly IAdquisicionCrudAppService<TResponse> _service;
        private readonly IUserContextService _userContext;

        protected PbrCrudController(IAdquisicionCrudAppService<TResponse> service, IUserContextService userContext)
        {
            _service = service;
            _userContext = userContext;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<TResponse>>> GetAll()
        {
            var result = await _service.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id:int}")]
        public async Task<ActionResult<PagedResult<TResponse>>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id);
            return result.Success ? Ok(result) : NotFound(result);
        }

        [HttpPost]
        [Authorize(Policy = "PBR|PBR|new")]
        public async Task<ActionResult<PagedResult<TResponse>>> Create([FromBody] TResponse response)
        {
            var result = await _service.CreateAsync(response, _userContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpPut("{id:int}")]
        [Authorize(Policy = "PBR|PBR|update")]
        public async Task<ActionResult<PagedResult<TResponse>>> Update(int id, [FromBody] TResponse response)
        {
            var result = await _service.UpdateAsync(id, response, _userContext.GetCurrentUserId());
            if (result.Success)
            {
                return Ok(result);
            }

            return result.Code == "NOT_FOUND" ? NotFound(result) : BadRequest(result);
        }

        [HttpDelete("{id:int}")]
        [Authorize(Policy = "PBR|PBR|delete")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
        {
            var result = await _service.DeleteAsync(id);
            if (result.Success)
            {
                return Ok(result);
            }

            return result.Code == "NOT_FOUND" ? NotFound(result) : BadRequest(result);
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<TResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _service.GetAllPaginadoAsync(request);
            return Ok(result);
        }
    }

    [Route("api/[controller]")]
    public class PbrAnteproyectoController : PbrCrudController<PbrAnteproyectoResponse>
    {
        public PbrAnteproyectoController(IAdquisicionCrudAppService<PbrAnteproyectoResponse> service, IUserContextService userContext)
            : base(service, userContext)
        {
        }
    }

    [Route("api/[controller]")]
    public class PbrPresupuestoProgramaController : PbrCrudController<PbrPresupuestoProgramaResponse>
    {
        public PbrPresupuestoProgramaController(IAdquisicionCrudAppService<PbrPresupuestoProgramaResponse> service, IUserContextService userContext)
            : base(service, userContext)
        {
        }
    }

    [Route("api/[controller]")]
    public class PbrPartidaGastoController : PbrCrudController<PbrPartidaGastoResponse>
    {
        public PbrPartidaGastoController(IAdquisicionCrudAppService<PbrPartidaGastoResponse> service, IUserContextService userContext)
            : base(service, userContext)
        {
        }
    }

    [Route("api/[controller]")]
    public class PbrMirNivelController : PbrCrudController<PbrMirNivelResponse>
    {
        public PbrMirNivelController(IAdquisicionCrudAppService<PbrMirNivelResponse> service, IUserContextService userContext)
            : base(service, userContext)
        {
        }
    }

    [Route("api/[controller]")]
    public class PbrIndicadorController : PbrCrudController<PbrIndicadorResponse>
    {
        public PbrIndicadorController(IAdquisicionCrudAppService<PbrIndicadorResponse> service, IUserContextService userContext)
            : base(service, userContext)
        {
        }
    }
}
