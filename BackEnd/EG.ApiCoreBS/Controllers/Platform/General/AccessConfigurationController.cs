using EG.ApiCoreBS.Services;
using EG.Application.Interfaces.AccessConfiguration;
using EG.Common.Enums;
using EG.Common.GenericModel;
using EG.Domain.Interfaces;
using EG.Domain.Platform.DTOs.Requests.AccessConfiguration;
using EG.Domain.Platform.DTOs.Responses.AccessConfiguration;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.General;

[Route("api/[controller]")]
[ApiController]
[Authorize]
public sealed class AccessConfigurationController(
    IAccessConfigurationAppService appService,
    IUserContextService userContext) : ControllerBase
{
    private readonly IAccessConfigurationAppService _appService = appService;
    private readonly IUserContextService _userContext = userContext;

    [HttpGet("snapshot")]
    public async Task<ActionResult<PagedResult<AccessConfigurationSnapshotResponse>>> GetSnapshot()
    {
        try
        {
            var result = await _appService.GetSnapshotAsync();
            return Ok(Success(result, "Configuracion de accesos cargada."));
        }
        catch (Exception ex)
        {
            return StatusCode(500, Error<AccessConfigurationSnapshotResponse>(ex.Message));
        }
    }

    [HttpGet("roles/{roleId}")]
    public async Task<ActionResult<PagedResult<AccessRoleDetailResponse>>> GetRoleDetail(string roleId)
    {
        try
        {
            var result = await _appService.GetRoleDetailAsync(roleId);
            return Ok(Success(result, "Rol cargado."));
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(Error<AccessRoleDetailResponse>(ex.Message, ApiResponseCode.NotFound));
        }
        catch (Exception ex)
        {
            return StatusCode(500, Error<AccessRoleDetailResponse>(ex.Message));
        }
    }

    [HttpGet("roles/template")]
    public async Task<ActionResult<PagedResult<AccessRoleDetailResponse>>> GetNewRoleTemplate()
    {
        try
        {
            var result = await _appService.GetNewRoleTemplateAsync();
            return Ok(Success(result, "Plantilla de rol cargada."));
        }
        catch (Exception ex)
        {
            return StatusCode(500, Error<AccessRoleDetailResponse>(ex.Message));
        }
    }

    [HttpGet("users/{pkIdUsuario:int}/roles")]
    public async Task<ActionResult<PagedResult<AccessUserRoleDetailResponse>>> GetUserRoleDetail(int pkIdUsuario)
    {
        try
        {
            var result = await _appService.GetUserRoleDetailAsync(pkIdUsuario);
            return Ok(Success(result, "Roles del usuario cargados."));
        }
        catch (ArgumentException ex)
        {
            return BadRequest(Error<AccessUserRoleDetailResponse>(ex.Message, ApiResponseCode.InvalidData));
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(Error<AccessUserRoleDetailResponse>(ex.Message, ApiResponseCode.NotFound));
        }
        catch (Exception ex)
        {
            return StatusCode(500, Error<AccessUserRoleDetailResponse>(ex.Message));
        }
    }

    [HttpPost("roles/save")]
    public async Task<ActionResult<PagedResult<AccessRoleDetailResponse>>> SaveRole([FromBody] SaveAccessRoleRequest request)
    {
        try
        {
            var operatorId = _userContext.GetCurrentUserId();
            var result = await _appService.SaveRoleAsync(request, operatorId);
            return Ok(Success(result, "Accesos guardados y menu de roles sincronizado."));
        }
        catch (ArgumentException ex)
        {
            return BadRequest(Error<AccessRoleDetailResponse>(ex.Message, ApiResponseCode.InvalidData));
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(Error<AccessRoleDetailResponse>(ex.Message, ApiResponseCode.NotFound));
        }
        catch (Exception ex)
        {
            return StatusCode(500, Error<AccessRoleDetailResponse>(ex.Message));
        }
    }

    [HttpPost("users/save-roles")]
    public async Task<ActionResult<PagedResult<AccessUserRoleDetailResponse>>> SaveUserRoles([FromBody] SaveAccessUserRolesRequest request)
    {
        try
        {
            var operatorId = _userContext.GetCurrentUserId();
            var result = await _appService.SaveUserRolesAsync(request, operatorId);
            return Ok(Success(result, "Roles del usuario actualizados."));
        }
        catch (ArgumentException ex)
        {
            return BadRequest(Error<AccessUserRoleDetailResponse>(ex.Message, ApiResponseCode.InvalidData));
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(Error<AccessUserRoleDetailResponse>(ex.Message, ApiResponseCode.NotFound));
        }
        catch (Exception ex)
        {
            return StatusCode(500, Error<AccessUserRoleDetailResponse>(ex.Message));
        }
    }

    [HttpPost("synchronize-menu-roles")]
    public async Task<ActionResult<PagedResult<int>>> SynchronizeMenuRoles()
    {
        try
        {
            var operatorId = _userContext.GetCurrentUserId();
            var affected = await _appService.SynchronizeMenuRolesAsync(operatorId);
            return Ok(Success(affected, "MenuRole sincronizado."));
        }
        catch (Exception ex)
        {
            return StatusCode(500, Error<int>(ex.Message));
        }
    }

    private static PagedResult<T> Success<T>(T data, string message) => new()
    {
        Success = true,
        Code = ApiResponseCode.Success.ToCode(),
        Message = message,
        Data = data,
        Items = data is null ? new List<T>() : new List<T> { data },
        TotalCount = data is null ? 0 : 1
    };

    private static PagedResult<T> Error<T>(string message, ApiResponseCode code = ApiResponseCode.Error) => new()
    {
        Success = false,
        Code = code.ToCode(),
        Message = message,
        TotalCount = 0
    };
}
