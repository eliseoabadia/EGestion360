using EG.Common.Enums;
using EG.Application.Interfaces.Adquisicion;
using EG.Common.GenericModel;
using EG.Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.PresupuestoModificado
{
    public abstract class PresupuestoModificadoControllerBase<TResponse>(
        IAdquisicionCrudAppService<TResponse> service,
        IUserContextService userContext,
        IAuthorizationService authorization) : PresupuestoModificadoReadOnlyControllerBase<TResponse>(service)
        where TResponse : class
    {
        protected readonly IUserContextService UserContext = userContext;

        protected abstract string PermissionFilterName { get; }
        protected abstract Task<int?> GetTipoAdecuacionAsync(TResponse response);
        protected abstract Task<int?> GetFilterTipoAdecuacionAsync(int value);

        protected async Task<bool> HasPermissionAsync(int? tipoAdecuacionId, PermissionAction action)
        {
            var subModule = tipoAdecuacionId switch
            {
                1 => "Adecuaciones_Compensadas",
                2 => "Reducciones",
                3 => "Ampliaciones",
                _ => null
            };
            return subModule != null &&
                (await authorization.AuthorizeAsync(User, null, $"Presupuesto_Modificado|{subModule}|{action.ToClaimValue()}")).Succeeded;
        }

        private async Task<bool> CanViewAllTypesAsync()
        {
            foreach (var type in new[] { 1, 2, 3 })
            {
                if (!await HasPermissionAsync(type, PermissionAction.View))
                    return false;
            }
            return true;
        }

        public override async Task<ActionResult<PagedResult<TResponse>>> GetAll() =>
            await CanViewAllTypesAsync() ? await base.GetAll() : Forbid();

        public override async Task<ActionResult<PagedResult<TResponse>>> GetById(int id)
        {
            var result = await Service.GetByIdAsync(id);
            if (!result.Success || result.Data == null)
                return NotFound(result);
            return await HasPermissionAsync(await GetTipoAdecuacionAsync(result.Data), PermissionAction.View)
                ? Ok(result) : Forbid();
        }

        public override async Task<ActionResult<PagedResult<TResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            // The same exact filter is passed to the query, before counting and paging.
            if (request.AdditionalFilters != null &&
                request.AdditionalFilters.TryGetValue(PermissionFilterName, out var value))
            {
                if (!int.TryParse(value?.ToString(), out var id) || id <= 0 ||
                    !await HasPermissionAsync(await GetFilterTipoAdecuacionAsync(id), PermissionAction.View))
                    return Forbid();
            }
            else if (!await CanViewAllTypesAsync())
            {
                return Forbid();
            }
            return await base.GetAllPaginado(request);
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<TResponse>>> Create([FromBody] TResponse response)
        {
            if (!await HasPermissionAsync(await GetTipoAdecuacionAsync(response), PermissionAction.New))
                return Forbid();
            var result = await Service.CreateAsync(response, UserContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpPut("{id:int}")]
        public async Task<ActionResult<PagedResult<TResponse>>> Update(int id, [FromBody] TResponse response)
        {
            var current = await Service.GetByIdAsync(id);
            if (!current.Success || current.Data == null)
                return NotFound(current);
            if (!await HasPermissionAsync(await GetTipoAdecuacionAsync(current.Data), PermissionAction.Update) ||
                !await HasPermissionAsync(await GetTipoAdecuacionAsync(response), PermissionAction.Update))
                return Forbid();
            var result = await Service.UpdateAsync(id, response, UserContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpDelete("{id:int}")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
        {
            var current = await Service.GetByIdAsync(id);
            if (!current.Success || current.Data == null)
                return NotFound(current);
            if (!await HasPermissionAsync(await GetTipoAdecuacionAsync(current.Data), PermissionAction.Delete))
                return Forbid();
            var result = await Service.DeleteAsync(id);
            return result.Success ? Ok(result) : BadRequest(result);
        }
    }
}
