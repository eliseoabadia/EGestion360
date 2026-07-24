using DevExpress.XtraReports.Services;
using EG.ApiCoreBS.Reporting;
using EG.Application.Interfaces.FirmaDocumental;
using EG.Application.Interfaces.General;
using EG.Application.Interfaces.SoporteDocumental;
using EG.Application.Services.FirmaDocumental.Models;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.FirmaDocumental;
using EG.Domain.DTOs.Requests.SoporteDocumental;
using EG.Domain.DTOs.Responses.FirmaDocumental;
using EG.Domain.DTOs.Responses.General;
using EG.Domain.DTOs.Responses.SoporteDocumental;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCoreBS.Controllers.Platform.FirmaDocumental
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class FirmaDocumentalController(
        IFirmaDocumentalAppService service,
        ISoporteDocumentalAppService soporteDocumental,
        IFirmaDocumentalStore firmaStore,
        IReportProvider reportProvider,
        IUserContextService userContext,
        IEnvioWorkflowService envioWorkflow,
        EGestionContext context) : ControllerBase
    {
        [HttpGet("proveedores")]
        public async Task<ActionResult<PagedResult<FirmaProveedorResponse>>> ObtenerProveedores()
            => Ok(await service.ObtenerProveedoresAsync());

        [HttpPost("certificados")]
        [RequestSizeLimit(5 * 1024 * 1024)]
        public async Task<ActionResult<PagedResult<FirmaCertificadoUsuarioResponse>>> RegistrarCertificado([FromForm] FirmaCertificadoUsuarioFormRequest request)
        {
            if (request.File == null || request.File.Length == 0)
            {
                return BadRequest(new PagedResult<FirmaCertificadoUsuarioResponse>
                {
                    Success = false,
                    Code = "INVALID_CERTIFICATE",
                    Message = "El archivo PFX es requerido."
                });
            }

            await using var stream = request.File.OpenReadStream();
            using var memory = new MemoryStream();
            await stream.CopyToAsync(memory);

            var dto = new FirmaCertificadoUsuarioUploadRequest
            {
                Alias = request.Alias ?? request.File.FileName,
                NombreOriginal = request.File.FileName,
                Extension = Path.GetExtension(request.File.FileName),
                Password = request.Password ?? string.Empty,
                Contenido = memory.ToArray(),
                TamanoBytes = request.File.Length,
                FkidEmpresaSis = userContext.GetCurrentEmpresaId()
            };

            return Ok(await service.RegistrarCertificadoAsync(dto, userContext.GetCurrentUserId()));
        }

        [HttpGet("certificados")]
        public async Task<ActionResult<PagedResult<FirmaCertificadoUsuarioResponse>>> ObtenerCertificados([FromQuery] int? empresaId = null)
            => Ok(await service.ObtenerCertificadosAsync(userContext.GetCurrentUserId(), userContext.GetCurrentEmpresaId()));

        [HttpPost("firmar")]
        public async Task<ActionResult<PagedResult<FirmaDocumentoResponse>>> FirmarDocumento([FromBody] FirmaDocumentoCrearRequest request)
        {
            request.FkidEmpresaSis = userContext.GetCurrentEmpresaId();
            return Ok(await service.FirmarDocumentoAsync(request, userContext.GetCurrentUserId()));
        }

        [HttpPost("firmas")]
        public async Task<ActionResult<PagedResult<FirmaDocumentoResponse>>> ObtenerFirmas([FromBody] FirmaDocumentoEntidadRequest request)
        {
            request.FkidEmpresaSis = userContext.GetCurrentEmpresaId();
            return Ok(await service.ObtenerFirmasAsync(request, userContext.GetCurrentUserId()));
        }

        [HttpPost("polizas/{polizaId:int}/preparar-firma")]
        public async Task<ActionResult<PagedResult<DocumentoResponse>>> PrepararPolizaParaFirma(int polizaId)
        {
            if (polizaId <= 0)
            {
                return BadRequest(new PagedResult<DocumentoResponse>
                {
                    Success = false,
                    Code = "INVALID_POLIZA",
                    Message = "La poliza es requerida."
                });
            }

            var usuarioActual = userContext.GetCurrentUserId();
            var empresaId = userContext.TryGetCurrentEmpresaId();
            var poliza = await context.Polizas
                .AsNoTracking()
                .Where(x => x.PkidPoliza == polizaId && x.Activo)
                .Select(x => new { x.PkidPoliza, x.EstaBalanceado })
                .FirstOrDefaultAsync();
            if (poliza == null)
            {
                return NotFound(new PagedResult<DocumentoResponse>
                {
                    Success = false,
                    Code = "NOT_FOUND",
                    Message = "La poliza no existe o esta inactiva."
                });
            }

            if (!poliza.EstaBalanceado)
            {
                return BadRequest(new PagedResult<DocumentoResponse>
                {
                    Success = false,
                    Code = "UNBALANCED_POLIZA",
                    Message = "La poliza debe estar balanceada antes de enviarse a firma."
                });
            }

            var claim = await envioWorkflow.TryBeginAsync(
                EnvioWorkflowProcesos.PolizaFirma,
                polizaId,
                usuarioActual);
            if (!claim.Claimed || !claim.OperationToken.HasValue)
            {
                return Conflict(new PagedResult<DocumentoResponse>
                {
                    Success = false,
                    Code = "ALREADY_SENT",
                    Message = $"La poliza no puede enviarse porque su estado de firma es {claim.State.Estado}."
                });
            }

            try
            {
                var pdf = ExportPolizaPdf(polizaId, usuarioActual, empresaId);
                var now = DateTime.UtcNow;
                var fileName = $"POLIZA_OFICIAL_FIRMA_{polizaId}_{now:yyyyMMddHHmmss}.pdf";

                var saved = await soporteDocumental.GuardarAsync(new DocumentoUploadRequest
                {
                    Modulo = "Contabilidad",
                    SubModulo = "Polizas",
                    Controlador = "Poliza",
                    EntidadId = polizaId,
                    FkidEmpresaSis = empresaId,
                    Titulo = "Documento oficial para firma de poliza",
                    Descripcion = "Generado automaticamente desde el reporte de poliza. Documento protegido: no se puede eliminar.",
                    NombreOriginal = fileName,
                    TipoMime = "application/pdf",
                    TamanoBytes = pdf.LongLength,
                    Contenido = pdf
                }, usuarioActual);

                var document = saved.Data ?? saved.Items.FirstOrDefault();
                if (document == null)
                {
                    await envioWorkflow.CancelAsync(
                        EnvioWorkflowProcesos.PolizaFirma,
                        polizaId,
                        claim.OperationToken.Value);
                    return StatusCode(StatusCodes.Status500InternalServerError, new PagedResult<DocumentoResponse>
                    {
                        Success = false,
                        Code = "DOCUMENT_NOT_CREATED",
                        Message = "No fue posible guardar el reporte oficial de poliza en soporte documental."
                    });
                }

                await firmaStore.ProtectDocumentAsync(new FirmaProtectedDocumentRecord
                {
                    DocumentoId = document.PkidDocumento,
                    TipoProteccion = "POLIZA_OFICIAL_FIRMA",
                    Etiqueta = "Oficial para firma",
                    EntidadOrigen = "Poliza",
                    RegistroOrigenId = polizaId,
                    FkidEmpresaSis = empresaId,
                    UsuarioCreacionId = usuarioActual,
                    FechaProteccionUtc = now
                });

                await envioWorkflow.CompleteAsync(
                    EnvioWorkflowProcesos.PolizaFirma,
                    polizaId,
                    claim.OperationToken.Value);

                document.EsDocumentoFirma = true;
                document.Protegido = true;
                document.TipoProteccion = "POLIZA_OFICIAL_FIRMA";
                document.EtiquetaProteccion = "Oficial para firma";

                saved.Data = document;
                saved.Items = [document];
                saved.TotalCount = 1;
                saved.Message = "Reporte oficial de poliza generado, guardado y enviado a firma.";
                return Ok(saved);
            }
            catch
            {
                try
                {
                    await envioWorkflow.CancelAsync(
                        EnvioWorkflowProcesos.PolizaFirma,
                        polizaId,
                        claim.OperationToken.Value);
                }
                catch
                {
                    // Conserva la excepción original.
                }

                throw;
            }
        }

        [HttpPost("polizas/{polizaId:int}/rechazar-envio")]
        public async Task<ActionResult<PagedResult<bool>>> RechazarEnvioPoliza(
            int polizaId,
            [FromBody] string? motivo = null)
        {
            var exists = await context.Polizas
                .AsNoTracking()
                .AnyAsync(x => x.PkidPoliza == polizaId && x.Activo);
            if (!exists)
            {
                return NotFound(new PagedResult<bool>
                {
                    Success = false,
                    Code = "NOT_FOUND",
                    Message = "La poliza no existe o esta inactiva."
                });
            }

            try
            {
                await envioWorkflow.RejectAsync(
                    EnvioWorkflowProcesos.PolizaFirma,
                    polizaId,
                    userContext.GetCurrentUserId(),
                    motivo);
                return Ok(new PagedResult<bool>
                {
                    Success = true,
                    Code = "SUCCESS",
                    Message = "El envío a firma fue rechazado; la acción quedó habilitada nuevamente.",
                    Data = true,
                    Items = [true],
                    TotalCount = 1
                });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new PagedResult<bool>
                {
                    Success = false,
                    Code = "INVALID_STATUS",
                    Message = ex.Message
                });
            }
        }

        private byte[] ExportPolizaPdf(int polizaId, int usuarioActual, int? empresaId)
        {
            var reportIdentifier = $"{ReportKeys.Poliza}?pk={polizaId}&IdEmpleado={usuarioActual}";
            if (empresaId.HasValue)
            {
                reportIdentifier += $"&IdEmpresa={empresaId.Value}";
            }

            var report = reportProvider.GetReport(reportIdentifier, null!);
            using var stream = new MemoryStream();
            report.CreateDocument();
            report.ExportToPdf(stream);
            return stream.ToArray();
        }
    }

    public class FirmaCertificadoUsuarioFormRequest
    {
        public string? Alias { get; set; }
        public string? Password { get; set; }
        public int? FkidEmpresaSis { get; set; }
        public IFormFile? File { get; set; }
    }
}
