using EG.Common.Enums;
using EG.Common.GenericModel;
using EG.Contracts.Platform.Licensing;
using EG.Domain.Interfaces;
using EG.Domain.Platform.Licensing;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Platform.Licensing;

[ApiController]
[Route("api/Licensing")]
[Authorize(Policy = "Sistema|Configurar_Accesos|view")]
public sealed class LicensingController(
    ILicensingService licensing,
    IUserContextService userContext,
    ILogger<LicensingController> logger) : ControllerBase
{
    [HttpGet("snapshot")]
    public async Task<ActionResult<PagedResult<LicenseSnapshotResponse>>> GetSnapshot(
        CancellationToken cancellationToken)
    {
        var snapshot = await licensing.GetSnapshotAsync(cancellationToken);
        return Ok(Success(snapshot, "Estado de licencia cargado."));
    }

    [HttpGet("installation-request")]
    public async Task<ActionResult<PagedResult<LicenseInstallationRequestResponse>>> GetInstallationRequest(
        CancellationToken cancellationToken)
    {
        var request = await licensing.GetInstallationRequestAsync(cancellationToken);
        return Ok(Success(request, "Solicitud de instalación generada."));
    }

    [HttpPost("import")]
    [Authorize(Policy = "Sistema|Configurar_Accesos|update")]
    [RequestSizeLimit(70 * 1024)]
    public async Task<ActionResult<PagedResult<LicenseSnapshotResponse>>> Import(
        [FromBody] ImportLicenseRequest request,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(request.SignedLicense))
            return BadRequest(Error<LicenseSnapshotResponse>("Seleccione un archivo de licencia válido.", "LIC_FILE_EMPTY"));

        try
        {
            var snapshot = await licensing.ImportAsync(
                request.SignedLicense,
                userContext.GetCurrentUserId(),
                cancellationToken);
            return Ok(Success(snapshot, "Licencia importada correctamente."));
        }
        catch (LicenseOperationException ex)
        {
            logger.LogWarning(
                "Importación de licencia rechazada. Code={Code}; UserId={UserId}",
                ex.Code,
                userContext.TryGetCurrentUserId());
            return BadRequest(Error<LicenseSnapshotResponse>(ex.Message, ex.Code));
        }
    }

    [HttpPut("modules/{moduleCode}")]
    [Authorize(Policy = "Sistema|Configurar_Accesos|update")]
    public async Task<ActionResult<PagedResult<LicenseSnapshotResponse>>> SetModuleState(
        string moduleCode,
        [FromBody] SetLicenseModuleStateRequest request,
        CancellationToken cancellationToken)
    {
        try
        {
            var snapshot = await licensing.SetModuleStateAsync(
                moduleCode,
                request.Active,
                request.Reason,
                userContext.GetCurrentUserId(),
                cancellationToken);
            return Ok(Success(snapshot, request.Active ? "Módulo encendido." : "Módulo apagado."));
        }
        catch (LicenseOperationException ex)
        {
            return BadRequest(Error<LicenseSnapshotResponse>(ex.Message, ex.Code));
        }
    }

    private static PagedResult<T> Success<T>(T data, string message) => new()
    {
        Success = true,
        Code = ApiResponseCode.Success.ToCode(),
        Message = message,
        Data = data,
        Items = [data],
        TotalCount = 1
    };

    private static PagedResult<T> Error<T>(string message, string code) => new()
    {
        Success = false,
        Code = code,
        Message = message,
        TotalCount = 0
    };
}
