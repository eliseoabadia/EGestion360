using EG.Application.Interfaces.General;
using EG.Common.GenericModel;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.PresupuestoModificado
{
    [ApiController]
    [Authorize]
    public abstract class ReadOnlyCatalogController<TResponse>(
        IReadOnlyCatalogAppService<TResponse> service) : ControllerBase
        where TResponse : class
    {
        [HttpGet("{id:int}")]
        public async Task<ActionResult<PagedResult<TResponse>>> GetById(int id)
        {
            TResponse? item = await service.GetByIdAsync(id);
            return item == null
                ? NotFound(new PagedResult<TResponse> { Success = false, Message = "Registro no encontrado", Code = "NOT_FOUND" })
                : Ok(new PagedResult<TResponse> { Success = true, Data = item, Items = new List<TResponse> { item }, TotalCount = 1 });
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<TResponse>>> GetAllPaginado([FromBody] PagedRequest request) =>
            Ok(await service.GetAllPaginadoAsync(request));
    }
}
