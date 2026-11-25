using EG.Application.Interfaces.Adquisicion;
using EG.Common.GenericModel;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.PresupuestoModificado
{
    [ApiController]
    [Authorize]
    public abstract class PresupuestoModificadoReadOnlyControllerBase<TResponse>(
        IAdquisicionCrudAppService<TResponse> service) : ControllerBase
        where TResponse : class
    {
        protected readonly IAdquisicionCrudAppService<TResponse> Service = service;

        [HttpGet]
        public virtual async Task<ActionResult<PagedResult<TResponse>>> GetAll() => Ok(await Service.GetAllAsync());

        [HttpGet("{id:int}")]
        public virtual async Task<ActionResult<PagedResult<TResponse>>> GetById(int id)
        {
            var result = await Service.GetByIdAsync(id);
            return result.Success ? Ok(result) : NotFound(result);
        }

        [HttpPost("GetAllPaginado")]
        public virtual async Task<ActionResult<PagedResult<TResponse>>> GetAllPaginado([FromBody] PagedRequest request) =>
            Ok(await Service.GetAllPaginadoAsync(request));
    }
}
