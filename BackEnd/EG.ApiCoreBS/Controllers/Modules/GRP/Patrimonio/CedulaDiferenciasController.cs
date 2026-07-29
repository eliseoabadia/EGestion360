using EG.Application.Interfaces.Patrimonio;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Patrimonio;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Patrimonio
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class CedulaDiferenciasController(
        ICedulaDiferenciasAppService appService,
        IAuthorizationService authorization) : ControllerBase
    {
        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<CedulaDiferenciaResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var permission = await authorization.AuthorizeAsync(User, null, "Patrimonio|Cedula_Diferencia|view");
            if (!permission.Succeeded)
            {
                return Forbid();
            }

            var result = await appService.GetAllPaginadoAsync(request);
            return result.Success ? Ok(result) : BadRequest(result);
        }
    }
}
